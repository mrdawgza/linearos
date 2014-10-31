
--[[
   Linear Operating System
           Loader
--]]

local bootImage = paintutils.loadImage("linear/system/imgs/bootScreen.lsg")
paintutils.drawImage(bootImage, 2,1)

if fs.exists("linear/system/userList.ls") then
else
 local uList = fs.open("linear/system/userList.ls", "w")
 uList.write("{}")
 uList.close()
end

local function checkSystem(file)
 if fs.exists("linear/system/"..file..".ls") then
   problem = true
  else
   noProblem = true
 end
 if noProblem then
   term.setBackgroundColor(colors.blue)
   term.clear()
   term.setCursorPos(1,1)
   term.setTextColor(colors.black)
   print("Error")
   print("-----")
   print("One or more system files are missing!")
   print("Problem file: "..file)
   print("Make sure the file is there.")
   print("File names are case sensitive.")
   print("If you cannot fix this problem, reinstall LinearOS with the intstaller.")
   print("Press any key to run Shell.")
   os.pullEvent("key")
   shell.run("shell")
  elseif noProblem then
  
 end
end

checkSystem("appStore")
checkSystem("desktop")
checkSystem("fileBrowser")
checkSystem("loados")
checkSystem("programManager")
checkSystem("settings")
checkSystem("userScreen")

shell.run("linear/system/apis/term.ls")
shell.run("linear/system/apis/centerPrint.ls")
shell.run("linear/system/apis/sha256.ls")
shell.run("linear/system/apis/user.ls")
sleep(0.4)
bCol(colors.white)
tCol(colors.black)
clear(1,1)


if fs.exists("linear/system/config.ls") then
  local handle = assert(fs.open("linear/system/config.ls", "r"), "Failed to load configuration")
  local input = handle.readAll()
  handle.close()
  local mainConf = textutils.unserialize(input)
  aUpdate = mainConf.autoUpdate
  if aUpdate == "enabled" then
    print("Checking for updates...")
	local latestVersionRaw = http.get("http://pastebin.com/raw.php?i=ppQG9UT9")
    local latestVersion = latestVersionRaw.readAll()
    latestVersionRaw.close()
	if latestVersion == version then 
	 else
	  print("Initiating update.")
	  clear(1,1)
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
	  centerPrint("Resume boot")
	  bCol(colors.white)
	  latestVersion = nil
	  while true do
       local event, button, x, y = os.pullEventRaw()
       if event == "mouse_click" then
        if x>1 and x<52 and y==11 and button==1 then
	      shell.run("pastebin get AkkBY0yS linear/system/updater.ls")
		  shell.run("linear/system/updater.ls")
         elseif x>1 and x<52 and y==12 and button==1 then
          break
        else
        end
       end
      end
	  end
   else
    print("Automatic updates are disabled.")
  end 
  sleep(0.2)
  shell.run("linear/system/userScreen.ls")
 else
  clear(1,5)
  centerPrint("Welcome to Linear Operating System")
  print("")
  centerPrint("Since this is the first time you are running")
  centerPrint("Linear OS, we need you to enter a few details.")
  print("")
  centerPrint("Press any key to continue.")
  os.pullEvent("key")
  clear(1,1)
  centerPrint("Configuration")
  centerPrint("-------------")
  print("")
  print("Automatic Updates (y/n):")
  print("Computer Name: ")
  pos(25,4)
  write("")
  local autoUpdates = read()
  if autoUpdates == "y" then
    automaticUpdates = "enabled"
   else
    automaticUpdates = "disabled"
  end
  pos(16,5)
  write("")
  local computerName = read()
  os.setComputerLabel(computerName)
  local config = {}
  config.autoUpdate = automaticUpdates
  local saveConfig = textutils.serialize(config)
  local configHandle = assert(fs.open("linear/system/config.ls", "w"), "Couldn't save config")
  configHandle.write(saveConfig)
  configHandle.close()
  clear(1,1)
  centerPrint("Done!")
  print("")
  print("")
  centerPrint("You're done!")
  print("")
  if automaticUpdates == "enabled" then
    centerPrint("Automatic updates are enabled")
   elseif automaticUpdates == "disabled" then
    centerPrint("Automatic updates are disabled")
  end
  centerPrint("Computername: "..computerName)
  sleep(2)
  print("")
  centerPrint("Computer will now restart.")
  sleep(1)
  os.reboot()
end
