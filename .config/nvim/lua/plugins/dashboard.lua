local function read(path, default)
  local f = io.open(vim.fn.stdpath("config") .. "/" .. path, "r")
  if not f then return default end
  local s = f:read("*l"); f:close()
  return (s and s ~= "") and s or default
end

local choice = read("dashboard-choice", "snacks-default")
local milli_on = read("dashboard-milli", "off") == "on"
local splash_name = read("dashboard-splash", "random")
local H = require("mydash.header")

local function is(prefix) return choice:sub(1, #prefix) == prefix end

-- Logo : image 1 du splash milli si actif, sinon logo perso
local function logo()
  if milli_on then
    local ok, s = pcall(function() return require("milli").load({ splash = splash_name }) end)
    if ok and type(s) == "table" and s.frames and s.frames[1] then
      return vim.deepcopy(s.frames[1])
    end
  end
  return vim.deepcopy(H)
end

-- Lance l'animation apres la creation du dashboard
local function after_milli(fn)
  if not milli_on then return end
  pcall(function() require("milli")[fn]({ splash = splash_name, loop = true }) end)
end

local function strip_search(node)
  if type(node) ~= "table" or type(node.val) ~= "table" then return end
  for i = #node.val, 1, -1 do
    local c = node.val[i]
    if type(c) == "table" and c.type == "button" and type(c.val) == "string"
      and (c.val:lower():find("find") or c.val:lower():find("grep")) then
      table.remove(node.val, i)
    else
      strip_search(c)
    end
  end
end

return {
  { "amansingh-afk/milli.nvim", lazy = false },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    dependencies = { "amansingh-afk/milli.nvim" },
    opts = function()
      if not is("snacks") then return { dashboard = { enabled = false } } end
      local keys = {
        { key = "n", desc = "Nouveau fichier", action = ":ene | startinsert" },
        { key = "l", desc = "Lazy", action = ":Lazy" },
        { key = "q", desc = "Quitter", action = ":qa" },
      }
      local sections = { { section = "header" }, { section = "keys", gap = 1, padding = 1 } }
      table.insert(sections, { section = "recent_files", limit = (choice == "snacks-compact") and 3 or 6, padding = 1 })
      if choice ~= "snacks-compact" then table.insert(sections, { section = "startup" }) end
      return { dashboard = { enabled = true, preset = { header = table.concat(logo(), "\n"), keys = keys }, sections = sections } }
    end,
    config = function(_, opts)
      require("snacks").setup(opts)
      if is("snacks") then after_milli("snacks") end
    end,
  },
  {
    "nvimdev/dashboard-nvim",
    lazy = not is("dashnvim"),
    event = is("dashnvim") and "VimEnter" or nil,
    dependencies = { "amansingh-afk/milli.nvim" },
    config = function()
      local theme = choice:sub(10)
      local L = logo()
      local cfg = { theme = theme, config = {} }
      if theme == "doom" then
        cfg.config = {
          header = vim.list_extend({ "", "" }, L),
          center = {
            { icon = "", desc = "Nouveau fichier", key = "n", action = "enew" },
            { icon = "", desc = "Lazy", key = "l", action = "Lazy" },
            { icon = "", desc = "Quitter", key = "q", action = "qa" },
          },
          footer = {},
        }
      else
        cfg.config = {
          shortcut = {
            { desc = "Lazy", group = "@property", action = "Lazy", key = "l" },
            { desc = "Nouveau", group = "Label", action = "enew", key = "n" },
          },
          project = { enable = false },
          mru = { limit = 8 },
          footer = {},
        }
        if milli_on then cfg.config.header = L else cfg.config.week_header = { enable = true } end
      end
      if theme == "doom" then vim.list_extend(cfg.config.center, require("mydash.recent").doom()) end
      require("dashboard").setup(cfg)
      after_milli("dashboard")
    end,
  },
  {
    "goolord/alpha-nvim",
    lazy = not is("alpha"),
    event = is("alpha") and "VimEnter" or nil,
    dependencies = { "nvim-tree/nvim-web-devicons", "amansingh-afk/milli.nvim" },
    config = function()
      local theme = choice:sub(7)
      local ok, t = pcall(require, "alpha.themes." .. theme)
      if not ok then return end
      if theme == "dashboard" then
        t.section.buttons.val = {
          t.button("n", "  Nouveau fichier", "<cmd>ene | startinsert<CR>"),
          t.button("l", "  Lazy", "<cmd>Lazy<CR>"),
          t.button("q", "  Quitter", "<cmd>qa<CR>"),
        }
      end
      if (theme == "dashboard" or milli_on) and t.section and t.section.header then
        t.section.header.val = logo()
      end
      strip_search({ val = t.config.layout })
      if theme == "dashboard" then require("mydash.recent").alpha(t) end
      require("alpha").setup(t.config)
      after_milli("alpha")
    end,
  },
  {
    "echasnovski/mini.starter",
    version = false,
    lazy = not is("mini"),
    dependencies = { "amansingh-afk/milli.nvim" },
    config = function()
      local s = require("mini.starter")
      s.setup({
        header = table.concat(logo(), "\n"),
        items = {
          s.sections.recent_files(5, false, false),
          {
            { name = "Nouveau fichier", action = "enew", section = "Actions" },
            { name = "Lazy", action = "Lazy", section = "Actions" },
            { name = "Quitter", action = "qa", section = "Actions" },
          },
        },
        content_hooks = { s.gen_hook.adding_bullet(), s.gen_hook.aligning("center", "center") },
      })
      after_milli("starter")
    end,
  },
}
