--[[
====================================================================
    LOTUX HUB — Rivals Loader
    Version: 1.0.0
    Platform: PC + Mobile
    Library: redzlib
====================================================================
    AVISOS IMPORTANTES:
    - Camera Aimbot em Rivals é LOGADO (movimento de mouse).
      Use com moderação em conta alt.
    - Speed Hack em Rivals é kick quase garantido se > 40.
    - Silent Aim: NÃO portei por padrão (URL externa não auditada).
      Se você confia em ThunderScriptSolutions, descomenta.
    - Use sempre em conta alt descartável.
====================================================================
--]]

-- ================================================================
-- [0] DEPENDÊNCIAS
-- ================================================================
local Players           = game:GetService("Players")
local UIS               = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local HttpService       = game:GetService("HttpService")
local Lighting          = game:GetService("Lighting")
local CoreGui           = game:GetService("CoreGui")
local Debris            = game:GetService("Debris")
local Workspace         = workspace

local LocalPlayer       = Players.LocalPlayer
local Camera            = Workspace.CurrentCamera

-- Carrega redzlib
local LIB_URL = "https://raw.githubusercontent.com/LotuxHub/LotuxHub/refs/heads/main/Library/LotuxLibrary.lua"
if not redzlib then
    local ok, lib = pcall(function() return loadstring(game:HttpGet(LIB_URL))() end)
    if ok and lib then redzlib = lib end
end
assert(redzlib, "[Lotux Rivals] Nao foi possivel carregar redzlib")

-- Notify helper
local function notify(title, desc, dur, kind)
    pcall(function()
        redzlib:Notify({
            Title = title,
            Description = desc,
            Duration = dur or 2,
            Type = kind or "Info",
        })
    end)
end

local IS_MOBILE = UIS.TouchEnabled and not UIS.MouseEnabled
getgenv().LotuxMobile = IS_MOBILE

-- ================================================================
-- [1] ESP LIBRARY (linemaster2)
-- ================================================================
local ESP = {}
local ESPLoaded = false

local function loadESPLibrary()
    if ESPLoaded and ESP.Enabled ~= nil then return true end
    local ok, lib = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/linemaster2/esp-library/main/library.lua"))()
    end)
    if ok and type(lib) == "table" then
        ESP = lib
        ESP.Enabled = false
        ESP.ShowBox = false
        ESP.ShowName = false
        ESP.ShowHealth = false
        ESP.ShowTracer = false
        ESP.ShowDistance = false
        ESP.ShowSkeletons = false
        ESP.TeamCheck = false
        ESP.BoxType = "2D"
        ESP.TracerPosition = "Bottom"
        ESPLoaded = true
        return true
    end
    return false
end

-- ================================================================
-- [2] AIMBOT BACKEND (refatorado — sem travamento)
-- ================================================================
local Aimbot = {
    enabled = false,
    aimAtPart = "HumanoidRootPart",   -- "HumanoidRootPart" | "Head"
    wallCheck = false,
    teamCheck = false,
    targetNPCs = false,
    loopConnection = nil,
    target = nil,
}

local function getClosestTarget()
    local character = LocalPlayer.Character
    if not character then return nil end
    local localRoot = character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end

    local nearestTarget = nil
    local shortestDistance = math.huge

    local function checkTarget(target)
        if not target or not target:IsA("Model") then return end
        local humanoid = target:FindFirstChild("Humanoid")
        local targetRoot = target:FindFirstChild(Aimbot.aimAtPart)
        if not humanoid or not targetRoot or humanoid.Health <= 0 then return end

        -- Skip local player character
        if target == character then return end

        local distance = (targetRoot.Position - localRoot.Position).Magnitude
        if distance >= shortestDistance then return end

        -- Wall check
        if Aimbot.wallCheck then
            local rayDirection = (targetRoot.Position - Camera.CFrame.Position).Unit * 1000
            local rp = RaycastParams.new()
            rp.FilterDescendantsInstances = {character}
            rp.FilterType = Enum.RaycastFilterType.Exclude
            local result = Workspace:Raycast(Camera.CFrame.Position, rayDirection, rp)
            if result and not result.Instance:IsDescendantOf(target) then
                return
            end
        end

        shortestDistance = distance
        nearestTarget = target
    end

    -- Players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not Aimbot.teamCheck or player.Team ~= LocalPlayer.Team then
                checkTarget(player.Character)
            end
        end
    end

    -- NPCs
    if Aimbot.targetNPCs then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild(Aimbot.aimAtPart) then
                -- skip player characters (they're already covered)
                if not Players:GetPlayerFromCharacter(obj) then
                    checkTarget(obj)
                end
            end
        end
    end

    return nearestTarget
end

local function lookAt(position)
    if not position then return end
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, position)
end

