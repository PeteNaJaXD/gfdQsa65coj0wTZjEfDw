
getgenv().Script_Setting = {}


local Race_Skill = {
    ['Ghoul'] = 'Heightened Senses',
    ['Human'] = 'Last Resort',
    ['Cyborg'] = 'Energy Core',
    ['Skypiea'] = 'Heavenly Blood',
    ['Mink'] = 'Agility',
    ['Fishman'] = 'Water Body',
}

local Library : table = loadstring(request({Url = "https://raw.githubusercontent.com/CFrame3310/UI/main/Linoria.lua",Method = "GET"}).Body)()
Library:Notify("Loaded Script.")
local Window = Library:CreateWindow({
    Title = 'Auto Race Awaken (Not Fully)',
    Center = true, 
    AutoShow = true,
})

local Tabs = {
    General = Window:AddTab('General'),
}

local Group = {
	Main_Group = Tabs.General:AddLeftGroupbox('Main'),
}

Group.Main_Group:AddToggle('Auto Race Trial', {
    Text = 'Auto Race Trial',
    Default = false,
}):OnChanged(function(v)
    getgenv().Script_Setting['Auto_Race_Trial'] = v
end) 

Group.Main_Group:AddToggle('TP to Race Door', {
    Text = 'TP to Race Door',
    Default = false,
}):OnChanged(function(v)
    getgenv().Script_Setting['Race_Door_TP'] = v
end) 

Group.Main_Group:AddToggle('Reset Character', {
    Text = 'Reset Character',
    Default = false,
}):OnChanged(function(v)
    getgenv().Script_Setting['Reset_Character'] = v
end) 

Group.Main_Group:AddToggle('Enabled Race Skill', {
    Text = 'Enabled Race Skill',
    Default = false,
}):OnChanged(function(v)
    getgenv().Script_Setting['Enabled_Race_Skill'] = v
end) 

task.spawn(function()
    while true do task.wait()
        local success, err =  pcall(function()
            if getgenv().Script_Setting['Enabled_Race_Skill'] then
                local Host = game.Players['pete9973']
                local Host_Race = Host.Data.Race.Value
                if Host.Character.HumanoidRootPart:FindFirstChild(Race_Skill[Host_Race]) then
                     game:GetService("ReplicatedStorage").Remotes.CommE:FireServer('ActivateAbility')
                end
            end
        end)
        if not success then warn(err) end
    end
end)

task.spawn(function()
    while true do task.wait()
        local success, err =  pcall(function()
            if getgenv().Script_Setting['Race_Door_TP'] and not LocalPlayer().PlayerGui.Main.Timer.Visible then
                local Teleport_Spawn = game:GetService("Workspace").Map["Temple of Time"].TeleportSpawn
                local My_Race = LocalPlayer().Data.Race.Value
                local Door = game:GetService("Workspace").Map["Temple of Time"][My_Race..'Corridor'].Door.Entrance
                if Magnitude(Teleport_Spawn.Position) > 1000 then
                    repeat task.wait() 
                        TP(Teleport_Spawn.CFrame)
                    until not getgenv().Script_Setting['Race_Door_TP'] or Magnitude(Teleport_Spawn.Position) <= 10 or LocalPlayer().PlayerGui.Main.Timer.Visible
                else
                    repeat task.wait() 
                        Tween(Door.CFrame)
                    until not getgenv().Script_Setting['Race_Door_TP'] or Magnitude(Teleport_Spawn.Position) > 1000 or LocalPlayer().PlayerGui.Main.Timer.Visible
                    StopTween(getgenv().Script_Setting['Race_Door_TP'])
                end
            end
        end)
        if not success then warn(err) end
    end
end)

task.spawn(function()
    while true do task.wait()
        local success, err =  pcall(function()
            if getgenv().Script_Setting['Reset_Character'] and game:GetService("Workspace").Map["Temple of Time"].FFABorder.Forcefield.Transparency < 1 and LocalPlayer().PlayerGui.Main.Timer.Visible then
                Humanoid():Destroy()
            end
        end)
        if not success then warn(err) end
    end
end)

task.spawn(function()
    while true do task.wait()
        local success, err =  pcall(function()
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
                    repeat task.wait()
                        Tween(CFrame.new(28293.2109375, 14896.54296875, 84.48397827148438))
                    until not getgenv().Script_Setting['Auto_Race_Trial'] or LocalPlayer().PlayerGui.Main.Timer.Visible or game:GetService("Workspace").Map["Temple of Time"].FFABorder.Forcefield.Transparency < 1
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
         if not success then warn(err) end
    end
end)

task.spawn(function()
    while true do task.wait()
        pcall(Farm_BC, getgenv().Script_Setting['Auto_Race_Trial'] or getgenv().Script_Setting['Race_Door_TP'])
    end
end)