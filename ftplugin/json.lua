-- Настройки отступов
vim.bo.tabstop = 2      -- Размер табуляции в 2 пробела
vim.bo.shiftwidth = 2   -- Размер отступа в 2 пробела
vim.bo.expandtab = true -- Преобразовывать табы в пробелы

-- 2. Запуск LSP-клиента
-- Это основной способ запуска LSP в Neovim 0.10+
vim.lsp.start({
    name = 'json-lsp',                      -- Имя сервера для отладки
    cmd = { 'vscode-json-language-server', '--stdio' }, -- Команда для запуска сервера
    root_dir = vim.fs.dirname(vim.fs.find({
        '.git',
        'package.json',
        'tsconfig.json',
        'jsconfig.json',
        '.vim-rooter'
    }, { upward = true })[1]), -- Определяем корень проекта
    capabilities = vim.g.lsp_capabilities,
    init_options = {
        provideFormatter = true,
    },
})
