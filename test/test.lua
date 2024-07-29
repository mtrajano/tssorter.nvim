---@diagnostic disable

local array_vals = { 'val1', 'first item', 'zee last item', 'some middle item' }

local array_vals = {
  'val1',
  'first item',
  'zee last item',
  'some middle item',
}

local function set(t)
  t[1] = 'hahah overridden boyyy'
end

local function before_other_one(something)
  print(something)

  return 'whoaaaa'
end
