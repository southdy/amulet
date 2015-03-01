-- extra table functions

function table.shallow_copy(t)
    if type(t) ~= "table" then
        error("table expected, but got a "..type(t), 2)
    end
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    return copy
end

local
function deep_copy_2(t, seen)
    local s = seen[t]
    if s then
        return s
    else
        s = {}
        seen[t] = s
        for k, v in pairs(t) do
            if type(k) == "table" then
                k = deep_copy_2(k, seen)
            elseif type(k) == "userdata" then
                error("cannot deep copy userdata values", 3)
            end
            if type(v) == "table" then
                v = deep_copy_2(v, seen)
            elseif type(v) == "userdata" then
                if type(k) == "string" then
                    error("cannot copy userdata value '"..k.."'", 3)
                else
                    error("cannot deep copy userdata values", 3)
                end
            end
            s[k] = v
        end
        return s
    end
end

function table.deep_copy(t)
    if type(t) == "table" then
        return deep_copy_2(t, {})
    else
        error("table expected, but got a "..type(t), 2)
    end
end

function table.search(t, elem)
    for i = 1, #t do
        if t[i] == elem then
            return i
        end
    end
    return nil
end

function table.append(arr1, arr2)
    local i = #arr1 + 1
    for _, v in ipairs(arr2) do
        arr1[i] = v
        i = i + 1
    end
end

function table.clear(t)
    for k, _ in pairs(t) do
        t[k] = nil
    end
end

local
function table_tostring(t, indent)
    local tp = type(t)
    if tp == "table" then
        indent = indent or 4
        local tab = "    "
        local prefix = string.rep(tab, indent)
        local str = "{\n"
        for key, value in pairs(t) do
            local keystr
            if type(key) == "string" then
                keystr = key
            else
                keystr = "[" .. tostring(key) .. "]"
            end
            str = str .. prefix .. tab .. keystr .. " = " .. table_tostring(value, indent + 1) .. ",\n"
        end
        str = str .. prefix .. "}"
        return str
    elseif tp == "string" then
        return '"' .. t:gsub("\"", "\\\"") .. '"'
    else
        return tostring(t)
    end
end

table.tostring = table_tostring

-- extra math functions

function math.cycle(i, by, len)
    return (i + by - 1) % len + 1
end

function math.cycle_dist(a, b, len)
    if b >= a then
        return b - a
    else
        return (b + len) - a
    end
end

-- override some maths functions to avoid nans

local acos = math.acos
local asin = math.asin
local clamp = math.clamp

function math.acos(x)
    return acos(math.clamp(x, -1, 1))
end

function math.asin(x)
    return asin(math.clamp(x, -1, 1))
end

-- vector/matrix stuff

vec2 = math.vec2
vec3 = math.vec3
vec4 = math.vec4
mat2 = math.mat2
mat3 = math.mat3
mat4 = math.mat4

local
function format_vec(v)
    local n = #v
    local str = "vec"..n.."("
    for i = 1, n do
        str = str..v[i]
        if i == n then
            str = str..")"
        else
            str = str..", "
        end
    end
    return str
end

rawset(getmetatable(vec2(0)), "__tostring", format_vec)
rawset(getmetatable(vec3(0)), "__tostring", format_vec)
rawset(getmetatable(vec4(0)), "__tostring", format_vec)

local
function format_mat(m)
    local n = #m
    local str = "mat"..n.."(\n"
    for col = 1, n do
        str = str.."  "..format_vec(m[col])
        if col == n then
            str = str..")"
        else
            str = str..",\n"
        end
    end
    return str
end

rawset(getmetatable(mat2(0)), "__tostring", format_mat)
rawset(getmetatable(mat3(0)), "__tostring", format_mat)
rawset(getmetatable(mat4(0)), "__tostring", format_mat)

-- extra builtins

function log(fmt, ...)
    if type(fmt) == "string" and ... then
        amulet.log(string.format(fmt, ...), false, 2)
    else
        amulet.log(tostring(fmt), false, 2)
    end
end

function log1(fmt, ...)
    if type(fmt) == "string" and ... then
        amulet.log(string.format(fmt, ...), true, 2)
    else
        amulet.log(tostring(fmt), true, 2)
    end
end