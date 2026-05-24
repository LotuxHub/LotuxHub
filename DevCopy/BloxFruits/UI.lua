-- =====================================================
--         Lotux Hub - Blox Fruits Script
--         by LoadFlint/lucas
--         v3.0 - Modular + Visual Features
-- =====================================================

-- =====================================================
-- LOADING SCREEN - PAINEL VISUAL (v3.1 Redesign)
-- =====================================================
local _Players   = game:GetService("Players")
local _TweenSvc  = game:GetService("TweenService")
local _LocalPl   = _Players.LocalPlayer
local _PGui      = _LocalPl:WaitForChild("PlayerGui")

-- Remove loading gui antiga se existir
pcall(function()
    if _PGui:FindFirstChild("LotuxLoading") then
        _PGui:FindFirstChild("LotuxLoading"):Destroy()
    end
end)

local _LGui = Instance.new("ScreenGui")
_LGui.Name = "LotuxLoading"
_LGui.ResetOnSpawn = false
_LGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
_LGui.DisplayOrder = 9999
_LGui.IgnoreGuiInset = true
_LGui.Parent = _PGui

-- Fundo escuro com gradiente radial simulado
local _BG = Instance.new("Frame")
_BG.Size = UDim2.fromScale(1, 1)
_BG.BackgroundColor3 = Color3.fromRGB(4, 4, 10)
_BG.BackgroundTransparency = 0
_BG.BorderSizePixel = 0
_BG.ZIndex = 1
_BG.Parent = _LGui

-- Gradiente de fundo (canto escuro -> centro levemente iluminado)
local _BGGrad = Instance.new("UIGradient")
_BGGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(8, 4, 20)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(14, 8, 32)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(4, 2, 12)),
})
_BGGrad.Rotation = 135
_BGGrad.Parent = _BG

-- Estrelas decorativas (pontos pequenos no fundo)
local _starPositions = {
    {0.08,0.12},{0.18,0.32},{0.05,0.55},{0.12,0.78},{0.22,0.92},
    {0.32,0.08},{0.45,0.18},{0.38,0.72},{0.28,0.60},{0.42,0.88},
    {0.55,0.05},{0.62,0.28},{0.72,0.15},{0.80,0.40},{0.68,0.62},
    {0.90,0.10},{0.88,0.35},{0.95,0.55},{0.78,0.80},{0.92,0.90},
    {0.50,0.45},{0.60,0.70},{0.35,0.35},{0.15,0.50},{0.75,0.95},
}
for i, sp in ipairs(_starPositions) do
    local star = Instance.new("Frame")
    local sz = math.random(1, 3)
    star.Size = UDim2.fromOffset(sz, sz)
    star.Position = UDim2.fromScale(sp[1], sp[2])
    star.BackgroundColor3 = Color3.fromRGB(
        math.random(180, 255),
        math.random(160, 220),
        math.random(220, 255)
    )
    star.BackgroundTransparency = math.random(30, 70) / 100
    star.BorderSizePixel = 0
    star.ZIndex = 1
    star.Parent = _BG
    Instance.new("UICorner", star).CornerRadius = UDim.new(1, 0)

    -- Animacao de pulsar nas estrelas
    task.spawn(function()
        local delay = math.random(0, 30) / 10
        task.wait(delay)
        while star and star.Parent do
            local t1 = _TweenSvc:Create(star, TweenInfo.new(math.random(10,25)/10, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = math.random(60, 90)/100})
            t1:Play(); t1.Completed:Wait()
            local t2 = _TweenSvc:Create(star, TweenInfo.new(math.random(10,25)/10, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = math.random(0, 30)/100})
            t2:Play(); t2.Completed:Wait()
        end
    end)
end

-- Painel central (mais alto e elegante)
local _Panel = Instance.new("Frame")
_Panel.Size = UDim2.fromOffset(560, 400)
_Panel.Position = UDim2.new(0.5, -280, 0.5, -200)
_Panel.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
_Panel.BorderSizePixel = 0
_Panel.ZIndex = 2
_Panel.Parent = _BG
Instance.new("UICorner", _Panel).CornerRadius = UDim.new(0, 20)

-- Brilho de fundo no painel (glow effect via frame maior e transparente)
local _PanelGlow = Instance.new("Frame")
_PanelGlow.Size = UDim2.new(1, 30, 1, 30)
_PanelGlow.Position = UDim2.new(0, -15, 0, -15)
_PanelGlow.BackgroundColor3 = Color3.fromRGB(80, 40, 200)
_PanelGlow.BackgroundTransparency = 0.88
_PanelGlow.BorderSizePixel = 0
_PanelGlow.ZIndex = 1
_PanelGlow.Parent = _Panel
Instance.new("UICorner", _PanelGlow).CornerRadius = UDim.new(0, 28)

-- Stroke com gradiente simulado (UIStroke nao suporta gradiente nativo)
local _PStroke = Instance.new("UIStroke")
_PStroke.Color = Color3.fromRGB(100, 55, 230)
_PStroke.Thickness = 1.5
_PStroke.Transparency = 0.2
_PStroke.Parent = _Panel

-- Animacao do stroke (pulsa levemente)
task.spawn(function()
    while _PStroke and _PStroke.Parent do
        local t1 = _TweenSvc:Create(_PStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.6})
        t1:Play(); t1.Completed:Wait()
        local t2 = _TweenSvc:Create(_PStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.0})
        t2:Play(); t2.Completed:Wait()
    end
end)

-- Barra topo com gradiente animado
local _AccBar = Instance.new("Frame")
_AccBar.Size = UDim2.new(1, 0, 0, 4)
_AccBar.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
_AccBar.BorderSizePixel = 0
_AccBar.ZIndex = 3
_AccBar.Parent = _Panel
Instance.new("UICorner", _AccBar).CornerRadius = UDim.new(0, 20)
local _AccGrad = Instance.new("UIGradient")
_AccGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(40, 15, 180)),
    ColorSequenceKeypoint.new(0.35, Color3.fromRGB(140, 60, 255)),
    ColorSequenceKeypoint.new(0.65, Color3.fromRGB(200, 100, 255)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(40, 15, 180)),
})
_AccGrad.Parent = _AccBar

-- Animacao do gradiente da barra (efeito shimmer)
task.spawn(function()
    local offset = 0
    while _AccGrad and _AccGrad.Parent do
        offset = (offset + 0.01) % 1
        _AccGrad.Offset = Vector2.new(math.sin(offset * math.pi * 2) * 0.3, 0)
        task.wait(0.05)
    end
end)

-- Icone / Logo area (circulo com inicial animado)
local _LogoBG = Instance.new("Frame")
_LogoBG.Size = UDim2.fromOffset(72, 72)
_LogoBG.Position = UDim2.new(0.5, -36, 0, 22)
_LogoBG.BackgroundColor3 = Color3.fromRGB(18, 12, 40)
_LogoBG.BorderSizePixel = 0
_LogoBG.ZIndex = 4
_LogoBG.Parent = _Panel
Instance.new("UICorner", _LogoBG).CornerRadius = UDim.new(1, 0)
local _LogoStroke = Instance.new("UIStroke")
_LogoStroke.Color = Color3.fromRGB(130, 70, 255)
_LogoStroke.Thickness = 2
_LogoStroke.Parent = _LogoBG
-- Pulsar o logo stroke
task.spawn(function()
    while _LogoStroke and _LogoStroke.Parent do
        local t1 = _TweenSvc:Create(_LogoStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.7})
        t1:Play(); t1.Completed:Wait()
        local t2 = _TweenSvc:Create(_LogoStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.0})
        t2:Play(); t2.Completed:Wait()
    end
end)

local _LogoLabel = Instance.new("TextLabel")
_LogoLabel.Size = UDim2.fromScale(1, 1)
_LogoLabel.BackgroundTransparency = 1
_LogoLabel.Text = "✦"
_LogoLabel.TextColor3 = Color3.fromRGB(190, 140, 255)
_LogoLabel.Font = Enum.Font.GothamBold
_LogoLabel.TextSize = 32
_LogoLabel.ZIndex = 5
_LogoLabel.Parent = _LogoBG
-- Rotacao suave do icone
task.spawn(function()
    local rot = 0
    while _LogoLabel and _LogoLabel.Parent do
        rot = (rot + 0.5) % 360
        _LogoLabel.Rotation = math.sin(rot * math.pi / 180) * 12
        task.wait(0.05)
    end
end)

