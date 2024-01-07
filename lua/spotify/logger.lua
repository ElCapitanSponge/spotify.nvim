local utils = require("spotify.utils")

---@class SpotifyLog
---@field lines string[]
---@field max_lines number
---@field enabled boolean
local SpotifyLog = {}

SpotifyLog.__index = SpotifyLog

function SpotifyLog:new()
    local log = setmetatable({
        lines = {},
        max_lines = 100,
        enabled = true,
    }, self)

    return log
end

function SpotifyLog:disable()
    self.enabled = false
end

function SpotifyLog:enable()
    self.enabled = true
end

function SpotifyLog:clear()
    self.lines = {}
end

function SpotifyLog:get()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, self.lines)
    vim.api.nvim_win_set_buf(0, bufnr)
end

---@vararg any
function SpotifyLog:add(...)
    local processed = {}
    for i = 1, select("#", ...) do
        local item = select(i, ...)
        if type(item) == "table" then
            item = vim.inspect(item)
        end
        table.insert(processed, item)
    end

    local lines = {}
    for _, line in ipairs(processed) do
        local split = utils.split(line, "\n")
        for _, l in ipairs(split) do
            if not utils.is_white_space(l) then
                local ll = utils.trim(utils.remove_duplicate_whitespace(l))
                table.insert(lines, ll)
            end
        end
    end

    table.insert(self.lines, table.concat(lines, " "))

    while #self.lines > self.max_lines do
        table.remove(self.lines, 1)
    end
end

return SpotifyLog:new()
