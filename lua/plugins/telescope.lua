return {
    {
        "nvim-telescope/telescope.nvim",
        -- pull a specific version of the plugin
        tag = "0.1.8",
        dependencies = {
            {
                -- general purpose plugin used to build user interfaces in neovim plugins
                "nvim-lua/plenary.nvim",
            },
            {
                { "nvim-telescope/telescope-fzf-native.nvim", build = "make", lazy = true },
            },

        },
        config = function()
            -- get access to telescopes built in functions
            local builtin = require("telescope.builtin")

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
            vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = '[f] [h]elp tags' })
        end,
    },
    {
        "nvim-telescope/telescope-ui-select.nvim",
        config = function()
            -- get access to telescopes navigation functions
            local actions = require("telescope.actions")
            local icons = require("config.icons")

            require("telescope").setup({
                pickers = {
                    lsp_references = {
                        fname_width = 100, -- Adjust filename column width
                    },
                },
                -- use ui-select dropdown as our ui
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown({}),
                    },
                    ["lsp_handlers"] = {
                        disable = {},
                        location = {
                            telescope = {},
                            no_results_message = 'No references found',
                        },
                        symbol = {
                            telescope = {},
                            no_results_message = 'No symbols found',
                        },
                        call_hierarchy = {
                            telescope = {},
                            no_results_message = 'No calls found',
                        },
                        code_action = {
                            telescope = {},
                            no_results_message = 'No code actions available',
                            prefix = '',
                        },
                    },
                    fzf = {
                        fuzzy = true,                   -- false will only do exact matching
                        override_generic_sorter = true, -- override the generic sorter
                        override_file_sorter = true,    -- override the file sorter
                        case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
                    },
                },
                defaults = {
                    prompt_prefix = icons.ui.Telescope .. " ",
                    selection_caret = icons.ui.Forward .. " ",
                    entry_prefix = "   ",
                    initial_mode = "insert",
                    selection_strategy = "reset",
                    sorting_strategy = "ascending",
                    layout_strategy = "horizontal",
                    layout_config = {
                        preview_width = 0.5, -- 50% of the screen width
                        horizontal = {
                            mirror = false,
                        },
                        vertical = {
                            mirror = false,
                        },
                    },
                    file_sorter = require 'telescope.sorters'.get_fuzzy_file,
                    file_ignore_patterns = {},
                    generic_sorter = require 'telescope.sorters'.get_generic_fuzzy_sorter,
                    winblend = 0,
                    border = {},
                    borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
                    color_devicons = true,
                    use_less = true,
                    path_display = { "tail" },
                    set_env = { ['COLORTERM'] = 'truecolor' }, -- default = nil,
                    file_previewer = require 'telescope.previewers'.vim_buffer_cat.new,
                    grep_previewer = require 'telescope.previewers'.vim_buffer_vimgrep.new,
                    qflist_previewer = require 'telescope.previewers'.vim_buffer_qflist.new,

                    -- Developer configurations: Not meant for general override
                    buffer_previewer_maker = require 'telescope.previewers'.buffer_previewer_maker,
                    vimgrep_arguments = {
                        "rg",
                        "--color=never",
                        "--no-heading",
                        "--with-filename",
                        "--line-number",
                        "--column",
                        "--smart-case",
                        -- "--hidden",
                        "--glob=!.git/",
                        -- можно добавить ненужные директории или типы файлов
                        -- "!.target/",
                        -- "*.class",
                    },
                },
                -- set keymappings to navigate through items in the telescope io
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
            })
            -- load the ui-select extension
            require("telescope").load_extension("ui-select")
        end,
    },
}
