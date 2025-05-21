-- MVS Hack Menu (Silent Aim + Reliable ESP + Clean Mobile UI)
-- No Triggerbot. Rebuilt by request.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- UI Colors
local purple = Color3.fromRGB(140, 0, 255)
local white = Color3.fromRGB(255, 255, 255)

-- UI Base
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "MVS_UI"
gui.ResetOnSpawn = false

-- Toggle button (Draggable)
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 60, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0.5, -15)
toggleBtn.Text = "MVS"
toggleBtn.TextColor3 = white
toggleBtn.BackgroundColor3 = purple
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 16
toggleBtn.Active = true
toggleBtn.Draggable = true

-- Main Frame
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 400, 0, 320)
frame.Position = UDim2.new(0, 80, 0.5, -160)
frame.BackgroundColor3 = purple
frame.Visible = false

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, -20, 1, -20)
scroll.Position = UDim2.new(0, 10, 0, 10)
scroll.CanvasSize = UDim2.new(0, 0, 2, 0)
scroll.ScrollBarThickness = 5
scroll.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", scroll)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 6)

-- Button Helper
local function createButton(text, callback)
    local b = Instance.new("TextButton", scroll)
    b.Size = UDim2.new(1, -10, 0, 40)
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextSize = 16
    b.TextColor3 = white
    b.BackgroundColor3 = Color3.fromRGB(100, 0, 180)
    b.BorderSizePixel = 0
    b.MouseButton1Click:Connect(callback)
    return b
end

-- ESP Setup
local espOn = false
local espColor = Color3.fromRGB(255, 0, 0)
local highlights = {}

local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not highlights[player.Name] then
                local hl = Instance.new("Highlight", gui)
                hl.Name = "ESP_" .. player.Name
                hl.Adornee = player.Character
                hl.FillColor = espColor
                hl.FillTransparency = 0.6
                hl.OutlineColor = white
                highlights[player.Name] = hl
            else
                highlights[player.Name].Adornee = player.Character
            end
        end
    end
end

local function clearESP()
    for _, v in pairs(highlights) do
        v:Destroy()
    end
    highlights = {}
end

RunService.RenderStepped:Connect(function()
    if espOn then
        updateESP()
    else
        clearESP()
    end
end)

-- Hitbox Expander
local hitboxSize = 2
RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
            hrp.Material = Enum.Material.ForceField
            hrp.Transparency = 0.5
        end
    end
end)

-- Silent Aim Logic (Gun & Knife Redirect)
local silentAim = false

local function getClosestTarget()
    local closest, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pos, visible = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if visible then
                local diff = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if diff < dist then
                    dist = diff
                    closest = p
                end
            end
        end
    end
    return closest
end

-- Hook for Silent Aim (tool click)
Mouse.Button1Down:Connect(function()
    if not silentAim then return end
    local target = getClosestTarget()
    if not target then return end

    -- Try to detect weapon
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then return end

    local remote = tool:FindFirstChildWhichIsA("RemoteEvent") or tool:FindFirstChildWhichIsA("RemoteFunction")
    if remote then
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local pos = hrp.Position
            -- Fire remote (generic handler)
            if remote:IsA("RemoteEvent") then
                remote:FireServer(pos, hrp)
            elseif remote:IsA("RemoteFunction") then
                remote:InvokeServer(pos, hrp)
            end
        end
    end
end)

-- Buttons
createButton("Toggle Silent Aim", function()
    silentAim = not silentAim
end)

createButton("Toggle ESP", function()
    espOn = not espOn
end)

createButton("Set ESP Color: Purple", function()
    espColor = purple
end)

createButton("Set ESP Color: Red", function()
    espColor = Color3.fromRGB(255, 0, 0)
end)

createButton("Set ESP Color: Blue", function()
    espColor = Color3.fromRGB(0, 100, 255)
end)

createButton("Set ESP Color: Green", function()
    espColor = Color3.fromRGB(0, 255, 100)
end)

createButton("Increase Hitbox Size", function()
    hitboxSize = math.clamp(hitboxSize + 1, 2, 10)
end)

createButton("Reset Hitbox", function()
    hitboxSize = 2
end)

-- Toggle GUI
toggleBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

print("✅ MVS Hack Menu loaded. Clean UI. Working ESP + Silent Aim.")
