return {
    {
        "echasnovski/mini.nvim",
        version = "*",
        config = function()
            require("mini.ai").setup({})

            require("mini.move").setup({})
            require("mini.surround").setup({})
            require("mini.cursorword").setup({})
            -- require("mini.indentscope").setup({})
            local miniTrailspace = require("mini.trailspace")
            miniTrailspace.setup({
                only_in_normal_buffers = true,
            })
            vim.keymap.set("n", "<leader>cw", function() miniTrailspace.trim() end, { desc = "Удалить пробелы в конце строк" })
            require("mini.bufremove").setup({})
            -- require("mini.notify").setup({})
            require("mini.icons").setup({})
            require("mini.animate").setup({})

            -- Split & join
            local miniSplitJoin = require("mini.splitjoin")
            miniSplitJoin.setup({
                mappings = { toggle = "" }, -- Disable default mapping
            })
            vim.keymap.set({ "n", "x" }, "sj", function() miniSplitJoin.join() end, { desc = "Соединить аргументы в одну строку" })
            vim.keymap.set({ "n", "x" }, "sk", function() miniSplitJoin.split() end, { desc = "Разбить аргументы по строкам" })
        end,
    }
}
