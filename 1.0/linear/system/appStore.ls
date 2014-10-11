local _jstr = [[
        local base = _G
 
        -----------------------------------------------------------------------------
        -- Module declaration
        -----------------------------------------------------------------------------
 
        -- Public functions
 
        -- Private functions
        local decode_scanArray
        local decode_scanComment
        local decode_scanConstant
        local decode_scanNumber
        local decode_scanObject
        local decode_scanString
        local decode_scanWhitespace
        local encodeString
        local isArray
        local isEncodable
 
        -----------------------------------------------------------------------------
        -- PUBLIC FUNCTIONS
        -----------------------------------------------------------------------------
        --- Encodes an arbitrary Lua object / variable.
        -- @param v The Lua object / variable to be JSON encoded.
        -- @return String containing the JSON encoding in internal Lua string format (i.e. not unicode)
        function encode (v)
          -- Handle nil values
          if v==nil then
            return "null"
          end
         
          local vtype = base.type(v)  
 
          -- Handle strings
          if vtype=='string' then    
            return '"' .. encodeString(v) .. '"'      -- Need to handle encoding in string
          end
         
          -- Handle booleans
          if vtype=='number' or vtype=='boolean' then
            return base.tostring(v)
          end
         
          -- Handle tables
          if vtype=='table' then
            local rval = {}
            -- Consider arrays separately
            local bArray, maxCount = isArray(v)
            if bArray then
              for i = 1,maxCount do
                table.insert(rval, encode(v[i]))
              end
            else -- An object, not an array
              for i,j in base.pairs(v) do
                if isEncodable(i) and isEncodable(j) then
                  table.insert(rval, '"' .. encodeString(i) .. '":' .. encode(j))
                end
              end
            end
            if bArray then
              return '[' .. table.concat(rval,',') ..']'
            else
              return '{' .. table.concat(rval,',') .. '}'
            end
          end
         
          -- Handle null values
          if vtype=='function' and v==null then
            return 'null'
          end
         
          base.assert(false,'encode attempt to encode unsupported type ' .. vtype .. ':' .. base.tostring(v))
        end
 
 
        --- Decodes a JSON string and returns the decoded value as a Lua data structure / value.
        -- @param s The string to scan.
        -- @param [startPos] Optional starting position where the JSON string is located. Defaults to 1.
        -- @param Lua object, number The object that was scanned, as a Lua table / string / number / boolean or nil,
        -- and the position of the first character after
        -- the scanned JSON object.
        function decode(s, startPos)
          startPos = startPos and startPos or 1
          startPos = decode_scanWhitespace(s,startPos)
          base.assert(startPos<=string.len(s), 'Unterminated JSON encoded object found at position in [' .. s .. ']')
          local curChar = string.sub(s,startPos,startPos)
          -- Object
          if curChar=='{' then
            return decode_scanObject(s,startPos)
          end
          -- Array
          if curChar=='[' then
            return decode_scanArray(s,startPos)
          end
          -- Number
          if string.find("+-0123456789.e", curChar, 1, true) then
            return decode_scanNumber(s,startPos)
          end
          -- String
          if curChar=='"' or curChar=="'" then
            return decode_scanString(s,startPos)
          end
          if string.sub(s,startPos,startPos+1)=='/*' then
            return decode(s, decode_scanComment(s,startPos))
          end
          -- Otherwise, it must be a constant
          return decode_scanConstant(s,startPos)
        end
 
        --- The null function allows one to specify a null value in an associative array (which is otherwise
        -- discarded if you set the value with 'nil' in Lua. Simply set t = { first=json.null }
        function null()
          return null -- so json.null() will also return null ;-)
        end
        -----------------------------------------------------------------------------
        -- Internal, PRIVATE functions.
        -- Following a Python-like convention, I have prefixed all these 'PRIVATE'
        -- functions with an underscore.
        -----------------------------------------------------------------------------
 
        --- Scans an array from JSON into a Lua object
        -- startPos begins at the start of the array.
        -- Returns the array and the next starting position
        -- @param s The string being scanned.
        -- @param startPos The starting position for the scan.
        -- @return table, int The scanned array as a table, and the position of the next character to scan.
        function decode_scanArray(s,startPos)
          local array = {}   -- The return value
          local stringLen = string.len(s)
          base.assert(string.sub(s,startPos,startPos)=='[','decode_scanArray called but array does not start at position ' .. startPos .. ' in string:\n'..s )
          startPos = startPos + 1
          -- Infinite loop for array elements
          repeat
            startPos = decode_scanWhitespace(s,startPos)
            base.assert(startPos<=stringLen,'JSON String ended unexpectedly scanning array.')
            local curChar = string.sub(s,startPos,startPos)
            if (curChar==']') then
              return array, startPos+1
            end
            if (curChar==',') then
              startPos = decode_scanWhitespace(s,startPos+1)
            end
            base.assert(startPos<=stringLen, 'JSON String ended unexpectedly scanning array.')
            object, startPos = decode(s,startPos)
            table.insert(array,object)
          until false
        end
 
        --- Scans a comment and discards the comment.
        -- Returns the position of the next character following the comment.
        -- @param string s The JSON string to scan.
        -- @param int startPos The starting position of the comment
        function decode_scanComment(s, startPos)
          base.assert( string.sub(s,startPos,startPos+1)=='/*', "decode_scanComment called but comment does not start at position " .. startPos)
          local endPos = string.find(s,'*/',startPos+2)
          base.assert(endPos~=nil, "Unterminated comment in string at " .. startPos)
          return endPos+2  
        end
 
        --- Scans for given constants: true, false or null
        -- Returns the appropriate Lua type, and the position of the next character to read.
        -- @param s The string being scanned.
        -- @param startPos The position in the string at which to start scanning.
        -- @return object, int The object (true, false or nil) and the position at which the next character should be
        -- scanned.
        function decode_scanConstant(s, startPos)
          local consts = { ["true"] = true, ["false"] = false, ["null"] = nil }
          local constNames = {"true","false","null"}
 
          for i,k in base.pairs(constNames) do
            --print ("[" .. string.sub(s,startPos, startPos + string.len(k) -1) .."]", k)
            if string.sub(s,startPos, startPos + string.len(k) -1 )==k then
              return consts[k], startPos + string.len(k)
            end
          end
          base.assert(nil, 'Failed to scan constant from string ' .. s .. ' at starting position ' .. startPos)
        end
 
        --- Scans a number from the JSON encoded string.
        -- (in fact, also is able to scan numeric +- eqns, which is not
        -- in the JSON spec.)
        -- Returns the number, and the position of the next character
        -- after the number.
        -- @param s The string being scanned.
        -- @param startPos The position at which to start scanning.
        -- @return number, int The extracted number and the position of the next character to scan.
        function decode_scanNumber(s,startPos)
          local endPos = startPos+1
          local stringLen = string.len(s)
          local acceptableChars = "+-0123456789.e"
          while (string.find(acceptableChars, string.sub(s,endPos,endPos), 1, true)
           and endPos<=stringLen
           ) do
            endPos = endPos + 1
          end
          local stringValue = 'return ' .. string.sub(s,startPos, endPos-1)
          local stringEval = base.loadstring(stringValue)
          base.assert(stringEval, 'Failed to scan number [ ' .. stringValue .. '] in JSON string at position ' .. startPos .. ' : ' .. endPos)
          return stringEval(), endPos
        end
 
        --- Scans a JSON object into a Lua object.
        -- startPos begins at the start of the object.
        -- Returns the object and the next starting position.
        -- @param s The string being scanned.
        -- @param startPos The starting position of the scan.
        -- @return table, int The scanned object as a table and the position of the next character to scan.
        function decode_scanObject(s,startPos)
          local object = {}
          local stringLen = string.len(s)
          local key, value
          base.assert(string.sub(s,startPos,startPos)=='{','decode_scanObject called but object does not start at position ' .. startPos .. ' in string:\n' .. s)
          startPos = startPos + 1
          repeat
            startPos = decode_scanWhitespace(s,startPos)
            base.assert(startPos<=stringLen, 'JSON string ended unexpectedly while scanning object.')
            local curChar = string.sub(s,startPos,startPos)
            if (curChar=='}') then
              return object,startPos+1
            end
            if (curChar==',') then
              startPos = decode_scanWhitespace(s,startPos+1)
            end
            base.assert(startPos<=stringLen, 'JSON string ended unexpectedly scanning object.')
            -- Scan the key
            key, startPos = decode(s,startPos)
            base.assert(startPos<=stringLen, 'JSON string ended unexpectedly searching for value of key ' .. key)
            startPos = decode_scanWhitespace(s,startPos)
            base.assert(startPos<=stringLen, 'JSON string ended unexpectedly searching for value of key ' .. key)
            base.assert(string.sub(s,startPos,startPos)==':','JSON object key-value assignment mal-formed at ' .. startPos)
            startPos = decode_scanWhitespace(s,startPos+1)
            base.assert(startPos<=stringLen, 'JSON string ended unexpectedly searching for value of key ' .. key)
            value, startPos = decode(s,startPos)
            object[key]=value
          until false  -- infinite loop while key-value pairs are found
        end
 
        --- Scans a JSON string from the opening inverted comma or single quote to the
        -- end of the string.
        -- Returns the string extracted as a Lua string,
        -- and the position of the next non-string character
        -- (after the closing inverted comma or single quote).
        -- @param s The string being scanned.
        -- @param startPos The starting position of the scan.
        -- @return string, int The extracted string as a Lua string, and the next character to parse.
        function decode_scanString(s,startPos)
          base.assert(startPos, 'decode_scanString(..) called without start position')
          local startChar = string.sub(s,startPos,startPos)
          base.assert(startChar=="'" or startChar=='"','decode_scanString called for a non-string')
          local escaped = false
          local endPos = startPos + 1
          local bEnded = false
          local stringLen = string.len(s)
          repeat
            local curChar = string.sub(s,endPos,endPos)
            -- Character escaping is only used to escape the string delimiters
            if not escaped then
              if curChar=='\\' then
                escaped = true
              else
                bEnded = curChar==startChar
              end
            else
              -- If we're escaped, we accept the current character come what may
              escaped = false
            end
            endPos = endPos + 1
            base.assert(endPos <= stringLen+1, "String decoding failed: unterminated string at position " .. endPos)
          until bEnded
          local stringValue = 'return ' .. string.sub(s, startPos, endPos-1)
          local stringEval = base.loadstring(stringValue)
          base.assert(stringEval, 'Failed to load string [ ' .. stringValue .. '] in JSON4Lua.decode_scanString at position ' .. startPos .. ' : ' .. endPos)
          return stringEval(), endPos  
        end
 
        --- Scans a JSON string skipping all whitespace from the current start position.
        -- Returns the position of the first non-whitespace character, or nil if the whole end of string is reached.
        -- @param s The string being scanned
        -- @param startPos The starting position where we should begin removing whitespace.
        -- @return int The first position where non-whitespace was encountered, or string.len(s)+1 if the end of string
        -- was reached.
        function decode_scanWhitespace(s,startPos)
          local whitespace=" \n\r\t"
          local stringLen = string.len(s)
          while ( string.find(whitespace, string.sub(s,startPos,startPos), 1, true)  and startPos <= stringLen) do
            startPos = startPos + 1
          end
          return startPos
        end
 
        --- Encodes a string to be JSON-compatible.
        -- This just involves back-quoting inverted commas, back-quotes and newlines, I think ;-)
        -- @param s The string to return as a JSON encoded (i.e. backquoted string)
        -- @return The string appropriately escaped.
        function encodeString(s)
          s = string.gsub(s,'\\','\\\\')
          s = string.gsub(s,'"','\\"')
          s = string.gsub(s,"'","\\'")
          s = string.gsub(s,'\n','\\n')
          s = string.gsub(s,'\t','\\t')
          return s
        end
 
        -- Determines whether the given Lua type is an array or a table / dictionary.
        -- We consider any table an array if it has indexes 1..n for its n items, and no
        -- other data in the table.
        -- I think this method is currently a little 'flaky', but can't think of a good way around it yet...
        -- @param t The table to evaluate as an array
        -- @return boolean, number True if the table can be represented as an array, false otherwise. If true,
        -- the second returned value is the maximum
        -- number of indexed elements in the array.
        function isArray(t)
          -- Next we count all the elements, ensuring that any non-indexed elements are not-encodable
          -- (with the possible exception of 'n')
          local maxIndex = 0
          for k,v in base.pairs(t) do
            if (base.type(k)=='number' and math.floor(k)==k and 1<=k) then   -- k,v is an indexed pair
              if (not isEncodable(v)) then return false end   -- All array elements must be encodable
              maxIndex = math.max(maxIndex,k)
            else
              if (k=='n') then
                if v ~= table.getn(t) then return false end  -- False if n does not hold the number of elements
              else -- Else of (k=='n')
                if isEncodable(v) then return false end
              end  -- End of (k~='n')
            end -- End of k,v not an indexed pair
          end  -- End of loop across all pairs
          return true, maxIndex
        end
 
        --- Determines whether the given Lua object / table / variable can be JSON encoded. The only
        -- types that are JSON encodable are: string, boolean, number, nil, table and json.null.
        -- In this implementation, all other types are ignored.
        -- @param o The object to examine.
        -- @return boolean True if the object should be JSON encoded, false if it should be ignored.
        function isEncodable(o)
          local t = base.type(o)
          return (t=='string' or t=='boolean' or t=='number' or t=='nil' or t=='table') or (t=='function' and o==null)
        end
]]
 
