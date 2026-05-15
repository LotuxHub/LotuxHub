-- Functions.lua
-- Redux Hub - Funcoes completas com integracao total do Tiroreal
-- Inclui: FastAttack, BringMob, NoClip, ESP, TP, AutoHaki, etc.

local Functions = {}

-- =====================================================
-- SERVICES LOCAIS
-- =====================================================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local VirtualUser       = game:GetService("VirtualUser")
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
    -- Fallback por level
    local ok, level = pcall(function() return Player.Data.Level.Value end)
    if ok and level then
        if level >= 1500 then return 3
        elseif level >= 700 then return 2
        else return 1 end
    end
    return 1
end

-- =====================================================
-- RESOLVE WEAPON NAME (igual ao Tiroreal)
-- =====================================================
function Functions.StartWeaponResolver(config)
    task.spawn(function()
        while task.wait(0.5) do
            pcall(function()
                local tipo    = config.FarmWeapon
                local tooltip = tipo
                if tipo == "BloxFruits" then tooltip = "Blox Fruit" end

                local found = false
                for _, tool in pairs(Player.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool.ToolTip == tooltip then
                        config.SelectedWeaponName = tool.Name
                        found = true; break
                    end
                end
                if not found and Player.Character then
                    for _, tool in pairs(Player.Character:GetChildren()) do
                        if tool:IsA("Tool") and tool.ToolTip == tooltip then
                            config.SelectedWeaponName = tool.Name
                            found = true; break
                        end
                    end
                end
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
-- EQUIP / UNEQUIP WEAPON (logica Tiroreal)
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
    if tool then
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
            if v:IsA("Tool") and v.Name ~= "Summon Sea Beast" and v.Name ~= "Water Body" and v.Name ~= "Awakening" then
                Player.Character.Humanoid:EquipTool(v)
                task.wait(1)
            end
        end
    end)
end

-- =====================================================
-- AUTO HAKI BUSO (do Tiroreal)
-- =====================================================
function Functions.AutoHaki()
    local character = Player.Character
    if not character then return end
    local hasBuso = character:FindFirstChild("HasBuso") or character:FindFirstChild("Buso") or character:FindFirstChild("HakiActive")
    if hasBuso then return end
    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
    end)
end

function Functions.ActivateBuso(commF_)
    pcall(function() Functions.AutoHaki() end)
    if commF_ then pcall(function() commF_:InvokeServer("Buso") end) end
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
-- TWEEN FLY (PartTele - metodo Tiroreal / topos)
-- =====================================================
local _isTeleporting = false

function Functions.FlyToPosition(targetCF, tweenSvc, config, isTeleportingRef, notAutoEquipRef)
    local char = Player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not hrp or not hum or hum.Health <= 0 then return end

    local distance = (targetCF.Position - hrp.Position).Magnitude
    if distance < 2 then return end

    -- Cria PartTele se nao existe (exatamente como o Tiroreal)
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

    -- Mantém o personagem na PartTele durante o voo
    local conn
    conn = RunService.Heartbeat:Connect(function()
        local c   = Player.Character
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

-- TP direto (teleporte instantaneo)
function Functions.TeleportTo(pos)
    local char = Player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = pos end
end

-- Para teleporte suave (igual ao TPP do Tiroreal)
function Functions.TPP(targetCF)
    local hum = Player.Character and Player.Character:FindFirstChild("Humanoid")
    if hum and hum.Health <= 0 then return end
    local char = Player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local dist = (targetCF.Position - hrp.Position).Magnitude
    local tween = TweenService:Create(hrp, TweenInfo.new(dist / 325, Enum.EasingStyle.Linear), {CFrame = targetCF})
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
-- BRING MOB (do Tiroreal - BodyVelocity Lock)
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

            v.HumanoidRootPart.CFrame = targetPosition or v.HumanoidRootPart.CFrame
            v.Humanoid.JumpPower      = 0
            v.Humanoid.WalkSpeed      = 0
            v.HumanoidRootPart.Transparency = 1
            v.HumanoidRootPart.CanCollide   = false

            if v:FindFirstChild("Head") then
                v.Head.CanCollide = false
            end
            if v.Humanoid:FindFirstChild("Animator") then
                v.Humanoid.Animator:Destroy()
            end
            if not v.HumanoidRootPart:FindFirstChild("Lock") then
                local lock          = Instance.new("BodyVelocity")
                lock.Parent         = v.HumanoidRootPart
                lock.Name           = "Lock"
                lock.MaxForce       = Vector3.new(100000, 100000, 100000)
                lock.Velocity       = Vector3.new(0, 0, 0)
            end

            pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
            v.Humanoid:ChangeState(11)
        end
    end
end

-- Alias para compatibilidade com o farm loop
Functions.BringMobFunc = Functions.BringMob

-- =====================================================
-- NOCLIP (do Tiroreal - com BodyVelocity na Head)
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

-- enableNoclip / disableNoclip (aliases do Tiroreal)
function Functions.EnableNoclip()
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp and not hrp:FindFirstChild("BodyClip") then
        local nc          = Instance.new("BodyVelocity")
        nc.Name           = "BodyClip"
        nc.Parent         = hrp
        nc.MaxForce       = Vector3.new(100000, 100000, 100000)
        nc.Velocity       = Vector3.new(0, 0, 0)
    end
end

function Functions.DisableNoclip()
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp and hrp:FindFirstChild("BodyClip") then
        hrp.BodyClip:Destroy()
    end
end

-- Noclip de colisão para todos os parts (Stepped)
function Functions.DisableCollisions()
    for _, v in pairs(Player.Character:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = false end
    end
end

-- =====================================================
-- FAST ATTACK (do Tiroreal - RegisterHit)
-- =====================================================
function Functions.FastAttack(targetMob, config, notAutoEquipRef)
    if not targetMob or not targetMob.Parent then return end
    local char = Player.Character
    if not char then return end

    -- Equipa arma se necessário
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool and config and config.SelectedWeaponName ~= "" then
        Functions.EquipWeapon(config.SelectedWeaponName, notAutoEquipRef)
        tool = char:FindFirstChildOfClass("Tool")
        if not tool then return end
    end

    -- Caso 1: Blox Fruit (LeftClickRemote)
    if tool and tool:FindFirstChild("LeftClickRemote") then
        local hrp = targetMob:FindFirstChild("HumanoidRootPart")
        if hrp then
            local direction = (hrp.Position - char.HumanoidRootPart.Position).Unit
            pcall(function() tool.LeftClickRemote:FireServer(direction, 1) end)
        end
        return
    end

    -- Caso 2: Net Modules (RegisterAttack / RegisterHit)
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

    -- Caso 3: Gun (RemoteFunctionShoot)
    if tool and tool:FindFirstChild("RemoteFunctionShoot") then
        local hrp = targetMob:FindFirstChild("HumanoidRootPart")
        if hrp then
            pcall(function()
                tool.RemoteFunctionShoot:InvokeServer(hrp.Position, hrp)
            end)
        end
        return
    end

    -- Caso 4: Fallback - VirtualUser click
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(1280, 672))
    end)
end

-- FastAttack avancado (igual ao Tiroreal original com seed)
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
                if #parts > 0 and tool and (tool:GetAttribute("WeaponType") == "Melee" or tool:GetAttribute("WeaponType") == "Sword") then
                    local Net = ReplicatedStorage.Modules.Net
                    pcall(function()
                        Net["RE/RegisterAttack"]:FireServer()
                        local head = parts[1][1]:FindFirstChild("Head")
                        if not head then return end
                        Net["RE/RegisterHit"]:FireServer(head, parts, {}, tostring(Player.UserId):sub(2,4) .. tostring(coroutine.running()):sub(11,15))
                        if remote and idremote then
                            pcall(function()
                                cloneref(remote):FireServer(
                                    string.gsub("RE/RegisterHit", ".", function(c)
                                        return string.char(bit32.bxor(string.byte(c), math.floor(workspace:GetServerTimeNow()/10%10)+1))
                                    end),
                                    bit32.bxor(idremote+909090, Net.seed:InvokeServer()*2), head, parts
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
-- BRING MOB LOOP (do Tiroreal - loop separado)
-- =====================================================
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
                        local hrp    = v.HumanoidRootPart
                        local bPos   = stateRef.BringPos or hrp.CFrame
                        hrp.CFrame = bPos
                        hrp.Size   = Vector3.new(60, 60, 60)
                        hrp.Transparency = 1
                        v.Humanoid.WalkSpeed = 0
                        v.Humanoid.JumpPower = 0
                        hrp.CanCollide = false
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

function Functions.HasActiveQuest(player, mobName)
    local questGui = player.PlayerGui:FindFirstChild("Main")
                     and player.PlayerGui.Main:FindFirstChild("Quest")
    if not questGui then return false end
    if not questGui.Visible then return false end
    local title = ""
    pcall(function()
        title = player.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
    end)
    return string.find(title, mobName, 1, true) ~= nil
end

-- requestEntrance helper (ilhas especiais)
function Functions.RequestEntrance(teleportPos)
    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", teleportPos)
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = hrp.CFrame + Vector3.new(0, 50, 0) end
        task.wait(0.5)
    end)
end

-- CheckNearestTeleporter (do Tiroreal - detecta teleportadores por ilha)
function Functions.CheckNearestTeleporter(pos)
    local vcspos   = pos.Position
    local minDist  = math.huge
    local chosen   = nil
    local y        = game.PlaceId

    local TableLocations = {}
    if y == 2753915549 then
        TableLocations = {
            ["Sky3"]          = Vector3.new(-7894, 5547, -380),
            ["Sky3Exit"]      = Vector3.new(-4607, 874, -1667),
            ["UnderWater"]    = Vector3.new(61163, 11, 1819),
            ["UnderwaterExit"]= Vector3.new(4050, -1, -1814),
        }
    elseif y == 4442272183 then
        TableLocations = {
            ["Swan Mansion"] = Vector3.new(-390, 332, 673),
            ["Cursed Ship"]  = Vector3.new(923, 126, 32852),
            ["Zombie Island"]= Vector3.new(-6509, 83, -133),
        }
    elseif y == 7449423635 then
        TableLocations = {
            ["Floating Turtle"]= Vector3.new(-12462, 375, -7552),
            ["Hydra Island"]   = Vector3.new(5657, 1013, -335),
            ["Castle"]         = Vector3.new(-5036, 315, -3179),
            ["Temple of Time"] = Vector3.new(28286, 14897, 103),
        }
    end

    for _, v in pairs(TableLocations) do
        local dist = (v - vcspos).Magnitude
        if dist < minDist then
            minDist = dist
            chosen  = v
        end
    end

    local playerPos = Player.Character and Player.Character.HumanoidRootPart
                      and Player.Character.HumanoidRootPart.Position
    if playerPos and chosen then
        if minDist <= (vcspos - playerPos).Magnitude then
            return chosen
        end
    end
    return nil
end

-- topos completo do Tiroreal (com PartTele + teleportador de ilha)
function Functions.ToPos(targetCF, config, isTeleportingRef, notAutoEquipRef)
    local char = Player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not hrp or not hum or hum.Health <= 0 then return end

    -- Verifica se precisa passar por um teleportador de ilha
    local nearestTeleport = Functions.CheckNearestTeleporter(targetCF)
    if nearestTeleport then
        Functions.RequestEntrance(nearestTeleport)
    end

    Functions.FlyToPosition(targetCF, TweenService, config, isTeleportingRef, notAutoEquipRef)
end

-- =====================================================
-- ESP - MOBS (circulo verde, do Tiroreal)
-- =====================================================
local mobESP = {}

function Functions.StartMobESP()
    local Camera   = workspace.CurrentCamera
    local MAX_DIST = 5000

    local function createCircle()
        local circle      = Drawing.new("Circle")
        circle.Color      = Color3.fromRGB(0, 255, 0)
        circle.Thickness  = 2
        circle.NumSides   = 50
        circle.Filled     = false
        circle.Radius     = 1.2
        circle.Visible    = true
        return circle
    end

    local function addESP(mob)
        if mobESP[mob] then return end
        local circle = createCircle()
        mobESP[mob]  = circle
        mob.AncestryChanged:Connect(function(_, parent)
            if not parent and mobESP[mob] then
                mobESP[mob]:Remove()
                mobESP[mob] = nil
            end
        end)
    end

    RunService.RenderStepped:Connect(function()
        local char = Player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for mob, circle in pairs(mobESP) do
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
        enemies.ChildAdded:Connect(function(mob) task.wait(0.2); addESP(mob) end)
    end
end

-- ESP Players (BillboardGui, do Tiroreal)
local ESPNumber = math.random(1, 1000000)

function Functions.UpdatePlayerESP(enabled, showTeammates)
    local function isnil(t) return t == nil end
    for _, v in ipairs(Players:GetChildren()) do
        pcall(function()
            if not isnil(v.Character) then
                if enabled then
                    if not isnil(v.Character.Head) and not v.Character.Head:FindFirstChild("NameEsp"..ESPNumber) then
                        local bill = Instance.new("BillboardGui", v.Character.Head)
                        bill.Name  = "NameEsp"..ESPNumber
                        bill.ExtentsOffset = Vector3.new(0, 1, 0)
                        bill.Size  = UDim2.new(1, 200, 1, 30)
                        bill.Adornee    = v.Character.Head
                        bill.AlwaysOnTop = true
                        local name = Instance.new("TextLabel", bill)
                        name.Font = Enum.Font.GothamSemibold
                        name.FontSize   = "Size14"
                        name.TextWrapped = true
                        name.Text = v.Name
                        name.Size = UDim2.new(1, 0, 1, 0)
                        name.TextYAlignment = "Top"
                        name.BackgroundTransparency = 1
                        name.TextStrokeTransparency = 0.5
                        if v.Team == Player.Team then
                            name.TextColor3 = (not showTeammates) and Color3.new(0,1,0) or Color3.new(1,1,0)
                        else
                            name.TextColor3 = Color3.new(1, 0, 0)
                        end
                    elseif not isnil(v.Character.Head) and v.Character.Head:FindFirstChild("NameEsp"..ESPNumber) then
                        local dist = math.floor((Player.Character.Head.Position - v.Character.Head.Position).Magnitude / 3)
                        v.Character.Head["NameEsp"..ESPNumber].TextLabel.Text =
                            v.Name .. " | " .. dist .. "m | HP:" ..
                            math.floor(v.Character.Humanoid.Health * 100 / v.Character.Humanoid.MaxHealth) .. "%"
                    end
                else
                    if v.Character.Head:FindFirstChild("NameEsp"..ESPNumber) then
                        v.Character.Head:FindFirstChild("NameEsp"..ESPNumber):Destroy()
                    end
                end
            end
        end)
    end
end

-- ESP Ilha (do Tiroreal)
function Functions.UpdateIslandESP(enabled)
    local locations = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Locations")
    if not locations then return end
    for _, v in ipairs(locations:GetChildren()) do
        pcall(function()
            if enabled and v.Name ~= "Sea" then
                if not v:FindFirstChild("NameEsp") then
                    local bill = Instance.new("BillboardGui", v)
                    bill.Name  = "NameEsp"
                    bill.ExtentsOffset = Vector3.new(0, 1, 0)
                    bill.Size  = UDim2.new(1, 200, 1, 30)
                    bill.Adornee    = v
                    bill.AlwaysOnTop = true
                    local name = Instance.new("TextLabel", bill)
                    name.Font  = "GothamSemibold"
                    name.FontSize   = "Size14"
                    name.TextWrapped = true
                    name.Size  = UDim2.new(1, 0, 1, 0)
                    name.TextYAlignment = "Top"
                    name.BackgroundTransparency = 1
                    name.TextStrokeTransparency = 0.5
                    name.TextColor3 = Color3.fromRGB(8, 247, 255)
                else
                    local dist = math.floor((Player.Character.Head.Position - v.Position).Magnitude / 3)
                    v.NameEsp.TextLabel.Text = v.Name .. "\n" .. dist .. "m"
                end
            else
                if v:FindFirstChild("NameEsp") then v.NameEsp:Destroy() end
            end
        end)
    end
end

-- ESP Frutas (do Tiroreal)
function Functions.UpdateDevilFruitESP(enabled)
    for _, v in ipairs(workspace:GetChildren()) do
        pcall(function()
            if enabled and string.find(v.Name, "Fruit") and v:FindFirstChild("Handle") then
                if not v.Handle:FindFirstChild("FruitEsp"..ESPNumber) then
                    local bill = Instance.new("BillboardGui", v.Handle)
                    bill.Name  = "FruitEsp"..ESPNumber
                    bill.ExtentsOffset = Vector3.new(0, 1, 0)
                    bill.Size  = UDim2.new(1, 200, 1, 30)
                    bill.Adornee    = v.Handle
                    bill.AlwaysOnTop = true
                    local name = Instance.new("TextLabel", bill)
                    name.Font  = Enum.Font.GothamSemibold
                    name.FontSize   = "Size14"
                    name.TextWrapped = true
                    name.Size  = UDim2.new(1, 0, 1, 0)
                    name.BackgroundTransparency = 1
                    name.TextStrokeTransparency = 0.5
                    name.TextColor3 = Color3.fromRGB(255, 255, 255)
                    local dist = math.floor((Player.Character.Head.Position - v.Handle.Position).Magnitude / 3)
                    name.Text = v.Name .. "\n" .. dist .. "m"
                else
                    local dist = math.floor((Player.Character.Head.Position - v.Handle.Position).Magnitude / 3)
                    v.Handle["FruitEsp"..ESPNumber].TextLabel.Text = v.Name .. "\n" .. dist .. "m"
                end
            else
                if v:FindFirstChild("Handle") and v.Handle:FindFirstChild("FruitEsp"..ESPNumber) then
                    v.Handle["FruitEsp"..ESPNumber]:Destroy()
                end
            end
        end)
    end
end

-- ESP Chest (do Tiroreal)
function Functions.UpdateChestESP(enabled)
    for _, chest in pairs(CollectionService:GetTagged("_ChestTagged")) do
        pcall(function()
            if enabled and not chest:GetAttribute("IsDisabled") then
                if not chest:FindFirstChild("ChestEsp") then
                    local bill = Instance.new("BillboardGui", chest)
                    bill.Name  = "ChestEsp"
                    bill.ExtentsOffset = Vector3.new(0, 1, 0)
                    bill.Size  = UDim2.new(1, 200, 1, 30)
                    bill.Adornee    = chest
                    bill.AlwaysOnTop = true
                    local name = Instance.new("TextLabel", bill)
                    name.Font  = "Code"
                    name.FontSize   = "Size14"
                    name.TextWrapped = true
                    name.Size  = UDim2.new(1, 0, 1, 0)
                    name.TextYAlignment = "Top"
                    name.BackgroundTransparency = 1
                    name.TextStrokeTransparency = 0.5
                    name.TextColor3 = Color3.fromRGB(255, 215, 0)
                else
                    local dist = math.floor((Player.Character.Head.Position - chest:GetPivot().Position).Magnitude / 3)
                    chest.ChestEsp.TextLabel.Text = "Chest\n" .. dist .. "m"
                end
            else
                if chest:FindFirstChild("ChestEsp") then chest.ChestEsp:Destroy() end
            end
        end)
    end
end

-- ESP Berries (do Tiroreal)
function Functions.UpdateBerriesESP(enabled)
    for _, bush in pairs(CollectionService:GetTagged("BerryBush")) do
        pcall(function()
            for attrName, berry in pairs(bush:GetAttributes()) do
                if berry then
                    if enabled then
                        if not bush.Parent:FindFirstChild("BerryESP") then
                            local bill = Instance.new("BillboardGui", bush.Parent)
                            bill.Name  = "BerryESP"
                            bill.ExtentsOffset = Vector3.new(0, 2, 0)
                            bill.Size  = UDim2.new(1, 200, 1, 30)
                            bill.Adornee = bush.Parent
                            bill.AlwaysOnTop = true
                            local name = Instance.new("TextLabel", bill)
                            name.Font  = Enum.Font.GothamSemibold
                            name.TextSize = 14
                            name.TextWrapped = true
                            name.Size  = UDim2.new(1, 0, 1, 0)
                            name.TextYAlignment = Enum.TextYAlignment.Top
                            name.BackgroundTransparency = 1
                            name.TextStrokeTransparency = 0.5
                            name.TextColor3 = Color3.fromRGB(255, 255, 0)
                            name.Text = tostring(berry)
                        end
                        if bush.Parent:FindFirstChild("BerryESP") then
                            local dist = math.floor((bush.Parent:GetPivot().Position - Player.Character.Head.Position).Magnitude)
                            bush.Parent.BerryESP.TextLabel.Text = tostring(berry) .. "\n" .. dist .. "m"
                        end
                    else
                        if bush.Parent:FindFirstChild("BerryESP") then
                            bush.Parent.BerryESP:Destroy()
                        end
                    end
                end
            end
        end)
    end
end

-- ESP Mirage Island (do Tiroreal)
function Functions.UpdateMirageESP(enabled)
    local locations = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Locations")
    if not locations then return end
    for _, v in ipairs(locations:GetChildren()) do
        pcall(function()
            if v.Name == "Mirage Island" then
                if enabled then
                    if not v:FindFirstChild("NameEsp") then
                        local bill = Instance.new("BillboardGui", v)
                        bill.Name  = "NameEsp"
                        bill.ExtentsOffset = Vector3.new(0, 1, 0)
                        bill.Size  = UDim2.new(1, 200, 1, 30)
                        bill.Adornee = v
                        bill.AlwaysOnTop = true
                        local name = Instance.new("TextLabel", bill)
                        name.Font  = "Code"
                        name.FontSize = "Size14"
                        name.TextWrapped = true
                        name.Size  = UDim2.new(1, 0, 1, 0)
                        name.BackgroundTransparency = 1
                        name.TextStrokeTransparency = 0.5
                        name.TextColor3 = Color3.fromRGB(80, 245, 245)
                    else
                        local dist = math.floor((Player.Character.Head.Position - v.Position).Magnitude / 3)
                        v.NameEsp.TextLabel.Text = "Mirage Island\n" .. dist .. "m"
                    end
                else
                    if v:FindFirstChild("NameEsp") then v.NameEsp:Destroy() end
                end
            end
        end)
    end
end

-- =====================================================
-- HOP (do Tiroreal - troca de servidor)
-- =====================================================
function Functions.Hop()
    local PlaceID = game.PlaceId
    local AllIDs  = {}
    local foundAnything = ""
    local actualHour    = os.date("!*t").hour

    local function TPReturner()
        local Site
        if foundAnything == "" then
            Site = game:GetService("HttpService"):JSONDecode(
                game:HttpGet("https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Asc&limit=100"))
        else
            Site = game:GetService("HttpService"):JSONDecode(
                game:HttpGet("https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Asc&limit=100&cursor="..foundAnything))
        end
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
-- AURA AQUA (visual do Tiroreal)
-- =====================================================
function Functions.StartAquaAura()
    task.delay(25, function()
        local function createAura(char)
            if not char then return end
            if char:FindFirstChild("AquaAura") then char.AquaAura:Destroy() end
            local aura = Instance.new("Highlight")
            aura.Name  = "AquaAura"
            aura.FillColor    = Color3.fromRGB(64, 224, 208)
            aura.OutlineColor = Color3.fromRGB(64, 224, 208)
            aura.FillTransparency    = 1
            aura.OutlineTransparency = 1
            aura.Parent = char
        end

        local function onCharAdded(char)
            char:WaitForChild("HumanoidRootPart")
            task.wait(1)
            createAura(char)
            local humanoid = char:WaitForChild("Humanoid")
            local aura     = char:FindFirstChild("AquaAura")
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
-- RAINBOW LABEL (billboard no personagem, do Tiroreal)
-- =====================================================
function Functions.StartRainbowBillboard(text)
    text = text or "Redux Hub"
    local function createBillboard(character)
        if not character then return end
        local head = character:FindFirstChild("Head") or character:FindFirstChildWhichIsA("BasePart")
        if not head then return end
        if head:FindFirstChild("Redux_Label") then head.Redux_Label:Destroy() end
        local billboard = Instance.new("BillboardGui")
        billboard.Name  = "Redux_Label"
        billboard.Adornee     = head
        billboard.AlwaysOnTop = true
        billboard.Size        = UDim2.new(0, 200, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 1.8, 0)
        billboard.Parent      = head
        local label = Instance.new("TextLabel")
        label.Name  = "Label"
        label.Size  = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text  = text
        label.Font  = Enum.Font.SourceSansBold
        label.TextSize = 14
        label.TextStrokeTransparency = 0.6
        label.Parent = billboard
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
-- FPS COUNTER (do Tiroreal)
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
        local now  = tick()
        if now - lastUpdate >= 1 then
            label.Text = string.format("FPS: %d", math.floor(frameCount / (now - lastUpdate)))
            frameCount = 0
            lastUpdate = now
        end
    end)
    task.spawn(function()
        local Dreamon = 0
        while true do
            Dreamon = Dreamon + 0.01
            if Dreamon > 1 then Dreamon = 0 end
            label.TextColor3 = Color3.fromHSV(Dreamon, 1, 1)
            RunService.RenderStepped:Wait()
        end
    end)
end

-- =====================================================
-- COLLECT BERRY (do Tiroreal)
-- =====================================================
function Functions.CollectBerry(config, hopFunc)
    task.spawn(function()
        while task.wait() do
            if not config.AutoCollectBerry then continue end
            local char    = Player.Character
            local pos     = char and char:GetPivot().Position
            if not pos then continue end
            local bushes  = CollectionService:GetTagged("BerryBush")
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
                local model = nearest.Parent
                local center = model:GetPivot().Position
                Functions.TeleportTo(CFrame.new(center + Vector3.new(0, 2, 0)))
                task.wait(0.5)
                local berryPart = model:FindFirstChild(nearestName)
                if berryPart and berryPart:IsA("BasePart") then
                    Functions.TeleportTo(berryPart.CFrame + Vector3.new(0, 1, 0))
                    task.wait(0.3)
                    local VIM = game:GetService("VirtualInputManager")
                    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
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
-- STORE FRUIT (do Tiroreal)
-- =====================================================
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

-- =====================================================
-- CHECK ITEM (do Tiroreal)
-- =====================================================
function Functions.CheckItem(name)
    for _, v in pairs(ReplicatedStorage.Remotes.CommF_:InvokeServer("getInventory")) do
        if v.Name == name then return v end
    end
end

function Functions.CheckItemInCharOrBackpack(name)
    local containers = {Player.Character, Player.Backpack}
    for _, cont in ipairs(containers) do
        if cont:FindFirstChild(name) then
            return cont:FindFirstChild(name)
        end
    end
end

-- =====================================================
-- RAINBOW SKILLS (do Tiroreal - muda cor das skills)
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
-- SAFE MODE (do Tiroreal - sobe se HP baixo)
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
-- REDEEM CODES (do Tiroreal)
-- =====================================================
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
-- AUTO FARM PRINCIPAL (quest + kill loop)
-- =====================================================
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

return Functions