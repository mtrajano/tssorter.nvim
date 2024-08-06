local M = {}

---@class SortableOpts
---@field node? string|string[]
---@field ordinal? string
---@field order_by? function

---@alias SortableCfg { [string]: SortableList }
---@alias SortableList { [string]: SortableOpts }

---@class LoggerCfg
---@field level? number
---@field outfile? string?

---@class Config
---@field sortables? SortableCfg
---@field logger? LoggerCfg

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
      list = {
        node = 'list_item',
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
      -- TODO: add todo tasks
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
