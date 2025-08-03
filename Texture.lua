-- Хоррор-текстуры для металла в Doors
local TEXTURES = {
    METAL_WITH_NAILS = "rbxassetid://13129246579",  -- Металл с кровавыми следами и царапинами
    METAL_PLATES = "rbxassetid://13129248763",      -- Искореженные металлические пластины с темными пятнами
    METAL_GRATE = "rbxassetid://13129250241",       -- Грязная металлическая решетка с подтеками
    METAL_RUSTY = "rbxassetid://13129251827",       -- Ржавый металл с пятнами, напоминающими кровь
    METAL_HEAVY_RUST = "rbxassetid://13129253412"   -- Сильно корродированный металл с мрачными узорами
}

-- Основная функция для наложения текстур
local function applyMetalTexture(part, textureType)
    -- Очищаем все существующие текстуры и декали
    for _, child in ipairs(part:GetChildren()) do
        if child:IsA("Texture") or child:IsA("Decal") then
            child:Destroy()
        end
    end

    -- Устанавливаем металлический материал с мрачными параметрами
    part.Material = Enum.Material.Metal
    part.Reflectance = 0.15  -- Уменьшенный блеск для мрачной атмосферы
    part.Color = Color3.fromRGB(80, 70, 60)  -- Темный, грязный цвет металла

    -- Выбираем текстуру в зависимости от типа объекта
    local textureId = TEXTURES.METAL_WITH_NAILS  -- По умолчанию металл с кровавыми следами
    
    if textureType == "plates" then
        textureId = TEXTURES.METAL_PLATES
    elseif textureType == "grate" then
        textureId = TEXTURES.METAL_GRATE
    elseif textureType == "rusty" then
        textureId = TEXTURES.METAL_RUSTY
    elseif textureType == "heavy_rust" then
        textureId = TEXTURES.METAL_HEAVY_RUST
    end

    -- Создаем новую текстуру с хоррор-стилистикой
    local texture = Instance.new("Texture")
    texture.Texture = textureId
    texture.StudsPerTileU = 2.5  -- Немного измененный масштаб для более натурального вида
    texture.StudsPerTileV = 2.5
    texture.Face = Enum.NormalId.Front
    texture.Parent = part

    -- Добавляем текстуры на все видимые стороны для мрачной атмосферы
    local backTexture = texture:Clone()
    backTexture.Face = Enum.NormalId.Back
    backTexture.Parent = part

    local leftTexture = texture:Clone()
    leftTexture.Face = Enum.NormalId.Left
    leftTexture.Parent = part

    local rightTexture = texture:Clone()
    rightTexture.Face = Enum.NormalId.Right
    rightTexture.Parent = part
end

-- Функция для определения типа объекта (без изменений)
local function getPartType(part)
    local lowerName = part.Name:lower()
    local parentName = part.Parent and part.Parent.Name:lower() or ""

    -- Двери и рамы
    if lowerName:find("door") or parentName:find("door") then
        if lowerName:find("frame") or lowerName:find("рама") then
            return "plates"  -- Дверные рамы с болтами
        else
            return "default"  -- Двери со следами насилия
        end
    
    -- Шкафы и металлическая мебель
    elseif lowerName:find("cabinet") or lowerName:find("locker") then
        return "plates"
    
    -- Стены и перегородки
    elseif lowerName:find("wall") or lowerName:find("стен") then
        if lowerName:find("grate") then
            return "grate"
        else
            return "rusty"
        end
    
    -- Технические элементы
    elseif lowerName:find("pipe") or lowerName:find("vent") then
        return "heavy_rust"
    
    -- Полы и потолки
    elseif lowerName:find("floor") or lowerName:find("пол") then
        return "plates"
    elseif lowerName:find("ceiling") or lowerName:find("потолок") then
        return "rusty"
    
    -- Все остальные объекты
    else
        return "default"
    end
end

-- Основная функция обработки (без изменений)
local function processEnvironment()
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 0.5 then
            local partType = getPartType(part)
            applyMetalTexture(part, partType)
        end
    end
end

-- Запускаем обработку
processEnvironment()
game:GetService("RunService").Heartbeat:Connect(onHeartbeat)

print("Хоррор-текстуры металла успешно применены ко всем объектам!")
