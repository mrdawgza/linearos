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
 local file = fs.open("userList", "w")
 file.write(textutils.serialize(userList))
 file.close()
end

function user.saveUserList()
local file = fs.open("userList", "w")
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
 return result
end

function user.register(regUser, newPass)
 if userList[regUser] then
  return false
 else
  userList[regUser] = sha256(newPass)
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
