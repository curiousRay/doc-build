function BlockQuote(el)
  -- print(el.c[1])
  -- print(el.c[1].t)
  -- https://stackoverflow.com/q/76894984/

  function IsGradeKeywordFound(str, type)

    -- Modify here
    str_info = {"提示","注意","Note","NOTE","Info","INFO"}
    str_warning = {"警告","小心","Warning","WARNING","Caution","CAUTION"}
    str_error = {"危险","错误","Danger","DANGER","Error","ERROR"}
    
    if (type == "info") then
      for _, v in ipairs(str_info) do
        location,_ = string.find(str, v)
        if (location ~= nil) then
          return true
        end
      end
    end

    if (type == "warning") then
      for _, v in ipairs(str_warning) do
        location,_ = string.find(str, v)
        if (location ~= nil) then
          return true
        end
      end
    end
    
    if (type == "error") then
      for _, v in ipairs(str_error) do
        location,_ = string.find(str, v)
        if (location ~= nil) then
          return true
        end
      end
    end

    return false
  end

  -- **Note:** or [!NOTE]
  if ((el.c[1].c[1].t == "Strong") 
    and (IsGradeKeywordFound(el.c[1].c[1].c[1].text, info)))
    or (el.c[1].c[1].text == "[!NOTE]")
    then
      table.insert(el.content, 1, pandoc.RawBlock("latex", "\\begin{info-box}"))
      table.insert(el.content, pandoc.RawBlock("latex", "\\end{info-box}"))
      return el.content
  end

  if ((el.c[1].c[1].t == "Strong") 
    and (IsGradeKeywordFound(el.c[1].c[1].c[1].text, warning)))
    or (el.c[1].c[1].text == "[!WARNING]")
    then
      table.insert(el.content, 1, pandoc.RawBlock("latex", "\\begin{warning-box}"))
      table.insert(el.content, pandoc.RawBlock("latex", "\\end{warning-box}"))
      return el.content
  end

  if ((el.c[1].c[1].t == "Strong") 
    and (IsGradeKeywordFound(el.c[1].c[1].c[1].text, error)))
    or (el.c[1].c[1].text == "[!CAUTION]")
    then
      table.insert(el.content, 1, pandoc.RawBlock("latex", "\\begin{error-box}"))
      table.insert(el.content, pandoc.RawBlock("latex", "\\end{error-box}"))
      return el.content
  end

end

function Code(el)
  return el
end