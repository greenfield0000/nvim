
local lspconfig = require("lspconfig")
local capabilities = vim.g.lsp_capabilities

lspconfig.sqlls.setup({
  capabilities = capabilities,
})
