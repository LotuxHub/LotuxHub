-- Functions.lua
-- Lotux Hub by LoadFlint/lucas
-- Todas as funcoes: Farm, Voo, ESP, Visual, Quest, Utilitarios

local Functions = {}

-- =====================================================
-- SERVICES
-- =====================================================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local VirtualUser       = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserInputService  = game:GetService("UserInputService")

local Player = Players.LocalPlayer

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
-- Loop em background: atualiza Config.SelectedWeaponName
-- com o nome real da tool que bate com o tipo selecionado.
-- Chame Functions.StartWeaponResolver(Config) uma unica vez no init.
-- =====================================================

function Functions.StartWeaponResolver(config)
    task.spawn(function()
        while task.wait(0.5) do
            pcall(function()
                local tipo    = config.FarmWeapon
                local tooltip = tipo
                if tipo == "BloxFruits" then tooltip = "Blox Fruit" end

                local found = false

                -- Procura no backpack
                for _, tool in pairs(Player.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool.ToolTip == tooltip then
                        config.SelectedWeaponName = tool.Name
                        found = true; break
                    end
                end

                -- Procura no personagem (ja equipada)
                if not found and Player.Character then
                    for _, tool in pairs(Player.Character:GetChildren()) do
                        if tool:IsA("Tool") and tool.ToolTip == tooltip then
                            config.SelectedWeaponName = tool.Name
                            found = true; break
                        end
                    end
                end

                -- Fallback por nome
                if not found then
                    for _, tool in pairs(Player.Backpack:GetChildren()) do
                        if tool:IsA("Tool") and tool.Name:lower():find(tooltip:lower()) then
                            config.SelectedWeaponName = tool.Name
                            break
                        end
                    end
                end
            end)
        end
    end)
end

-- =====================================================
-- EQUIP / UNEQUIP WEAPON
-- =====================================================

local _NotAutoEquip = false

function Functions.EquipWeapon(weaponName, notAutoEquipRef)
    if type(weaponName) == "table" then
        if weaponName.SelectedWeaponName then
            weaponName = weaponName.SelectedWeaponName
        else return end
    end
    if type(weaponName) ~= "string" or weaponName == "" then return end

    local notAuto = notAutoEquipRef and notAutoEquipRef.value or _NotAutoEquip
    if notAuto then return end

    local tool = Player.Backpack:FindFirstChild(weaponName)
    if tool and Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid:EquipTool(tool)
        task.wait(0.1)
    end
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

function Functions.AutoHaki()
    local character = Player.Character
    if not character then return end
    local hasBuso = character:FindFirstChild("HasBuso")
                 or character:FindFirstChild("Buso")
                 or character:FindFirstChild("HakiActive")
    if hasBuso then return end
    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
    end)
end

function Functions.ActivateBuso(commF_)
    pcall(function() Functions.AutoHaki() end)
    if commF_ then
        pcall(function() commF_:InvokeServer("Buso") end)
    end
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
-- FLY (PartTele - metodo suave com tween)
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
                c.HumanoidRootPart.CFrame = c.PartTele.CFrame
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
            cHrp.CFrame = pt.CFrame
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

-- Teleporte instantaneo
function Functions.TeleportTo(pos)
    local char = Player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = pos end
end

-- Teleporte suave direto no HRP (sem PartTele)
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
-- TELEPORTADOR DE ILHA (verifica se precisa passar por portal)
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
        ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", teleportPos)
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = hrp.CFrame + Vector3.new(0, 50, 0) end
        task.wait(0.5)
    end)
end

-- ToPos: voa com verificacao de portal de ilha
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
-- BRING MOB (BodyVelocity Lock)
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

-- Alias para compatibilidade com farm loop
Functions.BringMobFunc = Functions.BringMob

