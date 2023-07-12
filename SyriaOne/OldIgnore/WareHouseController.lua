US_HQ = COMMANDCENTER:New(GROUP:FindByName("BLUEHQ"),"Blue Command Center")
RU_HQ = COMMANDCENTER:New(GROUP:FindByName("REDHQ"), "Red Command Center")


-- Decl Warehouses
WarehousesLAND = {}
WarehousesCypro = {}
WarehousesSHIP = {}

local warehouseData = {
    {table = WarehousesLAND, name = "Incirlik", staticName = "WHINCIRLIK", warehouseName = "Warehouse Incirlik", airport = "Incirlik"},
    {table = WarehousesLAND, name = "Gazipasa", staticName = "WHGAZIPASA", warehouseName = "Warehouse Gazipasa", portZone = "GazipasaPORT", airport = "Gazipasa"},
    {table = WarehousesLAND, name = "Bassel_Al_Assad", staticName = "WHBASSELALASSAD", warehouseName = "Warehouse Bassel Al-Assad", portZone = "PZBassel", airport = "Bassel Al-Assad"},
    {table = WarehousesCypro, name = "Paphos", staticName = "WHPAPHOS", warehouseName = "Warehouse Paphos", airport = "Paphos"},
    {table = WarehousesCypro, name = "Akrotiri", staticName = "WHAKROTIRI", warehouseName = "Warehouse Akrotiri", airport = "Akrotiri"},
    {table = WarehousesCypro, name = "Pinarbashi", staticName = "WHPINARBASHI", warehouseName = "Warehouse Pinarbashi", airport = "Pinarbashi"},
    {table = WarehousesCypro, name = "Lakatamia", staticName = "WHLAKATAMIA", warehouseName = "Warehouse Lakatamia", airport = "Lakatamia"},
    {table = WarehousesCypro, name = "Ercan", staticName = "WHERCAN", warehouseName = "Warehouse Ercan", airport = "Ercan"},
    {table = WarehousesCypro, name = "Larnaca", staticName = "WHLARNACA", warehouseName = "Warehouse Larnaca", portZone = "LarnacaPORT", airport = "Larnaca"},
    {table = WarehousesCypro, name = "Kingsfield", staticName = "WHKINGSFIELD", warehouseName = "Warehouse Kingsfield", airport = "Kingsfield"},
    {table = WarehousesCypro, name = "Gecitkale", staticName = "WHGECITKALE", warehouseName = "Warehouse Gecitkale", airport = "Gecitkale"},
    {table = WarehousesCypro, name = "EastCypro", staticName = "WHEASTCYPRO", warehouseName = "Warehouse East Cypro", portZone = "CyproEastPORT", airport = "FARPCyproEast"},
    {table = WarehousesCypro, name = "Testadiponte", staticName = "WHTestadiPonte", warehouseName = "Warehouse Testa di Ponte Cipro"},
    {table = WarehousesSHIP, name = "Tarawa", staticName = "WHTarawa", warehouseName = "Warehouse Tarawa"}
}

for _, data in ipairs(warehouseData) do
    local warehouse = WAREHOUSE:New(STATIC:FindByName(data.staticName), data.warehouseName)
    
    if data.portZone then
        local portZone = ZONE_POLYGON:FindByName(data.portZone)
        warehouse:SetPortZone(portZone)
    end
    if data.airport then
        local airport = AIRBASE:FindByName(data.airport)
        warehouse:SetAirbase(airport)
end
    warehouse:Start()
    data.table[data.name] = warehouse
end

-- Inizializzazione Warehouse con unità

WarehousesLAND.Incirlik:AddAsset("REDAICAP", 10)
WarehousesLAND.Incirlik:AddAsset("TEMPL-AirTransportRED", 10, WAREHOUSE.Attribute.AIRTRANSPORT, 90000 )
WarehousesLAND.Incirlik:AddAsset("TEMPL-RedTank", 50)
WarehousesLAND.Incirlik:AddAsset("TEMPL-RedTruck", 50)
WarehousesLAND.Incirlik:AddAsset("TEMPL-RedInf", 100)
WarehousesLAND.Incirlik:AddAsset("TEMPL-SA15", 10)
WarehousesLAND.Incirlik:AddAsset("TEMPL-RedAAA", 10)
WarehousesLAND.Incirlik:AddAsset("TEMPL-BAISu25", 50)

