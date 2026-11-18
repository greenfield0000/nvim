return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- Иконки
            "MunifTanjim/nui.nvim",
        },
        cmd = "Neotree",
        keys = {
            -- Хоткей как в LazyVim: Space + e открывает/закрывает дерево
            { "<leader>e", "<cmd>Neotree toggle right<cr>", desc = "Neo-tree: файловое дерево" },
        },
        config = function()
            require("neo-tree").setup({
                renderers = {
                    file = {
                        -- Список компонентов, которые будут видны для каждого файла
                        { "indent" },
                        { "icon" },
                        {
                            "name",
                            use_git_status_colors = true,
                            highlight_opened_files = true,
                        },
                        { "clipboard" },
                        { "modified" },
                        { "git_status" },
                        { "diagnostics" },
                    },
                },
                enable_diagnostics = true,
                -- Показывать Git-статусы файлов и папок
                enable_git_status = true,
                git_status_async_options = {
                    batch_size = 1000,
                    batch_delay = 10,
                    max_lines = 100000,
                },
                close_if_last_window = true, -- Закрывать дерево, если оно осталось одно
                window = {
                    position = "right",
                    width = function()
                        local preferred = math.max(35, math.floor(vim.o.columns / 4))
                        return math.min(60, preferred, math.max(1, vim.o.columns - 20))
                    end,
                },
                -- Настройки самого файлового дерева
                filesystem = {
                    group_empty_dirs = true,
                    find_by_full_path_words = true,
                    use_libuv_file_watcher = true,
                    follow_current_file = {
                        enabled = true,
                        leave_dirs_open = true,
                    },
                    filtered_items = {
                        visible = false, -- H временно показывает скрытые элементы
                        hide_dotfiles = true,
                        hide_gitignored = true,
                        always_show = { ".gitignore", ".editorconfig" },
                        hide_by_name = {
                            ".git",
                            ".DS_Store",
                            ".settings",
                            "target",
                            "node_modules",
                            ".cache",
                            ".m2",
                            ".gradle",
                        },
                    },
                },

                -- Внешний вид в стиле LazyVim
                default_component_configs = {
                    file_size = { enabled = false },
                    last_modified = { enabled = false },
                    indent = {
                        with_expanders = true, -- ОБЯЗАТЕЛЬНО: включает стрелочки
                        expander_collapsed = "", -- Стрелочка, когда папка ЗАКРЫТА
                        expander_expanded = "", -- Стрелочка, когда папка ОТКРЫТА
                        expander_highlight = "NeoTreeExpander", -- Цвет стрелочки
                        with_markers = true,
                        indent_marker = "│",
                        last_indent_marker = "└",
                        highlight = "NeoTreeIndentMarker",
                    },
                    icon = {
                        folder_closed = "",
                        folder_open = "",
                        folder_empty = "  ",
                        default = "  ",
                    },
                    git_status = {
                        symbols = {
                            -- Замените на любые иконки
                            added     = "✚",
                            modified  = "",
                            deleted   = "✖",
                            renamed   = "  ",
                            untracked = "",
                            ignored   = "",
                            unstaged  = "  ",
                            staged    = "  ",
                            conflict  = "",
                        }
                    },
                    diagnostics = {
                        symbols = {
                            hint = "  ",
                            info = " ",
                            warn = " ",
                            error = " ",
                        },
                        highlights = {
                            hint = "DiagnosticSignHint",
                            info = "DiagnosticSignInfo",
                            warn = "DiagnosticSignWarn",
                            error = "DiagnosticSignError",
                        },
                    },
                },
            })
        end,
    },
    {
        -- Плагин для автоматического изменения импортов через LSP
        "antosha417/nvim-lsp-file-operations",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-neo-tree/neo-tree.nvim", -- Связываем с neo-tree
        },
        config = function()
            require("lsp-file-operations").setup()
        end,
    },
}
