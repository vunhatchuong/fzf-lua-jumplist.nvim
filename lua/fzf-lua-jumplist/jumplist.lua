local fzf_lua_config = require("fzf-lua.config")

local Config = require("fzf-lua-jumplist.config")

local M = {}

M.line_pattern = "^(%d+):(%d+)%s(.+)$"

---@param opts FzfLuaJumpConfig
---@return FzfLuaStorage entries
local function get_jumplist(opts)
    local jumplist = vim.fn.getjumplist()[1]

    local current_buffer = vim.fn.winbufnr(vim.fn.win_getid())

    local entries = {} ---@type FzfLuaStorage

    for _, jump in ipairs(jumplist) do
        if current_buffer == jump.bufnr then
            local line = vim.api.nvim_buf_get_lines(jump.bufnr, jump.lnum - 1, jump.lnum, false)[1]
            if line then
                line = string.format("%s:%-4s %s", jump.lnum, jump.col + 1, line)
                table.insert(entries, 1, line)
            end
        end
    end

    entries = require("fzf-lua-jumplist.core").filter(entries, opts)

    return entries
end

---@param selected string The key of FzfLuaStorage
function M.goto_jump(selected)
    local lnum, col, _ = selected[1]:match(M.line_pattern)
    col = (not Config.options.start_of_line and col) or 1

    vim.api.nvim_win_set_cursor(0, { tonumber(lnum), tonumber(col) - 1 })
end

function M.previewer()
    local previewer = require("fzf-lua.previewer.builtin")

    local Previewer = previewer.buffer_or_file:extend()
    function Previewer:new(o, opts, fzf_win)
        Previewer.super.new(self, o, opts, fzf_win)
        return self
    end

    function Previewer:parse_entry(entry_str)
        if entry_str == "" then
            return {}
        end

        local lnum, col, _ = entry_str:match(M.line_pattern)
        return {
            bufnr = self.win.src_bufnr,
            path = vim.api.nvim_buf_get_name(self.win.src_bufnr),
            line = tonumber(lnum) or 1,
            col = (not Config.options.start_of_line and col) or 1,
        }
    end

    return Previewer
end

function M.jumplist(fzf_opts)
    local entries = get_jumplist(Config.options)

    fzf_opts = fzf_lua_config.normalize_opts(fzf_opts, "jumps")
    if not fzf_opts then
        return
    end

    fzf_opts.prompt = "Jumplist> "
    fzf_opts.actions = { ["enter"] = M.goto_jump }
    fzf_opts.previewer = M.previewer()

    return require("fzf-lua.core").fzf_exec(entries, fzf_opts)
end

function M.setup()
    M.jumplist = M.jumplist

    vim.api.nvim_create_user_command("FzfLuaJumplist", function()
        M.jumplist()
    end, {})
end

return M
