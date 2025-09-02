vim.opt.nu = true
vim.opt.relativenumber = true

vim.g.netrw_bufsettings = 'noma nomod nu rnu nobl nowrap ro'

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.termguicolors = true
vim.opt.background = "dark"

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "number"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"
