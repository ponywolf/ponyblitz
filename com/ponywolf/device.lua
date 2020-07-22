local M = {}

M.isSimulator = system.getInfo("environment") == "simulator"
M.isAndroid = system.getInfo("platform") == "android"
M.isiOS = system.getInfo("platform") == "ios"
M.isKindle = system.getInfo("manufacturer") == "Amazon"

M.isWin32 = system.getInfo("platform") == "win32"
M.isMacos = system.getInfo("platform") == "macos"
M.isDesktop = M.isWin32 or M.isMacos
M.isSteam = false
M.isItch = false

local platform = system.getInfo("platform")
local version = system.getInfo("appVersionString")=="" and "0.0" or system.getInfo("appVersionString")
local code = M.isAndroid and (" #" .. (system.getInfo("androidAppVersionCode") or "0")) or ""

M.build = system.getInfo("environment") .. "-" .. platform .."-".. version

M.isMobile = M.isiOS or M.isAndroid

function M.setPremium(bool)
  M.isPremium = bool
end

function M.setItch(bool)
  M.isItch = bool
end

function M.setSteam(bool)
  M.isSteam = bool
end

function M.screenshot()
  local date = os.date( "*t" )
  local timeStamp = table.concat({date.year .. date.month .. date.day .. date.hour .. date.min .. date.sec})
  local fname = display.pixelWidth.."x"..display.pixelHeight.."_"..timeStamp..".png"
  local capture = display.captureScreen(false)
  capture.x, capture.y = display.contentWidth * 0.5, display.contentHeight * 0.5
  local function save()
    display.save( capture, { filename=fname, baseDir=system.DocumentsDirectory, isFullResolution=true } )
    capture:removeSelf()
    capture = nil
  end
  timer.performWithDelay( 100, save, 1)
  return true
end

return M