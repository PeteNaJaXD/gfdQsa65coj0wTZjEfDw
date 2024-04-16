if game.PlaceId == 2753915549 then
    W1 = true 
elseif game.PlaceId == 4442272183 then
    W2 = true
elseif game.PlaceId == 7449423635 then
    W3 = true
else 
    game.Players.LocalPlayer:Kick('Invaild game.')
    task.wait(5)
    game:Shutdown()
end


function ToPos(pos)
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

function ToCFrame(pos)
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

local PlaceID : number = game.PlaceId
local Player : number = game.Players.LocalPlayer.UserId 
local Folder_Name =  'CFrame Hub'
local Sub_Folder = `{Folder_Name}/{PlaceID}`
local File_Name = `{Sub_Folder}/{Player}.json`
local HttpService = game:GetService('HttpService')
local Fake_Encode = HttpService:JSONEncode({})

getgenv().Script_Setting = {}

function CreateFile()
	print(File_Name)
	if not isfolder(Folder_Name) then makefolder(Folder_Name) end
	if not isfolder(Sub_Folder) then makefolder(Sub_Folder) end
	if not isfile(File_Name) then writefile(File_Name, Fake_Encode) end
end

function SaveSetting()
	local Encode = HttpService:JSONEncode(getgenv().Script_Setting)
	if not isfile(File_Name) then writefile(File_Name, Encode) end
	writefile(File_Name, Encode)
end

function LoadSetting()
	local succes, err = pcall(function()
		local Decode = HttpService:JSONDecode(readfile(File_Name))
		print(Decode)

		if isfile(File_Name) then
			getgenv().Script_Setting = Decode
		end
	end)

	if not succes then 
		warn(err)
		getgenv().Script_Setting = {}
	end
end

function LocalPlayer() : Player
	return game.Players.LocalPlayer
end

function Character() : Model
	return LocalPlayer().Character or LocalPlayer().CharacterAdded:Wait()
end

function HumanoidRootPart() : BasePart
	return Character().HumanoidRootPart or Character().PrimaryPart
end

function Humanoid() : BasePart
	return Character().Humanoid
end

function Magnitude(pos : Vector3) : number
	return (HumanoidRootPart().Position - ToPos(pos)).Magnitude
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

function TP(pos)
    HumanoidRootPart().CFrame = ToCFrame(pos)
end

function Tween(Pos)
    local CPos = ToCFrame(Pos)
    local PPos =  ToPos(Pos)
    local Distance = Magnitude(PPos)
    local Speed
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
    end
    _G.TweenPlayer = game:GetService("TweenService"):Create(HumanoidRootPart(),TweenInfo.new(Distance/Speed, Enum.EasingStyle.Linear),{CFrame = CPos})
    
    if Magnitude(PPos) <= 150 then
        _G.TweenPlayer:Cancel()
        TP(CPos)
    else
        _G.TweenPlayer:Play()
    end
end

function StopTween()
    _G.BringMob = false
	Remove_BC()
	_G.TweenPlayer:Cancel()
end

function CommF_(...)
    return game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(...)
end

function CommE(...)
    return game:GetService("ReplicatedStorage").Remotes.CommE:FireServer(...)
end

local Property = {
    'ChooseTeam',
    'Mute',
    'Settings',
    'CrewButton',
    'AlliesButton',
    'HomeButton',
    'Code',
    'Compass',
    'MenuButton',
    'Beli',
    'Fragments',
    'Level',
    'HP',
    'Energy'
}

function MainGUI()
    return LocalPlayer().PlayerGui.Main
end

function JoinTeam(Team)
    if Team ~= 'Pirates' and Team ~= 'Marines' then Team = 'Pirates' end

    CommF_("SetTeam",Team)
    game:GetService("Workspace").Camera.CameraType = 'Custom'
    game:GetService("Workspace").Camera.CameraSubject =  Humanoid()
    local Main = MainGUI()
    if MainGUI():FindFirstChild("ChooseTeam") then
        for _, v in pairs(Property) do
            Main[v].Visible = not Main[v].Visible
        end
    end
    print(Team == 'Pirates' )
    Main['CrewButton'].Visible = Team == 'Pirates' 

end

function FindNilInstances(Name)
    for i,v in pairs(getnilinstances()) do
        if v.Name == Name or v.Name:find(Name) then
            return true
        end
    end
    return false
end

