local oldPull = os.pullEvent;
os.pullEvent = os.pullEventRaw;

local function programManager()
        local function uninstall()
                local function uninstallBar()
                        term.clear()
                        term.setCursorPos(1,1)
                        term.setBackgroundColor(2)
                        term.clearLine()
                        term.setTextColor(1)
                        print("Uninstall")
                        term.setCursorPos(49,1)
                        term.setBackgroundColor(16384)
                        print("(X)")
                        term.setBackgroundColor(colors.orange)
                end
                 
                local ProgramFolder = "linear/programs/"
                local Program = fs.list(ProgramFolder)
                 
                for i=1,#Program do
                        term.setBackgroundColor(colors.black)
                        term.clear()
                        uninstallBar()
                        term.setBackgroundColor(colors.black)
                        term.setCursorPos(1,i+1)
                        print(Program[i])
                        term.setBackgroundColor(colors.orange)
                end
                 
                while true do
                        local event, button, X, Y = os.pullEvent()
                        if event == "mouse_click" and button == 1 then
                                for i=1,#Program do
                                        if X>=0 and X<=#Program[i] and Y == i+1 then
                                                fs.delete(ProgramFolder..Program[i])           
                                                print("Successfully deleted ")
                                                sleep(1)
                                                programManager()
                                        elseif X>=45 and X<=51 and Y == 1 and button == 1 then
                                                programManager()
                                        end
                                end
                        end
                end
        end
                 
        local function install()
		        bCol(colors.gray)
                term.clear()
                term.setCursorPos(1,1)
                term.setBackgroundColor(menuBarC)
                term.clearLine()
                term.setTextColor(1)
                print("Install")
                term.setBackgroundColor(colors.gray)
                print("Currently, you have to use Pastebin to install a program.")
                print("Type 'cancel' for ID to go back")
				print("*No spaces (Use underscores for spaces (_))")
                write("Pastebin ID: ")
                local pid = read()
                 
                if pid == "cancel" then
                        programManager()
                else
                        write("Install as: ")
                        local ito = read()
                         
                        if shell.run("pastebin get "..pid.." linear/programs/"..ito) then
                                print("Successful!")
                                sleep(2)
                                programManager()
                        else
                                print("Unsuccessful.")
                                sleep(2)
                                programManager()
                        end
                end
        end
 
        term.setBackgroundColor(colors.white)
        term.clear()
        term.setCursorPos(1,1)
        term.setBackgroundColor(menuBarC)
        term.setTextColor(colors.black)
        term.setCursorPos(1,1)
        term.clearLine()
        print("Programs |          |             |")
        term.setCursorPos(11,1)
        term.setBackgroundColor(8192)
        print(" Install ")
        term.setCursorPos(23,1)
        term.setBackgroundColor(16384)
        print(" Uninstall ")
        term.setCursorPos(49,1)
        term.setBackgroundColor(16384)
        print("(X)")
 
        term.setCursorPos(1,3)
        term.setBackgroundColor(colors.red)
 
        local ProgramFolder = "linear/programs/"
        local Program = fs.list(ProgramFolder)
 
        for i=1,#Program do
                term.setCursorPos(1,i+1)
				bCol(colors.white)
				tCol(colors.black)
                print(Program[i])
        end
 
 
        while true do
                local event, button, X, Y = os.pullEvent()
                if event == "mouse_click" and button == 1 then
                        local clickedaprogram = false
                        for i=1,#Program do
                                if X>=0 and X<=#Program[i] and Y == i+1 then
                                        shell.run(ProgramFolder..Program[i])
                                        clickedaprogram = true
										programManager()
                                end
                        end
                        if not clickedaprogram then
                                if X>=48 and X<=51 and Y == 1 and button == 1 then
                                        shell.run("linear/system/desktop.ls")
                                elseif X>=11 and X<=20 and Y ==1 and button == 1 then
                                        install()
                                elseif X>=23 and X<=34 and Y ==1 and button == 1 then
                                        uninstall()
                                end
                        end
                end
        end
end
 
programManager()

os.pullEvent = oldPull;