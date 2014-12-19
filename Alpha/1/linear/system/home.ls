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

timeFormat = false

local function showTime()
 local formattedTime = textutils.formatTime(os.time(), timeFormat)
 return formattedTime
end

userBarColourInput = fs.open(usersPath..currentUser.."/barColour.ls","r")
userBarColourTarget = textutils.unserialize(userBarColourInput.readAll())
userBarC = userBarColourTarget.uBarC
userBarColourInput.close()

local homeFrame = NovaUI.UIFrame(1,1,w,h)

local mainBar = homeFrame:newChild(NovaUI.UIButton(1,1,w,1))
mainBar.bc = userBarC

local leftBar = homeFrame:newChild(NovaUI.UIText(1,2,1,h))
leftBar.bc = userBarC

local rightBar = homeFrame:newChild(NovaUI.UIText(51,2,1,h))
rightBar.bc = userBarC

local imageFile = fs.open(usersPath..currentUser.."/imgs/desktopBg.lsg","r")
local content = imageFile.readAll()
imageFile.close()
local background = NovaUI.Image(48,18)
background:loadstr(content)
if content:find "%-%-%-" then
    NovaUI.display.alert( UI, "Cannot load images with multiple layers" )
 else
    content = nil
    local backgroundDraw = homeFrame:newChild(NovaUI.UIImage(2,2,w,h,background))
end



local userText1 = homeFrame:newChild(NovaUI.UIButton(1,1,w,1,currentUser))
userText1.bc = userBarC
userText1.tc = colors.white
function userText1:onClick(x,y,button)
 if button == 2 then 
  local UBCFrame = NovaUI.UIFrame(1,1,w,h)
  local closeButton = UBCFrame:newChild(NovaUI.UIButton(1,1,w,h))
  closeButton.bc = 0
  function closeButton:onClick()
    UBCFrame:remove()
    UI:newChild(homeFrame)
  end

  local newText = UBCFrame:newChild(NovaUI.UIText(2,1,19,1,"Choose a new colour"))
  newText.bc = userBarC
  newText.tc = colors.white

  local backDraw = UBCFrame:newChild(NovaUI.UIText(1,9,w,3))
  backDraw.bc = userBarC

  for i = 1,14 do
    local button = UBCFrame:newChild(NovaUI.UIButton(2*i,10,2,1))
    button.bc = 2^i
    function button:onClick()
     userBarC = 2^i
    end
  end

  UI:newChild(UBCFrame)

 end
end

local timeDraw = homeFrame:newChild(NovaUI.UIButton(45,1,7,1,showTime))
timeDraw.bc = userBarC
timeDraw.tc = colors.white
function timeDraw:onClick()
  if timeFormat then
     timeFormat = false
   else
     timeFormat = true
  end
end

local desktopBgButton = homeFrame:newChild(NovaUI.UIButton(2,2,50,18))
desktopBgButton.bc = 0
function desktopBgButton:onClick(x,y,button)
 if button == 2 then
   local backgroundFrame = NovaUI.UIFrame(2,2,50,18)
   local backgroundReturn = backgroundFrame:newChild(NovaUI.UIButton(2,2,50,18))
   backgroundReturn.bc = 0 
   function backgroundReturn:onClick()
    backgroundFrame:remove()
    UI:newChild(homeFrame)
   end

   local backgroundMenu = backgroundFrame:newChild(NovaUI.UIButton(x,y,19,3,"Change Background"))
   backgroundMenu.bc = colors.lightGray
   backgroundMenu.tc = colors.black

   UI:newChild(backgroundFrame)
 end
end



