-- MVS Hack Menu - Updated for Murderers VS Sheriffs: DUELS
-- Features: Toggleable ESP, ESP color picker, hitbox expander, redesigned UI, and Silent Aim base hook

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- UI Colors
local primaryColor = Color3.fromRGB(140, 0, 255) -- Purple background
local textColor = Color3.new(1, 1, 1) -- White text

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MVS_Menu"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local toggleButton = Instance.new("TextButton", screenGui)
toggleButton.Text = "MVS"
toggleButton.Size = UDim2.new(0, 60, 0, 30)
toggleButton.Position = UDim2.new(0, 10, 0.5, -15)
toggleButton.BackgroundColor3 = primaryColor
toggleButton.TextColor3 = textColor
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 20

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 380, 0, 350)
mainFrame.Position = UDim2.new(0, 80, 0.5, -175)
mainFrame.BackgroundColor3 = primaryColor
mainFrame.Visible = false

local layout = Instance.new("UIListLayout", mainFrame)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 10)

-- Helper functions
local function createButton(text, parent, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Text = text
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(80, 0, 150)
    btn.TextColor3 = textColor
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 18
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function createLabel(text, parent)
    local label = Instance.new("TextLabel", parent)
    label.Size = UDim2.new(1, -20, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = textColor
    label.Font = Enum.Font.SourceSans
    label.TextSize = 18
    return label
end

-- ESP Logic
local espEnabled = false
local espColor = Color3.fromRGB(255, 0, 0)
local espBoxes = {}

local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not espBoxes[player.Name] then
                local box = Instance.new("Highlight", screenGui)
                box.Name = "ESP_Highlight"
                box.Adornee = player.Character
                box.FillColor = espColor
                box.FillTransparency = 0.7
                box.OutlineColor = Color3.new(1, 1, 1)
                box.OutlineTransparency = 0
                espBoxes[player.Name] = box
            else
                espBoxes[player.Name].FillColor = espColor
            end
        end
    end
end

local function disableESP()
    for _, box in pairs(espBoxes) do
        if box then box:Destroy() end
    end
    espBoxes = {}
end

RunService.RenderStepped:Connect(function()
    if espEnabled then
        updateESP()
    else
        disableESP()
    end
end)

-- Color Picker Logic
local function setESPColor(color)
    espColor = color
    for _, box in pairs(espBoxes) do
        if box and box:IsA("Highlight") then
            box.FillColor = color
        end
    end
end

-- Hitbox Expander
local hitboxSize = 2
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local part = player.Character.HumanoidRootPart
            part.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
            part.Transparency = 0.5
            part.Material = Enum.Material.ForceField
        end
    end
end)

-- Silent Aim Hook
local silentAim = false
local function getClosestTarget()
    local closest, dist = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if distance < dist then
                    dist = distance
                    closest = player
                end
            end
        end
    end
    return closest
end

-- Inject aim assist by redirecting attacks
Mouse.Button1Down:Connect(function()
    if silentAim then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            Mouse.Target = target.Character.HumanoidRootPart
        end
    end
end)

-- GUI Controls
createLabel("Main Controls", mainFrame)

createButton("Toggle ESP", mainFrame, function()
    espEnabled = not espEnabled
end)

createLabel("Select ESP Color", mainFrame)

createButton("Purple", mainFrame, function() setESPColor(Color3.fromRGB(140, 0, 255)) end)
createButton("Red", mainFrame, function() setESPColor(Color3.fromRGB(255, 0, 0)) end)
createButton("Blue", mainFrame, function() setESPColor(Color3.fromRGB(0, 100, 255)) end)
createButton("Green", mainFrame, function() setESPColor(Color3.fromRGB(0, 255, 100)) end)

createLabel("Hitbox Controls", mainFrame)

createButton("Increase Hitbox", mainFrame, function()
    hitboxSize = math.clamp(hitboxSize + 1, 2, 10)
end)
createButton("Reset Hitbox", mainFrame, function()
    hitboxSize = 2
end)

createLabel("Silent Aim", mainFrame)

createButton("Toggle Silent Aim", mainFrame, function()
    silentAim = not silentAim
end)

-- Toggle visibility
toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)
