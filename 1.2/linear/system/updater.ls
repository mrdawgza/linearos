--[[ 
  LINEAR OS INSTALLER
       Details
Version: NA
DOR: NA
STABLE: NA
--]]
local ver = "1"
--[[ 
   Junk
terminal width 51
terminal height 19
--]]

function get(repo,saveTo)
 local response = http.get("https://raw.githubusercontent.com/mrdawgza/linearos/master/1.12/"..repo)
 local carry = response.readAll()
 response.close()
 local file = fs.open(saveTo,"w")
 file.write(carry)
 file.close()
end
local function centerPrint(msg)
 msgLen = string.len(msg)
 screenWidth,_ = term.getSize()
 xCoords = tonumber(math.ceil((screenWidth / 2) - (msgLen / 2)))
 _,termY = term.getCursorPos()
 term.setCursorPos(xCoords,termY)
 print(msg)
 return xCoords
end
local function cLine()
 term.clearLine()
end
local function clear(x,y)
 term.clear()
 term.setCursorPos(x,y)
end
local function pos(x,y)
 term.setCursorPos(x,y)
end
local function resetCol()
 term.setBackgroundColor(colors.black)
 term.setTextColor(colors.white)
end
local function tCol(color)
 term.setTextColor(color)
end
local function bCol(color)
 term.setBackgroundColor(color)
end
local function drawBar1()
 clear(1,1)
 term.setBackgroundColor(colors.gray)
 term.clearLine()
 
 term.setCursorPos(1,1)
 print("LINEAR OS Updater")
 pos(47,1)
 print("v1.1")
 resetCol()
end
local function install()
 local function pBar(var)
  bCol(colors.white)
  clear(1,7)
  bCol(colors.black)
  cLine()
  pos(1,8)
  bCol(colors.red)
  cLine()
  pos(1,9)
  cLine()
  pos(1,10)
  cLine()
  pos(1,11)
  bCol(colors.black)
  cLine()
  pos(1,9)
 end
 
 pBar()
 pos(1,8)
 bCol(colors.green)
 print("         ")
 print("         ")
 print("         ")
 get("startup","startup")
 pos(1,8)
 print("          ")
 print("          ")
 print("          ")
 get("linear/system/appStore.ls","linear/system/appStore.ls")
 pos(1,8)
 print("            ")
 print("            ")
 print("            ")
 get("linear/system/desktop.ls","linear/system/desktop.ls")
 pos(1,8)
 print("              ")
 print("              ")
 print("              ")
 get("linear/system/fileBrowser.ls","linear/system/fileBrowser.ls")
 pos(1,8)
 print("               ")
 print("               ")
 print("               ")
 get("linear/system/loados.ls","linear/system/loados.ls")
 pos(1,8)
 print("                 ")
 print("                 ")
 print("                 ")
 get("linear/system/programManager.ls","linear/system/programManager.ls")
 pos(1,8)
 print("                   ")
 print("                   ")
 print("                   ")
 get("linear/system/settings.ls","linear/system/settings.ls")
 pos(1,8)
 print("                     ")
 print("                     ")
 print("                     ")
 get("linear/system/userScreen.ls","linear/system/userScreen.ls")
 pos(1,8)
 print("                       ")
 print("                       ")
 print("                       ")
 get("linear/system/imgs/bootScreen.lsg","linear/system/imgs/bootScreen.lsg")
 pos(1,8)
 print("                         ")
 print("                         ")
 print("                         ")
 get("linear/system/imgs/defaultBg.lsg","linear/system/imgs/defaultBg.lsg")
 pos(1,8)
 print("                           ")
 print("                           ")
 print("                           ")
 get("linear/system/imgs/logo.lsg","linear/system/imgs/logo.lsg")
 pos(1,8)
 print("                            ")
 print("                            ")
 print("                            ")
 get("linear/system/apis/centerPrint.ls","linear/system/apis/centerPrint.ls")
 pos(1,8)
 print("                             ")
 print("                             ")
 print("                             ")
 get("linear/system/apis/sha256.ls","linear/system/apis/sha256.ls")
 pos(1,8)
 print("                               ")
 print("                               ")
 print("                               ")
 get("linear/system/apis/term.ls","linear/system/apis/term.ls")
 pos(1,8)
 print("                                 ")
 print("                                 ")
 print("                                 ")
 get("linear/system/apis/user.ls","linear/system/apis/user.ls")
 bCol(colors.white)
 clear(1,8)
 tCol(colors.black)
 centerPrint("Update Complete")
 sleep(0.8)
 pos(1,10)
 centerPrint("Press any key to reboot")
 os.pullEvent("key")
 os.reboot()
end


local function drawButtons1()
 pos(1,6)
 bCol(colors.green)
 print("                        ")
 print("        Install         ")
 print("                        ")
 bCol(colors.lightGray)
 pos(25,6)
 print("Download and update   ")
 pos(25,7)
 print("Linear OS from Github.")
 
 pos(1,11)
 bCol(colors.red)
 print("                        ")
 print("        Cancel          ")
 print("                        ")
 bCol(colors.lightGray)
 pos(25,11)
 print("Cancel and quit the  ")
 pos(25,12)
 print("software update.     ")
 pos(1,15)
 
 while true do
  local event, button, x, y = os.pullEventRaw()
  if event == "mouse_click" then
   if x>1 and x<25 and y>5 and y<9 and button==1 then
     install()
    elseif x>1 and x<25 and y>10 and y<15 and button==1 then
     bCol(colors.black)
     clear(1,1)
   end
  end
 end
end

drawBar1()
drawButtons1()


