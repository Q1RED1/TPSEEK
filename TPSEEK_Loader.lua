--[[
    TPSEEK All-in-One Loader
    Automatically fetches and registers all 4 hive modules, then shows the GUI.
    No need to run the other scripts manually.
--]]

local BASE_URL = "https://raw.githubusercontent.com/Q1RED1/TPSEEK/refs/heads/main"

local modulesToLoad = {
    "TPSEEK_BlueHive.lua",
    "TPSEEK_RedHive.lua",
    "TPSEEK_WhiteHive.lua",
    "TPSEEK_AutoCompletion.lua"
}

-- Load all modules first
for _, fileName in ipairs(modulesToLoad) do
    local url = BASE_URL .. "/" .. fileName
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success then
        print("[TPSEEK] Loaded: " .. fileName)
    else
        warn("[TPSEEK] Failed to load: " .. fileName .. " - " .. tostring(result))
    end
    task.wait(0.3)  -- Slight delay to avoid rate limits
end

task.wait(1)  -- Allow modules to register themselves

-- ========== REST OF THE ORIGINAL LOADER CODE ==========
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

-- ... (PASTE THE REST OF YOUR EXISTING LOADER CODE HERE) ...

-- Continue with your existing GUI creation and button logic.
-- The `_G.TPSEEK.modules` table will already be populated by the loaded modules.    btn.Font = Enum.Font.GothamBold
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
        warn("TPSEEK: " .. moduleName .. " module not found. Make sure the script loaded correctly.")
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

print("TPSEEK Loader ready. Click a hive to start.")    local btn = Instance.new("TextButton")
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
