-- TPSEEK Minimal Loader – clean futuristic GUI, no external deps.
-- Just run this script. Click a hive to start.

local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "TPSEEK_Menu"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

-- Background dim
local black = Instance.new("Frame")
black.Size = UDim2.new(1, 0, 1, 0)
black.BackgroundColor3 = Color3.fromRGB(0,0,0)
black.BackgroundTransparency = 0.6
black.BorderSizePixel = 0
black.Parent = gui

-- Main panel
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 500)
frame.Position = UDim2.new(0.5, -200, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(20,20,30)
frame.BorderSizePixel = 0
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = frame
frame.Parent = gui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 60)
title.Position = UDim2.new(0, 0, 0, 20)
title.BackgroundTransparency = 1
title.Text = "TPSEEK"
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.TextSize = 40
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- Subtitle
local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1, 0, 0, 30)
sub.Position = UDim2.new(0, 0, 0, 80)
sub.BackgroundTransparency = 1
sub.Text = "Bee Swarm Automation Hub"
sub.TextColor3 = Color3.fromRGB(200,200,200)
sub.TextSize = 16
sub.Font = Enum.Font.Gotham
sub.Parent = frame

-- Buttons container
local btnY = 130
local btnH = 50
local btnW = 240
local function makeBtn(text, y, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, btnW, 0, btnH)
    btn.Position = UDim2.new(0.5, -btnW/2, 0, y)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextSize = 18
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 25)
    btnCorner.Parent = btn
    btn.Parent = frame
    return btn
end

local blueBtn = makeBtn("BLUE HIVE", btnY, Color3.fromRGB(0,100,200))
local redBtn = makeBtn("RED HIVE", btnY+65, Color3.fromRGB(200,40,40))
local whiteBtn = makeBtn("WHITE HIVE", btnY+130, Color3.fromRGB(160,160,190))
local autoBtn = makeBtn("⚡ AUTO COMPLETION ⚡", btnY+195, Color3.fromRGB(0,140,70))

-- Close button (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 10)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.BackgroundColor3 = Color3.fromRGB(100,0,0)
closeBtn.BorderSizePixel = 0
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 15)
closeCorner.Parent = closeBtn
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Dragging
local drag = false
local dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = false
    end
end)

-- Hive selection logic (simulated – you will replace with actual AI scripts)
local function startHive(hiveName)
    gui:Destroy()
    -- Here you would load the actual hive script.
    -- For now, just print.
    print("Starting " .. hiveName .. " hive. (AI not yet attached – add your hive logic here)")
    -- Example: if you have the full scripts, you can load them here.
    -- But to keep this working, I'll just show a message.
    local msg = Instance.new("Message")
    msg.Text = hiveName .. " Hive started! (Add your automation code)"
    msg.Parent = game:GetService("CoreGui")
    task.wait(3)
    msg:Destroy()
end

blueBtn.MouseButton1Click:Connect(function() startHive("Blue") end)
redBtn.MouseButton1Click:Connect(function() startHive("Red") end)
whiteBtn.MouseButton1Click:Connect(function() startHive("White") end)
autoBtn.MouseButton1Click:Connect(function() startHive("Auto Completion") end)

print("TPSEEK menu loaded. Click a button.")        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = col.bg}):Play()
        TweenService:Create(btnGlow, TweenInfo.new(0.2), {Transparency = 0.5}):Play()
    end)
    return btn
end

local btnBlue  = createButton("BLUE HIVE", 0, colors.Blue)
local btnRed   = createButton("RED HIVE", 60, colors.Red)
local btnWhite = createButton("WHITE HIVE", 120, colors.White)
local btnAuto  = createButton("⚡ AUTO COMPLETION ⚡", 180, colors.Green)

-- Footer
local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, 0, 0, 30)
footer.Position = UDim2.new(0, 0, 1, -40)
footer.BackgroundTransparency = 1
footer.Text = "TPSEEK v3.0 | press H to hide GUI"
footer.TextColor3 = Color3.fromRGB(120,120,140)
footer.TextSize = 12
footer.Parent = mainFrame

-- H key toggle
local guiVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.H then
        guiVisible = not guiVisible
        guiRoot.Enabled = guiVisible
    end
end)

_G.TPSEEK = _G.TPSEEK or {}
_G.TPSEEK.modules = _G.TPSEEK.modules or {}

local function loadHive(moduleName)
    local module = _G.TPSEEK.modules[moduleName]
    if not module then
        warn("TPSEEK: " .. moduleName .. " module not loaded. Run the corresponding hive script first.")
        return
    end
    local closeAnim = TweenService:Create(mainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1, Position = UDim2.new(0.5, -250, 0.5, -325)})
    closeAnim:Play()
    closeAnim.Completed:Connect(function()
        guiRoot:Destroy()
        blur:Destroy()
        module.Start()
    end)
end

btnBlue.MouseButton1Click:Connect(function() loadHive("Blue") end)
btnRed.MouseButton1Click:Connect(function() loadHive("Red") end)
btnWhite.MouseButton1Click:Connect(function() loadHive("White") end)
btnAuto.MouseButton1Click:Connect(function() loadHive("AutoCompletion") end)

print("TPSEEK Loader ready. Modules must be loaded first.")
