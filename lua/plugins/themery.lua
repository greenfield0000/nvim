return {
    {
        {
            "zaldih/themery.nvim",
            lazy = false,
            config = function()
                require("themery").setup({
                    -- add the config here
                    themes = { "jb"}, -- Your list of installed colorschemes.
                    livePreview = true,
                })
            end
        }
    }
}
