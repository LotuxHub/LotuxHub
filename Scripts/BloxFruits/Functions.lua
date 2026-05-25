-- Functions.lua
-- Lotux Hub by LoadFlint/lucas
-- COMPLETO: Farm, Voo, ESP, Visual, Quest, Boss, Sea, PvP, Shop, Misc

local Functions = {}

-- =====================================================
-- SERVICES
-- =====================================================
local Players             = game:GetService("Players")
local RunService          = game:GetService("RunService")
local TweenService        = game:GetService("TweenService")
local VirtualUser         = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local CollectionService   = game:GetService("CollectionService")
local UserInputService    = game:GetService("UserInputService")
local StarterGui          = game:GetService("StarterGui")

local Player = Players.LocalPlayer

-- =====================================================
-- COMMF_ HELPER (seguro contra nil durante server jump)
-- =====================================================
local function GetCommF()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotes then return nil end
    return remotes:FindFirstChild("CommF_")
end

local function CF(...)
    local c = GetCommF()
    if c then return c:InvokeServer(...) end
    return nil
end

-- =====================================================
-- UTILITY
-- =====================================================

function Functions.FormatTime(secs)
    secs = math.floor(secs)
    return string.format("%02d:%02d:%02d",
        math.floor(secs / 3600),
        math.floor((secs % 3600) / 60),
        secs % 60)
end

-- =====================================================
-- DETECTAR SEA
-- =====================================================

local SEA_PLACE_IDS = {
    [1] = { 2753915549, 6817450498, 8903419500 },
    [2] = { 4442272183, 79091703265657, 8165217374, 9176847717 },
    [3] = { 7449423635, 11100731664 },
}

function Functions.DetectCurrentSea()
    local pid = game.PlaceId
    for sea, ids in pairs(SEA_PLACE_IDS) do
        for _, id in ipairs(ids) do
            if pid == id then return sea end
        end
    end
    local ok, level = pcall(function() return Player.Data.Level.Value end)
    if ok and level then
        if level >= 1500 then return 3
        elseif level >= 700 then return 2
        else return 1 end
    end
    return 1
end

-- =====================================================
-- WEAPON RESOLVER
-- =====================================================

-- =====================================================
-- BFWIRELIST - Listas de nomes por tipo de arma
-- Usadas pelo ResolveWeaponNow para identificar armas no Backpack
-- =====================================================
local BFWirelist = {
    Melee = {
        "Combat",
        "Dark Step",
        "Electric",
        "Water Kung Fu",
        "Black Leg",
        "Electro",
        "Fishman Karate",
        "Superhuman",
        "Dragon Talon",
        "Death Step",
        "Sharkman Karate",
        "Electric Claw",
        "Godhuman",
        "Sanguine Art",
    },
    BloxFruits = {
        "Kilo-Kilo",
        "Rocket-Rocket",
        "Spin-Spin",
        "Smoke-Smoke",
        "Blade-Blade",
        "Spring-Spring",
        "Bomb-Bomb",
        "Spike-Spike",
        "Revive-Revive",
        "Diamond-Diamond",
        "Flame-Flame",
        "Ice-Ice",
        "Sand-Sand",
        "Dark-Dark",
        "Eagle-Eagle",
        "Door-Door",
        "Rubber-Rubber",
        "Ghost-Ghost",
        "Light-Light",
        "Magma-Magma",
        "Quake-Quake",
        "Love-Love",
        "Creation-Creation",
        "Spider-Spider",
        "Sound-Sound",
        "Portal-Portal",
        "Pain-Pain",
        "Lightning-Lightning",
        "Blizzard-Blizzard",
        "Buddha-Buddha",
        "Phoenix-Phoenix",
        "Gravity-Gravity",
        "Shadow-Shadow",
        "Venom-Venom",
        "Soul-Soul",
        "Spirit-Spirit",
        "Control-Control",
        "Dough-Dough",
        "Gas-Gas",
        "Mammoth-Mammoth",
        "T-Rex-T-Rex",
        "Dragon-Dragon",
        "Tiger-Tiger",
        "Yeti-Yeti",
        "Kitsune-Kitsune",
    },
    Sword = {
        "Katana",
        "Cutlass",
        "Dual Katana",
        "Iron Mace",
        "Shark Saw",
        "Triple Katana",
        "Twin Hooks",
        "Pipe",
        "Soul Cane",
        "Trident",
        "Longsword",
        "Warden's Sword",
        "Dual-Headed Blade",
        "Flail",
        "Gravity Blade",
        "Dragon Trident",
        "Bisento",
        "Saber",
        "Koko",
        "Jitte",
        "Pole (1st Form)",
        "Pole (2nd Form)",
        "Rengoku",
        "Saddi",
        "Shisui",
        "Wando",
        "Dark Dagger",
        "Buddy Sword",
        "Canvander",
        "Midnight Blade",
        "Oroshi",
        "Saishi",
        "Shizu",
        "Shark Anchor",
        "Spikey Trident",
        "Tushita",
        "Yama",
        "Dragonheart",
        "Fox Lamp",
        "Dark Blade",
        "True Triple Katana",
        "Cursed Dual Katana",
        "Hallow Scythe",
    },
    Gun = {
        "Slingshot",
        "Musket",
        "Flintlock",
        "Refined Slingshot",
        "Refined Musket",
        "Refined Flintlock",
        "Dual Flintlock",
        "Cannon",
        "Magma Blaster",
        "Acidum Rifle",
        "Bizarre Rifle",
        "Bazooka",
        "Kabucha",
        "Serpent Bow",
        "Venom Bow",
        "Dragonstorm",
        "Skull Guitar",
        "Soul Guitar",
    },
}

-- Monta um set (tabela chave=nome) para lookup O(1)
local function makeSet(list)
    local set = {}
    for _, name in ipairs(list) do
        set[name] = true
    end
    return set
end

local BFWirelistSets = {
    Melee      = makeSet(BFWirelist.Melee),
    BloxFruits = makeSet(BFWirelist.BloxFruits),
    Sword      = makeSet(BFWirelist.Sword),
    Gun        = makeSet(BFWirelist.Gun),
}

-- ResolveWeaponNow - Resolve o nome da arma pela BFWirelist
-- Verifica se o tool.Name existe na lista do tipo selecionado (FarmWeapon)
-- no Backpack ou no Character (caso já esteja equipado)
function Functions.ResolveWeaponNow(config)
    pcall(function()
        -- Usa _G._FarmWeapon (setado pelo Callback da UI) em vez de config.FarmWeapon
        -- Isso evita o bug da redzlib que sobrescreve config.FarmWeapon com tabela interna
        local farmType = _G._FarmWeapon or "Melee"

        local lista = BFWirelistSets[farmType]
        if not lista then
            config.SelectedWeaponName = ""
            return
        end

        local found = false

        -- 1. Procura no Backpack
        for _, tool in pairs(Player.Backpack:GetChildren()) do
            if tool:IsA("Tool") and lista[tool.Name] then
                config.SelectedWeaponName = tool.Name
                found = true
                break
            end
        end

        -- 2. Se nao achou, procura no Character (ja equipado)
        if not found and Player.Character then
            for _, tool in pairs(Player.Character:GetChildren()) do
                if tool:IsA("Tool") and lista[tool.Name] then
                    config.SelectedWeaponName = tool.Name
                    found = true
                    break
                end
            end
        end

        if not found then
            config.SelectedWeaponName = ""
        end
    end)
end

-- StartWeaponResolver - Loop de fundo que mantem SelectedWeaponName atualizado
function Functions.StartWeaponResolver(config)
    task.spawn(function()
        while task.wait(0.3) do
            Functions.ResolveWeaponNow(config)
        end
    end)
end

-- =====================================================
-- EQUIP / UNEQUIP WEAPON
-- =====================================================

local _NotAutoEquip = false

function Functions.EquipWeapon(weaponName, notAutoEquipRef)
    -- Respeita flag NotAutoEquip
    if notAutoEquipRef and notAutoEquipRef.value then return false end

    local char = Player.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end

    -- Se recebeu config (tabela), usa _G._FarmWeapon para buscar na wirelist
    if type(weaponName) == "table" then
        local cfg = weaponName

        -- Pega o tipo de arma da variavel global (nunca contaminada pela redzlib)
        local farmType = _G._FarmWeapon or "Melee"
        local lista = BFWirelistSets[farmType]
        if not lista then return false end

        -- Verifica se ja tem algo do tipo equipado no Character
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") and lista[tool.Name] then
                cfg.SelectedWeaponName = tool.Name
                return true
            end
        end

        -- Procura no Backpack
        for _, tool in pairs(Player.Backpack:GetChildren()) do
            if tool:IsA("Tool") and lista[tool.Name] then
                cfg.SelectedWeaponName = tool.Name
                local ok = pcall(function()
                    hum:EquipTool(tool)
                end)
                return ok
            end
        end

        warn("[EquipWeapon] Nenhuma arma do tipo '" .. farmType .. "' encontrada no Backpack.")
        return false
    end

    -- Se recebeu string direto (nome especifico da arma)
    local name = tostring(weaponName or "")
    if name == "" then return false end

    -- Ja esta equipado?
    if char:FindFirstChild(name) then return true end

    local tool = Player.Backpack:FindFirstChild(name)
    if not tool then
        warn("[EquipWeapon] '" .. name .. "' nao encontrada no Backpack.")
        return false
    end

    local ok = pcall(function()
        hum:EquipTool(tool)
    end)
    return ok
end

function Functions.UnEquipWeapon(config, notAutoEquipRef)
    pcall(function()
        local char = Player.Character
        if not char then return end
        local tool = char:FindFirstChild(config.SelectedWeaponName)
        if tool then
            if notAutoEquipRef then notAutoEquipRef.value = true end
            task.wait(0.5)
            tool.Parent = Player.Backpack
            task.wait(0.1)
            if notAutoEquipRef then notAutoEquipRef.value = false end
        end
    end)
end

function Functions.EquipAllWeapon()
    pcall(function()
        for _, v in pairs(Player.Backpack:GetChildren()) do
            if v:IsA("Tool")
               and v.Name ~= "Summon Sea Beast"
               and v.Name ~= "Water Body"
               and v.Name ~= "Awakening" then
                Player.Character.Humanoid:EquipTool(v)
                task.wait(1)
            end
        end
    end)
end

-- =====================================================
-- HAKI
-- =====================================================

local _hakiLastTime = 0
local _HAKI_COOLDOWN = 4

function Functions.AutoHaki()
    local character = Player.Character
    if not character then return end

    local hasBuso = character:FindFirstChild("HasBuso")
                 or character:FindFirstChild("Buso")
                 or character:FindFirstChild("HakiActive")
                 or character:GetAttribute("HasBuso")
                 or character:GetAttribute("BusoActive")
    if hasBuso then return end

    local now = tick()
    if now - _hakiLastTime < _HAKI_COOLDOWN then return end
    _hakiLastTime = now

    pcall(function()
        CF("Buso")
    end)
end

function Functions.ActivateBuso(commF_)
    Functions.AutoHaki()
end

function Functions.StartHakiLoop(config, commF_)
    task.spawn(function()
        while task.wait(2) do
            if config.AutoBusoHaki then
                Functions.AutoHaki()
            end
        end
    end)
end

-- =====================================================
-- NEAREST ENEMY
-- =====================================================

function Functions.GetNearestEnemy(character, humanoidRootPart, filterName)
    if not humanoidRootPart then return nil end
    local nearest, nearestDist = nil, math.huge
    local rootPos = humanoidRootPart.Position

    local folders = {}
    local ef  = workspace:FindFirstChild("Enemies")
    local cf2 = workspace:FindFirstChild("Characters")
    if ef  then table.insert(folders, ef)  end
    if cf2 then table.insert(folders, cf2) end

    for _, folder in ipairs(folders) do
        for _, obj in ipairs(folder:GetChildren()) do
            if obj:IsA("Model") and obj ~= character then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health > 0 then
                    local match = (not filterName or filterName == "")
                               or obj.Name:lower():find(filterName:lower(), 1, true)
                    if match then
                        local dist = (hrp.Position - rootPos).Magnitude
                        if dist < nearestDist then
                            nearest, nearestDist = obj, dist
                        end
                    end
                end
            end
        end
    end
    return nearest
end

-- =====================================================
-- FLY / TELEPORT
-- =====================================================

local _isTeleporting = false

function Functions.FlyToPosition(targetCF, tweenSvc, config, isTeleportingRef, notAutoEquipRef)
    local char = Player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not hrp or not hum or hum.Health <= 0 then return end

    local distance = (targetCF.Position - hrp.Position).Magnitude
    if distance < 2 then return end

    if not char:FindFirstChild("PartTele") then
        local pt        = Instance.new("Part", char)
        pt.Size         = Vector3.new(10, 1, 10)
        pt.Name         = "PartTele"
        pt.Anchored     = true
        pt.Transparency = 1
        pt.CanCollide   = false
        pt.CFrame       = hrp.CFrame

        pt:GetPropertyChangedSignal("CFrame"):Connect(function()
            local isTp = (isTeleportingRef and isTeleportingRef.value) or _isTeleporting
            if not isTp then return end
            task.wait()
            local c = Player.Character
            if c and c:FindFirstChild("HumanoidRootPart") and c:FindFirstChild("PartTele") then
                local cHrp = c.HumanoidRootPart
                local _, yaw, _ = cHrp.CFrame:ToOrientation()
                cHrp.CFrame = CFrame.new(c.PartTele.CFrame.Position) * CFrame.Angles(0, yaw, 0)
            end
        end)
    end

    if isTeleportingRef then isTeleportingRef.value = true end
    _isTeleporting = true

    local speed = tonumber(config and config.FlySpeed) or 300
    local dur   = math.clamp(distance / speed, 0.05, 60.0)

    local ts    = tweenSvc or TweenService
    local tween = ts:Create(
        char.PartTele,
        TweenInfo.new(dur, Enum.EasingStyle.Linear),
        { CFrame = targetCF }
    )
    tween:Play()

    local conn
    conn = RunService.Heartbeat:Connect(function()
        local c    = Player.Character
        local cHrp = c and c:FindFirstChild("HumanoidRootPart")
        local pt   = c and c:FindFirstChild("PartTele")
        if cHrp and pt then
            local _, currentYaw, _ = cHrp.CFrame:ToOrientation()
            cHrp.CFrame = CFrame.new(pt.CFrame.Position) * CFrame.Angles(0, currentYaw, 0)
        else
            conn:Disconnect()
        end
    end)

    tween.Completed:Wait()
    conn:Disconnect()

    if isTeleportingRef then isTeleportingRef.value = false end
    _isTeleporting = false

    if char:FindFirstChild("PartTele") then
        char.PartTele:Destroy()
    end
end

function Functions.TeleportTo(pos)
    local char = Player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = pos end
end

function Functions.TPP(targetCF)
    local hum = Player.Character and Player.Character:FindFirstChild("Humanoid")
    if hum and hum.Health <= 0 then return end
    local char = Player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local dist  = (targetCF.Position - hrp.Position).Magnitude
    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(dist / 325, Enum.EasingStyle.Linear),
        { CFrame = targetCF }
    )
    tween:Play()
end

function Functions.StopTeleport()
    _isTeleporting = false
    local char = Player.Character
    if char and char:FindFirstChild("PartTele") then
        char.PartTele:Destroy()
    end
end

-- =====================================================
-- TELEPORTADOR DE ILHA
-- =====================================================

function Functions.CheckNearestTeleporter(pos)
    local vcspos  = pos.Position
    local minDist = math.huge
    local chosen  = nil
    local y       = game.PlaceId

    local TableLocations = {}
    if y == 2753915549 then
        TableLocations = {
            ["Sky3"]           = Vector3.new(-7894, 5547, -380),
            ["Sky3Exit"]       = Vector3.new(-4607, 874, -1667),
            ["UnderWater"]     = Vector3.new(61163, 11, 1819),
            ["UnderwaterExit"] = Vector3.new(4050, -1, -1814),
        }
    elseif y == 4442272183 then
        TableLocations = {
            ["Swan Mansion"] = Vector3.new(-390, 332, 673),
            ["Cursed Ship"]  = Vector3.new(923, 126, 32852),
            ["Zombie Island"]= Vector3.new(-6509, 83, -133),
        }
    elseif y == 7449423635 then
        TableLocations = {
            ["Floating Turtle"] = Vector3.new(-12462, 375, -7552),
            ["Hydra Island"]    = Vector3.new(5657, 1013, -335),
            ["Castle"]          = Vector3.new(-5036, 315, -3179),
            ["Temple of Time"]  = Vector3.new(28286, 14897, 103),
        }
    end

    for _, v in pairs(TableLocations) do
        local dist = (v - vcspos).Magnitude
        if dist < minDist then
            minDist = dist
            chosen  = v
        end
    end

    local playerPos = Player.Character
        and Player.Character.HumanoidRootPart
        and Player.Character.HumanoidRootPart.Position

    if playerPos and chosen then
        if minDist <= (vcspos - playerPos).Magnitude then
            return chosen
        end
    end
    return nil
end

function Functions.RequestEntrance(teleportPos)
    pcall(function()
        CF("requestEntrance", teleportPos)
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = hrp.CFrame + Vector3.new(0, 50, 0) end
        task.wait(0.5)
    end)
end

function Functions.ToPos(targetCF, config, isTeleportingRef, notAutoEquipRef)
    local char = Player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not hrp or not hum or hum.Health <= 0 then return end

    local nearestTeleport = Functions.CheckNearestTeleporter(targetCF)
    if nearestTeleport then
        Functions.RequestEntrance(nearestTeleport)
    end

    Functions.FlyToPosition(targetCF, TweenService, config, isTeleportingRef, notAutoEquipRef)
end

-- =====================================================
-- BRING MOB
-- =====================================================

function Functions.BringMob(mobName, targetPosition, maxDist)
    maxDist = maxDist or 350
    local char = Player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return end

    for _, v in ipairs(enemies:GetChildren()) do
        if v.Name == mobName
           and v:FindFirstChild("HumanoidRootPart")
           and v:FindFirstChild("Humanoid")
           and v.Humanoid.Health > 0
           and (v.HumanoidRootPart.Position - hrp.Position).Magnitude <= maxDist then

            v.HumanoidRootPart.CFrame      = targetPosition or v.HumanoidRootPart.CFrame
            v.Humanoid.JumpPower           = 0
            v.Humanoid.WalkSpeed           = 0
            v.HumanoidRootPart.Transparency = 1
            v.HumanoidRootPart.CanCollide   = false

            if v:FindFirstChild("Head") then
                v.Head.CanCollide = false
            end
            if v.Humanoid:FindFirstChild("Animator") then
                v.Humanoid.Animator:Destroy()
            end
            if not v.HumanoidRootPart:FindFirstChild("Lock") then
                local lock        = Instance.new("BodyVelocity")
                lock.Parent       = v.HumanoidRootPart
                lock.Name         = "Lock"
                lock.MaxForce     = Vector3.new(100000, 100000, 100000)
                lock.Velocity     = Vector3.new(0, 0, 0)
            end

            pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
            v.Humanoid:ChangeState(11)
        end
    end
end

Functions.BringMobFunc = Functions.BringMob

function Functions.StartBringMobLoop(config, stateRef)
    task.spawn(function()
        while task.wait() do
            pcall(function()
                if not config.BringMob or not stateRef.StartBring or not stateRef.MonFarm then return end
                local enemies = workspace:FindFirstChild("Enemies")
                if not enemies then return end
                for _, v in ipairs(enemies:GetChildren()) do
                    if v.Name == stateRef.MonFarm
                       and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0
                       and v:FindFirstChild("HumanoidRootPart") then
                        local hrp = v.HumanoidRootPart
                        local bPos = stateRef.BringPos or hrp.CFrame
                        hrp.CFrame           = bPos
                        hrp.Size             = Vector3.new(60, 60, 60)
                        hrp.Transparency     = 1
                        v.Humanoid.WalkSpeed = 0
                        v.Humanoid.JumpPower = 0
                        hrp.CanCollide       = false
                        if v:FindFirstChild("Head") then v.Head.CanCollide = false end
                        if v.Humanoid:FindFirstChild("Animator") then
                            v.Humanoid.Animator:Destroy()
                        end
                        v.Humanoid:ChangeState(11)
                        pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                    end
                end
            end)
        end
    end)
end

-- =====================================================
-- NOCLIP
-- =====================================================

function Functions.ApplyNoClip(player, enabled)
    pcall(function()
        local char = player.Character
        if not char then return end
        local head = char:FindFirstChild("Head")
        if enabled then
            if head and not head:FindFirstChild("NoClipLock") then
                local bv    = Instance.new("BodyVelocity", head)
                bv.P        = 1500
                bv.Name     = "NoClipLock"
                bv.MaxForce = Vector3.new(0, 100000, 0)
                bv.Velocity = Vector3.new(0, 0, 0)
            end
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        else
            if head and head:FindFirstChild("NoClipLock") then
                head.NoClipLock:Destroy()
            end
        end
    end)
end

function Functions.EnableNoclip()
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp and not hrp:FindFirstChild("LotuxBodyClip") then
        local nc      = Instance.new("BodyVelocity")
        nc.Name       = "LotuxBodyClip"
        nc.Parent     = hrp
        nc.MaxForce   = Vector3.new(100000, 100000, 100000)
        nc.Velocity   = Vector3.new(0, 0, 0)
    end
end

function Functions.DisableNoclip()
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp and hrp:FindFirstChild("LotuxBodyClip") then
        hrp.LotuxBodyClip:Destroy()
    end
end

-- =====================================================
-- FAST ATTACK
-- =====================================================

function Functions.FastAttack(targetMob, config, notAutoEquipRef)
    if not targetMob or not targetMob.Parent then return end
    local char = Player.Character
    if not char then return end
    local charHrp = char:FindFirstChild("HumanoidRootPart")
    if not charHrp then return end

    local tool = char:FindFirstChildOfClass("Tool")
    if not tool and config and config.SelectedWeaponName ~= "" then
        Functions.EquipWeapon(config.SelectedWeaponName, notAutoEquipRef)
        tool = char:FindFirstChildOfClass("Tool")
    end

    local hrpTarget = targetMob:FindFirstChild("HumanoidRootPart")

    -- Metodo 1: LeftClickRemote (melee/sword)
    if tool and tool:FindFirstChild("LeftClickRemote") then
        if hrpTarget then
            local direction = (hrpTarget.Position - charHrp.Position).Unit
            local ok, err = pcall(function() tool.LeftClickRemote:FireServer(direction, 1) end)
            if ok then
            else
                warn("[FastAttack] LeftClickRemote falhou: " .. tostring(err))
            end
        end
        return
    end

    -- Metodo 2: RE/RegisterAttack + RE/RegisterHit
    -- Formato correto igual ao Tiroreal: BasePart=Head, OthersEnemies={{mob, Head}, ...}
    local Net = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
    if Net then
        local RegisterAttack = Net:FindFirstChild("RE/RegisterAttack")
        local RegisterHit    = Net:FindFirstChild("RE/RegisterHit")
        if RegisterAttack and RegisterHit then
            local head = targetMob:FindFirstChild("Head") or hrpTarget
            if head then
                -- OthersEnemies: lista de {model, Head} de todos inimigos no raio
                local OthersEnemies = {}
                local Enemies = workspace:FindFirstChild("Enemies")
                if Enemies then
                    for _, enemy in ipairs(Enemies:GetChildren()) do
                        if enemy ~= char then
                            local eHead = enemy:FindFirstChild("Head")
                            local eHum  = enemy:FindFirstChildOfClass("Humanoid")
                            if eHead and eHum and eHum.Health > 0 then
                                local d = (eHead.Position - charHrp.Position).Magnitude
                                if d < 500 then
                                    table.insert(OthersEnemies, {enemy, eHead})
                                end
                            end
                        end
                    end
                end
                -- Garante que o alvo principal está na lista
                if #OthersEnemies == 0 then
                    table.insert(OthersEnemies, {targetMob, head})
                end
                local ok, err = pcall(function()
                    RegisterAttack:FireServer(0)
                    RegisterHit:FireServer(head, OthersEnemies)
                end)
                if ok then
                else
                    warn("[FastAttack] RegisterHit falhou: " .. tostring(err))
                end
                return
            end
        end
    end

    -- Metodo 3: RemoteFunctionShoot (guns)
    if tool and tool:FindFirstChild("RemoteFunctionShoot") then
        if hrpTarget then
            local ok, err = pcall(function()
                tool.RemoteFunctionShoot:InvokeServer(hrpTarget.Position, hrpTarget)
            end)
            if ok then
            else
                warn("[FastAttack] RemoteFunctionShoot falhou: " .. tostring(err))
            end
        end
        return
    end

    -- Metodo 4: VirtualUser Button1Down (fallback)
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(1280, 672))
    end)
end

