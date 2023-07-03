-- Funzione per creare una nuova zona di cattura
function newCaptureZone(t, name)
    local captureZone = ZONE:New("AZ" .. name)
    local zoneCaptureCoalition = ZONE_CAPTURE_COALITION:New(captureZone, coalition.side.RED)
    zoneCaptureCoalition:__Guard(1) -- Imposta la zona nello stato di "Guarding"
    zoneCaptureCoalition:Start() -- Avvia il monitoraggio della zona
    t[name] = zoneCaptureCoalition
end

-- Dichiarazione delle zone di cattura
local captureZones = {}

-- Creazione delle zone di cattura
newCaptureZone(captureZones, "Paphos")
newCaptureZone(captureZones, "Akrotiri")
newCaptureZone(captureZones, "Pinarbashi")
newCaptureZone(captureZones, "Lakatamia")
newCaptureZone(captureZones, "Ercan")
newCaptureZone(captureZones, "Larnaca")
newCaptureZone(captureZones, "Kingsfield")
newCaptureZone(captureZones, "Gecitkale")
newCaptureZone(captureZones, "EastCypro")
newCaptureZone(captureZones, "Testadiponte")

-- Funzione per gestire l'evento di zona di cattura sotto protezione
function handleCaptureZoneGuarded(zone)
    local Coalition = zone:GetCoalition()
    if Coalition == coalition.side.BLUE then
        BLUE_CC:MessageTypeToCoalition(string.format("%s è sotto protezione BLUE", zone:GetName()), MESSAGE.Type.Information)
        RED_CC:MessageTypeToCoalition(string.format("%s è sotto protezione BLUE", zone:GetName()), MESSAGE.Type.Information)
    else
        RED_CC:MessageTypeToCoalition(string.format("%s è sotto protezione RED", zone:GetName()), MESSAGE.Type.Information)
        BLUE_CC:MessageTypeToCoalition(string.format("%s è sotto protezione RED", zone:GetName()), MESSAGE.Type.Information)
    end
end

-- Funzione per gestire l'evento di zona di cattura vuota
function handleCaptureZoneEmpty(zone)
    BLUE_CC:MessageTypeToCoalition(string.format("%s non è protetta e deve essere catturata!", zone:GetName()), MESSAGE.Type.Information)
    RED_CC:MessageTypeToCoalition(string.format("%s non è protetta e deve essere catturata!", zone:GetName()), MESSAGE.Type.Information)
end

-- Funzione per gestire l'evento di zona di cattura sotto attacco
function handleCaptureZoneAttacked(zone)
    local Coalition = zone:GetCoalition()
    if Coalition == coalition.side.BLUE then
        BLUE_CC:MessageTypeToCoalition(string.format("%s è sotto attacco RED", zone:GetName()), MESSAGE.Type.Information)
        RED_CC:MessageTypeToCoalition(string.format("Stiamo attaccando %s", zone:GetName()), MESSAGE.Type.Information)
    else
        RED_CC:MessageTypeToCoalition(string.format("%s è sotto attacco BLUE", zone:GetName()), MESSAGE.Type.Information)
        BLUE_CC:MessageTypeToCoalition(string.format("Stiamo attaccando %s", zone:GetName()), MESSAGE.Type.Information)
    end
end

-- Funzione per gestire l'evento di zona di cattura catturata
function handleCaptureZoneCaptured(zone)
    local Coalition = zone:GetCoalition()
    if Coalition == coalition.side.BLUE then
        RED_CC:MessageTypeToCoalition(string.format("%s è stata catturata dai BLUE .. L'abbiamo persa!", zone:GetName()), MESSAGE.Type.Information)
        BLUE_CC:MessageTypeToCoalition(string.format("Abbiamo catturato %s, Ottimo lavoro!", zone:GetName()), MESSAGE.Type.Information)
    else
        BLUE_CC:MessageTypeToCoalition(string.format("%s è catturata dai RED, L'abbiamo persa!", zone:GetName()), MESSAGE.Type.Information)
        RED_CC:MessageTypeToCoalition(string.format("Abbiamo catturato %s, Ottimo lavoro!", zone:GetName()), MESSAGE.Type.Information)
    end
end

-- Funzione per avviare il monitoraggio degli eventi di transizione delle zone di cattura
function startCaptureZoneEventMonitoring()
    for _, zone in pairs(captureZones) do
        zone:OnEnterGuarded(handleCaptureZoneGuarded)
        zone:OnEnterEmpty(handleCaptureZoneEmpty)
        zone:OnEnterAttacked(handleCaptureZoneAttacked)
        zone:OnEnterCaptured(handleCaptureZoneCaptured)
    end
end

-- Avvia il monitoraggio degli eventi di transizione delle zone di cattura
startCaptureZoneEventMonitoring()
