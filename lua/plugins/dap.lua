return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "theHamsta/nvim-dap-virtual-text",
            "nvim-telescope/telescope-dap.nvim",
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            -- === Конфигурация Java DAP ====================
            dap.adapters.java = {
                type = 'server',
                host = '127.0.0.1',
                port = 5005,
            }

            dap.adapters.java5006 = {
                type = 'server',
                host = '127.0.0.1',
                port = 5006,
            }

            dap.configurations.java = {
                {
                    type = 'java',
                    request = 'attach',
                    name = 'Attach to remote (port 5005)',
                    hostName = 'localhost',
                    port = 5005,
                    projectName = function()
                        return vim.fn.input('Project name: ', vim.fn.fnamemodify(vim.fn.getcwd(), ':t'), 'file')
                    end,
                },
                {
                    type = 'java',
                    request = 'attach',
                    name = 'Attach to remote (port 5006)',
                    hostName = 'localhost',
                    port = 5006,
                    projectName = function()
                        return vim.fn.input('Project name: ', vim.fn.fnamemodify(vim.fn.getcwd(), ':t'), 'file')
                    end,
                },
                {
                    type = 'java',
                    request = 'attach',
                    name = 'Attach to custom host',
                    hostName = function()
                        return vim.fn.input('Host: ', 'localhost', 'file')
                    end,
                    port = function()
                        return tonumber(vim.fn.input('Port: ', '5005', 'file'))
                    end,
                }
            }

            -- === Автозагрузка launch.json ====================
            local function load_launch_json()
                local launchjs = vim.fn.getcwd() .. "/.vscode/launch.json"
                if vim.fn.filereadable(launchjs) == 1 then
                    local status, _ = pcall(require("dap.ext.vscode").load_launchjs, launchjs, { java = { "java" } })
                    if status then
                        vim.notify("Loaded launch.json configurations", vim.log.levels.INFO)
                    end
                end
            end

            -- === Инициализация DAP UI ====================
            dapui.setup({
                controls = {
                    element = "repl",
                    enabled = true,
                    icons = {
                        disconnect = "",
                        pause = "",
                        play = "",
                        run_last = "",
                        step_back = "",
                        step_into = "",
                        step_out = "",
                        step_over = "",
                        terminate = ""
                    }
                },
                element_mappings = {},
                expand_lines = true,
                floating = {
                    border = "rounded",
                    mappings = {
                        close = { "q", "<Esc>" }
                    }
                },
                force_buffers = true,
                icons = {
                    collapsed = "",
                    current_frame = "",
                    expanded = ""
                },
                layouts = {
                    {
                        elements = {
                            { id = "scopes",      size = 0.25 },
                            { id = "breakpoints", size = 0.25 },
                            { id = "stacks",      size = 0.25 },
                            { id = "watches",     size = 0.25 }
                        },
                        position = "left",
                        size = 40
                    },
                    {
                        elements = {
                            { id = "repl",    size = 0.5 },
                            { id = "console", size = 0.5 }
                        },
                        position = "bottom",
                        size = 10
                    }
                },
                mappings = {
                    edit = "e",
                    expand = { "<CR>", "<2-LeftMouse>" },
                    open = "o",
                    remove = "d",
                    repl = "r",
                    toggle = "t"
                },
                render = {
                    indent = 1,
                    max_value_lines = 100
                }
            })

            -- === Автоматизация DAP UI ====================
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end

            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end

            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end

            -- === Горячие клавиши DAP ====================
            local keymap = vim.keymap.set
            local opts = { noremap = true, silent = true }

            -- Основные команды отладки
            keymap('n', '<F5>', function()
                if dap.session() then
                    dap.continue()
                else
                    load_launch_json()
                    vim.defer_fn(function()
                        if dap.configurations.java and #dap.configurations.java > 0 then
                            dap.run_last()
                        else
                            vim.notify("No DAP configurations found", vim.log.levels.WARN)
                        end
                    end, 100)
                end
            end, opts)

            keymap('n', '<F6>', function() dap.pause() end, opts)
            keymap('n', '<S-F5>', function() dap.restart() end, opts)
            keymap('n', '<C-F5>', function() dap.terminate() end, opts)

            -- Step commands
            keymap('n', '<F10>', function() dap.step_over() end, opts)
            keymap('n', '<F11>', function() dap.step_into() end, opts)
            keymap('n', '<F12>', function() dap.step_out() end, opts)

            -- Breakpoints
            keymap('n', '<F9>', function() dap.toggle_breakpoint() end, opts)
            keymap('n', '<leader>db', function() dap.toggle_breakpoint() end, opts)
            keymap('n', '<leader>dB', function()
                dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
            end, opts)
            keymap('n', '<leader>dl', function()
                dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
            end, opts)
            keymap('n', '<leader>dC', function() dap.clear_breakpoints() end, opts)

            -- Быстрое подключение к портам
            keymap('n', '<leader>d5', function()
                dap.run({
                    type = 'java',
                    request = 'attach',
                    name = 'Quick attach 5005',
                    hostName = 'localhost',
                    port = 5005,
                })
            end, { desc = 'Attach to port 5005' })

            keymap('n', '<leader>d6', function()
                dap.run({
                    type = 'java',
                    request = 'attach',
                    name = 'Quick attach 5006',
                    hostName = 'localhost',
                    port = 5006,
                })
            end, { desc = 'Attach to port 5006' })

            keymap('n', '<leader>da', function()
                local port = vim.fn.input('Port: ', '5005')
                dap.run({
                    type = 'java',
                    request = 'attach',
                    name = 'Custom attach',
                    hostName = 'localhost',
                    port = tonumber(port),
                })
            end, { desc = 'Attach to custom port' })

            -- UI и информация
            keymap('n', '<leader>dui', function() dapui.toggle() end, opts)
            keymap('n', '<leader>duh', function() require('dap.ui.widgets').hover() end, opts)
            keymap('n', '<leader>dup', function() require('dap.ui.widgets').preview() end, opts)
            keymap('n', '<leader>duf', function()
                local widgets = require('dap.ui.widgets')
                widgets.centered_float(widgets.frames)
            end, opts)
            keymap('n', '<leader>dus', function()
                local widgets = require('dap.ui.widgets')
                widgets.centered_float(widgets.scopes)
            end, opts)

            -- Управление подключениями
            keymap('n', '<leader>dD', function() dap.disconnect() end, opts)
            keymap('n', '<leader>dr', function() dap.repl.open() end, opts)
            keymap('n', '<leader>dR', function() dap.repl.toggle() end, opts)

            -- Значки для точек останова
            vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
            vim.fn.sign_define('DapBreakpointCondition',
                { text = '⚫', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
            vim.fn.sign_define('DapBreakpointRejected', { text = '❌', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
            vim.fn.sign_define('DapLogPoint', { text = '📝', texthl = 'DapLogPoint', linehl = '', numhl = '' })
            vim.fn.sign_define('DapStopped',
                { text = '👉', texthl = 'DapStopped', linehl = 'DapStoppedLine', numhl = 'DapStoppedNum' })

            -- Автозагрузка launch.json при входе в Java buffer
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "java",
                callback = function()
                    vim.defer_fn(load_launch_json, 500)
                end
            })

            vim.notify("DAP configuration loaded for Java remote debugging")
        end
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
        config = true
    },
    {
        "theHamsta/nvim-dap-virtual-text",
        dependencies = { "mfussenegger/nvim-dap" },
        config = true
    },
    {
        "nvim-telescope/telescope-dap.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim",
            "mfussenegger/nvim-dap"
        },
        config = function()
            require("telescope").load_extension("dap")
        end
    }
}
