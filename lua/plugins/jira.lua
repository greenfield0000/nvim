return {
    "letieu/jira.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    lazy = true,
    cmd = {
        "Jira",
    },
    opts = {
        jira = {
            -- === АУТЕНТИФИКАЦИЯ ===
            base    = vim.env.JIRA_URL,
            email   = vim.env.JIRA_EMAIL,
            token   = vim.env.JIRA_TOKEN,
            type    = "basic", -- или "pat"

            -- === ЛИМИТЫ ===
            limit   = 200,

            -- === ПОВЕДЕНИЕ ===
            timeout = 10000, -- ms (если поддерживается — игнорируется иначе)

            -- === НАСТРОЙКИ ДОСОК (BOARDS) ===
            boards  = {
                -- Список ID досок для загрузки (если не указано — грузятся все доступные)
                board_ids = {}, -- например: { "10001", "10002" }

                -- Фильтрация задач на доске
                filters = {
                    -- Фильтр по статусам (можно указать несколько)
                    statuses = {},   -- например: { "To Do", "In Progress", "Done" }
                    -- Фильтр по приоритету
                    priorities = {}, -- например: { "High", "Medium" }
                    -- Фильтр по исполнителю (assignee)
                    assignees = {},  -- например: { "john.doe", "jane.smith" }
                    -- Фильтр по компонентам
                    components = {},
                },

                -- Сортировка задач на доске
                sorting = {
                    field = "priority", -- поле для сортировки (например, "priority", "created", "updated")
                    order = "desc",     -- порядок: "asc" или "desc"
                },

                -- Отображение столбцов
                columns = {
                    -- Список столбцов для отображения (по умолчанию — все)
                    visible = {}, -- например: { "To Do", "In Progress", "Review", "Done" }
                    -- Ширина столбцов (в символах)
                    widths = {},  -- например: { ["To Do"] = 30, ["In Progress"] = 40 }
                },

                -- Поведение при обновлении
                refresh = {
                    interval = 60, -- интервал автообновления (в секундах, 0 = отключить)
                    auto = true,   -- автоматическое обновление при открытии доски
                },

                -- Кэширование данных доски
                cache = {
                    enabled = true, -- включать кэширование
                    ttl = 300,      -- время жизни кэша (в секундах)
                },

                -- Интерфейс доски
                ui = {
                    compact = false,          -- компактный режим (меньше отступов)
                    show_avatars = true,      -- показывать аватары исполнителей
                    highlight_changes = true, -- подсвечивать изменения при обновлении
                },
            },
        },
        -- active_sprint_query = "project = '%s' AND sprint in openSprints() ORDER BY Rank ASC",

        -- Saved JQL queries for the JQL tab
        -- Use %s as a placeholder for the project key
        queries = {
            ["My task"] = "project = '%s' AND assignee = currentUser()",
        },
    },
    config = function(_, opts)
        -- 🔍 Проверка env-переменных
        local missing = {}
        if not opts.jira.base then table.insert(missing, "JIRA_URL") end
        if not opts.jira.email then table.insert(missing, "JIRA_EMAIL") end
        if not opts.jira.token then table.insert(missing, "JIRA_TOKEN") end

        if #missing > 0 then
            vim.notify(
                "jira.nvim: missing env vars:\n- " .. table.concat(missing, "\n- "),
                vim.log.levels.ERROR
            )
            return
        end

        -- 🛡 Безопасная загрузка
        local ok, jira = pcall(require, "jira")
        if not ok then
            vim.notify("jira.nvim failed to load", vim.log.levels.ERROR)
            return
        end

        jira.setup(opts)

        -- === DEV-ХЕЛПЕР ===
        _G.JiraDebug = function()
            vim.print({
                base  = vim.env.JIRA_URL,
                email = vim.env.JIRA_EMAIL,
                token = vim.env.JIRA_TOKEN and "***" or nil,
                log   = vim.fn.stdpath("state") .. "/log",
            })
        end
    end,
}
