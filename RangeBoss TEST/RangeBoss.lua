TargetingRange = RANGE:New("Targeting Range")

--inizio dichiarazione StrafePit
local strafePit = "StrafePit"
local foulline = "RangeFoulLine"
TargetingRange:GetFoullineDistance("StrafePit", "RangeFoulLine")
TargetingRange:AddStrafePit(strafePit, nil, nil, nil, true, nil, 500)
TargetingRange:SetMaxStrafeAlt(2500)
TargetingRange:TrackRocketsOFF()
TargetingRange:SetRangeControl(271)
TargetingRange:SetInstructorRadio(272)

-- fine dichiarazione opzioni StrafePit
-- Dichiarazione bombing target

local bombingTargets = "BombingTargetCircle"
local btr80movingtargets = GROUP:FindByName("BombingTargetBTR80")

TargetingRange:AddBombingTargets(bombingTargets, 22)
TargetingRange:AddBombingTargetGroup(btr80movingtargets, 15)

-- Fine dichiarazione opzioni bombing target
TargetingRange:Start()
TargetingRange:SetFunkManOn()
