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
    local spotify = setmetatable({
        config = Config:new(),
        data = Data:new(),
        logger = Log,
        ui = Ui:new()
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
        partial_config = self
        self = spotify
    end

    self.config = Config.merge_config(partial_config, self.config)
    self.ui:configure(self.config.settings)

    return self
end

return spotify