-- Loop separado de bring (mantém mobs presos durante o farm)
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

    local tool = char:FindFirstChildOfClass("Tool")
    if not tool and config and config.SelectedWeaponName ~= "" then
        Functions.EquipWeapon(config.SelectedWeaponName, notAutoEquipRef)
        tool = char:FindFirstChildOfClass("Tool")
        if not tool then return end
    end

    -- Blox Fruit (LeftClickRemote)
    if tool and tool:FindFirstChild("LeftClickRemote") then
        local hrp = targetMob:FindFirstChild("HumanoidRootPart")
        if hrp then
            local direction = (hrp.Position - char.HumanoidRootPart.Position).Unit
            pcall(function() tool.LeftClickRemote:FireServer(direction, 1) end)
        end
        return
    end

    -- Net Modules (RegisterAttack / RegisterHit)
    local Net = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
    if Net then
        local RegisterAttack = Net:FindFirstChild("RE/RegisterAttack")
        local RegisterHit    = Net:FindFirstChild("RE/RegisterHit")
        if RegisterAttack and RegisterHit then
            local parts = {}
            for _, part in pairs(targetMob:GetChildren()) do
                if part:IsA("BasePart") then table.insert(parts, {targetMob, part}) end
            end
            local head = targetMob:FindFirstChild("Head") or targetMob:FindFirstChild("HumanoidRootPart")
            if head and #parts > 0 then
                pcall(function()
                    RegisterAttack:FireServer(0)
                    RegisterHit:FireServer(head, parts)
                end)
                return
            end
        end
    end

    -- Gun (RemoteFunctionShoot)
    if tool and tool:FindFirstChild("RemoteFunctionShoot") then
        local hrp = targetMob:FindFirstChild("HumanoidRootPart")
        if hrp then
            pcall(function()
                tool.RemoteFunctionShoot:InvokeServer(hrp.Position, hrp)
            end)
        end
        return
    end

    -- Fallback VirtualUser
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(1280, 672))
    end)
end

-- FastAttack avancado com seed (para armas corpo a corpo)
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
-- AUTO SKILL (usar Z/X/C automaticamente)
-- =====================================================

function Functions.StartAutoSkill(config)
    local function pressKey(key)
        VirtualInputManager:SendKeyEvent(true,  key, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, key, false, game)
    end

    local function useWeaponSkills(weaponType)
        local char = Player.Character
        if not char then return end
        for _, v in ipairs(Player.Backpack:GetChildren()) do
            if v:IsA("Tool") and v.ToolTip == weaponType then
                char.Humanoid:EquipTool(v)
                task.wait(0.1)
                pressKey(Enum.KeyCode.Z)
                task.wait(0.2)
                pressKey(Enum.KeyCode.X)
                task.wait(0.2)
                pressKey(Enum.KeyCode.C)
                task.wait(0.2)
            end
        end
    end

    task.spawn(function()
        while task.wait(1) do
            if not config.AutoSkill then continue end
            pcall(function()
                useWeaponSkills("Melee")
                useWeaponSkills("Sword")
                useWeaponSkills("Gun")
            end)
        end
    end)
end

-- =====================================================
-- RACE V3 / V4
-- =====================================================

function Functions.StartAutoRace(config)
    -- Race V3: ativar habilidade de raca
    task.spawn(function()
        while task.wait(0.1) do
            if not config.AutoRaceV3 then continue end
            pcall(function()
                ReplicatedStorage.Remotes.CommE:FireServer("ActivateAbility")
            end)
        end
    end)

    -- Race V4: pressionar Y
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

-- =====================================================
-- AUTO QUEST RACE (completar quest de evolucao de raca)
-- =====================================================

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
                    -- Matar todos os inimigos no raio
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
                            -- Usar skills: Z X C com melee e fruta
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
                                        VirtualInputManager:SendKeyEvent(true,  99, false,  Player.Character.HumanoidRootPart)
                                        VirtualInputManager:SendKeyEvent(false, 99, false,  Player.Character.HumanoidRootPart)
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

-- =====================================================
-- AUTO DOO HEE (olhar lua + pressionar T para V3)
-- =====================================================

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
-- AUTO BARTILO (quest para desbloquear Sea 3)
-- =====================================================

