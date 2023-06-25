_SETTINGS:SetPlayerMenuOff()

-- Capture zone persistence
----------------------------------------------------------
SaveScheduleUnits = 60 --Seconds between each table write
----------------------------------------------------------
RedAttackInterval = 60*60 --Seconds between each red attack
RedAttackIntervalSlow = 60*60
RedAttackIntervalFast = 30*60
RED_ATTACK_ENABLED = true
BLUE_ATTACK_ENABLED = true
PRICE_TANKATTACK = 30
PRICE_CASATTACK = 20
loadELINT = false

CaucasusPendulum = {}
CaucasusPendulum.radioMenusAdded = {}

TEAM_RESOURCES_MAX = {}
TEAM_RESOURCES_MAX[1] = 100
TEAM_RESOURCES_MAX[2] = 100

TEAM_RESOURCES = {}
CAPZONES = {"ALPHA", "BRAVO", "CHARLIE", "DELTA", "ECHO", "FOXTROT", "GOLF", "HOTEL", "INDIA", "JULIET", "KILO", "LIMA", "MIKE", "NOVEMBER", "OSCAR", "PAPA", "QUEBEC", "ROMEO", "SIERRA", "TANGO", "UNIFORM", "VICTOR", "WHISKEY", "XRAY", "YANKEE", "ZULU"}
CAPZONE_ID = {["ALPHA"] = 1, ["BRAVO"] = 2, ["CHARLIE"] = 3, ["DELTA"] = 4, ["ECHO"] = 5, ["FOXTROT"] = 6, ["GOLF"] = 7, ["HOTEL"] = 8, ["INDIA"] = 9, ["JULIET"] = 10, ["KILO"] = 11, ["LIMA"] = 12, ["MIKE"] = 13, ["NOVEMBER"] = 14, ["OSCAR"] = 15, ["PAPA"] = 16, ["QUEBEC"] = 17, ["ROMEO"] = 18, ["SIERRA"] = 19, ["TANGO"] = 20, ["UNIFORM"] = 21, ["VICTOR"] = 22, ["WHISKEY"] = 23, ["XRAY"] = 24, ["YANKEE"] = 25, ["ZULU"] = 26}

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function IntegratedbasicSerialize(s)
    if s == nil then
		return "\"\""
    else
		if ((type(s) == 'number') or (type(s) == 'boolean') or (type(s) == 'function') or (type(s) == 'table') or (type(s) == 'userdata') ) then
			return tostring(s)
		elseif type(s) == 'string' then
			return string.format('%q', s)
		end
    end
end
  
-- imported slmod.serializeWithCycles (Speed)
function IntegratedserializeWithCycles(name, value, saved)
    local basicSerialize = function (o)
		if type(o) == "number" then
			return tostring(o)
		elseif type(o) == "boolean" then
			return tostring(o)
		else -- assume it is a string
			return IntegratedbasicSerialize(o)
		end
	end

    local t_str = {}
    saved = saved or {}       -- initial value
    if ((type(value) == 'string') or (type(value) == 'number') or (type(value) == 'table') or (type(value) == 'boolean')) then
		table.insert(t_str, name .. " = ")
			if type(value) == "number" or type(value) == "string" or type(value) == "boolean" then
				table.insert(t_str, basicSerialize(value) ..  "\n")
			else
				if saved[value] then    -- value already saved?
					table.insert(t_str, saved[value] .. "\n")
				else
					saved[value] = name   -- save name for next time
					table.insert(t_str, "{}\n")
						for k,v in pairs(value) do      -- save its fields
							local fieldname = string.format("%s[%s]", name, basicSerialize(k))
							table.insert(t_str, IntegratedserializeWithCycles(fieldname, v, saved))
						end
				end
			end
		return table.concat(t_str)
    else
		return ""
    end
end

function file_exists(name) --check if the file already exists for writing
	if lfs == nil then
		return false
	elseif lfs.attributes(name) then
		return true
    else
		return false 
	end 
end

function writemission(data, file)--Function for saving to file (commonly found)
	File = io.open(file, "w")
	File:write(data)
	File:close()
end

function SEF_GetTableLength(Table)
	local TableLengthCount = 0
	for _ in pairs(Table) do TableLengthCount = TableLengthCount + 1 end
	return TableLengthCount
end

function getPlayerCount(side)
	local coalitionPlayers = coalition.getPlayers(side)
	return SEF_GetTableLength(coalitionPlayers)
end

function CaucasusPendulum.FOBTest()
    local _fob = ctld.spawnFOB("USA", 1, {x=0, y=0}, "CTLD Test FOB #1")
end
--timer.scheduleFunction(CaucasusPendulum.FOBTest, {}, timer.getTime() + (10))

function CaucasusPendulum.SEF_SaveCaptureZoneTable(timeloop, time)
	env.info("Progress saving...")
	AllGroups = SET_GROUP:New():FilterPrefixes("CTLD "):FilterActive(true):FilterStart()
	
	AllGroups:ForEachGroupAlive(function (grp)
		local DCSgroup = Group.getByName(grp:GetName() )
		local size = DCSgroup:getSize()
		_unittable={}
		for i = 1, size do
			local tmpTable =
			{   
				["type"]=grp:GetUnit(i):GetTypeName(),
				["transportable"]=true,
				["unitID"]=grp:GetUnit(i):GetID(),
				["skill"]="Average",
				["y"]=grp:GetUnit(i):GetVec2().y,
				["x"]=grp:GetUnit(i):GetVec2().x,
				["name"]=grp:GetUnit(i):GetName(),
				["playerCanDrive"]=true,
				["heading"]=math.rad(grp:GetUnit(i):GetHeading()), --fixed 24/03/2020
			}
			table.insert(_unittable,tmpTable) --add units to a temporary table
		end
	
		SaveUnits[grp:GetName()] =
		{
			["CountryID"]=grp:GetCountry(),
			["SpawnCoalitionID"]=grp:GetCountry(),
			["tasks"]={}, 
			["CategoryID"]=grp:GetCategory(),
			["task"]="Ground Nothing",
			["route"]={}, 
			["groupId"]=grp:GetID(),
			["units"]= _unittable,
			["y"]=grp:GetVec2().y, 
			["x"]=grp:GetVec2().x,
			["name"]=grp:GetName(),
			["start_time"]=0,
			["CoalitionID"]=grp:GetCoalition(),
			["SpawnCountryID"]=grp:GetCoalition(),
		}
	end)


	CaucasusPendulum.checkFOBs()
	
	persistenceStr = IntegratedserializeWithCycles("TEAM_RESOURCES", TEAM_RESOURCES) .. IntegratedserializeWithCycles("CAPZONE_STATUS", CAPZONE_STATUS) .. IntegratedserializeWithCycles("ctld.persistedFOBS", ctld.persistedFOBS) .. IntegratedserializeWithCycles("SaveUnits", SaveUnits) .. IntegratedserializeWithCycles("ctld.spawnedCratesRED", ctld.spawnedCratesRED) .. IntegratedserializeWithCycles("ctld.spawnedCratesBLUE", ctld.spawnedCratesBLUE) .. IntegratedserializeWithCycles("ctld.droppedTroopsRED", ctld.droppedTroopsRED) .. IntegratedserializeWithCycles("ctld.droppedTroopsBLUE", ctld.droppedTroopsBLUE) .. IntegratedserializeWithCycles("ctld.droppedVehiclesRED", ctld.droppedVehiclesRED) .. IntegratedserializeWithCycles("ctld.droppedVehiclesBLUE", ctld.droppedVehiclesBLUE) .. IntegratedserializeWithCycles("ctld.droppedFOBCratesRED", ctld.droppedFOBCratesRED) .. IntegratedserializeWithCycles("ctld.droppedFOBCratesBLUE", ctld.droppedFOBCratesBLUE) .. IntegratedserializeWithCycles("ctld.builtFOBS", ctld.builtFOBS) .. IntegratedserializeWithCycles("ctld.completeAASystems", ctld.completeAASystems)

	writemission(persistenceStr, "CaucasusConflictPersistence.lua")
	SaveUnits = {}
	env.info("Progress saved.")
	return time + SaveScheduleUnits
end

function CaucasusPendulum.checkFOBs()
	-- Each FOB increases the maximum resource storage for a team by 100 points
	TEAM_RESOURCES_MAX[1] = 100
	TEAM_RESOURCES_MAX[2] = 100
	for k,v in pairs (ctld.persistedFOBS) do
		_name = k
--		env.info("FOB: " .. _name .. " Faction: " .. ctld.persistedFOBS[_name]["country"])
		TEAM_RESOURCES_MAX[ctld.persistedFOBS[_name]["country"]] = TEAM_RESOURCES_MAX[ctld.persistedFOBS[_name]["country"]] + 100
	end

	-- Teams can only have as many resource points as they have storage capacity
	if TEAM_RESOURCES[1] > TEAM_RESOURCES_MAX[1] then
		TEAM_RESOURCES[1] = TEAM_RESOURCES_MAX[1]
	end
	if TEAM_RESOURCES[2] > TEAM_RESOURCES_MAX[2] then
		TEAM_RESOURCES[2] = TEAM_RESOURCES_MAX[2]
	end
end

-- LOAD PERSISTENCY ***************************************************************************************

function CaucasusPendulum.spawnFOBs()
	--RUN THROUGH THE KEYS IN THE TABLE (FOBs)
	for k,v in pairs (ctld.persistedFOBS) do
		_name = k
		env.info("Spawning saved FOB: " .. _name)

        local _fob = ctld.spawnFOB(ctld.persistedFOBS[_name]["country"], ctld.getNextUnitId(), {x=ctld.persistedFOBS[_name]["x"], y=ctld.persistedFOBS[_name]["y"], z=ctld.persistedFOBS[_name]["z"]}, _name)
        --make it able to deploy crates
        table.insert(ctld.logisticUnits, _fob:getName())

        ctld.beaconCount = ctld.beaconCount + 1
        local _radioBeaconName = "CTLD FOB Beacon #" .. ctld.beaconCount
        local _radioBeaconDetails = ctld.createRadioBeacon({x=ctld.persistedFOBS[_name]["x"], y=ctld.persistedFOBS[_name]["y"], z=ctld.persistedFOBS[_name]["z"]}, ctld.persistedFOBS[_name]["coalition"], ctld.persistedFOBS[_name]["country"], _radioBeaconName, nil, true)
        ctld.fobBeacons[_name] = { vhf = _radioBeaconDetails.vhf, uhf = _radioBeaconDetails.uhf, fm = _radioBeaconDetails.fm }
		
		local mooseFOB = STATIC:FindByName(_name)
		mooseFOB:HandleEvent(EVENTS.Dead)
		function mooseFOB:OnEventDead(EventData)
--			trigger.action.outText("FOB Destroyed: "..EventData.IniUnitName, 10) --..EventData.TgtDCSUnitName, 10)
			ctld.builtFOBS[EventData.IniUnitName] = nil
			ctld.persistedFOBS[EventData.IniUnitName] = nil
		end
		
		env.info("Spawning FOB done: " .. _name)

	end
end



SaveUnits={}
ctld.persistedFOBS={}
if file_exists("CaucasusConflictPersistence.lua") then
	dofile("CaucasusConflictPersistence.lua")
	tempTable={}
	Spawn={}

	CaucasusPendulum.spawnFOBs()

	--RUN THROUGH THE KEYS IN THE TABLE (GROUPS)
	for k,v in pairs (SaveUnits) do
		units={}
		--RUN THROUGH THE UNITS IN EACH GROUP
		for i= 1, #(SaveUnits[k]["units"]) do 
			env.info("Spawning saved group: " .. SaveUnits[k]["units"][i]["name"])

			tempTable =
			{ 
				["type"]=SaveUnits[k]["units"][i]["type"],
				["transportable"]= {["randomTransportable"] = false,}, 
				--["unitId"]=9000,used to generate ID's here but no longer doing that since DCS seems to handle it
				["skill"]=SaveUnits[k]["units"][i]["skill"],
				["y"]=SaveUnits[k]["units"][i]["y"] ,
				["x"]=SaveUnits[k]["units"][i]["x"] ,
				["name"]=SaveUnits[k]["units"][i]["name"],
				["heading"]=SaveUnits[k]["units"][i]["heading"],
				["playerCanDrive"]=true,  --hardcoded but easily changed.  
				ctld.getNextUnitId()
			}
			table.insert(units,tempTable)
		end --end unit for loop
		
		groupData = 
		{
			["visible"] = true,
			--["lateActivation"] = false,
			["tasks"] = {}, -- end of ["tasks"]
			["uncontrollable"] = false,
			["task"] = "Ground Nothing",
			--["taskSelected"] = true,
			--["route"] = 
			--{ 
			--["spans"] = {},
			--["points"]= {}
			-- },-- end of ["spans"] 
			--["groupId"] = 9000 + _count,
			["hidden"] = false,
			["units"] = units,
			["y"] = SaveUnits[k]["y"],
			["x"] = SaveUnits[k]["x"],
			["name"] = SaveUnits[k]["name"],
			--["start_time"] = 0,
		} 
		coalition.addGroup(SaveUnits[k]["CountryID"], SaveUnits[k]["CategoryID"], groupData)
		groupData = {}
	end --end Group for loop
else
	TEAM_RESOURCES[coalition.side.BLUE] = 0
	TEAM_RESOURCES[coalition.side.RED] = 0
	CAPZONE_STATUS = {}
	CAPZONE_STATUS.ALPHA = coalition.side.BLUE
	CAPZONE_STATUS.BRAVO = coalition.side.BLUE
	CAPZONE_STATUS.CHARLIE = coalition.side.BLUE
	CAPZONE_STATUS.DELTA = coalition.side.BLUE
	CAPZONE_STATUS.ECHO = coalition.side.BLUE
	CAPZONE_STATUS.FOXTROT = coalition.side.BLUE
	CAPZONE_STATUS.GOLF = coalition.side.BLUE
	CAPZONE_STATUS.HOTEL = coalition.side.BLUE
	CAPZONE_STATUS.INDIA = coalition.side.BLUE
	CAPZONE_STATUS.JULIET = coalition.side.BLUE
	CAPZONE_STATUS.KILO = coalition.side.BLUE
	CAPZONE_STATUS.LIMA = coalition.side.BLUE
	CAPZONE_STATUS.MIKE = coalition.side.RED
	CAPZONE_STATUS.NOVEMBER = coalition.side.RED
	CAPZONE_STATUS.OSCAR = coalition.side.RED
	CAPZONE_STATUS.PAPA = coalition.side.RED
	CAPZONE_STATUS.QUEBEC = coalition.side.RED
	CAPZONE_STATUS.ROMEO = coalition.side.RED
	CAPZONE_STATUS.SIERRA = coalition.side.RED
	CAPZONE_STATUS.TANGO = coalition.side.RED
	CAPZONE_STATUS.UNIFORM = coalition.side.RED
	CAPZONE_STATUS.VICTOR = coalition.side.RED
	CAPZONE_STATUS.WHISKEY = coalition.side.RED
	CAPZONE_STATUS.XRAY = coalition.side.RED
	CAPZONE_STATUS.YANKEE = coalition.side.RED
	CAPZONE_STATUS.ZULU = coalition.side.RED
