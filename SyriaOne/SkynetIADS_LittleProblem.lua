--- Crea Sistema IADS RED
RedIADS = SkynetIADS:create('RED IADS')

local commandCenter = StaticObject.getByName("Command Center")
RedIADS:addCommandCenter(commandCenter)
--- Aggiunge tutte le unità che hanno come prefisso REDSAM - REDEW - REDCC
RedIADS:addSAMSitesByPrefix('REDSAM')
RedIADS:addEarlyWarningRadarsByPrefix('REDEW')
RedIADS:addRadioMenu()
RedIADS:setUpdateInterval(5)
RedIADS:getSAMSiteByGroupName('REDSAM-S300CIPRO'):setActAsEW(true)
RedIADS:getSAMSiteByGroupName('REDSAM-S300CIPRO-1'):setActAsEW(true)

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

local sa15PDEast = RedIADS:getSAMSiteByGroupName('REDSAM-PDSA10East')
RedIADS:getSAMSiteByGroupName('REDSAM-S300CIPRO'):addPointDefence(sa15PDEast)

-- Attiva sistema IADS Skynet
RedIADS:activate()

--- INIZIO MOOSE AI-A2A-DISPATCHER

DetectionSetGroup = SET_GROUP:New()
Detection = DETECTION_AREAS:New( DetectionSetGroup, 30000 )
A2ADispatcher = AI_A2A_DISPATCHER:New( Detection )
A2ADispatcher:SetEngageRadius() -- 100000 is the default value.
A2ADispatcher:SetGciRadius() -- 200000 is the default value.

REDBorderZone = ZONE_POLYGON:New( "RED-BORDER", GROUP:FindByName( "RED-BORDER" ) )
A2ADispatcher:SetBorderZone( REDBorderZone )
A2ADispatcher:SetSquadron( "Larnaca", AIRBASE.Syria.Larnaca , { "REDAICAP-Mig29" }, 20 )
A2ADispatcher:SetSquadronGrouping( "Larnaca", 2 )
A2ADispatcher:SetSquadronGci( "Larnaca", 900, 1200 )
A2ADispatcher:SetTacticalDisplay(true)
A2ADispatcher:SetDefaultTakeoffFromParkingHot()
A2ADispatcher:SetDefaultLandingAtRunway()
A2ADispatcher:Start()

--- FINE MOOSE AI-A2A-DISPATCHER

RedIADS:addMooseSetGroup(DetectionSetGroup)

--- Debug ---

--local iadsDebug = RedIADS:getDebugSettings()

--iadsDebug.IADSStatus = true
--iadsDebug.contacts = true
--iadsDebug.jammerProbability = true
--iadsDebug.samSiteStatusEnvOutput = true
--iadsDebug.earlyWarningRadarStatusEnvOutput = true
--iadsDebug.addedEWRadar = true
--iadsDebug.addedSAMSite = true
--iadsDebug.warnings = true
--iadsDebug.radarWentLive = true
--iadsDebug.radarWentDark = true
--iadsDebug.harmDefence = true

--- fine debug ---