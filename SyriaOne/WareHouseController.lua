-- Decl Warehouses
WarehousesLAND = {}
WarehousesCypro = {}
-- Paphos
WarehousesCypro.Paphos = WAREHOUSE:New(STATIC:FindByName("WHPAPHOS"), "Warehouse Paphos")
WarehousesCypro.Paphos:Start()
-- Akrotiri
WarehousesCypro.Akrotiri = WAREHOUSE:New(STATIC:FindByName("WHAKROTIRI"), "Warehouse Akrotiri")
WarehousesCypro.Akrotiri:Start()
-- Pinarbashi
WarehousesCypro.Pinarbashi = WAREHOUSE:New(STATIC:FindByName("WHPINARBASHI"), "Warehouse Pinarbashi")
WarehousesCypro.Pinarbashi:Start()
-- Lakatamia
WarehousesCypro.Lakatamia = WAREHOUSE:New(STATIC:FindByName("WHLAKATAMIA"), "Warehouse Lakatamia")
WarehousesCypro.Lakatamia:Start()
-- Ercan
WarehousesCypro.Ercan = WAREHOUSE:New(STATIC:FindByName("WHERCAN"), "Warehouse Ercan")
WarehousesCypro.Ercan:Start()
-- Larnaca
WarehousesCypro.Larnaca = WAREHOUSE:New(STATIC:FindByName("WHLARNACA"), "Warehouse Larnaca")
local pzLarnaca = ZONE_POLYGON:FindByName("LarnacaPORT")
WarehousesCypro.Larnaca:SetPortZone(pzLarnaca)
WarehousesCypro.Larnaca:Start()
-- Kingsfield
WarehousesCypro.Kingsfield = WAREHOUSE:New(STATIC:FindByName("WHKINGSFIELD"), "Warehouse Kingsfield")
WarehousesCypro.Kingsfield:Start()
-- Gecitkale
WarehousesCypro.Gecitkale = WAREHOUSE:New(STATIC:FindByName("WHGECITKALE"), "Warehouse Gecitkale")
WarehousesCypro.Gecitkale:Start()
-- East Cypro
WarehousesCypro.EastCypro = WAREHOUSE:New(STATIC:FindByName("WHEASTCYPRO"), "Warehouse East Cypro")
local pzEastCypro = ZONE_POLYGON:FindByName("CyproEastPORT")
WarehousesCypro.EastCypro:SetPortZone(pzEastCypro)
WarehousesCypro.EastCypro:Start()
-- Testadiponte
WarehousesCypro.Testadiponte = WAREHOUSE:New(STATIC:FindByName("WHTestadiPonte"), "Warehouse Testa di Ponte Cipro")
WarehousesCypro.Testadiponte:Start()
-- Bassel_Al_Assad
WarehousesLAND.Bassel_Al_Assad = WAREHOUSE:New(STATIC:FindByName("WHBASSELALASSAD"), "Warehouse Bassel Al-Assad")
local pzBassel = ZONE_POLYGON:FindByName("PZBassel")
WarehousesLAND.Bassel_Al_Assad:SetPortZone(pzBassel)
WarehousesLAND.Bassel_Al_Assad:Start()
-- Tarawa
WarehouseTarawa = WAREHOUSE:New(STATIC:FindByName("WHTarawa"), "Warehouse Tarawa")
WarehouseTarawa:Start()

-- Inizializzazione Warehouse con unità
WarehousesCypro.Lakatamia:AddAsset("TEMPL-Mi24", 20)
WarehousesCypro.Lakatamia:AddAsset("Ka503", 20)
WarehousesCypro.Paphos:AddAsset("TEMPL-RedTank", 20)
WarehousesCypro.Paphos:AddAsset("TEMPL-SA15", 10)
WarehousesCypro.Paphos:AddAsset("TEMPL-RedTruck", 50)
WarehousesCypro.Ercan:AddAsset("TEMPL-RedInf", 100)
WarehousesCypro.Paphos:AddAsset("TEMPL-AirTransportRED", 10)
WarehousesCypro.Ercan:AddAsset("REDAICAP", 25)

-- Dichiarazione Unita e tipo di unita
-- TransportRED = GROUP:FindByName("TEMPL-AirTransportRED")
-- Inf = GROUP:FindByName("TEMPL-RedInf")
-- Aaa = GROUP:FindByName("TEMPL-RedAAA")
-- Truck = GROUP:FindByName("TEMPL-RedTruck")
-- SAMTor = GROUP:FindByName("TEMPL-SA15")
-- TankRed = GROUP:FindByName("TEMPL-RedTank")
-- Ka503 = GROUP:FindByName("Ka503")
-- AV8BShip = GROUP:FindByName("AV8B")
-- Fine Dichiarazione Unita e tipo

-- Funzione per la richiesta semplice di unità: ex. 
function RequestResource(fromWarehouse, toWarehouse, groupName, number)
    fromWarehouse:AddRequest(toWarehouse, WAREHOUSE.Descriptor.GROUPNAME, groupName, number)
end

function RequestResourceSelfProp(fromWarehouse, toWarehouse, groupName, number)
    fromWarehouse:AddRequest(toWarehouse, WAREHOUSE.Descriptor.GROUPNAME, groupName, number, WAREHOUSE.TransportType.SELFPROPELLED)
end

function RequestResourceAirTrans(fromWarehouse, toWarehouse, groupName, number)
    fromWarehouse:AddRequest(toWarehouse, WAREHOUSE.Descriptor.GROUPNAME, groupName, number, WAREHOUSE.TransportType.AIRPLANE)
