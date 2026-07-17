-- Set our leader keybinding to space
-- Anywhere you see <leader> in a keymapping specifies the space key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Remove search highlights after searching
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Сбросить подсветку поиска" })

-- Better window navigation
vim.keymap.set("n", "<C-h>", ":wincmd h<cr>", { desc = "Фокус на левое окно" })
vim.keymap.set("n", "<C-l>", ":wincmd l<cr>", { desc = "Фокус на правое окно" })
vim.keymap.set("n", "<C-j>", ":wincmd j<cr>", { desc = "Фокус на нижнее окно" })
vim.keymap.set("n", "<C-k>", ":wincmd k<cr>", { desc = "Фокус на верхнее окно" })

-- Easily split windows
vim.keymap.set("n", "<leader>wv", ":vsplit<cr>", { desc = "Сплит окна [V]ertical" })
vim.keymap.set("n", "<leader>wh", ":split<cr>", { desc = "Сплит окна [H]orizontal" })

-- Stay in indent mode
vim.keymap.set("v", "<", "<gv", { desc = "Отступ влево (visual mode)" })
vim.keymap.set("v", ">", ">gv", { desc = "Отступ вправо (visual mode)" })

-- Jira
vim.keymap.set("n", "<leader>jj", "<cmd>Jira<cr>", { desc = "Jira: Главное меню" })
