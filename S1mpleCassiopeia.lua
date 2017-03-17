--[[
S1mple Cassio
]]--
local version = 0.6

local s1lib = require "S1mpleLib"
if not s1lib then
  print("[Error] Missing Libary, please reload")
  return
end
if S1mpleLibVersion < 1.6 then
  print("[Error] Outdated S1mpleLib Version")
  return
end

local Q = Spell(_Q,{
    range = 850,
    type = TARGET_CIRCULAR,
    manacost = function(l) return 55+5*l end
  })

local W = Spell(_W,{
    range = 800,
    rangemin = 600,
    type = TARGET_CIRCULAR,
    manacost = function(l) return 70 end
  })

local E = Spell(_E,{
    range = 700,
    type = TARGET_CIRCULAR,
    manacost = function(l) return 30+10*l end
  })

local R = Spell(_R,{
    range = 825,
    type = TARGET_CIRCULAR,
    manacost = function(l) return 100 end
  })

local menu
function Menu()
  menu = MenuElement({type = MENU, id = "S1mpleCassiopeia", name = "S1mple Cassiopeia [V "..tostring(version).."]", leftIcon = "https://raw.githubusercontent.com/Scarjit/GoS-EXT/master/Images/S1mpleCassiopeia/Cassiopeia.png"})

  menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
  menu.Combo:MenuElement({type = SPACE, name = " [Noxious Blast] ", leftIcon = "https://raw.githubusercontent.com/Scarjit/GoS-EXT/master/Images/S1mpleCassiopeia/CassiopeiaQ.png"})
  menu.Combo:MenuElement({id = "useQ", name = "Use Q", value = true})
  menu.Combo:MenuElement({id = "minManaQ", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})

  menu.Combo:MenuElement({type = SPACE, name = " [Miasma] ", leftIcon = "https://raw.githubusercontent.com/Scarjit/GoS-EXT/master/Images/S1mpleCassiopeia/CassiopeiaW.png"})
  menu.Combo:MenuElement({id = "useW", name = "Use W", value = true})
  menu.Combo:MenuElement({id = "minManaW", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})

  menu.Combo:MenuElement({type = SPACE, name = " [Twin Fang] ", leftIcon = "https://raw.githubusercontent.com/Scarjit/GoS-EXT/master/Images/S1mpleCassiopeia/CassiopeiaE.png"})
  menu.Combo:MenuElement({id = "useE", name = "Use E", value = true})
  menu.Combo:MenuElement({id = "eOnlyPoisoned", name = "Only targed poisoned", value = true})
  menu.Combo:MenuElement({id = "minManaE", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})

  menu.Combo:MenuElement({type = SPACE, name = " [Petrifying Gaze] ", leftIcon = "https://raw.githubusercontent.com/Scarjit/GoS-EXT/master/Images/S1mpleCassiopeia/CassiopeiaR.png"})
  menu.Combo:MenuElement({id = "useR", name = "Use R", value = true})
  menu.Combo:MenuElement({id = "minManaR", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})
  menu.Combo:MenuElement({id = "minFacing", name = "Min Enemies facing you", value = 2, min = 1, max = 5, step = 1})
  menu.Combo:MenuElement({id = "prio", name = "Priotize", value = 1, drop = {"Low HP", "Closest", "Random"}})

  menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
  menu.Harass:MenuElement({type = SPACE, name = " [Noxious Blast] ", leftIcon = "https://raw.githubusercontent.com/Scarjit/GoS-EXT/master/Images/S1mpleCassiopeia/CassiopeiaQ.png"})
  menu.Harass:MenuElement({id = "useQ", name = "Use Q", value = true})
  menu.Harass:MenuElement({id = "minManaQ", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})

  menu.Harass:MenuElement({type = SPACE, name = " [Miasma] ", leftIcon = "https://raw.githubusercontent.com/Scarjit/GoS-EXT/master/Images/S1mpleCassiopeia/CassiopeiaW.png"})
  menu.Harass:MenuElement({id = "useW", name = "Use W", value = true})
  menu.Harass:MenuElement({id = "minManaW", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})

  menu.Harass:MenuElement({type = SPACE, name = " [Twin Fang] ", leftIcon = "https://raw.githubusercontent.com/Scarjit/GoS-EXT/master/Images/S1mpleCassiopeia/CassiopeiaE.png"})
  menu.Harass:MenuElement({id = "useE", name = "Use E", value = true})
  menu.Harass:MenuElement({id = "eOnlyPoisoned", name = "Only targed poisoned", value = true})
  menu.Harass:MenuElement({id = "minManaE", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})

  menu.Harass:MenuElement({type = SPACE, name = " [Petrifying Gaze] ", leftIcon = "https://raw.githubusercontent.com/Scarjit/GoS-EXT/master/Images/S1mpleCassiopeia/CassiopeiaR.png"})
  menu.Harass:MenuElement({id = "useR", name = "Use R", value = true})
  menu.Harass:MenuElement({id = "minManaR", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})
  menu.Harass:MenuElement({id = "minFacing", name = "Min Enemies facing you", value = 2, min = 1, max = 5, step = 1})
  menu.Harass:MenuElement({id = "prio", name = "Priotize", value = 1, drop = {"Low HP", "Closest", "Random"}})

  menu:MenuElement({type = MENU, id = "Laneclear", name = "Laneclear"})
  menu.Laneclear:MenuElement({type = SPACE, name = " [Noxious Blast] ", leftIcon = "https://raw.githubusercontent.com/Scarjit/GoS-EXT/master/Images/S1mpleCassiopeia/CassiopeiaQ.png"})
  menu.Laneclear:MenuElement({id = "useQ", name = "Use Q", value = true})
  menu.Laneclear:MenuElement({id = "minManaQ", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})

  menu.Laneclear:MenuElement({type = SPACE, name = " [Miasma] ", leftIcon = "https://raw.githubusercontent.com/Scarjit/GoS-EXT/master/Images/S1mpleCassiopeia/CassiopeiaW.png"})
  menu.Laneclear:MenuElement({id = "useW", name = "Use W", value = true})
  menu.Laneclear:MenuElement({id = "minManaW", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})

  menu.Laneclear:MenuElement({type = SPACE, name = " [Twin Fang] ", leftIcon = "https://raw.githubusercontent.com/Scarjit/GoS-EXT/master/Images/S1mpleCassiopeia/CassiopeiaE.png"})
  menu.Laneclear:MenuElement({id = "useE", name = "Use E", value = true})
  menu.Laneclear:MenuElement({id = "eOnlyPoisoned", name = "Only targed poisoned", value = true})
  menu.Laneclear:MenuElement({id = "minManaE", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})

  menu:MenuElement({type = MENU, id = "LastHit", name = "LastHit"})
  menu.LastHit:MenuElement({type = SPACE, name = " [Noxious Blast] ", leftIcon = "https://raw.githubusercontent.com/Scarjit/GoS-EXT/master/Images/S1mpleCassiopeia/CassiopeiaQ.png"})
  menu.LastHit:MenuElement({id = "useQ", name = "Use Q", value = true})
  menu.LastHit:MenuElement({id = "minManaQ", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})

  menu.LastHit:MenuElement({type = SPACE, name = " [Twin Fang] ", leftIcon = "https://raw.githubusercontent.com/Scarjit/GoS-EXT/master/Images/S1mpleCassiopeia/CassiopeiaE.png"})
  menu.LastHit:MenuElement({id = "useE", name = "Use E", value = true})
  menu.LastHit:MenuElement({id = "eOnlyPoisoned", name = "Only targed poisoned", value = false})
  menu.LastHit:MenuElement({id = "minManaE", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})

  menu:MenuElement({type = MENU, id = "draws", name = "Drawings"})
  menu.draws:MenuElement({id = "drawQ", name = "Draw Q range", value = true})
  menu.draws:MenuElement({id = "drawQColor", name = "Q color", color = Draw.Color(255, 0, 0, 255)})

  menu.draws:MenuElement({id = "drawW", name = "Draw W range", value = true})
  menu.draws:MenuElement({id = "drawWColor", name = "W color", color = Draw.Color(255, 0, 255, 0)})

  menu.draws:MenuElement({id = "drawE", name = "Draw E range", value = true})
  menu.draws:MenuElement({id = "drawEColor", name = "E color", color = Draw.Color(255, 139, 0, 139)})

  menu.draws:MenuElement({id = "drawR", name = "Draw R range", value = true})
  menu.draws:MenuElement({id = "drawRColor", name = "R color", color = Draw.Color(255, 255, 215, 0)})

  menu.draws:MenuElement({id = "thickness", name = "Line Thickness", value = 1, min = 1, max = 5, step = 1})
  menu.draws:MenuElement({id = "onlyReady", name = "Only Draw if Spell is Ready", value = true})
