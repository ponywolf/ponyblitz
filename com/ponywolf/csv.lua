local M = {}

--local translate = require "com.ponywolf.translator"

local function luafy(tbl)
  for k, v in pairs(tbl) do
    if type(v) == "string" and v:lower()=="true" then
      tbl[k]=true
    elseif type(v) == "string" and v:lower()=="false" then
      tbl[k]=false
    elseif tonumber(v) then
      tbl[k]=tonumber(v)
    elseif type(v) == "string" and (v=="" or v:lower()=="nil") then
      tbl[k]=nil
    elseif type(v) == "table" then
      luafy(v)
    end
  end
  return tbl
end

local function loadFile(filename)
  local path = system.pathForFile("csv/" .. filename, system.ResourceDirectory)
  local contents, obscured = {}, {}
  local file = io.open(path, "r")
  if file then
    -- read all contents of file into a string
    for line in file:lines() do
        contents[#contents+1] = line
    end
    io.close(file)
  else
    print("File not found", path)
    return nil
  end
--  if isSimulator then
--    if saveData(filename, obscured) then
--      print("Saved obscured CSV to DocumentsDirectory as", filename:gsub(".csv",".dat"))
--    end
--  end
  return contents
end

local function parseCSV(s)
  s = s .. ','        -- ending comma
  local t = {}        -- table to collect fields
  local fieldstart = 1
  repeat
    -- next field is quoted? (start with `"'?)
    if string.find(s, '^"', fieldstart) then
      local a, c
      local i  = fieldstart
      repeat
        -- find closing quote
        a, i, c = string.find(s, '"("?)', i+1)
      until c ~= '"'    -- quote not followed by quote?
      if not i then error('unmatched "') end
      local f = string.sub(s, fieldstart+1, i-1)
      table.insert(t, (string.gsub(f, '""', '"')))
      fieldstart = string.find(s, ',', i) + 1
    else                -- unquoted; find next comma
      local nexti = string.find(s, ',', fieldstart)
      table.insert(t, string.sub(s, fieldstart, nexti-1))
      fieldstart = nexti + 1
    end
  until fieldstart > string.len(s)
  return t
end

function M.load(filename)
  local csvTable = {}

  local contents = loadFile(filename)
  local keys = parseCSV(contents[1])
  local ids = {}
  for k = 1, #keys do keys[k] = keys[k]:gsub("\r","") end

  for i = 2, #contents do
    local values = parseCSV(contents[i])
    local row = {}
    for k = 1, #keys do
      if keys[k] == "id" then
        ids[#ids+1] = values[k]:gsub("\r","")
      end
      row[keys[k]] = values[k]:gsub("\r","")
      row[keys[k]] = tonumber(row[keys[k]]) ~= nil and tonumber(row[keys[k]]) or row[keys[k]]
      if translate then
        if translate.keys[keys[k]] then
          local const
          if row["id"] then
            const = row["id"] .. "_" .. keys[k]
          end
          row[keys[k]] = translate(row[keys[k]], const)
        end
      end
    end
    table.insert(csvTable,row)
  end

  csvTable = luafy(csvTable)

  function csvTable:find(k,v)
    if v == nil then
      v = k
      k = "id"
    end
    for i = 1, #self do
      --print(i,k,v)
      if self[i][k] == v then
        return self[i]
      end
    end
    return {}
  end

  function csvTable:findAll(k,v)
    local results = {}
    if v == nil then
      v = k
      k = "id"
    end

    for i = 1, #self do
      --print(i,k,v)
      if self[i][k] == v then
        results[#results + 1] = self[i]
      end
    end
    return results
  end

  function csvTable:values(k,v)
    for i = 1, #self do
      --print(i,k,v)
      if self[i][k] == v then
        return self[i]
      end
    end
    return {}
  end

  csvTable.keys = keys
  csvTable.ids = ids

  return csvTable
end

return M