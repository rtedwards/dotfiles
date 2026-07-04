-- File: lua/custom/plugins/git-blame.lua

return {
  "f-person/git-blame.nvim",
  config = function()
    require("gitblame").setup { enabled = true }
  end,
}