end

function SpellRangeDraws()
  if(menu.draws.drawQ:Value())then
    if((menu.draws.onlyReady:Value() and Q:CanUseSpell()) or not menu.draws.onlyReady:Value())then
      Draw.Circle(myHero, Q.spelldata.range, menu.draws.thickness:Value(), menu.draws.drawQColor:Value())
    end
  end

  if(menu.draws.drawW:Value())then
    if((menu.draws.onlyReady:Value() and W:CanUseSpell()) or not menu.draws.onlyReady:Value())then
      Draw.Circle(myHero, W.spelldata.range, menu.draws.thickness:Value(), menu.draws.drawWColor:Value())
    end
  end

  if(menu.draws.drawE:Value())then
    if((menu.draws.onlyReady:Value() and E:CanUseSpell()) or not menu.draws.onlyReady:Value())then
      Draw.Circle(myHero, E.spelldata.range, menu.draws.thickness:Value(), menu.draws.drawEColor:Value())
    end
  end

  if(menu.draws.drawR:Value())then
    if((menu.draws.onlyReady:Value() and R:CanUseSpell()) or not menu.draws.onlyReady:Value())then
      Draw.Circle(myHero, R.spelldata.range, menu.draws.thickness:Value(), menu.draws.drawRColor:Value())
    end
  end
