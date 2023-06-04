-- Use local variables for frequently used globals
local PlayerPedId = PlayerPedId
local GetEntityCoords = GetEntityCoords
local SetWeatherTypeNow = SetWeatherTypeNow
local SetWeatherTypeNowPersist = SetWeatherTypeNowPersist
local SetOverrideWeather = SetOverrideWeather
local SetTimecycleModifier = SetTimecycleModifier
local SetExtraTimecycleModifier = SetExtraTimecycleModifier
local ClearOverrideWeather = ClearOverrideWeather
local ClearWeatherTypePersist = ClearWeatherTypePersist
local ClearExtraTimecycleModifier = ClearExtraTimecycleModifier
local ClearTimecycleModifier = ClearTimecycleModifier
local Wait = Wait

-- Use constants instead of literals
local DEFAULT_WEATHER = Config.DefaultWeather

-- Use a table to store the weather zones
local weatherZones = {}
for k,v in ipairs(Config.WeathersZones) do
  weatherZones[k] = {coord = v.coord, radius = v.radius, weathertype = v.weathertype,
    timecycles = v.timecycles, extratimecycle = v.extratimecycle}
end

-- Use a numeric for loop to iterate over the weather zones
CreateThread(function()
  while true do
    local ped = PlayerPedId()
    local coord = GetEntityCoords(ped)
    local n = #weatherZones -- Get the number of weather zones
    for i=1,n do -- Use a numeric for loop
      local zone = weatherZones[i] -- Get the current zone
      if #(coord - zone.coord) < zone.radius then -- Check the distance
        -- Set the weather type and time cycle modifier for the zone
        local weathertype = zone.weathertype 
        SetWeatherTypeNow(weathertype)
        SetWeatherTypeNowPersist(weathertype)
        SetOverrideWeather(weathertype)
        if zone.timecycles then
          SetTimecycleModifier(zone.timecycles)
          SetExtraTimecycleModifier(zone.extratimecycle)
        end
        -- Wait until the player leaves the zone
        while #(coord - zone.coord) < zone.radius  do
          coord = GetEntityCoords(ped)
          Wait(1500)
        end
        -- Reset the weather type and time cycle modifier to default
        Default()
        Wait(500)
      end
    end
    Wait(1000)
  end
end)

-- Define a function to reset the weather type and time cycle modifier to default
function Default()
  ClearOverrideWeather()
  ClearWeatherTypePersist()
  Wait(100)
  ClearExtraTimecycleModifier()
  ClearTimecycleModifier()
  SetOverrideWeather(DEFAULT_WEATHER)
  SetWeatherTypeNow(DEFAULT_WEATHER)
  SetWeatherTypeNowPersist(DEFAULT_WEATHER)
end