local _api = [[

  local function contains(table, element)
    for _, value in pairs(table) do
      if value == element then
        return true
      end
    end
    return false
  end

  local apiURL = "http://ccappstore.com/api/"

  local function checkHTTP()
    if http then
      return true
    else
      return false
    end
  end

  local function requireHTTP()
    if checkHTTP() then
      return true
    else
      error("The 'http' API is not enabled!")
    end
  end

  function doRequest(command, subcommand, values)
    values = values or {}
    requireHTTP()

    local url = apiURL .. "?command=" .. command .."&subcommand=" .. subcommand
    for k, v in pairs(values) do
      url = url .. "&" .. k .. "=" .. v
    end
    local request = http.get(url)
    if request then
      local response = request.readAll()
      request.close()
      if response == "<h2>The server is too busy at the moment.</h2><p>Please reload this page few seconds later.</p>" then
        error("Server is too busy at the moment.")
      end
      return textutils.unserialize(response)
    end
    return nil
  end

  function getAllApplications()
    return doRequest('application', 'all')
  end

  function getTopCharts()
    return doRequest('application', 'topcharts')
  end

  function getApplicationsInCategory(name)
    return doRequest('application', 'category', {name = name})
  end

  function getFeaturedApplications()
    return doRequest('application', 'featured')
  end

  function getApplication(id)
    return doRequest('application', 'get', {id = id})
  end

  function getCategories(id)
    return doRequest('application', 'categories')
  end

  function addApplication(username, password, serializeddata, name, description, sdescription, category)
    return doRequest('application', 'add', {username = username, password = password, serializeddata = serializeddata, name = name, description = description, sdescription = sdescription, category = category})
  end

  function addChangeLogToApplication(id, username, password, changelog, version)
    return doRequest('application', 'addchangelog', {id = id, username = username, password = password, changelog = changelog, version = version})
  end

  function downloadApplication(id)
    return doRequest('application', 'download', {id = id})
  end

  function searchApplications(name)
    return doRequest('application', 'search', {name = name})
  end

  function getAllNews()
    return doRequest('news', 'all')
  end

  function getNews(id)
    return doRequest('news', 'get', {id = id})
  end

  function getInstalledApplications(id)
    return doRequest('computer', 'get', {id = id})
  end

  local function resolve( _sPath )
    local sStartChar = string.sub( _sPath, 1, 1 )
    if sStartChar == "/" or sStartChar == "\\" then
      return fs.combine( "", _sPath )
    else
      return fs.combine( sDir, _sPath )
    end
  end

  function saveApplicationIcon(id, path)
    local app = getApplication(id)
    local icon = app.icon
    local _fs = fs
    if OneOS then
      _fs = OneOS.FS
    end
    local h = _fs.open(path, 'w')
    h.write(icon)
    h.close()
  end
  --Downloads and installs an application
  --id = the id of the application
  --path = the path is the name of the folder/file it'll be copied too
  --removeSpaces = removes spaces from the name (useful if its being run from the shell)
  --alwaysFolder = be default if there is only one file it will save it as a single file, if true files will always be placed in a folder
  --fullPath = if true the given path will not be changed, if false the program name will be appended
  function installApplication(id, path, removeSpaces, alwaysFolder, fullPath)
    local package = downloadApplication(id)
    if type(package) ~= 'string' or #package == 0 then
      error('The application did not download correctly or is empty. Try again.')
    end
    local pack = JSON.decode(package)
    if pack then

      local _fs = fs
      if OneOS then
        _fs = OneOS.FS
      end
      local function makeFile(_path,_content)
        sleep(0)
        local file=_fs.open(_path,"w")
        file.write(_content)
        file.close()
      end
      local function makeFolder(_path,_content)
        _fs.makeDir(_path)
          for k,v in pairs(_content) do
            if type(v)=="table" then
              makeFolder(_path.."/"..k,v)
            else
              makeFile(_path.."/"..k,v)
            end
          end
      end

      local app = getApplication(id)
      local appName = app['name']
      local keyCount = 0
      for k, v in pairs(pack) do
        keyCount = keyCount + 1
      end
      if removeSpaces then
        appName = appName:gsub(" ", "")
      end
      local location = path..'/'
      if not fullPath then
        location = location .. appName
      end
      if keyCount == 1 and not alwaysFolder then
        makeFile(location, pack['startup'])
      else
        makeFolder(location, pack)
        location = location .. '/startup'
      end

      return location
    else
      error('The application appears to be corrupt. Try downloading it again.')
    end
  end

  function registerComputer(realid, username, password)
    return doRequest('computer', 'register', {realid = realid, username = username, password = password})
  end

  function getAllComments(type, id)
    return doRequest('comment', 'get', {ctype = type, ctypeid = id})
  end

  function getComment(id)
    return doRequest('comment', 'get', {id = id})
  end

  function deleteComment(id, username, password)
    return doRequest('comment', 'delete', {id = id, username = username, password = password})
  end

  function addComments()
    return doRequest('comment', 'get', {id = id})
  end

  function getUser()
    return doRequest('user', 'get', {id = id})
  end

  function registerUser(username, password, email, mcusername)
    return doRequest('user', 'register', {username = username, password = password, email = email, mcusername = mcusername})
  end

  function testConnection()
    local ok = false
      parallel.waitForAny(function()
        if http and http.get(apiURL) then
        ok = true
      end
    end,function()
        sleep(10)
    end)
    return ok 
  end
]]

