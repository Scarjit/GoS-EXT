require "DamageLib"
--[[
###############################
###############################
###############################
###############################
Optimizations and Init
###############################
###############################
###############################
###############################
--]]
S1mpleLibVersion = 1.8
local os = os
local math = math
local pairs = pairs
local table = table
local ipairs = ipairs
local string = string

math.randomseed(os.clock() + myHero.networkID + GetTickCount())

--[[
###############################
###############################
###############################
###############################
S1mpleLib Menu
###############################
###############################
###############################
###############################
--]]

local menu_id = tostring(math.floor(math.random(1,22)))
if(menu_id:len() == 1)then
  menu_id = "0"..menu_id
end
_G.S1mpleLibMenu = MenuElement({type = MENU, id = "S1mpleLib", name = "S1mpleLib [V" .. S1mpleLibVersion .. "]", leftIcon = "https://raw.githubusercontent.com/Scarjit/GoS-EXT/master/Images/S1mpleLib/80"..menu_id..".png"})

--[[
###############################
###############################
###############################
###############################
Common functions
###############################
###############################
###############################
###############################
--]]

function GetDistanceSqr(p1, p2)
  assert(p1, "GetDistance: invalid argument: cannot calculate distance to "..type(p1))
  p2 = p2 or myHero
  if not p1.x then p1 = p1.pos end
  if not p2.x then p2 = p2.pos end
  return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2
end

function GetDistance(p1, p2)
  return math.sqrt(GetDistanceSqr(p1, p2))
end

