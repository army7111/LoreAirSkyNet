-- Decl Warehouses
WarehousesLAND = {}
WarehousesCypro = {}
WarehousesCypro.Paphos = WAREHOUSE:New(STATIC:FindByName("WHPAPHOS"), "Warehouse Paphos")
WarehousesCypro.Paphos:Start()
WarehousesCypro.Akrotiri = WAREHOUSE:New(STATIC:FindByName("WHAKROTIRI"), "Warehouse Akroptiri")
WarehousesCypro.Akrotiri:Start()
WarehousesCypro.Pinarbashi = WAREHOUSE:New(STATIC:FindByName("WHPINARBASHI"), "Warehouse Pinarbashi")
WarehousesCypro.Pinarbashi:Start()
WarehousesCypro.Lakatamia = WAREHOUSE:New(STATIC:FindByName("WHLAKATAMIA"), "Warehouse Lakatamia")
WarehousesCypro.Lakatamia:Start()
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
WarehousesCypro.Gecitkale = WAREHOUSE:New(STATIC:FindByName("WHGECITKALE"), "Warehouse Gecitkale")
WarehousesCypro.Gecitkale:Start()
-- East Cypro
WarehousesCypro.EastCypro = WAREHOUSE:New(STATIC:FindByName("WHEASTCYPRO"), "Warehouse East Cypro")
local pzEastCypro = ZONE_POLYGON:FindByName("CyproEastPORT")
WarehousesCypro.EastCypro:SetPortZone(pzEastCypro)
WarehousesCypro.EastCypro:Start()
-- Bassel_Al_Assad
WarehousesLAND.Bassel_Al_Assad = WAREHOUSE:New(STATIC:FindByName("WHBASSELALASSAD"), "Warehouse Bassel Al-Assad")
local pzBassel = ZONE_POLYGON:FindByName("PZBassel")
WarehousesLAND.Bassel_Al_Assad:SetPortZone(pzBassel)
WarehousesLAND.Bassel_Al_Assad:Start()
-- Tarawa
WarehouseTarawa = WAREHOUSE:New(STATIC:FindByName("WHTarawa"), "Warehouse Tarawa")
WarehouseTarawa:Start()

-- FINE Decl Warehouses

-- Dichiarazione Unita e tipo di unita
Inf = GROUP:FindByName("TEMPL-RedInf")
Aaa = GROUP:FindByName("TEMPL-RedAAA")
Truck = GROUP:FindByName("TEMPL-RedTruck")
SAMTor = GROUP:FindByName("TEMPL-SA15")
TankRed = GROUP:FindByName("TEMPL-RedTank")
Ka503 = GROUP:FindByName("Ka503")
AV8BShip = GROUP:FindByName("AV8B")
-- Fine Dichiarazione Unita e tipo

-- Dichiarazione zone di attacco aeroporti
local az_EastFarp = ZONE:New("AZEastFARP")
local az_Gecitkale = ZONE:New("AZGecitkale")
local az_Kingsfield = ZONE:New("AZKingsfield")
local az_Ercan = ZONE:New("AZErcan")
local az_Larnaca = ZONE:New("AZLarnaca")
local az_Lakatamia = ZONE:New("AZLakatamia")
local az_Pinarbashi = ZONE:New("AZPinarbashi")
local az_Akrotiri = ZONE:New("AZAkrotiri")
local az_Paphos = ZONE:New("AZPaphos")
-- Fine Dichiarazione zone di attacco Aeroporti


-- Inizializzazione sistema di difesa/attacco automatico aeroporti
-- do
--     local RED_CC = COMMANDCENTER:New( STATIC:FindByName("Command Center"), "Red HQ")
--     local BLUE_CC = COMMANDCENTER:New( STATIC:FindByName("BLUHQ"), "BLUE HQ")
-- end

-- --- @param Functional.ZoneCaptureCoailition#ZONE_CAPTURE_COALITION self
-- function ZoneCaptureCoailition:OnenterGuarded()

--     local coalition = self:GetCoalition()
--     local ZoneName = self:GetZoneName()
--     if coalition == coalition.side.BLUE then
--         BLUE_CC:MessageTypeToCoalition( string.format("La zona %s è ancora controllata, i rinforzi sono in arrivo", ZoneName ),MESSAGE.Type.Information)
--     end
    
-- end

-- Fine Inizializzazione sistema di difesa/attacco automatico aeroporti
--Inizializzazione WareHouses
WarehousesCypro.Ercan:AddAsset(Inf, 10)
WarehousesCypro.Ercan:AddAsset(Aaa, 100)
WarehousesCypro.Ercan:AddAsset(Truck, 100)
WarehousesCypro.Ercan:AddAsset(SAMTor, 100)
WarehousesCypro.Ercan:AddAsset(TankRed, 100)

WarehousesCypro.EastCypro:AddAsset(SAMTor, 2)
WarehousesCypro.EastCypro:SetAutoDefenceOn()

WarehousesLAND.Bassel_Al_Assad:AddAsset(AV8BShip, 10)
WarehousesLAND.Bassel_Al_Assad:AddAsset(Ka503, 10)
--Fine Inizializzazione

WarehousesCypro.Ercan:AddAsset(GROUP:FindByName("REDSAM-PDSA10East"), 1)
WarehousesCypro.Ercan:AddAsset(GROUP:FindByName("CARGOHELITMPL"), 10)
WarehousesCypro.Ercan:AddRequest(WarehousesCypro.EastCypro, WAREHOUSE.Descriptor.GROUPNAME, "REDSAM-PDSA10East", 1, WAREHOUSE.TransportType.HELICOPTER)

WarehousesLAND.Bassel_Al_Assad:AddRequest(WarehouseTarawa, WAREHOUSE.Descriptor.GROUPNAME , "AV8BShip", 2, WAREHOUSE.TransportType.SELFPROPELLED)
WarehousesLAND.Bassel_Al_Assad:AddRequest(WarehouseTarawa, WAREHOUSE.Descriptor.UNITTYPE, "Ka-50 III", 2, WAREHOUSE.TransportType.SELFPROPELLED)