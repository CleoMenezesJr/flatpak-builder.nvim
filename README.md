## Configuration

```lua
require("flatpak-builder").setup({
  -- Build directory (default: "build")
  build_dir = "build",

  -- Repository directory (default: "repo")
  repo_dir = "repo",

  -- Specific manifest file (default: nil - auto-detect)
  manifest_file = nil,

  -- Auto-detect manifest files (default: true)
  auto_detect = true,

  -- Flatpak-builder command options
  builder_options = {
    "--force-clean",
    "--sandbox",
    "--user",
    "--install",
    "--ccache",
  },

  -- Terminal configuration
  terminal = {
    position = "horizontal", -- "horizontal", "vertical", or "float"
    size = 15,
  },

  -- Show notifications (default: true)
  notify = true,

  -- Executors configuration
  executors = {
    -- Custom flatpak-builder command (default: auto-detect)
    -- If not found, falls back to "flatpak run org.flatpak.Builder"
    flatpak_builder = nil, -- or "flatpak run org.flatpak.Builder"

    -- Custom flatpak command (default: auto-detect)
    flatpak = nil, -- or custom path/command

    -- Executor prefix for all commands (e.g., for toolbox/distrobox)
    executor_prefix = nil, -- or "flatpak-spawn --host" or "toolbox run"
  },
})
```

## Executor Examples

### Using inside a Flatpak sandbox (Flatpak development environment):
```lua
require("flatpak-builder").setup({
  executors = {
    executor_prefix = "flatpak-spawn --host",
  },
})
```

### Using inside a Toolbox/Distrobox container:
```lua
require("flatpak-builder").setup({
  executors = {
    executor_prefix = "flatpak-spawn --host",
    -- or
    -- executor_prefix = "toolbox run",
  },
})
```

### Using org.flatpak.Builder instead of system flatpak-builder:
```lua
require("flatpak-builder").setup({
  executors = {
    flatpak_builder = "flatpak run org.flatpak.Builder",
  },
})
```

### Using custom paths:
```lua
require("flatpak-builder").setup({
  executors = {
    flatpak_builder = "/usr/local/bin/flatpak-builder",
    flatpak = "/usr/local/bin/flatpak",
  },
})
```
