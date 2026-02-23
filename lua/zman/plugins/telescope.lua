return {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    -- or                              , branch = '0.1.x',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-tree/nvim-web-devicons',
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make"
        },
        "nvim-telescope/telescope-live-grep-args.nvim"
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
        telescope.load_extension("live_grep_args")

        vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = 'Telescope find files' })
        vim.keymap.set('n', '<leader>pg', builtin.git_files, { desc = 'Telescope find git files' })
        vim.keymap.set('n', '<leader>ps', telescope.extensions.live_grep_args.live_grep_args, { desc = 'Telescope find string' })
        vim.keymap.set('n', '<leader>pc', builtin.grep_string, { desc = 'Telescope find string at cursor' })
    end
}
