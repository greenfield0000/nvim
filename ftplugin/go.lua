-- ftplugin/go.lua
if vim.b.go_lsp_attached then
    return
end

vim.schedule(function()
    -- Проверяем, прикреплен ли уже LSP к текущему буферу
    local buf_clients = vim.lsp.get_active_clients({ bufnr = 0 })
    for _, client in ipairs(buf_clients) do
        if client.name == 'gopls' then
            vim.b.go_lsp_attached = true
            return
        end
    end

    -- Ищем запущенный gopls
    local clients = vim.lsp.get_active_clients({ name = 'gopls' })

    if #clients > 0 then
        -- Прикрепляем существующий клиент
        local client = clients[1]
        vim.lsp.buf_attach_client(0, client.id)
        print("Прикреплен существующий gopls клиент к буферу " .. vim.api.nvim_get_current_buf())
    else
        -- Запускаем новый клиент
        if vim.fn.executable('gopls') == 1 then
            local config = {
                name = 'gopls',
                cmd = { 'gopls' },
                root_dir = vim.fn.getcwd(),
                filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
            }

            local client_id = vim.lsp.start(config)
            if client_id then
                vim.lsp.buf_attach_client(0, client_id)
                print("Запущен и прикреплен новый gopls клиент")
            end
        else
            print("gopls не найден в PATH")
        end
    end

    vim.b.go_lsp_attached = true
end)
