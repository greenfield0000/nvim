local M = {
    {
        -- Marks
        "chentoast/marks.nvim",
        lazy = true,
        event = "BufEnter",
        config = function()
            -- require("marks").setup({
            --     default_mappings = false,
            --     builtin_marks = { ".", "<", ">", "#", "@", "$" },
            --     -- whether movements cycle back to the beginning/end of buffer. default true
            --     cyclic = true,
            --     -- whether the shada file is updated after modifying uppercase marks. default false
            --     force_write_shada = true,
            --     -- how often (in ms) to redraw signs/recompute mark positions.
            --     refresh_interval = 250,
            --     -- sign priorities for each type of mark - builtin marks, uppercase marks, lowercase
            --     -- marks, and bookmarks.
            --     -- can be either a table with all/none of the keys, or a single number, in which case
            --     -- the priority applies to all marks.
            --     -- default 10.
            --     sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
            --     mappings = {
            --         toggle = "<leader>mm",
            --         set_next = "<leader>mn,",
            --         next = "<leader>m]",
            --         preview = "<leader>m<TAB>",
            --         prev = "<leader>m[",
            --         delete = "<leader>md",
            --         delete_line = "<leader>md;",
            --         delete_buf = "dm<space>"
            --     }
            -- })
        end
    }, }

return M