-- Titulo
local _Title = Instance.new("TextLabel")
_Title.Size = UDim2.new(1, 0, 0, 32)
_Title.Position = UDim2.new(0, 0, 0, 102)
_Title.BackgroundTransparency = 1
_Title.Text = "Lotux Hub"
_Title.TextColor3 = Color3.fromRGB(220, 190, 255)
_Title.Font = Enum.Font.GothamBold
_Title.TextSize = 24
_Title.ZIndex = 3
_Title.Parent = _Panel

-- Efeito shimmer no titulo
task.spawn(function()
    while _Title and _Title.Parent do
        local t1 = _TweenSvc:Create(_Title, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(180, 140, 255)})
        t1:Play(); t1.Completed:Wait()
        local t2 = _TweenSvc:Create(_Title, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(230, 200, 255)})
        t2:Play(); t2.Completed:Wait()
    end
end)

-- Subtitulo
local _Sub = Instance.new("TextLabel")
_Sub.Size = UDim2.new(1, 0, 0, 18)
_Sub.Position = UDim2.new(0, 0, 0, 136)
_Sub.BackgroundTransparency = 1
_Sub.Text = "by LoadFlint/lucas  •  v3.0"
_Sub.TextColor3 = Color3.fromRGB(100, 75, 160)
_Sub.Font = Enum.Font.Gotham
_Sub.TextSize = 12
_Sub.ZIndex = 3
_Sub.Parent = _Panel

-- Separador com gradiente
local _SepFrame = Instance.new("Frame")
_SepFrame.Size = UDim2.new(0.88, 0, 0, 1)
_SepFrame.Position = UDim2.new(0.06, 0, 0, 162)
_SepFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
_SepFrame.BorderSizePixel = 0
_SepFrame.ZIndex = 3
_SepFrame.Parent = _Panel
local _SepGrad = Instance.new("UIGradient")
_SepGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(10, 8, 25)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(80, 45, 180)),
    ColorSequenceKeypoint.new(0.7, Color3.fromRGB(80, 45, 180)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(10, 8, 25)),
})
_SepGrad.Parent = _SepFrame

-- Label status
local _StatusMsg = Instance.new("TextLabel")
_StatusMsg.Size = UDim2.new(1, -30, 0, 20)
_StatusMsg.Position = UDim2.new(0, 15, 0, 172)
_StatusMsg.BackgroundTransparency = 1
_StatusMsg.Text = "⏳  Inicializando Lotux Hub..."
_StatusMsg.TextColor3 = Color3.fromRGB(190, 175, 240)
_StatusMsg.Font = Enum.Font.GothamBold
_StatusMsg.TextSize = 13
_StatusMsg.TextXAlignment = Enum.TextXAlignment.Left
_StatusMsg.ZIndex = 3
_StatusMsg.Parent = _Panel

-- Mini console (frame de fundo)
local _ConFrame = Instance.new("Frame")
_ConFrame.Size = UDim2.new(0.88, 0, 0, 138)
_ConFrame.Position = UDim2.new(0.06, 0, 0, 200)
_ConFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 11)
_ConFrame.BorderSizePixel = 0
_ConFrame.ZIndex = 3
_ConFrame.Parent = _Panel
Instance.new("UICorner", _ConFrame).CornerRadius = UDim.new(0, 10)
local _ConStroke = Instance.new("UIStroke")
_ConStroke.Color = Color3.fromRGB(45, 30, 90)
_ConStroke.Thickness = 1
_ConStroke.Parent = _ConFrame

-- Cabecalho do console
local _ConHeader = Instance.new("Frame")
_ConHeader.Size = UDim2.new(1, 0, 0, 22)
_ConHeader.BackgroundColor3 = Color3.fromRGB(14, 10, 30)
_ConHeader.BorderSizePixel = 0
_ConHeader.ZIndex = 4
_ConHeader.Parent = _ConFrame
Instance.new("UICorner", _ConHeader).CornerRadius = UDim.new(0, 10)
local _ConHeaderLabel = Instance.new("TextLabel")
_ConHeaderLabel.Size = UDim2.fromScale(1, 1)
_ConHeaderLabel.BackgroundTransparency = 1
_ConHeaderLabel.Text = "console"
_ConHeaderLabel.TextColor3 = Color3.fromRGB(70, 50, 130)
_ConHeaderLabel.Font = Enum.Font.Code
_ConHeaderLabel.TextSize = 10
_ConHeaderLabel.ZIndex = 5
_ConHeaderLabel.Parent = _ConHeader

-- ScrollingFrame dentro do console
local _ConScroll = Instance.new("ScrollingFrame")
_ConScroll.Size = UDim2.new(1, -8, 1, -28)
_ConScroll.Position = UDim2.new(0, 4, 0, 24)
_ConScroll.BackgroundTransparency = 1
_ConScroll.BorderSizePixel = 0
_ConScroll.ScrollBarThickness = 3
_ConScroll.ScrollBarImageColor3 = Color3.fromRGB(90, 50, 200)
_ConScroll.ZIndex = 4
_ConScroll.Parent = _ConFrame

local _ConLayout = Instance.new("UIListLayout")
_ConLayout.SortOrder = Enum.SortOrder.LayoutOrder
_ConLayout.Padding = UDim.new(0, 2)
_ConLayout.Parent = _ConScroll

-- Barra de progresso (fundo) - com label de etapa acima
local _StepLabel = Instance.new("TextLabel")
_StepLabel.Size = UDim2.new(0.88, 0, 0, 16)
_StepLabel.Position = UDim2.new(0.06, 0, 0, 345)
_StepLabel.BackgroundTransparency = 1
_StepLabel.Text = "Aguardando..."
_StepLabel.TextColor3 = Color3.fromRGB(90, 65, 155)
_StepLabel.Font = Enum.Font.Gotham
_StepLabel.TextSize = 10
_StepLabel.TextXAlignment = Enum.TextXAlignment.Left
_StepLabel.ZIndex = 3
_StepLabel.Parent = _Panel

local _BarBG = Instance.new("Frame")
_BarBG.Size = UDim2.new(0.88, 0, 0, 16)
_BarBG.Position = UDim2.new(0.06, 0, 0, 362)
_BarBG.BackgroundColor3 = Color3.fromRGB(16, 12, 35)
_BarBG.BorderSizePixel = 0
_BarBG.ZIndex = 3
_BarBG.Parent = _Panel
Instance.new("UICorner", _BarBG).CornerRadius = UDim.new(0, 8)

-- Preenchimento da barra
local _BarFill = Instance.new("Frame")
_BarFill.Size = UDim2.new(0, 0, 1, 0)
_BarFill.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
_BarFill.BorderSizePixel = 0
_BarFill.ZIndex = 4
_BarFill.Parent = _BarBG
Instance.new("UICorner", _BarFill).CornerRadius = UDim.new(0, 8)
local _FillGrad = Instance.new("UIGradient")
_FillGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(70, 25, 200)),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(160, 80, 255)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(200, 120, 255)),
})
_FillGrad.Parent = _BarFill

-- Brilho (shimmer) que percorre a barra
local _BarShimmer = Instance.new("Frame")
_BarShimmer.Size = UDim2.new(0, 30, 1, 0)
_BarShimmer.Position = UDim2.new(-0.1, 0, 0, 0)
_BarShimmer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
_BarShimmer.BackgroundTransparency = 0.75
_BarShimmer.BorderSizePixel = 0
_BarShimmer.ZIndex = 5
_BarShimmer.Parent = _BarFill
Instance.new("UICorner", _BarShimmer).CornerRadius = UDim.new(0, 8)
task.spawn(function()
    while _BarShimmer and _BarShimmer.Parent do
        local t = _TweenSvc:Create(_BarShimmer, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(1.1, 0, 0, 0)})
        t:Play(); t.Completed:Wait()
        _BarShimmer.Position = UDim2.new(-0.15, 0, 0, 0)
        task.wait(0.3)
    end
end)

-- Label de porcentagem (dentro da barra)
local _PctLabel = Instance.new("TextLabel")
_PctLabel.Size = UDim2.fromScale(1, 1)
_PctLabel.BackgroundTransparency = 1
_PctLabel.Text = "0%"
_PctLabel.TextColor3 = Color3.fromRGB(210, 190, 255)
_PctLabel.Font = Enum.Font.GothamBold
_PctLabel.TextSize = 10
_PctLabel.ZIndex = 6
_PctLabel.Parent = _BarBG

-- Versao no rodape do painel
local _Footer = Instance.new("TextLabel")
_Footer.Size = UDim2.new(1, 0, 0, 16)
_Footer.Position = UDim2.new(0, 0, 0, 382)
_Footer.BackgroundTransparency = 1
_Footer.Text = "Lotux Hub  •  Blox Fruits"
_Footer.TextColor3 = Color3.fromRGB(50, 35, 90)
_Footer.Font = Enum.Font.Gotham
_Footer.TextSize = 10
_Footer.ZIndex = 3
_Footer.Parent = _Panel

