local syriaCSAR = CSAR:New(coalition.side.BLUE, "CSARPilot", "SOS-Beacon")
syriaCSAR.immortalcrew = true
syriaCSAR.invisiblecrew = true
syriaCSAR.allowbronco = true
syriaCSAR.topmenuname = "Combat Search & Rescue"
syriaCSAR.useprefix = true
syriaCSAR.csarPrefix = "CSAR"

local activeCsarMissions = 0

function syriaCSAR:OnAfterPilotDown(From, Event, To, SpawnedGroup, Frequency, Leadername, CoordinatesText)
    activeCsarMissions = activeCsarMissions + 1
    MESSAGE:New(string.format("Il pilota %s è abbattuto! La frequenza per il CSAR è %s KHz, le coordinate sono %s.",
        Leadername, Frequency, CoordinatesText), 15):ToAll()
end

syriaCSAR:Start()

local csarZone = ZONE:New("CSARMissionZone")

local function startCsarMission()
    if activeCsarMissions < 5 then
        syriaCSAR:SpawnCSARAtZone(csarZone, coalition.side.BLUE, "PilotaTEST", true)
        activeCsarMissions = activeCsarMissions + 1
    end
end

function syriaCSAR:OnAfterRescued(From, Event, To, HeliUnit, HeliName, PilotsSaved)
    activeCsarMissions = activeCsarMissions - 1
    MESSAGE:New("Missione CSAR terminata con successo.", 15):ToAll()
end

local checkActiveMissionsScheduler = SCHEDULER:New(nil, startCsarMission, {}, 0, 60)
checkActiveMissionsScheduler:Start()
