-- Хоррор-текстуры для металла в Doors
local TEXTURES = {
    METAL_WITH_NAILS = "rbxassetid://13129246579",
    METAL_PLATES = "rbxassetid://13129248763",
    METAL_GRATE = "rbxassetid://13129250241",
    METAL_RUSTY = "rbxassetid://13129251827",
    METAL_HEAVY_RUST = "rbxassetid://13129253412"
}

-- Кэш для уже обработанных частей
local processedParts = {}

-- Оптимизированная функция для наложения текстур
local function applyMetalTexture(part, textureType)
    -- Проверяем, не был ли уже обработан этот part
    if processedParts[part] then return end
    processedParts[part] = true

    -- Устанавливаем свойства материала
    part.Material = Enum.Material.Metal
    part.Reflectance = 0.15
    part.Color = Color3.fromRGB(80, 70, 60)

    -- Выбираем текстуру
    local textureId = TEXTURES.METAL_WITH_NAILS
    
    if textureType == "plates" then
        textureId = TEXTURES.METAL_PLATES
    elseif textureType == "grate" then
        textureId = TEXTURES.METAL_GRATE
    elseif textureType == "rusty" then
        textureId = TEXTURES.METAL_RUSTY
    elseif textureType == "heavy_rust" then
        textureId = TEXTURES.METAL_HEAVY_RUST
    end

    -- Создаем текстуру только для видимых сторон
    local faces = {Enum.NormalId.Front, Enum.NormalId.Back, Enum.NormalId.Right, Enum.NormalId.Left}
    
    for _, face in ipairs(faces) do
        local texture = Instance.new("Texture")
        texture.Texture = textureId
        texture.StudsPerTileU = 2.5
        texture.StudsPerTileV = 2.5
        texture.Face = face
        texture.Parent = part
    end
end

-- Функция для определения типа объекта (без изменений)
local function getPartType(part)
    local lowerName = part.Name:lower()
    local parentName = part.Parent and part.Parent.Name:lower() or ""

    if lowerName:find("door") or parentName:find("door") then
        if lowerName:find("frame") or lowerName:find("рама") then
            return "plates"
        else
            return "default"
        end
    elseif lowerName:find("cabinet") or lowerName:find("locker") then
        return "plates"
    elseif lowerName:find("wall") or lowerName:find("стен") then
        if lowerName:find("grate") then
            return "grate"
        else
            return "rusty"
        end
    elseif lowerName:find("pipe") or lowerName:find("vent") then
        return "heavy_rust"
    elseif lowerName:find("floor") or lowerName:find("пол") then
        return "plates"
    elseif lowerName:find("ceiling") or lowerName:find("потолок") then
        return "rusty"
    else
        return "default"
    end
end

-- Оптимизированная обработка с разделением на кадры
local function processEnvironment()
    local parts = {}
    
    -- Сначала собираем все части для обработки
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 0.5 then
            table.insert(parts, part)
        end
    end
    
    -- Обрабатываем по 10 частей за кадр
    local index = 0
    local connection
    connection = game:GetService("RunService").Heartbeat:Connect(function()
        local processed = 0
        while processed < 10 and index < #parts do
            index = index + 1
            local part = parts[index]
            local partType = getPartType(part)
            applyMetalTexture(part, partType)
            processed = processed + 1
        end
        
        if index >= #parts then
            connection:Disconnect()
            print("Хоррор-текстуры металла успешно применены ко всем объектам!")
        end
    end)
end

-- Запускаем обработку
processEnvironment()
