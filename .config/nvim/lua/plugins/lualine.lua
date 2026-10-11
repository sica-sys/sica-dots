local state_file = vim.fn.stdpath("config") .. "/lualine-theme"

local function read_theme()
  local file = io.open(state_file, "r")
  if not file then return "auto" end
  local theme = file:read("*l")
  file:close()

  local allowed = {
    auto=true, ["16color"]=true, ayu_dark=true, ayu_mirage=true, ayu=true,
    base16=true, codedark=true, dracula=true, everforest=true,
    gruvbox_dark=true, gruvbox=true, ["gruvbox-material"]=true, horizon=true,
    iceberg_dark=true, iceberg=true, jellybeans=true, material=true,
    ["modus-vivendi"]=true, molokai=true, moonfly=true, nightfly=true,
    nord=true, OceanicNext=true, onedark=true, palenight=true,
    papercolor_dark=true, PaperColor=true, powerline=true,
    powerline_dark=true, pywal=true, seoul256=true, solarized_dark=true,
    Tomorrow=true, tomorrow_night=true, wombat=true,
  }

  return allowed[theme] and theme or "auto"
end

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  config = function()
    require("lualine").setup({
      options = {
        theme = read_theme(),
        icons_enabled = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "filename" },
        lualine_x = { "filetype", "encoding" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    })
  end,
}
