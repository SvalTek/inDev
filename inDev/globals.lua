--[[ --
  ==========================================================================================
    File: globals.lua	Author: theros#7648
    Description: inDev common globals
    Created:  2021-06-08T05:05:47.710Z
    Modified: 2021-06-13T17:40:50.468Z
    vscode-fold=2
  ==========================================================================================
--]] --
local exports

-- ──────────────────────────────────────────────────────────── GLOBAL CONFIG ─────

--- The command used to Launch a docker container
DOCKER_LAUNCH_CMD =
    [[docker run ${LAUNCH_OPTS} -w ${WORK_DIR} -i -t ${IMAGE} ${COMMANDLINE}]]

--- syntax used to add a bindmount to the launch command
DOCKER_BINDMOUNT_SYNTAX =
    [[--mount type=bind,src=${bindmount_src},dst=${bindmount_dest}]]

-- ────────────────────────────────────────────────────────────────────────────────



-- ──────────────────────────────────────────────────────────────── CONSTANTS ─────
local CONSTANTS = {
  IS_DEBUG_BUILD = false
}
_G['CONSTANTS'] = readOnly(CONSTANTS, "GLOBAL CONSTANTS")

return exports