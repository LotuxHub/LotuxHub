-- =====================================================
--         Lotux Hub - Blox Fruits Script
--         by LoadFlint/lucas
--         v3.0 - Modular + Visual Features
-- =====================================================

-- =====================================================
-- CARREGA MODULOS
-- =====================================================
local redzlib   = loadstring(game:HttpGet("https://raw.githubusercontent.com/LotuxHub/LotuxHub/refs/heads/main/Library/LotuxLibrary.lua"))()
local QuestData = loadstring(game:HttpGet("https://raw.githubusercontent.com/LotuxHub/LotuxHub/refs/heads/main/DevCopy/BloxFruits/Quests.lua"))()
local Config    = loadstring(game:HttpGet("https://raw.githubusercontent.com/LotuxHub/LotuxHub/refs/heads/main/DevCopy/BloxFruits/Config.lua"))()
local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/LotuxHub/LotuxHub/refs/heads/main/DevCopy/BloxFruits/Functions.lua"))()

-- =====================================================
-- SERVICES
-- =====================================================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local VirtualUser       = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService       = game:GetService("HttpService")
local Lighting          = game:GetService("Lighting")
local UserInputService  = game:GetService("UserInputService")

local Player = Players.LocalPlayer

-- =====================================================
-- REFERENCIAS INTERNAS
-- =====================================================
local isTeleporting = { value = false }
local NoClip        = { value = false }
local NotAutoEquip  = { value = false }
local BringPos      = CFrame.new(0, 0, 0)

local Character, Humanoid, HumanoidRootPart
local function UpdateChar(c)
    Character        = c
    Humanoid         = c:WaitForChild("Humanoid")
    HumanoidRootPart = c:WaitForChild("HumanoidRootPart")
end
UpdateChar(Player.Character or Player.CharacterAdded:Wait())
Player.CharacterAdded:Connect(function(c)
    UpdateChar(c)
    isTeleporting.value = false
    NoClip.value        = false
end)

local Camera = workspace.CurrentCamera

-- =====================================================
-- REMOTES
-- =====================================================
local CommF_
pcall(function()
    CommF_ = ReplicatedStorage:WaitForChild("Remotes", 5)
                              :WaitForChild("CommF_", 5)
end)

-- =====================================================
-- DADOS DAS QUESTS
-- =====================================================
local QuestList = QuestData.QuestList
local Islands   = QuestData.Islands
local Materials = QuestData.Materials
local Bosses    = QuestData.Bosses

-- =====================================================
-- LANGUAGE SYSTEM
-- =====================================================
local LangData    = {}
local CurrentLang = "English"

local LANG_URL = "https://raw.githubusercontent.com/LotuxHub/LotuxHub/refs/heads/main/DevCopy/BloxFruits/Language.json"

local function LoadLanguage()
    local ok, raw = pcall(function() return game:HttpGet(LANG_URL, true) end)
    if ok and raw then
        local ok2, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
        if ok2 and decoded then LangData = decoded end
    end
end
LoadLanguage()

local function T(key, vars)
    local lang = LangData[CurrentLang] or LangData["English"] or {}
    local str  = lang[key] or (LangData["English"] and LangData["English"][key]) or key
    if vars then
        for k, v in pairs(vars) do str = str:gsub("{" .. k .. "}", tostring(v)) end
    end
    return str
end

-- =====================================================
-- DETECT SEA
-- =====================================================
local SEA_PLACE_IDS = {
    [1] = { 2753915549, 6817450498, 8903419500 },
    [2] = { 4442272183, 79091703265657, 8165217374, 9176847717 },
    [3] = { 7449423635, 11100731664 },
}

local function GetSeaByPlaceId()
    local pid = game.PlaceId
    for sea, ids in pairs(SEA_PLACE_IDS) do
        for _, id in ipairs(ids) do
            if pid == id then return sea end
        end
    end
    return nil
end

local function GetSeaByWorkspace()
    local sea3Keywords = { "SeaOfTreats", "Hydra", "Tartarus", "CastleOnSea", "FloatingTurtle", "HydraIsland" }
    local sea2Keywords = { "Dressrosa", "GreenZone", "KingdomOfRose", "Graveyard", "SnowMountain", "DressrosaIsland" }
    local sea1Keywords = { "Jungle", "PirateVillage", "MiddleTown", "Desert", "Skylands" }
    for _, kw in ipairs(sea3Keywords) do if workspace:FindFirstChild(kw, true) then return 3 end end
    for _, kw in ipairs(sea2Keywords) do if workspace:FindFirstChild(kw, true) then return 2 end end
    for _, kw in ipairs(sea1Keywords) do if workspace:FindFirstChild(kw, true) then return 1 end end
    return nil
end

local function GetSeaByLevel()
    local ok, level = pcall(function() return Player.Data.Level.Value end)
    if ok and level then
        if level >= 1500 then return 3
        elseif level >= 700 then return 2
        else return 1 end
    end
    return 1
end

_G.OverrideSea = nil

local function GetSea()
    if _G.OverrideSea then return _G.OverrideSea end
    local sea = GetSeaByPlaceId()
    if sea then return sea end
    sea = GetSeaByWorkspace()
    if sea then return sea end
    return GetSeaByLevel()
end

local CurrentSea = GetSea()
World1 = (CurrentSea == 1)
World2 = (CurrentSea == 2)
World3 = (CurrentSea == 3)

-- =====================================================
-- INICIA RESOLVER DE ARMA
-- =====================================================
Functions.StartWeaponResolver(Config)

-- =====================================================
-- NOCLIP LOOP
-- =====================================================
task.spawn(function()
    while task.wait() do
        pcall(function()
            Functions.ApplyNoClip(Player, NoClip.value or Config.NoClip)
        end)
    end
end)

-- =====================================================
-- AUTOCLICK LOOP
-- =====================================================
local currentTarget = nil

task.spawn(function()
    while task.wait(0.12) do
        if not Config.AutoClick then continue end
        local char = Player.Character
        if not char or not HumanoidRootPart then continue end
        if Humanoid and Humanoid.Health <= 0 then continue end

        local bestTarget, bestDist = nil, math.huge

        local enemies = workspace:FindFirstChild("Enemies")
        if enemies then
            for _, obj in ipairs(enemies:GetChildren()) do
                if obj:IsA("Model") and obj ~= char then
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    local hrp = obj:FindFirstChild("HumanoidRootPart")
                    if hum and hrp and hum.Health > 0 then
                        local d = (hrp.Position - HumanoidRootPart.Position).Magnitude
                        if d < bestDist then bestDist = d; bestTarget = obj end
                    end
                end
            end
        end

        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= Player then
                local otherChar = otherPlayer.Character
                if otherChar then
                    local hum = otherChar:FindFirstChildOfClass("Humanoid")
                    local hrp = otherChar:FindFirstChild("HumanoidRootPart")
                    if hum and hrp and hum.Health > 0 then
                        local d = (hrp.Position - HumanoidRootPart.Position).Magnitude
                        if d < bestDist then bestDist = d; bestTarget = otherChar end
                    end
                end
            end
        end

        if not bestTarget then continue end
        local hrpTarget = bestTarget:FindFirstChild("HumanoidRootPart")
        if not hrpTarget then continue end

        pcall(function()
            HumanoidRootPart.CFrame = CFrame.lookAt(HumanoidRootPart.Position, hrpTarget.Position)
        end)

        local dist = (hrpTarget.Position - HumanoidRootPart.Position).Magnitude
        if dist > 25 then continue end

        Functions.FastAttack(bestTarget, Config, NotAutoEquip)
    end
end)

