local syriaCSAR = CSAR:New(coalition.side.BLUE,"CSARPilot","SOS-Beacon")
syriaCSAR.immortalcrew = true
syriaCSAR.invisiblecrew = true
syriaCSAR.allowbronco = true
syriaCSAR.topmenuname = "Combat Search & Rescue"
syriaCSAR.useprefix = true
syriaCSAR.csarPrefix = "CSAR"

function syriaCSAR:OnAfterPilotDown(From, Event, To, SpawnedGroup, Frequency, Leadername, CoordinatesText)
    MESSAGE:New(string.format("Il pilota %s è abbattuto! La frequenza per il CSAR è %s KHz, le coordinate sono %s.", Leadername, Frequency, CoordinatesText), 15):ToAll()
end

syriaCSAR:Start()

local csarZone = ZONE:New("CSARMissionZone")

local csarGroups = SET_GROUP:New():FilterPrefixes({"CSAR"}):FilterStart()

local csarDetection = DETECTION_UNITS:New(csarGroups, csarZone, 1000)

local function startCsarMission()
  syriaCSAR:SpawnCSARAtZone(csarZone, coalition.side.BLUE, "PilotaTEST", true)
end

local csarMissionScheduler = SCHEDULER:New(nil, startCsarMission, {}, 0, 600)

csarDetection:Start() 

CSAR_SCHEDULER_RUNNING = false

function csarDetection:OnAfterDetect(EventData)
  local detectedSets = EventData.DetectedSets
  local firstSet = detectedSets and detectedSets[1]
  
  if firstSet and firstSet:Count() > 0 then
    if not CSAR_SCHEDULER_RUNNING then
        csarMissionScheduler:Start()
        CSAR_SCHEDULER_RUNNING = true
    end
  else
    if CSAR_SCHEDULER_RUNNING then
        csarMissionScheduler:Stop()
        CSAR_SCHEDULER_RUNNING = false
    end
  end
end
