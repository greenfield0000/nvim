return {
    "kdheepak/lazygit.nvim",
    cmd = {
        "LazyGit",
        "LazyGitConfig",
        "LazyGitCurrentFile",
        "LazyGitFilter",
        "LazyGitFilterCurrentFile",
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    keys = {
        { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Open lazy git" },
    },

    config = function()
        -- Настройки Lazygit
        vim.g.lazygit_floating_window_scaling_factor = 0.9
        vim.g.lazygit_floating_window_border = 'rounded'
        vim.g.lazygit_use_neovim_remote = 1
        vim.g.lazygit_floating_window_winblend = 0

        -- Локальные переменные для хранения оригинальных настроек
        local original_timeoutlen = vim.o.timeoutlen
        local original_ttimeoutlen = vim.o.ttimeoutlen

        -- Функция для исправления Escape в конкретном буфере
        local function fix_lazygit_escape(bufnr)
            if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
                vim.api.nvim_buf_set_keymap(bufnr, 't', '<Esc>', '<C-\\><C-n>', { noremap = true })
                vim.api.nvim_buf_set_keymap(bufnr, 't', '<C-[>', '<C-\\><C-n>', { noremap = true })
                vim.api.nvim_buf_set_keymap(bufnr, 't', '<C-c>', '<C-\\><C-n>', { noremap = true })
            end
        end

        -- Автоматическое исправление при открытии терминала
        vim.api.nvim_create_autocmd("TermOpen", {
            pattern = "*lazygit*",
            callback = function(args)
                vim.o.timeoutlen = 1000
                vim.o.ttimeoutlen = 1000
                fix_lazygit_escape(args.buf)
            end
        })

        -- Восстановление настроек после закрытия
        vim.api.nvim_create_autocmd("TermClose", {
            pattern = "*lazygit*",
            callback = function()
                vim.o.timeoutlen = original_timeoutlen
                vim.o.ttimeoutlen = original_ttimeoutlen
            end
        })

        -- Переопределяем команду для надежности
        vim.api.nvim_create_user_command("LazyGit", function()
            vim.o.timeoutlen = 1000
            vim.o.ttimeoutlen = 1000
            require("lazygit").lazygit()
        end, { desc = "Open LazyGit with escape fix" })
    end
}
