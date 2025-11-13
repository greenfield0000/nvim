if vim.fn.executable('vscode-json-language-server') == 1 then
    local config = {
        name = 'vscode-json-language-server',
        cmd = { 'vscode-json-language-server', 'start', '--stdio' },
        filetypes = { 'json', 'jsonc' },
        root_dir = vim.fn.getcwd(),
        init_options = {
            provideFormatter = true,
        },
        root_markers = { '.git' },
    }

    vim.lsp.start(config)
else
    vim.notify("json-language-server not found", vim.log.levels.WARN)
end
