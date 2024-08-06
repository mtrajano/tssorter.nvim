local sorter = require('tssorter.sorter')
local logger = require('tssorter.logger')
local config = require('tssorter.config')

local M = {}

---@param opts Config?
M.setup = function(opts)
  opts = config.setup(opts)

  logger.init(opts.logger)
end

M.sort = sorter.sort

return M
