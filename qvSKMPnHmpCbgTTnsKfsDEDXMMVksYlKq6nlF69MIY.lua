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
	return LocalPlayer()
end

function Character() : Model
	return LocalPlayer().Character or LocalPlayer().CharacterAdded:Wait()
end

function Humanoid() : BasePart
	return Character().HumanoidRootPart or Character().PrimaryPart
end

function HumanoidRootPart() : BasePart
	return Character().Humanoid
end

function Magnitude(pos : Vector3) : number
	return (HumanoidRootPart().Position - CFrameToPos(pos)).Magnitude
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
    HumanoidRootPart().CFrame = PosToCFrame(pos)
end

function Tween(Pos)
    local CPos = PosToCFrame(Pos)
    local PPos =  CFrameToPos(Pos)
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
    else
        Speed = math.huge
    end
    _G.TweenPlayer = game:GetService("TweenService"):Create(HumanoidRootPart(),TweenInfo.new(Distance/Speed, Enum.EasingStyle.Linear),{CFrame = CPos})
    
    if Magnitude(PPos) <= 150 then
        _G.TweenPlayer:Cancel()
        TP(CPos)
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

function CommF_(...)
    return game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(...)
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

    local Main = MainGUI()
    if MainGUI():FindFirstChild("ChooseTeam") then
        for _, v in pairs(Property) do
            Main[v] = not Main[v]
            if Team == 'Marines' and v == 'CrewButton' then 
                Main['CrewButton'] = false 
            end
        end
    end
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


CreateFile()
LoadSetting()

local Library : table = loadstring(request({Url = "https://raw.githubusercontent.com/CFrame3310/UI/main/Linoria.lua",Method = "GET"}).Body)()
Library:Notify("Loaded Script.")
local Window = Library:CreateWindow({
    Title = 'Untitled Hub',
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
                            Tween(CFrame.new(DataList.QuestPos))
                            if Magnitude(Data.QuestPos).Magnitude <= 3 then
                                CommF_("StartQuest", Data.QuestName, Data.QuestLevel)
                            end
                        until not getgenv().Script_Setting['Auto_Farm_Level'] or IsQuestVisible()
                        StopTween(getgenv().Script_Setting['Auto_Farm_Level'])
                    elseif IsQuestVisible() then
                        if game.Workspace.Enemies:FindFirstChild(Data.Mob) then
                            for i,v in pairs(game.Workspace.Enemies:GetChildren()) do
                                if v.Name == Data.Mob and v:FindFirstChild('HumanoidRootPart') and v:FindFirstChild('Humanoid') and v.Humanoid.Health > 0 then
--[[                                     v.HumanoidRootPart.CanCollide = false
                                    v.Humanoid.WalkSpeed = 0
                                    v.Head.CanCollide = false
                                    _G.Mon = v.Name
                                    _G.Pos = v.HumanoidRootPart.CFrame *]]
                                    StartMagnet = true
                                    repeat task.wait()
                                        Tween(v.HumanoidRootPart.CFrame * CFrame.new(0, 50, 0))
                                    until mixfarm or not getgenv().Script_Setting['Auto_Farm_Level'] or not v.Parent or v.Humanoid.Health <= 0 or not v:FindFirstChild('Humanoid') or not v:FindFirstChild('HumanoidRootPart') or not IsQuestVisible()
                                    StopTween(getgenv().Script_Setting['Auto_Farm_Level'])
                                    StartMagnet = false
                                end
                            end
                        else
                            for i,v in pairs(game.Workspace["_WorldOrigin"].EnemySpawns:GetChildren()) do
                                if v.Name == Data.Mob or v.Name:find(Data.Mob) then
                                    repeat task.wait()
                                        Tween(v.HumanoidRootPart.CFrame * CFrame.new(0, 50, 0))
                                    until Magnitude(v.Position + Vector3.new(0, 50, 0)) <= 5 or not getgenv().Script_Setting['Auto_Farm_Level'] or not IsQuestVisible()
                                    StopTween(getgenv().Script_Setting['Auto_Farm_Level'])
                                end--[[  ]]
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
    while true do task.wait()
        pcall(Farm_BC, getgenv().Script_Setting['Auto_Farm_Level'])
    end
end)