local M = require("flatpak-builder.main")
local C = require("flatpak-builder.config")

local FlatpakBuilder = {}

--- Toggle the plugin by calling the `enable`/`disable` methods respectively.
function FlatpakBuilder.toggle()
    if _G.FlatpakBuilder.config == nil then
        _G.FlatpakBuilder.config = C.options
    end

    M.toggle("publicAPI_toggle")
end

--- Initializes the plugin, sets event listeners and internal state.
function FlatpakBuilder.enable()
    if _G.FlatpakBuilder.config == nil then
        _G.FlatpakBuilder.config = C.options
    end

    M.enable("publicAPI_enable")
end

--- Disables the plugin, clear highlight groups and autocmds, closes side buffers and resets the internal state.
function FlatpakBuilder.disable()
    M.disable("publicAPI_disable")
end

-- setup FlatpakBuilder options and merge them with user provided ones.
function FlatpakBuilder.setup(opts)
    _G.FlatpakBuilder.config = C.setup(opts)
end

_G.FlatpakBuilder = FlatpakBuilder

return _G.FlatpakBuilder
