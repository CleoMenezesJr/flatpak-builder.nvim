local D = require("flatpak-builder.util.debug")

local FlatpakBuilder = {}

--- Your plugin configuration with its default values.
---
--- Default values:
---@eval return MiniDoc.afterlines_to_code(MiniDoc.current.eval_section)
FlatpakBuilder.options = {
    -- Prints useful logs about what event are triggered, and reasons actions are executed.
    debug = false,
}

---@private
local defaults = vim.deepcopy(FlatpakBuilder.options)

--- Defaults FlatpakBuilder options by merging user provided options with the default plugin values.
---
---@param options table Module config table. See |FlatpakBuilder.options|.
---
---@private
function FlatpakBuilder.defaults(options)
    local tde = function(t1, t2)
        return vim.deepcopy(vim.tbl_deep_extend("keep", t1 or {}, t2 or {}))
    end

    FlatpakBuilder.options = tde(options, defaults)

    -- let your user know that they provided a wrong value, this is reported when your plugin is executed.
    assert(
        type(FlatpakBuilder.options.debug) == "boolean",
        "`debug` must be a boolean (`true` or `false`)."
    )

    return FlatpakBuilder.options
end

--- Define your flatpak-builder setup.
---
---@param options table Module config table. See |FlatpakBuilder.options|.
---
---@usage `require("flatpak-builder").setup()` (add `{}` with your |FlatpakBuilder.options| table)
function FlatpakBuilder.setup(options)
    FlatpakBuilder.options = FlatpakBuilder.defaults(options or {})

    -- Useful for later checks that requires nvim 0.9 features at runtime.
    FlatpakBuilder.options.hasNvim9 = vim.fn.has("nvim-0.9") == 1

    D.warnDeprecation(FlatpakBuilder.options)

    return FlatpakBuilder.options
end

return FlatpakBuilder
