return {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        -- plugin to allow us to automatically comment tsx elements with the comment plugin
        "JoosepAlviste/nvim-ts-context-commentstring",
    },
    config = function()
        vim.keymap.set("n", "<leader>/", "<Plug>(comment_toggle_linewise_current)", { desc = "Comment Line" })
        vim.keymap.set("v", "<leader>/", "<Plug>(comment_toggle_linewise_visual)", { desc = "Comment Selected" })

        local comment = require("Comment")
        local ts_context_commentstring = require("ts_context_commentstring.integrations.comment_nvim")
        local ts_hook = ts_context_commentstring.create_pre_hook()

        comment.setup({
            pre_hook = function(ctx)
                local ok, result = pcall(ts_hook, ctx)
                if ok and result then
                    return result
                end
                if vim.bo.commentstring and vim.bo.commentstring ~= '' then
                    return vim.bo.commentstring
                end
                local ft_ok, ft_result = pcall(function()
                    return require("Comment.ft").get(vim.bo.filetype, ctx.ctype)
                end)
                if ft_ok and ft_result then
                    vim.bo.commentstring = ft_result
                    return ft_result
                end
            end,
        })
    end,
}
