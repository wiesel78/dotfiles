return {
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Automatically install LSPs to stdpath for neovim
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',

    -- Useful status updates for LSP
    { 'j-hui/fidget.nvim', opts = {} },

    -- Autocompletion
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
  },
  config = function()
    local cmp = require('cmp')
    local cmp_lsp = require('cmp_nvim_lsp')

    -- Setup nvim-cmp.
    cmp.setup({
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'buffer' },
        { name = 'path' },
      }),
      mapping = cmp.mapping.preset.insert({
        ['<C-k>'] = cmp.mapping.select_prev_item(),
        ['<C-j>'] = cmp.mapping.select_next_item(),
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
      }),
      -- Use buffer and nvim-lsp as sources
      capability = cmp_lsp.default_capabilities(),
    })

    -- Setup mason so it can manage language servers
    require('mason').setup()
    require('mason-lspconfig').setup({
      -- A list of servers to automatically install if they're not already installed
      ensure_installed = { 'lua_ls', 'bashls', 'jsonls', 'gopls'},
    })

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('UserLspKeymaps', { clear = true }),
      callback = function(args)
        local bufnr = args.buf
        local keymap = vim.keymap

        local function opts(desc)
          return { noremap = true, silent = true, buffer = bufnr, desc = desc }
        end

        -- Keymaps for LSP actions
        keymap.set('n', '<leader>gD', vim.lsp.buf.declaration, opts("(D)eclaration"))
        keymap.set('n', '<leader>gd', vim.lsp.buf.definition, opts("(d)efinition"))
        keymap.set('n', '<leader>gi', vim.lsp.buf.implementation, opts("(i)mplementation"))
        keymap.set('n', '<leader>gk', vim.lsp.buf.hover, opts("(h)over"))
        keymap.set('n', '<leader>gh', vim.lsp.buf.signature_help, opts("signature (h)elp"))
        keymap.set('n', '<leader>ga', vim.lsp.buf.code_action, opts("code (a)ctions"))
        keymap.set('n', '<leader>gr', vim.lsp.buf.references, opts("(r)eferences"))
        keymap.set('n', 'gD', vim.lsp.buf.declaration, opts("(D)eclaration"))
        keymap.set('n', 'gd', vim.lsp.buf.definition, opts("(d)efinition"))
        keymap.set('n', 'gi', vim.lsp.buf.implementation, opts("(i)mplementation"))
        keymap.set('n', 'gr', vim.lsp.buf.references, opts("(r)eferences"))

        keymap.set('n', '<leader>sr', vim.lsp.buf.references, opts("(r)eferences"))

        keymap.set('n', '<leader>er', vim.lsp.buf.rename, opts("(r)ename"))
        keymap.set('n', '<leader>ef', vim.lsp.buf.format, opts("(f)ormat"))
      end,
    })

  end,
}
