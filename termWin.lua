--- @meta
require("panel")
require("stringBUffer")
llc = require("llcontrol").unpack()

--- @class TermWin
---
---
--- @field win_size table<string, integer>
--- @field panels table<integer, Panel>
---
---
--- @field new fun(win_size?: table<string, integer>) 
---
--- @field draw fun(self)

TermWin = {}
TermWin.__index = TermWin

function TermWin:clear()
  io.write("\027[2J\027[H")
end
