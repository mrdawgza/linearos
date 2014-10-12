

local function runDesktop()

--[[
   
                                        Linear Operating System
                                                Desktop

--]] 

--------------------------------------------------------------------------------------------------------------------------------- 
  
  
--[[ Variables ]]

local defaultBc = colors.black
local defaultTc = colors.white
globalUser = user.getCurrent()


---------------------------------------------------------------------------------------------------------------------------------


--[[ Time ]]
  
local function drawTime()
 time = os.time()
 if timeFormat == "24HR" then 
   outTime = textutils.formatTime(time, true)
   pos(46,1)
   bCol(menuBarC)
   print(outTime)
   bCol(defaultBc)
  elseif timeFormat == "12HR" then
   outTime = textutils.formatTime(time, false)
   pos(44,1)
   bCol(menuBarC)
   print(outTime)
   bCol(defaultBc)
  end
end
  
  
--[[ Menus ]]

local function drawMainMenu()
 pos(2,2)
 bCol(colors.gray)
 print("               ")
 pos(2,3)
 print("   App Store   ")
 pos(2,4)
 print("   Programs    ")
 pos(2,5)
 print("  File Browser ")
 pos(2,6)
 print("   Settings    ")
 pos(2,7)
 print("               ")
 pos(2,8)
 print(" [S]  [R]  [L] ")
 pos(2,9)
 print("               ")
 pos(2,10)
 bCol(colors.lightGray)
 print("               ")
 bCol(defaultBc)
 
 while true do
 local timeout = os.startTimer(0.4)
 local event, button, x, y = os.pullEventRaw()
 if event == "mouse_click" then 
  if x>2 and x<18 and y==3 and button==1 then
   shell.run("linear/system/appStore.ls")
   runDesktop()
  elseif x>2 and x<18 and y==4 and button==1 then 
   shell.run("linear/system/programManager.ls")
   runDesktop()
  elseif x>2 and x<18 and y==5 and button==1 then
   shell.run("linear/system/fileBrowser.ls")
   runDesktop()
  elseif x>2 and x<18 and y==6 and button==1 then
   shell.run("linear/system/settings.ls")
  elseif x>2 and x<6 and y==8 and button==1 then
   os.shutdown()
  elseif x>7 and x<11 and y==8 and button==1 then
   os.reboot()
  elseif x>12 and x<16 and y==8 and button==1 then
   bCol(colors.white)
   clear(1,1)
   pos(1,8)
   tCol(colors.black)
   centerPrint("Securing your account..")
   user.logOut()
   sleep(1.2)
   shell.run("linear/system/userScreen.ls")
  else
  runDesktop()
  end
 elseif event == "timer" then
  drawTime()
 end
 end
end

---------------------------------------------------------------------------------------------------------------------------------

                                            --[[ CODE ]]--
if fs.exists("linear/system/desktopConfig.ls") then
  
  
  --[[ Load Configuration ]]
 local handle = assert(fs.open("linear/system/desktopConfig.ls", "r"), "Failed to load desktop configuration")
 local input = handle.readAll()
 handle.close()
 local deskVar = textutils.unserialize(input)
 menuBarC = deskVar.mBarC
 timeFormat = deskVar.timeFormat
  
 
  --[[ Draw Desktop ]]
 
 bCol(menuBarC)
 clear(1,1)
 local backgroundImage = paintutils.loadImage("linear/userfolders/"..username.."/imgs/desktopBg.lsg")
 paintutils.drawImage(backgroundImage,2,2)
  
  --[[ Bar ]]
 pos(1,1)
 bCol(menuBarC)
 cLine()
 
 while true do
 
  
  --[[ Main Menu ]]

  pos(2,1)
  tCol(defaultTc)
  bCol(menuBarC)
  print("[<->]")
  pos(1,1)
  tCol(colors.black)
  centerPrint(user.getCurrent())
  tCol(defaultTc)
  bCol(defaultBc)
  local timeout = os.startTimer(0.4)
  local event, button, x, y = os.pullEventRaw()
  if event == "mouse_click" then 
   if x>2 and x<6 and y==1 and button ==1 then 
    drawMainMenu()
   else
    runDesktop()
   end
  elseif event == "timer" then 
   drawTime()
  else
  end
  sleep(0.3)

  end
  
 
---------------------------------------------------------------------------------------------------------------------------------
 
 else --If the configuration does not exist (first time setup)
  
---------------------------------------------------------------------------------------------------------------------------------
 
  local function finish()
   bCol(colors.white)
   tCol(colors.black)
   clear(1,1)
   centerPrint("Finished")
   centerPrint("--------")
   print("")
   print("You have successfully set up your desktop")
   print("Press any key to continue.")
   os.pullEvent("key")
   shell.run("linear/system/desktop.ls")
  end
  
  local function step3()
   finish()
  end
  
  local function step2()
   clear(1,1)
   tCol(colors.black)
   centerPrint("Time Format")
   print("")
   tCol(colors.black)
   centerPrint("Do you want the clock in 12hr or 24hrs?")
   print("")

   bCol(colors.green)
   pos(12,8)
   print("          ")
   pos(12,9)
   print("   12hr   ")
   pos(12,10)
   print("          ")

   bCol(colors.cyan)
   pos(32,8)
   print("          ")
   pos(32,9)
   print("   24hr   ")
   pos(32,10)
   print("          ")
   bCol(colors.white)
   tCol(colors.red)
   while true do
   local event, button, x, y = os.pullEventRaw()
   if event == "mouse_click" then
    if x>12 and x<22 and y>7 and y<11 and button==1 then
	 target1.timeFormat = "12HR"
      local output = textutils.serialize(target1)
      local handle = assert(fs.open("linear/system/desktopConfig.ls", "w"), "Couldn't save config")
      handle.write(output)
      handle.close()
	  output = nil
	  step3()
	elseif x>31 and x<42 and y>7 and y<11 and button ==1 then
	  target1.timeFormat = "24HR"
	  local output = textutils.serialize(target1)
      local handle = assert(fs.open("linear/system/desktopConfig.ls", "w"), "Couldn't save config")
      handle.write(output)
      handle.close()
	  output = nil
	  step3()
	end
   end
   sleep(0.3)
   end
  end
   
  clear(1,3)
  centerPrint("Welcome to Linear OS")
  print("")
  print("")
  centerPrint("Choose a Menu Bar color")
  print("")
  print("[BLUE] [RED] [GREEN] [CYAN] [ORANGE]")
  target1 = {}
  while true do
  local event, button, x, y = os.pullEventRaw()
  if event == "mouse_click" then 
   if x>1 and x<6 and y==8 and button==1 then
	target1.mBarC = 2048
	step2()
	
   elseif x>8 and x<12 and y==8 and button==1 then
	target1.mBarC = 16384
	step2()
	
   elseif x>14 and x<20 and y==8 and button==1 then
	target1.mBarC = 8192
	step2()
	
   elseif x>22 and x<27 and y==8 and button==1 then
	target1.mBarC = 512
	step2()
   
   elseif x>29 and x<36 and y==8 and button==1 then
	target1.mBarC = 2
	step2()
   end
  end
  end
end
    
end



---------------------------------------------------------------------------------------------------------------------------------


runDesktop()

