return {
    {
        "nvim-telescope/telescope.nvim",
        version = "*",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-fzf-native.nvim",
            "nvim-telescope/telescope-live-grep-args.nvim",
            "nvim-telescope/telescope-ui-select.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            local builtin = require("telescope.builtin")

            -- Key mappings
            vim.keymap.set("n", "<leader>f.", builtin.oldfiles, { desc = '[f]ind Recent Files ("." for repeat)' })
            vim.keymap.set("n", "<leader>fB", builtin.git_branches, { desc = "[f]ind Git [B]ranch" })
            vim.keymap.set("n", "<leader>fS", builtin.git_stash, { desc = "[f]ind Git [S]tash" })
            vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[f]ind Existing [b]uffers" })
            vim.keymap.set("n", "<leader>fc", builtin.colorscheme, { desc = "[f]ind [c]olorscheme" })
            vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "[f]ind [d]iagnostics" })
            vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[f]ind [f]iles" })
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[f]ind by [g]rep" })
            vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "[f]inder [r]esume" })
            vim.keymap.set("n", "<leader>fs", builtin.git_status, { desc = "[f]ind Git [s]tatus" })
            vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = '[f]ind [h]elp tags' })
            vim.keymap.set('n', '<leader>fp', function()
                local actions = require("telescope.actions")
                local action_state = require("telescope.actions.state")
                local finders = require("telescope.finders")
                local pickers = require("telescope.pickers")
                local telescope_conf = require("telescope.config").values
                local history = require("project_nvim.utils.history")
                local project = require("project_nvim.project")

                local results = history.get_recent_projects()

                local function change_working_directory(prompt_bufnr)
                    local selection = action_state.get_selected_entry(prompt_bufnr)
                    if selection then
                        project.set_pwd(selection.value, "telescope")
                        actions.close(prompt_bufnr)
                        require("neo-tree.command").execute({ action = "show", dir = selection.value })
                        return
                    end
                    actions.close(prompt_bufnr)
                end

                local function refresh_picker(prompt_bufnr)
                    action_state.get_current_picker(prompt_bufnr):refresh(
                        finders.new_table({
                            results = history.get_recent_projects(),
                            entry_maker = function(entry)
                                return {
                                    display = vim.fn.fnamemodify(entry, ":t") .. "  (" .. entry .. ")",
                                    name = vim.fn.fnamemodify(entry, ":t"),
                                    value = entry,
                                    ordinal = vim.fn.fnamemodify(entry, ":t") .. "  (" .. entry .. ")",
                                }
                            end,
                        }),
                        { reset_prompt = true }
                    )
                end

                local function delete_project(prompt_bufnr)
                    local selection = action_state.get_selected_entry(prompt_bufnr)
                    if not selection then return end
                    local choice = vim.fn.confirm("Delete '" .. selection.value .. "' from project list?", "&Yes\n&No", 2)
                    if choice == 1 then
                        history.delete_project(selection)
                        refresh_picker(prompt_bufnr)
                    end
                end

                local function delete_all_except_current(prompt_bufnr)
                    local cwd = vim.fn.getcwd()
                    local to_remove = {}
                    for _, v in ipairs(history.recent_projects) do
                        if v ~= cwd then
                            table.insert(to_remove, v)
                        end
                    end
                    if #to_remove == 0 then
                        vim.notify("No other projects to delete", vim.log.levels.INFO)
                        return
                    end
                    local choice = vim.fn.confirm(
                        "Delete " .. #to_remove .. " projects (keep current)?", "&Yes\n&No", 2
                    )
                    if choice == 1 then
                        for _, v in ipairs(to_remove) do
                            history.delete_project({ value = v })
                        end
                        refresh_picker(prompt_bufnr)
                    end
                end

                pickers.new({}, {
                    prompt_title = "Recent Projects",
                    finder = finders.new_table({
                        results = results,
                        entry_maker = function(entry)
                            return {
                                display = vim.fn.fnamemodify(entry, ":t") .. "  (" .. entry .. ")",
                                name = vim.fn.fnamemodify(entry, ":t"),
                                value = entry,
                                ordinal = vim.fn.fnamemodify(entry, ":t") .. "  (" .. entry .. ")",
                            }
                        end,
                    }),
                    previewer = false,
                    sorter = telescope_conf.generic_sorter({}),
                    attach_mappings = function(prompt_bufnr, map)
                        actions.select_default:replace(change_working_directory)
                        map("n", "d", delete_project)
                        map("i", "<c-d>", delete_project)
                        map("n", "D", delete_all_except_current)
                        map("i", "<c-D>", delete_all_except_current)
                        return true
                    end,
                }):find()
            end, { desc = '[f]ind [p]rojects' })

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
                            preview_width = 0.4,
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
                    use_less = false,
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
                        -- fname_width = 200,
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
                        require("telescope.themes").get_dropdown({}),
                        -- require("telescope.themes").get_dropdown({
                        --     theme = "ivy",
                        -- }),
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
            pcall(require("telescope").load_extension, "ui-select")
            pcall(require("telescope").load_extension, "fzf")
            pcall(require("telescope").load_extension, "live_grep_args")
        end,
    },
}
