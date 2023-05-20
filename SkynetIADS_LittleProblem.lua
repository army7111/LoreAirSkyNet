--- Crea Sistema IADS RED
RedIADS = SkynetIADS:create('RED IADS')

local commandCenter = StaticObject.getByName("Command Center")
RedIADS:addCommandCenter(commandCenter)
--- Aggiunge tutte le unità che hanno come prefisso REDSAM - REDEW - REDCC
RedIADS:addSAMSitesByPrefix('REDSAM')
RedIADS:addEarlyWarningRadarsByPrefix('REDEW')
RedIADS:addRadioMenu()
RedIADS:setUpdateInterval(5)

-- Attiva sistema IADS Skynet
RedIADS:activate()