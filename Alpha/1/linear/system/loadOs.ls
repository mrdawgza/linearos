term.clear()
term.setCursorPos(1,1)

w, h = term.getSize()
systemPath = "linear/system/"
usersPath = "linear/userfolders/"

os.loadAPI("linear/system/apis/NovaUI")
print("apis/NovaUI.ls")
shell.run("linear/system/apis/sha256.ls")
print("apis/sha256.ls")
shell.run("linear/system/apis/user.ls")
print("apis/user.ls")

runningPrograms = {}


print("load completed")

sleep(0.1)

shell.run(systemPath.."userLogin.ls")