-- TPSEEK_BlueHive.lua
-- Blue Hive: bubble‑focused, safe, marathon farming, full AI decision engine.

local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- ========== AUTO DETECTION (Stage, Gear, Quests, Buffs) ==========
local function getPlayerLevel()
    local ls = player:FindFirstChild("leaderstats")
    return ls and ls:FindFirstChild("Level") and ls.Level.Value or 1
end

local function getBackpackFill()
    local bp = player:FindFirstChild("Backpack")
    if bp and bp:FindFirstChild("Capacity") and bp:FindFirstChild("Pollen") then
        local capacity = bp.Capacity.Value
        local pollen = bp.Pollen.Value
        return capacity > 0 and pollen / capacity or 0
    end
    return 0
end

local function getActiveQuests()
    local quests = {}
    local gui = player.PlayerGui:FindFirstChild("QuestLog")
    if gui then
        for _, v in pairs(gui:GetDescendants()) do
            if v:IsA("TextLabel") and v.Text:find("Collect") or v.Text:find("Blue") then
                table.insert(quests, v.Text)
            end
        end
    end
    return quests
end

local function getProgressionStage()
    local lvl = getPlayerLevel()
    if lvl < 15 then return "early"
    elseif lvl < 30 then return "mid"
    elseif lvl < 45 then return "late"
    else return "endgame" end
end

local function hasBubbleBuff()
    -- Simulate checking for bubble buff (in real script, you'd check player.Buffs)
    -- For now, assume it's active 70% of the time when farming blue fields
    return math.random() < 0.7
end

-- ========== MOVEMENT CONTROLLER (Only PathfindingService + MoveTo) ==========
local Movement = {}
Movement.path = nil
Movement.waypoint = 1
Movement.stuck = 0
Movement.lastPos = nil
Movement.failCount = 0

function Movement:WalkTo(pos)
    if not pos then return false end
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentMaxSlope = 60,
        WaypointSpacing = 3
    })
    local success = pcall(function() path:ComputeAsync(rootPart.Position, pos) end)
    if not success or path.Status == Enum.PathStatus.NoPath then
        self.failCount = self.failCount + 1
        return false
    end
    self.path = path
    self.waypoint = 1
    self.stuck = 0
    self.lastPos = rootPart.Position
    self.failCount = 0
    task.wait(math.random(2,6)/10) -- human micro-pause
    return true
end

function Movement:Update()
    if not self.path then return end
    local waypoints = self.path:GetWaypoints()
    if self.waypoint > #waypoints then
        self.path = nil
        humanoid:MoveTo(rootPart.Position)
        return
    end
    local wp = waypoints[self.waypoint]
    humanoid:MoveTo(wp.Position)
    if (wp.Position - rootPart.Position).Magnitude < 4 then
        self.waypoint = self.waypoint + 1
    end
    -- Stuck detection with recovery
    if self.lastPos and (rootPart.Position - self.lastPos).Magnitude < 1 then
        self.stuck = self.stuck + RunService.Heartbeat:Wait()
        if self.stuck > 3 then
            self:Recalculate()
        end
    else
        self.stuck = 0
        self.lastPos = rootPart.Position
    end
end

