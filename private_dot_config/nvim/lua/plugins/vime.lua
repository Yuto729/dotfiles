-- vime.nvim: Neovim 内で日本語入力（ローマ字→ひらがな→漢字変換、Anthy 使用）
-- 依存: libanthy。macOS では nix 経由で導入済み（nix profile add nixpkgs#anthy）。
return {
  "skanehira/vime.nvim",
  event = "InsertEnter",
  config = function()
    require("vime").setup({
      anthy = {
        -- nix profile の libanthy を明示指定（macOS では自動検出されないため）
        lib = vim.fn.expand("~/.nix-profile/lib/libanthy.dylib"),
      },
    })
  end,
}
