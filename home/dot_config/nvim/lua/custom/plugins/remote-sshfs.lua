-- init.lua requires remote-sshfs at top level (see "[[Configure remote-sshfs]]"),
-- so it must be declared here or nvim errors on a fresh machine. lazy=false so
-- it's loaded before that require runs.
return {
  'nosduco/remote-sshfs.nvim',
  dependencies = { 'nvim-telescope/telescope.nvim' },
  lazy = false,
}