end




-- Rescue Helo with home base Lake Erie. Has to be a global object!
rescuehelo=RESCUEHELO:New("BLUE CV STENNIS", "BLUE CV STENNIS RESCUE HELO")
rescuehelo:SetHomeBase(AIRBASE:FindByName("BLUE CV ANZIO"))
rescuehelo:SetModex(42)
rescuehelo:__Start(1)

local AirbossStennis=AIRBOSS:New("BLUE CV STENNIS")
AirbossStennis:AddRecoveryWindow("5:50", "6:50", 1, nil, true, 20)
AirbossStennis:AddRecoveryWindow("7:50", "9:50", 1, nil, true, 20)
AirbossStennis:AddRecoveryWindow("10:50", "12:50", 1, nil, true, 20)
AirbossStennis:AddRecoveryWindow("13:50", "15:50", 1, nil, true, 20)
AirbossStennis:AddRecoveryWindow("16:50", "18:50", 1, nil, true, 20)
AirbossStennis:AddRecoveryWindow("19:50", "21:50", 1, nil, true, 20)
AirbossStennis:AddRecoveryWindow("22:50", "23:50", 1, nil, true, 20)
AirbossStennis:SetSoundfilesFolder("Airboss Soundfiles/")
AirbossStennis:SetTACAN(74, "X", "STN")
AirbossStennis:SetICLS(11, "STN")
AirbossStennis:SetMenuMarkZones(false)
AirbossStennis:SetMenuSmokeZones(false)
AirbossStennis:SetPatrolAdInfinitum(true)
AirbossStennis:Start()

if (loadELINT == true) then
  Elint_blue = HoundElint:create(coalition.side.BLUE)
  Elint_blue:addPlatform("ELINT_1_BLUE")
  Elint_blue:addPlatform("ELINT_2_BLUE")
  Elint_blue:addPlatform("BLUE AWACS OVERLORD")
  Elint_blue:setMarkerType(HOUND.MARKER.POLYGON)
  Elint_blue:enableMarkers()
  atis_args_blue = {
     freq = 260.500,
  }
  controller_args_blue = {
     freq = 260.000,
     modulation = "AM,FM"
  }
  Elint_blue:configureController(controller_args_blue)
  Elint_blue:enableController()
  Elint_blue:disableAtis()
  Elint_blue:systemOn()

  Elint_red = HoundElint:create(coalition.side.RED)
  Elint_red:addPlatform("ELINT_1_RED")
  Elint_red:addPlatform("ELINT_2_RED")
  Elint_red:addPlatform("RED AWACS")
  atis_args_red = {
     freq = 261.500,
  }
  controller_args_red = {
     freq = 261.000,
     modulation = "AM,FM"
  }
  Elint_red:configureController(controller_args_red)
  Elint_red:enableController()
  Elint_red:disableAtis()
  Elint_red:systemOn()
	
  env.info("Dynamic Conflict ELINT loaded ...")
  trigger.action.outText("Dynamic Conflict ELINT loaded ...", 10)
end


-- CONSTANTS *************************************************************************************

CAPTURE_ZONE_NAMES = {"ALPHA", "BRAVO", "CHARLIE", "DELTA", "ECHO", "FOXTROT", "GOLF", "HOTEL", "INDIA", "JULIET"}


RED_AI_CAP = nil
RED_AI_CAP_COVER = nil
BLUE_AI_CAP = nil
BLUE_AI_CAP_COVER = nil
BLUE_CARRIER_PROTECTION = nil
RED_ATTACK_1 = nil
RED_ATTACK_2 = nil
BLUE_ATTACK_1 = nil
BLUE_ATTACK_2 = nil

--BLUE_CARRIER_PROTECTION = SPAWN:New( "BLUE CARRIER PROTECTION"):InitLimit( 1, 0 )
--BLUE_CARRIER_PROTECTION:InitRepeatOnEngineShutDown()
--BLUE_CARRIER_PROTECTION:SpawnScheduled(180,0)

function CaucasusPendulum.redAttack()
	if (RED_ATTACK_1 == nil or RED_ATTACK_1:IsAlive() ~= true) then	
		RED_ATTACK_1 = SPAWN:New( "RED ATTACK 1"):InitLimit( 1, 0 ):InitCleanUp( 45 ):OnSpawnGroup(
				function (capGroup)
					capGroup:HandleEvent(EVENTS.Land)
					function capGroup:OnEventLand(EventData)
					    capGroup:Destroy()
					 end
				end
				)
	--RED_ATTACK_1:InitRepeatOnLanding()
	--RED_ATTACK_1:SpawnScheduled(120,0)
	end
	if (RED_ATTACK_2 == nil or RED_ATTACK_2:IsAlive() ~= true) then	
		RED_ATTACK_2 = SPAWN:New( "RED ATTACK 2"):InitLimit( 1, 0 ):InitCleanUp( 45 ):OnSpawnGroup(
				function (capGroup)
					capGroup:HandleEvent(EVENTS.Land)
					function capGroup:OnEventLand(EventData)
					    capGroup:Destroy()
					 end
				end
				)
	--RED_ATTACK_2:InitRepeatOnLanding()
	--RED_ATTACK_2:SpawnScheduled(120,0)
	end
end

function CaucasusPendulum.blueAttack()
	if (BLUE_ATTACK_1 == nil or BLUE_ATTACK_1:IsAlive() ~= true) then	
		BLUE_ATTACK_1 = SPAWN:New( "BLUE ATTACK 1"):InitLimit( 1, 0 ):InitCleanUp( 45 ):OnSpawnGroup(
				function (capGroup)
					capGroup:HandleEvent(EVENTS.Land)
					function capGroup:OnEventLand(EventData)
					    capGroup:Destroy()
					 end
				end
				):Spawn()
	--BLUE_ATTACK_1:InitRepeatOnLanding()
	--BLUE_ATTACK_1:SpawnScheduled(120,0)
	end
	if (BLUE_ATTACK_2 == nil or BLUE_ATTACK_2:IsAlive() ~= true) then	
		BLUE_ATTACK_2 = SPAWN:New( "BLUE ATTACK 2"):InitLimit( 1, 0 ):InitCleanUp( 45 ):OnSpawnGroup(
				function (capGroup)
					capGroup:HandleEvent(EVENTS.Land)
					function capGroup:OnEventLand(EventData)
					    capGroup:Destroy()
					 end
				end
				):Spawn()
	--BLUE_ATTACK_2:InitRepeatOnLanding()
	--BLUE_ATTACK_2:SpawnScheduled(120,0)
	end
end

BLUE_ATTACK_SCHEDULER = SCHEDULER:New(nil,
	function()
		if (getPlayerCount(coalition.side.BLUE) < 3) then
			CaucasusPendulum.blueAttack()
		end
	end,
	{}, 5, 120, 0.1)

RED_ATTACK_SCHEDULER = SCHEDULER:New(nil,
	function()
		if (getPlayerCount(coalition.side.RED) < 3) then
			CaucasusPendulum.redAttack()
		end
	end,
	{}, 5, 120, 0.1)

BLUE_ATTACK_SCHEDULER:Start()
RED_ATTACK_SCHEDULER:Start()
-- RED CAP ***************************************************************************************

RED_CAP_GROUPS = {"RED CAP MIG-23", "RED CAP SU-30", "RED CAP J-11", "RED CAP JF-17"}
BLUE_CAP_GROUPS = {"BLUE CAP F-15", "BLUE CAP F-16", "BLUE CAP F-18", "BLUE CAP JF-17", "BLUE CAP M-2000C"}

function CaucasusPendulum.redCap()
	if RED_AI_CAP == nil or (RED_AI_CAP:AllOnGround() or (RED_AI_CAP:IsAlive() ~= true)) then	
		RED_AI_CAP = SPAWN
			:New( "RED CAP" )
			:InitCleanUp( 45 )
			:InitRandomizeTemplate(RED_CAP_GROUPS)
			:OnSpawnGroup(
				function (capGroup)
					capGroup:HandleEvent(EVENTS.Land)
					function capGroup:OnEventLand(EventData)
					    capGroup:Destroy()
					 end
				end
				)
			:Spawn()

		-- this is the zone where the AI patrol will loiter
	    local RED_ALERT_PATROL_ZONE = ZONE:New( "RED PATROL LOITER ZONE" )
	    -- here we define the zone where any hostile unit will be engaged
	    local RED_AI_CAP_ENGAGE_ZONE = ZONE_POLYGON:NewFromGroupName( "RED PATROL ENGAGE ZONE")
	    -- here we define parameters for the AI like floor altitude, top altitude, min speed and max speed
	    local RED_AI_CAP_ZONE = AI_CAP_ZONE:New( RED_ALERT_PATROL_ZONE, 5000, 7000, 450, 900 )
	    RED_AI_CAP_ZONE:SetControllable( RED_AI_CAP )
	    RED_AI_CAP_ZONE:SetEngageZone( RED_AI_CAP_ENGAGE_ZONE ) -- Set the Engage Zone. The AI will only engage when the bogeys are within the CapEngageZone.
	    RED_AI_CAP_ZONE:__Start( 1 ) -- They should statup, and start patrolling in the PatrolZone.
	end
end

function CaucasusPendulum.redCas()
	if RED_AI_CAS == nil or (RED_AI_CAS:AllOnGround() or (RED_AI_CAS:IsAlive() ~= true)) then	
		TEAM_RESOURCES[coalition.side.RED] = TEAM_RESOURCES[coalition.side.RED] - PRICE_CASATTACK
		env.info("Spawning RED CAS")
		RED_AI_CAS = SPAWN
			:New( "RED CAS" )
			:InitCleanUp( 45 )
			:OnSpawnGroup(
				function (casGroup)
					local RED_CAS_ENGANGEMENT_ZONE = ZONE:New( "RED CAS ZONE" )
					local RED_CAS_PATROL_ZONE = ZONE:New( "RED PATROL LOITER ZONE" )
					RED_CAS_ZONE = AI_CAS_ZONE:New( RED_CAS_PATROL_ZONE, 500, 2000, 400, 650, RED_CAS_ENGANGEMENT_ZONE )
					RED_CAS_ZONE:SetControllable( casGroup )
					RED_CAS_ZONE:__Start( 1 )
					RED_CAS_ZONE:__Engage( 5, 700, 2000 )
					casGroup:HandleEvent(EVENTS.Land)
					function casGroup:OnEventLand(EventData)
						casGroup:Destroy()
					end
				end
				)
			:Spawn()
		return true
	end
	return false
end

function CaucasusPendulum.blueCas()
	if BLUE_AI_CAS == nil or (BLUE_AI_CAS:AllOnGround() or (BLUE_AI_CAS:IsAlive() ~= true)) then	
		TEAM_RESOURCES[coalition.side.BLUE] = TEAM_RESOURCES[coalition.side.BLUE] - PRICE_CASATTACK
		env.info("Spawning BLUE CAS")
		BLUE_AI_CAS = SPAWN
			:New( "BLUE CAS" )
			:InitCleanUp( 45 )
			:OnSpawnGroup(
				function (casGroup)
		
					local BLUE_CAS_ENGANGEMENT_ZONE = ZONE:New( "BLUE CAS ZONE" )
					local BLUE_CAS_PATROL_ZONE = ZONE:New( "BLUE CAP LOITER ZONE" )
					BLUE_CAS_ZONE = AI_CAS_ZONE:New( BLUE_CAS_PATROL_ZONE, 500, 2000, 400, 650, BLUE_CAS_ENGANGEMENT_ZONE )
					BLUE_CAS_ZONE:SetControllable( casGroup )
					BLUE_CAS_ZONE:__Start( 1 )
					BLUE_CAS_ZONE:__Engage( 5, 700, 2000 )
		
					casGroup:HandleEvent(EVENTS.Land)
					function casGroup:OnEventLand(EventData)
						casGroup:Destroy()
					end
				end
				)
			:Spawn()
		return true
	end
	return false
end



-- RED HELOS ***************************************************************************************

RED_HELO_GROUPS = {"RED HELO KA50"}

function CaucasusPendulum.redHelos()
	if RED_AI_HELO == nil or (RED_AI_HELO:AllOnGround() or (RED_AI_HELO:IsAlive() ~= true)) then	
		env.info("Spawning RED HELO")
		RED_AI_HELO = SPAWN
			:New( "RED HELO KA50" )
			:InitCleanUp( 45 )
			:InitRandomizeTemplate(RED_HELO_GROUPS)
			:OnSpawnGroup(
				function (capGroup)
					capGroup:HandleEvent(EVENTS.Land)
					function capGroup:OnEventLand(EventData)
					    capGroup:Destroy()
					 end
				end
				)
			:Spawn()
	end
end

-- BLUE HELOS ***************************************************************************************

BLUE_HELO_GROUPS = {"BLUE HELO AH64"}

function CaucasusPendulum.blueHelos()
	if BLUE_AI_HELO == nil or (BLUE_AI_HELO:AllOnGround() or (BLUE_AI_HELO:IsAlive() ~= true)) then	
		env.info("Spawning BLUE HELO")
		BLUE_AI_HELO = SPAWN
			:New( "BLUE HELO AH64" )
			:InitCleanUp( 45 )
			:InitRandomizeTemplate(BLUE_HELO_GROUPS)
			:OnSpawnGroup(
				function (capGroup)
					capGroup:HandleEvent(EVENTS.Land)
					function capGroup:OnEventLand(EventData)
					    capGroup:Destroy()
					 end
				end
				)
			:Spawn()
	end
end

-- RED INTERCEPTOR ***************************************************************************************

RedDetectionSetGroup = SET_GROUP:New()
RedDetectionSetGroup:FilterPrefixes( { "RED AWACS" } )
RedDetectionSetGroup:FilterStart()

RedDetection = DETECTION_AREAS:New( RedDetectionSetGroup, 30000 )

RedGciDispatcher = AI_A2A_DISPATCHER:New( RedDetection )

RedGciZone = ZONE:New( "RED INTERCEPTOR ENGAGE ZONE" )

RedGciDispatcher:SetBorderZone( RedGciZone )
RedGciDispatcher:SetEngageRadius( 200000 )

