-----------------------------------
-- Ability: Ninja Roll
-- Enhances evasion for party members within area of effect
-- Optimal Job: Ninja
-- Lucky Number: 4
-- Unlucky Number: 8
-- Jobs:
-- Corsair Level 8
--
-- Die Roll    |With NIN
-- --------    ----------
-- 1           |+4
-- 2           |+5
-- 3           |+5
-- 4           |+14
-- 5           |+6
-- 6           |+7
-- 7           |+9
-- 8           |+2
-- 9           |+10
-- 10          |+11
-- 11          |+18
-- Bust        |-6
-----------------------------------
require("scripts/globals/ability")
require("scripts/globals/status")
require("scripts/globals/msg")
-----------------------------------

function onAbilityCheck(player,target,ability)
    ability:setRange(ability:getRange() + player:getMod(tpz.mod.ROLL_RANGE))

    if player:hasStatusEffect(tpz.effect.NINJA_ROLL) then
        return tpz.msg.basic.ROLL_ALREADY_ACTIVE,0
    elseif atMaxCorsairBusts(player) then
        return tpz.msg.basic.CANNOT_PERFORM,0
    else
        return 0,0
    end
end

function onUseAbility(caster,target,ability,action)
    if caster:getID() == target:getID() then
        corsairSetup(caster, ability, action, tpz.effect.NINJA_ROLL, tpz.job.NIN)
    end

    local total = caster:getLocalVar("corsairRollTotal")

    return applyRoll(caster,target,ability,action,total)
end

function applyRoll(caster,target,ability,action,total)
    local duration = 300 + caster:getMerit(tpz.merit.WINNING_STREAK) + caster:getMod(tpz.mod.PHANTOM_DURATION)
    local effectpowers = {4, 5, 5, 14, 6, 7, 9, 2, 10, 11, 18, 6}
    local effectpower = effectpowers[total]
    if caster:getLocalVar("corsairRollBonus") == 1 and total < 12 then
        effectpower = effectpower + 6
    end

    -- Check if COR Main or Sub
    if caster:getMainJob() == tpz.job.COR and caster:getMainLvl() < target:getMainLvl() then
        effectpower = effectpower * (caster:getMainLvl() / target:getMainLvl())
    elseif caster:getSubJob() == tpz.job.COR and caster:getSubLvl() < target:getMainLvl() then
        effectpower = effectpower * (caster:getSubLvl() / target:getMainLvl())
    end

    if not target:addCorsairRoll(caster:getMainJob(), caster:getMerit(tpz.merit.BUST_DURATION), tpz.effect.NINJA_ROLL, effectpower, 0, duration, caster:getID(), total, tpz.mod.EVA) then
        ability:setMsg(tpz.msg.basic.ROLL_MAIN_FAIL)
    elseif total > 11 then
        ability:setMsg(tpz.msg.basic.DOUBLEUP_BUST)
    end

    return total
end
