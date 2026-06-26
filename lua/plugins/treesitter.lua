return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,

    dependencies = {
        "windwp/nvim-ts-autotag",
    },

    config = function()
        -- включаем autotag отдельно
        require("nvim-ts-autotag").setup()

        -- включаем highlight вручную
        vim.api.nvim_create_autocmd("FileType", {
            pattern = {
                "vim",
                "go",
                "vimdoc",
                "lua",
                "java",
                "javascript",
                "typescript",
                "html",
                "css",
                "json",
                "tsx",
                "gitignore",
                "sql",
            },
            callback = function()
                pcall(vim.treesitter.start)
            end,
        })

        -- -- авто-установка парсеров (новый API)
        -- vim.api.nvim_create_autocmd("FileType", {
        --     callback = function(args)
        --         local lang = vim.treesitter.language.get_lang(args.match)
        --         if lang and not vim.treesitter.language.inspect(lang) then
        --             vim.cmd("TSInstall " .. lang)
        --         end
        --     end,
        -- })
    end,
}
