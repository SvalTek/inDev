--[[ --
  ==========================================================================================
    File: environment_utils.lua	Author: theros#7648
    Description: environment_utils helper methods
    Created:  2021-06-08T09:32:27.812Z
    Modified: 2021-06-13T19:40:09.224Z
    vscode-fold=2
  ==========================================================================================
--]] --
local devEnv = require("classes.devEnv")

local function loadEnvironments()
    local environments = {}
    for i, environment in ipairs(Application.Environments) do
        local new_env = devEnv(environment)
        if new_env then table.insert(environments, i, new_env) end
    end
    return environments ---@type table<number,devEnv>
end

local function doesProvide(provider, command)
    if (not provider) or (type(provider['provides']) ~= "table") then
        return false, "invalid provider"
    end
    local provides = false
    for _, v in ipairs(provider['provides']) do
        if (v == command) then provides = true end
    end
    return provides
end

local function findProvider(command)
    local environments = loadEnvironments()
    for _, environment in ipairs(environments) do
        if doesProvide(environment, command) then
            return environment ---@type devEnv
        end
    end
end

local function createBindmountParams(bindmounts)
    local arg_str = ""
    for _, bindmount in ipairs(bindmounts) do
        arg_str = arg_str .. " " .. string.expand(DOCKER_BINDMOUNT_SYNTAX, {
            bindmount_src = bindmount.source,
            bindmount_dest = bindmount.target
        })
    end
    return arg_str
end

local function runEnvironment(provider, command, argStr)
    local cmdline = command .. " " .. argStr

    local bindmount_args = createBindmountParams(provider.bindmounts)

    local opts = {
        LAUNCH_OPTS = "" .. bindmount_args,
        WORK_DIR = provider.workdir or "/tmp",
        IMAGE = provider.image,
        COMMANDLINE = cmdline
    }
    local launchCommand = string.expand(DOCKER_LAUNCH_CMD, opts)
    print(launchCommand)
    os.execute(launchCommand)
end

local function runProvider(command, ...)
    -- try to find a provider for `command`
    local provider = findProvider(command)
    if provider then
        print('found provider ', provider.name)
        return runEnvironment(provider, command, ...)
    else
        return error("provider not found for command: " .. command)
    end
end

return {
    loadEnvironments = loadEnvironments,
    findProvider = findProvider,
    runProvider = runProvider
}
