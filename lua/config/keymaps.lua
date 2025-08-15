-- Set our leader keybinding to space
-- Anywhere you see <leader> in a keymapping specifies the space key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Remove search highlights after searching
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Remove search highlights" })

-- Exit Vim's terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- OPTIONAL: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Better window navigation
vim.keymap.set("n", "<C-h>", ":wincmd h<cr>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", ":wincmd l<cr>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", ":wincmd j<cr>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", ":wincmd k<cr>", { desc = "Move focus to the upper window" })

vim.keymap.set("n", "<leader>tc", ":tabnew<cr>", { desc = "[T]ab [C]reat New" })
vim.keymap.set("n", "<leader>tn", ":tabnext<cr>", { desc = "[T]ab [N]ext" })
vim.keymap.set("n", "<leader>tp", ":tabprevious<cr>", { desc = "[T]ab [P]revious" })

-- Easily split windows
vim.keymap.set("n", "<leader>wv", ":vsplit<cr>", { desc = "[W]indow Split [V]ertical" })
vim.keymap.set("n", "<leader>wh", ":split<cr>", { desc = "[W]indow Split [H]orizontal" })

-- Stay in indent mode
vim.keymap.set("v", "<", "<gv", { desc = "Indent left in visual mode" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right in visual mode" })

-- Code
vim.keymap.set("v", "<leader>cf", vim.lsp.buf.format, { desc = "[C]ode [F]ormat" })
vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, { desc = "[C]ode [F]ormat" })
-- Set vim motion for <Space> + c + h to show code documentation about the code the cursor is currently over if available
vim.keymap.set("n", "<leader>ch", vim.lsp.buf.hover, { desc = "[C]ode [H]over Documentation" })
-- Set vim motion for <Space> + c + d to go where the code/variable under the cursor was defined
vim.keymap.set("n", "<leader>cd", vim.lsp.buf.definition, { desc = "[C]ode Goto [D]efinition" })
-- Set vim motion for <Space> + c + a for display code action suggestions for code diagnostics in both normal and visual mode
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "[C]ode [A]ctions" })
-- Set a vim motion for <Space> + c + <Shift>R to smartly rename the code under the cursor
vim.keymap.set("n", "<leader>cR", vim.lsp.buf.rename, { desc = "[C]ode [R]ename" })
-- Set a vim motion for <Space> + c + <Shift>D to go to where the code/object was declared in the project (class file)
vim.keymap.set("n", "<leader>cD", vim.lsp.buf.declaration, { desc = "[C]ode Goto [D]eclaration" })
