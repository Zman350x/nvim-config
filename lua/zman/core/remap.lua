vim.g.mapleader = " "

vim.keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })
vim.keymap.set("n", "<leader>n", ":nohl<CR>", { desc = "Clear search highlights" })

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Return to file explorer" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected line down in visual mode" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected line up in visual mode" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Append line below to current line with a space" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half-page scroll down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half-page scroll up" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev search result" })

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting buffer" })

-- next greatest remap ever : asbjornHaland
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]], { desc = "Yank into system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank whole line into system clipboard" })

vim.keymap.set({"n", "v"}, "<leader>d", [["_d]], { desc = "Delete without overwriting buffer" })

vim.keymap.set("n", "Q", "<nop>", { desc = "Remove Q binding" })

--vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
--vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
--vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
--vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace current word across current file" })
vim.keymap.set("n", "<leader>X", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make current file executable" })

vim.keymap.set("n", "<leader>xc", ":w !wc -m<CR>", { desc = "Character count on current buffer" })

-- Project specific
vim.keymap.set("n", "<leader>hd", ":make! debug<CR>", { desc = "Build Debug Configuration" })
vim.keymap.set("n", "<leader>hD", ":make! clean<CR>:make! debug<CR>", { desc = "Rebuild Debug Configuration" })
vim.keymap.set("n", "<leader>hr", ":make! release<CR>", { desc = "Build Release Configuration" })
vim.keymap.set("n", "<leader>hR", ":make! clean<CR>:make! release<CR>", { desc = "Rebuild Release Configuration" })
vim.keymap.set("n", "<leader>hf", ":make! full-debug<CR>", { desc = "Build Full-Debug Configuration" })
vim.keymap.set("n", "<leader>hF", ":make! clean<CR>:make! full-debug<CR>", { desc = "Rebuild Full-Debug Configuration" })
vim.keymap.set("n", "<leader>hc", ":make! clean<CR>", { desc = "Clean" })
vim.keymap.set("n", "<leader>hp", ":make! run<CR>", { desc = "Run" })
