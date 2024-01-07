local Log = require("spotify.logger")
local Ui = require("spotify.ui")
local Data = require("spotify.data")
local Config = require("spotify.config")

---@class Spotify
---@field config SpotifyConfig
---@field ui SpotifyUI
---@field data SpotifyData
---@field logger SpotifyLog
local Spotify = {}

Spotify.__index = Spotify

function Spotify:new()
    local config = Config:get_default()

    local spotify = setmetatable({
        config = config,
        data = Data.Data:new(),
        logger = Log,
        ui = Ui:new(config.settings)
    }, self)

    return spotify
end

function Spotify:info()
    return {

    }
end

function Spotify:dump()
    return self.data._data
end

function Spotify:_debug_reset()
    require("plenary.reload").reload_module("spotify")
end

local spotify = Spotify:new()

---@param self Spotify
---@param partial_config SpotifyPartialConfig
---@return Spotify
function Spotify.setup(self, partial_config)
    if self ~= spotify then
        ---@diagnostic disable-next-line: cast-local-type
        partial_config = self
        self = spotify
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    self.config = Config:merge(partial_config, self.config)
    self.ui:configure(self.config.settings)

    return self
end

return spotify
