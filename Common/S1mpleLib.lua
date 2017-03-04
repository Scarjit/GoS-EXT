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
S1mpleLibVersion = 1.4
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
Minimum Enclosing Circle
Thanks to DelusionalLogic (github)
###############################
###############################
###############################
###############################
--]]

-- Circle Class
--[[
Methods:
circle = Circle(center (opt),radius (opt))
Function :
circle:Contains(v) -- return if Vector point v is in the circle
Members :
circle.center -- Vector point for circle's center
circle.radius -- radius of the circle
]]
class'Circle'
function Circle:__init(center, radius)
  assert((VectorType(center) or center == nil) and (type(radius) == "number" or radius == nil), "Circle: wrong argument types (expected <Vector> or nil, <number> or nil)")
  self.center = Vector(center) or Vector()
  self.radius = radius or 0
end

function Circle:Contains(v)
  assert(VectorType(v), "Contains: wrong argument types (expected <Vector>)")
  return math.close(self.center:dist(v), self.radius)
end

function Circle:__tostring()
  return "{center: " .. tostring(self.center) .. ", radius: " .. tostring(self.radius) .. "}"
end

-- ===========================
-- Minimum enclosing circle algorithm
-- ---------------------------
-- Much of this code was inspired from the ruby implementation at:
-- [http://www.dseifert.net/code/mec/source.html]
-- ===========================

-- ===========================
-- Copy the array portion of the table.
-- ===========================
function CopyArray(t)
  local ret = {}
  for i,v in ipairs(t) do
    ret[i] = v
  end
  return ret
end

-- ===========================
-- Create a new array, minus the element at the specified index
-- ===========================
function DeleteAt(t, index)
  local ret = {}
  for i,v in ipairs(t) do
    if i ~= index then
      table.insert(ret, v)
    end
  end
  return ret
end

-- ===========================
-- Joins arrays t1 and t2 and outputs only the unique elements.
-- ===========================
function JoinUniqueArrayElements(t1, t2)
  local ret = {}
  local unique = {}
  -- Place the elements of t1 and t2 into the unique dictionary
  for i,p in ipairs(t1) do
    unique["x" .. p.x .. "z" .. p.z] = p
  end
  for i,p in ipairs(t2) do
    unique["x" .. p.x .. "z" .. p.z] = p
  end
  -- Insert each element of unique into the return array.
  for k,p in pairs(unique) do
    table.insert(ret, p)
  end
  return ret
end

-- ===========================
-- Minimum Enclosing Circle object and algorithm
-- ===========================
MEC = {
  -- ===========================
  -- Create a new MEC table
  -- ===========================
  New = function(self, points)
    local mec = {}
    mec = setmetatable({}, {__index = self})
    mec.circle = nil
    mec.points = {} -- a table of x,z coordinates

    if points then
      mec:SetPoints(points)
    end

    return mec
  end,

  -- ===========================
  -- Set the points used to compute the MEC.
  -- points is an array, starting at 1.
  -- ===========================
  SetPoints = function(self, points)
    -- Set the points
    self.points = points
    for i, p in ipairs(self.points) do
      p = Vector:New(p)
    end
  end,

  -- ===========================
  -- Computes the half hull of a set of points
  -- ===========================
  HalfHull = function(left, right, pointTable, factor)
    local input = CopyArray(pointTable)
    table.insert(input, right)
    local half = {}
    table.insert(half, left)
    for i,p in ipairs(input) do
      table.insert(half, p)
      while #half >= 3 do
        local dir = factor * Vector.Direction(half[(#half+1)-3], half[(#half+1)-1], half[(#half+1)-2])
        if dir <= 0 then
          half = DeleteAt(half, #half-1)
        else
          break
        end
      end
    end
    return half
  end,

  -- ===========================
  -- Computes the set of points that represent the
  -- convex hull of the set of points
  -- ===========================
  ConvexHull = function(self)
    local a = self.points
    local left = a[1]
    local right = a[#a]
    local upper = {}
    local lower = {}

    -- Partition remaining points into upper and lower buckets.
    for i = 2, #a-1 do
      local dir = Vector.Direction(left, right, a[i])
      if dir < 0 then
        table.insert(upper, a[i])
      else
        table.insert(lower, a[i])
      end
    end

    local upperHull = self.HalfHull(left, right, upper, -1)
    local lowerHull = self.HalfHull(left, right, lower, 1)

    return JoinUniqueArrayElements(upperHull, lowerHull)
  end,

  -- ===========================
  -- Compute the MEC.
  -- ===========================
  Compute = function(self)
    self.circle = self.circle or Circle:New()

    -- Make sure there are some points.
    if #self.points == 0 then return self.circle end

    -- Handle degenerate cases first
    if #self.points == 1 then
      self.circle.center = self.points[1]
      self.circle.radius = 0
      self.circle.radiusPoint = self.points[1]
    elseif #self.points == 2 then
      local a = self.points
      self.circle.center = a[1]:Center(a[2])
      self.circle.radius = a[1]:Distance(self.circle.center)
      self.circle.radiusPoint = a[1]
    else
      local a = self:ConvexHull()
      local point_a = a[1]
      local point_b = nil
      local point_c = a[2]

      if not point_c then
        self.circle.center = point_a
        self.circle.radius = 0
        self.circle.radiusPoint = point_a
        return self.circle
      end

      -- Loop until we get appropriate values for point_a and point_c
      while true do
        point_b = nil
        local best_theta = 180.0
        -- Search for the point "b" which subtends the smallest angle a-b-c.
        for i,point in ipairs(self.points) do
          if (not point:Equals(point_a)) and (not point:Equals(point_c)) then
            local theta_abc = point:AngleBetween(point_a, point_c)
            if theta_abc < best_theta then
              point_b = point
              best_theta = theta_abc
            end
          end
        end
        -- If the angle is obtuse, then line a-c is the diameter of the circle,
        -- so we can return.
        if best_theta >= 90.0 or (not point_b) then
          self.circle.center = point_a:Center(point_c)
          self.circle.radius = point_a:Distance(self.circle.center)
          self.circle.radiusPoint = point_a
          return self.circle
        end
        local ang_bca = point_c:AngleBetween(point_b, point_a)
        local ang_cab = point_a:AngleBetween(point_c, point_b)
        if ang_bca > 90.0 then
          point_c = point_b
        elseif ang_cab <= 90.0 then
          break
        else
          point_a = point_b
        end
      end
      local ch1 = (point_b - point_a):Scale(0.5)
      local ch2 = (point_c - point_a):Scale(0.5)
      local n1 = ch1:NormalLeft()
      local n2 = ch2:NormalLeft()
      ch1 = point_a + ch1
      ch2 = point_a + ch2
      self.circle.center = Vector.InfLineIntersection (ch1, n1, ch2, n2)
      self.circle.radius = self.circle.center:Distance(point_a)
      self.circle.radiusPoint = point_a
    end
    return self.circle
  end,
}

function __check_if_target(obj,range,R)
  return obj ~= nil and obj.team == TEAM_ENEMY and not obj.dead and obj.visible and player:GetDistance(obj) <= (range + R)
  --return obj ~= nil
end

function __check_if_near_target(obj,target,range,R)
  return obj ~= nil and obj.team == target.team and not obj.dead and obj.visible and obj:GetDistance(target) <= R*2
end

function FindGroupCenterNearTarget(target,R,range)
  local playerCount = heroManager.iCount
  local points = {}
  for i = 1, playerCount, 1 do
    local object = heroManager:GetHero(i)
    if __check_if_near_target(object,target,range,R) or object == target then -- finding enemies near our target. grouping them in points table.
      table.insert(points, Vector:New(object.x,object.z))
    end
  end
  return CalcSpellPosForGroup(R,range,points)
end

function FindGroupCenterFromNearestEnemies(R,range)
  local playerCount = heroManager.iCount
  local points = {}
  for i = 1, playerCount, 1 do
    local object = heroManager:GetHero(i)
    if __check_if_target(object,range,R) then -- finding enemies in our range (spell range + AoE radius) and grouping them in points table.
      table.insert(points, Vector:New(object.x,object.z))
    end
  end
  return CalcSpellPosForGroup(R,range,points)
end

-- ============================================================
-- Weee's additional stuff:
-- ============================================================

-- =======================
-- CalcCombosFromString is used to fill table "comboTableToFill[]" with unique
-- combinations (with size of comboSize) generated from table "targetsTable[]".
-- =======================
function CalcCombosFromString(comboString,index_number,comboSize,targetsTable,comboTableToFill)
  if string.len(comboString) == comboSize then
    local b = {}
    for i=1,string.len(comboString),1 do
      local ai = tonumber(string.sub(comboString,i,i))
      table.insert(b,targetsTable[ai])
    end
    return table.insert(comboTableToFill,b)
  end
  for i = index_number, #targetsTable, 1 do
    CalcCombosFromString(comboString..i,i+1,comboSize,targetsTable,comboTableToFill)
  end
end

-- =======================
-- CalcSpellPosForGroup is used to get optimal position for your AoE circle spell (annie ult, brand W, etc).
-- It will always return MEC with position, where spell will hit most players and where players will be staying closer to each other.
-- =======================
function CalcSpellPosForGroup(spellRadius,spellRange,enemyTable)
  if #enemyTable == 1 then
    return { center = { x = enemyTable[1].x, z = enemyTable[1].z } }
  end
  local combos = {
    [5] = {}, -- 5-player combos
    [4] = {}, -- 4-player combos
    [3] = {}, -- 3-player combos
    [2] = {}, -- 2-player combos
  }
  mec = MEC:New()
  for j = #enemyTable,2,-1 do
    CalcCombosFromString("",1,j,enemyTable,combos[j])
    local spellPos = nil
    for i,v in ipairs(combos[j]) do
      mec:SetPoints(v)
      local c = mec:Compute()
      if c.radius <= spellRadius and (spellPos == nil or c.radius < spellPos.radius) then
        spellPos = Circle:New()
        spellPos.center = c.center
        spellPos.radius = c.radius
      end
    end
    if spellPos ~= nil then return spellPos end
  end
end

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
    if m and m.valid and m.visible and not m.dead and (team and m.team == team or true) and GetDistance(m, target) < range then
      minions[#minions+1] = m
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
  return (_G.Orbwalker.Combo:Value() and "Combo") or (_G.Orbwalker.Harass:Value() and "Harass") or (_G.Orbwalker.Farm:Value() and "Farm") or (_G.Orbwalker.LastHit:Value() and "LastHit") or "None"
end

function math.perc(current, max)
  return current/max*100
end

function WorldToScreen (obj)
  if not obj.x then obj = obj.pos end
  local V = Vector(obj.x, obj.y, obj.z)
  return V:To2D()
end

function DrawText3D (text, x, y, z, color, size)
  size = size or 12
  color = color or Draw.Color(255,255,255,255)
  local wts = WorldToScreen({x = x, y = y, z = z})
  Draw.Text(text, size, wts.x, wts.y, color)
end

function Is3DVector(v)
  if(v.x and v.y and v.z)then
    return true
  end
end

--[[
VectorPointProjectionOnLineSegment: Extended VectorPointProjectionOnLine in 2D Space
v1 and v2 are the start and end point of the linesegment
v is the point next to the line
return:
pointSegment = the point closest to the line segment (table with x and y member)
pointLine = the point closest to the line (assuming infinite extent in both directions) (table with x and y member), same as VectorPointProjectionOnLine
isOnSegment = if the point closest to the line is on the segment
]]
function VectorPointProjectionOnLineSegment(v1, v2, v)
  assert(v1 and v2 and v, "VectorPointProjectionOnLineSegment: wrong argument types (3 <Vector> expected)")
  local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
  local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
  local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
  local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
  local isOnSegment = rS == rL
  local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
  return pointSegment, pointLine, isOnSegment
end

-- GetMinionCollision
--[[
Global Function :
GetMinionCollision(posEnd, spellWidth) -> return true/false if collision with minion from player to posEnd with spellWidth.
]]
local function _minionInCollision(minion, posStart, posEnd, spellSqr, sqrDist)
  if GetDistanceSqr(minion, posStart) < sqrDist and GetDistanceSqr(minion, posEnd) < sqrDist then
    local _, p2, isOnLineSegment = VectorPointProjectionOnLineSegment(posStart, posEnd, minion)
    if isOnLineSegment and GetDistanceSqr(minion, p2) <= spellSqr then return true end
  end
  return false
end

function GetMinionCollision(posStart, posEnd, spellWidth, minionTable)
  assert(Is3DVector(posStart) and Is3DVector(posEnd) and type(spellWidth) == "number", "GetMinionCollision: wrong argument types (<Vector>, <Vector>, <number> expected)")
  local sqrDist = GetDistanceSqr(posStart, posEnd)
  local spellSqr = spellWidth * spellWidth / 4
  if minionTable then
    for _, minion in pairs(minionTable) do
      if _minionInCollision(minion.pos, posStart, posEnd, spellSqr, sqrDist) then return true end
    end
  else
    for i = 0, objManager.maxObjects, 1 do
      local object = objManager:getObject(i)
      if object and object.valid and object.team ~= player.team and object.type == "obj_AI_Minion" and not object.dead and object.visible and object.bTargetable then
        if _minionInCollision(object, posStart, posEnd, spellSqr, sqrDist) then return true end
      end
    end
  end
  return false
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
  damagetype (number)
  damageformular (function(self, target, level))
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
  if Game.CanUseSpell(self.slot) ~= READY then return end
  if(type(targetorX) ~= "number" and targetorX ~= nil)then
    Control.CastSpell(self.castSlot, targetorX.pos.x,targetorX.pos.y, targetorX.pos.z)
  elseif(type(targetorX) == "number")then
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

function Spell:GetDamage(target)
  if(myHero:GetSpellData(self.slot).level == 0)then
    return 0
  end
  return self.spelldata.damageformular(myHero, target, myHero:GetSpellData(self.slot).level)
end

function Spell:GetManaCost (level)
  level = level or myHero:GetSpellData(self.slot).level
  return self.spelldata.manacost(level)
end

function Spell:GetLevel ()
  return myHero:GetSpellData(self.slot).level
end

function Spell:GetRealDamage(target)
  if(not self:CanUseSpell(target))then return 0 end

  if(self.spelldata.damagetype == DAMAGE_MAGIC)then
    local dmg_mult = 1
    local targetArmor = target.magicResist * myHero.magicPenPercent - myHero.magicPen
    if targetArmor >= 0 then
      dmg_mult = 100 / (100 + targetArmor)*dmg_mult
    else
      dmg_mult = dmg_mult*1
    end
    local dmg = dmg_mult * self:GetDamage(target)
    return dmg

  elseif(self.spelldata.damagetype == DAMAGE_PHYSIC)then
    local dmg_mult = 1
    local targetArmor = target.armor * myHero.armorPenPercent - myHero.armorPen
    if targetArmor >= 0 then
      dmg_mult = 100 / (100 + targetArmor)*dmg_mult
    else
      dmg_mult = dmg_mult*1
    end
    local dmg = dmg_mult * self:GetDamage(target)
    return dmg

  elseif(self.spelldata.damagetype == DAMAGE_MIXED)then
    --TODO
    return self:GetDamage(target)

  elseif(self.spelldata.damagetype == DAMAGE_TRUE)then
    return self:GetDamage(target)
  elseif(self.spelldata.damagetype == DAMAGE_OTHER)then
    return self:GetDamage(target)
  elseif(self.spelldata.damagetype == DAMAGE_OTHER)then
    return self:GetDamage(target)
  else --This should never happen
    return self:GetDamage(target)
  end
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
      if enemy and enemy.valid and GetDistance(myHero, enemy) < range then
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
