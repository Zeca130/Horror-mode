local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")
local blocked = false
local isMobile = UserInputService.TouchEnabled

-- Sound setup
local warningSound = Instance.new("Sound")
warningSound.SoundId = "rbxassetid://89590435981520"
warningSound.Volume = 8
warningSound.Looped = false
warningSound.Parent = workspace
warningSound:Play()

-- GUI setup
local blockGui = Instance.new("ScreenGui")
blockGui.Name = "EarBlockGui"
blockGui.IgnoreGuiInset = true
blockGui.ResetOnSpawn = false
blockGui.Parent = gui

-- Background frame
local background = Instance.new("Frame")
background.Size = UDim2.new(1, 0, 1, 0)
background.BackgroundColor3 = Color3.new(0, 0, 0)
background.BackgroundTransparency = 0.5
background.Parent = blockGui

-- Instruction text
local text = Instance.new("TextLabel")
text.Size = UDim2.new(0.8, 0, 0.15, 0)
text.Position = UDim2.new(0.1, 0, 0.3, 0)
text.TextScaled = true
text.TextColor3 = Color3.new(1, 1, 1)
text.BackgroundTransparency = 1
text.Font = Enum.Font.GothamBold
text.Text = isMobile and "press to close ears!" or "PRESS E TO CLOSE EARS!"
text.Parent = blockGui

-- Timer display (now shows 8 seconds)
local timerText = Instance.new("TextLabel")
timerText.Size = UDim2.new(0.3, 0, 0.1, 0)
timerText.Position = UDim2.new(0.35, 0, 0.45, 0)
timerText.TextScaled = true
timerText.TextColor3 = Color3.new(0.8, 0.8, 1)
timerText.BackgroundTransparency = 1
timerText.Font = Enum.Font.GothamBlack
timerText.Text = "8.00"
timerText.Parent = blockGui

-- Progress display
local progressText = Instance.new("TextLabel")
progressText.Size = UDim2.new(0.4, 0, 0.1, 0)
progressText.Position = UDim2.new(0.3, 0, 0.55, 0)
progressText.TextScaled = true
progressText.TextColor3 = Color3.new(1, 1, 1)
progressText.BackgroundTransparency = 1
progressText.Font = Enum.Font.GothamBold
progressText.Text = "0/20"
progressText.Parent = blockGui

local clicksNeeded = 20
local clicksDone = 0
local timeLimit = 8  -- Changed to 8 seconds
local timeLeft = timeLimit
local timerRunning = true

-- Mobile button setup
if isMobile then
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.5, 0, 0.2, 0)
    button.Position = UDim2.new(0.25, 0, 0.7, 0)
    button.Text = "TAP HERE!"
    button.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextScaled = true
    button.Font = Enum.Font.GothamBlack
    button.Parent = blockGui
    
    -- Button animation
    local function animateButton()
        local tweenIn = TweenService:Create(
            button,
            TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = UDim2.new(0.45, 0, 0.18, 0)}
        )
        local tweenOut = TweenService:Create(
            button,
            TweenInfo.new(0.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
            {Size = UDim2.new(0.5, 0, 0.2, 0)}
        )
        tweenIn:Play()
        tweenIn.Completed:Wait()
        tweenOut:Play()
    end

    button.MouseButton1Click:Connect(function()
        if not timerRunning then return end
        
        animateButton()
        clicksDone = clicksDone + 1
        progressText.Text = clicksDone.."/20"
        
        if clicksDone >= clicksNeeded then
            blocked = true
            timerRunning = false
            blockGui:Destroy()
            warningSound:Stop()
        end
    end)
else
    -- Keyboard input for desktop
    local inputConnection
    inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not timerRunning or gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.E then
            clicksDone = clicksDone + 1
            progressText.Text = clicksDone.."/20"
            
            if clicksDone >= clicksNeeded then
                blocked = true
                timerRunning = false
                inputConnection:Disconnect()
                blockGui:Destroy()
                warningSound:Stop()
            end
        end
    end)
end

-- Timer system (8 seconds)
local startTime = os.clock()
local timerConnection
timerConnection = RunService.Heartbeat:Connect(function()
    if not timerRunning then
        timerConnection:Disconnect()
        return
    end
    
    timeLeft = timeLimit - (os.clock() - startTime)
    timerText.Text = string.format("%.2f", math.max(0, timeLeft))
    
    -- Visual feedback
    if timeLeft < 4 then
        timerText.TextColor3 = Color3.new(1, 0.5, 0.5)
    end
    if timeLeft < 2 then
        timerText.TextColor3 = Color3.new(1, 0.2, 0.2)
        timerText.Text = "HURRY! "..string.format("%.1f", timeLeft)
    end
    
    if timeLeft <= 0 then
        timerRunning = false
        timerConnection:Disconnect()
        
        if not blocked then
            blockGui:Destroy()
            warningSound:Stop()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Zeca130/doors-my-version-nightmareMode./refs/heads/main/Whistle%20horror%20mode"))()
        end
    end
end)
