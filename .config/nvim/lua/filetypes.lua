vim.filetype.add {
  pattern = {
    -- check all files without an extension and try to attach the right lsp
    ['*'] = {
      function(path, bufnr)

        -- attach bashls if the shebang exists and match
        local content = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ''
        if vim.regex([[^#!.*/bin/.*sh]]):match_str(content) ~= nil then
          return 'sh'
        end

      end,
      { priority = -math.huge },
    },
  },
}
