local TickPerSec
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
	if not Data['PollenPerSec'] then Data['PollenPerSec'] = Pollen end

    if tick() - TickPerSec >= 1 then
        Data['PollenPerSec'] = math.floor(Pollen - Data['PollenPerSec'])
        Data['HoneyPerSec'] = math.floor(Honey - Data['HoneyPerSec'])
        TickPerSec = tick()
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
                            ["name"] = "Honey Per Sec:",
                            ["value"] = tostring(Data['HoneyPerSec']),
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
            Headers = ["content-Type"] = "application/json"
        })
        return
    end
    

end