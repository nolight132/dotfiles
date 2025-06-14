return {
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig", -- Mason needs lspconfig to be in the runtimepath
        },
        config = function()
            require("mason-lspconfig").setup({
                automatic_installation = true,
                automatic_enable = true, -- New in v2.0.0
                ensure_installed = {
                    "cssls",
                    "biome",
                    "html",
                    "jsonls",
                    "pyright",
                    "tailwindcss",
                },
            })
        end,
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            require("mason-tool-installer").setup({
                ensure_installed = {
                    "prettier",
                    "stylua", -- lua formatter
                    "isort",  -- python formatter
                    "black",  -- python formatter
                    "pylint",
                    "biome",
                },
            })
        end,
    }
}
