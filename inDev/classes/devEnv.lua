--[[ --
  ==========================================================================================
    File: devEnv.lua	Author: theros#7648
    Description: inDev Developer Environment Schema Implementation
    Created:  2021-06-08T05:29:49.087Z
    Modified: 2021-06-09T01:27:45.452Z
    vscode-fold=2
  ==========================================================================================
--]] --
local Class = require("Classy")

---@class devEnv
---@field name        string                    Environment Name.
---@field env_type    string                    devEnv Environment Type (usualy docker).
---@field image       string                    docker image.
---@field provides    table<number,string>      list of commands this environment provides.
---@field bindmounts  table<number,table>       list of this environments bindmounts.
local devEnv = Class('devEnv',{})
devEnv.env_type = "docker"

function devEnv:new(schema)
    if assert_arg(1, schema, 'table') then return false end
    self.name = schema['name']
    self.image = schema['image']
    self.provides = schema['provides']
    self.bindmounts = schema['bindmounts']
    self.workdir = schema['workdir']
    return self
end

return devEnv
