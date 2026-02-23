vim.api.nvim_create_user_command('WritingMode', function()
    vim.cmd('setlocal spell wrap linebreak textwidth=80')
end, {})

vim.api.nvim_create_user_command('EndWritingMode', function()
    vim.cmd('setlocal nospell nowrap nolinebreak textwidth=0')
end, {})

vim.api.nvim_create_user_command('Tab2', function()
    vim.cmd('setlocal shiftwidth=2 tabstop=2 softtabstop=2')
end, {})

vim.api.nvim_create_user_command('Tab4', function()
    vim.cmd('setlocal shiftwidth=4 tabstop=4 softtabstop=4')
end, {})

vim.api.nvim_create_user_command('Tab8', function()
    vim.cmd('setlocal shiftwidth=8 tabstop=8 softtabstop=8')
end, {})
