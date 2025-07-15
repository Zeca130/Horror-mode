local spawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/Zeca130/Horror-mode/refs/heads/main/Spawner.lua"))()

-- Настройки сущности
local entity = spawner.Create({
    Entity = {
        Name = "Flower",
        Asset = "rbxassetid://87984943504200",
        HeightOffset = 0
    },
    Lights = {
        Flicker = {
            Enabled = false,
            Duration = 1
        },
        Shatter = true,
        Repair = false
    },
    CameraShake = {
        Enabled = true,
        Range = 100,
        Values = {1.5, 20, 0.1, 1}
    },
    Movement = {
        Speed = 50,  -- Базовая скорость
        Delay = 0,
        Reversed = false
    },
    Damage = {
        Enabled = true,
        Range = 70,
        Amount = 125
    },
    Crucifixion = {
        Enabled = true,
        Range = 40,
        Resist = false,
        Break = true
    }
})

-- Параметры преследования
local chaseSpeed = 90
local reverseSpeed = 60 -- Скорость при движении назад (быстрее чем базовая)
local detectionRange = 600
local isChasing = false
local originalPath = nil
local damageInterval = 1 -- Интервал нанесения урона в секундах
local lastDamageTime = 0

-- Функция проверки видимости игрока
local function CanSeePlayer()
    local player = game.Players.LocalPlayer
    if not player or not player.Character or not player.Character:FindFirstChild("Head") then
        return false
    end
    
    local entityModel = entity.Model
    if not entityModel or not entityModel:FindFirstChild("Head") then
        return false
    end
    
    local distance = (entityModel.Head.Position - player.Character.Head.Position).Magnitude
    if distance > detectionRange then
        return false
    end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {entityModel, player.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local raycastResult = workspace:Raycast(
        entityModel.Head.Position,
        (player.Character.Head.Position - entityModel.Head.Position).Unit * detectionRange,
        raycastParams
    )
    
    if raycastResult then
        return raycastResult.Instance:IsDescendantOf(player.Character)
    end
    
    return true
end

-- Функция нанесения урона игроку
local function ApplyDamageToPlayer()
    local currentTime = tick()
    if currentTime - lastDamageTime >= damageInterval then
        lastDamageTime = currentTime
        local player = game.Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid:TakeDamage(10) -- Отнимаем 10 HP
        end
    end
end

-- Основная логика преследования
local function UpdateChase()
    if not entity.Model then return end
    
    local canSee = CanSeePlayer()
    
    if canSee and not isChasing then
        -- Начало преследования
        isChasing = true
        originalPath = entity.Model:GetPrimaryPartCFrame() -- Сохраняем оригинальный путь
        entity:UpdateMovement({Speed = chaseSpeed})
        
        -- Звук при обнаружении
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://9111268331"
        sound.Volume = 0.5
        sound.Parent = entity.Model.Head
        sound:Play()
        
    elseif not canSee and isChasing then
        -- Конец преследования - возвращаемся к оригинальному пути
        isChasing = false
        entity:UpdateMovement({Speed = entity.Movement.Reversed and reverseSpeed or 25})
        if originalPath then
            entity.Model:SetPrimaryPartCFrame(originalPath)
        end
    end
    
    -- Если преследуем, двигаемся к игроку и наносим урон
    if isChasing then
        local player = game.Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("Head") then
            local direction = (player.Character.Head.Position - entity.Model.Head.Position).Unit
            entity.Model:SetPrimaryPartCFrame(CFrame.lookAt(entity.Model.Head.Position, entity.Model.Head.Position + direction))
            
            -- Наносим урон игроку
            ApplyDamageToPlayer()
        end
    end
end

-- Проверка направления движения
local function CheckMovementDirection()
    while wait(0.5) do
        if entity and entity.Model and not isChasing then
            -- Если сущность движется назад (Reversed), устанавливаем повышенную скорость
            if entity.Movement.Reversed then
                entity:UpdateMovement({Speed = reverseSpeed})
            else
                entity:UpdateMovement({Speed = 25})
            end
        end
    end
end

-- Запуск преследования
spawn(function()
    while wait(0.1) do
        if entity and entity.Model then
            UpdateChase()
        else
            break
        end
    end
end)

-- Запуск проверки направления движения
spawn(CheckMovementDirection)

-- Остальные callback-функции
entity:SetCallback("OnSpawned", function()
    require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game).caption("DO YOU HEAR THE WHISTLE", true)
    
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://116519796488654"
    sound.Volume = 1
    sound.Parent = workspace
    sound:Play()
end)

entity:SetCallback("OnStartMoving", function()
    game.Players.LocalPlayer.Character.Humanoid:TakeDamage(10)
end)

entity:Run()
