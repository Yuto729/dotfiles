return {
  "rmagatti/goto-preview",
  event = "LspAttach",
  opts = {
    border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
    dismiss_on_move = false,
    stack_floating_preview_windows = true,
    preview_window_title = { enable = true, position = "left" },
  },
  keys = {
    { "gpd", function() require("goto-preview").goto_preview_definition() end, desc = "Peek definition" },
    { "gpt", function() require("goto-preview").goto_preview_type_definition() end, desc = "Peek type definition" },
    { "gpi", function() require("goto-preview").goto_preview_implementation() end, desc = "Peek implementation" },
    { "gpr", function() require("goto-preview").goto_preview_references() end, desc = "Peek references" },
    { "gP", function() require("goto-preview").close_all_win() end, desc = "Close all peek windows" },
  },
}
