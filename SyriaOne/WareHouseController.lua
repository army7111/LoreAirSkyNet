-- Creazione delle istanze dei magazzini
local warehouses = {
    WAREHOUSE:New(STATIC:FindByName("WHCyproEast"), "WHCyproEast"),
    WAREHOUSE:New(STATIC:FindByName("WHCyproGeck"), "WHCyproGeck"),
    WAREHOUSE:New(STATIC:FindByName("WHCyproErcan"), "WHCyproErcan"),
}

for i, warehouse in ipairs(warehouses) do
    warehouse:SetAutoDefenceOn(true)
    -- Dichiara tipo di Unità dai template
    local tank=GROUP:FindByName("REDWARTank")
    local infantry=GROUP:FindByName("REDWARInfantry")
    local truck=GROUP:FindByName("REDWARTruck")
    local sam=GROUP:FindByName("REDWARSA19")
    local aaa=GROUP:FindByName("REDWARAAAShilka")
    local rpg=GROUP:FindByName("REDWARInRPG")
    -- Caricamento Asset Standard
    warehouse:AddAsset(infantry, 20, WAREHOUSE.Attribute.GROUND_INFANTRY)
    warehouse:AddAsset(tank, 8, WAREHOUSE.Attribute.GROUND_TANK)
    warehouse:AddAsset(truck, 16, WAREHOUSE.Attribute.GROUND_TRUCK)
    warehouse:AddAsset(sam, 8, WAREHOUSE.Attribute.GROUND_SAM)
    warehouse:AddAsset(aaa, 8, WAREHOUSE.Attribute.GROUND_AAA)
    warehouse:AddAsset(rpg, 20, WAREHOUSE.Attribute.GROUND_INFANTRY)
end

warehouses.WHCyproEast:AddRequest(warehouses.WHCyproGeck, WAREHOUSE.Descriptor.UNITTYPE, sam, 2)
-- Dichiara tipo di Unità dai template

--local tank=GROUP:FindByName("REDWARTank")
--local infantry=GROUP:FindByName("REDWARInfantry")
--local truck=GROUP:FindByName("REDWARTruck")
--local sam=GROUP:FindByName("REDWARSA19")
--local aaa=GROUP:FindByName("REDWARAAAShilka")
--local rpg=GROUP:FindByName("REDWARInRPG")

-- Caricamento Asset Standard

--for _, warehouse in pairs(warehouses) do 
--    warehouse:AddAsset(infantry, 20)
--    warehouse:AddAsset(tank, 8)
--    warehouse:AddAsset(truck, 16)
--    warehouse:AddAsset(sam, 8)
--    warehouse:AddAsset(aaa, 8)
--    warehouse:AddAsset(rpg, 20)
--    warehouse:Start()
--end