end
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

FromToWarehouseCAP = {
    {WarehousesCypro.Ercan, WarehousesCypro.Akrotiri},
    {WarehousesCypro.Ercan, WarehousesCypro.Gecitkale},
    {WarehousesCypro.Ercan, WarehousesCypro.Larnaca},
    {WarehousesCypro.Ercan, WarehousesCypro.Paphos},
    {WarehousesCypro.Ercan, WarehousesCypro.Pinarbashi}
}

AirframesCAP = {"REDAICAP", "REDAICAP"}

function ScheduleCAPRequest()
    local warehousePair = FromToWarehouseCAP[math.random(#FromToWarehouseCAP)]
    local currFromWarehouse = warehousePair[1]
    local currToWarehouse = warehousePair[2]
    local currGroup = AirframesCAP[math.random(#AirframesCAP)]
    local currNumber = math.random(2)
    RequestResource(currFromWarehouse, currToWarehouse, currGroup, currNumber)
end

-- ----------------------------------------------------------------------------------------------------------------

FromToWarehouseGROUND = {
    {WarehousesCypro.Paphos, WarehousesCypro.Akrotiri},
    {WarehousesCypro.Paphos, WarehousesCypro.Larnaca}
}

GroundTank = {"TEMPL-RedTank", "TEMPL-RedAAA","TEMPL-RedTruck"}

function ScheduleGROUNDWHRefill()
    local warehousePair = FromToWarehouseGROUND[math.random(#FromToWarehouseGROUND)]
    local currFromWarehouse = warehousePair[1]
    local currToWarehouse = warehousePair[2]
    local currGroup = GroundTank[math.random(#GroundTank)]
    local currNumber = math.random(2,2)
    RequestResourceAirTrans(currFromWarehouse, currToWarehouse, currGroup, currNumber)
end

-- ----------------------------------------------------------------------------------------------------------------

FromToWarehouseHeli = {
    {WarehousesCypro.Lakatamia, WarehousesCypro.EastCypro},
    {WarehousesCypro.Lakatamia, WarehousesCypro.Gecitkale}
}
--{
--    {WarehousesCypro.Lakatamia, WarehousesCypro.EastCypro}
    --{WarehousesCypro.Lakatamia, WarehousesCypro.Akrotiri},
    --{WarehousesCypro.Lakatamia, WarehousesCypro.Gecitkale},
    --{WarehousesCypro.Lakatamia, WarehousesCypro.Kingsfield},
    --{WarehousesCypro.Lakatamia, WarehousesCypro.Larnaca},
    --{WarehousesCypro.Lakatamia, WarehousesCypro.Pinarbashi}
--}

AirframesHELI = {"Ka503", "TEMPL-Mi24"}

function ScheduleHelirefill()
    local warehousePair = FromToWarehouseHeli[math.random(#FromToWarehouseHeli)]
    local currFromWarehouse = warehousePair[1]
    local currToWarehouse = warehousePair[2]
    local currGroup = AirframesHELI[math.random(#AirframesHELI)]
    local currNumber = math.random(2)
    RequestResourceSelfProp(currFromWarehouse, currToWarehouse, currGroup, currNumber)
end

-- ----------------------------------------------------------------------------------------------------------------

FromToGroundPropelled = {
    {WarehousesCypro.Larnaca, WarehousesCypro.Testadiponte},
    {WarehousesCypro.Larnaca, WarehousesCypro.EastCypro},
    {WarehousesCypro.Akrotiri, WarehousesCypro.Testadiponte},
    {WarehousesCypro.Akrotiri, WarehousesCypro.EastCypro}
}

-- GroundTank = {"TEMPL-RedTank", "TEMPL-RedAAA","TEMPL-RedTruck"}

function ScheduleGROUNDToEast()
    local warehousePair = FromToGroundPropelled[math.random(#FromToGroundPropelled)]
    local currFromWarehouse = warehousePair[1]
    local currToWarehouse = warehousePair[2]
    local currGroup = GroundTank[math.random(#GroundTank)]
    local currNumber = math.random(5)
    RequestResourceSelfProp(currFromWarehouse, currToWarehouse, currGroup, currNumber, WAREHOUSE.TransportType.SELFPROPELLED)
end

-- ----------------------------------------------------------------------------------------------------------------

RedCapScheduler = SCHEDULER:New(nil, ScheduleCAPRequest, {}, 10, 20*60, 1.0, 3600*24)
HeliScheduler = SCHEDULER:New(nil, ScheduleHelirefill, {}, 60, 20*60, 1.0, 3600*24)
GroundUnitScheduler = SCHEDULER:New( nil, ScheduleGROUNDWHRefill, {}, 30, 60*15, 1.0, 3600*24)
GroundUnitToEastSched = SCHEDULER:New( nil, ScheduleGROUNDToEast, {}, 7200, 30*60, 1.0, 3600*24)


function WAREHOUSE:OnAfterAirbaseCaptured(From, Event, To, Coalition)
    US_CC:MessageTypeToCoalition(string.format("%s , %s, %s, %s",From, Event, To, Coalition, MESSAGE.Type.Information))
    RU_CC:MessageTypeToCoalition(string.format("%s , %s, %s, %s",From, Event, To, Coalition, MESSAGE.Type.Information))
end

WAREHOUSE:SetDebugOn()