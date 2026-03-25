---@param config {type?:string, args?:string[]|fun():string[]?}
local function get_args(config)
    local args = type(config.args) == 'function' and (config.args() or {})
        or config.args
        or {} --[[@as string[] | string ]]
    local args_str = type(args) == 'table' and table.concat(args, ' ') or args --[[@as string]]

    config = vim.deepcopy(config)
    ---@cast args string[]
    config.args = function()
        local new_args = vim.fn.expand(vim.fn.input('Run with args: ', args_str)) --[[@as string]]
        if config.type and config.type == 'java' then
            ---@diagnostic disable-next-line: return-type-mismatch
            return new_args
        end
        return require('dap.utils').splitstr(new_args)
    end
    return config
end


local function setup_common(dap)
    local dapui = require("dapui")
    -- Auto open/close DAP UI
    dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
    end

    -- Initialize DAP UI
    dapui.setup({
        layouts = {
            {
                elements = {
                    "scopes",
                    "watches",
                },
                size = 40,
                position = "right"
            },
            {
                elements = {
                    "console"
                },
                size = 0.30,
                position = "bottom"
            }
        }
    })
end

local function setup_golang(dap)
    -- Set up nvim-dap-go
    require("dap-go").setup({
        -- Optional: customize delve settings
        delve = {
            path = "dlv",                -- Path to dlv executable
            initialize_timeout_sec = 20, -- Timeout for dlv to start
            port = "${port}",            -- Use random port by default
            args = {},                   -- Additional args to dlv
            build_flags = "",            -- Build flags (e.g., "-tags=integration")
            detached = true,             -- Run dlv in detached mode
        },
        -- Optional: add custom dap configurations
        dap_configurations = {
            {
                type = "go",
                name = "Attach remote",
                mode = "remote",
                request = "attach",
            },
        },
    })

    -- Optional: Fix for REPL output issues in some versions
    -- See: https://github.com/mfussenegger/nvim-dap/issues/1454
    -- Add this if you experience missing debug output
    dap.configurations.go = vim.list_extend(dap.configurations.go or {}, {
        {
            type = "go",
            name = "Debug (outputMode remote)",
            request = "launch",
            program = "${file}",
            outputMode = "remote", -- Workaround for REPL output issues
        },
    })
end

local function setup_java(dap)
    -- Java configurations
    dap.configurations.java = {
        {
            type = "java",
            request = "attach",
            name = "Attach to Java Process (Port 5005)",
            hostName = "localhost",
            port = 5005,
        },
        {
            type = "java",
            request = "attach",
            name = "Attach to Java Process (Port 5006)",
            hostName = "localhost",
            port = 5006,
        },
        {
            type = "java",
            request = "attach",
            name = "Attach to Remote Java Process with custom port",
            hostName = "localhost",
            port = function()
                return tonumber(vim.fn.input('Port: ', '9229'))
            end,
        },
    }
end

return {
    {
        'mfussenegger/nvim-dap',
        recommended = true,
        desc = 'Debugging support. Requires language specific adapters to be configured. (see lang extras)',

        dependencies = {
            'rcarriga/nvim-dap-ui',
            -- virtual text for the debugger
            {
                'theHamsta/nvim-dap-virtual-text',
                opts = {
                    virt_text_win_col = 80,
                },
            },
        },

        -- stylua: ignore
        keys = {
            { "<leader>da", function() require("dap").continue({ before = get_args }) end,                        desc = "Run with Args" },
            { "<leader>db", function() require("dap").toggle_breakpoint() end,                                    desc = "Toggle Breakpoint" },
            { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
            { "<leader>dC", function() require("dap").run_to_cursor() end,                                        desc = "Run to Cursor" },
            { "<leader>dc", function() require("dap").continue() end,                                             desc = "Run/Continue" },
            { "<leader>de", function() require("dapui").eval() end,                                               desc = "Evaluate" },
            { "<leader>dg", function() require("dap").goto_() end,                                                desc = "Go to Line (No Execute)" },
            { "<leader>di", function() require("dap").step_into() end,                                            desc = "Step Into" },
            { "<leader>dj", function() require("dap").down() end,                                                 desc = "Down" },
            { "<leader>dk", function() require("dap").up() end,                                                   desc = "Up" },
            { "<leader>dl", function() require("dap").run_last() end,                                             desc = "Run Last" },
            { "<leader>do", function() require("dap").step_over() end,                                            desc = "Step Over" },
            { "<leader>dO", function() require("dap").step_out() end,                                             desc = "Step Out" },
            { "<leader>dP", function() require("dap").pause() end,                                                desc = "Pause" },
            { "<leader>dr", function() require("dap").repl.toggle() end,                                          desc = "Toggle REPL" },
            { "<leader>ds", function() require("dap").session() end,                                              desc = "Session" },
            { "<leader>dt", function() require("dap").terminate() end,                                            desc = "Terminate" },
            { "<leader>du", function() require("dapui").toggle() end,                                             desc = "Toggle DAPUI" },
            { "<leader>dw", function() require("dap.ui.widgets").hover() end,                                     desc = "Widgets" },
        },

        config = function()
            -- load mason-nvim-dap here, after all adapters have been setup
            local mason_nvim_dap = require('lazy.core.config').spec.plugins['mason-nvim-dap.nvim']
            local Plugin = require 'lazy.core.plugin'
            local mason_nvim_dap_opts = Plugin.values(mason_nvim_dap, 'opts', false)
            require('mason-nvim-dap').setup(mason_nvim_dap_opts)

            vim.api.nvim_set_hl(
                0,
                'DapStoppedLine',
                { default = true, link = 'Visual' }
            )

            local dap_icons = {
                Stopped = { '󰁕 ', 'DiagnosticWarn', 'DapStoppedLine' },
                Breakpoint = ' ',
                BreakpointCondition = ' ',
                BreakpointRejected = { ' ', 'DiagnosticError' },
                LogPoint = '.>',
            }
            for name, sign in pairs(dap_icons) do
                sign = type(sign) == 'table' and sign or { sign }
                vim.fn.sign_define('Dap' .. name, {
                    text = sign[1],
                    texthl = sign[2] or 'DiagnosticInfo',
                    linehl = sign[3],
                    numhl = sign[3],
                })
            end

            -- setup dap config by VsCode launch.json file
            local vscode = require 'dap.ext.vscode'
            local json = require 'plenary.json'
            vscode.json_decode = function(str)
                return vim.json.decode(json.json_strip_comments(str))
            end
        end,
    },

    -- mason.nvim integration
    -- Complete setup with nvim-dap-ui
    {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = {
            "leoluz/nvim-dap-go",
            'nvim-neotest/nvim-nio',
            "williamboman/mason.nvim",
            "mfussenegger/nvim-dap",
            "rcarriga/nvim-dap-ui",
        },
        config = function()
            require("mason-nvim-dap").setup({
                ensure_installed = { "java-debug-adapter", "java-test" },
                automatic_installation = true,
            })

            local dap = require("dap")

            setup_java(dap)   -- java
            setup_golang(dap) -- golang
            setup_common(dap)
        end,
    },
}
