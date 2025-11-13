-- ftplugin/lua.lua
-- if vim.b.lua_lsp_attached then
--     return
-- end

local function setup_lua_ls()
    local clients = vim.lsp.get_clients({ name = 'lua_ls' })
    if #clients > 0 then
        vim.lsp.buf_attach_client(0, clients[1].id)
        return true
    end
    return false
end

-- if setup_lua_ls() then
--     vim.b.lua_lsp_attached = true
-- else
if vim.fn.executable('lua-language-server') == 1 then
    -- Минимальная безопасная конфигурация
    local config = {
        name = 'lua_ls',
        cmd = { 'lua-language-server' },
        root_dir = vim.fn.getcwd(),
        settings = {
            Lua = {
                diagnostics = {
                    globals = { 'vim' }
                },
                workspace = {
                    checkThirdParty = false
                },
                telemetry = {
                    enable = false
                }
            }
        }
    }

    vim.lsp.start(config)
    -- vim.b.lua_lsp_attached = true
else
    vim.notify("lua-language-server not found", vim.log.levels.WARN)
end
-- end
