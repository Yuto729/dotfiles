-- LSP inlay hints を有効化（K は LazyVim 標準の vim.lsp.buf.hover）
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = true },
    },
  },
}
