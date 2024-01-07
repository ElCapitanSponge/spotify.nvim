local Logger = require("spotify.logger")
local Path = require("plenary.path")
local function normalize_path(buf_name, root)
    return Path:new(buf_name):make_relative(root)
end

local CONFIG = {}

---@class SpotifyDefault

---@class SpotifyPartialDefault

---@class SpotifySettings

---@class SpotifyPartialSettings

---@class SpotifyConfig
---@field settings SpotifySettings
---@field default SpotifyDefault
---@field [string] SpotifyPartialDefault

---@class SpotifyPartialConfig
---@field settings? SpotifyPartialSettings
---@field default? SpotifyPartialDefault
---@field [string] SpotifyPartialDefault

---@param config SpotifyConfig Spotify configuration
---@param name string Name of the default configuration field
---@return SpotifyPartialDefault
function CONFIG:get_config(config, name)
    return vim.tbl_extend("force", {}, config.default, config[name] or {})
end

---@param config SpotifyConfig Spotify configuration
---@param name string Name of the settings configuration field
---@return SpotifyPartialSettings
function CONFIG:get_setting(config, name)
    return vim.tbl_extend("force", {}, config.settings, config[name] or {})
end

---@param config SpotifyConfig Spotify configuration
---@param setting string Name of the custom setting to be used
---@param name string Name of the custom setting field
---@return SpotifyPartialDefault
function CONFIG:get_custom_setting(config, setting, name)
    return vim.tbl_extend("force", {}, config[setting], config[name] or {})
end

---@return SpotifyConfig
function CONFIG:get_default()
    return {
        settings = {},
        default = {},
    }
end

---@param partial_config SpotifyPartialConfig
---@param latest_config SpotifyConfig?
---@return SpotifyConfig
function CONFIG:merge(partial_config, latest_config)
    partial_config = partial_config or {}
    local config = latest_config or CONFIG:get_default()
    for key, value in pairs(partial_config) do
        config[key] = vim.tbl_extend("force", config[key] or {}, value)
    end
    return config
end

return CONFIG
