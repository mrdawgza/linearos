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


local settingsFrame = NovaUI.UIFrame(1,1,w,h)

local mainBar = settingsFrame:newChild(NovaUI.UIText(1,1,w,h))
mainBar.bc = userBarC

local exitButton = settingsFrame:newChild(NovaUI.UIButton(51,1,1,1,"X"))
exitButton.tc = colors.white
exitButton.bc = userBarC
function exitButton:onClick()
	return
	shell.run(systemPath.."home.ls")
end 


local barText = settingsFrame:newChild(NovaUI.UIText(2,1,8,1))
barText.bc = userBarC
barText.tc = colors.white
barText.text = "Settings"

local bc = settingsFrame:newChild(NovaUI.UIText(1,2,w,h))
bc.bc = colors.white
bc.tc = colors.white

local userButton = settingsFrame:newChild(NovaUI.UIButton(1,3,30,1,"User Accounts                 "))
userButton.bc = colors.lightGray
userButton.tc = colors.black
function userButton:onClick()
 settingsFrame:remove()
 local userFrame = NovaUI.UIFrame(1,1,w,h)
 userFrame:newChild(mainBar)
 userFrame:newChild(barText)
 userFrame:newChild(bc)
 local userFrameReturn = userFrame:newChild(NovaUI.UIButton(51,1,1,1,"<"))
 userFrameReturn.bc = userBarC
 userFrameReturn.tc = colors.white
 function userFrameReturn:onClick()
  userFrame:remove()
  UI:newChild(settingsFrame)
 end

 local currentUserText = userFrame:newChild(NovaUI.UIText(1,3,13,1,"Current User:"))
 currentUserText.bc = colors.white
 currentUserText.tc = colors.black

 local currentUserVar = userFrame:newChild(NovaUI.UIText(15,3,w,1,currentUser))
 currentUserVar.bc = colors.white
 currentUserVar.tc = colors.black

 local changePass = userFrame:newChild(NovaUI.UIButton(1,5,30,1,"Change Password               "))
 changePass.bc = colors.lightGray
 changePass.tc = colors.black

 local changeUsername = userFrame:newChild(NovaUI.UIButton(1,7,30,1,"Change Username               "))
 changeUsername.bc = colors.lightGray
 changeUsername.tc = colors.black

 local addUser = userFrame:newChild(NovaUI.UIButton(1,9,30,1,"Add a user                    "))
 addUser.bc = colors.green
 addUser.tc = colors.black

 local delUser = userFrame:newChild(NovaUI.UIButton(1,11,30,1,"Delete my account             "))
 delUser.bc = colors.red
 delUser.tc = colors.black
 
 UI:newChild(userFrame)
end


local userBc = settingsFrame:newChild(NovaUI.UIButton(1,5,30,1,"User Background               "))
userBc.bc = colors.lightGray
userBc.tc = colors.black
function userBc:onClick()
 shell.run(systemPath.."NovaPaint linear/userfolders/"..currentUser.."/imgs/desktopBg.lsg")
 shell.run(systemPath.."settings.ls")
end


local userBarColour = settingsFrame:newChild(NovaUI.UIButton(1,7,30,1,"User Bar Colour               "))
userBarColour.bc = colors.lightGray
userBarColour.tc = colors.black
function userBarColour:onClick()

end


local aboutLinear = settingsFrame:newChild(NovaUI.UIButton(1,9,30,1,"About LinearOS                "))
aboutLinear.bc = colors.lightGray
aboutLinear.tc = colors.black
function aboutLinear:onClick()

end


local checkUpdates = settingsFrame:newChild(NovaUI.UIButton(1,11,30,1,"Check for updates             "))
checkUpdates.bc = colors.lightGray
checkUpdates.tc = colors.black
function checkUpdates:onClick()

end


local autoUpdates = settingsFrame:newChild(NovaUI.UIButton(1,13,30,1,"Automatic Updates             "))
autoUpdates.bc = colors.lightGray
autoUpdates.tc = colors.black
function autoUpdates:onClick()

end


local bootBehav = settingsFrame:newChild(NovaUI.UIButton(1,15,30,1,"Boot behaviour                "))
bootBehav.bc = colors.lightGray
bootBehav.tc = colors.black
function bootBehav:onClick()

end


local deskIcons = settingsFrame:newChild(NovaUI.UIButton(1,17,30,1,"Desktop Icons                 "))
deskIcons.bc = colors.lightGray
deskIcons.tc = colors.black


UI:newChild(settingsFrame)

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
