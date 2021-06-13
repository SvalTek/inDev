---@diagnostic disable: lowercase-global
local bundle = require("luvi").bundle
bundle.register("utils", "./common/utils.lua")
bundle.register("Classy", "./common/Classy.lua")
local utils = require("utils")
bundle.register("common_methods", "./common/methods.lua")
require("common_methods")

---load globals
bundle.register("bundled_globals", "globals.lua")
require("bundled_globals")

local function LoadBundledScripts(dir, ns)
    local bundles = bundle.readdir(dir)
    for _, filename in ipairs(bundles) do
        local scriptName = string.gsub(filename, ".lua$", "")
        local scriptFile = string.format("%s/%s", dir, scriptName .. ".lua")
        local NameSpace = (ns or "Application") .. "." .. scriptName
        if DEBUG then
            local msg = string.format("Loading Bundled Script: %s", scriptFile)
            print(msg, NameSpace)
        end
        bundle.register(NameSpace, scriptFile)
    end
end

--- The Main Application
local App = {NAME = "Unset", VERSION = "Unset"}
local App_Meta = {__index = App, LoadBundledScripts = LoadBundledScripts}

Application = setmetatable({}, App_Meta)
LoadBundledScripts("./modules", "modules")

LoadBundledScripts("./classes", "classes")

Application['UTILS'] = utils

local pack = table.pack
Application.uv = require('uv')



-- setTimeout(1000, function(...) print((...or'noName'),"> This happens later") end,'lua')
-- print("This happens first")
function setTimeout(timeout, callback, ...)
    local uv = Application.uv
    -- try to see if we have params for our callback.
    local params
    local has_params = (not (... == nil))
    if has_params then params = pack(...) end

    -- create a timer
    local timer = uv.new_timer()

    local function ontimeout()
        if DEBUG then print("ontimeout", timeout) end

        uv.timer_stop(timer)
        uv.close(timer)

        local cbOk, cbMessage
        if (has_params ~= false) and (params ~= nil) then
            cbOk, cbMessage = pcall(callback, unpack(params))
        else
            cbOk, cbResult, cbMessage = pcall(callback)
        end

        -- check if our callback ran ok
        if (not cbOk) then
            local error_message = "Unknown Error"
            -- if cbMessage contains a string then use it as an error message
            if (type(cbMessage) == "string") then
                error_message = cbMessage
            end
            if DEBUG then
                print("ontimeout: Error in setTimeout", error_message)
            end
        end
    end

    -- start our timer
    uv.timer_start(timer, timeout, 0, ontimeout)

    return timer
end

local env = require("env")

Application.Sys = {
    EnvKeys = function() return env.keys() end,
    GetEnv = function(key) return env.get(key) end,
    SetEnv = function(key,value) return env.set(key,value) end
}

function Application:Main()
    -- run our main loop
    self.uv.run()
end
