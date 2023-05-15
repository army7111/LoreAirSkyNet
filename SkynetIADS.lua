--- Crea Sistema IADS RED
redIADS = SkynetIADS:create('RED IADS')

--- Aggiunge tutte le unità che hanno come prefisso REDSAM - REDEW - REDCC
redIADS:addSAMSitesByPrefix('REDSAM')
redIADS:addEarlyWarningRadarsByPrefix('REDEW')
redIADS:addComma

-- Attiva sistema IADS Skynet
redIADS:activate()