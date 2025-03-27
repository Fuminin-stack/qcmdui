--- @meta
require("stringBuffer")

--- @class Panel
---
---
--- The output target file
--- @field target file*
---
--- The position of the panel in the window
--- @field panel_pos table<integer, integer>
---
--- The size of the panel
--- @field panel_size table<string, integer>
---
--- Texts contents of a panel
--- @field paragraphs table<string, StringBuffer>
---
--- Cursor position of in the panel
--- @field cursor_pos table<integer, integer>
---
---
--- Set the panel's size
--- @field setPanelsize fun(self, panel_size: table<string, integer>)
---
--- Set the set the target file
--- @field setTarget fun(self, target: file*)
---
--- Write to the target file
--- @field writeToio fun(self, paragraphs: table<integer, StringBuffer>)
---
--- Insert a carriage return at the cursor
--- @field cursor_carriageReturn fun(self)
---
--- Clear the panel
--- @field cursor_clear fun(self)

Panel = {}
Panel.__index = Panel

--- Construct a new Panel object
--- @param target file* 
--- @param panel_size table<string, integer>
--- @param panel_pos table<integer, integer>
function Panel.new(target, panel_size, panel_pos)
  --- @type Panel
  local self = setmetatable({}, Panel)
  self.target = target
  self.panel_pos = panel_pos
  self.panel_size = panel_size
  self.paragraphs = {}
  self.cursor_pos = {0, 0}
  return self
end

function Panel:setWinsize(winsize)
  self.winsize = winsize
end

function Panel:setTarget(target)
  self.target = target
end

function Panel:cursor_carriageReturn()
  self.target:write("\r\n")
end

function Panel:cursor_clear()
  self.target:write("\027[2J\027[H")
end

--- @param paragraphs table<integer, StringBuffer>
function Panel:writeToio(paragraphs)
  local width = self.winsize.width
  for i=1, #paragraphs do
    local currentBuffer = paragraphs[i]
    for j=1, #(currentBuffer.value) / width + 1 do
      currentBuffer:writeToio(self.target, 1 + (j - 1)  * width, j * width)
      self.target:write("\r\n")
    end
  end
end

a = Panel.new(io.stdout, {height = 10, width = 40}, {0, 0})
a:cursor_carriageReturn()
a:cursor_clear()