RedGciDispatcher:SetSquadron( "RED GCI", AIRBASE.Caucasus.Maykop_Khanskaya, { "RED INTERCEPTOR MIG-25", "RED INTERCEPTOR MIG-31" } )
RedGciDispatcher:SetSquadronTakeoff( "RED GCI", AI_A2A_DISPATCHER.Takeoff.Air )
RedGciDispatcher:SetSquadronLanding( "RED GCI", AI_A2A_DISPATCHER.Landing.NearAirbase )
RedGciDispatcher:SetDefaultCapTimeInterval( 300, 1200 )
RedGciDispatcher:SetSquadronGci( "RED GCI", 900, 1200 )

-- BLUE CAP ***************************************************************************************

function CaucasusPendulum.blueCap()
	if BLUE_AI_CAP == nil or (BLUE_AI_CAP:AllOnGround() or (BLUE_AI_CAP:IsAlive() ~= true)) then
		BLUE_AI_CAP = SPAWN
			:New( "BLUE CAP" )
			:InitRandomizeTemplate(BLUE_CAP_GROUPS)
			:InitCleanUp( 45 )
			:OnSpawnGroup(
				function (capGroup)
					capGroup:HandleEvent(EVENTS.Land)
					function capGroup:OnEventLand(EventData)
					    capGroup:Destroy()
					 end
				end
				)
			:Spawn()
		-- this is the zone where the AI patrol will loiter
	    local BLUE_ALERT_PATROL_ZONE = ZONE:New( "BLUE CAP LOITER ZONE" )
	    -- here we define the zone where any hostile unit will be engaged
	    local BLUE_AI_CAP_ENGAGE_ZONE = ZONE_POLYGON:NewFromGroupName( "BLUE CAP ENGAGE ZONE")
	    -- here we define parameters for the AI like floor altitude, top altitude, min speed and max speed
	    local BLUE_AI_CAP_ZONE = AI_CAP_ZONE:New( BLUE_ALERT_PATROL_ZONE, 6000, 10000, 400, 850 )
	    BLUE_AI_CAP_ZONE:SetControllable( BLUE_AI_CAP )
	    BLUE_AI_CAP_ZONE:SetEngageZone( BLUE_AI_CAP_ENGAGE_ZONE ) -- Set the Engage Zone. The AI will only engage when the bogeys are within the CapEngageZone.
	    BLUE_AI_CAP_ZONE:__Start( 1 ) -- They should statup, and start patrolling in the PatrolZone.
	end
end

RED_CAP_SCHEDULER = SCHEDULER:New(nil,
	function()
		if (getPlayerCount(coalition.side.RED) < 5) then
			CaucasusPendulum.redCap()
		end
	end,
	{}, 5, 300, 0.1)

RED_CAS_SCHEDULER = SCHEDULER:New(nil,
	function()
		if (getPlayerCount(coalition.side.RED) < 1 and getPlayerCount(coalition.side.BLUE) > 0) then
			CaucasusPendulum.redCas()
		end
	end,
	{}, 5, 300, 0.1)

RED_HELO_SCHEDULER = SCHEDULER:New(nil,
	function()
		CaucasusPendulum.redHelos()
	end,
	{}, 5, 300, 0.1)


RED_INTERCEPTOR_SCHEDULER = SCHEDULER:New(nil,
	function()
		env.info("Checking for GCI")
		local redInterceptorZone = ZONE:New( "RED INTERCEPTOR ENGAGE ZONE" )
		local redInterceptorZoneRadius = ZONE_RADIUS:New("RED INTERCEPTOR ENGAGE ZONE", redInterceptorZone:GetVec2(), 7500)
		redInterceptorZoneRadius:Scan( Object.Category.UNIT, { Unit.Category.AIRPLANE, Unit.Category.HELICOPTER } )
		local isVitalRedZoneAttacked = redInterceptorZoneRadius:IsSomeInZoneOfCoalition( coalition.side.BLUE )
		if isVitalRedZoneAttacked then
			if (getPlayerCount(coalition.side.RED) < 3) then
				env.info("GCI active!")
				CaucasusPendulum.redInterceptor()
			end
		end
	end,
	{}, 5, 300, 0.1)

BLUE_CAP_SCHEDULER = SCHEDULER:New(nil,
	function()
		if (getPlayerCount(coalition.side.BLUE) < 5) then
			CaucasusPendulum.blueCap()
		end
	end,
	{}, 5, 300, 0.1)

BLUE_CAS_SCHEDULER = SCHEDULER:New(nil,
	function()
		if (getPlayerCount(coalition.side.BLUE) < 1 and getPlayerCount(coalition.side.RED) > 0) then
			CaucasusPendulum.blueCas()
		end
	end,
	{}, 5, 300, 0.1)


BLUE_HELO_SCHEDULER = SCHEDULER:New(nil,
	function()
		CaucasusPendulum.blueHelos()
	end,
	{}, 5, 300, 0.1)

RED_CAP_SCHEDULER:Start()
--RED_CAS_SCHEDULER:Start()
BLUE_CAP_SCHEDULER:Start()
--BLUE_CAS_SCHEDULER:Start()
RED_HELO_SCHEDULER:Start()
BLUE_HELO_SCHEDULER:Start()

-- END ***************************************************************************************

env.info("Caucasus Pendulum CAP loaded ...")
trigger.action.outText("Caucasus Pendulum CAP loaded ...", 10)



-- CAP speeds
CaucasusPendulum.minInterceptSpeed = 650
CaucasusPendulum.maxInterceptSpeed = 900


-- SAM SPAWNING ***************************************************************************************



FARP_MOSCOW_SAM = SPAWN
	:New( "FARP MOSCOW SAM" )
	:InitLimit(12,0)
	:SpawnScheduled(500, 1)

FARP_TORBA_SAM = SPAWN
	:New( "FARP TORBA SAM" )
	:InitLimit(12,0)
	:SpawnScheduled(500, 1)

-- RED SAMS
--RedSochiSA6SpawnZones = { 
--	ZONE:FindByName( "RED SOCHI SA6 SPAWN ZONE1" ), 
--	ZONE:FindByName( "RED SOCHI SA6 SPAWN ZONE2" ),
--	ZONE:FindByName( "RED SOCHI SA6 SPAWN ZONE3" ),
--	ZONE:FindByName( "RED SOCHI SA6 SPAWN ZONE4" ),
--	ZONE:FindByName( "RED SOCHI SA6 SPAWN ZONE5" ),
--	ZONE:FindByName( "RED SOCHI SA6 SPAWN ZONE6" )}
--RED_SOCHI_SA6 = SPAWN
--	:New( "RED SOCHI SA6" )
--	:InitLimit(8,0)
----	:InitRandomizeZones( RedSochiSA6SpawnZones )
--	:SpawnScheduled(600, 1)

-- BLUE SAMS
FARP_DUBLIN_SAM = SPAWN
	:New( "FARP DUBLIN SAM" )
	:InitLimit(12,0)
	:SpawnScheduled(500, 1)

FARP_MADRID_SAM = SPAWN
	:New( "FARP MADRID SAM" )
	:InitLimit(12,0)
	:SpawnScheduled(500, 1)

env.info("Dynamic Conflict SAM SPAWNING loaded ...")
trigger.action.outText("Dynamic Conflict SAM SPAWNING loaded ...", 10)


-- AWACS ***************************************************************************************

BLUE_AWACS = SPAWN
	:New( "BLUE AWACS OVERLORD" )
	:InitLimit(1,0)
	:InitCleanUp( 45 )
	:OnSpawnGroup(
		function(MooseGroup)
			if (loadELINT == true) then
				Elint_blue:addPlatform("BLUE AWACS OVERLORD")
			end
			MooseGroup:HandleEvent(EVENTS.Land)

			function MooseGroup:OnEventLand(EventData)
		        MooseGroup:Destroy()
		    end
		end
	)
	:SpawnScheduled(900, 1)

RED_AWACS = SPAWN
	:New( "RED AWACS" )
	:InitLimit(1,0)
	:InitCleanUp( 45 )
	:OnSpawnGroup(
		function(MooseGroup)
			if (loadELINT == true) then
				Elint_red:addPlatform("RED AWACS")
			end
			MooseGroup:HandleEvent(EVENTS.Land)

			function MooseGroup:OnEventLand(EventData)
		        MooseGroup:Destroy()
		    end
		end)
	:SpawnScheduled(900, 1)

-- FAC ***************************************************************************************

-- POINTER FAC
BLUE_FAC_POINTER = SPAWN
	:New("BLUE FAC POINTER")
	:InitLimit(1, 0)
	:OnSpawnGroup(
		function (facGroup) 
		  
			ctld.JTACAutoLase(facGroup:GetName(), 1651, false, "vehicle")
			env.info("JTAC START " .. facGroup:GetName())
			trigger.action.outTextForCoalition(2, "POINTER heading to Gali", 10)
			trigger.action.outSoundForCoalition(2, "walkietalkie.ogg" )
			 
			facGroup:HandleEvent(EVENTS.Dead)
			facGroup:HandleEvent(EVENTS.Land)
			 
			function facGroup:OnEventDead(EventData)
			   ctld.JTACAutoLaseStop(EventData.IniGroupName)
			   env.info("JTAC STOP " .. EventData.IniGroupName) 
			end

			function facGroup:OnEventLand(EventData)
		       facGroup:Destroy()
		    end
		end)
	:SpawnScheduled(120, 1)

 -- AXEMAN FAC
BLUE_FAC_AXEMAN = SPAWN
	:New("BLUE FAC AXEMAN")
	:InitLimit(1, 0)
	:OnSpawnGroup(
	function (facGroup) 
	    
	   ctld.JTACAutoLase(facGroup:GetName(), 1652, false, "vehicle")
	   env.info("JTAC START " .. facGroup:GetName()) 
	   trigger.action.outTextForCoalition(2, "AXEMAN heading to Sukhumi", 10)
	   trigger.action.outSoundForCoalition(2, "walkietalkie.ogg" )
	    
	   facGroup:HandleEvent(EVENTS.Dead)
	   facGroup:HandleEvent(EVENTS.Land)
	    
	   function facGroup:OnEventDead(EventData)
	      ctld.JTACAutoLaseStop(EventData.IniGroupName)
	      env.info("JTAC STOP " .. EventData.IniGroupName) 
	   end

	   function facGroup:OnEventLand(EventData)
            facGroup:Destroy()
         end
	end)

env.info("Dynamic Conflict JTAC loaded ...")
trigger.action.outText("Dynamic Conflict JTAC loaded ...", 10)

RED_COMMAND_ZONES = { 
	ZONE:FindByName( "RED COMMAND ZONE" )}

function CaucasusPendulum.spawnRedCommandPost()
	RED_COMMAND = SPAWN
		:New( "RED COMMAND POST" )
		:InitRandomizeZones( RED_COMMAND_ZONES )
		:OnSpawnGroup(
		function( MooseGroup )
		  local MooseGroupCoordinate = MooseGroup:GetCoordinate()
		  local markId = MooseGroupCoordinate:MarkToAll("Red Command Post\nBLUE: Attack\nRED: Protect", true, nil)
		  CaucasusPendulum.mapMarkRedBarracks = markId

		  RED_ATTACK_ENABLED = true
		  RED_CAP_SCHEDULER:Start()
		  trigger.action.outText("RED Command Post repaired, see map.", 10)
		  trigger.action.outSound("walkietalkie.ogg" )

		  MooseGroup:HandleEvent(EVENTS.Dead)

		 function MooseGroup:OnEventDead(EventData)
		 	if RED_COMMAND:GetSize() == 4 then
		 		trigger.action.removeMark( CaucasusPendulum.mapMarkRedBarracks )
				RED_ATTACK_ENABLED = false
				RED_CAP_SCHEDULER:Stop()
			 	RED_COMMAND:Destroy( false )
			 	trigger.action.outText("RED Command Post attacked, no red reinforcements for 2 hours.", 10)
			    trigger.action.outSound("walkietalkie.ogg" )
			    timer.scheduleFunction(CaucasusPendulum.spawnRedCommandPost, {}, timer.getTime() + (2*60*60))
		 	end
		  end
		end)
		:Spawn()
end

CaucasusPendulum.spawnRedCommandPost()


BLUE_COMMAND_ZONES = { 
	ZONE:FindByName( "BLUE COMMAND ZONE" )}

function CaucasusPendulum.spawnBlueCommandPost()
	BLUE_COMMAND = SPAWN
		:New( "BLUE COMMAND POST" )
		:InitRandomizeZones( BLUE_COMMAND_ZONES )
		:OnSpawnGroup(
		function( MooseGroup )
		  local MooseGroupCoordinate = MooseGroup:GetCoordinate()
		  local markId = MooseGroupCoordinate:MarkToAll("Blue Command Post\nBLUE: Protect\nRED: Attack", true, nil)
		  CaucasusPendulum.mapMarkBlueBarracks = markId

		  BLUE_ATTACK_ENABLED = true
		  BLUE_CAP_SCHEDULER:Start()
		  trigger.action.outText("BLUE Command Post repaired, see map.", 10)
		  trigger.action.outSound("walkietalkie.ogg" )

		  MooseGroup:HandleEvent(EVENTS.Dead)

		 function MooseGroup:OnEventDead(EventData)
		 	if BLUE_COMMAND:GetSize() == 4 then
		 		trigger.action.removeMark( CaucasusPendulum.mapMarkBlueBarracks )
				BLUE_ATTACK_ENABLED = false
				BLUE_CAP_SCHEDULER:Stop()
			 	BLUE_COMMAND:Destroy( false )
			 	trigger.action.outText("BLUE Command Post attacked, no blue reinforcements for 2 hours.", 10)
			    trigger.action.outSound("walkietalkie.ogg" )
			    timer.scheduleFunction(CaucasusPendulum.spawnBlueCommandPost, {}, timer.getTime() + (2*60*60))
		 	end
		  end
		end)
		:Spawn()
end

CaucasusPendulum.spawnBlueCommandPost()



if (CAPZONE_STATUS.MIKE == coalition.side.RED) then
	trigger.action.setUserFlag("BLUE PLAYER SA342M KUTAISI", 100)
	trigger.action.setUserFlag("BLUE PLAYER SA342Mistral KUTAISI", 100)
	trigger.action.setUserFlag("BLUE PLAYER KA50 KUTAISI", 100)
	trigger.action.setUserFlag("BLUE PLAYER M2000 KUTAISI", 100)
	trigger.action.setUserFlag("BLUE PLAYER AV8B KUTAISI", 100)
	trigger.action.setUserFlag("BLUE PLAYER F16 KUTAISI", 100)
	trigger.action.setUserFlag("BLUE PLAYER A10CII KUTAISI", 100)
	trigger.action.setUserFlag("BLUE PLAYER MIG21Bis KUTAISI", 100)
	trigger.action.setUserFlag("BLUE PLAYER F5 KUTAISI", 100)
	trigger.action.setUserFlag("BLUE PLAYER F/A-18C KUTAISI", 100)
	trigger.action.setUserFlag("RED PLAYER SU33 KUTAISI", 0)
	trigger.action.setUserFlag("RED PLAYER JF17 KUTAISI", 0)
	trigger.action.setUserFlag("RED PLAYER M2000 KUTAISI", 0)
	trigger.action.setUserFlag("RED PLAYER SA342M KUTAISI", 0)
	trigger.action.setUserFlag("RED PLAYER SA342Mistral KUTAISI", 0)
	trigger.action.setUserFlag("RED PLAYER KA50 KUTAISI", 0)
