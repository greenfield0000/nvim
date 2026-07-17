local M = {
    "ThePrimeagen/harpoon",
    event = "VeryLazy",
    dependencies = {
        "nvim-lua/plenary.nvim"
    },
    config = function()
        vim.keymap.set("n", "<s-m>", "<cmd>lua require('plugins.harpoon').mark_file()<cr>", { desc = "Harpoon: отметить файл" })
        vim.keymap.set("n", "<TAB>", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>",
            { desc = "Harpoon: меню файлов" })
    end
}

function M.mark_file()
    require("harpoon.mark").add_file()
    vim.notify "󱡅  marked file"
end

-- return M
return M
