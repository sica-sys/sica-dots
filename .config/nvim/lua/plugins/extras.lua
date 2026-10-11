local on = require("mydash.modules").on
local api = vim.api

-- ---------- Outils tableaux ----------
local function is_row(l) return l ~= nil and l:match("^%s*|") ~= nil end
local function is_sep(l) return l ~= nil and l:match("^%s*|[%s:%-|]+$") ~= nil and l:find("%-") ~= nil end
local function cells(l) local _, n = l:gsub("|", ""); return n - 1 end
local function realign() pcall(vim.cmd, "TableModeRealign") end

local function block()
  local cur = api.nvim_win_get_cursor(0)[1]
  local n = api.nvim_buf_line_count(0)
  if not is_row(api.nvim_buf_get_lines(0, cur - 1, cur, false)[1]) then return nil end
  local s, e = cur, cur
  while s > 1 and is_row(api.nvim_buf_get_lines(0, s - 2, s - 1, false)[1]) do s = s - 1 end
  while e < n and is_row(api.nvim_buf_get_lines(0, e, e + 1, false)[1]) do e = e + 1 end
  return s, e
end

local function tableau(c, r)
  c, r = math.max(1, tonumber(c) or 3), math.max(1, tonumber(r) or 3)
  local function row(t) return "| " .. table.concat(t, " | ") .. " |" end
  local h, s, e = {}, {}, {}
  for i = 1, c do h[i] = "Titre " .. i; s[i] = "-------"; e[i] = "       " end
  local lines = { "", row(h), row(s) }
  for _ = 1, r do lines[#lines + 1] = row(e) end
  lines[#lines + 1] = ""
  local cur = api.nvim_win_get_cursor(0)[1]
  api.nvim_buf_set_lines(0, cur, cur, false, lines)
  api.nvim_win_set_cursor(0, { cur + 2, 2 })
  pcall(vim.cmd, "TableModeEnable")
end

local function demander()
  vim.ui.input({ prompt = "Nombre de colonnes : ", default = "3" }, function(c)
    if not c or c == "" then return end
    vim.ui.input({ prompt = "Nombre de lignes : ", default = "3" }, function(r)
      if r and r ~= "" then tableau(c, r) end
    end)
  end)
end

local function add_row()
  local l = api.nvim_get_current_line()
  if not is_row(l) then return vim.notify("Place le curseur dans un tableau", vim.log.levels.WARN) end
  local t = {}
  for i = 1, cells(l) do t[i] = "   " end
  local cur = api.nvim_win_get_cursor(0)[1]
  api.nvim_buf_set_lines(0, cur, cur, false, { "| " .. table.concat(t, " | ") .. " |" })
  api.nvim_win_set_cursor(0, { cur + 1, 2 })
  realign()
end

-- Répare un tableau cassé : enlève le décalage, ajoute les | manquants,
-- complète les lignes trop courtes et ajoute la ligne de tirets si besoin
local function reparer()
  local s, e = block()
  if not s then return vim.notify("Place le curseur dans le tableau à réparer", vim.log.levels.WARN) end
  local L = api.nvim_buf_get_lines(0, s - 1, e, false)
  for i, l in ipairs(L) do
    l = l:gsub("^%s+", ""):gsub("%s+$", "")
    if not l:match("|$") then l = l .. " |" end
    L[i] = l
  end
  local n = 0
  for _, l in ipairs(L) do n = math.max(n, cells(l)) end
  for i, l in ipairs(L) do
    for _ = cells(l) + 1, n do l = l .. "   |" end
    L[i] = l
  end
  if not is_sep(L[2]) then
    local t = {}
    for i = 1, n do t[i] = "-------" end
    table.insert(L, 2, "| " .. table.concat(t, " | ") .. " |")
  end
  api.nvim_buf_set_lines(0, s - 1, e, false, L)
  api.nvim_win_set_cursor(0, { s, 2 })
  realign()
  vim.notify("Tableau réparé", vim.log.levels.INFO)
end

-- Tab / Shift+Tab : case suivante / précédente (comme Word)
local function pipes(l)
  local t, i = {}, 0
  while true do i = l:find("|", i + 1, true); if not i then break end; t[#t + 1] = i end
  return t
end

local function goto_cell(back)
  realign()
  local row, col = unpack(api.nvim_win_get_cursor(0))
  local l = api.nvim_get_current_line()
  local p = pipes(l)
  local pos = col + 1
  if not back then
    for k = 1, #p - 1 do
      if p[k] >= pos then return api.nvim_win_set_cursor(0, { row, p[k] + 1 }) end
    end
    -- fin de ligne : ligne suivante (on saute la ligne de tirets), ou nouvelle ligne
    local nxt = row + 1
    local nl = api.nvim_buf_get_lines(0, nxt - 1, nxt, false)[1]
    if is_sep(nl) then nxt = nxt + 1; nl = api.nvim_buf_get_lines(0, nxt - 1, nxt, false)[1] end
    if not is_row(nl) then
      local t = {}
      for i = 1, cells(l) do t[i] = "   " end
      api.nvim_buf_set_lines(0, nxt - 1, nxt - 1, false, { "| " .. table.concat(t, " | ") .. " |" })
      realign()
    end
    return api.nvim_win_set_cursor(0, { nxt, 2 })
  else
    local a
    for k = #p, 1, -1 do if p[k] < pos then a = k; break end end
    if a and a > 1 then return api.nvim_win_set_cursor(0, { row, p[a - 1] + 1 }) end
    local prv = row - 1
    local pl = api.nvim_buf_get_lines(0, prv - 1, prv, false)[1]
    if is_sep(pl) then prv = prv - 1; pl = api.nvim_buf_get_lines(0, prv - 1, prv, false)[1] end
    if prv >= 1 and is_row(pl) then
      local q = pipes(pl)
      if #q >= 2 then api.nvim_win_set_cursor(0, { prv, q[#q - 1] + 1 }) end
    end
  end
end

local function tab_key(back)
  return function()
    if is_row(api.nvim_get_current_line()) then return goto_cell(back) end
    local k = api.nvim_replace_termcodes(back and "<S-Tab>" or "<Tab>", true, false, true)
    api.nvim_feedkeys(k, "n", false)
  end
end

return {
  { "stevearc/oil.nvim", lazy = false, enabled = on("oil"),
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { view_options = { show_hidden = true } },
    keys = {
      { "<leader>o", "<cmd>Oil<cr>", desc = "Explorer le dossier (Oil)" },
      { "-", "<cmd>Oil<cr>", desc = "Dossier parent (Oil)" },
    } },
  { "dhruvasagar/vim-table-mode", enabled = on("table-mode"),
    ft = { "markdown" }, cmd = { "Tableau", "TableModeToggle", "TableModeEnable", "TableModeRealign" },
    init = function()
      vim.g.table_mode_corner = "|"
      vim.g.table_mode_map_prefix = "<leader>T"
    end,
    config = function()
      vim.api.nvim_create_user_command("Tableau", function(o) tableau(o.fargs[1], o.fargs[2]) end,
        { nargs = "*", desc = "Créer un tableau : :Tableau colonnes lignes" })
      local grp = vim.api.nvim_create_augroup("TableauxWord", { clear = true })
      local function setup_buf(buf)
        vim.keymap.set({ "i", "n" }, "<Tab>", tab_key(false), { buffer = buf, desc = "Case suivante du tableau" })
        vim.keymap.set({ "i", "n" }, "<S-Tab>", tab_key(true), { buffer = buf, desc = "Case précédente du tableau" })
      end
      vim.api.nvim_create_autocmd("FileType", { group = grp, pattern = "markdown",
        callback = function(a) setup_buf(a.buf) end })
      if vim.bo.filetype == "markdown" then setup_buf(0) end
      vim.api.nvim_create_autocmd("InsertLeave", { group = grp, pattern = { "*.md", "*.markdown" },
        callback = function() if is_row(vim.api.nvim_get_current_line()) then realign() end end })
    end,
    keys = {
      { "<leader>Tn", demander, desc = "Nouveau tableau (choisir la taille)" },
      { "<leader>Tl", add_row, desc = "Ajouter une ligne en dessous" },
      { "<leader>Tf", reparer, desc = "Réparer le tableau" },
    } },
}
