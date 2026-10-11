local M = {}

local defaults = {
  ["which-key"] = true, ["vim-be-good"] = true, tips = true, store = true,
  yanky = true, ["float-terminal"] = true, showkeys = false, neoscroll = false, ["snacks-notifier"] = true, ["snacks-scroll"] = false, ["snacks-indent"] = false, ["cellular-automaton"] = true, duck = true, bufferline = true, incline = true, ["snacks-rename"] = true, ["snacks-dim"] = true, ["snacks-input"] = true, oil = true, ["table-mode"] = true,
  autopairs = true, colorizer = true, undotree = true, image = true, leetcode = false, recherche = true,
}

local state = {}
do
  local f = io.open(vim.fn.stdpath("config") .. "/modules.conf", "r")
  if f then
    for line in f:lines() do
      local k, v = line:match("^([%w%-_]+)=(%a+)$")
      if k then state[k] = (v == "on") end
    end
    f:close()
  end
end

function M.is_on(name)
  if state[name] ~= nil then return state[name] end
  return defaults[name] == true
end

function M.on(name) return function() return M.is_on(name) end end

-- Terminal flottant maison (aucun plugin)
function M.setup_float_terminal()
  if not M.is_on("float-terminal") then return end
  local term = { buf = nil, win = nil }
  local function toggle()
    if term.win and vim.api.nvim_win_is_valid(term.win) then
      vim.api.nvim_win_hide(term.win)
      term.win = nil
      return
    end
    local new = false
    if not (term.buf and vim.api.nvim_buf_is_valid(term.buf)) then
      term.buf = vim.api.nvim_create_buf(false, true)
      new = true
    end
    local w = math.floor(vim.o.columns * 0.8)
    local h = math.floor(vim.o.lines * 0.8)
    term.win = vim.api.nvim_open_win(term.buf, true, {
      relative = "editor", width = w, height = h,
      row = math.floor((vim.o.lines - h) / 2), col = math.floor((vim.o.columns - w) / 2),
      style = "minimal", border = "rounded",
    })
    if new then
      vim.fn.jobstart(vim.o.shell, { term = true })
      vim.api.nvim_create_autocmd("TermClose", {
        buffer = term.buf,
        callback = function()
          if term.win and vim.api.nvim_win_is_valid(term.win) then vim.api.nvim_win_close(term.win, true) end
          term.win, term.buf = nil, nil
        end,
      })
    end
    vim.cmd.startinsert()
  end
  vim.keymap.set("n", "<leader>t", toggle, { desc = "Terminal flottant" })
  vim.keymap.set("t", "<C-t>", toggle, { desc = "Fermer le terminal flottant" })
end

return M
