return {
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "mfussenegger/nvim-dap",
      "mfussenegger/nvim-dap-python",
      { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
    },
    lazy = false,
    branch = "regexp",
    config = function()
      require("venv-selector").setup({
        settings = {
          search = {
            anaconda_base = {
              command = "fdfind -p '/bin/python$' ~/.conda/envs --full-path --color never -E /proc",
              type = "anaconda",
            },
            anaconda_envs = {
              command = "fdfind -p '/bin/python$' ~/anaconda3/envs --full-path --color never -E /proc",
              type = "anaconda",
            },
            miniconda = {
              command = "fdfind -p '/bin/python$' ~/miniconda3/envs --full-path --color never -E /proc",
              type = "anaconda",
            },
            virtualenvs = {
              command = "fdfind -p '/bin/python$' ~/.virtualenvs --full-path --color never -E /proc",
              type = "virtualenv",
            },
            pipenv = {
              command = "fdfind -p '/bin/python$' ~/.local/share/virtualenvs --full-path --color never -E /proc",
              type = "pipenv",
            },
            pipenv_absolute = {
              command = "fdfind -p '/bin/python$' /home/mitomi/.local/share/virtualenvs --full-path --color never -E /proc",
              type = "pipenv",
            },
            pyenv = {
              command = "fdfind -p '/bin/python$' ~/.pyenv/versions --full-path --color never -E /proc",
              type = "pyenv",
            },
            poetry = {
              command = "fdfind -p '/bin/python$' ~/.cache/pypoetry/virtualenvs --full-path --color never -E /proc",
              type = "poetry",
            },
            venv = {
              command = "fdfind 'python$' . -p -t f -HI -a -L -E .git -E .wine -E .steam -E /proc | grep -E 'venv|virtualenv|env' | head -20",
              type = "virtualenv",
            },
          },
        },
      })
    end,
    keys = {
      { "<leader>vs", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv" },
      { "<leader>vc", "<cmd>VenvSelectCached<cr>", desc = "Select Cached VirtualEnv" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "standard",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                autoImportCompletions = true,
                diagnosticSeverityOverrides = {
                  reportUnusedVariable = "warning",
                  reportUnusedImport = "warning",
                },
              },
            },
          },
        },
      },
    },
  },
}