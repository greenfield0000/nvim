local function setup_marksman()
  vim.bo.conceallevel = 2

  vim.bo.formatoptions = vim.bo.formatoptions
    :gsub('t', '')
    :gsub('c', '')
    vim.bo.formatoptions = vim.bo.formatoptions .. 'croql'

  vim.bo.comments = 'fb:*,fb:-,fb:+,n:>'
  vim.bo.commentstring = '<!--%s-->'

  local client = vim.lsp.start({
    name = 'marksman',
    cmd = { 'marksman', 'server' },
    cmd_env = {},
    init_options = {},
    on_attach = function(client, bufnr)
      local opts = { buffer = bufnr }
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    end
  })

  if client then
    vim.lsp.buf_attach_client(0, client)
  end
end

setup_marksman()