-- Contador de linhas no console (para layout)
local _conLineCount = 0

-- Animacao de entrada do painel (slide + fade in)
_Panel.Position = UDim2.new(0.5, -280, 0.6, -200)
_Panel.BackgroundTransparency = 1
task.spawn(function()
    task.wait(0.05)
    local tin = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    _TweenSvc:Create(_Panel, tin, {
        Position = UDim2.new(0.5, -280, 0.5, -200),
        BackgroundTransparency = 0,
    }):Play()
end)

-- Funcoes do painel
local function _SetProgress(pct)
    pct = math.clamp(pct, 0, 100)
    _TweenSvc:Create(_BarFill, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(pct / 100, 0, 1, 0)
    }):Play()
    _PctLabel.Text = math.floor(pct) .. "%"
end

local _colorCycle = {
    Color3.fromRGB(140, 110, 220),
    Color3.fromRGB(100, 200, 180),
    Color3.fromRGB(200, 160, 100),
    Color3.fromRGB(140, 110, 220),
}
local _colorIdx = 0

local function _ConsoleLog(msg)
    _conLineCount = _conLineCount + 1
    _colorIdx = (_colorIdx % #_colorCycle) + 1
    local line = Instance.new("TextLabel")
    line.Size = UDim2.new(1, 0, 0, 15)
    line.BackgroundTransparency = 1
    line.Text = "> " .. msg
    line.TextColor3 = _colorCycle[_colorIdx]
    line.Font = Enum.Font.Code
    line.TextSize = 11
    line.TextXAlignment = Enum.TextXAlignment.Left
    line.LayoutOrder = _conLineCount
    line.ZIndex = 5
    line.BackgroundTransparency = 1
    line.Parent = _ConScroll
    -- Auto scroll para o fim
    task.defer(function()
        _ConScroll.CanvasSize = UDim2.new(0, 0, 0, _ConLayout.AbsoluteContentSize.Y + 8)
        _ConScroll.CanvasPosition = Vector2.new(0, math.max(0, _ConScroll.CanvasSize.Y.Offset - _ConScroll.AbsoluteSize.Y))
    end)
end

local function _SetStatus(msg)
    _StatusMsg.Text = "⏳  " .. msg
    _StepLabel.Text = msg
    _ConsoleLog(msg)
    task.wait(0.1)
end

-- Funcao segura de load com retry (CORRIGE O ERRO Load_yb)
local function _SafeLoad(url, nome, retries)
    retries = retries or 5
    task.wait(0.1) -- pequena espera para garantir contexto Roblox pronto
    for i = 1, retries do
        local ok, result = pcall(function()
            local code = game:HttpGet(url, true)
            if not code or code == "" or #code < 10 then
                error("HttpGet retornou vazio/invalido para: " .. nome)
            end
            local fn, compErr = loadstring(code)
            if not fn then
                error("Erro de compilacao em " .. nome .. ": " .. tostring(compErr))
            end
            local runOk, runResult = pcall(fn)
            if not runOk then
                error("Erro de execucao em " .. nome .. ": " .. tostring(runResult))
            end
            return runResult
        end)
        if ok and result ~= nil then
            _ConsoleLog("[OK] " .. nome .. " carregado com sucesso!")
            return result
        else
            local errMsg = tostring(result):sub(1, 80)
            _ConsoleLog("[ERRO " .. i .. "/" .. retries .. "] " .. nome .. ": " .. errMsg)
            warn("[LotuxHub] Falha ao carregar " .. nome .. " (tentativa " .. i .. "): " .. tostring(result))
            if i < retries then
                local waitTime = i * 1.5
                _ConsoleLog("[AGUARDANDO] " .. waitTime .. "s antes de tentar novamente...")
                task.wait(waitTime)
            end
        end
    end
    -- Se falhou tudo, mostra erro critico e retorna tabela vazia
    _ConsoleLog("[CRITICO] " .. nome .. " NAO carregou apos " .. retries .. " tentativas!")
    warn("[LotuxHub] ERRO CRITICO: " .. nome .. " nao carregou! Algumas funcoes podem estar indisponiveis.")
    return setmetatable({}, {
        __index = function(_, k)
            return function(...)
                warn("[LotuxHub] FUNCAO INDISPONIVEL: " .. nome .. "." .. tostring(k) .. " (modulo nao carregou)")
            end
        end
    })
end

-- =====================================================
-- CARREGA MODULOS (COM PAINEL + PCALL + RETRY)
-- =====================================================
local redzlib   = _SafeLoad("https://raw.githubusercontent.com/LotuxHub/LotuxHub/refs/heads/main/Library/LotuxLibrary.lua",  "LotuxLibrary", 3)
local QuestData = _SafeLoad("https://raw.githubusercontent.com/LotuxHub/LotuxHub/refs/heads/main/DevCopy/BloxFruits/Quests.lua",   "Quests",        3)
local Config    = _SafeLoad("https://raw.githubusercontent.com/LotuxHub/LotuxHub/refs/heads/main/DevCopy/BloxFruits/Config.lua",    "Config",        3)
local Functions = _SafeLoad("https://raw.githubusercontent.com/LotuxHub/LotuxHub/refs/heads/main/DevCopy/BloxFruits/Functions.lua", "Functions",     3)

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

-- Arquivo local para salvar idioma entre sessoes
local LANG_SAVE_FILE = "LotuxHub_Language.txt"
local LANG_URL = "https://raw.githubusercontent.com/LotuxHub/LotuxHub/refs/heads/main/DevCopy/BloxFruits/Language.json"

-- Carregar idioma salvo localmente
local function LoadSavedLanguage()
    pcall(function()
        if isfile and isfile(LANG_SAVE_FILE) then
            local saved = readfile(LANG_SAVE_FILE)
            if saved and saved ~= "" then
                CurrentLang = saved:gsub("%s+", "")
            end
        end
    end)
end
LoadSavedLanguage()

-- Salvar idioma no arquivo local
local function SaveLanguage(lang)
    pcall(function()
        if writefile then
            writefile(LANG_SAVE_FILE, lang)
        end
    end)
end

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
    -- Fallback: PlaceId não reconhecido, tenta detectar pelo level
    local ok, level = pcall(function() return Player.Data.Level.Value end)
    if ok and level then
        if level >= 1500 then return 3
        elseif level >= 700 then return 2
        else return 1 end
    end
    warn("[GetSea] PlaceId " .. tostring(game.PlaceId) .. " não reconhecido, usando Sea 1 como fallback.")
    return 1
end

local CurrentSea = GetSea()
World1 = (CurrentSea == 1)
World2 = (CurrentSea == 2)
World3 = (CurrentSea == 3)

-- =====================================================
-- INICIA RESOLVER DE ARMA
-- =====================================================
local ok_wres, err_wres = pcall(function() Functions.StartWeaponResolver(Config) end)
if not ok_wres then
    warn("[LotuxHub] StartWeaponResolver falhou: " .. tostring(err_wres))
    _ConsoleLog("[ERRO] StartWeaponResolver: " .. tostring(err_wres):sub(1,60))
else
    end

-- Inicia loop de haki (substitui o ActivateBuso por frame)
local ok_haki, err_haki = pcall(function() Functions.StartHakiLoop(Config, CommF_) end)
if not ok_haki then
    warn("[LotuxHub] StartHakiLoop falhou: " .. tostring(err_haki))
    _ConsoleLog("[ERRO] StartHakiLoop: " .. tostring(err_haki):sub(1,60))
end

-- Inicia todos os loops das funções do Tiroreal integradas
local ok_loops, err_loops = pcall(function() Functions.StartAllLoops(Config) end)
if not ok_loops then
    warn("[LotuxHub] StartAllLoops falhou: " .. tostring(err_loops))
    _ConsoleLog("[ERRO] StartAllLoops: " .. tostring(err_loops):sub(1,60))
end

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

        -- FIX: NÃO rotaciona o personagem para o alvo (removido CFrame.lookAt)
        -- O ataque funciona sem precisar virar o personagem
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

                if Config.AutoBusoHaki then Functions.AutoHaki() end

                local equipped = false
                for retry = 1, 5 do
                    Functions.ResolveWeaponNow(Config)
                    if Config.SelectedWeaponName and Config.SelectedWeaponName ~= "" then
                        equipped = Functions.EquipWeapon(Config, NotAutoEquip)
                        if equipped then break end
                    end
                    task.wait(0.5)
                end
                if not equipped then
                    warn("[AutoFarmNearest] Nenhuma arma disponível para o tipo: " .. tostring(Config.FarmWeapon))
                end

                currentTarget = mob
                NoClip.value = true

                repeat
                    task.wait()
                    if not mob.Parent then break end
                    local mhrp = mob:FindFirstChild("HumanoidRootPart")
                    if not mhrp then break end
                    BringPos = mhrp.CFrame

                    local distToMob = (mhrp.Position - HumanoidRootPart.Position).Magnitude
                    if distToMob > 15 then
                        Functions.FlyToPosition(mhrp.CFrame * CFrame.new(0, Config.FlyOffset, 0),
                            TweenService, Config, isTeleporting, NotAutoEquip)
                    end

                    if Config.BringMob then
                        local enemiesFolder = workspace:FindFirstChild("Enemies")
                        if enemiesFolder then
                            for _, otherMob in ipairs(enemiesFolder:GetChildren()) do
                                if otherMob ~= mob and otherMob.Name == mob.Name then
                                    local ohrp = otherMob:FindFirstChild("HumanoidRootPart")
                                    local ohum = otherMob:FindFirstChild("Humanoid")
                                    if ohrp and ohum and ohum.Health > 0 then
                                        local distOther = (ohrp.Position - BringPos.Position).Magnitude
                                        if distOther <= Config.BringDistance then
                                            Functions.BringMobFunc(otherMob, BringPos)
                                        end
                                    end
                                end
                            end
                        end
                    end

                    Functions.FastAttack(mob, Config, NotAutoEquip)

                until not mob.Parent
                   or not mob:FindFirstChild("Humanoid")
                   or mob.Humanoid.Health <= 0
                   or (not Config.AutoFarmNearest and not Config.AutoFarmLevel)

                NoClip.value = false
                if mob.Humanoid and mob.Humanoid.Health <= 0 then
                    Config.KillCount = Config.KillCount + 1
                end
                currentTarget = nil
            end)
            farmRunning = false

        elseif Config.AutoFarmLevel then
            pcall(function()
                local quest = Functions.GetQuestForLevel(QuestList, CurrentSea, Player)
                if not quest then farmRunning = false; return end

                if quest.RequestEntrance and HumanoidRootPart then
                    if (quest.CFrameMon.Position - HumanoidRootPart.Position).Magnitude > 10000 then
                        pcall(function() (CommF_ or {}):InvokeServer("requestEntrance", quest.RequestEntrance) end)
                        task.wait(1)
                    end
                end

                local questGui = Player.PlayerGui:FindFirstChild("Main")
                                 and Player.PlayerGui.Main:FindFirstChild("Quest")
                local questVisible = questGui and questGui.Visible or false
                local questTitle = ""
                pcall(function()
                    questTitle = Player.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
                end)

                if not questVisible then
                    currentTarget = nil
                    NoClip.value = false

                    if HumanoidRootPart and (quest.CFrameQuest.Position - HumanoidRootPart.Position).Magnitude > 8 then
                        NoClip.value = true
                        Functions.FlyToPosition(quest.CFrameQuest, TweenService, Config, isTeleporting, NotAutoEquip)
                        NoClip.value = false
                    end

                    task.wait(0.3)
                    pcall(function() (CommF_ or {}):InvokeServer("StartQuest", quest.NameQuest, quest.QuestLv) end)
                    task.wait(0.5)

                    local equipped = false
                    for retry = 1, 5 do
                        Functions.ResolveWeaponNow(Config)
                        if Config.SelectedWeaponName and Config.SelectedWeaponName ~= "" then
                            equipped = Functions.EquipWeapon(Config, NotAutoEquip)
                            if equipped then break end
                        end
                        task.wait(0.5)
                    end
                    if not equipped then
                        warn("[AutoFarm] Não foi possível equipar nenhuma arma do tipo: " .. tostring(Config.FarmWeapon))
                    end
                else
                    local questIsCorrect = string.find(questTitle, quest.Mob, 1, true) ~= nil
                    if not questIsCorrect then
                        currentTarget = nil
                        NoClip.value = false
                        pcall(function() (CommF_ or {}):InvokeServer("AbandonQuest") end)
                        task.wait(0.5)
                    else
                        local mob = Functions.GetNearestEnemy(Character, HumanoidRootPart, quest.Mob)
                        if mob then
                            local hrp = mob:FindFirstChild("HumanoidRootPart")
                            local hum = mob:FindFirstChild("Humanoid")
                            if hrp and hum and hum.Health > 0 then
                                if Config.AutoBusoHaki then Functions.AutoHaki() end

                                if Config.SelectedWeaponName and Config.SelectedWeaponName ~= "" then
                                    Functions.EquipWeapon(Config, NotAutoEquip)
                                end

                                currentTarget = mob
                                NoClip.value = true
                                local bringPosition = hrp.CFrame

                                repeat
                                    task.wait()
                                    if not mob.Parent then break end
                                    local mhrp = mob:FindFirstChild("HumanoidRootPart")
                                    if not mhrp then break end
                                    bringPosition = mhrp.CFrame

                                    local distToMob = (mhrp.Position - HumanoidRootPart.Position).Magnitude
                                    if distToMob > 15 then
                                        Functions.FlyToPosition(mhrp.CFrame * CFrame.new(0, Config.FlyOffset, 0),
                                            TweenService, Config, isTeleporting, NotAutoEquip)
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

                                    Functions.FastAttack(mob, Config, NotAutoEquip)

                                until not mob.Parent
                                   or not mob:FindFirstChild("Humanoid")
                                   or mob.Humanoid.Health <= 0
                                   or not Config.AutoFarmLevel

                                NoClip.value = false
                                if mob.Humanoid and mob.Humanoid.Health <= 0 then
                                    Config.KillCount = Config.KillCount + 1
                                end
                                currentTarget = nil
                            end
                        else
                            currentTarget = nil
                            NoClip.value = true
                            Functions.FlyToPosition(quest.CFrameMon * CFrame.new(0, Config.FlyOffset, 0),
                                TweenService, Config, isTeleporting, NotAutoEquip)
                            NoClip.value = false

                            local rs = game:GetService("ReplicatedStorage")
                            if rs:FindFirstChild(quest.Mob) then
                                local rsMob = rs[quest.Mob]
                                local rsHrp = rsMob:FindFirstChild("HumanoidRootPart")
                                if rsHrp then
                                    NoClip.value = true
                                    Functions.FlyToPosition(rsHrp.CFrame * CFrame.new(0, 20, 0),
                                        TweenService, Config, isTeleporting, NotAutoEquip)
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
local IMG     = "rbxassetid://111672166073808" -- Icone padrao das notificacoes (pode ser trocado por outro link de imagem)
local uiReady = false
local function Notify(cfg)
    if not uiReady then return end
    pcall(function() redzlib:Notify(cfg) end)
end

-- =====================================================
-- CARREGAMENTO COM PORCENTAGEM
-- =====================================================
local function LoadingBar(percent)
    _SetProgress(percent)
end

task.spawn(function()
    for i = 10, 90, 10 do
        LoadingBar(i)
        task.wait(0.2)
    end
end)

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
    { "ui_auto_big_mom",       "AutoBigMom"          },
    { "ui_auto_rip_indra",     "AutoRipIndra"        },
    { "ui_auto_soul_reaper",   "AutoSoulReaper"      },
    { "ui_auto_tyrant",        "AutoTyrantSpawn"     },
    { "ui_auto_farm_bone",     "AutoFarmBone"        },
    { "ui_auto_temple",        "AutoUnlockTemple"    },
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
    { "Auto Gray Beard (Sea 2)",      "AutoGrayBeard"     },
}
for _, t in pairs(sea2Toggles) do
    local key = t[2]
    Main:AddToggle({ Title = T(t[1]), Default = false, Flag = key, Callback = function(v) Config[key] = v end })
