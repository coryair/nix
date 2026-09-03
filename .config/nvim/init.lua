-- A small, learnable Neovim setup.
-- Start with :Tutor, then read this file as you customize it.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Make the editor comfortable in a terminal pane.
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.scrolloff = 8
vim.opt.wrap = false
vim.opt.undofile = true
vim.opt.clipboard = "unnamedplus"

-- nvim-tree replaces the older built-in directory browser.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local function github(repo)
  return "https://github.com/" .. repo
end

-- Neovim installs these on first launch and keeps them under stdpath('data').
vim.pack.add {
  github("folke/tokyonight.nvim"),
  github("nvim-tree/nvim-web-devicons"),
  github("nvim-tree/nvim-tree.lua"),
  github("nvim-lua/plenary.nvim"),
  github("nvim-telescope/telescope.nvim"),
  github("lewis6991/gitsigns.nvim"),
  github("nvim-lualine/lualine.nvim"),
  github("folke/which-key.nvim"),
}

vim.cmd.colorscheme("tokyonight-night")

require("nvim-tree").setup {
  view = { width = 32 },
  renderer = { group_empty = true },
  filters = { dotfiles = false },
  hijack_directories = { enable = true, auto_open = true },
  update_focused_file = { enable = true, update_root = false },
  on_attach = function(bufnr)
    local api = require("nvim-tree.api")
    api.map.on_attach.default(bufnr)

    -- The default mapping assumes every cursor position has a node.
    -- During a refresh, a blank row can briefly have no corresponding node.
    vim.keymap.set("n", "<CR>", function()
      local node = api.tree.get_node_under_cursor()
      if node then
        api.node.open.edit(node)
      end
    end, { buffer = bufnr, noremap = true, silent = true, nowait = true, desc = "nvim-tree: Open" })
  end,
}

require("gitsigns").setup()

require("lualine").setup {
  options = {
    theme = "tokyonight",
    icons_enabled = false,
    section_separators = "",
    component_separators = "",
  },
}

require("which-key").setup()

require("telescope").setup {
  defaults = {
    layout_strategy = "flex",
    sorting_strategy = "ascending",
    layout_config = {
      prompt_position = "top",
      width = 0.9,
      height = 0.85,
    },
  },
}

local telescope = require("telescope.builtin")

-- The leader key is Space. Press Space and pause to see available commands.
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file tree" })
vim.keymap.set("n", "<leader>o", "<cmd>NvimTreeFocus<cr>", { desc = "Focus file tree" })
vim.keymap.set("n", "<leader>ff", function()
  telescope.find_files { hidden = true }
end, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", function()
  telescope.live_grep {
    additional_args = function()
      return { "--hidden", "--glob", "!.git/*" }
    end,
  }
end, { desc = "Search file contents" })
vim.keymap.set("n", "<leader>fb", telescope.buffers, { desc = "Find open buffers" })
vim.keymap.set("n", "<leader>fh", telescope.help_tags, { desc = "Search Neovim help" })
vim.keymap.set("n", "<leader>u", function()
  vim.pack.update()
end, { desc = "Update plugins" })

-- Move between Neovim windows without leaving the home row.
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move to right window" })
