local lspconfig = require("lspconfig")
local capabilities = vim.g.lsp_capabilities

lspconfig.lemminx.setup({
  capabilities = capabilities,
})
