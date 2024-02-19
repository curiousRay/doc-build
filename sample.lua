-- counts words in a document

words = 0
characters = 0
characters_and_spaces = 0
process_anyway = true

wordcount = {
  Str = function(el)
    -- we don't count a word if it's entirely punctuation:
    if el.text:match("%P") then
        words = words + 1
    end
    characters = characters + utf8.len(el.text)
    characters_and_spaces = characters_and_spaces + utf8.len(el.text)
  end,

  Space = function(el)
    characters_and_spaces = characters_and_spaces + 1
  end,

  Code = function(el)
  
    -- 此处可以遍历所有inlinecode
    -- print(el)

    _,n = el.text:gsub("%S+","")
    words = words + n
    text_nospace = el.text:gsub("%s", "")
    characters = characters + utf8.len(text_nospace)
    characters_and_spaces = characters_and_spaces + utf8.len(el.text)
  end,

  CodeBlock = function(el)
    _,n = el.text:gsub("%S+","")
    words = words + n
    text_nospace = el.text:gsub("%s", "")
    characters = characters + utf8.len(text_nospace)
    characters_and_spaces = characters_and_spaces + utf8.len(el.text)
  end,

  BlockQuote = function(el)
    --print(el.c[1]) -- 获取quote的开头部分
    -- https://stackoverflow.com/q/76894984/

    -- github旧风格
    if (el.c[1].c[1].t == "Strong") and (el.c[1].c[1].c[1].text == "注意：") then
        --print("bingo")
        --print(el)

        --local raw_elem = '\\begin{error-box}' .. el.c[1].content .. '\\end{error-box}'
        --local raw_elem = '\\begin{error-box}this is test errorbox\\end{error-box}'
        --return pandoc.RawBlock('latex', raw_elem) -- TOFIX
        --local myenv = pandoc.Div(el.content, pandoc.Attr(), {'latex', '\\begin{error-box}'})
        --table.insert(myenv.content, pandoc.RawBlock('latex', '\\end{error-box}'))
        table.insert(el.content, 1, pandoc.RawBlock('latex', '\\begin{error-box}'))
        table.insert(el.content, pandoc.RawBlock('latex', '\\end{error-box}'))
        --print(el)
        return el
    end

    -- github新风格
    --if (el.c[1].c[1].text == "[!NOTE]") then
    --  print("bingo again")
    --end

  end
}

-- check if the `wordcount` variable is set to `process-anyway`
function Meta(meta)
  if meta.wordcount and (meta.wordcount=="process-anyway"
    or meta.wordcount=="process" or meta.wordcount=="convert") then
      process_anyway = true
  end
end

function Pandoc(el)

    -- skip metadata, just count body:
    pandoc.walk_block(pandoc.Div(el.blocks), wordcount)
    -- print(words .. " words in body")
    -- print(characters .. " characters in body")
    -- print(characters_and_spaces .. " characters in body (including spaces)")
    print(el)

    if not process_anyway then
      os.exit(0)
    end
end

