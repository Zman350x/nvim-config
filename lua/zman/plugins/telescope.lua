return {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    -- or                              , branch = '0.1.x',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-tree/nvim-web-devicons',
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make"
        }
    },

    config = function()
        local telescope = require('telescope')
        local builtin = require('telescope.builtin')

        telescope.setup({
            defaults = {
                file_ignore_patterns = { "%.dll" }
            }
        })

        telescope.load_extension("fzf")

        vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = 'Telescope find files' })
        vim.keymap.set('n', '<leader>pg', builtin.git_files, { desc = 'Telescope find git files' })
        vim.keymap.set('n', '<leader>ps', builtin.live_grep, { desc = 'Telescope find string' })
        vim.keymap.set('n', '<leader>pc', builtin.grep_string, { desc = 'Telescope find string at cursor' })
    end
}
