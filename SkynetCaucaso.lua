-- This script creates a complex IADS system with a variety of units.

-- Import the Skynet IADS library.
require("skynet-iads")

-- Create a new Skynet IADS object.
skynet = SkynetIADS()

-- Add a function to add units with a certain prefix.
def add_units_with_prefix(prefix):
    units = []
    for unit in skynet.get_units():
        if unit.name.startswith(prefix):
            units.append(unit)
    return units

-- Add radar units to the IADS system.
radar_units = add_units_with_prefix("EW-RED")
for radar_unit in radar_units:
    skynet.add_radar(radar_unit)

-- Add SAM sites to the IADS system.
sam_sites = add_units_with_prefix("SAM-RED")
for sam_site in sam_sites:
    skynet.add_sam_site(sam_site)

-- Add power generators to the IADS system.
power_generators = add_units_with_prefix("GEN-RED")
for power_generator in power_generators:
    skynet.add_power_generator(power_generator)

-- Add command centers to the IADS system.
command_centers = add_units_with_prefix("CC-RED")
for command_center in command_centers:
    skynet.add_command_center(command_center)

-- Set the radars' detection range.
for radar in radar_units:
    radar.set_detection_range(100)

-- Set the SAM sites' engagement range.
for sam_site in sam_sites:
    sam_site.set_engagement_range(50)

-- Start the IADS system.
skynet.start()

-- Wait for the player to enter the IADS system's airspace.
while true do
    sleep(1)
    if skynet.is_player_in_range(radar_units[0]) then
        break
    end
end

-- The player is now in the IADS system's airspace.
-- The radars will detect the player and the SAM sites will engage the player.

-- If a power generator is destroyed, the radars and SAM sites will be disabled.
for power_generator in power_generators:
    if power_generator.is_destroyed():
        print("Power generator destroyed!")
        for radar in radar_units:
            radar.disable()
        for sam_site in sam_sites:
            sam_site.disable()

-- If a command center is destroyed, the radars and SAM sites will be unable to receive orders.
for command_center in command_centers:
    if command_center.is_destroyed():
        print("Command center destroyed!")
        for radar in radar_units:
            radar.set_alert_state(AlertState.PASSIVE)
        for sam_site in sam_sites:
            sam_site.set_alert_state(AlertState.PASSIVE)
