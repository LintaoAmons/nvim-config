; Overrides nvim-treesitter (master) markdown injections, whose
; #set-lang-from-info-string! directive reads match[id] as a single node.
; Neovim 0.11+ made query matches lists of nodes, so that directive crashes
; injection parsing on codeblocks ("attempt to call method 'range' (a nil value)").
; This mirrors Neovim's built-in query and captures the language directly.

(fenced_code_block
  (info_string
    (language) @injection.language)
  (code_fence_content) @injection.content)

((html_block) @injection.content
  (#set! injection.language "html")
  (#set! injection.combined)
  (#set! injection.include-children))

((minus_metadata) @injection.content
  (#set! injection.language "yaml")
  (#offset! @injection.content 1 0 -1 0)
  (#set! injection.include-children))

((plus_metadata) @injection.content
  (#set! injection.language "toml")
  (#offset! @injection.content 1 0 -1 0)
  (#set! injection.include-children))

([
  (inline)
  (pipe_table_cell)
] @injection.content
  (#set! injection.language "markdown_inline"))
