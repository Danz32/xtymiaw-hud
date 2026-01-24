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

getgenv().XTYMIAW_SET = function(throwDelay, reelDelay, duration)
    if throwDelay then Settings.THROW_DELAY = throwDelay end
    if reelDelay then Settings.REEL_DELAY = reelDelay end
    if duration then Settings.DURATION = duration end
    SaveSetting()
    print("[xtymiaw] SETTING UPDATED & SAVED")
end