function Functions.StartAutoBartilo(config)
    task.spawn(function()
        while task.wait(0.1) do
            if not config.AutoBartilo then continue end
            pcall(function()
                local level = Player.Data.Level.Value
                if level < 800 then return end

                local progress = ReplicatedStorage.Remotes.CommF_:InvokeServer("BartiloQuestProgress", "Bartilo")

                if progress == 0 then
                    local questGui = Player.PlayerGui.Main.Quest
                    local questTitle = questGui.Container.QuestTitle.Title.Text
                    if questGui.Visible
                       and questTitle:find("Swan Pirates") and questTitle:find("50") then
                        -- Matar Swan Pirates
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
                        -- Pegar quest do Bartilo
                        Functions.TeleportTo(CFrame.new(-456.28952, 73.0200958, 299.895966))
                        task.wait(1.1)
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", "BartiloQuest", 1)
                    end

                elseif progress == 1 then
                    -- Matar Jeremy
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
                    elseif ReplicatedStorage:FindFirstChild("Jeremy") then
                        Functions.TeleportTo(CFrame.new(-456.28952, 73.0200958, 299.895966))
                        task.wait(1.1)
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("BartiloQuestProgress", "Bartilo")
                        task.wait(1)
                        Functions.TeleportTo(CFrame.new(2099.88159, 448.931, 648.997375))
                        task.wait(2)
                    else
                        Functions.TeleportTo(CFrame.new(2099.88159, 448.931, 648.997375))
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
                        -- Tem quest ativa, atacar o mob
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
                                -- Tentar teleportar para o mob via ReplicatedStorage
                                local rs = ReplicatedStorage:FindFirstChild(name)
                                if rs and rs:FindFirstChild("HumanoidRootPart") then
                                    Functions.TeleportTo(rs.HumanoidRootPart.CFrame * CFrame.new(2, 20, 2))
                                end
                            end
                        end
                    end
                else
                    -- Sem quest, ir pegar
                    local response = ReplicatedStorage.Remotes.CommF_:InvokeServer("EliteHunter")
                    if config.AutoEliteHunterHop
                       and response == "I don't have anything for you right now. Come back later." then
                        Functions.Hop()
                    else
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("EliteHunter")
                    end
                end
            end)
        end
    end)
end

-- =====================================================
-- AUTO GET YAMA
-- =====================================================

