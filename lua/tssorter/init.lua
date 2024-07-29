local sorter = require('tssorter.sorter')

---@class LanguageOpts
---@field sortables string[]

local M = {}

M.setup = function(opts)
  sorter.init(opts)
end

M.sort = sorter.sort

return M
