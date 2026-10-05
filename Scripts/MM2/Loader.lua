local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = workspace
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local LIB_URL = "https://raw.githubusercontent.com/LotuxHub/LotuxHub/refs/heads/main/Library/LotuxLibrary.lua"
if not redzlib then
    local ok, lib = pcall(function() return loadstring(game:HttpGet(LIB_URL))() end)
    if ok and lib then redzlib = lib end
end
assert(redzlib, "[Lotux MM2] Failed to load redzlib")

local function notify(title, desc, dur, kind)
    pcall(function()
        redzlib:Notify({Title = title, Description = desc, Duration = dur or 2, Type = kind or "Info"})
    end)
end

local IS_MOBILE = UIS.TouchEnabled and not UIS.MouseEnabled

local function getRole(player)
    if not player or not player.Parent then return "Innocent" end
    local char = player.Character
    if not char then return "Innocent" end
    if char:FindFirstChild("Knife") then return "Murderer" end
    if char:FindFirstChild("Gun") then return "Sheriff" end
    local bp = player:FindFirstChild("Backpack")
    if bp and bp:FindFirstChild("Gun") then return "Sheriff" end
    return "Innocent"
end

local ESP = {enabled = false, showName = true, showDistance = true, showRole = true, onlyMurderer = false, onlySheriff = false, maxDist = 500, tracked = {}, connections = {}}

local ROLE_COLORS = {
    Murderer = Color3.fromRGB(255, 40, 40),
    Sheriff = Color3.fromRGB(60, 140, 255),
    Innocent = Color3.fromRGB(80, 220, 100),
}

local function buildESP(player)
    if player == LocalPlayer then return end
    if ESP.tracked[player] then return end
    local entry = {connections = {}, highlight = nil, billboard = nil, label = nil}
    ESP.tracked[player] = entry
    local function attach(char)
        if not char then return end
        local head = char:WaitForChild("Head", 5)
        if not head then return end
        if entry.highlight then entry.highlight:Destroy() end
        if entry.billboard then entry.billboard:Destroy() end
        local hl = Instance.new("Highlight")
        hl.Name = "LotuxESP"
        hl.Adornee = char
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.FillTransparency = 0.65
        hl.OutlineTransparency = 0.15
        hl.Parent = CoreGui
        entry.highlight = hl
        local bb = Instance.new("BillboardGui")
        bb.Name = "LotuxESPName"
        bb.Adornee = head
        bb.Size = UDim2.new(0, 220, 0, 34)
        bb.StudsOffset = Vector3.new(0, 2.5, 0)
        bb.AlwaysOnTop = true
        bb.Parent = CoreGui
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextStrokeTransparency = 0
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Text = player.DisplayName
        label.Parent = bb
        entry.billboard = bb
        entry.label = label
    end
    if player.Character then attach(player.Character) end
    table.insert(entry.connections, player.CharacterAdded:Connect(attach))
end

local function startESP()
    for _, p in ipairs(Players:GetPlayers()) do buildESP(p) end
    table.insert(ESP.connections, Players.PlayerAdded:Connect(buildESP))
    table.insert(ESP.connections, RunService.RenderStepped:Connect(function()
        if not ESP.enabled then return end
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        for player, entry in pairs(ESP.tracked) do
            if not player.Parent then
                if entry.highlight then entry.highlight:Destroy() end
                if entry.billboard then entry.billboard:Destroy() end
                for _, c in ipairs(entry.connections) do c:Disconnect() end
                ESP.tracked[player] = nil
            else
                local role = getRole(player)
                local color = ROLE_COLORS[role] or ROLE_COLORS.Innocent
                local visible = true
                if ESP.onlyMurderer and role ~= "Murderer" then visible = false end
                if ESP.onlySheriff and role ~= "Sheriff" then visible = false end
                if entry.highlight then
                    entry.highlight.Enabled = visible
                    entry.highlight.FillColor = color
                    entry.highlight.OutlineColor = color
                end
                if entry.billboard and entry.label then
                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if myHrp and hrp then
                        local dist = (hrp.Position - myHrp.Position).Magnitude
                        if dist > ESP.maxDist then visible = false end
                        local parts = {}
                        if ESP.showName then table.insert(parts, player.DisplayName) end
                        if ESP.showRole then table.insert(parts, "[" .. role .. "]") end
                        if ESP.showDistance then table.insert(parts, string.format("%.0fm", dist)) end
                        entry.label.Text = table.concat(parts, " ")
                        entry.label.TextColor3 = color
                        entry.billboard.Enabled = visible and ESP.enabled
                    end
                end
            end
        end
    end))
