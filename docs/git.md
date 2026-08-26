---
title: Git
---

# Git in this config

Everything on this page was read out of this repository (or, where marked, out
of the installed plugin's own source). **Every entry carries a `file:line`**, so
each claim can be checked against the code. Nothing here is generic
"how to use git in Neovim" advice.

Leader is `<Space>` (`lua/config/options.lua:1`), so `<leader>gs` means `Space` `g` `s`.

## How to read the three markers

| Marker | Meaning |
|---|---|
| **`[mine]`** | Written in this config. The `file:line` points at this repo. It only changes when *you* change it. |
| **`[plugin default]`** | Not configured here — it comes from the plugin as shipped. The `file:line` points into `~/.local/share/nvim/lazy/…`. **This can change when the plugin is updated.** |
| **`[no entry point]`** | Present in the config, but nothing currently reaches it, or it fails when reached. Listed so it is not mistaken for a working feature. See [the dedicated section](#present-in-the-config-but-with-no-working-entry-point). |

Only three plugins provide git functionality here:

| Plugin | Spec | Role |
|---|---|---|
| `gitsigns.nvim` | `lua/plugins/git.lua:39` | in-buffer signs, hunks, blame |
| `diffview-plus.nvim` | `lua/plugins/git.lua:7` | full-tab diff / file history |
| `snacks.nvim` | `lua/plugins/snacks.lua:2` | git pickers, lazygit, gitbrowse |

`lua/config/keymaps.lua` contains **no git mappings at all** — it was checked
end to end (175 lines). Every git key below comes from a plugin spec's `keys =`
table.

---

## 1. Cheat sheet — the keys written in this config

All `[mine]`.

### In the buffer you are editing (gitsigns)

| Key | Does | Source |
|---|---|---|
| `gj` | next hunk, then `zz` to recentre | `lua/plugins/git.lua:55` |
| `gk` | previous hunk, then `zz` | `lua/plugins/git.lua:56` |
| `ga` | preview the hunk in a float | `lua/plugins/git.lua:57` |
| `<leader>ghp` | preview the hunk *inline*, in the buffer | `lua/plugins/git.lua:66` |
| `<leader>ghs` | stage hunk | `lua/plugins/git.lua:58` |
| `<leader>ghr` | reset (discard) hunk | `lua/plugins/git.lua:59` |
| `<leader>ghS` | stage the whole buffer | `lua/plugins/git.lua:60` |
| `<leader>ghu` | undo the last stage | `lua/plugins/git.lua:61` |
| `<leader>ghd` | diff this file against the index (`:diffthis`) | `lua/plugins/git.lua:62` |
| `<leader>ghb` | blame popup for the current line (full commit) | `lua/plugins/git.lua:63` |
| `<leader>ghB` | toggle the always-on current-line blame | `lua/plugins/git.lua:64` |
| `<leader>ghf` | blame the whole file in a side panel | `lua/plugins/git.lua:65` |

Note `gj` / `gk` are **remapped away from their Vim meanings** (down/up by
display line). `lua/config/keymaps.lua:61-62` maps plain `j` / `k` to `gj` / `gk`
*as builtins*, so wrapped-line movement still works on `j` / `k`; the `g`-prefixed
keys are hunk navigation here.

### Pickers (snacks)

| Key | Does | Source |
|---|---|---|
| `<leader>gs` | git status picker | `lua/plugins/snacks.lua:181` |
| `<leader>gd` | git diff, hunk by hunk | `lua/plugins/snacks.lua:183` |
| `<leader>gl` | git log (repo) | `lua/plugins/snacks.lua:179` |
| `<leader>gL` | git log for the current *line* | `lua/plugins/snacks.lua:180` |
| `<leader>gf` | git log for the current *file* | `lua/plugins/snacks.lua:184` |
| `<leader>gb` | branches | `lua/plugins/snacks.lua:178` |
| `<leader>gS` | stashes | `lua/plugins/snacks.lua:182` |
| `<leader>gB` | open the current file/selection on the git host (n + v) | `lua/plugins/snacks.lua:185` |
| `<leader>gg` | lazygit | `lua/plugins/snacks.lua:186` |
| `<leader>fg` | find files, tracked-by-git only | `lua/plugins/snacks.lua:171` |

**One deliberate override worth knowing.** In `<leader>gl` and `<leader>gL`,
pressing `<CR>` on a commit opens **that commit's diff** — set at
`lua/plugins/snacks.lua:76-83` and `lua/plugins/snacks.lua:84-91`. That replaces
snacks' shipped behaviour, which is `confirm = "git_checkout"`.
**`<leader>gf` (`git_log_file`) was not given the same override**, so there
`<CR>` still *checks out* the commit — see
[the plugin-default section](#2-what-you-get-for-free-plugin-defaults-not-set-here).

### Diffview

| Key | Does | Source |
|---|---|---|
| `<leader>gdo` | `:DiffviewOpen` — working tree vs index/HEAD in a new tab | `lua/plugins/git.lua:11` |
| `<leader>gdc` | `:DiffviewClose` | `lua/plugins/git.lua:12` |
| `<leader>gdh` | file history of the **current** file | `lua/plugins/git.lua:13` |
| `<leader>gdH` | file history of the **whole repo** | `lua/plugins/git.lua:14` |

Inside the diffview **file panel**, this config adds five keys of its own on top
of the plugin's defaults (`lua/plugins/git.lua:23-34`):

| Key | Does | Source |
|---|---|---|
| `q` | close the diffview tab | `lua/plugins/git.lua:25` |
| `a` | stage / unstage the entry under the cursor | `lua/plugins/git.lua:26` |
| `A` | stage everything | `lua/plugins/git.lua:27` |
| `d` | restore (discard) the entry | `lua/plugins/git.lua:28` |
| `C` | drop into lazygit | `lua/plugins/git.lua:29` |

and one in the **file-history panel**: `q` closes the tab
(`lua/plugins/git.lua:32`).

Both panels show a winbar with the diff's revision info, turned on at
`lua/plugins/git.lua:19-22`.

### Context menu

`<M-l>` or `<C-g>` opens the context menu, in normal *and* visual mode —
`lua/plugins/context-menu.lua:286-287`. Its git-relevant entries:

| Entry | Does | Source |
|---|---|---|
| `Copy Line Reference` | copies `path/from/git/root:line:col` to the system clipboard; warns if the file is not in a repo | `lua/plugins/context-menu.lua:56-71` |
| `Git ▸ File History :: Diffview` | `:DiffviewFileHistory %`, hidden on buffers with no real file behind them | `lua/plugins/context-menu.lua:235-250` |
| `Diffview: Clear File Selections` | **the only way to reach this action** — see the note below | `lua/plugins/context-menu.lua:130-135` |
| `Diffview: Toggle File Selection` | mark/unmark entries for multi-file operations | `lua/plugins/context-menu.lua:124-129` |
| `Diffview: Unstage All` | unstage everything | `lua/plugins/context-menu.lua:136-141` |
| `Diffview: Toggle Untracked Files` | show/hide untracked files in the panel | `lua/plugins/context-menu.lua:142-147` |
| `Diffview: Inline (unified) Diff` | single-pane unified diff, the fork's headline feature; bound to no key by any default | `lua/plugins/context-menu.lua:148-161` |
| `Diffview: Cycle Layout (split orientation)` | horizontal ⇄ vertical split, and the way back out of the inline view | `lua/plugins/context-menu.lua:162-172` |
| `Diffview: Commit Log for This File` | only meaningful when the panel shows a commit range | `lua/plugins/context-menu.lua:173-182` |

The five `Diffview: …` entries above only appear when a `DiffviewFiles` panel is
focused (`ft` gate). **"Clear File Selections" is load-bearing**: the plugin
binds it to `C` by default, and `lua/plugins/git.lua:29` takes `C` for lazygit —
so with `C` shadowed, the context menu is the only remaining route to it. That
reasoning is written down in the config itself at
`lua/plugins/context-menu.lua:118-120`.

### Ambient / passive

| What | Source | Marker |
|---|---|---|
| Current-line blame virtual text, always on, 300 ms delay | `lua/plugins/git.lua:42-43` | `[mine]` |
| Blame format `<author>, <YYYY-MM-DD> - <summary>` | `lua/plugins/git.lua:44` | `[mine]` |
| Custom sign glyphs (`▎` for add/change/untracked, `` for deletes) | `lua/plugins/git.lua:45-52` | `[mine]` |
| Statusline shows branch + added/changed/removed counts | `lua/plugins/lualine.lua:22` | `[mine]` |
| `GitSignsChange` recoloured to the theme's peach | `lua/plugins/colorscheme.lua:56` | `[mine]` |
| gitsigns highlight integration enabled in the theme | `lua/plugins/colorscheme.lua:75` | `[mine]` |
| `<leader>g` labelled "git" in which-key | `lua/plugins/which-key.lua:12` | `[mine]` |
| `.git` used to detect a project root (`<leader>fp`) | `lua/plugins/cd-project.lua:6` | `[mine]` |
| `.git` used as an LSP root marker | `lua/plugins/lsp.lua:119` | `[mine]` |

gitsigns loads on `BufReadPost` (`lua/plugins/git.lua:40`), so signs and blame
appear as soon as a file is opened — no key needed.

---

## 2. What you get for free — plugin defaults, not set here

These are **not** in this repo. They come from the installed plugins and can
change when a plugin is updated. Line references point into
`~/.local/share/nvim/lazy/`.

### gitsigns ships no keymaps at all

`gitsigns.nvim` defines no default mappings; its only default entry point is the
`:Gitsigns <action>` command (verified: `exists(':Gitsigns')` returns `2` with
this config loaded). So **every gitsigns key in section 1 is this config's own**,
and anything not listed there is reachable only via `:Gitsigns`, e.g.
`:Gitsigns toggle_deleted`, `:Gitsigns setqflist`, `:Gitsigns diffthis HEAD~1`.

### snacks git pickers — keys *inside* the picker

| Picker | Key | Does | Plugin source |
|---|---|---|---|
| `<leader>gs`, `<leader>gd` | `<Tab>` | stage the file/hunk under the cursor | `snacks.nvim/lua/snacks/picker/config/sources.lua:451-454` and `:472-475` |
| `<leader>gs`, `<leader>gd` | `<C-r>` | restore (discard) it | same lines |
| `<leader>gb` | `<C-a>` | create a branch | `…/sources.lua:352-353` |
| `<leader>gb` | `<C-x>` | delete a branch | `…/sources.lua:352-353` |
| `<leader>gb` | `<CR>` | **checks out** the branch | `…/sources.lua:348` |
| `<leader>gS` | `<CR>` | **applies** the stash | `…/sources.lua:436-441` |
| `<leader>gf` | `<CR>` | **checks out that commit** (detached HEAD) | `…/sources.lua:415-423` |

The last row is the sharp edge: `<leader>gl` / `<leader>gL` were overridden to
show a diff instead (`lua/plugins/snacks.lua:76-91`), but `<leader>gf` was not,
so it kept `confirm = "git_checkout"`. Verified at runtime — see
[section 5](#5-what-was-actually-run-in-a-real-neovim).

### snacks explorer shows git status

`<leader>e` (`lua/plugins/snacks.lua:155-163`) opens the explorer. Git status
markers, including untracked files, are on because snacks defaults them on
(`…/sources.lua:58-60`), not because this config asks for them.

### diffview panel keys this config did not touch

The panel keymaps in `lua/plugins/git.lua:23-34` are **merged with**, not
substituted for, the plugin's defaults — so both sets are live. In the **file
panel** (`diffview-plus.nvim/lua/diffview/config.lua:716-739`):

| Key | Does |
|---|---|
| `-` / `s` | stage / unstage entry (`config.lua:719-720`) — same action as this config's `a` |
| `S` | stage all (`config.lua:721`) — same as `A` |
| `U` | unstage all (`config.lua:722`) |
| `X` | restore entry (`config.lua:723`) — same as `d` |
| `w` | toggle file selection (`config.lua:717`) |
| `L` / `gL` | commit log, panel-wide / for the file under the cursor (`config.lua:724-725`) |
| `i` | toggle list ⇄ tree listing (`config.lua:727`) |
| `R` | refresh entries (`config.lua:729`) |
| `g<C-x>` | cycle layout (`config.lua:730`) |
| `g?` | open the help panel — the authoritative list (`config.lua:733`) |
| `[x` / `]x` | previous / next merge conflict (`config.lua:731-732`) |

In the **file-history panel** (`config.lua:740-749`): `y` copies the commit
hash, `H` diffs the commit under the cursor against HEAD, `L` shows commit
details, `X` restores the file to that commit, `g!` opens the option panel.

Shared by both panels (`config.lua:73-104`): `<Tab>` / `<S-Tab>` next/previous
file, `j`/`k` move by entry, `<CR>` / `o` / `l` open the diff, `gf` opens the real
file in the previous tab, `zo`/`zc`/`za`/`zR`/`zM` fold controls.

> ⚠️ **Shadowing to be aware of.** Inside diffview windows the plugin binds
> `<leader>e` to "focus file panel" and `<leader>b` to "toggle file panel"
> (`config.lua:82-83`), and `<leader>c…` to conflict resolution
> (`config.lua:114-126`). While a diffview tab is focused those win over this
> config's `<leader>e` (explorer), `<leader>b` (buffer group) and `<leader>c`
> (code group). `g?` is the fastest way to see what is actually bound.

### `C` in the diffview panel

`C` is `clear_select_entries` by default (`config.lua:718`).
`lua/plugins/git.lua:29` overrides it with lazygit — that is the whole reason the
context-menu entry in section 1 exists.

---

## 3. Present in the config, but with no working entry point

Listed here rather than above, because they read like features and are not.

### 3.1 The context-menu `git` module is mostly dead — 8 of its 11 entries

`lua/plugins/context-menu.lua:42` enables `modules = { "git" }`. That module
(`context-menu.nvim/lua/context-menu/modules/git.lua`) was written against
[VGit.nvim](https://github.com/tanvirtin/vgit.nvim), **which is not installed
here** — it is not in `lazy-lock.json`, and `exists(':VGit')` returns `0`.

Dependencies are checked when an item is *chosen*, not when the menu is built
(`context-menu.nvim/lua/context-menu/ui/init.lua:60`), so these entries **are
listed in the menu** and fail with a
`VGit.nvim is required — install tanvirtin/vgit.nvim` notice when picked:

| Menu entry | Module source |
|---|---|
| `Git: Status` | `modules/git.lua:3-10` |
| `Git ▸ Project Diff` | `modules/git.lua:23-29` |
| `Git ▸ Project Histories :: VGit` | `modules/git.lua:30-37` |
| `Git ▸ Project Stash` | `modules/git.lua:46-52` |
| `Git ▸ Buffer Diff` | `modules/git.lua:53-59` |
| `Git ▸ Buffer Histories` | `modules/git.lua:60-67` |
| `Git ▸ Reset Hunk` | `modules/git.lua:89-95` |
| `Git ▸ Reset Buffer` | `modules/git.lua:96-102` |

The three that **do** work come from the same module and need no VGit:
`Git ▸ Buffer Blame` and `Git ▸ Blame Line` (gitsigns,
`modules/git.lua:68-81`) and `Git ▸ Open in github` (snacks gitbrowse,
`modules/git.lua:82-88`) — plus `Git: Add .`, which just runs `!git add .`
(`modules/git.lua:11-18`). Note `Git ▸ Reset Hunk` being dead is harmless in
practice: `<leader>ghr` (`lua/plugins/git.lua:59`) already does it.

### 3.2 The `Diffview ▸` menu group is dead until diffview has been loaded once

`lua/plugins/context-menu.lua:256-282` adds `Toggle Diffview`,
`Diff Two Files…` and `Diff Two Directories…`. Their `deps` require the
commands `:DiffviewToggle` / `:DiffviewDiffFiles` / `:DiffviewDiffDirs` to
exist — but `lua/plugins/git.lua:9` only lists `DiffviewOpen` and
`DiffviewFileHistory` as lazy-load triggers, so lazy.nvim creates stubs for
those two commands only.

Measured in a fresh session:

```
BEFORE any diffview use          AFTER pressing <leader>gdo once
:DiffviewOpen        exists=2    :DiffviewOpen        exists=2
:DiffviewFileHistory exists=2    :DiffviewFileHistory exists=2
:DiffviewToggle      exists=0    :DiffviewToggle      exists=2
:DiffviewDiffFiles   exists=0    :DiffviewDiffFiles   exists=2
:DiffviewDiffDirs    exists=0    :DiffviewDiffDirs    exists=2
```

So on a cold start those three entries answer
`requires diffview-plus.nvim`; after any `<leader>gdo` / `<leader>gdh` in the
same session they work. Adding the three names to
`lua/plugins/git.lua:9` would fix it. **This page documents the behaviour; it
does not change the config.**

### 3.3 Reachable capability with no key bound

`:Gitsigns select_hunk` (the "inside hunk" text object, `gitsigns/actions.lua:624`)
is not mapped anywhere in this repo — grep for `select_hunk` in `lua/` returns
nothing. It works if typed as a command; there is no `ih` operator-pending
mapping.

### 3.4 Commented-out snacks modules that are *not* actually broken

`lua/plugins/snacks.lua:127`, `:136` and `:137` leave `lazygit`, `gitbrowse` and
`git` commented out in the "disabled by default" block. This looks like
`<leader>gg` and `<leader>gB` should not work — **they do**. Those `enabled`
flags only govern snacks' own setup pass; `Snacks.lazygit` and
`Snacks.gitbrowse` are resolved on access. Verified live: both are non-`nil`
tables with this config loaded.

---

## 4. External binaries this relies on

| Binary | Needed for | Present on this machine |
|---|---|---|
| `git` | everything | yes — `/usr/bin/git`, 2.50.1 |
| `lazygit` | `<leader>gg`, and `C` in the diffview panel | yes — `/opt/homebrew/bin/lazygit`, 0.62.2 |

Neither is declared as a dependency anywhere in this repo; `<leader>gg` simply
fails if `lazygit` is not on `$PATH`.

---

## 5. What was actually run in a real Neovim

Not read from source — executed, in a throwaway git repo with one commit and two
edited lines, using this exact config.

- **Hunk navigation (`gj` / `gk`, `lua/plugins/git.lua:55-56`).**
  gitsigns reported 2 hunks (`@@ -3,1 +3,1 @@`, `@@ -7,1 +7,1 @@`). From line 1:
  `gj` → line 3, `gj` → line 7, `gk` → line 3. *(In `--headless` the navigation
  is asynchronous and needs a moment to settle; interactively it is immediate.)*
- **Hunk preview (`ga`, `lua/plugins/git.lua:57`).** One floating window opened
  containing `Hunk 1 of 2 / -line3 / +CHANGED`.
- **Current-line blame (`lua/plugins/git.lua:42-44`).** Virtual text rendered as
  `You, 2026-08-26 - initial commit for gitsigns test` — exactly the
  `<author>, <author_time:%Y-%m-%d> - <summary>` format set on line 44.
- **Custom signs (`lua/plugins/git.lua:45-52`).** Extmarks on lines 3 and 7 with
  `sign_text="▎"` and highlight `GitSignsChange`.
- **Key resolution.** `gj`, `gk`, `ga`, `<leader>ghb`, `<leader>ghs`,
  `<leader>gg`, `<leader>gs`, `<leader>gdo`, `<leader>gl`, `<leader>gB` all
  resolve to the descriptions given in section 1.
- **Context menu registry.** Enumerated with the plugin's own `check_deps`: 8
  entries fail on missing VGit, 3 `Diffview ▸` entries fail before diffview
  loads, the rest pass. This is the evidence behind section 3.
- **Diffview panel.** After `:DiffviewOpen`, the `DiffviewFiles` buffer had
  `q`/`a`/`A`/`d`/`C` from this config **and** `s`/`S`/`X`/`U`/`w`/`L` from the
  plugin, live at the same time.
- **`<leader>gf` checkout behaviour.** The resolved picker config reports
  `git_log_file confirm=git_checkout`, while `git_log` and `git_log_line` report
  a Lua function (this config's override).

---

## What this page does **not** cover

Stated plainly so the gaps are not mistaken for absences in the config.

**Git capabilities this config does not have:**

- **No commit/push/pull/rebase UI in Neovim.** There is no fugitive, no neogit,
  no VGit. Anything that writes history happens in `lazygit` (`<leader>gg`) or in
  a shell. `git commit` has no keybinding here.
- **No merge-conflict workflow of its own.** diffview ships conflict keymaps
  (`[x`, `]x`, `<leader>co/ct/cb/ca`), but this config neither rebinds nor
  documents them, and `<leader>c` is otherwise the "code" group.
- **No worktree management**, no PR/issue integration (no octo, no `gh` wiring —
  `gh` is installed but nothing in this repo calls it), no commit-message
  filetype setup, no `git blame`-driven code lens.
- **No `<leader>g` mapping for `git add -p`-style partial staging** beyond
  gitsigns' hunk-level staging; visual-mode range staging is available in
  gitsigns but is not mapped here (only the normal-mode `<leader>ghs` is).

**Things on this page that were *not* verified by running them:**

- `<leader>gg` (lazygit) and `<leader>gB` (gitbrowse) were verified only as far
  as *the functions exist and are callable* — neither was actually launched
  (lazygit is a full-screen TUI; gitbrowse opens a browser).
- The snacks in-picker keys (`<Tab>` stage, `<C-r>` restore, `<C-a>`/`<C-x>`
  branch add/delete) were read from the plugin's source and from the resolved
  runtime config; **the actual staging/checkout was not performed.**
- The diffview panel keys were confirmed to be *bound* to the listed actions;
  the actions themselves (stage all, restore, unstage all, inline diff) were not
  each executed.
- `<leader>gf`'s checkout behaviour is reported from the resolved config value,
  not from an actual checkout.
- Merge-conflict keymaps were read from diffview's source only — no conflict was
  constructed.
- Every `[plugin default]` line reflects the versions currently pinned in
  `lazy-lock.json`. After `:Lazy update` they must be re-checked.
