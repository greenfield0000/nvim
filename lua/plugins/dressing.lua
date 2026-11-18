return {
    {
        "stevearc/dressing.nvim",
        opts = {
            input = {
                enabled = true,
                default_prompt = "➤ ",
                title_pos = "left",
                start_mode = "insert",
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
                    max_width = 0.8,
                    max_height = 0.8,
                },
                telescope = {
                    -- Конфигурация для telescope (если установлен)
                },
            },
        }
    },
}
