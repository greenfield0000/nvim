return {
    {
        "echasnovski/mini.nvim",
        version = "*",
        config = function()
            require("mini.ai").setup({})
            require("mini.comment").setup({})
            require("mini.move").setup({})
            require("mini.surround").setup({})
            require("mini.cursorword").setup({})
            -- require("mini.indentscope").setup({})
            require("mini.pairs").setup({})
            require("mini.trailspace").setup({})
            require("mini.bufremove").setup({})
            -- require("mini.notify").setup({})
            require("mini.icons").setup({})
            require("mini.animate").setup({})
        end
    },
    {
        "echasnovski/mini.trailspace",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            local miniTrailspace = require("mini.trailspace")

            miniTrailspace.setup({
                only_in_normal_buffers = true,
            })
            vim.keymap.set("n", "<leader>cw", function() miniTrailspace.trim() end, { desc = "Erase Whitespace" })

            -- Ensure highlight never reappears by removing it on CursorMoved
            vim.api.nvim_create_autocmd("CursorMoved", {
                pattern = "*",
                callback = function()
                    -- require("mini.trailspace").unhighlight()
                end,
            })
        end,
    },
    -- Split & join
    {
        "echasnovski/mini.splitjoin",
        config = function()
            local miniSplitJoin = require("mini.splitjoin")
            miniSplitJoin.setup({
                mappings = { toggle = "" }, -- Disable default mapping
            })
            vim.keymap.set({ "n", "x" }, "sj", function() miniSplitJoin.join() end, { desc = "Join arguments" })
            vim.keymap.set({ "n", "x" }, "sk", function() miniSplitJoin.split() end, { desc = "Split arguments" })
        end,
    }
}
