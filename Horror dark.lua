
task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Zeca130/Horror-mode/refs/heads/main/Hotel%20horror%20text.lua"))()

    end)
end)

game.ReplicatedStorage.GameData.LatestRoom.Changed:Wait()

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local disabledLights = {}
local playerLights = {}

local function DisableLight(light)
    if light and light.Parent and not playerLights[light] then
        light.Enabled = false
        disabledLights[light] = true
    end
end

local function ScanForLights(instance)
    if instance:IsA("Light") then
        DisableLight(instance)
    end
    for _, child in ipairs(instance:GetChildren()) do
        ScanForLights(child)
    end
end

Lighting.Ambient = Color3.new(0, 0, 0)
Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
Lighting.Brightness = 0
Lighting.FogStart = 50
Lighting.FogEnd = 55
Lighting.FogColor = Color3.new(10, 10, 10)
Lighting.GlobalShadows = true
Lighting.ExposureCompensation = -1

local function HandleTool(tool)
    if not tool:IsA("Tool") then return end
    
    local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
    if not handle then return end
    
    for _, light in ipairs(handle:GetDescendants()) do
        if light:IsA("Light") then
            playerLights[light] = {object = light, active = false}
            light.Enabled = false
            
            local function UpdateLightState()
                local isActive = tool:GetAttribute("IsLit") or false
                if playerLights[light].active ~= isActive then
                    light.Enabled = isActive
                    playerLights[light].active = isActive
                end
            end
            
            tool.Equipped:Connect(function()
                UpdateLightState()
            end)
            
            tool.Unequipped:Connect(function()
                light.Enabled = false
                playerLights[light].active = false
            end)
            
            tool.AttributeChanged:Connect(function(attr)
                if attr == "IsLit" then
                    UpdateLightState()
                end
            end)
        end
    end
end

local function HandleCharacter(character)
    for _, tool in ipairs(character:GetChildren()) do
        HandleTool(tool)
    end
    
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            HandleTool(child)
        end
    end)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(HandleCharacter)
    if player.Character then
        HandleCharacter(player.Character)
    end
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player.Character then
        HandleCharacter(player.Character)
    end
end

local function ProcessRoom(room)
    ScanForLights(room)
    room.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Light") then
            DisableLight(descendant)
        end
    end)
end

for _, room in ipairs(Workspace.CurrentRooms:GetChildren()) do
    ProcessRoom(room)
end

Workspace.CurrentRooms.ChildAdded:Connect(ProcessRoom)

Workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("Light") then
        DisableLight(descendant)
    end
end)

while true do
    for light, _ in pairs(disabledLights) do
        if not light or not light.Parent then
            disabledLights[light] = nil
        elseif not playerLights[light] then
            light.Enabled = false
        end
    end
    RunService.Heartbeat:Wait()
end
