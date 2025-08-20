if vim.g.loaded_flatpak_builder then
  return
end
vim.g.loaded_flatpak_builder = 1

-- Create commands
vim.api.nvim_create_user_command('FlatpakBuildAndRun', function()
  require('flatpak-builder').build_and_run()
end, { desc = 'Build and run flatpak' })

vim.api.nvim_create_user_command('FlatpakBuild', function()
  require('flatpak-builder').build()
end, { desc = 'Build flatpak' })

vim.api.nvim_create_user_command('FlatpakRun', function()
  require('flatpak-builder').run()
end, { desc = 'Run flatpak' })

vim.api.nvim_create_user_command('FlatpakStop', function()
  require('flatpak-builder').stop()
end, { desc = 'Stop flatpak' })

vim.api.nvim_create_user_command('FlatpakClean', function()
  require('flatpak-builder').clean()
end, { desc = 'Clean flatpak build' })

vim.api.nvim_create_user_command('FlatpakUpdateDependencies', function()
  require('flatpak-builder').update_dependencies()
end, { desc = 'Update flatpak dependencies' })

vim.api.nvim_create_user_command('FlatpakExportBundle', function()
  require('flatpak-builder').export_bundle()
end, { desc = 'Export flatpak bundle' })

vim.api.nvim_create_user_command('FlatpakSelectManifest', function()
  require('flatpak-builder').select_manifest()
end, { desc = 'Select flatpak manifest' })
