local lfs = require "lfs"

local M = {}


local sep = string.match (package.config, "[^\n]+")
function M.attrdir(path)
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local f = path .. sep .. file
            print("\t=> " .. f .. " <=")
            local attr = lfs.attributes(f)
            assert(type(attr) == "table")
            if attr.mode == "directory" then
                M.attrdir(f)
            else
                for name, value in pairs(attr) do
                    print(name, value)
                end
            end
        end
    end
end

return M

