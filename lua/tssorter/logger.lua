local M = {}

local log_level
local outfile

---@param opts LoggerCfg
M.init = function(opts)
  log_level = opts.level
  outfile = opts.outfile
end

M.log = function(message, level, context)
  level = level or vim.log.levels.WARN

  if level < log_level then
    return
  end

  if context then
    message = string.format('%s: %s', message, vim.inspect(context))
  end

  if outfile then
    local fd = io.open(outfile, 'a+')
    if not fd then
      error('Could not open outfile: ' .. outfile)
    end

    fd:write(message .. '\n')
    fd:close()
  else
    vim.notify(message, level)
  end
end

M.trace = function(message, context)
  M.log(message, vim.log.levels.TRACE, context)
end

M.warn = function(message, context)
  M.log(message, vim.log.levels.WARN, context)
end

M.off = function(message, context)
  M.log(message, vim.log.levels.OFF, context)
end

M.info = function(message, context)
  M.log(message, vim.log.levels.INFO, context)
end

M.debug = function(message, context)
  M.log(message, vim.log.levels.DEBUG, context)
end

M.error = function(message, context)
  M.log(message, vim.log.levels.ERROR, context)
end

return M
