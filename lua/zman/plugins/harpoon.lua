return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local harpoon = require('harpoon')
        harpoon:setup({})

        vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Open Harpoon UI" })
        vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Add current buffer to Harpoon" })

        vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end, { desc = "Go to Harpoon buffer #1" })
        vim.keymap.set("n", "<C-j>", function() harpoon:list():select(2) end, { desc = "Go to Harpoon buffer #2" })
        vim.keymap.set("n", "<C-k>", function() harpoon:list():select(3) end, { desc = "Go to Harpoon buffer #3" })
        vim.keymap.set("n", "<C-l>", function() harpoon:list():select(4) end, { desc = "Go to Harpoon buffer #4" })

        vim.keymap.set("n", "<C-p>", function() harpoon:list():prev() end, { desc = "Go to prev Harpoon buffer" })
        vim.keymap.set("n", "<C-n>", function() harpoon:list():next() end, { desc = "Go to next Harpoon buffer" })
    end
}
