-- TPSEEK_Loader.lua
-- Loader with Blue, Red, White, and Auto Game Completion (green)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local guiRoot = Instance.new("ScreenGui")
guiRoot.Name = "TPSEEK_Loader"
guiRoot.ResetOnSpawn = false
guiRoot.Parent = CoreGui
guiRoot.IgnoreGuiInset = true

local blur = Instance.new("BlurEffect")
blur.Size = 10
blur.Parent = game:GetService("Lighting")

-- Main frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 650)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -325)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = guiRoot

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 20)
corner.Parent = mainFrame

local glow = Instance.new("UIStroke")
glow.Thickness = 2
glow.Color = Color3.fromRGB(0, 200, 255)
glow.Transparency = 0.3
glow.Parent = mainFrame

-- Dragging
local dragging = false
local dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Logo
local logoContainer = Instance.new("Frame")
logoContainer.Size = UDim2.new(0, 120, 0, 120)
logoContainer.Position = UDim2.new(0.5, -60, 0, 30)
logoContainer.BackgroundTransparency = 1
logoContainer.Parent = mainFrame
local logo = Instance.new("ImageLabel")
logo.Size = UDim2.new(1, 0, 1, 0)
logo.BackgroundTransparency = 1
logo.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
logo.Parent = logoContainer

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.Position = UDim2.new(0, 0, 0, 160)
title.BackgroundTransparency = 1
title.Text = "TPSEEK"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextSize = 44
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, 0, 0, 25)
subtitle.Position = UDim2.new(0, 0, 0, 210)
subtitle.BackgroundTransparency = 1
subtitle.Text = "ultimate bee swarm automation"
subtitle.TextColor3 = Color3.fromRGB(0,200,255)
subtitle.TextSize = 14
subtitle.Parent = mainFrame

-- Buttons container
local btnContainer = Instance.new("Frame")
btnContainer.Size = UDim2.new(1, -60, 0, 260)
btnContainer.Position = UDim2.new(0, 30, 0, 250)
btnContainer.BackgroundTransparency = 1
btnContainer.Parent = mainFrame

local colors = {
    Blue   = {bg = Color3.fromRGB(0, 100, 200), hover = Color3.fromRGB(0, 150, 250), accent = Color3.fromRGB(0, 200, 255)},
    Red    = {bg = Color3.fromRGB(200, 40, 40), hover = Color3.fromRGB(230, 60, 60), accent = Color3.fromRGB(255, 80, 80)},
    White  = {bg = Color3.fromRGB(160, 160, 190), hover = Color3.fromRGB(200, 200, 230), accent = Color3.fromRGB(240, 240, 255)},
    Green  = {bg = Color3.fromRGB(0, 140, 70),  hover = Color3.fromRGB(0, 180, 90),  accent = Color3.fromRGB(80, 255, 120)}
}

local function createButton(name, yPos, col)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 240, 0, 48)
    btn.Position = UDim2.new(0.5, -120, 0, yPos)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextSize = 20
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = col.bg
    btn.BorderSizePixel = 0
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 30)
    btnCorner.Parent = btn
    local btnGlow = Instance.new("UIStroke")
    btnGlow.Thickness = 1.5
    btnGlow.Color = col.accent
    btnGlow.Transparency = 0.5
    btnGlow.Parent = btn
    btn.Parent = btnContainer
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = col.hover}):Play()
        TweenService:Create(btnGlow, TweenInfo.new(0.2), {Transparency = 0.1}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = col.bg}):Play()
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
