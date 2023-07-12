------------------------------------------------------------------------------- SyriaOne_CSAR.lua -------------------------------------------------------------------------------------

local syriaCSAR = CSAR:New(coalition.side.BLUE, "CSARPilot", "SOS-Beacon")
syriaCSAR.immortalcrew = true
syriaCSAR.invisiblecrew = true
syriaCSAR.allowbronco = true
syriaCSAR.topmenuname = "Combat Search & Rescue"
syriaCSAR.useprefix = true
syriaCSAR.csarPrefix = "CSAR"

local activeCsarMissions = 0

function syriaCSAR:OnAfterPilotDown(From, Event, To, SpawnedGroup, Frequency, Leadername, CoordinatesText)
    activeCsarMissions = activeCsarMissions + 1
    MESSAGE:New(string.format("Il pilota %s è abbattuto! La frequenza per il CSAR è %s KHz, le coordinate sono %s.", Leadername, Frequency, CoordinatesText), 15):ToAll()
end

syriaCSAR:Start()

local csarZone = ZONE:New("CSARMissionZone")

local function startCsarMission()
    if activeCsarMissions < 5 then
        syriaCSAR:SpawnCSARAtZone(csarZone, coalition.side.BLUE, "PilotaTEST", true)
        activeCsarMissions = activeCsarMissions + 1
    end
end

function syriaCSAR:OnAfterRescued(From, Event, To, HeliUnit, HeliName, PilotsSaved)
    activeCsarMissions = activeCsarMissions - 1
    MESSAGE:New("Missione CSAR terminata con successo.", 30):ToAll()
end

local checkActiveMissionsScheduler = SCHEDULER:New(nil, startCsarMission, {}, 0, 60)
checkActiveMissionsScheduler:Start()

------------------------------------------------------------------------------- WareHouseController.lua -------------------------------------------------------------------------------------


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
WAREHOUSE:SetDebugOn()

----------------------------------------------------------------------------------- SyriaOneZoneCapture.lua --------------------------------------------------------------------------------


-- Funzione per creare una nuova zona di cattura
function NewCaptureZone(t, name)
    local captureZone = ZONE:New("AZ" .. name)
    local zoneCaptureCoalition = ZONE_CAPTURE_COALITION:New(captureZone, coalition.side.RED)
    zoneCaptureCoalition:__Guard(1) -- Imposta la zona nello stato di "Guarded"
    zoneCaptureCoalition:Start() -- Avvia il monitoraggio della zona
    t[name] = zoneCaptureCoalition
end

-- Dichiarazione delle zone di cattura
local captureZones = {}

-- Creazione delle zone di cattura
NewCaptureZone(captureZones, "Paphos")
NewCaptureZone(captureZones, "Akrotiri")
NewCaptureZone(captureZones, "Pinarbashi")
NewCaptureZone(captureZones, "Lakatamia")
NewCaptureZone(captureZones, "Ercan")
NewCaptureZone(captureZones, "Larnaca")
NewCaptureZone(captureZones, "Kingsfield")
NewCaptureZone(captureZones, "Gecitkale")
NewCaptureZone(captureZones, "EastCypro")
NewCaptureZone(captureZones, "Testadiponte")

-- Funzione di difesa e ricattura
-- Questa funzione gestisce le unità in caso di attacco ad una delle warehouse. La funzione dovra attivarsi non appena c'è un evento di tipo: "OnEnterAttacked" e invierà un messaggio 
-- a tutte le coalizioni per indicare che c'è l'attacco in corso. subito dopo spawnera con la funzione "self" 3 unità di tipo "TEMPL-RedTank" che difenderanno la zona. Nel caso in cui
-- La warehouse non ha disponibili i mezzi , deve chiederli a Larnaca. Se Larnaca non ha unità di quel tipo disponibili , dovra fare una richiesta a Incirlik. Se Incirlik non ha unità
-- o non è disponibile, allora la richiesta sarà negata. 