function MoveNilInstances(Name)
    for i,v in pairs(getnilinstances()) do
        if (v.Name == Name or v.Name:find(Name)) and v:GetAttribute('Active') ~= nil then
            v:SetAttribute('Active' , true) 
        end
    end
    return
end

function IsQuestVisible()
    return MainGUI().Quest.Visible
end

repeat task.wait()
    pcall(function()
        if MainGUI():FindFirstChild("ChooseTeam") and MainGUI().ChooseTeam.Visible == true then
            JoinTeam(_G.Team)
        end
    end)
until LocalPlayer().Neutral == false or not MainGUI():FindFirstChild("ChooseTeam")

pcall(function()        
    game.ReplicatedStorage.Effect.Container.Death:Destroy()
    game.ReplicatedStorage.Effect.Container.Respawn:Destroy()
    game.ReplicatedStorage.Effect.Container.Hit:Destroy()
end)

function AutoCheckQuest()
    local Level = LocalPlayer().Data.Level.Value
    local Guide = require(game:GetService("ReplicatedStorage").GuideModule)
    local Quest = require(game:GetService("ReplicatedStorage").Quests)
    
    local NPCList = Guide['Data']['NPCList']
    local LastQuestLevel = Guide['Data']['LastQuestLevel']
    local LastClosestNPC = Guide['Data']['LastClosestNPC']

    local Data = {}

    for i,v in pairs(NPCList) do
        if i.Parent.Name == LastClosestNPC then
            Data.QuestPos = i.CFrame
            break
        end
    end

    for QuestName,QuestsLevel in pairs(Quest) do
        for QuestIndex = 1, #QuestsLevel do
            if QuestsLevel[QuestIndex].LevelReq == tonumber(LastQuestLevel) then
                if QuestIndex == 3 then QuestIndex -= 1 end 
                Data.QuestName = QuestName
                Data.QuestLevel = QuestIndex
                Data.Mob = QuestsLevel[QuestIndex].Name
                break 
            end
        end
    end

    if LastQuestLevel == 0 then
        Data.Mob = "Bandit"
        Data.QuestLevel = 1
        Data.QuestName = "BanditQuest1"
        Data.QuestPos = CFrame.new(1059.37195, 15.4495068, 1550.4231)
    elseif LastQuestLevel == 10 then
        Data.Mob = "Monkey"
        Data.QuestLevel = 1
        Data.QuestName = "JungleQuest"
        Data.QuestPos = CFrame.new(-1598.08911, 35.5501175, 153.377838)
    elseif LastQuestLevel == 15 then
        Data.Mob = "Gorilla"
        Data.QuestLevel = 2
        Data.QuestName = "JungleQuest"
        Data.QuestPos = CFrame.new(-1598.08911, 35.5501175, 153.377838)
    elseif LastQuestLevel == 130 then
        Data.Mob = "Chief Petty Officer"
        Data.QuestLevel = 1
        Data.QuestName = "MarineQuest2"
        Data.QuestPos = CFrame.new(-5039,27,4324)
    end

    return Data
end

local Module = require(game:GetService("Players").LocalPlayer.PlayerScripts.CombatFramework)
local CombatFramework = debug.getupvalues(Module)[2]
local CameraShakerR = require(game.ReplicatedStorage.Util.CameraShaker)

task.spawn(function()
    while true do task.wait()
        pcall(function()
            CameraShakerR:Stop()
            CombatFramework.activeController.attacking = false
            CombatFramework.activeController.timeToNextAttack = -(math.huge^math.huge^math.huge)
            CombatFramework.activeController.increment = 4
            CombatFramework.activeController.hitboxMagnitude = 100
            CombatFramework.activeController.blocking = false
            CombatFramework.activeController.timeToNextBlock = 0
            CombatFramework.activeController.focusStart = 0
            CombatFramework.activeController.humanoid.AutoRotate = true
        end)
    end
end)

function WeaponModel() 
    local AC = CombatFramework.activeController
    local Blades = AC.blades[1]
    if not Blades then return end
    while Blades.Parent~=game.Players.LocalPlayer.Character do Blades=Blades.Parent end
    return Blades
end

