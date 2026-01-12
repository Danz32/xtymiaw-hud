-- ===== XTYMIAW HUD DELTA SAFE | Get Fish =====
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

-- Rod ID sesuai rod kamu
local rodId = "f748fb1a-337a-4e80-a73f-3b4d0ad37685"

-- Status toggle
local autoFish = false
local autoSell = false

-- Delay / duration
local fishingDelay = 2       -- jeda lempar kail
local cancelDelay = 0.35     -- jeda sebelum loop ulang
local reelDuration = 3.8     -- durasi reel agar ikan nyangkut

-- ===== AUTO FISH & SELL LOOP =====
task.spawn(function()
    while true do
        task.wait(cancelDelay)
        if autoFish then
            pcall(function()
                RS.Fishing_RemoteThrow:FireServer(0.5, rodId)
            end)

            task.wait(fishingDelay)

            pcall(function()
                RS.Fishing.ToServer.ReelFinished:FireServer({
                    duration = reelDuration,
                    result="SUCCESS",
                    insideRatio=1
                }, rodId)
            end)
        end

        if autoSell then
            pcall(function()
                RS.Economy.ToServer.SellFish:FireServer({[1]="ALL"})
            end)
        end
    end
end)

-- ===== ANTI LAG =====
local function AntiLag()
    for _,v in pairs(workspace:GetDescendants()) do
        pcall(function()
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy()
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
                v.Enabled = false
            end
        end)
    end
    local L = game:GetService("Lighting")
    L.GlobalShadows = false
    L.FogEnd = 9e9
end

-- ===== HUD =====
task.wait(1) -- tunggu PlayerGui siap
local gui = Instance.new("ScreenGui")
gui.Name = "xtymiawHUD"
gui.Parent = LP:WaitForChild("PlayerGui")

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.6,0.5)
main.Position = UDim2.fromScale(0.2,0.2)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.Active = true
main.Draggable = true

local top = Instance.new("TextLabel", main)
top.Size = UDim2.fromScale(1,0.15)
top.BackgroundColor3 = Color3.fromRGB(40,40,40)
top.Text = "XTYMIAW HUB - GET FISH"
top.TextColor3 = Color3.new(1,1,1)
top.TextScaled = true

local min = Instance.new("TextButton", main)
min.Size = UDim2.fromScale(0.12,0.15)
min.Position = UDim2.fromScale(0.88,0)
min.Text = "-"
min.TextScaled = true

local body = Instance.new("Frame", main)
body.Size = UDim2.fromScale(1,0.85)
body.Position = UDim2.fromScale(0,0.15)
body.BackgroundTransparency = 1

-- ===== Helper Functions =====
local function makeBtn(txt,y,cb)
    local b = Instance.new("TextButton", body)
    b.Size = UDim2.fromScale(0.9,0.12)
    b.Position = UDim2.fromScale(0.05,y)
    b.Text = txt
    b.TextScaled = true
    b.BackgroundColor3 = Color3.fromRGB(45,45,45)
    b.TextColor3 = Color3.new(1,1,1)
    b.MouseButton1Click:Connect(cb)
    return b
end

local function makeBox(ph,y,cb)
    local t = Instance.new("TextBox", body)
    t.Size = UDim2.fromScale(0.9,0.1)
    t.Position = UDim2.fromScale(0.05,y)
    t.PlaceholderText = ph
    t.Text = ""
    t.TextScaled = true
    t.BackgroundColor3 = Color3.fromRGB(50,50,50)
    t.TextColor3 = Color3.new(1,1,1)
    t.FocusLost:Connect(function()
        local n = tonumber(t.Text)
        if n then cb(n) end
    end)
end

-- ===== Buttons & Inputs =====
local autoBtn = makeBtn("AUTO FISH : OFF",0.05,function()
    autoFish = not autoFish
    autoBtn.Text = autoFish and "AUTO FISH : ON" or "AUTO FISH : OFF"
end)

local sellBtn = makeBtn("AUTO SELL : OFF",0.18,function()
    autoSell = not autoSell
    sellBtn.Text = autoSell and "AUTO SELL : ON" or "AUTO SELL : OFF"
end)

makeBox("Fishing Delay (ex:2)",0.32,function(v) fishingDelay = v end)
makeBox("Cancel Delay (ex:0.35)",0.44,function(v) cancelDelay = v end)

makeBtn("ANTI LAG",0.6,function() AntiLag() end)
makeBtn("FPS EXTREME",0.75,function() AntiLag() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end)

-- ===== Minimize Toggle =====
local mini = false
min.MouseButton1Click:Connect(function()
    mini = not mini
    body.Visible = not mini
    main.Size = mini and UDim2.fromScale(0.6,0.15) or UDim2.fromScale(0.6,0.5)
    min.Text = mini and "+" or "-"
end)
