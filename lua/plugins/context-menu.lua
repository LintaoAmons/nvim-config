return {
  "LintaoAmons/context-menu.nvim",
  event = "VeryLazy",
  config = function()
    -- Diffview's panels are not real files: their buffers are named
    -- `diffview:///panels/N/DiffviewFilePanel`. Any item that derives a path
    -- from the buffer name therefore produces garbage in them -- measured:
    -- "Copy Line Reference" yields `0/DiffviewFilePanel:5:0`. Blanket-hide
    -- those items here rather than teaching each one to detect the panel.
    -- `DiffviewFiles` is the file panel; `DiffviewFileHistory` is used by both
    -- the history panel and the option panel, so both names are needed.
    local diffview_panels = { "DiffviewFiles", "DiffviewFileHistory" }

    -- Run a diffview action by name. These are emit stubs dispatching to the
    -- active view, so they are only meaningful while a view is open -- which
    -- is exactly what the `ft` gate on the items below guarantees.
    local function diffview_action(name)
      return function()
        require("diffview.actions")[name]()
      end
    end

    -- `:DiffviewDiffFiles` / `:DiffviewDiffDirs` take two operands and have no
    -- interactive form. Prompt for them one at a time rather than splitting a
    -- single line, so operands containing spaces survive.
    local function prompt_two_operands(cmd, label, completion)
      vim.ui.input({ prompt = label .. " (1/2): ", completion = completion }, function(first)
        if not first or first == "" then
          return
        end
        vim.ui.input({ prompt = label .. " (2/2): ", completion = completion }, function(second)
          if not second or second == "" then
            return
          end
          vim.cmd(("%s %s %s"):format(cmd, vim.fn.fnameescape(first), vim.fn.fnameescape(second)))
        end)
      end)
    end

    require("context-menu").setup({
      picker = "menu", -- right-click style float; use "vim-ui" for vim.ui.select
      modules = { "git" },
    })
    require("context-menu").add_items({
      {
        order = 1,
        name = "Code Action",
        -- No LSP client ever attaches to a diffview panel buffer, so this item
        -- could only ever report "no client with method textDocument/codeAction".
        not_ft = vim.list_extend({ "markdown", "toggleterm", "http" }, diffview_panels),
        action = function()
          vim.lsp.buf.code_action()
        end,
      },
      {
        name = "Copy Line Reference",
        not_ft = diffview_panels,
        action = function()
          local git_dir = vim.fn.finddir(".git", vim.fn.expand("%:p:h") .. ";")
          if git_dir ~= "" then
            local root = vim.fn.fnamemodify(git_dir, ":p:h:h")
            local rel = string.sub(vim.fn.expand("%:p"), #root + 2)
            local line, col = unpack(vim.api.nvim_win_get_cursor(0))
            local ref = rel .. ":" .. line .. ":" .. col
            vim.fn.setreg("+", ref)
            vim.notify("Copied: " .. ref)
          else
            vim.notify("No git repository found", vim.log.levels.WARN)
          end
        end,
      },
      {
        name = "Copy",
        not_ft = diffview_panels,
        items = {
          {
            name = "Buffer Name",
            action = function()
              local name = vim.fn.expand("%:p:t")
              vim.fn.setreg("+", name)
              vim.notify("Copied: " .. name)
            end,
          },
          {
            name = "Absolute Path",
            action = function()
              local path = vim.fn.expand("%:p")
              vim.fn.setreg("+", path)
              vim.notify("Copied: " .. path)
            end,
          },
          {
            name = "Relative Path",
            action = function()
              local path = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":.")
              vim.fn.setreg("+", path)
              vim.notify("Copied: " .. path)
            end,
          },
          {
            name = "Directory Path",
            action = function()
              local path = vim.fn.expand("%:p:h")
              vim.fn.setreg("+", path)
              vim.notify("Copied: " .. path)
            end,
          },
        },
      },

      -- Diffview file-panel entries (diffview-plus.nvim).
      --
      -- Selection rule: `git.lua` already binds `q`/`a`/`A`/`d`/`C` by hand
      -- (close / stage entry / stage all / restore / lazygit) and those have
      -- muscle memory, so this menu deliberately does not repeat them. A slot
      -- is earned by a capability whose key or command name is hard to recall.
      --
      -- "Clear File Selections" is the load-bearing one: diffview-plus binds it
      -- to `C` by default, which owner's own `C` -> lazygit shadows, so there is
      -- no key left that reaches it -- the menu is its only entry point.
      --
      -- No `deps` on these: the `ft` gate only matches when a diffview panel is
      -- on screen, which already implies the plugin is loaded.
      {
        order = 2,
        name = "Diffview: Toggle File Selection",
        ft = { "DiffviewFiles" },
        action = diffview_action("toggle_select_entry"),
      },
      {
        order = 3,
        name = "Diffview: Clear File Selections",
        ft = { "DiffviewFiles" },
        action = diffview_action("clear_select_entries"),
      },
      {
        order = 4,
        name = "Diffview: Unstage All",
        ft = { "DiffviewFiles" },
        action = diffview_action("unstage_all"),
      },
      {
        order = 5,
        name = "Diffview: Toggle Untracked Files",
        ft = { "DiffviewFiles" },
        action = diffview_action("toggle_untracked"),
      },
      {
        order = 6,
        -- The fork's headline capability: single-pane unified diff that renders
        -- deleted lines inline (upstream has no equivalent). `set_layout` is
        -- bound to no key by default and takes a layout name, so without this
        -- entry the only routes in are `view.default.layout` or adding
        -- "diff1_inline" to `cycle_layouts` -- both config, neither discoverable.
        -- Note it takes the name and RETURNS the action, hence the extra call.
        name = "Diffview: Inline (unified) Diff",
        ft = { "DiffviewFiles" },
        action = function()
          require("diffview.actions").set_layout("diff1_inline")()
        end,
      },
      {
        order = 7,
        -- Cycles `view.cycle_layouts.default`, which ships as
        -- { "diff2_horizontal", "diff2_vertical" } -- a split-orientation
        -- toggle, not a route to inline (see the entry above). Cycling from an
        -- unlisted layout restarts at the first, so this is also the way back
        -- out of the inline view.
        name = "Diffview: Cycle Layout (split orientation)",
        ft = { "DiffviewFiles" },
        action = diffview_action("cycle_layout"),
      },
      {
        order = 8,
        -- Only meaningful when the panel shows a commit range
        -- (`:DiffviewOpen HEAD~2..HEAD`). On a plain `:DiffviewOpen` the entries
        -- are uncommitted, and diffview answers "no log available for these
        -- changes" -- which is correct, just not useful.
        name = "Diffview: Commit Log for This File",
        ft = { "DiffviewFiles" },
        action = diffview_action("open_commit_log_file"),
      },

      -- CSV/TSV tabular view (csvview.nvim). The plugin ships no default keymap,
      -- and its command names -- plus the `display_mode=` argument -- are exactly
      -- the hard-to-recall kind this menu exists to surface. `ft` gates the whole
      -- group to delimited buffers so it is invisible everywhere else; `deps`
      -- degrades each item to a "not installed" notice if csvview is ever
      -- removed -- same contract as the diffview entries. csvview lazy-loads on
      -- the csv/tsv filetypes, so by the time this group is visible its commands
      -- already exist.
      {
        order = 2,
        name = "CSV",
        ft = { "csv", "tsv" },
        items = {
          {
            name = "Toggle Table View",
            deps = { { "cmd:CsvViewToggle", msg = "requires csvview.nvim" } },
            action = function()
              vim.cmd("CsvViewToggle")
            end,
          },
          {
            name = "Table View: Bordered",
            deps = { { "cmd:CsvViewEnable", msg = "requires csvview.nvim" } },
            action = function()
              vim.cmd("CsvViewEnable display_mode=border")
            end,
          },
          {
            name = "Table View: Highlight",
            deps = { { "cmd:CsvViewEnable", msg = "requires csvview.nvim" } },
            action = function()
              vim.cmd("CsvViewEnable display_mode=highlight")
            end,
          },
          {
            name = "Disable Table View",
            deps = { { "cmd:CsvViewDisable", msg = "requires csvview.nvim" } },
            action = function()
              vim.cmd("CsvViewDisable")
            end,
          },
        },
      },

      -- Current-file history, merged into the git module's "Git" group (by
      -- name, so it lands beside its "Project Histories :: Diffview" sibling and
      -- follows that group's `X :: Provider` naming). `DiffviewFileHistory %`
      -- logs the file behind the buffer, so `filter_func` hides the item on any
      -- buffer where `%` has no backing file -- panels (buftype "nofile"/
      -- "acwrite"), terminals ("terminal"), quickfix, unnamed scratch. `deps`
      -- degrades to a notice if diffview is ever removed, matching the siblings.
      {
        name = "Git",
        items = {
          {
            order = 1,
            name = "File History :: Diffview",
            filter_func = function(ctx)
              return ctx.filename ~= "" and vim.bo[ctx.buffer].buftype == ""
            end,
            deps = { { "cmd:DiffviewFileHistory", msg = "diffview.nvim is required — install sindrets/diffview.nvim" } },
            action = function()
              vim.cmd("DiffviewFileHistory %")
            end,
          },
        },
      },

      -- Commands that only exist in diffview-plus, available from any buffer.
      -- `deps` keeps these degrading to a "not installed" notice rather than an
      -- error if the pin ever moves back to upstream sindrets/diffview.nvim,
      -- which has none of them.
      {
        order = 20,
        name = "Diffview",
        items = {
          {
            name = "Toggle Diffview",
            deps = { { "cmd:DiffviewToggle", msg = "requires diffview-plus.nvim" } },
            action = function()
              vim.cmd("DiffviewToggle")
            end,
          },
          {
            name = "Diff Two Files...",
            deps = { { "cmd:DiffviewDiffFiles", msg = "requires diffview-plus.nvim" } },
            action = function()
              prompt_two_operands("DiffviewDiffFiles", "File", "file")
            end,
          },
          {
            name = "Diff Two Directories...",
            deps = { { "cmd:DiffviewDiffDirs", msg = "requires diffview-plus.nvim" } },
            action = function()
              prompt_two_operands("DiffviewDiffDirs", "Directory", "dir")
            end,
          },
        },
      },

      -- Yazi (yazi.nvim). Selection rule is the same one the Diffview group
      -- above states: a slot is earned by a capability with no key of its own.
      -- yazi.nvim exposes exactly four entry points (`lua/yazi/commands.lua:4-21`)
      -- and `yazi.lua` already binds the plain one -- `<leader>E` -> `:Yazi`,
      -- "open at the current file" -- so that one is deliberately NOT repeated
      -- here. The two below have no key at all; `:Yazi logs` is a debugging aid,
      -- not a menu item.
      --
      -- Only one location entry, not three: `cd-project.lua` `lcd`s to the
      -- project root on every switch, so "project root" and "cwd" are the same
      -- directory in this config -- a separate project-root item would be a
      -- duplicate of this one.
      --
      -- Called through the lua API (`lua/yazi.lua:22,182`) rather than `:Yazi
      -- cwd` / `:Yazi toggle`: yazi.nvim is lazy-loaded on `<leader>E` only, so
      -- the user command does not exist until that key is pressed. `require`
      -- goes through lazy.nvim's module loader and loads the plugin on demand,
      -- which also makes `deps` report honestly instead of claiming a missing
      -- plugin that is merely unloaded.
      --
      -- No `ft` gate, unlike the Diffview panel entries -- measured, not assumed:
      -- yazi.nvim resolves a buffer whose name carries a non-`file://` URI
      -- scheme to `getcwd()` itself (`lua/yazi/utils.lua:133-141`), so in a
      -- `diffview:///panels/2/DiffviewFilePanel` buffer it opens at the project
      -- directory rather than at a garbage path. "Open at CWD" never reads the
      -- buffer name to begin with, and the sibling paths it passes along are
      -- filtered to `buftype == "" and buflisted` (`utils.lua:451-457`), so
      -- panels, terminals and quickfix can never leak in.
      {
        order = 21,
        name = "Yazi",
        items = {
          {
            name = "Open at CWD",
            deps = { { "lua:yazi", msg = "requires yazi.nvim" } },
            action = function()
              require("yazi").yazi(nil, vim.fn.getcwd())
            end,
          },
          {
            -- `:Yazi toggle` under a name that says what it does: it reopens at
            -- the file yazi last hovered (`lua/yazi.lua:182-198`), which is the
            -- one thing `<leader>E` cannot do.
            name = "Resume Last Session",
            deps = { { "lua:yazi", msg = "requires yazi.nvim" } },
            action = function()
              require("yazi").toggle()
            end,
          },
        },
      },
    })
  end,
  keys = {
    { "<M-l>", function() require("context-menu").open() end, mode = { "v", "n" }, desc = "Context Menu" },
    { "<C-g>", function() require("context-menu").open() end, mode = { "v", "n" }, desc = "Context Menu" },
  },
}