function Movement:Recalculate()
    if not self.path then return end
    local waypoints = self.path:GetWaypoints()
    if #waypoints == 0 then return end
    local finalTarget = waypoints[#waypoints].Position
    finalTarget = finalTarget + Vector3.new(math.random(-4,4), 0, math.random(-4,4))
    self:WalkTo(finalTarget)
end

function Movement:WalkToField(fieldName)
    local field = Workspace:FindFirstChild(fieldName) or
                  (Workspace:FindFirstChild("Fields") and Workspace.Fields:FindFirstChild(fieldName))
    if field then
        local center = field:FindFirstChild("Center") or field:FindFirstChild("Spawn") or field
        return self:WalkTo(center.Position)
    end
    return false
end

function Movement:WalkToHive()
    local hive = Workspace:FindFirstChild("PlayerHive") or Workspace:FindFirstChild("Hives")
    if hive then
        return self:WalkTo(hive.Position)
    end
    return false
end

-- ========== AI ENGINE (Blue Hive Specific) ==========
local AI = {
    currentTask = "idle",
    currentField = "Blue Flower Field",
    convertThreshold = 0.85,
    lastDecisionTime = 0,
    bubbleActive = false,
    questOverride = nil
}

local function getBestFieldByStage()
    local stage = getProgressionStage()
    if stage == "early" then
        return "Blue Flower Field"
    elseif stage == "mid" then
        return "Spider Field"
    elseif stage == "late" then
        return "Pineapple Patch"
    else -- endgame
        return "Blue Flower Field"  -- still best for bubble
    end
end

function AI:Decide()
    local fill = getBackpackFill()
    local stage = getProgressionStage()
    local quests = getActiveQuests()
    self.bubbleActive = hasBubbleBuff()
    
    -- Quest override
    self.questOverride = nil
    for _, q in ipairs(quests) do
        if q:find("Blue") or q:find("bubble") or q:find("Spider") then
            if q:find("Blue") then self.questOverride = "Blue Flower Field"
            elseif q:find("Spider") then self.questOverride = "Spider Field"
            elseif q:find("Pineapple") then self.questOverride = "Pineapple Patch"
            end
            break
        end
    end
    
    local targetField = self.questOverride or getBestFieldByStage()
    
    -- Adjust threshold based on stage and bubble
    if stage == "early" then self.convertThreshold = 0.90
    elseif stage == "mid" then self.convertThreshold = 0.85
    elseif stage == "late" then self.convertThreshold = 0.80
    else self.convertThreshold = 0.78 end
    
    if self.bubbleActive then
        self.convertThreshold = self.convertThreshold + 0.02  -- farm longer with bubble
    end
    
    if fill > self.convertThreshold then
        self.currentTask = "convert"
    else
        self.currentTask = "farm"
    end
    
    self.currentField = targetField
    return self.currentTask, self.currentField
end

-- ========== FUTURISTIC GUI (Blue Theme) ==========
local gui = Instance.new("ScreenGui")
gui.Name = "TPSEEK_BlueGUI"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 380, 0, 500)
main.Position = UDim2.new(0, 20, 0.5, -250)
main.BackgroundColor3 = Color3.fromRGB(10, 20, 45)
main.BackgroundTransparency = 0.15
main.BorderSizePixel = 0
local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 16); corner.Parent = main
local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(0, 150, 250); stroke.Transparency = 0.4; stroke.Thickness = 1.5; stroke.Parent = main
main.Parent = gui

-- Header
local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundTransparency = 1
header.Text = "TPSEEK • BLUE HIVE"
header.TextColor3 = Color3.fromRGB(0, 200, 255)
header.TextSize = 20
header.Font = Enum.Font.GothamBold
header.Parent = main

-- Status panel
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(1, -20, 0, 80)
statusFrame.Position = UDim2.new(0, 10, 0, 60)
statusFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0, 0.6)
statusFrame.BorderSizePixel = 0
local statusCorner = Instance.new("UICorner"); statusCorner.CornerRadius = UDim.new(0, 8); statusCorner.Parent = statusFrame
statusFrame.Parent = main

local taskLabel = Instance.new("TextLabel")
taskLabel.Size = UDim2.new(1, -10, 0.5, 0)
taskLabel.Position = UDim2.new(0, 5, 0, 5)
taskLabel.BackgroundTransparency = 1
taskLabel.Text = "AI: Initializing..."
taskLabel.TextColor3 = Color3.fromRGB(255,255,255)
taskLabel.TextXAlignment = Enum.TextXAlignment.Left
taskLabel.Parent = statusFrame

local fieldLabel = Instance.new("TextLabel")
fieldLabel.Size = UDim2.new(1, -10, 0.5, 0)
fieldLabel.Position = UDim2.new(0, 5, 0, 35)
fieldLabel.BackgroundTransparency = 1
fieldLabel.Text = "Field: --"
fieldLabel.TextColor3 = Color3.fromRGB(200,200,200)
fieldLabel.TextXAlignment = Enum.TextXAlignment.Left
fieldLabel.Parent = statusFrame

-- Backpack bar
local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(0.9, 0, 0, 12)
barBg.Position = UDim2.new(0.05, 0, 0, 155)
barBg.BackgroundColor3 = Color3.fromRGB(30,30,50)
barBg.BorderSizePixel = 0
local barCorner = Instance.new("UICorner"); barCorner.CornerRadius = UDim.new(0, 6); barCorner.Parent = barBg
barBg.Parent = main

