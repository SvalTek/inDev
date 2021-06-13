--[[ --
  ==========================================================================================
    File: main.lua	Author: theros#7648
    Description: inDev Main
    Created:  2021-06-08T03:41:47.717Z
    Modified: 2021-06-13T19:35:53.477Z
    vscode-fold=2
  ==========================================================================================
--]] --
-- Debugging
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end
DEBUG = false

-- imports
local bundle = require("luvi").bundle
bundle.register("common", "./common.lua")
require("common")
local YAML = require("modules.YAML")
local utils = Application.UTILS
_G['pprint'] = utils.prettyPrint
local colorize = utils.colorize

-- load default config
local loaded_cfg = false
local default_cfg = bundle.readfile('inDev.yaml')
if default_cfg then
    loaded_cfg = YAML.parse(default_cfg)
    if loaded_cfg then Application.Config = loaded_cfg['globals'] end
end

local function AddEnvironments(environmentSchema)
    local environments = {}
    for i, env in ipairs(environmentSchema) do
        table.insert(environments, i, env)
    end
    Application.Environments = environments ---@type table<number,devEnv>
end

-- fetch current directory argument
local current_dir = tostring(args[1])
-- try to validate we were given a valid path, theres probably better ways to handle this
-- but we are expecting the current directory so one effective way is just to check that path exists
local message
if (current_dir == "nil") then
    message = colorize("failure",
                       "first argument to inDev must allways be the current path")
    print(message, colorize("string", "eg, inDev.exe %CD% [params]"))
    return
else
    if (not isDir(current_dir)) then
        message = colorize("failure", " -> invalid dir: ")
        print(message, colorize("string", current_dir))
        return
    else
        message = colorize("success", " -> running in dir:")
        print(message, colorize("string", current_dir))
    end
end

local environment_list
-- create initial environment list
if (type(loaded_cfg['environments']) == 'table') then
    environment_list = table.update({}, loaded_cfg['environments'])
end

-- try to load local inDev config file
local localCfg_path = joinPath(current_dir, "inDev.yaml")
local localCfg, localCfgData = readFile(localCfg_path)
if (not localCfg) then
    message = colorize("err", " -> no local config found:")
    print(message, colorize("err", localCfg_path))
else
    if (not type(localCfgData) == "string") then
        message = colorize("failure", " -> invalid data in file:")
        print(message, colorize("string", localCfg_path))
        return
    end
    -- try to parse local config
    local localConfig = YAML.parse(localCfgData)
    if (not localConfig) then
        message = colorize("failure", " -> failed to parse config:")
        print(message, colorize("string", localCfg_path))
        return
    else
        message = colorize("success", " -> loading config:")
        print(message, colorize("string", localCfg_path))

        if (localConfig['config']) then
            for k, v in pairs(localConfig['config']) do
                Application.Config[k] = v
            end
        end

        -- try to load local environments
        if (not localConfig['environments']) then
            message = colorize("highlight",
                               " -> environments section missing from local config:")
            print(message, colorize("string", localCfg_path))
        else
            for _, environment in ipairs(localConfig['environments']) do
                local existing_enviroment =
                    FindInTable(environment_list, "name", environment.name)
                if existing_enviroment then
                    RemoveFromTable(environment_list, existing_enviroment)
                    existing_enviroment =
                        table.update(existing_enviroment, environment)
                    InsertIntoTable(environment_list, existing_enviroment)
                else
                    InsertIntoTable(environment_list, environment)
                end
            end
        end
    end
end
--- Add all loaded Environments
AddEnvironments(environment_list)

bundle.register('environment_utils', 'environment_utils.lua')
local env_utils = require('environment_utils')

local providers = env_utils.loadEnvironments()

local AppHelp = [[
    version: ${version}                              Debug: ${isDebug}

    usage: 
        inDev [current dir] run [program] [arguments]
    example:        
        inDev %CD% run npm rum dev
        inDev %CD% run npm install -g npx

]]

--- Displays basic help based on provider topics
local function ShowHelp()
    print(colorize("success", "inDev Help:"))
    local msg = string.expand(AppHelp, {
        version = Application.Config['version'],
        isDebug = tostring(Application.Config['debug'])
    })
    print(colorize("string", msg))
end

-- fetch the action argument
local action = tostring(args[2])
-- try to validate the given action
local validActions = {
    ['help'] = {
        method = function(_, params)
            local topic = params[1]
            return ShowHelp(topic)
        end,
        message = "Action: help."
    },
    ['run'] = {
        method = function(_, params)
            local command = table.remove(params, 1)
            local argStr = table.concat(params, " ")
            return env_utils.runProvider(command, argStr)
        end,
        message = "Action: run."
    },
    ['show'] = {
        method = function() pprint(environment_list) end,
        message = "Showing Provider config"
    }
}

-- check if the provided action exists and then wrap it and run it
local next_action
if (not validActions[action]) then
    next_action = function()
        message = colorize("failure", "Error: Unknown Action >")
        print(message, colorize("err", action))
        return
    end
else
    next_action = function(command, params)
        local method = validActions[action].method
        print(colorize("success", " -> " .. validActions[action].message))
        return method(command, params)
    end
end

--- collect any params for our action
local params, max_params = {}, 6
for i = 3, max_params, 1 do
    local param = args[i]
    if DEBUG then print('packing param:', i, param) end
    if (param ~= nil) then table.insert(params, tostring(param)) end
end
next_action(action, params)

Application:Main()
