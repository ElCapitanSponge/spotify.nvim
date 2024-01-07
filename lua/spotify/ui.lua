local Buffer = require("spotify.buffer")
local Logger = require("spotify.logger")

---@class SpotifyToggleOptions
---@field border? any this value is passed directly into nvim_open_win
---@field title_pos? any this value is passed directly into nvim_open_win
---@field title? string this value is passed directly into nvim_open_win
---@field fallback_width? number this is the default width for the window
---@field width_ratio? number the ratio of the window
---@field max_width? number the max width the window can border
---@return SpotifyToggleOptions
local function toggle_options(config)
    return vim.tbl_extend("force", {
        fallback_width = 80,
        width_ratio = 1.33,
    }, config or {})
end

---@class SpotifyUI
---@field win_id number
---@field bufnr number
---@field settings SpotifySettings
local SpotifyUI = {}

SpotifyUI.__index = SpotifyUI

---@param settings SpotifySettings
---@return SpotifyUI
function SpotifyUI:new(settings)
    return setmetatable({
        win_id = nil,
        bufnr = nil,
        settings = settings,
    }, self)
end

function SpotifyUI:close()
    if self.closing then
        return
    end

    self.closing = true
    Logger:add(
        "UI:close ~ win_id and bufnr",
        {
            win_id = self.win_id,
            bufnr = self.bufnr,
        }
    )
end

function SpotifyUI:toggle()
    -- TODO: Implement the toggling of the window display
end

---@param toggle_opts SpotifyToggleOptions
---@return number,number
function SpotifyUI:_create_window(toggle_opts)
    local win = vim.api.nvim_list_uis()
    local width = toggle_opts.fallback_width

    if #win > 0 then
        width = math.floor(win[1].width * toggle_opts.width_ratio)
    end

    if toggle_opts.max_width and width > toggle_opts.max_width then
        width = toggle_opts.max_width
    end

    local height = width * toggle_opts.width_ratio
    local bufnr = vim.api.create_buf(false, true)
    local win_id = vim.api.nvim_open_win(
        bufnr,
        true,
        {
            relative = "editor",
            title = toggle_opts.title or "Spotify",
            title_pos = toggle_opts.title_pos or "center",
            row = math.floor(((vim.o.lines - height) / 2) - 1),
            col = math.floor((vim.o.columns - width) / 2),
            width = width,
            height = height,
            style = "minimal",
            border = toggle_opts.border or "single",
        })

    if win_id == 0 then
        Logger:add("UI:_create_window failed to create the window. win_id returned 0")
        self.bufnr = bufnr
        self:close()
        error("Failed to close the window")
    end

    Buffer:setup_cmds_and_keymaps(bufnr)

    self.win_id = win_id
    vim.api.nvim_set_option_value(
        "number",
        true, {
            win = win_id,
        })

    return win_id, bufnr
end

---@param settings SpotifySettings
function SpotifyUI:configure(settings)
    self.settings = settings
end

return SpotifyUI
