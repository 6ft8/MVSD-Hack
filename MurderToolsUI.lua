--// Murder Game Script with GUI, ESP, Silent Aim, Hitbox Expander & More
--// Made for Delta Executor (Mobile)

-- Settings
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "MurderToolsGUI"
local toggleButton = Instance.new("ImageButton", ScreenGui)
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0, 10, 0, 200)
toggleButton.Image = "rbxassetid://77339698"
toggleButton.BackgroundTransparency = 1
toggleButton.Draggable = true
toggleButton.Active = true

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 300)
MainFrame.Position = UDim2.new(0, 70, 0, 150)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Visible = true
MainFrame.Draggable = true
MainFrame.Active = true

local UIListLayout = Instance.new("UIListLayout", MainFrame)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Toggle Logic
toggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Button Creator
local function createButton(text, callback)
    local button = Instance.new("TextButton", MainFrame)
    button.Size = UDim2.new(1, 0, 0, 40)
    button.Text = text
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.SourceSans
    button.TextSize = 18
    button.MouseButton1Click:Connect(callback)
end

-- HITBOX EXPANDER
local hitboxEnabled = false
local function toggleHitbox()
    hitboxEnabled = not hitboxEnabled
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                if hitboxEnabled then
                    root.Size = Vector3.new(15, 15, 15)
                    root.Transparency = 0.5
                    root.Material = Enum.Material.ForceField
                    root.CanCollide = false
                else
                    root.Size = Vector3.new(2, 2, 1)
                    root.Transparency = 0
                    root.Material = Enum.Material.Plastic
                    root.CanCollide = true
                end
            end
        end
    end
end

-- ESP
local espEnabled = false
local function toggleESP()
    espEnabled = not espEnabled
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            if espEnabled then
                if not head:FindFirstChild("ESP") then
                    local billboard = Instance.new("BillboardGui", head)
                    billboard.Name = "ESP"
                    billboard.Size = UDim2.new(0, 100, 0, 20)
                    billboard.AlwaysOnTop = true

                    local label = Instance.new("TextLabel", billboard)
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.Text = player.Name
                    label.TextColor3 = Color3.new(1, 0, 0)
                    label.BackgroundTransparency = 1
                end
            else
                if head:FindFirstChild("ESP") then
                    head.ESP:Destroy()
                end
            end
        end
    end
end

-- Silent Aim
local silentAimEnabled = false
local function getClosestVisibleTarget()
    local closest, dist = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            if player.Team ~= LocalPlayer.Team then
                local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                if onScreen and player.Character.Humanoid.Health > 0 then
                    local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if distance < dist then
                        closest = player
                        dist = distance
                    end
                end
            end
        end
    end
    return closest
end

-- Aimbot Assist
local aimAssistEnabled = false
RunService.RenderStepped:Connect(function()
    if aimAssistEnabled then
        local target = getClosestVisibleTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
        end
    end
end)

-- Toggle Silent Aim Logic
local function toggleSilentAim()
    silentAimEnabled = not silentAimEnabled
end

local function toggleAimbotAssist()
    aimAssistEnabled = not aimAssistEnabled
end

-- Buttons
createButton("Toggle Hitbox", toggleHitbox)
createButton("Toggle ESP", toggleESP)
createButton("Toggle Silent Aim", toggleSilentAim)
createButton("Toggle Aimbot Assist", toggleAimbotAssist)
Add script
