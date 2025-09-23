local function setup_noice_theme()
    -- Базовые цвета из текущей темы
    local colors = {
        bg = vim.api.nvim_get_hl_by_name("Normal", true).background or "#1e1e2e",
        fg = vim.api.nvim_get_hl_by_name("Normal", true).foreground or "#cdd6f4",
        border = vim.api.nvim_get_hl_by_name("FloatBorder", true).foreground or "#585b70",
        comment = vim.api.nvim_get_hl_by_name("Comment", true).foreground or "#7f849c",
        search = vim.api.nvim_get_hl_by_name("Search", true).background or "#a6e3a1",
    }

    -- Noice highlight группы
    local hl_groups = {
        -- Основные
        NoiceCmdlinePopup = { bg = colors.bg, fg = colors.fg },
        NoiceCmdlinePopupBorder = { fg = colors.border, bg = colors.bg },
        NoiceCmdlinePopupTitle = { fg = colors.fg, bg = colors.bg, bold = true },

        -- Уведомления
        NoiceNotify = { bg = colors.bg, fg = colors.fg },
        NoiceNotifyBorder = { fg = colors.border, bg = colors.bg },
        NoiceNotifyTitle = { fg = colors.fg, bg = colors.bg, bold = true },

        -- Мини
        NoiceMini = { bg = colors.bg, fg = colors.comment },

        -- Иконки
        NoiceCmdlineIcon = { fg = colors.comment },
        NoiceCmdlineIconSearch = { fg = colors.search or colors.comment },

        -- LSP
        NoiceLspProgressClient = { fg = colors.comment },
        NoiceLspProgressTitle = { fg = colors.fg, bold = true },
    }

    -- Применяем highlight группы
    for group, settings in pairs(hl_groups) do
        vim.api.nvim_set_hl(0, group, settings)
    end
end

