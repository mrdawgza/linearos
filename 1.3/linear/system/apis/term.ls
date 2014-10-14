--[[
  Short Terminal Commands
  (C) Linear Systems
--]]


function clear(x,y)
 term.clear()
 term.setCursorPos(x,y)
end

function pos(x,y)
 term.setCursorPos(x,y)
end

function tCol(color)
 term.setTextColor(color)
end

function bCol(color)
 term.setBackgroundColor(color)
end

function cLine()
 term.clearLine()
end