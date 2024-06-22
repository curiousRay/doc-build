resource_path , _ = string.gsub(tostring(PANDOC_WRITER_OPTIONS.variables["resource-path"]), "%-", "_")


-- delete all zero-width-space characters
local file = io.open(PANDOC_STATE.input_files[1], "r")
local content = file:read("*all")
file:close()
content = string.gsub(content, "\u{200B}", "")

--- replace all image href according to resource_path
local img_caption = content:match("!%[(.-)%]")
local dir_prefix = resource_path
local test = string.gsub(content, "!%[(.-)%)", "%0")
if (not string.find(test, dir_prefix)) then
	-- igonre if image href has been replaced
	content = string.gsub(content, "!%[(.-)%]%((.-)%)", "![" .. img_caption .. "]" .. "(" .. dir_prefix .."%2)")
end

file = io.open(PANDOC_STATE.input_files[1], "w+")
file:write(content)
file:close()

function Link (elem)
	print()
end