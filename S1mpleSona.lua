--[[
    S1mple Sona
--]]
local version = 1.0

function RequireS1mpleLib(version)
    if(io.open(COMMON_PATH.."S1mpleLib.lua","r") == nil)then
        print("Missing S1mpleLib")
        return false
    end

    require("S1mpleLib")
    if(S1mpleLibVersion < version)then
        print("Outdated S1mpleLib Version")
        return false
    end

    return true
end

if not RequireS1mpleLib(1.0) then return end


local Q = Spell(_Q, {range = 850, type = TARGET_UNTARGETED, damagetype = DAMAGE_MAGIC, damageformular = function(s,t,l)
    return 30+10*l+s.ap*0.5
end, manacost = function(l) return 40+5*l end})

local W = Spell(_W, {range = 1000, type = TARGET_UNTARGETED, damagetype = DAMAGE_OTHER, damageformular = function(s,t,l)
    return (15+20*l+s.ap*0.25)*-1 --Heals instead of damaging ;)
end, manacost = function(l) return 75+5*l end})

local E = Spell(_E, {range = 400, type = TARGET_UNTARGETED, damagetype = DAMAGE_NONE, damageformular = function(s,t,l)
    return 0
end, manacost = function(l) return 65 end})

local R = Spell(_R, {range = 900, type = TARGET_LINEAR, damagetype = DAMAGE_MAGIC, damageformular = function(s,t,l)
    return 50+100*l+s.ap*0.5
end, width = 140, manacost = function(l) return 100 end})

local menu

