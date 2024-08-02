local tshelper = require('tssorter.tshelper')
local logger = require('tssorter.logger')

local M = {}

---@type Sortable
M.config = {}

--- Returns the nodes in a sorted order
local function get_sorted_lines(lines)
  -- TODO: provide other abilities for sorting such as reverse, custom sort functions, etc..
  table.sort(lines, function(val1, val2)
    -- TODO: this should probably be handled by the ordinal TSNode
    return vim.trim(val1) < vim.trim(val2)
  end)

  return lines
end

local function get_position_marks(positions)
  local ns_id = vim.api.nvim_create_namespace('tssorter') -- TODO: make this global to the package
  local bufnr = vim.api.nvim_get_current_buf()

  return vim
    .iter(positions)
    :map(function(position)
      return vim.api.nvim_buf_set_extmark(bufnr, ns_id, position[1], position[2], {
        end_row = position[3],
        end_col = position[4],
      })
    end)
    :totable()
end

-- TODO: move to tsutils helper
local function place_sorted_lines_in_pos(sorted_lines, positions)
  local bufnr = vim.api.nvim_get_current_buf()
  local it = vim.iter(sorted_lines)
  local marks = get_position_marks(positions)
  local namespaces = vim.api.nvim_get_namespaces()
  local ns_id = namespaces['tssorter']

  for i, line in ipairs(sorted_lines) do
    local extmark_id = marks[i]
    local extmark = vim.api.nvim_buf_get_extmark_by_id(bufnr, ns_id, extmark_id, { details = true })

    line = vim.trim(line)

    local lines = vim.split(line, '\n')

    logger.trace('Setting sorted line in position', {
      extmark = extmark,
      lines = lines,
    })

    vim.api.nvim_buf_set_text(bufnr, extmark[1], extmark[2], extmark[3].end_row, extmark[3].end_col, lines)
  end

  -- TODO: clean up extmarks
end

---@param config Sortable
M.init = function(config)
  M.config = vim.tbl_deep_extend('force', M.config, config)
end

M.sort = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[bufnr].filetype
  local sortables = M.config[filetype]

  logger.trace('Finding sortables', {
    bufnr = bufnr,
    filetype = filetype,
    sortables = sortables,
  })

  local sortable_lines, original_positions = tshelper.find_sortables(sortables)

  logger.trace(
    'Returned from find_sortables',
    { sortable_lines = sortable_lines, original_positions = original_positions }
  )

  if not sortable_lines then
    logger.warn('No sortable node under cursor')
    return
  end

  local sorted_lines = get_sorted_lines(sortable_lines)

  place_sorted_lines_in_pos(sorted_lines, original_positions)
end

return M
