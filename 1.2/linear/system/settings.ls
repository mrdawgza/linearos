--[[
                      Linear OS
			        Settings Code
--]]

local oldPull = os.pullEvent;
os.pullEvent = os.pullEventRaw;

local function settingsProgram()

 --[[ Draw Screen ]]

 local function drawScreen()
  bCol(colors.white)
  tCol(colors.black) 
  clear(1,1)
 end
 
 --[[ Bar ]] 

 local function drawBar(title, v)
  bCol(menuBarC)
  cLine()
  pos(2,1)
  print(title)
  pos(49,1)
  if v == "back" then
    print("[<]")
   elseif v == "exit" then
    print("[X]")
  end
 end

 --[[ Functions ]]
 
 local function checkUpdates()
  bCol(colors.white)
  clear(1,1)
  drawBar("Update","back")
  pos(1,3)
  bCol(colors.white)
  pos(1,6)
  centerPrint("Checking for updates")
  centerPrint("--------------------")
  pos(1,9)
  centerPrint("This may take a moment")
  
  local latestVersionRaw = http.get("http://pastebin.com/raw.php?i=dvgiJFGA")
  local latestVersion = latestVersionRaw.readAll()
  latestVersionRaw.close()
  
  if "1.2" == latestVersion then 
	clear(1,1)
	drawBar("Update","back")
	pos(1,5)
	bCol(colors.white)
    centerPrint("LinearOS is up to date")
	centerPrint("running v"..version)
	latestVersion = nil
   else 
    clear(1,1)
	drawBar("Update to v"..latestVersion, "back")
	pos(1,5)
	bCol(colors.white)
	centerPrint("An update is avaliable")
	centerPrint("----------------------")
	print("")
	centerPrint("Update to v"..latestVersion.."?")
	centerPrint("You can find the changelog in the forum thread.")
	print("")
	bCol(colors.green)
	cLine()
	pos(1,11)
	centerPrint(" Install")
	bCol(colors.red)
	cLine()
	pos(1,12)
	centerPrint("Return")
	latestVersion = nil
	while true do
     local event, button, x, y = os.pullEventRaw()
     if event == "mouse_click" then
      if x>1 and x<52 and y==11 and button==1 then
	    shell.run("pastebin get AkkBY0yS linear/system/updater.ls")
        shell.run("linear/system/updater.ls")
       elseif x>1 and x<52 and y==12 and button==1 then
        settingsProgram()
	   elseif x>48 and x<52 and y==1 and button==1 then
	    settingsProgram()
      else
      end
     end
    end
  end
  
  while true do
  local event, button, x, y = os.pullEventRaw()
  if event == "mouse_click" then
   if x>1 and x<7 and y==5 and button==1 then
    settingsProgram()
   elseif x>48 and x<52 and y==1 and button==1 then
    settingsProgram()
   else
   end
  end
  end
 end
 local function computerStatistics()
  drawScreen()
  drawBar("Computer Statistics","back")
  pos(1,3)
  local logo = paintutils.loadImage("linear/system/imgs/logo.lsg")
  paintutils.drawImage(logo,2,3)
  bCol(colors.white)
  pos(15,4)
  print("Linear Operating System")
  pos(15,5)
  print("Version: "..version)
  pos(15,7)
  print("(c) 2014 mrdawgza")
  pos(2,12)
  print("Computer Statistics")
  print(" -------------------")
  print("")
  if http then 
    print("HTTP: Enabled")
   else
    print("HTTP: Disabled")
  end
  print("Free Disk Space: "..fs.getFreeSpace("/"))
  while true do
  local event, button, x, y = os.pullEventRaw()
  if event == "mouse_click" then
   if x>48 and x<52 and y==1 and button==1 then
    settingsProgram()
   else
   end
  end
  end
 end
 local function changeMenuBarC()
  bCol(colors.white)
  clear(1,1)
  drawBar("Menu Bar Color","back")
  pos(1,3)
  bCol(colors.white)
  print("[BLUE] [RED] [GREEN] [CYAN] [ORANGE]")
  while true do
  target2 = {}
  local event, button, x, y = os.pullEventRaw()
  if event == "mouse_click" then 
   if x>1 and x<6 and y==3 and button==1 then
	target2.mBarC = 2048
   elseif x>8 and x<12 and y==3 and button==1 then
	target2.mBarC = 16384
   elseif x>14 and x<20 and y==3 and button==1 then
	target2.mBarC = 8192
   elseif x>22 and x<27 and y==3 and button==1 then
	target2.mBarC = 512
   elseif x>29 and x<36 and y==3 and button==1 then
	target2.mBarC = 2
   elseif x>48 and x<52 and y==1 and button==1 then
    settingsProgram()
   end
  end
  target2.timeFormat = timeFormat
  local output = textutils.serialize(target2)
  local handle = assert(fs.open("linear/system/desktopConfig.ls", "w"), "Couldn't save config")
  handle.write(output)
  handle.close()
  end
 end
 local function changePassword()
  while true do
   bCol(colors.white)
   clear(1,1)
   drawBar("Change Password","back")
   pos(1,3)
   bCol(colors.white)
   tCol(colors.black)
   print("Choose a new password")
   print("('cancel' to return)")
   print("New: ")
   print("Confirm: ")
   pos(6,5)
   write("")
   local newPass = read("*")
   pos(10,6)
   write("")
   local cNewPass = read("*")
   
   if newPass == "cancel" then
    settingsProgram()
   end
   
   if newPass == cNewPass then
    user.setPassword(newPass)
    clear(1,1)
	bCol(colors.green)
	cLine()
	pos(1,2)
	cLine()
	pos(1,1)
	centerPrint("Success")
	centerPrint("-------")
	bCol(colors.white)
	print("")
	print("You have successfully changed your password.")
	print("You will now be logged out to the user screen.")
	user.logOut()
	sleep(4)
	shell.run("linear/system/userScreen.ls")
   else 
    clear(1,1) 
	bCol(colors.red)
	cLine()
	pos(1,2)
	cLine()
	pos(1,1)
	centerPrint("Error")
	centerPrint("-----")
	bCol(colors.white)
	print("")
	print("Passwords do not match.")
	sleep(3)
	changePassword()
   end
  end
 end
 local function changeUsername()
  while true do
   bCol(colors.white)
   clear(1,1)
   drawBar("Change Username","back")
   pos(1,3)
   bCol(colors.white)
   tCol(colors.black)
   print("Choose a new username")
   print("('cancel' to return)")
   write("New: ")
   local newUser = read()
   write("Confirm: ")
   local cNewUser = read()
   
   if newUser == "cancel" then
    settingsProgram()
   end
   
   if newUser == cNewUser then
    if fs.exists("linear/system/userfolders/"..newUser) then
 	 clear(1,1) 
	 bCol(colors.red)
	 cLine()
	 pos(1,2)
	 cLine()
	 pos(1,1)
	 centerPrint("Error")
	 centerPrint("-----")
	 bCol(colors.white)
	 print("")
	 print("User already exists.")
	 sleep(3)
	else
	 fs.copy("linear/userfolders/"..user.getCurrent(), "linear/userfolders/"..newUser)
	 fs.delete("linear/userfolders/"..user.getCurrent())
	 user.setUsername(newUser)
	 clear(1,1)
	 bCol(colors.green)
	 cLine()
	 pos(1,2)
	 cLine()
	 pos(1,1)
	 centerPrint("Success")
	 centerPrint("-------")
	 bCol(colors.white)
	 print("")
	 print("You successfully changed your username to "..newUser..".")
	 print("You will now be logged out to the user screen")
	 sleep(5)
	 user.logOut()
	 shell.run("linear/system/userScreen.ls")
	end
	else
     clear(1,1) 
	 bCol(colors.red)
	 cLine()
	 pos(1,2)
	 cLine()
	 pos(1,1)
	 centerPrint("Error")
	 centerPrint("-----")
	 bCol(colors.white)
	 print("")
	 print("Usernames do not match.")
	 sleep(3)
	end
  end
 end
 local function userSettings()
  bCol(colors.white)
  clear(1,1)
  drawBar("User Settings","back")
  pos(1,3)
  bCol(colors.lightGray)
  print(" Change username     ")
  pos(1,5)
  print(" Change password     ")
  while true do
  local event, button, x, y = os.pullEventRaw()
  if event == "mouse_click" then 
   if x>1 and x<22 and y==3 and button==1 then
    changeUsername()
   elseif x>1 and x<22 and y==5 and button==1 then
    changePassword()
   elseif x>48 and x<52 and y==1 and button==1 then
   settingsProgram()
   else
   userSettings()
   end
 end
 end
 end
 local function userBackground()
  bCol(colors.white)
  clear(1,1)
  shell.run("paint linear/userfolders/"..user.getCurrent().."/imgs/desktopBg.lsg")
  settingsProgram()
 end
  
 --[[ Code ]]


 drawScreen()
 drawBar("Settings", "exit")

 pos(1,3)

 bCol(colors.lightGray)
 print(" User Settings       ")
 print("")
 print(" User Background     ")
 print("")
 print(" Menu Bar Colour     ")
 print("")
 print(" Computer Statistics ")
 print("")
 print(" Check for Updates   ")
 while true do 
 local event, button, x, y = os.pullEventRaw()
 if event == "mouse_click" then
  if x>1 and x<23 and y==3 and button==1 then
   userSettings()
   settingsProgram()
  elseif x>1 and x<23 and y==5 and button==1 then
   userBackground()
  elseif x>1 and x<23 and y==7 and button==1 then
   changeMenuBarC()
  elseif x>1 and x<23 and y==9 and button==1 then
   computerStatistics()
  elseif x>1 and x<23 and y==11 and button==1 then
   checkUpdates()
  elseif x>48 and x<52 and y==1 and button==1 then
   shell.run("linear/system/desktop.ls")
  else
  end
 end
 sleep(0.1)
 end
end


settingsProgram()

os.pullEvent = oldPull;