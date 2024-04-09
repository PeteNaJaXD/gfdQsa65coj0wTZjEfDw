---@diagnostic disable: undefined-global, trailing-space
type Array<T> = {[number] : T}

repeat task.wait()
	pcall(function()
		if not game:GetService("Players").LocalPlayer:FindFirstChild('Honeycomb') then
			for i = 6,1,-1 do
				game:GetService("ReplicatedStorage").Events.ClaimHive:FireServer(i)
			end
		end
	end)
until game:GetService("Players").LocalPlayer:FindFirstChild('Honeycomb')

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
	return game:GetService("Players").LocalPlayer
end

function Character() : Model
	return LocalPlayer().Character or LocalPlayer().CharacterAdded:Wait()
end

function HumanoidRootPart() : BasePart
	return Character().HumanoidRootPart or Character().PrimaryPart
end

function Magnitude(pos : Vector3) : number
	return (HumanoidRootPart().Position - CFrameToPos(pos)).Magnitude
end

function WalkTo(pos : Vector3)
	local new_pos = CFrameToPos(pos)
	Character().Humanoid:MoveTo(new_pos)
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

function NoClip(Statement : boolean)
	for _,v in pairs(game:GetService('Players').LocalPlayer.Character:GetChildren()) do
		if v:IsA('BasePart') then
			v.CanCollide = not Statement
		end
	end
	
end

function SendKeyEvent(Key)
	game:GetService("VirtualInputManager"):SendKeyEvent(true,Key,false,game)
	game:GetService("VirtualInputManager"):SendKeyEvent(false,Key,false,game)
end

function GetKeyTag()
	return LocalPlayer().PlayerGui.ScreenGui.ActivateButton.KeyTag.Visible
end

function Get_Maximum_Bees()
	local Self = LocalPlayer().Honeycomb.Value
	local bees = {}
	for i,v in pairs(game.Workspace.Honeycombs[tostring(Self)].Cells:GetChildren()) do
		if v.CellType.Value ~= 'Empty' then
			table.insert(bees,v)		
		end
	end
	return #bees
end

function Get_Maximum_Cells()
	local Self = LocalPlayer().Honeycomb.Value
	local Cells = {}
	for i,v in pairs(game.Workspace.Honeycombs[tostring(Self)].Cells:GetChildren()) do
		if v:FindFirstChild('Backplate') then
			table.insert(Cells,v)		
		end
	end
	return #Cells
end

function Part_To_Detect()
	if not getgenv().Part_To_Detect then
		getgenv().Part_To_Detect = Instance.new('Part')
	end
	local Field = game:GetService("Workspace").FlowerZones:FindFirstChild(getgenv().Script_Setting['Selected_Field'])

    Part_To_Detect.Anchored = true
    Part_To_Detect.Position = Field.Position
	Part_To_Detect.Size = Field.Size + Vector3.new(0,18,0)
    Part_To_Detect.BrickColor = BrickColor.new("Bright green")
    Part_To_Detect.Parent = Field
	Part_To_Detect.CanCollide = false
	Part_To_Detect.Transparency = 0.5
	Part_To_Detect.CastShadow = false
	Part_To_Detect.Name = 'Part To Detect'
end

function IsPlayerInField() : BasePart
	Part_To_Detect()

    local overlap : OverlapParams = OverlapParams.new()
	overlap.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
	overlap.FilterType = Enum.RaycastFilterType.Include

	local DetectPart = game:GetService("Workspace"):GetPartsInPart(Part_To_Detect, overlap)
	return #DetectPart > 0
end

function Tween(Pos,CanWalk)
	local CPos = PosToCFrame(Pos)
	local PPos = CFrameToPos(Pos)
	local Speed : number;
	local Dis : number = Magnitude(PPos)
	if Dis < 1000 then
		Speed = 300
	elseif Dis >= 100 then
		Speed = 200
	end
	local TService = game:GetService("TweenService")
	local Height = HumanoidRootPart().Position.Y - PPos.Y 
	if getgenv().Script_Setting['Safe_Mode'] and (Character().Humanoid.Health / Character().Humanoid.MaxHealth) * 100 <= 50 then
		repeat task.wait()                            
			_G.Tween = TService:Create(HumanoidRootPart(),TweenInfo.new(Dis/Speed,Enum.EasingStyle.Linear),{CFrame = CPos*CFrame.new(0,80,0)})
			_G.Tween:Play()
			Create_BC()
		until (Character().Humanoid.Health / Character().Humanoid.MaxHealth) * 100 >= 80 or not getgenv().Script_Setting['Safe_Mode']
		_G.Tween:Cancel()
		Remove_BC()
	else
		if CanWalk and IsPlayerInField() then
			Remove_BC()
			WalkTo(Pos)
		else
			_G.Tween = TService:Create(HumanoidRootPart(),TweenInfo.new(Dis/Speed,Enum.EasingStyle.Linear),{CFrame = CPos})
			_G.Tween:Play()
			Create_BC()
		end
	end
end

function StopTween(Statement)
	if not Statement and _G.Tween then 
		Remove_BC()
		_G.Tween:Cancel()
	end
end

function FindDetectPart(MaxPart: number?, Filter : Instance?) : BasePart
	MaxPart = MaxPart or math.huge

	Part_To_Detect()

    local overlap : OverlapParams = OverlapParams.new()
	
	overlap.MaxParts = MaxPart
	overlap.FilterDescendantsInstances = {Filter}
	overlap.FilterType = Enum.RaycastFilterType.Include

	
	local DetectPart = game:GetService("Workspace"):GetPartsInPart(Part_To_Detect, overlap)
	return DetectPart
end

