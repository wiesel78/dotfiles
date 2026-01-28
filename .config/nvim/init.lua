vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true
vim.opt.clipboard = 'unnamedplus'
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 200
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

function Log(...)
  local file = io.open('/tmp/nvim-ollama.log', 'a')
  if not file then return end

  local parts = {}
  for i = 1, select('#', ...) do
    local arg = select(i, ...)
    table.insert(parts, type(arg) == 'string' and arg or vim.inspect(arg))
  end

  file:write(os.date('%Y-%m-%dT%H:%M:%S') .. ' - ' .. table.concat(parts, ' ') .. '\n')
  file:close()
end

require('lazy').setup('plugins', {

})

require('options')
require('keymaps')
require('filetypes')
require('autocmds')
-- require('llm').setup({
--   model = "codellama:7b-code-q4_0",
--   debounce_ms = 200,
--   max_tokens = 64,
--   temperature = 0.1,
--   fim = "codellama",
-- })
