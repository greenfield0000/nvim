return {
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-ui-select.nvim",
            "nvim-telescope/telescope-fzf-native.nvim",
        },
        config = function()
            local builtin = require("telescope.builtin")

            -- Key mappings
            vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[f]ind [f]iles" })
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[f]ind by [g]rep" })
            vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "[f]ind [d]iagnostics" })
            vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "[f]inder [r]esume" })
            vim.keymap.set("n", "<leader>f.", builtin.oldfiles, { desc = '[f]ind Recent Files ("." for repeat)' })
            vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[f]ind Existing [b]uffers" })
            vim.keymap.set("n", "<leader>fc", builtin.colorscheme, { desc = "[f]ind [c]olorscheme" })
            vim.keymap.set("n", "<leader>fB", builtin.git_branches, { desc = "[f]ind Git [B]ranch" })
            vim.keymap.set("n", "<leader>fs", builtin.git_status, { desc = "[f]ind Git [s]tatus" })
            vim.keymap.set("n", "<leader>fS", builtin.git_stash, { desc = "[f]ind Git [S]tash" })
            vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = '[f]ind [h]elp tags' })
            vim.keymap.set('n', '<leader>fp', function() require("telescope").extensions.projects.projects() end,
                { desc = '[f]ind [p]rojects' })

            local actions = require("telescope.actions")
            local icons = require("icons")

            -- Setup Telescope
            require("telescope").setup({
                defaults = {
                    prompt_prefix = icons.ui.Telescope .. " ",
                    selection_caret = icons.ui.Forward .. " ",
                    entry_prefix = "   ",
                    initial_mode = "insert",
                    selection_strategy = "reset",
                    sorting_strategy = "ascending",
                    layout_strategy = "horizontal",
                    layout_config = {
                        horizontal = {
                            preview_width = 0.8,
                            mirror = false,
                        },
                        vertical = {
                            mirror = false,
                        },
                    },
                    file_sorter = require('telescope.sorters').get_fuzzy_file,
                    file_ignore_patterns = {},
                    generic_sorter = require('telescope.sorters').get_generic_fuzzy_sorter,
                    winblend = 0,
                    border = {},
                    borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
                    color_devicons = true,
                    use_less = true,
                    path_display = { "tail" },
                    set_env = { ['COLORTERM'] = 'truecolor' },
                    file_previewer = require('telescope.previewers').vim_buffer_cat.new,
                    grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
                    qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
                    buffer_previewer_maker = require('telescope.previewers').buffer_previewer_maker,
                    vimgrep_arguments = {
                        "rg",
                        "--color=never",
                        "--no-heading",
                        "--with-filename",
                        "--line-number",
                        "--column",
                        "--smart-case",
                        "--glob=!.git/",
                    },
                    mappings = {
                        i = {
                            ["<C-n>"] = actions.cycle_history_next,
                            ["<C-p>"] = actions.cycle_history_prev,
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                        },
                        n = {
                            ["<esc>"] = actions.close,
                            ["j"] = actions.move_selection_next,
                            ["k"] = actions.move_selection_previous,
                            ["q"] = actions.close,
                        },
                    },
                },
                pickers = {
                    lsp_references = {
                        theme = "ivy",
                        fname_width = 200,
                    },
                    find_files = {
                        theme = "ivy"
                    },
                    live_grep = {
                        theme = "ivy"
                    }
                },
                extensions = {
                    ["ui-select"] = {
                        -- require("telescope.themes").get_dropdown({}),
                        require("telescope.themes").get_dropdown({
                            theme = "ivy",
                        }),
                    },
                    fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                        case_mode = "smart_case",
                    },
                },
            })

            -- Load extensions
            require("telescope").load_extension("ui-select")
            pcall(require("telescope").load_extension, "fzf")
        end,
    },
}
