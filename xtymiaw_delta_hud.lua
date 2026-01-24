-- XTYMIAW GET FISH HUB
-- draggable small hub + auto fishing + save setting

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

-- =========================
-- SAVE FILE
-- =========================
local SAVE_FILE = "xtymiaw_getfish.json"

local Settings = {
	AUTO_FISH = false,
	THROW_DELAY = 2,
	REEL_DELAY = 0.35,
	DURATION = 2.5,
	INSIDE_RATIO = 0.85
}

local function SaveSetting()
	if writefile then
		writefile(SAVE_FILE, HttpService:JSONEncode(Settings))
	end
end

local function LoadSetting()
	if readfile and isfile and isfile(SAVE_FILE) then
		local data = HttpService:JSONDecode(readfile(SAVE_FILE))
		for i,v in pairs(data) do
			Settings[i] = v
		end
	end
end
LoadSetting()

-- =========================
-- REMOTE
-- =========================
local ThrowRemote = ReplicatedStorage:FindFirstChild("Fishing_RemoteThrow", true)
local ReelRemote = ReplicatedStorage.Fishing.ToServer:FindFirstChild("ReelFinished", true)
local StartBiteRemote = ReplicatedStorage.Fishing.ToClient:FindFirstChild("StartBite", true)

-- =========================
-- TOOL
-- =========================
local function getRod()
	return (LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Tool"))
		or LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
end

local function getUUID(tool)
	if not tool then return HttpService:GenerateGUID(false) end
	local uuid = tool:GetAttribute("ToolUniqueId")
	if not uuid then
		uuid = HttpService:GenerateGUID(false)
		tool:SetAttribute("ToolUniqueId", uuid)
	end
	return uuid
end

-- =========================
-- AUTO SYSTEM
-- =========================
local function autoCast()
	if not Settings.AUTO_FISH then return end
	local tool = getRod()
	if not tool then return end
	ThrowRemote:FireServer(0.9 + math.random()*0.05, getUUID(tool))
end

local function autoReel()
	if not Settings.AUTO_FISH then return end
	local tool = getRod()
	if not tool then return end
	ReelRemote:FireServer({
		duration = Settings.DURATION + math.random()*1.5,
		result = "SUCCESS",
		insideRatio = Settings.INSIDE_RATIO
	}, getUUID(tool))
end

if StartBiteRemote then
	StartBiteRemote.OnClientEvent:Connect(function()
		if not Settings.AUTO_FISH then return end
		task.wait(Settings.REEL_DELAY + math.random()*0.3)
		autoReel()
	end)
end

task.spawn(function()
	while true do
		if Settings.AUTO_FISH then
			autoCast()
			SaveSetting()
			task.wait(Settings.THROW_DELAY + math.random()*0.4)
		else
			task.wait(0.4)
		end
	end
end)

-- =========================
-- UI (HUD)
-- =========================
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "XTYMIAW_HUB"

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromOffset(180,130)
main.Position = UDim2.fromScale(0.05,0.3)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.Active = true
main.Draggable = true

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,28)
title.Text = "XTYMIAW HUB"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 13

local toggle = Instance.new("TextButton", main)
toggle.Position = UDim2.fromOffset(10,35)
toggle.Size = UDim2.fromOffset(160,30)
toggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
toggle.TextColor3 = Color3.new(1,1,1)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 12

local function refresh()
	toggle.Text = Settings.AUTO_FISH and "AUTO FISH : ON" or "AUTO FISH : OFF"
	toggle.BackgroundColor3 = Settings.AUTO_FISH and Color3.fromRGB(0,170,0) or Color3.fromRGB(120,0,0)
end
refresh()

toggle.MouseButton1Click:Connect(function()
	Settings.AUTO_FISH = not Settings.AUTO_FISH
	SaveSetting()
	refresh()
end)

local info = Instance.new("TextLabel", main)
info.Position = UDim2.fromOffset(10,75)
info.Size = UDim2.fromOffset(160,45)
info.BackgroundTransparency = 1
info.TextWrapped = true
info.TextColor3 = Color3.fromRGB(200,200,200)
info.Font = Enum.Font.Gotham
info.TextSize = 11
info.Text = "Auto mancing\nGeser HUD sesuka hati"

-- =========================
-- GLOBAL CONTROL
-- =========================
getgenv().XTYMIAW_ON = function()
	Settings.AUTO_FISH = true
	SaveSetting()
	refresh()
end

getgenv().XTYMIAW_OFF = function()
	Settings.AUTO_FISH = false
	SaveSetting()
	refresh()
end

print("[XTYMIAW] HUB LOADED")
