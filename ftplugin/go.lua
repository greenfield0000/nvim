local lspconfig = require("lspconfig")
local capabilities = vim.g.lsp_capabilities

lspconfig.gopls.setup({
  capabilities = capabilities,
})

