-- -- You can use this loaded variable to enable conditional parts of your plugin.
-- if _G.FlatpakBuilderLoaded then
--     return
-- end
--
-- _G.FlatpakBuilderLoaded = true
--
-- -- Useful if you want your plugin to be compatible with older (<0.7) neovim versions
-- if vim.fn.has("nvim-0.7") == 0 then
--     vim.cmd("command! FlatpakBuilder lua require('flatpak-builder').toggle()")
-- else
--     vim.api.nvim_create_user_command("FlatpakBuilder", function()
--         require("flatpak-builder").toggle()
--     end, {})
-- end
-- print("hello world")
ManifestoData = {}
FlatpakSpawn = os.execute("which flatpak-spawn")

local function list_files_with_extensions()
    local manifesto_candidates = {}
    for file in io.popen([[ls | grep -E '.(json|ymal|yml)$']]):lines() do
        table.insert(manifesto_candidates, file)
    end

    GetFileWithReversedDomain(manifesto_candidates)
end

function GetFileWithReversedDomain(candidates)
    for _, file in ipairs(candidates) do
        local last_dot_index = file:match(".*()%.")
        local file_without_extension = file:sub(1, last_dot_index - 1)

        local is_reversed_domain_name =
            string.match(file_without_extension, "^([a-zA-Z0-9-]+)%.([a-zA-Z0-9-]+)%.([a-zA-Z]+)$")

        if is_reversed_domain_name then
            ManifestoData = { filename = file_without_extension, manifesto = file }
        end
    end
end

local function build()
    local command = "flatpak run org.flatpak.Builder build "
        .. ManifestoData.filename
        .. " --user --install --force-clean"
    if FlatpakSpawn == 0 then
        command = "flatpak-spawn --host " .. command
    end

    os.execute(command)
end

local function run()
    local command = "flatpak run " .. ManifestoData.manifesto
    if FlatpakSpawn == 0 then
        command = "flatpak-spawn --host " .. command
    end

    os.execute(command)
end

local function build_and_run()
    build()
    run()
end

return {
    build = build,
    run = run,
    build_and_run = build_and_run,
}
