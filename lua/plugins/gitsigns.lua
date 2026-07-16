return {
    -- #gitsigns: shows git related infos in the gutter (*****)
    'lewis6991/gitsigns.nvim',
    enabled = true,
    requires = {
        'nvim-lua/plenary.nvim'
    },
    lazy = false,
    config = function()
        require('gitsigns').setup {
            signcolumn = true,
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
                end, { desc = "Следующий hunk" })

                map('n', '[c', function()
                    if vim.wo.diff then
                        vim.cmd.normal({ '[c', bang = true })
                    else
                        gitsigns.nav_hunk('prev')
                    end
                end, { desc = "Предыдущий hunk" })

                -- Actions
                map('n', '<leader>gh', gitsigns.stage_hunk, { desc = "Stage hunk"})
                map('n', '<leader>gr', gitsigns.reset_hunk, { desc = "Unstage hunk"})
                map('v', '<leader>gs', function() gitsigns.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end, { desc = "Stage hunk (visual)"})
                map('v', '<leader>gr', function() gitsigns.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end, { desc = "Unstage hunk (visual)"})
                map('n', '<leader>gB', gitsigns.stage_buffer, { desc = "Stage весь buffer"})
                map('n', '<leader>gu', gitsigns.undo_stage_hunk, { desc = "Undo stage hunk"})
                map('n', '<leader>gR', gitsigns.reset_buffer, { desc = "Reset весь buffer"})
                map('n', '<leader>gp', gitsigns.preview_hunk, { desc = "Preview hunk"})
                map('n', '<leader>gb', function() gitsigns.blame_line { full = true } end, { desc = "Blame строки"})
                map('n', '<leader>gb', gitsigns.toggle_current_line_blame, { desc = "Blame строки (тоггл)"})
                map('n', '<leader>gd', gitsigns.diffthis, { desc = "Diff файла"})
                map('n', '<leader>gD', function() gitsigns.diffthis('~') end, { desc = "Diff c предыдущим коммитом"})
                map('n', '<leader>gd', gitsigns.toggle_deleted, { desc = "Показать/скрыть удалённые строки"})
                map('n', '<leader>gfh', function() require("telescope.builtin").git_bcommits() end, { desc = "История файла" })
                -- Text object
                map({ 'o', 'x' }, 'gh', ':<C-U>Gitsigns select_hunk<CR>', { desc = "Text object: hunk" })
            end
        }
    end
}