-- Funzione per la richiesta semplice di unità: ex. 
function RequestResource(fromWarehouse, toWarehouse, groupName, number, transportType)
    -- DEBUG - Invia messaggio con dati richiesta
    MESSAGE:New("Richiesta da " .. fromWarehouse:GetAirbaseName() .. " per " .. toWarehouse:GetAirbaseName() .. " di " .. number .. " " .. groupName, 60):ToAll()
    -- Controlla se le coalizioni dei magazzini sono uguali
    if fromWarehouse:GetCoalition() ~= toWarehouse:GetCoalition() then
        print("Richiesta negata: Le coalizioni dei magazzini non sono uguali")
        return
    end
    if transportType == nil then
        fromWarehouse:AddRequest(toWarehouse, WAREHOUSE.Descriptor.GROUPNAME, groupName, number)
    else
        fromWarehouse:AddRequest(toWarehouse, WAREHOUSE.Descriptor.GROUPNAME, groupName, number, transportType)
    end
end

function InitialRequest()
    RequestResource(WarehousesLAND.Incirlik, WarehousesCypro.Larnaca, "TEMPL-RedTank", 5, WAREHOUSE.TransportType.AIRPLANE)
end

SchedulazioneIniziale = SCHEDULER:New( nil, InitialRequest, {}, 10, 300, 0, 3600 )

-- Funzione per la richiesta di unità per distribuzione automatica: ex.


--Coppie fromToWarehouse per funzione random di convogli

-- fromToWarehouse = {
--     {WarehousesCypro.EastCypro, WarehousesCypro.Ercan},
--     {WarehousesCypro.Akrotiri, WarehousesCypro.Ercan},
--     {WarehousesCypro.Gecitkale, WarehousesCypro.Ercan},
--     {WarehousesCypro.Kingsfield, WarehousesCypro.Ercan},
--     {WarehousesCypro.Lakatamia, WarehousesCypro.Ercan},
--     {WarehousesCypro.Larnaca, WarehousesCypro.Ercan},
--     {WarehousesCypro.Paphos, WarehousesCypro.Ercan},
--     {WarehousesCypro.Pinarbashi, WarehousesCypro.Ercan}
-- }

-- FromToWarehouseCAP = {
--     {WarehousesCypro.Ercan, WarehousesCypro.Akrotiri},
--     {WarehousesCypro.Ercan, WarehousesCypro.Gecitkale},
--     {WarehousesCypro.Ercan, WarehousesCypro.Larnaca},
--     {WarehousesCypro.Ercan, WarehousesCypro.Paphos},
--     {WarehousesCypro.Ercan, WarehousesCypro.Pinarbashi}
-- }

-- AirframesCAP = {"REDAICAP", "REDAICAP"}

