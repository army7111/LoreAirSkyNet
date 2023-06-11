-- Creazione delle istanze dei magazzini
local warehouses = {
    WAREHOUSE:New(STATIC:FindByName("WHCyproEast"), "WHCyproEast"),
    WAREHOUSE:New(STATIC:FindByName("WHCyproGeck"), "WHCyproGeck"),
    WAREHOUSE:New(STATIC:FindByName("WHCyproErcan"), "WHCyproErcan"),
}

warehouses.WHCyproEast:SetAutoDefenceOn(true)
warehouses.WHCyproGeck:SetAutoDefenceOn(true)
warehouses.WHCyproErcan:SetAutoDefenceOn(true)

-- Dichiara tipo di Unità dai template

local tank=GROUP:FindByName("REDWARTank")
local infantry=GROUP:FindByName("REDWARInfantry")
local truck=GROUP:FindByName("REDWARTruck")
local sam=GROUP:FindByName("REDWARSA19")
local aaa=GROUP:FindByName("REDWARAAAShilka")
local rpg=GROUP:FindByName("REDWARInRPG")

-- Caricamento Asset Standard

for _, warehouse in pairs(warehouses) do 
    warehouse:AddAsset(infantry, 20)
    warehouse:AddAsset(tank, 8)
    warehouse:AddAsset(truck, 16)
    warehouse:AddAsset(sam, 8)
    warehouse:AddAsset(aaa, 8)
    warehouse:AddAsset(rpg, 20)
    warehouse:Start()
end

