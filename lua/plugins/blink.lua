return {
  {
    "saghen/blink.cmp",
    -- V1 stable; switch to `branch = "main"` for V2 (requires blink.lib + Rust toolchain)
    version = "1.*",
    dependencies = {
      "rafamadriz/friendly-snippets", -- community snippet collection (VSCode-style)
    },
    event = { "InsertEnter", "CmdlineEnter" },

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      ----------------------------------------------------------------------
      -- Keymap: "enter" preset — <CR> accepts, <Tab>/<S-Tab> navigate snippets
      ----------------------------------------------------------------------
      keymap = {
        preset = "enter",
        -- The "enter" preset gives us:
        --   <CR>          accept
        --   <C-space>     show / toggle docs
        --   <C-e>         cancel
        --   <C-p>/<C-n>   select prev/next
        --   <Up>/<Down>   select prev/next
        --   <C-b>/<C-f>   scroll docs
        --   <Tab>         snippet_forward, fallback
        --   <S-Tab>       snippet_backward, fallback
        --   <C-k>         show/hide signature help
        ["<C-y>"] = { "select_and_accept" },
      },

      ----------------------------------------------------------------------
      -- Completion
      ----------------------------------------------------------------------
      completion = {
        accept = {
          auto_brackets = { enabled = true }, -- auto-insert brackets after functions
        },

        list = {
          -- With the "enter" preset, don't preselect so plain <CR> still inserts a newline
          selection = {
            preselect = false,
            auto_insert = true,
          },
        },

        menu = {
          draw = {
            -- Use treesitter to highlight completion labels from LSP
            treesitter = { "lsp" },
          },
        },

        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },

        ghost_text = {
          enabled = true,
        },
      },

      ----------------------------------------------------------------------
      -- Signature help (experimental, opt-in)
      ----------------------------------------------------------------------
      signature = {
        enabled = true,
      },

      ----------------------------------------------------------------------
      -- Sources
      ----------------------------------------------------------------------
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },

        -- Per-filetype overrides: add lazydev for Lua files
        per_filetype = {
          lua = { inherit_defaults = true, "lazydev" },
        },

        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100, -- show at higher priority than LSP
          },
        },
      },

      ----------------------------------------------------------------------
      -- Snippets: uses built-in vim.snippet (native, no luasnip needed)
      -- friendly-snippets provides the snippet definitions
      ----------------------------------------------------------------------
      snippets = {
        preset = "default",
      },

      ----------------------------------------------------------------------
      -- Fuzzy matching
      ----------------------------------------------------------------------
      fuzzy = {
        implementation = "prefer_rust",
      },

      ----------------------------------------------------------------------
      -- Appearance
      ----------------------------------------------------------------------
      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = "mono", -- "mono" for Nerd Font Mono, "normal" for Nerd Font
      },

      ----------------------------------------------------------------------
      -- Command line completion
      ----------------------------------------------------------------------
      cmdline = {
        enabled = true,
        keymap = { preset = "cmdline" },
        completion = {
          list = { selection = { preselect = false } },
          menu = {
            auto_show = function(ctx)
              return ctx.mode == "cmdline" or vim.fn.getcmdtype() == ":"
            end,
          },
          ghost_text = { enabled = true },
        },
      },
    },
  },
}
