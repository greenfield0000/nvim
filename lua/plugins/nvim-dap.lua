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
        -- gain access to the dap ui plugin and its functions
        local dapui = require("dapui")

        -- Setup the dap ui with default configuration
        dapui.setup()

        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end
        --
        -- -- set a vim motion for <Space> + d + t to toggle a breakpoint at the line where the cursor is currently on
        vim.keymap.set("n", "<leader>dt", dap.toggle_breakpoint, { desc = "[D]ebug [T]oggle Breakpoint" })

        -- set a vim motion for <Space> + d + s to start the debugger and launch the debugging ui
        vim.keymap.set("n", "<leader>ds", dap.continue, { desc = "[D]ebug [S]tart" })

        -- set a vim motion to close the debugging ui
        vim.keymap.set("n", "<leader>dc", dapui.close, { desc = "[D]ebug [C]lose" })

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
}
