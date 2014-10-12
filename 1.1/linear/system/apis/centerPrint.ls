function centerPrint(msg)
msgLen = string.len(msg)
screenWidth,_ = term.getSize()
xCoords = tonumber(math.ceil((screenWidth / 2) - (msgLen / 2)))
_,termY = term.getCursorPos()
term.setCursorPos(xCoords,termY)
print(msg)
return xCoords
end
