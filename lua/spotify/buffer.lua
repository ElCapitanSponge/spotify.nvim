local Utils = require("spotify.utils")
local SpotifyGroup = require("spotify.autocmd")

local Buffer = {}

local SPOTIFY_MENU = "===Spotify-Menu==="

local spotify_menu_id = math.random(1000000)

local function get_menu_name()
    spotify_menu_id = spotify_menu_id + 1
    return SPOTIFY_MENU .. spotify_menu_id
end

function Buffer:run_toggle(key)
    local spotify = require("spotify")
    spotify.logger:add("Toggled by keymap '" .. key .."'")
    spotify.ui:toggle()
end

---@param bufnr number
function Buffer:setup_cmds_and_keymaps(bufnr)
    local curr_file = vim.api.nvim_buf_get_name(0)

    if vim.api.nvim_buf_get_name(bufnr) == "" then
        vim.api.nvim_buf_set_name(bufnr, get_menu_name())
    end

    vim.api.nvim_set_option_value(
        "filetype",
        "Spotify",
        {
            buf = bufnr
        })

    vim.api.nvim_set_option_value(
        "buftype",
        "acwrite",
        {
            buf = bufnr
        })

    vim.keymap.set("n", "q", function()
        Buffer:run_toggle("q")
    end, { buffer = bufnr, silent = true })

    vim.keymap.set("n", "Esc", function()
        Buffer:run_toggle("Esc")
    end, { buffer = bufnr, silent = true })

    vim.api.nvim_create_autocmd({ "BufWriteCmd" },{
        group = SpotifyGroup,
        buffer = bufnr,
        callback = function()
            --vim.schedule(function()
            require("spotify").logger:add("Toggle display by BufWriteCmd")
            require("spotify").ui:toggle()
            --end)
        end
    })

    vim.api.nvim_create_autocmd({ "BufLeave" },{
        group = SpotifyGroup,
        buffer = bufnr,
        callback = function()
            --vim.schedule(function()
            require("spotify").logger:add("Toggle display by BufLeave")
            require("spotify").ui:toggle()
            --end)
        end
    })
end

---@parm bufnr number
function Buffer:get_contents(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
    local indices = {}

    for _, line in pairs(lines) do
        if not Utils.is_white_space(line) then
            table.insert(indices, line)
        end
    end

    return indices
end

function Buffer:set_contents(bufnr, contents)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, contents)
end

return Buffer
