return {
    {
        "stevearc/dressing.nvim",
        opts = {
            input = {
                enabled = true,
                default_prompt = "➤ ",
                title_pos = "left",
                insert_only = true,
                start_in_insert = true,
                border = "rounded",
                relative = "cursor",
                win_options = {
                    winblend = 10,
                    wrap = false,
                },
                get_config = function(opts)
                    if opts.prompt == "Main class: " then
                        return {
                            border = "single",
                            relative = "editor",
                            width = 0.8,
                        }
                    end
                    return {}
                end,
            },
            select = {
                enabled = true,
                backend = { "telescope", "builtin" },
                trim_prompt = true,
                builtin = {
                    border = "rounded",
                    relative = "cursor",
                    win_options = {
                        winblend = 10,
                        cursorline = true,
                        cursorlineopt = "both",
                    },
                    -- Правильная конфигурация для builtin select
                    win_config = {
                        width = 0.8,
                        height = 0.8,
                    },
                },
                telescope = {
                    -- Конфигурация для telescope (если установлен)
                },
                get_config = function(opts)
                    if opts.kind == "dap" then
                        return {
                            border = "single",
                            relative = "editor",
                        }
                    end
                    return {}
                end,
            },
        }
    },
}
