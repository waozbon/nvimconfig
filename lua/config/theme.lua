local M = {}

M.setup = function()
  local status_ok, tokyonight = pcall(require, "tokyonight")
  if not status_ok then
    vim.notify("Plugin 'tokyonight' no encontrado", vim.log.levels.WARN)
    return
  end

  tokyonight.setup({
    style = "storm", -- "night", "storm", "day", "moon"
    light_style = "day",
    transparent = false, -- Habilitar fondo transparente
    terminal_colors = true,
    styles = {
      comments = { italic = true },
      keywords = { italic = true },
      functions = {},
      variables = {},
      sidebars = "dark", -- "dark", "transparent"
      floats = "dark",   -- "dark", "transparent"
    },
    -- Puedes personalizar colores aquí si lo deseas
    -- on_colors = function(colors)
    --   colors.comment = "#another_color"
    -- end,
  })

  -- Cargar el esquema de color
  vim.cmd.colorscheme("tokyonight")
  print("Tema Tokyonight cargado")
end

return M
