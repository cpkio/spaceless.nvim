local api = vim.api

local spaceless_event = {}

local function stripWhitespace(buffer, top, bottom)

  local sourced_text = api.nvim_buf_get_lines(0, top, bottom, false)
  local replaced_text = {}
  for index, line in ipairs(sourced_text) do
    local l, _ = string.gsub(line, '%s+$', '')
    table.insert(replaced_text, index, l)
  end
  api.nvim_buf_set_lines(0, top, bottom, false, replaced_text)

end

local function onBufLeave()
  api.nvim_buf_detach(0)
end

local function onBufEnter()
  api.nvim_buf_attach(0, false, {
    on_lines = function(...)
      spaceless_event = { ... }
    end
  })
end

local function onBufModify()
  stripWhitespace(0, spaceless_event[4], spaceless_event[5])
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
  au('InsertLeave', onBufModify)
end

return M
