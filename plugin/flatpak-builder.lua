-- -- You can use this loaded variable to enable conditional parts of your plugin.
-- if _G.FlatpakBuilderLoaded then
--     return
-- end
--
-- _G.FlatpakBuilderLoaded = true

-- Useful if you want your plugin to be compatible with older (<0.7) neovim versions
-- if vim.fn.has("nvim-0.7") == 0 then
--     vim.cmd("command! FlatpakBuilder lua require('flatpak-builder').toggle()")
-- else
--     vim.api.nvim_create_user_command("FlatpakBuilder", function()
--         require("flatpak-builder").toggle()
--     end, {})
-- end
-- print("hello world")

M = {}
ManifestoData = {}
FlatpakSpawn = os.execute("which flatpak-spawn")

function M.list_files_with_extensions()
  local manifesto_candidates = {}
  for file in io.popen([[ls | grep -E '.(json|ymal|yml)$']]):lines() do
    table.insert(manifesto_candidates, file)
  end

  M.get_file_with_reversed_domain(manifesto_candidates)
end

function M.get_file_with_reversed_domain(candidates)
  for _, file in ipairs(candidates) do
    local last_dot_index = file:match(".*()%.")
    local file_without_extension = file:sub(1, last_dot_index - 1)

    local is_reversed_domain_name =
      string.match(file_without_extension, "^([a-zA-Z0-9-]+)%.([a-zA-Z0-9-]+)%.([a-zA-Z]+)$")

    if is_reversed_domain_name then
      ManifestoData = { filename = file_without_extension, manifesto = file }
    end
  end
  print(ManifestoData.filename)
  print(ManifestoData.manifesto)
end

function M.setup()
  M.list_files_with_extensions()
end

function M.build()
  local command = "flatpak run org.flatpak.Builder build "
    .. ManifestoData.filename
    .. " --user --install --force-clean"
  if FlatpakSpawn == 0 then
    command = "flatpak-spawn --host " .. command
  end

  os.execute(command)
end

function M.run()
  local command = "flatpak run " .. ManifestoData.manifesto
  if FlatpakSpawn == 0 then
    command = "flatpak-spawn --host " .. command
  end

  os.execute(command)
end

function M.build_and_run()
  M.build()
  M.run()
end

return M
