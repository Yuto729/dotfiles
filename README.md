# dotfiles

chezmoiで管理するdotfilesリポジトリ

## セットアップ(Ubuntu)

### 1. chezmoiのインストール

```bash
# Ubuntu/Debian
sudo apt install chezmoi

# または公式スクリプト
sh -c "$(curl -fsLS get.chezmoi.io)"
```

### 2. dotfilesの適用

```bash
chezmoi init https://github.com/Yuto729/dotfiles.git
chezmoi apply
```

## 必要なパッケージ

### フォント

```bash
# HackGen (日本語対応プログラミングフォント)
cd /tmp
wget https://github.com/yuru7/HackGen/releases/download/v2.9.0/HackGen_NF_v2.9.0.zip
unzip HackGen_NF_v2.9.0.zip
mkdir -p ~/.local/share/fonts
cp HackGen_NF_v2.9.0/*.ttf ~/.local/share/fonts/
fc-cache -fv
```

## アプリケーション別セットアップ

### Neovim

```bash
# Neovimのインストール
sudo apt install neovim

# または最新版
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update
sudo apt install neovim

# 依存パッケージ
sudo apt install git curl ripgrep fd-find nodejs npm
```

初回起動時にLazyVimがプラグインを自動インストールします。

### WezTerm

以下の公式URLを参照
https://wezterm.org/install/linux.html#__tabbed_1_3

```sh
brew install --cask wezterm
```

### Ghostty

linux版は以下を参照
https://github.com/dariogriffo/ghostty-debian

### cmux

ターミナルマルチプレクサ。設定は `private_dot_config/cmux/cmux.json` で管理している。

## ファイル構成

```
~/.local/share/chezmoi/
├── dot_bashrc                 # Bash設定
├── dot_zshrc                  # Zsh設定
├── private_dot_config/
│   ├── cmux/                  # cmux設定
│   ├── ghostty/               # Ghostty設定
│   ├── nvim/                  # Neovim設定 (LazyVim)
│   └── wezterm/               # WezTerm設定
└── README.md
```

## 設定を変更する場合

chezmoiはシンボリックリンクではなくコピーで動作するため、以下の手順で変更を行う。

### 方法1: chezmoi edit を使う（推奨）

```bash
# 設定ファイルを編集
chezmoi edit ~/.config/wezterm/wezterm.lua

# 変更を適用
chezmoi apply

# GitHubにプッシュ
chezmoi cd
git add -A && git commit -m "Update wezterm config" && git push
```

### 方法2: 直接編集した場合

```bash
# ~/.config/xxx を直接編集した後、chezmoiに取り込む
chezmoi add ~/.config/wezterm/wezterm.lua

# GitHubにプッシュ
chezmoi cd
git add -A && git commit -m "Update wezterm config" && git push
```

## 便利なコマンド

```bash
# 変更を確認
chezmoi diff

# 設定を適用
chezmoi apply

# ファイルを追加
chezmoi add ~/.config/xxx

# 設定を編集
chezmoi edit ~/.config/xxx

# ソースディレクトリへ移動
chezmoi cd
```
