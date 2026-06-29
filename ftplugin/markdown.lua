local util = require("lspconfig.util")

vim.lsp.start({
    name = "marksman",
    cmd = { "marksman" },
    root_dir = util.root_pattern(".git", "package.json", "Cargo.toml", "go.mod", "pom.xml"),
    filetypes = { "markdown" },
    single_file_support = true,
    on_attach = function(client, bufnr)
        local opts = { buffer = bufnr, silent = true }
        vim.keymap.set("n", "gd", vim.lsp.buf.goto_definition, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, opts)
    end,
})