function Functions.StartAutoYama(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoYama then continue end
            pcall(function()
                local progress = ReplicatedStorage.Remotes.CommF_:InvokeServer("EliteHunter", "Progress")
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

-- =====================================================
-- AUTO HOLY TORCH (quest pre-Tushita)
-- =====================================================

function Functions.StartAutoHolyTorch(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoHolyTorch then continue end
            pcall(function()
                -- Entrar na Hydra Island
                ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance",
                    Vector3.new(5657.88623046875, 1013.0790405273438, -335.4996337890625))
                task.wait(1)
                Functions.TeleportTo(CFrame.new(5711.87451171875, 45.82802963256836, 254.17005920410156))
                task.wait(15)
                Functions.EquipWeapon("Holy Torch")

                -- Percorrer as tochas
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

-- =====================================================
-- AUTO GET TUSHITA (farm Longma)
-- =====================================================

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

-- =====================================================
-- AUTO RENGOKU (Hidden Key → Awakened Ice Admiral)
-- =====================================================

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
-- KILL AURA
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
                        if dist <= 1000 then
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

-- =====================================================
-- AUTO PLAYER HUNTER / AUTO KILL PLAYER
-- =====================================================

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
-- SAIL BOAT (auto navegar barco - Sea 3)
-- =====================================================

function Functions.StartSailBoat(config)
    -- Waypoints do barco entre ilhas do Sea 3
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

                -- Comprar barco se nao tiver
                if not boats:FindFirstChild("PirateBrigade") then
                    Functions.TPP(CFrame.new(-16927.451171875, 9.0863618850708, 433.8642883300781))
                    local char = Player.Character
                    if char and (CFrame.new(-16927.451171875, 9.0863618850708, 433.8642883300781).Position
                               - char.HumanoidRootPart.Position).Magnitude <= 10 then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyBoat", "PirateBrigade")
                    end
                    return
                end

                local brigade = boats.PirateBrigade
                local seat    = brigade:FindFirstChild("VehicleSeat")
                if not seat then return end

                local char = Player.Character
                if not char then return end

                -- Sentar no barco se nao estiver sentado
                if not char.Humanoid.Sit then
                    Functions.TPP(seat.CFrame * CFrame.new(0, 1, 0))
                    return
                end

                -- Verificar inimigos perto (sair do barco para lutar)
                local enemyNames = {"Shark", "Terrorshark", "Piranha", "Fish Crew Member"}
                for _, name in ipairs(enemyNames) do
                    if workspace.Enemies:FindFirstChild(name) then
                        char.Humanoid.Sit = false
                        return
                    end
                end

                -- Navegar pelos waypoints
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                for _, wp in ipairs(waypoints) do
                    if (wp.Position - hrp.Position).Magnitude <= 10 then
                        -- chegou nesse waypoint, ir para o proximo
                    end
                end
            end)
        end
    end)
end

-- =====================================================
-- AUTO TERRORSHARK (matar criaturas do mar - Sea 3)
-- =====================================================

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
                                -- Sair do barco
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
                                    -- Verificar Typhoon
                                    local hasTyphoon = workspace._WorldOrigin:FindFirstChild("Typhoon Splash")
                                    local offset = hasTyphoon and CFrame.new(0, 300, 0) or CFrame.new(0, 60, 0)
                                    Functions.TeleportTo(v.HumanoidRootPart.CFrame * offset)
                                until not config.AutoTerrorshark or not v.Parent or v.Humanoid.Health <= 0
                            end
                        end
                    end
                end

                if not found then
                    -- Voltar para o barco
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

-- =====================================================
-- WALK ON WATER
-- =====================================================

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
-- MYSTIC ISLAND / TWEEN KITSUNE
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

-- =====================================================
-- TWEEN GEAR (Mystic Island M-Gear)
-- =====================================================

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

-- =====================================================
-- AUTO AZURE / BLAZE EMBER
-- =====================================================

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

-- =====================================================
-- AUTO HYDRA TREE
-- =====================================================

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
                    -- Tween suave ate a posicao
                    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                    if not hrp then break end
                    local dist = (hrp.Position - cf.Position).Magnitude
                    local tween = TweenService:Create(hrp, TweenInfo.new(dist / 200, Enum.EasingStyle.Linear), {CFrame = cf})
                    tween:Play()
                    tween.Completed:Wait()

                    -- Usar skills por 3 segundos na posicao
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

-- =====================================================
-- AUTO MOB DRAGON (Floating Turtle - Sea 3)
-- =====================================================

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
-- AUTO COLLECT BONE / COLLECT EGG
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

-- =====================================================
-- FARM CHEST
-- =====================================================

function Functions.StartFarmChest(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.FarmChest then continue end
            pcall(function()
                for _, chest in ipairs(CollectionService:GetTagged("_ChestTagged")) do
                    if not chest:GetAttribute("IsDisabled") then
                        Functions.TeleportTo(CFrame.new(chest:GetPivot().Position))
                        task.wait(0.5)
                        VirtualInputManager:SendKeyEvent(true,  Enum.KeyCode.E, false, game)
                        task.wait(0.1)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    end
                end
            end)
        end
    end)
end

-- =====================================================
-- AUTO STORE FRUIT / TWEEN FRUIT / GRAB FRUIT
-- =====================================================

function Functions.StartAutoStoreFruit(config)
    task.spawn(function()
        while task.wait(0.5) do
            if not config.AutoStoreFruit then continue end
            pcall(function()
                for _, v in ipairs(Player.Backpack:GetChildren()) do
                    if v:IsA("Tool") and v.Name:find("Fruit") then
                        local firstName = v.Name:gsub(" Fruit", "")
                        ReplicatedStorage.Remotes.CommF_:InvokeServer(
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

function Functions.StartTweenFruit(config)
    task.spawn(function()
        while task.wait(0.1) do
            if not config.TweenFruit then continue end
            pcall(function()
                for _, v in ipairs(workspace:GetChildren()) do
                    if v.Name:find("Fruit") and v:FindFirstChild("Handle") then
                        Functions.TPP(v.Handle.CFrame)
                    end
                end
            end)
        end
    end)
end

function Functions.StartGrabFruit(config)
    task.spawn(function()
        while task.wait(0.1) do
            if not config.GrabFruit then continue end
            pcall(function()
                for _, v in ipairs(workspace:GetChildren()) do
                    if v.Name:find("Fruit") and v:FindFirstChild("Handle") then
                        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then hrp.CFrame = v.Handle.CFrame end
                    end
                end
            end)
        end
    end)
end

-- =====================================================
-- AUTO BUY ENHANCEMENT COLOUR / LEGENDARY SWORD
-- =====================================================

function Functions.StartAutoBuyEnhancement(config)
    task.spawn(function()
        while task.wait(1) do
            if not config.AutoBuyEnhancementColour then continue end
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyEnhancementColour")
            end)
        end
    end)
end

function Functions.StartAutoBuyLegendarySword(config)
    task.spawn(function()
        while task.wait(1) do
            if not config.AutoBuyLegendarySword then continue end
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyLegendarySword")
            end)
        end
    end)
end

-- =====================================================
-- AUTO DUNGEON
-- =====================================================

function Functions.StartAutoDungeon(config)
    -- Funcao auxiliar para encontrar proxima ilha no dungeon
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

    -- Funcao auxiliar para atacar inimigos proximos
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

function Functions.CheckItem(name)
    for _, v in pairs(ReplicatedStorage.Remotes.CommF_:InvokeServer("getInventory")) do
        if v.Name == name then return v end
    end
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
                ReplicatedStorage.Remotes.CommF_:InvokeServer(
                    "StoreFruit",
                    v:GetAttribute("OriginalName"),
                    v
                )
            end)
        end
    end
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
-- COLLECT BERRY
-- =====================================================

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
                    local VIM = game:GetService("VirtualInputManager")
                    VIM:SendKeyEvent(true,  Enum.KeyCode.E, false, game)
                    task.wait(0.1)
                    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
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
-- SAFE MODE (sobe se HP ficar baixo)
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
-- ANTI-AFK
-- =====================================================

function Functions.StartAntiAFK()
    Player.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
end

-- =====================================================
-- HOP (troca de servidor)
-- =====================================================

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

-- =====================================================
-- REMOVE FOG / REMOVE LAVA
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
-- ESP - MOBS (circulo verde via Drawing)
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

-- =====================================================
-- ESP - PLAYERS
-- =====================================================

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

-- =====================================================
-- ESP - ILHAS
-- =====================================================

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
                    lbl.Font               = "GothamSemibold"
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

-- =====================================================
-- ESP - FRUTAS DO DIABO
-- =====================================================

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
                    local dist = math.floor(
                        (Player.Character.Head.Position - v.Handle.Position).Magnitude / 3)
                    lbl.Text = v.Name .. "\n" .. dist .. "m"
                else
                    local dist = math.floor(
                        (Player.Character.Head.Position - v.Handle.Position).Magnitude / 3)
                    v.Handle["LotuxFruitESP".. _espNumber].TextLabel.Text = v.Name .. "\n" .. dist .. "m"
                end
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

-- =====================================================
-- ESP - BAUS
-- =====================================================

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
                else
                    local dist = math.floor(
                        (Player.Character.Head.Position - chest:GetPivot().Position).Magnitude / 3)
                    chest.LotuxChestESP.TextLabel.Text = "Chest\n" .. dist .. "m"
                end
            else
                if chest:FindFirstChild("LotuxChestESP") then
                    chest.LotuxChestESP:Destroy()
                end
            end
        end)
    end
