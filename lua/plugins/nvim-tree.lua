return {
    "nvim-tree/nvim-tree.lua",
    enabled = true,
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
        local nvimtree = require("nvim-tree")

        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1

        nvimtree.setup({
            update_focused_file = {
                enable = true,
                update_root = true,

            },
            hijack_directories = {
                enable = true,     -- Set this to false if you want to disable it
                auto_open = false, -- Automatically open the tree when switching to a directory
            },
            view = {
                width = 70,
                relativenumber = true,
                side = "right",
            },
            -- change folder arrow icons
            renderer = {
                indent_width = 2,
                indent_markers = {
                    enable = false,
                },
                icons = {
                    glyphs = {
                        folder = {
                            arrow_closed = "→", -- arrow when folder is closed
                            arrow_open = "↓", -- arrow when folder is open
                        },
                    },
                },
            },
            -- disable window_picker for
            -- explorer to work well with
            -- window splits
            actions = {
                open_file = {
                    window_picker = {
                        enable = true,
                    },
                },
            },
            filters = {
                custom = { ".DS_Store" },
            },
            git = {
                ignore = false,
            },
        })

        -- ** Opens nvim file tree at start
        -- if vim.fn.argc(-1) == 0 then
        --     vim.cmd("NvimTreeFocus")
        -- end

        -- keymaps
        local keymap = vim
        .keymap                                                                                    -- for conciseness

        keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" }) -- toggle file explorer
        -- keymap.set("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>",
        --     { desc = "Toggle file explorer on current file" })                                          -- toggle file explorer on current file
        -- keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" }) -- collapse file explorer
        keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" }) -- refresh file explorer
    end
}