else
	trigger.action.setUserFlag("BLUE PLAYER SA342M KUTAISI", 0)
	trigger.action.setUserFlag("BLUE PLAYER SA342Mistral KUTAISI", 0)
	trigger.action.setUserFlag("BLUE PLAYER KA50 KUTAISI", 0)
	trigger.action.setUserFlag("BLUE PLAYER M2000 KUTAISI", 0)
	trigger.action.setUserFlag("BLUE PLAYER AV8B KUTAISI", 0)
	trigger.action.setUserFlag("BLUE PLAYER F16 KUTAISI", 0)
	trigger.action.setUserFlag("BLUE PLAYER A10CII KUTAISI", 0)
	trigger.action.setUserFlag("BLUE PLAYER MIG21Bis KUTAISI", 0)
	trigger.action.setUserFlag("BLUE PLAYER F5 KUTAISI", 0)
	trigger.action.setUserFlag("BLUE PLAYER F/A-18C KUTAISI", 0)
	trigger.action.setUserFlag("RED PLAYER SU33 KUTAISI", 100)
	trigger.action.setUserFlag("RED PLAYER JF17 KUTAISI", 100)
	trigger.action.setUserFlag("RED PLAYER M2000 KUTAISI", 100)
	trigger.action.setUserFlag("RED PLAYER SA342M KUTAISI", 100)
	trigger.action.setUserFlag("RED PLAYER SA342Mistral KUTAISI", 100)
	trigger.action.setUserFlag("RED PLAYER KA50 KUTAISI", 100)
end


if (CAPZONE_STATUS.PAPA == coalition.side.RED) then
	trigger.action.setUserFlag("BLUE PLAYER AJS37 KOBULETI", 100)
	trigger.action.setUserFlag("BLUE PLAYER F15C KOBULETI", 100)
	trigger.action.setUserFlag("BLUE PLAYER A10A KOBULETI", 100)
	trigger.action.setUserFlag("BLUE PLAYER A10C II KOBULETI", 100)
	trigger.action.setUserFlag("RED PLAYER AJS37 KOBULETI", 0)
	trigger.action.setUserFlag("RED PLAYER SU25T KOBULETI", 0)
else
	trigger.action.setUserFlag("BLUE PLAYER AJS37 KOBULETI", 0)
	trigger.action.setUserFlag("BLUE PLAYER F15C KOBULETI", 0)
	trigger.action.setUserFlag("BLUE PLAYER A10A KOBULETI", 0)
	trigger.action.setUserFlag("BLUE PLAYER A10C II KOBULETI", 0)
	trigger.action.setUserFlag("RED PLAYER AJS37 KOBULETI", 100)
	trigger.action.setUserFlag("RED PLAYER SU25T KOBULETI", 100)
end

if (CAPZONE_STATUS.VICTOR == coalition.side.RED) then
	trigger.action.setUserFlag("BLUE PLAYER F16C SUKHUMI", 100)
	trigger.action.setUserFlag("RED PLAYER F16C SUKHUMI", 0)
	trigger.action.setUserFlag("RED PLAYER AV-8B SUKHUMI", 0)
else
	trigger.action.setUserFlag("BLUE PLAYER F16C SUKHUMI", 0)
	trigger.action.setUserFlag("RED PLAYER F16C SUKHUMI", 100)
	trigger.action.setUserFlag("RED PLAYER AV-8B SUKHUMI", 100)
end

fillcolor = {}
fillcolor[coalition.side.BLUE] = {0,0,1,0.2}
fillcolor[coalition.side.RED] = {1,0,0,0.2}
linecolor = {}
linecolor[coalition.side.BLUE] = {0,0,1,0.5}
linecolor[coalition.side.RED] = {1,0,0,0.5}

ZoneID = {}

-- Persistence: Define Capture Zones
AlphaZone = ZONE:FindByName( "ALPHA ZONE" )
ZoneID["ALPHA ZONE"] = UTILS.GetMarkID()
AlphaCaptureZone = ZONE_CAPTURE_COALITION:New( AlphaZone, CAPZONE_STATUS.ALPHA )
AlphaCaptureZone:__Guard( 1 )
AlphaCaptureZone:Start( 30, 120 )
trigger.action.circleToAll(-1, ZoneID["ALPHA ZONE"], AlphaZone:GetVec3(0), 5000, linecolor[CAPZONE_STATUS.ALPHA],fillcolor[CAPZONE_STATUS.ALPHA], 2, true)

BravoZone = ZONE:FindByName( "BRAVO ZONE" )
ZoneID["BRAVO ZONE"] = UTILS.GetMarkID()
BravoCaptureZone = ZONE_CAPTURE_COALITION:New( BravoZone, CAPZONE_STATUS.BRAVO )
BravoCaptureZone:__Guard( 1 )
BravoCaptureZone:Start( 30, 120 )
trigger.action.circleToAll(-1, ZoneID["BRAVO ZONE"], BravoZone:GetVec3(0), 5000, linecolor[CAPZONE_STATUS.BRAVO],fillcolor[CAPZONE_STATUS.BRAVO], 2, true)

CharlieZone = ZONE:FindByName( "CHARLIE ZONE" )
ZoneID["CHARLIE ZONE"] = UTILS.GetMarkID()
CharlieCaptureZone = ZONE_CAPTURE_COALITION:New( CharlieZone, CAPZONE_STATUS.CHARLIE )
CharlieCaptureZone:__Guard( 1 )
CharlieCaptureZone:Start( 30, 120 )
trigger.action.circleToAll(-1, ZoneID["CHARLIE ZONE"], CharlieZone:GetVec3(0), 5000, linecolor[CAPZONE_STATUS.CHARLIE],fillcolor[CAPZONE_STATUS.CHARLIE], 2, true)

DeltaZone = ZONE:FindByName( "DELTA ZONE" )
ZoneID["DELTA ZONE"] = UTILS.GetMarkID()
DeltaCaptureZone = ZONE_CAPTURE_COALITION:New( DeltaZone, CAPZONE_STATUS.DELTA )
DeltaCaptureZone:__Guard( 1 )
DeltaCaptureZone:Start( 30, 120 )
trigger.action.circleToAll(-1, ZoneID["DELTA ZONE"], DeltaZone:GetVec3(0), 5000, linecolor[CAPZONE_STATUS.DELTA],fillcolor[CAPZONE_STATUS.DELTA], 2, true)

EchoZone = ZONE:FindByName( "ECHO ZONE" )
ZoneID["ECHO ZONE"] = UTILS.GetMarkID()
EchoCaptureZone = ZONE_CAPTURE_COALITION:New( EchoZone, CAPZONE_STATUS.ECHO )
EchoCaptureZone:__Guard( 1 )
EchoCaptureZone:Start( 30, 120 )
trigger.action.circleToAll(-1, ZoneID["ECHO ZONE"], EchoZone:GetVec3(0), 5000, linecolor[CAPZONE_STATUS.ECHO],fillcolor[CAPZONE_STATUS.ECHO], 2, true)

FoxtrotZone = ZONE:FindByName( "FOXTROT ZONE" )
ZoneID["FOXTROT ZONE"] = UTILS.GetMarkID()
FoxtrotCaptureZone = ZONE_CAPTURE_COALITION:New( FoxtrotZone, CAPZONE_STATUS.FOXTROT )
FoxtrotCaptureZone:__Guard( 1 )
FoxtrotCaptureZone:Start( 30, 120 )
trigger.action.circleToAll(-1, ZoneID["FOXTROT ZONE"], FoxtrotZone:GetVec3(0), 5000, linecolor[CAPZONE_STATUS.FOXTROT],fillcolor[CAPZONE_STATUS.FOXTROT], 2, true)

GolfZone = ZONE:FindByName( "GOLF ZONE" )
ZoneID["GOLF ZONE"] = UTILS.GetMarkID()
GolfCaptureZone = ZONE_CAPTURE_COALITION:New( GolfZone, CAPZONE_STATUS.GOLF )
GolfCaptureZone:__Guard( 1 )
GolfCaptureZone:Start( 30, 120 )
trigger.action.circleToAll(-1, ZoneID["GOLF ZONE"], GolfZone:GetVec3(0), 5000, linecolor[CAPZONE_STATUS.GOLF],fillcolor[CAPZONE_STATUS.GOLF], 2, true)

HotelZone = ZONE:FindByName( "HOTEL ZONE" )
ZoneID["HOTEL ZONE"] = UTILS.GetMarkID()
HotelCaptureZone = ZONE_CAPTURE_COALITION:New( HotelZone, CAPZONE_STATUS.HOTEL )
HotelCaptureZone:__Guard( 1 )
HotelCaptureZone:Start( 30, 120 )
trigger.action.circleToAll(-1, ZoneID["HOTEL ZONE"], HotelZone:GetVec3(0), 5000, linecolor[CAPZONE_STATUS.HOTEL],fillcolor[CAPZONE_STATUS.HOTEL], 2, true)

IndiaZone = ZONE:FindByName( "INDIA ZONE" )
ZoneID["INDIA ZONE"] = UTILS.GetMarkID()
IndiaCaptureZone = ZONE_CAPTURE_COALITION:New( IndiaZone, CAPZONE_STATUS.INDIA )
IndiaCaptureZone:__Guard( 1 )
IndiaCaptureZone:Start( 30, 120 )
trigger.action.circleToAll(-1, ZoneID["INDIA ZONE"], IndiaZone:GetVec3(0), 5000, linecolor[CAPZONE_STATUS.INDIA],fillcolor[CAPZONE_STATUS.INDIA], 2, true)

JulietZone = ZONE:FindByName( "JULIET ZONE" )
ZoneID["JULIET ZONE"] = UTILS.GetMarkID()
JulietCaptureZone = ZONE_CAPTURE_COALITION:New( JulietZone, CAPZONE_STATUS.JULIET )
JulietCaptureZone:__Guard( 1 )
JulietCaptureZone:Start( 30, 120 )
trigger.action.circleToAll(-1, ZoneID["JULIET ZONE"], JulietZone:GetVec3(0), 5000, linecolor[CAPZONE_STATUS.JULIET],fillcolor[CAPZONE_STATUS.JULIET], 2, true)

KiloZone = ZONE:FindByName( "KILO ZONE" )
ZoneID["KILO ZONE"] = UTILS.GetMarkID()
KiloCaptureZone = ZONE_CAPTURE_COALITION:New( KiloZone, CAPZONE_STATUS.KILO )
KiloCaptureZone:__Guard( 1 )
KiloCaptureZone:Start( 30, 120 )
trigger.action.circleToAll(-1, ZoneID["KILO ZONE"], KiloZone:GetVec3(0), 5000, linecolor[CAPZONE_STATUS.KILO],fillcolor[CAPZONE_STATUS.KILO], 2, true)

LimaZone = ZONE:FindByName( "LIMA ZONE" )
ZoneID["LIMA ZONE"] = UTILS.GetMarkID()
LimaCaptureZone = ZONE_CAPTURE_COALITION:New( LimaZone, CAPZONE_STATUS.LIMA )
LimaCaptureZone:__Guard( 1 )
LimaCaptureZone:Start( 30, 120 )
trigger.action.circleToAll(-1, ZoneID["LIMA ZONE"], LimaZone:GetVec3(0), 5000, linecolor[CAPZONE_STATUS.LIMA],fillcolor[CAPZONE_STATUS.LIMA], 2, true)

MikeZone = ZONE:FindByName( "MIKE ZONE" )
ZoneID["MIKE ZONE"] = UTILS.GetMarkID()
MikeCaptureZone = ZONE_CAPTURE_COALITION:New( MikeZone, CAPZONE_STATUS.MIKE )
MikeCaptureZone:__Guard( 1 )
MikeCaptureZone:Start( 30, 120 )
trigger.action.circleToAll(-1, ZoneID["MIKE ZONE"], MikeZone:GetVec3(0), 5000, linecolor[CAPZONE_STATUS.MIKE],fillcolor[CAPZONE_STATUS.MIKE], 2, true)

NovemberZone = ZONE:FindByName( "NOVEMBER ZONE" )
ZoneID["NOVEMBER ZONE"] = UTILS.GetMarkID()
NovemberCaptureZone = ZONE_CAPTURE_COALITION:New( NovemberZone, CAPZONE_STATUS.NOVEMBER )
NovemberCaptureZone:__Guard( 1 )
NovemberCaptureZone:Start( 30, 120 )
trigger.action.circleToAll(-1, ZoneID["NOVEMBER ZONE"], NovemberZone:GetVec3(0), 5000, linecolor[CAPZONE_STATUS.NOVEMBER],fillcolor[CAPZONE_STATUS.NOVEMBER], 2, true)

OscarZone = ZONE:FindByName( "OSCAR ZONE" )
ZoneID["OSCAR ZONE"] = UTILS.GetMarkID()
OscarCaptureZone = ZONE_CAPTURE_COALITION:New( OscarZone, CAPZONE_STATUS.OSCAR )
OscarCaptureZone:__Guard( 1 )
OscarCaptureZone:Start( 30, 120 )
trigger.action.circleToAll(-1, ZoneID["OSCAR ZONE"], OscarZone:GetVec3(0), 5000, linecolor[CAPZONE_STATUS.OSCAR],fillcolor[CAPZONE_STATUS.OSCAR], 2, true)

PapaZone = ZONE:FindByName( "PAPA ZONE" )
ZoneID["PAPA ZONE"] = UTILS.GetMarkID()
PapaCaptureZone = ZONE_CAPTURE_COALITION:New( PapaZone, CAPZONE_STATUS.PAPA )
PapaCaptureZone:__Guard( 1 )
PapaCaptureZone:Start( 30, 120 )
trigger.action.circleToAll(-1, ZoneID["PAPA ZONE"], PapaZone:GetVec3(0), 5000, linecolor[CAPZONE_STATUS.PAPA],fillcolor[CAPZONE_STATUS.PAPA], 2, true)

QuebecZone = ZONE:FindByName( "QUEBEC ZONE" )
ZoneID["QUEBEC ZONE"] = UTILS.GetMarkID()
QuebecCaptureZone = ZONE_CAPTURE_COALITION:New( QuebecZone, CAPZONE_STATUS.QUEBEC )
QuebecCaptureZone:__Guard( 1 )
QuebecCaptureZone:Start( 30, 120 )
trigger.action.circleToAll(-1, ZoneID["QUEBEC ZONE"], QuebecZone:GetVec3(0), 5000, linecolor[CAPZONE_STATUS.QUEBEC],fillcolor[CAPZONE_STATUS.QUEBEC], 2, true)