end

local function stopESP()
    for _, c in ipairs(ESP.connections) do c:Disconnect() end
    ESP.connections = {}
    for _, entry in pairs(ESP.tracked) do
        if entry.highlight then entry.highlight:Destroy() end
        if entry.billboard then entry.billboard:Destroy() end
        for _, c in ipairs(entry.connections) do c:Disconnect() end
    end
    ESP.tracked = {}
end

local Aimbot = {enabled = false, targetPart = "Head", priority = "Murderer", fov = 200, smoothness = 0.4, visibleCheck = false, conn = nil}

local function getValidTargets()
    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    table.insert(list, {player = player, character = char, role = getRole(player)})
                end
            end
        end
    end
    return list
end

local function pickTarget()
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil end
    local mouse = UIS:GetMouseLocation()
    local targets = getValidTargets()
    local best, bestScore = nil, -math.huge
    for _, t in ipairs(targets) do
        local part = t.character:FindFirstChild(Aimbot.targetPart)
        if not part then continue end
        if Aimbot.priority == "Murderer" and t.role ~= "Murderer" then continue end
        if Aimbot.priority == "Sheriff" and t.role ~= "Sheriff" then continue end
        local sp, onScreen = Camera:WorldToScreenPoint(part.Position)
        if not onScreen then continue end
        local dist2D = (Vector2.new(sp.X, sp.Y) - mouse).Magnitude
        if dist2D > Aimbot.fov then continue end
        if Aimbot.visibleCheck then
            local origin = Camera.CFrame.Position
            local dir = part.Position - origin
            local rp = RaycastParams.new()
            rp.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
            rp.FilterType = Enum.RaycastFilterType.Exclude
            local result = Workspace:Raycast(origin, dir, rp)
            if result and not result.Instance:IsDescendantOf(t.character) then continue end
        end
        local score = -dist2D
        if t.role == "Murderer" and Aimbot.priority == "Closest" then score = score + 500 end
        if score > bestScore then
            bestScore = score
            best = t
        end
    end
    return best
end

local function startAimbot()
    if Aimbot.conn then return end
    Aimbot.conn = RunService.RenderStepped:Connect(function()
        if not Aimbot.enabled then return end
        local target = pickTarget()
        if not target then return end
        local part = target.character:FindFirstChild(Aimbot.targetPart)
        if not part then return end
        local camPos = Camera.CFrame.Position
        local newCF = CFrame.new(camPos, part.Position)
        Camera.CFrame = Camera.CFrame:Lerp(newCF, math.clamp(Aimbot.smoothness, 0.05, 1))
    end)
end

local function stopAimbot()
    if Aimbot.conn then Aimbot.conn:Disconnect(); Aimbot.conn = nil end
end

local FOVCircle = {gui = nil, frame = nil, enabled = false, conn = nil}

local function startFOVCircle()
    if not FOVCircle.gui then
        local g = Instance.new("ScreenGui")
        g.Name = "LotuxFOVCircle"
        g.ResetOnSpawn = false
        g.IgnoreGuiInset = true
        g.DisplayOrder = 5
        g.Parent = CoreGui
        local frame = Instance.new("Frame")
        frame.AnchorPoint = Vector2.new(0.5, 0.5)
        frame.Position = UDim2.new(0.5, 0, 0.5, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = g
        local circle = Instance.new("ImageLabel")
        circle.Size = UDim2.fromScale(1, 1)
        circle.BackgroundTransparency = 1
        circle.Image = "rbxassetid://3570695787"
        circle.ImageColor3 = Color3.fromRGB(255, 60, 60)
        circle.ImageTransparency = 0.4
        circle.ScaleType = Enum.ScaleType.Fit
        circle.Parent = frame
        FOVCircle.gui = g
        FOVCircle.frame = frame
    end
    FOVCircle.gui.Enabled = true
    FOVCircle.conn = RunService.RenderStepped:Connect(function()
        if not FOVCircle.enabled then return end
        FOVCircle.frame.Size = UDim2.fromOffset(Aimbot.fov * 2, Aimbot.fov * 2)
    end)
end

local function stopFOVCircle()
    if FOVCircle.gui then FOVCircle.gui.Enabled = false end
    if FOVCircle.conn then FOVCircle.conn:Disconnect(); FOVCircle.conn = nil end
end

local AutoFarm = {coinEnabled = false, coinConn = nil, gunEnabled = false, gunConn = nil}

local function findCoins()
    local list = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("candy")) then
            table.insert(list, obj)
        end
    end
    return list
