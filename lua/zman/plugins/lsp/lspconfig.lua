return {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        { "antosha417/nvim-lsp-file-operations", config = true },
        { "folke/neodev.nvim", opts = {} },
        { "williamboman/mason.nvim",
            opts = {
                ui = {
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗",
                    },
                },
            },
        },
        { "williamboman/mason-lspconfig.nvim",
            opts = {
                ensure_installed = {
                    'lua_ls',
                    'omnisharp_mono',
                    'clangd'
                },
            }
        },
        { "Hoffs/omnisharp-extended-lsp.nvim", lazy = true },
    },
    config = function()
        -- import lspconfig plugin
        local lspconfig = require("lspconfig")

        -- import mason_lspconfig plugin
        local mason_lspconfig = require("mason-lspconfig")

        -- import cmp-nvim-lsp plugin
        local cmp_nvim_lsp = require("cmp_nvim_lsp")

        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(ev)
                -- Buffer local mappings.
                -- See `:help vim.lsp.*` for documentation on any of the below functions
                local opts = { buffer = ev.buf, silent = true }

                -- set keybinds
                opts.desc = "Show LSP references"
                vim.keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

                opts.desc = "Go to declaration"
                vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

                opts.desc = "Show LSP definitions"
                vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

                opts.desc = "Show LSP implementations"
                vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

                opts.desc = "Show LSP type definitions"
                vim.keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

                opts.desc = "See available code actions"
                vim.keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

                opts.desc = "Smart rename"
                vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, opts) -- smart rename

                opts.desc = "Show buffer diagnostics"
                vim.keymap.set("n", "<leader>xD", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

                opts.desc = "Show line diagnostics"
                vim.keymap.set("n", "<leader>xd", vim.diagnostic.open_float, opts) -- show diagnostics for line

                opts.desc = "Go to previous diagnostic"
                vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

                opts.desc = "Go to next diagnostic"
                vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

                opts.desc = "Show documentation for what is under cursor"
                vim.keymap.set("n", "<leader>ld", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

                opts.desc = "Restart LSP"
                vim.keymap.set("n", "<leader>ls", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
            end
        })

        -- used to enable autocompletion (assign to every lsp server config)
        local capabilities = cmp_nvim_lsp.default_capabilities()


        local function is_cairns()
            local cwd = vim.loop.fs_realpath(vim.loop.cwd())
            local cairns_dir = vim.loop.fs_realpath(vim.fn.expand('~/Documents/Cairns'))

            if not cwd or not cairns_dir then
                return false
            end

            return string.sub(cwd, 1, #cairns_dir) == cairns_dir
        end

        local function get_docker_container_id()
            local handle = io.popen("docker container ls | awk 'NR==2 { print $1 }'")
            if handle then
                local result = handle:read("*a")
                handle:close()
                return vim.trim(result)
            end
        end

        local function get_docker_clangd_cmd()
            local container_id = get_docker_container_id()
            if container_id and #container_id > 0 then
                return { "docker", "exec", "-i", container_id, "clangd-10", "--log=verbose", "--pretty" }
            end
            return nil
        end

        local clangd_opts = {}

        local docker_clangd_cmd = get_docker_clangd_cmd()
        if is_cairns() and docker_clangd_cmd then
            clangd_opts.cmd = docker_clangd_cmd
        end

        mason_lspconfig.setup_handlers({
            -- default handler for installed servers
            function(server_name)
                lspconfig[server_name].setup({
                    capabilities = capabilities,
                })
            end,
            ["omnisharp_mono"] = function()
                lspconfig["omnisharp_mono"].setup({
                    capabilities = capabilities,
                    root_dir = function(fname)
                        local primary = require("lspconfig").util.root_pattern("*.sln")(fname)
                        local fallback = require("lspconfig").util.root_pattern("*.csproj")(fname)
                        return primary or fallback
                    end,
                    handlers = { ["textDocument/definition"] = require('omnisharp_extended').definition_handler,
                                 ["textDocument/typeDefinition"] = require('omnisharp_extended').type_definition_handler,
                                 ["textDocument/references"] = require('omnisharp_extended').references_handler,
                                 ["textDocument/implementation"] = require('omnisharp_extended').implementation_handler, },
                    enable_roslyn_analyzers = true,
                    organize_imports_on_format = true,
                    enable_import_completion = true,
                    require("omnisharp_extended").telescope_lsp_definitions()
                })
            end,
            ["lua_ls"] = function()
                -- configure lua server (with special settings)
                lspconfig["lua_ls"].setup({
                    capabilities = capabilities,
                    settings = {
                        Lua = {
                            -- make the language server recognize "vim" global
                            diagnostics = {
                                globals = { "vim" },
                            },
                            completion = {
                                callSnippet = "Replace",
                            },
                        },
                    },
                })
            end,
            ["clangd"] = function()
                lspconfig["clangd"].setup(clangd_opts)
            end
        })
    end,
}