end

-- =====================================================
-- ESP - BERRIES
-- =====================================================

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
                        else
                            local dist = math.floor(
                                (Player.Character.Head.Position - bush.Parent:GetPivot().Position).Magnitude / 3)
                            bush.Parent.LotuxBerryESP.TextLabel.Text = attrName .. "\n" .. dist .. "m"
                        end
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

-- =====================================================
-- ESP - MIRAGE ISLAND
-- =====================================================

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
                    else
                        local dist = math.floor(
                            (Player.Character.Head.Position - v.Position).Magnitude / 3)
                        v.LotuxMirageESP.TextLabel.Text = "Mirage Island\n" .. dist .. "m"
                    end
                else
                    if v:FindFirstChild("LotuxMirageESP") then
                        v.LotuxMirageESP:Destroy()
                    end
                end
            end
        end)
    end
end

-- =====================================================
-- HIGHLIGHT NO PROPRIO PERSONAGEM
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

-- =====================================================
-- AURA AQUA
-- =====================================================

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
                    floatTime += dt
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

-- =====================================================
-- RAINBOW SKILLS
-- =====================================================

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

-- =====================================================
-- RAINBOW BILLBOARD
-- =====================================================

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

-- =====================================================
-- FPS COUNTER
-- =====================================================

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
-- RENDER 3D QUANDO JANELA PERDE FOCO
-- =====================================================

