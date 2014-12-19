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
--CODE BEGIN
local loginFrame = NovaUI.UIFrame(1,1,51,19)

local target2 = {}

if fs.exists(systemPath.."config.cfg") then
  local loginBar = loginFrame:newChild(NovaUI.UIText(1,1,w,1))  
  loginBar.bc = colors.blue
  local loginText1 = loginFrame:newChild(NovaUI.UIText(1,1,18,1,"Login to Linear OS"))
  loginText1:centreX()
  loginText1.bc = colors.blue
  loginText1.tc = colors.white
  local loginText2 = loginFrame:newChild(NovaUI.UIText(1,5,8,1,"Username"))
  loginText2.tc = colors.black
  loginText2:centreX()
  local loginText3 = loginFrame:newChild(NovaUI.UIText(1,9,8,1,"Password"))
  loginText3.tc = colors.black
  loginText3:centreX()
  local loginUsername = loginFrame:newChild(NovaUI.UIInput(1,6,w,1))
  local loginPassword = loginFrame:newChild(NovaUI.UIInput(1,10,w,1,"*"))
  local alignButton = loginFrame:newChild(NovaUI.UIButton(1,13,1,1))
  alignButton:centreX()
  local loginButton1 = loginFrame:newChild(NovaUI.UIButton(1,13,10,1,"Login"))
  loginButton1.bc = colors.green
  loginButton1.tc = colors.black
  loginButton1.h = 3
  loginButton1:alignTo("left",alignButton)
  function loginButton1:onClick()
    if user.logIn(loginUsername.text,loginPassword.text) then
      currentUser = loginUsername.text
      loginFrame:remove()
      local mainUI = NovaUI.UIFrame(1,1,w,h)
      local loadDesktop = mainUI:newChild(NovaUI.UICanvas(1,1,w,h))
      local f, err = shell.run("linear/system/home.ls")
      args={}
      if f then
        loadDesktop:setTask( function( ... )
        setfenv( f, getfenv( ) )
        local ok, err = pcall( f, ... )
        if not ok and err ~= nil then
          print(err)
          return
        end
      print( "App has finished," .. " press any key to exit." )
      parallel.waitForAny( function( ) os.pullEvent "key" end, function( ) os.pullEvent "mouse_click" end )
    end )
    loadDesktop:passEvent( unpack( args ) )
   else
     print(err)
   end

      UI:newChild(mainUI)
     else
      local errorText = loginFrame:newChild(NovaUI.UIButton(1,3,w,1,"Either wrong password or no such user."))
      errorText.bc = colors.red
      errorText.tc = colors.black
    end
  end
  local loginButton2 = loginFrame:newChild(NovaUI.UIButton(1,13,10,1,"Shutdown"))
  loginButton2.bc = colors.red
  loginButton2.tc = colors.black
  loginButton2.h = 3
  loginButton2:alignTo("right",alignButton)
  function loginButton2:onClick()
    os.shutdown()
  end

 else

  userBarC = colors.blue
  local setupBackground = loginFrame:newChild(NovaUI.UIText(1,2,w,25))
  setupBackground.bc = userBarC
  local setupBar1 = loginFrame:newChild(NovaUI.UIText(1,1,w,1,""))
  setupBar1.bc = userBarC
  local setupText1 = loginFrame:newChild(NovaUI.UIText(1,1,34,1,"Welcome to Linear Operating System"))
  setupText1.bc = userBarC
  setupText1.tc = colors.white
  setupText1:centreX()
  local scrollBar = loginFrame:newChild(NovaUI.UIScrollBar(51,1,1,23,loginFrame,verticle))
  local setupCNT = loginFrame:newChild(NovaUI.UIText(1,3,49,1,"Computer Name:"))
  setupCNT.tc = colors.white
  setupCNT.bc = userBarC
  local setupCNI = loginFrame:newChild(NovaUI.UIInput(1,4,50,1))
  local setupUN = loginFrame:newChild(NovaUI.UIText(1,7,49,1,"User Name:"))
  setupUN.bc = userBarC
  setupUN.tc = colors.white
  local setupUNI = loginFrame:newChild(NovaUI.UIInput(1,8,50,1))
  local setupUP = loginFrame:newChild(NovaUI.UIText(1,11,49,1,"User Password:"))
  setupUP.bc = userBarC
  setupUP.tc = colors.white
  local setupUPI = loginFrame:newChild(NovaUI.UIInput(1,12,50,1,"*"))
  local setupUPC = loginFrame:newChild(NovaUI.UIText(1,15,49,1,"Confirm User Password:"))
  setupUPC.bc = userBarC
  setupUPC.tc = colors.white
  local setupUPCI = loginFrame:newChild(NovaUI.UIInput(1,16,50,1,"*"))
  local setupUC = loginFrame:newChild(NovaUI.UIText(1,18,49,1,"User Colour:"))
  setupUC.bc = userBarC
  setupUC.tc = colors.white
  local setupUCBar1 = loginFrame:newChild(NovaUI.UIText(1,19,50,1))
  setupUCBar1.bc = colors.black
  local setupUCBar2 = loginFrame:newChild(NovaUI.UIText(1,21,50,1))
  setupUCBar2.bc = colors.black
  local setupUCBar3 = loginFrame:newChild(NovaUI.UIText(1,20,50,1))
  setupUCBar3.bc = colors.black
  local setupFinishB = loginFrame:newChild(NovaUI.UIButton(1,23,10,1,"Continue"))
  setupFinishB:centreX()
  setupFinishB.bc = colors.green
  setupFinishB.tc = colors.black
  setupFinishB.h = 3
  function setupFinishB:onClick()
    if setupUPCI.text == setupUPI.text then
     local saveConf = fs.open(systemPath.."config.cfg","w")
     saveConf.close()
     fs.copy(systemPath.."imgs/desktopBg.lsg", usersPath..setupUNI.text.."/imgs/desktopBg.lsg")
     local output = textutils.serialize(target2)
     local outputFile = fs.open(usersPath..setupUNI.text.."/barColour.ls","w")
     outputFile.write(output)
     outputFile.close()
     user.register(setupUNI.text,setupUPI.text)
     os.setComputerLabel(setupCNI.text)
     os.reboot()
    else
     setupUP.bc = colors.red
     setupUP.text = "User Password: Passwords do not match!"
     setupUPC.bc = colors.red
     setupUPC.text = "Confirm User Password: Passwords do no match!"
    end
  end
  for i = 1,14 do
    local button = loginFrame:newChild(NovaUI.UIButton(2*i,20,2,1))
    button.bc = 2^i
    function button:onClick()
     userBarC = 2^i
     setupText1.bc = userBarC
     setupBar1.bc = userBarC
     target2.uBarC = 2^i
     setupCNT.bc = userBarC
     setupBackground.bc = userBarC
     setupUN.bc = userBarC
     setupUP.bc = userBarC
     setupUPC.bc = userBarC
     setupUC.bc = userBarC
    end
  end

end



UI:newChild(loginFrame)

--CODE END
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



