-- Functions.lua
-- Funcoes de autofarm, voo, trazer mob, quest e utilitarios

local Functions = {}

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
-- DETECTAR SEA (corrigido para servidor publico Sea 2)
-- PlaceIds conhecidos:
--   Sea 1 privado  : 2753915549
--   Sea 2 privado  : 4442272183
--   Sea 2 publico  : 79091703265657  (PlaceId diferente!)
--   Sea 3 privado  : 7449423635
-- Se aparecer um PlaceId desconhecido, usa o level do player como fallback.
-- =====================================================
function Functions.DetectCurrentSea()
    local placeId = game.PlaceId
    local player = game:GetService("Players").LocalPlayer
    local placeIdToSea = {
        [2753915549] = 1, -- Sea 1 privado
        [4442272183] = 2, -- Sea 2 privado
        [79091703265657] = 2, -- Sea 2 publico
        [7449423635] = 3, -- Sea 3 privado
    }
    local sea = placeIdToSea[placeId]
    if sea then return sea end
    local placeIdPublic = {
        [] = 1,
        [79091703265657] = 2,
        [] = 3
    }
    local placeIdPrivate = {
        [2753915549] = 1,
        [4442272183] = 2,
        [7449423635] = 3
    }
    -- Sea 3: PlaceId unico, sempre confiavel
    if placeIdPrivate[placeId] == 3 or placeIdPublic[placeId] == 3 then
        return 3
    end

    -- Sea 2: privado OU publico
    if placeIdPrivate[placeId] == 2 or placeIdPublic[placeId] == 2 then
        return 2
    end

    -- Sea 1: PlaceId padrao
    if placeIdPrivate[placeId] == 1 or placeIdPublic[placeId] == 1 then
        return 1
    end

    if placeIdToSea[placeId] then
        return placeIdToSea[placeId]
    end

    -- order fallback: tenta detecta pelo place ID normal sem precisa de usa "local" pra achar

    if placeId == 2753915549 then
        return 1
    end

    if placeId == 4442272183 or placeId == 79091703265657 then
        return 2
    end

    if placeId == 7449423635 then
        return 3
    end

end

