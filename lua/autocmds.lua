vim.api.nvim_create_autocmd("FileType", {
    pattern = { "*" },
    callback = function()
        local colorcolumn_settings = {
            java = "120",
            kotlin = "120",
            scala = "120",
            python = "88",
            javascript = "100",
            typescript = "100",
            javascriptreact = "100",
            typescriptreact = "100",
            lua = "80",
            go = "100",
            c = "80",
            cpp = "80",
            rust = "100",
            html = "120",
            css = "120",
            markdown = "150",
            -- добавьте другие языки по необходимости
        }
        local ft = vim.bo.filetype
        if colorcolumn_settings[ft] then
            vim.opt.colorcolumn = colorcolumn_settings[ft]
        else
            vim.opt.colorcolumn = "80" -- Значение по умолчанию
        end
    end
})

vim.api.nvim_create_autocmd("TermLeave", {
    callback = function()
        vim.schedule(function()
            require("neo-tree.sources.manager").refresh("filesystem")
        end)
    end,
    desc = "Refresh Neo-tree after terminal use",
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "dapui_watches", "dapui_repl" },
    callback = function()
        require("cmp").setup.buffer({
            enabled = true,
            sources = {
                { name = "dap" },
                { name = "buffer" },
            },
        })
    end,
})

local function close_deleted_buffers()
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted then
            local bufname = vim.api.nvim_buf_get_name(bufnr)
            if bufname ~= "" and not (vim.uv or vim.loop).fs_stat(bufname) then
                vim.schedule(function()
                    if vim.api.nvim_buf_is_valid(bufnr) then
                        vim.api.nvim_buf_delete(bufnr, { force = true })
                    end
                end)
            end
        end
    end
end

local events = { "BufEnter", "FocusGained", "CursorHold", "VimResume" }
for _, event in ipairs(events) do
    vim.api.nvim_create_autocmd(event, {
        callback = close_deleted_buffers,
        desc = "Close buffer if file was deleted",
    })
end
