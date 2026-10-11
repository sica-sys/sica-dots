local function read(path, default)
  local f = io.open(vim.fn.stdpath("config") .. "/" .. path, "r")
  if not f then return default end
  local s = f:read("*l"); f:close()
  return (s and s ~= "") and s or default
end

local scheme = read("colorscheme", "default")
if scheme ~= "default" then
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function() vim.schedule(function() pcall(vim.cmd.colorscheme, scheme) end) end,
  })
end

return {
  { "catppuccin/nvim", name = "catppuccin", lazy = true, opts = { transparent_background = true } },
  { "folke/tokyonight.nvim", lazy = true, opts = { transparent = true, styles = { sidebars = "transparent", floats = "transparent" } } },
  { "rose-pine/neovim", name = "rose-pine", lazy = true, opts = { styles = { transparency = true } } },
  { "rebelot/kanagawa.nvim", lazy = true, opts = { transparent = true } },
}
