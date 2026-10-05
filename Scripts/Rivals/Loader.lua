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
assert(redzlib, "[Lotux Rivals] Failed to load redzlib")

local function notify(title, desc, dur, kind)
    pcall(function()
        redzlib:Notify({Title = title, Description = desc, Duration = dur or 2, Type = kind or "Info"})
    end)
end

local ESP = {enabled = false, showName = true, showDist = true, showHealth = true, maxDist = 500, tracked = {}, connections = {}}

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
        hl.Adornee = char
        hl.FillColor = Color3.fromRGB(255, 60, 60)
        hl.OutlineColor = Color3.new(1,1,1)
        hl.FillTransparency = 0.65
        hl.OutlineTransparency = 0.15
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = CoreGui
        entry.highlight = hl
        local bb = Instance.new("BillboardGui")
        bb.Adornee = head
        bb.Size = UDim2.new(0, 220, 0, 40)
        bb.StudsOffset = Vector3.new(0, 2.5, 0)
        bb.AlwaysOnTop = true
        bb.Parent = CoreGui
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1,0,1,0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1,1,1)
        label.TextStrokeTransparency = 0
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
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
            elseif entry.billboard and entry.label then
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                if myHrp and hrp then
                    local dist = (hrp.Position - myHrp.Position).Magnitude
                    local visible = dist <= ESP.maxDist and ESP.enabled
                    local parts = {}
                    if ESP.showName then table.insert(parts, player.DisplayName) end
                    if ESP.showHealth and hum then table.insert(parts, string.format("%d HP", math.floor(hum.Health))) end
                    if ESP.showDist then table.insert(parts, string.format("%.0fm", dist)) end
                    entry.label.Text = table.concat(parts, " | ")
                    entry.billboard.Enabled = visible
                    if entry.highlight then entry.highlight.Enabled = visible end
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

local Aimbot = {enabled = false, targetPart = "Head", fov = 200, smoothness = 0.4, visibleCheck = true, teamCheck = true, conn = nil}

local function pickTarget()
    local mouse = UIS:GetMouseLocation()
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local best, bestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if Aimbot.teamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then continue end
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local part = player.Character:FindFirstChild(Aimbot.targetPart)
                if part then
                    local sp, onScreen = Camera:WorldToScreenPoint(part.Position)
                    if onScreen then
                        local d2d = (Vector2.new(sp.X, sp.Y) - mouse).Magnitude
                        if d2d <= Aimbot.fov and d2d < bestDist then
                            if Aimbot.visibleCheck then
                                local origin = Camera.CFrame.Position
                                local dir = part.Position - origin
                                local rp = RaycastParams.new()
                                rp.FilterDescendantsInstances = {myChar, Camera}
                                rp.FilterType = Enum.RaycastFilterType.Exclude
                                local result = Workspace:Raycast(origin, dir, rp)
                                if not result or result.Instance:IsDescendantOf(player.Character) then
                                    bestDist = d2d
                                    best = part
                                end
                            else
                                bestDist = d2d
                                best = part
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