function GetFlowers()
    local DetectParts = FindDetectPart(math.huge, game.Workspace.Flowers)
	return DetectParts[math.random(1, #DetectParts)]
end

function GetToken() : BasePart
	for _, v : BasePart in pairs(FindDetectPart(math.huge, game.Workspace.Collectibles)) do
		if v.Parent ~= nil and v.Transparency < 1 and v.Parent and v then
			return v
		end
	end
end

function GetField(Field_S)
	local Field = game:GetService("Workspace").FlowerZones:FindFirstChild(Field_S)
	local Height = HumanoidRootPart().Position.Y - Field.Position.Y 
	if Magnitude(Field.Position) >= 120 or Height < -8 or Height > 8  then
		return Field
	end
	return nil
end
--GetField(Field) or 
function GetTarget() : BasePart
	return GetToken() or GetFlowers()
end

function Insert_FlowerZones()
	local FlowerZones = {}
	for i,v in pairs(game:GetService("Workspace").FlowerZones:GetChildren()) do
		if v.Name ~= 'Ant Field' or v.Name ~= 'Hub Field' then
			table.insert(FlowerZones, v.Name)
		end
	end
	table.sort(FlowerZones)
	return FlowerZones
end

function Check_Capacity() : number
	local CoreStats : Folder = LocalPlayer().CoreStats
	return (CoreStats.Pollen.Value / CoreStats.Capacity.Value) * 100 
end

function ToyCD(toy : string) : number
	local toysplit : table = string.split(toy,'_')
	local toyname : string = toysplit[1]..' '..toysplit[2]                             
	local RetrievePlayerStats = game:GetService("ReplicatedStorage").Events.RetrievePlayerStats:InvokeServer()
	local cd : NumberValue = game.Workspace.Toys[toyname].Cooldown.Value
    return os.time()-RetrievePlayerStats.ToyTimes[toy] > cd
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

Group.Main_Group:AddDropdown('Select Field', {
	Text = 'Select Field',
	Values = Insert_FlowerZones(),
	Default = getgenv().Script_Setting['Selected_Field']
}):OnChanged(function(v)
    getgenv().Script_Setting['Selected_Field'] = v
	SaveSetting()
end) 

Group.Main_Group:AddToggle('Auto Farm Pollen', {
    Text = 'Auto Farm Pollen',
    Default = getgenv().Script_Setting['Auto_Farm'],
}):OnChanged(function(v)
    getgenv().Script_Setting['Auto_Farm'] = v
	SaveSetting()
end) 

Group.Setting_Group:AddToggle('No Clip', {
    Text = 'No Clip',
    Default = getgenv().Script_Setting['No_Clip'],
}):OnChanged(function(v)
    getgenv().Script_Setting['No_Clip'] = v
	SaveSetting()
end)

Group.Setting_Group:AddToggle('Safe Mode', {
    Text = 'Safe Mode',
    Default = getgenv().Script_Setting['Safe_Mode'],
}):OnChanged(function(v)
    getgenv().Script_Setting['Safe_Mode'] = v
	SaveSetting()
end) 

Group.Setting_Group:AddSlider('Walk Speed', {
    Text = 'Walk Speed',
    Default = getgenv().Script_Setting['Walk_Speed'] or 70,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Compact = false,
}):OnChanged(function(v)
    getgenv().Script_Setting['Walk_Speed'] = v
	SaveSetting()
end) 

task.spawn(function()
    while true do task.wait()
		local status , response = pcall(function()
			if getgenv().Script_Setting['Auto_Farm'] and getgenv().Script_Setting['Selected_Field'] then 
				--if Check_Capacity() < 100 then
				local CurrentField = getgenv().Script_Setting['Selected_Field']
				local target : BasePart = GetTarget()
				repeat task.wait()
					Tween(target.CFrame, true)
					Character().Humanoid.WalkSpeed = getgenv().Script_Setting['Walk_Speed']
					game:GetService("ReplicatedStorage").Events.ToolCollect:FireServer()
				until not getgenv().Script_Setting['Auto_Farm'] or not game.Workspace.Collectibles[target] or target.Parent == nil or target.Transparency >= 1 or Magnitude(target.Position) <= 8 or not target.Parent or not target or CurrentField ~= getgenv().Script_Setting['Selected_Field']
				StopTween(getgenv().Script_Setting['Auto_Farm'])
				if IsPlayerInField() and Check_Capacity() >= 100 then
					repeat wait() 
						Tween(LocalPlayer().SpawnPos.Value.Position, false) 
						if Magnitude(LocalPlayer().SpawnPos.Value.Position) <= 15 and GetKeyTag() and LocalPlayer().PlayerGui.ScreenGui.ActivateButton.TextBox.Text == 'Make Honey' then
							--game:GetService("ReplicatedStorage").Events.PlayerHiveCommand:FireServer("ToggleHoneyMaking")
							SendKeyEvent('E')
							task.wait(.75)
						end
					until Check_Capacity() <= 0 or not getgenv().Script_Setting['Auto_Farm'] or not GetKeyTag()
					StopTween(getgenv().Script_Setting['Auto_Farm'])
                    task.wait(Get_Maximum_Bees()/Get_Maximum_Bees()+3)
				end
			end
		end)
		if not status then warn(response) end
    end
end)

task.spawn(function()
	while true do task.wait() 
		local status , response = pcall(function()
			NoClip(getgenv().Script_Setting['No_Clip'] or getgenv().Script_Setting['Auto_Farm'])
		end)
		if not status then warn(response) end
	end
end)

print('Anti-AFK Activated Enjoy :)')
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
	vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
	task.wait()
	vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
	warn('Fire Anti Kick')
end)

--