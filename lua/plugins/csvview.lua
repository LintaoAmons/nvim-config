-- Tabular view for CSV/TSV files: aligns delimited columns into a readable grid
-- so a raw comma-soup file reads like a spreadsheet, without rewriting the
-- buffer. Not auto-enabled -- it is toggled on demand, and the discoverable
-- entry point is the CSV submenu added in plugins/context-menu.lua (gated to
-- the csv/tsv filetypes), which is what master asked for.
--
-- display_mode = "border": draw real box-drawing separators between columns
-- (the "looks like a table" rendering) rather than the default "highlight",
-- which only tints alternating columns.
--
-- Lazy-loaded on the csv/tsv filetypes and on its own commands, so it costs
-- nothing until a delimited file is actually opened.
return {
  "hat0uma/csvview.nvim",
  ft = { "csv", "tsv" },
  cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
  opts = {
    view = {
      display_mode = "border",
    },
  },
}