end

Main:AddSection(T("sec_farm_sea1"))
local sea1Toggles = {
    { "ui_auto_sea2",       "AutoSea2"        }, { "ui_auto_saber",       "AutoSaber"       },
    { "ui_auto_graybeard",  "AutoGrayBeard"   }, { "ui_auto_darkblade",   "AutoDarkBladeV2" },
    { "Auto Fruit (carregar frutas baratas)", "AutoFruit" },
}
for _, t in pairs(sea1Toggles) do
    local key = t[2]
    Main:AddToggle({ Title = T(t[1]), Default = false, Flag = key, Callback = function(v) Config[key] = v end })
end

Main:AddSection(T("sec_extras"))
Main:AddToggle({ Title = "Auto Skill Z/X/C (loop geral)", Default = false, Flag = "AutoSkill", Callback = function(v) Config.AutoSkill = v end })
Main:AddToggle({ Title = "Farm Chocola Island (mobs)", Default = false, Flag = "FarmChocola", Callback = function(v) Config.FarmChocola = v end })
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
    Default  = CurrentLang,
    Callback = function(v)
        CurrentLang = tostring(v)
        Config.Language = CurrentLang
        -- Salvar idioma no arquivo local para proxima execucao
        SaveLanguage(CurrentLang)
        -- Notificacao pedindo para re-executar o script
        Notify({
            Title       = T("language_restart_title"),
            Description = T("language_restart_desc"),
            Image       = IMG,
            Type        = "Warning",
            Duration    = 8
        })
    end,
})
Settings:AddParagraph({ Title = T("tab_language"), Text = T("ui_lang_list") })

