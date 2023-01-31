local api = vim.api
local utf8 = require'lua-utf8'

local event = {}

local function atTipOfUndo()
  local tree = vim.fn.undotree()
  return tree.seq_last == tree.seq_cur
end

local function stripWhitespace(buffer, top, bottom)

  if (atTipOfUndo()) then return end

  local sourced_text = api.nvim_buf_get_lines(buffer, top, bottom, false)
  local replaced_text = {}
  for index, line in ipairs(sourced_text) do
    local l, _ = string.gsub(line, '%s%s+$', '')
    table.insert(replaced_text, l)
  end
  api.nvim_buf_set_lines(buffer, top, bottom, false, replaced_text)

end

local function onBufLeave()
end

local function onBufEnter()
  api.nvim_buf_attach(api.nvim_get_current_buf(), false, {
    on_lines = function(...)
      event = { ... }
    end,
    on_detach = function()
      print("Detached")
    end
  })
end

local function onBufModify()
  stripWhitespace(event[2], event[4], event[6])
end

local M = {}

function M.setup()
  local group = api.nvim_create_augroup('spaceless', {})

  local pattern = {
    "*.adoc",
    "*.md",
    "*.vimwiki"
  }

  local function au(event, callback)
    api.nvim_create_autocmd(event, { pattern = pattern, group = group, callback = callback })
  end

  -- The user may move between buffers in insert mode
  -- (for example, with the mouse), so handle this appropriately.
  au('BufEnter', onBufEnter)
  au('BufLeave', onBufLeave)
  au('TextChanged', onBufModify)
  au('TextChangedI', onBufModify)
end

return M