return {
    {
        "folke/noice.nvim",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        opts = {
            -- === ОСНОВНЫЕ НАСТРОЙКИ ===
            enabled = true,
            debug = false,
            verbose = 0,

            -- === ВИДЫ СООБЩЕНИЙ ===
            cmdline = {
                enabled = true,
                view = "cmdline", -- cmdline, cmdline_popup
                opts = {},
                format = {
                    cmdline = { pattern = "^:", icon = "", lang = "vim" },
                    search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
                    search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
                    filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
                    lua = { pattern = "^:%s*lua%s+", icon = "", lang = "lua" },
                    help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
                },
            },

            messages = {
                enabled = true,
                view = "notify", -- mini, notify, messages
                view_error = "notify",
                view_warn = "notify",
                view_history = "messages",
            },

            popupmenu = {
                enabled = true,
                backend = "nui", -- nvim-cmp, nui
            },

            -- === ВНЕШНИЙ ВИД И ПОЗИЦИЯ ===
            views = {
                cmdline_popup = {
                    position = {
                        row = "30%", -- Вертикальная позиция (20%, 50%, 5)
                        -- col = "50%", -- Горизонтальная позиция
                    },
                    size = {
                        width = "60%", -- 60% ширины экрана
                        height = "auto",
                    },
                    border = {
                        style = "rounded", -- none, single, double, rounded, solid, shadow
                        padding = { 1, 2 },
                    },
                    win_options = {
                        winhighlight = {
                            Normal = "Normal",           -- Группа highlight для фона
                            FloatBorder = "FloatBorder", -- Группа для border
                            Search = "WarningMsg",       -- Подсветка поиска
                        },
                    },
                },

                popup = {
                    position = { row = "50%", col = "50%" },
                    size = { width = 60, height = 10 },
                    border = { style = "rounded" },
                },

                notify = {
                    position = {
                        row = "90%",  -- НИЖНИЙ правый угол (было 100%)
                        col = "100%", -- Правая граница
                    },
                    size = {
                        width = "auto",
                        max_width = 80, -- Максимальная ширина
                        height = "auto",
                    },
                    border = { style = "rounded" },
                    win_options = {
                        winblend = 100, -- Прозрачность (0-100)
                    },
                },

                mini = {
                    position = {
                        row = -1,     -- Самая нижняя строка
                        col = "100%", -- Правый край
                    },
                    size = "auto",
                    border = { style = "none" },
                },

                messages = {
                    position = { row = "25%", col = "50%" },
                    size = { width = 80, height = 20 },
                    border = { style = "rounded" },
                },
            },

            -- === ФОРМАТИРОВАНИЕ СООБЩЕНИЙ ===
            format = {
                level = {
                    icons = {
                        error = "",
                        warn = "",
                        info = "",
                        debug = "",
                        trace = "",
                    },
                },
            },

            -- === МАРШРУТИЗАЦИЯ СООБЩЕНИЙ ===
            routes = {
                -- === ГЛОБАЛЬНОЕ ПЕРЕНАПРАВЛЕНИЕ: ОТКЛЮЧАЕМ ВСЕ СТАНДАРТНЫЕ УВЕДОМЛЕНИЯ ===
                {
                    filter = { event = "msg_show" },
                    opts = { skip = true }, -- Пропускаем все стандартные сообщения
                },

                -- Но оставляем ошибки через noice
                {
                    filter = {
                        event = "msg_show",
                        kind = "error",
                    },
                    view = "notify",
                },

                -- Скрыть сообщение "written"
                {
                    filter = {
                        event = "msg_show",
                        kind = "",
                        find = "written",
                    },
                    opts = { skip = true },
                },

                -- Скрыть сообщения поиска
                {
                    filter = {
                        event = "msg_show",
                        kind = "search_count",
                    },
                    opts = { skip = true },
                },

                -- Скрыть все LSP/JDTLS уведомления
                {
                    filter = {
                        event = "msg_show",
                        find = "jdtls",
                    },
                    opts = { skip = true },
                },
                {
                    filter = {
                        event = "msg_show",
                        find = "JDTLS",
                    },
                    opts = { skip = true },
                },
                {
                    filter = {
                        event = "msg_show",
                        find = "LSP",
                    },
                    opts = { skip = true },
                },
                {
                    filter = {
                        event = "msg_show",
                        find = "connected",
                    },
                    opts = { skip = true },
                },
                {
                    filter = {
                        event = "msg_show",
                        find = "initialized",
                    },
                    opts = { skip = true },
                },
            },

            -- === КОМАНДЫ И ЛОУАУТЫ ===
            commands = {
                history = {
                    view = "split",
                    position = { row = "20%", col = "50%" },
                    size = { height = "60%" },
                },
                last = {
                    view = "popup",
                    position = { row = "30%", col = "50%" },
                    size = { width = "80%", height = "40%" },
                },
                errors = {
                    view = "popup",
                    position = { row = "30%", col = "50%" },
                    size = { width = "80%", height = "40%" },
                },
            },

            -- === НАСТРОЙКИ ПРОИЗВОДИТЕЛЬНОСТИ ===
            throttle = 1000 / 60, -- 60 FPS
            lazy_update = true,

            -- === ДОПОЛНИТЕЛЬНЫЕ ОПЦИИ ===
            health = {
                checker = true,
            },

            smart_move = {
                enabled = true,
                excluded_filetypes = { "cmp_menu", "cmp_docs", "" },
            },

            presets = {
                bottom_search = true,
                command_palette = true,
                long_message_to_split = true,
                inc_rename = true,
                lsp_doc_border = true,
            },
        },

        config = function(_, opts)
            -- Сохраняем оригинальный vim.notify
            local original_notify = vim.notify

            -- === ГЛОБАЛЬНОЕ ПЕРЕНАПРАВЛЕНИЕ VIM.NOTIFY ===
            vim.notify = function(msg, level, _)
                -- Список сообщений для полного игнорирования
                local ignored_patterns = {
                    "jdtls", "JDTLS", "LSP", "lsp",
                    "connected", "initialized", "starting",
                    "Loading", "Building", "Compiling",
                    "workspace", "indexing", "progress"
                }

                -- Проверяем нужно ли полностью игнорировать сообщение
                local should_ignore = false
                for _, pattern in ipairs(ignored_patterns) do
                    if msg:find(pattern) or (opts and opts.title and opts.title:find(pattern)) then
                        should_ignore = true
                        break
                    end
                end

                if should_ignore then
                    return -- Полностью игнорируем
                end

                -- Все остальные сообщения показываем через noice
                return original_notify(msg, level, opts)
            end

            -- Инициализируем noice
            require("noice").setup(opts)

            setup_noice_theme()
            vim.api.nvim_create_autocmd("ColorScheme", {
                callback = setup_noice_theme,
            })

            -- === КАСТОМНЫЕ ХОТКЕИ ===
            local keymap = vim.keymap.set
            local nopts = { noremap = true, silent = true }

            -- История сообщений
            keymap("n", "<leader>nH", "<cmd>Noice history<CR>", nopts)
            -- Последнее сообщение
            keymap("n", "<leader>nL", "<cmd>Noice last<CR>", nopts)
            -- Ошибки
            keymap("n", "<leader>nE", "<cmd>Noice errors<CR>", nopts)
            -- Перезагрузить noice
            keymap("n", "<leader>nR", "<cmd>Noice reload<CR>", nopts)
            -- Документация
            keymap("n", "<leader>nD", "<cmd>Noice docs<CR>", nopts)
            -- Отладка
            keymap("n", "<leader>nd", "<cmd>Noice disable<CR>", nopts)
            -- Тoggle noice
            keymap("n", "<leader>nt", function()
                require("noice").cmd("toggle")
            end, nopts)

            -- === АВТОМАТИЧЕСКОЕ УПРАВЛЕНИЕ LSP УВЕДОМЛЕНИЯМИ ===
            -- Отключаем прогресс-бары LSP
            vim.lsp.handlers["$/progress"] = function() end

            -- Перенаправляем LSP сообщения через нашу систему
            vim.lsp.handlers["window/showMessage"] = function(_, result, ctx)
                local client = vim.lsp.get_client_by_id(ctx.client_id)
                local client_name = client and client.name or "unknown"

                -- Показываем только ошибки через noice
                if result.type == vim.lsp.protocol.MessageType.Error then
                    vim.notify(result.message, vim.log.levels.ERROR, {
                        title = "LSP Error: " .. client_name
                    })
                end
            end

            vim.notify("Noice configured with global redirection", vim.log.levels.INFO)
        end,
    }
}
