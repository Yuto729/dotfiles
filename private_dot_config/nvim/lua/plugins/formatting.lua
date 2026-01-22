return {
  {
    "stevearc/conform.nvim",
    opts = {
      format_on_save = false,
      format_after_save = false,
      formatters_by_ft = {
        python = {},
        typescript = {},
        typescriptreact = {},
        javascript = {},
        javascriptreact = {},
        lua = {},
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ts_ls = {
          on_attach = function(client, _)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,
        },
        vtsls = {
          on_attach = function(client, _)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,
        },
        lua_ls = {
          on_attach = function(client, _)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,
        },
      },
    },
  },
}
