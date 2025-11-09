-- lua/ollama_ghost/init.lua
local M = {}

local ns = vim.api.nvim_create_namespace("ollama_ghost")
local extmark = nil
local active_job = nil
local idle_timer = vim.loop.new_timer()
local accepting = false

-- user config
local cfg = {
  model = "qwen2.5-coder:7b",       -- pick any local code model
  debounce_ms = 220,                 -- idle wait before asking
  max_tokens = 64,                   -- keep it short for inline ghosting
  temperature = 0.1,                 -- less drift
  stop = { "\n\n", "\r\n\r\n", "\n}", "\n;" }, -- conservative stops
  fim = "qwen",                      -- "qwen" | "codellama" | "mistral" | "generic"
  cooldown_ms = 100,
}

local function clear_ghost(buf)
  if extmark then
    pcall(vim.api.nvim_buf_del_extmark, buf, ns, extmark)
    extmark = nil
  end
end

local function show_ghost(buf, row, col, text)
  clear_ghost(buf)
  -- Render inline ghost text after the cursor
  extmark = vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
    virt_text = {{ text, "Comment" }},             -- use a faint hl group
    virt_text_win_col = col,                        -- place at cursor column
    hl_mode = "combine",
  })
end

local function build_fim_prompt(prefix, suffix)
  if cfg.fim == "codellama" then
    -- CodeLlama FIM tokens
    return ("<PRE> %s <SUF>%s <MID>"):format(prefix, suffix)
  elseif cfg.fim == "qwen" then
    -- Qwen2.5-Coder FIM tokens
    return ("<|fim_prefix|>%s<|fim_suffix|>%s<|fim_middle|>"):format(prefix, suffix)
  elseif cfg.fim == "gemma" then
    -- mistral FIM tokens
    return ("<|fim_prefix|>%s<|fim_suffix|>%s<|fim_middle|>"):format(prefix, suffix)
  elseif cfg.fim == "mistral" then
    -- Codestral style (identical to Codellama in many builds)
    return ("[PREFIX]%s[SUFFIX]%s[MIDDLE]"):format(prefix, suffix)
  else
    -- Generic "continue" fallback (prefix only)
    return prefix
  end
end

