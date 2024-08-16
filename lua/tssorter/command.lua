local config = require('tssorter.config')
local sorter = require('tssorter.sorter')

local M = {}

---Returns completions based on a prefix
---@param prefix string
---@param possible_values string[]
---@return string[] completions
local function complete_prefix(prefix, possible_values)
  local completions = {}
  for _, value in ipairs(possible_values) do
    if value:find(prefix, 1, true) == 1 then
      table.insert(completions, value)
    end
  end

  return completions
end

---@param prefix string
---@return string[] sortable_completions
local function complete_sortables(prefix)
  local ft = vim.bo[0].filetype
  local sortables = config.get_sortables_by_filetype(ft)

  if not sortables then
    return {}
  end

  local possible_sortables = vim.tbl_keys(sortables)

  return complete_prefix(prefix, possible_sortables)
end

---@param prefix string
---@return string[]
local function complete_option_names(prefix)
  local possible_options = {
    'reverse',
  }

  return complete_prefix(prefix, possible_options)
end

---@param option_name string
---@param prefix string
---@return string[]
local function complete_option_values(option_name, prefix)
  local possible_option_values = {
    reverse = { 'true', 'false' },
  }

  local possible_values = possible_option_values[option_name]

  if not possible_values then
    return {}
  end

  return complete_prefix(prefix, possible_values)
end

---@param prefix string
---@return string[] option_completions
local function complete_options(prefix)
  local tokens = vim.split(prefix, '=')

  if #tokens == 1 then
    return complete_option_names(prefix)
  elseif #tokens == 2 then
    return complete_option_values(tokens[1], tokens[2])
  end

  return {}
end

--- Returns completions for TSSort command
---@param prefix string
---@param line string
---@return string[]
M.complete = function(prefix, line, _)
  local tokens = vim.split(line, ' ')

  if #tokens == 2 then
    return complete_sortables(prefix)
  elseif #tokens == 3 then
    return complete_options(prefix)
  end

  return {}
end

---@param value string
---@return any
local function convert_value(value)
  if value == 'true' then
    return true
  elseif value == 'false' then
    return false
  end

  return value
end

---@param sortable string
---@param args string[]
---@return table
local function prepare_args(sortable, args)
  local cmd_args = vim.iter(args):fold({}, function(acc, key, _)
    local cmd_key, cmd_val = unpack(vim.split(key, '='))
    acc[cmd_key] = convert_value(cmd_val)
    return acc
  end)

  cmd_args['sortable'] = sortable

  return cmd_args
end

--- Prepares user command args and calls the underlying lua api
---@param sortable string
---@vararg string
M.execute = function(sortable, ...)
  local cmd_args = { ... }
  cmd_args = prepare_args(sortable, cmd_args)
  cmd_args['sortable'] = sortable

  sorter.sort(cmd_args)
end

return M
