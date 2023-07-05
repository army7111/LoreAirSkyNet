-- Decl Warehouses
WarehousesLAND = {}
WarehousesCypro = {}
-- Paphos
WarehousesCypro.Paphos = WAREHOUSE:New(STATIC:FindByName("WHPAPHOS"), "Warehouse Paphos")
WarehousesCypro.Paphos:Start()
-- Akrotiri
WarehousesCypro.Akrotiri = WAREHOUSE:New(STATIC:FindByName("WHAKROTIRI"), "Warehouse Akroptiri")
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
WarehousesCypro.Ercan:AddAsset("Mi24", 50)
WarehousesCypro.Ercan:AddAsset("Ka503", 50)
WarehousesCypro.Paphos:AddAsset("TEMPL-RedTank", 50)
WarehousesCypro.Paphos:AddAsset("TEMPL-SA15", 50)
WarehousesCypro.Paphos:AddAsset("TEMPL-RedTruck", 50)
WarehousesCypro.Ercan:AddAsset("TEMPL-RedInf", 100)
WarehousesCypro.Paphos:AddAsset("TEMPL-AirTransportRED", 50)
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

function RequestResourceSelfProp(fromWarehouse, toWarehouse, groupName, number, TransportType)
    fromWarehouse:AddRequest(toWarehouse, WAREHOUSE.Descriptor.GROUPNAME, groupName, number, SELFPROPELLED)
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
    {WarehousesCypro.Ercan, WarehousesCypro.Kingsfield},
    {WarehousesCypro.Ercan, WarehousesCypro.Larnaca},
    {WarehousesCypro.Ercan, WarehousesCypro.Paphos},
    {WarehousesCypro.Ercan, WarehousesCypro.Pinarbashi}
}

FromToWarehouseGROUND = {
    {WarehousesCypro.Paphos, WarehousesCypro.Akrotiri},
    --{WarehousesCypro.Paphos, WarehousesCypro.Gecitkale},
    --{WarehousesCypro.Paphos, WarehousesCypro.Kingsfield},
    {WarehousesCypro.Paphos, WarehousesCypro.Larnaca}
    --{WarehousesCypro.Paphos, WarehousesCypro.Ercan},
    --{WarehousesCypro.Paphos, WarehousesCypro.Pinarbashi}
}

FromToWarehouseHeli = {
    {WarehousesCypro.Ercan, WarehousesCypro.EastCypro},
    {WarehousesCypro.Ercan, WarehousesCypro.Akrotiri},
    {WarehousesCypro.Ercan, WarehousesCypro.Gecitkale},
    {WarehousesCypro.Ercan, WarehousesCypro.Kingsfield},
    {WarehousesCypro.Ercan, WarehousesCypro.Larnaca},
    {WarehousesCypro.Ercan, WarehousesCypro.Pinarbashi}
}

FromToGroundPropelled = {
    {WarehousesCypro.Larnaca, WarehousesCypro.Testadiponte},
    {WarehousesCypro.Larnaca, WarehousesCypro.EastCypro},
    {WarehousesCypro.Akrotiri, WarehousesCypro.Testadiponte},
    {WarehousesCypro.Akrotiri, WarehousesCypro.EastCypro}
}

AirframesCAP = {"REDAICAP", "REDAICAP"}
AirframesHELI = {"Ka503", "TEMPL-Mi24"}
GroundTank = {"TEMPL-RedTank", "TEMPL-RedAAA", "TEMPL-SA15"}

function ScheduleCAPRequest()
    local warehousePair = FromToWarehouseCAP[math.random(2, table.getn(FromToWarehouseCAP))]
    local currFromWarehouse = warehousePair[1]
    local currToWarehouse = warehousePair[2]
    local currGroup = AirframesCAP[math.random(2, table.getn(AirframesCAP))]
    --local currNumber = math.random(2,2)
    RequestResource(currFromWarehouse, currToWarehouse, currGroup, 2)
end

function ScheduleWHrefill()
    local warehousePair = FromToWarehouseHeli[math.random(2, table.getn(FromToWarehouseHeli))]
    local currFromWarehouse = warehousePair[1]
    local currToWarehouse = warehousePair[2]
    local currGroup = AirframesHELI[math.random(2, table.getn(AirframesHELI))]
    local currNumber = math.random(1,2)
    RequestResource(currFromWarehouse, currToWarehouse, currGroup, currNumber)
end

function ScheduleGROUNDWHRefill()
    local warehousePair = FromToWarehouseGROUND[math.random(2, table.getn(FromToWarehouseGROUND))]
    local currFromWarehouse = warehousePair[1]
    local currToWarehouse = warehousePair[2]
    local currGroup = GroundTank[math.random(2, table.getn(GroundTank))]
    local currNumber = math.random(1,5)
    RequestResourceSelfProp(currFromWarehouse, currToWarehouse, currGroup, currNumber, WAREHOUSE.TransportType.AIRPLANE )
end

function ScheduleGROUNDToEast()
    local warehousePair = FromToGroundPropelled[math.random(2, table.getn(FromToGroundPropelled))]
    local currFromWarehouse = warehousePair[1]
    local currToWarehouse = warehousePair[2]
    local currGroup = GroundTank[math.random(2, table.getn(GroundTank))]
    local currNumber = math.random(1,5)
    RequestResourceSelfProp(currFromWarehouse, currToWarehouse, currGroup, currNumber, WAREHOUSE.TransportType.SELFPROPELLED)
end

RedCapScheduler = SCHEDULER:New(nil, ScheduleCAPRequest, {}, 10, 20*60, 1.0, 3600*24)
HeliScheduler = SCHEDULER:New( nil, ScheduleWHrefill, {}, 60, 20*60, 1.0, 3600*24)
GroundUnitScheduler = SCHEDULER:New( nil, ScheduleGROUNDWHRefill, {}, 30, 60*15, 1.0, 3600*24)
GroundUnitToEastSched = SCHEDULER:New( nil, ScheduleGROUNDToEast, {}, 45, 30*60, 1.0, 3600*24)