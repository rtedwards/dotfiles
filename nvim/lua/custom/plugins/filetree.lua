-- File: lua/custom/plugins/filetree.lua

return {
  "nvim-neo-tree/neo-tree.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require('neo-tree').setup {
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      use_libuv_file_watcher = true
    }
  end,
}
