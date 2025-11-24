local lspconfig = require("lspconfig")
local capabilities = vim.g.lsp_capabilities

lspconfig.jsonls.setup({
    capabilities = capabilities,
})
