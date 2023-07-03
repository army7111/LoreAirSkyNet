-- Funzione per creare una nuova zona di cattura
function newCaptureZone(t, name)
    local zone = ZONE:FindByName("AZ" .. name)
    t[name] = zone
end

-- Dichiarazione command center
RED_CC = COMMANDCENTER:New( GROUP:FindByName("REDHQ"), "Red HeadQuarter")
BLUE_CC = COMMANDCENTER:New(GROUP:FindByName("BLUEHQ"), "Blue HeadQuarter")

-- Dichiarazione zone di cattura
local captureZones = {}

-- Creazione zone di cattura
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

-- Tabella degli stati delle zone di cattura
local captureZoneStates = {}

-- Funzione per controllare gli eventi di transizione delle zone di cattura
function checkCaptureZoneEvents()
    for _, zone in pairs(captureZones) do
        local currentState = captureZoneStates[zone:GetName()]
        local nextState = zone:GetState()

        if currentState ~= nextState then
            handleCaptureZoneEvent(zone, currentState, nextState)
            captureZoneStates[zone:GetName()] = nextState
        end
    end
end

-- Funzione per gestire gli eventi di transizione delle zone di cattura
function handleCaptureZoneEvent(zone, from, to)
    local Coalition = zone:GetCoalition()

    if from ~= to then
        if Coalition == coalition.side.BLUE then
            -- La zona è stata catturata dalla coalizione blu (USA)
            BLUE_CC:MessageTypeToCoalition(string.format("%s è sotto protezione BLUE", zone:GetName()), MESSAGE.Type.Information)
            RED_CC:MessageTypeToCoalition(string.format("%s è sotto protezione BLUE", zone:GetName()), MESSAGE.Type.Information)
        else
            -- La zona è stata catturata dalla coalizione rossa (Russia)
            RED_CC:MessageTypeToCoalition(string.format("%s è sotto protezione RED", zone:GetName()), MESSAGE.Type.Information)
            BLUE_CC:MessageTypeToCoalition(string.format("%s è sotto protezione RED", zone:GetName()), MESSAGE.Type.Information)
        end
    end

    if to == ZONE_CAPTURE_COALITION.States.Empty then
        -- La zona è vuota e può essere catturata
        BLUE_CC:MessageTypeToCoalition(string.format("%s non è protetta e deve essere catturata!", zone:GetName()), MESSAGE.Type.Information)
        RED_CC:MessageTypeToCoalition(string.format("%s non è protetta e deve essere catturata!", zone:GetName()), MESSAGE.Type.Information)
    end

    if to == ZONE_CAPTURE_COALITION.States.Attacked then
        -- La zona è sotto attacco
        if Coalition == coalition.side.BLUE then
            BLUE_CC:MessageTypeToCoalition(string.format("%s è sotto attacco RED", zone:GetName()), MESSAGE.Type.Information)
            RED_CC:MessageTypeToCoalition(string.format("Stiamo attaccando %s", zone:GetName()), MESSAGE.Type.Information)
        else
            RED_CC:MessageTypeToCoalition(string.format("%s è sotto attacco BLUE", zone:GetName()), MESSAGE.Type.Information)
            BLUE_CC:MessageTypeToCoalition(string.format("Stiamo attaccando %s", zone:GetName()), MESSAGE.Type.Information)
        end
    end

    if to == ZONE_CAPTURE_COALITION.States.Captured then
        -- La zona è stata catturata
        if Coalition == coalition.side.BLUE then
            RED_CC:MessageTypeToCoalition(string.format("%s è stata catturata dai BLUE .. L'abbiamo persa!", zone:GetName()), MESSAGE.Type.Information)
            BLUE_CC:MessageTypeToCoalition(string.format("Abbiamo catturato %s, Ottimo lavoro!", zone:GetName()), MESSAGE.Type.Information)
        else
            BLUE_CC:MessageTypeToCoalition(string.format("%s è catturata dai RED, L'abbiamo persa!", zone:GetName()), MESSAGE.Type.Information)
            RED_CC:MessageTypeToCoalition(string.format("Abbiamo catturato %s, Ottimo lavoro!", zone:GetName()), MESSAGE.Type.Information)
        end
    end
end

-- Funzione per avviare il monitoraggio degli eventi di transizione delle zone di cattura
function startCaptureZoneEventMonitoring()
    SCHEDULER:New(nil, checkCaptureZoneEvents, {}, 1, 1)
end

-- Avvia la cattura delle zone
for _, zone in pairs(captureZones) do
    ZONE_CAPTURE_COALITION:New(zone)
        :Start(30) -- Durata di 30 secondi per la cattura della zona
end

-- Avvia il monitoraggio degli eventi di transizione delle zone di cattura
startCaptureZoneEventMonitoring()
