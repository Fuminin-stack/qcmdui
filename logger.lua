--- @meta

--- @class Logger
--- Target file of the logs
--- @field logfile file*
---
--- Construct a new logger
--- @field new fun(logfile: string): Logger 
---
--- Log a string to the target file
--- @field logentry fun(self, entry: string)
Logger = {}
Logger.__index = Logger


local ERROR_ON_OPENING = function (filename)
  return "Fail to open file:'logs/" .. filename ..
    "' , check whether the file exists or the logger has permission to access to the file"
end

function Logger.new(logfile)
  local self = setmetatable({}, Logger)
  self.logfile = assert(io.open("./logs/" .. logfile, "a"), ERROR_ON_OPENING(logfile))
  return self
end

function Logger:logentry(entry)
  assert(self.logfile:write(entry))
  self.logfile:flush()
end

function Logger:close()
  self.logfile:close()
end