-- =====================================================
-- RESOLVE WEAPON NAME (loop identico ao Tiroreal)
-- Fica rodando em background e atualiza Config.SelectedWeaponName
-- com o nome real da tool que bate com o tipo selecionado (ToolTip).
-- Chame Functions.StartWeaponResolver(Config) uma unica vez no init.
-- =====================================================
function Functions.StartWeaponResolver(config)
    task.spawn(function()
        local player = game:GetService("Players").LocalPlayer
        while task.wait(0.5) do
            pcall(function()
                local tipo = config.FarmWeapon
                local tooltip = tipo
                if tipo == "BloxFruits" then tooltip = "Blox Fruit" end

                local found = false
                -- Procura no backpack
                for _, tool in pairs(player.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool.ToolTip == tooltip then
                        if player.Backpack:FindFirstChild(tool.Name) then
                            config.SelectedWeaponName = tool.Name
                            found = true
                            break
                        end
                    end
                end
                -- Se não achou, procura no personagem (já equipada)
                if not found and player.Character then
                    for _, tool in pairs(player.Character:GetChildren()) do
                        if tool:IsA("Tool") and tool.ToolTip == tooltip then
                            config.SelectedWeaponName = tool.Name
                            found = true
                            break
                        end
                    end
                end
                -- Fallback: tenta qualquer arma que contenha o tipo no nome (caso ToolTip não seja confiável)
                if not found then
                    for _, tool in pairs(player.Backpack:GetChildren()) do
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
-- EQUIP WEAPON (logica exata do Tiroreal)
-- =====================================================
function Functions.EquipWeapon(weaponName, notAutoEquipRef)
    -- Se não forneceu nome, tenta pegar do Config (caso chamada antiga)
    if type(weaponName) == "table" then
        -- Se for tabela (Config), tenta extrair SelectedWeaponName
        if weaponName.SelectedWeaponName then
            weaponName = weaponName.SelectedWeaponName
        else
            warn("EquipWeapon: primeiro argumento inválido (tabela sem SelectedWeaponName)")
            return
        end
    end
    if type(weaponName) ~= "string" or weaponName == "" then return end

    local notAuto = notAutoEquipRef and notAutoEquipRef.value or _G.NotAutoEquip
    if notAuto then return end

    local tool = game.Players.LocalPlayer.Backpack:FindFirstChild(weaponName)
    if tool then
        game.Players.LocalPlayer.Character.Humanoid:EquipTool(tool)
        task.wait(0.1)
    else
        warn("Arma não encontrada no Backpack: " .. tostring(weaponName))
    end
end

-- =====================================================
-- UNEQUIP WEAPON
-- =====================================================
function Functions.UnEquipWeapon(config, notAutoEquipRef)
    pcall(function()
        local player = game:GetService("Players").LocalPlayer
        local char   = player.Character
        if not char then return end
        local tool = char:FindFirstChild(config.SelectedWeaponName)
        if tool then
            if notAutoEquipRef then notAutoEquipRef.value = true end
            task.wait(0.5)
            tool.Parent = player.Backpack
            task.wait(0.1)
            if notAutoEquipRef then notAutoEquipRef.value = false end
        end
    end)
end

-- =====================================================
-- GET NEAREST ENEMY
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
    if #folders == 0 then table.insert(folders, workspace) end

    for _, folder in ipairs(folders) do
        local list = (folder == workspace)
            and workspace:GetDescendants()
            or folder:GetChildren()
        for _, obj in ipairs(list) do
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
-- FLY (PartTele - metodo Tiroreal)
-- =====================================================
function Functions.FlyToPosition(targetCF, tweenService, config, isTeleportingRef, notAutoEquipRef)
    local player = game:GetService("Players").LocalPlayer
    local char   = player.Character
    local hrp    = char and char:FindFirstChild("HumanoidRootPart")
    local hum    = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not hrp or not hum or hum.Health <= 0 then return end

    local distance = (targetCF.Position - hrp.Position).Magnitude
    if distance < 2 then return end

    if notAutoEquipRef then notAutoEquipRef.value = true end

    if not char:FindFirstChild("PartTele") then
        local pt          = Instance.new("Part", char)
        pt.Size           = Vector3.new(10, 1, 10)
        pt.Name           = "PartTele"
        pt.Anchored       = true
        pt.Transparency   = 1
        pt.CanCollide     = false
        pt.CFrame         = hrp.CFrame

        pt:GetPropertyChangedSignal("CFrame"):Connect(function()
            if not isTeleportingRef or not isTeleportingRef.value then return end
            task.wait()
            local c = player.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                c.HumanoidRootPart.CFrame = pt.CFrame
            end
        end)
    end

    if isTeleportingRef then isTeleportingRef.value = true end

    local speed = tonumber(config.FlySpeed) or 60
    local dur = math.clamp(distance / speed, 0.05, 60.0)

    local tween = tweenService:Create(
        char.PartTele,
        TweenInfo.new(dur, Enum.EasingStyle.Linear),
        { CFrame = targetCF }
    )
    tween:Play()

    local RunService = game:GetService("RunService")
    local conn
    conn = RunService.Heartbeat:Connect(function()
        local c = player.Character
        if not c then conn:Disconnect(); return end
        local cHrp = c:FindFirstChild("HumanoidRootPart")
        local pt   = c:FindFirstChild("PartTele")
        if cHrp and pt then
            cHrp.CFrame = pt.CFrame
        else
            conn:Disconnect()
        end
    end)

    tween.Completed:Wait()
    conn:Disconnect()

    if isTeleportingRef then isTeleportingRef.value = false end
    if notAutoEquipRef  then notAutoEquipRef.value  = false end

    if char:FindFirstChild("PartTele") then
        char.PartTele:Destroy()
    end
end

-- =====================================================
-- BRING MOB (BodyVelocity Lock - Tiroreal)
-- =====================================================
function Functions.BringMob(mobName, targetPosition)
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, v in ipairs(workspace.Enemies:GetChildren()) do
        if v.Name == mobName 
           and v:FindFirstChild("HumanoidRootPart") 
           and v:FindFirstChild("Humanoid") 
           and v.Humanoid.Health > 0 
           and (v.HumanoidRootPart.Position - hrp.Position).Magnitude <= 350 then
            
            v.HumanoidRootPart.CFrame = targetPosition or v.HumanoidRootPart.CFrame
            v.Humanoid.JumpPower = 0
            v.Humanoid.WalkSpeed = 0
            v.HumanoidRootPart.Transparency = 1
            v.HumanoidRootPart.CanCollide = false
            v.Head.CanCollide = false

            if v.Humanoid:FindFirstChild("Animator") then
                v.Humanoid.Animator:Destroy()
            end

            if not v.HumanoidRootPart:FindFirstChild("Lock") then
                local lock = Instance.new("BodyVelocity")
                lock.Parent = v.HumanoidRootPart
                lock.Name = "Lock"
                lock.MaxForce = Vector3.new(100000, 100000, 100000)
                lock.Velocity = Vector3.new(0, 0, 0)
            end

            sethiddenproperty(player, "SimulationRadius", math.huge)
            v.Humanoid:ChangeState(11) -- PhysicsStateType: PlatformStand
        end
    end
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
                local bv        = Instance.new("BodyVelocity", head)
                bv.P            = 1500
                bv.Name         = "NoClipLock"
                bv.MaxForce     = Vector3.new(0, 100000, 0)
                bv.Velocity     = Vector3.new(0, 0, 0)
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

-- =====================================================
-- ATIVAR BUSO HAKI
-- =====================================================
function Functions.ActivateBuso(commF_)
    pcall(function() commF_:InvokeServer("Buso") end)
end

-- =====================================================
-- QUEST: pega a quest certa para o level/sea atual
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

-- =====================================================
-- QUEST: checa se ja tem quest ativa pelo nome/mob
-- =====================================================
function Functions.HasActiveQuest(commF_, player, questName, mobName)
    local ok, qData = pcall(function()
        return commF_:InvokeServer("GetCurrentQuest")
    end)
    if ok and type(qData) == "table" and qData.Name == questName then
        return true
    end
    -- fallback: checa GUI
    for _, gui in ipairs(player.PlayerGui:GetDescendants()) do
        if gui:IsA("TextLabel") then
            local txt = gui.Text or ""
            if txt:find(mobName, 1, true) or txt:find(questName, 1, true) then
                return true
            end
        end
    end
    return false
end

-- =====================================================
-- QUEST: verifica se a quest foi completada pela GUI
-- =====================================================
function Functions.IsQuestCompleted(player)
    for _, gui in ipairs(player.PlayerGui:GetDescendants()) do
        if gui:IsA("TextLabel") and gui.Name == "QuestProgress" then
            local txt = gui.Text or ""
            if txt:lower():find("complete") or txt:find("0") then
                return true
            end
        end
    end
    return false
end

-- =====================================================
-- AUTOFARM PRINCIPAL (corrigido)
--
-- CORRECOES APLICADAS:
--
-- [FIX 1 - Quest nao pega apos completar]
-- O problema era: quando Quest.Visible == false (quest completada),
-- o codigo chamava AbandonQuest() antes de pegar nova quest.
-- Isso cancelava a recompensa/xp e deixava o loop travado.
-- Agora: Quest.Visible == false = apenas vai pegar nova quest.
--        AbandonQuest() so ocorre quando a quest ATIVA e a errada
--        (Quest.Visible == true mas o mob nao bate com NameMon).
--
-- [FIX 2 - Deteccao de Sea errada em servidor publico]
-- Servidor publico do Sea 2 tem PlaceId 79091703265657, diferente
-- do privado (4442272183). A funcao DetectCurrentSea() cobre ambos
-- e ainda usa o level como fallback para PlaceIds desconhecidos.
--
-- Como usar:
--   local sea = Functions.DetectCurrentSea()
--   local quest = Functions.GetQuestForLevel(QuestData.QuestList, sea, player)
--   Functions.StartAutoFarm(quest, commF_, config, notAutoEquipRef)
-- =====================================================
function Functions.StartAutoFarm(quest, commF_, config, notAutoEquipRef)
    if not quest then return end

    local player    = game:GetService("Players").LocalPlayer
    local CommF_    = commF_
    local NameMon   = quest.Mob
    local NameQuest = quest.NameQuest
    local LevelQuest= quest.QuestLv
    local CFrameQuest = quest.CFrameQuest
    local CFrameMon   = quest.CFrameMon
    local ReqEntrance = quest.RequestEntrance

    -- Flag interna: acabou de sair de uma quest (completada ou nao iniciada)
    -- Usada para evitar AbandonQuest no momento errado
    local justFinished = false

    task.spawn(function()
        while config.AutoFarmLevel do
            pcall(function()
                local char = player.Character
                if not char then task.wait(1); return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hrp or not hum or hum.Health <= 0 then task.wait(1); return end

                local questGui = player.PlayerGui:FindFirstChild("Main")
                    and player.PlayerGui.Main:FindFirstChild("Quest")

                local questVisible = questGui and questGui.Visible or false

                -- -----------------------------------------------
                -- ESTADO: sem quest ativa (Quest.Visible == false)
                -- -> vai ao NPC pegar a quest
                -- NAO chama AbandonQuest aqui!
                -- -----------------------------------------------
                if not questVisible then
                    justFinished = false
                    config.StartBring = false

                    -- Se precisa de entrance (ilha especial)
                    if ReqEntrance then
                        local dist = (hrp.Position - CFrameQuest.Position).Magnitude
                        if dist > 10000 then
                            pcall(function()
                                CommF_:InvokeServer("requestEntrance", ReqEntrance)
                            end)
                            task.wait(1)
                        end
                    end

                    -- Vai ao NPC da quest
                    local tweenService = game:GetService("TweenService")
                    Functions.FlyToPosition(CFrameQuest, tweenService, config, nil, notAutoEquipRef)

                    -- Chega perto o suficiente -> aceita quest
                    local distToQuest = (hrp.Position - CFrameQuest.Position).Magnitude
                    if distToQuest <= 25 then
                        task.wait(0.3)
                        pcall(function()
                            CommF_:InvokeServer("StartQuest", NameQuest, LevelQuest)
                        end)
                        task.wait(0.5)
                    end

                -- -----------------------------------------------
                -- ESTADO: quest ativa (Quest.Visible == true)
                -- -----------------------------------------------
                else
                    local questTitle = ""
                    pcall(function()
                        questTitle = player.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
                    end)

                    -- Quest ativa e a errada -> abandona e pega a certa
                    if not string.find(questTitle, NameMon, 1, true) then
                        if not justFinished then
                            config.StartBring = false
                            pcall(function()
                                CommF_:InvokeServer("AbandonQuest")
                            end)
                            task.wait(0.5)
                            justFinished = true
                        end
                        return
                    end

                    justFinished = false

                    -- Quest certa ativa -> procura e mata o mob
                    local Enemies = workspace:FindFirstChild("Enemies")
                    if Enemies and Enemies:FindFirstChild(NameMon) then
                        for _, mob in pairs(Enemies:GetChildren()) do
                            if mob.Name == NameMon then
                                local mobHrp = mob:FindFirstChild("HumanoidRootPart")
                                local mobHum = mob:FindFirstChild("Humanoid")
                                local mobHead = mob:FindFirstChild("Head")
                                if mobHrp and mobHum and mobHum.Health > 0 then
                                    config.StartBring = true
                                    repeat
                                        task.wait()
                                        -- Equipa arma
                                        Functions.EquipWeapon(config, notAutoEquipRef)
                                        -- Haki
                                        Functions.ActivateBuso(CommF_)
                                        -- Trava mob
                                        mobHrp.CanCollide = false
                                        mobHum.WalkSpeed  = 0
                                        if mobHead then mobHead.CanCollide = false end
                                        mobHrp.Size = Vector3.new(70, 70, 70)
                                        -- Voa ate o mob
                                        local tweenService = game:GetService("TweenService")
                                        Functions.FlyToPosition(
                                            mobHrp.CFrame * CFrame.new(0, 30, 0),
                                            tweenService, config, nil, notAutoEquipRef
                                        )
                                        -- Ataque virtual (igual Tiroreal)
                                        pcall(function()
                                            game:GetService("VirtualUser"):CaptureController()
                                            game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 672))
                                        end)
                                    until not config.AutoFarmLevel
                                        or not mob.Parent
                                        or mobHum.Health <= 0
                                        or not questVisible
                                    config.StartBring = false
                                end
                            end
                        end
                    else
                        -- Mob nao encontrado no workspace -> vai ate a posicao do mob
                        local tweenService = game:GetService("TweenService")
                        Functions.FlyToPosition(CFrameMon, tweenService, config, nil, notAutoEquipRef)
                        -- Tenta pegar pelo ReplicatedStorage (spawn pendente)
                        local rs = game:GetService("ReplicatedStorage")
                        if rs:FindFirstChild(NameMon) then
                            local rsMob = rs:FindFirstChild(NameMon)
                            local rsMobHrp = rsMob:FindFirstChild("HumanoidRootPart")
                            if rsMobHrp then
                                Functions.FlyToPosition(
                                    rsMobHrp.CFrame * CFrame.new(0, 20, 0),
                                    tweenService, config, nil, notAutoEquipRef
                                )
                            end
                        end
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
end

-- =====================================================
-- FAST ATTACK
-- =====================================================
function Functions.FastAttack(targetMob, config, notAutoEquipRef)
    if not targetMob or not targetMob.Parent then return end
    local player = game:GetService("Players").LocalPlayer
    local char = player.Character
    if not char then return end

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Net = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
    
    -- Equipa a arma se não tiver nenhuma
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then
        local weaponName = config.SelectedWeaponName
        if weaponName and weaponName ~= "" then
            Functions.EquipWeapon(weaponName, notAutoEquipRef)
        else
            return
        end
        tool = char:FindFirstChildOfClass("Tool")
        if not tool then return end
    end

    -- Caso 1: Fruta/Blox Fruit (usa LeftClickRemote)
    if tool:FindFirstChild("LeftClickRemote") then
        local hrp = targetMob:FindFirstChild("HumanoidRootPart")
        if hrp then
            local direction = (hrp.Position - char.HumanoidRootPart.Position).Unit
            pcall(function()
                tool.LeftClickRemote:FireServer(direction, 1)
            end)
        end
        return
    end

    -- Caso 2: Tenta usar os remotes avançados (funciona para mobs e players)
    if Net then
        local RegisterAttack = Net:FindFirstChild("RE/RegisterAttack")
        local RegisterHit    = Net:FindFirstChild("RE/RegisterHit")
        if RegisterAttack and RegisterHit then
            local parts = {}
            for _, part in pairs(targetMob:GetChildren()) do
                if part:IsA("BasePart") then
                    table.insert(parts, part)
                end
            end
            local head = targetMob:FindFirstChild("Head") or targetMob:FindFirstChild("HumanoidRootPart")
            if head then
                RegisterAttack:FireServer(0)
                RegisterHit:FireServer(head, parts)
                return
            end
        end
    end

    -- Caso 3: Fallback universal (para qualquer arma corpo a corpo)
    -- Isso funciona para players e mobs quando os remotes não estão disponíveis
    pcall(function()
        tool:Activate()
        -- Simula clique do mouse para garantir o ataque
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 672))
    end)
end


function AutoHaki()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return end

    -- Verifica se já tem Haki ativo (por um atributo ou pelo efeito visual)
    local hasBuso = character:FindFirstChild("HasBuso") or character:FindFirstChild("Buso") or character:FindFirstChild("HakiActive")
    if hasBuso then return end

    -- Tenta ativar
    local remote = game:GetService("ReplicatedStorage").Remotes.CommF_
    if remote then
        remote:InvokeServer("Buso")
        -- Em alguns jogos é "KenHaki" ou "ActivateBuso"
        -- remote:InvokeServer("KenHaki") 
    end
end


return Functions
-- =============================
-- INTEGRAÇÃO TIROREAL: ESP, Aura, FastAttack, FPS, Notificações
-- =============================

-- ESP Mobs (círculo verde)
function Functions.EnableMobESP()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer
    local mobESP = {}
    local MAX_DISTANCE = 5000
    local function createCircle()
        local circle = Drawing.new("Circle")
        circle.Color = Color3.fromRGB(0, 255, 0)
        circle.Thickness = 2
        circle.NumSides = 50
        circle.Filled = false
        circle.Radius = 1.2
        circle.Visible = true
        return circle
    end
    local function addESP(mob)
        if mobESP[mob] then return end
        local circle = createCircle()
        mobESP[mob] = circle
        mob.AncestryChanged:Connect(function(_, parent)
            if not parent then
                if mobESP[mob] then
                    mobESP[mob]:Remove()
                    mobESP[mob] = nil
                end
            end
        end)
    end
    RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for mob, circle in pairs(mobESP) do
            if mob and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChildOfClass("Humanoid") and mob.Humanoid.Health > 0 then
                local distance = (mob.HumanoidRootPart.Position - hrp.Position).Magnitude
                if distance <= MAX_DISTANCE then
                    local pos, onScreen = Camera:WorldToViewportPoint(mob.HumanoidRootPart.Position)
                    if onScreen then
                        circle.Position = Vector2.new(pos.X, pos.Y)
                        circle.Visible = true
                    else
                        circle.Visible = false
                    end
                else
                    circle.Visible = false
                end
            else
                circle.Visible = false
            end
        end
    end)
    for _, mob in ipairs(workspace.Enemies:GetChildren()) do
        addESP(mob)
    end
    workspace.Enemies.ChildAdded:Connect(function(mob)
        task.wait(0.2)
        addESP(mob)
    end)
