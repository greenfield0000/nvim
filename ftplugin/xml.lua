vim.lsp.start({
    name = 'lemminx',
    cmd = { 'lemminx' },                                       -- Укажите полный путь к исполняемому файлу
    root_dir = vim.fs.root(0, { '.git', 'lsp-root-markers' }), -- Автоматически находим корень проекта
    filetypes = { 'properties' },                              -- Укажите типы файлов, для которых нужен LSP
    on_attach = function(client)
        -- Здесь можно настроить дополнительные опции или действия при присоединении к буферу
        vim.lsp.diagnostic.set_loclist_command('ags', '--debug=infra:4000')
    end,
})
