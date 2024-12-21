local uv = vim.uv

local fzf_lua_config = require("fzf-lua.config")

local Core = require("fzf-lua-jumplist.core")
local Config = require("fzf-lua-jumplist.config")

local _storage = nil

local M = {}

---@param opts FzfLuaJumpConfig
---@return FzfLuaStorage entries
local function get_jumplist(opts)
    local jumplist = vim.fn.getjumplist()[1]
    -- Core.reverse(jumplist)

    local current_buffer = vim.fn.winbufnr(vim.fn.win_getid())

    local entries = {} ---@type FzfLuaStorage

    for _, v in ipairs(jumplist) do
        if current_buffer == v.bufnr then
            local text = vim.api.nvim_buf_get_lines(v.bufnr, v.lnum - 1, v.lnum, false)[1]
            if text then
                text = string.format("%s: %s", v.lnum, text)
                entries[text] = v
            end
        end
    end

    entries = Core.filter(entries, opts)

    return entries
end

---@param selected string The key of FzfLuaStorage
function M.goto_jump(selected)
    local value
    for key, v in pairs(_storage) do
        if key == selected[1] then
            value = v
        end
    end

    local col = (Config.options.start_of_line and value.col) or 1
    vim.api.nvim_win_set_cursor(0, { value.lnum, col })
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

        local value
        for key, v in pairs(_storage) do
            if key == entry_str then
                value = v
            end
        end

        return {
            bufnr = value.bufnr,
            path = uv.cwd(),
            line = value.lnum or 1,
            col = (Config.options.start_of_line and value.col) or 1,
        }
    end

    return Previewer
end

function M.jumplist(fzf_opts)
    _storage = get_jumplist(Config.options)

    local text = {}
    for key, _ in pairs(_storage) do
        table.insert(text, key)
    end

    fzf_opts = fzf_lua_config.normalize_opts(fzf_opts, "jumps")
    if not fzf_opts then
        return
    end

    fzf_opts.prompt = "Jumplist> "
    fzf_opts.actions = { ["enter"] = M.goto_jump }
    fzf_opts.previewer = M.previewer()

    return require("fzf-lua.core").fzf_exec(text, fzf_opts)
end

return M
