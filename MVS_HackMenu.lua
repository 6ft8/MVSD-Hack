-- Bloodware-Inspired UI for MVS Hack Script (Purple/White Theme)
-- Mobile draggable, scrollable, and touch-friendly
-- Tabs: Silent Aim, ESP, HBE

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Main GUI setup
local gui = Instance.new("ScreenGui")
gui.Name = "MVS_BloodwareUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Color theme
local purple = Color3.fromRGB(140, 0, 255)
local white = Color3.fromRGB(255, 255, 255)

-- Draggable MVS button
local toggleButton = Instance.new("TextButton", gui)
toggleButton.Size = UDim2.new(0, 60, 0, 30)
toggleButton.Position = UDim2.new(0, 10, 0.5, -15)
toggleButton.Text = "MVS"
toggleButton.BackgroundColor3 = purple
toggleButton.TextColor3 = white
toggleButton.TextSize = 18
toggleButton.Font = Enum.Font.GothamBold
toggleButton.BorderSizePixel = 0

-- Drag logic
local dragging, dragInput, dragStart, startPos
toggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = toggleButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        toggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Main Frame
local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 420, 0, 320)
mainFrame.Position = UDim2.new(0, 80, 0.5, -160)
mainFrame.BackgroundColor3 = purple
mainFrame.Visible = false
mainFrame.BorderSizePixel = 0

-- Sidebar
local sidebar = Instance.new("Frame", mainFrame)
sidebar.Size = UDim2.new(0, 100, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(110, 0, 200)
sidebar.BorderSizePixel = 0

-- Tab buttons
local tabButtons = {}
local function createSidebarButton(name, callback)
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Text = name
    btn.TextColor3 = white
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.BackgroundTransparency = 1
    btn.MouseButton1Click:Connect(callback)
    table.insert(tabButtons, btn)
end

-- Scrollable content area
local contentFrame = Instance.new("ScrollingFrame", mainFrame)
contentFrame.Position = UDim2.new(0, 110, 0, 10)
contentFrame.Size = UDim2.new(1, -120, 1, -20)
contentFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
contentFrame.ScrollBarThickness = 6
contentFrame.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", contentFrame)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 8)

-- Button helper
local function createActionButton(label, func)
    local btn = Instance.new("TextButton", contentFrame)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Text = label
    btn.TextColor3 = white
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 16
    btn.BackgroundColor3 = Color3.fromRGB(100, 0, 180)
    btn.BorderSizePixel = 0
    btn.MouseButton1Click:Connect(func)
end

-- ESP Setup
local espEnabled = false
local espColor = Color3.fromRGB(255, 0, 0)
local espBoxes = {}

local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not espBoxes[player.Name] then
                local h = Instance.new("Highlight", gui)
                h.Adornee = player.Character
                h.FillColor = espColor
                h.FillTransparency = 0.6
                h.OutlineColor = white
                espBoxes[player.Name] = h
            end
        end
    end
end

local function disableESP()
    for _, h in pairs(espBoxes) do
        if h then h:Destroy() end
    end
    espBoxes = {}
end

RunService.RenderStepped:Connect(function()
    if espEnabled then updateESP() else disableESP() end
end)

-- Hitbox
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

-- Silent Aim
local silentAim = false
local function getTarget()
    local closest, dist = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if mag < dist then
                    dist = mag
                    closest = player
                end
            end
        end
    end
    return closest
end

Mouse.Button1Down:Connect(function()
    if silentAim then
        local target = getTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            Mouse.Target = target.Character.HumanoidRootPart
        end
    end
end)

-- Sidebar tabs
createSidebarButton("Silent Aim", function()
    contentFrame:ClearAllChildren()
    layout = Instance.new("UIListLayout", contentFrame)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)

    createActionButton("Toggle Silent Aim", function()
        silentAim = not silentAim
    end)
end)

createSidebarButton("ESP", function()
    contentFrame:ClearAllChildren()
    layout = Instance.new("UIListLayout", contentFrame)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)

    createActionButton("Toggle ESP", function()
        espEnabled = not espEnabled
    end)
    createActionButton("Purple", function() espColor = Color3.fromRGB(140, 0, 255) end)
    createActionButton("Red", function() espColor = Color3.fromRGB(255, 0, 0) end)
    createActionButton("Blue", function() espColor = Color3.fromRGB(0, 100, 255) end)
    createActionButton("Green", function() espColor = Color3.fromRGB(0, 255, 100) end)
end)

createSidebarButton("HBE", function()
    contentFrame:ClearAllChildren()
    layout = Instance.new("UIListLayout", contentFrame)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)

    createActionButton("Increase Hitbox", function()
        hitboxSize = math.clamp(hitboxSize + 1, 2, 10)
    end)
    createActionButton("Reset Hitbox", function()
        hitboxSize = 2
    end)
end)

-- Toggle GUI
toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Load default tab
tabButtons[1].MouseButton1Click:Fire()
