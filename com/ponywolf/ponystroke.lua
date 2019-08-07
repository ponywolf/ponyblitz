-- stroke module com.ponywolf.strokeText

-- define module
local M = {}
local useContainer = false
local renderSteps = 0.75

function M.newText(options)

  -- default options for instance
  options = options or {}
  local x = options.x or 0
  local y = options.y or 0
  local h = options.height
  options.height = nil
  options.x = 0
  options.y = 0
  local parent = options.parent

  -- new options 
  local color = options.color or {1,1,1,1}
  local strokeColor = options.strokeColor or {0,0,0,0.65}
  local strokeWidth = options.strokeWidth or 1.5

  -- create the main text
  local text = display.newText(options)
  text:setFillColor(unpack(color))

  -- make a bounding box based on the default text
  local width = math.max(text.contentWidth, options.width or 0)
  local height = h or math.max(text.contentHeight * 2, width)

  --  create snapshot to hold text/strokes
  local stroked

  if useContainer then 
    stroked = display.newSnapshot(width + (2 * strokeWidth), height + (2 * strokeWidth))
  else 
    stroked = display.newGroup()
  end
  if parent then parent:insert(stroked) end

  stroked.strokes = {}
  stroked.unstroked = text

  -- draw the strokes
  for i = -strokeWidth, strokeWidth, renderSteps do
    for j = -strokeWidth, strokeWidth, renderSteps do
      if not (i == 0 and j == 0) then --skip middle
        options.x,options.y = i,j
        local stroke = display.newText(options)
        stroke:setFillColor(unpack(strokeColor))
        if useContainer then
          stroked.group:insert(stroke)
        else
          stroked:insert(stroke)
        end
        --stroked:insert(stroke)        
        stroked.strokes[#stroked.strokes+1] = stroke
      end
    end
  end

  if useContainer then
    stroked.group:insert(text)  
  else
    stroked:insert(text) 
    function stroked:setFillColor(r,g,b,a)
      stroked.unstroked:setTextColor(r,g,b,a)
    end
  end

  -- call this function to update the text and invalidate the canvas
  function stroked:update(text)
    self.unstroked.text = text
    self.text = text
    for i=1, #self.strokes do
      self.strokes[i].text = text
    end
    if useContainer and self.invalidate then self:invalidate() end
  end

  -- call this function to set text color
  function stroked:setTextColor(r,g,b,a)
    stroked.unstroked:setTextColor(r,g,b,a)
    --if self.invalidate then self:invalidate() end
  end

  stroked:translate(x,y) 
  options.x = x
  options.y = y 
  stroked.text = options.text

  -- keep a private access to original table
  local _stroked = stroked

  -- create proxy
  stroked = {}
  stroked.raw = _stroked

  -- create metatable
  local mt = {
    __index = function (t,k)
      return _stroked[k]   -- access the original table
    end,

    __newindex = function (t,k,v)
      if k == "text" then 
        _stroked:update(v)
      end
      _stroked[k] = v   -- update original table
    end
  }
  setmetatable(stroked, mt)

  -- return instance
  return stroked
end

-- return module
return M