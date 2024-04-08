getgenv().Script_Setting = {}

function CFrameToPos(pos)
	local convertion = {
		['Vector3'] = function(pos)
			return pos
		end,
		['CFrame'] = function(pos)
			return pos.Position
		end,
	}
	return convertion[typeof(pos)](pos)
end

function PosToCFrame(pos)
	local convertion = {
		['Vector3'] = function(pos)
			return CFrame.new(pos)
		end,
		['CFrame'] = function(pos)
			return pos
		end,
	}
	return convertion[typeof(pos)](pos)
end

function LocalPlayer() : Player
	return game:GetService("Players").LocalPlayer
end

function Character() : Model
	return LocalPlayer().Character or LocalPlayer().CharacterAdded:Wait()
end

function HumanoidRootPart() : BasePart
	return Character().HumanoidRootPart or Character().PrimaryPart
end

function Magnitude(pos : Vector3) : number
	return (HumanoidRootPart().Position - convertpos(pos)).Magnitude
end

function Create_BC()
	if not HumanoidRootPart():FindFirstChild("BC") then
		local Noclip : BodyVelocity = Instance.new("BodyVelocity",HumanoidRootPart())
		Noclip.Name = "BC"
		Noclip.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
		Noclip.Velocity = Vector3.new(0,0,0)
	end
end

function Remove_BC()
	if HumanoidRootPart():FindFirstChild("BC") then
		HumanoidRootPart():FindFirstChild("BC"):Destroy()
	end
end

function Farm_BC(Statement)
    NoClip(Statement)
    if Statement then
        Create_BC()
    else
        Remove_BC()
    end
end

function NoClip(Statement : boolean)
	for _,v in pairs(game:GetService('Players').LocalPlayer.Character:GetChildren()) do
		if v:IsA('BasePart') then
			v.CanCollide = not Statement
		end
	end
end

function Tween(Pos)
    local CPos = PosToCFrame(Pos)
    local PPos CFrameToPos(Pos)
    local Distance = Magnitude(PPos)
    if Distance <= 200 then
        Speed = 375
    elseif Distance <= 500 then
        Speed = 400
    elseif Distance <= 750 then
        Speed = 375
    elseif Distance <= 1000 then
        Speed = 350
    elseif Distance <= 1250 then
        Speed = 325
    elseif Distance <= 1500 then
        Speed = 300
    elseif Distance > 1500 then
        Speed = 275 
    else
        Speed = math.huge
    end
    _G.TweenPlayer = game:GetService("TweenService"):Create(HumanoidRootPart(),TweenInfo.new(Distance/Speed, Enum.EasingStyle.Linear),{CFrame = CPos})
    
    if Distance <= 150 then
        _G.TweenPlayer:Cancel()
        HumanoidRootPart().CFrame = P1
    else
        _G.TweenPlayer:Play()
    end
end

function StopTween(Statement)
	if not Statement then 
		Remove_BC()
		_G.TweenPlayer:Cancel()
	end
end


local Library : table = loadstring(request({Url = "https://raw.githubusercontent.com/CFrame3310/UI/main/Linoria.lua",Method = "GET"}).Body)()
Library:Notify("Loaded Script.")
local Window = Library:CreateWindow({
    Title = 'Untitled Hub',
    Center = true, 
    AutoShow = true,
})

local Tabs = {
    General = Window:AddTab('General'),
}

local Group = {
	Main_Group = Tabs.General:AddLeftGroupbox('Main'),
}

Group.Main_Group:AddToggle('Auto Farm Pollen', {
    Text = 'Auto Farm Pollen',
    Default = false,
}):OnChanged(function(v)
    getgenv().Script_Setting['Auto_Race_Trial'] = v
end) 

task.spawn(function()
    while true do task.wait()
        pcall(function()
            if getgenv().Script_Setting['Auto_Race_Trial'] then
                local My_Race = LocalPlayer().Data.Race.Value
                if My_Race == 'Ghoul' or My_Race == 'Human' then
                    for i,v in pairs(game.Workspace.Enemies:GetChildren()) do
                        if v:FindFirstChild('HumanoidRootPart') and v:FindFirstChild('Humanoid') then
                            sethiddenproperty(game.Players.LocalPlayer, "MaximumSimulationRadius",  math.huge)
                            sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius",  9e20)
                            v.Humanoid.Health = -100
                        end
                    end
                elseif My_Race == 'Cyborg' then
                    Tween(CFrame.new(28293.2109375, 14896.54296875, 84.48397827148438))
                    StopTween(getgenv().Script_Setting.AutoCompleteTrial)
                elseif My_Race == 'Skypiea' then
                    if game.Workspace.Map.SkyTrial.Model:FindFirstChild('FinishPart') then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Workspace.Map.SkyTrial.Model.FinishPart.CFrame
                    end
                elseif My_Race == 'Mink' then
                    if game:GetService("Workspace").Map.MinkTrial:FindFirstChild('Ceiling') then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").Map.MinkTrial.Ceiling.CFrame * CFrame.new(0,-5,0)
                    end
                end
            end
        end)
    end
end)

task.spawn(function()
    while true do task.wait()
        pcall(Farm_BC, getgenv().Script_Setting['Auto_Race_Trial'])
    end
end)