-- =====================================================
-- FARM LOOP PRINCIPAL
-- =====================================================
local farmRunning = false

task.spawn(function()
    while true do
        task.wait(0.05)

        if not Config.AutoFarmLevel and not Config.AutoFarmNearest then
            if currentTarget ~= nil then currentTarget = nil end
            NoClip.value = false
            farmRunning  = false
            task.wait(0.2)
            continue
        end

        if farmRunning then continue end
        farmRunning = true

        local char = Player.Character
        if not char or not HumanoidRootPart or not Humanoid or Humanoid.Health <= 0 then
            farmRunning = false; continue
        end

        -- AUTO FARM NEAREST
        if Config.AutoFarmNearest and not Config.AutoFarmLevel then
            pcall(function()
                local mob = Functions.GetNearestEnemy(Character, HumanoidRootPart, nil)
                if not mob then farmRunning = false; return end
                local hrp = mob:FindFirstChild("HumanoidRootPart")
                local hum = mob:FindFirstChild("Humanoid")
                if not hrp or not hum or hum.Health <= 0 then farmRunning = false; return end

                if Config.AutoBusoHaki then Functions.ActivateBuso(CommF_) end
                if Config.SelectedWeaponName and Config.SelectedWeaponName ~= "" then
                    Functions.EquipWeapon(Config.SelectedWeaponName, NotAutoEquip)
                end
                currentTarget = mob
                NoClip.value  = true

                repeat
                    task.wait()
                    if not mob.Parent then break end
                    local mhrp = mob:FindFirstChild("HumanoidRootPart")
                    if not mhrp then break end
                    BringPos = mhrp.CFrame
                    Functions.FlyToPosition(
                        mhrp.CFrame * CFrame.new(0, Config.FlyOffset, 0),
                        TweenService, Config, isTeleporting, NotAutoEquip
                    )
                    if Config.BringMob then Functions.BringMobFunc(mob, BringPos) end
                until not mob.Parent
                    or not mob:FindFirstChild("Humanoid")
                    or mob:FindFirstChild("Humanoid").Health <= 0
                    or (not Config.AutoFarmNearest and not Config.AutoFarmLevel)

                NoClip.value = false
                local mhum = mob:FindFirstChild("Humanoid")
                if mhum and mhum.Health <= 0 then Config.KillCount = Config.KillCount + 1 end
                currentTarget = nil
            end)
            farmRunning = false

        -- AUTO FARM LEVEL (com quest)
        elseif Config.AutoFarmLevel then
            pcall(function()
                local quest = Functions.GetQuestForLevel(QuestList, CurrentSea, Player)
                if not quest then farmRunning = false; return end

                if quest.RequestEntrance and HumanoidRootPart then
                    if (quest.CFrameMon.Position - HumanoidRootPart.Position).Magnitude > 10000 then
                        pcall(function() CommF_:InvokeServer("requestEntrance", quest.RequestEntrance) end)
                        task.wait(1)
                    end
                end

                local questGui     = Player.PlayerGui:FindFirstChild("Main")
                                     and Player.PlayerGui.Main:FindFirstChild("Quest")
                local questVisible = questGui and questGui.Visible or false
                local questTitle   = ""
                pcall(function()
                    questTitle = Player.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
                end)

                -- Sem quest -> pega a quest
                if not questVisible then
                    currentTarget = nil
                    NoClip.value  = false

                    if HumanoidRootPart and
                       (quest.CFrameQuest.Position - HumanoidRootPart.Position).Magnitude > 8 then
                        NoClip.value = true
                        Functions.FlyToPosition(
                            quest.CFrameQuest,
                            TweenService, Config, isTeleporting, NotAutoEquip
                        )
                        NoClip.value = false
                    end

                    task.wait(0.3)
                    pcall(function() CommF_:InvokeServer("StartQuest", quest.NameQuest, quest.QuestLv) end)
                    task.wait(0.5)
                    if Config.SelectedWeaponName and Config.SelectedWeaponName ~= "" then
                        Functions.EquipWeapon(Config.SelectedWeaponName, NotAutoEquip)
                    end

                -- Quest ativa
                else
                    local questIsCorrect = string.find(questTitle, quest.Mob, 1, true) ~= nil

                    if not questIsCorrect then
                        currentTarget = nil
                        NoClip.value  = false
                        pcall(function() CommF_:InvokeServer("AbandonQuest") end)
                        task.wait(0.5)
                    else
                        local mob = Functions.GetNearestEnemy(Character, HumanoidRootPart, quest.Mob)

                        if mob then
                            local hrp = mob:FindFirstChild("HumanoidRootPart")
                            local hum = mob:FindFirstChild("Humanoid")
                            if hrp and hum and hum.Health > 0 then
                                if Config.AutoBusoHaki then Functions.ActivateBuso(CommF_) end
                                if Config.SelectedWeaponName and Config.SelectedWeaponName ~= "" then
                                    Functions.EquipWeapon(Config.SelectedWeaponName, NotAutoEquip)
                                end
                                currentTarget = mob
                                NoClip.value  = true
                                local bringPosition = hrp.CFrame

                                repeat
                                    task.wait()
                                    if not mob.Parent then break end
                                    local mhrp = mob:FindFirstChild("HumanoidRootPart")
                                    if not mhrp then break end
                                    bringPosition = mhrp.CFrame
                                    local distToMob = (mhrp.Position - HumanoidRootPart.Position).Magnitude
                                    if distToMob > 15 then
                                        Functions.FlyToPosition(
                                            mhrp.CFrame * CFrame.new(0, Config.FlyOffset, 0),
                                            TweenService, Config, isTeleporting, NotAutoEquip
                                        )
                                    end
                                    if Config.BringMob then
                                        local enemiesFolder = workspace:FindFirstChild("Enemies")
                                        if enemiesFolder then
                                            for _, otherMob in ipairs(enemiesFolder:GetChildren()) do
                                                if otherMob ~= mob and otherMob.Name == quest.Mob then
                                                    local ohrp = otherMob:FindFirstChild("HumanoidRootPart")
                                                    local ohum = otherMob:FindFirstChild("Humanoid")
                                                    if ohrp and ohum and ohum.Health > 0 then
                                                        local distOther = (ohrp.Position - bringPosition.Position).Magnitude
                                                        if distOther <= Config.BringDistance then
                                                            Functions.BringMobFunc(otherMob, bringPosition)
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                until not mob.Parent
                                    or not mob:FindFirstChild("Humanoid")
                                    or mob:FindFirstChild("Humanoid").Health <= 0
                                    or not Config.AutoFarmLevel

                                NoClip.value = false
                                local mhum = mob:FindFirstChild("Humanoid")
                                if mhum and mhum.Health <= 0 then
                                    Config.KillCount = Config.KillCount + 1
                                end
                                currentTarget = nil
                            end
                        else
                            currentTarget = nil
                            NoClip.value  = true
                            Functions.FlyToPosition(
                                quest.CFrameMon * CFrame.new(0, Config.FlyOffset, 0),
                                TweenService, Config, isTeleporting, NotAutoEquip
                            )
                            NoClip.value = false
                            local rs = game:GetService("ReplicatedStorage")
                            if rs:FindFirstChild(quest.Mob) then
                                local rsMob = rs:FindFirstChild(quest.Mob)
                                local rsMobHrp = rsMob:FindFirstChild("HumanoidRootPart")
                                if rsMobHrp then
                                    NoClip.value = true
                                    Functions.FlyToPosition(
                                        rsMobHrp.CFrame * CFrame.new(0, 20, 0),
                                        TweenService, Config, isTeleporting, NotAutoEquip
                                    )
                                    NoClip.value = false
                                end
                            end
                        end
                    end
                end
            end)
            farmRunning = false
        end
    end
end)