RomeoZone = ZONE:FindByName( "ROMEO ZONE" )
ZoneID["ROMEO ZONE"] = UTILS.GetMarkID()
RomeoCaptureZone = ZONE_CAPTURE_COALITION:New( RomeoZone, CAPZONE_STATUS.ROMEO )
RomeoCaptureZone:__Guard( 1 )
RomeoCaptureZone:Start( 30, 120 )
trigger.action.circleToAll(-1, ZoneID["ROMEO ZONE"], RomeoZone:GetVec3(0), 5000, linecolor[CAPZONE_STATUS.ROMEO],fillcolor[CAPZONE_STATUS.ROMEO], 2, true)

SierraZone = ZONE:FindByName( "SIERRA ZONE" )
ZoneID["SIERRA ZONE"] = UTILS.GetMarkID()
SierraCaptureZone = ZONE_CAPTURE_COALITION:New( SierraZone, CAPZONE_STATUS.SIERRA )
SierraCaptureZone:__Guard( 1 )
SierraCaptureZone:Start( 30, 120 )
trigger.action.circleToAll(-1, ZoneID["SIERRA ZONE"], SierraZone:GetVec3(0), 5000, linecolor[CAPZONE_STATUS.SIERRA],fillcolor[CAPZONE_STATUS.SIERRA], 2, true)

TangoZone = ZONE:FindByName( "TANGO ZONE" )
ZoneID["TANGO ZONE"] = UTILS.GetMarkID()
TangoCaptureZone = ZONE_CAPTURE_COALITION:New( TangoZone, CAPZONE_STATUS.TANGO )
TangoCaptureZone:__Guard( 1 )
TangoCaptureZone:Start( 30, 120 )
trigger.action.circleToAll(-1, ZoneID["TANGO ZONE"], TangoZone:GetVec3(0), 5000, linecolor[CAPZONE_STATUS.TANGO],fillcolor[CAPZONE_STATUS.TANGO], 2, true)

UniformZone = ZONE:FindByName( "UNIFORM ZONE" )
ZoneID["UNIFORM ZONE"] = UTILS.GetMarkID()
UniformCaptureZone = ZONE_CAPTURE_COALITION:New( UniformZone, CAPZONE_STATUS.UNIFORM )
UniformCaptureZone:__Guard( 1 )
UniformCaptureZone:Start( 30, 120 )
trigger.action.circleToAll(-1, ZoneID["UNIFORM ZONE"], UniformZone:GetVec3(0), 5000, linecolor[CAPZONE_STATUS.UNIFORM],fillcolor[CAPZONE_STATUS.UNIFORM], 2, true)

VictorZone = ZONE:FindByName( "VICTOR ZONE" )
ZoneID["VICTOR ZONE"] = UTILS.GetMarkID()
VictorCaptureZone = ZONE_CAPTURE_COALITION:New( VictorZone, CAPZONE_STATUS.VICTOR )
VictorCaptureZone:__Guard( 1 )
VictorCaptureZone:Start( 30, 120 )
trigger.action.circleToAll(-1, ZoneID["VICTOR ZONE"], VictorZone:GetVec3(0), 5000, linecolor[CAPZONE_STATUS.VICTOR],fillcolor[CAPZONE_STATUS.VICTOR], 2, true)

WhiskeyZone = ZONE:FindByName( "WHISKEY ZONE" )
ZoneID["WHISKEY ZONE"] = UTILS.GetMarkID()
WhiskeyCaptureZone = ZONE_CAPTURE_COALITION:New( WhiskeyZone, CAPZONE_STATUS.WHISKEY )
WhiskeyCaptureZone:__Guard( 1 )
WhiskeyCaptureZone:Start( 30, 120 )
trigger.action.circleToAll(-1, ZoneID["WHISKEY ZONE"], WhiskeyZone:GetVec3(0), 5000, linecolor[CAPZONE_STATUS.WHISKEY],fillcolor[CAPZONE_STATUS.WHISKEY], 2, true)

XrayZone = ZONE:FindByName( "XRAY ZONE" )
ZoneID["XRAY ZONE"] = UTILS.GetMarkID()
XrayCaptureZone = ZONE_CAPTURE_COALITION:New( XrayZone, CAPZONE_STATUS.XRAY )
XrayCaptureZone:__Guard( 1 )
XrayCaptureZone:Start( 30, 120 )
trigger.action.circleToAll(-1, ZoneID["XRAY ZONE"], XrayZone:GetVec3(0), 5000, linecolor[CAPZONE_STATUS.XRAY],fillcolor[CAPZONE_STATUS.XRAY], 2, true)

YankeeZone = ZONE:FindByName( "YANKEE ZONE" )
ZoneID["YANKEE ZONE"] = UTILS.GetMarkID()
YankeeCaptureZone = ZONE_CAPTURE_COALITION:New( YankeeZone, CAPZONE_STATUS.YANKEE )
YankeeCaptureZone:__Guard( 1 )
YankeeCaptureZone:Start( 30, 120 )
trigger.action.circleToAll(-1, ZoneID["YANKEE ZONE"], YankeeZone:GetVec3(0), 5000, linecolor[CAPZONE_STATUS.YANKEE],fillcolor[CAPZONE_STATUS.YANKEE], 2, true)

ZuluZone = ZONE:FindByName( "ZULU ZONE" )
ZoneID["ZULU ZONE"] = UTILS.GetMarkID()
ZuluCaptureZone = ZONE_CAPTURE_COALITION:New( ZuluZone, CAPZONE_STATUS.ZULU )
ZuluCaptureZone:__Guard( 1 )
ZuluCaptureZone:Start( 30, 120 )
trigger.action.circleToAll(-1, ZoneID["ZULU ZONE"], ZuluZone:GetVec3(0), 5000, linecolor[CAPZONE_STATUS.ZULU],fillcolor[CAPZONE_STATUS.ZULU], 2, true)

RedCommandZone = ZONE:FindByName( "RED COMMAND ZONE" )
BlueCommandZone = ZONE:FindByName( "BLUE COMMAND ZONE" )


-- Persistence Scheduler
timer.scheduleFunction(CaucasusPendulum.SEF_SaveCaptureZoneTable, {}, timer.getTime() + SaveScheduleUnits)


function CaucasusPendulum.AttackScheduler(timeloop, time)
  if (getPlayerCount(coalition.side.RED) == 0 and getPlayerCount(coalition.side.BLUE) > 0 and RED_ATTACK_ENABLED == true) then
	env.info("RED GROUND ATTACK initiated")
	RedAttackInterval = RedAttackIntervalSlow
	if (CAPZONE_STATUS.YANKEE == coalition.side.BLUE and CAPZONE_STATUS.ZULU == coalition.side.RED) then
		CaucasusPendulum.SpawnAttack("YANKEE", "ZULU", "RED", true)
	end
	if (CAPZONE_STATUS.XRAY == coalition.side.BLUE and CAPZONE_STATUS.YANKEE == coalition.side.RED) then
		CaucasusPendulum.SpawnAttack("XRAY", "YANKEE", "RED", true)
	end
	if (CAPZONE_STATUS.WHISKEY == coalition.side.BLUE and CAPZONE_STATUS.XRAY == coalition.side.RED) then
		CaucasusPendulum.SpawnAttack("WHISKEY", "XRAY", "RED", true)
	end
	if (CAPZONE_STATUS.VICTOR == coalition.side.BLUE and CAPZONE_STATUS.WHISKEY == coalition.side.RED) then
		CaucasusPendulum.SpawnAttack("VICTOR", "WHISKEY", "RED", true)
	end
	if (CAPZONE_STATUS.UNIFORM == coalition.side.BLUE and CAPZONE_STATUS.VICTOR == coalition.side.RED) then
		CaucasusPendulum.SpawnAttack("UNIFORM", "VICTOR", "RED", true)
	end
	if (CAPZONE_STATUS.TANGO == coalition.side.BLUE and CAPZONE_STATUS.UNIFORM == coalition.side.RED) then
		CaucasusPendulum.SpawnAttack("TANGO", "UNIFORM", "RED", true)
	end
	if (CAPZONE_STATUS.SIERRA == coalition.side.BLUE and CAPZONE_STATUS.TANGO == coalition.side.RED) then
		CaucasusPendulum.SpawnAttack("SIERRA", "TANGO", "RED", true)
	end
	if (CAPZONE_STATUS.ROMEO == coalition.side.BLUE and CAPZONE_STATUS.SIERRA == coalition.side.RED) then
		CaucasusPendulum.SpawnAttack("ROMEO", "SIERRA", "RED", true)
	end
	if (CAPZONE_STATUS.QUEBEC == coalition.side.BLUE and CAPZONE_STATUS.ROMEO == coalition.side.RED) then
		CaucasusPendulum.SpawnAttack("QUEBEC", "ROMEO", "RED", true)
	end
	if (CAPZONE_STATUS.PAPA == coalition.side.BLUE and CAPZONE_STATUS.QUEBEC == coalition.side.RED) then
		RedAttackInterval = RedAttackIntervalFast
		CaucasusPendulum.SpawnAttack("PAPA", "QUEBEC", "RED", true)
	end
	if (CAPZONE_STATUS.OSCAR == coalition.side.BLUE and CAPZONE_STATUS.PAPA == coalition.side.RED) then
		CaucasusPendulum.SpawnAttack("OSCAR", "PAPA", "RED", true)
	end
	if (CAPZONE_STATUS.NOVEMBER == coalition.side.BLUE and CAPZONE_STATUS.OSCAR == coalition.side.RED) then
		CaucasusPendulum.SpawnAttack("NOVEMBER", "OSCAR", "RED", true)
	end
--	if (CAPZONE_STATUS.MIKE == coalition.side.BLUE and CAPZONE_STATUS.NOVEMBER == coalition.side.RED) then
--		CaucasusPendulum.SpawnAttack("MIKE", "NOVEMBER", "RED", true)
--	end
	if (CAPZONE_STATUS.LIMA == coalition.side.BLUE and CAPZONE_STATUS.MIKE == coalition.side.RED) then
		CaucasusPendulum.SpawnAttack("LIMA", "MIKE", "RED", true)
	end
	if (CAPZONE_STATUS.KILO == coalition.side.BLUE and CAPZONE_STATUS.LIMA == coalition.side.RED) then
		CaucasusPendulum.SpawnAttack("KILO", "LIMA", "RED", true)
	end
	if (CAPZONE_STATUS.JULIET == coalition.side.BLUE and CAPZONE_STATUS.KILO == coalition.side.RED) then
		CaucasusPendulum.SpawnAttack("JULIET", "KILO", "RED", true)
	end
	if (CAPZONE_STATUS.INDIA == coalition.side.BLUE and CAPZONE_STATUS.JULIET == coalition.side.RED) then
		CaucasusPendulum.SpawnAttack("INDIA", "JULIET", "RED", true)
	end
	if (CAPZONE_STATUS.HOTEL == coalition.side.BLUE and CAPZONE_STATUS.INDIA == coalition.side.RED) then
		CaucasusPendulum.SpawnAttack("HOTEL", "INDIA", "RED", true)
	end
	if (CAPZONE_STATUS.GOLF == coalition.side.BLUE and CAPZONE_STATUS.HOTEL == coalition.side.RED) then
		CaucasusPendulum.SpawnAttack("GOLF", "HOTEL", "RED", true)
	end
	if (CAPZONE_STATUS.FOXTROT == coalition.side.BLUE and CAPZONE_STATUS.GOLF == coalition.side.RED) then
		CaucasusPendulum.SpawnAttack("FOXTROT", "GOLF", "RED", true)
	end
	if (CAPZONE_STATUS.ECHO == coalition.side.BLUE and CAPZONE_STATUS.FOXTROT == coalition.side.RED) then
		CaucasusPendulum.SpawnAttack("ECHO", "FOXTROT", "RED", true)
	end
	if (CAPZONE_STATUS.DELTA == coalition.side.BLUE and CAPZONE_STATUS.ECHO == coalition.side.RED) then
		CaucasusPendulum.SpawnAttack("DELTA", "ECHO", "RED", true)
	end
	if (CAPZONE_STATUS.CHARLIE == coalition.side.BLUE and CAPZONE_STATUS.DELTA == coalition.side.RED) then
		CaucasusPendulum.SpawnAttack("CHARLIE", "DELTA", "RED", true)
	end
	if (CAPZONE_STATUS.BRAVO == coalition.side.BLUE and CAPZONE_STATUS.CHARLIE == coalition.side.RED) then
		CaucasusPendulum.SpawnAttack("BRAVO", "CHARLIE", "RED", true)
	end
	if (CAPZONE_STATUS.ALPHA == coalition.side.BLUE and CAPZONE_STATUS.BRAVO == coalition.side.RED) then
		CaucasusPendulum.SpawnAttack("ALPHA", "BRAVO", "RED", true)
	end
  end

  if (getPlayerCount(coalition.side.BLUE) == 0 and getPlayerCount(coalition.side.RED) > 0 and BLUE_ATTACK_ENABLED == true) then
	if (CAPZONE_STATUS.BRAVO == coalition.side.RED and CAPZONE_STATUS.ALPHA == coalition.side.BLUE) then
		CaucasusPendulum.SpawnAttack("BRAVO", "ALPHA", "BLUE", true)
	end
	if (CAPZONE_STATUS.CHARLIE == coalition.side.RED and CAPZONE_STATUS.BRAVO == coalition.side.BLUE) then
		CaucasusPendulum.SpawnAttack("CHARLIE", "BRAVO", "BLUE", true)
	end
	if (CAPZONE_STATUS.DELTA == coalition.side.RED and CAPZONE_STATUS.CHARLIE == coalition.side.BLUE) then
		CaucasusPendulum.SpawnAttack("DELTA", "CHARLIE", "BLUE", true)
	end
	if (CAPZONE_STATUS.ECHO == coalition.side.RED and CAPZONE_STATUS.DELTA == coalition.side.BLUE) then
		CaucasusPendulum.SpawnAttack("ECHO", "DELTA", "BLUE", true)
	end
	if (CAPZONE_STATUS.FOXTROT == coalition.side.RED and CAPZONE_STATUS.ECHO == coalition.side.BLUE) then
		CaucasusPendulum.SpawnAttack("FOXTROT", "ECHO", "BLUE", true)
	end
	if (CAPZONE_STATUS.GOLF == coalition.side.RED and CAPZONE_STATUS.FOXTROT == coalition.side.BLUE) then
		CaucasusPendulum.SpawnAttack("GOLF", "FOXTROT", "BLUE", true)
	end
	if (CAPZONE_STATUS.HOTEL == coalition.side.RED and CAPZONE_STATUS.GOLF == coalition.side.BLUE) then
		CaucasusPendulum.SpawnAttack("HOTEL", "GOLF", "BLUE", true)
	end
	if (CAPZONE_STATUS.INDIA == coalition.side.RED and CAPZONE_STATUS.HOTEL == coalition.side.BLUE) then
		CaucasusPendulum.SpawnAttack("INDIA", "HOTEL", "BLUE", true)
	end
	if (CAPZONE_STATUS.JULIET == coalition.side.RED and CAPZONE_STATUS.INDIA == coalition.side.BLUE) then
		CaucasusPendulum.SpawnAttack("JULIET", "ALPHA", "BLUE", true)
	end
	if (CAPZONE_STATUS.KILO == coalition.side.RED and CAPZONE_STATUS.JULIET == coalition.side.BLUE) then
		CaucasusPendulum.SpawnAttack("KILO", "JULIET", "BLUE", true)
	end
	if (CAPZONE_STATUS.LIMA == coalition.side.RED and CAPZONE_STATUS.KILO == coalition.side.BLUE) then
		CaucasusPendulum.SpawnAttack("LIMA", "KILO", "BLUE", true)
	end
	if (CAPZONE_STATUS.MIKE == coalition.side.RED and CAPZONE_STATUS.LIMA == coalition.side.BLUE) then
		CaucasusPendulum.SpawnAttack("MIKE", "LIMA", "BLUE", true)
	end
  end
  return time + RedAttackInterval
