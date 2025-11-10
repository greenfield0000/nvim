-- ftplugin/markdown.lua
-- if vim.b.markdown_lsp_attached then
--     return
-- end

local function setup_markdown_ls()
    local clients = vim.lsp.get_clients({ name = 'marksman' })
    if #clients > 0 then
        vim.lsp.buf_attach_client(0, clients[1].id)
        return true
    end
    return false
end

-- if setup_markdown_ls() then
--     vim.b.markdown_lsp_attached = true
-- else
if vim.fn.executable('marksman') == 1 then
    local config = {
        name = 'marksman',
        cmd = { 'marksman', 'server' },
        root_dir = vim.fn.getcwd(),
        filetypes = { 'markdown', 'md' },
        single_file_support = true,
    }

    vim.lsp.start(config)
    vim.b.markdown_lsp_attached = true
else
    vim.notify("marksman not found", vim.log.levels.WARN)
end
-- end
