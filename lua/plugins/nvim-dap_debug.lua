return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        "theHamsta/nvim-dap-virtual-text",
        "williamboman/mason-nvim-dap.nvim",
        "mfussenegger/nvim-jdtls",
        "williamboman/mason.nvim",
    },
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")

        -- Правильная настройка DAP UI
        dapui.setup({
            icons = { expanded = "▾", collapsed = "▸" },
            mappings = {
                expand = { "<CR>", "<2-LeftMouse>" },
                open = "o",
                remove = "d",
                edit = "e",
                repl = "r",
                toggle = "t",
            },
            expand_lines = true,
            layouts = {
                {
                    elements = {
                        { id = "scopes", size = 0.35 },
                        { id = "breakpoints", size = 0.15 },
                        { id = "stacks", size = 0.25 },
                        { id = "watches", size = 0.25 },
                    },
                    position = "right",
                    size = 40,
                },
                {
                    elements = {
                        { id = "repl", size = 0.8 },
                        { id = "console", size = 0.2 },
                    },
                    position = "bottom",
                    size = 15,
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
        })

        -- Автоматическое открытие/закрытие UI
        dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open({})
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close({})
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close({})
        end

        -- Значки для отладки
        vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = 'Error', linehl = '', numhl = '' })
        vim.fn.sign_define('DapBreakpointCondition', { text = '🔵', texthl = 'WarningMsg', linehl = '', numhl = '' })
        vim.fn.sign_define('DapLogPoint', { text = '📝', texthl = 'Info', linehl = '', numhl = '' })
        vim.fn.sign_define('DapStopped', { text = '→', texthl = 'MatchParen', linehl = 'CursorLine', numhl = '' })

        -- Клавиши для отладки
        local keymap = vim.keymap.set

        keymap('n', '<F5>', function() require('dap').continue() end, { desc = 'Debug: Continue' })
        keymap('n', '<F6>', function() require('dap').pause() end, { desc = 'Debug: Pause' })
        keymap('n', '<F7>', function() require('dap').step_into() end, { desc = 'Debug: Step Into' })
        keymap('n', '<F8>', function() require('dap').step_over() end, { desc = 'Debug: Step Over' })
        keymap('n', '<S-F8>', function() require('dap').step_out() end, { desc = 'Debug: Step Out' })
        keymap('n', '<F9>', function() require('dap').toggle_breakpoint() end, { desc = 'Debug: Toggle Breakpoint' })
        keymap('n', '<leader>db', function() require('dap').toggle_breakpoint() end, { desc = 'Debug: Toggle Breakpoint' })
        keymap('n', '<leader>dB', function()
            require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
        end, { desc = 'Debug: Conditional Breakpoint' })
        keymap('n', '<F10>', function() require('dap').run_to_cursor() end, { desc = 'Debug: Run to Cursor' })
        keymap('n', '<F11>', function() require('dap').terminate() end, { desc = 'Debug: Stop' })

        -- UI управления
        keymap('n', '<leader>du', function() require('dapui').toggle() end, { desc = 'Debug: Toggle UI' })
        keymap('n', '<leader>dr', function() require('dap').repl.toggle() end, { desc = 'Debug: Toggle REPL' })

        -- Инициализация конфигураций для языков
        -- golang_debug_setting(dap)
        -- java_debug_setting(dap)

        vim.notify("Debug configuration loaded successfully!", vim.log.levels.INFO)
    end
}
