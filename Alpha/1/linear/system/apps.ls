local running = true
local UI = NovaUI.UIHandler( )
-- any UI elements go here
local function update( event, dt )
if event[1] ~= "update" then
    NovaUI.Thread.update( event )
  UI:event( event )
else
    NovaUI.Thread.update { "update", dt }
  UI:update( event[2] )
  UI:draw( )
  NovaUI.buffer.drawChanges( )
  NovaUI.buffer.clear( )
end
end
--CODE BEGIN--


local appsFrame = NovaUI.UIFrame(1,1,w,h)

local appsBar = appsFrame:newChild(NovaUI.UIText(1,1,51,1))
appsBar.bc = userBarC

local appsBarText1 = appsFrame:newChild(NovaUI.UIText(2,1,4,1,"Apps"))
appsBarText1.bc = userBarC
appsBarText1.tc = colors.white

UI:newChild(appsFrame)

--CODE END--
local ok, err = pcall( function( )
local time = os.clock( )
local timer = os.startTimer( 0 )
os.queueEvent "start"
while running do
  local ev = { coroutine.yield( ) }
  -- any custom update code goes here
  if ev[1] ~= "update" then
   -- any custom event code goes here
  end
  local dt = os.clock( ) - time
  time = os.clock( )
  if ev[1] == "timer" and ev[2] == timer then
   update( { "update" }, dt )
   timer = os.startTimer( 0.05 )   
  else
   update( ev, dt )
  end
end
end )
if not ok then
print( err )
-- errorhandler goes here
end