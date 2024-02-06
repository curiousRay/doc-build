-- get doc language variable
-- hyphen cannot be used in lua string
doc_lang , _ = string.gsub(tostring(PANDOC_WRITER_OPTIONS.variables["lang"]), "%-", "_")

-- experimental: add background color to inline-code
show_inlinecode_background = true

function Table (el)
  --表的长度
  -- print(#el.colspecs)

  for key,value in pairs(el.colspecs) do
      --print(key, value)
      --print("第" .. key .. "列的系数为")
      --print(value[2])
      --value[2] = 1 / #el.colspecs
  end
  
  return el
end

function OptimizeColWidth (el)
  return el
end

function RawBlock (raw)
  if (raw.format:match 'html') then
    if (pandoc.read(raw.text, 'html').blocks[1].tag == "Table") then
    
      -- htmltable_singular is iterator of each html-table
      htmltable = pandoc.read(raw.text, 'html').blocks
    
      --print("====以下是一个表====")
      for key,value in pairs(htmltable[1].colspecs) do
        --print(key, value)
        --print("第" .. key .. "列的系数为")
        --print(value[2])

        -- temp: set each column width equally
        value[2] = 1 / #htmltable[1].colspecs
      end
      --print("====以上是一个表====")

       -- test: allocate colwidth factors automatically
      OptimizeColWidth(htmltable[1])

      return htmltable
    end

    -- process other html-tagged elements here
  else
    return raw
  end
end

function Code(el)
  esc_text, _ = el.text:gsub("\\", "\\\\")
  esc_text, _ = esc_text:gsub("#", "\\#")
  esc_text, _ = esc_text:gsub("%%", "\\%%")
  esc_text, _ = esc_text:gsub("}", "\\}")
  esc_text, _ = esc_text:gsub("{", "\\{")
  esc_text, _ = esc_text:gsub("$$", "\\$$")
  esc_text, _ = esc_text:gsub("&", "\\&")
  esc_text, _ = esc_text:gsub("~", "\\~")

  code_head_str = '\\lstinline[breaklines=true, identifierstyle=\\color{inlinecode-textcolor}, basicstyle=\\color{inlinecode-textcolor}\\ttfamily{}]¿'
  code_rear_str = '¿'
  wrapped = code_head_str .. esc_text .. code_rear_str
    
  if (show_inlinecode_background) then
    return pandoc.RawInline('latex', '\\colorbox{inlinecode-bgcolor}{' .. wrapped .. '}')
  else
    return pandoc.RawInline('latex', wrapped)
  end
end

function BlockQuote(el)
  -- print(el.c[1])
  -- print(el.c[1].t)
  -- https://stackoverflow.com/q/76894984/

  function IsGradeKeywordFound(str, type)
    -- Modify here for customize displayed text
    -- the string below shall be included with markdown quote.
    -- e.g. > **foo_Note_bar:** will be treated as risk info and will be rendered
    -- e.g. > **foo_NOTE_bar:** will NOT be treated as risk info and will NOT be rendered
    str_info = {
      default="Note",
      zh_CN="注意",
      en_US="Note",
      zh_TW="注意",
      kr="메모",
      jp="手記"
    }

    str_warning = {
      default="Warning",
      zh_CN="警告",
      en_US="Warning",
      zh_TW="警告",
      kr="경고",
      jp="警告"
    }

    str_error = {
      default="Caution",
      zh_CN="危险",
      en_US="Caution",
      zh_TW="危險",
      kr="위험",
      jp="危険"
    }
    
    -- Modify below if more custom risk grades are required

    if (type == "quotetype_info") then
      res = str_info[doc_lang]
      if (res == nil) then
        -- fallback to default
        res = str_info.default
      end
      location,_ = string.find(str, res)
      if (location ~= nil) then
        return true
      end
    end

    if (type == "quotetype_warning") then
      res = str_warning[doc_lang]
      if (res == nil) then
        -- fallback to default
        res = str_warning.default
      end
      location,_ = string.find(str, res)
      if (location ~= nil) then
        return true
      end
    end
    
    if (type == "quotetype_error") then
      res = str_error[doc_lang]
      if (res == nil) then
        -- fallback to default
        res = str_warning.default
      end
      location,_ = string.find(str, res)
      if (location ~= nil) then
        return true
      end
    end

    return false
  end

  -- **Note:** or [!NOTE]
  if ((el.c[1].c[1].t == "Strong") 
    and (IsGradeKeywordFound(el.c[1].c[1].c[1].text, "quotetype_info")))
    or (el.c[1].c[1].text == "[!NOTE]")
    then
      if (el.c[1].c[1].text == "[!NOTE]") then
        res = str_info[doc_lang]
        if (res == nil) then
            -- fallback to default
            res = str_info.default
        end
        el.c[1].content[1] = pandoc.Strong(pandoc.Str(res))
      end
      table.insert(el.content, 1, pandoc.RawBlock("latex", "\\begin{info-box}"))
      table.insert(el.content, pandoc.RawBlock("latex", "\\end{info-box}"))
      return el.content
  end

  if ((el.c[1].c[1].t == "Strong") 
    and (IsGradeKeywordFound(el.c[1].c[1].c[1].text, "quotetype_warning")))
    or (el.c[1].c[1].text == "[!WARNING]")
    then
      if (el.c[1].c[1].text == "[!WARNING]") then
        res = str_warning[doc_lang]
        if (res == nil) then
            -- fallback to default
            res = str_warning.default
        end
        el.c[1].content[1] = pandoc.Strong(pandoc.Str(res))
      end
      table.insert(el.content, 1, pandoc.RawBlock("latex", "\\begin{warning-box}"))
      table.insert(el.content, pandoc.RawBlock("latex", "\\end{warning-box}"))
      return el.content
  end

  if ((el.c[1].c[1].t == "Strong") 
    and (IsGradeKeywordFound(el.c[1].c[1].c[1].text, "quotetype_error")))
    or (el.c[1].c[1].text == "[!CAUTION]")
    then
      if (el.c[1].c[1].text == "[!CAUTION]") then
        res = str_error[doc_lang]
        if (res == nil) then
            -- fallback to default
            res = str_error.default
        end
        el.c[1].content[1] = pandoc.Strong(pandoc.Str(res))
      end
      table.insert(el.content, 1, pandoc.RawBlock("latex", "\\begin{error-box}"))
      table.insert(el.content, pandoc.RawBlock("latex", "\\end{error-box}"))
      return el.content
  end

end