function Functions.StartFocusRenderControl()
    UserInputService.WindowFocused:Connect(function()
        RunService:Set3dRenderingEnabled(true)
    end)
    UserInputService.WindowFocusReleased:Connect(function()
        RunService:Set3dRenderingEnabled(false)
    end)
end

-- =====================================================
-- ESP - SEA BEASTS
-- =====================================================

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
                local dist = math.floor(
                    (Player.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                v.LotuxSeaESP.TextLabel.Text = v.Name .. " — " .. dist .. "m"
            else
                if v:FindFirstChild("LotuxSeaESP") then
                    v.LotuxSeaESP:Destroy()
                end
            end
        end)
    end
end

-- =====================================================
-- ESP - NPCs
-- =====================================================

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
                local dist = math.floor(
                    (Player.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
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
-- CHECK ITEM NO INVENTARIO
-- =====================================================

function Functions.CheckItem(itemName)
    local ok, inventory = pcall(function()
        return game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("getInventory")
    end)
    if not ok or not inventory then return nil end
    for _, v in pairs(inventory) do
        if v.Name == itemName then
            return v
        end
    end
    return nil
end

-- =====================================================
-- SERVER HOP
-- =====================================================

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
-- INICIALIZAR TODOS OS LOOPS (chamado uma vez no init)
-- Passa o Config para ligar/desligar via toggles
-- =====================================================

function Functions.StartAllLoops(config)
    Functions.StartAutoRace(config)
    Functions.StartAutoDooHee(config)
    Functions.StartAutoBartilo(config)
    Functions.StartAutoEliteHunter(config)
    Functions.StartAutoYama(config)
    Functions.StartAutoHolyTorch(config)
    Functions.StartAutoGetTushita(config)
    Functions.StartAutoRengoku(config)
    Functions.StartKillAura(config)
    Functions.StartAutoPlayerHunter(config)
    Functions.StartSailBoat(config)
    Functions.StartAutoTerrorshark(config)
    Functions.StartAutoMysticIsland(config)
    Functions.StartTweenToKitsune(config)
    Functions.StartTweenMGear(config)
    Functions.StartAutoEmber(config)
    Functions.StartAutoHydraTree(config)
    Functions.StartAutoMobDragon(config)
    Functions.StartAutoCollectBone(config)
    Functions.StartAutoCollectEgg(config)
    Functions.StartFarmChest(config)
    Functions.StartAutoStoreFruit(config)
    Functions.StartTweenFruit(config)
    Functions.StartGrabFruit(config)
    Functions.StartAutoQuestRace(config)
    Functions.StartAutoDungeon(config)
    Functions.StartAutoSkill(config)
    Functions.StartAutoBuyEnhancement(config)
    Functions.StartAutoBuyLegendarySword(config)
end

return Functions