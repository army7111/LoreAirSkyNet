--- Crea Sistema IADS RED
RedIADS = SkynetIADS:create('RED IADS')

local commandCenter = StaticObject.getByName("Command Center")
RedIADS:addCommandCenter(commandCenter)
--- Aggiunge tutte le unità che hanno come prefisso REDSAM - REDEW - REDCC
RedIADS:addSAMSitesByPrefix('REDSAM')
RedIADS:addEarlyWarningRadarsByPrefix('REDEW')
RedIADS:addRadioMenu()
RedIADS:setUpdateInterval(5)
RedIADS:getSAMSiteByGroupName('REDSAM-S300'):setActAsEW(true)

-- Impostazione del range di ingaggio al massimo per tutti i siti SAM
local allSAMSites = RedIADS:getSAMSites()
for i, samSite in ipairs(allSAMSites) do
   -- samSite:setHARMDetectionChance(100)
    samSite:setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
end



-- Dichiarazione Point Defence 
local sa15PDKTS = RedIADS:getSAMSiteByGroupName('REDSAM-PDKUTAISI')
RedIADS:getSAMSiteByGroupName('REDSAM-S300'):addPointDefence(sa15PDKTS)


-- Attiva sistema IADS Skynet
RedIADS:activate()

--- Debug ---

local iadsDebug = RedIADS:getDebugSettings()  

iadsDebug.IADSStatus = true
iadsDebug.contacts = true
iadsDebug.jammerProbability = true

--iadsDebug.samSiteStatusEnvOutput = true
--iadsDebug.earlyWarningRadarStatusEnvOutput = true
iadsDebug.addedEWRadar = true
iadsDebug.addedSAMSite = true
iadsDebug.warnings = true
iadsDebug.radarWentLive = true
iadsDebug.radarWentDark = true
iadsDebug.harmDefence = true

--- fine debug ---