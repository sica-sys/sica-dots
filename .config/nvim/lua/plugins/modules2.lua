-- Modules Neovim (lot 2) : chacun s'active / se désactive avec Super+Alt+M
local on = require("mydash.modules").on
local is_on = require("mydash.modules").is_on

return {
  -- Ferme tout seul ( [ { " ' quand tu les ouvres
  { "windwp/nvim-autopairs", event = "InsertEnter", enabled = on("autopairs"), opts = { check_ts = true } },

  -- Colore les codes couleur (#c678dd, rgb(...)) directement dans le texte
  { "catgoose/nvim-colorizer.lua", event = "BufReadPre", enabled = on("colorizer"),
    opts = { user_default_options = { names = false, RRGGBBAA = true, css = true, mode = "background" } },
    keys = { { "<leader>uc", "<cmd>ColorizerToggle<cr>", desc = "Couleurs dans le texte (on/off)" } } },

  -- Arbre de l'historique d'annulation (même après avoir fermé le fichier)
  { "mbbill/undotree", cmd = "UndotreeToggle", enabled = on("undotree"),
    init = function() vim.opt.undofile = true; vim.g.undotree_SetFocusWhenToggle = 1 end,
    keys = { { "<leader>U", "<cmd>UndotreeToggle<cr>", desc = "Historique d'annulation" } } },

  -- Affiche les images dans Kitty (Markdown, et fichiers .png/.jpg ouverts)
  { "3rd/image.nvim", build = false, ft = { "markdown", "png", "jpg", "jpeg", "gif", "webp" }, enabled = on("image"),
    opts = { backend = "kitty", processor = "magick_cli",
      integrations = { markdown = { enabled = true, only_render_image_at_cursor = false } },
      max_height_window_percentage = 50,
      hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" } } },

  -- Exercices LeetCode dans Neovim  (:Leet)
  { "kawre/leetcode.nvim", cmd = "Leet", build = ":TSUpdate html", enabled = on("leetcode"),
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
    opts = { lang = "python3", cn = { enabled = false } } },

  -- Ctrl+F : chercher dans le fichier ouvert (liste des lignes trouvées + aperçu, Entrée pour y aller)
  -- Utilise snacks (déjà installé), donc aucune dépendance en plus. Remplace le Ctrl+F natif (page suivante : Ctrl+D reste dispo)
  { "folke/snacks.nvim",
    keys = is_on("recherche") and {
      { "<C-f>", function() Snacks.picker.lines() end, desc = "Chercher dans le fichier" },
      { "<C-f>", function() Snacks.picker.lines({ search = (function()
          local a, b = vim.fn.getpos("v"), vim.fn.getpos(".")
          return table.concat(vim.fn.getregion(a, b), " ") end)() }) end,
        mode = "x", desc = "Chercher la sélection dans le fichier" },
    } or {} },
}
