local colorcolumn_settings = {
    java = "120",
    kotlin = "120", 
    scala = "120",
    python = "88",
    javascript = "100",
    typescript = "100",
    javascriptreact = "100",
    typescriptreact = "100",
    lua = "80",
    go = "100",
    c = "80",
    cpp = "80",
    rust = "100",
    html = "120",
    css = "120",
    -- добавьте другие языки по необходимости
}

vim.api.nvim_create_autocmd("FileType", {
    pattern = {"*"},
    callback = function()
        local ft = vim.bo.filetype
        if colorcolumn_settings[ft] then
            vim.opt.colorcolumn = colorcolumn_settings[ft]
        else
            vim.opt.colorcolumn = "80"  -- Значение по умолчанию
        end
    end
})

-- vim.api.nvim_create_autocmd("DirChanged", {
--   callback = function()
--     -- Останавливаем все LSP клиенты для текущего буфера
--     for _, client in pairs(vim.lsp.get_active_clients()) do
--       vim.lsp.stop_client(client.id)
--     end
--     -- Повторно запускаем LSP для буфера
--     -- Обычно достаточно просто переоткрыть буфер, но для надёжности:
--     vim.cmd("edit")
--   end,
--   desc = "Перезапуск LSP при изменении рабочей директории",
-- })