function getHits(Size)
    local Hits = {}
    local Enemies = workspace.Enemies:GetChildren()
    local Characters = workspace.Characters:GetChildren()
    for i=1,#Enemies do 
        local v = Enemies[i]
        local Human = v:FindFirstChildOfClass("Humanoid")
        if Human and Human.RootPart and Human.Health > 0 and game.Players.LocalPlayer:DistanceFromCharacter(Human.RootPart.Position) < Size+55 then
            table.insert(Hits,Human.RootPart)
        end
    end
    --[[ for i=1,#Characters do 
        local v = Characters[i]
        if v ~= game.Players.LocalPlayer.Character then
            local Human = v:FindFirstChildOfClass("Humanoid")
            if Human and Human.RootPart and Human.Health > 0 and game.Players.LocalPlayer:DistanceFromCharacter(Human.RootPart.Position) < Size+55 then
                table.insert(Hits,Human.RootPart)
            end
        end
    end *]]
    return Hits
end

function Boost()
    spawn(function()
        if CombatFramework.activeController then
            game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("weaponChange",tostring(WeaponModel()))
        end
    end)
end


local cdnormal = 0
local Animation = Instance.new("Animation")
function Hit()
    local ac = CombatFramework.activeController
    if ac and ac.equipped then
        coroutine.wrap(function()
            --if tick() - cdnormal > 7 then
                ac:attack()
                Animation.AnimationId = ac.anims.basic[2]
                ac.humanoid:LoadAnimation(Animation):Play(0.01, 0.01)
                game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("hit", getHits(60), 1, "")
                spawn(function()
                    if ac then
                        game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("weaponChange",tostring(WeaponModel()))
                    end
                end)
                task.wait(.1)
               -- cdnormal = tick()
            --[[ else
                Animation.AnimationId = ac.anims.basic[2]
                ac.humanoid:LoadAnimation(Animation):Play(0.01, 0.01)
                game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("hit", getHits(60), 1, "") *]]
            --end
        end)()
    end
end

function Attack()
    Hit()
    --Boost()
end

function GetTool()
    local Tool_Type = getgenv().Script_Setting['Selected_Weapon']
    for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        if v:IsA("Tool") and v.ToolTip == Tool_Type then
            _G.Tool = v
            return
        end
    end
    return
end

function Equip()
    local succes, err = pcall(function()
        GetTool()
        print(_G.Tool)
        if Humanoid().Health > 0 and not Character():FindFirstChildOfClass('Tool') and Character():FindFirstChildOfClass('Tool') ~= _G.Tool.Name then
            if not Character():FindFirstChild("HasBuso") then
                CommF_("Buso")
            end
            Humanoid():EquipTool(_G.Tool)
        else
            Attack()
        end
    end)
    if not succes then warn('Equip Weapon status : ', err) end
end

CreateFile()
LoadSetting()

local Library : table = loadstring(request({Url = "https://raw.githubusercontent.com/CFrame3310/UI/main/Linoria.lua",Method = "GET"}).Body)()
Library:Notify("Loaded Script.")
local Window = Library:CreateWindow({
    Title = 'Millemium RBLX Script',
    Center = true, 
    AutoShow = true,
})

local Tabs = {
    General = Window:AddTab('General'),
    ['UI Settings'] = Window:AddTab('Settings'),
}

local Group = {
	Main_Group = Tabs.General:AddLeftGroupbox('Main'),
	Setting_Group = Tabs.General:AddRightGroupbox('Setting')
}


Group.Main_Group:AddToggle('Auto Farm Level', {
    Text = 'Auto Farm Level',
    Default = getgenv().Script_Setting['Auto_Farm_Level'],
}):OnChanged(function(v)
    getgenv().Script_Setting['Auto_Farm_Level'] = v
	SaveSetting()
end) 

Group.Setting_Group:AddDropdown('Select Weapon', {
	Text = 'Select Weapon',
	Values = {"Melee","Blox Fruit","Sword","Gun"},
	Default = getgenv().Script_Setting['Selected_Weapon'] or 'Melee'
}):OnChanged(function(v)
    getgenv().Script_Setting['Selected_Weapon'] = v
	SaveSetting()
end) 