function Functions.FastAttackAdvanced()
    task.spawn(function()
        local remote, idremote
        for _, v in next, {ReplicatedStorage.Util, ReplicatedStorage.Common,
                            ReplicatedStorage.Remotes, ReplicatedStorage.Assets, ReplicatedStorage.FX} do
            pcall(function()
                for _, n in next, v:GetChildren() do
                    if n:IsA("RemoteEvent") and n:GetAttribute("Id") then
                        remote, idremote = n, n:GetAttribute("Id")
                    end
                end
                v.ChildAdded:Connect(function(n)
                    if n:IsA("RemoteEvent") and n:GetAttribute("Id") then
                        remote, idremote = n, n:GetAttribute("Id")
                    end
                end)
            end)
        end

        while task.wait(0.05) do
            pcall(function()
                local char = Player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                local parts = {}
                for _, x in ipairs({workspace.Enemies, workspace.Characters}) do
                    for _, v in ipairs(x and x:GetChildren() or {}) do
                        local hrp = v:FindFirstChild("HumanoidRootPart")
                        local hum = v:FindFirstChild("Humanoid")
                        if v ~= char and hrp and hum and hum.Health > 0
                           and (hrp.Position - root.Position).Magnitude <= 60 then
                            for _, _v in ipairs(v:GetChildren()) do
                                if _v:IsA("BasePart") then
                                    parts[#parts+1] = {v, _v}
                                end
                            end
                        end
                    end
                end
                local tool = char:FindFirstChildOfClass("Tool")
                if #parts > 0 and tool
                   and (tool:GetAttribute("WeaponType") == "Melee"
                     or tool:GetAttribute("WeaponType") == "Sword") then
                    local Net = ReplicatedStorage.Modules.Net
                    pcall(function()
                        Net["RE/RegisterAttack"]:FireServer()
                        local head = parts[1][1]:FindFirstChild("Head")
                        if not head then return end
                        Net["RE/RegisterHit"]:FireServer(
                            head, parts, {},
                            tostring(Player.UserId):sub(2,4) .. tostring(coroutine.running()):sub(11,15)
                        )
                        if remote and idremote then
                            pcall(function()
                                cloneref(remote):FireServer(
                                    string.gsub("RE/RegisterHit", ".", function(c)
                                        return string.char(bit32.bxor(string.byte(c),
                                            math.floor(workspace:GetServerTimeNow()/10%10)+1))
                                    end),
                                    bit32.bxor(idremote+909090, Net.seed:InvokeServer()*2),
                                    head, parts
                                )
                            end)
                        end
                    end)
                end
            end)
        end
    end)
end

-- =====================================================
-- AUTO SKILL (Z / X / C)
-- =====================================================

function Functions.PressKey(key)
    VirtualInputManager:SendKeyEvent(true,  key, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end

function Functions.StartAutoSkill(config)
    -- Loop geral AutoSkill (Z+X+C) - equipa arma e usa todas as skills
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoSkill then continue end
            pcall(function()
                local char = Player.Character
                if not char then return end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then return end

                -- Equipa a arma selecionada atual
                local weaponName = config.SelectedWeaponName
                if weaponName ~= "" then
                    Functions.EquipWeapon(weaponName)
                    task.wait(0.1)
                end

                -- Usa Z, X, C com a ferramenta equipada
                Functions.PressKey(Enum.KeyCode.Z)
                task.wait(0.15)
                Functions.PressKey(Enum.KeyCode.X)
                task.wait(0.15)
                Functions.PressKey(Enum.KeyCode.C)
                task.wait(0.15)
            end)
        end
    end)

    -- Loop individual AutoSkillZ
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoSkillZ then continue end
            pcall(function()
                local char = Player.Character
                if not char then return end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then return end
                local weaponName = config.SelectedWeaponName
                if weaponName ~= "" then Functions.EquipWeapon(weaponName) task.wait(0.1) end
                Functions.PressKey(Enum.KeyCode.Z)
            end)
        end
    end)

    -- Loop individual AutoSkillX
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoSkillX then continue end
            pcall(function()
                local char = Player.Character
                if not char then return end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then return end
                local weaponName = config.SelectedWeaponName
                if weaponName ~= "" then Functions.EquipWeapon(weaponName) task.wait(0.1) end
                Functions.PressKey(Enum.KeyCode.X)
            end)
        end
    end)

    -- Loop individual AutoSkillC
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoSkillC then continue end
            pcall(function()
                local char = Player.Character
                if not char then return end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then return end
                local weaponName = config.SelectedWeaponName
                if weaponName ~= "" then Functions.EquipWeapon(weaponName) task.wait(0.1) end
                Functions.PressKey(Enum.KeyCode.C)
            end)
        end
    end)
end

-- =====================================================
-- RACE V3 / V4 / DOO HEE / QUEST RACE
-- =====================================================

function Functions.StartAutoRace(config)
    task.spawn(function()
        while task.wait(0.1) do
            if not config.AutoRaceV3 then continue end
            pcall(function()
                ReplicatedStorage.Remotes.CommE:FireServer("ActivateAbility")
            end)
        end
    end)

    task.spawn(function()
        while task.wait(0.1) do
            if not config.AutoRaceV4 then continue end
            pcall(function()
                VirtualInputManager:SendKeyEvent(true,  "Y", false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, "Y", false, game)
            end)
        end
    end)
end

