return {
    -- for all git plugins
    -- {
    --     "tpope/vim-fugitive",
    --     config = function()
    --         vim.keymap.set("n", "<leader>gg", vim.cmd.Git)
    --
    --         local myFugitive = vim.api.nvim_create_augroup("myFugitive", {})
    --
    --         local autocmd = vim.api.nvim_create_autocmd
    --         autocmd("BufWinEnter", {
    --             group = myFugitive,
    --             pattern = "*",
    --             callback = function()
    --                 if vim.bo.ft ~= "fugitive" then
    --                     return
    --                 end
    --
    --                 local bufnr = vim.api.nvim_get_current_buf()
    --                 local opts = { buffer = bufnr, remap = false }
    --
    --                 vim.keymap.set("n", "<leader>P", function()
    --                     vim.cmd.Git('push')
    --                 end, opts)
    --
    --                 -- NOTE: rebase always
    --                 vim.keymap.set("n", "<leader>p", function()
    --                     vim.cmd.Git({ 'pull', '--rebase' })
    --                 end, opts)
    --
    --                 -- NOTE: easy set up branch that wasn't setup properly
    --                 vim.keymap.set("n", "<leader>t", ":Git push -u origin ", opts);
    --             end,
    --         })
    --     end,
    -- },
    {
        -- #gitsigns: shows git related infos in the gutter (*****)
        'lewis6991/gitsigns.nvim',
        enabled = true,
        requires = {
            'nvim-lua/plenary.nvim'
        },
        lazy = false,
        config = function()
            require('gitsigns').setup {
                signs = {
                    add          = { text = '+' }, -- {text = '│'},
                    change       = { text = '*' }, -- {text = '│'},
                    delete       = { text = '_' },
                    topdelete    = { text = '‾' },
                    changedelete = { text = '~' },
                    untracked    = { text = '+' },
                },
                on_attach = function(bufnr)
                    local gitsigns = require('gitsigns')

                    local function map(mode, l, r, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        vim.keymap.set(mode, l, r, opts)
                    end

                    -- Navigation
                    map('n', ']c', function()
                        if vim.wo.diff then
                            vim.cmd.normal({ ']c', bang = true })
                        else
                            gitsigns.nav_hunk('next')
                        end
                    end)

                    map('n', '[c', function()
                        if vim.wo.diff then
                            vim.cmd.normal({ '[c', bang = true })
                        else
                            gitsigns.nav_hunk('prev')
                        end
                    end)

                    -- Actions
                    map('n', '<leader>gh', gitsigns.stage_hunk, { desc = "[S]tage [H]unk" })
                    map('n', '<leader>gr', gitsigns.reset_hunk, { desc = "[R]eset [H]unk" })
                    map('v', '<leader>gs', function() gitsigns.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
                        { desc = "[S]tage [H]unk" })
                    map('v', '<leader>gr', function() gitsigns.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
                        { desc = "[R]eset [H]unk" })
                    map('n', '<leader>gB', gitsigns.stage_buffer, { desc = "[S]tage [B]uffer" })
                    map('n', '<leader>gu', gitsigns.undo_stage_hunk, { desc = "[U]ndo stage [H]unk" })
                    map('n', '<leader>gR', gitsigns.reset_buffer, { desc = "[R]eset [B]uffer" })
                    map('n', '<leader>gp', gitsigns.preview_hunk, { desc = "[P]review [H]unk" })
                    map('n', '<leader>gb', function() gitsigns.blame_line { full = true } end,
                        { desc = "Toggle line blame" })
                    map('n', '<leader>gb', gitsigns.toggle_current_line_blame, { desc = "Toggle line blame" })
                    map('n', '<leader>gd', gitsigns.diffthis, { desc = "[D]iff this" })
                    map('n', '<leader>gD', function() gitsigns.diffthis('~') end, { desc = "[D]iff this" })
                    map('n', '<leader>gd', gitsigns.toggle_deleted, { desc = "Toggle deleted" })
                    -- Text object
                    map({ 'o', 'x' }, 'gh', ':<C-U>Gitsigns select_hunk<CR>')
                end
            }
        end

    },
    {
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
}
