return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        { "folke/neodev.nvim", opts = {} },
        "williamboman/mason-lspconfig.nvim",
    },
    config = function()
        local on_attach = function(client, bufnr)
            if client.server_capabilities.documentFormattingProvider then
                vim.api.nvim_create_autocmd("BufWritePre", {
                    group = vim.api.nvim_create_augroup("Format", { clear = true }),
                    buffer = bufnr,
                    callback = function()
                        vim.lsp.buf.format()
                    end,
                })
            end
        end

        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        -- Configure all servers with shared settings
        local servers = {
            "cssls", "tailwindcss", "html", "jsonls", "biome", "pyright"
        }

        -- Setup global options for all LSP servers
        local default_config = {
            on_attach = on_attach,
            capabilities = capabilities,
        }

        -- Configure each server
        for _, server in ipairs(servers) do
            vim.lsp.config(server, default_config)
        end
    end,
}
