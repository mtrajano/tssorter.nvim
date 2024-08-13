local tshelper = require('tssorter.tshelper')
local logger = require('tssorter.logger')
local config = require('tssorter.config')

local M = {}

---@class SorterOpts
---@field sortable? string
---@field reverse? boolean

--- Return a list of lines from the given nodes
---@param nodes TSNode[]
---@return string[]
local function get_node_lines(nodes)
  return vim
    .iter(nodes)
    :map(function(node)
      return tshelper.get_text(node)
    end)
    :totable()
end

--- Return a list of ordinal text for this node
---@param node TSNode
---@param ordinal string|string[]
---@return string
local function get_ordinal_text(node, ordinal)
  local child_node = tshelper.get_nested_child(node, ordinal)

  if not child_node then
    logger.warn(
      'Ordinal node was not found in given node defaulting to empty string',
      { node_type = node:type(), ordinal = ordinal }
    )
    return '' -- FIX: is this the best way to handle when the nested ordinal is not found? Consider adding option for default value
  end

  return tshelper.get_text(child_node)
end

--- Default sort function simply sorts the text alphabetically with optinal ordinal nodes
---@param node1 TSNode
---@param node2 TSNode
---@param ordinal1 string If a nested ordinal node was specified this is for node1
---@param ordinal2 string If a nested ordinal node was specified this is for node1
---@return boolean # Return true if the node1 comes before node2
local function default_sort(node1, node2, ordinal1, ordinal2)
  if ordinal1 and ordinal2 then
    return ordinal1 < ordinal2
  end

  local line1 = tshelper.get_text(node1)
  local line2 = tshelper.get_text(node2)

  return line1 < line2
end

--- Returns the retrieved lines in a sorted order
---@param nodes TSNode[]
---@param opts SorterOpts | SortableOpts
---@return string[]
local function get_sorted_lines(nodes, opts)
  local order_by = opts.order_by or default_sort

  table.sort(nodes, function(node1, node2)
    local ordinal1, ordinal2
    if opts.ordinal then
      vim.print { type = node1:type(), ordinal = opts.ordinal }
      ordinal1 = get_ordinal_text(node1, opts.ordinal)
      ordinal2 = get_ordinal_text(node2, opts.ordinal)
    end

    return order_by(node1, node2, ordinal1, ordinal2)
  end)

  local lines = get_node_lines(nodes)

  if opts.reverse then
    lines = vim.iter(lines):rev():totable()
  end

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
  local marks = get_position_marks(positions)
  local namespaces = vim.api.nvim_get_namespaces()
  local ns_id = namespaces['tssorter']

  for i, line in ipairs(sorted_lines) do
    local extmark_id = marks[i]
    local extmark = vim.api.nvim_buf_get_extmark_by_id(bufnr, ns_id, extmark_id, { details = true })

    local lines = vim.split(line, '\n')

    logger.trace('Setting sorted line in position', {
      extmark = extmark,
      lines = lines,
    })

    vim.api.nvim_buf_set_text(bufnr, extmark[1], extmark[2], extmark[3].end_row, extmark[3].end_col, lines)

    vim.cmd([[silent! undojoin]])
  end

  -- TODO: clean up extmarks?
end

--- Main function of sorter, by default sorts current line under
---@param opts SorterOpts
M.sort = function(opts)
  opts = opts or {}

  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[bufnr].filetype
  local sortables = config.get_sortables_for_ft(filetype)

  if not sortables then
    logger.warn('No sortables configured for current filetype!')
    return
  end

  logger.trace('Finding sortables', {
    bufnr = bufnr,
    filetype = filetype,
    sortables = sortables,
  })

  local sortable_name, sortable_nodes = tshelper.find_sortables(sortables)

  logger.trace('Returned from find_sortables', { num_nodes = sortable_nodes and #sortable_nodes or 0 })

  if not sortable_name or not sortable_nodes or vim.tbl_isempty(sortable_nodes) then
    logger.warn('No sortable node under cursor')
    return
  end

  -- merge any extra config from the sortable such as custom sorter, etc...
  local sortable_config = sortables[sortable_name]
  opts = vim.tbl_deep_extend('keep', opts, sortable_config)

  local original_positions = tshelper.get_positions(sortable_nodes)
  local sorted_lines = get_sorted_lines(sortable_nodes, opts)

  place_sorted_lines_in_pos(sorted_lines, original_positions)
end

return M
