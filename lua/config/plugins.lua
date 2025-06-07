return {
	-- ========== Gestor de Plugins ==========
	"folke/lazy.nvim", -- Ya lo configuramos en init.lua, pero lo listamos
	{
		"onsails/lspkind.nvim", -- Iconos para nvim-cmp
		lazy = true, -- Carga cuando sea necesario por nvim-cmp
	},
	-- ========== UI y Apariencia ==========
	{
		"folke/tokyonight.nvim",
		lazy = false,      -- Cargar al inicio
		priority = 1000,   -- Asegurar que se cargue antes que otros
		config = function()
			require("config.theme").setup() -- Llama a la configuración del tema
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					theme = "tokyonight",
					-- component_separators = { left = '', right = ''},
					-- section_separators = { left = '', right = ''},
					component_separators = "", -- Sin separadores para un look más limpio
					section_separators = "",
					disabled_filetypes = { "NvimTree", "alpha" },
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { { "filename", path = 1 } }, -- Path relativo
					lualine_x = { "encoding", "fileformat", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			})
		end,
	},
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" }, -- Opcional, para iconos bonitos
		config = function()
			require("nvim-tree").setup({
				sort_by = "case_sensitive",
				view = {
					width = 30,
					-- adapt_ арифметическое_среднее = true, -- ajusta el tamaño automáticamente
				},
				renderer = {
					group_empty = true,
					highlight_git = true,
					icons = {
						show = {
							file = true,
							folder = true,
							folder_arrow = true,
							git = true,
						},
						glyphs = {
							default = "",
							symlink = "",
							folder = {
								arrow_closed = "",
								arrow_open = "",
								default = "",
								open = "",
								empty = "",
								empty_open = "",
								symlink = "",
								symlink_open = "",
							},
							git = {
								unstaged = "✗",
								staged = "✓",
								unmerged = "",
								renamed = "➜",
								untracked = "★",
								deleted = "",
								ignored = "◌",
							},
						},
					},
				},
				filters = {
					dotfiles = false, -- Mostrar archivos ocultos
					custom = { ".git", "node_modules", ".cache" },
				},
				git = {
					enable = true,
					ignore = false,
				},
				update_focused_file = {
					enable = true,
					update_root = false, -- No cambiar el directorio raíz al cambiar de archivo
				},
				actions = {
					open_file = {
						quit_on_open = true, -- Cerrar nvim-tree al abrir un archivo
					},
				},
			})
			-- Mapeo para NvimTree
			vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Alternar NvimTree" })
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {
			-- char = "▏", -- Carácter para la línea de indentación
			-- show_trailing_blankline_indent = false,
			-- show_current_context = true,
			-- show_current_context_start = true,
		},
		config = function(_, opts)
			require("ibl").setup(opts)
		end
	},
	{
		"goolord/alpha-nvim", -- Dashboard
		config = function()
			local alpha = require("alpha")
			local dashboard = require("alpha.themes.dashboard")

			dashboard.section.header.val = {
				[[                                                 ]],
				[[                                                 ]],
				[[                                                 ]],
				[[                  ███╗   ██╗ ██╗   ██╗██╗███╗   ███╗ ]],
				[[                  ████╗  ██║ ██║   ██║██║████╗ ████║ ]],
				[[                  ██╔██╗ ██║ ██║   ██║██║██╔████╔██║ ]],
				[[                  ██║╚██╗██║ ██║   ██║██║██║╚██╔╝██║ ]],
				[[                  ██║ ╚████║ ╚██████╔╝██║██║ ╚═╝ ██║ ]],
				[[                  ╚═╝  ╚═══╝  ╚═════╝ ╚═╝╚═╝     ╚═╝ ]],
				[[                                                 ]],
			}
			dashboard.section.buttons.val = {
				dashboard.button("f", "󰈞  Buscar Archivos", ":Telescope find_files <CR>"),
				dashboard.button("n", "  Nuevo Archivo", ":enew <CR>"),
				dashboard.button("r", "  Recientes", ":Telescope oldfiles <CR>"),
				dashboard.button("g", "  Buscar Texto", ":Telescope live_grep <CR>"),
				dashboard.button("c", "  Configuración", ":e $MYVIMRC <CR>"),
				dashboard.button("q", "  Salir", ":qa<CR>"),
			}
			dashboard.section.footer.val = "Neovim " ..
			    vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch
			dashboard.config.layout[1].val = 8 -- Aumentar espacio para el header

			alpha.setup(dashboard.opts)

			-- Deshabilitar alpha si se abre un archivo directamente
			vim.api.nvim_create_autocmd("User", {
				pattern = "LazyVimStarted",
				callback = function()
					local stats = require("lazy").stats()
					local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
					dashboard.section.footer.val = "⚡ Neovim cargado en " .. ms .. "ms"
					pcall(function() require("alpha").redraw() end)
				end,
			})
		end
	},
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("bufferline").setup({
				options = {
					mode = "buffers", -- "tabs" si prefieres
					numbers = "ordinal", -- "buffer_id", "both"
					diagnostics = "nvim_lsp",
					diagnostics_indicator = function(count, level, diagnostics_dict, context)
						local s = " "
						for e, n in pairs(diagnostics_dict) do
							local sym = e == "error" and "" or
							    (e == "warning" and "" or "")
							s = s .. n .. sym .. " "
						end
						return s
					end,
					offsets = {
						{
							filetype = "NvimTree",
							text = "Explorador",
							highlight = "Directory",
							text_align = "left",
						},
					},
					separator_style = "thin", -- "slant", "padded_slant", "thick"
					always_show_bufferline = true,
					-- No mostrar iconos para cerrar tan grandes
					indicator = { style = 'none' },
					buffer_close_icon = '',
					modified_icon = '●',
				}
			})
			-- Mapeos para bufferline
			vim.keymap.set('n', '<S-l>', ':BufferLineCycleNext<CR>',
				{ desc = "Siguiente buffer (BufferLine)" })
			vim.keymap.set('n', '<S-h>', ':BufferLineCyclePrev<CR>',
				{ desc = "Buffer anterior (BufferLine)" })
			vim.keymap.set('n', '<leader>bc', ':BufferLinePickClose<CR>', { desc = "Cerrar buffer (Picker)" })
		end
	},

	-- ========== Utilidades ==========
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup({})
			-- Para compatibilidad con nvim-cmp si lo usas
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		config = function()
			require("which-key").setup({
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			})
		end
	},

	-- ========== GIT ==========
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "▎" },
					change = { text = "▎" },
					delete = { text = "" },
					topdelete = { text = "" },
					changedelete = { text = "▎" },
					untracked = { text = "▎" },
				},
				signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
				numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
				linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
				word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns
					local function map(mode, l, r, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
					end

					-- Navigation
					map("n", "]c", function()
						if vim.wo.diff then return "]c" end
						vim.schedule(function() gs.next_hunk() end)
						return "<Ignore>"
					end, { expr = true, desc = "Siguiente Hunk (Git)" })

					map("n", "[c", function()
						if vim.wo.diff then return "[c" end
						vim.schedule(function() gs.prev_hunk() end)
						return "<Ignore>"
					end, { expr = true, desc = "Anterior Hunk (Git)" })

					-- Actions
					map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage Hunk (Git)" })
					map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset Hunk (Git)" })
					map("v", "<leader>hs",
						function() gs.stage_hunk { vim.fn.line("."), vim.fn.line("v") } end,
						{ desc = "Stage Hunk (Visual Git)" })
					map("v", "<leader>hr",
						function() gs.reset_hunk { vim.fn.line("."), vim.fn.line("v") } end,
						{ desc = "Reset Hunk (Visual Git)" })
					map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage Buffer (Git)" })
					map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Undo Stage Hunk (Git)" })
					map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset Buffer (Git)" })
					map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview Hunk (Git)" })
					map("n", "<leader>hb", function() gs.blame_line { full = true } end,
						{ desc = "Blame Line (Git)" })
					map("n", "<leader>tb", gs.toggle_current_line_blame,
						{ desc = "Toggle Blame Line (Git)" })
					map("n", "<leader>hd", gs.diffthis, { desc = "Diff This (Git)" })
					map("n", "<leader>hD", function() gs.diffthis("~") end,
						{ desc = "Diff This ~ (Git)" })
					map("n", "<leader>td", gs.toggle_deleted, { desc = "Toggle Deleted (Git)" })
				end,
			})
		end,
	},

	-- ========== Fuzzy Finder (Telescope) ==========
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.6", -- O la última versión estable
		dependencies = {
			"nvim-lua/plenary.nvim",
			-- Opcional para mejor rendimiento en búsqueda de archivos
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			-- Para previsualizar archivos md, etc.
			"nvim-telescope/telescope-media-files.nvim",
		},
		config = function()
			require("config.telescope").setup() -- Llama a la configuración de telescope
		end,
	},

	-- ========== Treesitter (Mejor resaltado de sintaxis, etc.) ==========
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("config.treesitter").setup() -- Llama a la configuración de treesitter
		end,
	},

	-- ========== LSP (Language Server Protocol) ==========
	{
		"neovim/nvim-lspconfig",        -- Colección de configuraciones de LSP
		dependencies = {
			"williamboman/mason.nvim", -- Gestor de LSPs, Linters, Formatters
			"williamboman/mason-lspconfig.nvim", -- Puente entre mason y lspconfig
			"WhoIsSethDaniel/mason-tool-installer.nvim", -- Para instalar tools automáticamente
			-- Autocompletado (ver sección nvim-cmp)
			"hrsh7th/cmp-nvim-lsp",
			-- Opcional: UI para LSP
			{ "folke/neodev.nvim", opts = {} }, -- Para desarrollo de plugins Lua
			{ "j-hui/fidget.nvim", tag = "legacy", opts = {} }, -- Notificaciones de progreso LSP
		},
		--config = function()
		--require("config.lsp").setup() -- Llama a la configuración de LSP
		--end,
	},

	-- ========== Autocompletado (nvim-cmp) ==========
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-buffer", -- Fuente para palabras del buffer actual
			"hrsh7th/cmp-path", -- Fuente para rutas de sistema
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-cmdline", -- Fuente para línea de comandos de vim
			"hrsh7th/cmp-git",
			"L3MON4D3/LuaSnip", -- Motor de Snippets
			"saadparwaiz1/cmp_luasnip", -- Fuente de Luasnip para nvim-cmp
			"windwp/nvim-autopairs",
			"rafamadriz/friendly-snippets", -- Colección de snippets
			"hrsh7th/cmp-nvim-lua", -- Fuente para API de Lua de Neovim

			-- "hrsh7th/cmp-nvim-lsp-signature-help", -- Ayuda de signatura (opcional)
		},
		config = function()
			require("config.cmp").setup() -- Llama a la configuración de nvim-cmp
		end,
	},
}
