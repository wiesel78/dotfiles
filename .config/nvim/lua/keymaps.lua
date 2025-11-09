local keymap = vim.keymap

-- search
-- keymap.set('n', '<leader>sf', '')

-- window splits
keymap.set('n', '<leader>wl', '<C-w>v', { desc = 'Split vertically' })
keymap.set('n', '<leader>wj', '<C-w>s', { desc = 'Split horizontally' })
keymap.set('n', '<leader>we', '<C-w>=', { desc = 'Equal splits' })
keymap.set('n', '<leader>wq', ':close<CR>', { desc = 'Close window' })

-- buffer and tabs
keymap.set('n', '<C-j>', ':bnext<CR>', { desc = 'Next buffer' })
keymap.set('n', '<C-k>', ':bprevious<CR>', { desc = 'Previous buffer' })
keymap.set('n', '<C-l>', ':tabNext<CR>', { desc = 'Next tan' })
keymap.set('n', '<C-h>', ':tabprevious<CR>', { desc = 'Previoud tab' })
keymap.set('n', '<leader>tn', ':tabnew<CR>', { desc = 'New tab' })

keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
keymap.set('n', '<A-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
keymap.set('n', '<A-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
keymap.set('n', '<A-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
keymap.set('n', '<A-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- clipboard copy with CTRL-c
keymap.set('n', '<C-c>', '"+', { desc = 'set register + prefix so you can copy with motion and y' })
keymap.set('n', '<C-S-c>', '"+', { desc = 'set register + prefix so you can copy with motion and y' })
keymap.set('v', '<C-c>', '"+y', { desc = 'Copy current selection into the system clipboard' })
keymap.set('v', '<C-S-c>', '"+y', { desc = 'Copy current selection into the system clipboard' })
keymap.set('v', '<C-S-v>', '"+p', { desc = 'replace current selection with clipboard content' })

-- comment
local api =  require('Comment.api')
local esc = vim.api.nvim_replace_termcodes(
  '<ESC>', true, false, true
)
keymap.set('n', '<leader>ec', function () api.toggle.linewise() end, { desc = 'Toggle comment' })
keymap.set('x', '<leader>ec', function()
  vim.api.nvim_feedkeys(esc, 'nx', false)
  api.toggle.linewise(vim.fn.visualmode())
end, { desc = 'Toggle comment'})

-- panels
keymap.set('n', '<leader>pt', '<cmd>split | terminal<CR>', { desc = 'Terminal' })

-- reload config
local function reload_config()
  for key in pairs(package.loaded) do
    if key:match('^user.') then
      package.loaded[key] = nil
    end
  end

  dofile(vim.fn.stdpath('config') .. '/init.lua')
  vim.notify('neovim config reloaded!', vim.log.levels.info)
end

keymap.set('n', '<leader>rc', reload_config, { desc = 'Reload Nvim config' })
keymap.set('x', '<leader>rc', reload_config, { desc = 'Reload Nvim config' })