end

-- Aura azul (Highlight)
function Functions.EnableAquaAura()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer
    local function createAquaAura(char)
        if not char then return end
        if char:FindFirstChild("AquaAura") then
            char.AquaAura:Destroy()
        end
        local aura = Instance.new("Highlight")
        aura.Name = "AquaAura"
        aura.FillColor = Color3.fromRGB(64, 224, 208)
        aura.OutlineColor = Color3.fromRGB(64, 224, 208)
        aura.FillTransparency = 1
        aura.OutlineTransparency = 1
        aura.Parent = char
    end
    local function onCharacterAdded(char)
        char:WaitForChild("HumanoidRootPart")
        task.wait(1)
        createAquaAura(char)
        local humanoid = char:WaitForChild("Humanoid")
        local aura = char:FindFirstChild("AquaAura")
        local floatTime = 0
        RunService.RenderStepped:Connect(function(dt)
            if not humanoid or not aura then return end
            if humanoid.FloorMaterial == Enum.Material.Air then
                floatTime += dt
                if floatTime >= 3 then
                    aura.FillTransparency = 0.3
                    aura.OutlineTransparency = 0
                end
            else
                floatTime = 0
                aura.FillTransparency = 1
                aura.OutlineTransparency = 1
            end
        end)
    end
    if LocalPlayer.Character then
        onCharacterAdded(LocalPlayer.Character)
    end
    LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