-- =====================================================
-- TAB: ITEMS QUEST (espadas lendárias, boss itens)
-- =====================================================
local ItemsQuest = Window:MakeTab({ Title = T("tab_itemquest"), Icon = "swords" })

if World3 then
    ItemsQuest:AddSection("Espadas Lendárias - Sea 3")
    ItemsQuest:AddToggle({ Title = "Auto Pegar Tushita (Farm Longma)", Default = false,
        Callback = function(v) Config.AutoGetTushita = v
            Notify({ Title = v and "Auto Tushita ON" or "Auto Tushita OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 }) end })
    ItemsQuest:AddToggle({ Title = "Auto Holy Torch (Tochas Tushita)", Default = false,
        Callback = function(v) Config.AutoHolyTorch = v end })
    ItemsQuest:AddToggle({ Title = "Auto Pegar Yama (30 Elite Hunter kills)", Default = false,
        Callback = function(v) Config.AutoYama = v end })
    ItemsQuest:AddToggle({ Title = "Auto Pegar Rengoku (Ice Admiral)", Default = false,
        Callback = function(v) Config.AutoRengoku = v end })
    ItemsQuest:AddSection("Elite Hunter")
    ItemsQuest:AddToggle({ Title = "Auto Farm Elite Hunter (Diablo/Deandre/Urban)", Default = false,
        Callback = function(v) Config.AutoEliteHunter = v end })
    ItemsQuest:AddToggle({ Title = "Server Hop se sem Elite Hunter", Default = false,
        Callback = function(v) Config.AutoEliteHunterHop = v end })
end

if World2 then
    ItemsQuest:AddSection("Espadas Lendárias - Sea 2")
    ItemsQuest:AddToggle({ Title = "Auto Pegar Dark Blade V2", Default = false,
        Callback = function(v) Config.AutoDarkBladeV2 = v end })
    ItemsQuest:AddToggle({ Title = T("ui_auto_buy_ttk"), Default = false,
        Callback = function(v) Config.AutoBuyTTK = v end })
    ItemsQuest:AddToggle({ Title = "Auto Pegar Thunder Pole (Thunder God)", Default = false,
        Callback = function(v)
            Config.AutoGetPole = v
            if v then task.spawn(function() Functions.StartAutoGetPole(Config) end) end
            Notify({ Title = v and "Auto Pole ON" or "Auto Pole OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
        end })
    ItemsQuest:AddToggle({ Title = "Auto Pegar The Saw (Espada)", Default = false,
        Callback = function(v)
            Config.AutoGetSaw = v
            if v then task.spawn(function() Functions.StartAutoGetSaw(Config) end) end
            Notify({ Title = v and "Auto Saw ON" or "Auto Saw OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
        end })
end

if World1 then
    ItemsQuest:AddSection("Itens - Sea 1")
    ItemsQuest:AddToggle({ Title = T("ui_auto_buy_ttk"), Default = false,
        Callback = function(v) Config.AutoBuyTTK = v end })
    ItemsQuest:AddToggle({ Title = "Auto Dark Blade V2", Default = false,
        Callback = function(v) Config.AutoDarkBladeV2 = v end })
end

ItemsQuest:AddSection("Geral")
ItemsQuest:AddToggle({ Title = T("ui_farm_chest"), Default = false,
    Callback = function(v)
        Config.FarmChest = v
        if v then
            task.spawn(function()
                Functions.StartFarmChest(Config, isTeleporting, NotAutoEquip)
            end)
        end
        Notify({ Title = v and "Farm Chest ON - TweenFly" or "Farm Chest OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
ItemsQuest:AddToggle({ Title = "Auto Guardar Frutas no Storage", Default = false,
    Callback = function(v)
        Config.AutoStoreFruit = v
        if v then
            task.spawn(function()
                while Config.AutoStoreFruit do
                    Functions.StoreFruit()
                    task.wait(2)
                end
            end)
        end
        Notify({ Title = v and "Auto Store Fruit ON" or "Auto Store Fruit OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
ItemsQuest:AddToggle({ Title = "Auto Dungeon (avançar ilhas)", Default = false,
    Callback = function(v) Config.AutoDungeon = v end })

-- =====================================================
-- TAB: RACE V4
-- =====================================================
local RaceTab = Window:MakeTab({ Title = T("tab_race"), Icon = "flag" })
RaceTab:AddSection("Raça e Evolução")
RaceTab:AddToggle({ Title = "Auto Quest Race (completar trial de raça)", Default = false,
    Callback = function(v)
        Config.AutoQuestRace = v
        Notify({ Title = v and "Auto Quest Race ON" or "Auto Quest Race OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
RaceTab:AddToggle({ Title = "Auto Race V3 (ativar habilidade V3)", Default = false,
    Callback = function(v) 
        Config.AutoRaceV3 = v 
        if v then
            task.spawn(function()
                while Config.AutoRaceV3 do
                    pcall(function()
                        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.T.Value, false, hrp)
                            task.wait(0.1)
                            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.T.Value, false, hrp)
                        end
                    end)
                    task.wait(0.5)
                end
            end)
        end
        Notify({ Title = v and "Auto active Race V3 ON" or "Auto active Race V3 OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
RaceTab:AddToggle({ Title = "Auto Race V4 (pressionar Y)", Default = false,
    Callback = function(v)
        Config.AutoRaceV4 = v
        if v then
            task.spawn(function()
                while Config.AutoRaceV4 do
                    pcall(function()
                        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Y.Value, false, hrp)
                            task.wait(0.1)
                            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Y.Value, false, hrp)
                        end
                    end)
                    task.wait(0.5)
                end
            end)
        end
        Notify({ Title = v and "Auto active Race V4 ON" or "Auto active Race V4 OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
RaceTab:AddToggle({ Title = "Auto Doo Hee (olhar lua + T para V3 Moon)", Default = false,
    Callback = function(v)
        Config.AutoDooHee = v
        if v then
            task.spawn(function()
                while Config.AutoDooHee do
                    pcall(function()
                        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.T.Value, false, hrp)
                            task.wait(0.1)
                            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.T.Value, false, hrp)
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end })
RaceTab:AddSection("Skills Automáticas")
RaceTab:AddToggle({ Title = T("ui_auto_skill_z"), Default = false,
    Callback = function(v)
        Config.AutoSkillZ = v
        Notify({ Title = v and "Auto Skill Z ON" or "Auto Skill Z OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
RaceTab:AddToggle({ Title = T("ui_auto_skill_x"), Default = false,
    Callback = function(v)
        Config.AutoSkillX = v
        Notify({ Title = v and "Auto Skill X ON" or "Auto Skill X OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
RaceTab:AddToggle({ Title = T("ui_auto_skill_c"), Default = false,
    Callback = function(v)
        Config.AutoSkillC = v
        Notify({ Title = v and "Auto Skill C ON" or "Auto Skill C OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
RaceTab:AddSection("Temple of Time")
RaceTab:AddButton({ Title = "TP Temple of Time", Callback = function()
    pcall(function()
        (CommF_ or {}):InvokeServer("requestEntrance",
            Vector3.new(28286.35546875, 14895.3017578125, 102.62469482421875))
    end)
    Notify({ Title = "Teleportando para Temple of Time", Image = IMG, Type = "Info", Duration = 3 })
end })
RaceTab:AddButton({ Title = "TP Lever Pull", Callback = function()
    if HumanoidRootPart then
        HumanoidRootPart.CFrame = CFrame.new(28575.181640625, 14936.6279296875, 72.31636810302734)
    end
end })
RaceTab:AddButton({ Title = "TP The Clock", Callback = function()
    if HumanoidRootPart then
        HumanoidRootPart.CFrame = CFrame.new(29553.7812, 15066.6133, -88.2750015)
    end
end })
RaceTab:AddButton({ Title = "Comprar Ancient One Quest", Callback = function()
    pcall(function()
        (CommF_ or {}):InvokeServer("UpgradeRace", "Buy")
    end)
    Notify({ Title = "Comprando Ancient One Quest", Image = IMG, Type = "Success", Duration = 3 })
end })

-- =====================================================
-- TAB: VULCAO / PREHISTORIC
-- =====================================================
local VulcaoTab = Window:MakeTab({ Title = T("tab_vulcano"), Icon = "flame" })
VulcaoTab:AddSection("Prehistoric Island")
VulcaoTab:AddToggle({ Title = "Auto Defender Vulcão (Prehistoric)", Default = false,
    Callback = function(v)
        Config.DefendVolcano = v
        Notify({ Title = v and "Defend Vulcão ON" or "Defend Vulcão OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
VulcaoTab:AddToggle({ Title = "Tween para o Vulcão", Default = false,
    Callback = function(v)
        Config.TweenVolcano = v
        if v then
            task.spawn(function()
                while Config.TweenVolcano do
                    pcall(function()
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj.Name == "Volcano" and obj:IsA("BasePart") then
                                Functions.FlyToPosition(obj.CFrame, TweenService, Config, isTeleporting, NotAutoEquip)
                            end
                        end
                    end)
                    task.wait(2)
                end
            end)
        end
    end })
VulcaoTab:AddToggle({ Title = "Auto Encontrar Prehistoric Island", Default = false,
    Callback = function(v)
        Config.AutoFindPrehistoric = v
        if v then
            task.spawn(function()
                while Config.AutoFindPrehistoric do
                    pcall(function()
                        local pre = workspace.Map:FindFirstChild("PrehistoricIsland")
                        if pre then
                            Functions.FlyToPosition(pre:GetPivot(), TweenService, Config, isTeleporting, NotAutoEquip)
                        end
                    end)
                    task.wait(3)
                end
            end)
        end
    end })
VulcaoTab:AddToggle({ Title = "Auto Coletar Ossos (DinoBone)", Default = false,
    Callback = function(v)
        Config.AutoCollectBone = v
        if v then
            task.spawn(function()
                while Config.AutoCollectBone do
                    pcall(function()
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj.Name == "DinoBone" or obj.Name == "Bone" then
                                if HumanoidRootPart then
                                    HumanoidRootPart.CFrame = obj.CFrame
                                end
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end })
VulcaoTab:AddSection("Dragon Quest")
VulcaoTab:AddToggle({ Title = "Auto Farm Mob Dragon (Floating Turtle)", Default = false,
    Callback = function(v) Config.AutoMobDragon = v end })
VulcaoTab:AddToggle({ Title = "Auto Coletar Ovo de Dragão", Default = false,
    Callback = function(v)
        Config.CollectEgg = v
        if v then
            task.spawn(function()
                while Config.CollectEgg do
                    pcall(function()
                        (CommF_ or {}):InvokeServer("CollectEgg")
                    end)
                    task.wait(2)
                end
            end)
        end
    end })

VulcaoTab:AddSection("Lava Golem")
VulcaoTab:AddToggle({ Title = "Auto Kill Lava Golem (Prehistoric Island)", Default = false,
    Callback = function(v)
        Config.AutoKillGolem = v
        if v then task.spawn(function() Functions.StartAutoKillGolem(Config) end) end
        Notify({ Title = v and "Kill Golem ON" or "Kill Golem OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })

-- =====================================================
-- TAB: SEA EVENT
-- =====================================================
local SeaEventTab = Window:MakeTab({ Title = T("tab_seaevent"), Icon = "waves" })
SeaEventTab:AddSection("Ilhas Especiais")
SeaEventTab:AddToggle({ Title = "Auto Tween para Mirage Island", Default = false,
    Callback = function(v)
        Config.AutoMysticIsland = v
        if v then
            task.spawn(function()
                while Config.AutoMysticIsland do
                    pcall(function()
                        local locs = workspace["_WorldOrigin"].Locations
                        local mirage = locs:FindFirstChild("Mirage Island")
                        if mirage and HumanoidRootPart then
                            Functions.FlyToPosition(mirage.CFrame, TweenService, Config, isTeleporting, NotAutoEquip)
                        end
                    end)
                    task.wait(3)
                end
            end)
        end
        Notify({ Title = v and "Auto Mirage Island ON" or "Auto Mirage Island OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
SeaEventTab:AddToggle({ Title = "Tween para Kitsune Island", Default = false,
    Callback = function(v)
        Config.TweenToKitsune = v
        if v then
            task.spawn(function()
                while Config.TweenToKitsune do
                    pcall(function()
                        local kit = workspace.Map:FindFirstChild("KitsuneIsland")
                        if kit and HumanoidRootPart then
                            Functions.FlyToPosition(kit:GetPivot(), TweenService, Config, isTeleporting, NotAutoEquip)
                        end
                    end)
                    task.wait(3)
                end
            end)
        end
    end })
SeaEventTab:AddToggle({ Title = "Auto Azure Ember (TP quando aparecer)", Default = false,
    Callback = function(v)
        Config.AutoAzuerEmber = v
        if v then
            task.spawn(function()
                while Config.AutoAzuerEmber do
                    pcall(function()
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj.Name == "AzureEmber" or obj.Name == "Azure Ember" then
                                if HumanoidRootPart then HumanoidRootPart.CFrame = obj.CFrame end
                            end
                        end
                    end)
                    task.wait(2)
                end
            end)
        end
    end })
SeaEventTab:AddToggle({ Title = "Auto Blaze Ember (TP quando aparecer)", Default = false,
    Callback = function(v)
        Config.AutoBlazeEmber = v
        if v then
            task.spawn(function()
                while Config.AutoBlazeEmber do
                    pcall(function()
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj.Name == "BlazeEmber" or obj.Name == "Blaze Ember" then
                                if HumanoidRootPart then HumanoidRootPart.CFrame = obj.CFrame end
                            end
                        end
                    end)
                    task.wait(2)
                end
            end)
        end
    end })
SeaEventTab:AddSection("Farm Especial Sea 3")
SeaEventTab:AddToggle({ Title = "Auto Farm Hydra Tree (Hydra Island)", Default = false,
    Callback = function(v) Config.AutoHydraTree = v end })
SeaEventTab:AddToggle({ Title = "Auto Navegar Barco (Sea 3)", Default = false,
    Callback = function(v)
        Config.SailBoat = v
        Notify({ Title = v and "Sail Boat ON" or "Sail Boat OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
SeaEventTab:AddToggle({ Title = "Auto Farm Terrorshark", Default = false,
    Callback = function(v) Config.AutoTerrorshark = v end })
SeaEventTab:AddToggle({ Title = "Walk on Water (aumentar base)", Default = false,
    Callback = function(v)
        Config.WalkWater = v
        if v then
            task.spawn(function()
                while Config.WalkWater do
                    pcall(function()
                        local char = Player.Character
                        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp then hrp.Size = Vector3.new(hrp.Size.X, hrp.Size.Y, 20) end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end })
SeaEventTab:AddSection("M-Gear (Mystic Island)")
SeaEventTab:AddToggle({ Title = "Auto Tween para M-Gear (partes Neon)", Default = false,
    Callback = function(v)
        Config.TweenMGear = v
        if v then
            task.spawn(function()
                while Config.TweenMGear do
                    pcall(function()
                        for _, obj in pairs(workspace.Map.MysticIsland:GetChildren()) do
                            if obj.Name == "MeshPart" then
                                Functions.FlyToPosition(obj.CFrame, TweenService, Config, isTeleporting, NotAutoEquip)
                                task.wait(0.5)
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end })

-- =====================================================
-- TAB: FRUTAS / RAID
-- =====================================================
local FruitRaidTab = Window:MakeTab({ Title = T("tab_fruitraid"), Icon = "apple" })
FruitRaidTab:AddSection("Frutas")
FruitRaidTab:AddToggle({ Title = T("ui_twenfly_fruit"), Default = false,
    Callback = function(v)
        Config.TweenFlyFruit = v
        if v then
            task.spawn(function()
                Functions.StartTweenFlyFruit(Config, isTeleporting, NotAutoEquip)
            end)
        end
        Notify({ Title = v and "TweenFly Fruit ON" or "TweenFly Fruit OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
FruitRaidTab:AddToggle({ Title = "Grab Fruit (TP até a fruta)", Default = false,
    Callback = function(v)
        Config.GrabFruit = v
        if v then
            task.spawn(function()
                while Config.GrabFruit do
                    pcall(function()
                        for _, obj in pairs(workspace:GetChildren()) do
                            if obj:IsA("Tool") and obj.Name:find("Fruit") then
                                local h = obj:FindFirstChild("Handle")
                                if h and HumanoidRootPart then
                                    HumanoidRootPart.CFrame = h.CFrame
                                end
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end })
FruitRaidTab:AddToggle({ Title = "Auto Store Fruit (guardar no storage)", Default = false,
    Callback = function(v)
        Config.AutoStoreFruit = v
        if v then
            task.spawn(function()
                while Config.AutoStoreFruit do
                    pcall(function()
                        for _, tool in pairs(Player.Backpack:GetChildren()) do
                            if tool:IsA("Tool") and tool.Name:find("Fruit") then
                                (CommF_ or {}):InvokeServer("StoreFruit", tool:GetAttribute("OriginalName"), tool)
                            end
                        end
                    end)
                    task.wait(3)
                end
            end)
        end
        Notify({ Title = v and "Auto Store Fruit ON" or "Auto Store Fruit OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
FruitRaidTab:AddSection("Raid")
FruitRaidTab:AddToggle({ Title = "Auto Raid (Law - Sea 2)", Default = false,
    Callback = function(v) Config.AutoRaidLaw = v end })
FruitRaidTab:AddToggle({ Title = "Auto Comprar Chip Raid Law", Default = false,
    Callback = function(v) Config.AutoBuyChipRaidLaw = v end })
FruitRaidTab:AddToggle({ Title = "Auto Start Raid Law", Default = false,
    Callback = function(v) Config.AutoStartRaidLaw = v end })
FruitRaidTab:AddToggle({ Title = "Auto Pirate Raid (Sea 3)", Default = false,
    Callback = function(v) Config.AutoPirateRaid = v end })
FruitRaidTab:AddSection("Barista e Berry")
FruitRaidTab:AddToggle({ Title = "Auto Coletar Berry", Default = false,
    Callback = function(v)
        Config.AutoCollectBerry = v
        if v then Functions.StartAutoCollectBerry(Config) end
        Notify({ Title = v and "Auto Berry ON" or "Auto Berry OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
FruitRaidTab:AddToggle({ Title = "Server Hop se sem Berry", Default = false,
    Callback = function(v) Config.AutoCollectBerryHop = v end })
FruitRaidTab:AddToggle({ Title = "Auto Barista (cor de Haki)", Default = false,
    Callback = function(v)
        Config.AutoBarista = v
        if v then Functions.StartAutoBarista(Config) end
    end })
FruitRaidTab:AddDropdown({ Title = "Cor do Haki (Barista)",
    Options = { "White","Black","Red","Blue","Green","Yellow","Purple","Pink" }, Default = "White",
    Callback = function(v) Config.HakiColor = tostring(v) end })

-- =====================================================
-- TAB: PVP / PLAYER HUNTER
-- =====================================================
local PvpTab = Window:MakeTab({ Title = "PvP", Icon = "shield" })
PvpTab:AddSection("Modo PvP")
PvpTab:AddToggle({ Title = "Ativar Modo PvP", Default = false,
    Callback = function(v)
        Config.EnabledPvP = v
        Notify({ Title = v and "Modo PvP ATIVADO" or "Modo PvP Desativado", Image = IMG, Type = v and "Warning" or "Info", Duration = 2 })
    end })
PvpTab:AddToggle({ Title = "Fast Attack (ataque rápido manual)", Default = false,
    Callback = function(v)
        Config.FastAttack = v
        Notify({ Title = v and "Fast Attack ON" or "Fast Attack OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
PvpTab:AddSection("Player Hunter")
PvpTab:AddToggle({ Title = "Auto Player Hunter (TP para alvo)", Default = false,
    Callback = function(v)
        Config.AutoPlayerHunter = v
        if v then
            task.spawn(function()
                while Config.AutoPlayerHunter do
                    pcall(function()
                        local target = Players:FindFirstChild(Config.SelectedPlayer or "")
                        if not target then return end
                        local tChar = target.Character
                        local tHrp  = tChar and tChar:FindFirstChild("HumanoidRootPart")
                        local tHum  = tChar and tChar:FindFirstChildOfClass("Humanoid")
                        if not tHrp or not tHum or tHum.Health <= 0 then return end
                        if HumanoidRootPart then
                            -- só move a posição, não vira o personagem
                            HumanoidRootPart.CFrame = CFrame.new(tHrp.Position + Vector3.new(0, 5, 5))
                        end
                        Functions.EquipWeapon(Config.SelectedWeaponName, NotAutoEquip)
                        tHrp.CanCollide = false
                    end)
                    task.wait(0.1)
                end
            end)
        end
        Notify({ Title = v and "Player Hunter ON" or "Player Hunter OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
PvpTab:AddTextBox({ Title = "Nome do Player Alvo", Default = "", PlaceholderText = "Digite o nome...", ClearText = true,
    Callback = function(v) Config.SelectedPlayer = tostring(v) end })
PvpTab:AddSection("Kill Aura")
PvpTab:AddToggle({ Title = T("ui_kill_aura"), Default = false,
    Callback = function(v)
        Config.KillAura = v
        if v then
            task.spawn(function()
                while Config.KillAura do
                    pcall(function()
                        local char  = Player.Character
                        local myHrp = char and char:FindFirstChild("HumanoidRootPart")
                        if not myHrp then return end
                        local ef = workspace:FindFirstChild("Enemies")
                        if ef then
                            for _, mob in pairs(ef:GetChildren()) do
                                local hum = mob:FindFirstChildOfClass("Humanoid")
                                local hrp = mob:FindFirstChild("HumanoidRootPart")
                                if hum and hrp and hum.Health > 0
                                and (hrp.Position - myHrp.Position).Magnitude <= (Config.KillAuraRadius or 1000) then
                                    hum.Health = 0
                                    hrp.CanCollide = false
                                    pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end)
                                end
                            end
                        end
                    end)
                    task.wait(0.05)
                end
            end)
        end
        Notify({ Title = v and "Kill Aura ON" or "Kill Aura OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
PvpTab:AddSlider({ Title = T("ui_kill_aura_radius"), Min = 100, Max = 3000, Default = 1000,
    Callback = function(v) Config.KillAuraRadius = v end })
PvpTab:AddSection("Safe Mode")
PvpTab:AddToggle({ Title = "Safe Mode (sobe se HP < 20%)", Default = false,
    Callback = function(v)
        Config.SafeMode = v
        if v then
            task.spawn(function()
                while Config.SafeMode do
                    pcall(function()
                        local hum = Humanoid
                        local hrp = HumanoidRootPart
                        if hum and hrp and hum.MaxHealth > 0 then
                            if hum.Health / hum.MaxHealth < 0.2 then
                                hrp.CFrame = hrp.CFrame * CFrame.new(0, 100, 0)
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
        end
        Notify({ Title = v and "Safe Mode ON" or "Safe Mode OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })

PvpTab:AddSection("Auto Kill Player")
PvpTab:AddToggle({ Title = "Auto Kill Player (matar player alvo)", Default = false,
    Callback = function(v)
        Config.AutoKillPlayer = v
        Notify({ Title = v and "Auto Kill ON" or "Auto Kill OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })

PvpTab:AddSection("Aimbot")
PvpTab:AddToggle({ Title = "Aimbot Gun (mira automática com arma)", Default = false,
    Callback = function(v)
        Config.AimbotGun = v
        if v then task.spawn(function() Functions.StartAimbotGun(Config) end) end
        Notify({ Title = v and "Aimbot Gun ON" or "Aimbot Gun OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
PvpTab:AddToggle({ Title = "Aimbot Skill (mira automática com skill)", Default = false,
    Callback = function(v)
        Config.AimbotSkill = v
        if v then task.spawn(function() Functions.StartAimbotSkill(Config) end) end
        Notify({ Title = v and "Aimbot Skill ON" or "Aimbot Skill OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })

PvpTab:AddSection("Criaturas do Mar")
PvpTab:AddToggle({ Title = "Auto Matar Shark (mar)", Default = false,
    Callback = function(v) Config.AutoKillShark = v end })
PvpTab:AddToggle({ Title = "Auto Matar Piranha (mar)", Default = false,
    Callback = function(v) Config.AutoKillPiranha = v end })
PvpTab:AddToggle({ Title = "Auto Matar Fish Crew (mar)", Default = false,
    Callback = function(v) Config.AutoKillFishCrew = v end })

-- =====================================================
-- TAB: SHOP / COMPRAS
-- =====================================================
local ShopTab = Window:MakeTab({ Title = "Compras", Icon = "shoppingbag" })
ShopTab:AddSection("Compras Automáticas")
ShopTab:AddToggle({ Title = T("ui_auto_buy_sword_legends"), Default = false,
    Callback = function(v)
        Config.AutoBuyLegendarySword = v
        if v then task.spawn(function() Functions.StartAutoBuyLegendarySword(Config) end) end
    end })
ShopTab:AddToggle({ Title = "Auto Comprar Cor de Haki (Enhancement)", Default = false,
    Callback = function(v)
        Config.AutoBuyEnhancementColour = v
        if v then task.spawn(function() Functions.StartAutoBuyEnhancement(Config) end) end
    end })
ShopTab:AddToggle({ Title = "Auto Comprar Chip de Raid (Law)", Default = false,
    Callback = function(v) Config.AutoBuyChipRaidLaw = v end })
ShopTab:AddSection("Haki e Combate")
ShopTab:AddToggle({ Title = "Auto Haki V2 (Desbloquear Haki Armamento V2)", Default = false,
    Callback = function(v) Config.AutoHakiV2 = v end })
ShopTab:AddToggle({ Title = "Auto Farm Observação Haki", Default = false,
    Callback = function(v) Config.AutoFarmObsHaki = v end })
ShopTab:AddSection("Estilos de Luta - Sea 2")
ShopTab:AddToggle({ Title = "Auto Sharkman V2 (Sea 2)", Default = false,
    Callback = function(v) Config.AutoSharkmanV2 = v end })
ShopTab:AddToggle({ Title = "Auto Death Step (Sea 2)", Default = false,
    Callback = function(v) Config.AutoDeathStep = v end })
ShopTab:AddSection("Estilos de Luta - Sea 3")
ShopTab:AddToggle({ Title = "Auto God Human (Sea 3)", Default = false,
    Callback = function(v) Config.AutoGodHuman = v end })
ShopTab:AddToggle({ Title = "Auto Electric Claw (Sea 3)", Default = false,
    Callback = function(v) Config.AutoElectricClaw = v end })
ShopTab:AddToggle({ Title = "Auto Dragon Taylor (Sea 3)", Default = false,
    Callback = function(v) Config.AutoDragonTaylor = v end })
ShopTab:AddSection("Resgatar Códigos")
ShopTab:AddButton({ Title = "Resgatar Todos os Códigos", Callback = function()
    Notify({ Title = "Códigos", Description = "Resgatando códigos...", Image = IMG, Type = "Info", Duration = 3 })
    task.spawn(function() Functions.RedeemAllCodes() end)
end })
ShopTab:AddSection("Info do Script")
ShopTab:AddParagraph({ Title = "Lotux Hub", Text =
    "by LoadFlint/lucas\n" ..
    "[>] Auto Farm Level + Quest Fix\n" ..
    "[>] Auto Farm Nearest\n" ..
    "[>] ESP completo (mobs, players, ilhas, frutas, baus, berries)\n" ..
    "[>] Aura Aqua, Rainbow Skills, Billboard\n" ..
    "[>] Self Highlight + FPS Counter\n" ..
    "[>] Race V4, Items Quest, Sea Events\n" ..
    "[>] PVP: Kill Aura, Player Hunter\n" ..
    "[>] Sea 1/2/3 detectado automaticamente"
})

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
local Misc = Window:MakeTab({ Title = "Misc", Icon = "calendarsearch" })
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
Misc:AddButton({ Title = "Hop (sair e re-entrar servidor)", Callback = function()
    task.spawn(function() Functions.Hop() end)
end })

Misc:AddSection("Factory e Bosses (Sea 2)")
Misc:AddToggle({ Title = "Auto Factory (Sea 2)", Default = false,
    Callback = function(v) Config.AutoFactory = v end })
Misc:AddToggle({ Title = "Auto Dark Beard (Sea 2)", Default = false,
    Callback = function(v) Config.AutoDarkBeard = v end })
Misc:AddToggle({ Title = "Auto Bartilo Quest (acesso Sea 3)", Default = false,
    Callback = function(v) Config.AutoBartilo = v end })
Misc:AddToggle({ Title = "Auto Chief Warden (Farm)", Default = false,
    Callback = function(v)
        Config.ChiefWarden = v
        Notify({ Title = v and "Chief Warden ON" or "Chief Warden OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
Misc:AddToggle({ Title = "Auto Cursed Captain (Farm)", Default = false,
    Callback = function(v)
        Config.CursedCaptain = v
        Notify({ Title = v and "Cursed Captain ON" or "Cursed Captain OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })

Misc:AddSection("Bosses Especiais (Sea 3)")
Misc:AddToggle({ Title = "Auto Dough King (Sea 3)", Default = false,
    Callback = function(v) Config.AutoDoughKing = v end })
Misc:AddToggle({ Title = "Auto Cake Prince (Sea 3)", Default = false,
    Callback = function(v) Config.AutoCakePrince = v end })

Misc:AddSection("Auto Farm Frutas (Mastery)")
Misc:AddDropdown({ Title = "Tipo de Farm de Frutas",
    Options = { "Farm Level Mastery", "Farm Level Mastery No Quest", "Farm Bone Mastery", "Farm Cake Mastery" },
    Default = "Farm Level Mastery",
    Callback = function(v) Config.SelectFruitFarm = v end })
Misc:AddToggle({ Title = "Auto Farm com Frutas (Mastery)", Default = false,
    Callback = function(v)
        Config.AutoFarmFruits = v
        if v then task.spawn(function() Functions.StartAutoFarmFruits(Config) end) end
        Notify({ Title = v and "Farm Frutas ON" or "Farm Frutas OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })

Misc:AddSection("Pray / Luck")
Misc:AddToggle({ Title = "Auto Pray (Altar/Shrine)", Default = false,
    Callback = function(v)
        Config.AutoPray = v
        if v then task.spawn(function() Functions.StartAutoPray(Config) end) end
    end })
Misc:AddToggle({ Title = "Auto Try Luck", Default = false,
    Callback = function(v)
        Config.AutoTryLuck = v
        if v then task.spawn(function() Functions.StartAutoTryLuck(Config) end) end
    end })
Misc:AddToggle({ Title = "Auto Trade Bone (DinoBone)", Default = false,
    Callback = function(v)
        Config.AutoTradeBone = v
        if v then task.spawn(function() Functions.StartAutoTradeBone(Config) end) end
    end })

Misc:AddSection("Skills Individuais")
Misc:AddToggle({ Title = "Auto Skill Z", Default = false,
    Callback = function(v) Config.AutoSkillZ = v end })
Misc:AddToggle({ Title = "Auto Skill X", Default = false,
    Callback = function(v) Config.AutoSkillX = v end })
Misc:AddToggle({ Title = "Auto Skill C", Default = false,
    Callback = function(v) Config.AutoSkillC = v end })

Misc:AddSection(T("sec_script_info"))
Misc:AddParagraph({ Title = "Lotux Hub v3.0 - Modular", Text =
    "Lotux Hub Update v1.2\n" ..
    "[>] Auto Farm com Quest Fix\n" ..
    "[>] ESP Circulo Verde + SelectionBox\n" ..
    "[>] Aqua Aura, Rainbow Skills, Billboard\n" ..
    "[>] Self Highlight + FPS Counter\n" ..
    "[>] Sea 1, 2 e 3 detectado automaticamente"
})
Misc:AddButton({ Title = T("ui_close_ui"), Callback = function() Window:CloseBtn() end })

-- =====================================================
-- INICIA FEATURES ATIVAS POR PADRAO
-- =====================================================

-- Sem neblina por padrao
Lighting.FogEnd = Config.NoFog and 100000 or 1000

-- =====================================================
-- FINALIZACAO
-- =====================================================
uiReady = true

-- Fecha o painel de loading com animacao suave
task.spawn(function()
    task.wait(0.3)
    pcall(function()
        _SetProgress(100)
        _StatusMsg.Text = "✅  Lotux Hub carregado com sucesso!"
        _StatusMsg.TextColor3 = Color3.fromRGB(100, 255, 150)
        _ConsoleLog("[OK] Script pronto! Sea " .. tostring(CurrentSea))
        task.wait(1.2)
        -- Fade out
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = game:GetService("TweenService"):Create(_BG, tweenInfo, {BackgroundTransparency = 1})
        local tween2 = game:GetService("TweenService"):Create(_Panel, tweenInfo, {BackgroundTransparency = 1})
        tween:Play()
        tween2:Play()
        task.wait(0.6)
        _LGui:Destroy()
    end)
end)

print("[LotuxHub] ✅ Carregado! v1.2 | Sea " .. CurrentSea .. " | by LoadFlint/lucas")

Notify({
    Title       = "Lotux Hub v1.2 Carregado!",
    Description = "Sea " .. CurrentSea .. " | PlaceId: " .. game.PlaceId,
    Image       = IMG,
    Duration    = 5,
    Type        = "Success",
})