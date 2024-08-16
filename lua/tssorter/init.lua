local sorter = require('tssorter.sorter')
local logger = require('tssorter.logger')
local config = require('tssorter.config')
local command = require('tssorter.command')

local M = {}

---@param opts Config?
M.setup = function(opts)
  opts = config.setup(opts)

  logger.init(opts.logger)

  vim.api.nvim_create_user_command('TSSort', function(cmd)
    command.execute(unpack(cmd.fargs))
  end, {
    nargs = '*',
    complete = function(prefix, line, pos)
      return command.complete(prefix, line, pos)
    end,
  })
end

M.sort = sorter.sort

return M
