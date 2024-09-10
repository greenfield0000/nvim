return {
    'folke/which-key.nvim',
    event = 'VimEnter',
    config = function()
        -- gain access to the which key plugin
        local which_key = require('which-key')

        -- call the setup function with default properties
        which_key.setup()

    --     -- Register prefixes for the different key mappings we have setup previously
    --     which_key.add({
    --         ["<leader>/"] = {
    --             _ = "which_key_ignore",
    --             name = "Comments"
    --         },
    --         ["<leader>J"] = {
    --             _ = "which_key_ignore",
    --             name = "[J]ava"
    --         },
    --         ["<leader>c"] = {
    --             _ = "which_key_ignore",
    --             name = "[C]ode"
    --         },
    --         ["<leader>d"] = {
    --             _ = "which_key_ignore",
    --             name = "[D]ebug"
    --         },
    --         ["<leader>e"] = {
    --             _ = "which_key_ignore",
    --             name = "[E]xplorer"
    --         },
    --         ["<leader>f"] = {
    --             _ = "which_key_ignore",
    --             name = "[F]ind"
    --         },
    --         ["<leader>g"] = {
    --             _ = "which_key_ignore",
    --             name = "[G]it"
    --         },
    --         ["<leader>t"] = {
    --             _ = "which_key_ignore",
    --             name = "[T]ab"
    --         },
    --         ["<leader>w"] = {
    --             _ = "which_key_ignore",
    --             name = "[W]indow"
    --         }
    --     })
    end
}