function Functions.StartAutoQuestRace(config)
    task.spawn(function()
        while task.wait(0.1) do
            if not config.AutoQuestRace then continue end
            pcall(function()
                local timerGui = Player.PlayerGui:FindFirstChild("Main")
                               and Player.PlayerGui.Main:FindFirstChild("Timer")
                if not timerGui or not timerGui.Visible then return end

                local race = Player.Data.Race.Value

                if race == "Human" then
                    for _, v in pairs(workspace.Enemies:GetDescendants()) do
                        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart")
                           and v.Humanoid.Health > 0 then
                            pcall(function()
                                repeat task.wait(0.1)
                                    v.Humanoid.Health = 0
                                    v.HumanoidRootPart.CanCollide = false
                                    pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                                until not config.AutoQuestRace or not v.Parent or v.Humanoid.Health <= 0
                            end)
                        end
                    end

                elseif race == "Skypiea" then
                    for _, v in pairs(workspace.Map.SkyTrial.Model:GetDescendants()) do
                        if v.Name == "snowisland_Cylinder.081" then
                            Functions.TeleportTo(v.CFrame)
                        end
                    end

                elseif race == "Fishman" then
                    local seaBeast = workspace.SeaBeasts:FindFirstChild("SeaBeast1")
                    if seaBeast then
                        local hrp = seaBeast:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            Functions.TeleportTo(hrp.CFrame)
                            for _, toolType in ipairs({"Melee", "Blox Fruit", "Sword"}) do
                                for _, tool in ipairs(Player.Backpack:GetChildren()) do
                                    if tool:IsA("Tool") and tool.ToolTip == toolType then
                                        Player.Character.Humanoid:EquipTool(tool)
                                        task.wait(0.1)
                                        VirtualInputManager:SendKeyEvent(true,  122, false, Player.Character.HumanoidRootPart)
                                        VirtualInputManager:SendKeyEvent(false, 122, false, Player.Character.HumanoidRootPart)
                                        task.wait(0.2)
                                        VirtualInputManager:SendKeyEvent(true,  120, false, Player.Character.HumanoidRootPart)
                                        VirtualInputManager:SendKeyEvent(false, 120, false, Player.Character.HumanoidRootPart)
                                        task.wait(0.2)
                                        VirtualInputManager:SendKeyEvent(true,  99,  false, Player.Character.HumanoidRootPart)
                                        VirtualInputManager:SendKeyEvent(false, 99,  false, Player.Character.HumanoidRootPart)
                                        task.wait(0.5)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end

function Functions.StartAutoDooHee(config)
    task.spawn(function()
        while task.wait(0.1) do
            if not config.AutoDooHee then continue end
            pcall(function()
                local moonDir = game.Lighting:GetMoonDirection()
                local lookAtPos = workspace.CurrentCamera.CFrame.p + moonDir * 100
                workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.p, lookAtPos)
                task.wait(2)
                VirtualInputManager:SendKeyEvent(true,  "T", false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, "T", false, game)
            end)
        end
    end)
end

-- =====================================================
-- AUTO BARTILO
-- =====================================================

function Functions.StartAutoBartilo(config)
    task.spawn(function()
        while task.wait(0.1) do
            if not config.AutoBartilo then continue end
            pcall(function()
                local level = Player.Data.Level.Value
                if level < 800 then return end

                local progress = CF("BartiloQuestProgress", "Bartilo")

                if progress == 0 then
                    local questGui = Player.PlayerGui.Main.Quest
                    local questTitle = questGui.Container.QuestTitle.Title.Text
                    if questGui.Visible
                       and questTitle:find("Swan Pirates") and questTitle:find("50") then
                        local enemies = workspace.Enemies
                        if enemies:FindFirstChild("Swan Pirate") then
                            for _, v in ipairs(enemies:GetChildren()) do
                                if v.Name == "Swan Pirate" and v:FindFirstChild("Humanoid")
                                   and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                    pcall(function()
                                        repeat task.wait()
                                            pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                                            Functions.EquipWeapon(config.SelectedWeaponName)
                                            Functions.AutoHaki()
                                            v.HumanoidRootPart.Transparency = 1
                                            v.HumanoidRootPart.CanCollide   = false
                                            v.HumanoidRootPart.Size         = Vector3.new(50, 50, 50)
                                            Functions.TeleportTo(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                            VirtualUser:CaptureController()
                                            VirtualUser:Button1Down(Vector2.new(1280, 672))
                                        until not v.Parent or v.Humanoid.Health <= 0
                                           or not config.AutoBartilo
                                           or not questGui.Visible
                                    end)
                                end
                            end
                        else
                            Functions.TeleportTo(CFrame.new(932.624451, 156.106079, 1180.27466))
                        end
                    else
                        Functions.TeleportTo(CFrame.new(-456.28952, 73.0200958, 299.895966))
                        task.wait(1.1)
                        CF("StartQuest", "BartiloQuest", 1)
                    end

                elseif progress == 1 then
                    if workspace.Enemies:FindFirstChild("Jeremy") then
                        for _, v in ipairs(workspace.Enemies:GetChildren()) do
                            if v.Name == "Jeremy" and v:FindFirstChild("Humanoid")
                               and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                local oldCF = v.HumanoidRootPart.CFrame
                                repeat task.wait()
                                    pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                                    Functions.EquipWeapon(config.SelectedWeaponName)
                                    Functions.AutoHaki()
                                    v.HumanoidRootPart.Transparency = 1
                                    v.HumanoidRootPart.CanCollide   = false
                                    v.HumanoidRootPart.Size         = Vector3.new(50, 50, 50)
                                    v.HumanoidRootPart.CFrame       = oldCF
                                    Functions.TeleportTo(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                    VirtualUser:CaptureController()
                                    VirtualUser:Button1Down(Vector2.new(1280, 672))
                                until not v.Parent or v.Humanoid.Health <= 0 or not config.AutoBartilo
                            end
                        end
                    else
                        Functions.TeleportTo(CFrame.new(2099.88159, 448.931, 648.997375))
                        task.wait(2)
                    end

                elseif progress == 2 then
                    Functions.TeleportTo(CFrame.new(-1850.49329, 13.1789551, 1750.89685))
                    task.wait(1)
                end
            end)
        end
    end)
end

-- =====================================================
-- AUTO ELITE HUNTER (Diablo / Deandre / Urban)
-- =====================================================

function Functions.StartAutoEliteHunter(config)
    task.spawn(function()
        while task.wait(0.1) do
            if not config.AutoEliteHunter then continue end
            pcall(function()
                local questGui = Player.PlayerGui.Main.Quest
                if questGui.Visible then
                    local title = questGui.Container.QuestTitle.Title.Text
                    if title:find("Diablo") or title:find("Deandre") or title:find("Urban") then
                        local targets = {"Diablo", "Deandre", "Urban"}
                        for _, name in ipairs(targets) do
                            if workspace.Enemies:FindFirstChild(name) then
                                for _, v in ipairs(workspace.Enemies:GetChildren()) do
                                    if v.Name == name and v:FindFirstChild("Humanoid")
                                       and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                        repeat task.wait()
                                            Functions.AutoHaki()
                                            Functions.EquipWeapon(config.SelectedWeaponName)
                                            v.HumanoidRootPart.CanCollide = false
                                            v.Humanoid.WalkSpeed = 0
                                            Functions.TeleportTo(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                            VirtualUser:CaptureController()
                                            VirtualUser:Button1Down(Vector2.new(1280, 672))
                                            pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                                        until not config.AutoEliteHunter or v.Humanoid.Health <= 0 or not v.Parent
                                    end
                                end
                            else
                                local rs = ReplicatedStorage:FindFirstChild(name)
                                if rs and rs:FindFirstChild("HumanoidRootPart") then
                                    Functions.TeleportTo(rs.HumanoidRootPart.CFrame * CFrame.new(2, 20, 2))
                                end
                            end
                        end
                    end
                else
                    local response = CF("EliteHunter")
                    if config.AutoEliteHunterHop
                       and response == "I don't have anything for you right now. Come back later." then
                        Functions.Hop()
                    else
                        CF("EliteHunter")
                    end
                end
            end)
        end
    end)
end

-- =====================================================
-- AUTO YAMA / HOLY TORCH / TUSHITA / RENGOKU
-- =====================================================

function Functions.StartAutoYama(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoYama then continue end
            pcall(function()
                local progress = CF("EliteHunter", "Progress")
                if progress >= 30 then
                    local clickDetector = workspace.Map.Waterfall.SealedKatana.Handle:FindFirstChild("ClickDetector")
                    if clickDetector then
                        fireclickdetector(clickDetector)
                    end
                end
            end)
        end
    end)
end

function Functions.StartAutoHolyTorch(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoHolyTorch then continue end
            pcall(function()
                CF("requestEntrance",
                    Vector3.new(5657.88623046875, 1013.0790405273438, -335.4996337890625))
                task.wait(1)
                Functions.TeleportTo(CFrame.new(5711.87451171875, 45.82802963256836, 254.17005920410156))
                task.wait(15)
                Functions.EquipWeapon("Holy Torch")

                local torches = {
                    CFrame.new(-10752, 417, -9366),
                    CFrame.new(-11672, 334, -9474),
                    CFrame.new(-12132, 521, -10655),
                    CFrame.new(-13336, 486, -6985),
                    CFrame.new(-13489, 332, -7925),
                }
                for _, cf in ipairs(torches) do
                    if not config.AutoHolyTorch then break end
                    repeat
                        Functions.TeleportTo(cf)
                        task.wait()
                    until not config.AutoHolyTorch
                       or (Player.Character.HumanoidRootPart.Position - cf.Position).Magnitude <= 10
                    task.wait(1)
                end
            end)
        end
    end)
end

function Functions.StartAutoGetTushita(config)
    task.spawn(function()
        while task.wait(0.1) do
            if not config.AutoGetTushita then continue end
            pcall(function()
                if workspace.Enemies:FindFirstChild("Longma") then
                    for _, v in ipairs(workspace.Enemies:GetChildren()) do
                        if v.Name == "Longma" and v:FindFirstChild("Humanoid")
                           and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            repeat task.wait()
                                Functions.AutoHaki()
                                Functions.EquipWeapon(config.SelectedWeaponName)
                                v.HumanoidRootPart.CanCollide = false
                                v.Humanoid.WalkSpeed = 0
                                v.HumanoidRootPart.Size = Vector3.new(80, 80, 80)
                                Functions.TeleportTo(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                            until not config.AutoGetTushita or not v.Parent or v.Humanoid.Health <= 0
                        end
                    end
                elseif ReplicatedStorage:FindFirstChild("Longma") then
                    local longma = ReplicatedStorage.Longma
                    if longma:FindFirstChild("HumanoidRootPart") then
                        Functions.TeleportTo(longma.HumanoidRootPart.CFrame * CFrame.new(5, 10, 2))
                    end
                end
            end)
        end
    end)
end

function Functions.StartAutoRengoku(config)
    task.spawn(function()
        while task.wait(0.1) do
            if not config.AutoRengoku then continue end
            pcall(function()
                local hasKey = Player.Backpack:FindFirstChild("Hidden Key")
                            or (Player.Character and Player.Character:FindFirstChild("Hidden Key"))

                if hasKey then
                    Functions.EquipWeapon("Hidden Key")
                    Functions.TeleportTo(CFrame.new(6571.1201171875, 299.23028564453, -6967.841796875))

                elseif workspace.Enemies:FindFirstChild("Awakened Ice Admiral") then
                    for _, v in ipairs(workspace.Enemies:GetChildren()) do
                        if v.Name == "Awakened Ice Admiral" and v:FindFirstChild("Humanoid")
                           and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            repeat task.wait()
                                Functions.EquipWeapon(config.SelectedWeaponName)
                                Functions.AutoHaki()
                                v.HumanoidRootPart.CanCollide = false
                                v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                Functions.TeleportTo(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                config.StartBring = true
                            until Player.Backpack:FindFirstChild("Hidden Key")
                               or not config.AutoRengoku
                               or not v.Parent
                               or v.Humanoid.Health <= 0
                            config.StartBring = false
                        end
                    end
                else
                    config.StartBring = false
                    Functions.TeleportTo(CFrame.new(5439.716796875, 84.420944213867, -6715.1635742188))
                end
            end)
        end
    end)
end

-- =====================================================
-- AUTO SEA 3 BOSSES ESPECIAIS
-- =====================================================

-- Soul Reaper (Hallow Essence)
function Functions.StartAutoSoulReaper(config)
    task.spawn(function()
        while task.wait() do
            if not config.AutoSoulReaper then continue end
            pcall(function()
                if workspace.Enemies:FindFirstChild("Soul Reaper") then
                    for _, v in ipairs(workspace.Enemies:GetChildren()) do
                        if v.Name:find("Soul Reaper") then
                            repeat task.wait()
                                Functions.EquipWeapon(config.SelectedWeaponName)
                                Functions.AutoHaki()
                                v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                Functions.TeleportTo(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                VirtualUser:CaptureController()
                                VirtualUser:Button1Down(Vector2.new(1280, 670))
                                v.HumanoidRootPart.Transparency = 1
                            until v.Humanoid.Health <= 0 or not config.AutoSoulReaper
                        end
                    end
                elseif Player.Backpack:FindFirstChild("Hallow Essence") or
                       (Player.Character and Player.Character:FindFirstChild("Hallow Essence")) then
                    repeat
                        Functions.TeleportTo(CFrame.new(-8932.322265625, 146.83154296875, 6062.55078125))
                        task.wait()
                    until (CFrame.new(-8932.322265625, 146.83154296875, 6062.55078125).Position
                         - Player.Character.HumanoidRootPart.Position).Magnitude <= 8
                    Functions.EquipWeapon("Hallow Essence")
                else
                    if ReplicatedStorage:FindFirstChild("Soul Reaper") then
                        Functions.TeleportTo(ReplicatedStorage:FindFirstChild("Soul Reaper").HumanoidRootPart.CFrame * CFrame.new(2, 20, 2))
                    end
                end
            end)
        end
    end)
end

-- Tyrant of the Skies
function Functions.StartAutoTyrantSpawn(config)
    local TyrantPos = CFrame.new(-16194.0048828125, 155.21844482421875, 1420.719970703125)

    task.spawn(function()
        while task.wait() do
            if not config.AutoTyrantSpawn then continue end
            pcall(function()
                if workspace.Enemies:FindFirstChild("Tyrant of the Skies") then
                    for _, v in ipairs(workspace.Enemies:GetChildren()) do
                        if v.Name == "Tyrant of the Skies" and v:FindFirstChild("Humanoid")
                           and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            repeat task.wait()
                                Functions.AutoHaki()
                                Functions.EquipWeapon(config.SelectedWeaponName)
                                v.HumanoidRootPart.CanCollide = false
                                v.Humanoid.WalkSpeed = 0
                                v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                Functions.TeleportTo(v.HumanoidRootPart.CFrame * CFrame.new(0, 40, 0))
                                VirtualUser:CaptureController()
                                VirtualUser:Button1Down(Vector2.new(1280, 672))
                                pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                            until not config.AutoTyrantSpawn or not v.Parent or v.Humanoid.Health <= 0
                        end
                    end
                else
                    Functions.TeleportTo(TyrantPos)
                end
            end)
        end
    end)
end

-- Cake Prince / Fullykatakuri V2
function Functions.StartAutoCakePrince(config)
    local CakePos = CFrame.new(-2130.80712890625, 69.95634460449219, -12327.83984375)

    task.spawn(function()
        while task.wait() do
            if not config.AutoCakePrince then continue end
            pcall(function()
                if workspace.Enemies:FindFirstChild("Cake Prince") then
                    for _, v in ipairs(workspace.Enemies:GetChildren()) do
                        if v.Name == "Cake Prince" and v:FindFirstChild("Humanoid")
                           and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            repeat task.wait()
                                Functions.AutoHaki()
                                Functions.EquipWeapon(config.SelectedWeaponName)
                                v.HumanoidRootPart.CanCollide = false
                                v.Humanoid.WalkSpeed = 0
                                v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                Functions.TeleportTo(v.HumanoidRootPart.CFrame * CFrame.new(4, 10, 10))
                                VirtualUser:CaptureController()
                                VirtualUser:Button1Down(Vector2.new(1280, 672))
                                pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                            until not config.AutoCakePrince or not v.Parent or v.Humanoid.Health <= 0
                        end
                    end
                else
                    -- Farm mobs pre-Cake Prince
                    local preMobs = {"Cookie Crafter", "Cake Guard", "Baking Staff", "Head Baker"}
                    local bringPositions = {
                        ["Cookie Crafter"] = CFrame.new(-2212.88965, 37.0051041, -11969.2568),
                        ["Cake Guard"]     = CFrame.new(-1693.98047, 35.2188225, -12436.8438),
                        ["Baking Staff"]   = CFrame.new(-1980.4375, 34.6653099, -12983.8408),
                        ["Head Baker"]     = CFrame.new(-2151.37793, 51.0095749, -13033.3975),
                    }
                    local found = false
                    for _, mobName in ipairs(preMobs) do
                        if workspace.Enemies:FindFirstChild(mobName) then
                            found = true
                            for _, v in ipairs(workspace.Enemies:GetChildren()) do
                                if v.Name == mobName and v:FindFirstChild("Humanoid")
                                   and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                    local bPos = bringPositions[mobName]
                                    repeat task.wait()
                                        Functions.AutoHaki()
                                        Functions.EquipWeapon(config.SelectedWeaponName)
                                        v.HumanoidRootPart.CanCollide = false
                                        v.Humanoid.WalkSpeed = 0
                                        v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                        if bPos then v.HumanoidRootPart.CFrame = bPos end
                                        Functions.TeleportTo(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                        VirtualUser:CaptureController()
                                        VirtualUser:Button1Down(Vector2.new(1280, 672))
                                        pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                                    until not config.AutoCakePrince or not v.Parent or v.Humanoid.Health <= 0
                                end
                            end
                        end
                    end
                    if not found then
                        Functions.TeleportTo(CakePos)
                    end
                end
            end)
        end
    end)
end

-- Dough King
function Functions.StartAutoDoughKing(config)
    task.spawn(function()
        while task.wait() do
            if not config.AutoDoughKing then continue end
            pcall(function()
                if workspace.Enemies:FindFirstChild("Dough King") or ReplicatedStorage:FindFirstChild("Dough King") then
                    if workspace.Enemies:FindFirstChild("Dough King") then
                        for _, v in ipairs(workspace.Enemies:GetChildren()) do
                            if v.Name == "Dough King" and v:FindFirstChild("Humanoid")
                               and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                repeat task.wait()
                                    Functions.AutoHaki()
                                    Functions.EquipWeapon(config.SelectedWeaponName)
                                    v.HumanoidRootPart.Size = Vector3.new(70, 70, 70)
                                    v.HumanoidRootPart.CanCollide = false
                                    Functions.TeleportTo(v.HumanoidRootPart.CFrame * CFrame.new(0, -40, 0))
                                    VirtualUser:CaptureController()
                                    VirtualUser:Button1Down(Vector2.new(1280, 672))
                                    pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                                until not config.AutoDoughKing or not v.Parent or v.Humanoid.Health <= 0
                            end
                        end
                    else
                        Functions.TeleportTo(CFrame.new(-2130.80712890625, 69.95634460449219, -12327.83984375))
                    end
                else
                    -- Verificar Sweet Chalice / Katakuri V2
                    if Player.Backpack:FindFirstChild("Sweet Chalice") or
                       (Player.Character and Player.Character:FindFirstChild("Sweet Chalice")) then
                        if string.find(CF("CakePrinceSpawner"), "Do you want to open the portal now?") then
                            CF("CakePrinceSpawner")
                        end
                    elseif Player.Backpack:FindFirstChild("God's Chalice") or
                           (Player.Character and Player.Character:FindFirstChild("God's Chalice")) then
                        if string.find(CF("SweetChaliceNpc"), "Where") then
                            CF("SweetChaliceNpc")
                        end
                    else
                        Functions.TeleportTo(CFrame.new(-1820.0634765625, 210.74781799316406, -12297.49609375))
                    end
                end
            end)
        end
    end)
end

-- rip_indra (Big Mom equivalente)
function Functions.StartAutoRipIndra(config)
    task.spawn(function()
        while task.wait() do
            if not config.AutoRipIndra then continue end
            pcall(function()
                local indra = workspace.Enemies:FindFirstChild("rip_indra True Form")
                           or workspace.Enemies:FindFirstChild("rip_indra")
                if indra and indra:FindFirstChild("Humanoid") and indra:FindFirstChild("HumanoidRootPart")
                   and indra.Humanoid.Health > 0 then
                    local oldCF = indra.HumanoidRootPart.CFrame
                    repeat task.wait()
                        Functions.AutoHaki()
                        Functions.EquipWeapon(config.SelectedWeaponName)
                        indra.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                        indra.HumanoidRootPart.CanCollide = false
                        indra.HumanoidRootPart.CFrame = oldCF
                        Functions.TeleportTo(indra.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new(1280, 672))
                        pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                    until not config.AutoRipIndra or indra.Humanoid.Health <= 0 or not indra.Parent
                elseif ReplicatedStorage:FindFirstChild("rip_indra True Form") then
                    local rindra = ReplicatedStorage:FindFirstChild("rip_indra True Form")
                    if rindra:FindFirstChild("HumanoidRootPart") then
                        Functions.TeleportTo(rindra.HumanoidRootPart.CFrame * CFrame.new(2, 20, 2))
                    end
                else
                    Functions.TeleportTo(CFrame.new(-26880.93359375, 22.848554611206, 473.18951416016))
                end
            end)
        end
    end)
end

-- Auto Big Mom (alias)
function Functions.StartAutoBigMom(config)
    task.spawn(function()
        while task.wait() do
            if not config.AutoBigMom then continue end
            pcall(function()
                local bigmom = workspace.Enemies:FindFirstChild("Big Mom")
                if bigmom and bigmom:FindFirstChild("Humanoid") and bigmom:FindFirstChild("HumanoidRootPart")
                   and bigmom.Humanoid.Health > 0 then
                    repeat task.wait()
                        Functions.AutoHaki()
                        Functions.EquipWeapon(config.SelectedWeaponName)
                        bigmom.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                        bigmom.HumanoidRootPart.CanCollide = false
                        Functions.TeleportTo(bigmom.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new(1280, 672))
                        pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                    until not config.AutoBigMom or bigmom.Humanoid.Health <= 0 or not bigmom.Parent
                elseif ReplicatedStorage:FindFirstChild("Big Mom") then
                    local bm = ReplicatedStorage:FindFirstChild("Big Mom")
                    if bm:FindFirstChild("HumanoidRootPart") then
                        Functions.TeleportTo(bm.HumanoidRootPart.CFrame * CFrame.new(2, 20, 2))
                    end
                end
            end)
        end
    end)
end

-- Auto Farm Bone (Bone Island - Sea 3)
function Functions.StartAutoFarmBone(config)
    task.spawn(function()
        while task.wait() do
            if not config.AutoFarmBone then continue end
            pcall(function()
                local boneIslandMobs = {"Island Empress", "Bone Crusher", "Skeleton Warrior"}
                for _, mobName in ipairs(boneIslandMobs) do
                    if workspace.Enemies:FindFirstChild(mobName) then
                        for _, v in ipairs(workspace.Enemies:GetChildren()) do
                            if v.Name == mobName and v:FindFirstChild("Humanoid")
                               and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                repeat task.wait()
                                    Functions.AutoHaki()
                                    Functions.EquipWeapon(config.SelectedWeaponName)
                                    v.HumanoidRootPart.CanCollide = false
                                    v.Humanoid.WalkSpeed = 0
                                    v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                    Functions.TeleportTo(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                    VirtualUser:CaptureController()
                                    VirtualUser:Button1Down(Vector2.new(1280, 672))
                                    pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                                until not config.AutoFarmBone or not v.Parent or v.Humanoid.Health <= 0
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- Auto Pray / Try Luck (Bone Island rituals)
function Functions.StartAutoPray(config)
    task.spawn(function()
        while task.wait(0.1) do
            if not config.AutoPray then continue end
            pcall(function()
                Functions.TeleportTo(CFrame.new(-8652.99707, 143.450119, 6170.50879))
                task.wait()
                CF("gravestoneEvent", 1)
            end)
        end
    end)
end

function Functions.StartAutoTryLuck(config)
    task.spawn(function()
        while task.wait(1) do
            if not config.AutoTryLuck then continue end
            pcall(function()
                local CommF_ = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_")
                local result = CommF_:InvokeServer("Cousin", "Buy", "DLCBoxData")
                if result then
                else
                    warn("[AutoTryLuck] Sem Beli suficiente ou cooldown ativo.")
                end
            end)
        end
    end)
end

-- Auto Trade Bone
function Functions.StartAutoTradeBone(config)
    task.spawn(function()
        while task.wait(0.1) do
            if not config.AutoTradeBone then continue end
            pcall(function()
                CF("Bones", "Buy", 1, 1)
            end)
        end
    end)
end

-- Auto Haki V2 (Desbloquear)
function Functions.StartAutoHakiV2(config)
    task.spawn(function()
        while task.wait(0.1) do
            if not config.AutoHakiV2 then continue end
            pcall(function()
                -- Ir ate o NPC de Haki V2 e interagir
                local hakiNPCPos = CFrame.new(-1830, 10, -1700) -- posicao aproximada
                Functions.TeleportTo(hakiNPCPos)
                task.wait(0.5)
                CF("UnlockHaki")
            end)
        end
    end)
end

-- Auto Unlock Temple of Time
function Functions.StartAutoUnlockTemple(config)
    task.spawn(function()
        while task.wait(0.1) do
            if not config.AutoUnlockTemple then continue end
            pcall(function()
                -- Comprar Ancient One Quest
                CF("AncientOneQuest", "StartQuest")
                task.wait(1)
                -- TP para o Temple
                Functions.TeleportTo(CFrame.new(28286, 14897, 103))
            end)
        end
    end)
end

-- Auto God Human (Sea 3)
function Functions.StartAutoGodHuman(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoGodHuman then continue end
            pcall(function()
                CF("BuyGodhuman")
            end)
        end
    end)
end

-- Auto Dragon Taylor (Dragon Talon)
function Functions.StartAutoDragonTaylor(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoDragonTaylor then continue end
            pcall(function()
                CF("BuyDragonTalon")
            end)
        end
    end)
end

-- Auto Electric Claw
function Functions.StartAutoElectricClaw(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoElectricClaw then continue end
            pcall(function()
                CF("BuyElectricClaw")
            end)
        end
    end)
end

-- =====================================================
-- SEA 2 ESPECIAIS
-- =====================================================

-- Auto Dark Beard
function Functions.StartAutoDarkBeard(config)
    task.spawn(function()
        while task.wait() do
            if not config.AutoDarkBeard then continue end
            pcall(function()
                local darkbeard = workspace.Enemies:FindFirstChild("Dark Beard")
                if darkbeard and darkbeard:FindFirstChild("Humanoid") and darkbeard:FindFirstChild("HumanoidRootPart")
                   and darkbeard.Humanoid.Health > 0 then
                    repeat task.wait()
                        Functions.AutoHaki()
                        Functions.EquipWeapon(config.SelectedWeaponName)
                        darkbeard.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                        darkbeard.HumanoidRootPart.CanCollide = false
                        Functions.TeleportTo(darkbeard.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new(1280, 672))
                        pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                    until not config.AutoDarkBeard or darkbeard.Humanoid.Health <= 0 or not darkbeard.Parent
                elseif ReplicatedStorage:FindFirstChild("Dark Beard") then
                    Functions.TeleportTo(ReplicatedStorage.DarkBeard.HumanoidRootPart.CFrame * CFrame.new(2, 20, 2))
                else
                    Functions.TeleportTo(CFrame.new(-16204.21875, 90.44, -100.03))
                end
            end)
        end
    end)
end

-- Auto Gray Beard (Greybeard)
function Functions.StartAutoGrayBeard(config)
    task.spawn(function()
        while task.wait() do
            if not config.AutoGrayBeard then continue end
            pcall(function()
                if workspace.Enemies:FindFirstChild("Greybeard") then
                    for _, v in ipairs(workspace.Enemies:GetChildren()) do
                        if v.Name == "Greybeard" and v:FindFirstChild("Humanoid")
                           and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            repeat task.wait()
                                Functions.AutoHaki()
                                Functions.EquipWeapon(config.SelectedWeaponName)
                                v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                v.HumanoidRootPart.CanCollide = false
                                Functions.TeleportTo(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                VirtualUser:CaptureController()
                                VirtualUser:Button1Down(Vector2.new(1280, 672))
                                pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                            until not config.AutoGrayBeard or v.Humanoid.Health <= 0 or not v.Parent
                        end
                    end
                elseif ReplicatedStorage:FindFirstChild("Greybeard") then
                    Functions.TeleportTo(ReplicatedStorage.Greybeard.HumanoidRootPart.CFrame * CFrame.new(2, 20, 2))
                else
                    if config.AutoGrayBeardHop then Functions.Hop() end
                end
            end)
        end
    end)
end

-- Auto Sharkman V2
function Functions.StartAutoSharkmanV2(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoSharkmanV2 then continue end
            pcall(function()
                CF("BuySharkmanKarate", true)
                CF("BuySharkmanKarate")
            end)
        end
    end)
end

-- Auto Death Step
function Functions.StartAutoDeathStep(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoDeathStep then continue end
            pcall(function()
                CF("BuyDeathStep")
            end)
        end
    end)
end

-- Auto Factory (Sea 2)
function Functions.StartAutoFactory(config)
    task.spawn(function()
        while task.wait() do
            if not config.AutoFactory then continue end
            pcall(function()
                if workspace.Enemies:FindFirstChild("Core") then
                    for _, v in ipairs(workspace.Enemies:GetChildren()) do
                        if v.Name == "Core" and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            repeat task.wait()
                                Functions.AutoHaki()
                                Functions.EquipWeapon(config.SelectedWeaponName)
                                Functions.TeleportTo(CFrame.new(448.46756, 199.356781, -441.389252))
                                VirtualUser:CaptureController()
                                VirtualUser:Button1Down(Vector2.new(1280, 672))
                            until v.Humanoid.Health <= 0 or not config.AutoFactory
                        end
                    end
                else
                    Functions.TeleportTo(CFrame.new(448.46756, 199.356781, -441.389252))
                end
            end)
        end
    end)
end

-- Auto Raid Law (Sea 2) - CORRIGIDO igual Tiroreal
function Functions.StartAutoRaidLaw(config)

    -- Nomes de todos os bosses de chip raid do Blox Fruits
    local RAID_BOSS_NAMES = {
        "Flame Master",
        "Ice Admiral",
        "Quake Admiral",
        "Light Admiral",
        "Dark Master",
        "Magma Admiral",
        "Sand Master",
        "Buddha Master",
        "Spider Master",
        "Sound Master",
        "Dough Master",
        "Phoenix Master",
        -- variantes com prefixo [Raid Boss]
        "[Raid Boss] Flame Master",
        "[Raid Boss] Ice Admiral",
        "[Raid Boss] Quake Admiral",
        "[Raid Boss] Light Admiral",
        "[Raid Boss] Dark Master",
        "[Raid Boss] Magma Admiral",
        "[Raid Boss] Sand Master",
        "[Raid Boss] Buddha Master",
        "[Raid Boss] Spider Master",
        "[Raid Boss] Sound Master",
        "[Raid Boss] Dough Master",
        "[Raid Boss] Phoenix Master",
    }

    -- Set para lookup O(1)
    local RAID_BOSS_SET = {}
    for _, name in ipairs(RAID_BOSS_NAMES) do
        RAID_BOSS_SET[name] = true
    end

    -- Helper: tween fly até um CFrame dentro da raid (sem cair)
    local _raidIsTp   = { value = false }
    local _raidNoEquip = { value = false }

    local function RaidFlyTo(targetCF)
        local char = Player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- Ancora o HRP no Y atual para nao cair durante o voo
        local anchorY = hrp.Position.Y + 10
        local safeCF  = CFrame.new(
            targetCF.Position.X,
            math.max(targetCF.Position.Y, anchorY),
            targetCF.Position.Z
        )
        Functions.FlyToPosition(safeCF, TweenService, config, _raidIsTp, _raidNoEquip)
    end

    -- Helper: ancora o player no ar para nao cair enquanto aguarda spawn
    local function AnchorPlayerMidAir()
        pcall(function()
            local char = Player.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            if not hrp:FindFirstChild("RaidAnchor") then
                local bv       = Instance.new("BodyVelocity")
                bv.Name        = "RaidAnchor"
                bv.Parent      = hrp
                bv.MaxForce    = Vector3.new(0, 100000, 0)
                bv.Velocity    = Vector3.new(0, 0, 0)
            end
        end)
    end

    local function RemoveAnchor()
        pcall(function()
            local char = Player.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and hrp:FindFirstChild("RaidAnchor") then
                hrp.RaidAnchor:Destroy()
            end
        end)
    end

    -- Helper: pega próxima ilha da raid (ordem 1->5, a mais próxima ainda viva)
    local function GetNextRaidIsland(hrp)
        local loc = workspace._WorldOrigin and workspace._WorldOrigin:FindFirstChild("Locations")
        if not loc then return nil end
        for cu = 1, 5 do
            local islandPart = loc:FindFirstChild("Island " .. cu)
            if islandPart then
                local dist = (islandPart.Position - hrp.Position).Magnitude
                if dist <= 5000 then
                    return islandPart
                end
            end
        end
        return nil
    end

    -- Helper: verifica se tem boss de raid vivo no workspace.Enemies
    local function FindRaidBoss()
        local enemies = workspace:FindFirstChild("Enemies")
        if not enemies then return nil end
        for _, v in ipairs(enemies:GetChildren()) do
            if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart")
               and v.Humanoid.Health > 0 then
                -- Checa nome exato ou se contem "[Raid Boss]" no nome
                if RAID_BOSS_SET[v.Name] or v.Name:find("%[Raid Boss%]") then
                    return v
                end
            end
        end
        return nil
    end

    -- =============================================
    -- Loop 1: Comprar chip automaticamente
    -- =============================================
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoBuyChipRaidLaw then continue end
            pcall(function()
                local SelectChip = config.SelectChipRaid or "Flame"
                CF("RaidsNpc", "Select", SelectChip)
            end)
        end
    end)

    -- =============================================
    -- Loop 2: Iniciar raid automaticamente
    -- =============================================
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoStartRaidLaw then continue end
            pcall(function()
                local timerGui = Player.PlayerGui.Main and Player.PlayerGui.Main:FindFirstChild("Timer")
                if timerGui and timerGui.Visible then return end

                local hasChip = Player.Backpack:FindFirstChild("Special Microchip")
                            or (Player.Character and Player.Character:FindFirstChild("Special Microchip"))
                if not hasChip then return end

                local loc = workspace._WorldOrigin and workspace._WorldOrigin:FindFirstChild("Locations")
                if loc and loc:FindFirstChild("Island 1") then return end -- raid já ativa

                if game.PlaceId == 4442272183 then -- Sea 2
                    local summonCF = CFrame.new(-6438.73535, 250.645355, -4501.50684)
                    RaidFlyTo(summonCF)
                    task.wait(0.5)
                    CF("SetSpawnPoint")
                    pcall(function()
                        fireclickdetector(workspace.Map.CircleIsland.RaidSummon2.Button.Main.ClickDetector)
                    end)
                elseif game.PlaceId == 7449423635 then -- Sea 3
                    CF("requestEntrance",
                        Vector3.new(-5075.50927734375, 314.5155029296875, -3150.0224609375))
                    task.wait(0.5)
                    local summonCF = CFrame.new(-5017.40869, 314.844055, -2823.0127)
                    RaidFlyTo(summonCF)
                    task.wait(0.5)
                    CF("SetSpawnPoint")
                    pcall(function()
                        fireclickdetector(workspace.Map["Boat Castle"].RaidSummon2.Button.Main.ClickDetector)
                    end)
                end
            end)
        end
    end)

    -- =============================================
    -- Loop 3: Farm Raid principal
    -- =============================================
    task.spawn(function()
        while task.wait(0.1) do
            if not config.AutoRaidLaw then
                RemoveAnchor()
                continue
            end
            pcall(function()
                local char = Player.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                local hum  = char and char:FindFirstChildOfClass("Humanoid")
                if not hrp or not hum or hum.Health <= 0 then return end

                -- ── PRIORIDADE 1: Boss de raid vivo → mata instantaneamente ──
                local boss = FindRaidBoss()
                if boss then
                    RemoveAnchor()
                    local bossHrp = boss:FindFirstChild("HumanoidRootPart")
                    local bossHum = boss:FindFirstChild("Humanoid")
                    if bossHrp and bossHum and bossHum.Health > 0 then
                        -- Voa até o boss
                        RaidFlyTo(bossHrp.CFrame * CFrame.new(0, 30, 0))
                        task.wait(0.1)
                        -- Mata instantaneamente via SimulationRadius
                        repeat
                            task.wait(0.05)
                            pcall(function()
                                sethiddenproperty(Player, "SimulationRadius", math.huge)
                                bossHum.Health    = 0
                                bossHrp.CanCollide = false
                                bossHrp.Size       = Vector3.new(60, 60, 60)
                            end)
                        until not boss.Parent
                            or not boss:FindFirstChild("Humanoid")
                            or boss.Humanoid.Health <= 0
                            or not config.AutoRaidLaw
                    end
                    return
                end

                -- ── PRIORIDADE 2: Mobs normais vivos na área ──
                local enemies = workspace:FindFirstChild("Enemies")
                if not enemies then return end

                local hadMob = false
                for _, v in ipairs(enemies:GetChildren()) do
                    if not config.AutoRaidLaw then break end
                    local vHrp = v:FindFirstChild("HumanoidRootPart")
                    local vHum = v:FindFirstChild("Humanoid")
                    if vHrp and vHum and vHum.Health > 0
                       and (vHrp.Position - hrp.Position).Magnitude <= 2500 then
                        hadMob = true
                        RemoveAnchor()
                        -- Voa até o mob com TweenFly
                        RaidFlyTo(vHrp.CFrame * CFrame.new(0, 30, 0))
                        -- Ataca em loop até morrer
                        repeat
                            task.wait(0.05)
                            if not config.AutoRaidLaw then break end
                            Functions.AutoHaki()
                            Functions.EquipWeapon(config)
                            pcall(function()
                                vHrp.CanCollide = false
                                vHrp.Size       = Vector3.new(50, 50, 50)
                                pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                                VirtualUser:CaptureController()
                                VirtualUser:Button1Down(Vector2.new(1280, 672))
                            end)
                        until not v.Parent
                            or not v:FindFirstChild("Humanoid")
                            or v.Humanoid.Health <= 0
                            or not config.AutoRaidLaw
                    end
                end

                -- ── PRIORIDADE 3: Nenhum mob → avança para próxima ilha ──
                if not hadMob then
                    local nextIsland = GetNextRaidIsland(hrp)
                    if nextIsland then
                        -- Ancora no ar enquanto o tween voa (evita cair no mar)
                        AnchorPlayerMidAir()
                        local targetCF = CFrame.new(
                            nextIsland.Position.X,
                            nextIsland.Position.Y + 60,
                            nextIsland.Position.Z
                        )
                        RaidFlyTo(targetCF)
                        RemoveAnchor()
                    else
                        -- Sem ilha próxima: ancora no ar aguardando respawn
                        AnchorPlayerMidAir()
                        task.wait(1)
                    end
                end
            end)
        end
    end)
end

-- =====================================================
-- AWAKENER FRUIT (ativar frutas desperto no raid)
-- =====================================================
function Functions.StartAutoAwakenAbilities(config)
    task.spawn(function()
        while task.wait(0.1) do
            if not config.AutoAwakenAbilities then continue end
            pcall(function()
                CF("Awakener", "Awaken")
            end)
        end
    end)
end

-- =====================================================
-- LOAD FRUIT CHEAP (Auto Get Fruit Low Beli)
-- =====================================================
function Functions.StartAutoLoadFruitCheap(config)
    local cheapFruits = {
        "Rocket-Rocket","Spin-Spin","Chop-Chop","Spring-Spring","Bomb-Bomb",
        "Smoke-Smoke","Spike-Spike","Flame-Flame","Falcon-Falcon","Ice-Ice",
        "Sand-Sand","Dark-Dark","Ghost-Ghost","Diamond-Diamond","Light-Light",
        "Rubber-Rubber","Barrier-Barrier","Magnet-Magnet","Quake-Quake",
        "Human-Human","Bird: Phoenix","Gura-Gura","Gravity-Gravity",
        "Shadow-Shadow","Love-Love","Spider-Spider","Sound-Sound",
        "Ripple-Ripple","Door-Door","Pain-Pain"
    }

    task.spawn(function()
        while task.wait(0.1) do
            if not config.AutoFruit then continue end
            pcall(function()
                for _, fruitName in ipairs(cheapFruits) do
                    CF("LoadFruit", fruitName)
                end
            end)
        end
    end)
end

-- =====================================================
-- TWEEN FRUIT - CORRIGIDO
-- =====================================================
function Functions.StartTweenFruit(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.TweenFruit then continue end
            pcall(function()
                -- Frutas no workspace raiz (estilo Tiroreal)
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj:IsA("Tool") and obj.Name:find("Fruit") then
                        local handle = obj:FindFirstChild("Handle")
                        if handle then
                            local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local dist = (handle.Position - hrp.Position).Magnitude
                                local tween = TweenService:Create(
                                    hrp,
                                    TweenInfo.new(dist / 300, Enum.EasingStyle.Linear),
                                    { CFrame = CFrame.new(handle.Position) }
                                )
                                tween:Play()
                                tween.Completed:Wait()
                            end
                        end
                    end
                end

                -- Frutas no AppleSpawner
                local spawner = workspace:FindFirstChild("AppleSpawner")
                if spawner then
                    for _, obj in pairs(spawner:GetChildren()) do
                        if obj:IsA("Tool") then
                            local handle = obj:FindFirstChild("Handle")
                            if handle then
                                local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    local dist = (handle.Position - hrp.Position).Magnitude
                                    local tween = TweenService:Create(
                                        hrp,
                                        TweenInfo.new(dist / 300, Enum.EasingStyle.Linear),
                                        { CFrame = CFrame.new(handle.Position) }
                                    )
                                    tween:Play()
                                    tween.Completed:Wait()
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- Grab Fruit: TP direto (sem tween, instantâneo)
function Functions.StartGrabFruit(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.GrabFruit then continue end
            pcall(function()
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj:IsA("Tool") and obj.Name:find("Fruit") then
                        local handle = obj:FindFirstChild("Handle")
                        if handle then
                            Functions.TeleportTo(CFrame.new(handle.Position))
                        end
                    end
                end
            end)
        end
    end)
end

-- Auto Saber (Sea 1 & 2)
function Functions.StartAutoBuyTTK(config)
    task.spawn(function()
        while task.wait() do
            if not config.AutoBuyTTK then continue end
            pcall(function()
                local level = Player.Data.Level.Value
                if level < 200 then return end

                local hasSaber = Player.Backpack:FindFirstChild("True Triple Katana")
                              or (Player.Character and Player.Character:FindFirstChild("True Triple Katana"))
                if hasSaber then config.AutoBuyTTK = false; return end

                if workspace.Enemies:FindFirstChild("Saber Expert") then
                    for _, v in ipairs(workspace.Enemies:GetChildren()) do
                        if v.Name == "Saber Expert" and v:FindFirstChild("Humanoid")
                           and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            repeat task.wait()
                                Functions.AutoHaki()
                                Functions.EquipWeapon(config.SelectedWeaponName)
                                v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                v.HumanoidRootPart.CanCollide = false
                                Functions.TeleportTo(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                VirtualUser:CaptureController()
                                VirtualUser:Button1Down(Vector2.new(1280, 672))
                                pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                            until not config.AutoBuyTTK or v.Humanoid.Health <= 0 or not v.Parent
                        end
                    end
                elseif ReplicatedStorage:FindFirstChild("Saber Expert") then
                    local se = ReplicatedStorage:FindFirstChild("Saber Expert")
                    if se:FindFirstChild("HumanoidRootPart") then
                        Functions.TeleportTo(se.HumanoidRootPart.CFrame * CFrame.new(2, 20, 2))
                    end
                else
                    -- Ir ao NPC da quest Saber
                    Functions.TeleportTo(CFrame.new(-6763.52734375, 6.72978878, -5890.28515625))
                    task.wait(1)
                    CF("StartQuest", "SaberQuest", 1)
                end
            end)
        end
    end)
end

-- Auto Dark Blade V2
function Functions.StartAutoDarkBladeV2(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoDarkBladeV2 then continue end
            pcall(function()
                -- Verificar se tem Yoru
                if Player.Backpack:FindFirstChild("Dark Blade") or
                   (Player.Character and Player.Character:FindFirstChild("Dark Blade")) then
                    -- Ir ao NPC para upgrade
                    Functions.TeleportTo(CFrame.new(-1830.2, 10.5, -1713.4))
                    task.wait(0.5)
                    CF("UpgradeDarkBlade")
                end
            end)
        end
    end)
end

-- Auto Sea 2 (navegar de Sea 1 para Sea 2)
function Functions.StartAutoSea2(config)
    task.spawn(function()
        while task.wait() do
            if not config.AutoSea2 then continue end
            pcall(function()
                local level = Player.Data.Level.Value
                if level < 700 then return end
                -- Navegar ate o portal do Sea 2
                local pos1 = CFrame.new(4851.8720703125, 5.6514348983765, 718.47094726563)
                repeat task.wait()
                    Functions.TeleportTo(pos1)
                until (pos1.Position - Player.Character.HumanoidRootPart.Position).Magnitude <= 3 or not config.AutoSea2
                task.wait(0.5)
                CF("TravelToSea", 2)
            end)
        end
    end)
end

-- Auto Sea 3 (navegar para Sea 3 via rip_indra)
function Functions.StartAutoSea3(config)
    task.spawn(function()
        while task.wait() do
            if not config.AutoSea3 then continue end
            pcall(function()
                local level = Player.Data.Level.Value
                if level < 1500 then return end

                if workspace.Enemies:FindFirstChild("rip_indra") then
                    for _, v in ipairs(workspace.Enemies:GetChildren()) do
                        if v.Name == "rip_indra" and v:FindFirstChild("Humanoid")
                           and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            repeat task.wait()
                                Functions.AutoHaki()
                                Functions.EquipWeapon(config.SelectedWeaponName)
                                v.HumanoidRootPart.CanCollide = false
                                v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                Functions.TeleportTo(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                CF("TravelZou")
                                pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                            until not config.AutoSea3 or v.Humanoid.Health <= 0 or not v.Parent
                        end
                    end
                else
                    Functions.TeleportTo(CFrame.new(-26880.93359375, 22.848554611206, 473.18951416016))
                end
            end)
        end
    end)
end

-- Auto Pirate Raid (Sea 3)
function Functions.StartAutoPirateRaid(config)
    -- =====================================================
    -- AUTO PIRATE RAID - reescrito
    -- Fluxo: voa ate ilha atual -> espera mobs -> mata ->
    --        checa proxima ilha (RaidIsland1..5) -> voa ate ela -> repete
    -- Usa PartTele para hover no ar (nao cai apos o voo)
    -- =====================================================

    local ISLAND_COUNT   = 5
    local MOB_SEARCH_R   = 2500   -- raio de busca de mobs ao redor da ilha atual
    local HOVER_Y_OFFSET = 40     -- altura acima do centro da ilha para flutuar/esperar

    -- Refs de controle do FlyToPosition (mesmo padrao do resto do script)
    local _raidIsTp    = { value = false }
    local _raidNoEquip = { value = false }

    -- ── Cria/mantem o PartTele no ar para o char nao cair apos o voo ──
    local function EnsurePartTele()
        local char = Player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not char or not hrp then return end
        if not char:FindFirstChild("PartTele") then
            local pt        = Instance.new("Part", char)
            pt.Name         = "PartTele"
            pt.Size         = Vector3.new(10, 1, 10)
            pt.Anchored     = true
            pt.Transparency = 1
            pt.CanCollide   = false
            pt.CFrame       = hrp.CFrame
            -- Cola o HRP no PartTele enquanto _raidIsTp.value for true
            pt:GetPropertyChangedSignal("CFrame"):Connect(function()
                if not _raidIsTp.value then return end
                task.wait()
                local c = Player.Character
                if c and c:FindFirstChild("HumanoidRootPart") and c:FindFirstChild("PartTele") then
                    local cHrp = c.HumanoidRootPart
                    local _, yaw, _ = cHrp.CFrame:ToOrientation()
                    cHrp.CFrame = CFrame.new(c.PartTele.CFrame.Position) * CFrame.Angles(0, yaw, 0)
                end
            end)
        end
    end

    -- ── Destrói o PartTele (libera o char para gravidade normal) ──
    local function DestroyPartTele()
        local char = Player.Character
        if char and char:FindFirstChild("PartTele") then
            char.PartTele:Destroy()
        end
    end

    -- ── Hover: mantém o char flutuando em targetCF sem cair ──
    -- Cria o PartTele, posiciona ele no alvo e deixa ancorado (nao destroi)
    local function HoverAt(targetCF)
        local char = Player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not char or not hrp then return end
        EnsurePartTele()
        local pt = char:FindFirstChild("PartTele")
        if not pt then return end
        _raidIsTp.value = true
        pt.CFrame = targetCF
        -- Cola o HRP imediatamente no PartTele via Heartbeat enquanto hover ativo
        local conn
        conn = RunService.Heartbeat:Connect(function()
            local c   = Player.Character
            local cPt = c and c:FindFirstChild("PartTele")
            local cHrp = c and c:FindFirstChild("HumanoidRootPart")
            if cPt and cHrp and _raidIsTp.value then
                local _, yaw, _ = cHrp.CFrame:ToOrientation()
                cHrp.CFrame = CFrame.new(cPt.CFrame.Position) * CFrame.Angles(0, yaw, 0)
            else
                conn:Disconnect()
            end
        end)
    end

    -- ── StopHover: para de flutuar e remove o PartTele ──
    local function StopHover()
        _raidIsTp.value = false
        DestroyPartTele()
    end

    -- ── RaidFlyTo: usa FlyToPosition com o PartTele (igual ao resto do script) ──
    -- Nao adiciona offset extra de Y - o caller ja passa o Y correto
    local function RaidFlyTo(targetCF)
        local char = Player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not char or not hrp then return end
        -- Garante que PartTele nao existe antes (FlyToPosition cria o proprio)
        DestroyPartTele()
        _raidIsTp.value = false
        Functions.FlyToPosition(targetCF, TweenService, config, _raidIsTp, _raidNoEquip)
        -- Apos o voo o FlyToPosition destroi o PartTele; recriar para hover
    end

    -- ── GetIsland: retorna o Part/Model da ilha de raid pelo numero (1-5) ──
    local function GetIsland(n)
        local raidMap = workspace:FindFirstChild("Map")
                    and workspace.Map:FindFirstChild("RaidMap")
        if not raidMap then return nil end
        return raidMap:FindFirstChild("RaidIsland" .. n)
    end

    -- ── GetIslandCenter: retorna CFrame do centro da ilha + HOVER_Y_OFFSET ──
    local function GetIslandCenter(island)
        if not island then return nil end
        -- Se for Model, usa PrimaryPart ou HumanoidRootPart ou calcula AABB
        if island:IsA("Model") then
            if island.PrimaryPart then
                return CFrame.new(island.PrimaryPart.Position + Vector3.new(0, HOVER_Y_OFFSET, 0))
            end
            -- Fallback: primeiro BasePart filho
            for _, p in ipairs(island:GetDescendants()) do
                if p:IsA("BasePart") then
                    return CFrame.new(p.Position + Vector3.new(0, HOVER_Y_OFFSET, 0))
                end
            end
        elseif island:IsA("BasePart") then
            return CFrame.new(island.Position + Vector3.new(0, HOVER_Y_OFFSET, 0))
        end
        return nil
    end

    -- ── GetMobsNearIsland: lista mobs vivos perto de uma ilha ──
    local function GetMobsNearIsland(islandCenter)
        local mobs = {}
        local enemies = workspace:FindFirstChild("Enemies")
        if not enemies or not islandCenter then return mobs end
        for _, v in ipairs(enemies:GetChildren()) do
            local vHrp = v:FindFirstChild("HumanoidRootPart")
            local vHum = v:FindFirstChild("Humanoid")
            if vHrp and vHum and vHum.Health > 0
               and (vHrp.Position - islandCenter).Magnitude <= MOB_SEARCH_R then
                table.insert(mobs, v)
            end
        end
        return mobs
    end

    -- =====================================================
    -- LOOP PRINCIPAL
    -- =====================================================
    task.spawn(function()
        local currentIsland = 1   -- ilha atual (1 a 5)

        while task.wait(0.1) do
            if not config.AutoPirateRaid then
                StopHover()
                currentIsland = 1
                continue
            end

            pcall(function()
                local char = Player.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                local hum  = char and char:FindFirstChildOfClass("Humanoid")
                if not char or not hrp or not hum or hum.Health <= 0 then return end

                -- ── 1. Pega a ilha atual ──
                local island = GetIsland(currentIsland)

                -- Se a ilha nao existe ainda (ainda nao spawnou), aguarda no ar
                if not island then
                    -- Tenta a primeira ilha como fallback
                    island = GetIsland(1)
                    if not island then
                        StopHover()
                        task.wait(1)
                        return
                    end
                    currentIsland = 1
                end

                local islandCF     = GetIslandCenter(island)
                if not islandCF then task.wait(1); return end
                local islandCenter = islandCF.Position - Vector3.new(0, HOVER_Y_OFFSET, 0)

                -- ── 2. Se esta longe da ilha atual, voa ate ela ──
                if (hrp.Position - islandCF.Position).Magnitude > 200 then
                    RaidFlyTo(islandCF)
                    task.wait(0.3)
                    return
                end

                -- ── 3. Procura mobs na ilha atual ──
                local mobs = GetMobsNearIsland(islandCenter)

                if #mobs > 0 then
                    -- Tem mobs: mata todos
                    StopHover()
                    for _, v in ipairs(mobs) do
                        if not config.AutoPirateRaid then break end
                        local vHrp = v:FindFirstChild("HumanoidRootPart")
                        local vHum = v:FindFirstChild("Humanoid")
                        if not vHrp or not vHum or vHum.Health <= 0 then continue end

                        -- Voa ate o mob
                        RaidFlyTo(vHrp.CFrame * CFrame.new(0, 30, 0))

                        -- Ataca em loop ate morrer
                        repeat
                            task.wait(0.05)
                            if not config.AutoPirateRaid then break end
                            Functions.AutoHaki()
                            Functions.EquipWeapon(config, _raidNoEquip)
                            pcall(function()
                                vHrp.CanCollide = false
                                vHrp.Size       = Vector3.new(60, 60, 60)
                                pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                                VirtualUser:CaptureController()
                                VirtualUser:Button1Down(Vector2.new(1280, 672))
                            end)
                        until not v.Parent
                            or not v:FindFirstChild("Humanoid")
                            or v.Humanoid.Health <= 0
                            or not config.AutoPirateRaid
                    end

                else
                    -- Sem mobs na ilha atual: checa se a proxima ilha ja spawnou
                    if currentIsland < ISLAND_COUNT then
                        local nextIsland = GetIsland(currentIsland + 1)
                        if nextIsland then
                            -- Proxima ilha spawnou: avanca
                            currentIsland = currentIsland + 1
                            local nextCF = GetIslandCenter(nextIsland)
                            if nextCF then
                                RaidFlyTo(nextCF)
                            end
                            return
                        end
                    end

                    -- Proxima ilha ainda nao spawnou (ou ja e a ultima):
                    -- flutua no centro da ilha atual esperando mobs/proxima ilha
                    HoverAt(islandCF)
                    task.wait(0.5)
                end
            end)
        end
    end)
end
-- Auto Farm Chocola Island
function Functions.StartAutoFarmChocola(config)
    task.spawn(function()
        while task.wait() do
            if not config.FarmChocola then continue end
            pcall(function()
                local chocoMobs = {"Chocolate Bar Battler", "Sweet Chef", "Cocoa Warrior"}
                for _, mobName in ipairs(chocoMobs) do
                    if workspace.Enemies:FindFirstChild(mobName) then
                        for _, v in ipairs(workspace.Enemies:GetChildren()) do
                            if v.Name == mobName and v:FindFirstChild("Humanoid")
                               and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                repeat task.wait()
                                    Functions.AutoHaki()
                                    Functions.EquipWeapon(config.SelectedWeaponName)
                                    v.HumanoidRootPart.CanCollide = false
                                    v.Humanoid.WalkSpeed = 0
                                    v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                    Functions.TeleportTo(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                    VirtualUser:CaptureController()
                                    VirtualUser:Button1Down(Vector2.new(1280, 672))
                                    pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                                until not config.FarmChocola or not v.Parent or v.Humanoid.Health <= 0
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- =====================================================
-- KILL AURA / PVP
-- =====================================================

function Functions.StartKillAura(config)
    task.spawn(function()
        while task.wait(0.05) do
            if not config.KillAura then continue end
            pcall(function()
                local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                    if enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart")
                       and enemy.Humanoid.Health > 0 then
                        local dist = (enemy.HumanoidRootPart.Position - hrp.Position).Magnitude
                        if dist <= (config.KillAuraRadius or 1000) then
                            pcall(function()
                                repeat task.wait()
                                    pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                                    enemy.Humanoid.Health = 0
                                    enemy.HumanoidRootPart.CanCollide = false
                                until not config.KillAura or not enemy.Parent or enemy.Humanoid.Health <= 0
                            end)
                        end
                    end
                end
            end)
        end
    end)
end

function Functions.StartAutoPlayerHunter(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoPlayerHunter and not config.AutoKillPlayer then continue end
            pcall(function()
                local target = Players:FindFirstChild(config.SelectedPlayer)
                if not target or not target.Character then return end
                local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
                if not targetHRP then return end

                if config.AutoPlayerHunter then
                    Functions.TeleportTo(targetHRP.CFrame * CFrame.new(0, 5, 0))
                end

                if config.AutoKillPlayer then
                    local targetHum = target.Character:FindFirstChildOfClass("Humanoid")
                    if targetHum then
                        pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                        targetHum.Health = 0
                    end
                end
            end)
        end
    end)
end

-- =====================================================
-- SAIL BOAT / TERRORSHARK / WALK WATER
-- =====================================================

function Functions.StartSailBoat(config)
    local waypoints = {
        CFrame.new(-37813.6953, -0.3221744, 6105.16895),
        CFrame.new(-42250.2227, -0.3221744, 9247.07715),
    }

    task.spawn(function()
        while task.wait(0.1) do
            if not config.SailBoat then continue end
            pcall(function()
                local boats = workspace:FindFirstChild("Boats")
                if not boats then return end

                if not boats:FindFirstChild("PirateBrigade") then
                    Functions.TPP(CFrame.new(-16927.451171875, 9.0863618850708, 433.8642883300781))
                    local char = Player.Character
                    if char and (CFrame.new(-16927.451171875, 9.0863618850708, 433.8642883300781).Position
                               - char.HumanoidRootPart.Position).Magnitude <= 10 then
                        CF("BuyBoat", "PirateBrigade")
                    end
                    return
                end

                local brigade = boats.PirateBrigade
                local seat    = brigade:FindFirstChild("VehicleSeat")
                if not seat then return end

                local char = Player.Character
                if not char then return end

                if not char.Humanoid.Sit then
                    Functions.TPP(seat.CFrame * CFrame.new(0, 1, 0))
                    return
                end

                local enemyNames = {"Shark", "Terrorshark", "Piranha", "Fish Crew Member"}
                for _, name in ipairs(enemyNames) do
                    if workspace.Enemies:FindFirstChild(name) then
                        char.Humanoid.Sit = false
                        return
                    end
                end
            end)
        end
    end)
end

function Functions.StartAutoTerrorshark(config)
    task.spawn(function()
        while task.wait(0.1) do
            if not config.AutoTerrorshark then continue end
            pcall(function()
                local targetNames = {"Terrorshark", "Piranha", "Fish Crew Member", "Shark"}
                local found = false

                for _, name in ipairs(targetNames) do
                    if workspace.Enemies:FindFirstChild(name) then
                        found = true
                        for _, v in ipairs(workspace.Enemies:GetChildren()) do
                            if v.Name == name and v:FindFirstChild("Humanoid")
                               and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                local char = Player.Character
                                if char and char.Humanoid then
                                    char.Humanoid.Sit = false
                                end
                                repeat task.wait()
                                    Functions.AutoHaki()
                                    Functions.EquipWeapon(config.SelectedWeaponName)
                                    v.HumanoidRootPart.CanCollide = false
                                    v.Humanoid.WalkSpeed = 0
                                    v.Head.CanCollide = false
                                    config.MonFarm = v.Name
                                    local hasTyphoon = workspace._WorldOrigin:FindFirstChild("Typhoon Splash")
                                    local offset = hasTyphoon and CFrame.new(0, 300, 0) or CFrame.new(0, 60, 0)
                                    Functions.TeleportTo(v.HumanoidRootPart.CFrame * offset)
                                until not config.AutoTerrorshark or not v.Parent or v.Humanoid.Health <= 0
                            end
                        end
                    end
                end

                if not found then
                    local brigade = workspace.Boats:FindFirstChild("PirateBrigade")
                    if brigade then
                        local seat = brigade:FindFirstChild("VehicleSeat")
                        if seat then
                            Functions.TeleportTo(seat.CFrame * CFrame.new(0, -1, 0))
                        end
                    end
                end
            end)
        end
    end)
end

function Functions.SetWalkWater(enabled)
    pcall(function()
        local waterBase = workspace.Map:FindFirstChild("WaterBase-Plane")
        if waterBase then
            waterBase.Size = enabled
                and Vector3.new(1000, 112, 1000)
                or  Vector3.new(1000, 80, 1000)
        end
    end)
end

-- =====================================================
-- EVENTOS E ILHAS ESPECIAIS
-- =====================================================

function Functions.StartAutoMysticIsland(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoMysticIsland then continue end
            pcall(function()
                local locations = workspace._WorldOrigin:FindFirstChild("Locations")
                if not locations then return end
                for _, v in ipairs(locations:GetChildren()) do
                    if v.Name == "Mirage Island" then
                        Functions.TeleportTo(v.CFrame * CFrame.new(0, 333, 0))
                    end
                end
            end)
        end
    end)
end

function Functions.StartTweenToKitsune(config)
    task.spawn(function()
        while task.wait(0.1) do
            if not config.TweenToKitsune then continue end
            pcall(function()
                local kitsune = workspace.Map:FindFirstChild("KitsuneIsland")
                if not kitsune then return end
                local shrine = kitsune:FindFirstChild("ShrineActive")
                if shrine then
                    local part = shrine:FindFirstChild("NeonShrinePart")
                    if part then
                        Functions.TeleportTo(part.CFrame * CFrame.new(0, 0, 10))
                    end
                end
            end)
        end
    end)
end

function Functions.StartTweenMGear(config)
    task.spawn(function()
        while task.wait(0.1) do
            if not config.TweenMGear then continue end
            pcall(function()
                local mystic = workspace.Map:FindFirstChild("MysticIsland")
                if not mystic then return end
                for _, v in ipairs(mystic:GetChildren()) do
                    if v:IsA("MeshPart") and v.Material == Enum.Material.Neon then
                        Functions.TeleportTo(v.CFrame)
                    end
                end
            end)
        end
    end)
end

function Functions.StartAutoEmber(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoAzuerEmber and not config.AutoBlazeEmber then continue end
            pcall(function()
                if config.AutoAzuerEmber then
                    local ember = workspace:FindFirstChild("AttachedAzureEmber")
                    if ember then
                        local template = workspace:FindFirstChild("EmberTemplate")
                        if template and template:FindFirstChild("Part") then
                            Functions.TeleportTo(template.Part.CFrame)
                        end
                    end
                end
                if config.AutoBlazeEmber then
                    local ember = workspace:FindFirstChild("AttachedBlazeEmber")
                    if ember then
                        local template = workspace:FindFirstChild("EmberTemplate")
                        if template and template:FindFirstChild("Part") then
                            Functions.TeleportTo(template.Part.CFrame)
                        end
                    end
                end
            end)
        end
    end)
end

function Functions.StartAutoHydraTree(config)
    local positions = {
        CFrame.new(5500, 100, -400),
        CFrame.new(5600, 100, -300),
        CFrame.new(5700, 100, -350),
        CFrame.new(5650, 150, -450),
    }

    task.spawn(function()
        while task.wait(0.1) do
            if not config.AutoHydraTree then continue end
            pcall(function()
                Functions.AutoHaki()
                for _, cf in ipairs(positions) do
                    if not config.AutoHydraTree then break end
                    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                    if not hrp then break end
                    local dist = (hrp.Position - cf.Position).Magnitude
                    local tween = TweenService:Create(hrp, TweenInfo.new(dist / 200, Enum.EasingStyle.Linear), {CFrame = cf})
                    tween:Play()
                    tween.Completed:Wait()
                    local char = Player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local arrived = (char.HumanoidRootPart.Position - cf.Position).Magnitude <= 5
                        if arrived then
                            config.AutoSkill = true
                            task.wait(3)
                            config.AutoSkill = false
                        end
                    end
                end
            end)
        end
    end)
end

function Functions.StartAutoMobDragon(config)
    task.spawn(function()
        while task.wait(0.1) do
            if not config.AutoMobDragon then continue end
            pcall(function()
                if workspace.Enemies:FindFirstChild("Dragon") then
                    for _, v in ipairs(workspace.Enemies:GetChildren()) do
                        if v.Name == "Dragon" and v:FindFirstChild("Humanoid")
                           and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            repeat task.wait()
                                Functions.AutoHaki()
                                Functions.EquipWeapon(config.SelectedWeaponName)
                                v.HumanoidRootPart.CanCollide = false
                                v.Humanoid.WalkSpeed = 0
                                v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                Functions.TeleportTo(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                VirtualUser:CaptureController()
                                VirtualUser:Button1Down(Vector2.new(1280, 672))
                                pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                            until not config.AutoMobDragon or not v.Parent or v.Humanoid.Health <= 0
                        end
                    end
                end
            end)
        end
    end)
end

-- =====================================================
-- VULCAO (Prehistoric Island)
-- =====================================================

function Functions.StartDefendVolcano(config)
    task.spawn(function()
        while task.wait(0.1) do
            if not config.DefendVolcano then continue end
            pcall(function()
                -- Ficar perto do vulcao e matar inimigos
                local volcanoPos = CFrame.new(-14000, 300, -14000)
                local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                if (volcanoPos.Position - hrp.Position).Magnitude > 500 then
                    Functions.TeleportTo(volcanoPos)
                end

                for _, v in ipairs(workspace.Enemies:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart")
                       and v.Humanoid.Health > 0
                       and (v.HumanoidRootPart.Position - volcanoPos.Position).Magnitude <= 1000 then
                        pcall(function()
                            v.Humanoid.Health = 0
                            v.HumanoidRootPart.CanCollide = false
                            pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                        end)
                    end
                end
            end)
        end
    end)
end

function Functions.StartTweenVolcano(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.TweenVolcano then continue end
            pcall(function()
                local volcano = workspace:FindFirstChild("Volcano")
                           or workspace.Map:FindFirstChild("Volcano")
                if volcano then
                    local top = volcano:FindFirstChild("VulcanoTop") or volcano:FindFirstChild("Top")
                    if top then
                        Functions.TPP(top.CFrame * CFrame.new(0, 10, 0))
                    end
                end
            end)
        end
    end)
end

function Functions.StartAutoFindPrehistoric(config)
    task.spawn(function()
        while task.wait(1) do
            if not config.AutoFindPrehistoric then continue end
            pcall(function()
                -- Procurar Prehistoric Island nos Locations
                local locations = workspace._WorldOrigin and workspace._WorldOrigin:FindFirstChild("Locations")
                if locations then
                    for _, v in ipairs(locations:GetChildren()) do
                        if v.Name:find("Prehistoric") then
                            Functions.TPP(v.CFrame * CFrame.new(0, 100, 0))
                            return
                        end
                    end
                end
                -- Hop para encontrar o servidor com a ilha
                if config.AutoFindPrehistoricHop then
                    Functions.Hop()
                end
            end)
        end
    end)
end

-- =====================================================
-- BONE / EGG / CHEST
-- =====================================================

function Functions.StartAutoCollectBone(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoCollectBone then continue end
            pcall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and obj.Name == "DinoBone" then
                        Functions.TeleportTo(CFrame.new(obj.Position))
                        task.wait(0.1)
                    end
                end
            end)
        end
    end)
end

function Functions.StartAutoCollectEgg(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.CollectEgg then continue end
            pcall(function()
                ReplicatedStorage.Modules.Net["RE/CollectedDragonEgg"]:FireServer()
            end)
        end
    end)
end

function Functions.StartFarmChest(config, isTeleportingRef, notAutoEquipRef)
    task.spawn(function()
        while task.wait(0.2) do
            if not config.FarmChest then continue end
            pcall(function()
                local char = Player.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                local hum  = char and char:FindFirstChildOfClass("Humanoid")
                if not hrp or not hum or hum.Health <= 0 then return end

                -- Encontrar o bau mais proximo nao coletado
                local chests = CollectionService:GetTagged("_ChestTagged")
                local nearest, nearestDist = nil, math.huge
                for _, chest in ipairs(chests) do
                    if not chest:GetAttribute("IsDisabled") then
                        local dist = (chest:GetPivot().Position - hrp.Position).Magnitude
                        if dist < nearestDist then
                            nearestDist = dist
                            nearest = chest
                        end
                    end
                end

                if nearest then
                    local targetCF = CFrame.new(nearest:GetPivot().Position)
                    -- Usa TweenFly para voar ate o bau
                    Functions.FlyToPosition(targetCF, TweenService, config, isTeleportingRef, notAutoEquipRef)
                end
            end)
        end
    end)
end

-- =====================================================
-- FRUTAS
-- =====================================================

function Functions.StartAutoStoreFruit(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoStoreFruit then continue end
            pcall(function()
                for _, v in ipairs(Player.Backpack:GetChildren()) do
                    if v:IsA("Tool") and v.Name:find("Fruit") then
                        local firstName = v.Name:gsub(" Fruit", "")
                        CF(
                            "StoreFruit",
                            firstName .. "-" .. firstName,
                            v
                        )
                    end
                end
            end)
        end
    end)
end

function Functions.StartTweenFlyFruit(config, isTeleportingRef, notAutoEquipRef)
    task.spawn(function()
        while task.wait(0.3) do
            if not config.TweenFlyFruit then continue end
            pcall(function()
                local char = Player.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                -- Frutas diretas no workspace
                for _, v in ipairs(workspace:GetChildren()) do
                    if v:IsA("Tool") and v.Name:lower():find("fruit") then
                        local handle = v:FindFirstChild("Handle")
                        if handle then
                            local dist = (handle.Position - hrp.Position).Magnitude
                            if dist > 5 then
                                Functions.FlyToPosition(
                                    CFrame.new(handle.Position),
                                    TweenService, config,
                                    isTeleportingRef, notAutoEquipRef
                                )
                            end
                            return
                        end
                    end
                end

                -- Frutas no AppleSpawner
                local spawner = workspace:FindFirstChild("AppleSpawner")
                if spawner then
                    for _, v in ipairs(spawner:GetChildren()) do
                        if v:IsA("Tool") then
                            local handle = v:FindFirstChild("Handle")
                            if handle then
                                local dist = (handle.Position - hrp.Position).Magnitude
                                if dist > 5 then
                                    Functions.FlyToPosition(
                                        CFrame.new(handle.Position),
                                        TweenService, config,
                                        isTeleportingRef, notAutoEquipRef
                                    )
                                end
                                return
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- Alias de compatibilidade


function Functions.StartAutoFruit(config)
    task.spawn(function()
        while task.wait(1) do
            if not config.AutoFruit then continue end
            pcall(function()
                CF("LoadFruit")
            end)
        end
    end)
end

-- =====================================================
-- SHOP / COMPRAS
-- =====================================================

function Functions.StartAutoBuyEnhancement(config)
    task.spawn(function()
        while task.wait(1) do
            if not config.AutoBuyEnhancementColour then continue end
            pcall(function()
                CF("BuyEnhancementColour")
            end)
        end
    end)
end

function Functions.StartAutoBuyLegendarySword(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoBuyLegendarySword then continue end
            pcall(function()
                -- Compra as 3 espadas lendarias do dealer (Sea 2)
                CF("LegendarySwordDealer", "1")
                task.wait(0.1)
                CF("LegendarySwordDealer", "2")
                task.wait(0.1)
                CF("LegendarySwordDealer", "3")
            end)
        end
    end)
end

-- Comprar itens da loja (botao direto)
function Functions.BuyItem(itemName)
    pcall(function()
        CF("BuyItem", itemName)
    end)
end

function Functions.BuyFightingStyle(style)
    local styleMap = {
        ["Superhuman"]      = "BuySuperhuman",
        ["Death Step"]      = "BuyDeathStep",
        ["Electric Claw"]   = "BuyElectricClaw",
        ["Dragon Talon"]    = "BuyDragonTalon",
        ["God Human"]       = "BuyGodhuman",
        ["Sharkman Karate"] = "BuySharkmanKarate",
        ["Water Kung Fu"]   = "BuyFishmanKarate",
        ["Sanguine Art"]    = "BuySanguineArt",
    }
    local remote = styleMap[style]
    if remote then
        pcall(function()
            CF(remote)
        end)
    end
end

function Functions.BuyBlackbeardItem(itemType, slot)
    pcall(function()
        CF("BlackbeardReward", itemType, slot or "1")
    end)
end

-- =====================================================
-- AUTO BARISTA / BERRY / OBS HAKI
-- =====================================================

function Functions.StartAutoBarista(config)
    local hakiColors = {
        ["White"]  = 1, ["Black"]  = 2, ["Red"]    = 3,
        ["Blue"]   = 4, ["Green"]  = 5, ["Yellow"] = 6,
        ["Purple"] = 7, ["Pink"]   = 8,
    }

    task.spawn(function()
        while task.wait(1) do
            if not config.AutoBarista then continue end
            pcall(function()
                local colorIndex = hakiColors[config.HakiColor] or 1
                CF("Barista", colorIndex)
            end)
        end
    end)
end

function Functions.StartAutoFarmObsHaki(config)
    task.spawn(function()
        while task.wait(0.1) do
            if not config.AutoFarmObsHaki then continue end
            pcall(function()
                -- Ativar Observacao (pressionar F)
                VirtualInputManager:SendKeyEvent(true,  Enum.KeyCode.F, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                task.wait(0.1)
                -- Lutar para acumular exp de observacao
                local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                for _, enemy in ipairs(workspace.Enemies:GetChildren()) do
                    if enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart")
                       and enemy.Humanoid.Health > 0
                       and (enemy.HumanoidRootPart.Position - hrp.Position).Magnitude <= 50 then
                        Functions.FastAttack(enemy, config)
                    end
                end
            end)
        end
    end)
end

function Functions.CollectBerry(config, hopFunc)
    task.spawn(function()
        while task.wait() do
            if not config.AutoCollectBerry then continue end
            local char = Player.Character
            local pos  = char and char:GetPivot().Position
            if not pos then continue end

            local bushes = CollectionService:GetTagged("BerryBush")
            local nearest, nearestName, nearestDist = nil, nil, math.huge

            for _, bush in ipairs(bushes) do
                for attrName, _ in pairs(bush:GetAttributes()) do
                    local mag = (bush.Parent:GetPivot().Position - pos).Magnitude
                    if mag < nearestDist then
                        nearestDist = mag
                        nearest     = bush
                        nearestName = attrName
                    end
                end
            end

            if nearest and nearestName then
                local model  = nearest.Parent
                local center = model:GetPivot().Position
                Functions.TeleportTo(CFrame.new(center + Vector3.new(0, 2, 0)))
                task.wait(0.5)
                local berryPart = model:FindFirstChild(nearestName)
                if berryPart and berryPart:IsA("BasePart") then
                    Functions.TeleportTo(berryPart.CFrame + Vector3.new(0, 1, 0))
                    task.wait(0.3)
                    VirtualInputManager:SendKeyEvent(true,  Enum.KeyCode.E, false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                end
            else
                if config.AutoCollectBerryHop and hopFunc then
                    hopFunc()
                end
            end
        end
    end)
end

-- =====================================================
-- AUTO DUNGEON
-- =====================================================

function Functions.StartAutoDungeon(config)
    local function getNextIsland()
        local islands = workspace:FindFirstChild("DungeonIslands")
        if not islands then return nil end
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        local nearest, nearestDist = nil, math.huge
        for _, island in ipairs(islands:GetChildren()) do
            local pos = island:IsA("Model") and island:GetPivot() or (island:IsA("BasePart") and island.CFrame)
            if pos then
                local dist = (pos.Position - hrp.Position).Magnitude
                if dist < nearestDist then
                    nearest, nearestDist = island, dist
                end
            end
        end
        return nearest
    end

    local function attackNearby()
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for _, v in ipairs(workspace.Enemies:GetChildren()) do
            if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart")
               and v.Humanoid.Health > 0 then
                local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
                if dist <= 100 then
                    pcall(function()
                        v.Humanoid.Health = 0
                        v.HumanoidRootPart.CanCollide = false
                        pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                    end)
                end
            end
        end
    end

    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoDungeon then continue end
            pcall(function()
                attackNearby()
                local next = getNextIsland()
                if next then
                    local pos = next:IsA("Model") and next:GetPivot() or next.CFrame
                    Functions.TeleportTo(pos * CFrame.new(0, 60, 0))
                end
            end)
        end
    end)
end

-- =====================================================
-- SAFE MODE
-- =====================================================

function Functions.StartSafeMode(config)
    task.spawn(function()
        while task.wait(0.1) do
            if not config.SafeMode then continue end
            pcall(function()
                local char = Player.Character
                local hum  = char and char:FindFirstChild("Humanoid")
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if char and hum and hrp then
                    if hum.Health < 5500 then
                        while config.SafeMode and hum.Health < 5500 do
                            task.wait(0.1)
                            hrp.CFrame = hrp.CFrame + Vector3.new(0, 200, 0)
                        end
                    end
                end
            end)
        end
    end)
end

-- =====================================================
-- ANTI-AFK / HOP
-- =====================================================

function Functions.StartAntiAFK()
    Player.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
end

function Functions.Hop()
    local PlaceID = game.PlaceId
    local AllIDs  = {}
    local foundAnything = ""
    local actualHour    = os.date("!*t").hour

    local function TPReturner()
        local url = "https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Asc&limit=100"
        if foundAnything ~= "" then url = url .. "&cursor=" .. foundAnything end

        local Site = game:GetService("HttpService"):JSONDecode(game:HttpGet(url))

        if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
            foundAnything = Site.nextPageCursor
        end

        local num = 0
        for _, v in pairs(Site.data) do
            local Possible = true
            local ID       = tostring(v.id)
            if tonumber(v.maxPlayers) > tonumber(v.playing) then
                for _, Existing in pairs(AllIDs) do
                    if num ~= 0 then
                        if ID == tostring(Existing) then Possible = false end
                    else
                        if tonumber(actualHour) ~= tonumber(Existing) then
                            AllIDs = {}
                            table.insert(AllIDs, actualHour)
                        end
                    end
                    num = num + 1
                end
                if Possible then
                    table.insert(AllIDs, ID)
                    task.wait(0.1)
                    pcall(function()
                        game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, Player)
                    end)
                    task.wait(0.1)
                end
            end
        end
    end

    while task.wait(0.1) do
        pcall(function()
            TPReturner()
            if foundAnything ~= "" then TPReturner() end
        end)
    end
end

function Functions.ServerHop()
    local TeleportService = game:GetService("TeleportService")
    local HttpService     = game:GetService("HttpService")
    local placeId         = game.PlaceId
    local allIDs          = {}
    local cursor          = ""

    local function fetchServers()
        local url = "https://games.roblox.com/v1/games/" .. placeId
                 .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor ~= "" then url = url .. "&cursor=" .. cursor end

        local ok, raw = pcall(function() return game:HttpGet(url) end)
        if not ok then return end

        local ok2, data = pcall(function() return HttpService:JSONDecode(raw) end)
        if not ok2 or not data or not data.data then return end

        if data.nextPageCursor and data.nextPageCursor ~= "null" then
            cursor = data.nextPageCursor
        end

        for _, server in pairs(data.data) do
            local id = tostring(server.id)
            if tonumber(server.maxPlayers) > tonumber(server.playing) then
                local duplicate = false
                for _, existing in pairs(allIDs) do
                    if id == existing then duplicate = true; break end
                end
                if not duplicate then
                    table.insert(allIDs, id)
                    pcall(function()
                        task.wait(0.1)
                        TeleportService:TeleportToPlaceInstance(placeId, id, Player)
                    end)
                    task.wait(0.1)
                end
            end
        end
    end

    task.spawn(function()
        while true do
            task.wait(0.1)
            pcall(fetchServers)
            if cursor ~= "" then
                pcall(fetchServers)
            end
        end
    end)
end

-- =====================================================
-- MISC UI
-- =====================================================

function Functions.SetHideChat(enabled)
    pcall(function()
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, not enabled)
    end)
end

function Functions.SetHideLeaderboard(enabled)
    pcall(function()
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not enabled)
    end)
end

-- =====================================================
-- DISABLE GAME NOTIFY (suprime notificacoes do Blox Fruits)
-- =====================================================

local _notifyConn = nil

function Functions.SetDisableGameNotify(enabled)
    if enabled then
        -- Hook StarterGui:SetCore para bloquear notificacoes do jogo
        pcall(function()
            -- Suprime notificacoes via metodo de override
            local oldSetCore = StarterGui.SetCore
            StarterGui.SetCore = function(self, coreType, ...)
                -- Bloqueia SendNotification (popups do jogo)
                if coreType == "SendNotification" then return end
                return oldSetCore(self, coreType, ...)
            end
        end)

        -- Tambem remove GUIs de notificacao existentes do PlayerGui
        pcall(function()
            local function removeNotifyGuis()
                local pg = Player.PlayerGui
                for _, gui in ipairs(pg:GetChildren()) do
                    if gui.Name == "Notification"
                    or gui.Name == "NotificationGui"
                    or gui.Name == "BloxFruitNotification"
                    or gui.Name == "SystemMessage" then
                        gui:Destroy()
                    end
                end
            end

            removeNotifyGuis()

            -- Monitora novos GUIs e remove os de notificacao
            if _notifyConn then _notifyConn:Disconnect() end
            _notifyConn = Player.PlayerGui.ChildAdded:Connect(function(child)
                if child.Name == "Notification"
                or child.Name == "NotificationGui"
                or child.Name == "BloxFruitNotification"
                or child.Name == "SystemMessage" then
                    task.wait()
                    pcall(function() child:Destroy() end)
                end
            end)
        end)

        -- Bloqueia via ReplicatedStorage se o jogo usar remote de notify
        pcall(function()
            local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
            if remotes then
                local notifyRemote = remotes:FindFirstChild("Notify")
                               or remotes:FindFirstChild("SendNotification")
                               or remotes:FindFirstChild("CommE")
                if notifyRemote and notifyRemote:IsA("RemoteEvent") then
                    notifyRemote.OnClientEvent:Connect(function(notifyType)
                        -- Intercepta e ignora (nao faz nada)
                        if notifyType == "Notification" or notifyType == "Notify" then
                            return
                        end
                    end)
                end
            end
        end)
    else
        -- Desativa monitoramento
        if _notifyConn then
            _notifyConn:Disconnect()
            _notifyConn = nil
        end
    end
end

function Functions.StartDisableGameNotify(config)
    task.spawn(function()
        while task.wait(0.5) do
            pcall(function()
                local notify = Player.PlayerGui:FindFirstChild("Notifications")
                if notify then
                    notify.Enabled = not config.DisableGameNotify
                end
            end)
        end
    end)
end

function Functions.OpenInventory()
    pcall(function()
        CF("getInventoryWeapons")
        task.wait(1)
        Player.PlayerGui.Main.Inventory.Visible = true
    end)
end

function Functions.OpenFruitInventory()
    pcall(function()
        CF("getInventoryFruits")
        Player.PlayerGui.Main.FruitInventory.Visible = true
    end)
end

function Functions.OpenHakiColors()
    pcall(function()
        Player.PlayerGui.Main.Colors.Visible = true
    end)
end

function Functions.OpenTitles()
    pcall(function()
        CF("getTitles")
        Player.PlayerGui.Main.Titles.Visible = true
    end)
end

function Functions.JoinTeam(teamName)
    pcall(function()
        CF("SetTeam", teamName)
    end)
end

function Functions.RedeemAllCodes()
    local codes = {
        "KITTGAMING","ENYU_IS_PRO","FUDD10","BIGNEWS","THEGREATACE",
        "SUB2GAMERROBOT_EXP1","STRAWHATMAIME","SUB2OFFICIALNOOBIE",
        "SUB2NOOBMASTER123","SUB2DAIGROCK","AXIORE","TANTAIGAMIMG",
        "STRAWHATMAINE","JCWK","FUDD10_V2","SUB2FER999","MAGICBIS",
        "TY_FOR_WATCHING","STARCODEHEO"
    }
    for _, code in ipairs(codes) do
        pcall(function()
            ReplicatedStorage.Remotes.Redeem:InvokeServer(code)
        end)
    end
end

-- =====================================================
-- VISUAIS / FOG / LAVA
-- =====================================================

function Functions.RemoveFog()
    pcall(function()
        game:GetService("Lighting").FogEnd = 9e9
        local atm = game:GetService("Lighting"):FindFirstChild("BaseAtmosphere")
        if atm then atm:Destroy() end
    end)
end

function Functions.RemoveLava()
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "Lava" then pcall(function() v:Destroy() end) end
    end
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v.Name == "Lava" then pcall(function() v:Destroy() end) end
    end
end

-- =====================================================
-- ESP
-- =====================================================

local _mobESP = {}

function Functions.StartMobESP()
    local Camera   = workspace.CurrentCamera
    local MAX_DIST = 5000

    local function createCircle()
        local circle     = Drawing.new("Circle")
        circle.Color     = Color3.fromRGB(0, 255, 0)
        circle.Thickness = 2
        circle.NumSides  = 50
        circle.Filled    = false
        circle.Radius    = 1.2
        circle.Visible   = true
        return circle
    end

    local function addESP(mob)
        if _mobESP[mob] then return end
        local circle = createCircle()
        _mobESP[mob] = circle
        mob.AncestryChanged:Connect(function(_, parent)
            if not parent and _mobESP[mob] then
                _mobESP[mob]:Remove()
                _mobESP[mob] = nil
            end
        end)
    end

    RunService.RenderStepped:Connect(function()
        local char = Player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for mob, circle in pairs(_mobESP) do
            if mob and mob:FindFirstChild("HumanoidRootPart")
               and mob:FindFirstChildOfClass("Humanoid")
               and mob.Humanoid.Health > 0 then
                local dist = (mob.HumanoidRootPart.Position - hrp.Position).Magnitude
                if dist <= MAX_DIST then
                    local pos, onScreen = Camera:WorldToViewportPoint(mob.HumanoidRootPart.Position)
                    circle.Position = Vector2.new(pos.X, pos.Y)
                    circle.Visible  = onScreen
                else
                    circle.Visible = false
                end
            else
                circle.Visible = false
            end
        end
    end)

    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in ipairs(enemies:GetChildren()) do addESP(mob) end
        enemies.ChildAdded:Connect(function(mob)
            task.wait(0.2)
            addESP(mob)
        end)
    end
end

local _espNumber = math.random(1, 1000000)

function Functions.UpdatePlayerESP(enabled, showTeammates)
    for _, v in ipairs(Players:GetChildren()) do
        pcall(function()
            if not v.Character then return end
            local head = v.Character:FindFirstChild("Head")
            if not head then return end
            local tag = "LotuxESP" .. _espNumber

            if enabled then
                if not head:FindFirstChild(tag) then
                    local bill = Instance.new("BillboardGui", head)
                    bill.Name          = tag
                    bill.ExtentsOffset = Vector3.new(0, 1, 0)
                    bill.Size          = UDim2.new(1, 200, 1, 30)
                    bill.Adornee       = head
                    bill.AlwaysOnTop   = true
                    local lbl = Instance.new("TextLabel", bill)
                    lbl.Font               = Enum.Font.GothamSemibold
                    lbl.TextSize           = 14
                    lbl.TextWrapped        = true
                    lbl.Text               = v.Name
                    lbl.Size               = UDim2.new(1, 0, 1, 0)
                    lbl.TextYAlignment     = Enum.TextYAlignment.Top
                    lbl.BackgroundTransparency = 1
                    lbl.TextStrokeTransparency = 0.5
                    if v.Team == Player.Team then
                        lbl.TextColor3 = (not showTeammates) and Color3.new(0,1,0) or Color3.new(1,1,0)
                    else
                        lbl.TextColor3 = Color3.new(1,0,0)
                    end
                else
                    local hum  = v.Character:FindFirstChildOfClass("Humanoid")
                    local dist = math.floor((Player.Character.Head.Position - head.Position).Magnitude / 3)
                    head[tag].TextLabel.Text = v.Name
                        .. " | " .. dist .. "m"
                        .. " | HP:" .. (hum and math.floor(hum.Health*100/hum.MaxHealth) or "?") .. "%"
                end
            else
                if head:FindFirstChild(tag) then
                    head:FindFirstChild(tag):Destroy()
                end
            end
        end)
    end
end

function Functions.UpdateIslandESP(enabled)
    local locations = workspace:FindFirstChild("_WorldOrigin")
                   and workspace._WorldOrigin:FindFirstChild("Locations")
    if not locations then return end
    for _, v in ipairs(locations:GetChildren()) do
        pcall(function()
            if enabled and v.Name ~= "Sea" then
                if not v:FindFirstChild("LotuxIslandESP") then
                    local bill = Instance.new("BillboardGui", v)
                    bill.Name          = "LotuxIslandESP"
                    bill.ExtentsOffset = Vector3.new(0, 1, 0)
                    bill.Size          = UDim2.new(1, 200, 1, 30)
                    bill.Adornee       = v
                    bill.AlwaysOnTop   = true
                    local lbl = Instance.new("TextLabel", bill)
                    lbl.Font               = Enum.Font.GothamSemibold
                    lbl.TextSize           = 14
                    lbl.TextWrapped        = true
                    lbl.Size               = UDim2.new(1, 0, 1, 0)
                    lbl.TextYAlignment     = Enum.TextYAlignment.Top
                    lbl.BackgroundTransparency = 1
                    lbl.TextStrokeTransparency = 0.5
                    lbl.TextColor3         = Color3.fromRGB(8, 247, 255)
                else
                    local dist = math.floor(
                        (Player.Character.Head.Position - v.Position).Magnitude / 3)
                    v.LotuxIslandESP.TextLabel.Text = v.Name .. "\n" .. dist .. "m"
                end
            else
                if v:FindFirstChild("LotuxIslandESP") then
                    v.LotuxIslandESP:Destroy()
                end
            end
        end)
    end
end

function Functions.UpdateDevilFruitESP(enabled)
    for _, v in ipairs(workspace:GetChildren()) do
        pcall(function()
            if enabled and string.find(v.Name, "Fruit") and v:FindFirstChild("Handle") then
                local tag = "LotuxFruitESP" .. _espNumber
                if not v.Handle:FindFirstChild(tag) then
                    local bill = Instance.new("BillboardGui", v.Handle)
                    bill.Name          = tag
                    bill.ExtentsOffset = Vector3.new(0, 1, 0)
                    bill.Size          = UDim2.new(1, 200, 1, 30)
                    bill.Adornee       = v.Handle
                    bill.AlwaysOnTop   = true
                    local lbl = Instance.new("TextLabel", bill)
                    lbl.Font               = Enum.Font.GothamSemibold
                    lbl.TextSize           = 14
                    lbl.TextWrapped        = true
                    lbl.Size               = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextStrokeTransparency = 0.5
                    lbl.TextColor3         = Color3.fromRGB(255, 255, 255)
                end
                local dist = math.floor((Player.Character.Head.Position - v.Handle.Position).Magnitude / 3)
                v.Handle["LotuxFruitESP".. _espNumber].TextLabel.Text = v.Name .. "\n" .. dist .. "m"
            else
                if v:FindFirstChild("Handle") then
                    local tag = "LotuxFruitESP" .. _espNumber
                    if v.Handle:FindFirstChild(tag) then
                        v.Handle[tag]:Destroy()
                    end
                end
            end
        end)
    end
end

function Functions.UpdateChestESP(enabled)
    for _, chest in pairs(CollectionService:GetTagged("_ChestTagged")) do
        pcall(function()
            if enabled and not chest:GetAttribute("IsDisabled") then
                if not chest:FindFirstChild("LotuxChestESP") then
                    local bill = Instance.new("BillboardGui", chest)
                    bill.Name          = "LotuxChestESP"
                    bill.ExtentsOffset = Vector3.new(0, 1, 0)
                    bill.Size          = UDim2.new(1, 200, 1, 30)
                    bill.Adornee       = chest
                    bill.AlwaysOnTop   = true
                    local lbl = Instance.new("TextLabel", bill)
                    lbl.Font               = Enum.Font.Code
                    lbl.TextSize           = 14
                    lbl.TextWrapped        = true
                    lbl.Size               = UDim2.new(1, 0, 1, 0)
                    lbl.TextYAlignment     = Enum.TextYAlignment.Top
                    lbl.BackgroundTransparency = 1
                    lbl.TextStrokeTransparency = 0.5
                    lbl.TextColor3         = Color3.fromRGB(255, 215, 0)
                end
                local dist = math.floor((Player.Character.Head.Position - chest:GetPivot().Position).Magnitude / 3)
                chest.LotuxChestESP.TextLabel.Text = "Chest\n" .. dist .. "m"
            else
                if chest:FindFirstChild("LotuxChestESP") then
                    chest.LotuxChestESP:Destroy()
                end
            end
        end)
    end
end

function Functions.UpdateBerriesESP(enabled)
    for _, bush in pairs(CollectionService:GetTagged("BerryBush")) do
        pcall(function()
            for attrName, berry in pairs(bush:GetAttributes()) do
                if berry then
                    if enabled then
                        if not bush.Parent:FindFirstChild("LotuxBerryESP") then
                            local bill = Instance.new("BillboardGui", bush.Parent)
                            bill.Name          = "LotuxBerryESP"
                            bill.ExtentsOffset = Vector3.new(0, 1, 0)
                            bill.Size          = UDim2.new(1, 200, 1, 30)
                            bill.Adornee       = bush.Parent
                            bill.AlwaysOnTop   = true
                            local lbl = Instance.new("TextLabel", bill)
                            lbl.Font               = Enum.Font.GothamSemibold
                            lbl.TextSize           = 14
                            lbl.TextWrapped        = true
                            lbl.Size               = UDim2.new(1, 0, 1, 0)
                            lbl.TextYAlignment     = Enum.TextYAlignment.Top
                            lbl.BackgroundTransparency = 1
                            lbl.TextStrokeTransparency = 0.5
                            lbl.TextColor3         = Color3.fromRGB(0, 200, 100)
                        end
                        local dist = math.floor((Player.Character.Head.Position - bush.Parent:GetPivot().Position).Magnitude / 3)
                        bush.Parent.LotuxBerryESP.TextLabel.Text = attrName .. "\n" .. dist .. "m"
                    else
                        if bush.Parent:FindFirstChild("LotuxBerryESP") then
                            bush.Parent.LotuxBerryESP:Destroy()
                        end
                    end
                end
            end
        end)
    end
end

function Functions.UpdateMirageESP(enabled)
    local locations = workspace:FindFirstChild("_WorldOrigin")
                   and workspace._WorldOrigin:FindFirstChild("Locations")
    if not locations then return end
    for _, v in ipairs(locations:GetChildren()) do
        pcall(function()
            if v.Name == "Mirage Island" then
                if enabled then
                    if not v:FindFirstChild("LotuxMirageESP") then
                        local bill = Instance.new("BillboardGui", v)
                        bill.Name          = "LotuxMirageESP"
                        bill.ExtentsOffset = Vector3.new(0, 1, 0)
                        bill.Size          = UDim2.new(1, 200, 1, 30)
                        bill.Adornee       = v
                        bill.AlwaysOnTop   = true
                        local lbl = Instance.new("TextLabel", bill)
                        lbl.TextSize           = 14
                        lbl.TextWrapped        = true
                        lbl.Size               = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.TextStrokeTransparency = 0.5
                        lbl.TextColor3         = Color3.fromRGB(80, 245, 245)
                    end
                    local dist = math.floor((Player.Character.Head.Position - v.Position).Magnitude / 3)
                    v.LotuxMirageESP.TextLabel.Text = "Mirage Island\n" .. dist .. "m"
                else
                    if v:FindFirstChild("LotuxMirageESP") then
                        v.LotuxMirageESP:Destroy()
                    end
                end
            end
        end)
    end
end

function Functions.UpdateSeaBeastESP(enabled)
    local folder = workspace:FindFirstChild("SeaBeasts")
    if not folder then return end
    for _, v in ipairs(folder:GetChildren()) do
        pcall(function()
            local hrp = v:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            if enabled then
                if not v:FindFirstChild("LotuxSeaESP") then
                    local bill = Instance.new("BillboardGui", v)
                    bill.Name          = "LotuxSeaESP"
                    bill.AlwaysOnTop   = true
                    bill.Size          = UDim2.new(0, 200, 0, 50)
                    bill.StudsOffset   = Vector3.new(0, 2.5, 0)
                    local lbl = Instance.new("TextLabel", bill)
                    lbl.BackgroundTransparency = 1
                    lbl.Size               = UDim2.new(0, 200, 0, 50)
                    lbl.Font               = Enum.Font.GothamBold
                    lbl.TextColor3         = Color3.fromRGB(7, 236, 240)
                    lbl.TextSize           = 16
                    lbl.TextWrapped        = true
                end
                local dist = math.floor((Player.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                v.LotuxSeaESP.TextLabel.Text = v.Name .. " — " .. dist .. "m"
            else
                if v:FindFirstChild("LotuxSeaESP") then
                    v.LotuxSeaESP:Destroy()
                end
            end
        end)
    end
end

function Functions.UpdateNpcESP(enabled)
    local folder = workspace:FindFirstChild("NPCs")
    if not folder then return end
    for _, v in ipairs(folder:GetChildren()) do
        pcall(function()
            local hrp = v:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            if enabled then
                if not v:FindFirstChild("LotuxNpcESP") then
                    local bill = Instance.new("BillboardGui", v)
                    bill.Name          = "LotuxNpcESP"
                    bill.AlwaysOnTop   = true
                    bill.Size          = UDim2.new(0, 200, 0, 50)
                    bill.StudsOffset   = Vector3.new(0, 2.5, 0)
                    local lbl = Instance.new("TextLabel", bill)
                    lbl.BackgroundTransparency = 1
                    lbl.Size               = UDim2.new(0, 200, 0, 50)
                    lbl.Font               = Enum.Font.GothamBold
                    lbl.TextColor3         = Color3.fromRGB(255, 220, 50)
                    lbl.TextSize           = 14
                    lbl.TextWrapped        = true
                end
                local dist = math.floor((Player.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                v.LotuxNpcESP.TextLabel.Text = v.Name .. " — " .. dist .. "m"
            else
                if v:FindFirstChild("LotuxNpcESP") then
                    v.LotuxNpcESP:Destroy()
                end
            end
        end)
    end
end

-- =====================================================
-- VISUAIS DO PERSONAGEM
-- =====================================================

function Functions.StartSelfHighlight()
    local folder = Instance.new("Folder")
    folder.Name   = "LotuxHighlight_Folder"
    folder.Parent = game.CoreGui

    local function applyHighlight(player)
        local hl = Instance.new("Highlight")
        hl.Name              = player.Name
        hl.FillColor         = Color3.fromRGB(255, 255, 255)
        hl.DepthMode         = Enum.HighlightDepthMode.AlwaysOnTop
        hl.FillTransparency  = 0.7
        hl.OutlineColor      = Color3.fromRGB(255, 255, 255)
        hl.Parent            = folder

        if player.Character then
            hl.Adornee = player.Character
        end
        player.CharacterAdded:Connect(function(char)
            hl.Adornee = char
        end)
    end

    applyHighlight(Player)
end

function Functions.StartAquaAura()
    task.delay(25, function()
        local function createAura(char)
            if not char then return end
            if char:FindFirstChild("LotuxAquaAura") then
                char.LotuxAquaAura:Destroy()
            end
            local aura = Instance.new("Highlight")
            aura.Name             = "LotuxAquaAura"
            aura.FillColor        = Color3.fromRGB(64, 224, 208)
            aura.OutlineColor     = Color3.fromRGB(64, 224, 208)
            aura.FillTransparency    = 1
            aura.OutlineTransparency = 1
            aura.Parent = char
        end

        local function onCharAdded(char)
            char:WaitForChild("HumanoidRootPart")
            task.wait(1)
            createAura(char)
            local humanoid  = char:WaitForChild("Humanoid")
            local aura      = char:FindFirstChild("LotuxAquaAura")
            local floatTime = 0
            RunService.RenderStepped:Connect(function(dt)
                if not humanoid or not aura then return end
                if humanoid.FloorMaterial == Enum.Material.Air then
                    floatTime = floatTime + dt
                    if floatTime >= 3 then
                        aura.FillTransparency    = 0.3
                        aura.OutlineTransparency = 0
                    end
                else
                    floatTime = 0
                    aura.FillTransparency    = 1
                    aura.OutlineTransparency = 1
                end
            end)
        end

        if Player.Character then onCharAdded(Player.Character) end
        Player.CharacterAdded:Connect(onCharAdded)
    end)
end

function Functions.StartRainbowSkills()
    local function rainbowSkill(obj)
        if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") then
            obj.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 0,   0)),
                ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 165, 0)),
                ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0,   255, 0)),
                ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0,   0,   255)),
                ColorSequenceKeypoint.new(1,   Color3.fromRGB(128, 0,   128)),
            })
        end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do rainbowSkill(obj) end
    workspace.DescendantAdded:Connect(rainbowSkill)
end

function Functions.StartRainbowBillboard(text)
    text = text or "Lotux Hub"

    local function createBillboard(character)
        if not character then return end
        local head = character:FindFirstChild("Head")
                  or character:FindFirstChildWhichIsA("BasePart")
        if not head then return end

        if head:FindFirstChild("Lotux_Label") then
            head.Lotux_Label:Destroy()
        end

        local billboard = Instance.new("BillboardGui")
        billboard.Name        = "Lotux_Label"
        billboard.Adornee     = head
        billboard.AlwaysOnTop = true
        billboard.Size        = UDim2.new(0, 200, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 1.8, 0)
        billboard.Parent      = head

        local label = Instance.new("TextLabel")
        label.Name                 = "Label"
        label.Size                 = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text                 = text
        label.Font                 = Enum.Font.SourceSansBold
        label.TextSize             = 14
        label.TextStrokeTransparency = 0.6
        label.TextTransparency     = 0
        label.TextScaled           = false
        label.Parent               = billboard

        local hue, conn = 0, nil
        conn = RunService.RenderStepped:Connect(function(dt)
            hue = (hue + dt * 1.0) % 1
            if label and label.Parent then
                label.TextColor3 = Color3.fromHSV(hue, 0.9, 1)
            else
                if conn then conn:Disconnect() end
            end
        end)
    end

    if Player.Character then createBillboard(Player.Character) end
    Player.CharacterAdded:Connect(function(c)
        task.wait(0.1)
        createBillboard(c)
    end)
end

function Functions.StartFPSCounter()
    local screenGui = Instance.new("ScreenGui")
    local label     = Instance.new("TextLabel")
    screenGui.Parent       = game.CoreGui
    screenGui.DisplayOrder = 100
    label.Parent = screenGui
    label.Size   = UDim2.new(0, 200, 0, 40)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.Font   = Enum.Font.FredokaOne
    label.TextScaled = false
    label.TextSize   = 20
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0

    local frameCount = 0
    local lastUpdate = tick()
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = tick()
        if now - lastUpdate >= 1 then
            label.Text = string.format("FPS: %d", math.floor(frameCount / (now - lastUpdate)))
            frameCount = 0
            lastUpdate = now
        end
    end)

    task.spawn(function()
        local hue = 0
        while true do
            hue = hue + 0.01
            if hue > 1 then hue = 0 end
            label.TextColor3 = Color3.fromHSV(hue, 1, 1)
            RunService.RenderStepped:Wait()
        end
    end)
end

-- =====================================================
-- QUEST HELPERS
-- =====================================================

function Functions.GetQuestForLevel(questList, currentSea, player)
    local level = 0
    pcall(function() level = player.Data.Level.Value end)
    local best = nil
    for _, q in ipairs(questList) do
        if q.Sea == currentSea and level >= q.Level then
            if not best or q.Level > best.Level then best = q end
        end
    end
    return best
end

function Functions.GetQuestGuiTitle(player)
    local title = ""
    pcall(function()
        title = player.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
    end)
    return title
end

function Functions.IsQuestVisible(player)
    local ok, result = pcall(function()
        return player.PlayerGui.Main.Quest.Visible
    end)
    return ok and result or false
end

function Functions.HasActiveQuest(player, mobName)
    local questGui = player.PlayerGui:FindFirstChild("Main")
                  and player.PlayerGui.Main:FindFirstChild("Quest")
    if not questGui or not questGui.Visible then return false end
    local title = ""
    pcall(function()
        title = player.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
    end)
    return string.find(title, mobName, 1, true) ~= nil
end

-- =====================================================
-- INVENTARIO / ITENS
-- =====================================================

function Functions.CheckItem(itemName)
    local ok, inventory = pcall(function()
        return CF("getInventory")
    end)
    if not ok or not inventory then return nil end
    for _, v in pairs(inventory) do
        if v.Name == itemName then
            return v
        end
    end
    return nil
end

function Functions.CheckItemInCharOrBackpack(name)
    local containers = { Player.Character, Player.Backpack }
    for _, cont in ipairs(containers) do
        if cont and cont:FindFirstChild(name) then
            return cont:FindFirstChild(name)
        end
    end
end

function Functions.StoreFruit()
    for _, v in pairs(Player.Backpack:GetChildren()) do
        if v:IsA("Tool") and string.find(v.Name, "Fruit") then
            pcall(function()
                CF(
                    "StoreFruit",
                    v:GetAttribute("OriginalName"),
                    v
                )
            end)
        end
    end
end

-- =====================================================
-- AUTO GET POLE (Thunder God - Sea 2)
-- =====================================================

function Functions.StartAutoGetPole(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoGetPole then continue end
            pcall(function()
                local Enemies = workspace:FindFirstChild("Enemies")
                if Enemies and Enemies:FindFirstChild("Thunder God") then
                    for _, v in pairs(Enemies:GetChildren()) do
                        if v.Name == "Thunder God" and v:FindFirstChild("Humanoid")
                        and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            Functions.AutoHaki()
                            Functions.EquipWeapon(config.SelectedWeaponName)
                            v.HumanoidRootPart.CanCollide = false
                            v.Humanoid.WalkSpeed = 0
                            v.HumanoidRootPart.Size = Vector3.new(80, 80, 80)
                            Functions.ToPos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0), config)
                            pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                        end
                    end
                else
                    local rs = game:GetService("ReplicatedStorage")
                    if rs:FindFirstChild("Thunder God") then
                        Functions.ToPos(rs:FindFirstChild("Thunder God").HumanoidRootPart.CFrame * CFrame.new(5, 10, 2), config)
                    end
                end
            end)
        end
    end)
end

-- =====================================================
-- AUTO GET SAW (The Saw - Sea 2)
-- =====================================================

function Functions.StartAutoGetSaw(config)
    local SawPos = CFrame.new(-690.33, 15.09, 1582.24)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoGetSaw then continue end
            pcall(function()
                local Enemies = workspace:FindFirstChild("Enemies")
                if Enemies and Enemies:FindFirstChild("The Saw") then
                    for _, v in pairs(Enemies:GetChildren()) do
                        if v.Name == "The Saw" and v:FindFirstChild("Humanoid")
                        and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            Functions.AutoHaki()
                            Functions.EquipWeapon(config.SelectedWeaponName)
                            v.HumanoidRootPart.CanCollide = false
                            v.Humanoid.WalkSpeed = 0
                            v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                            Functions.ToPos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0), config)
                        end
                    end
                else
                    local rs = game:GetService("ReplicatedStorage")
                    if rs:FindFirstChild("The Saw") then
                        Functions.ToPos(rs:FindFirstChild("The Saw").HumanoidRootPart.CFrame * CFrame.new(2, 40, 2), config)
                    else
                        Functions.ToPos(SawPos, config)
                    end
                end
            end)
        end
    end)
end

-- =====================================================
-- AUTO KILL GOLEM (Lava Golem - Prehistoric Island)
-- =====================================================

function Functions.StartAutoKillGolem(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoKillGolem then continue end
            pcall(function()
                local Enemies = workspace:FindFirstChild("Enemies")
                if Enemies and Enemies:FindFirstChild("Lava Golem") then
                    for _, v in pairs(Enemies:GetChildren()) do
                        if v.Name == "Lava Golem" and v:FindFirstChild("Humanoid")
                        and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            repeat
                                task.wait(0.1)
                                Functions.AutoHaki()
                                Functions.EquipWeapon(config.SelectedWeaponName)
                                v.HumanoidRootPart.CanCollide = false
                                v.Humanoid.WalkSpeed = 0
                                v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                Functions.ToPos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0), config)
                                pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                            until not config.AutoKillGolem or not v.Parent or v.Humanoid.Health <= 0
                        end
                    end
                else
                    local rs = game:GetService("ReplicatedStorage")
                    if rs:FindFirstChild("Lava Golem") then
                        Functions.ToPos(rs:FindFirstChild("Lava Golem").HumanoidRootPart.CFrame * CFrame.new(2, 20, 2), config)
                    end
                end
            end)
        end
    end)
end

-- =====================================================
-- AUTO KILL SHARK / PIRANHA / FISH CREW (Mar)
-- =====================================================

function Functions.StartAutoKillSeaCreatures(config)
    task.spawn(function()
        while task.wait(0.3) do
            pcall(function()
                local Enemies = workspace:FindFirstChild("Enemies")
                if not Enemies then return end
                local char = Player.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                for _, v in pairs(Enemies:GetChildren()) do
                    local isShark    = v.Name == "Shark" and config.AutoKillShark
                    local isPiranha  = v.Name == "Piranha" and config.AutoKillPiranha
                    local isFishCrew = v.Name == "Fish Crew Member" and config.AutoKillFishCrew
                    if (isShark or isPiranha or isFishCrew)
                    and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart")
                    and v.Humanoid.Health > 0 then
                        Functions.AutoHaki()
                        Functions.EquipWeapon(config.SelectedWeaponName)
                        v.HumanoidRootPart.CanCollide = false
                        v.Humanoid.WalkSpeed = 0
                        Functions.ToPos(v.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0), config)
                        pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                    end
                end
            end)
        end
    end)
end

-- =====================================================
-- AUTO FARM FRUITS (Farm com Frutas / Mastery)
-- =====================================================

function Functions.StartAutoFarmFruits(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoFarmFruits then continue end
            pcall(function()
                local Enemies = workspace:FindFirstChild("Enemies")
                if not Enemies then return end
                local char = Player.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                for _, v in pairs(Enemies:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart")
                    and v.Humanoid.Health > 0 then
                        repeat
                            task.wait(0.1)
                            pcall(function()
                                Functions.AutoHaki()
                                Functions.EquipWeapon(config.SelectedWeaponName)
                                v.HumanoidRootPart.CanCollide = false
                                v.Humanoid.WalkSpeed = 0
                                Functions.ToPos(v.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0), config)
                                pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                            end)
                        until not config.AutoFarmFruits or not v.Parent or v.Humanoid.Health <= 0
                        break
                    end
                end
            end)
        end
    end)
end

-- =====================================================
-- AUTO PRAY (Altar/Shrine)
-- =====================================================


-- =====================================================
-- AUTO TRY LUCK
-- =====================================================


-- =====================================================
-- AUTO TRADE BONE
-- =====================================================


-- =====================================================
-- AIMBOT GUN
-- =====================================================

function Functions.StartAimbotGun(config)
    task.spawn(function()
        while task.wait(0.05) do
            if not config.AimbotGun then continue end
            pcall(function()
                local char = Player.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                local nearestEnemy = Functions.GetNearestEnemy(char, hrp)
                if not nearestEnemy then return end
                local enemyHrp = nearestEnemy:FindFirstChild("HumanoidRootPart")
                if not enemyHrp then return end

                local gun = Player.Character:FindFirstChildWhichIsA("Tool")
                if gun and gun.ToolTip == "Gun" then
                    workspace.CurrentCamera.CFrame = CFrame.new(
                        workspace.CurrentCamera.CFrame.Position,
                        enemyHrp.Position
                    )
                end
            end)
        end
    end)
end

-- =====================================================
-- AIMBOT SKILL
-- =====================================================

function Functions.StartAimbotSkill(config)
    task.spawn(function()
        while task.wait(0.05) do
            if not config.AimbotSkill then continue end
            pcall(function()
                local char = Player.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                local nearestEnemy = Functions.GetNearestEnemy(char, hrp)
                if not nearestEnemy then return end
                local enemyHrp = nearestEnemy:FindFirstChild("HumanoidRootPart")
                if not enemyHrp then return end

                workspace.CurrentCamera.CFrame = CFrame.new(
                    workspace.CurrentCamera.CFrame.Position,
                    enemyHrp.Position
                )
            end)
        end
    end)
end

-- =====================================================
-- INICIALIZAR TODOS OS LOOPS
-- =====================================================

function Functions.StartAllLoops(config)
    -- Race
    Functions.StartAutoRace(config)
    Functions.StartAutoDooHee(config)
    Functions.StartAutoQuestRace(config)

    -- Sea 3 - Quest/Items
    Functions.StartAutoBartilo(config)
    Functions.StartAutoEliteHunter(config)
    Functions.StartAutoYama(config)
    Functions.StartAutoHolyTorch(config)
    Functions.StartAutoGetTushita(config)
    Functions.StartAutoRengoku(config)

    -- Sea 3 - Bosses
    Functions.StartAutoSoulReaper(config)
    Functions.StartAutoTyrantSpawn(config)
    Functions.StartAutoCakePrince(config)
    Functions.StartAutoDoughKing(config)
    Functions.StartAutoRipIndra(config)
    Functions.StartAutoBigMom(config)
    Functions.StartAutoFarmBone(config)
    Functions.StartAutoPirateRaid(config)
    Functions.StartAutoFarmChocola(config)

    -- Sea 3 - Especiais
    Functions.StartAutoGodHuman(config)
    Functions.StartAutoDragonTaylor(config)
    Functions.StartAutoElectricClaw(config)
    Functions.StartAutoMysticIsland(config)
    Functions.StartTweenToKitsune(config)
    Functions.StartTweenMGear(config)
    Functions.StartAutoEmber(config)
    Functions.StartAutoHydraTree(config)
    Functions.StartAutoMobDragon(config)
    Functions.StartAutoCollectBone(config)
    Functions.StartAutoCollectEgg(config)
    Functions.StartDefendVolcano(config)
    Functions.StartTweenVolcano(config)
    Functions.StartAutoFindPrehistoric(config)

    -- Sea 3 - Navegacao
    Functions.StartSailBoat(config)
    Functions.StartAutoTerrorshark(config)

    -- Sea 2
    Functions.StartAutoFactory(config)
    Functions.StartAutoRaidLaw(config)
    Functions.StartAutoDarkBeard(config)
    Functions.StartAutoGrayBeard(config)
    Functions.StartAutoSharkmanV2(config)
    Functions.StartAutoDeathStep(config)
    Functions.StartAutoSea3(config)

    -- Sea 1/2
    Functions.StartAutoBuyTTK(config)
    Functions.StartAutoDarkBladeV2(config)
    Functions.StartAutoSea2(config)
    Functions.StartAutoHakiV2(config)
    Functions.StartAutoUnlockTemple(config)

    -- Frutas
    Functions.StartAutoStoreFruit(config)
    Functions.StartTweenFruit(config)
    Functions.StartGrabFruit(config)
    Functions.StartAutoFruit(config)

    -- Extras
    Functions.StartAutoBarista(config)
    Functions.StartAutoFarmObsHaki(config)
    Functions.StartFarmChest(config)
    Functions.StartAutoDungeon(config)
    Functions.StartAutoSkill(config)
    Functions.StartAutoBuyEnhancement(config)
    Functions.StartAutoBuyLegendarySword(config)
    Functions.StartAutoPray(config)
    Functions.StartAutoTryLuck(config)
    Functions.StartAutoTradeBone(config)

    -- PvP
    Functions.StartKillAura(config)
    Functions.StartAutoPlayerHunter(config)
    Functions.StartAimbotGun(config)
    Functions.StartAimbotSkill(config)

    -- Sea Creatures
    Functions.StartAutoKillSeaCreatures(config)

    -- Volcanic Extra
    Functions.StartAutoKillGolem(config)

    -- Sea 2 Espadas Extras
    Functions.StartAutoGetPole(config)
    Functions.StartAutoGetSaw(config)

    -- Frutas (Raid + Tween + Grab + Load)
    Functions.StartAutoLoadFruitCheap(config)
    Functions.StartTweenFruit(config)
    Functions.StartGrabFruit(config)
    Functions.StartAutoAwakenAbilities(config)

    -- Frutas Farm
    Functions.StartAutoFarmFruits(config)

    -- Extras Misc
    Functions.StartAutoPray(config)
    Functions.StartAutoTryLuck(config)
    Functions.StartAutoTradeBone(config)

    -- Player
    Functions.StartSafeMode(config)

    -- Notificacoes
    Functions.StartDisableGameNotify(config)
end


-- =====================================================
-- FUNCOES ADICIONAIS (novas, nao duplicadas)
-- =====================================================

function Functions.CheckRace()
    local raceValue = Player:FindFirstChild("Data") and Player.Data:FindFirstChild("Race")
    if raceValue then
        return raceValue.Value
    end
    return "Human"
end

-- CheckItemBPCR - Verifica item no character ou backpack
function Functions.CheckItemBPCR(name)
    local itemLocs = {Player.Character, Player.Backpack}
    for i, v in pairs(itemLocs) do
        if v:FindFirstChild(name) then
            return v:FindFirstChild(name)
        end
    end
    return nil
end

function Functions.Tween23(targetCFrame)
    Functions.FlyToPosition(targetCFrame, TweenService, {FlySpeed = 300}, {value = false}, {value = false})
end

-- CancelTween23 - Cancelar tween (compatibilidade)
function Functions.CancelTween23()
    -- Pode ser implementado com StopAllTweens se necessario
end

-- BringPos global para compatibilidade
_G.BringPos = CFrame.new(0, 0, 0)

-- BringMob - Trazer mobs para perto
function Functions.BringMobFunc(mob, targetCFrame)
    if not mob or not mob.Parent then return end
    
    local mobHrp = mob:FindFirstChild("HumanoidRootPart")
    if mobHrp then
        mobHrp.CFrame = targetCFrame
    end
end

-- ActivateBuso - Ativar Haki Busoushoku
function Functions.ActivateObservation(commF)
    if not commF then return end
    
    pcall(function()
        commF:InvokeServer("Observation")
    end)
end

-- RedeemCode - Resgatar um codigo
function Functions.RedeemCode(code)
    pcall(function()
        CF("RedeemCode", code)
    end)
end

-- RedeemAllCodes - Resgatar todos os codigos conhecidos
function Functions.StartAutoCollectBerry(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoCollectBerry then continue end
            
            pcall(function()
                local berry = workspace:FindFirstChild("Berry", true)
                if berry then
                    local handle = berry:FindFirstChild("Handle")
                    if handle then
                        local char = Player.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.CFrame = handle.CFrame
                        end
                    end
                end
            end)
        end
    end)
end

-- StartAutoBarista - Farm cores de Haki com NPC Barista
function Functions.StartAutoKillShark(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoKillShark then continue end
            
            pcall(function()
                local shark = workspace:FindFirstChild("Shark", true)
                if shark and shark:FindFirstChildOfClass("Humanoid") then
                    Functions.FastAttack(shark, config)
                end
            end)
        end
    end)
end

-- StartAutoKillPiranha - Matar Piranhas
function Functions.StartAutoKillPiranha(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoKillPiranha then continue end
            
            pcall(function()
                local piranha = workspace:FindFirstChild("Piranha", true)
                if piranha and piranha:FindFirstChildOfClass("Humanoid") then
                    Functions.FastAttack(piranha, config)
                end
            end)
        end
    end)
end

-- StartAutoKillFishCrew - Matar Fish Crew
function Functions.StartAutoKillFishCrew(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoKillFishCrew then continue end
            
            pcall(function()
                local fishCrew = workspace:FindFirstChild("Fish Crew", true)
                if fishCrew and fishCrew:FindFirstChildOfClass("Humanoid") then
                    Functions.FastAttack(fishCrew, config)
                end
            end)
        end
    end)
end

-- =====================================================
-- FUNCOES AVANCADAS DO TIROREAL - PARTE 2
-- =====================================================

-- StartAutoDungeon - Farm no Dungeon atacando inimigos
function Functions.StartAutoEliteHunterHop(config)
    task.spawn(function()
        while task.wait(5) do
            if not config.AutoEliteHunterHop then continue end
            
            pcall(function()
                local enemies = workspace:FindFirstChild("Enemies")
                local hasElite = false
                
                if enemies then
                    for _, enemy in ipairs(enemies:GetChildren()) do
                        if string.find(enemy.Name, "Elite") then
                            hasElite = true
                            break
                        end
                    end
                end
                
                if not hasElite then
                    -- Hop para outro servidor
                    Functions.Hop()
                end
            end)
        end
    end)
end

-- StartAutoFarmObsHaki - Farm Observation Haki mastery
function Functions.StartAutoTweenToKitsune(config)
    task.spawn(function()
        while task.wait(1) do
            if not config.TweenToKitsune then continue end
            
            pcall(function()
                local kitsune = workspace:FindFirstChild("Kitsune Island", true)
                if kitsune then
                    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local islandPos = kitsune:IsA("Model") and kitsune:GetPivot() or kitsune.CFrame
                        Functions.FlyToPosition(islandPos + Vector3.new(0, 10, 0), TweenService, config, {value = false}, {value = false})
                    end
                end
            end)
        end
    end)
end

-- StartAutoAwakeningFruit - Auto despertar frutas
function Functions.StartAutoAwakeningFruit(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoAwakenAbilities then continue end
            
            pcall(function()
                CF("Awakener", "Awaken")
            end)
        end
    end)
end

-- StartAutoLoadFruit - Carregar frutas baratas automaticamente
function Functions.StartAutoLoadFruit(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoFruit then continue end
            
            pcall(function()
                -- Lista de frutas baratas para farm
                local cheapFruits = {
                    "Rocket-Rocket",
                    "Spin-Spin",
                    "Chop-Chop",
                    "Spring-Spring",
                    "Bomb-Bomb",
                    "Smoke-Smoke",
                    "Spike-Spike",
                    "Flame-Flame",
                    "Falcon-Falcon",
                }
                
                for _, fruit in ipairs(cheapFruits) do
                    pcall(function()
                        CF("LoadFruit", fruit)
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end)
end

-- GetNextIsland - Pega proxima ilha do raid
function Functions.GetNextIsland()
    local islands = {5, 4, 3, 2, 1}
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    
    if not hrp then return nil end
    
    for _, islandNum in ipairs(islands) do
        local islandFolder = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Locations")
        if islandFolder then
            for _, location in ipairs(islandFolder:GetChildren()) do
                if string.find(location.Name, "Island") then
                    local dist = (location.Position - hrp.Position).Magnitude
                    if dist <= 4500 then
                        return location
                    end
                end
            end
        end
    end
    
    return nil
end

-- AttackNearbyEnemies - Ataca todos inimigos proximos (Dungeon)
function Functions.AttackNearbyEnemies(config)
    local enemies = {}
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    
    if not enemiesFolder or not hrp then return end
    
    for _, enemy in ipairs(enemiesFolder:GetChildren()) do
        if enemy:IsA("Model") then
            local eHrp = enemy:FindFirstChild("HumanoidRootPart")
            local eHum = enemy:FindFirstChildOfClass("Humanoid")
            
            if eHrp and eHum and eHum.Health > 0 then
                local dist = (eHrp.Position - hrp.Position).Magnitude
                if dist <= 1000 then
                    table.insert(enemies, enemy)
                end
            end
        end
    end
    
    for _, enemy in ipairs(enemies) do
        Functions.FastAttack(enemy, config)
        task.wait(0.1)
    end
end

-- DetectMob - Detecta mob pelo nome
function Functions.DetectMob(mobName)
    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, enemy in ipairs(enemies:GetChildren()) do
            if string.find(enemy.Name, mobName) then
                return enemy
            end
        end
    end
    return nil
end

-- DetectMob2 - Versao alternativa de DetectMob
function Functions.DetectMob2(mobName)
    return Functions.DetectMob(mobName)
end

-- GetLocalBoat - Pega barco do jogador pelo Owner no workspace.Boats
-- Identico ao Tiroreal (verifica Humanoid.Value > 0)
function Functions.GetLocalBoat()
    local boats = workspace:FindFirstChild("Boats")
    if not boats then return false end
    for _, v in next, boats:GetChildren() do
        if v:IsA("Model") then
            if v:FindFirstChild("Owner") and tostring(v.Owner.Value) == Player.Name then
                local hum = v:FindFirstChild("Humanoid")
                if hum and hum.Value > 0 then
                    return v
                end
            end
        end
    end
    return false
end

-- GetPlayerBoat - Pega barco onde o player esta sentado (pelo VehicleSeat)
-- Identico ao Tiroreal
function Functions.GetPlayerBoat()
    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
            return hum.SeatPart.Parent
        end
    end
    return nil
end

-- MoveBoat - Move o barco em direcao com Tween (logica do Tiroreal)
local _boatMovementConnection = nil
function Functions.MoveBoat(direction, distance, speed)
    local boat = Functions.GetPlayerBoat()
    if boat and boat.PrimaryPart then
        local boatPrimaryPart = boat.PrimaryPart
        local targetPosition  = boatPrimaryPart.Position + (direction * distance)
        targetPosition = Vector3.new(targetPosition.X, targetPosition.Y + 200, targetPosition.Z)
        local dist2    = (boatPrimaryPart.Position - targetPosition).Magnitude
        local tweenInfo = TweenInfo.new(dist2 / speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(boatPrimaryPart, tweenInfo, {CFrame = CFrame.new(targetPosition)})
        tween:Play()
    end
end

-- StartBoatMovement / StopBoatMovement (identicos ao Tiroreal)
function Functions.StartBoatMovement(config)
    Functions.StopBoatMovement()
    _boatMovementConnection = RunService.Heartbeat:Connect(function()
        local direction = Vector3.new(0, 0, 1000)
        local distance  = 500
        local speed     = 186
        Functions.MoveBoat(direction, distance, speed)
    end)
end

function Functions.StopBoatMovement()
    if _boatMovementConnection then
        _boatMovementConnection:Disconnect()
        _boatMovementConnection = nil
    end
end

-- WaitHRP - Aguarda HumanoidRootPart do player (identico ao Tiroreal)
function Functions.WaitHRP(plr)
    if not plr then return end
    return plr.Character:WaitForChild("HumanoidRootPart", 9)
end

-- isnil - Verifica se objeto eh nulo/destruido com pcall (identico ao Tiroreal)
function Functions.isnil(thing)
    return not pcall(function() return thing.Parent end)
end

-- attackNearbyEnemies - Ataca inimigos proximos (logica do Tiroreal)
function Functions.attackNearbyEnemies(config, range)
    range = range or 20
    local char = Player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return end
    for _, mob in pairs(enemies:GetChildren()) do
        pcall(function()
            local mobHrp = mob:FindFirstChild("HumanoidRootPart")
            local mobHum = mob:FindFirstChild("Humanoid")
            if mobHrp and mobHum and mobHum.Health > 0 then
                local dist = (mobHrp.Position - hrp.Position).Magnitude
                if dist <= range then
                    Functions.EquipWeapon(config.SelectedWeaponName)
                    local remote = ReplicatedStorage.Remotes:FindFirstChild("CommF_")
                    if remote then
                        remote:InvokeServer("UpdateNPCHealth", mob, 1)
                    end
                end
            end
        end)
    end
end

-- targettrial - Completa trial/arena atacando mobs proximos
function Functions.targettrial(config)
    local char = Player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return end
    for _, mob in pairs(enemies:GetChildren()) do
        pcall(function()
            local mobHrp = mob:FindFirstChild("HumanoidRootPart")
            local mobHum = mob:FindFirstChild("Humanoid")
            if mobHrp and mobHum and mobHum.Health > 0 then
                Functions.EquipWeapon(config.SelectedWeaponName)
                hrp.CFrame = mobHrp.CFrame * CFrame.new(0, 0, 3)
            end
        end)
    end
end

-- CheckPirateBoat - Verifica se existe barco pirata no mapa
function Functions.CheckPirateBoat()
    local boats = workspace:FindFirstChild("Boats")
    if not boats then return false end
    for _, v in pairs(boats:GetChildren()) do
        if v:IsA("Model") and v.Name:lower():find("pirate") then
            return true
        end
    end
    return false
end

-- TpEntrance - Teleporta para entrada de dungeon/portal (identico ao Tiroreal)
function Functions.TpEntrance(pos)
    local char = Player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = pos
end

-- UpdateTime - Atualiza label de tempo na UI (placeholder para compatibilidade)
function Functions.UpdateTime(label)
    if not label then return end
    local elapsed = os.time() - (Functions._startTime or os.time())
    local h = math.floor(elapsed / 3600)
    local m = math.floor((elapsed % 3600) / 60)
    local s = elapsed % 60
    pcall(function()
        label:Set(string.format("%02d:%02d:%02d", h, m, s))
    end)
end

-- UpdateClient / UpdateClient1 - Atualiza labels de status (placeholder)
function Functions.UpdateClient(label, text)
    pcall(function()
        if label then label:Set(tostring(text)) end
    end)
end

function Functions.UpdateClient1(label, text)
    Functions.UpdateClient(label, text)
end

-- InfAb - Activa Awakening/AbilityBar infinitamente via remote
function Functions.InfAb()
    local remote = ReplicatedStorage.Remotes:FindFirstChild("CommF_")
    if remote then
        pcall(function()
            remote:InvokeServer("ActivateAbility")
        end)
    end
end

-- =====================================================
-- FUNÇÕES FALTANTES DO TIROREAL
-- =====================================================

-- 1. CHECK QUEST (determina quest baseada no nível/mundo)
local function CheckQuest()
    local MyLevel = Player.Data.Level.Value
    local SelectMonster = _G.SelectMonster or ""
    local World1 = (CurrentSea == 1)
    local World2 = (CurrentSea == 2)
    local World3 = (CurrentSea == 3)

    if World1 then
        if (MyLevel >= 1 and MyLevel <= 9) or SelectMonster == "Bandit" then
            Mon = "Bandit"
            LevelQuest = 1
            NameQuest = "BanditQuest1"
            NameMon = "Bandit"
            CFrameQuest = CFrame.new(1059.37195, 15.4495068, 1550.4231, 0.939700544, -0, -0.341998369, 0, 1, -0, 0.341998369, 0, 0.939700544)
            CFrameMon = CFrame.new(1045.962646484375, 27.00250816345215, 1560.8203125)
        elseif (MyLevel >= 10 and MyLevel <= 14) or SelectMonster == "Monkey" then
            Mon = "Monkey"
            LevelQuest = 1
            NameQuest = "JungleQuest"
            NameMon = "Monkey"
            CFrameQuest = CFrame.new(-1598.08911, 35.5501175, 153.377838, 0, 0, 1, 0, 1, -0, -1, 0, 0)
            CFrameMon = CFrame.new(-1448.51806640625, 67.85301208496094, 11.46579647064209)
        elseif (MyLevel >= 15 and MyLevel <= 29) or SelectMonster == "Gorilla" then
            Mon = "Gorilla"
            LevelQuest = 2
            NameQuest = "JungleQuest"
            NameMon = "Gorilla"
            CFrameQuest = CFrame.new(-1598.08911, 35.5501175, 153.377838, 0, 0, 1, 0, 1, -0, -1, 0, 0)
            CFrameMon = CFrame.new(-1129.8836669921875, 40.46354675292969, -525.4237060546875)
        elseif (MyLevel >= 30 and MyLevel <= 39) or SelectMonster == "Pirate" then
            Mon = "Pirate"
            LevelQuest = 1
            NameQuest = "BuggyQuest1"
            NameMon = "Pirate"
            CFrameQuest = CFrame.new(-1141.07483, 4.10001802, 3831.5498, 0.965929627, -0, -0.258804798, 0, 1, -0, 0.258804798, 0, 0.965929627)
            CFrameMon = CFrame.new(-1103.513427734375, 13.752052307128906, 3896.091064453125)
        elseif (MyLevel >= 40 and MyLevel <= 59) or SelectMonster == "Brute" then
            Mon = "Brute"
            LevelQuest = 2
            NameQuest = "BuggyQuest1"
            NameMon = "Brute"
            CFrameQuest = CFrame.new(-1141.07483, 4.10001802, 3831.5498, 0.965929627, -0, -0.258804798, 0, 1, -0, 0.258804798, 0, 0.965929627)
            CFrameMon = CFrame.new(-1140.083740234375, 14.809885025024414, 4322.92138671875)
        elseif (MyLevel >= 60 and MyLevel <= 74) or SelectMonster == "Desert Bandit" then
            Mon = "Desert Bandit"
            LevelQuest = 1
            NameQuest = "DesertQuest"
            NameMon = "Desert Bandit"
            CFrameQuest = CFrame.new(894.488647, 5.14000702, 4392.43359, 0.819155693, -0, -0.573571265, 0, 1, -0, 0.573571265, 0, 0.819155693)
            CFrameMon = CFrame.new(924.7998046875, 6.44867467880249, 4481.5859375)
        elseif (MyLevel >= 75 and MyLevel <= 89) or SelectMonster == "Desert Officer" then
            Mon = "Desert Officer"
            LevelQuest = 2
            NameQuest = "DesertQuest"
            NameMon = "Desert Officer"
            CFrameQuest = CFrame.new(894.488647, 5.14000702, 4392.43359, 0.819155693, -0, -0.573571265, 0, 1, -0, 0.573571265, 0, 0.819155693)
            CFrameMon = CFrame.new(1608.2822265625, 8.614224433898926, 4371.00732421875)
        elseif (MyLevel >= 90 and MyLevel <= 99) or SelectMonster == "Snow Bandit" then
            Mon = "Snow Bandit"
            LevelQuest = 1
            NameQuest = "SnowQuest"
            NameMon = "Snow Bandit"
            CFrameQuest = CFrame.new(1389.74451, 88.1519318, -1298.90796, -0.342042685, 0, 0.939684391, 0, 1, 0, -0.939684391, 0, -0.342042685)
            CFrameMon = CFrame.new(1354.347900390625, 87.27277374267578, -1393.946533203125)
        elseif (MyLevel >= 100 and MyLevel <= 119) or SelectMonster == "Snowman" then
            Mon = "Snowman"
            LevelQuest = 2
            NameQuest = "SnowQuest"
            NameMon = "Snowman"
            CFrameQuest = CFrame.new(1389.74451, 88.1519318, -1298.90796, -0.342042685, 0, 0.939684391, 0, 1, 0, -0.939684391, 0, -0.342042685)
            CFrameMon = CFrame.new(1201.6412353515625, 144.57958984375, -1550.0670166015625)
        elseif (MyLevel >= 120 and MyLevel <= 149) or SelectMonster == "Chief Petty Officer" then
            Mon = "Chief Petty Officer"
            LevelQuest = 1
            NameQuest = "MarineQuest2"
            NameMon = "Chief Petty Officer"
            CFrameQuest = CFrame.new(-5039.58643, 27.3500385, 4324.68018, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            CFrameMon = CFrame.new(-4881.23095703125, 22.65204429626465, 4273.75244140625)
        elseif (MyLevel >= 150 and MyLevel <= 174) or SelectMonster == "Sky Bandit" then
            Mon = "Sky Bandit"
            LevelQuest = 1
            NameQuest = "SkyQuest"
            NameMon = "Sky Bandit"
            CFrameQuest = CFrame.new(-4839.53027, 716.368591, -2619.44165, 0.866007268, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, 0.866007268)
            CFrameMon = CFrame.new(-4953.20703125, 295.74420166015625, -2899.22900390625)
        elseif (MyLevel >= 175 and MyLevel <= 189) or SelectMonster == "Dark Master" then
            Mon = "Dark Master"
            LevelQuest = 2
            NameQuest = "SkyQuest"
            NameMon = "Dark Master"
            CFrameQuest = CFrame.new(-4839.53027, 716.368591, -2619.44165, 0.866007268, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, 0.866007268)
            CFrameMon = CFrame.new(-5259.8447265625, 391.3976745605469, -2229.035400390625)
        elseif (MyLevel >= 190 and MyLevel <= 209) or SelectMonster == "Prisoner" then
            Mon = "Prisoner"
            LevelQuest = 1
            NameQuest = "PrisonerQuest"
            NameMon = "Prisoner"
            CFrameQuest = CFrame.new(5308.93115, 1.65517521, 475.120514, -0.0894274712, -5.00292918e-09, -0.995993316, 1.60817859e-09, 1, -5.16744869e-09, 0.995993316, -2.06384709e-09, -0.0894274712)
            CFrameMon = CFrame.new(5098.9736328125, -0.3204058110713959, 474.2373352050781)
        elseif (MyLevel >= 210 and MyLevel <= 249) or SelectMonster == "Dangerous Prisone" then
            Mon = "Dangerous Prisoner"
            LevelQuest = 2
            NameQuest = "PrisonerQuest"
            NameMon = "Dangerous Prisoner"
            CFrameQuest = CFrame.new(5308.93115, 1.65517521, 475.120514, -0.0894274712, -5.00292918e-09, -0.995993316, 1.60817859e-09, 1, -5.16744869e-09, 0.995993316, -2.06384709e-09, -0.0894274712)
            CFrameMon = CFrame.new(5654.5634765625, 15.633401870727539, 866.2991943359375)
        -- ... (continue com todas as faixas do Tiroreal)
        else
            -- fallback
            Mon = "Bandit"
            LevelQuest = 1
            NameQuest = "BanditQuest1"
            NameMon = "Bandit"
            CFrameQuest = CFrame.new(1059.37195, 15.4495068, 1550.4231)
            CFrameMon = CFrame.new(1045.962646484375, 27.00250816345215, 1560.8203125)
        end
    elseif World2 then
        -- Adicione aqui as quests do Sea 2 (baseado no Tiroreal)
        if (MyLevel >= 700 and MyLevel <= 724) or SelectMonster == "Raider" then
            Mon = "Raider"
            LevelQuest = 1
            NameQuest = "Area1Quest"
            NameMon = "Raider"
            CFrameQuest = CFrame.new(-429.543518, 71.7699966, 1836.18188, -0.22495985, 0, -0.974368095, 0, 1, 0, 0.974368095, 0, -0.22495985)
            CFrameMon = CFrame.new(-728.3267211914062, 52.779319763183594, 2345.7705078125)
        elseif (MyLevel >= 725 and MyLevel <= 774) or SelectMonster == "Mercenary" then
            Mon = "Mercenary"
            LevelQuest = 2
            NameQuest = "Area1Quest"
            NameMon = "Mercenary"
            CFrameQuest = CFrame.new(-429.543518, 71.7699966, 1836.18188, -0.22495985, 0, -0.974368095, 0, 1, 0, 0.974368095, 0, -0.22495985)
            CFrameMon = CFrame.new(-1004.3244018554688, 80.15886688232422, 1424.619384765625)
        else
            Mon = "Raider"
            LevelQuest = 1
            NameQuest = "Area1Quest"
            NameMon = "Raider"
            CFrameQuest = CFrame.new(-429.543518, 71.7699966, 1836.18188)
            CFrameMon = CFrame.new(-728.3267211914062, 52.779319763183594, 2345.7705078125)
        end
    elseif World3 then
        -- Adicione aqui as quests do Sea 3 (baseado no Tiroreal)
        if (MyLevel >= 1500 and MyLevel <= 1524) or SelectMonster == "Pirate Millionaire" then
            Mon = "Pirate Millionaire"
            LevelQuest = 1
            NameQuest = "PiratePortQuest"
            NameMon = "Pirate Millionaire"
            CFrameQuest = CFrame.new(-450.104645, 107.681458, 5950.72607, 0.957107544, -0, -0.289732844, 0, 1, -0, 0.289732844, 0, 0.957107544)
            CFrameMon = CFrame.new(-245.9963836669922, 47.30615234375, 5584.1005859375)
        else
            Mon = "Pirate Millionaire"
            LevelQuest = 1
            NameQuest = "PiratePortQuest"
            NameMon = "Pirate Millionaire"
            CFrameQuest = CFrame.new(-450.104645, 107.681458, 5950.72607)
            CFrameMon = CFrame.new(-245.9963836669922, 47.30615234375, 5584.1005859375)
        end
    end
end

-- 2. MATERIAL MON (define mob/posição para farm de material)
local function MaterialMon()
    if _G.SelectMaterial == "Radiactive Material" then
        MMon = "Factory Staff"
        MPos = CFrame.new(-105.889565, 72.8076935, -670.247986, -0.965929747, 0, -0.258804798, 0, 1, 0, 0.258804798, 0, -0.965929747)
        SP = "Bar"
    elseif _G.SelectMaterial == "Leather + Scrap Metal" then
        if game.PlaceId == 2753915549 then
            MMon = "Pirate"
            MPos = CFrame.new(-967.433105, 13.5999937, 4034.24707, -0.258864403, 0, -0.965913713, 0, 1, 0, 0.965913713, 0, -0.258864403)
            SP = "Pirate"
            MMon = "Brute"
            MPos = CFrame.new(-1191.41235, 15.5999985, 4235.50928, 0.629286051, -0, -0.777173758, 0, 1, -0, 0.777173758, 0, 0.629286051)
            SP = "Pirate"
        elseif game.PlaceId == 4442272183 then
            MMon = "Mercenary"
            MPos = CFrame.new(-986.774475, 72.8755951, 1088.44653, -0.656062722, 0, 0.754706323, 0, 1, 0, -0.754706323, 0, -0.656062722)
            SP = "DressTown"
        elseif game.PlaceId == 7449423635 then
            MMon = "Pirate Millionaire"
            MPos = CFrame.new(-118.809372, 55.4874573, 5649.17041, -0.965929747, 0, 0.258804798, 0, 1, 0, -0.258804798, 0, -0.965929747)
            SP = "Default"
        end
    elseif _G.SelectMaterial == "Magma Ore" then
        if game.PlaceId == 2753915549 then
            MMon = "Military Soldier"
            MPos = CFrame.new(-5565.60156, 9.10001755, 8327.56934, -0.838688731, 0, -0.544611216, 0, 1, 0, 0.544611216, 0, -0.838688731)
            SP = "Magma"
            MMon = "Military Spy"
            MPos = CFrame.new(-5806.70068, 78.5000458, 8904.46973, 0.707134247, 0, 0.707079291, 0, 1, 0, -0.707079291, 0, 0.707134247)
            SP = "Magma"
        elseif game.PlaceId == 4442272183 then
            MMon = "Lava Pirate"
            MPos = CFrame.new(-5158.77051, 14.4791956, -4654.2627, -0.848060489, 0, -0.529899538, 0, 1, 0, 0.529899538, 0, -0.848060489)
            SP = "CircleIslandFire"
        end
    elseif _G.SelectMaterial == "Fish Tail" then
        if game.PlaceId == 2753915549 then
            MMon = "Fishman Warrior"
            MPos = CFrame.new(60943.9023, 17.9492188, 1744.11133, 0.826706648, -0, -0.562633216, 0, 1, -0, 0.562633216, 0, 0.826706648)
            SP = "Underwater City"
            MMon = "Fishman Commando"
            MPos = CFrame.new(61760.8984, 18.0800781, 1460.11133, -0.632549644, 0, -0.774520278, 0, 1, 0, 0.774520278, 0, -0.632549644)
            SP = "Underwater City"
        elseif game.PlaceId == 7449423635 then
            MMon = "Fishman Captain"
            MPos = CFrame.new(-10828.1064, 331.825989, -9049.14648, -0.0912091732, 0, 0.995831788, 0, 1, 0, -0.995831788, 0, -0.0912091732)
            SP = "PineappleTown"
        end
    elseif _G.SelectMaterial == "Angel Wings" then
        MMon = "Royal Soldier"
        MPos = CFrame.new(-7759.45898, 5606.93652, -1862.70276, -0.866007447, 0, -0.500031412, 0, 1, 0, 0.500031412, 0, -0.866007447)
        SP = "SkyArea2"
    elseif _G.SelectMaterial == "Mystic Droplet" then
        MMon = "Water Fighter"
        MPos = CFrame.new(-3331.70459, 239.138336, -10553.3564, -0.29242146, 0, 0.95628953, 0, 1, 0, -0.95628953, 0, -0.29242146)
        SP = "ForgottenIsland"
    elseif _G.SelectMaterial == "Vampire Fang" then
        MMon = "Vampire"
        MPos = CFrame.new(-6132.39453, 9.00769424, -1466.16919, -0.927179813, 0, -0.374617696, 0, 1, 0, 0.374617696, 0, -0.927179813)
        SP = "Graveyard"
    elseif _G.SelectMaterial == "Gunpowder" then
        MMon = "Pistol Billionaire"
        MPos = CFrame.new(-185.693283, 84.7088699, 6103.62744, 0.90629667, -0, -0.422642082, 0, 1, -0, 0.422642082, 0, 0.90629667)
        SP = "Mansion"
    elseif _G.SelectMaterial == "Mini Tusk" then
        MMon = "Mythological Pirate"
        MPos = CFrame.new(-13456.0498, 469.433228, -7039.96436, 0, 0, 1, 0, 1, -0, -1, 0, 0)
        SP = "BigMansion"
    elseif _G.SelectMaterial == "Conjured Cocoa" then
        MMon = "Chocolate Bar Battler"
        MPos = CFrame.new(582.828674, 25.5824986, -12550.7041, -0.766061664, 0, -0.642767608, 0, 1, 0, 0.642767608, 0, -0.766061664)
        SP = "Chocolate"
    end
end

-- 3. ESP FLOWER (flores azuis/vermelhas)
function Functions.UpdateFlowerChams()
    local Number = _G.FlowerESPNumber or math.random(1, 1000000)
    for _, v in pairs(workspace:GetChildren()) do
        if v.Name == "Flower2" or v.Name == "Flower1" then
            if _G.FlowerESP then
                if not v:FindFirstChild('NameEsp'..Number) then
                    local bill = Instance.new('BillboardGui', v)
                    bill.Name = 'NameEsp'..Number
                    bill.ExtentsOffset = Vector3.new(0, 1, 0)
                    bill.Size = UDim2.new(1, 200, 1, 30)
                    bill.Adornee = v
                    bill.AlwaysOnTop = true
                    local name = Instance.new('TextLabel', bill)
                    name.Font = Enum.Font.GothamSemibold
                    name.TextSize = 14
                    name.TextWrapped = true
                    name.Size = UDim2.new(1, 0, 1, 0)
                    name.TextYAlignment = 'Top'
                    name.BackgroundTransparency = 1
                    name.TextStrokeTransparency = 0.5
                    if v.Name == "Flower1" then
                        name.Text = ("Blue Flower" .. ' \n' .. math.floor((Player.Character.Head.Position - v.Position).Magnitude / 3) .. ' Distance')
                        name.TextColor3 = Color3.fromRGB(0, 0, 255)
                    else
                        name.Text = ("Red Flower" .. ' \n' .. math.floor((Player.Character.Head.Position - v.Position).Magnitude / 3) .. ' Distance')
                        name.TextColor3 = Color3.fromRGB(255, 0, 0)
                    end
                else
                    v['NameEsp'..Number].TextLabel.Text = v.Name .. '   \n' .. math.floor((Player.Character.Head.Position - v.Position).Magnitude / 3) .. ' Distance'
                end
            else
                if v:FindFirstChild('NameEsp'..Number) then
                    v:FindFirstChild('NameEsp'..Number):Destroy()
                end
            end
        end
    end
end

-- 4. ESP REAL FRUIT (Apple/Pineapple/Banana)
function Functions.UpdateRealFruitChams()
    local Number = _G.RealFruitESPNumber or math.random(1, 1000000)
    local spawners = {"AppleSpawner", "PineappleSpawner", "BananaSpawner"}
    for _, spawnerName in ipairs(spawners) do
        local spawner = workspace:FindFirstChild(spawnerName)
        if spawner then
            for _, v in pairs(spawner:GetChildren()) do
                if v:IsA("Tool") and v:FindFirstChild("Handle") then
                    if _G.RealFruitESP then
                        if not v.Handle:FindFirstChild('NameEsp'..Number) then
                            local bill = Instance.new('BillboardGui', v.Handle)
                            bill.Name = 'NameEsp'..Number
                            bill.ExtentsOffset = Vector3.new(0, 1, 0)
                            bill.Size = UDim2.new(1, 200, 1, 30)
                            bill.Adornee = v.Handle
                            bill.AlwaysOnTop = true
                            local name = Instance.new('TextLabel', bill)
                            name.Font = Enum.Font.GothamSemibold
                            name.TextSize = 14
                            name.TextWrapped = true
                            name.Size = UDim2.new(1, 0, 1, 0)
                            name.TextYAlignment = 'Top'
                            name.BackgroundTransparency = 1
                            name.TextStrokeTransparency = 0.5
                            if spawnerName == "AppleSpawner" then
                                name.TextColor3 = Color3.fromRGB(255, 0, 0)
                            elseif spawnerName == "PineappleSpawner" then
                                name.TextColor3 = Color3.fromRGB(255, 174, 0)
                            else
                                name.TextColor3 = Color3.fromRGB(251, 255, 0)
                            end
                            name.Text = v.Name .. ' \n' .. math.floor((Player.Character.Head.Position - v.Handle.Position).Magnitude / 3) .. ' Distance'
                        else
                            v.Handle['NameEsp'..Number].TextLabel.Text = v.Name .. ' ' .. math.floor((Player.Character.Head.Position - v.Handle.Position).Magnitude / 3) .. ' Distance'
                        end
                    else
                        if v.Handle:FindFirstChild('NameEsp'..Number) then
                            v.Handle:FindFirstChild('NameEsp'..Number):Destroy()
                        end
                    end
                end
            end
        end
    end
end

-- 5. ESP GEAR (Mystic Island)
function Functions.UpdateGearESP()
    local Number = _G.GearESPNumber or math.random(1, 1000000)
    local mystic = workspace.Map:FindFirstChild("MysticIsland")
    if mystic then
        for _, v in pairs(mystic:GetChildren()) do
            if v.Name == "MeshPart" then
                if _G.GearESP then
                    if not v:FindFirstChild('NameEsp'..Number) then
                        local bill = Instance.new('BillboardGui', v)
                        bill.Name = 'NameEsp'..Number
                        bill.ExtentsOffset = Vector3.new(0, 1, 0)
                        bill.Size = UDim2.new(1, 200, 1, 30)
                        bill.Adornee = v
                        bill.AlwaysOnTop = true
                        local name = Instance.new('TextLabel', bill)
                        name.Font = "Code"
                        name.TextSize = 14
                        name.TextWrapped = true
                        name.Size = UDim2.new(1, 0, 1, 0)
                        name.TextYAlignment = 'Top'
                        name.BackgroundTransparency = 1
                        name.TextStrokeTransparency = 0.5
                        name.TextColor3 = Color3.fromRGB(80, 245, 245)
                        name.Text = "Gear Part"
                    else
                        local dist = math.floor((Player.Character.Head.Position - v.Position).Magnitude / 3)
                        v['NameEsp'..Number].TextLabel.Text = "Gear\n" .. dist .. " M"
                    end
                else
                    if v:FindFirstChild('NameEsp'..Number) then
                        v:FindFirstChild('NameEsp'..Number):Destroy()
                    end
                end
            end
        end
    end
end

-- 6. FUNÇÕES DE MOVIMENTO/BARCO
function Functions.TPB(CFgo)
    local boatSeat = workspace.Boats:FindFirstChild("PirateBrigade")
    if boatSeat then
        boatSeat = boatSeat:FindFirstChild("VehicleSeat")
    end
    if not boatSeat then return end
    local dist = (boatSeat.CFrame.Position - CFgo.Position).Magnitude
    local tween = TweenService:Create(boatSeat, TweenInfo.new(dist / 300, Enum.EasingStyle.Linear), {CFrame = CFgo})
    tween:Play()
    return { Stop = function() tween:Cancel() end }
end

function Functions.BTP(p)
    pcall(function()
        if (p.Position - HumanoidRootPart.Position).Magnitude >= 1500 and Humanoid and Humanoid.Health > 0 then
            repeat
                task.wait()
                HumanoidRootPart.CFrame = p
                task.wait(0.05)
                local head = Character:FindFirstChild("Head")
                if head then head:Destroy() end
                HumanoidRootPart.CFrame = p
            until (p.Position - HumanoidRootPart.Position).Magnitude < 1500 or (Humanoid and Humanoid.Health <= 0)
        end
    end)
end

function Functions.fastpos(Pos)
    local dist = (Pos.Position - HumanoidRootPart.Position).Magnitude
    TweenService:Create(HumanoidRootPart, TweenInfo.new(dist / 1250, Enum.EasingStyle.Linear), {CFrame = Pos}):Play()
end

function Functions.slowpos(Pos)
    local dist = (Pos.Position - HumanoidRootPart.Position).Magnitude
    TweenService:Create(HumanoidRootPart, TweenInfo.new(dist / 300, Enum.EasingStyle.Linear), {CFrame = Pos}):Play()
end

function Functions.GetLocalBoat()
    for _, v in pairs(workspace.Boats:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild("Owner") and tostring(v.Owner.Value) == Player.Name then
            local hum = v:FindFirstChild("Humanoid")
            if hum and hum.Value > 0 then
                return v
            end
        end
    end
    return false
end

function Functions.GetPlayerBoat()
    local char = Player.Character
    if char and char:FindFirstChild("Humanoid") then
        local seat = char.Humanoid.SeatPart
        if seat and seat:IsA("VehicleSeat") then
            return seat.Parent
        end
    end
    return nil
end

local _boatMovementConnection = nil
function Functions.MoveBoat(direction, distance, speed)
    local boat = Functions.GetPlayerBoat()
    if boat and boat.PrimaryPart then
        local targetPos = boat.PrimaryPart.Position + (direction * distance)
        targetPos = Vector3.new(targetPos.X, targetPos.Y + 200, targetPos.Z)
        local tween = TweenService:Create(boat.PrimaryPart, TweenInfo.new(distance / speed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
        tween:Play()
    end
end

function Functions.StartBoatMovement()
    Functions.StopBoatMovement()
    _boatMovementConnection = RunService.Heartbeat:Connect(function()
        Functions.MoveBoat(Vector3.new(0, 0, 1000), 500, 186)
    end)
end

function Functions.StopBoatMovement()
    if _boatMovementConnection then
        _boatMovementConnection:Disconnect()
        _boatMovementConnection = nil
    end
end

function Functions.CheckPirateBoat()
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v.Name == "PirateBrigade" or v.Name == "FishBoat" then
            if v:FindFirstChild("Health") and v.Health.Value > 0 then
                return v
            end
        end
    end
    return nil
end

-- 7. HABILIDADES INFINITAS (Soru, Geppo, Dodge, InfAb)
function Functions.InfiniteSoruLoop()
    task.spawn(function()
        while task.wait(0.5) do
            if _G.InfiniteSoru and Character and Character:FindFirstChild("Soru") then
                pcall(function()
                    for _, v in pairs(getgc()) do
                        if getfenv(v).script == Character:WaitForChild("Soru") then
                            for i2, v2 in pairs(debug.getupvalues(v)) do
                                if type(v2) == 'table' and (v2.LastUse ~= nil) then
                                    debug.setupvalue(v, i2, {LastAfter = 0, LastUse = 0})
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)
end

function Functions.InfiniteGeppoLoop()
    task.spawn(function()
        while task.wait(0.5) do
            if _G.InfiniteGeppo and Character and Character:FindFirstChild("Geppo") then
                pcall(function()
                    for _, v in pairs(getgc()) do
                        if getfenv(v).script == Character:WaitForChild("Geppo") then
                            for i2, v2 in pairs(debug.getupvalues(v)) do
                                if tostring(v2) == "0" then
                                    debug.setupvalue(v, i2, 0)
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)
end

function Functions.DodgeNoCDLoop()
    task.spawn(function()
        while task.wait(0.5) do
            if _G.DodgeNoCD and Character and Character:FindFirstChild("Dodge") then
                pcall(function()
                    for _, v in pairs(getgc()) do
                        if getfenv(v).script == Character:WaitForChild("Dodge") then
                            for i2, v2 in pairs(debug.getupvalues(v)) do
                                if tostring(v2) == "0.4" then
                                    debug.setupvalue(v, i2, 0)
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)
end

function Functions.InfAb()
    if _G.InfAbility then
        if not Character.HumanoidRootPart:FindFirstChild("Agility") then
            local inf = Instance.new("ParticleEmitter")
            inf.Name = "Agility"
            inf.Acceleration = Vector3.new(0,0,0)
            inf.Drag = 20
            inf.EmissionDirection = Enum.NormalId.Top
            inf.Enabled = true
            inf.Lifetime = NumberRange.new(0,0)
            inf.LightInfluence = 0
            inf.LockedToPart = true
            inf.Rate = 500
            inf.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,4)})
            inf.RotSpeed = NumberRange.new(9999, 99999)
            inf.Rotation = NumberRange.new(0, 0)
            inf.Speed = NumberRange.new(30, 30)
            inf.SpreadAngle = Vector2.new(0,0)
            inf.Texture = ""
            inf.VelocityInheritance = 0
            inf.ZOffset = 2
            inf.Transparency = NumberSequence.new(0)
            inf.Color = ColorSequence.new(Color3.fromRGB(0,0,0))
            inf.Parent = Character.HumanoidRootPart
        end
    else
        if Character.HumanoidRootPart:FindFirstChild("Agility") then
            Character.HumanoidRootPart.Agility:Destroy()
        end
    end
end

-- 8. RIP_INDRA PUZZLE
function Functions.CheckColorRipIndra()
    local colors = {}
    local circle = workspace.Map["Boat Castle"].Summoner.Circle
    if circle then
        for _, v in pairs(circle:GetChildren()) do
            if v:IsA("Part") and v:FindFirstChild("Part") and v.Part.BrickColor.Name == "Dark stone grey" then
                colors[v.BrickColor.Name] = v
            end
        end
    end
    return colors
end

function Functions.ActivateColor(colorName)
    local hakiMap = {
        ["Hot pink"] = "Winter Sky",
        ["Really red"] = "Pure Red",
        ["Oyster"] = "Snow White"
    }
    local hakiName = hakiMap[colorName]
    if hakiName then
        pcall(function()
            CommF_:InvokeServer("activateColor", hakiName)
        end)
    end
end

function Functions.AutoActiveColorRip_Indra()
    for colorName, part in pairs(Functions.CheckColorRipIndra()) do
        Functions.ActivateColor(colorName)
        Functions.TeleportTo(part.CFrame)
        pcall(function() firetouchinterest(part, 0) end) -- toque simulado
    end
end

-- 9. OUTRAS UTILIDADES
function Functions.SetHomePoint()
    pcall(function()
        CommF_:InvokeServer("SetSpawnPoint")
    end)
end

function Functions.WalkWater(enabled)
    local water = workspace.Map:FindFirstChild("WaterBase-Plane")
    if water then
        water.Size = enabled and Vector3.new(1000, 112, 1000) or Vector3.new(1000, 80, 1000)
    end
end

function Functions.SpinPositionLoop()
    task.spawn(function()
        local posY = _G.PosY or 35
        while _G.SpinPos do
            HumanoidRootPart.CFrame = CFrame.new(0, posY, -20)
            task.wait(0.1)
            HumanoidRootPart.CFrame = CFrame.new(-20, posY, 0)
            task.wait(0.1)
            HumanoidRootPart.CFrame = CFrame.new(0, posY, 20)
            task.wait(0.1)
            HumanoidRootPart.CFrame = CFrame.new(20, posY, 0)
            task.wait(0.1)
        end
    end)
end

function Functions.TpEntrance(pos)
    pcall(function()
        CommF_:InvokeServer("requestEntrance", pos)
        HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + Vector3.new(0, 50, 0)
        task.wait(0.5)
    end)
end

function Functions.CheckItemBPCR(name)
    local containers = {Player.Character, Player.Backpack}
    for _, cont in pairs(containers) do
        if cont and cont:FindFirstChild(name) then
            return cont:FindFirstChild(name)
        end
    end
    return nil
end

-- 10. AUTO KATAKURI V2 (versão simplificada baseada no Tiroreal)
function Functions.AutoKatakuriV2Loop()
    task.spawn(function()
        while _G.AutoKatakuriV2 do
            pcall(function()
                local char = Player.Character
                if not char then task.wait(1); return end
                local backpack = Player.Backpack

                -- Verifica se tem Sweet Chalice ou God's Chalice
                local sweetChalice = backpack:FindFirstChild("Sweet Chalice") or char:FindFirstChild("Sweet Chalice")
                local godsChalice = backpack:FindFirstChild("God's Chalice") or char:FindFirstChild("God's Chalice")

                if godsChalice then
                    -- Falar com SweetChaliceNpc
                    if string.find(CommF_:InvokeServer("SweetChaliceNpc") or "", "Where") then
                        CommF_:InvokeServer("SweetChaliceNpc")
                    end
                elseif sweetChalice then
                    -- Abrir portal do Cake Prince
                    if string.find(CommF_:InvokeServer("CakePrinceSpawner") or "", "open the portal") then
                        CommF_:InvokeServer("CakePrinceSpawner")
                    end
                else
                    -- Farm mobs para conseguir God's Chalice
                    local eliteMobs = {"Diablo", "Deandre", "Urban"}
                    for _, mobName in ipairs(eliteMobs) do
                        local mob = workspace.Enemies:FindFirstChild(mobName)
                        if mob and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                            repeat
                                task.wait()
                                Functions.EquipWeapon(Config.SelectedWeaponName)
                                Functions.AutoHaki()
                                Functions.TeleportTo(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                VirtualUser:Button1Down(Vector2.new(1280, 672))
                            until not mob.Parent or mob.Humanoid.Health <= 0
                        end
                    end
                end

                -- Se Dough King apareceu, matar
                local doughKing = workspace.Enemies:FindFirstChild("Dough King")
                if doughKing and doughKing:FindFirstChild("Humanoid") and doughKing.Humanoid.Health > 0 then
                    repeat
                        task.wait()
                        Functions.EquipWeapon(Config.SelectedWeaponName)
                        Functions.AutoHaki()
                        doughKing.HumanoidRootPart.Size = Vector3.new(70,70,70)
                        doughKing.HumanoidRootPart.CanCollide = false
                        Functions.TeleportTo(doughKing.HumanoidRootPart.CFrame * CFrame.new(0, -40, 0))
                        VirtualUser:Button1Down(Vector2.new(1280, 672))
                    until doughKing.Humanoid.Health <= 0 or not _G.AutoKatakuriV2
                end

                -- Se Cake Prince apareceu, matar
                local cakePrince = workspace.Enemies:FindFirstChild("Cake Prince")
                if cakePrince and cakePrince:FindFirstChild("Humanoid") and cakePrince.Humanoid.Health > 0 then
                    repeat
                        task.wait()
                        Functions.EquipWeapon(Config.SelectedWeaponName)
                        Functions.AutoHaki()
                        cakePrince.HumanoidRootPart.Size = Vector3.new(50,50,50)
                        cakePrince.HumanoidRootPart.CanCollide = false
                        Functions.TeleportTo(cakePrince.HumanoidRootPart.CFrame * CFrame.new(4, 10, 10))
                        VirtualUser:Button1Down(Vector2.new(1280, 672))
                    until cakePrince.Humanoid.Health <= 0 or not _G.AutoKatakuriV2
                end
            end)
            task.wait(1)
        end
    end)
end

-- EXPOR FUNÇÕES GLOBAIS PARA COMPATIBILIDADE
_G.CheckQuest = CheckQuest
_G.MaterialMon = MaterialMon
_G.UpdateFlowerChams = Functions.UpdateFlowerChams
_G.UpdateRealFruitChams = Functions.UpdateRealFruitChams
_G.UpdateGeaESP = Functions.UpdateGearESP
_G.TPB = Functions.TPB
_G.BTP = Functions.BTP
_G.fastpos = Functions.fastpos
_G.slowpos = Functions.slowpos
_G.GetLocalBoat = Functions.GetLocalBoat
_G.GetPlayerBoat = Functions.GetPlayerBoat
_G.MoveBoat = Functions.MoveBoat
_G.StartBoatMovement = Functions.StartBoatMovement
_G.StopBoatMovement = Functions.StopBoatMovement
_G.CheckPirateBoat = Functions.CheckPirateBoat
_G.InfiniteSoruLoop = Functions.InfiniteSoruLoop
_G.InfiniteGeppoLoop = Functions.InfiniteGeppoLoop
_G.DodgeNoCDLoop = Functions.DodgeNoCDLoop
_G.InfAb = Functions.InfAb
_G.CheckColorRipIndra = Functions.CheckColorRipIndra
_G.ActivateColor = Functions.ActivateColor
_G.AutoActiveColorRip_Indra = Functions.AutoActiveColorRip_Indra
_G.SetHomePoint = Functions.SetHomePoint
_G.WalkWater = Functions.WalkWater
_G.SpinPositionLoop = Functions.SpinPositionLoop
_G.TpEntrance = Functions.TpEntrance

-- =====================================================
-- SUBMERGED ISLAND - Teleporte para a ilha submersa
-- Fluxo: voa ate o NPC da Tiki Outpost -> dispara RF/SubmarineWorkerSpeak -> checar se chegou
-- =====================================================

-- Posicoes chave
local SUBMERGED_NPC_POS    = Vector3.new(-16271.37, 25.23, 1373.66)   -- NPC da Tiki Outpost (SubmarineWorker)
local SUBMERGED_TIKI_POS   = Vector3.new(-16818.81, 58.30, 293.64)    -- Tiki Outpost (referencia)
local SUBMERGED_CHECK_Y    = -500  -- Y abaixo disso = ja esta na ilha submersa

local function IsOnSubmergedIsland()
    local char = Player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    return hrp.Position.Y < SUBMERGED_CHECK_Y
end

function Functions.TravelToSubmergedIsland(config)
    -- Se ja esta la embaixo, nao faz nada
    if IsOnSubmergedIsland() then
        return true
    end

    local char = Player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    -- 1. Voa diretamente pro NPC da Tiki Outpost (de qualquer lugar do mapa)
    local distToNPC = (hrp.Position - SUBMERGED_NPC_POS).Magnitude

    if distToNPC > 15 then
        local TweenSvc  = game:GetService("TweenService")
        local targetCF  = CFrame.new(SUBMERGED_NPC_POS + Vector3.new(0, 5, 0))
        local fakeIsTp  = { value = false }
        local fakeNoAuto = { value = false }
        Functions.FlyToPosition(targetCF, TweenSvc, config, fakeIsTp, fakeNoAuto)
        task.wait(0.5)
    end

    -- 2. Dispara o remote do NPC -> TravelToSubmergedIsland
    pcall(function()
        local net = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net")
        local rf  = net:FindFirstChild("RF/SubmarineWorkerSpeak")
        if not rf then
            warn("[TravelToSubmerged] RF/SubmarineWorkerSpeak nao encontrado!")
            return
        end
        rf:InvokeServer("TravelToSubmergedIsland")
    end)

    -- 3. Aguarda teleporte para a Submerged Island (ate 15s)
    local waited = 0
    while not IsOnSubmergedIsland() and waited < 15 do
        task.wait(0.5)
        waited = waited + 0.5
    end

    if IsOnSubmergedIsland() then
        return true
    else
        warn("[TravelToSubmerged] Timeout apos " .. waited .. "s - nao foi teleportado. Verifique se o nivel e suficiente (2600+).")
        return false
    end
end

_G.CheckItemBPCR = Functions.CheckItemBPCR
_G.AutoKatakuriV2Loop = Functions.AutoKatakuriV2Loop
_G.AutoClick = Functions.FastAttackAdvanced

print("UI loaded")
print("Functions Updated Loaded v6FLSA-1LDA")
return Functions
