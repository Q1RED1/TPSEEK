-- TPSEEK_AutoCompletion.lua
-- Auto Game Completion: dynamically chooses best field/strategy for maximum honey per hour.
-- Green theme, no hive bias, focuses on fastest possible progression.

local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Auto detection (enhanced)
local function getPlayerLevel()
    local ls = player:FindFirstChild("leaderstats")
    return ls and ls:FindFirstChild("Level") and ls.Level.Value or 1
end

local function getBackpackFill()
    local bp = player:FindFirstChild("Backpack")
    if bp and bp:FindFirstChild("Capacity") and bp:FindFirstChild("Pollen") then
        return bp.Pollen.Value / bp.Capacity.Value
    end
    return 0
end

local function getStage()
    local lvl = getPlayerLevel()
    if lvl < 15 then return "early"
    elseif lvl < 30 then return "mid"
    elseif lvl < 45 then return "late"
    else return "endgame" end
end

-- Real-time field efficiency scoring (simulated, but can be extended)
local function getFieldEfficiency(fieldName)
    -- In a real script, you'd measure pollen per second here.
    -- For now, return a static value based on stage and field type.
    local stage = getStage()
    local efficiency = 1.0
    if fieldName:find("Blue") then efficiency = 1.2 * (stage == "early" and 1.5 or 1.0)
    elseif fieldName:find("Strawberry") then efficiency = 1.1 * (stage == "mid" and 1.3 or 1.0)
    elseif fieldName:find("Pepper") then efficiency = 1.5 * (stage == "endgame" and 1.8 or 1.0)
    elseif fieldName:find("Pineapple") then efficiency = 1.4
    end
    return efficiency
end

local function getBestField()
    local candidates = {"Blue Flower Field", "Strawberry Field", "Sunflower Field", "Pineapple Patch", "Pepper Patch"}
    local best = candidates[1]
    local bestScore = 0
    for _, f in ipairs(candidates) do
        local score = getFieldEfficiency(f)
        if score > bestScore then
            bestScore = score
            best = f
        end
    end
    return best
end

-- Movement (same pattern)
local Movement = {}
Movement.path = nil
Movement.waypoint = 1
Movement.stuck = 0
Movement.lastPos = nil

function Movement:WalkTo(pos)
    if not pos then return false end
    local path = PathfindingService:CreatePath({AgentRadius=2, AgentHeight=5, AgentCanJump=true, AgentMaxSlope=60})
    local ok = pcall(function() path:ComputeAsync(rootPart.Position, pos) end)
    if not ok or path.Status == Enum.PathStatus.NoPath then return false end
    self.path = path
    self.waypoint = 1
    self.stuck = 0
    self.lastPos = rootPart.Position
    task.wait(math.random(2,5)/10)
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
    if self.lastPos and (rootPart.Position - self.lastPos).Magnitude < 1 then
        self.stuck = self.stuck + RunService.Heartbeat:Wait()
        if self.stuck > 3 then
            self:Recalc()
        end
    else
        self.stuck = 0
        self.lastPos = rootPart.Position
    end
end

function Movement:Recalc()
    if not self.path then return end
    local wp = self.path:GetWaypoints()
    if #wp == 0 then return end
    self:WalkTo(wp[#wp].Position + Vector3.new(math.random(-3,3),0,math.random(-3,3)))
end

function Movement:WalkToField(name)
    local f = Workspace:FindFirstChild(name) or (Workspace:FindFirstChild("Fields") and Workspace.Fields:FindFirstChild(name))
    if f and f:FindFirstChild("Center") then return self:WalkTo(f.Center.Position) end
    return false
end

-- AI (Auto Completion: always picks highest efficiency)
local AI = { threshold = 0.75 }
function AI:Decide()
    local fill = getBackpackFill()
    local bestField = getBestField()
    if fill > self.threshold then
        return "convert", bestField
    else
        return "farm", bestField
    end
end

-- GUI (Green theme)
local gui = Instance.new("ScreenGui")
gui.Name = "TPSEEK_AutoGUI"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 350, 0, 450)
main.Position = UDim2.new(0, 20, 0.5, -225)
main.BackgroundColor3 = Color3.fromRGB(10, 30, 10)
main.BackgroundTransparency = 0.15
local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0,16); corner.Parent = main
local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(80, 255, 120); stroke.Transparency = 0.4; stroke.Parent = main
main.Parent = gui

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1,0,0,45)
header.Text = "TPSEEK • AUTO COMPLETION"
header.TextColor3 = Color3.fromRGB(80, 255, 120)
header.BackgroundTransparency = 1
header.Parent = main

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-20,0,60)
status.Position = UDim2.new(0,10,0,55)
status.BackgroundColor3 = Color3.fromRGB(0,0,0,0.6)
status.Text = "AI: idle"
status.Parent = main

local recBtn = Instance.new("TextButton")
recBtn.Size = UDim2.new(0.8,0,0,40)
recBtn.Position = UDim2.new(0.1,0,0,140)
recBtn.Text = "⚡ RECOMMENDED CONFIG ⚡"
recBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 50)
recBtn.Parent = main

local autoFarm = Instance.new("TextButton")
autoFarm.Size = UDim2.new(0.4,0,0,35)
autoFarm.Position = UDim2.new(0.05,0,0,200)
autoFarm.Text = "Auto Farm: ON"
autoFarm.BackgroundColor3 = Color3.fromRGB(0,120,0)
autoFarm.Parent = main

local runtime = Instance.new("TextLabel")
runtime.Size = UDim2.new(0.9,0,0,20)
runtime.Position = UDim2.new(0.05,0,1,-30)
runtime.BackgroundTransparency = 1
runtime.Text = "Runtime: 00:00:00"
runtime.Parent = main

local startTime = tick()
local function updateUI()
    local elapsed = tick() - startTime
    runtime.Text = string.format("Runtime: %02d:%02d:%02d", elapsed/3600, (elapsed%3600)/60, elapsed%60)
end

local running = true
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    Movement.path = nil
    task.wait(2)
end)

recBtn.MouseButton1Click:Connect(function()
    AI.threshold = 0.75
    autoFarm.Text = "Auto Farm: ON"
    autoFarm.BackgroundColor3 = Color3.fromRGB(0,150,0)
    print("[AutoCompletion] Recommended config applied (maximum speed)")
end)

local function convert()
    local hive = Workspace:FindFirstChild("PlayerHive") or Workspace:FindFirstChild("Hives")
    if hive then Movement:WalkTo(hive.Position) end
    while Movement.path and running do Movement:Update() task.wait() end
    task.wait(1.8)
end

local function farm(field)
    if Movement:WalkToField(field) then
        while Movement.path and running do Movement:Update() task.wait() end
    end
    task.wait(5)
end

function Start()
    humanoid.WalkSpeed = math.random(15,19)
    while running do
        local taskType, field = AI:Decide()
        status.Text = string.format("AI: %s | %s (best field)", taskType:upper(), field)
        updateUI()
        if taskType == "convert" then convert() else farm(field) end
        humanoid.WalkSpeed = math.random(15,19)
        task.wait(2)
    end
end

_G.TPSEEK = _G.TPSEEK or {}
_G.TPSEEK.modules = _G.TPSEEK.modules or {}
_G.TPSEEK.modules["AutoCompletion"] = { Start = Start }
print("Auto Completion module loaded (green mode)")