function ZoneCaptureCoalition:OnEnterGuarded(From, Event, To, self)
    if From ~= To then
        local Coalition = self:GetCoalition()
        self:E({ Coalition = Coalition })
        if Coalition == coalition.side.BLUE then
            self:Smoke(SMOKECOLOR.Blue)
            US_CC:MessageTypeToCoalition(string.format("%s is under protection of the RED", self:GetZoneName()), MESSAGE.Type.Information)
            RU_CC:MessageTypeToCoalition(string.format("%s is under protection of the BLUE", self:GetZoneName()), MESSAGE.Type.Information)
        else
            self:Smoke(SMOKECOLOR.Red)
            RU_CC:MessageTypeToCoalition(string.format("%s is under protection of BLUE", self:GetZoneName()), MESSAGE.Type.Information)
            US_CC:MessageTypeToCoalition(string.format("%s is under protection of RED", self:GetZoneName()), MESSAGE.Type.Information)
        end
    end
end

function ZoneCaptureCoalition:OnEnterCapture(From, Event, To)
    if From ~= To then
        local Coalition = self:GetCoalition()
        self:E({ Coalition = Coalition })
        if Coalition == coalition.side.BLUE then
            self:Smoke(SMOKECOLOR.Blue)
            US_CC:MessageTypeToCoalition(string.format("%s is under attack by RED", self:GetZoneName()), MESSAGE.Type.Information)
            RU_CC:MessageTypeToCoalition(string.format("%s is under attack by BLUE", self:GetZoneName()), MESSAGE.Type.Information)
        else
            self:Smoke(SMOKECOLOR.Red)
            RU_CC:MessageTypeToCoalition(string.format("%s is under attack by BLUE", self:GetZoneName()), MESSAGE.Type.Information)
            US_CC:MessageTypeToCoalition(string.format("%s is under attack by RED", self:GetZoneName()), MESSAGE.Type.Information)
        end
    end
end

---------------------------------------------------------------------------- SkynetIADS_LittleProblem.lua ----------------------------------------------------------------------------

--- Crea Sistema IADS RED
RedIADS = SkynetIADS:create('RED IADS')

local commandCenter = StaticObject.getByName("Command Center")
RedIADS:addCommandCenter(commandCenter)
--- Aggiunge tutte le unità che hanno come prefisso REDSAM - REDEW
RedIADS:addSAMSitesByPrefix('REDSAM')
RedIADS:addEarlyWarningRadarsByPrefix('REDEW')
RedIADS:addRadioMenu()
RedIADS:setUpdateInterval(5)
--RedIADS:getSAMSiteByGroupName('REDSAM-S300CIPRO'):setActAsEW(true)
RedIADS:getSAMSiteByGroupName('REDSAM-S300CIPROWest'):setActAsEW(true)

-- Impostazione del range di ingaggio al massimo per tutti i siti SAM
local allSAMSites = RedIADS:getSAMSites()
for i, samSite in ipairs(allSAMSites) do
   -- samSite:setHARMDetectionChance(100)
    samSite:setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
end

-- Dichiarazione Point Defence 
local sa15PDCC = RedIADS:getSAMSiteByGroupName('REDSAM-PDCC')
RedIADS:getSAMSiteByGroupName('REDSAM-SA11CC'):addPointDefence(sa15PDCC)

local sa15PDCC1 = RedIADS:getSAMSiteByGroupName('REDSAM-PDCC-1')
RedIADS:getSAMSiteByGroupName('REDSAM-SA11CC'):addPointDefence(sa15PDCC1)

local sa15PDCC2 = RedIADS:getSAMSiteByGroupName('REDSAM-PDCC-2')
RedIADS:getSAMSiteByGroupName('REDSAM-SA11CC'):addPointDefence(sa15PDCC2)

local sa15PDCC3 = RedIADS:getSAMSiteByGroupName('REDSAM-PDCC-3')
RedIADS:getSAMSiteByGroupName('REDSAM-SA11CC'):addPointDefence(sa15PDCC3)

local sa15PDEast = RedIADS:getSAMSiteByGroupName('REDSAM-PDSA15East')
RedIADS:getSAMSiteByGroupName('REDSAM-S300CIPRO'):addPointDefence(sa15PDEast)
RedIADS:getSAMSiteByGroupName('REDSAM-S300CIPRO'):setIgnoreHARMSWhilePointDefencesHaveAmmo(true)

local sa15PDWest = RedIADS:getSAMSiteByGroupName('REDSAM-SA15PDS20B')
RedIADS:getSAMSiteByGroupName('REDSAM-S300CIPROWest'):addPointDefence(sa15PDWest)

