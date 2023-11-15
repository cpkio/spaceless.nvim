local api = vim.api

local from = 0
local till = 0

local function stripWhitespace(buffer, top, bottom)
  vim.cmd(top..','..bottom..[[s/\s*$//]])
end

local function onBufLeave()
end

local function onBufEnter()
  api.nvim_buf_attach(api.nvim_get_current_buf(), false, {
    on_lines = function(...)
      local event = { ... }
      from = math.min(from, event[5])
      till = math.max(till, event[5])
    end,
    on_detach = function()
      vim.notify_once("Detached")
    end
  })
end

local function onInsEnter()
  local current = api.nvim_win_get_cursor(0)[1]
  from = current
  till = current
end

local function onInsLeave()
  stripWhitespace(0, from, till)
end

local M = {}

function M.setup()
  local group = api.nvim_create_augroup('spaceless', { clear = true })

  local pattern = {
    "*.txt",
    "*.adoc",
    "*.md",
    "*.vimwiki"
  }

  api.nvim_create_autocmd('BufEnter', { once = true, pattern = pattern, group = group, callback = onBufEnter })
  api.nvim_create_autocmd('BufLeave', { once = true, pattern = pattern, group = group, callback = onBufLeave })
  api.nvim_create_autocmd('InsertEnter', { pattern = pattern, group = group, callback = onInsEnter })
  api.nvim_create_autocmd('InsertLeavePre', { pattern = pattern, group = group, callback = onInsLeave })

end

return M
