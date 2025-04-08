--- @meta
require("panel")
require("stringBUffer")

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