local function startAimbot()
    if Aimbot.conn then return end
    Aimbot.conn = RunService.RenderStepped:Connect(function()
        if not Aimbot.enabled then return end
        local part = pickTarget()
        if not part then return end
        local newCF = CFrame.new(Camera.CFrame.Position, part.Position)
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
        g.Name = "LotuxFOV"
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
    gyro.P = 90000; gyro.MaxTorque = Vector3.new(9e9,9e9,9e9); gyro.Parent = hrp
    local vel = Instance.new("BodyVelocity")
    vel.Velocity = Vector3.zero; vel.MaxForce = Vector3.new(9e9,9e9,9e9); vel.Parent = hrp
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
    FullbrightState.old = {FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart, Ambient = Lighting.Ambient, Brightness = Lighting.Brightness}
    Lighting.FogEnd = 1e9
    Lighting.FogStart = 1e9
    Lighting.Ambient = Color3.new(1,1,1)
    Lighting.Brightness = 2.5
end

local function stopFullbright()
    for k, v in pairs(FullbrightState.old) do pcall(function() Lighting[k] = v end) end
end

local IMG = "rbxassetid://111672166073808"

local windows = redzlib:MakeWindow({Title = "Lotux Hub", SubTitle = "Rivals", SaveFolder = "Lotux Hub\\" .. LocalPlayer.Name})

local HomeTab = windows:MakeTab({Title = "Home", Icon = "home"})
HomeTab:AddSection("Welcome To Lotux Hub | Rivals")
HomeTab:AddSection("Discord Server")
HomeTab:AddDiscordInvite({Title = "Lotux Hub", Desc = "Join our Discord for updates!", Logo = IMG, Invite = "https://discord.gg/HkB97N772p"})

local EspTab = windows:MakeTab({Title = "ESP", Icon = "eye"})
EspTab:AddSection("Player ESP")
EspTab:AddToggle({Title = "Enable ESP", Default = false, Flag = "riv_esp",
    Callback = function(state)
        ESP.enabled = state
        if state then startESP() notify("ESP", "ON", 2, "Success")
        else stopESP() notify("ESP", "OFF", 2, "Info") end
    end})
EspTab:AddToggle({Title = "Show Name", Default = true, Flag = "riv_esp_name", Callback = function(s) ESP.showName = s end})
EspTab:AddToggle({Title = "Show Health", Default = true, Flag = "riv_esp_hp", Callback = function(s) ESP.showHealth = s end})
EspTab:AddToggle({Title = "Show Distance", Default = true, Flag = "riv_esp_dist", Callback = function(s) ESP.showDist = s end})
EspTab:AddSlider({Title = "Max Distance", Min = 50, Max = 2000, Default = 500, Flag = "riv_esp_maxd",
    Callback = function(v) ESP.maxDist = v end})

local AimTab = windows:MakeTab({Title = "Aimbot", Icon = "crosshair"})
AimTab:AddSection("Aimbot")
AimTab:AddToggle({Title = "Enable Aimbot", Default = false, Flag = "riv_aim",
    Callback = function(state)
        Aimbot.enabled = state
        if state then startAimbot() notify("Aimbot", "ON", 2, "Success")
        else stopAimbot() notify("Aimbot", "OFF", 2, "Info") end
    end})
AimTab:AddDropdown({Title = "Aim Part", Options = {"Head", "HumanoidRootPart", "UpperTorso"}, Default = "Head", Flag = "riv_aim_part",
    Callback = function(v) Aimbot.targetPart = (typeof(v) == "table" and v[1]) or v end})
AimTab:AddSlider({Title = "FOV", Min = 50, Max = 800, Default = 200, Flag = "riv_fov",
    Callback = function(v) Aimbot.fov = v end})
AimTab:AddSlider({Title = "Smoothness", Min = 0.05, Max = 1, Default = 0.4, Flag = "riv_smooth",
    Callback = function(v) Aimbot.smoothness = v end})
AimTab:AddToggle({Title = "Visible Check", Default = true, Flag = "riv_vis", Callback = function(s) Aimbot.visibleCheck = s end})
AimTab:AddToggle({Title = "Team Check", Default = true, Flag = "riv_team", Callback = function(s) Aimbot.teamCheck = s end})
AimTab:AddToggle({Title = "Show FOV Circle", Default = false, Flag = "riv_fovc",
    Callback = function(s)
        FOVCircle.enabled = s
        if s then startFOVCircle() else stopFOVCircle() end
    end})

local MoveTab = windows:MakeTab({Title = "Movement", Icon = "user"})
MoveTab:AddSection("Speed")
MoveTab:AddToggle({Title = "Walkspeed", Default = false, Flag = "riv_ws",
    Callback = function(s) MoveState.speedOn = s; if s then startMoveLoop() end end})
MoveTab:AddSlider({Title = "Walkspeed Value", Min = 16, Max = 200, Default = 40, Flag = "riv_ws_val",
    Callback = function(v) MoveState.speed = v end})
MoveTab:AddToggle({Title = "JumpPower", Default = false, Flag = "riv_jp",
    Callback = function(s) MoveState.jumpOn = s; if s then startMoveLoop() end end})
MoveTab:AddSlider({Title = "JumpPower Value", Min = 50, Max = 300, Default = 100, Flag = "riv_jp_val",
    Callback = function(v) MoveState.jump = v end})
MoveTab:AddSection("Physics")
MoveTab:AddToggle({Title = "Noclip", Default = false, Flag = "riv_noclip",
    Callback = function(s) NoclipState.enabled = s; if s then startNoclip() else stopNoclip() end end})
MoveTab:AddToggle({Title = "Fly", Default = false, Flag = "riv_fly",
    Callback = function(s) FlyState.enabled = s; if s then startFly() else stopFly() end end})
MoveTab:AddSlider({Title = "Fly Speed", Min = 20, Max = 200, Default = 60, Flag = "riv_fly_speed",
    Callback = function(v) FlyState.speed = v end})

local MiscTab = windows:MakeTab({Title = "Misc", Icon = "settings"})
MiscTab:AddToggle({Title = "Fullbright", Default = false, Flag = "riv_fb",
    Callback = function(s) FullbrightState.enabled = s; if s then startFullbright() else stopFullbright() end end})
MiscTab:AddToggle({Title = "Anti-AFK", Default = false, Flag = "riv_afk",
    Callback = function(state)
        if state then
            if not getgenv()._rivAFK then
                getgenv()._rivAFK = LocalPlayer.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end
        else
            if getgenv()._rivAFK then getgenv()._rivAFK:Disconnect(); getgenv()._rivAFK = nil end
        end
    end})

notify("Lotux Hub", "Rivals loaded", 3, "Success")
print("[Lotux Hub] Rivals loader loaded.")
return redzlib