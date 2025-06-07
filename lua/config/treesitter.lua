local M = {}

M.setup = function()
  local status_ok, treesitter_configs = pcall(require, "nvim-treesitter.configs")
  if not status_ok then
    vim.notify("Plugin 'nvim-treesitter' no encontrado", vim.log.levels.WARN)
    return
  end

  treesitter_configs.setup({
    ensure_installed = {
      "bash",
      "c",
      "cpp",
      "css",
      "dockerfile",
      "go",
      "html",
      "javascript",
      "json",
      "lua",
      "luadoc",
      "luap",
      "markdown",
      "markdown_inline",
      "python",
      "query",
      "regex",
      "rust",
      "scss",
      "toml",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
      "yaml",
      -- Agrega más lenguajes según necesites
    },
    sync_install = false, -- Instalar parsers asíncronamente
    auto_install = true, -- Instalar automáticamente parsers faltantes

    highlight = {
      enable = true, -- Habilitar resaltado de sintaxis basado en Treesitter
      -- disable = { "c", "rust" },  -- Lista de lenguajes a deshabilitar (si prefieres el resaltado por defecto)
      additional_vim_regex_highlighting = false,
    },
    indent = {
      enable = true, -- Habilitar indentación basada en Treesitter
      -- disable = { "python" },
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<CR>", -- Iniciar selección incremental
        node_incremental = "<CR>", -- Incrementar selección al siguiente nodo
        scope_incremental = "<S-CR>", -- Incrementar selección al nodo de ámbito
        node_decremental = "<BS>", -- Decrementar selección
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Ver hacia adelante para mejor selección de objetos de texto
        keymaps = {
          -- Puedes usar la opción `additional_vim_regex_highlighting = true` para obtener estos objetos de texto
          ["aa"] = "@parameter.outer",
          ["ia"] = "@parameter.inner",
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- saltar al siguiente/anterior objeto de texto también guarda un salto en la jumplist
        goto_next_start = {
          ["]m"] = "@function.outer",
          ["]]"] = "@class.outer",
        },
        goto_next_end = {
          ["]M"] = "@function.outer",
          ["]["] = "@class.outer",
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[["] = "@class.outer",
        },
        goto_previous_end = {
          ["[M"] = "@function.outer",
          ["[]"] = "@class.outer",
        },
      },
    },
    -- Opcional: Autotag para HTML/XML
    autotag = {
        enable = true,
    },
    -- Opcional: Rainbow parentheses
    -- rainbow = {
    --   enable = true,
    --   extended_mode = true, -- También para pares de paréntesis no estándar
    --   max_file_lines = nil, -- Deshabilitar para archivos muy grandes si causa lentitud
    -- }
  })

  print("Treesitter cargado")
end

return M
