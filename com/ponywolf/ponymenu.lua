-- com.ponywolf.textMenu

-- Simple text UI that can respond to key
-- events for desktop/joystick games

local M = {}

local function split(line, separator)
  line = line or ""
  separator = separator or ","  
  local items = {}
  local i=1
  for str in string.gmatch(line, "([^"..separator.."]+)") do
    items[i] = str
    i = i + 1
  end
  return items
end

local function inBounds(event, object)
  local ex, ey = event.x or 0, event.y or 0
  local bounds = object._contentBounds or object.contentBounds or {}
  if bounds then
    if ex < bounds.xMin or ex > bounds.xMax or ey < bounds.yMin or ey > bounds.yMax then   
      return false
    else 
      return true
    end
  end
  return false
end

function M.new(options, listener)

  options = options or {}

  local instance = display.newGroup()
  --instance.anchorChildren = true
  instance.items = {}
  instance.selected = 1

  function instance:add(text, name)
    if not text then error("ERROR: ponymenu:add() requires at least one string.") end
    name = name or text:lower():gsub(" ","")
    local items = self.items
    local index = #items + 1
    local toggles = split(text)
    items[index] = { name = name, text = toggles[1], toggles = toggles, selected = 1 }
    self:refresh() 
    self:update()
    return index
  end

  function instance:refresh()
    local items = self.items
    for i = self.numChildren,1,-1 do 
      display.remove(self[i])
    end

    -- set your text options here
    local default = options.text or { align = "center", fontSize = 42 }

    for i = 1, #items do
      default.text = items[i].text
      items[i].object = display.newText(default)
      items[i].object:translate(0, (i > 1) and items[i-1].object.contentHeight * (i-1) or 0)
      instance:insert(items[i].object)
    end
  end

  function instance:update(index)
    local items = self.items
    index = index or self.selected
    index = math.min(math.max(index,1),#items)
    self.selected = index

    -- refresh these to hightlight your menu
    local selected = options.selected or { time = 250, xScale = 1.075, yScale = 1.075, alpha = 1, transition = easing.outQuad }
    local normal = options.normal or { time = 350, xScale = 1, yScale = 1, alpha = 0.7, transition = easing.outElastic  }

    for i = 1, #items do
      local item = items[i].object
      if i == index then
        transition.to(item, selected)
      else
        transition.to(item, normal)
      end
    end
  end

  function instance:up()
    self:update(self.selected - 1)
  end

  function instance:down()
    self:update(self.selected + 1)
  end

  function instance:select(item)  
    local selectedItem = item or self.items[self.selected]
    if #selectedItem.toggles > 1 then
      local newSelected = (selectedItem.selected or 1) + 1
      if newSelected > #selectedItem.toggles then
        newSelected = 1
      end
      selectedItem.text = selectedItem.toggles[newSelected]
      selectedItem.object.text = selectedItem.text 
      selectedItem.selected = newSelected
      selectedItem.name = selectedItem.text:lower():gsub(" ","")
    end
    return selectedItem.name
  end

  function instance:touch(event)
    local phase = event.phase
    local name = event.name
    
    -- we are a mouse?
    if name == "mouse" then
      for i = 1, #self.items do
        if inBounds(event, self.items[i].object) then
          self:update(i)
        end
      end
    end

    if phase == "ended" then
      Runtime:dispatchEvent( { name = "key", phase = "up", keyName = "enter" } )
    end
  end

  local function mouse(event)
    instance:touch(event)
  end

  local function key(event)
    local phase = event.phase
    local name = event.keyName    
    if phase == "up" then
      if name == "up" then
        instance:up()
      elseif name == "down" then
        instance:down()      
      elseif name == "enter" or name == "space" then
        local item = instance:select() 
        if listener then
          listener( { phase = "selected", name = item } )
        else
          Runtime:dispatchEvent( { name = "key", phase = "selected", keyName = "enter" } )
        end
      end
    end
  end

  function instance:finalize()
    Runtime:removeEventListener( "mouse", mouse )
    Runtime:removeEventListener( "key", key )    
  end

  Runtime:addEventListener( "mouse", mouse )
  Runtime:addEventListener( "key", key )  
  instance:addEventListener("touch")  
  instance:addEventListener('finalize')

  return instance
end

return M
