--- MeowvimKeyboardLayouts.spoon
-- Switches macOS keyboard layout based on Neovim mode signalled via the
-- Ghostty window title.
--
-- When a Ghostty window enters Insert mode ("[I]" in title) the last-used
-- input source is restored.  When it leaves Insert mode (Normal, Visual, etc.)
-- the current source is saved and the layout is switched to ABC so that Neovim
-- keybindings work regardless of the active language.
--
-- Usage:
--   hs.loadSpoon("MeowvimKeyboardLayouts")
--   spoon.MeowvimKeyboardLayouts:start()

local obj = {}
obj.__index = obj

obj.name    = "MeowvimKeyboardLayouts"
obj.version = "1.0"
obj.author  = "Andrew Vasilyev"
obj.license = "MIT"

-- Input source used for Normal/Visual/etc. modes
obj.englishSource = "com.apple.keylayout.ABC"

-- Applications to track.  The title-change watcher is scoped to these names.
obj.trackedApps = { "Ghostty" }

obj._lastInputSource = nil
obj._titleWatcher    = nil
obj._appWatcher      = nil

-- ── Helpers ───────────────────────────────────────────────────────────────────

local function isMeowvimTitle(title)
  if not title then return false end
  -- meowvim title formats:
  --   New:  "filename [N]"  /  "filename+ [I]"
  --   Old:  "meowvim | filename [I] -- user@host"
  return title:find("meowvim") ~= nil
      or title:find("%[%a+%]") ~= nil
      or title:find("%[%a%-%a%]") ~= nil
end

local function isInsertMode(title)
  return title:find("%[I%]") ~= nil
end

-- ── Core ──────────────────────────────────────────────────────────────────────

function obj:_handleTitleChange(window, _appName, _event)
  local appName = window:application():name()
  local tracked = false
  for _, name in ipairs(obj.trackedApps) do
    if appName == name then tracked = true; break end
  end
  if not tracked then return end

  local title = window:title()
  if not isMeowvimTitle(title) then return end

  local current = hs.keycodes.currentSourceID()

  if isInsertMode(title) then
    -- Entering Insert: restore saved source if different from current
    if self._lastInputSource ~= nil and current ~= self._lastInputSource then
      hs.keycodes.currentSourceID(self._lastInputSource)
    end
  else
    -- Leaving Insert (Normal/Visual/etc.): save source, switch to ABC
    self._lastInputSource = current
    if current ~= self.englishSource then
      hs.keycodes.currentSourceID(self.englishSource)
    end
  end
end

function obj:_handleAppEvent(appName, eventType, _app)
  local tracked = false
  for _, name in ipairs(obj.trackedApps) do
    if appName == name then tracked = true; break end
  end
  if not tracked then return end

  if eventType == hs.application.watcher.activated then
    local win = hs.window.focusedWindow()
    if win then self:_handleTitleChange(win, appName, nil) end
  elseif eventType == hs.application.watcher.deactivated then
    -- Save whatever source is active when leaving the tracked app
    self._lastInputSource = hs.keycodes.currentSourceID()
  end
end

-- ── Public API ────────────────────────────────────────────────────────────────

function obj:start()
  if self._titleWatcher then self:stop() end

  local filter = {}
  for _, name in ipairs(self.trackedApps) do filter[name] = true end

  self._titleWatcher = hs.window.filter.new(filter)
  self._titleWatcher:subscribe(
    hs.window.filter.windowTitleChanged,
    function(win, appName, event) self:_handleTitleChange(win, appName, event) end
  )

  self._appWatcher = hs.application.watcher.new(function(appName, eventType, app)
    self:_handleAppEvent(appName, eventType, app)
  end)
  self._appWatcher:start()

  hs.notify.new({ title = "Meowvim Keyboard Layouts", informativeText = "Ready" }):send()
  return self
end

function obj:stop()
  if self._titleWatcher then
    self._titleWatcher:unsubscribeAll()
    self._titleWatcher = nil
  end
  if self._appWatcher then
    self._appWatcher:stop()
    self._appWatcher = nil
  end
end

return obj
