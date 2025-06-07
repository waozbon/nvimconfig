local M = {}

M.setup = function()
  local cmp_status_ok, cmp = pcall(require, "cmp")
  if not cmp_status_ok then
    vim.notify("Plugin 'nvim-cmp' no encontrado", vim.log.levels.WARN)
    return
  end

  local snip_status_ok, luasnip = pcall(require, "luasnip")
  if not snip_status_ok then
    vim.notify("Plugin 'LuaSnip' no encontrado", vim.log.levels.WARN)
    return
  end

  -- Cargar snippets amigables (opcional, pero recomendado)
  require("luasnip.loaders.from_vscode").lazy_load()
  -- Puedes cargar snippets específicos también:
  -- require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets" })

  local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  end

  cmp.setup({
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),           -- Scroll hacia arriba en la documentación
      ["<C-f>"] = cmp.mapping.scroll_docs(4),            -- Scroll hacia abajo en la documentación
      ["<C-Space>"] = cmp.mapping.complete(),            -- Mostrar completaciones
      ["<C-e>"] = cmp.mapping.abort(),                   -- Cerrar completaciones
      ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Aceptar la selección actual.
      -- Comportamiento de Tab y Shift-Tab
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        elseif has_words_before() then
          cmp.complete()  -- Autocompleta si hay texto antes
        else
          fallback()      -- Comportamiento por defecto de Tab
        end
      end, { "i", "s" }), -- i: insert mode, s: select mode (snippets)

      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback() -- Comportamiento por defecto de Shift-Tab
        end
      end, { "i", "s" }),
    }),
    -- Fuentes de completado
    sources = cmp.config.sources({
      { name = "nvim_lsp" }, -- LSP
      { name = "luasnip" },  -- Snippets
      { name = "nvim_lua" }, -- API de Lua de Neovim
      { name = "buffer" },   -- Palabras del buffer actual
      { name = "path" },     -- Rutas del sistema de archivos
    }),
    -- Configuración de la ventana de completado (opcional)
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    formatting = {
      fields = { "kind", "abbr", "menu" },
      format = function(entry, vim_item)
        -- Iconos para diferentes tipos de completado (requiere una Nerd Font)
        vim_item.kind = string.format("%s %s", require("lspkind").presets.default[vim_item.kind] or "", vim_item.kind)
        -- vim_item.kind = require("lspkind").cmp_format({ mode = "symbol_text", maxwidth = 50 })(entry, vim_item)
        vim_item.menu = ({
          nvim_lsp = "[LSP]",
          luasnip = "[Snip]",
          buffer = "[Buff]",
          path = "[Path]",
          nvim_lua = "[Lua]",
        })[entry.source.name]
        return vim_item
      end,
    },
    experimental = {
      ghost_text = true, -- Muestra texto fantasma de la completación seleccionada (experimental)
    },
  })

  -- Configuración para la línea de comandos
  cmp.setup.cmdline("/", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = "buffer" },
    },
  })

  cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = "path" },
    }, {
      { name = "cmdline" },
    }),
  })

  -- Para que lspkind funcione, necesita este plugin si no lo tienes en `plugins.lua`
  -- Normalmente se define como dependencia de nvim-cmp o lspconfig
  local lspkind_status_ok, lspkind = pcall(require, "lspkind")
  if not lspkind_status_ok then
    vim.notify("Plugin 'lspkind' para iconos de nvim-cmp no encontrado", vim.log.levels.WARN)
  else
    -- Ya está siendo usado en la función de `formatting`
    -- lspkind.init({}) -- No es necesario si solo usas presets
  end

  print("nvim-cmp cargado")
end

return M
