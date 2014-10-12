
--[[
   Linear Operating System
           Loader
--]]

--[[ 
   Junk
terminal width 51
terminal height 19
--]]

local oldPull = os.pullEvent;
os.pullEvent = os.pullEventRaw;

term.clear()
term.setCursorPos(1,1)
term.setBackgroundColor(colors.white)
term.clear()

term.setBackgroundColor(colors.black)
term.setCursorPos(1,14)
term.clearLine()
term.setCursorPos(1,15)
term.setBackgroundColor(colors.red)
term.clearLine()
term.setCursorPos(1,16)
term.setBackgroundColor(colors.red)
term.clearLine()
term.setCursorPos(1,17)
term.setBackgroundColor(colors.black)
term.clearLine()

if fs.exists("linear/system/userList.ls") then
 term.setCursorPos(1,13)
 term.setBackgroundColor(colors.white)
 term.setTextColor(colors.black)
 print("system/userList.ls")
 term.setCursorPos(1,15)
 term.setBackgroundColor(colors.green)
 print("     ")
 print("     ")
 term.setCursorPos(1,13)
 term.setBackgroundColor(colors.white)
 term.clearLine()
else
 local uList = fs.open("linear/system/userList.ls", "w")
 uList.write("{}")
 uList.close()
 term.setCursorPos(1,13)
 term.setBackgroundColor(colors.white)
 term.setTextColor(colors.black)
 print("system/userList.ls")
 term.setCursorPos(1,15)
 term.setBackgroundColor(colors.green)
 print("     ")
 print("     ")
 term.setCursorPos(1,13)
 term.setBackgroundColor(colors.white)
 term.clearLine()
end

shell.run("linear/system/apis/term.ls")
term.setCursorPos(1,13)
term.setBackgroundColor(colors.white)
term.setTextColor(colors.black)
print("apis/term.ls")
term.setCursorPos(1,15)
term.setBackgroundColor(colors.green)
print("     ")
print("     ")
term.setCursorPos(1,13)
term.setBackgroundColor(colors.white)
term.clearLine()

shell.run("linear/system/apis/centerPrint.ls")
term.setCursorPos(1,13)
term.setBackgroundColor(colors.white)
term.setTextColor(colors.black)
print("apis/centerPrint.ls")
term.setCursorPos(1,15)
term.setBackgroundColor(colors.green)
print("             ")
print("             ")

term.setCursorPos(1,13)
term.setBackgroundColor(colors.white)
term.clearLine()


shell.run("linear/system/apis/sha256.ls")
term.setCursorPos(1,13)
term.setBackgroundColor(colors.white)
term.setTextColor(colors.black)
print("apis/sha256.ls")
term.setCursorPos(1,15)
term.setBackgroundColor(colors.green)
print("                         ")
print("                         ")

term.setCursorPos(1,13)
term.setBackgroundColor(colors.white)
term.clearLine()


user = {}
local file = fs.open("linear/system/userList.ls", "r")
local userList = textutils.unserialize(file.readAll())
file.close()
local currentUser = false
function user.getCurrent()
 return currentUser
end
function user.logIn(username, password)
 if currentUser then
  return false
 else
  if userList[username] == sha256(password) then
   currentUser = username
   return true
  else
   return false
  end
 end
end
function user.logOut()
 if currentUser then
  currentUser = false
  return true
 else
  return false
 end
end
local function saveUserList()
 local file = fs.open("linear/system/userList.ls", "w")
 file.write(textutils.serialize(userList))
 file.close()
end
function user.saveUserList()
local file = fs.open("linear/system/userList.ls", "w")
 file.write(textutils.serialize(userList))
 file.close()
end
function user.setUsername(username)
 userList[username] = userList[currentUser]
 userList[currentUser] = nil
 saveUserList()
 currentUser = username
end
function user.setPassword(password)
 userList[currentUser] = sha256(password)
 saveUserList()
end
function user.listUsers()
 local result = {}
 for key in pairs(userList) do table.insert(result, key) end
 local list = textutils.serialize(result)
 print(list)
 return result
end
function user.register(username, password)
 if userList[username] then
  return false
 else
  userList[username] = sha256(password)
  saveUserList()
  return true
 end
end
function user.unregister(currentUser)
 if userList[username] then
  userList[username] = nil
  saveUserList()
  return true
 else
  return false
 end
end
term.setCursorPos(1,13)
term.setBackgroundColor(colors.white)
term.setTextColor(colors.black)
print("apis/user.api")
term.setCursorPos(1,15)
term.setBackgroundColor(colors.green)
print("                                                    ")
print("                                                    ")

term.setCursorPos(1,13)
term.setBackgroundColor(colors.white)
term.clearLine()

if fs.exists("linear/system/config.ls") then
  sleep(0.2)
  shell.run("linear/system/userScreen.ls")
 else
  clear(1,1)
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
    automaticUpdates = true
   else
    automaticUpdates = false
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
  if automaticUpdates == true then
    centerPrint("Automatic updates are enabled")
	centerPrint("Automatic updates are NOT implemented yet.")
   elseif automaticUpdates == false then
    centerPrint("Automatic updates are disabled")
	centerPrint("Automatic updates are NOT implemented yet.")
  end
  centerPrint("Computername: "..computerName)
  sleep(2)
  print("")
  centerPrint("Computer will now restart.")
  sleep(1)
  os.reboot()
end

os.pullEvent = oldPull;
  
  