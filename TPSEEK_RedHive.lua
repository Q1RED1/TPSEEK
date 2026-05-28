-- TPSEEK_RedHive.lua
-- Red Hive: aggressive, flame/combat focused, high risk/reward.

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

-- Auto detection
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

-- Movement Controller (identical to Blue)
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

-- AI (Red specific)
local AI = { threshold = 0.70 }  -- convert earlier for aggressive farming
function AI:Decide()
    local fill = getBackpackFill()
    local stage = getStage()
    local field = "Strawberry Field"
    if stage == "mid" then field = "Rose Field"
    elseif stage == "late" then field = "Cactus Field"
    elseif stage == "endgame" then field = "Pepper Patch" end
    if fill > self.threshold then
        return "convert", field
    else
        return "farm", field
    end
end

-- GUI (Red / Crimson theme)
local gui = Instance.new("ScreenGui")
gui.Name = "TPSEEK_RedGUI"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 350, 0, 450)
main.Position = UDim2.new(0, 20, 0.5, -225)
main.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
main.BackgroundTransparency = 0.15
local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0,16); corner.Parent = main
local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(220, 60, 60); stroke.Transparency = 0.4; stroke.Parent = main
main.Parent = gui

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1,0,0,45)
header.Text = "TPSEEK • RED HIVE"
header.TextColor3 = Color3.fromRGB(255, 80, 80)
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
recBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
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
    AI.threshold = 0.70
    autoFarm.Text = "Auto Farm: ON"
    autoFarm.BackgroundColor3 = Color3.fromRGB(0,150,0)
    print("[Red] Recommended config applied (aggressive mode)")
end)

local function convert()
    local hive = Workspace:FindFirstChild("PlayerHive") or Workspace:FindFirstChild("Hives")
    if hive then Movement:WalkTo(hive.Position) end
    while Movement.path and running do Movement:Update() task.wait() end
    task.wait(1.5)  -- faster conversion for red
end

local function farm(field)
    if Movement:WalkToField(field) then
        while Movement.path and running do Movement:Update() task.wait() end
    end
    task.wait(4)  -- shorter farming cycles for aggression
end

function Start()
    humanoid.WalkSpeed = math.random(16,20)  -- faster base speed
    while running do
        local taskType, field = AI:Decide()
        status.Text = string.format("AI: %s | %s", taskType:upper(), field)
        updateUI()
        if taskType == "convert" then convert() else farm(field) end
        humanoid.WalkSpeed = math.random(16,20)
        task.wait(1.5)
    end
end

_G.TPSEEK = _G.TPSEEK or {}
_G.TPSEEK.modules = _G.TPSEEK.modules or {}
_G.TPSEEK.modules["Red"] = { Start = Start }
print("Red Hive module loaded")
