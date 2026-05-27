local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- UI LIBRARY
local WindUI = loadstring(game:HttpGetAsync(
    "https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/dist/main.lua"
))()

WindUI:SetTheme("Dark")

-- WINDOW
local Window = WindUI:CreateWindow({
    Title = "DeathHub",
    Icon = "skull",
    Author = "Null_Reaper",
    Folder = "DeathHub",
    Size = UDim2.fromOffset(560, 430),
    Transparent = true,
    Theme = "Dark",
})

Window:EditOpenButton({
    Title = "Open DeathHub",
    Icon = "skull",
})

-- TABS
local Tabs = {
    Main = Window:Tab({ Title = "Main", Icon = "home" }),
    Player = Window:Tab({ Title = "Player", Icon = "user" }),
    Teleport = Window:Tab({ Title = "Teleport", Icon = "map-pin" }),
    ESP = Window:Tab({ Title = "ESP", Icon = "eye" }),
    Misc = Window:Tab({ Title = "Misc", Icon = "settings" }),
}

-- FUNCTIONS
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function getHRP()
    local char = getCharacter()
    return char:WaitForChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = getCharacter()
    return char:WaitForChild("Humanoid")
end

-- =========================
-- MAIN TAB
-- =========================

Tabs.Main:Paragraph({
    Title = "DeathHub",
    Content = "Clean UI | Optimized | Made by Null_Reaper",
})

Tabs.Main:Button({
    Title = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, player)
    end,
})

Tabs.Main:Button({
    Title = "Copy Discord",
    Callback = function()
        setclipboard("discord.gg/deathhub")
    end,
})

-- =========================
-- PLAYER TAB
-- =========================

-- WALKSPEED
Tabs.Player:Slider({
    Title = "WalkSpeed",
    Default = 16,
    Min = 16,
    Max = 200,
    Increment = 1,
    Callback = function(value)
        getHumanoid().WalkSpeed = value
    end,
})

-- JUMPPOWER
Tabs.Player:Slider({
    Title = "JumpPower",
    Default = 50,
    Min = 50,
    Max = 250,
    Increment = 5,
    Callback = function(value)
        getHumanoid().JumpPower = value
    end,
})

-- INFINITE JUMP
local InfiniteJump = false

Tabs.Player:Toggle({
    Title = "Infinite Jump",
    Default = false,
    Callback = function(state)
        InfiniteJump = state
    end,
})

UIS.JumpRequest:Connect(function()
    if InfiniteJump then
        local hum = getHumanoid()
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- NOCLIP
local Noclip = false

Tabs.Player:Toggle({
    Title = "NoClip",
    Default = false,
    Callback = function(state)
        Noclip = state
    end,
})

RunService.Stepped:Connect(function()
    if Noclip then
        for _, v in pairs(getCharacter():GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

-- FLY
local Fly = false
local FlySpeed = 70

Tabs.Player:Slider({
    Title = "Fly Speed",
    Default = 70,
    Min = 20,
    Max = 250,
    Increment = 5,
    Callback = function(value)
        FlySpeed = value
    end,
})

Tabs.Player:Toggle({
    Title = "Fly",
    Default = false,
    Callback = function(state)
        Fly = state

        if Fly then
            local hrp = getHRP()

            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(999999,999999,999999)
            bv.Velocity = Vector3.zero
            bv.Parent = hrp

            task.spawn(function()
                while Fly do
                    task.wait()

                    local cam = workspace.CurrentCamera
                    local moveDir = Vector3.zero

                    if UIS:IsKeyDown(Enum.KeyCode.W) then
                        moveDir += cam.CFrame.LookVector
                    end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then
                        moveDir -= cam.CFrame.LookVector
                    end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then
                        moveDir -= cam.CFrame.RightVector
                    end
                    if UIS:IsKeyDown(Enum.KeyCode.D) then
                        moveDir += cam.CFrame.RightVector
                    end

                    bv.Velocity = moveDir * FlySpeed
                end

                bv:Destroy()
            end)
        end
    end,
})

-- =========================
-- TELEPORT TAB
-- =========================

Tabs.Teleport:Button({
    Title = "Teleport High Up",
    Callback = function()
        getHRP().CFrame = getHRP().CFrame + Vector3.new(0,150,0)
    end,
})

Tabs.Teleport:Button({
    Title = "Teleport Spawn",
    Callback = function()
        getHRP().CFrame = CFrame.new(0,10,0)
    end,
})

-- =========================
-- ESP TAB
-- =========================

local ESPEnabled = false
local ESPFolder = Instance.new("Folder", game.CoreGui)
ESPFolder.Name = "DeathHubESP"

local function clearESP()
    ESPFolder:ClearAllChildren()
end

local function createESP(plr)
    if plr == player then return end

    local char = plr.Character
    if not char then return end

    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Adornee = char
    highlight.Parent = ESPFolder
end

Tabs.ESP:Toggle({
    Title = "Player ESP",
    Default = false,
    Callback = function(state)
        ESPEnabled = state

        clearESP()

        if ESPEnabled then
            for _, plr in pairs(Players:GetPlayers()) do
                createESP(plr)
            end
        end
    end,
})

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(1)

        if ESPEnabled then
            createESP(plr)
        end
    end)
end)

-- =========================
-- MISC TAB
-- =========================

Tabs.Misc:Dropdown({
    Title = "Theme",
    Values = {"Dark", "Light"},
    Default = "Dark",
    Callback = function(value)
        WindUI:SetTheme(value)
    end,
})

Tabs.Misc:Button({
    Title = "Destroy UI",
    Callback = function()
        WindUI:Destroy()
    end,
})

print("DeathHub Loaded Successfully")
