local function java_debug_setting(dap)
    dap.configurations.java = {
        {
            type = 'java',
            request = 'attach',
            name = "Debug (Attach) - Remote 5005",
            hostName = "127.0.0.1",
            port = 5005,
        },
        {
            type = 'java',
            request = 'attach',
            name = "Debug (Attach) - Remote 5006",
            hostName = "127.0.0.1",
            port = 5006,
        },
    }
end

local function golang_debug_setting(dap)
    dap.configurations.go = {
        {
            type = 'go',
            name = "Debug (Launch) - Current File",
            request = 'launch',
            program = "${file}",
        },
        {
            type = 'go',
            name = "Debug (Launch) - Package",
            request = 'launch',
            program = "${fileDirname}",
        },
        {
            type = 'go',
            name = "Debug (Attach) - Remote 5005",
            request = 'attach',
            mode = 'remote',
            port = 5005,
            host = "127.0.0.1",
        },
    }
end

return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        {
            "theHamsta/nvim-dap-virtual-text",
            opts = {},
        },
        -- Добавляем адаптеры для автоматической установки
        {
            "williamboman/mason-nvim-dap.nvim",
            opts = {
                automatic_installation = true,
                handlers = {},
            }
        },
        -- Интеграция с which-key
        {
            "folke/which-key.nvim",
            optional = true,
            opts = {
                defaults = {
                    ["<leader>d"] = { name = "+debug" },
                },
            },
        },
    },
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")

        -- Настройка адаптера для Go
        dap.adapters.go = {
            type = "server",
            port = "${port}",
            executable = {
                command = vim.fn.stdpath("data") .. '/mason/bin/dlv',
                args = { "dap", "-l", "127.0.0.1:${port}" },
            },
        }

        -- Автоматическое открытие/закрытие DAP UI
        dap.listeners.before.attach.dapui_config = function()
            dapui.open({})
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open({})
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close({})
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close({})
        end

        -- Настройка DAP UI
        dapui.setup({
            icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
            mappings = {
                expand = { "<CR>", "<2-LeftMouse>" },
                open = "o",
                remove = "d",
                edit = "e",
                repl = "r",
                toggle = "t",
            },
            expand_lines = vim.fn.has("nvim-0.7"),
            layouts = {
                {
                    elements = {
                        { id = "scopes",      size = 0.3 },
                        { id = "breakpoints", size = 0.2 },
                        { id = "stacks",      size = 0.2 },
                        { id = "watches",     size = 0.3 },
                    },
                    size = 0.3,
                    position = "right"
                },
                {
                    elements = {
                        { id = "repl",    size = 0.8 },
                        { id = "console", size = 0.2 },
                    },
                    size = 0.3,
                    position = "bottom",
                },
            },
            controls = {
                enabled = true,
                element = "repl",
                icons = {
                    pause = "⏸",
                    play = "▶",
                    step_into = "⏎",
                    step_over = "⏭",
                    step_out = "⏮",
                    step_back = "b",
                    run_last = "▶▶",
                    terminate = "⏹",
                },
            },
            floating = {
                max_height = 0.9,
                max_width = 0.5,
                border = "single",
                mappings = {
                    close = { "q", "<Esc>" },
                },
            },
            windows = { indent = 1 },
            render = {
                max_type_length = nil,
                max_value_lines = 100,
            },
        })

        -- Значки для точек остановки
        vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = '', linehl = '', numhl = '' })
        vim.fn.sign_define('DapStopped', { text = '→', texthl = '', linehl = '', numhl = '' })
        vim.fn.sign_define('DapBreakpointRejected', { text = '🔶', texthl = '', linehl = '', numhl = '' })
        vim.fn.sign_define('DapBreakpointCondition', { text = '🔵', texthl = '', linehl = '', numhl = '' })

        -- Клавиши для отладки как в IntelliJ IDEA
        local keymap = vim.keymap.set

        -- F8 - Step Over (как в IDEA)
        keymap("n", "<F8>", dap.step_over, { desc = "Debug: Step Over" })

        -- F7 - Step Into (как в IDEA)
        keymap("n", "<F7>", dap.step_into, { desc = "Debug: Step Into" })

        -- Shift+F8 - Step Out (как в IDEA)
        keymap("n", "<S-F8>", dap.step_out, { desc = "Debug: Step Out" })

        -- F9 - Resume Program/Continue (как в IDEA)
        keymap("n", "<F9>", function()
            dap.continue()
        end, { desc = "Debug: Resume Program" })

        -- Ctrl+F2 - Stop (как в IDEA)
        keymap("n", "<C-F2>", function()
            dap.terminate()
            vim.notify("Debugger session ended", vim.log.levels.WARN)
        end, { desc = "Debug: Stop Debugging" })

        -- Ctrl+F8 - Toggle Breakpoint (как в IDEA)
        keymap("n", "<C-F8>", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })

        -- Ctrl+Shift+F8 - View Breakpoints
        keymap("n", "<C-S-F8>", function()
            dapui.open({ reset = true })
            vim.schedule(function()
                local wins = vim.api.nvim_list_wins()
                for _, win in ipairs(wins) do
                    local buf = vim.api.nvim_win_get_buf(win)
                    local buf_name = vim.api.nvim_buf_get_name(buf)
                    if string.find(buf_name, "breakpoints") then
                        vim.api.nvim_set_current_win(win)
                        break
                    end
                end
            end)
        end, { desc = "Debug: View Breakpoints" })

        -- Alt+F8 - Evaluate Expression
        keymap("n", "<A-F8>", require("dap.ui.widgets").hover, { desc = "Debug: Evaluate Expression" })

        -- Alt+F9 - Run to Cursor
        keymap("n", "<A-F9>", function()
            dap.run_to_cursor()
        end, { desc = "Debug: Run to Cursor" })

        -- Alt+F10 - Show Execution Point
        keymap("n", "<A-F10>", function()
            dap.focus_frame()
        end, { desc = "Debug: Show Execution Point" })

        -- Дополнительные маппинги для which-key
        local wk = require("which-key")
        wk.register({
            d = {
                name = "Debug",
                -- Основные команды отладки
                s = { function() dap.continue() end, "Start/Continue Debugging" },
                c = { dap.continue, "Continue" },
                n = { dap.step_over, "Step Over" },
                i = { dap.step_into, "Step Into" },
                o = { dap.step_out, "Step Out" },
                b = { dap.toggle_breakpoint, "Toggle Breakpoint" },
                B = { function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, "Conditional Breakpoint" },
                C = { function()
                    dap.clear_breakpoints()
                    vim.notify("Breakpoints cleared", vim.log.levels.WARN)
                end, "Clear Breakpoints" },
                e = { function()
                    dap.terminate()
                    dapui.toggle({})
                end, "End Debug Session" },

                -- UI управления
                u = { dapui.toggle, "Toggle DAP UI" },
                r = { dap.repl.toggle, "Toggle REPL" },
                l = { require("dap.ui.widgets").hover, "Show Variable Value" },

                -- Дополнительные функции
                t = { function() dap.run_to_cursor() end, "Run to Cursor" },
                f = { function() dap.focus_frame() end, "Focus Frame" },
                R = { function() dap.restart_frame() end, "Restart Frame" },

                -- Конфигурации
                j = { function() require('dap').run_last() end, "Run Last Configuration" },
                k = { function() require('dap').disconnect() end, "Disconnect" },
            },
        }, { prefix = "<leader>" })

        -- Также добавим маппинги для localleader если нужно
        wk.register({
            d = {
                name = "Debug (Local)",
                s = { function()
                    dap.continue()
                    dapui.toggle({})
                end, "Start Debug with UI" },
                u = { dapui.toggle, "Toggle DAP UI" },
                r = { dap.repl.toggle, "Toggle REPL" },
                l = { require("dap.ui.widgets").hover, "Show Variable Value" },
                C = { function()
                    dap.clear_breakpoints()
                    vim.notify("Breakpoints cleared", vim.log.levels.WARN)
                end, "Clear Breakpoints" },
            },
        }, { prefix = "<localleader>" })

        -- Регистрируем F-клавиши в which-key
        wk.register({
            ["<F7>"] = "Debug: Step Into",
            ["<F8>"] = "Debug: Step Over",
            ["<S-F8>"] = "Debug: Step Out",
            ["<F9>"] = "Debug: Resume Program",
            ["<C-F2>"] = "Debug: Stop Debugging",
            ["<C-F8>"] = "Debug: Toggle Breakpoint",
            ["<C-S-F8>"] = "Debug: View Breakpoints",
            ["<A-F8>"] = "Debug: Evaluate Expression",
            ["<A-F9>"] = "Debug: Run to Cursor",
            ["<A-F10>"] = "Debug: Show Execution Point",
        })

        -- Инициализация конфигураций для языков
        java_debug_setting(dap)
        golang_debug_setting(dap)

        -- Уведомление о доступных клавишах
        vim.notify("IDEA-style debug mappings loaded with which-key support", vim.log.levels.INFO)
    end
}
