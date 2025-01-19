local line_pattern = require("fzf-lua-jumplist.jumplist").line_pattern

local M = {}

--- Filter based on opts
---
---@param entries FzfLuaStorage
---@param opts FzfLuaJumpConfig
---@return FzfLuaStorage results
function M.filter(entries, opts)
    local result = {} ---@type FzfLuaStorage

    if opts.line_distance_threshold then
        for _, entry in ipairs(entries) do
            local should_add = true

            local lnum, _, _ = entry:match(line_pattern)

            for _, added_jump in ipairs(result) do
                local added_lnum, _, _ = added_jump:match(line_pattern)
                if math.abs(lnum - added_lnum) <= opts.line_distance_threshold then
                    should_add = false
                    break
                end
            end

            if should_add then
                table.insert(result, entry)
            end
        end
    else
        result = { unpack(entries) }
    end

    if opts.max_result and #result > opts.max_result then
        result = vim.list_slice(result, 1, opts.max_result)
    end

    return result
end

return M
