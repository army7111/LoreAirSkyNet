--- Crea Sistema IADS RED
redIADS = SkynetIADS:create('RED IADS')

local commandCenter = StaticObject.getByName("Command Center")
redIADS:addCommandCenter(commandCenter)
--- Aggiunge tutte le unità che hanno come prefisso REDSAM - REDEW - REDCC
redIADS:addSAMSitesByPrefix('REDSAM')
redIADS:addEarlyWarningRadarsByPrefix('REDEW')
redIADS:addRadioMenu()
redIADS:setUpdateInterval(5)

-- Attiva sistema IADS Skynet
redIADS:activate()

--- Debug 

local iadsDebug = redIADS:getDebugSettings()  

iadsDebug.IADSStatus = true
iadsDebug.contacts = true
iadsDebug.jammerProbability = true

iadsDebug.addedEWRadar = true
iadsDebug.addedSAMSite = true
iadsDebug.warnings = true
iadsDebug.radarWentLive = true
iadsDebug.radarWentDark = true
iadsDebug.harmDefence = true