local menuButton = homeFrame:newChild(NovaUI.UIButton(2,1,6,1,"linear"))
menuButton.bc = userBarC
menuButton.tc = colors.white
function menuButton:onClick()
  local menuFrame = NovaUI.UIFrame(1,1,w,h)

  local menuBackButton = menuFrame:newChild(NovaUI.UIButton(1,2,w,h))
  menuBackButton.bc = 0
  function menuBackButton:onClick()
    menuFrame:remove()
    UI:newChild(homeFrame)
  end

  local menuBackground = menuFrame:newChild(NovaUI.UIText(2,1,15,9))
  menuBackground.bc = colors.gray 

  local menuLinear = menuFrame:newChild(NovaUI.UIText(2,1,6,1,"Linear"))
  menuLinear.bc = colors.gray
  menuLinear.tc = colors.white

  local menuAppSwitcher = menuFrame:newChild(NovaUI.UIButton(2,3,15,1,"App Switcher"))
  menuAppSwitcher.bc = colors.gray
  menuAppSwitcher.tc = colors.white
  function menuAppSwitcher:onClick()
   local listProgramsFrame = UI:newChild( NovaUI.UIFrame( 17, 3, 18, 15 ) ) 

   --local runningPrograms2 = textutils.unserialize(runningPrograms)

   local listProgramsBackground = listProgramsFrame:newChild(NovaUI.UIText(1,1,18,15))
   listProgramsBackground.bc = colors.gray

   for i = 1, #runningPrograms do
    local button1 = listProgramsFrame:newChild( NovaUI.UIButton( 1, i, listProgramsFrame.w, 1, runningPrograms[i].name ) )
    button1.tc = colors.white
    button1.bc = colors.gray
    button1.align = false
    function button1:onClick( )
     listProgramsFrame:remove()
     UI:newChild(runningPrograms[i].canvas)
   end
end
  end

  local menuFileBrowser = menuFrame:newChild(NovaUI.UIButton(2,4,15,1,"File Browser"))
  menuFileBrowser.bc = colors.gray
  menuFileBrowser.tc = colors.white
function menuFileBrowser:onClick()
    local loadFileBrowser = UI:newChild(NovaUI.UICanvas(1,1,w,h))
    local shell = shell
    table.insert(runningPrograms, {name = "File Browser", canvas = "loadFileBrowser"})
    loadFileBrowser:setTask( function( ... )
    shell.run("linear/system/fileBrowser.ls")
        --print("App has finished. Press any key or click to return.")
        --parallel.waitForAny( function( ) os.pullEvent "key" end, function( ) os.pullEvent "mouse_click" end )
        loadFileBrowser:remove()
    end)
    loadFileBrowser:passEvent( )
    
end

  local menuApps = menuFrame:newChild(NovaUI.UIButton(2,5,15,1,"Apps"))
  menuApps.bc = colors.gray
  menuApps.tc = colors.white
  function menuApps:onClick()
    local loadApps = UI:newChild(NovaUI.UICanvas(1,1,w,h))
    local shell = shell
  
    loadApps:setTask( function( ... )
    shell.run("linear/system/apps.ls")
        print("App has finished. Press any key or click to return.")
        parallel.waitForAny( function( ) os.pullEvent "key" end, function( ) os.pullEvent "mouse_click" end )
        loadApps:remove()
    end)
    loadApps:passEvent( )
  end

  local menuSettings = menuFrame:newChild(NovaUI.UIButton(2,6,15,1,"Settings"))
  menuSettings.bc = colors.gray
  menuSettings.tc = colors.white
  function menuSettings:onClick()
   --[[loadSettings = UI:newChild(NovaUI.UICanvas(1,1,w,h))
    local shell = shell
    loadSettings:setTask( function( ... )
    homeFrame:remove()
    shell.run("linear/system/settings.ls")
        print("App has finished. Press any key or click to return.")
        parallel.waitForAny( function( ) os.pullEvent "key" end, function( ) os.pullEvent "mouse_click" end )
        loadSettings:remove()
        UI:newChild(homeFrame)

    end)
    loadSettings:passEvent( )]]
    return
    shell.run("linear/system/settings.ls")
  end

  local menuS = menuFrame:newChild(NovaUI.UIButton(3,8,3,1,"[S]"))
  menuS.bc = colors.red 
  menuS.tc = colors.white
  function menuS:onClick()
   os.shutdown()
  end

  local menuR = menuFrame:newChild(NovaUI.UIButton(1,8,3,1,"[R]"))
  menuR:alignTo("right", menuS)
  menuR.x = menuR.x + 2
  menuR.bc = colors.cyan
  menuR.tc = colors.white
  function menuR:onClick()
    os.reboot()
  end

  local menuL = menuFrame:newChild(NovaUI.UIButton(1,8,3,1,"[L]"))
  menuL:alignTo("right", menuR)
  menuL.x = menuL.x + 2
  menuL.bc = colors.green
  menuL.tc = colors.white
  function menuL:onClick()
   user.logOut()
   shell.run(systemPath.."userLogin.ls")
  end

  UI:newChild(menuFrame)

end

UI:newChild(homeFrame)


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