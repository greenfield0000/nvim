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
                map('n', '<leader>gh', gitsigns.stage_hunk, { desc = "[S]tage [H]unk"})
                map('n', '<leader>gr', gitsigns.reset_hunk, { desc = "[R]eset [H]unk"})
                map('v', '<leader>gs', function() gitsigns.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end, { desc = "[S]tage [H]unk"})
                map('v', '<leader>gr', function() gitsigns.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end, { desc = "[R]eset [H]unk"})
                map('n', '<leader>gB', gitsigns.stage_buffer, { desc = "[S]tage [B]uffer"})
                map('n', '<leader>gu', gitsigns.undo_stage_hunk, { desc = "[U]ndo stage [H]unk"})
                map('n', '<leader>gR', gitsigns.reset_buffer, { desc = "[R]eset [B]uffer"})
                map('n', '<leader>gp', gitsigns.preview_hunk, { desc = "[P]review [H]unk"})
                map('n', '<leader>gb', function() gitsigns.blame_line { full = true } end, { desc = "Toggle line blame"})
                map('n', '<leader>gb', gitsigns.toggle_current_line_blame, { desc = "Toggle line blame"})
                map('n', '<leader>gd', gitsigns.diffthis, { desc = "[D]iff this"})
                map('n', '<leader>gD', function() gitsigns.diffthis('~') end, { desc = "[D]iff this"})
                map('n', '<leader>gd', gitsigns.toggle_deleted, { desc = "Toggle deleted"})
                -- Text object
                map({ 'o', 'x' }, 'gh', ':<C-U>Gitsigns select_hunk<CR>')
            end
        }
    end
}
