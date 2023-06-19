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
WarehousesLAND.Bassel_Al_Assad:Start()
-- FINE Decl Warehouses

-- Dichiarazione Unita e tipo di unita
Inf = GROUP:FindByName("TEMPL-RedInf")
Aaa = GROUP:FindByName("TEMPL-RedAAA")
Truck = GROUP:FindByName("TEMPL-RedTruck")
SAMTor = GROUP:FindByName("TEMPL-SA15")
TankRed = GROUP:FindByName("TEMPL-RedTank")
-- Fine Dichiarazione Unita e tipo

--Inizializzazione WareHouses
WarehousesCypro.Ercan:AddAsset(Inf, 10)
WarehousesCypro.Ercan:AddAsset(Aaa, 100)
WarehousesCypro.Ercan:AddAsset(Truck, 100)
WarehousesCypro.Ercan:AddAsset(SAMTor, 100)
WarehousesCypro.Ercan:AddAsset(TankRed, 100)

WarehousesCypro.EastCypro:AddAsset(SAMTor, 2)
WarehousesCypro.EastCypro:SetAutoDefenceOn()
--Fine Inizializzazione

WarehousesCypro.Ercan:AddAsset(GROUP:FindByName("REDSAM-PDSA10East"), 1)
WarehousesCypro.Ercan:AddAsset(GROUP:FindByName("CARGOHELITMPL"), 10)
WarehousesCypro.Ercan:AddRequest(WarehousesCypro.EastCypro, WAREHOUSE.Descriptor.GROUPNAME, "REDSAM-PDSA10East", 1, WAREHOUSE.TransportType.HELICOPTER)