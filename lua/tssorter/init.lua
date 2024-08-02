local sorter = require('tssorter.sorter')
local logger = require('tssorter.logger')

---@class LanguageOpts
---@field sortables string[]

local M = {}

M.setup = function(opts)
  logger.init(opts.logger)
  sorter.init(opts.sortables)
end

M.sort = sorter.sort

return M