local function loadJSON()
        local sName = 'JSON'
               
        local tEnv = {}
        setmetatable( tEnv, { __index = _G } )
        local fnAPI, err = loadstring(_jstr)
        if fnAPI then
                setfenv( fnAPI, tEnv )
                fnAPI()
        else
                printError( err )
                return false
        end
       
        local tAPI = {}
        for k,v in pairs( tEnv ) do
                tAPI[k] =  v
        end
       
        _G[sName] = tAPI
        return true
end

local function loadAPI()
        local sName = 'api'
               
        local tEnv = {}
        setmetatable( tEnv, { __index = _G } )
        local fnAPI, err = loadstring(_api)
        if fnAPI then
                setfenv( fnAPI, tEnv )
                fnAPI()
        else
                printError( err )
                return false
        end
       
        local tAPI = {}
        for k,v in pairs( tEnv ) do
                tAPI[k] =  v
        end
       
        _G[sName] = tAPI
        return true
end

local tArgs = {...}
 
loadJSON()
loadAPI()

Settings = {
  InstallLocation = '/', --if you have a folder you'd like programs to be installed to (for an OS) change this (e.g. /Programs/)
  AlwaysFolder = false, --when false if there is only one file it will save it as a single file, if true files will always be placed in a folder
}

local isMenuVisible = false
local currentPage = ''
local listItems = {}

