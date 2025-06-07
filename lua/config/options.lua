local opt = vim.opt
local g = vim.g

--Apariencia
opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.title = true

--Tabs
opt.smartindent = true
opt.autoindent = true

-- === Plegado (Folding) ===
opt.foldmethod = "expr" -- Usar treesitter para el plegado
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevelstart = 99 -- No plegar nada al abrir archivos

--Variables globales
g.mapleader = ""           -- Establece la tecla líder a Espacio
g.maplocalleader = "\\"     -- Establece la tecla líder local a Backslash
