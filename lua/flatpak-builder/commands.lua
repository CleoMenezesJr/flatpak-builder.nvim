local M = {}

local config = require("flatpak-builder.config")
local utils = require("flatpak-builder.utils")

-- Setup commands
function M.setup()
  -- Check if flatpak-builder is available
  if not utils.check_flatpak_builder() then
    utils.notify(
      "flatpak-builder not found and fallback not available. Please install flatpak-builder or org.flatpak.Builder.",
      vim.log.levels.WARN
    )
  end

  -- Check if flatpak is available
  if not utils.check_flatpak() then
    utils.notify("flatpak not found. Please install flatpak.", vim.log.levels.WARN)
  end
end

-- Build flatpak
function M.build()
  local manifest = utils.get_manifest_file()
  if not manifest then
    utils.notify(
      "No manifest file found. Use :FlatpakSelectManifest to select one.",
      vim.log.levels.ERROR
    )
    return
  end

  local flatpak_builder_cmd = utils.get_flatpak_builder_cmd()
  if not flatpak_builder_cmd then
    utils.notify("flatpak-builder not available.", vim.log.levels.ERROR)
    return
  end

  local build_dir = config.options.build_dir
  local repo_dir = config.options.repo_dir
  local options = table.concat(config.options.builder_options, " ")

  local cmd = string.format(
    "%s %s %s %s --repo=%s",
    flatpak_builder_cmd,
    options,
    build_dir,
    manifest,
    repo_dir
  )

  cmd = utils.apply_executor_prefix(cmd)

  utils.notify("Building flatpak...")
  utils.execute_command(cmd)
end

-- Run flatpak
function M.run()
  local app_id = utils.get_app_id()
  if not app_id then
    utils.notify("Could not determine application ID from manifest.", vim.log.levels.ERROR)
    return
  end

  local flatpak_cmd = utils.get_flatpak_cmd()
  if not flatpak_cmd then
    utils.notify("flatpak not available.", vim.log.levels.ERROR)
    return
  end

  local cmd = string.format("%s run %s", flatpak_cmd, app_id)
  cmd = utils.apply_executor_prefix(cmd)

  utils.notify("Running " .. app_id .. "...")
  utils.execute_command(cmd)
end

-- Build and run flatpak
function M.build_and_run()
  local manifest = utils.get_manifest_file()
  if not manifest then
    utils.notify(
      "No manifest file found. Use :FlatpakSelectManifest to select one.",
      vim.log.levels.ERROR
    )
    return
  end

  local app_id = utils.get_app_id()
  if not app_id then
    utils.notify("Could not determine application ID from manifest.", vim.log.levels.ERROR)
    return
  end

  local flatpak_builder_cmd = utils.get_flatpak_builder_cmd()
  if not flatpak_builder_cmd then
    utils.notify("flatpak-builder not available.", vim.log.levels.ERROR)
    return
  end

  local build_dir = config.options.build_dir
  local repo_dir = config.options.repo_dir
  local options = table.concat(config.options.builder_options, " ")

  local cmd = string.format(
    "%s %s %s %s --repo=%s --run %s",
    flatpak_builder_cmd,
    options,
    build_dir,
    manifest,
    repo_dir,
    app_id
  )

  cmd = utils.apply_executor_prefix(cmd)

  utils.notify("Building and running flatpak...")
  utils.execute_command(cmd)
end

-- Stop flatpak
function M.stop()
  local app_id = utils.get_app_id()
  if not app_id then
    utils.notify("Could not determine application ID from manifest.", vim.log.levels.ERROR)
    return
  end

  local flatpak_cmd = utils.get_flatpak_cmd()
  if not flatpak_cmd then
    utils.notify("flatpak not available.", vim.log.levels.ERROR)
    return
  end

  local cmd = string.format("%s kill %s", flatpak_cmd, app_id)
  cmd = utils.apply_executor_prefix(cmd)

  utils.notify("Stopping " .. app_id .. "...")
  utils.execute_command(cmd)
end

-- Clean build
function M.clean()
  local build_dir = config.options.build_dir
  local repo_dir = config.options.repo_dir

  local cmd = string.format("rm -rf %s %s .flatpak-builder", build_dir, repo_dir)
  cmd = utils.apply_executor_prefix(cmd)

  utils.notify("Cleaning build directories...")
  utils.execute_command(cmd)
end

-- Update dependencies
function M.update_dependencies()
  local manifest = utils.get_manifest_file()
  if not manifest then
    utils.notify(
      "No manifest file found. Use :FlatpakSelectManifest to select one.",
      vim.log.levels.ERROR
    )
    return
  end

  local flatpak_builder_cmd = utils.get_flatpak_builder_cmd()
  if not flatpak_builder_cmd then
    utils.notify("flatpak-builder not available.", vim.log.levels.ERROR)
    return
  end

  local build_dir = config.options.build_dir
  local cmd = string.format("%s --download-only %s %s", flatpak_builder_cmd, build_dir, manifest)
  cmd = utils.apply_executor_prefix(cmd)

  utils.notify("Updating dependencies...")
  utils.execute_command(cmd)
end

-- Export bundle
function M.export_bundle()
  local app_id = utils.get_app_id()
  if not app_id then
    utils.notify("Could not determine application ID from manifest.", vim.log.levels.ERROR)
    return
  end

  local flatpak_cmd = utils.get_flatpak_cmd()
  if not flatpak_cmd then
    utils.notify("flatpak not available.", vim.log.levels.ERROR)
    return
  end

  local repo_dir = config.options.repo_dir
  local bundle_name = app_id .. ".flatpak"

  local cmd = string.format("%s build-bundle %s %s %s", flatpak_cmd, repo_dir, bundle_name, app_id)
  cmd = utils.apply_executor_prefix(cmd)

  utils.notify("Exporting bundle...")
  utils.execute_command(cmd)
end

-- Select manifest file
function M.select_manifest()
  local manifests = utils.find_manifest_files()

  if #manifests == 0 then
    utils.notify("No manifest files found in current directory.", vim.log.levels.WARN)
    return
  end

  if #manifests == 1 then
    -- utils.set_manifest_file(manifests[1])
    utils.notify("Selected manifest: " .. vim.fn.fnamemodify(manifests[1], ":t"))
    return
  end

  -- Multiple manifests found, let user choose
  vim.ui.select(manifests, {
    prompt = "Select manifest file:",
    format_item = function(item)
      return vim.fn.fnamemodify(item, ":t")
    end,
  }, function(choice)
    if choice then
      -- utils.set_manifest_file(choice)
      utils.notify("Selected manifest: " .. vim.fn.fnamemodify(choice, ":t"))
    end
  end)
end

return M