local function collect_context()
  local buf = vim.api.nvim_get_current_buf()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  -- Limit context to keep requests light
  local before = table.concat(vim.list_slice(lines, math.max(1, row - 120), row), "\n")
  local after  = table.concat(vim.list_slice(lines, row + 1, math.min(#lines, row + 80)), "\n")

  local prefix = before .. "\n" .. (lines[row+1] or ""):sub(1, col)
  local suffix = (lines[row+1] or ""):sub(col+1) .. "\n" .. after

  local ft = vim.bo[buf].filetype
  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")

  return {
    buf = buf, row = row, col = col,
    prefix = prefix, suffix = suffix,
    ft = ft, path = path,
  }
end

local function cancel_job()
  if active_job then
    pcall(vim.fn.jobstop, active_job)
    active_job = nil
  end
end

local function request_completion()
  cancel_job()
  local ctx = collect_context()
  clear_ghost(ctx.buf)

  -- Prompt
  local prompt = build_fim_prompt(ctx.prefix, ctx.suffix)

  -- Build Ollama JSON payload (streaming)
  local payload = vim.fn.json_encode({
    model = cfg.model,
    prompt = prompt,
    stream = true,
    options = {
      temperature = cfg.temperature,
      num_predict = cfg.max_tokens,
      stop = cfg.stop,
    }
  })

  -- Use curl to stream JSON lines from Ollama
  local cmd = {
    "curl", "-sN", "-X", "POST", "http://127.0.0.1:11434/api/generate",
    "-H", "Content-Type: application/json",
    "-d", payload
  }

  local acc = ""
  active_job = vim.fn.jobstart(cmd, {
    stdout_buffered = false,
    on_stdout = function(_, data, _)
      for _, line in ipairs(data or {}) do
        if line ~= "" then
          local ok, obj = pcall(vim.fn.json_decode, line)
          if ok and obj and obj.response then
            acc = acc .. obj.response

            -- Show only what fits on this line (until newline)
            local first_line = acc:match("^[^\r\n]*") or ""

            -- delete the sometimes occouring <EOT> suffix
            first_line = first_line:gsub("<EOT>%s*$", "")

            show_ghost(ctx.buf, ctx.row, ctx.col, first_line)
          end
          if ok and obj and obj.done then
            active_job = nil
          end
        end
      end
    end,
    on_exit = function()
      active_job = nil
    end
  })
end

local function schedule()
  if accepting then return end
  idle_timer:stop()
  idle_timer:start(cfg.debounce_ms, 0, vim.schedule_wrap(function()
    -- only when in Insert mode and buffer is modifiable
    if vim.api.nvim_get_mode().mode:match("^i") and vim.bo.modifiable then
      request_completion()
    end
  end))
end

function M.setup(user_cfg)
  cfg = vim.tbl_deep_extend("force", cfg, user_cfg or {})

  -- Clear on type; reschedule
  vim.api.nvim_create_autocmd({ "TextChangedI", "InsertCharPre" }, {
    callback = function()
      clear_ghost(0)
      cancel_job()
      schedule()
    end,
  })

  vim.api.nvim_create_autocmd({"CursorMovedI"}, {
    callback = function () if clear_ghost then pcall(clear_ghost, 0) end end,
  })

  -- Also allow manual trigger
  vim.api.nvim_create_user_command("OllamaGhost", request_completion, {})

  -- Accept keys
  vim.keymap.set("i", "<Tab>", function()
    -- If popup menu is visible, keep normal Tab behavior
    if vim.fn.pumvisible() == 1 then
      return "\t"
    end

    local ns = vim.api.nvim_create_namespace("ollama_ghost") -- use your ns
    local buf = vim.api.nvim_get_current_buf()
    local marks = vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, { details = true })
    if #marks == 0 then
      return "\t" -- no ghost text; insert a real tab
    end

    -- Extract the ghost text from the extmark
    local details = marks[1][4] or {}
    local vt = details.virt_text
    local ghost = (vt and vt[1] and vt[1][1]) and vt[1][1] or nil
    if not ghost or ghost == "" then
      return "\t"
    end

    -- Defer the buffer modification to avoid E565
    vim.schedule(function()
      -- cancel any in-flight request and clear the ghost
      if cancel_job then pcall(cancel_job) end
      if clear_ghost then pcall(clear_ghost, buf) end

      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      row = row - 1
      -- Insert ghost text at cursor
      local lines = {}
      for s in (ghost .. "\n"):gmatch("(.-)\n") do table.insert(lines, s) end
      if #lines == 1 then
        vim.api.nvim_buf_set_text(buf, row, col, row, col, {ghost})
        local new_col = col + vim.str_utfindex(ghost)
        vim.api.nvim_win_set_cursor(0, { row + 1, new_col })
      else
        vim.api.nvim_buf_set_text(buf, row, col, row, col, lines)
        local last = lines[#lines]
        local new_row = row + (#lines - 1)
        local new_col = vim.str_utfindex(last)
        vim.api.nvim_win_set_cursor(0, { new_row + 1, new_col})
      end

      -- Optional: join with previous undo step so “accept” is a single undo
      pcall(vim.cmd, "undojoin")

      accepting = true
      vim.defer_fn(function() accepting = false end, cfg.cooldown_ms)
    end)

    return "" -- we've handled the key
  end, { expr = true, silent = true })

  -- Cancel on leave
  vim.api.nvim_create_autocmd({ "InsertLeave", "BufLeave" }, {
    callback = function()
      clear_ghost(0)
      cancel_job()
    end,
  })
end

return M