end

ATTACKGROUP = {}

function CaucasusPendulum.groupIsDead(groupName)
	local groupHealth =0
	local groupDead = false
	for index, unitData in pairs(GROUP:FindByName(groupName):GetUnits()) do
			env.info("Found unit in group: " .. unitData.UnitName .. " Life: "..unitData:GetLife())
			groupHealth = groupHealth + unitData:GetLife()
	end
	env.info("group health: " .. groupHealth)

	if groupHealth <1 then
			groupDead = true
	end
	return groupDead
end


function CaucasusPendulum.saveActiveAttackGroup( SpawnGroup, attackGroupIndex )
	env.info("Created new group: "..SpawnGroup.GroupName)
	ATTACKGROUP[attackGroupIndex] = SpawnGroup.GroupName
end

function CaucasusPendulum.SpawnAttack(targetzone, sourcezone, coalitionName, noResourceCost)
	local _coalition = 1
	if (coalitionName == "BLUE") then
		_coalition = 2
	end

	if (noResourceCost ~= true and TEAM_RESOURCES[_coalition] < PRICE_TANKATTACK) then
		return
	end



	local SpawnZones = { ZONE:FindByName( sourcezone .. " ZONE" )}

	env.info("ATTACK GROUP SPAWN: "..coalitionName.." "..sourcezone .. " attacking " .. targetzone)
	local attackGroupIndex = coalitionName..sourcezone..targetzone
	
	if (ATTACKGROUP[attackGroupIndex] == nil or CaucasusPendulum.groupIsDead(ATTACKGROUP[attackGroupIndex])) then
		trigger.action.outText(coalitionName .. " ground units from " .. sourcezone .. " are moving to attack " .. targetzone, 10 , false)
		local newGroup = SPAWN
		:New(coalitionName .. " " .. targetzone .. " ATTACK GROUP")
--		:InitKeepUnitNames( true )
		:InitLimit(10,0)
		:OnSpawnGroup(CaucasusPendulum.saveActiveAttackGroup, attackGroupIndex)
		newGroup:Spawn()
		if (noResourceCost ~= true) then
			TEAM_RESOURCES[_coalition] = TEAM_RESOURCES[_coalition] - PRICE_TANKATTACK
		end
		CaucasusPendulum.updateStrategicCommandMenu(_coalition)
	else
		trigger.action.outText("Invalid Request, ".. coalitionName .. " ground units are already attacking " .. targetzone, 5 , false)
	end
end


-- Attack Scheduler
timer.scheduleFunction(CaucasusPendulum.AttackScheduler, {}, timer.getTime() + (60*60))




function CaucasusPendulum.SpawnCaptureZoneUnitsArray (args)
	CaucasusPendulum.SpawnCaptureZoneUnits (args["zoneName"], args["coalitionParam"])
end

