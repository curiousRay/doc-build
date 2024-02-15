-- get doc language variable
-- hyphen cannot be used in lua string
doc_lang , _ = string.gsub(tostring(PANDOC_WRITER_OPTIONS.variables["lang"]), "%-", "_")

-- experimental: add background color to inline-code
show_inlinecode_background = true

-- helper function
function DeepCopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= 'table' then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end 
        local new_table = {}
        lookup_table[object] = new_table
        for k,v in pairs(object) do
            new_table[_copy(k)] = _copy(v) 
        end 
        return setmetatable(new_table, getmetatable(object))
    end 
    return _copy(object)                    
end

function OptimizeColWidth (el)
  function factor_opt(fac)
    local limit = 6
    need_redo = false
    min_val = math.min(table.unpack(fac))
    for key,value in pairs(fac) do
      if (value / min_val > limit) then
        need_redo = true
        value = value * 0.618
        fac[key] = value
        need_redo = true
      end
    end
    
    if (need_redo) then
      fac = factor_opt(fac)
    else
      -- normalize column width
      sum = 0
      for key,value in pairs(fac) do
        sum = sum + value
      end
      for key,value in pairs(fac) do
        fac[key] = fac[key] / sum
      end
      return
    end
  end

  --print("====Table Start====")

  tbl_colnum = #el.colspecs
  tbl_strlen = {}

  -- merge table header with table body

  --tbl = el.head.rows -- this is wrong
  -- must use deep copy so that the original structure of table won't break
  tbl = DeepCopy(el.head.rows)

  for _,value_bodyrows in pairs(el.bodies[1].body) do 
    table.insert(tbl, value_bodyrows)
  end
  
  -- reading table
  for _,value_row in pairs(tbl) do    
    --print("-----Row Start-----")
    tbl_strlen_newrow = {}

    -- do not count rows with rowspan attr (except the first row)
    if (#value_row.cells == tbl_colnum) then
      for _,value_cell in pairs(value_row.cells) do
        cell_textstrlen = 0

        for _,value_frag in pairs(value_cell.contents[1].content) do
            if (value_frag.tag == "Space") then
              cell_textstrlen = cell_textstrlen + 1
            elseif (value_frag.tag == "Code") then
              -- inline code characters are fatter thus scale the width value
              cell_textstrlen = cell_textstrlen + #value_frag.text * 1.343
            else
              cell_textstrlen = cell_textstrlen + #value_frag.text
            end
        end
        
        -- store the length of string finally to `tbl_strlen`
        table.insert(tbl_strlen_newrow, cell_textstrlen)
      end

      table.insert(tbl_strlen, tbl_strlen_newrow)
    end
    --print("-----Row End-----")
  end

  factor = {}
  for col=1,tbl_colnum do
    column = {}
    for k,v in pairs(tbl_strlen) do
      table.insert(column, tbl_strlen[k][col])
    end

    -- use column's max content length as column-width factor
    factor[col] = math.max(table.unpack(column))
    
    for key,value in pairs(column) do
      --print(key,value)
    end
  
  end
  
  factor_opt(factor)

  --print("Optimization result:")
  for key,value in pairs(factor) do
    --print("第" .. key .. "列的系数为" .. value)
    --print(value[2])
    --print(key,value)
  end

  --print("====Table End====")

  return factor
end

function RawBlock (raw)
  if (raw.format:match 'html') then
    if (pandoc.read(raw.text, 'html').blocks[1].tag == "Table") then
      -- htmltable_singular is iterator of each html-table
      htmltable = pandoc.read(raw.text, 'html').blocks

      -- calculate colwidth factors
      colfactor_result = OptimizeColWidth(htmltable[1])

      --print("====Table Start====")
      for key,value in pairs(htmltable[1].colspecs) do
        -- set column width evenly
        --value[2] = 1 / #htmltable[1].colspecs

        -- set column width using optimization algorithm
        value[2] = colfactor_result[key]
      end

      --print("====Table End====")
      return htmltable
    end

    -- process other html-tagged elements here if you wish
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