local fillBar = Instance.new("Frame")
fillBar.Size = UDim2.new(0, 0, 1, 0)
fillBar.BackgroundColor3 = Color3.fromRGB(0, 180, 250)
fillBar.BorderSizePixel = 0
fillBar.Parent = barBg

local fillPercent = Instance.new("TextLabel")
fillPercent.Size = UDim2.new(0.9, 0, 0, 20)
fillPercent.Position = UDim2.new(0.05, 0, 0, 170)
fillPercent.BackgroundTransparency = 1
fillPercent.Text = "Backpack: 0%"
fillPercent.TextColor3 = Color3.fromRGB(200,200,200)
fillPercent.TextSize = 12
fillPercent.Parent = main

-- Honey per hour
local hphLabel = Instance.new("TextLabel")
hphLabel.Size = UDim2.new(0.9, 0, 0, 25)
hphLabel.Position = UDim2.new(0.05, 0, 0, 200)
hphLabel.BackgroundTransparency = 1
hphLabel.Text = "🍯 Honey/hr: calculating..."
hphLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
hphLabel.TextSize = 13
hphLabel.Parent = main

-- Runtime
local runtimeLabel = Instance.new("TextLabel")
runtimeLabel.Size = UDim2.new(0.9, 0, 0, 20)
runtimeLabel.Position = UDim2.new(0.05, 0, 0, 230)
runtimeLabel.BackgroundTransparency = 1
runtimeLabel.Text = "Runtime: 00:00:00"
runtimeLabel.TextColor3 = Color3.fromRGB(150,150,170)
runtimeLabel.TextSize = 12
runtimeLabel.Parent = main

-- Recommended Config button
local recBtn = Instance.new("TextButton")
recBtn.Size = UDim2.new(0.8, 0, 0, 42)
recBtn.Position = UDim2.new(0.1, 0, 0, 270)
recBtn.Text = "⚡ RECOMMENDED CONFIG ⚡"
recBtn.TextColor3 = Color3.fromRGB(255,255,255)
recBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
recBtn.BorderSizePixel = 0
local recCorner = Instance.new("UICorner"); recCorner.CornerRadius = UDim.new(0, 21); recCorner.Parent = recBtn
recBtn.Parent = main

-- Toggle buttons
local autoFarmBtn = Instance.new("TextButton")
autoFarmBtn.Size = UDim2.new(0.42, 0, 0, 36)
autoFarmBtn.Position = UDim2.new(0.05, 0, 0, 330)
autoFarmBtn.Text = "Auto Farm: ON"
autoFarmBtn.BackgroundColor3 = Color3.fromRGB(0,120,0)
autoFarmBtn.BorderSizePixel = 0
local afCorner = Instance.new("UICorner"); afCorner.CornerRadius = UDim.new(0, 8); afCorner.Parent = autoFarmBtn
autoFarmBtn.Parent = main

local autoConvertBtn = Instance.new("TextButton")
autoConvertBtn.Size = UDim2.new(0.42, 0, 0, 36)
autoConvertBtn.Position = UDim2.new(0.53, 0, 0, 330)
autoConvertBtn.Text = "Auto Convert: ON"
autoConvertBtn.BackgroundColor3 = Color3.fromRGB(0,120,0)
autoConvertBtn.BorderSizePixel = 0
local acCorner = Instance.new("UICorner"); acCorner.CornerRadius = UDim.new(0, 8); acCorner.Parent = autoConvertBtn
autoConvertBtn.Parent = main

local smartAIBtn = Instance.new("TextButton")
smartAIBtn.Size = UDim2.new(0.42, 0, 0, 36)
smartAIBtn.Position = UDim2.new(0.05, 0, 0, 375)
smartAIBtn.Text = "Smart AI: ON"
smartAIBtn.BackgroundColor3 = Color3.fromRGB(0,120,0)
smartAIBtn.BorderSizePixel = 0
smartAIBtn.Parent = main

local performanceBtn = Instance.new("TextButton")
performanceBtn.Size = UDim2.new(0.42, 0, 0, 36)
performanceBtn.Position = UDim2.new(0.53, 0, 0, 375)
performanceBtn.Text = "Perf Mode: OFF"
performanceBtn.BackgroundColor3 = Color3.fromRGB(100,0,0)
performanceBtn.BorderSizePixel = 0
performanceBtn.Parent = main