end

function CastR(mode)
  local m = menu[mode]
  if(m.useR:Value() and m.minManaR:Value() < math.perc(myHero.mana, myHero.maxMana))then
    local facing = GetFacing(myHero, GetEnemyHeroes(), R.spelldata.range)
    if(#facing >= m.minFacing:Value())then
      local mmode = m.prio:Value()
      local target = facing[1]
      if(mmode == 1)then --Low HP
        for i=1,#facing do
          local current = facing[i]
          if(current.valid and target.health > current.health and not current.dead)then
            target = current
          end
        end
      elseif(mmode == 2)then --Closest
        for i=1,#facing do
          local current = facing[i]
          if(current.valid and target.health > current.health and not current.dead)then
            target = current
          end
        end
      elseif(mmode == 3)then --Random
        target = facing[math.round(math.random(1, #facing))]
      end
      R:Cast(target)
    end
  end
end

function CastE(mode)
  local m = menu[mode]

  if(m.useE:Value() and m.minManaE:Value() < math.perc(myHero.mana, myHero.maxMana))then
    if(mode == "Combo" or mode == "Harass")then
      if(m.eOnlyPoisoned:Value())then
        local target = TargetSelector:GetTarget(E.spelldata.range)
        if(target and isPoisoned(target))then
          E:Cast(target)
        else
          for i=1,#GetEnemyHeroes() do
            local current = GetEnemyHeroes()[i]
            if(current and current.valid and not current.dead and GetDistance(myHero, current) < E.spelldata.range)then
              E:Cast(current)
            end
          end
        end
      else
        if(TargetSelector:GetTarget(E.spelldata.range) ~= nil)then
          E:Cast(TargetSelector:GetTarget(E.spelldata.range))
        end
      end
    elseif(mode == "Laneclear")then
      if(m.eOnlyPoisoned:Value())then
        for i=1,#GetMinionsNear(myHero, E.spelldata.range, TEAM_ENEMY) do
          local current = GetMinionsNear(myHero, E.spelldata.range, TEAM_ENEMY)[i]
          if(isPoisoned(current))then
            E:Cast(current)
          end
        end
      else
        for i=1,#GetMinionsNear(myHero, E.spelldata.range, TEAM_ENEMY) do
          local current = GetMinionsNear(myHero, E.spelldata.range, TEAM_ENEMY)[i]
          E:Cast(current)
        end
      end
    elseif(mode == "LastHit")then
      if(m.eOnlyPoisoned:Value())then
        for i=1,#GetMinionsNear(myHero, E.spelldata.range, TEAM_ENEMY) do
          local current = GetMinionsNear(myHero, E.spelldata.range, TEAM_ENEMY)[i]
          if(isPoisoned(current) and current.health < E:GetDamage(current, myHero))then
            E:Cast(current)
          end
        end
      else
        for i=1,#GetMinionsNear(myHero, E.spelldata.range, TEAM_ENEMY) do
          local current = GetMinionsNear(myHero, E.spelldata.range, TEAM_ENEMY)[i]
          if(current and current.health < E:GetDamage(current, myHero))then
            E:Cast(current)
          end
        end
      end
    end
  end
end

function CastW(mode)
  local m = menu[mode]
  if(m.useW:Value() and m.minManaW:Value() < math.perc(myHero.mana, myHero.maxMana))then
    if(mode == "Laneclear")then
      for i=1,#GetMinionsNear(myHero, W.spelldata.range, TEAM_ENEMY) do
        local current = GetMinionsNear(myHero, W.spelldata.range, TEAM_ENEMY)[i]
        if(GetDistance(myHero, current) > W.spelldata.rangemin)then
          W:Cast(current)
        end
      end
    else
      local target = TargetSelector:GetTarget(W.spelldata.range)
      if(target and GetDistance(target) > W.spelldata.rangemin)then
        W:Cast(target)
      else
        for i=1,#GetEnemyHeroes() do
          local current = GetEnemyHeroes()[i]
          local dst = GetDistance(current)
          if(dst > W.spelldata.rangemin and dst < W.spelldata.range)then
            W:Cast(current)
          end
        end
      end
    end
  end
end

function CastQ(mode)
  local m = menu[mode]
  if(m.useQ:Value() and m.minManaQ:Value() < math.perc(myHero.mana, myHero.maxMana))then
    if(mode == "Combo" or mode == "Harass")then
      if(TargetSelector:GetTarget(Q.spelldata.range))then
        Q:Cast(TargetSelector:GetTarget(Q.spelldata.range))
      end
    elseif(mode == "Laneclear")then
      for i=1,#GetMinionsNear(myHero, Q.spelldata.range, TEAM_ENEMY) do
        local current = GetMinionsNear(myHero, Q.spelldata.range, TEAM_ENEMY)[i]
        Q:Cast(current)
      end
    elseif(mode == "LastHit")then
      for i=1,#GetMinionsNear(myHero, Q.spelldata.range, TEAM_ENEMY) do
        local current = GetMinionsNear(myHero, Q.spelldata.range, TEAM_ENEMY)[i]
        if(current.health < Q:GetDamage(current, myHero))then
          Q:Cast(current)
        end
      end
    end
  end

end

function Combo()
  CastR("Combo")
  CastE("Combo")
  CastW("Combo")
  CastQ("Combo")
end

function Harass()
  CastR("Harass")
  CastE("Harass")
  CastW("Harass")
  CastQ("Harass")
end

function LaneClear()
  CastE("Laneclear")
  CastW("Laneclear")
  CastQ("Laneclear")
end

function LastHit()
  CastE("LastHit")
  CastQ("LastHit")
end

Callback.Add("Load", function()
    Menu()
    print("S1mple Cassiopeia Version " .. tostring(version) .. " loaded")
  end)

Callback.Add("Tick", function()
    local orbmode = GetOrbWalkerMode()
    if(orbmode == "Combo") then
      Combo()
    elseif(orbmode == "Harass") then
      Harass()
    elseif(orbmode == "Farm") then
      LaneClear()
    elseif(orbmode == "LastHit")then
      LastHit()
    end
  end)

Callback.Add("Draw", function()
    SpellRangeDraws()
  end)

function isPoisoned(target)
  for i=0, target.buffCount do
    local b = target:GetBuff(i)
    if b and b.count > 0 and (b.name == "cassiopeiaqdebuff" or b.name == "cassiopeiawpoison") then
      return true
    end
  end
end
