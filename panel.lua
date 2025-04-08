--- @meta
require("stringBuffer")
llc = require("llcontrol").unpack()

--- @class Panel
---
---
--- The output target file
--- @field target file*
---
--- The position of the panel in the window
--- @field pos table<integer, integer>
---
--- The size of the panel
--- @field size table<string, integer>
---
--- Texts contents of a panel
--- @field paragraphs table<integer, table<integer, StringBuffer | integer>>
---
--- Cursor position of in the panel
--- @field cursor table<integer, integer>
---
---
--- Set the panel's size
--- @field rescale fun(self, size: table<string, integer>)
---
--- Set the set the target file
--- @field redirect fun(self, target: file*)
---
--- Write to the target file
--- @field darw fun(self, paragraphs: table<integer, StringBuffer>)
---
--- Clear the panel
--- @field clear fun(self)
---
--- @field cursor_sync fun(self)
---
--- @field cursor_moveBy fun(self, pos: table<integer, integer>)
---
--- @field cursor_moveTo fun(self, pos: table<integer, integer>)
---
--- Move to the top left top of the Panel
--- @field cursor_home fun(self)
---
--- Insert a carriage return at the cursor
--- @field cursor_carriageReturn fun(self)

Panel = {}
Panel.__index = Panel

local SP = "\032"
local ESC = "\027"
local ESCSEQ = "\027["
local SEMICOL = ";"
local H = "H"
local C = "C"
local NL = "\n"
local CR = "\r"

--- Construct a new Panel object
--- @param target file* 
--- @param size table<string, integer>
--- @param pos table<integer, integer>
function Panel.new(target, size, pos)
  --- @type Panel
  local self = setmetatable({}, Panel)
  self.target = target
  self.size = size
  self.pos = pos
  self.paragraphs = {}
  self.cursor = {line = 0, column = 0}
  return self
end

function Panel:rescale(size)
  self.size = size
  self:draw()
end

function Panel:redirect(target)
  self.target = target
end

local function __cursorLimitChecker(pos, lim, osz, adj)
  if pos == "skip" then
    return osz
  end

  if pos > lim - adj then
    return lim - adj
  elseif pos == nil then
    return osz
  elseif pos < 0 then
    return 0
  else
    return pos
  end
end

function Panel:cursor_sync()
  self.target:write(ESCSEQ)
  self.target:write(self.pos.line + self.cursor.line)
  self.target:write(SEMICOL)
  self.target:write(self.pos.column + self.cursor.column)
  self.target:write(H)
end

function Panel:cursor_moveBy(increment)
  local line = self.cursor.line
  local column  = self.cursor.column

  if type(increment) == "number" then
    column = column + increment
    column = __cursorLimitChecker(column, self.size.column, self.cursor.column, 0)
  elseif type(increment) == "table" then
    line = __cursorLimitChecker(line + increment[1], self.size.line, self.cursor.line, 1)
    column = __cursorLimitChecker(column + increment[2], self.size.column, self.cursor.column, 0)
  end

  self.cursor.line = line
  self.cursor.column = column
  self:cursor_sync()
end

function Panel:cursor_moveTo(pos)
  self.cursor.line = __cursorLimitChecker(pos[1], self.size.line, self.cursor.line, 1)
  self.cursor.column = __cursorLimitChecker(pos[2], self.size.column, self.cursor.column, 0)
  self:cursor_sync()
end

function Panel:cursor_carriageReturn()
  self:cursor_moveBy({1,0})
  self:cursor_moveTo({"skip", 0})

end
function Panel:cursor_home()
  self.cursor = {line=0, column=0}
  self:cursor_sync()
end

function Panel:clear()
  self:cursor_home()
  for _=1, self.size.line do
    for _=1, self.size.column do
      self.target:write(" ")
      self:cursor_moveBy({0, 1})
    end
    self:cursor_carriageReturn()
  end
end

function Panel:draw()
  local width = self.size.width

  for i=1, #self.paragraphs do
    local currentBuffer = self.paragraphs[i]

    for j=1, #(currentBuffer.value) / width + 1 do
      currentBuffer:writeToio(self.target, 1 + (j - 1)  * width, j * width)
      self.target:cursor_carriageReturn()
    end

  end
end

function Panel:editor_carriageRetrun()
end

a = Panel.new(io.stdout, {line = 6, column = 20}, {line = 5, column = 5})
llc.enableRawMode()
io.write("\027[2J\027[H")
for _=1, 20 do
  io.write("abcdefghijklmnopqrstuvwxyz \n")
end
a:clear()
llc.disableRawMode()
