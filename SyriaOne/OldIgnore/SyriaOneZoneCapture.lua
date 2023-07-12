require("Functional")

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

-- Funzione di difesa e ricattura
-- Questa funzione gestisce le unità in caso di attacco ad una delle warehouse. La funzione dovra attivarsi non appena c'è un evento di tipo: "OnEnterAttacked" e invierà un messaggio 
-- a tutte le coalizioni per indicare che c'è l'attacco in corso. subito dopo spawnera con la funzione "self" 3 unità di tipo "TEMPL-RedTank" che difenderanno la zona. Nel caso in cui
-- La warehouse non ha disponibili i mezzi , deve chiederli a Larnaca. Se Larnaca non ha unità di quel tipo disponibili , dovra fare una richiesta a Incirlik. Se Incirlik non ha unità
-- o non è disponibile, allora la richiesta sarà negata. 

function ZoneCaptureCoalition:OnEnterGuarded(From, Event, To, self)
    if From ~= To then
        local Coalition = self:GetCoalition()
        self:E({ Coalition = Coalition })
        if Coalition == coalition.side.BLUE then
            self:Smoke(SMOKECOLOR.Blue)
            US_CC:MessageTypeToCoalition(string.format("%s is under protection of the RED", self:GetZoneName()), MESSAGE.Type.Information)
            RU_CC:MessageTypeToCoalition(string.format("%s is under protection of the BLUE", self:GetZoneName()), MESSAGE.Type.Information)
        else
            self:Smoke(SMOKECOLOR.Red)
            RU_CC:MessageTypeToCoalition(string.format("%s is under protection of BLUE", self:GetZoneName()), MESSAGE.Type.Information)
            US_CC:MessageTypeToCoalition(string.format("%s is under protection of RED", self:GetZoneName()), MESSAGE.Type.Information)
        end
    end
end

function ZoneCaptureCoalition:OnEnterCapture(From, Event, To)
    if From ~= To then
        local Coalition = self:GetCoalition()
        self:E({ Coalition = Coalition })
        if Coalition == coalition.side.BLUE then
            self:Smoke(SMOKECOLOR.Blue)
            US_CC:MessageTypeToCoalition(string.format("%s is under attack by RED", self:GetZoneName()), MESSAGE.Type.Information)
            RU_CC:MessageTypeToCoalition(string.format("%s is under attack by BLUE", self:GetZoneName()), MESSAGE.Type.Information)
        else
            self:Smoke(SMOKECOLOR.Red)
            RU_CC:MessageTypeToCoalition(string.format("%s is under attack by BLUE", self:GetZoneName()), MESSAGE.Type.Information)
            US_CC:MessageTypeToCoalition(string.format("%s is under attack by RED", self:GetZoneName()), MESSAGE.Type.Information)
        end
    end
end
