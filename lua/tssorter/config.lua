local M = {}

---@class Config
---@field sortables? SortableCfg
---@field logger? LoggerCfg

---@alias SortableCfg { [string]: SortableList }
---@alias SortableList { [string]: SortableOpts }

---@class SortableOpts
---@field node? string|string[]
---@field ordinal? string|string[]
---@field order_by? function

---@class LoggerCfg
---@field level? number
---@field outfile? string?

---@type Config
-- TODO: add any more defaults that would make sense having out of the box
M.default_config = {
  sortables = {
    css = {
      properties = {
        node = 'declaration',
      },
    },
    go = {
      imports = {
        node = 'import_spec',
      },
    },
    html = {
      attributes = {
        node = 'attribute',
      },
    },
    json = {
      keys = {
        node = 'pair',
      },
    },
    lua = {
      list = {
        node = 'field',
      },
    },
    markdown = {
      task_text = {
        node = 'list_item',
        ordinal = 'inline',
      },
      task_status = {
        node = 'list_item',
        ordinal = { 'task_list_marker_unchecked', 'task_list_marker_checked' }, -- TODO: these two are conflicting, need to add user commands so user is able to specify which one he wants to sort by
      },
      headers = {
        node = 'section',
      },
    },
    norg = {
      headers = {
        node = {
          'heading1',
          'heading2',
          'heading3',
          'heading4',
          'heading5',
          'heading6',
        },
      },
      todos = {
        node = {
          'ordered_list1',
          'ordered_list2',
          'ordered_list3',
          'ordered_list4',
          'ordered_list5',
          'ordered_list6',
          'unordered_list1',
          'unordered_list2',
          'unordered_list3',
          'unordered_list4',
          'unordered_list5',
          'unordered_list6',
        },
        ordinal = 'detached_modifier_extension',
        order_by = function(_, _, ordinal1, ordinal2)
          local todo_order = {
            ['(!)'] = 1, -- important
            ['( )'] = 2, -- undone
            ['(-)'] = 3, -- pending
            ['(+)'] = 4, -- recurring
            ['(=)'] = 5, -- hold
            ['(?)'] = 6, -- ambiguous
            ['(x)'] = 7, -- done
            ['(_)'] = 8, -- cancelled
            [''] = 9, -- regular list with no todo
          }

          return todo_order[ordinal1] < todo_order[ordinal2]
        end,
      },
    },
    python = {
      imports = {
        node = 'import_from_statement',
      },
    },
    rust = {
      enums = {
        node = 'enum_variant',
      },
      imports = {
        node = 'use_declaration',
      },
    },
  },
  logger = {
    level = vim.log.levels.WARN,
    outfile = nil,
  },
}

---@param opts Config?
M.setup = function(opts)
  opts = opts or {}
  -- FIX: what happens if the sortable the user wants to specify conflicts with one of the sortables? We need to give a
  -- higher priority to the users config or give user ability to override default sortables
  M.default_config = vim.tbl_deep_extend('force', M.default_config, opts)
  return M.default_config
end

---@return Config
M.get_config = function()
  return M.default_config
end

---@param filetype string
---@return SortableCfg?
M.get_sortables_for_ft = function(filetype)
  return M.get_config().sortables[filetype]
end

return M
