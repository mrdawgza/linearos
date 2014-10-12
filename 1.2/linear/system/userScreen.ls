--[[
   Linear Operating System
       Users Screen
--]]
--[[ 
   Junk
terminal width 51
terminal height 19
--]]



local function main()
user.logOut()
local function login()
 clear(1,1)
 centerPrint("Login to Linear OS")
 centerPrint("------------------")
 print("")
 print("Username: ")
 print("Password: ")
 pos(10,4)
 write("")
 username = read()
 pos(10,5)
 write("")
 local password = read("*")
 if user.logIn(username, password) then
  clear(1,8)
  centerPrint("Welcome to Linear OS,")
  centerPrint(username..".")
  sleep(2)
  shell.run("linear/system/desktop.ls")
 else
  clear(1,1)
  bCol(colors.red)
  cLine()
  pos(1,2)
  cLine()
  pos(1,1)
  centerPrint("ERROR")
  centerPrint("-----")
  bCol(colors.white)
  print("")
  print("Wrong username or password!")
  sleep(2)
  main()
 end
end

local function listUsers()
 clear(1,1)
 centerPrint("Linear OS Users -BETA")
 centerPrint("---------------")
 user.listUsers()
 print("")
 print("Press any key to return.")
 os.pullEvent("key") 
 main()
end

local function register()
 local function register1()
  clear(1,1)
  centerPrint("Please provide")
  centerPrint("--------------")
  pos(1,4)
  print("Username:")
  print("Password: ")
  print("Confirm Password: ")
  pos(11,4)
  write("")
  local regUser = read()
  pos(11,5)
  write("")
  local regPass = read("*")
  pos(19,6)
  write("")
  local regPassConf = read("*")
  if regUser == "" then
   bCol(colors.white)
   clear(1,1)
   bCol(colors.red)
   centerPrint("Error")
   centerPrint("-----")
   bCol(colors.white)
   print("")
   print("You cannot leave the username blank.")
  end
  if regPass == regPassConf then
	clear(1,3)
	centerPrint("Linear OS Registration")
	centerPrint("----------------------")
	print("Saving details...")
	fs.copy("linear/system/imgs/defaultBg.lsg", "linear/userfolders/"..regUser.."/imgs/desktopBg.lsg")
	user.register(regUser, regPass)
	print("User "..regUser.." created!")
	print("Returning to login screen.")
	sleep(3)
	main()
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
	print("Your passwords did not match.")
	print("Press any key to retry.")
	os.pullEvent("key")
	register1()
 end
 end
 
 bCol(colors.white)
 tCol(colors.black)
 clear(1,1)
 centerPrint("Linear OS User Registration")
 centerPrint("---------------------------")
 pos(1,4)
 print("Password is hashed with sha256; we still recommend")
 print("that you do not use a personal password (such as")
 print("your Minecraft account password if playing on a")
 print("server). If you want to turn back during your")
 print("registration, just hold CTRL+R to reboot the")
 print("computer.")
 pos(1,13)
 bCol(colors.green)
 centerPrint("          ")
 centerPrint(" Continue ")
 centerPrint("          ")
 bCol(colors.red)
 centerPrint("  Cancel  ")
 bCol(colors.white)
 while true do
 local event, button, x, y = os.pullEvent()
 if event == "mouse_click" then
  if x>20 and x<31 and y>12 and y<16 and button==1 then
   register1()
  elseif x>20 and x<31 and y==16 and button==1 then
   main()
  end
 end
 sleep(0.2)
 end
end

bCol(colors.white)
tCol(colors.black)
clear(1,1)

bCol(colors.green)
pos(12,8)
print("          ")
pos(12,9)
print("  Login   ")
pos(12,10)
print("          ")

pos(11,10)
bCol(colors.gray)
print("?")
bCol(colors.white)

bCol(colors.cyan)
pos(32,8)
print("          ")
pos(32,9)
print(" Register ")
pos(32,10)
print("          ")

pos(1,3)
bCol(colors.white)
centerPrint(" Welcome to ")
centerPrint(" Linear Operating System")

pos(1,18)
print("(C)Linear Systems")
pos(41,18)
print("      v1.0")

pos(22,9)
bCol(colors.red)
print(" Shutdown ")
bCol(colors.white)

while true do
local event, button, x, y = os.pullEvent()
 if event == "mouse_click" then
  if x>12 and x<22 and y>7 and y<11 and button==1 then 
   login()
  elseif x>31 and x<42 and y>7 and y<11 and button ==1 then
   register()
  elseif x>21 and x<32 and y==9 and button ==1 then
   os.shutdown()
  elseif x==11 and y==10 and button==1 then
   listUsers()
  break
  else
  end
  sleep(0.2)
 end
end

end

main()

