---@class FzfLuaJumplist
local M = {}

---@param user_opts? FzfLuaJumpConfig
function M.setup(user_opts)
    local Config = require("fzf-lua-jumplist.config")
    Config.setup(user_opts)

    local jumplist = require("fzf-lua-jumplist.jumplist")
    jumplist.setup()
end

return M
