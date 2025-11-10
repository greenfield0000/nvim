-- ftplugin/dockerfile.lua
-- if vim.b.docker_lsp_attached then
--     return
-- end

---@diagnostic disable-next-line: unused-function
local function setup_docker_ls()
    local clients = vim.lsp.get_clients({ name = 'docker_language_server' })
    if #clients > 0 then
        vim.lsp.buf_attach_client(0, clients[1].id)
        return true
    end
    return false
end

-- if setup_docker_ls() then
--     vim.b.docker_lsp_attached = true
-- else
if vim.fn.executable('docker-language-server') == 1 then
    local config = {
        name = 'docker_language_server',
        cmd = { 'docker-language-server', 'start', '--stdio' },     -- ИСПРАВЛЕНО: добавили --stdio
        root_dir = vim.fn.getcwd(),
        settings = {
            docker = {
                languageserver = {
                    formatter = {
                        ignoreMultilineInstructions = true,
                    }
                }
            }
        },
        single_file_support = true,
    }

    vim.lsp.start(config)
    -- vim.b.docker_lsp_attached = true
else
    vim.notify("docker-language-server not found", vim.log.levels.WARN)
end
-- end