end

local function startCoinFarm()
    if AutoFarm.coinConn then return end
    AutoFarm.coinConn = RunService.Heartbeat:Connect(function()
        if not AutoFarm.coinEnabled then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local coins = findCoins()
        if #coins == 0 then return end
        table.sort(coins, function(a, b)
            return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude
        end)
        local target = coins[1]
        if target and (target.Position - hrp.Position).Magnitude < 300 then
            hrp.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
            task.wait(0.08)
        end
    end)
end

local function stopCoinFarm()
    if AutoFarm.coinConn then AutoFarm.coinConn:Disconnect(); AutoFarm.coinConn = nil end
end

local function findGun()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Gun" then return obj end
        if obj:IsA("Tool") and obj.Name == "Gun" then return obj end
    end
    return nil
end

local function startGunFarm()
    if AutoFarm.gunConn then return end
    AutoFarm.gunConn = RunService.Heartbeat:Connect(function()
        if not AutoFarm.gunEnabled then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local gun = findGun()
        if gun and gun:IsA("BasePart") then
            hrp.CFrame = CFrame.new(gun.Position + Vector3.new(0, 3, 0))
            task.wait(0.1)
        end
    end)
end

local function stopGunFarm()
    if AutoFarm.gunConn then AutoFarm.gunConn:Disconnect(); AutoFarm.gunConn = nil end
end

local function tpTo(target)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if typeof(target) == "Instance" then
        if target:IsA("BasePart") then
            hrp.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
        elseif target.PrimaryPart then
            hrp.CFrame = CFrame.new(target.PrimaryPart.Position + Vector3.new(0, 3, 0))
        end
    end
end

local function findPlayerByRole(role)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and getRole(p) == role then return p end
    end
    return nil
end

local function teleportToRole(role)
    local p = findPlayerByRole(role)
    if p and p.Character then
        tpTo(p.Character)
        notify("TP", "Teleported to " .. role .. ": " .. p.Name, 2, "Success")
    else
        notify("TP", "No " .. role .. " found", 2, "Warning")
    end
end

local MoveState = {speed = 16, jump = 50, speedOn = false, jumpOn = false, conn = nil}

local function startMoveLoop()
    if MoveState.conn then return end
    MoveState.conn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if MoveState.speedOn then hum.WalkSpeed = MoveState.speed end
        if MoveState.jumpOn then hum.JumpPower = MoveState.jump end
    end)
end

local NoclipState = {enabled = false, conn = nil}

local function startNoclip()
    if NoclipState.conn then return end
    NoclipState.conn = RunService.Stepped:Connect(function()
        if not NoclipState.enabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
end

local function stopNoclip()
    if NoclipState.conn then NoclipState.conn:Disconnect(); NoclipState.conn = nil end
end

local FlyState = {enabled = false, speed = 60, gyro = nil, vel = nil, conn = nil}

local function startFly()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    local gyro = Instance.new("BodyGyro")
    gyro.P = 90000; gyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9); gyro.Parent = hrp
    local vel = Instance.new("BodyVelocity")
    vel.Velocity = Vector3.zero; vel.MaxForce = Vector3.new(9e9, 9e9, 9e9); vel.Parent = hrp
    hum.PlatformStand = true
    FlyState.gyro = gyro; FlyState.vel = vel
    FlyState.conn = RunService.RenderStepped:Connect(function()
        if not FlyState.enabled then return end
        if not gyro.Parent or not vel.Parent then return end
        local cam = Camera.CFrame
        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.E) then dir += Vector3.yAxis end
        if UIS:IsKeyDown(Enum.KeyCode.Q) then dir -= Vector3.yAxis end
        if dir.Magnitude > 0 then dir = dir.Unit end
        vel.Velocity = dir * FlyState.speed
        gyro.CFrame = cam
    end)
end

local function stopFly()
    if FlyState.conn then FlyState.conn:Disconnect(); FlyState.conn = nil end
    if FlyState.gyro then FlyState.gyro:Destroy(); FlyState.gyro = nil end
    if FlyState.vel then FlyState.vel:Destroy(); FlyState.vel = nil end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
end

local FullbrightState = {enabled = false, old = {}}

