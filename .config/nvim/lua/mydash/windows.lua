local M = {}

local function quatre()
  vim.cmd("tabnew")
  vim.cmd("vsplit")
  vim.cmd("split")
  vim.cmd("wincmd l")
  vim.cmd("split")
  vim.cmd("wincmd =")
  vim.cmd("wincmd t")
end

function M.setup()
  local map = vim.keymap.set
  map("n", "<leader>wv", "<cmd>vnew<cr>", { desc = "Fenêtre vide à côté" })
  map("n", "<leader>ws", "<cmd>new<cr>", { desc = "Fenêtre vide en dessous" })
  map("n", "<leader>wV", "<cmd>vsplit<cr>", { desc = "Dupliquer à côté" })
  map("n", "<leader>wS", "<cmd>split<cr>", { desc = "Dupliquer en dessous" })
  map("n", "<leader>wq", "<cmd>close<cr>", { desc = "Fermer la fenêtre" })
  map("n", "<leader>wo", "<cmd>only<cr>", { desc = "Garder seulement celle-ci" })
  map("n", "<leader>w=", "<C-w>=", { desc = "Égaliser les fenêtres" })
  map("n", "<leader>w4", quatre, { desc = "4 fenêtres en grille" })
  map("n", "<C-h>", "<C-w>h", { desc = "Fenêtre de gauche" })
  map("n", "<C-j>", "<C-w>j", { desc = "Fenêtre du dessous" })
  map("n", "<C-k>", "<C-w>k", { desc = "Fenêtre du dessus" })
  map("n", "<C-l>", "<C-w>l", { desc = "Fenêtre de droite" })
  vim.api.nvim_create_user_command("Quatre", quatre, { desc = "Ouvre 4 fenêtres en grille 2x2 dans un nouvel onglet" })
end

return M
