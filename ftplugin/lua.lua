-- Проверяем что filetype действительно lua
if vim.bo.filetype ~= 'lua' then
  vim.notify('Not Lua extension!', vim.log.levels.INFO)
  return
end

-- Локальные настройки буфера
local bufnr = vim.api.nvim_get_current_buf()

-- Опции для Lua файлов
vim.bo.expandtab = true
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.bo.tabstop = 2
vim.bo.commentstring = '-- %s'

-- Настройка LSP если не активен
local clients = vim.lsp.get_clients({ bufnr = bufnr })
if #clients == 0 then
  vim.lsp.config.lua_ls.setup({
    on_attach = function(client, bufnr)
      -- LSP on_attach логика
      vim.notify('Lua LSP attached!', vim.log.levels.INFO)
    end,
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        diagnostics = { globals = { 'vim' } },
        workspace = {
          library = vim.api.nvim_get_runtime_file('', true),
          checkThirdParty = false
        },
        telemetry = { enable = false },
      }
    }
  })

  -- Запускаем LSP для текущего буфера
  vim.lsp.start({
    name = 'lua_ls',
    bufnr = bufnr,
  })
end
