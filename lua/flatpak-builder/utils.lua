local M = {}

local config = require("flatpak-builder.config")

-- Get current working directory
function M.get_cwd()
  return vim.fn.getcwd()
end

-- Find manifest files in current directory
function M.find_manifest_files()local cwd = M.get_cwd()
local manifests = {}

-- Get manifest candidates with specific extensions
local manifesto_candidates = {}
for file in io.popen("cd " .. cwd .. " && ls | grep -E '\\.(json|yaml|yml)$'"):lines() do
  table.insert(manifesto_candidates, cwd .. "/" .. file)
end

-- Check for files with reversed domain name pattern
for _, file in ipairs(manifesto_candidates) do
  local basename = vim.fn.fnamemodify(file, ":t")
  local last_dot_index = basename:match(".*()%.")
  if last_dot_index then
    local file_without_extension = basename:sub(1, last_dot_index - 1)

    local is_reversed_domain_name =
      string.match(file_without_extension, "^([a-zA-Z0-9-]+)%.([a-zA-Z0-9-]+)%.([a-zA-Z]+)$")

    if is_reversed_domain_name then
      table.insert(manifests, file)
    end
  end
end

-- Fallback to old logic if no reversed domain files found
if #manifests == 0 then
  local patterns = {
    "*.json",
    "*.yaml",
    "*.yml",
  }

  for _, pattern in ipairs(patterns) do
    local files = vim.fn.glob(cwd .. "/" .. pattern, false, true)
    for _, file in ipairs(files) do
      local basename = vim.fn.fnamemodify(file, ":t")
      -- Check if it looks like a flatpak manifest
      if basename:match("manifest") or basename:match("flatpak") or basename:match("app") then
        table.insert(manifests, file)
      end
    end
  end
end

return manifests
end

-- Get current manifest file
function M.get_manifest_file()
  if config.options.manifest_file and vim.fn.filereadable(config.options.manifest_file) == 1 then
    return config.options.manifest_file
  end

  if config.options.auto_detect then
    local manifests = M.find_manifest_files()
    if #manifests > 0 then
      return manifests[1]
    end
  end

  return nil
end

-- Set manifest file
function M.set_manifest_file(file)
  config.options.manifest_file = file
end

-- Get application ID from manifest
function M.get_app_id()
  local manifest = M.get_manifest_file()
  if not manifest then
    return nil
  end

  local content = vim.fn.readfile(manifest)
  local text = table.concat(content, "\n")

  -- Try to parse as JSON first
  local ok, data = pcall(vim.fn.json_decode, text)
  if ok and data.id then
    return data.id
  elseif ok and data["app-id"] then
    return data["app-id"]
  end

  -- Fallback: try to find id in text
  local app_id = text:match('"id"%s*:%s*"([^"]+)"') or text:match('"app%-id"%s*:%s*"([^"]+)"')
  return app_id
end

-- Show notification
function M.notify(msg, level)
  if config.options.notify then
    vim.notify(msg, level or vim.log.levels.INFO, { title = "Flatpak Builder" })
  end
end

-- Execute command in terminal
function M.execute_command(cmd, opts)
  opts = opts or {}

  local term_cmd
  if config.options.terminal.position == "horizontal" then
    term_cmd = config.options.terminal.size .. "split | terminal " .. cmd
  elseif config.options.terminal.position == "vertical" then
    term_cmd = "vsplit | terminal " .. cmd
  else
    term_cmd = "terminal " .. cmd
  end

  vim.cmd(term_cmd)

  if opts.close_on_success then
    -- TODO: Implement close on success logic
  end
end

-- Check if a command exists
function M.command_exists(cmd)
  local result = vim.fn.system("which " .. cmd .. " 2>/dev/null")
  return vim.v.shell_error == 0
end

-- Get flatpak-builder command
function M.get_flatpak_builder_cmd()
  -- Use custom executor if configured
  if config.options.executors.flatpak_builder then
    return config.options.executors.flatpak_builder
  end

  -- Try to find flatpak-builder
  if M.command_exists("flatpak-builder") then
    return "flatpak-builder"
  end

  -- Fallback to flatpak run org.flatpak.Builder
  if M.command_exists("flatpak") then
    return "flatpak run org.flatpak.Builder"
  end

  return nil
end

-- Get flatpak command
function M.get_flatpak_cmd()
  -- Use custom executor if configured
  if config.options.executors.flatpak then
    return config.options.executors.flatpak
  end

  -- Try to find flatpak
  if M.command_exists("flatpak") then
    return "flatpak"
  end

  return nil
end

-- Apply executor prefix if configured
function M.apply_executor_prefix(cmd)
  if config.options.executors.executor_prefix then
    return config.options.executors.executor_prefix .. " " .. cmd
  end
  return cmd
end

-- Check if flatpak-builder is available
function M.check_flatpak_builder()
  local cmd = M.get_flatpak_builder_cmd()
  return cmd ~= nil
end

-- Check if flatpak is available
function M.check_flatpak()
  local cmd = M.get_flatpak_cmd()
  return cmd ~= nil
end

return M
