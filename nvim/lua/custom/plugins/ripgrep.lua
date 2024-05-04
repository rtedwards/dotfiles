return {
  "mangelozzi/nvim-rgflow.lua",
  -- Optional dependency
  config = function()
    require("rgflow").setup(
      {
        default_trigger_mappings = true,
        default_ui_mappings = true,
        default_quickfix_mappings = true,

        -- WARNING !!! Glob for '-g *{*}' will not use .gitignore file: https://github.com/BurntSushi/ripgrep/issues/2252
        cmd_flags = ("--smart-case -g *.{*,py} -g !*.{min.js,pyc} --fixed-strings --no-fixed-strings --no-ignore -M 500"
          -- Exclude globs
          .. " -g !**/venv/"
          .. " -g !**/*.lock/"
          .. " -g !**/.angular/"
          .. " -g !**/node_modules/"
          .. " -g !**/static/*/jsapp/"
          .. " -g !**/static/*/wcapp/"
          .. " -g !**/.ipynb_checkpoints/"
          .. " -g !**/.mypy_cache/"
        )
      }
    )
  end,
}
