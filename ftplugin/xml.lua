-- ftplugin/xml.lua
if vim.b.xml_lsp_attached then
  return
end

local function setup_lemminx()
  local clients = vim.lsp.get_active_clients({ name = 'lemminx' })
  if #clients > 0 then
    vim.lsp.buf_attach_client(0, clients[1].id)
    return true
  end
  return false
end

if setup_lemminx() then
  vim.b.xml_lsp_attached = true
else
  if vim.fn.executable('lemminx') == 1 then
    -- Минимальная безопасная конфигурация
    local config = {
      name = 'lemminx',
      cmd = { 'lemminx' },
      root_dir = vim.fn.getcwd(),
      filetypes = { 'xml', 'xsd', 'xsl', 'xslt' },
      settings = {
        xml = {
          server = {
            workDir = vim.fn.stdpath('cache') .. '/lemminx'
          }
        }
      }
    }
    
    vim.lsp.start(config)
    vim.b.xml_lsp_attached = true
  else
    vim.notify("lemminx not found", vim.log.levels.WARN)
  end
end
