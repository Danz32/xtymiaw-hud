local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- =========================
-- FILE SAVE
-- =========================
local SAVE_FILE = "xtymiaw_getfish.json"

local Settings = {
    AUTO_FISH = false,
    THROW_DELAY = 2,
    REEL_DELAY = 0.35,
    DURATION = 3.8,
    INSIDE_RATIO = 0.85
}

-- =========================
-- SAVE / LOAD
-- =========================
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
-- CAST
-- =========================
local function autoCast()
    if not Settings.AUTO_FISH then return end
    local tool = getRod()
    if not tool then return end

    local uuid = getUUID(tool)
    local power = 0.85 + math.random() * 0.1

    ThrowRemote:FireServer(power, uuid)
end

-- =========================
-- REEL
-- =========================
local function autoReel()
    if not Settings.AUTO_FISH then return end
    local tool = getRod()
    if not tool then return end

    local uuid = getUUID(tool)

    ReelRemote:FireServer({
        duration = Settings.DURATION + math.random() * 0.3,
        result = "SUCCESS",
        insideRatio = Settings.INSIDE_RATIO
    }, uuid)
end

-- =========================
-- BITE LISTENER
-- =========================
if StartBiteRemote then
    StartBiteRemote.OnClientEvent:Connect(function()
        if not Settings.AUTO_FISH then return end
        task.wait(Settings.REEL_DELAY + math.random() * 0.15)
        autoReel()
    end)
end

-- =========================
-- LOOP CAST
-- =========================
task.spawn(function()
    while true do
        if Settings.AUTO_FISH then
            autoCast()
            SaveSetting()
            task.wait(Settings.THROW_DELAY + math.random() * 0.5)
        else
            task.wait(0.5)
        end
    end
end)

-- =========================
-- CONTROL
-- =========================
getgenv().XTYMIAW_ON = function()
    Settings.AUTO_FISH = true
    SaveSetting()
    print("[xtymiaw] AUTO FISH ON")
end

getgenv().XTYMIAW_OFF = function()
    Settings.AUTO_FISH = false
    SaveSetting()
    print("[xtymiaw] AUTO FISH OFF")
end

-- =========================
-- HUB KECIL + DRAG
-- =========================

pcall(function()
    if game.CoreGui:FindFirstChild("XTYMIAW_HUB") then
        game.CoreGui.XTYMIAW_HUB:Destroy()
    end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "XTYMIAW_HUB"
gui.Parent = game.CoreGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.18, 0.16)
frame.Position = UDim2.fromScale(0.03, 0.3)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.fromScale(1, 0.28)
title.Text = "XTYMIAW FISH"
title.TextScaled = true
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold

local onBtn = Instance.new("TextButton", frame)
onBtn.Size = UDim2.fromScale(0.85, 0.28)
onBtn.Position = UDim2.fromScale(0.075, 0.35)
onBtn.Text = "ON"
onBtn.TextScaled = true
onBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
onBtn.TextColor3 = Color3.new(1,1,1)

local c1 = Instance.new("UICorner", onBtn)
c1.CornerRadius = UDim.new(0,10)

local offBtn = Instance.new("TextButton", frame)
offBtn.Size = UDim2.fromScale(0.85, 0.28)
offBtn.Position = UDim2.fromScale(0.075, 0.67)
offBtn.Text = "OFF"
offBtn.TextScaled = true
offBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
offBtn.TextColor3 = Color3.new(1,1,1)

local c2 = Instance.new("UICorner", offBtn)
c2.CornerRadius = UDim.new(0,10)

onBtn.MouseButton1Click:Connect(function()
    getgenv().XTYMIAW_ON()
    onBtn.Text = "ON ✓"
end)

offBtn.MouseButton1Click:Connect(function()
    getgenv().XTYMIAW_OFF()
    onBtn.Text = "ON"
end)