-- return an array of object, of matching coalition found in a zone
-- @param #enum category (the object category to search for. eg Object.Category.UNIT)
-- @param #enum coalition (the coalition to search for. eg coalition.side.BLUE)
-- @param #string zoneName (the zone to search in. eg "SAM Zone")
function CaucasusPendulum.ScanZone(category, coalition, zoneName)

    local foundUnits = {}

    if trigger.misc.getZone(zoneName) ~= nil then

        local searchZone = trigger.misc.getZone(zoneName)
        -- new sphere searchVolume from searchZone
        local searchVolume = {
            ["id"] = world.VolumeType.SPHERE,
            ["params"] = {
                ["point"] = {x=searchZone.point.x, z=searchZone.point.z, y=land.getHeight({x=searchZone.point.x, y=searchZone.point.z})},
                ["radius"] = searchZone.radius,
            }
        }
        -- search the volume for an object category
        world.searchObjects(category, searchVolume, function(obj)

            -- if the found object is of the same coalition, add it to the table
            if obj ~= nil
				and obj:getLife() > 0
				and obj:isActive()
				and obj:getCoalition() == coalition then
                foundUnits[#foundUnits+1] = obj
            end
        end)
    end

    if #foundUnits > 0 then
        -- return the found units
        return foundUnits
    end

    -- return nil if no found units
    return nil
end

function CaucasusPendulum.CheckLostZone(zoneName)
--	env.info("Check lost zone: "..zoneName)

	if (CAPZONE_STATUS[zoneName] == coalition.side.RED) then
		defendingCoalitionName = "RED"
		capturingCoalition = coalition.side.BLUE
	else
		defendingCoalitionName = "BLUE"
		capturingCoalition = coalition.side.RED
	end

	local defendersInZone = CaucasusPendulum.ScanZone(Object.Category.UNIT, CAPZONE_STATUS[zoneName], zoneName .. " ZONE")
	if (defendersInZone == nil) then
--		env.info("Defenders dead in " .. zoneName)
		CaucasusPendulum.CaptureZone(zoneName, capturingCoalition)	
--	else
--		env.info("Defenders alive in " .. zoneName)
	end


end

function CaucasusPendulum.CaptureZone(zoneName, coalitionParam)
	local SpawnZones = { ZONE:FindByName( zoneName .. " ZONE" )}
	local coalitionName = "BLUE"
	if (coalitionParam == coalition.side.RED) then
		coalitionName = "RED"
	end
	env.info("ZONE CAPTURED: "..coalitionName.." has taken control of "..zoneName)
	trigger.action.outText(coalitionName .. " forces captured Zone " .. zoneName, 15 , false)
	trigger.action.removeMark(ZoneID[zoneName .. " ZONE"])
	local circleZone = ZONE:FindByName( zoneName .. " ZONE" )
	trigger.action.circleToAll(-1, ZoneID[zoneName .. " ZONE"], circleZone:GetVec3(0), 5000, linecolor[coalitionParam],fillcolor[coalitionParam], 2, true)
	if (coalitionParam == coalition.side.RED) then
		if (zoneName == "MIKE") then
			trigger.action.setUserFlag("BLUE PLAYER SA342M KUTAISI", 100)
			trigger.action.setUserFlag("BLUE PLAYER SA342Mistral KUTAISI", 100)
			trigger.action.setUserFlag("BLUE PLAYER KA50 KUTAISI", 100)
			trigger.action.setUserFlag("BLUE PLAYER M2000 KUTAISI", 100)
			trigger.action.setUserFlag("BLUE PLAYER AV8B KUTAISI", 100)
			trigger.action.setUserFlag("BLUE PLAYER F16 KUTAISI", 100)
			trigger.action.setUserFlag("BLUE PLAYER A10CII KUTAISI", 100)
			trigger.action.setUserFlag("BLUE PLAYER MIG21Bis KUTAISI", 100)
			trigger.action.setUserFlag("BLUE PLAYER F5 KUTAISI", 100)
			trigger.action.setUserFlag("BLUE PLAYER F/A-18C KUTAISI", 100)
			trigger.action.setUserFlag("RED PLAYER MIG21Bis KUTAISI", 0)
			trigger.action.setUserFlag("RED PLAYER SU33 KUTAISI", 0)
			trigger.action.setUserFlag("RED PLAYER JF17 KUTAISI", 0)
			trigger.action.setUserFlag("RED PLAYER M2000 KUTAISI", 0)
			trigger.action.setUserFlag("RED PLAYER SA342M KUTAISI", 0)
			trigger.action.setUserFlag("RED PLAYER SA342Mistral KUTAISI", 0)
			trigger.action.setUserFlag("RED PLAYER KA50 KUTAISI", 0)
			trigger.action.outText("Red air spawns at Kutaisi (MIKE) are now active!", 15 , false)							
		elseif (zoneName == "PAPA") then
			trigger.action.setUserFlag("BLUE PLAYER AJS37 KOBULETI", 100)
			trigger.action.setUserFlag("BLUE PLAYER F15C KOBULETI", 100)
			trigger.action.setUserFlag("BLUE PLAYER A10A KOBULETI", 100)
			trigger.action.setUserFlag("BLUE PLAYER A10C II KOBULETI", 100)
			trigger.action.setUserFlag("RED PLAYER AJS37 KOBULETI", 0)
			trigger.action.setUserFlag("RED PLAYER SU25T KOBULETI", 0)
			trigger.action.outText("Red air spawns at Kobuleti (PAPA) are now active!", 15 , false)							
		elseif (zoneName == "VICTOR") then
			trigger.action.setUserFlag("BLUE PLAYER F16C SUKHUMI", 100)
			trigger.action.setUserFlag("RED PLAYER F16C SUKHUMI", 0)
			trigger.action.setUserFlag("RED PLAYER MIG21Bis SUKHUMI", 0)
			trigger.action.outText("Red air spawns at Sukhumi (VICTOR) are now active!", 15 , false)							
		end
	else
		if (zoneName == "MIKE") then
			trigger.action.setUserFlag("BLUE PLAYER SA342M KUTAISI", 0)
			trigger.action.setUserFlag("BLUE PLAYER SA342Mistral KUTAISI", 0)
			trigger.action.setUserFlag("BLUE PLAYER KA50 KUTAISI", 0)
			trigger.action.setUserFlag("BLUE PLAYER M2000 KUTAISI", 0)
			trigger.action.setUserFlag("BLUE PLAYER AV8B KUTAISI", 0)
			trigger.action.setUserFlag("BLUE PLAYER F16 KUTAISI", 0)
			trigger.action.setUserFlag("BLUE PLAYER A10CII KUTAISI", 0)
			trigger.action.setUserFlag("BLUE PLAYER MIG21Bis KUTAISI", 0)
			trigger.action.setUserFlag("BLUE PLAYER F5 KUTAISI", 0)
			trigger.action.setUserFlag("BLUE PLAYER F/A-18C KUTAISI", 0)
			trigger.action.setUserFlag("RED PLAYER MIG21Bis KUTAISI", 100)
			trigger.action.setUserFlag("RED PLAYER SU33 KUTAISI", 100)
			trigger.action.setUserFlag("RED PLAYER JF17 KUTAISI", 100)
			trigger.action.setUserFlag("RED PLAYER M2000 KUTAISI", 100)
			trigger.action.setUserFlag("RED PLAYER SA342M KUTAISI", 100)
			trigger.action.setUserFlag("RED PLAYER SA342Mistral KUTAISI", 100)
			trigger.action.setUserFlag("RED PLAYER KA50 KUTAISI", 100)
			trigger.action.outText("Blue air spawns at Kutaisi (MIKE) are now active!", 15 , false)							
		elseif (zoneName == "PAPA") then
			trigger.action.setUserFlag("BLUE PLAYER AJS37 KOBULETI", 0)
			trigger.action.setUserFlag("BLUE PLAYER F15C KOBULETI", 0)
			trigger.action.setUserFlag("BLUE PLAYER A10A KOBULETI", 0)
			trigger.action.setUserFlag("BLUE PLAYER A10C II KOBULETI", 0)
			trigger.action.setUserFlag("RED PLAYER AJS37 KOBULETI", 100)
			trigger.action.setUserFlag("RED PLAYER SU25T KOBULETI", 100)
			trigger.action.outText("Blue air spawns at Kobuleti (PAPA) are now active!", 15 , false)							
		elseif (zoneName == "VICTOR") then
			trigger.action.setUserFlag("BLUE PLAYER F16C SUKHUMI", 0)
			trigger.action.setUserFlag("RED PLAYER F16C SUKHUMI", 100)
			trigger.action.setUserFlag("RED PLAYER MIG21Bis SUKHUMI", 100)
			trigger.action.outText("Blue air spawns at Sukhumi (VICTOR) are now active!", 15 , false)							
		end
	end
	CAPZONE_STATUS[zoneName] = coalitionParam
	CaucasusPendulum.updateStrategicCommandMenu(coalition.side.BLUE)
	CaucasusPendulum.updateStrategicCommandMenu(coalition.side.RED)
	
	local allBasesCaptured = true
	for _capzone, _capzoneStatus in pairs(CAPZONE_STATUS) do
		if (_capzoneStatus ~= coalitionParam) then
			allBasesCaptured = false
		end
	end
	if (allBasesCaptured == true) then
			trigger.action.outText(coalitionName .. " HAS CAPTURED ALL ZONES! Congratulations!\nServer will now reset, please stand by...", 60 , false)							
	end
	timer.scheduleFunction(CaucasusPendulum.timerSpawnCaptureZoneUnits, {zoneName, coalitionParam}, timer.getTime() + 15)
--	CaucasusPendulum.SpawnCaptureZoneUnits (zoneName, coalitionParam)
end

function CaucasusPendulum.timerSpawnCaptureZoneUnits (_args)
	CaucasusPendulum.SpawnCaptureZoneUnits(_args[1], _args[2])
end

function CaucasusPendulum.SpawnCaptureZoneUnits (zoneName, coalitionParam)
	local SpawnZones = { ZONE:FindByName( zoneName .. " ZONE" )}
	local coalitionName = "BLUE"
	if (coalitionParam == coalition.side.RED) then
		coalitionName = "RED"
	end
	local SpawnGroup 

	env.info("GROUP SPAWN: "..coalitionName.." "..zoneName)

	if (coalitionParam == coalition.side.BLUE) then
	  SpawnGroup = SPAWN
		:New(coalitionName .. " " .. zoneName .. " GROUP")
		:InitKeepUnitNames( true )
		:InitLimit(20,0)
--		:InitRandomizeZones( SpawnZones )
	else
	  SpawnGroup = SPAWN
		:New(coalitionName .. " " .. zoneName .. " GROUP")
		:InitKeepUnitNames( true )
		:InitLimit(20,0)
--		:InitRandomizeZones( SpawnZones )
	end
	SpawnGroup:Spawn()
end

CaucasusPendulum.SpawnCaptureZoneUnits( "ALPHA", CAPZONE_STATUS.ALPHA);
CaucasusPendulum.SpawnCaptureZoneUnits( "BRAVO", CAPZONE_STATUS.BRAVO);
CaucasusPendulum.SpawnCaptureZoneUnits( "CHARLIE", CAPZONE_STATUS.CHARLIE);
CaucasusPendulum.SpawnCaptureZoneUnits( "DELTA", CAPZONE_STATUS.DELTA);
CaucasusPendulum.SpawnCaptureZoneUnits( "ECHO", CAPZONE_STATUS.ECHO);
CaucasusPendulum.SpawnCaptureZoneUnits( "FOXTROT", CAPZONE_STATUS.FOXTROT);
CaucasusPendulum.SpawnCaptureZoneUnits( "GOLF", CAPZONE_STATUS.GOLF);
CaucasusPendulum.SpawnCaptureZoneUnits( "HOTEL", CAPZONE_STATUS.HOTEL);
CaucasusPendulum.SpawnCaptureZoneUnits( "INDIA", CAPZONE_STATUS.INDIA);
CaucasusPendulum.SpawnCaptureZoneUnits( "JULIET", CAPZONE_STATUS.JULIET);
CaucasusPendulum.SpawnCaptureZoneUnits( "KILO", CAPZONE_STATUS.KILO);
CaucasusPendulum.SpawnCaptureZoneUnits( "LIMA", CAPZONE_STATUS.LIMA);
CaucasusPendulum.SpawnCaptureZoneUnits( "MIKE", CAPZONE_STATUS.MIKE);
CaucasusPendulum.SpawnCaptureZoneUnits( "NOVEMBER", CAPZONE_STATUS.NOVEMBER);
CaucasusPendulum.SpawnCaptureZoneUnits( "OSCAR", CAPZONE_STATUS.OSCAR);
CaucasusPendulum.SpawnCaptureZoneUnits( "PAPA", CAPZONE_STATUS.PAPA);
CaucasusPendulum.SpawnCaptureZoneUnits( "QUEBEC", CAPZONE_STATUS.QUEBEC);
CaucasusPendulum.SpawnCaptureZoneUnits( "ROMEO", CAPZONE_STATUS.ROMEO);
CaucasusPendulum.SpawnCaptureZoneUnits( "SIERRA", CAPZONE_STATUS.SIERRA);
CaucasusPendulum.SpawnCaptureZoneUnits( "TANGO", CAPZONE_STATUS.TANGO);
CaucasusPendulum.SpawnCaptureZoneUnits( "UNIFORM", CAPZONE_STATUS.UNIFORM);
CaucasusPendulum.SpawnCaptureZoneUnits( "VICTOR", CAPZONE_STATUS.VICTOR);
CaucasusPendulum.SpawnCaptureZoneUnits( "WHISKEY", CAPZONE_STATUS.WHISKEY);
CaucasusPendulum.SpawnCaptureZoneUnits( "XRAY", CAPZONE_STATUS.XRAY);
CaucasusPendulum.SpawnCaptureZoneUnits( "YANKEE", CAPZONE_STATUS.YANKEE);
CaucasusPendulum.SpawnCaptureZoneUnits( "ZULU", CAPZONE_STATUS.ZULU);


function CaucasusPendulum.ScheduledZoneChecks()
	CaucasusPendulum.CheckLostZone("ALPHA")
	CaucasusPendulum.CheckLostZone("BRAVO")
	CaucasusPendulum.CheckLostZone("CHARLIE")
	CaucasusPendulum.CheckLostZone("DELTA")
	CaucasusPendulum.CheckLostZone("ECHO")
	CaucasusPendulum.CheckLostZone("FOXTROT")
	CaucasusPendulum.CheckLostZone("GOLF")
	CaucasusPendulum.CheckLostZone("HOTEL")
	CaucasusPendulum.CheckLostZone("INDIA")
	CaucasusPendulum.CheckLostZone("JULIET")
	CaucasusPendulum.CheckLostZone("KILO")
	CaucasusPendulum.CheckLostZone("LIMA")
	CaucasusPendulum.CheckLostZone("MIKE")
	CaucasusPendulum.CheckLostZone("NOVEMBER")
	CaucasusPendulum.CheckLostZone("OSCAR")
	CaucasusPendulum.CheckLostZone("PAPA")
	CaucasusPendulum.CheckLostZone("QUEBEC")
	CaucasusPendulum.CheckLostZone("ROMEO")
	CaucasusPendulum.CheckLostZone("SIERRA")
	CaucasusPendulum.CheckLostZone("TANGO")
	CaucasusPendulum.CheckLostZone("UNIFORM")
	CaucasusPendulum.CheckLostZone("VICTOR")
	CaucasusPendulum.CheckLostZone("WHISKEY")
	CaucasusPendulum.CheckLostZone("XRAY")
	CaucasusPendulum.CheckLostZone("YANKEE")
	CaucasusPendulum.CheckLostZone("ZULU")
	timer.scheduleFunction(CaucasusPendulum.ScheduledZoneChecks, {}, timer.getTime() + 20)
end
timer.scheduleFunction(CaucasusPendulum.ScheduledZoneChecks, {}, timer.getTime() + 20)

function CaucasusPendulum.addResources(_coalition, resAmount)
	if (TEAM_RESOURCES[_coalition] + resAmount <= TEAM_RESOURCES_MAX[_coalition]) then
		TEAM_RESOURCES[_coalition] = TEAM_RESOURCES[_coalition] + resAmount
		CaucasusPendulum.updateStrategicCommandMenu(_coalition)
	end
end

function CaucasusPendulum.setupResourceHandler()
	local ev = {}
	function ev:onEvent(event)
		local unit = event.initiator
		if unit and unit:getCategory() == Object.Category.UNIT and (unit:getDesc().category == Unit.Category.AIRPLANE or unit:getDesc().category == Unit.Category.HELICOPTER)then
			local coalition = unit:getCoalition()
			local groupid = unit:getGroup():getID()
			local pname = unit:getPlayerName()
			if pname then
				if (event.id==28) then
					if event.target.getCoalition and coalition ~= event.target:getCoalition() then
						if event.target:getCategory() == Object.Category.UNIT then
							local credits = 0
							local targetType = event.target:getDesc().category
							if targetType == Unit.Category.AIRPLANE  then
								credits = 6
								trigger.action.outTextForGroup(groupid, '['..pname..'] earned '..credits..' credits for aircraft kill', 5)
							elseif targetType == Unit.Category.HELICOPTER then
								credits = 4
								trigger.action.outTextForGroup(groupid, '['..pname..'] earned '..credits..' credits for helicopter kill', 5)
							elseif targetType == Unit.Category.GROUND_UNIT then
								if (event.target:hasAttribute('SAM SR') or event.target:hasAttribute('SAM TR') or event.target:hasAttribute('IR Guided SAM')) then
									credits = 5
									trigger.action.outTextForGroup(groupid, '['..pname..'] earned '..credits..' credits for SAM kill', 5)
								else
									credits = 3
									trigger.action.outTextForGroup(groupid, '['..pname..'] earned '..credits..' credits for ground unit kill', 5)
								end
							elseif targetType == Unit.Category.SHIP then
								credits = 10
								trigger.action.outTextForGroup(groupid, '['..pname..'] earned '..credits..' credits for ship kill', 5)
							elseif targetType == Unit.Category.STRUCTURE then
								credits = 3
								trigger.action.outTextForGroup(groupid, '['..pname..'] earned '..credits..' credits for ground structure kill', 5)
							end
							CaucasusPendulum.addResources(coalition, credits)
						end
					end
				end
			end
		end
	end

	world.addEventHandler(ev)
end
--CaucasusPendulum.setupResourceHandler()


env.info("Dynamic Conflict CAPTURE ZONES loaded ...")
trigger.action.outText("Dynamic Conflict CAPTURE ZONES loaded ...", 10)


RedPatrolZones = {}
RedPatrolZones[1] = ZONE:New( "RED PATROL ZONE 1" )
RedPatrolZones[2] = ZONE:New( "RED PATROL ZONE 2" )
RedPatrolZones[3] = ZONE:New( "RED PATROL ZONE 3" )
RedPatrolZones[4] = ZONE:New( "RED PATROL ZONE 4" )
RedPatrolZones[5] = ZONE:New( "RED PATROL ZONE 5" )
RedPatrolZones[6] = ZONE:New( "RED PATROL ZONE 6" )

RED_PlanesSpawn = {}
RED_PlanesSpawn[1] = SPAWN:New( "RED AIB SU27 1" ):InitCleanUp( 45 ):OnSpawnGroup(
				function (capGroup)
					capGroup:HandleEvent(EVENTS.Land)
					function capGroup:OnEventLand(EventData)
					    capGroup:Destroy()
					 end
				end
				)
RED_PlanesSpawn[2] = SPAWN:New( "RED AIB SU27 2" ):InitCleanUp( 45 ):OnSpawnGroup(
				function (capGroup)
					capGroup:HandleEvent(EVENTS.Land)
					function capGroup:OnEventLand(EventData)
					    capGroup:Destroy()
					 end
				end
				)
RED_PlanesSpawn[3] = SPAWN:New( "RED AIB JF17 1" ):InitCleanUp( 45 ):OnSpawnGroup(
				function (capGroup)
					capGroup:HandleEvent(EVENTS.Land)
					function capGroup:OnEventLand(EventData)
					    capGroup:Destroy()
					 end
				end
				)
RED_PlanesSpawn[4] = SPAWN:New( "RED AIB JF17 2" ):InitCleanUp( 45 ):OnSpawnGroup(
				function (capGroup)
					capGroup:HandleEvent(EVENTS.Land)
					function capGroup:OnEventLand(EventData)
					    capGroup:Destroy()
					 end
				end
				)
--RED_PlanesSpawn[5] = SPAWN:New( "RED AIB JF17 3" ):InitCleanUp( 45 )
--RED_PlanesSpawn[6] = SPAWN:New( "RED AIB JF17 4" ):InitCleanUp( 45 )

RED_PlanesClientSet = {}
RED_PlanesClientSet[1] = SET_CLIENT:New():FilterPrefixes("RED PLAYER SU27 1")
RED_PlanesClientSet[2] = SET_CLIENT:New():FilterPrefixes("RED PLAYER SU27 2")
RED_PlanesClientSet[3] = SET_CLIENT:New():FilterPrefixes("RED PLAYER JF17 1")
RED_PlanesClientSet[4] = SET_CLIENT:New():FilterPrefixes("RED PLAYER JF17 2")
--RED_PlanesClientSet[5] = SET_CLIENT:New():FilterPrefixes("RED PLAYER JF17 3")
--RED_PlanesClientSet[6] = SET_CLIENT:New():FilterPrefixes("RED PLAYER JF17 4")

RED_AI_Balancer = {}
for i=1, 4 do
  RED_AI_Balancer[i] = AI_BALANCER:New(RED_PlanesClientSet[i], RED_PlanesSpawn[i])
  
  local curAIBalancer = RED_AI_Balancer[i]
  curAIBalancer:ReturnToHomeAirbase(1000)
  function curAIBalancer:OnAfterSpawned( SetGroup, From, Event, To, AIGroup )
    local Patrol = AI_PATROL_ZONE:New( RedPatrolZones[math.random( 1, table.getn(RedPatrolZones))], 1500, 20000, 700, 1400 )
    Patrol:ManageFuel( 0.2, 60 )
    Patrol:SetControllable( AIGroup )
    Patrol:Start()
  end
end

BluePatrolZones = {}
BluePatrolZones[1] = ZONE:New( "BLUE PATROL ZONE 1" )
BluePatrolZones[2] = ZONE:New( "BLUE PATROL ZONE 2" )
BluePatrolZones[3] = ZONE:New( "BLUE PATROL ZONE 3" )
BluePatrolZones[4] = ZONE:New( "BLUE PATROL ZONE 4" )
BluePatrolZones[5] = ZONE:New( "BLUE PATROL ZONE 5" )
BluePatrolZones[6] = ZONE:New( "BLUE PATROL ZONE 6" )

BLUE_PlanesSpawn = {}
BLUE_PlanesSpawn[1] = SPAWN:New( "BLUE AIB AV8B US 1" ):InitCleanUp( 45 ):OnSpawnGroup(
				function (capGroup)
					capGroup:HandleEvent(EVENTS.Land)
					function capGroup:OnEventLand(EventData)
					    capGroup:Destroy()
					 end
				end
				)
BLUE_PlanesSpawn[2] = SPAWN:New( "BLUE AIB AV8B US 2" ):InitCleanUp( 45 ):OnSpawnGroup(
				function (capGroup)
					capGroup:HandleEvent(EVENTS.Land)
					function capGroup:OnEventLand(EventData)
					    capGroup:Destroy()
					 end
				end
				)
BLUE_PlanesSpawn[3] = SPAWN:New( "BLUE AIB F18C ES 1" ):InitCleanUp( 45 ):OnSpawnGroup(
				function (capGroup)
					capGroup:HandleEvent(EVENTS.Land)
					function capGroup:OnEventLand(EventData)
					    capGroup:Destroy()
					 end
				end
				)
--BLUE_PlanesSpawn[4] = SPAWN:New( "BLUE AIB F18C ES 2" ):InitCleanUp( 45 )
BLUE_PlanesSpawn[4] = SPAWN:New( "BLUE AIB F18C ES 3" ):InitCleanUp( 45 ):OnSpawnGroup(
				function (capGroup)
					capGroup:HandleEvent(EVENTS.Land)
					function capGroup:OnEventLand(EventData)
					    capGroup:Destroy()
					 end
				end
				)
--BLUE_PlanesSpawn[6] = SPAWN:New( "BLUE AIB F18C ES 4" ):InitCleanUp( 45 )

BLUE_PlanesClientSet = {}
BLUE_PlanesClientSet[1] = SET_CLIENT:New():FilterPrefixes("BLUE PLAYER AV8B US 1")
BLUE_PlanesClientSet[2] = SET_CLIENT:New():FilterPrefixes("BLUE PLAYER AV8B US 2")
BLUE_PlanesClientSet[3] = SET_CLIENT:New():FilterPrefixes("BLUE PLAYER F18C ES 1")
--BLUE_PlanesClientSet[4] = SET_CLIENT:New():FilterPrefixes("BLUE PLAYER F18C ES 2")
BLUE_PlanesClientSet[4] = SET_CLIENT:New():FilterPrefixes("BLUE PLAYER F18C ES 3")
--BLUE_PlanesClientSet[6] = SET_CLIENT:New():FilterPrefixes("BLUE PLAYER F18C ES 4")

BLUE_AI_Balancer = {}
for i=1, 4 do
  BLUE_AI_Balancer[i] = AI_BALANCER:New(BLUE_PlanesClientSet[i], BLUE_PlanesSpawn[i])
  
  local curAIBalancer = BLUE_AI_Balancer[i]
  curAIBalancer:ReturnToHomeAirbase(1000)
  function curAIBalancer:OnAfterSpawned( SetGroup, From, Event, To, AIGroup )
    local Patrol = AI_PATROL_ZONE:New( BluePatrolZones[math.random( 1, table.getn(BluePatrolZones))], 1500, 20000, 700, 1400 )
    Patrol:ManageFuel( 0.2, 60 )
    Patrol:SetControllable( AIGroup )
    Patrol:Start()
  end
end


env.info("Dynamic Conflict AI BALANCING loaded ...")
trigger.action.outText("Dynamic Conflict AI BALANCING loaded ...", 10)


-- LIST RADIO FREQUENCIES FUNCTIONS ***************************************************************************************

function CaucasusPendulum.listRadioFrequencies(_groupId)

  trigger.action.outTextForGroup(_groupId, 
    [[
    BLUE COALITION
    AWACS: 251 MHz
    TANKER (Basket): 252 MHz - TCN 99X
    TANKER (Boom): 253 MHz - TCN 98X
    CARRIER: 127.5 MHz - TCN 74X - ICLS 11
    LHA-1 Tarawa: 128.5 MHz
    Airport Tbilisi-Lochini: 138.0 MHz / 267 MHz - TCN 25X
    CAP FLIGHTS: 300 MHz
    CAS FLIGHTS: 310 MHz
    ****
    RED COALITION
    AWACS: 124/257 MHz
    TANKER: 253 MHz
    CARRIER: 129.5 MHz
    Airport Sochi-Adler: 127 Mhz / 256 MHz
    CAP FLIGHTS: 305 MHz
    CAS FLIGHTS: 315 MHz
    ]]
    , 15 , false)  
  trigger.action.outSoundForGroup(_groupId, "walkietalkie.ogg")
end

-- ADD RADIO MENUS ***************************************************************************************

function CaucasusPendulum.addRadioMenus(_side)

	local _players = coalition.getPlayers(_side)

    if _players ~= nil then
        for _, _playerUnit in pairs(_players) do
          local _groupId = ctld.getGroupId(_playerUnit)
          if _groupId then
              if CaucasusPendulum.radioMenusAdded[tostring(_groupId)] == nil then
                missionCommands.addCommandForGroup(_groupId, "List Radio Frequencies", nil, CaucasusPendulum.listRadioFrequencies, _groupId)
                CaucasusPendulum.radioMenusAdded[tostring(_groupId)] = true
              end
          end
        end
    end

end

function CaucasusPendulum.showTeamResources(_coalition)
	env.info("SHOW TEAM RESOURCES called, blue resources: "..TEAM_RESOURCES[coalition.side.BLUE])
	CaucasusPendulum.checkFOBs()
	trigger.action.outTextForCoalition(_coalition, 'BLUE Team Resources: ' .. TEAM_RESOURCES[coalition.side.BLUE] .. ' points\n' .. 'RED Team Resources: ' .. TEAM_RESOURCES[coalition.side.RED] .. ' points', 10)
end

function CaucasusPendulum.purchaseTankAttack(_coalition, sourceZone, targetZone)
	env.info("PURCHASE TANK ATTACK called. coalition: " .. _coalition .. " source:" .. sourceZone .. " target: " .. targetZone)
	CaucasusPendulum.checkFOBs()
	local coalitionName = "RED"
	if (_coalition == coalition.side.BLUE) then
		coalitionName = "BLUE"
	end
	timer.scheduleFunction(CaucasusPendulum.SpawnAttackScheduled, {["targetZone"] = targetZone, ["sourceZone"] = sourceZone, ["coalitionName"] = coalitionName}, timer.getTime()+1)
end

function CaucasusPendulum.purchaseCASAttack(_coalition)
	env.info("PURCHASE CAS ATTACK called. coalition: " .. _coalition )

	CaucasusPendulum.checkFOBs()

	local coalitionName = "RED"
	if (_coalition == coalition.side.BLUE) then
		coalitionName = "BLUE"
	end


	if (_coalition == coalition.side.BLUE) then
		if BLUE_AI_CAS == nil or (BLUE_AI_CAS:AllOnGround() or (BLUE_AI_CAS:IsAlive() ~= true)) then	
			trigger.action.outText(coalitionName .. " CAS is now on station", 10 , false)
			timer.scheduleFunction(CaucasusPendulum.blueCas, {}, timer.getTime()+1)
		else
			trigger.action.outText(coalitionName .. " CAS is already in the air", 10 , false)
		end
	end
	if (_coalition == coalition.side.RED) then
		if RED_AI_CAS == nil or (RED_AI_CAS:AllOnGround() or (RED_AI_CAS:IsAlive() ~= true)) then	
			trigger.action.outText(coalitionName .. " CAS is now on station", 10 , false)
			timer.scheduleFunction(CaucasusPendulum.redCas, {}, timer.getTime()+1)
		else
			trigger.action.outText(coalitionName .. " CAS is already in the air", 10 , false)
		end
	end

end


function CaucasusPendulum.SpawnAttackScheduled(params)
	CaucasusPendulum.SpawnAttack(params["targetZone"], params["sourceZone"], params["coalitionName"], false)
end
--TODO: REMOVE!
--timer.scheduleFunction(CaucasusPendulum.SpawnAttackScheduled, {["targetzone"] = "ALPHA", ["sourcezone"] = "BRAVO", ["coalitionName"] = "RED"}, timer.getTime()+10)


function CaucasusPendulum.updateStrategicCommandMenu(_coalition)
	missionCommands.removeItemForCoalition(_coalition, {[1]='Strategic Command'})
	local menu = missionCommands.addSubMenuForCoalition(_coalition, 'Strategic Command')
	
	missionCommands.addCommandForCoalition(_coalition, 'Show Team Resources', menu, CaucasusPendulum.showTeamResources, _coalition)
	if (TEAM_RESOURCES[_coalition] >= PRICE_CASATTACK) then
		missionCommands.addCommandForCoalition(_coalition, 'Purchase CAS Attack', menu, CaucasusPendulum.purchaseCASAttack, _coalition)
	end
	
--CAPZONES = {"ALPHA", "BRAVO", "CHARLIE", "DELTA", "ECHO", "FOXTROT", "GOLF", "HOTEL", "INDIA", "JULIET", "KILO", "LIMA", "MIKE", "NOVEMBER", "OSCAR", "PAPA", "QUEBEC", "ROMEO", "SIERRA", "TANGO", "UNIFORM", "VICTOR", "WHISKEY", "XRAY", "YANKEE", "ZULU"}
--CAPZONE_ID = {"ALPHA" = 1, "BRAVO" = 2, "CHARLIE" = 3, "DELTA" = 4, "ECHO" = 5, "FOXTROT" = 6, "GOLF" = 7, "HOTEL" = 8, "INDIA" = 9, "JULIET" = 10, "KILO" = 11, "LIMA" = 12, "MIKE" = 13, "NOVEMBER" = 14, "OSCAR" = 15, "PAPA" = 16, "QUEBEC" = 17, "ROMEO" = 18, "SIERRA" = 19, "TANGO" = 20, "UNIFORM" = 21, "VICTOR" = 22, "WHISKEY" = 23, "XRAY" = 24, "YANKEE" = 25, "ZULU" = 26}

	if (TEAM_RESOURCES[_coalition] >= PRICE_TANKATTACK) then
		local tankmenu = missionCommands.addSubMenuForCoalition(_coalition, 'Purchase Tank Attack (Price: ' .. PRICE_TANKATTACK .. 'pt)', menu)

		for _capzone, _capzoneStatus in pairs(CAPZONE_STATUS) do
			env.info("_capzone=" .. _capzone .. " _capzoneStatus=" .. _capzoneStatus)
			local nextCapzoneID 
			if (_coalition == coalition.side.BLUE) then
				nextCapzoneID = CAPZONE_ID[_capzone] + 1
			else
				nextCapzoneID = CAPZONE_ID[_capzone] - 1
			end
			if (nextCapzoneID < 27 and nextCapzoneID > 0 and nextCapzoneID ~= 13) then --Don't allow ground attacks on Mike which is such a center airfield, manual attacks are required
				local nextCapzoneName = CAPZONES[nextCapzoneID]
				local nextCapzoneStatus = CAPZONE_STATUS[nextCapzoneName]
				env.info("nextCapzoneName=" .. nextCapzoneName)
				env.info("nextCapzoneStatus=" .. nextCapzoneStatus)
				if (_capzoneStatus == _coalition and nextCapzoneStatus ~= _coalition) then
					missionCommands.addCommandForCoalition(_coalition, 'Purchase Tank Attack on '.. nextCapzoneName, tankmenu, CaucasusPendulum.purchaseTankAttack, _coalition, _capzone, nextCapzoneName)
				end
			end
		end
	end

end


-- reschedule for users that change slot or coalition
RADIO_FREQUENCIES_MENU_SCHEDULER = SCHEDULER:New(nil,
  function()
    -- ADD MENUS FOR RED
    CaucasusPendulum.addRadioMenus(1)
    -- ADD MENUS FOR BLUE
    CaucasusPendulum.addRadioMenus(2)
  end, {}, 0, 60, 0 )

CaucasusPendulum.updateStrategicCommandMenu(coalition.side.BLUE)
CaucasusPendulum.updateStrategicCommandMenu(coalition.side.RED)

env.info("Dynamic Conflict RADIO FREQUENCIES FUNCTIONS loaded ...")
trigger.action.outText("Dynamic Conflict RADIO FREQUENCIES FUNCTIONS loaded ...", 10)

-- SCORING ***************************************************************************************

CaucasusPendulumScore = SCORING:New( "Caucasus Pendulum" )
CaucasusPendulumScore:SetScaleDestroyScore( 100 )
CaucasusPendulumScore:SetScaleDestroyPenalty( 200 )
CaucasusPendulumScore:SetMessagesHit( false )
CaucasusPendulumScore:SetMessagesDestroy( true )
CaucasusPendulumScore:SetMessagesToAll( true )
CaucasusPendulumScore:AddZoneScore(AlphaZone, 50)
CaucasusPendulumScore:AddZoneScore(BravoZone, 50)
CaucasusPendulumScore:AddZoneScore(CharlieZone, 40)
CaucasusPendulumScore:AddZoneScore(DeltaZone, 40)
CaucasusPendulumScore:AddZoneScore(EchoZone, 30)
CaucasusPendulumScore:AddZoneScore(FoxtrotZone, 30)
CaucasusPendulumScore:AddZoneScore(GolfZone, 20)
CaucasusPendulumScore:AddZoneScore(HotelZone, 20)
CaucasusPendulumScore:AddZoneScore(IndiaZone, 20)
CaucasusPendulumScore:AddZoneScore(JulietZone, 20)
CaucasusPendulumScore:AddZoneScore(KiloZone, 20)
CaucasusPendulumScore:AddZoneScore(LimaZone, 20)
CaucasusPendulumScore:AddZoneScore(MikeZone, 20)
CaucasusPendulumScore:AddZoneScore(NovemberZone, 50)
CaucasusPendulumScore:AddZoneScore(OscarZone, 50)
CaucasusPendulumScore:AddZoneScore(PapaZone, 50)
CaucasusPendulumScore:AddZoneScore(QuebecZone, 20)
CaucasusPendulumScore:AddZoneScore(RomeoZone, 20)
CaucasusPendulumScore:AddZoneScore(SierraZone, 20)
CaucasusPendulumScore:AddZoneScore(TangoZone, 20)
CaucasusPendulumScore:AddZoneScore(UniformZone, 30)
CaucasusPendulumScore:AddZoneScore(VictorZone, 50)
CaucasusPendulumScore:AddZoneScore(WhiskeyZone, 40)
CaucasusPendulumScore:AddZoneScore(XrayZone, 40)
CaucasusPendulumScore:AddZoneScore(YankeeZone, 50)
CaucasusPendulumScore:AddZoneScore(ZuluZone, 50)

CaucasusPendulumScore:AddZoneScore(ZuluZone, 50)

CaucasusPendulumScore:AddZoneScore(BlueCommandZone, 100)
CaucasusPendulumScore:AddZoneScore(RedCommandZone, 100)

env.info("Dynamic Conflict SCORING loaded ...")
trigger.action.outText("Dynamic Conflict SCORING loaded ...", 10)


-- END ***************************************************************************************

-- Mission timer chat
RESTART_NOTICE_SCHEDULER = SCHEDULER:New(nil,
  function()
    timeSecs = timer.getAbsTime() - timer.getTime0()
	timeLeft = 28700 - timeSecs
	timeLeftMinutesTotal = math.floor((timeLeft / 60.0))
	timeLeftHours = math.floor((timeLeftMinutesTotal / 60.0))
	timeLeftMinutes = math.floor(((timeLeft - (timeLeftHours*60.0*60.0)) / 60.0))
	if (timeLeftMinutesTotal > 60) then
      env.info("Server restart in: " .. timeLeftHours .. " hours " .. timeLeftMinutes .. " minutes.")
      trigger.action.outText("Server restart in: " .. timeLeftHours .. " hours " .. timeLeftMinutes .. " minutes.", 10)
      trigger.action.outText("Live map, SRS and Discord at https://167dgn.airforce", 10)
	end
  end, {}, 0, 900, 0 )

RESTART_NOTICE_FINAL_SCHEDULER = SCHEDULER:New(nil,
  function()
    timeSecs = timer.getAbsTime() - timer.getTime0()
	timeLeft = 28700 - timeSecs
	timeLeftMinutesTotal = math.floor((timeLeft / 60.0))
	timeLeftHours = math.floor((timeLeftMinutesTotal / 60.0))
	timeLeftMinutes = math.floor(((timeLeft - (timeLeftHours*60.0*60.0)) / 60.0))
	if (timeLeftMinutesTotal < 60 and timeLeftMinutesTotal > 0) then
      env.info("NOTICE: Server restart in " .. timeLeftHours .. " hours " .. timeLeftMinutes .. " minutes.")
      trigger.action.outText("NOTICE: Server restart in " .. timeLeftHours .. " hours " .. timeLeftMinutes .. " minutes.", 10)
      trigger.action.outText("Live map, SRS and Discord at https://167dgn.airforce", 10)
	end
  end, {}, 0, 300, 0 )


env.info("Dynamic Conflict loaded OK ...")
trigger.action.outText("Dynamic Conflict loaded OK ...", 10)