function Menu()
    menu = MenuElement({type = MENU, id = "S1mpleSona", name = "S1mple Sona [V "..tostring(version).."]", leftIcon = "http://s1mplescripts.de/S1mple/Scripts/GoS/S1mpleSona/Images/Sona.png"})
    menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})

        menu.Combo:MenuElement({type = SPACE, name = " [Hymn of Valor] ", leftIcon = "http://s1mplescripts.de/S1mple/Scripts/GoS/S1mpleSona/Images/SonaQ.png"})
        menu.Combo:MenuElement({id = "useQ", name = "Use Q", value = true})
        menu.Combo:MenuElement({id = "minEnemysQ", name = "Min Enemy Champions", value = 1, min = 1, max = 2, step = 1})
        menu.Combo:MenuElement({id = "minManaQ", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})

        menu.Combo:MenuElement({type = SPACE, name = " [Song of Celerity] ", leftIcon = "http://s1mplescripts.de/S1mple/Scripts/GoS/S1mpleSona/Images/SonaE.png"})
        menu.Combo:MenuElement({id = "useE", name = "Use E", value = true})
        menu.Combo:MenuElement({id = "minAllysE", name = "Min Ally Champions", value = 0, min = 0, max = 5, step = 1})
        menu.Combo:MenuElement({id = "minEnemysE", name = "Min Enemy Champions", value = 0, min = 0, max = 5, step = 1})
        menu.Combo:MenuElement({id = "minManaE", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})

        menu.Combo:MenuElement({type = SPACE, name = " [Crescendo] ", leftIcon = "http://s1mplescripts.de/S1mple/Scripts/GoS/S1mpleSona/Images/SonaR.png"})
        menu.Combo:MenuElement({id = "useR", name = "Use R", value = true})
        menu.Combo:MenuElement({id = "minEnemysR", name = "Min Enemy Champions", value = 1, min = 1, max = 5, step = 1})
        menu.Combo:MenuElement({id = "minManaR", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})
        menu.Combo:MenuElement({id = "saveForR", name = "Save Mana for R", value = true})

    menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})

        menu.Harass:MenuElement({type = SPACE, name = " [Hymn of Valor] ", leftIcon = "http://s1mplescripts.de/S1mple/Scripts/GoS/S1mpleSona/Images/SonaQ.png"})
        menu.Harass:MenuElement({id = "useQ", name = "Use Q", value = true})
        menu.Harass:MenuElement({id = "minEnemysQ", name = "Min Enemy Champions", value = 1, min = 1, max = 2, step = 1})
        menu.Harass:MenuElement({id = "minManaQ", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})

        menu.Harass:MenuElement({type = SPACE, name = " [Song of Celerity] ", leftIcon = "http://s1mplescripts.de/S1mple/Scripts/GoS/S1mpleSona/Images/SonaE.png"})
        menu.Harass:MenuElement({id = "useE", name = "Use E", value = true})
        menu.Harass:MenuElement({id = "minAllysE", name = "Min Ally Champions", value = 0, min = 0, max = 5, step = 1})
        menu.Harass:MenuElement({id = "minEnemysE", name = "Min Enemy Champions", value = 0, min = 0, max = 5, step = 1})
        menu.Harass:MenuElement({id = "minManaE", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})

        menu.Harass:MenuElement({type = SPACE, name = " [Crescendo] ", leftIcon = "http://s1mplescripts.de/S1mple/Scripts/GoS/S1mpleSona/Images/SonaR.png"})
        menu.Harass:MenuElement({id = "useR", name = "Use R", value = true})
        menu.Harass:MenuElement({id = "minEnemysR", name = "Min Enemy Champions", value = 1, min = 1, max = 5, step = 1})
        menu.Harass:MenuElement({id = "minManaR", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})
        menu.Harass:MenuElement({id = "saveForR", name = "Save Mana for R", value = true})

    menu:MenuElement({type = MENU, id = "Laneclear", name = "Laneclear"})
        menu.Laneclear:MenuElement({type = SPACE, name = " [Hymn of Valor] ", leftIcon = "http://s1mplescripts.de/S1mple/Scripts/GoS/S1mpleSona/Images/SonaQ.png"})
        menu.Laneclear:MenuElement({id = "useQ", name = "Use Q", value = true})
        menu.Laneclear:MenuElement({id = "minManaQ", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})

    menu:MenuElement({type = MENU, id = "Heal", name = "Heal Settings", leftIcon = "http://s1mplescripts.de/S1mple/Scripts/GoS/S1mpleSona/Images/SonaW.png"})
        menu.Heal:MenuElement({id = "useW", name = "Use W", value = true})
        menu.Heal:MenuElement({id = "healOnRecall", name = "Heal on Recall", value = false})
        menu.Heal:MenuElement({id = "minSelfManaW", name = "Min Self Heal Mana %", value = 0, min = 0, max = 100, step = 1})
        menu.Heal:MenuElement({id = "minSelfHP", name = "Min Self HP %", value = 50, min = 0, max = 100, step = 1})

        if(#GetAllyHeroes() >= 1)then
            menu.Heal:MenuElement({id = "minAllyHP", name = "Min Ally HP %", value = 30, min = 0, max = 100, step = 1})
                menu.Heal:MenuElement({id = "minAllyManaW", name = "Min Ally Mana %", value = 30, min = 0, max = 100, step = 1})
            menu.Heal:MenuElement({type = SPACE, name = ""})
            for i=1,#GetAllyHeroes() do
                local current = GetAllyHeroes()[i]
                menu.Heal:MenuElement({id = "heal"..current.charName, name = "Heal "..current.charName, value = true})
            end
        end

    menu:MenuElement({type = MENU, id = "misc", name = "Misc"})
        menu.misc:MenuElement({id = "autoR", name = "Enable Auto R", value = true, rightIcon = "http://s1mplescripts.de/S1mple/Scripts/GoS/S1mpleSona/Images/SonaR.png"})
        menu.misc:MenuElement({id = "autoRMinHits", name = "Auto R min Hits", value = 4, min = 1, max = 5, step = 1})
        menu.misc:MenuElement({id = "autoROnRecall", name = "Auto R on Recall", value = false})

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

function CastR(min)
    local near = GetObjectsNear(myHero, GetEnemyHeroes(), R.spelldata.range)
    if #near < min then return end
    if min == 1 then
        R:Cast(near[1])
    else
        local castPos = CalcSpellPosForGroup(R.spelldata.width, R.spelldata.range, GetEnemyHeroes())
        if(castPos.center)then
            R:Cast(castPos.center)
        end
    end
end

function Combo()
    if(menu.Combo.saveForR:Value() and myHero.mana < R:GetManaCost() and R:GetLevel() > 0)then
        return
    end

    if(menu.Combo.useR:Value() and math.perc(myHero.mana, myHero.maxMana) > menu.Combo.minManaE:Value())then
        CastR(menu.Combo.minEnemysR:Value())
    end

    if(not menu.Combo.saveForR:Value())then
        if(menu.Combo.useQ:Value() and math.perc(myHero.mana, myHero.maxMana) > menu.Combo.minManaQ:Value() and #GetObjectsNear(myHero,GetEnemyHeroes(), Q.spelldata.range) >= menu.Combo.minEnemysQ:Value())then
            Q:Cast()
        end
        if(menu.Combo.useE:Value() and math.perc(myHero.mana, myHero.maxMana) > menu.Combo.minManaE:Value() and #GetObjectsNear(myHero,GetEnemyHeroes(), Q.spelldata.range) >= menu.Combo.minEnemysE:Value() and #GetObjectsNear(myHero,GetAllyHeroes(), E.spelldata.range) >= menu.Combo.minAllysE:Value())then
            E:Cast()
        end
    else
        if(myHero.mana-Q:GetManaCost() > R:GetManaCost() and menu.Combo.useQ:Value() and math.perc(myHero.mana, myHero.maxMana) > menu.Combo.minManaQ:Value() and #GetObjectsNear(myHero,GetEnemyHeroes(), Q.spelldata.range) >= menu.Combo.minEnemysQ:Value())then
            Q:Cast()
        end
        if(myHero.mana-E:GetManaCost() > R:GetManaCost() and menu.Combo.useE:Value() and math.perc(myHero.mana, myHero.maxMana) > menu.Combo.minManaE:Value() and #GetObjectsNear(myHero,GetEnemyHeroes(), Q.spelldata.range) >= menu.Combo.minEnemysE:Value() and #GetObjectsNear(myHero,GetAllyHeroes(), E.spelldata.range) >= menu.Combo.minAllysE:Value())then
            E:Cast()
        end
    end
end

function Harass()
    if(menu.Harass.saveForR:Value() and myHero.mana < R:GetManaCost() and R:GetLevel() > 0)then
        return
    end

    if(menu.Harass.useR:Value() and math.perc(myHero.mana, myHero.maxMana) > menu.Harass.minManaE:Value())then
        CastR(menu.Harass.minEnemysR:Value())
    end

    if(not menu.Harass.saveForR:Value())then
        if(menu.Harass.useQ:Value() and math.perc(myHero.mana, myHero.maxMana) > menu.Harass.minManaQ:Value() and #GetObjectsNear(myHero,GetEnemyHeroes(), Q.spelldata.range) >= menu.Harass.minEnemysQ:Value())then
            Q:Cast()
        end
        if(menu.Harass.useE:Value() and math.perc(myHero.mana, myHero.maxMana) > menu.Harass.minManaE:Value() and #GetObjectsNear(myHero,GetEnemyHeroes(), Q.spelldata.range) >= menu.Harass.minEnemysE:Value() and #GetObjectsNear(myHero,GetAllyHeroes(), E.spelldata.range) >= menu.Harass.minAllysE:Value())then
            E:Cast()
        end
    else
        if(myHero.mana-Q:GetManaCost() > R:GetManaCost() and menu.Harass.useQ:Value() and math.perc(myHero.mana, myHero.maxMana) > menu.Harass.minManaQ:Value() and #GetObjectsNear(myHero,GetEnemyHeroes(), Q.spelldata.range) >= menu.Harass.minEnemysQ:Value())then
            Q:Cast()
        end
        if(myHero.mana-E:GetManaCost() > R:GetManaCost() and menu.Harass.useE:Value() and math.perc(myHero.mana, myHero.maxMana) > menu.Harass.minManaE:Value() and #GetObjectsNear(myHero,GetEnemyHeroes(), Q.spelldata.range) >= menu.Harass.minEnemysE:Value() and #GetObjectsNear(myHero,GetAllyHeroes(), E.spelldata.range) >= menu.Harass.minAllysE:Value())then
            E:Cast()
        end
    end
end

function LaneClear()
    if(menu.Laneclear.useQ:Value() and math.perc(myHero.mana, myHero.maxMana) > menu.Laneclear.minManaQ:Value())then
        local nearbyMinions = GetMinionsNear(myHero, Q.spelldata.range, TEAM_ENEMY)
        if(#nearbyMinions > 0)then
            Q:Cast()
        end
    end
end

function AutoHeal()
    if(not menu.Heal.useW:Value())then return end
    if(menu.Heal.healOnRecall:Value() or IsRecalling(myHero)) then return end

    if(menu.Heal.minSelfManaW:Value() <= math.perc(myHero.mana, myHero.maxMana) and menu.Heal.minSelfHP:Value() > math.perc(myHero.health, myHero.maxHealth))then
        W:Cast()
    end

    for i=1,#GetAllyHeroes()do
        local hero = GetAllyHeroes()[i]
        if hero and hero.valid and not hero.dead and GetDistance(hero, myHero) < W.spelldata.range then
            if(menu.Heal["heal"..hero.charName]:Value() and menu.Heal.minAllyManaW:Value() <= math.perc(myHero.mana, myHero.maxMana) and menu.Heal.minAllyHP:Value() > math.perc(hero.health, hero.maxHealth))then
                W:Cast()
            end
        end
    end
end

function AutoR()
    if(menu.misc.autoROnRecall:Value() or IsRecalling(myHero)) then return end
    if(menu.misc.autoR:Value())then
        CastR(menu.misc.autoRMinHits:Value())
    end
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

Callback.Add("Load", function()
    Menu()
    print("S1mple Sona Version " .. tostring(version) .. " loaded")
end)

Callback.Add("Tick", function()
    local orbmode = GetOrbWalkerMode()
    if(orbmode == "Combo") then
        Combo()
    elseif(orbmode == "Harass") then
        Harass()
    elseif(orbmode == "Farm") then
        LaneClear()
    end
    AutoR()
    AutoHeal()
end)

Callback.Add("Draw", function()
    SpellRangeDraws()
end)
