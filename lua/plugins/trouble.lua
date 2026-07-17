-- better diagnostics list and others
return { {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    opts = {
        modes = {
            symbols = {
                win = {
                    type = "split",     -- split window
                    relative = "win",   -- relative to current window
                    position = "right", -- right side
                    size = 0.5,         -- 50% of the window,
                },
            },
        },
    },
    keys = {
        { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Trouble: диагностики" },
        { "<leader>cs", "<cmd>Trouble symbols toggle<cr>",                  desc = "Trouble: символы" },
        { "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                  desc = "Trouble: location list" },
        { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",                   desc = "Trouble: quickfix list" },
        {
            "[q",
            function()
                if require("trouble").is_open() then
                    require("trouble").prev({ skip_groups = true, jump = true })
                else
                    local ok, err = pcall(vim.cmd.cprev)
                    if not ok then
                        vim.notify(err, vim.log.levels.ERROR)
                    end
                end
            end,
            desc = "Предыдущий Trouble/Quickfix",
        },
        {
            "]q",
            function()
                if require("trouble").is_open() then
                    require("trouble").next({ skip_groups = true, jump = true })
                else
                    local ok, err = pcall(vim.cmd.cnext)
                    if not ok then
                        vim.notify(err, vim.log.levels.ERROR)
                    end
                end
            end,
            desc = "Следующий Trouble/Quickfix",
        },
    },
}, }
