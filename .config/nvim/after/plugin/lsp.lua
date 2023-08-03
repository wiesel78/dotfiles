local lsp = require('lsp-zero').preset({})

-- lsp.preset("recommended")
--
--lsp.ensure_installed({
--    'tsserver',
--    'eslint',
--    'sumneko_lua',
--    'rust_analyzer',
--})
--
--local com = require('cmp')
--local cpm_select = {behavior = cmp.SelectBehavior.Select}
--local cmp_mappings = lsp.defaults.cmp_mappings({
--    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
--    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
--    ['<C-y>'] = cmp.mapping.confirm({select = true}),
--    ['<C-Space>'] = cmp.mapping.complete(),
--})

lsp.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp.default_keymaps({buffer = bufnr})
end)

-- (Optional) Configure lua language server for neovim
require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

lsp.setup()
