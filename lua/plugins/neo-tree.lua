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
            { "<leader>e", "<cmd>Neotree toggle right<cr>", desc = "NeoTree (Root Dir)" },
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
                        },
                        -- { "file_size" }, -- ЗАКОММЕНТИРУЙТЕ или удалите эту строку!
                        -- { "type" },      -- Если отображается тип файла, его тоже можно убрать
                        { "git_status" },
                        { "diagnostics" },
                    },
                },
                diagnostics = {
                    enable = true,
                    show_on_dirs = true, -- Показывать значок ошибки на родительской папке, если внутри неё есть ошибка
                    show_on_open_dirs = true,
                    debounce = 150,      -- Задержка обновления (в мс), чтобы Neovim не лагал при печати
                    signs = {
                        -- Настройка иконок (можете заменить на свои)
                        hint = "  ",
                        info = " ",
                        warn = " ",
                        error = "   ",
                    },
                },
                -- Добавляет счетчик измененных Git-файлов рядом с папками
                enable_git_status = true,
                close_if_last_window = true, -- Закрывать дерево, если оно осталось одно
                window = {
                    width = function()
                        -- vim.o.columns возвращает количество символов (колонок) всего экрана Neovim
                        return math.floor(vim.o.columns / 2)
                    end,
                    -- mappings = {
                    --     ["<tab>"] = function(state)
                    --         local node = state.tree:get_node()
                    --         if node.type == "directory" then
                    --             -- Если это папка, раскрываем или закрываем её
                    --             require("neo-tree.sources.filesystem.commands").toggle_node(state)
                    --         else
                    --             -- Если это файл, открываем его
                    --             require("neo-tree.sources.common.commands").open(state)
                    --         end
                    --     end,
                    -- }
                },
                -- Настройки самого файлового дерева
                filesystem = {
                    follow_current_file = {
                        enabled = true, -- Авто-фокус на текущий открытый файл
                        leave_dirs_open = true,
                    },
                    filtered_items = {
                        visible = false, -- ПОКАЗЫВАТЬ скрытые файлы (.env, .gitignore)
                        hide_dotfiles = false,
                        hide_gitignored = true,
                        hide_by_name = {
                            ".git", -- Скрываем только саму папку репозитория, чтобы не мешала
                            ".DS_Store",
                            ".settings",
                            "target",
                        },
                    },
                    -- Настройка поиска (Клавиша / или f в дереве)
                    search_by_name = {
                        fuzzy = true,
                        -- Включаем авто-раскрытие папок, внутри которых есть совпадения
                        expanded_by_default = true,
                    },
                },

                -- Внешний вид в стиле LazyVim
                default_component_configs = {
                    indent = {
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
                            error = "   ",
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
            vim.cmd([[
                highlight NeoTreeFileIconActive guifg=#ff007c
                highlight NeoTreeFileNameActive gui=bold guifg=#ffffff
            ]])
        end,
    },
    {
        -- Плагин для автоматического изменения импортов через LSP
        {
            "antosha417/nvim-lsp-file-operations",
            dependencies = {
                "nvim-lua/plenary.nvim",
                "nvim-neo-tree/neo-tree.nvim", -- Связываем с neo-tree
            },
            config = function()
                require("lsp-file-operations").setup()
            end,
        },
    },
}
