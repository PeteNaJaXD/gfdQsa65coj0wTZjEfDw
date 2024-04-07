local TickPerSec, TickPerHour
local Data = {}
local Url = 'https://discordapp.com/api/webhooks/969887424178171987/8YfqfG-TvpIWCwQQ1dckVL50KtN5BArOz69Ibst8_Uy8kx9WQQXD-W7f-E0z3Qx_VqbQ'
function LocalPlayer() : Player
	return game:GetService("Players").LocalPlayer
end

while true do task.wait()
	local CoreStats : Folder = LocalPlayer().CoreStats
	local Honey = CoreStats.Honey.Value
	local Pollen = CoreStats.Pollen.Value
	if not TickPerSec then TickPerSec = tick() end
    if not TickPerHour then TickPerHour = tick() end
	if not Data['PollenPerSec'] then Data['PollenPerSec'] = Pollen end
    if not Data['PollenPerHour'] then Data['PollenPerHour'] = Pollen end

    if tick() - TickPerSec >= 1 then
        Data['PollenPerSec'] = math.floor(Pollen - Data['PollenPerSec'])
        TickPerSec = tick()
    end
    
    if tick() - TickPerHour >= 3600 then 
        Data['PollenPerHour'] = math.floor(Pollen - Data['PollenPerHour'])
        TickPerHour = tick()
    end

    local data = {
        ["embeds"] = {
            {
                ["fields"] = {
                    {
                        ["name"] = "Pollen Per Sec:",
                        ["value"] = tostring(Data['PollenPerSec']),
                        ["inline"] =  false
                    },
                    {
                        ["name"] = "Honey Per Hour:",
                        ["value"] = tostring(Data['PollenPerHour']),
                        ["inline"] =  false
                    }
                }
            }
        }
    }
    request({
        Url = hook,
        Body = game:GetService("HttpService"):JSONEncode(data),
        Method = "POST",
        Headers = {
            ["content-Type"] = "application/json"
        }
    })

    task.wait(120) 
end