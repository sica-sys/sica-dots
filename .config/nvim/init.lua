vim.g.mapleader = " "
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({ { import = "plugins" } }, {
  checker = { enabled = false },
  change_detection = { notify = false },
})
require("mydash.modules").setup_float_terminal()
require("mydash.windows").setup()
require("mydash.tips").setup()

-- Espace + A : ouvrir l'accueil (dashboard actif) dans un nouvel onglet
vim.keymap.set("n", "<leader>A", function()
  vim.cmd("tabnew")
  local essais = {
    function() require("snacks").dashboard() end,
    function() vim.cmd("Dashboard") end,
    function() vim.cmd("Alpha") end,
    function() require("mini.starter").open() end,
  }
  for _, f in ipairs(essais) do if pcall(f) then return end end
  vim.notify("Aucun dashboard trouvé", vim.log.levels.WARN)
end, { desc = "Accueil (nouvel onglet)" })
