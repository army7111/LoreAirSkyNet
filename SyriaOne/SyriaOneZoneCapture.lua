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

-- Funzione per gestire gli eventi di transizione delle zone di cattura
function handleCaptureZoneEvent(self, From, Event, To)
    local Coalition = self:GetCoalition()
    self:E({ Coalition = Coalition })

    -- Gestisci l'evento di cambio di stato
    if From ~= To then
        if Coalition == coalition.side.BLUE then
            self:Smoke(SMOKECOLOR.Blue)
            US_CC:MessageTypeToCoalition(string.format("%s is under protection of the USA", self:GetZoneName()), MESSAGE.Type.Information)
            RU_CC:MessageTypeToCoalition(string.format("%s is under protection of the USA", self:GetZoneName()), MESSAGE.Type.Information)
        else
            self:Smoke(SMOKECOLOR.Red)
            RU_CC:MessageTypeToCoalition(string.format("%s is under protection of Russia", self:GetZoneName()), MESSAGE.Type.Information)
            US_CC:MessageTypeToCoalition(string.format("%s is under protection of Russia", self:GetZoneName()), MESSAGE.Type.Information)
        end
    end
end