task.spawn(function()
    while true do task.wait()
        local success, err = pcall(function()
            if getgenv().Script_Setting['Auto_Farm_Level'] then
                if not mixfarm then
                    local Data = AutoCheckQuest()
                    if not string.find(MainGUI().Quest.Container.QuestTitle.Title.Text, Data.Mob) then
                        CommF_("AbandonQuest")
                    end
                    if LocalPlayer().Character.Humanoid.Health > 0 and not IsQuestVisible() then
                        repeat task.wait()
                            Tween(ToCFrame(Data.QuestPos))
                            if Magnitude(ToPos(Data.QuestPos)) <= 3 then
                                task.wait(.5)
                                CommF_("StartQuest", Data.QuestName, Data.QuestLevel)
                            end
                        until not getgenv().Script_Setting['Auto_Farm_Level'] or IsQuestVisible()
                        if not getgenv().Script_Setting['Auto_Farm_Level'] then StopTween() return end
                    elseif IsQuestVisible() then
                        if game.Workspace.Enemies:FindFirstChild(Data.Mob) then
                            for i,v in pairs(game.Workspace.Enemies:GetChildren()) do
                                if v.Name == Data.Mob and v:FindFirstChild('HumanoidRootPart') and v:FindFirstChild('Humanoid') and v.Humanoid.Health > 0 then
                                    v.Humanoid.WalkSpeed = 0
                                    v.Humanoid:ChangeState(14)
                                    v.HumanoidRootPart.CanCollide = false
                                    v.Head.CanCollide = false
                                    _G.Mon = v.Name
                                    _G.Pos = v.HumanoidRootPart.CFrame
                                    _G.BringMob = true
                                    repeat task.wait()
                                        Equip()
                                        Tween(ToCFrame(v.HumanoidRootPart.Position) * CFrame.new(0, 50, 0))
                                    until mixfarm or not getgenv().Script_Setting['Auto_Farm_Level'] or not v.Parent or v.Humanoid.Health <= 0 or not v:FindFirstChild('Humanoid') or not v:FindFirstChild('HumanoidRootPart') or not IsQuestVisible()
                                    if not getgenv().Script_Setting['Auto_Farm_Level'] then StopTween() return end
                                    _G.BringMob = false
                                end
                            end
                        else
                            if FindNilInstances(Data.Mob) then MoveNilInstances(Data.Mob) end
                            for i,v in pairs(game.Workspace["_WorldOrigin"].EnemySpawns:GetChildren()) do
                                if v.Name == Data.Mob or v.Name:find(Data.Mob) then
                                    repeat task.wait()
                                        Tween(v.CFrame * CFrame.new(0, 50, 0))
                                    until Magnitude(v.Position + Vector3.new(0, 50, 0)) <= 1 or not getgenv().Script_Setting['Auto_Farm_Level'] or not IsQuestVisible()
                                    wait(.25)
                                    if not getgenv().Script_Setting['Auto_Farm_Level'] then StopTween() return end
                                end
                            end
                        end
                    end
                end
            end
        end)
        if not success then warn('Auto Farm : ', err) end
    end
end)

task.spawn(function() 
    while task.wait() do
        if _G.BringMob then
            local success, err = pcall(function() -- v.Name == _G.Mon and (game.Players.LocalPlayer.Character.HumanoidRootPart.Position-v.HumanoidRootPart.Position).Magnitude
                for i,v in pairs(game.Workspace.Enemies:GetChildren()) do
                    if v.Name == _G.Mon and Magnitude(_G.Pos) <= 550 and v:FindFirstChild('HumanoidRootPart') and v:FindFirstChild('Humanoid') and v.Humanoid.Health > 0 then
                        v.Humanoid.WalkSpeed = 0
                        v.HumanoidRootPart.CanCollide = false
                        v.Head.CanCollide = false
                        v.HumanoidRootPart.CFrame = _G.Pos
                        v.Humanoid:ChangeState(14)
                        if v.Humanoid:FindFirstChild("Animator") then
                            v.Humanoid:FindFirstChild("Animator"):Destroy()
                        end
                        if not v.HumanoidRootPart:FindFirstChild("BodyClip") then
                            local Noclip = Instance.new("BodyVelocity")
                            Noclip.Name = "BodyClip"
                            Noclip.Parent = v.HumanoidRootPart
                            Noclip.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
                            Noclip.Velocity = Vector3.new(0,0,0)
                        end
                        sethiddenproperty(game.Players.LocalPlayer, "MaximumSimulationRadius",  math.huge)
                        sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius",  9e20)
                    end
                end
            end)
            if not success then warn('Bring Mob : ', err) end
        end
    end
end)

task.spawn(function()
    while true do task.wait()
        pcall(Farm_BC, getgenv().Script_Setting['Auto_Farm_Level'])
    end
end)