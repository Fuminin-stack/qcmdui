--- @meta

--- @class StringBuffer
--- @field value table
--- @field pos integer
--- @field toString fun(self): string
--- @field push fun(self, char: string)
--- @field pop fun(self): string
--- @field getPos fun(self): number
--- @field movePos fun(self, increment: number): boolean
--- @field insert fun(self, char: string): number
--- @field withdraw fun(self): string
--- @field toEnd fun(self)
--- @field clear fun(self)
--- @field writeToio fun(self, target: file*, start_from?: number, stop_at?: number)
--- @field pushString fun(self, str: string)

StringBuffer = {}
StringBuffer.__index = StringBuffer

--- Constructor of StringBuffer
--- @return StringBuffer
function StringBuffer.new()
  --- @type StringBuffer
  local self = setmetatable({}, StringBuffer)
  self.value = {}
  self.pos = 1
  return self
end

--- Check, trim, and output the input string to a character
--- @param input string
--- @return string 
function StringBuffer.trimInput(input)
  if #input ~= 1 then return input:sub(1,1) else return input end
end

function StringBuffer:toString()
  return table.concat(self.value)
end

function StringBuffer:push(char)
  local input = self.trimInput(char)
  self.value[#self.value+1] = input
  self.pos = #self.value+1
end

function StringBuffer:pop()
  local char = self.value[#self.value]
  self.value[#self.value] = nil
  self.pos = #self.value+1
  return char
end

function StringBuffer:getPos()
  return self.pos
end

function StringBuffer:movePos(increment)
  local resultPos = self.pos + increment
  if resultPos < 1 then
    self.pos = 1
    return false
  elseif resultPos > #self.value+1 then
    self.pos = #self.value+1
    return false
  else
    self.pos = resultPos
  end
  return true
end

function StringBuffer:insert(char)
  table.insert(self.value, self.pos, self.trimInput(char))
  self.pos = self.pos + 1
end

function StringBuffer:withdraw()
  local char = table.remove(self.value, self.pos-1)
  self.pos = self.pos-1
  return char
end

function StringBuffer:toEnd()
  self.pos = #self.value+1
end

function StringBuffer:clear()
  self.pos = 1
  self.value = nil
  self.value = {}
end

function StringBuffer:writeToio(target, start_from, stop_at)
  local s = 1
  local e = #self.value
  if start_from > stop_at then io.stderr("start_from > stop_at when calling writeToio")  end
  if start_from ~= nil and start_from >= 1 then s = start_from end
  if stop_at ~= nil and stop_at <= #self.value then e = stop_at end
  for i=s, e do
    target:write(self.value[i])
  end
end

function StringBuffer:split(pos)
  local splited_buffer = StringBuffer.new()
  if pos ~= nil then self.pos = pos end
  local cutpos = self.pos
  if cutpos > #self.value then return splited_buffer end
  for i=cutpos, #self.value do
    self:movePos(1)
    splited_buffer:push(self:withdraw())
  end

  return splited_buffer
end

function StringBuffer:pushString(str)
  for i=1, str:len() do
    self:push(string.sub(str, i, i))
  end
end