local _enemyHeroes = {}
function GetEnemyHeroes()
  if(#_enemyHeroes == 0)then
    for i=1,Game.HeroCount() do
      local current = Game.Hero(i)
      if current and current.team ~= myHero.team then
        _enemyHeroes[#_enemyHeroes+1] = current
      end
    end
  end
  return _enemyHeroes
end

local _allyHeroes = {}
function GetAllyHeroes()
  if(#_allyHeroes == 0)then
    for i=1,Game.HeroCount() do
      local current = Game.Hero(i)
      if current and current.team == myHero.team and current.networkID ~= myHero.networkID then
        _allyHeroes[#_allyHeroes+1] = current
      end
    end
  end
  return _allyHeroes
end

function GetObjectsNear(target, objTable, range)
  local objtbl = {}
  for i=1,#objTable do
    local obj = objTable[i]
    if obj and obj.valid and obj.visible and not obj.dead and GetDistance(target, obj) < range then
      objtbl[#objtbl+1] = obj
    end
  end
  return objtbl
end

function GetMinionsNear(target, range, team)
  local minions = {}
  for i=1,Game.MinionCount() do
    local m = Game.Minion(i)
    if m and m.valid and m.visible and not m.dead and GetDistance(m, target) < range then
      if(team and m.team == team)then
        minions[#minions+1] = m
      elseif(not team)then
        minions[#minions+1] = m
      end
    end
  end
  return minions
end

local _recallTable = {}
Callback.Add("ProcessRecall", function(unit, proc)
    if(proc.isStart)then
      _recallTable[unit.networkID] = true
    else
      _recallTable[unit.networkID] = false
    end
  end)

function IsRecalling(unit)
  return _recallTable[unit.networkID]
end

function GetOrbWalkerMode ()
    if(_G.Orbwalker.Enabled:Value())then
            return (_G.Orbwalker.Combo:Value() and "Combo") or (_G.Orbwalker.Harass:Value() and "Harass") or (_G.Orbwalker.Farm:Value() and "Farm") or (_G.Orbwalker.LastHit:Value() and "LastHit") or "None"
    end
    if(EOW)then
        if(EOW:Mode() == "LaneClear")then
            return "Farm"
        else
            return EOW:Mode()
        end
    end
    if(_G.SDK and _G.SDK.Orbwalker)then
        return (_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] and "Combo" or _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] and "Harass" or _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] and "Farm" or _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] and "LastHit") or "None"
    end
    return "None"
end

function math.perc(current, max)
  return current/max*100
end

function math.round(num, idp)
  assert(type(num) == "number", "math.round: wrong argument types (<number> expected for num)")
  assert(type(idp) == "number" or idp == nil, "math.round: wrong argument types (<integer> expected for idp)")
  local mult = 10 ^ (idp or 0)
  if num >= 0 then return math.floor(num * mult + 0.5) / mult
  else return math.ceil(num * mult - 0.5) / mult
  end
end

function IsFacing(source, target) --Thanks to Bananaraka (http://gamingonsteroids.com/topic/19189-)
  local sD = {x = source.dir.x, z = source.dir.z}
  local tD = {x = target.dir.x, z = target.dir.z}
  local sP = {x = source.pos.x, z = source.pos.z}
  local tP = {x = target.pos.x, z = target.pos.z}

  local dot = sD.x*tD.x + sD.z*tD.z
  if(dot < 0)then
    if (sD.x > 0 and sD.z > 0) then
      return ((tP.x - sP.x > 0) and (tP.z - sP.z > 0))
    elseif (sD.x < 0 and sD.z < 0) then
      return ((tP.x - sP.x < 0) and (tP.z - sP.z < 0))
    elseif (sD.x > 0 and sD.z < 0) then
      return ((tP.x - sP.x > 0) and (tP.z - sP.z < 0))
    elseif (sD.x < 0 and sD.z > 0) then
      return ((tP.x - sP.x < 0) and (tP.z - sP.z > 0))
    end
  end
  return false
end

function GetFacing(source, targets, range)
  local n = {}
  for i=1,#targets do
    if(IsFacing(source, targets[i]) and GetDistance(source, targets[i]) < range)then
      n[#n+1] = targets[i]
    end
  end
  return n
end

--[[
###############################
###############################
###############################
###############################
Draw Stuff
###############################
###############################
###############################
###############################
--]]

function WorldToScreen (obj)
  if not obj.x then obj = obj.pos end
  local V = GoSVector(obj.x, obj.y, obj.z)
  return V:To2D()
end

function Draw.DrawText3D(text, x, y, z, color, size)
  size = size or 12
  color = color or Draw.Color(255,255,255,255)
  local wts = WorldToScreen({x = x, y = y, z = z})
  Draw.Text(text, size, wts.x, wts.y, color)
end

function Draw.RectOutline(x, y, width, height, color, borderWidth)
    local x = math.min(x, x + width)
    local y = math.min(y, y + width)
    local width = math.abs(width)
    local height = math.abs(height)
    Draw.Rect(x, y, width, borderWidth, color)
    Draw.Rect(x, y, borderWidth, height, color)
    Draw.Rect(x, y + height - borderWidth, width, borderWidth, color)
    Draw.Rect(x + width - borderWidth, y, borderWidth, height, color)
end

function Draw.LineBorder(x1, y1, x2, y2, size, color, width)
    local o = { x = -(y2 - y1), y = x2 - x1 }
    local len = math.sqrt(o.x ^ 2 + o.y ^ 2)
    o.x, o.y = o.x / len * size / 2, o.y / len * size / 2
    local points = {
        {x = x1 + o.x, y = y1 + o.y},
        {x = x1 - o.x, y = y1 - o.y},
        {x = x2 - o.x, y = y2 - o.y},
        {x = x2 + o.x, y = y2 + o.y},
        {x = x1 + o.x, y = y1 + o.y},
    }
    Draw.Lines2(points, width or 1, color or Draw.Color(255,255,255,255))
end

function Draw.Lines2(points, width, color)
    for i=1,#points-1 do
        local point = points[i]
        local next = points[i+1]
        if(not point.nodraw)then
            Draw.Line(point.x, point.y, next.x, next.y, width, color)
        end
    end
end

function Draw.Arrow(posStartX, posStartY, posEndX, posEndY, size, color, opening)
    local startPoint = Vector({x = posStartX, y = posStartY})
    local endPoint = Vector({x = posEndX, y = posEndY})

    local dx = endPoint.x - startPoint.x
    local dy = endPoint.y - startPoint.y

    local lenght = math.sqrt(dx*dx+dy*dy)
    local unitDx = dx/lenght
    local unitDy = dy/lenght

    local arrowHeadBoxSize = opening

    local arrowPoint1 = Vector({x = endPoint.x - unitDx * arrowHeadBoxSize - unitDy * arrowHeadBoxSize,
                                y = endPoint.y - unitDy * arrowHeadBoxSize + unitDx * arrowHeadBoxSize})

    local arrowPoint2 = Vector({x = endPoint.x - unitDx * arrowHeadBoxSize + unitDy * arrowHeadBoxSize,
                                y = endPoint.y - unitDy * arrowHeadBoxSize - unitDx * arrowHeadBoxSize})

    Draw.Line(startPoint, endPoint)
    Draw.Line(arrowPoint1, endPoint)
    Draw.Line(arrowPoint2, endPoint)

end

--[[
"Enum's"
--]]
TARGET_SELF = 1
TARGET_TARGETED = 2
TARGET_LINEAR = 3
TARGET_CIRCULAR = 4
TARGET_CONE = 5
TARGET_UNTARGETED = 6
TARGET_SPECIAL = 7

DAMAGE_MAGIC = 1
DAMAGE_PHYSIC = 2
DAMAGE_MIXED = 3
DAMAGE_TRUE = 4
DAMAGE_OTHER = 5
DAMAGE_NONE = 6

TEAM_ALLY = myHero.team
TEAM_ENEMY = (myHero.team == 100 and 200 or 100)
TEAM_OTHER = 300

--[[
###############################
###############################
###############################
###############################
Spell Class
###############################
###############################
###############################
###############################
--]]

--[[
SpellSlot = {_Q, _W, _E, _R,
  ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, ITEM_7,
  SUMMONER_1, SUMMONER_2}
SpellData = {
  type (number)
  manacost (function(level))

  for non self:
  range (number)

  for linear:
  width (number)
  for circular:
  radius (number)
  for cone:
  coneAngle (number)
  coneDistance (number)
}
--]]

class"Spell"
function Spell:__init (SpellSlot,SpellData)
  assert(type(SpellSlot) == "number", "Invalid Spellslot Type. Got: "..type(SpellSlot))
  assert(type(SpellData) == "table", "Invalid SpellData Type. Got: "..type(SpellData))
  self.slot = SpellSlot
  self.castSlot = (SpellSlot == 0 and HK_Q) or (SpellSlot == 1 and HK_W) or (SpellSlot == 2 and HK_E) or (SpellSlot == 3 and HK_R)
  self.spelldata = SpellData
end

function Spell:Cast(targetorX, Y, Z)
    --Make sure cursor is over target. .... Gos pls fix

  if Game.CanUseSpell(self.slot) ~= READY then return end
  if(type(targetorX) ~= "number" and targetorX ~= nil)then
    Control.SetCursorPos(targetorX)
    Control.CastSpell(self.castSlot, targetorX.pos.x,targetorX.pos.y, targetorX.pos.z)
  elseif(type(targetorX) == "number")then
    Control.SetCursorPos(targetorX, Z)
    Control.CastSpell(self.castSlot, targetorX, Y, Z)
  else
    Control.CastSpell(self.castSlot)
  end
end

function Spell:CanUseSpell(target)
  if(target and not self.spelldata.type == 1)then
    return Game.CanUseSpell(self.slot) == READY and GetDistance(target) < self.spelldata.range
  else
    return Game.CanUseSpell(self.slot) == READY
  end
end

function Spell:GetDamage(target, source, stagedmg, spelllvl)
  local slots = {_Q = "Q", _W = "W", _E = "E", _R = "R"}
  return getdmg(slots[self.slot], target, source, stagedmg, spelllvl)
end

function Spell:GetManaCost (level)
  level = level or myHero:GetSpellData(self.slot).level
  return self.spelldata.manacost(level)
end

function Spell:GetLevel ()
  return myHero:GetSpellData(self.slot).level
end

--[[
###############################
###############################
###############################
###############################
objManager
###############################
###############################
###############################
###############################
--]]

local objManager_update_interval = 6
local objManager_next_update = 0

function AddCreateObjectCallbackMenu()
  S1mpleLibMenu:MenuElement({type = MENU, id = "ObjectCallback", name = "Object Callback"})
  S1mpleLibMenu.ObjectCallback:MenuElement({id = "ups", name = "Updates per Second", value = 6, min = 1, max = 10, step = 1, callback = function()
        if(S1mpleLibMenu.ObjectCallback.ups)then objManager_update_interval = S1mpleLibMenu.ObjectCallback.ups:Value() end
        end})

    objManager_update_interval = S1mpleLibMenu.ObjectCallback.ups:Value()
  end
  AddCreateObjectCallbackMenu()

  local objManager_Ccallbacks = {}
  local objManager_Dcallbacks = {}

  function AddCreateObjectCallback(func)
    local l = #objManager_Ccallbacks
    objManager_Ccallbacks[l+1] = func
    return l
  end

  function AddDeleteObjectCallback(func)
    local l = #objManager_Dcallbacks
    objManager_Dcallbacks[l+1] = func
    return l
  end

  function DelCreateObjectCallback(id)
    objManager_Ccallbacks[id] = nil
  end

  function DelDeleteObjectCallback(id)
    objManager_Dcallbacks[id] = nil
  end

  local objManager_objects = {}
  local objManager_objects_mt = {
    __len = function()
      local count = 0
      for _ in pairs(objManager_objects) do count = count + 1 end
      return count
    end
  }
  setmetatable(objManager_objects, objManager_objects_mt)

  function objManager_OnTick()
    if os.clock() < objManager_next_update then
      return
    end

    objManager_next_update = os.clock()+(10-objManager_update_interval)*0.1

    for k,v in pairs(objManager_objects) do
      if (not v or not v.valid) and v.name == "Seed" then
        objManager_objects[v.networkID] = nil
        for i=1,#objManager_Dcallbacks do
          objManager_Dcallbacks[i](v)
        end
      end
    end

    for i=1,Game.ObjectCount() do
      local current = Game.Object(i)
      if current and current.valid then
        objManager_objects[current.networkID] = current
        for i=1,#objManager_Ccallbacks do
          objManager_Ccallbacks[i](current)
        end
      end
    end
  end

  Callback.Add("Tick", function()
      objManager_OnTick()
    end)

  Callback.Add("Load", function()
      for i=1,Game.ObjectCount() do
        local obj = Game.Object(i)
        if obj and obj.valid then
          objManager_objects[obj.networkID] = obj
        end
      end
    end)

  --[[
  ###############################
  ###############################
  ###############################
  ###############################
  targetSelector
  ###############################
  ###############################
  ###############################
  ###############################
  --]]

  TARGET_LOW_HP = 1
  TARGET_MOST_AP = 2
  TARGET_MOST_AD = 3
  TARGET_NEAR_MOUSE = 4
  TARGET_PRIORITY = 5
  TARGET_LOW_HP_PRIORITY = 6
  TARGET_CLOSEST = 7

  class("TargetSelector")
  function TargetSelector:__init()
    self.target_type = TARGET_PRIORITY
    self:Menu()
  end

  function TargetSelector:Menu()
    S1mpleLibMenu:MenuElement({type = MENU, id = "ts", name = "TargetSelector"})
    self.menu = S1mpleLibMenu.ts
    self.menu:MenuElement({id = "mode", name = "Target Selection Mode", value = TARGET_LOW_HP_PRIORITY, drop = {"Low HP", "Most AP", "Most AD", "Near Mouse", "Priority", "Low HP Priority", "Closest"}, callback = function(v) if(self.menu.mode) then self.target_type = self.menu.mode:Value() end end})
    for i=1,#GetEnemyHeroes() do
      local current = GetEnemyHeroes()[i]
      self.menu:MenuElement({id = "prio"..current.charName, name = current.charName, value = 3, min = 1, max = 5, step = 1})
    end
  end

  function TargetSelector:GetTarget(range, checkCollision, spellWidth)
    local possible_targets = {}
    for i=1,#GetEnemyHeroes() do
      local enemy = GetEnemyHeroes()[i]
      if enemy and enemy.valid and not enemy.dead and GetDistance(myHero, enemy) < range then
        if(checkCollision)then
          if(not GetMinionCollision(myHero.pos, enemy.pos, spellWidth, GetMinionsNear(myHero, range, TEAM_ENEMY)))then
            possible_targets[#possible_targets+1] = enemy
          end
        else
          possible_targets[#possible_targets+1] = enemy
        end
      end
    end
    if(#possible_targets == 0)then
      return nil
    end

    local target = possible_targets[1]
    local prio = self.menu["prio"..target.charName]:Value()

    if(self.target_type == TARGET_LOW_HP)then
      for i=1,#possible_targets do
        local current = possible_targets[i]
        if(current.health < target.health)then
          target = current
        end
      end
    elseif(self.target_type == TARGET_MOST_AP)then
      for i=1,#possible_targets do
        local current = possible_targets[i]
        if(current.ap > target.ap)then
          target = current
        end
      end
    elseif(self.target_type == TARGET_MOST_AD)then
      for i=1,#possible_targets do
        local current = possible_targets[i]
        if(current.ad > target.ad)then
          target = current
        end
      end
    elseif(self.target_type == TARGET_NEAR_MOUSE)then
      for i=1,#possible_targets do
        local current = possible_targets[i]
        if(GetDistanceSqr(current, mousePos) < GetDistanceSqr(target, mousePos))then
          target = current
        end
      end
    elseif(self.target_type == TARGET_PRIORITY)then
      for i=1,#possible_targets do
        local current = possible_targets[i]
        if(self.menu["prio"..current.charName]:Value() > prio)then
          target = current
        end
      end
    elseif(self.target_type == TARGET_LOW_HP_PRIORITY)then
      for i=1,#possible_targets do
        local current = possible_targets[i]
        if(self.menu["prio"..current.charName]:Value() > prio)then
          target = current
        elseif (self.menu["prio"..current.charName]:Value() == prio)then
          if(current.health < target.health)then
            target = current
          end
        end
      end
    elseif(self.target_type == TARGET_CLOSEST)then
      for i=1,#possible_targets do
        local current = possible_targets[i]
        if(GetDistanceSqr(current, myHero) < GetDistanceSqr(target, myHero))then
          target = current
        end
      end
    end

    return target, prio
  end

  TargetSelector = TargetSelector()

  --[[

  Credits:
  - gReY (VectorPointProjectionOnLineSegment)

  --]]