-- Attiva sistema IADS Skynet
RedIADS:activate()

--- INIZIO MOOSE AI-A2A-DISPATCHER

DetectionSetGroup = SET_GROUP:New()
Detection = DETECTION_AREAS:New( DetectionSetGroup, 30000 )
A2ADispatcher = AI_A2A_DISPATCHER:New( Detection )
A2ADispatcher:SetEngageRadius() -- 100000 is the default value.
A2ADispatcher:SetGciRadius() -- 200000 is the default value.
A2ADispatcher:SetDisengageRadius(200000)
-- Imposta Confini
REDBorderZone = ZONE_POLYGON:New( "RED-BORDER", GROUP:FindByName( "RED-BORDER" ) )
A2ADispatcher:SetBorderZone( REDBorderZone )
-- INIZIO SQUAD Decl
-- Squad Larnaca
A2ADispatcher:SetSquadron( "Larnaca", AIRBASE.Syria.Larnaca , { "REDAICAP" }, 5 )
A2ADispatcher:SetSquadronGrouping( "Larnaca", 2 )
A2ADispatcher:SetSquadronGci( "Larnaca", 900, 1200 )
-- Squad Gecitkale
A2ADispatcher:SetSquadron("Gecitkale", AIRBASE.Syria.Gecitkale , { "REDAICAP" }, 5)
A2ADispatcher:SetSquadronGrouping( "Gecitkale", 2)
A2ADispatcher:SetSquadronGci( "Gecitkale", 900, 1200)
-- Squad Incirlik
A2ADispatcher:SetSquadron("Incirlik", AIRBASE.Syria.Incirlik , { "REDAICAP" }, 5)
A2ADispatcher:SetSquadronGrouping( "Incirlik", 2)
A2ADispatcher:SetSquadronGci( "Incirlik", 900, 1200)
--FINE SQUAD Decl
-- Dichiarazione CAP Zone e CAP

CapZoneA = ZONE:New( "REDCAPZONEA")
CapZoneB = ZONE:New( "REDCAPZONEB")

A2ADispatcher:SetSquadronCap( "Incirlik", CapZoneB, 3030, 10606, 486, 720, 630, 1260, "BARO")
A2ADispatcher:SetSquadronCapInterval( "Incirlik", 1, 300, 1800)

A2ADispatcher:SetSquadronCap( "Larnaca", CapZoneA, 3030, 10606, 486, 720, 630, 1260, "BARO")
A2ADispatcher:SetSquadronCapInterval( "Larnaca", 1, 300, 1800)

-- FINE Dichiarazione CAP Zone e CAP

A2ADispatcher:SetTacticalDisplay(true)
A2ADispatcher:SetDefaultTakeoffFromParkingHot()
A2ADispatcher:SetDefaultLandingAtRunway()
A2ADispatcher:Start()

--Scheduler per refill ogni 2 ore

local function refillSquadrons()
    A2ADispatcher:SetSquadron("Larnaca", AIRBASE.Syria.Larnaca , { "REDAICAP" }, 10)
    A2ADispatcher:SetSquadron("Gecitkale", AIRBASE.Syria.Gecitkale , { "REDAICAP" }, 5)
    A2ADispatcher:SetSquadron("Incirlik", AIRBASE.Syria.Incirlik , { "REDAICAP" }, 5)
    MESSAGE:New("Squadrons have been refilled!",10,"System"):ToAll()
end
local refillScheduler = SCHEDULER:New(nil, refillSquadrons, {}, 0, 3600*12) -- 7200 secondi sono 2 ore
-- Fine scheduler
--- FINE MOOSE AI-A2A-DISPATCHER

RedIADS:addMooseSetGroup(DetectionSetGroup)


--- Debug ---

local iadsDebug = RedIADS:getDebugSettings()

iadsDebug.IADSStatus = false
--iadsDebug.contacts = true
--iadsDebug.jammerProbability = true
--iadsDebug.samSiteStatusEnvOutput = true
iadsDebug.earlyWarningRadarStatusEnvOutput = false
--iadsDebug.addedEWRadar = true
--iadsDebug.addedSAMSite = true
--iadsDebug.warnings = true
--iadsDebug.radarWentLive = true
--iadsDebug.radarWentDark = true
iadsDebug.harmDefence = false

--- fine debug ---