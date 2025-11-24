require("lspconfig").lemminx.setup({
    capabilities = vim.g.lsp_capabilities,
    cmd = { 'lemminx' },
    filetypes = { 'xml', 'xsd', 'xsl', 'xslt', 'svg' },
    root_markers = { '.git' },
})
