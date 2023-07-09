-- Dichiarazione HQ
US_CC = COMMANDCENTER:New(GROUP:FindByName("BLUEHQ"),"Blue Command Center")
RU_CC = COMMANDCENTER:New(GROUP:FindByName("REDHQ"), "Red Command Center")

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


