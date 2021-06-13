---@diagnostic disable: lowercase-global
--- safely escape a given string
---@param str string    string to escape
string.escape = function(str)
    return str:gsub('([%^%$%(%)%%%.%[%]%*%+%-%?])', '%%%1')
end

--- expand a string containing any `${var}` or `$var`.
--- Substitution values should be only numbers or strings.
--- @param s string the string
--- @param subst any either a table or a function (as in `string.gsub`)
--- @return string expanded string
function string.expand(s, subst)
    local res, k = s:gsub('%${([%w_]+)}', subst)
    if k > 0 then return res end
    return (res:gsub('%$([%w_]+)', subst))
end

local charset = {}
do -- [0-9a-zA-Z]
    for c = 48, 57 do table.insert(charset, string.char(c)) end
    for c = 65, 90 do table.insert(charset, string.char(c)) end
    for c = 97, 122 do table.insert(charset, string.char(c)) end
end


---* Copies all the fields from the source into t and return .
-- If a key exists in multiple tables the right-most table value is used.
--- @param t table      table to update
function table.update( t, ... )
    for i = 1, select( '#', ... ) do
        local x = select( i, ... )
        if x then for k, v in pairs( x ) do t[k] = v end end
    end
    return t
end

--
-- ──────────────────────────────────────────────────────────────────── EXTRA ─────
--

---* bind an argument to a type and throw an error if the provided param doesnt match at runtime.
-- Note this works in reverse of the normal assert in that it returns nil if the argumens provided are valid
-- if not the it either returns true plus and error message , or if it fails to grab debug info just true.
--- @param idx number
-- positonal index of the param to bind
--- @param val any the param to bind
--- @param tp string the params bound type
--- @usage
-- local test = function(somearg,str,somearg)
-- if assert_arg(2,str,'string') then
--    return
-- end
--
-- test(nil,1,nil) -> Invalid Param in [test()]> Argument:2 Type: number Expected: string
function assert_arg(idx, val, tp)
    if type(val) ~= tp then
        local fn = debug.getinfo(2, 'n')
        local msg = 'Invalid Param in [' .. fn.name .. '()]> ' ..
                        string.format('Argument:%s Type: %q Expected: %q',
                                      tostring(idx), type(val), tp)
        local test = function() error(msg, 4) end
        local rStat, cResult = pcall(test)
        if rStat then
            return true
        else
            error(cResult)
            return true, cResult
        end
    end
end

--- recursive read-only definition
function readOnly(t, name)
    for x, y in pairs(t) do
        if type(x) == 'table' then
            if type(y) == 'table' then
                t[readOnly(x)] = readOnly[y]
            else
                t[readOnly(x)] = y
            end
        elseif type(y) == 'table' then
            t[x] = readOnly(y)
        end
    end

    local proxy = {}
    local mt = {
        -- hide the actual table being accessed
        __metatable = 'read only table',
        __index = function(_, k) return t[k] end,
        __pairs = function() return pairs(t) end,
        __newindex = function(_, k, v)
            local msg = string.format(
                            'attempt to update a read-only table [%s]: Key: %s Value: %s',
                            (name or "UnNamed"), k, v)
            error(msg, 2)
        end
    }
    setmetatable(proxy, mt)
    return proxy
end

local oldpairs = pairs
function pairs(t)
    local mt = getmetatable(t)
    if mt == nil then
        return oldpairs(t)
    elseif type(mt.__pairs) ~= 'function' then
        return oldpairs(t)
    end

    return mt.__pairs()
end

function isDir(path)
  path = string.gsub(path .. "/", "//", "/")
  local ok, err, code = os.rename(path, path)
  if ok or code == 13 then
      return true
  end
  return false
end

---* Read File from Disk
---@param path string      path of file to Write, starts in Server root
---@return boolean,any     true,nil and file content or message
function readFile(path)
    local thisFile, errMsg = io.open(path, 'r')
    if thisFile ~= nil then
        local fContent = thisFile:read('*all')
        thisFile:close()
        if fContent ~= '' or nil then
            return true, fContent
        else
            return nil, 'Failed to Read from File: ' .. path
        end
    else
        return nil, 'Error Opening file: ' .. path .. ' io.open returned:' .. errMsg
    end
end

DIR_SEPERATOR = _G['package'].config:sub(1, 1)
function joinPath(...)
    local parts = {...}
    -- TODO: might be more useful to handle empty/missing parts
    if #parts < 2 then error('joinpath requires at least 2 parts', 2) end
    local r = parts[1]
    for i = 2, #parts do
        local v = string.gsub(parts[i], '^[' .. DIR_SEPERATOR .. ']', '')
        if not string.match(r, '[' .. DIR_SEPERATOR .. ']$') then r = r .. '/' end
        r = r .. v
    end
    return r
end

-- Removes a value from a table
function RemoveFromTable(tbl, ent)
	for i,v in ipairs(tbl) do
		if (v == ent) then
			table.remove(tbl, i);
			break;
		end
	end
end
-- EI find entry in spawn/weather tables
function FindInTable(tbl, keyname, keyvalue)
	for i,v in ipairs(tbl) do
		if (v[keyname] == keyvalue) then
			return v
		end
	end
end

-- Inserts a value into a table unless it is already present
function InsertIntoTable(tbl, ent)
	local inside = false;
	for i,v in ipairs(tbl) do
		if (v == ent) then
			inside = true;
			break;
		end
	end
	if (not inside) then
		table.insert(tbl, ent);
	end
end