local function stopAimbot()
    if Aimbot.loopConnection then
        Aimbot.loopConnection:Disconnect()
        Aimbot.loopConnection = nil
    end
    Aimbot.target = nil
end

local function startAimbot()
    stopAimbot()

    Aimbot.loopConnection = RunService.RenderStepped:Connect(function()
        if not Aimbot.enabled then
            stopAimbot()
            return
        end

        local target = getClosestTarget()
        Aimbot.target = target

        if target then
            local targetRoot = target:FindFirstChild(Aimbot.aimAtPart)
            if targetRoot then
                lookAt(targetRoot.Position)
            end
        end
    end)
end

-- ================================================================
-- [3] INFINITE JUMP (corrigido)
-- ================================================================
local InfiniteJump = {
    enabled = false,
    connection = nil,
}

local function startInfiniteJump()
    if InfiniteJump.connection then
        InfiniteJump.connection:Disconnect()
        InfiniteJump.connection = nil
    end
    InfiniteJump.connection = UIS.JumpRequest:Connect(function()
        if not InfiniteJump.enabled then return end
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function stopInfiniteJump()
    if InfiniteJump.connection then
        InfiniteJump.connection:Disconnect()
        InfiniteJump.connection = nil
    end
end

-- ================================================================
-- [4] SPEED HACK (safe loop)
-- ================================================================
local SpeedHack = {
    enabled = false,
    speed = 16,
    connection = nil,
}

local function startSpeedHack()
    if SpeedHack.connection then
        SpeedHack.connection:Disconnect()
        SpeedHack.connection = nil
    end
    SpeedHack.connection = RunService.Heartbeat:Connect(function()
        if not SpeedHack.enabled then return end
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.WalkSpeed ~= SpeedHack.speed then
            humanoid.WalkSpeed = SpeedHack.speed
        end
    end)
end

local function stopSpeedHack()
    if SpeedHack.connection then
        SpeedHack.connection:Disconnect()
        SpeedHack.connection = nil
    end
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 16
    end
end

-- ================================================================
-- [5] UI — redzlib
-- ================================================================
local IMG = "rbxassetid://111672166073808"

local windows = redzlib:MakeWindow({
    Title = "Lotux Hub",
    SubTitle = "Rivals",
    SaveFolder = "Lotux Hub\\" .. LocalPlayer.Name,
})

-- ---- HOME ----
local HomeTab = windows:MakeTab({ Title = "Home", Icon = "home" })
HomeTab:AddSection("Welcome To Lotux Hub | Rivals")
HomeTab:AddSection("Discord Server")
HomeTab:AddDiscordInvite({
    Title = "Lotux Hub",
    Desc = "Join our Discord community for updates and support!",
    Logo = IMG,
    Invite = "https://discord.gg/HkB97N772p",
})

-- ---- AIMBOT ----
local AimbotTab = windows:MakeTab({ Title = "Aimbot", Icon = "crosshair" })
AimbotTab:AddSection("Aimbot Settings")

AimbotTab:AddToggle({
    Name = "Aimbot",
    Description = "Camera snap to closest enemy (use with caution)",
    Default = false,
    Flag = "aimbot_enabled",
    Callback = function(state)
        Aimbot.enabled = state
        if state then
            startAimbot()
            notify("Aimbot", "Enabled", 2, "Success")
        else
            stopAimbot()
            notify("Aimbot", "Disabled", 2, "Error")
        end
    end,
})

AimbotTab:AddDropdown({
    Name = "Aim Part",
    Description = "Where to aim at",
    Options = {"HumanoidRootPart", "Head"},
    Default = "HumanoidRootPart",
    Flag = "aimbot_part",
    Callback = function(value)
        Aimbot.aimAtPart = (typeof(value) == "table" and value[1]) or value
    end,
})

AimbotTab:AddToggle({
    Name = "Wall Check",
    Description = "Only aim at visible targets",
    Default = false,
    Flag = "aimbot_wallcheck",
    Callback = function(state) Aimbot.wallCheck = state end,
})

AimbotTab:AddToggle({
    Name = "Team Check",
    Description = "Don't aim at teammates",
    Default = false,
    Flag = "aimbot_teamcheck",
    Callback = function(state) Aimbot.teamCheck = state end,
})

AimbotTab:AddToggle({
    Name = "Target NPCs",
    Description = "Include NPCs in target selection",
    Default = false,
    Flag = "aimbot_npcs",
    Callback = function(state) Aimbot.targetNPCs = state end,
})

AimbotTab:AddSection("Silent Aim")
AimbotTab:AddParagraph({
    Title = "Silent Aim (external)",
    Text = "NÃO PORTEI por padrão — a URL original aponta pra um repo externo de terceiros (ThunderScriptSolutions). Se você confia nessa source, descomente o botão no Loader.lua. Do contrário, NÃO USE — pode ser token logger.",
})

AimbotTab:AddButton({
    Name = "Silent Aim (UNSAFE - audit URL first)",
    Description = "Loads external script — read the source before running",
    Callback = function()
        local url = "https://raw.githubusercontent.com/ThunderScriptSolutions/Misc/refs/heads/main/RivalsSilentAim"
        notify("Silent Aim", "Audit the URL before use", 4, "Warning")
        -- Se você auditou e confia:
        -- loadstring(game:HttpGet(url))()
    end,
})

-- ---- ESP ----
local ESPTab = windows:MakeTab({ Title = "ESP", Icon = "eye" })
ESPTab:AddSection("ESP Settings")

ESPTab:AddParagraph({
    Title = "ESP Library",
    Text = "Usa a lib pública linemaster2/esp-library. Carrega automaticamente no primeiro toggle.",
})

local function ensureESP()
    if not ESPLoaded then
        local ok = loadESPLibrary()
        if not ok then
            notify("ESP", "Failed to load ESP library", 3, "Error")
            return false
        end
    end
    return true
end

ESPTab:AddToggle({
    Name = "Enable ESP",
    Description = "Master toggle",
    Default = false,
    Flag = "esp_enabled",
    Callback = function(state)
        if not ensureESP() then return end
        ESP.Enabled = state
    end,
})

ESPTab:AddToggle({
    Name = "Show Box",
    Description = "Draw box around players",
    Default = false,
    Flag = "esp_box",
    Callback = function(state)
        if not ensureESP() then return end
        ESP.ShowBox = state
    end,
})

ESPTab:AddToggle({
    Name = "Show Name",
    Description = "Draw name above players",
    Default = false,
    Flag = "esp_name",
    Callback = function(state)
        if not ensureESP() then return end
        ESP.ShowName = state
    end,
})

ESPTab:AddToggle({
    Name = "Show Health",
    Description = "Draw health bar",
    Default = false,
    Flag = "esp_health",
    Callback = function(state)
        if not ensureESP() then return end
        ESP.ShowHealth = state
    end,
})

ESPTab:AddToggle({
    Name = "Show Tracer",
    Description = "Line from bottom of screen to target",
    Default = false,
    Flag = "esp_tracer",
    Callback = function(state)
        if not ensureESP() then return end
        ESP.ShowTracer = state
    end,
})

ESPTab:AddToggle({
    Name = "Show Distance",
    Description = "Distance to target",
    Default = false,
    Flag = "esp_distance",
    Callback = function(state)
        if not ensureESP() then return end
        ESP.ShowDistance = state
    end,
})

ESPTab:AddToggle({
    Name = "Show Skeleton",
    Description = "Draw skeleton",
    Default = false,
    Flag = "esp_skeleton",
    Callback = function(state)
        if not ensureESP() then return end
        ESP.ShowSkeletons = state
    end,
})

ESPTab:AddToggle({
    Name = "Team Check",
    Description = "Only show enemies",
    Default = false,
    Flag = "esp_teamcheck",
    Callback = function(state)
        if not ensureESP() then return end
        ESP.TeamCheck = state
    end,
})

ESPTab:AddDropdown({
    Name = "Box Type",
    Description = "Style of box drawing",
    Options = {"2D", "Corner Box Esp"},
    Default = "2D",
    Flag = "esp_box_type",
    Callback = function(value)
        if not ensureESP() then return end
        local v = (typeof(value) == "table" and value[1]) or value
        ESP.BoxType = v
    end,
})

ESPTab:AddDropdown({
    Name = "Tracer Position",
    Description = "Where the tracer starts",
    Options = {"Bottom", "Top", "Middle"},
    Default = "Bottom",
    Flag = "esp_tracer_pos",
    Callback = function(value)
        if not ensureESP() then return end
        local v = (typeof(value) == "table" and value[1]) or value
        ESP.TracerPosition = v
    end,
})

-- ---- MISC ----
local MiscTab = windows:MakeTab({ Title = "Misc", Icon = "settings" })
MiscTab:AddSection("Movement")

MiscTab:AddToggle({
    Name = "Infinite Jump",
    Description = "Jump infinitely in the air",
    Default = false,
    Flag = "infinite_jump",
    Callback = function(state)
        InfiniteJump.enabled = state
        if state then
            startInfiniteJump()
            notify("Infinite Jump", "ON", 2, "Success")
        else
            stopInfiniteJump()
            notify("Infinite Jump", "OFF", 2, "Error")
        end
    end,
})

MiscTab:AddToggle({
    Name = "Speed Hack",
    Description = "Override WalkSpeed continuously",
    Default = false,
    Flag = "speed_hack_enabled",
    Callback = function(state)
        SpeedHack.enabled = state
        if state then
            startSpeedHack()
            notify("Speed Hack", "ON", 2, "Success")
        else
            stopSpeedHack()
            notify("Speed Hack", "OFF", 2, "Error")
        end
    end,
})

MiscTab:AddSlider({
    Name = "Speed Value",
    Description = "WalkSpeed (16 = default, 40+ = risky)",
    Min = 16, Max = 100, Default = 16,
    Flag = "speed_hack_value",
    Callback = function(value)
        SpeedHack.speed = value
    end,
})

MiscTab:AddParagraph({
    Title = "Speed Hack Warning",
    Text = "Acima de ~40 de WalkSpeed, o servidor do Rivals te kicka em 1-2 partidas. Mantenha em 30-40 para minimizar risco.",
})

-- ---- INFO ----
local InfoTab = windows:MakeTab({ Title = "Info", Icon = "info" })
InfoTab:AddSection("Credits")
InfoTab:AddParagraph({
    Title = "Aimbot + Infinite Jump + Speed Hack",
    Text = "Based on Onetap ReCoded by Aidar & Smash (bugs corrigidos)",
})
InfoTab:AddParagraph({
    Title = "ESP Library",
    Text = "linemaster2/esp-library (public)",
})
InfoTab:AddParagraph({
    Title = "UI Library",
    Text = "redzlib (LotuxLibrary)",
})

-- ================================================================
-- [6] CLEANUP
-- ================================================================
-- Cleanup ao sair
Players.LocalPlayer.CharacterAdded:Connect(function()
    if InfiniteJump.enabled then startInfiniteJump() end
    if SpeedHack.enabled then
        task.wait(1)
        startSpeedHack()
    end
end)

-- ================================================================
-- [7] FINAL
-- ================================================================
notify("Lotux Hub", "Loaded — Rivals ready", 3, "Success")
print("[Lotux Hub] Rivals loader carregado com sucesso.")
print("[Lotux Hub] Aimbot: camera snap | Speed Hack: continuous | ESP: linemaster2")

return redzlib