-- =====================================================
-- ESP MOB - CIRCULO VERDE (Drawing API)
-- Raio de deteccao: 5000 studs, circulo pequeno
-- =====================================================
local _mobESP   = {}
local _espConns = {}

local function _createMobCircle()
    local circle        = Drawing.new("Circle")
    circle.Color        = Color3.fromRGB(0, 255, 0)
    circle.Thickness    = 2
    circle.NumSides     = 50
    circle.Filled       = false
    circle.Radius       = 1.2
    circle.Visible      = true
    return circle
end

local function _addMobCircleESP(mob)
    if _mobESP[mob] then return end
    local circle = _createMobCircle()
    _mobESP[mob] = circle
    mob.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if _mobESP[mob] then
                _mobESP[mob]:Remove()
                _mobESP[mob] = nil
            end
        end
    end)
end

local function _clearAllMobCircles()
    for mob, circle in pairs(_mobESP) do
        pcall(function() circle:Remove() end)
        _mobESP[mob] = nil
    end
end

-- Loop de update dos circulos
local _espCircleConn = nil
local function _startMobCircleLoop()
    if _espCircleConn then return end
    _espCircleConn = RunService.RenderStepped:Connect(function()
        if not Config.ESPEnabled then return end
        local char = Player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for mob, circle in pairs(_mobESP) do
            pcall(function()
                if mob and mob:FindFirstChild("HumanoidRootPart")
                   and mob:FindFirstChildOfClass("Humanoid")
                   and mob.Humanoid.Health > 0 then
                    local distance = (mob.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if distance <= 5000 then
                        local pos, onScreen = Camera:WorldToViewportPoint(mob.HumanoidRootPart.Position)
                        if onScreen then
                            circle.Position = Vector2.new(pos.X, pos.Y)
                            circle.Visible  = true
                        else
                            circle.Visible = false
                        end
                    else
                        circle.Visible = false
                    end
                else
                    circle.Visible = false
                end
            end)
        end
    end)
end

local function _stopMobCircleLoop()
    if _espCircleConn then
        _espCircleConn:Disconnect()
        _espCircleConn = nil
    end
end

-- Registra mobs ja existentes e novos
local function _initMobCircleESP()
    local ef = workspace:FindFirstChild("Enemies")
    if ef then
        for _, mob in ipairs(ef:GetChildren()) do _addMobCircleESP(mob) end
        ef.ChildAdded:Connect(function(mob)
            task.wait(0.2)
            if Config.ESPEnabled then _addMobCircleESP(mob) end
        end)
    end
end

-- =====================================================
-- ESP LOOP - SelectionBox (existente)
-- =====================================================
RunService.Heartbeat:Connect(function()
    if not Config.ESPEnabled then return end
    local ef = workspace:FindFirstChild("Enemies")
    if not ef then return end
    for _, obj in ipairs(ef:GetChildren()) do
        if obj:IsA("Model") and obj ~= Character then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and not obj:FindFirstChild("ESP_Lotux") then
                local box         = Instance.new("SelectionBox")
                box.Name          = "ESP_Lotux"
                box.Color3        = Color3.fromRGB(255, 50, 50)
                box.LineThickness  = 0.05
                box.Adornee       = obj
                box.Parent        = obj
            end
        end
    end
end)

-- =====================================================
-- INFINITE JUMP
-- =====================================================
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- =====================================================
-- NOTIFICACOES
-- =====================================================
local IMG     = "rbxassetid://1116721660738080" -- Icone padrao das notificacoes (pode ser trocado por outro link de imagem)
local uiReady = false
local function Notify(cfg)
    if not uiReady then return end
    pcall(function() redzlib:Notify(cfg) end)
end

-- =====================================================
-- WINDOW
-- =====================================================
local Window = redzlib:MakeWindow({
    Title      = "Lotux Hub",
    SubTitle   = "by LoadFlint/lucas v3.0",
    SaveFolder = "LotuxHub_Save",
})

Window:AddMinimizeButton({
    Button = { Size = UDim2.fromOffset(45, 45), Position = UDim2.fromScale(0.05, 0.05), Image = IMG, BackgroundTransparency = 1 },
    Corner = { CornerRadius = UDim.new(1, 0) },
})

-- =====================================================
-- TAB: HOME
-- =====================================================
local Home = Window:MakeTab({ Title = T("tab_home"), Icon = "home" })
Home:AddSection(T("sec_discord"))
Home:AddDiscordInvite({ Title = "Lotux Hub", Logo = IMG, Link = "https://discord.gg/HkB97N772p" })
Home:AddSection(T("sec_states"))

local tzPara        = Home:AddParagraph({ Title = T("lbl_time_zone"),    Text = T("loading") })
local tscrPara      = Home:AddParagraph({ Title = T("lbl_time_script"),  Text = "00:00:00" })
local tsrvPara      = Home:AddParagraph({ Title = T("lbl_time_server"),  Text = "00:00:00" })
local miragePara    = Home:AddParagraph({ Title = T("lbl_mirage"),       Text = T("loading") })
local kitsPara      = Home:AddParagraph({ Title = T("lbl_kitsune"),      Text = T("loading") })
local prHistPara    = Home:AddParagraph({ Title = T("lbl_prehistoric"),  Text = T("loading") })
local frozenPara    = Home:AddParagraph({ Title = T("lbl_frozen"),       Text = T("loading") })
local swordDealPara = Home:AddParagraph({ Title = T("lbl_sword_dealer"), Text = T("loading") })
local fruitPara     = Home:AddParagraph({ Title = T("lbl_fruit"),        Text = T("loading") })
local berryPara     = Home:AddParagraph({ Title = T("lbl_berry"),        Text = T("loading") })
local baristaPara   = Home:AddParagraph({ Title = T("lbl_barista"),      Text = T("loading") })
local ripIndraPara  = Home:AddParagraph({ Title = T("lbl_rip_indra"),    Text = T("loading") })
local seaPara       = Home:AddParagraph({ Title = "Sea Detectado",       Text = "Sea " .. CurrentSea .. " (PlaceId: " .. game.PlaceId .. ")" })
local killPara      = Home:AddParagraph({ Title = "Kill Count",          Text = "0" })
local weaponPara    = Home:AddParagraph({ Title = "Arma Equipada",       Text = "Nenhuma" })
local questPara     = Home:AddParagraph({ Title = "Quest Atual",         Text = "Nenhuma" })
local weaponResPara = Home:AddParagraph({ Title = "Arma Resolvida",      Text = "..." })

task.spawn(function()
    while true do
        task.wait(1)
        local t = os.date("*t")
        pcall(function()
            tzPara:Set(T("lbl_time_zone"), string.format(
                "%02d/%02d/%04d  %02d:%02d:%02d",
                t.day, t.month, t.year, t.hour, t.min, t.sec))
        end)
        pcall(function() tscrPara:Set(T("lbl_time_script"), Functions.FormatTime(os.time() - Config.ScriptStartTime)) end)
        pcall(function() tsrvPara:Set(T("lbl_time_server"), Functions.FormatTime(math.floor(workspace.DistributedGameTime))) end)
        pcall(function() killPara:Set("Kill Count", tostring(Config.KillCount)) end)
        pcall(function()
            local char     = Player.Character
            local equipped = char and char:FindFirstChildOfClass("Tool")
            weaponPara:Set("Arma Equipada", equipped and equipped.Name or "Nenhuma")
        end)
        pcall(function()
            weaponResPara:Set("Arma Resolvida",
                Config.SelectedWeaponName ~= "" and Config.SelectedWeaponName or "(nenhuma na mochila)")
        end)
        pcall(function()
            local q = Functions.GetQuestForLevel(QuestList, CurrentSea, Player)
            questPara:Set("Quest Atual", q and (q.Mob .. " (Lv " .. q.Level .. ")") or "Nenhuma")
        end)
        pcall(function()
            local function sp(name) return workspace:FindFirstChild(name, true) ~= nil end
            local yes, no = T("lbl_spawned"), T("lbl_not_spawned")
            miragePara:Set(T("lbl_mirage"),          sp("MirageIsland")      and yes or no)
            kitsPara:Set(T("lbl_kitsune"),           sp("KitsuneIsland")     and yes or no)
            prHistPara:Set(T("lbl_prehistoric"),     sp("PreHistoricIsland") and yes or no)
            frozenPara:Set(T("lbl_frozen"),          sp("FrozenIsland")      and yes or no)
            swordDealPara:Set(T("lbl_sword_dealer"), sp("LegendSwordDealer") and yes or no)
            ripIndraPara:Set(T("lbl_rip_indra"),     sp("RipIndra")          and yes or no)
            local fruit = workspace:FindFirstChild("Fruits", true) or workspace:FindFirstChild("Fruit", true)
            fruitPara:Set(T("lbl_fruit"), fruit and (yes .. " - " .. fruit.Name) or no)
            local berry = workspace:FindFirstChild("Berry", true)
            berryPara:Set(T("lbl_berry"), berry and (yes .. " - " .. berry.Name) or no)
            local bar = workspace:FindFirstChild("Barista", true)
            baristaPara:Set(T("lbl_barista"), bar and (yes .. " - " .. bar.Name) or no)
        end)
    end
end)

-- =====================================================
-- TAB: MAIN (FARM)
-- =====================================================
local Main = Window:MakeTab({ Title = T("tab_main"), Icon = "menu" })

Main:AddDropdown({
    Title    = T("ui_farm_weapon"),
    Options  = { "Melee", "Sword", "Gun", "BloxFruits" },
    Default  = "Melee",
    Callback = function(v)
        Config.FarmWeapon         = tostring(v)
        Config.SelectedWeaponName = ""
        Notify({ Title = "Farm Weapon: " .. tostring(v), Image = IMG, Type = "Info", Duration = 2 })
    end,
})

Main:AddDropdown({
    Title    = T("ui_farm_attack"),
    Options  = { "Normal", "FastAttack", "SuperFastAttack" },
    Default  = "Normal",
    Callback = function(v) Config.FarmAttack = tostring(v) end,
})

Main:AddSection(T("sec_farm_normal"))

Main:AddToggle({
    Title    = T("ui_autofarm_level"),
    Default  = false,
    Flag     = "AutoFarmLevel",
    Callback = function(v)
        Config.AutoFarmLevel = v
        if v then Config.AutoFarmNearest = false end
        Notify({ Title = T(v and "autofarm_level_on" or "autofarm_level_off"), Image = IMG, Type = v and "Success" or "Error", Duration = 3 })
    end,
})

Main:AddToggle({
    Title    = T("ui_autofarm_nearest"),
    Default  = false,
    Flag     = "AutoFarmNearest",
    Callback = function(v)
        Config.AutoFarmNearest = v
        if v then Config.AutoFarmLevel = false end
        Notify({ Title = T(v and "autofarm_nearest_on" or "autofarm_nearest_off"), Image = IMG, Type = v and "Success" or "Error", Duration = 3 })
    end,
})

Main:AddDropdown({
    Title    = T("ui_select_island"),
    Options  = Islands[CurrentSea],
    Default  = Islands[CurrentSea][1],
    Callback = function(v) Config.FarmIsland = tostring(v) end,
})

Main:AddSection(T("sec_farm_sea3"))
local sea3Toggles = {
    { "ui_auto_pirate_raid",   "AutoPirateRaid"     }, { "ui_auto_rip_indra",     "AutoRipIndra"       },
    { "ui_auto_tyrant",        "AutoTyrantSpawn"     }, { "ui_auto_soul_reaper",   "AutoSoulReaper"     },
    { "ui_auto_big_mom",       "AutoBigMom"          }, { "ui_auto_farm_bone",     "AutoFarmBone"       },
    { "ui_auto_haki_v2",       "AutoHakiV2"          }, { "ui_auto_temple",        "AutoUnlockTemple"   },
    { "ui_auto_god_human",     "AutoGodHuman"        }, { "ui_auto_dragon",        "AutoDragonTaylor"   },
    { "ui_auto_electric_claw", "AutoElectricClaw"    }, { "ui_auto_cake_prince",   "AutoCakePrince"     },
    { "ui_auto_dough_king",    "AutoDoughKing"       },
}
for _, t in pairs(sea3Toggles) do
    local key = t[2]
    Main:AddToggle({ Title = T(t[1]), Default = false, Flag = key, Callback = function(v) Config[key] = v end })
end

Main:AddSection(T("sec_farm_sea2"))
local sea2Toggles = {
    { "ui_auto_sea3",        "AutoSea3"           }, { "ui_auto_factory",     "AutoFactory"        },
    { "ui_auto_raid_law",    "AutoRaidLaw"        }, { "ui_auto_buy_chip",    "AutoBuyChipRaidLaw" },
    { "ui_auto_start_raid",  "AutoStartRaidLaw"   }, { "ui_auto_darkbeard",   "AutoDarkBeard"      },
    { "ui_auto_sharkman",    "AutoSharkmanV2"     }, { "ui_auto_death_step",  "AutoDeathStep"      },
}
for _, t in pairs(sea2Toggles) do
    local key = t[2]
    Main:AddToggle({ Title = T(t[1]), Default = false, Flag = key, Callback = function(v) Config[key] = v end })
end

Main:AddSection(T("sec_farm_sea1"))
local sea1Toggles = {
    { "ui_auto_sea2",       "AutoSea2"        }, { "ui_auto_saber",       "AutoSaber"       },
    { "ui_auto_graybeard",  "AutoGrayBeard"   }, { "ui_auto_darkblade",   "AutoDarkBladeV2" },
}
for _, t in pairs(sea1Toggles) do
    local key = t[2]
    Main:AddToggle({ Title = T(t[1]), Default = false, Flag = key, Callback = function(v) Config[key] = v end })
end

Main:AddSection(T("sec_extras"))
Main:AddToggle({ Title = T("ui_auto_berry"),    Default = false, Flag = "AutoCollectBerry", Callback = function(v) Config.AutoCollectBerry = v end })
Main:AddToggle({ Title = T("ui_auto_barista"),  Default = false, Flag = "AutoBarista",      Callback = function(v) Config.AutoBarista = v end })
Main:AddDropdown({ Title = T("ui_haki_color"), Options = { "White","Black","Red","Blue","Green","Yellow","Purple","Pink" }, Default = "White",
    Callback = function(v) Config.HakiColor = tostring(v) end })
Main:AddToggle({ Title = T("ui_auto_obs_haki"), Default = false, Flag = "AutoFarmObsHaki",  Callback = function(v) Config.AutoFarmObsHaki = v end })

Main:AddSection(T("sec_boss"))
Main:AddDropdown({ Title = T("ui_select_boss"), Options = Bosses[CurrentSea], Default = Bosses[CurrentSea][1],
    Callback = function(v) Config.SelectedBoss = tostring(v) end })
Main:AddToggle({ Title = T("ui_auto_farm_boss"),      Default = false, Callback = function(v) Config.AutoFarmBoss = v end })
Main:AddToggle({ Title = T("ui_auto_farm_all_boss"),  Default = false, Callback = function(v) Config.AutoFarmAllBoss = v end })
Main:AddToggle({ Title = T("ui_auto_farm_raid_boss"), Default = false, Callback = function(v) Config.AutoFarmRaidBoss = v end })

Main:AddSection(T("sec_material"))
Main:AddDropdown({ Title = T("ui_select_material"), Options = Materials[CurrentSea], Default = Materials[CurrentSea][1],
    Callback = function(v) Config.SelectedMaterial = tostring(v) end })
Main:AddToggle({ Title = T("ui_auto_material"), Default = false, Callback = function(v) Config.AutoFarmMaterial = v end })

Main:AddSection(T("sec_mastery"))
Main:AddDropdown({ Title = T("ui_mastery_weapon"), Options = { "Gun","Sword","Melee","BloxFruits" }, Default = "Gun",
    Callback = function(v) Config.MasteryWeapon = tostring(v) end })
Main:AddSlider({ Title = T("ui_health_kill"), Min = 1, Max = 100, Default = 30,
    Callback = function(v) Config.HealthKillMob = v end })
Main:AddDropdown({ Title = T("ui_selection_island"), Options = Islands[CurrentSea], Default = Islands[CurrentSea][1],
    Callback = function(v) Config.MasteryIsland = tostring(v) end })
Main:AddToggle({ Title = T("ui_auto_mastery"), Default = false, Callback = function(v) Config.AutoFarmMastery = v end })

-- =====================================================
-- TAB: SETTINGS
-- =====================================================
local Settings = Window:MakeTab({ Title = T("tab_settings"), Icon = "settings" })

Settings:AddSection(T("sec_farming_settings"))
Settings:AddToggle({ Title = T("ui_auto_click"), Default = true,  Callback = function(v) Config.AutoClick = v end })
Settings:AddToggle({ Title = T("ui_bring_mob"),  Default = true,  Callback = function(v) Config.BringMob  = v end })
Settings:AddDropdown({ Title = T("ui_bring_dist"), Options = { "200","300","350","400","500" }, Default = "350",
    Callback = function(v) Config.BringDistance = tonumber(tostring(v)) end })
Settings:AddSlider({ Title = "Fly Speed (studs/s)", Min = 10, Max = 800, Default = 300,
    Callback = function(v) Config.FlySpeed = v end })
Settings:AddSlider({ Title = "Fly Offset (altura acima do mob)", Min = 5, Max = 50, Default = 15,
    Callback = function(v) Config.FlyOffset = v end })
Settings:AddToggle({ Title = T("ui_auto_spawn"), Default = false, Callback = function(v) Config.AutoSetSpawn = v end })
Settings:AddToggle({ Title = T("ui_auto_buso"), Default = true,
    Callback = function(v)
        Config.AutoBusoHaki = v
        if v then Functions.ActivateBuso(CommF_) end
    end })
Settings:AddToggle({ Title = T("ui_auto_obs"), Default = false, Callback = function(v) Config.AutoObservation = v end })

Settings:AddSection(T("sec_extras"))
Settings:AddToggle({ Title = T("ui_auto_speed"), Default = true, Callback = function(v) Config.AutoSpeed = v end })
Settings:AddSlider({ Title = T("ui_speed"), Min = 20, Max = 100, Default = 20,
    Callback = function(v) Config.Speed = v; if Humanoid then Humanoid.WalkSpeed = v end end })
Settings:AddToggle({ Title = T("ui_auto_jump"), Default = true, Callback = function(v) Config.AutoSetJump = v end })
Settings:AddSlider({ Title = T("ui_jump"), Min = 50, Max = 200, Default = 50,
    Callback = function(v) Config.Jump = v; if Humanoid then Humanoid.JumpPower = v end end })

Settings:AddSection(T("sec_visual"))
local _uiScaleDebounce = nil
Settings:AddSlider({
    Title   = "Tamanho da UI (%)",
    Min     = 50, Max = 150, Default = 100,
    Callback = function(v)
        if _uiScaleDebounce then task.cancel(_uiScaleDebounce) end
        _uiScaleDebounce = task.delay(0.4, function()
            _uiScaleDebounce = nil
            local scaleValue = math.clamp(math.floor(450 * (100 / v)), 300, 2000)
            Config.UIScale = scaleValue
            pcall(function() redzlib:SetScale(scaleValue) end)
        end)
    end,
})

Settings:AddToggle({ Title = T("ui_disable_notify"), Default = false, Callback = function(v) Config.DisableGameNotify = v end })
Settings:AddToggle({ Title = T("ui_no_fog"), Default = true,
    Callback = function(v)
        Config.NoFog    = v
        Lighting.FogEnd = v and 100000 or 1000
    end })
Settings:AddToggle({ Title = T("ui_notify_error"), Default = false, Callback = function(v) Config.NotifyErroScript = v end })
Settings:AddButton({ Title = T("ui_test_notify"),
    Callback = function()
        Notify({ Title = "Lotux Hub v3.0", Description = "Script funcionando!", Image = IMG, Type = "Success", Duration = 3 })
    end })
Settings:AddToggle({ Title = T("ui_noclip"), Default = false,
    Callback = function(v)
        Config.NoClip = v
        NoClip.value  = v
        Notify({ Title = T(v and "noclip_on" or "noclip_off"), Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })

Settings:AddSection(T("sec_select_lang"))
Settings:AddDropdown({
    Title    = T("ui_lang_dropdown"),
    Options  = { "English","Portugues_Brazil","Portugues_Portugal","Espanol","Vietnam" },
    Default  = "English",
    Callback = function(v)
        CurrentLang = tostring(v)
        Notify({ Title = T("language_changed"), Image = IMG, Type = "Success", Duration = 3 })
    end,
})
Settings:AddParagraph({ Title = T("tab_language"), Text = T("ui_lang_list") })

-- =====================================================
-- TABS "EM BREVE"
-- =====================================================
local function SoonTab(title, icon)
    local tab = Window:MakeTab({ Title = T(title), Icon = icon })
    tab:AddParagraph({ Title = T(title), Text = T("soon_coming") })
end
SoonTab("tab_fishing",   "anchor")
SoonTab("tab_itemquest", "swords")
SoonTab("tab_race",      "flag")
SoonTab("tab_vulcano",   "flame")
SoonTab("tab_seaevent",  "waves")
SoonTab("tab_fruitraid", "apple")
SoonTab("tab_shopping",  "shoppingbag")

-- =====================================================
-- TAB: ESP
-- =====================================================
local Esp = Window:MakeTab({ Title = T("tab_esp"), Icon = "eye" })
Esp:AddSection(T("sec_esp_settings"))

-- ESP Mobs (SelectionBox vermelho)
Esp:AddToggle({
    Title    = T("ui_esp_mobs"),
    Default  = false,
    Callback = function(v)
        Config.ESPEnabled = v
        if v then
            -- Inicia circulos verdes + rastreamento de mobs
            _initMobCircleESP()
            _startMobCircleLoop()
        else
            -- Remove SelectionBoxes
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("SelectionBox") and obj.Name == "ESP_Lotux" then obj:Destroy() end
            end
            -- Remove circulos verdes
            _stopMobCircleLoop()
            _clearAllMobCircles()
        end
        Notify({ Title = T(v and "esp_on" or "esp_off"), Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end,
})

Esp:AddToggle({
    Title    = T("ui_esp_teammates"),
    Default  = false,
    Callback = function(v) Config.ESPTeammates = v end,
})

Esp:AddSection("ESP Players e Mobs Especiais")

-- ESP Players (nome + HP + distância - verde=time / vermelho=inimigo)
Esp:AddToggle({
    Title    = "ESP Players (nome + HP + distância)",
    Default  = false,
    Callback = function(v)
        Config.ESPTeammates = v
        if not v then
            -- limpa labels de todos os players
            for _, plr in ipairs(Players:GetPlayers()) do
                pcall(function()
                    local head = plr.Character and plr.Character:FindFirstChild("Head")
                    if head then
                        for _, child in ipairs(head:GetChildren()) do
                            if child.Name:find("LotuxESP") then child:Destroy() end
                        end
                    end
                end)
            end
        end
        Notify({ Title = v and "ESP Players Ativado" or "ESP Players Desativado", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end,
})

-- ESP Sea Beasts (criaturas do mar)
Esp:AddToggle({
    Title    = "ESP Sea Beasts (criaturas do mar)",
    Default  = false,
    Callback = function(v)
        Config.ESPSeaBeasts = v
        if not v then
            for _, mob in ipairs((workspace:FindFirstChild("SeaBeasts") or {Beasts={}}).GetChildren and workspace.SeaBeasts:GetChildren() or {}) do
                pcall(function()
                    if mob:FindFirstChild("LotuxSeaESP") then mob.LotuxSeaESP:Destroy() end
                end)
            end
        end
        Notify({ Title = v and "ESP Sea Beasts Ativado" or "ESP Sea Beasts Desativado", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end,
})

-- ESP NPCs
Esp:AddToggle({
    Title    = "ESP NPCs",
    Default  = false,
    Callback = function(v)
        Config.ESPNpcs = v
        if not v then
            for _, npc in ipairs((workspace:FindFirstChild("NPCs") and workspace.NPCs:GetChildren()) or {}) do
                pcall(function()
                    if npc:FindFirstChild("LotuxNpcESP") then npc.LotuxNpcESP:Destroy() end
                end)
            end
        end
        Notify({ Title = v and "ESP NPCs Ativado" or "ESP NPCs Desativado", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end,
})

Esp:AddSection("ESP Ilhas e Objetos")
Esp:AddToggle({
    Title    = "ESP Ilhas",
    Default  = false,
    Callback = function(v)
        Config.ESPIslands = v
        if not v then
            local locs = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Locations")
            if locs then
                for _, isle in ipairs(locs:GetChildren()) do
                    pcall(function()
                        if isle:FindFirstChild("LotuxIslandESP") then isle.LotuxIslandESP:Destroy() end
                    end)
                end
            end
        end
        Notify({ Title = v and "ESP Ilhas Ativado" or "ESP Ilhas Desativado", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end,
})
Esp:AddToggle({
    Title    = "ESP Frutas do Diabo",
    Default  = false,
    Callback = function(v)
        Config.ESPFruits = v
        if not v then
            for _, obj in ipairs(workspace:GetChildren()) do
                pcall(function()
                    if obj:FindFirstChild("Handle") then
                        for _, child in ipairs(obj.Handle:GetChildren()) do
                            if child.Name:find("LotuxFruitESP") then child:Destroy() end
                        end
                    end
                end)
            end
        end
        Notify({ Title = v and "ESP Frutas Ativado" or "ESP Frutas Desativado", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end,
})
Esp:AddToggle({
    Title    = "ESP Baus (Chests)",
    Default  = false,
    Callback = function(v)
        Config.ESPChests = v
        if not v then
            for _, chest in ipairs(game:GetService("CollectionService"):GetTagged("_ChestTagged")) do
                pcall(function()
                    if chest:FindFirstChild("LotuxChestESP") then chest.LotuxChestESP:Destroy() end
                end)
            end
        end
        Notify({ Title = v and "ESP Baus Ativado" or "ESP Baus Desativado", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end,
})
Esp:AddToggle({
    Title    = "ESP Berries",
    Default  = false,
    Callback = function(v)
        Config.ESPBerries = v
        Notify({ Title = v and "ESP Berries Ativado" or "ESP Berries Desativado", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end,
})
Esp:AddToggle({
    Title    = "ESP Mirage Island",
    Default  = false,
    Callback = function(v)
        Config.ESPMirage = v
        Notify({ Title = v and "ESP Mirage Ativado" or "ESP Mirage Desativado", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end,
})

-- Loop de update de todos os ESPs (Heartbeat)
RunService.Heartbeat:Connect(function()
    -- Players
    pcall(function() Functions.UpdatePlayerESP(Config.ESPTeammates, false) end)
    -- Sea Beasts
    pcall(function() Functions.UpdateSeaBeastESP(Config.ESPSeaBeasts) end)
    -- NPCs
    pcall(function() Functions.UpdateNpcESP(Config.ESPNpcs) end)
    -- Ilhas
    pcall(function() Functions.UpdateIslandESP(Config.ESPIslands) end)
    -- Frutas do Diabo
    pcall(function() Functions.UpdateDevilFruitESP(Config.ESPFruits) end)
    -- Baus
    pcall(function() Functions.UpdateChestESP(Config.ESPChests) end)
    -- Berries
    pcall(function() Functions.UpdateBerriesESP(Config.ESPBerries) end)
    -- Mirage Island
    pcall(function() Functions.UpdateMirageESP(Config.ESPMirage) end)
end)

-- =====================================================
-- TAB: LOCAL PLAYER
-- =====================================================
local LPTab = Window:MakeTab({ Title = T("tab_localplayer"), Icon = "users" })
LPTab:AddSection(T("sec_char_stats"))
LPTab:AddSlider({ Title = T("ui_walkspeed"), Min = 16, Max = 500, Default = 16,
    Callback = function(v) Config.WalkSpeed = v; if Humanoid then Humanoid.WalkSpeed = v end end })
LPTab:AddSlider({ Title = T("ui_jumppower"), Min = 50, Max = 500, Default = 50,
    Callback = function(v) Config.JumpPower = v; if Humanoid then Humanoid.JumpPower = v end end })
LPTab:AddToggle({ Title = T("ui_infinite_jump"), Default = false,
    Callback = function(v)
        Config.InfiniteJump = v
        Notify({ Title = T(v and "infinitejump_on" or "infinitejump_off"), Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
LPTab:AddToggle({ Title = T("ui_anti_afk"), Default = false,
    Callback = function(v)
        Config.AntiAFK = v
        if v then
            task.spawn(function()
                while Config.AntiAFK do
                    pcall(function()
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new())
                    end)
                    if Humanoid then Humanoid.Jump = true end
                    task.wait(55)
                end
            end)
        end
        Notify({ Title = T(v and "antiafk_on" or "antiafk_off"), Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })

LPTab:AddSection(T("sec_actions"))
LPTab:AddButton({ Title = T("ui_check_hp"),
    Callback = function()
        if Humanoid then
            Notify({ Title = T("hp_title"),
                Description = string.format("%d / %d", math.floor(Humanoid.Health), math.floor(Humanoid.MaxHealth)),
                Image = IMG, Type = "Info", Duration = 4 })
        end
    end })
LPTab:AddButton({ Title = T("ui_reset_char"),
    Callback = function()
        if Humanoid then Humanoid.Health = 0 end
        Notify({ Title = T("resetting"), Image = IMG, Type = "Warning", Duration = 3 })
    end })
LPTab:AddButton({ Title = T("ui_copy_pos"),
    Callback = function()
        if HumanoidRootPart then
            local p = HumanoidRootPart.Position
            local s = string.format("%.1f,%.1f,%.1f", p.X, p.Y, p.Z)
            pcall(function() setclipboard(s) end)
            Notify({ Title = T("position_copied"), Description = s, Image = IMG, Type = "Success", Duration = 4 })
        end
    end })

-- =====================================================
-- TAB: TELEPORT
-- =====================================================
local Teleport = Window:MakeTab({ Title = T("tab_teleport"), Icon = "mouse" })
Teleport:AddSection(T("sec_quick_tp"))
for _, island in ipairs(Islands[CurrentSea]) do
    local islandName = tostring(island)
    Teleport:AddButton({
        Title    = T("ui_tp_prefix") .. islandName,
        Callback = function()
            local found = false
            for _, q in ipairs(QuestList) do
                if q.Sea == CurrentSea and q.Mob:lower():find(islandName:lower():sub(1, 5), 1, true) then
                    if HumanoidRootPart then HumanoidRootPart.CFrame = q.CFrameQuest end
                    Notify({ Title = T("teleported"), Description = islandName, Image = IMG, Type = "Success", Duration = 3 })
                    found = true; break
                end
            end
            if not found then
                Notify({ Title = T("teleported"), Description = islandName .. " - " .. T("teleport_not_mapped"), Image = IMG, Type = "Warning", Duration = 3 })
            end
        end,
    })
end
Teleport:AddSection(T("sec_custom_coords"))
Teleport:AddTextBox({
    Title           = T("ui_xyz_coords"),
    Desc            = T("ui_xyz_desc"),
    Default         = "",
    PlaceholderText = "X,Y,Z",
    ClearText       = true,
    Callback        = function(v)
        if not v or tostring(v):gsub(" ", "") == "" then return end
        local c = {}
        for n in tostring(v):gmatch("%-?%d+%.?%d*") do table.insert(c, tonumber(n)) end
        if #c >= 3 and HumanoidRootPart then
            HumanoidRootPart.CFrame = CFrame.new(c[1], c[2], c[3])
            Notify({ Title = T("teleported"), Description = string.format("X:%g Y:%g Z:%g", c[1], c[2], c[3]), Image = IMG, Type = "Success", Duration = 4 })
        else
            Notify({ Title = T("teleport_invalid"), Image = IMG, Type = "Error", Duration = 3 })
        end
    end,
})
Teleport:AddSection("TP Rapido (Quest Atual)")
Teleport:AddButton({ Title = "Ir ao NPC da Quest",
    Callback = function()
        local q = Functions.GetQuestForLevel(QuestList, CurrentSea, Player)
        if q and HumanoidRootPart then
            HumanoidRootPart.CFrame = q.CFrameQuest
            Notify({ Title = "Teleportado!", Description = "NPC: " .. q.NameQuest, Image = IMG, Type = "Success", Duration = 3 })
        end
    end })
Teleport:AddButton({ Title = "Ir ao Mob da Quest",
    Callback = function()
        local q = Functions.GetQuestForLevel(QuestList, CurrentSea, Player)
        if q and HumanoidRootPart then
            HumanoidRootPart.CFrame = q.CFrameMon * CFrame.new(0, Config.FlyOffset, 0)
            Notify({ Title = "Teleportado!", Description = "Mob: " .. q.Mob, Image = IMG, Type = "Success", Duration = 3 })
        end
    end })

-- =====================================================
-- TAB: VISUAL (NOVO - Funcoes do Tiroreal integradas)
-- =====================================================
local Visual = Window:MakeTab({ Title = "Visual", Icon = "sparkles" })

Visual:AddSection("Efeitos no Personagem")

-- Aqua Aura
Visual:AddToggle({
    Title    = "Aqua Aura (flutuar)",
    Default  = false,
    Callback = function(v)
        Config.AquaAura = v
        if v then
            Functions.StartAquaAura()
            Notify({ Title = "Aqua Aura Ativado", Description = "Aparece ao flutuar por 3s", Image = IMG, Type = "Success", Duration = 3 })
        else
            -- Remove aura do personagem atual
            pcall(function()
                local char = Player.Character
                if char and char:FindFirstChild("LotuxAquaAura") then
                    char.LotuxAquaAura:Destroy()
                end
            end)
            Notify({ Title = "Aqua Aura Desativado", Image = IMG, Type = "Info", Duration = 2 })
        end
    end,
})

-- Rainbow Skills
Visual:AddToggle({
    Title    = "Rainbow Skills (particulas arco-iris)",
    Default  = false,
    Callback = function(v)
        Config.RainbowSkills = v
        if v then
            Functions.StartRainbowSkills()
            Notify({ Title = "Rainbow Skills Ativado", Image = IMG, Type = "Success", Duration = 3 })
        else
            Notify({ Title = "Rainbow Skills Desativado", Description = "Recarregue para resetar as cores", Image = IMG, Type = "Info", Duration = 3 })
        end
    end,
})

-- Rainbow Billboard
Visual:AddToggle({
    Title    = "Rainbow Billboard (nome arco-iris)",
    Default  = false,
    Callback = function(v)
        Config.RainbowBillboard = v
        if v then
            Functions.StartRainbowBillboard("Lotux Hub")
            Notify({ Title = "Rainbow Billboard Ativado", Image = IMG, Type = "Success", Duration = 3 })
        else
            -- Remove label do personagem atual
            pcall(function()
                local char = Player.Character
                if char then
                    local head = char:FindFirstChild("Head")
                    if head and head:FindFirstChild("Lotux_Label") then
                        head.Lotux_Label:Destroy()
                    end
                end
            end)
            Notify({ Title = "Rainbow Billboard Desativado", Image = IMG, Type = "Info", Duration = 2 })
        end
    end,
})

-- Self Highlight
Visual:AddToggle({
    Title    = "Self Highlight (brilho branco)",
    Default  = false,
    Callback = function(v)
        Config.SelfHighlight = v
        if v then
            Functions.StartSelfHighlight()
            Notify({ Title = "Self Highlight Ativado", Image = IMG, Type = "Success", Duration = 3 })
        else
            -- Remove highlight folder
            pcall(function()
                local folder = game.CoreGui:FindFirstChild("LotuxHighlight_Folder")
                if folder then folder:Destroy() end
            end)
            Notify({ Title = "Self Highlight Desativado", Image = IMG, Type = "Info", Duration = 2 })
        end
    end,
})

Visual:AddSection("Interface e Performance")

-- FPS Counter
Visual:AddToggle({
    Title    = "FPS Counter (canto superior esq.)",
    Default  = false,
    Callback = function(v)
        Config.FPSCounter = v
        if v then
            Functions.StartFPSCounter()
            Notify({ Title = "FPS Counter Ativado", Image = IMG, Type = "Success", Duration = 3 })
        else
            -- Remove ScreenGui do FPS
            pcall(function()
                for _, gui in ipairs(game.CoreGui:GetChildren()) do
                    if gui:IsA("ScreenGui") and gui:FindFirstChildOfClass("TextLabel") then
                        -- identifica pelo TextLabel na raiz
                        local lbl = gui:FindFirstChildOfClass("TextLabel")
                        if lbl and lbl.Text:find("FPS") then
                            gui:Destroy()
                        end
                    end
                end
            end)
            Notify({ Title = "FPS Counter Desativado", Image = IMG, Type = "Info", Duration = 2 })
        end
    end,
})

-- Render on Focus (pausa render quando janela perde foco)
Visual:AddToggle({
    Title    = "Render on Focus (economiza CPU)",
    Default  = true,
    Callback = function(v)
        Config.RenderOnFocus = v
        if v then
            Functions.StartFocusRenderControl()
            Notify({ Title = "Render on Focus Ativado", Description = "3D pausa quando janela perde foco", Image = IMG, Type = "Success", Duration = 3 })
        else
            -- Garante que o render esta ligado ao desativar
            pcall(function() RunService:Set3dRenderingEnabled(true) end)
            Notify({ Title = "Render on Focus Desativado", Image = IMG, Type = "Info", Duration = 2 })
        end
    end,
})

Visual:AddSection("Visuais do Mapa")

-- Fullbright
Visual:AddToggle({ Title = T("ui_fullbright"), Default = false,
    Callback = function(v)
        if v then
            Lighting.Brightness     = 10
            Lighting.GlobalShadows  = false
            Lighting.Ambient        = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        else
            Lighting.Brightness     = 2
            Lighting.GlobalShadows  = true
            Lighting.Ambient        = Color3.fromRGB(70, 70, 70)
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end
        Notify({ Title = T(v and "fullbright_on" or "fullbright_off"), Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })

Visual:AddSlider({ Title = T("ui_fov"), Min = 30, Max = 120, Default = 70,
    Callback = function(v) Camera.FieldOfView = v end })

Visual:AddButton({ Title = T("ui_reset_visual"),
    Callback = function()
        Camera.FieldOfView      = 70
        Lighting.Brightness     = 2
        Lighting.GlobalShadows  = true
        Lighting.Ambient        = Color3.fromRGB(70, 70, 70)
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        Notify({ Title = T("visual_reset"), Image = IMG, Type = "Info", Duration = 3 })
    end })

-- =====================================================
-- TAB: MISC
-- =====================================================
local Misc = Window:MakeTab({ Title = T("tab_misc"), Icon = "calendarsearch" })
Misc:AddSection(T("sec_utility"))
Misc:AddSection("Server")
Misc:AddButton({
    Title    = "Server Hop (trocar de servidor)",
    Callback = function()
        Notify({ Title = "Server Hop", Description = "Procurando servidor...", Image = IMG, Type = "Info", Duration = 3 })
        task.spawn(function()
            Functions.ServerHop()
        end)
    end,
})

Misc:AddSection(T("sec_script_info"))
Misc:AddParagraph({ Title = "Lotux Hub v3.0 - Modular", Text =
    "by LoadFlint/lucas\n" ..
    "[>] Auto Farm com Quest Fix\n" ..
    "[>] ESP Circulo Verde + SelectionBox\n" ..
    "[>] Aqua Aura, Rainbow Skills, Billboard\n" ..
    "[>] Self Highlight + FPS Counter\n" ..
    "[>] Render on Focus (economiza CPU)\n" ..
    "[>] Sea 1, 2 e 3 detectado automaticamente"
})
Misc:AddButton({ Title = T("ui_close_ui"), Callback = function() Window:CloseBtn() end })

-- =====================================================
-- INICIA FEATURES ATIVAS POR PADRAO
-- =====================================================

-- Render on Focus ativo por padrao (Config.RenderOnFocus = true)
Functions.StartFocusRenderControl()

-- Sem neblina por padrao
Lighting.FogEnd = Config.NoFog and 100000 or 1000

-- =====================================================
-- FINALIZACAO
-- =====================================================
uiReady = true

Notify({
    Title       = "Lotux Hub v3.0 Carregado!",
    Description = "Sea " .. CurrentSea .. " | PlaceId: " .. game.PlaceId,
    Image       = IMG,
    Duration    = 5,
    Type        = "Success",
})

print("[Lotux Hub] Sea detectado:", CurrentSea)
print("[Lotux Hub] PlaceId:", game.PlaceId)
print("[Lotux Hub] World1:", World1, "| World2:", World2, "| World3:", World3)