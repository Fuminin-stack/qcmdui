--- @meta
require("stringBuffer")
require("math")
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
--- Clear the panel
--- @field clear fun(self, fill?: string)
---
--- @field cursor_sync fun(self)
---
--- @field cursor_moveBy fun(self, pos: table<integer, integer>)
---
--- @field cursor_moveTo fun(self, pos: table<integer, integer | string>)
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

function Panel:clear(fill)
  self:cursor_home()
  for _=1, self.size.line do
    for _=1, self.size.column do
      if (fill == nil) then
        self.target:write(SP)
      else
        self.target:write(fill)
      end
      self:cursor_moveBy({0, 1})
    end
    self:cursor_carriageReturn()
  end
end

--- @class TextPanel
---
--- @field paragraphs table<integer, StringBuffer>
---
--- @field hidden_lines integer
---
--- @field renderToLine fun(self): table<integer, StringBuffer>
---
--- @field editor_insert fun(self, char: string)
---
--- @field draw(self)

TextPanel = setmetatable({}, {__index = Panel})
TextPanel.__index = TextPanel

function TextPanel.new(target, size, pos)
  -- to-do
  local self = setmetatable({Panel.new(target, size, pos)}, TextPanel)
  self.hidden_lines = 0
  self.text_cursor = {buffer = 1, positiion = 1}
  self.paragraphs = {}
  return self
end

function TextPanel:renderToLine()
  local lines = {}

  for buffer in self.paragraphs do
    buffer_remainded = buffer
    local loop_times = math.ceil((#buffer) / self.size.column)
    for _=1, loop_times do
      buffer_remainded = buffer.split(self.size.column)
      table.insert(lines, buffer)
    end
  end

  return lines
end

function TextPanel:editor_insert(char)
end

function TextPanel:draw()
  --- @type table<integer, StringBuffer>
  local lines = self:renderToLine()

  local lines_to_draw = 0
  if (#lines - self.hidden_lines > self.size.lines) then
    lines_to_draw = self.size.lines
  else
    lines_to_draw = #lines - self.hidden_lines
  end

  for i=1, lines_to_draw do
    lines[i]:writeToio(self.target)
    self:cursor_carriageReturn()
  end
end



a = TextPanel.new(io.stdout, {line = 6, column = 20}, {line = 5, column = 5})
llc.enableRawMode()
io.write("\027[2J\027[H")
for _=1, 20 do
  io.write("abcdefghijklmnopqrstuvwxyz \n")
end
llc.disableRawMode()
print(a.size)
a:clear("h")
io.write(NL)
llc.disableRawMode()
