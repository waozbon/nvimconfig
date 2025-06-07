local M = {}

M.setup = function()
  local lsp_status_ok, lspconfig = pcall(require, "lspconfig")
  if not lsp_status_ok then
    vim.notify("Plugin 'nvim-lspconfig' no encontrado", vim.log.levels.WARN)
    return
  end

  local mason_status_ok, mason = pcall(require, "mason")
  if not mason_status_ok then
    vim.notify("Plugin 'mason.nvim' no encontrado", vim.log.levels.WARN)
    return
  end

  local mason_lspconfig_status_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
  if not mason_lspconfig_status_ok then
    vim.notify("Plugin 'mason-lspconfig.nvim' no encontrado", vim.log.levels.WARN)
    return
  end

  local mason_tool_installer_status_ok, mason_tool_installer = pcall(require, "mason-tool-installer")
  if not mason_tool_installer_status_ok then
    vim.notify("Plugin 'mason-tool-installer.nvim' no encontrado", vim.log.levels.WARN)
    return
  end

  local cmp_nvim_lsp_status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if not cmp_nvim_lsp_status_ok then
    vim.notify("Fuente 'cmp_nvim_lsp' para nvim-cmp no encontrada", vim.log.levels.WARN)
    return
  end

  -- ========= Configuración de Mason ==========
  mason.setup({
    ui = {
      border = "rounded",
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗",
      },
    },
  })

  mason_lspconfig.setup({
    -- Lista de servidores LSP a instalar automáticamente y configurar.
    -- Asegúrate de que estén disponibles en mason.nvim. :Mason para ver la lista.
    ensure_installed = {
      "lua_ls",
      "pyright",        -- Para Python
      "tsserver",       -- Para TypeScript/JavaScript
      "html",
      "cssls",
      "jsonls",
      "yamlls",
      "bashls",
      "dockerls",
      "gopls",          -- Para Go
      "rust_analyzer",  -- Para Rust
      -- Agrega más según necesites
    },
    -- También puedes especificar aquí manejadores si necesitas una configuración
    -- más granular por servidor antes de que lspconfig lo tome.
  })

  -- Para instalar automáticamente formateadores y linters
  mason_tool_installer.setup({
    ensure_installed = {
      "stylua",       -- Formateador para Lua
      "prettier",     -- Formateador para JS/TS/CSS/JSON/MD etc.
      "eslint_d",     -- Linter para JS/TS
      "black",        -- Formateador para Python
      "isort",        -- Organizador de imports para Python
      "flake8",       -- Linter para Python
      -- Agrega más según necesites
    }
  })


  -- ========= Callbacks y Keymaps de LSP ==========
  local on_attach = function(client, bufnr)
    -- Habilitar completion con <c-x><c-o>
    -- vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    -- Mapeos de LSP. Usa <leader>l como prefijo para LSP.
    -- Ver `:help vim.lsp.*` para documentación de las funciones.
    local nmap = function(keys, func, desc)
      if desc then
        desc = "LSP: " .. desc
      end
      vim.keymap.set("n", keys, func, { buffer = bufnr, noremap = true, silent = true, desc = desc })
    end

    nmap("<leader>lr", vim.lsp.buf.rename, "Renombrar")
    nmap("<leader>la", vim.lsp.buf.code_action, "Acciones de Código")
    nmap("gd", vim.lsp.buf.definition, "Ir a Definición")
    nmap("gD", vim.lsp.buf.declaration, "Ir a Declaración")
    nmap("gr", require("telescope.builtin").lsp_references, "Mostrar Referencias")
    nmap("gi", vim.lsp.buf.implementation, "Ir a Implementación")
    nmap("K", vim.lsp.buf.hover, "Mostrar Documentación (Hover)")
    nmap("<C-k>", vim.lsp.buf.signature_help, "Ayuda de Signatura")
    nmap("<leader>lf", function() vim.lsp.buf.format { async = true } end, "Formatear Buffer")
    nmap("<leader>lj", vim.diagnostic.goto_next, "Siguiente Diagnóstico")
    nmap("<leader>lk", vim.diagnostic.goto_prev, "Diagnóstico Anterior")
    nmap("<leader>le", vim.diagnostic.open_float, "Mostrar Diagnóstico (Flotante)")
    nmap("<leader>lq", vim.diagnostic.setloclist, "Listar Diagnósticos (Location List)")
    nmap("gl", vim.diagnostic.open_float, "Mostrar Diagnóstico (Flotante) - cursor")

    -- Para algunos LSPs que lo soportan, como gopls.
    nmap("<leader>lI", vim.lsp.buf.incoming_calls, "Llamadas Entrantes")
    nmap("<leader>lO", vim.lsp.buf.outgoing_calls, "Llamadas Salientes")

    -- Crear comando para organizar imports si el LSP lo soporta (ej: pyright, tsserver)
    if client.supports_method("textDocument/codeAction") then
      local group = vim.api.nvim_create_augroup("LspFormatting", { clear = true })
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        group = group,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr })
          -- Para algunos LSPs como pyright, la acción de organizar imports es una code action
          -- podrías necesitar lógica más específica aquí o usar un plugin como conform.nvim
        end,
      })
    end

    -- Resaltar símbolo bajo el cursor
    if client.server_capabilities.documentHighlightProvider then
      local highlight_augroup = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = bufnr,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd("CursorMoved", {
        buffer = bufnr,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end

  -- Capacidades del cliente LSP (para nvim-cmp)
  local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
  -- Añadir soporte para snippets si tu LSP lo provee
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  -- ========= Configuración específica de Servidores LSP ==========
  -- Lua (lua_ls / sumneko_lua)
  lspconfig.lua_ls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" }, -- O 'Lua 5.1', etc.
        diagnostics = {
          globals = { "vim", "it", "describe", "before_each", "after_each" }, -- Para tests y config de Neovim
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false, -- Puede ser lento
        },
        telemetry = { enable = false },
      },
    },
  })

  -- Python (pyright)
  lspconfig.pyright.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      python = {
        analysis = {
          -- autoSearchPaths = true,
          -- diagnosticMode = "workspace",
          -- useLibraryCodeForTypes = true,
          -- typeCheckingMode = "off", -- "basic" or "strict"
        },
      },
    },
  })

  -- TypeScript / JavaScript (tsserver)
  lspconfig.tsserver.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    -- init_options = {
    --   preferences = {
    --     importModuleSpecifierPreference = "non-relative",
    --   },
    -- },
  })

  -- HTML
  lspconfig.html.setup({
    on_attach = on_attach,
    capabilities = capabilities,
  })

  -- CSS
  lspconfig.cssls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
  })

  -- JSON
  lspconfig.jsonls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      json = {
        schemas = require('schemastore').json.schemas(), -- Esquemas de JSON da comunidade
        validate = { enable = true },
      },
    },
  })
  require('schemastore').json.setup({
      -- Configuración de schemastore si es necesaria
  })


  -- YAML
  lspconfig.yamlls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      yaml = {
        schemas = require('schemastore').yaml.schemas(),
        -- schemaStore = {
        --   enable = false, -- Evitar que yamlls use su propio schema store si causa conflictos
        --   url = "",
        -- },
        -- validate = true,
        -- hover = true,
        -- completion = true,
        -- format = { enable = true },
      },
    },
  })
  -- Es necesario llamar a setup en schemastore también para yaml
  require('schemastore').yaml.setup({})

  -- Docker
  lspconfig.dockerls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
  })

  -- Bash
  lspconfig.bashls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
  })

  -- Go
  lspconfig.gopls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      gopls = {
        -- analyses = {
        --   unusedparams = true,
        -- },
        -- staticcheck = true,
        -- gofumpt = true, -- Usa gofumpt para formatear
      },
    },
  })

  -- Rust (rust_analyzer)
  lspconfig.rust_analyzer.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      ["rust-analyzer"] = {
        -- Asistencias para autocompletado, etc.
        assist = {
          importGranularity = "module",
          importPrefix = "by_crate",
        },
        cargo = {
          loadOutDirsFromCheck = true,
        },
        procMacro = {
          enable = true,
        },
        checkOnSave = {
          command = "clippy", -- O "check"
        },
      },
    },
  })

  -- Aquí puedes agregar más configuraciones para otros LSPs que instales.
  -- Por ejemplo, para clangd (C/C++):
  -- lspconfig.clangd.setup({
  --   on_attach = on_attach,
  --   capabilities = capabilities,
  -- })

  -- Configuración global de diagnósticos de LSP
  vim.diagnostic.config({
    virtual_text = true, -- Muestra errores inline (puedes poner { prefix = '●' } para un icono)
    signs = true,
    underline = true,
    update_in_insert = false, -- No actualizar diagnósticos mientras escribes (puede ser molesto)
    severity_sort = true,
  })

  -- Configurar formato de diagnósticos (opcional)
  local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
  end

  print("LSP configurado")
end

return M
