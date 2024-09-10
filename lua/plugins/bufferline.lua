return {
    {
        'akinsho/bufferline.nvim',
        version = "*",
        dependencies = 'nvim-tree/nvim-web-devicons',
        confing = function()
            vim.opt.termguicolors = true
            require("bufferline").setup {}
        end
    }
}
