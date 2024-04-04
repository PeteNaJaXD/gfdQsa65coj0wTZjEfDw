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
function convertpos(pos)
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

getgenv().Script_Setting = {}

function CreateFile()
	local PlaceID : number = game.PlaceId
    local Player : string = game.Players.LocalPlayer.Name
	local Folder_Name = string.format('CFrame Hub/%s',PlaceID)
   -- local File_Name = string.format(Folder_Name..'/%s.json',PlaceID,Player)
	if not isfolder('CFrame Hub') then makefolder('CFrame Hub') end
	if not isfolder(Folder_Name) then makefolder(Folder_Name) end
end

function SaveSetting()
	local PlaceID : number = game.PlaceId
    local Player : string = game.Players.LocalPlayer.Name
	local Folder_Name =  'CFrame Hub'
    local File_Name = `{Folder_Name}/{Player}.json`

	local HttpService = game:GetService('HttpService')
	local Encode = HttpService:JSONEncode(getgenv().Script_Setting)
    print(Encode)
	if not isfile(File_Name) then writefile(File_Name,Encode) end
	writefile(File_Name,Encode)
end

function LoadSetting()
	local PlaceID : number = game.PlaceId
    local Player : string = game.Players.LocalPlayer.Name
	local Folder_Name =  'CFrame Hub'
    local File_Name = `{Folder_Name}/{Player}.json`

	local HttpService = game:GetService('HttpService')
	local Decode = HttpService:JSONDecode(readfile(File_Name))
	print(Decode)
	if isfile(File_Name) then
		getgenv().Script_Setting = Decode
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
	return (HumanoidRootPart().Position - convertpos(pos)).Magnitude
end

function WalkTo(pos : Vector3)
	local new_pos = convertpos(pos)
	Character().Humanoid:MoveTo(pos)
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

function Tween(Pos)
	local Features = {}
	local Speed : number;
	local Dis : number = Magnitude(Pos)
	local CPos = CFrame.new(convertpos(Pos))
	if Dis < 1000 then
		Speed = 300
	elseif Dis >= 100 then
		Speed = 200
	end
	local TService = game:GetService("TweenService")
	local Height = HumanoidRootPart().Position.Y - convertpos(Pos).Y 
	print(Height)
	print(Dis >= 120 and (Height <= 0 or Height >= 10) , Dis >= 120 and Height <= 0 or Height >= 10)
	if Dis >= 120 and (Height <= 0 or Height >= 10) then
		_G.Tween = TService:Create(game:GetService("Players")["LocalPlayer"].Character.HumanoidRootPart,TweenInfo.new(Dis/Speed,Enum.EasingStyle.Linear),{CFrame = CPos})
		_G.Tween:Play()
		Create_BC()
	else
		Remove_BC()
		WalkTo(Pos)
	end
end

function FindDetectPart(size : number?, MaxPart: number?, Filter : Instance?) : BasePart
	size = size or 50
	MaxPart = MaxPart or math.huge
	local Pos : CFrame = HumanoidRootPart().CFrame
	local detect_size : Vector3 = Vector3.new(size, 5, size)
    local overlap : OverlapParams = OverlapParams.new()

	overlap.MaxParts = MaxPart
	overlap.FilterDescendantsInstances = {Filter}
	overlap.FilterType = Enum.RaycastFilterType.Include

    local DetectPart : BasePart = game:GetService("Workspace"):GetPartBoundsInBox(Pos, detect_size, overlap)
	return DetectPart
end

function GetFlowers(Field : string)
	local hash : Array<BasePart> = {}
	local CurrentZone : BasePart = game:GetService("Workspace").FlowerZones:FindFirstChild(Field) 
	local ZoneID : number = CurrentZone.ID.Value
	local FP_ID : string = 'FP'..tostring(ZoneID)
	for _, v : BasePart in pairs(FindDetectPart(70, 30, game.Workspace.Flowers)) do
		local FP = string.split(v.Name,'-')
		if not hash[v] and Magnitude(v.Position) > 20 and FP[1] == FP_ID then
			hash[v] = true
			return v
		end
	end
end

function GetToken() : BasePart
	local hash : Array<BasePart> = {}
	for _, v : BasePart in pairs(FindDetectPart(70, 30, game.Workspace.Collectibles)) do
		if not hash[v] then
			hash[v] = true
			return v
		end
	end
end

function GetTarget(Field) : BasePart
	return GetToken() or GetFlowers(Field) or game:GetService("Workspace").FlowerZones:FindFirstChild(Field)
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
	Main_Group = Tabs.General:AddLeftGroupbox('Main')
}

Group.Main_Group:AddDropdown('Select Field', {
	Text = 'Select Field',
	Values = Insert_FlowerZones(),
	Default = getgenv().Script_Setting['Selected Field']
}):OnChanged(function(v)
    getgenv().Script_Setting['Selected Field'] = v
	SaveSetting()
end) 


Group.Main_Group:AddToggle('Auto Farm Pollen', {
    Text = 'Auto Farm Pollen',
    Default = getgenv().Script_Setting['Auto_Farm'],
}):OnChanged(function(v)
    getgenv().Script_Setting['Auto_Farm'] = v
	SaveSetting()
end) 

task.spawn(function()
    while true do task.wait()
		local succes , response = pcall(function()
			if getgenv().Script_Setting['Auto_Farm'] and getgenv().Script_Setting['Selected Field'] then 
				if Check_Capacity() < 100 then
					local target : BasePart = GetTarget(getgenv().Script_Setting['Selected Field'])
					repeat task.wait()
						Tween(target.Position)
						Character().Humanoid.WalkSpeed = 90
					until not getgenv().Script_Setting['Auto_Farm'] or Magnitude(target.Position) <= 5 or not target.Parent or not target or Check_Capacity() >= 100
					if not getgenv().Script_Setting['Auto_Farm'] then _G.Tween:Cancel() end
				else
					repeat task.wait() 
						Tween(LocalPlayer().SpawnPos.Value.Position) 
						if Magnitude(LocalPlayer().SpawnPos.Value.Position) <= 10 and LocalPlayer().PlayerGui.ScreenGui.ActivateButton.TextBox.Text == 'Make Honey' then
							game:GetService("ReplicatedStorage").Events.PlayerHiveCommand:FireServer("ToggleHoneyMaking")
							task.wait(.25)
						end
					until Check_Capacity() <= 0 or not getgenv().Script_Setting['Auto_Farm']
					if not getgenv().Script_Setting['Auto_Farm'] then _G.Tween:Cancel() end
					task.wait(6)
				end
			end
		end)
		if not succes then warn(response) end
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