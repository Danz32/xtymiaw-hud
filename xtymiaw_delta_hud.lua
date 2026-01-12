-- ===== XTYMIAW HUB DELTA SAFE =====
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

local rodId = "da2d51d4-8144-4190-b8ab-3492dc3ba534"
local autoFish = false
local fishingDelay = 2
local cancelDelay = 1

-- ===== AUTO FISH LOOP =====
task.spawn(function()
    while task.wait(cancelDelay) do
        if autoFish then
            pcall(function() RS.Fishing_RemoteThrow:FireServer(0.5, rodId) end)
            task.wait(fishingDelay)
            pcall(function()
                RS.Fishing.ToServer.ReelFinished:FireServer({duration=2,result="SUCCESS",insideRatio=0.8}, rodId)
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
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "xtymiawHUD"

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.6,0.5)
main.Position = UDim2.fromScale(0.2,0.2)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.Active = true
main.Draggable = true

-- title bar
local top = Instance.new("TextLabel", main)
top.Size = UDim2.fromScale(1,0.15)
top.BackgroundColor3 = Color3.fromRGB(40,40,40)
top.Text = "xtymiaw hub - get fish"
top.TextColor3 = Color3.new(1,1,1)
top.TextScaled = true

-- minimize button
local min = Instance.new("TextButton", main)
min.Size = UDim2.fromScale(0.12,0.15)
min.Position = UDim2.fromScale(0.88,0)
min.Text = "-"
min.TextScaled = true

-- body frame
local body = Instance.new("Frame", main)
body.Size = UDim2.fromScale(1,0.85)
body.Position = UDim2.fromScale(0,0.15)
body.BackgroundTransparency = 1

-- helper function
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

-- AUTO FISH toggle
local autoBtn = makeBtn("AUTO FISH : OFF",0.05,function()
    autoFish = not autoFish
    autoBtn.Text = autoFish and "AUTO FISH : ON" or "AUTO FISH : OFF"
end)

-- fishing delay input
makeBox("Fishing Delay (ex:2)",0.25,function(v)
    fishingDelay = v
end)

-- cancel delay input
makeBox("Cancel Delay (ex:1)",0.42,function(v)
    cancelDelay = v
end)

-- Anti Lag
makeBtn("ANTI LAG",0.6,function()
    AntiLag()
end)

-- FPS Extreme
makeBtn("FPS EXTREME",0.75,function()
    AntiLag()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end)

-- minimize toggle
local mini = false
min.MouseButton1Click:Connect(function()
    mini = not mini
    body.Visible = not mini
    main.Size = mini and UDim2.fromScale(0.6,0.15) or UDim2.fromScale(0.6,0.5)
    min.Text = mini and "+" or "-"
end)