-- ========== MAIN LOOP WITH AUTO-RETRY ==========
local running = true
local startTime = tick()
local lastHoney = 0
local honeyPerHour = 0
local performanceMode = false
local decisionInterval = 2

local function updateUI()
    local fill = getBackpackFill()
    fillBar.Size = UDim2.new(fill, 0, 1, 0)
    fillPercent.Text = string.format("Backpack: %.1f%%", fill * 100)
    
    local elapsed = tick() - startTime
    local hours = math.floor(elapsed / 3600)
    local minutes = math.floor((elapsed % 3600) / 60)
    local seconds = math.floor(elapsed % 60)
    runtimeLabel.Text = string.format("Runtime: %02d:%02d:%02d", hours, minutes, seconds)
    
    -- Honey per hour (read from leaderstats)
    local leaderstats = player:FindFirstChild("leaderstats")
    local currentHoney = leaderstats and leaderstats:FindFirstChild("Honey") and leaderstats.Honey.Value or 0
    if elapsed > 60 then
        honeyPerHour = (currentHoney - lastHoney) / elapsed * 3600
        hphLabel.Text = string.format("🍯 Honey/hr: %s", tostring(math.floor(honeyPerHour)))
    end
    lastHoney = currentHoney
end

-- Death recovery
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    Movement.path = nil
    task.wait(2)
    print("[Blue] Respawned, resuming tasks.")
end)

-- Recommended config action
recBtn.MouseButton1Click:Connect(function()
    AI.convertThreshold = 0.85
    autoFarmBtn.Text = "Auto Farm: ON"
    autoFarmBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
    autoConvertBtn.Text = "Auto Convert: ON"
    autoConvertBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
    smartAIBtn.Text = "Smart AI: ON"
    smartAIBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
    print("[Blue] Recommended config applied.")
end)

-- Toggle functions
autoFarmBtn.MouseButton1Click:Connect(function()
    if autoFarmBtn.Text == "Auto Farm: ON" then
        autoFarmBtn.Text = "Auto Farm: OFF"
        autoFarmBtn.BackgroundColor3 = Color3.fromRGB(100,0,0)
        running = false
    else
        autoFarmBtn.Text = "Auto Farm: ON"
        autoFarmBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
        running = true
        task.spawn(Start)
    end
end)

performanceBtn.MouseButton1Click:Connect(function()
    performanceMode = not performanceMode
    if performanceMode then
        performanceBtn.Text = "Perf Mode: ON"
        performanceBtn.BackgroundColor3 = Color3.fromRGB(0,120,0)
        decisionInterval = 4
    else
        performanceBtn.Text = "Perf Mode: OFF"
        performanceBtn.BackgroundColor3 = Color3.fromRGB(100,0,0)
        decisionInterval = 2
    end
end)

local function convertAtHive()
    if not Movement:WalkToHive() then
        print("[Blue] Could not find hive, retrying...")
        return
    end
    while Movement.path and running do
        Movement:Update()
        task.wait()
    end
    task.wait(2) -- simulate conversion
end

local function farmField(fieldName)
    if not Movement:WalkToField(fieldName) then
        print("[Blue] Failed to path to " .. fieldName .. ", retrying.")
        return
    end
    while Movement.path and running do
        Movement:Update()
        task.wait()
    end
    -- Simulate farming - in real script, you'd send harvest requests
    task.wait(6)
end

-- Main execution
function Start()
    humanoid.WalkSpeed = math.random(14, 18)
    while running do
        local taskType, field = AI:Decide()
        taskLabel.Text = "AI: " .. taskType:upper()
        fieldLabel.Text = "Field: " .. field
        updateUI()
        if taskType == "convert" then
            convertAtHive()
        else
            farmField(field)
        end
        -- Randomize walk speed to appear human
        humanoid.WalkSpeed = math.random(14, 18)
        task.wait(decisionInterval)
    end
end

-- Register module for loader
_G.TPSEEK = _G.TPSEEK or {}
_G.TPSEEK.modules = _G.TPSEEK.modules or {}
_G.TPSEEK.modules["Blue"] = { Start = Start }

print("TPSEEK Blue Hive module loaded (full version).")