local isRunning = true
local currentScroll = 0
local maxScroll = 0
local pageHeight = 0

local searchBox = nil
local featuredBannerTimer = nil

Values = {
  ToolbarHeight = 2,
}

Current = {
  CursorBlink = false,
  CursorPos = {},
  CursorColour = colours.black
}

local function split(str, sep)
        local sep, fields = sep or ":", {}
        local pattern = string.format("([^%s]+)", sep)
        str:gsub(pattern, function(c) fields[#fields+1] = c end)
        return fields
end
--This is my drawing API, is is pretty much identical to what drives PearOS.
local _w, _h = term.getSize()
Drawing = {
  
  Screen = {
    Width = _w,
    Height = _h
  },

  DrawCharacters = function (x, y, characters, textColour,bgColour)
    Drawing.WriteStringToBuffer(x, y, characters, textColour, bgColour)
  end,
  
  DrawBlankArea = function (x, y, w, h, colour)
    Drawing.DrawArea (x, y, w, h, " ", 1, colour)
  end,

  DrawArea = function (x, y, w, h, character, textColour, bgColour)
    --width must be greater than 1, other wise we get a stack overflow
    if w < 0 then
      w = w * -1
    elseif w == 0 then
      w = 1
    end

    for ix = 1, w do
      local currX = x + ix - 1
      for iy = 1, h do
        local currY = y + iy - 1
        Drawing.WriteToBuffer(currX, currY, character, textColour, bgColour)
      end
    end
  end,

  LoadImage = function(str)
    local image = {
      text = {},
      textcol = {}
    }
    local tLines = split(str, '\n')
    for num, sLine in ipairs(tLines) do
            table.insert(image, num, {})
            table.insert(image.text, num, {})
            table.insert(image.textcol, num, {})
                                        
            --As we're no longer 1-1, we keep track of what index to write to
            local writeIndex = 1
            --Tells us if we've hit a 30 or 31 (BG and FG respectively)- next char specifies the curr colour
            local bgNext, fgNext = false, false
            --The current background and foreground colours
            local currBG, currFG = nil,nil
            for i=1,#sLine do
                    local nextChar = string.sub(sLine, i, i)
                    if nextChar:byte() == 30 then
                            bgNext = true
                    elseif nextChar:byte() == 31 then
                            fgNext = true
                    elseif bgNext then
                            currBG = Drawing.GetColour(nextChar)
                            bgNext = false
                    elseif fgNext then
                            currFG = Drawing.GetColour(nextChar)
                            fgNext = false
                    else
                            if nextChar ~= " " and currFG == nil then
                                    currFG = colours.white
                            end
                            image[num][writeIndex] = currBG
                            image.textcol[num][writeIndex] = currFG
                            image.text[num][writeIndex] = nextChar
                            writeIndex = writeIndex + 1
                    end
            end
            num = num+1
        end
    return image
  end,

  DrawImage = function(_x,_y,tImage, w, h)
    if tImage then
      for y = 1, h do
        if not tImage[y] then
          break
        end
        for x = 1, w do
          if not tImage[y][x] then
            break
          end
          local bgColour = tImage[y][x]
                local textColour = tImage.textcol[y][x] or colours.white
                local char = tImage.text[y][x]
                Drawing.WriteToBuffer(x+_x-1, y+_y-1, char, textColour, bgColour)
        end
      end
    elseif w and h then
      Drawing.DrawBlankArea(_x, _y, w, h, colours.lightGrey)
    end
  end,

  DrawCharactersCenter = function(x, y, w, h, characters, textColour,bgColour)
    w = w or Drawing.Screen.Width
    h = h or Drawing.Screen.Height
    x = x or math.floor((w - #characters) / 2)
    y = y or math.floor(h / 2)

    Drawing.DrawCharacters(x, y, characters, textColour, bgColour)
  end,

  GetColour = function(hex)
      local value = tonumber(hex, 16)
      if not value then return nil end
      value = math.pow(2,value)
      return value
  end,

  Clear = function (_colour)
    _colour = _colour or colours.black
    Drawing.ClearBuffer()
    Drawing.DrawBlankArea(1, 1, Drawing.Screen.Width, Drawing.Screen.Height, _colour)
  end,

  Buffer = {},
  BackBuffer = {},

  DrawBuffer = function()
    for y,row in pairs(Drawing.Buffer) do
      for x,pixel in pairs(row) do
        local shouldDraw = true
        local hasBackBuffer = true
        if Drawing.BackBuffer[y] == nil or Drawing.BackBuffer[y][x] == nil or #Drawing.BackBuffer[y][x] ~= 3 then
          hasBackBuffer = false
        end
        if hasBackBuffer and Drawing.BackBuffer[y][x][1] == Drawing.Buffer[y][x][1] and Drawing.BackBuffer[y][x][2] == Drawing.Buffer[y][x][2] and Drawing.BackBuffer[y][x][3] == Drawing.Buffer[y][x][3] then
          shouldDraw = false
        end
        if shouldDraw then
          term.setBackgroundColour(pixel[3])
          term.setTextColour(pixel[2])
          term.setCursorPos(x, y)
          term.write(pixel[1])
        end
      end
    end
    Drawing.BackBuffer = Drawing.Buffer
    Drawing.Buffer = {}
  end,

  ClearBuffer = function()
    Drawing.Buffer = {}
  end,

  Offset = {
    X = 0,
    Y = 0,
  },

  SetOffset = function(x, y)
    Drawing.Offset.X = x
    Drawing.Offset.Y = y
  end,

  ClearOffset = function()
    Drawing.Offset = {
      X = 0,
      Y = 0,
    }
  end,

  WriteStringToBuffer = function (x, y, characters, textColour,bgColour)
    for i = 1, #characters do
        local character = characters:sub(i,i)
        Drawing.WriteToBuffer(x + i - 1, y, character, textColour, bgColour)
    end
  end,

  WriteToBuffer = function(x, y, character, textColour,bgColour)
    x = x + Drawing.Offset.X
    y = y + Drawing.Offset.Y
    Drawing.Buffer[y] = Drawing.Buffer[y] or {}
    Drawing.Buffer[y][x] = {character, textColour, bgColour}
  end

}

SearchPage = {
  X = 0,
  Y = 0,
  Width = 0,
  Height = 3,
  Text = "",
  Placeholder = "Search...",
  CursorPos = 1,

  Draw = function(self)
    Drawing.DrawBlankArea(self.X+1, self.Y+1, self.Width-6, self.Height, colours.grey)
    Drawing.DrawBlankArea(self.X, self.Y, self.Width-6, self.Height, colours.white)


    Drawing.DrawBlankArea(self.X + self.Width - 5 + 1, self.Y + 1, 6, self.Height, colours.grey)
    Drawing.DrawBlankArea(self.X + self.Width - 5, self.Y, 6, self.Height, colours.blue)
    Drawing.DrawCharacters(self.X + self.Width - 3, self.Y + 1, "GO", colours.white, colours.blue)

    RegisterClick(self.X + self.Width - 5, self.Y, 6, self.Height, function() 
      ChangePage('Search Results', self.Text)
    end)

    if self.Text == "" then
      Drawing.DrawCharacters(self.X+1, self.Y+1, self.Placeholder, colours.lightGrey, colours.white)
    else
      Drawing.DrawCharacters(self.X+1, self.Y+1, self.Text, colours.black, colours.white)
    end

    Current.CursorBlink = true
    Current.CursorPos = {self.X+self.CursorPos, self.Y+3}
    Current.CursorColour = colours.black

  end,

  Initialise = function(self)
    local new = {}    -- the new instance
    setmetatable( new, {__index = self} )
    new.Y = math.floor((Drawing.Screen.Height - 1 - new.Height) / 2)
    new.X = 2
    new.Width = Drawing.Screen.Width - 4
    return new
  end
}

ListItem = {
  X = 0,
  Y = 0,
  XMargin = 1,
  YMargin = 1,
  Width = 0,
  Height = 6,
  AppID = 0,
  Title = '',
  Author = '',
  Rating = 0,
  Description = {},
  Icon = {},
  Downloads = 0,
  Category = '?',
  Version = 1,
  Type = 0, --0 = app list item, 1 = more info, 2 category

  CalculateWrapping = function(self, text)

    local numberOfLines = false

    if self.Type == 0 then
      numberOfLines = 2
    end
    
    local textWidth = self.Width - 8

    local lines = {''}
        for word, space in text:gmatch('(%S+)(%s*)') do
                local temp = lines[#lines] .. word .. space:gsub('\n','')
                if #temp > textWidth then
                        table.insert(lines, '')
                end
                if space:find('\n') then
                        lines[#lines] = lines[#lines] .. word
                        
                        space = space:gsub('\n', function()
                                table.insert(lines, '')
                                return ''
                        end)
                else
                        lines[#lines] = lines[#lines] .. word .. space
                end
        end

        if not numberOfLines then
          return lines
        else
          local _lines = {}
          for i, v in ipairs(lines) do
            _lines[i] = v
            if i >= numberOfLines then
              return _lines
            end
          end
          return _lines
        end
  end,
  Draw = function(self)
    if self.Y + Drawing.Offset.Y >= Drawing.Screen.Height + 1 or self.Y + Drawing.Offset.Y + self.Height <= 1 then
      return
    end
    --register clicks
    --install

    local installPos = 1

    if self.Type == 1 then
      installPos = 2
    end

    RegisterClick(self.Width - 7, self.Y + Drawing.Offset.Y + installPos - 1, 9, 1, function()
      Load("Installing App", function()
        api.installApplication(tonumber(self.AppID), Settings.InstallLocation..'/', true, Settings.AlwaysFolder)
        --api.saveApplicationIcon(tonumber(self.AppID), Settings.InstallLocation..'/'..self.Title.."/icon")
      end)
      Load("Application Installed!", function()
        sleep(1)
      end)
    end)

    --more info
    if self.Type == 0 then
      RegisterClick(self.X, self.Y + Drawing.Offset.Y, self.Width, self.Height, function()
        ChangePage('more-info',self.AppID)
      end)
    elseif self.Type == 2 then
      RegisterClick(self.X, self.Y + Drawing.Offset.Y, self.Width, self.Height, function()
        ChangePage('Category Items',self.Title)
      end)
    end

    Drawing.DrawBlankArea(self.X+1, self.Y+1, self.Width, self.Height, colours.grey)
    Drawing.DrawBlankArea(self.X, self.Y, self.Width, self.Height, colours.white)
    
    --Drawing.DrawBlankArea(self.X+1, self.Y+1, 6, 4, colours.green)
    Drawing.DrawCharacters(self.X + 8, self.Y + 1, self.Title, colours.black, colours.white)
    if self.Type ~= 2 then
      Drawing.DrawCharacters(self.X + 8, self.Y + 2, "by "..self.Author, colours.grey, colours.white)
      Drawing.DrawCharacters(self.Width - 8, self.Y + installPos - 1, " Install ", colours.white, colours.green)
    end

    Drawing.DrawImage(self.X+1, self.Y+1, self.Icon, 4, 3)
    

    if self.Type == 1 then
      Drawing.DrawCharacters(self.X, self.Y + 6, "Category", colours.grey, colours.white)
      Drawing.DrawCharacters(math.ceil(self.X+(8-#self.Category)/2), self.Y + 7, self.Category, colours.grey, colours.white)

      Drawing.DrawCharacters(self.X+1, self.Y + 9, "Dwnlds", colours.grey, colours.white)
      Drawing.DrawCharacters(math.ceil(self.X+(8-#tostring(self.Downloads))/2), self.Y + 10, tostring(self.Downloads), colours.grey, colours.white)

      Drawing.DrawCharacters(self.X+1, self.Y + 12, "Version", colours.grey, colours.white)
      Drawing.DrawCharacters(math.ceil(self.X+(8-#tostring(self.Version))/2), self.Y + 13, tostring(self.Version), colours.grey, colours.white)

    end

    if self.Type ~= 2 then
      --draw the rating
      local starColour = colours.yellow
      local halfColour = colours.lightGrey
      local emptyColour = colours.lightGrey

      local sX = self.X + 8 + #("by "..self.Author) + 1
      local sY = self.Y + 2

        local s1C = emptyColour
        local s1S = " "

        local s2C = emptyColour
        local s2S = " "

        local s3C = emptyColour
        local s3S = " "

        local s4C = emptyColour
        local s4S = " "

        local s5C = emptyColour
        local s5S = " "

      if self.Rating >= .5 then
        s1C = halfColour
        s1S = "#"
      end

      if self.Rating >= 1 then
        s1C = starColour
        s1S = " "
      end


      if self.Rating >= 1.5 then
        s2C = halfColour
        s2S = "#"
      end

      if self.Rating >= 2 then
        s2C = starColour
        s2S = " "
      end

        
      if self.Rating >= 2.5 then
        s3C = halfColour
        s3S = "#"
      end

      if self.Rating >= 3 then
        s3C = starColour
        s3S = " "
      end

        
      if self.Rating >= 3.5 then
        s4C = halfColour
        s4S = "#"
      end

      if self.Rating >= 4 then
        s4C = starColour
        s4S = " "
      end

        
      if self.Rating >= 4.5 then
        s5C = halfColour
        s5S = "#"
      end

      if self.Rating == 5 then
        s5C = starColour
        s5S = " "
      end

      Drawing.DrawCharacters(sX, sY, s1S, starColour, s1C)
      Drawing.DrawCharacters(sX + 2, sY, s2S, starColour, s2C)
      Drawing.DrawCharacters(sX + 4, sY, s3S, starColour, s3C)
      Drawing.DrawCharacters(sX + 6, sY, s4S, starColour, s4C)
      Drawing.DrawCharacters(sX + 8, sY, s5S, starColour, s5C)
    end

    local descPos = 2



    if self.Type == 1 then
      descPos = 3
    elseif self.Type == 2 then
      descPos = 1
    end

    for _,line in ipairs(self.Description) do
      Drawing.DrawCharacters(self.X + 8, self.Y + descPos + _, line, colours.lightGrey, colours.white)
    end
  end,
  Initialise = function(self, y, appid, title, icon, description, author, rating, version, category, downloads, Type)
    Type = Type or 0
    local new = {}    -- the new instance
    setmetatable( new, {__index = self} )
    new.Y = y
    new.Type = Type
    new:UpdateSize()
    new.AppID = appid
    new.Title = title
    new.Icon = Drawing.LoadImage(icon)
    new.Icon[5] = nil
    new.Description = new:CalculateWrapping(description)
    new.Author = author
    new.Rating = rating
    new.Version = version
    new.Category = category
    new.Downloads = downloads
    return new
  end,
  UpdateSize = function(self)
    self.X = self.XMargin + 1
    self.Width = Drawing.Screen.Width - 2 * self.XMargin - 2

    if self.Type == 1 then
      self.Height = 15
    end
  end,
}

Clicks = {
  
}

function RegisterClick(x, y, width, height, action)
  table.insert(Clicks,{
    X = x,
    Y = y,
    Width = width,
    Height = height,
    Action = action
  })
end

function Load(title, func)
  Drawing.DrawBlankArea(1, 1, Drawing.Screen.Width+1, Drawing.Screen.Height+1, colours.lightGrey)
  Drawing.DrawCharactersCenter(nil, Drawing.Screen.Height/2, nil, nil, title, colours.white, colours.lightGrey)
  isLoading = true
  parallel.waitForAny(function()
    func()
    isLoading = false
  end, DisplayLoader)
end

function DisplayLoader()
  local maxStep = 100 -- about 10 seconds, timeout
  local currStep = 0
  local loadStep = 0
  while isLoading do
    local Y = Drawing.Screen.Height/2 + 2
    local cX = Drawing.Screen.Width/2

    Drawing.DrawCharacters(cX-3, Y, ' ', colours.black, colours.grey)
    Drawing.DrawCharacters(cX-1, Y, ' ', colours.black, colours.grey)
    Drawing.DrawCharacters(cX+1, Y, ' ', colours.black, colours.grey)
    Drawing.DrawCharacters(cX+3, Y, ' ', colours.black, colours.grey)
    
    if loadStep ~= -1 then
      Drawing.DrawCharacters(cX-3 + (loadStep * 2), Y, ' ', colours.black, colours.white)   
    end

    loadStep = loadStep + 1
    if loadStep >= 4 then
      loadStep = -1
    end

    currStep = currStep + 1
    if currStep >= maxStep then
      isLoading = false
      error('Load timeout. Check your internet connection and try again. The server may also be down, try again in 10 minutes.')
    end

    Drawing.DrawBuffer()
    sleep(0.15)
  end
end

function ChangePage(title, arg)
  ClearCurrentPage()
  if title == 'Top Charts' then
    LoadList(api.getTopCharts)
  elseif title == 'Search Results' then
    LoadList(function() return api.searchApplications(arg) end)
  elseif title == "Featured" then
    LoadFeatured()
  elseif title == "Categories" then
    LoadCategories()
  elseif title == "more-info" then
    LoadAboutApp(arg)
  elseif title == "Search" then
    LoadSearch()
  elseif title == "Category Items" then
    LoadList(function() return api.getApplicationsInCategory(arg) end)
  end

  currentPage = title

  maxScroll = getMaxScroll()
end

function LoadAboutApp(id)
  Load("Loading Application", function()
    --ClearCurrentPage()
    local app = api.getApplication(id)
    local item = ListItem:Initialise(1, app.id, app.name, app.icon, app.description, app.user.username, app.stars, app.version, app.category, app.downloads, 1)
    table.insert(listItems, item)
  end)

end

function LoadFeatured()
  Load("Loading", function()
    local tApps = api.getFeaturedApplications()

    --all items
    for i, app in ipairs(tApps) do
      local item = ListItem:Initialise(1+(i-1)*(ListItem.Height + 2), 
        app.id, app.name, app.icon, app.description,
         app.user.username, app.stars, app.version,
          app.category, app.downloads)
      table.insert(listItems, item)
    end
  end)  
end

function LoadCategories()
  Load("Loading", function()
    local tApps = api.getCategories()
    local i = 1
    for name, category in pairs(tApps) do
      local item = ListItem:Initialise(1+(i-1)*(ListItem.Height + 2), 
        0, name, category.icon, category.description, nil, nil, nil, nil, nil, 2)
      table.insert(listItems, item)
      i = i + 1
    end
  end)
end

function LoadSearch(id)
    local item = SearchPage:Initialise()
    searchBox = item
    --featuredBannerTimer = os.startTimer(5)
    table.insert(listItems, item)

end

function ClearCurrentPage()
  --listItems = {}
  for i,v in ipairs(listItems) do listItems[i]=nil end
  currentScroll = 0
  searchBox = nil
  featuredBannerTimer = nil

  Current.CursorBlink = false
  Draw()
end

function LoadList(func)
  Load("Loading", function()
    local tApps = func()
    if tApps == nil then
      error('Can not connect to the App Store server.')
    elseif type(tApps) ~= 'table' then
      error('The server is too busy. Try again in a few minutes.')
    end
    for i, app in ipairs(tApps) do
      local item = ListItem:Initialise(1+(i-1)*(ListItem.Height + 2), 
        app.id, app.name, app.icon, app.description,
         app.user.username, app.stars, app.version,
          app.category, app.downloads)
      table.insert(listItems, item)
    end
  end)
end

function Draw()
  Clicks = {}
  Drawing.Clear(colours.lightGrey)
  DrawList()
  DrawToolbar()

  --DrawScrollbar()

  Drawing.DrawBuffer()

  if Current.CursorPos and Current.CursorPos[1] and Current.CursorPos[2] then
    term.setCursorPos(unpack(Current.CursorPos))
  end
  term.setTextColour(Current.CursorColour)
  term.setCursorBlink(Current.CursorBlink)
end

function DrawList()
  Drawing.SetOffset(0, -currentScroll + 2)
    for i, v in ipairs(listItems) do
      v:Draw()
    end
  Drawing.ClearOffset()
  
  if getMaxScroll() ~= 0 then
    DrawScrollBar(Drawing.Screen.Width, currentScroll, getMaxScroll())
  end
end

--[[
function DrawScrollbar()

  local scrollBarHeight = Drawing.Screen.Height - 1
  local scrollBarPosition = 0

  if pageHeight > 0 and maxScroll > 0 then
    scrollBarHeight = (Drawing.Screen.Height / pageHeight) * (Drawing.Screen.Height - 1)
    scrollBarPosition = (currentScroll / pageHeight) * (Drawing.Screen.Height - 1)
  end

  Drawing.DrawBlankArea(Drawing.Screen.Width, scrollBarPosition + 2, 1, scrollBarHeight, colours.blue)


  Drawing.DrawCharacters(Drawing.Screen.Width, scrollBarPosition + 2, "-", colours.black,colours.white)

  Drawing.DrawCharacters(Drawing.Screen.Width-1, 2, "+", colours.black,colours.white)

  --Drawing.DrawBuffer()

  Drawing.DrawBlankArea(51, 2, 1, 18, colours.green)


end
]]--

function DrawScrollBar(x, current, max)
  local fullHeight = Drawing.Screen.Height - 3
  local barHeight = (fullHeight - max)
  if barHeight < 5 then
    barHeight = 5
  end
  Drawing.DrawBlankArea(x, 4, 1, fullHeight, colours.grey)
  Drawing.DrawBlankArea(x, 4+current, 1, barHeight, colours.lightGrey)
end

function DrawToolbar()
  Drawing.DrawBlankArea(1, 1, Drawing.Screen.Width, 1, colours.white)
  local items = {
    {
      active = false,
      title = "Featured"
    },
    {
      active = false,
      title = "Top Charts"
    },
    {
      active = false,
      title = "Categories"
    },
    {
      active = false,
      title = "Search"
    }
  }
  local itemsLength = 0
  local itemsString = ""
  for i, v in ipairs(items) do
    itemsLength = itemsLength + #v.title + 3
    itemsString = itemsString .. v.title .. " | "
  end
  itemsLength = itemsLength - 3
  
  local itemX = (Drawing.Screen.Width - itemsLength) / 2

  for i, v in ipairs(items) do
    local border = " | "
    if i == #items then
      border = ""
    end
    Drawing.DrawCharacters(itemX, 1, v.title .. border, colours.blue, colours.white)
    RegisterClick(itemX-1, 1, #v.title + 2, 1, function()
      ChangePage(v.title)
    end)
    itemX = itemX + #(v.title .. border)
  end
  Drawing.DrawCharacters(Drawing.Screen.Width, 1, "X", colours.white, colours.red)

  RegisterClick(Drawing.Screen.Width, 1, 1, 1, function()
    if OneOS then
      OneOS.Close()
    end
    isRunning = false
    term.setBackgroundColour(colours.black)
    term.setTextColour(colours.white)
    term.clear()
    term.setCursorPos(1,1)
    print = _print
    print('Thanks for using the App Store!')
    print('(c) oeed 2013 - 2014')
  end)
end

function getMaxScroll()
  local totalHeight = 0
  for i, v in ipairs(listItems) do
    totalHeight = totalHeight + v.Height + 2
  end

  local s = totalHeight - Drawing.Screen.Height + 2
    
  if s < 0 then
    s = 0
  end

  pageHeight = totalHeight

  return s
end

function setScroll(iScroll)
  maxScroll = getMaxScroll()
  currentScroll = iScroll
  if currentScroll < 0 then
    currentScroll = 0
  elseif currentScroll > maxScroll then
    currentScroll = maxScroll
  end
end

function EventHandler()
  while isRunning do
    local event, arg, x, y = os.pullEvent()

    if event == "mouse_scroll" then
      setScroll(currentScroll + (arg * 3))
      Draw()
    elseif event == "timer" then
      if arg == featuredBannerTimer and currentPage == 'Featured' then

        --featuredBannerTimer = os.startTimer(5)
        listItems[1]:NextPage()
        Draw()
      end
    elseif event == "char" then
      if currentPage == 'Search' then
        searchBox.Text = searchBox.Text .. arg
        searchBox.CursorPos = searchBox.CursorPos + 1
        Draw()
      end
    elseif event == "key" then
      if arg == keys.down then
        setScroll(currentScroll + 3)
        Draw()

      elseif arg == keys.up then
        setScroll(currentScroll - 3)
        Draw()
      end

      if arg == keys.backspace and currentPage == 'Search' then
        searchBox.Text = string.sub(searchBox.Text,0,#searchBox.Text-1)
        searchBox.CursorPos = searchBox.CursorPos - 1
        if searchBox.CursorPos < 1 then
          searchBox.CursorPos = 1
        end
        Draw()
      elseif arg == keys.enter and currentPage == 'Search' then
        ChangePage('Search Results', searchBox.Text)
        Draw()
      end

    elseif event == "mouse_click" then
      local clicked = false
      for i = 1, #Clicks do
        local v = Clicks[(#Clicks - i) + 1]
        if not clicked and x >= v.X and (v.X + v.Width) > x and y >= v.Y and (v.Y + v.Height) > y then
          clicked = true

          local iMV = isMenuVisible
          v:Action()

          if iMV == isMenuVisible then
            isMenuVisible = false
          end

          Draw()
        end
      end

      if not clicked then
        isMenuVisible = false
        Draw()
      end
    end



  end
end

function TidyPath(path)
  if fs.exists(path) and fs.isDir(path) then
    path = path .. '/'
  end

  path, n = path:gsub("//", "/")
  while n > 0 do
    path, n = path:gsub("//", "/")
  end
  return path
end

function Initialise()
  if tArgs and tArgs[1] then
    if tArgs[1] == 'install' and tArgs[2] and tonumber(tArgs[2]) then
      print('Connecting...')
      if api.testConnection() then
        print('Downloading program...')
        local path = tArgs[3] or shell.dir()
        local location = api.installApplication(tonumber(tArgs[2]), path, true)
        if location then
          print('Program installed!')
          print("Type '"..TidyPath(location).."' to run it.")
        else
          printError('Download failed. Check the ID and try again.')
        end
      else
        printError('Could not connect to the App Store.')
        printError('Check your connection and try again.')
      end
    elseif tArgs[1] == 'submit' and tArgs[2] and fs.exists(shell.resolve(tArgs[2])) then
      print('Packaging...')
      local pkg = Package(shell.resolve(tArgs[2]))
      if pkg then
        print('Connecting...')
        if api.testConnection() then
          print('Uploading...')
          local str = JSON.encode(pkg)
          str = str:gsub("\\'","'")
          local h = http.post('http://ccappstore.com/submitPreupload.php', 
                                  "file="..textutils.urlEncode(str));
          if h then
            local id = h.readAll()
            if id:sub(1,2) == 'OK' then
              print('Your program has been uploaded.')
              print('It\'s unique ID is: '..id:sub(3))
              print('Go to ccappstore.com/submit/ and select "In Game" as the upload option and enter the above code.')
            else
              printError('The server rejected the file. Try again or PM oeed. ('..h.getResponseCode()..' error)')
            end
          else
              printError('Could not submit file.')
          end
        else
          printError('Could not connect to the App Store.')
          printError('Check your connection and try again.')
        end
      end
    else
      print('Useage: appstore install <app id> <path (optional)>')
      print('Or: appstore submit <path>') 
    end
  else
    Load('Connecting', api.testConnection)
    ChangePage('Top Charts')
    Draw()
    EventHandler()
  end
end

function addFile(package, path, name)
  if name == '.DS_Store' or shell.resolve(path) == shell.resolve(shell.getRunningProgram()) then
    return package
  end
  local h = fs.open(path, 'r')
  if not h then
    error('Failed reading file: '..path)
  end
  package[name] = h.readAll()
  h.close()
  return package
end

function addFolder(package, path, master)
  local subPkg = {}

  if path:sub(1,4) == '/rom' then
    return package
  end
  for i, v in ipairs(fs.list(path)) do
    if fs.isDir(path..'/'..v) then
      subPkg = addFolder(subPkg, path..'/'..v)
    else
      subPkg = addFile(subPkg, path..'/'..v, v)
    end
  end

  if master then
    package = subPkg
  else
    package[fs.getName(path)] = subPkg
  end
  return package
end

function Package(path)
  local pkg = {}
  if fs.isDir(path) then
    pkg = addFolder(pkg, path, true)
  else
    pkg = addFile(pkg, path, 'startup')
  end
  if not pkg['startup'] then
    print('You must have a file named startup in your program. This is the file used to start the program.')
  else
    return pkg
  end
end

if term.isColor and term.isColor() then
  local httpTest = nil
  if http then
    httpTest = true-- http.get('http://ccappstore.com/api/')
  end
  if httpTest == nil then
    print = _print
    term.setBackgroundColor(colours.grey)
    term.setTextColor(colours.white)
    term.clear()
    term.setCursorPos(3, 3)

    print("Could not connect to the App Store server!\n\n")

    term.setTextColor(colours.white)
    print("Try the following steps:")
    term.setTextColor(colours.lightGrey)
    print(' - Ensure you have enabled the HTTP API')
    print(' - Check your internet connection is working')
    print(' - Retrying again in 10 minutes')
    print(' - Get assistance on the forum page')
    print()
    print()
    print()
    term.setTextColor(colours.white)
    print(" Click anywhere to exit...")
    os.pullEvent("mouse_click")
    OneOS.Close()

  else

    -- Run main function
    local _, err = pcall(Initialise)
    if err then
      print = _print
      term.setBackgroundColor(colours.lightGrey)
      term.setTextColor(colours.white)
      term.clear()


      term.setBackgroundColor(colours.grey)
      term.setCursorPos(1, 2)
      term.clearLine()
      term.setCursorPos(1, 3)
      term.clearLine()
      term.setCursorPos(1, 4)
      term.clearLine()
      term.setCursorPos(3, 3)

      print("The ComputerCraft App Store has crashed!\n\n")

      term.setBackgroundColour(colours.lightGrey)
      print("Try repeating what you just did, if this is the second time you've seen this message go to")
      term.setTextColour(colours.black)
      print("http://ccappstore.com/help/crash/\n")
      term.setTextColour(colours.white)    
      print("The error was:")

      term.setTextColour(colours.black)
      print(" " .. tostring(err) .. "\n\n")

      term.setTextColour(colours.white)
      print(" Click anywhere to exit...")
      os.pullEvent("mouse_click")
      if OneOS then
        OneOS.Close()
      end
      term.setTextColour(colours.white)
      term.setBackgroundColour(colours.black)
      term.clear()
      term.setCursorPos(1,1)
    end
  end
else
  print('The App Store requires an Advanced (gold) Computer!')
end