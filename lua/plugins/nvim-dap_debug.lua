local function java_debug_setting(dap)
    -- add debug configurations 4 java
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
    -- add debug configurations 4 java
    dap.configurations.go = {
        {
            type = 'go',
            request = 'launch',
            name = "Debug (Attach) - Remote 5005",
            program = "${file}",
        },
        {
            type = 'go',
            request = 'launch',
            name = "Debug (Attach) - Remote 5006",
            program = "${file}",
        },
    }
end


return {
    "mfussenegger/nvim-dap",
    dependencies = {
        -- ui plugins to make debugging simplier
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        {
            "theHamsta/nvim-dap-virtual-text",
            opts = {},
        },
    },
    config = function()
        -- gain access to the dap plugin and its functions
        local dap = require("dap")
        dap.adapters.go = {
            type = "server",
            port = "${port}",
            executable = {
                command = vim.fn.stdpath("data") .. '/mason/bin/dlv',
                args = { "dap", "-l", "127.0.0.1:${port}" },
            },
        }
        -- gain access to the dap ui plugin and its functions
        local dapui = require("dapui")
        -- Setup the dap ui with default configuration
        dapui.setup({
            icons = { expanded = "▾", collapsed = "▸" },
            mappings = {
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
                        "scopes",
                    },
                    size = 0.3,
                    position = "right"
                },
                {
                    elements = {
                        "repl",
                        "breakpoints"
                    },
                    size = 0.3,
                    position = "bottom",
                },
            },
            floating = {
                max_height = nil,
                max_width = nil,
                border = "single",
                mappings = {
                    close = { "q", "<Esc>" },
                },
            },
            windows = { indent = 1 },
            render = {
                max_type_length = nil,
            },
        })
        vim.fn.sign_define('DapBreakpoint', { text = '🐞' })
        -- Start debugging session
        vim.keymap.set("n", "<localleader>ds", function()
            dap.continue()
            dapui.toggle({})
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>=", false, true, true), "n", false) -- Spaces buffers evenly
        end)

        -- Set breakpoints, get variable values, step into/out of functions, etc.
        vim.keymap.set("n", "<localleader>dl", require("dap.ui.widgets").hover)
        vim.keymap.set("n", "<localleader>dc", dap.continue)
        vim.keymap.set("n", "<localleader>db", dap.toggle_breakpoint)
        vim.keymap.set("n", "<localleader>dn", dap.step_over)
        vim.keymap.set("n", "<localleader>di", dap.step_into)
        vim.keymap.set("n", "<localleader>do", dap.step_out)
        vim.keymap.set("n", "<localleader>dC", function()
            dap.clear_breakpoints()
            require("notify")("Breakpoints cleared", "warn")
        end)

        -- Close debugger and clear breakpoints
        vim.keymap.set("n", "<localleader>de", function()
            dap.clear_breakpoints()
            dapui.toggle({})
            dap.terminate()
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>=", false, true, true), "n", false)
            require("notify")("Debugger session ended", "warn")
        end)
        java_debug_setting(dap)   -- java debug setting
        golang_debug_setting(dap) -- golang debug setting
    end


}