end

-- Notificações (exemplo de uso)
function Functions.ShowTirorealNotifications()
    local Notification = require(game:GetService("ReplicatedStorage").Notification)
    local msgs = {
        "<Color=Blue>Chúc Mừng 2026 Và tạm Biệt 2025<Color=/>",
        "<Color=Blue>Chúc Mọi Người Tết Vui Vẻ<Color=/>",
        "<Color=Blue>Bác Hồ Chí Minh Muôn Năm<Color=/>",
        "<Color=Blue>Bác Hồ Vĩ Đại Muôn Năm<Color=/>",
        "<Color=Blue>Năm Mới Chúc Nước Việt Nam Vui Vẻ<Color=/>",
        "<Color=Blue>Cali con cặc tuổi lồn<Color=/>",
        "<Color=Blue>Thằng Diệm Liệt Não ăn cứt<Color=/>",
        "<Color=Blue>Tiro Hub yêu Bác Hồ<Color=/>",
    }
    for _, msg in ipairs(msgs) do
        Notification.new(msg):Display()
        task.wait(3)
    end
end

-- FPS Counter (exemplo simples)
function Functions.EnableFPSCounter()
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local screenGui = Instance.new("ScreenGui")
    local textLabel = Instance.new("TextLabel")
    screenGui.Parent = game.CoreGui
    screenGui.DisplayOrder = 100
    textLabel.Parent = screenGui
    textLabel.Size = UDim2.new(0, 200, 0, 40)
    textLabel.Position = UDim2.new(0, 10, 0, 10)
    textLabel.Font = Enum.Font.FredokaOne
    textLabel.TextScaled = false
    textLabel.TextSize = 20
    textLabel.BackgroundTransparency = 1
    textLabel.TextStrokeTransparency = 0
    local frameCount = 0
    local lastUpdate = tick()
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = tick()
        if now - lastUpdate >= 1 then
            local fps = frameCount / (now - lastUpdate)
            frameCount = 0
            lastUpdate = now
            textLabel.Text = string.format("FPS: %d", math.floor(fps))
        end
    end)
    -- Rainbow color
    spawn(function()
        local Dreamon = 0
        while true do
            Dreamon = Dreamon + 0.01
            if Dreamon > 1 then Dreamon = 0 end
            textLabel.TextColor3 = Color3.fromHSV(Dreamon, 1, 1)
            RunService.RenderStepped:Wait()
        end
    end)
