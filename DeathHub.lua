local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer

------------------------------------------------
-- UI LOAD
------------------------------------------------

local WindUI = loadstring(game:HttpGetAsync(
    "https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/dist/main.lua"
))()

WindUI:SetTheme("Dark")

local Window = WindUI:CreateWindow({
    Title = "DeathHub",
    Icon = "skull",
    Author = "DeathHub",
    Folder = "DeathHub",
    Size = UDim2.fromOffset(520, 420),
})

Window:EditOpenButton({
    Title = "Open DeathHub",
    Icon = "skull",
})

local Tabs = {
    Player = Window:Tab({ Title = "Player", Icon = "user" }),
    Visual = Window:Tab({ Title = "Visual", Icon = "eye" }),
    Misc = Window:Tab({ Title = "Misc", Icon = "settings" }),
}

WindUI:Notify({
    Title = "DeathHub",
    Content = "Loaded successfully",
    Duration = 3
})

------------------------------------------------
-- 🌈 RAINBOW OUTLINE
------------------------------------------------

task.spawn(function()
    local hue = 0

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 3
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = Window.Instance

    RunService.RenderStepped:Connect(function()
        hue = (hue + 0.01) % 1
        stroke.Color = Color3.fromHSV(hue, 1, 1)
    end)
end)

------------------------------------------------
-- CHARACTER HANDLER
------------------------------------------------

local char
local hum
local hrp

local function setChar(c)
    char = c
    hum = c:WaitForChild("Humanoid")
    hrp = c:WaitForChild("HumanoidRootPart")
end

if player.Character then
    setChar(player.Character)
end

player.CharacterAdded:Connect(setChar)

------------------------------------------------
-- 🚀 SMOOTH CAMERA FLY
------------------------------------------------

local fly = false
local flySpeed = 50

local bv
local bg
local flyConn

function startFly()
    if not char or not hrp or not hum then return end

    if bv then bv:Destroy() end
    if bg then bg:Destroy() end

    fly = true

    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.zero
    bv.Parent = hrp

    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 10000
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp

    hum.AutoRotate = false

    flyConn = RunService.RenderStepped:Connect(function()
        if not fly then return end
        if not char or not hrp or not hum then return end

        local cam = workspace.CurrentCamera
        local moveDir = hum.MoveDirection

        bv.Velocity =
            cam.CFrame:VectorToWorldSpace(moveDir) * flySpeed

        bg.CFrame =
            CFrame.new(
                hrp.Position,
                hrp.Position + cam.CFrame.LookVector
            )
    end)
end

function stopFly()
    fly = false

    if flyConn then
        flyConn:Disconnect()
        flyConn = nil
    end

    if bv then
        bv:Destroy()
        bv = nil
    end

    if bg then
        bg:Destroy()
        bg = nil
    end

    if hum then
        hum.AutoRotate = true
    end

    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
end

------------------------------------------------
-- 👁 NPC ESP
------------------------------------------------

local espEnabled = false
local espObjects = {}

local function addESP(model)
    if model:FindFirstChild("ESP_TAG") then return end

    local root = model:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local tag = Instance.new("BillboardGui")
    tag.Name = "ESP_TAG"
    tag.Size = UDim2.fromOffset(100, 40)
    tag.AlwaysOnTop = true
    tag.Parent = root

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.fromScale(1,1)
    txt.BackgroundTransparency = 1
    txt.TextScaled = true
    txt.Font = Enum.Font.GothamBold
    txt.TextColor3 = Color3.fromRGB(255, 0, 0)
    txt.Text = model.Name
    txt.Parent = tag

    table.insert(espObjects, tag)
end

local function toggleESP()
    espEnabled = not espEnabled

    if espEnabled then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model")
            and v:FindFirstChild("Humanoid")
            and not Players:GetPlayerFromCharacter(v) then
                addESP(v)
            end
        end
    else
        for _, v in pairs(espObjects) do
            if v then
                v:Destroy()
            end
        end

        espObjects = {}
    end
end

workspace.DescendantAdded:Connect(function(v)
    if espEnabled then
        if v:IsA("Model")
        and v:FindFirstChild("Humanoid")
        and not Players:GetPlayerFromCharacter(v) then
            addESP(v)
        end
    end
end)

------------------------------------------------
-- 🛡 GOD MODE
------------------------------------------------

local god = false
local godConn

local function enableGod()
    if not hum then return end

    god = true

    hum.MaxHealth = math.huge
    hum.Health = math.huge

    if godConn then
        godConn:Disconnect()
    end

    godConn = RunService.Heartbeat:Connect(function()
        if god and hum then
            hum.Health = math.huge
        end
    end)
end

local function disableGod()
    god = false

    if godConn then
        godConn:Disconnect()
        godConn = nil
    end

    if hum then
        hum.MaxHealth = 100
        hum.Health = 100
    end
end

------------------------------------------------
-- 📏 R6 SIZE SYSTEM
------------------------------------------------

local originalSizes = {}

local function setSize(scale)
    if not char then return end

    for _, v in pairs(char:GetChildren()) do
        if v:IsA("BasePart")
        and v.Name ~= "HumanoidRootPart" then

            if not originalSizes[v] then
                originalSizes[v] = v.Size
            end

            v.Size = originalSizes[v] * scale
        end
    end

    if hum then
        hum.HipHeight = 2 * scale
    end
end

local function resetSize()
    for part, size in pairs(originalSizes) do
        if part and part.Parent then
            part.Size = size
        end
    end

    if hum then
        hum.HipHeight = 2
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end
end

------------------------------------------------
-- 🧍 PLAYER TAB
------------------------------------------------

Tabs.Player:Toggle({
    Title = "Fly",
    Default = false,
    Callback = function(v)
        if v then
            startFly()
        else
            stopFly()
        end
    end,
})

Tabs.Player:Slider({
    Title = "Fly Speed",
    Min = 10,
    Max = 200,
    Default = 50,
    Increment = 5,
    Callback = function(v)
        flySpeed = tonumber(v) or 50
    end,
})

Tabs.Player:Button({
    Title = "Big Size",
    Callback = function()
        setSize(1.5)
    end,
})

Tabs.Player:Button({
    Title = "Small Size",
    Callback = function()
        setSize(0.7)
    end,
})

Tabs.Player:Button({
    Title = "Reset Size",
    Callback = function()
        resetSize()
    end,
})

Tabs.Player:Button({
    Title = "God Mode",
    Callback = function()
        enableGod()
    end,
})

Tabs.Player:Button({
    Title = "Reset God",
    Callback = function()
        disableGod()
    end,
})

------------------------------------------------
-- 👁 VISUAL TAB
------------------------------------------------

Tabs.Visual:Button({
    Title = "NPC ESP",
    Callback = function()
        toggleESP()
    end,
})

Tabs.Visual:Button({
    Title = "Full Bright",
    Callback = function()
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
    end,
})

Tabs.Visual:Button({
    Title = "Restore Lighting",
    Callback = function()
        Lighting.Brightness = 1
        Lighting.ClockTime = 12
        Lighting.FogEnd = 5000
    end,
})

------------------------------------------------
-- 🔗 DISCORD BUTTON
------------------------------------------------

Tabs.Misc:Button({
    Title = "Copy Discord Link",
    Callback = function()
        setclipboard("https://discord.gg/HsTVeBHAV")
    end,
})
