local lspconfig = require("lspconfig")
local capabilities = vim.g.lsp_capabilities

lspconfig.lua_ls.setup({
  capabilities = capabilities,
})