end

-- FastAttack (simplificado, pode ser expandido)
function Functions.EnableFastAttack()
    _G.FastAttack = true
    local _ENV = (getgenv or getrenv or getfenv)()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local Player = Players.LocalPlayer
    local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not Remotes then return end
    local Net = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
    if not Net then return end
    local RegisterAttack = Net:FindFirstChild("RE/RegisterAttack")
    local RegisterHit = Net:FindFirstChild("RE/RegisterHit")
    local Enemies = workspace:FindFirstChild("Enemies")
    local Characters = workspace:FindFirstChild("Characters")
    local Settings = { AutoClick = true, ClickDelay = 0.0000000000001 }
    local function IsAlive(character)
        return character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0
    end
    local function ProcessEnemies(OthersEnemies, Folder)
        for _, Enemy in Folder:GetChildren() do
            local Head = Enemy:FindFirstChild("Head")
            if Head and IsAlive(Enemy) and Player:DistanceFromCharacter(Head.Position) < 500 then
                if Enemy ~= Player.Character then
                    table.insert(OthersEnemies, { Enemy, Head })
                end
            end
        end
    end
    local function Attack(BasePart, OthersEnemies)
        if not BasePart or #OthersEnemies == 0 then return end
        RegisterAttack:FireServer(Settings.ClickDelay or 0)
        RegisterHit:FireServer(BasePart, OthersEnemies)
    end
    local function AttackNearest()
        local OthersEnemies = {}
        ProcessEnemies(OthersEnemies, Enemies)
        ProcessEnemies(OthersEnemies, Characters)
        local character = Player.Character
        if not character then return end
        local equippedWeapon = character:FindFirstChildOfClass("Tool")
        if equippedWeapon and equippedWeapon:FindFirstChild("LeftClickRemote") then
            for _, enemyData in ipairs(OthersEnemies) do
                local enemy = enemyData[1]
                local direction = (enemy.HumanoidRootPart.Position - character:GetPivot().Position).Unit
                pcall(function()
                    equippedWeapon.LeftClickRemote:FireServer(direction, 1)
                end)
            end
        elseif #OthersEnemies > 0 then
            Attack(OthersEnemies[1][2], OthersEnemies)
        else
            task.wait(0)
        end
    end
    task.spawn(function()
        while task.wait(Settings.ClickDelay) do
            if Settings.AutoClick then
                AttackNearest()
            end
        end
    end)
end