local function startFullbright()
    FullbrightState.old = {
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart,
        Ambient = Lighting.Ambient,
        Brightness = Lighting.Brightness,
    }
    Lighting.FogEnd = 1e9
    Lighting.FogStart = 1e9
    Lighting.Ambient = Color3.new(1, 1, 1)
    Lighting.Brightness = 2.5
end

local function stopFullbright()
    for k, v in pairs(FullbrightState.old) do
        pcall(function() Lighting[k] = v end)
    end
end

local IJState = {enabled = false, conn = nil}

local function startIJ()
    if IJState.conn then return end
    IJState.conn = UIS.JumpRequest:Connect(function()
        if not IJState.enabled then return end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end

local function stopIJ()
    if IJState.conn then IJState.conn:Disconnect(); IJState.conn = nil end
end

local AutoShoot = {enabled = false, conn = nil}

local function startAutoShoot()
    if AutoShoot.conn then return end
    AutoShoot.conn = RunService.Heartbeat:Connect(function()
        if not AutoShoot.enabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local gun = char:FindFirstChild("Gun")
        if not gun then return end
        local myHrp = char:FindFirstChild("HumanoidRootPart")
        if not myHrp then return end
        local murderers = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and getRole(p) == "Murderer" and p.Character then
                table.insert(murderers, p)
            end
        end
        if #murderers == 0 then return end
        table.sort(murderers, function(a, b)
            local ah = a.Character and a.Character:FindFirstChild("HumanoidRootPart")
            local bh = b.Character and b.Character:FindFirstChild("HumanoidRootPart")
            if not ah or not bh then return false end
            return (ah.Position - myHrp.Position).Magnitude < (bh.Position - myHrp.Position).Magnitude
        end)
        local target = murderers[1]
        local th = target.Character and target.Character:FindFirstChild("Head")
        if th then
            myHrp.CFrame = CFrame.new(myHrp.Position, Vector3.new(th.Position.X, myHrp.Position.Y, th.Position.Z))
            pcall(function()
                if gun:IsA("Tool") and gun:FindFirstChild("Handle") then
                    gun:Activate()
                end
            end)
        end
    end)
end

local function stopAutoShoot()
    if AutoShoot.conn then AutoShoot.conn:Disconnect(); AutoShoot.conn = nil end
end

local function killAll()
    local role = getRole(LocalPlayer)
    if role ~= "Murderer" then
        notify("Kill All", "You are not the Murderer", 2, "Warning")
        return
    end
    task.spawn(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local th = p.Character:FindFirstChild("Head")
                local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if th and myHrp then
                    myHrp.CFrame = CFrame.new(th.Position + Vector3.new(0, 2, 1))
                    local knife = LocalPlayer.Character:FindFirstChild("Knife")
                    if knife and knife:FindFirstChild("Handle") then
                        pcall(function() knife:Activate() end)
                    end
                    task.wait(0.15)
                end
            end
        end
        notify("Kill All", "Executed", 2, "Success")
    end)
end

local IMG = "rbxassetid://111672166073808"

local windows = redzlib:MakeWindow({
    Title = "Lotux Hub",
    SubTitle = "Murder Mystery 2",
    SaveFolder = "Lotux Hub\\" .. LocalPlayer.Name,
})

local HomeTab = windows:MakeTab({Title = "Home", Icon = "home"})
HomeTab:AddSection("Welcome To Lotux Hub | MM2")
HomeTab:AddSection("Discord Server")
HomeTab:AddDiscordInvite({
    Title = "Lotux Hub",
    Desc = "Join our Discord for updates!",
    Logo = IMG,
    Invite = "https://discord.gg/HkB97N772p",
})

local EspTab = windows:MakeTab({Title = "ESP", Icon = "eye"})
EspTab:AddSection("Player ESP")

EspTab:AddToggle({
    Title = "Enable ESP",
    Description = "Shows name, role, distance",
    Default = false, Flag = "mm2_esp",
    Callback = function(state)
        ESP.enabled = state
        if state then startESP() notify("ESP", "ON", 2, "Success")
        else stopESP() notify("ESP", "OFF", 2, "Info") end
    end,
})
EspTab:AddToggle({
    Title = "Show Name", Default = true, Flag = "mm2_esp_name",
    Callback = function(s) ESP.showName = s end,
})
EspTab:AddToggle({
    Title = "Show Role", Default = true, Flag = "mm2_esp_role",
    Callback = function(s) ESP.showRole = s end,
})
EspTab:AddToggle({
    Title = "Show Distance", Default = true, Flag = "mm2_esp_dist",
    Callback = function(s) ESP.showDistance = s end,
})
EspTab:AddToggle({
    Title = "Only Murderer", Description = "Only shows the Murderer",
    Default = false, Flag = "mm2_esp_murderer",
    Callback = function(s) ESP.onlyMurderer = s end,
})
EspTab:AddToggle({
    Title = "Only Sheriff", Description = "Only shows the Sheriff",
    Default = false, Flag = "mm2_esp_sheriff",
    Callback = function(s) ESP.onlySheriff = s end,
})
EspTab:AddSlider({
    Title = "Max Distance", Min = 50, Max = 2000, Default = 500,
    Flag = "mm2_esp_maxdist",
    Callback = function(v) ESP.maxDist = v end,
})

local AimTab = windows:MakeTab({Title = "Aimbot", Icon = "crosshair"})
AimTab:AddSection("Aimbot")

AimTab:AddToggle({
    Title = "Enable Aimbot", Default = false, Flag = "mm2_aim",
    Callback = function(state)
        Aimbot.enabled = state
        if state then startAimbot() notify("Aimbot", "ON", 2, "Success")
        else stopAimbot() notify("Aimbot", "OFF", 2, "Info") end
    end,
})
AimTab:AddDropdown({
    Title = "Aim Part",
    Options = {"Head", "HumanoidRootPart", "UpperTorso"},
    Default = "Head", Flag = "mm2_aim_part",
    Callback = function(v) Aimbot.targetPart = (typeof(v) == "table" and v[1]) or v end,
})
AimTab:AddDropdown({
    Title = "Priority",
    Options = {"Murderer", "Sheriff", "All", "Closest"},
    Default = "Murderer", Flag = "mm2_aim_priority",
    Callback = function(v)
        local val = (typeof(v) == "table" and v[1]) or v
        Aimbot.priority = val
    end,
})
AimTab:AddSlider({
    Title = "FOV", Min = 50, Max = 800, Default = 200,
    Flag = "mm2_aim_fov",
    Callback = function(v) Aimbot.fov = v end,
})
AimTab:AddSlider({
    Title = "Smoothness", Min = 0.05, Max = 1, Default = 0.4,
    Flag = "mm2_aim_smooth",
    Callback = function(v) Aimbot.smoothness = v end,
})
AimTab:AddToggle({
    Title = "Visible Check",
    Default = false, Flag = "mm2_aim_vis",
    Callback = function(s) Aimbot.visibleCheck = s end,
})
AimTab:AddToggle({
    Title = "Show FOV Circle", Default = false, Flag = "mm2_fov_circle",
    Callback = function(state)
        FOVCircle.enabled = state
        if state then startFOVCircle() else stopFOVCircle() end
    end,
})

local FarmTab = windows:MakeTab({Title = "Auto Farm", Icon = "zap"})
FarmTab:AddSection("Farm")

FarmTab:AddToggle({
    Title = "Auto Collect Coins",
    Description = "Collects coins automatically",
    Default = false, Flag = "mm2_coin",
    Callback = function(state)
        AutoFarm.coinEnabled = state
        if state then startCoinFarm() notify("Coin Farm", "ON", 2, "Success")
        else stopCoinFarm() notify("Coin Farm", "OFF", 2, "Info") end
    end,
})
FarmTab:AddToggle({
    Title = "Auto Grab Gun",
    Description = "Picks up gun from ground automatically",
    Default = false, Flag = "mm2_gun",
    Callback = function(state)
        AutoFarm.gunEnabled = state
        if state then startGunFarm() notify("Gun Farm", "ON", 2, "Success")
        else stopGunFarm() notify("Gun Farm", "OFF", 2, "Info") end
    end,
})

local RoleTab = windows:MakeTab({Title = "Role Actions", Icon = "shield"})
RoleTab:AddSection("Sheriff")

RoleTab:AddToggle({
    Title = "Auto Shoot Murderer",
    Description = "Only works if you are the Sheriff",
    Default = false, Flag = "mm2_autoshoot",
    Callback = function(state)
        AutoShoot.enabled = state
        if state then startAutoShoot() notify("Auto Shoot", "ON", 2, "Success")
        else stopAutoShoot() notify("Auto Shoot", "OFF", 2, "Info") end
    end,
})

RoleTab:AddSection("Murderer")
RoleTab:AddButton({
    Title = "Kill All",
    Description = "Only works if you are the Murderer",
    Callback = killAll,
})

local TpTab = windows:MakeTab({Title = "Teleports", Icon = "map-pin"})
TpTab:AddSection("Teleport")

TpTab:AddButton({
    Title = "TP to Murderer",
    Callback = function() teleportToRole("Murderer") end,
})
TpTab:AddButton({
    Title = "TP to Sheriff",
    Callback = function() teleportToRole("Sheriff") end,
})
TpTab:AddButton({
    Title = "TP to Gun",
    Callback = function()
        local gun = findGun()
        if gun then tpTo(gun) notify("TP", "Teleported to gun", 2, "Success")
        else notify("TP", "Gun not found", 2, "Warning") end
    end,
})
TpTab:AddButton({
    Title = "TP to Random Coin",
    Callback = function()
        local coins = findCoins()
        if #coins > 0 then
            tpTo(coins[math.random(1, #coins)])
            notify("TP", "Teleported to coin", 2, "Success")
        else
            notify("TP", "No coins found", 2, "Warning")
        end
    end,
})

local MoveTab = windows:MakeTab({Title = "Movement", Icon = "user"})
MoveTab:AddSection("Speed")

MoveTab:AddToggle({
    Title = "Walkspeed", Default = false, Flag = "mm2_ws",
    Callback = function(state)
        MoveState.speedOn = state
        if state then startMoveLoop() end
    end,
})
MoveTab:AddSlider({
    Title = "Walkspeed Value", Min = 16, Max = 200, Default = 40,
    Flag = "mm2_ws_val",
    Callback = function(v) MoveState.speed = v end,
})
MoveTab:AddToggle({
    Title = "JumpPower", Default = false, Flag = "mm2_jp",
    Callback = function(state)
        MoveState.jumpOn = state
        if state then startMoveLoop() end
    end,
})
MoveTab:AddSlider({
    Title = "JumpPower Value", Min = 50, Max = 300, Default = 100,
    Flag = "mm2_jp_val",
    Callback = function(v) MoveState.jump = v end,
})

MoveTab:AddSection("Physics")
MoveTab:AddToggle({
    Title = "Infinite Jump", Default = false, Flag = "mm2_ij",
    Callback = function(state)
        IJState.enabled = state
        if state then startIJ() else stopIJ() end
    end,
})
MoveTab:AddToggle({
    Title = "Noclip", Default = false, Flag = "mm2_noclip",
    Callback = function(state)
        NoclipState.enabled = state
        if state then startNoclip() else stopNoclip() end
    end,
})
MoveTab:AddToggle({
    Title = "Fly", Default = false, Flag = "mm2_fly",
    Callback = function(state)
        FlyState.enabled = state
        if state then startFly() else stopFly() end
    end,
})
MoveTab:AddSlider({
    Title = "Fly Speed", Min = 20, Max = 200, Default = 60,
    Flag = "mm2_fly_speed",
    Callback = function(v) FlyState.speed = v end,
})

local MiscTab = windows:MakeTab({Title = "Misc", Icon = "settings"})
MiscTab:AddSection("Lighting")

MiscTab:AddToggle({
    Title = "Fullbright",
    Default = false, Flag = "mm2_fb",
    Callback = function(state)
        FullbrightState.enabled = state
        if state then startFullbright() else stopFullbright() end
    end,
})

MiscTab:AddSection("Utility")
MiscTab:AddToggle({
    Title = "Anti-AFK", Default = false, Flag = "mm2_afk",
    Callback = function(state)
        if state then
            if not getgenv()._mm2AntiAFK then
                getgenv()._mm2AntiAFK = LocalPlayer.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end
        else
            if getgenv()._mm2AntiAFK then
                getgenv()._mm2AntiAFK:Disconnect()
                getgenv()._mm2AntiAFK = nil
            end
        end
    end,
})

MiscTab:AddSection("Rejoin")
MiscTab:AddButton({
    Title = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end,
})
MiscTab:AddButton({
    Title = "Server Hop",
    Callback = function()
        local ts = game:GetService("TeleportService")
        local http = game:GetService("HttpService")
        pcall(function()
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            local res = http:JSONDecode(game:HttpGet(url))
            for _, s in ipairs(res.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    ts:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                    return
                end
            end
        end)
    end,
})

notify("Lotux Hub", "MM2 loaded", 3, "Success")
print("[Lotux Hub] MM2 loader loaded.")

return redzlib