local M = {}

--- Filter based on opts
---
---@param entries FzfLuaStorage
---@param opts FzfLuaJumpConfig
---@return FzfLuaStorage results
function M.filter(entries, opts)
    local result = {} ---@type FzfLuaStorage

    if opts.line_distance_threshold then
        for key, jump in pairs(entries) do
            local should_add = true

            if next(result) ~= nil then
                for _, added_key in pairs(result) do
                    if math.abs(jump.lnum - added_key.lnum) <= opts.line_distance_threshold then
                        should_add = false
                        break
                    end
                end
            end

            if should_add then
                result[key] = jump
            end
        end
    end

    if opts.max_result then
        local count = 0
        for key in pairs(result) do
            count = count + 1
            if count > opts.max_result then
                result[key] = nil
            end
        end
    end

    return result
end

--- Reverses the list in place
---
---@param table table
---@return table
function M.reverse(table)
    local n = #table
    local i = 1
    while i < n do
        table[i], table[n] = table[n], table[i]
        i = i + 1
        n = n - 1
    end

    return table
end

return M
