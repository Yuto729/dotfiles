return {
  "WilliamHsieh/overlook.nvim",
  event = "LspAttach",
  opts = {},
  keys = {
    -- peek
    { "gpd", function() require("overlook.api").peek_definition() end, desc = "Overlook: Peek definition" },
    { "gpc", function() require("overlook.api").peek_cursor() end, desc = "Overlook: Peek cursor" },
    { "gpm", function() require("overlook.api").peek_mark() end, desc = "Overlook: Peek mark" },
    -- focus / manage
    { "gpf", function() require("overlook.api").switch_focus() end, desc = "Overlook: Switch focus" },
    { "gP", function() require("overlook.api").close_all() end, desc = "Overlook: Close all popups" },
    { "gpu", function() require("overlook.api").restore_popup() end, desc = "Overlook: Restore popup" },
    -- promote popup to a real window
    { "gps", function() require("overlook.api").open_in_split() end, desc = "Overlook: Open in split" },
    { "gpv", function() require("overlook.api").open_in_vsplit() end, desc = "Overlook: Open in vsplit" },
    { "gpt", function() require("overlook.api").open_in_tab() end, desc = "Overlook: Open in tab" },
    { "gpo", function() require("overlook.api").open_in_original_window() end, desc = "Overlook: Open in current window" },
  },
}
