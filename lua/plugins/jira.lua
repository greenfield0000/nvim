return {
    "letieu/jira.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    lazy = true,
    cmd = {
        "Jira",
        "JiraIssues",
        "JiraBoards",
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

        vim.notify("jira.nvim loaded successfully 🚀", vim.log.levels.INFO)

        -- === KEYMAPS ===
        local map = vim.keymap.set
        map("n", "<leader>ji", "<cmd>JiraIssues<cr>", { desc = "Jira: Issues" })
        map("n", "<leader>jb", "<cmd>JiraBoards<cr>", { desc = "Jira: Boards" })
        map("n", "<leader>jj", "<cmd>Jira<cr>", { desc = "Jira: Main" })

        -- -- === АВТО-ЛОГ ОШИБОК LUA ===
        -- vim.api.nvim_create_autocmd("LspLog", {
        --     callback = function()
        --         vim.notify("Jira LSP log updated", vim.log.levels.DEBUG)
        --     end,
        -- })
        --
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
