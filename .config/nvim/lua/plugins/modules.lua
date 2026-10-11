local M = require("mydash.modules")
local on, is_on = M.on, M.is_on

local function incline_pos()
  local f = io.open(vim.fn.stdpath("config") .. "/incline-pos", "r")
  local s = f and f:read("*l") or "top-right"
  if f then f:close() end
  local v, h = (s or ""):match("^(%a+)%-(%a+)$")
  return v or "top", h or "right"
end

return {
  { "folke/which-key.nvim", event = "VeryLazy", enabled = on("which-key"), opts = { spec = require("mydash.wkfr") },
    keys = { { "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Raccourcis du buffer" } } },
  { "ThePrimeagen/vim-be-good", cmd = "VimBeGood", enabled = on("vim-be-good"),
    keys = { { "<leader>vg", "<cmd>VimBeGood<cr>", desc = "Jeu vim-be-good" } } },
  { "alex-popov-tech/store.nvim", cmd = "Store", enabled = on("store"),
    dependencies = { { "OXY2DEV/markview.nvim", opts = {} } }, opts = {},
    keys = { { "<leader>S", function() vim.cmd("tabnew") vim.cmd("Store") end, desc = "Catalogue de plugins" } } },
  { "gbprod/yanky.nvim", event = "VeryLazy", enabled = on("yanky"), opts = { highlight = { timer = 150 } },
    keys = { { "<leader>y", "<cmd>YankyRingHistory<cr>", mode = { "n", "x" }, desc = "Historique du presse-papier" } } },
  { "nvzone/showkeys", cmd = "ShowkeysToggle", enabled = on("showkeys"),
    opts = { timeout = 1, maxkeys = 5, position = "bottom-right" },
    keys = { { "<leader>k", "<cmd>ShowkeysToggle<cr>", desc = "Afficher les touches" } } },
  { "karb94/neoscroll.nvim", event = "VeryLazy", enabled = on("neoscroll"), opts = {} },

  { "akinsho/bufferline.nvim", version = "*", event = "VeryLazy", enabled = on("bufferline"),
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { options = { always_show_bufferline = false, separator_style = "slant" } },
    keys = {
      { "<leader>bl", "<cmd>BufferLineCycleNext<cr>", desc = "Page suivante" },
      { "<leader>bh", "<cmd>BufferLineCyclePrev<cr>", desc = "Page précédente" },
      { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Page suivante" },
      { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Page précédente" },
      { "<leader>bx", "<cmd>bdelete<cr>", desc = "Fermer la page" },
    } },
  { "b0o/incline.nvim", event = "VeryLazy", enabled = on("incline"),
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local v, h = incline_pos()
      local devicons = require("nvim-web-devicons")
      require("incline").setup({
        window = { placement = { horizontal = h, vertical = v }, margin = { horizontal = 1, vertical = 1 } },
        render = function(props)
          local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          if name == "" then name = "[sans nom]" end
          local icon, color = devicons.get_icon_color(name)
          local modified = vim.bo[props.buf].modified
          return {
            icon and { icon, " ", guifg = color } or "",
            { name, gui = modified and "bold,italic" or "bold" },
            modified and " ●" or "",
          }
        end,
      })
    end },

  { "folke/snacks.nvim", priority = 1000, lazy = false,
    opts = function(_, opts)
      opts = opts or {}
      opts.notifier = { enabled = is_on("snacks-notifier") }
      opts.scroll = { enabled = is_on("snacks-scroll") }
      opts.indent = { enabled = is_on("snacks-indent") }
      opts.input = { enabled = is_on("snacks-input") }
      opts.dim = opts.dim or {}
      opts.zen = { toggles = { dim = is_on("snacks-dim") } }
      opts.scratch = opts.scratch or {}
      return opts
    end,
    keys = {
      { "<leader>z", function() Snacks.zen() end, desc = "Mode zen" },
      { "<leader>.", function() Snacks.scratch() end, desc = "Bloc-notes temporaire" },
      { "<leader>,", function() Snacks.scratch.select() end, desc = "Choisir un bloc-notes" },
      { "<leader>n", function() Snacks.notifier.show_history() end, desc = "Historique des notifications" },
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Fermer les notifications" },
      { "<leader>Z", function()
          if not is_on("snacks-dim") then return vim.notify("dim est désactivé (Super+Alt+M)") end
          local ok = pcall(function() Snacks.toggle.dim():toggle() end)
          if not ok then if Snacks.dim.enabled then Snacks.dim.disable() else Snacks.dim.enable() end end
        end, desc = "Assombrir autour du paragraphe" },
      { "<leader>R", function()
          if not is_on("snacks-rename") then return vim.notify("rename est désactivé (Super+Alt+M)") end
          Snacks.rename.rename_file()
        end, desc = "Renommer le fichier" },
    } },
  { "OXY2DEV/markview.nvim", lazy = false, opts = {},
    keys = { { "<leader>m", "<cmd>Markview toggle<cr>", desc = "Rendu Markdown" } } },
  { "Eandrju/cellular-automaton.nvim", cmd = "CellularAutomaton", enabled = on("cellular-automaton"),
    keys = {
      { "<leader>cr", "<cmd>CellularAutomaton make_it_rain<cr>", desc = "Le texte fond comme de la pluie" },
      { "<leader>cg", "<cmd>CellularAutomaton game_of_life<cr>", desc = "Jeu de la vie" },
    } },
  { "tamton-aquib/duck.nvim", enabled = on("duck"),
    keys = {
      { "<leader>dd", function() require("duck").hatch("🦆", 10) end, desc = "Faire apparaître un canard" },
      { "<leader>dk", function() require("duck").cook() end, desc = "Retirer un canard" },
      { "<leader>da", function() require("duck").cook_all() end, desc = "Retirer tous les canards" },
    } },
}
