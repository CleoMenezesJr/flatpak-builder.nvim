local M = {}

-- Default configuration
M.defaults = {
  -- Build directory
  build_dir = 'build',
  -- Repository directory
  repo_dir = 'repo',
  -- Default manifest file
  manifest_file = nil,
  -- Auto-detect manifest files
  auto_detect = true,
  -- Flatpak-builder command options
  builder_options = {
    '--force-clean',
    '--sandbox',
    '--user',
    '--install',
    '--ccache',
  },
  -- Terminal options
  terminal = {
    position = 'horizontal',
    size = 15,
  },
  -- Notifications
  notify = true,
  -- Executors configuration
  executors = {
    -- Flatpak-builder binary/command
    flatpak_builder = nil, -- Auto-detect if nil
    -- Flatpak binary/command
    flatpak = nil, -- Auto-detect if nil
    -- Custom executor prefix (e.g., "flatpak-spawn --host")
    executor_prefix = nil,
  },
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend('force', M.defaults, opts or {})
end

return M
