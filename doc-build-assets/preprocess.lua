-- delete all zero-width-space characters

local file = io.open(PANDOC_STATE.input_files[1], "r")
local content = file:read("*all")
file:close()
content = string.gsub(content, "\u{200B}", "")
file = io.open(PANDOC_STATE.input_files[1], "w+")
file:write(content)
file:close()