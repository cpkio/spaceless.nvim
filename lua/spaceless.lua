local api = vim.api
-- local utf8 = require'lua-utf8'

local from = 0
local till = 0

-- local function atTipOfUndo()
--   local tree = vim.fn.undotree()
--   return tree.seq_last == tree.seq_cur
-- end

local function stripWhitespace(buffer, top, bottom)
  local sourced_text = api.nvim_buf_get_lines(buffer, top, bottom, true)
  local replaced_text = {}
  for _, line in ipairs(sourced_text) do
    local l, _ = string.gsub(line, '%s+$', '')
    -- local l = vim.fn.trim( line, " \t", 2 )
    table.insert(replaced_text, l)
  end
  api.nvim_buf_set_lines(buffer, top, bottom, true, replaced_text)
end

local function onBufLeave()
end

local function onBufEnter()
  api.nvim_buf_attach(api.nvim_get_current_buf(), false, {
    on_lines = function(...)
      local event = { ... }
      from = math.min(from, event[4])
      till = math.max(till, event[5])
    end,
    on_detach = function()
      vim.notify_once("Detached")
    end
  })
end

local function onInsEnter()
  local current = api.nvim_win_get_cursor(0)[1]
  from = current - 1
  till = current
end

local function onInsLeave()
  stripWhitespace(0, from, till)
end

local M = {}

function M.setup()
  local group = api.nvim_create_augroup('spaceless', { clear = true })

  local pattern = {
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
