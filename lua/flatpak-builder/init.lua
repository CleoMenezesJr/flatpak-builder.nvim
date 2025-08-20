local M = {}

local config = require('flatpak-builder.config')
local commands = require('flatpak-builder.commands')
local utils = require('flatpak-builder.utils')

-- Setup function
function M.setup(opts)
  config.setup(opts)
  commands.setup()
end

-- Export main functions
M.build_and_run = commands.build_and_run
M.build = commands.build
M.run = commands.run
M.stop = commands.stop
M.clean = commands.clean
M.update_dependencies = commands.update_dependencies
M.export_bundle = commands.export_bundle
M.select_manifest = commands.select_manifest

return M
