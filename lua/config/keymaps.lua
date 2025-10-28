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

-- Easily split windows
vim.keymap.set("n", "<leader>wv", ":vsplit<cr>", { desc = "[W]indow Split [V]ertical" })
vim.keymap.set("n", "<leader>wh", ":split<cr>", { desc = "[W]indow Split [H]orizontal" })

-- Stay in indent mode
vim.keymap.set("v", "<", "<gv", { desc = "Indent left in visual mode" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right in visual mode" })

-- Code
vim.keymap.set({ "n", "v" }, "<leader>cf", vim.lsp.buf.format, { desc = "[C]ode [F]ormat" })
vim.keymap.set("n", "<leader>ch", vim.lsp.buf.hover, { desc = "[C]ode [H]over Documentation" })
vim.keymap.set("n", "<leader>cd", vim.lsp.buf.definition, { desc = "[C]ode Goto [D]efinition" })
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "[C]ode [A]ctions" })
vim.keymap.set("n", "<leader>cR", vim.lsp.buf.rename, { desc = "[C]ode [R]ename" })
vim.keymap.set("n", "<leader>ci", vim.lsp.buf.implementation, { desc = "[C]ode Goto [I]mplementation" })
vim.keymap.set("n", "<leader>ct", vim.lsp.buf.type_definition, { desc = "[C]ode Goto [T]ype definition" })
vim.keymap.set("n", "<leader>cr", vim.lsp.buf.references, { desc = "[C]ode [R]eferences" })
vim.keymap.set("n", "<leader>cds", vim.lsp.buf.document_symbol, { desc = "[C]ode [D]ocument [S]ymbol" })
vim.keymap.set("n", "<leader>csh", vim.lsp.buf.signature_help, { desc = "[C]ode [S]ignature [H]elp" })
