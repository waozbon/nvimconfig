local M = {}

M.setup = function()
  local status_ok, telescope = pcall(require, "telescope")
  if not status_ok then
    vim.notify("Plugin 'telescope' no encontrado", vim.log.levels.WARN)
    return
  end

  local actions = require("telescope.actions")

  telescope.setup({
    defaults = {
      prompt_prefix = "  ",
      selection_caret = " ",
      path_display = { "smart" },
      mappings = {
        i = {
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
          ["<esc>"] = actions.close,
        },
        n = {
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
        },
      },
    },
    pickers = {
      find_files = {
        theme = "dropdown",
        previewer = true,
        hidden = true, -- Mostrar archivos ocultos
      },
      live_grep = {
        theme = "dropdown",
        previewer = true,
      },
      buffers = {
        theme = "dropdown",
        previewer = true,
        sort_mru = true,
        ignore_current_buffer = true,
      },
      oldfiles = {
        theme = "dropdown",
        previewer = true,
      },
      lsp_references = {
        theme = "dropdown",
        previewer = true,
      },
      lsp_definitions = {
        theme = "dropdown",
        previewer = true,
      },
      lsp_implementations = {
        theme = "dropdown",
        previewer = true,
      },
    },
    extensions = {
      fzf = {
        fuzzy = true,                   -- Habilitar fzf-like fuzzy matching
        override_generic_sorter = true, -- Reemplazar el sorter genérico por fzf
        override_file_sorter = true,    -- Reemplazar el sorter de archivos por fzf
        case_mode = "smart_case",       -- Modo de sensibilidad a mayúsculas/minúsculas
      },
      media_files = {
        -- filetypes = { "png", "webp", "jpg", "jpeg" }, -- Descomenta para limitar los tipos de archivo
        -- five_below = true, -- Muestra archivos si hay menos de 5 en el directorio
      },
    },
  })

  -- Cargar extensiones si existen
  pcall(telescope.load_extension, "fzf")
  pcall(telescope.load_extension, "media_files")

  -- Mapeos de Telescope
  local builtin = require("telescope.builtin")
  vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Buscar Archivos" })
  vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Buscar por Texto (Grep)" })
  vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buscar Buffers Abiertos" })
  vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Buscar Ayuda (Help Tags)" })
  vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Buscar Archivos Recientes" })
  vim.keymap.set("n", "<leader>fc", builtin.commands, { desc = "Buscar Comandos" })
  vim.keymap.set("n", "<leader>fz", builtin.current_buffer_fuzzy_find, { desc = "Buscar en Buffer Actual" })

  --print("Telescope cargado")
end

return M
