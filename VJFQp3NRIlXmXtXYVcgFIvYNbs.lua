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
	local Folder_Name = string.format('CFrame Hub/%s',PlaceID)
    local File_Name = string.format(Folder_Name..'/%s.json',Player)

	local HttpService = game:GetService('HttpService')
	local Encode = HttpService:JSONEncode(getgenv().Script_Setting)
    
	if not isfile(File_Name) then writefile(File_Name,Encode) end
end

function LoadSetting()
	local PlaceID : number = game.PlaceId
    local Player : string = game.Players.LocalPlayer.Name
	local Folder_Name = string.format('CFrame Hub/%s',PlaceID)
    local File_Name = string.format(Folder_Name..'/%s.json',Player)

	local HttpService = game:GetService('HttpService')

	if isfile(File_Name) then
		getgenv().Script_Setting = HttpService:JSONDecode(readfile(File_Name))
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
    if typeof(pos) ~= "Vector3" then return end
	return (HumanoidRootPart().Position - pos).Magnitude
end

function WalkTo(pos : Vector3)
	local new_pos = convertion[typeof(pos)](pos)
	Character().Humanoid:MoveTo(new_pos)
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

local General_Group = Tabs.General:AddLeftGroupbox('Group')
                 
General_Group:AddToggle('Auto Farm Pollen', {
    Text = 'Auto Farm Pollen',
    Default = false,
}):OnChanged(function(v)
    getgenv().Script_Setting['Auto_Farm'] = v
end) 

task.spawn(function()
    while true do task.wait()
		local succes , response = pcall(function()
			if getgenv().Script_Setting['Auto_Farm'] then
				local target = GetTarget('Rose Field')
				print(target)
				repeat task.wait()
					WalkTo(target.Position)
					Character().Humanoid.WalkSpeed = 90
				until Magnitude(target.Position) <= 5 or not target.Parent or not target
			end
		end)
		if not succes then print(response) end
    end
end)
--