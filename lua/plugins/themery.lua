return {
    {
        {
            "nickkadutskyi/jb.nvim",
            lazy = false,
            priority = 1000,
            opts = {},
            config = function()
                -- require("jb").setup({transparent = true})
            end,
        },

        {
            "xiantang/darcula-dark.nvim",
            config = function()
                -- setup must be called before loading
                require("darcula").setup({
                    override = function(_)
                        return {
                            background = "#333333",
                            dark = "#000000"
                        }
                    end,
                    opt = {
                        integrations = {
                            telescope = false,
                            lualine = true,
                            lsp_semantics_token = true,
                            nvim_cmp = true,
                            dap_nvim = true,
                        },
                    },
                })
            end,
        },
        {
            "zaldih/themery.nvim",
            lazy = false,
            config = function()
                require("themery").setup({
                    -- add the config here
                    themes = { "jb", "darcula-dark", "tokyonight" }, -- Your list of installed colorschemes.
                    livePreview = true,
                })
            end
        }
    }
}