-- function ScheduleCAPRequest()
--     local warehousePair = FromToWarehouseCAP[math.random(#FromToWarehouseCAP)]
--     local currFromWarehouse = warehousePair[1]
--     local currToWarehouse = warehousePair[2]
--     local currGroup = AirframesCAP[math.random(#AirframesCAP)]
--     local currNumber = math.random(2)
--     RequestResource(currFromWarehouse, currToWarehouse, currGroup, currNumber)
-- end

-- -- ----------------------------------------------------------------------------------------------------------------

-- FromToWarehouseGROUND = {
--     {WarehousesCypro.Paphos, WarehousesCypro.Akrotiri},
--     {WarehousesCypro.Paphos, WarehousesCypro.Larnaca}
-- }

-- GroundTank = {"TEMPL-RedTank", "TEMPL-RedAAA","TEMPL-RedTruck"}

-- -- function ScheduleGROUNDWHRefill()
-- --     local warehousePair = FromToWarehouseGROUND[math.random(#FromToWarehouseGROUND)]
-- --     local currFromWarehouse = warehousePair[1]
-- --     local currToWarehouse = warehousePair[2]
-- --     local currGroup = GroundTank[math.random(#GroundTank)]
-- --     local currNumber = math.random(2,2)
-- --     RequestResourceAirTrans(currFromWarehouse, currToWarehouse, currGroup, currNumber)
-- -- end

-- -- ----------------------------------------------------------------------------------------------------------------

-- FromToWarehouseHeli = {
--     {WarehousesCypro.Lakatamia, WarehousesCypro.EastCypro},
--     {WarehousesCypro.Lakatamia, WarehousesCypro.Gecitkale}
-- }
-- --{
-- --    {WarehousesCypro.Lakatamia, WarehousesCypro.EastCypro}
--     --{WarehousesCypro.Lakatamia, WarehousesCypro.Akrotiri},
--     --{WarehousesCypro.Lakatamia, WarehousesCypro.Gecitkale},
--     --{WarehousesCypro.Lakatamia, WarehousesCypro.Kingsfield},
--     --{WarehousesCypro.Lakatamia, WarehousesCypro.Larnaca},
--     --{WarehousesCypro.Lakatamia, WarehousesCypro.Pinarbashi}
-- --}

-- AirframesHELI = {"Ka503", "TEMPL-Mi24"}

-- -- function ScheduleHelirefill()
-- --     local warehousePair = FromToWarehouseHeli[math.random(#FromToWarehouseHeli)]
-- --     local currFromWarehouse = warehousePair[1]
-- --     local currToWarehouse = warehousePair[2]
-- --     local currGroup = AirframesHELI[math.random(#AirframesHELI)]
-- --     local currNumber = math.random(2)
-- --     RequestResourceSelfProp(currFromWarehouse, currToWarehouse, currGroup, currNumber)
-- -- end

-- -- ----------------------------------------------------------------------------------------------------------------

-- FromToGroundPropelled = {
--     {WarehousesCypro.Larnaca, WarehousesCypro.Testadiponte},
--     {WarehousesCypro.Larnaca, WarehousesCypro.EastCypro},
--     {WarehousesCypro.Akrotiri, WarehousesCypro.Testadiponte},
--     {WarehousesCypro.Akrotiri, WarehousesCypro.EastCypro}
-- }

-- -- GroundTank = {"TEMPL-RedTank", "TEMPL-RedAAA","TEMPL-RedTruck"}

-- -- function ScheduleGROUNDToEast()
-- --     local warehousePair = FromToGroundPropelled[math.random(#FromToGroundPropelled)]
-- --     local currFromWarehouse = warehousePair[1]
-- --     local currToWarehouse = warehousePair[2]
-- --     local currGroup = GroundTank[math.random(#GroundTank)]
-- --     local currNumber = math.random(5)
-- --     RequestResourceSelfProp(currFromWarehouse, currToWarehouse, currGroup, currNumber, WAREHOUSE.TransportType.SELFPROPELLED)
-- -- end

-- -- ----------------------------------------------------------------------------------------------------------------

-- RedCapScheduler = SCHEDULER:New(nil, ScheduleCAPRequest, {}, 10, 20*60, 1.0, 3600*24)
-- HeliScheduler = SCHEDULER:New(nil, ScheduleHelirefill, {}, 60, 20*60, 1.0, 3600*24)
-- GroundUnitScheduler = SCHEDULER:New( nil, ScheduleGROUNDWHRefill, {}, 30, 60*15, 1.0, 3600*24)
-- GroundUnitToEastSched = SCHEDULER:New( nil, ScheduleGROUNDToEast, {}, 7200, 30*60, 1.0, 3600*24)

-- function WarehousesCypro.Gecitkale:OnAfterCaptured(From, Event, To, Coalition)
--     MESSAGE:Message(string.format("%s , %s, %s, %s",From, Event, To, Coalition, MESSAGE.Type.Information))
--     RU_CC:MessageTypeToCoalition(string.format("%s , %s, %s, %s",From, Event, To, Coalition, MESSAGE.Type.Information))
-- end
-- function WarehousesCypro.Gecitkale:OnAfterAirbaseCaptured(From, Event, To, Coalition)
--     US_CC:MessageTypeToCoalition(string.format("%s , %s, %s, %s",From, Event, To, Coalition, MESSAGE.Type.Information))
--     RU_CC:MessageTypeToCoalition(string.format("%s , %s, %s, %s",From, Event, To, Coalition, MESSAGE.Type.Information))
-- end

-- --- @param Functional.ZoneCaptureCoalition#ZONE_CAPTURE_COALITION self
-- -- function ZoneCaptureCoalition:OnEnterGuarded( From, Event, To )
-- --     if From ~= To then
-- --       local Coalition = self:GetCoalition()
-- --       self:E( { Coalition = Coalition } )
-- --       if Coalition == coalition.side.BLUE then
-- --         ZoneCaptureCoalition:Smoke( SMOKECOLOR.Blue )
-- --         US_CC:MessageTypeToCoalition( string.format( "%s is under protection of the USA", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
-- --         RU_CC:MessageTypeToCoalition( string.format( "%s is under protection of the USA", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
-- --       else
-- --         ZoneCaptureCoalition:Smoke( SMOKECOLOR.Red )
-- --         RU_CC:MessageTypeToCoalition( string.format( "%s is under protection of Russia", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
-- --         US_CC:MessageTypeToCoalition( string.format( "%s is under protection of Russia", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
-- --       end
-- --     end
-- --   end

WAREHOUSE:SetDebugOn()