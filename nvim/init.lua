-----------------------

-- Set leader key.

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Disable netrw, Neovim thinks it is already loaded.
vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

-----------------------

require('marrio/keymaps')
require('marrio/options')

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")
