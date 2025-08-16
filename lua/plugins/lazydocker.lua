return {
    {
        'crnvl96/lazydocker.nvim',
        config = function()
            require('lazydocker').setup({
                window = {
                    settings = {
                        width = 0.618,       -- Percentage of screen width (0 to 1)
                        height = 0.618,      -- Percentage of screen height (0 to 1)
                        border = 'rounded',  -- See ':h nvim_open_win' border options
                        relative = 'editor', -- See ':h nvim_open_win' relative options
                    },
                },
            })

            vim.keymap.set({ 'n', 't' }, '<leader>ld', '<Cmd>lua LazyDocker.toggle()<CR>')
        end
    }
}
