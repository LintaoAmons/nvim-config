return {
  -- LSP configuration -- native Neovim 0.11+ approach
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Mason: portable package manager for LSP servers, linters, formatters
      { "mason-org/mason.nvim", opts = {} },
      {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = {
          ensure_installed = {
            -- Formatters
            "goimports",
            "gofumpt",
            "prettierd",
            "prettier",
            "stylua",
            "ruff",
            "shfmt",
            "jq",
            "sqruff",
          },
        },
      },
      {
        "mason-org/mason-lspconfig.nvim",
        opts = {
          -- Servers to auto-install via Mason
          ensure_installed = {
            "lua_ls",
            "vtsls",
            "gopls",
            "pyright",
            "jsonls",
            "yamlls",
            "bashls",
            "html",
            "cssls",
            "tailwindcss",
          },
          -- Automatically call vim.lsp.enable() for Mason-installed servers
          automatic_enable = {
            exclude = { "sqruff", "ts_ls", "eslint" },
          },
        },
      },

      -- Lua development: configures lua_ls for Neovim runtime/plugins/APIs
      {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
          library = {
            -- Load luvit types when the `vim.uv` word is found
            { path = "luvit-meta/library", words = { "vim%.uv" } },
            { path = "snacks.nvim", words = { "Snacks" } },
          },
        },
      },
      { "Bilal2453/luvit-meta", lazy = true },

      -- Completion capabilities
      "saghen/blink.cmp",
    },
    config = function()
      ----------------------------------------------------------------------
      -- Global LSP capabilities (blink.cmp integration)
      ----------------------------------------------------------------------
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      ----------------------------------------------------------------------
      -- Per-server configuration (override defaults from nvim-lspconfig)
      -- Only needed for servers that require custom settings.
      -- Servers with no custom config just work via automatic_enable.
      ----------------------------------------------------------------------
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = {
              checkThirdParty = false,
            },
            completion = {
              callSnippet = "Replace",
            },
            -- lazydev.nvim handles type annotations; disable built-in here
            diagnostics = {
              disable = { "missing-fields" },
            },
          },
        },
      })

      vim.lsp.config("jsonls", {
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      })

      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            schemaStore = { enable = false, url = "" },
            schemas = require("schemastore").yaml.schemas(),
          },
        },
      })

      vim.lsp.config("vtsls", {
        settings = {
          vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
              maxInlayHintLength = 30,
              completion = {
                enableServerSideFuzzyMatch = true,
              },
            },
          },
          typescript = {
            updateImportsOnFileMove = { enabled = "always" },
            suggest = { completeFunctionCalls = true },
            inlayHints = {
              enumMemberValues = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              parameterNames = { enabled = "literals" },
              parameterTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              variableTypes = { enabled = false },
            },
          },
          javascript = {
            updateImportsOnFileMove = { enabled = "always" },
            suggest = { completeFunctionCalls = true },
            inlayHints = {
              enumMemberValues = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              parameterNames = { enabled = "literals" },
              parameterTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              variableTypes = { enabled = false },
            },
          },
        },
      })

      ----------------------------------------------------------------------
      -- Servers NOT installed by Mason (manual install / system-provided).
      -- Configure + enable them explicitly.
      ----------------------------------------------------------------------
      -- Example:
      -- vim.lsp.config("gleam", { cmd = { "gleam", "lsp" } })
      -- vim.lsp.enable("gleam")

      ----------------------------------------------------------------------
      -- Diagnostics
      ----------------------------------------------------------------------
      vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded", source = true },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.INFO] = " ",
            [vim.diagnostic.severity.HINT] = " ",
          },
        },
        virtual_text = {
          prefix = "●",
          spacing = 4,
        },
      })

      ----------------------------------------------------------------------
      -- LspAttach: keymaps & buffer-local settings
      -- Navigation keymaps (gd, gr, gI, gy, gD) are in snacks.lua using
      -- Snacks.picker. Below are the remaining LSP keymaps.
      ----------------------------------------------------------------------
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
        callback = function(args)
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = "LSP: " .. desc })
          end

          -- Actions
          map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
          map("n", "<leader>cl", vim.lsp.codelens.run, "Run Codelens")
          map("n", "<leader>cL", vim.lsp.codelens.refresh, "Refresh Codelens")

          -- Info
          map("n", "K", function()
            vim.lsp.buf.hover({ border = "rounded" })
          end, "Hover Documentation")
          map("n", "gK", vim.lsp.buf.signature_help, "Signature Help")
          map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")

          -- Workspace (using <leader>lw* to avoid conflict with window splits)
          map("n", "<leader>lwa", vim.lsp.buf.add_workspace_folder, "Add Workspace Folder")
          map("n", "<leader>lwr", vim.lsp.buf.remove_workspace_folder, "Remove Workspace Folder")
          map("n", "<leader>lwl", function()
            vim.print(vim.lsp.buf.list_workspace_folders())
          end, "List Workspace Folders")

          -- vtsls-specific keymaps
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "vtsls" then
            map("n", "<leader>cM", function()
              vim.lsp.buf.code_action({ apply = true, context = { only = { "source.addMissingImports.ts" }, diagnostics = {} } })
            end, "Add Missing Imports")
            map("n", "<leader>cD", function()
              vim.lsp.buf.code_action({ apply = true, context = { only = { "source.fixAll.ts" }, diagnostics = {} } })
            end, "Fix All Diagnostics")
            map("n", "<leader>cO", function()
              vim.lsp.buf.code_action({ apply = true, context = { only = { "source.organizeImports.ts" }, diagnostics = {} } })
            end, "Organize Imports")
            map("n", "<leader>cU", function()
              vim.lsp.buf.code_action({ apply = true, context = { only = { "source.removeUnused.ts" }, diagnostics = {} } })
            end, "Remove Unused Imports")
          end

          -- Toggle inlay hints (if supported)
          if client and client:supports_method("textDocument/inlayHint") then
            map("n", "<leader>th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }))
            end, "Toggle Inlay Hints")
          end
        end,
      })
    end,
  },

  -- SchemaStore for JSON/YAML schemas
  { "b0o/SchemaStore.nvim", lazy = true },
}
