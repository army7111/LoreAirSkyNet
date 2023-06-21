--- Crea Sistema IADS RED
RedIADS = SkynetIADS:create('RED IADS')

local commandCenter = StaticObject.getByName("Command Center")
RedIADS:addCommandCenter(commandCenter)
--- Aggiunge tutte le unità che hanno come prefisso REDSAM - REDEW - REDCC
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
A2ADispatcher:SetSquadron( "Larnaca", AIRBASE.Syria.Larnaca , { "REDAICAP" }, 10 )
A2ADispatcher:SetSquadronGrouping( "Larnaca", 2 )
A2ADispatcher:SetSquadronGci( "Larnaca", 900, 1200 )
-- Squad Gecitkale
A2ADispatcher:SetSquadron("Gecitkale", AIRBASE.Syria.Gecitkale , { "REDAICAP" }, 10)
A2ADispatcher:SetSquadronGrouping( "Gecitkale", 2)
A2ADispatcher:SetSquadronGci( "Gecitkale", 900, 1200)
-- Squad Incirlik
A2ADispatcher:SetSquadron("Incirlik", AIRBASE.Syria.Incirlik , { "REDAICAP" }, 10)
A2ADispatcher:SetSquadronGrouping( "Incirlik", 2)
A2ADispatcher:SetSquadronGci( "Incirlik", 900, 1200)
--FINE SQUAD Decl
A2ADispatcher:SetTacticalDisplay(false)
A2ADispatcher:SetDefaultTakeoffFromParkingHot()
A2ADispatcher:SetDefaultLandingAtRunway()
A2ADispatcher:Start()

--Scheduler per refill ogni 2 ore

local function refillSquadrons()
    A2ADispatcher:SetSquadron("Larnaca", AIRBASE.Syria.Larnaca , { "REDAICAP" }, 10)
    A2ADispatcher:SetSquadron("Gecitkale", AIRBASE.Syria.Gecitkale , { "REDAICAP" }, 10)
    A2ADispatcher:SetSquadron("Incirlik", AIRBASE.Syria.Incirlik , { "REDAICAP" }, 10)
    MESSAGE:New("Squadrons have been refilled!",10,"System"):ToAll()
end
local refillScheduler = SCHEDULER:New(nil, refillSquadrons, {}, 0, 7200) -- 7200 secondi sono 2 ore
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