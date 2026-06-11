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
local SaveSystem = _SafeLoad("https://raw.githubusercontent.com/LotuxHub/LotuxHub/refs/heads/main/DevCopy/BloxFruits/SaveSystem.lua", "SaveSystem",  3)

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
local BringPos      = CFrame.new(0, -10, 0)

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

-- URL do arquivo de idioma
local LANG_URL = "https://raw.githubusercontent.com/LotuxHub/LotuxHub/refs/heads/main/DevCopy/BloxFruits/Language.json"

-- Carrega idioma salvo via SaveSystem (pasta por conta)
local function LoadSavedLanguage()
    if SaveSystem then
        local saved = SaveSystem.LoadLanguage()
        if saved and saved ~= "" then
            CurrentLang = saved
        end
    end
end
LoadSavedLanguage()

-- Salva idioma via SaveSystem
local function SaveLanguage(lang)
    if SaveSystem then
        SaveSystem.SaveLanguage(lang)
    end
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
-- INICIA SAVE SYSTEM (carrega configs salvas da conta)
-- =====================================================
if SaveSystem then
    SaveSystem.Init(Config)
    -- Sincroniza idioma que o SaveSystem pode ter restaurado
    CurrentLang = Config.Language or CurrentLang
end

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

local function _acLog(msg) end -- logs removidos

task.spawn(function()
    while task.wait(0.12) do
        if not Config.AutoClick then continue end

        local char = Player.Character
        if not char then
            _acLog("SKIP: Player.Character e nil")
            continue
        end
        local localHrp = char:FindFirstChild("HumanoidRootPart")
        local localHum = char:FindFirstChildOfClass("Humanoid")
        if not localHrp then
            _acLog("SKIP: HumanoidRootPart nao encontrado no char")
            continue
        end
        if not localHum then
            _acLog("SKIP: Humanoid nao encontrado no char")
            continue
        end
        if localHum.Health <= 0 then
            _acLog("SKIP: Player morto (Health <= 0)")
            continue
        end

        local bestTarget, bestDist = nil, math.huge

        local enemies = workspace:FindFirstChild("Enemies")
        if not enemies then
            _acLog("SKIP: workspace.Enemies nao existe")
            continue
        end

        local totalEnemies = 0
        for _, obj in ipairs(enemies:GetChildren()) do
            if obj:IsA("Model") and obj ~= char then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health > 0 then
                    totalEnemies = totalEnemies + 1
                    local d = (hrp.Position - localHrp.Position).Magnitude
                    if d < bestDist then bestDist = d; bestTarget = obj end
                end
            end
        end

        if Config.KillAura or Config.EnabledPvP then
            for _, otherPlayer in ipairs(Players:GetPlayers()) do
                if otherPlayer ~= Player then
                    local otherChar = otherPlayer.Character
                    if otherChar then
                        local hum = otherChar:FindFirstChildOfClass("Humanoid")
                        local hrp = otherChar:FindFirstChild("HumanoidRootPart")
                        if hum and hrp and hum.Health > 0 then
                            local d = (hrp.Position - localHrp.Position).Magnitude
                            if d < bestDist then bestDist = d; bestTarget = otherChar end
                        end
                    end
                end
            end
        end

        if not bestTarget then
            _acLog("SKIP: Nenhum inimigo vivo encontrado (total na pasta: " .. totalEnemies .. ")")
            continue
        end

        local hrpTarget = bestTarget:FindFirstChild("HumanoidRootPart")
        if not hrpTarget then
            _acLog("SKIP: alvo '" .. bestTarget.Name .. "' sem HumanoidRootPart")
            continue
        end

        local dist = (hrpTarget.Position - localHrp.Position).Magnitude
        if dist > 60 then
            _acLog("SKIP: alvo '" .. bestTarget.Name .. "' longe demais (" .. math.floor(dist) .. " studs, max 60)")
            continue
        end

        _acLog("ATACANDO: '" .. bestTarget.Name .. "' | dist: " .. math.floor(dist) .. " studs")
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
            -- Para o voo e derruba o player ao desativar o farm
            if NoClip.value or farmRunning then
                NoClip.value        = false
                isTeleporting.value = false
                Functions.StopTeleport()
                -- Remove qualquer BodyVelocity/BodyPosition que esteja mantendo o player no ar
                pcall(function()
                    local char = Player.Character
                    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        for _, obj in ipairs(hrp:GetChildren()) do
                            if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
                                obj:Destroy()
                            end
                        end
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) end
                    end
                end)
            end
            farmRunning = false
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

                local equipped = Functions.EquipWeapon(Config, NotAutoEquip)
                if not equipped then
                    warn("[AutoFarmNearest] Nenhuma arma do tipo '" .. tostring(Config.FarmWeapon) .. "' encontrada no Backpack.")
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

                    -- BringMob: puxa mobs para o chão embaixo do player
                    -- Usa raycast para achar o chão real, evita flutuar ou afundar
                    if Config.BringMob then
                        local function GetGroundBelow(pos)
                            local rayResult = workspace:Raycast(
                                pos + Vector3.new(0, 5, 0),
                                Vector3.new(0, -200, 0),
                                RaycastParams.new()
                            )
                            if rayResult then
                                return rayResult.Position.Y + 3  -- 3 studs acima do chão
                            end
                            return pos.Y - 3  -- fallback: 3 studs abaixo do HRP
                        end
                        local pp = HumanoidRootPart.Position
                        local groundY = GetGroundBelow(pp)
                        local playerBringPos = CFrame.new(pp.X, groundY, pp.Z)
                        local _ = playerBringPos and true
                        if playerBringPos then
                            local enemiesFolder = workspace:FindFirstChild("Enemies")
                            if enemiesFolder then
                                for _, otherMob in ipairs(enemiesFolder:GetChildren()) do
                                    if otherMob.Name == mob.Name then
                                        local ohrp = otherMob:FindFirstChild("HumanoidRootPart")
                                        local ohum = otherMob:FindFirstChild("Humanoid")
                                        if ohrp and ohum and ohum.Health > 0 then
                                            local distOther = (ohrp.Position - HumanoidRootPart.Position).Magnitude
                                            if distOther <= Config.BringDistance then
                                                Functions.BringMobFunc(otherMob, playerBringPos)
                                            end
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

                -- Submerged Island (level 2600+): usa remote especial, nao requestEntrance nem FlyTo
                local isSubmerged = string.find(quest.NameQuest or "", "SubmergedQuest", 1, true) ~= nil
                if isSubmerged then
                    -- So viaja se ainda nao estiver la embaixo (Y < -500)
                    local jaEstaLa = HumanoidRootPart and HumanoidRootPart.Position.Y < -500
                    if not jaEstaLa then
                        print("[AutoFarm] Indo para Submerged Island via remote...")
                        local chegou = Functions.TravelToSubmergedIsland(Config)
                        if not chegou then
                            warn("[AutoFarm] Nao conseguiu chegar na Submerged Island, tentando novamente...")
                            farmRunning = false
                            return
                        end
                        task.wait(1.5)
                    end
                    -- Atualiza HRP apos teleporte
                    local char2 = Player.Character
                    if not char2 then farmRunning = false; return end
                    HumanoidRootPart = char2:FindFirstChild("HumanoidRootPart") or HumanoidRootPart
                elseif quest.RequestEntrance and HumanoidRootPart then
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

                    if HumanoidRootPart and (quest.CFrameQuest.Position - HumanoidRootPart.Position).Magnitude > 8 then
                        -- Mantem NoClip ativo se estiver na Submerged (Y < -500) para nao afundar
                        local naSubmerged = HumanoidRootPart.Position.Y < -500
                        if not naSubmerged then NoClip.value = false end
                        NoClip.value = true
                        Functions.FlyToPosition(quest.CFrameQuest, TweenService, Config, isTeleporting, NotAutoEquip)
                        NoClip.value = false
                    else
                        NoClip.value = false
                    end

                    task.wait(0.3)
                    pcall(function() (CommF_ or {}):InvokeServer("StartQuest", quest.NameQuest, quest.QuestLv) end)
                    task.wait(0.5)

                    local equipped = Functions.EquipWeapon(Config, NotAutoEquip)
                    if not equipped then
                        warn("[AutoFarm] Nenhuma arma do tipo '" .. tostring(Config.FarmWeapon) .. "' encontrada no Backpack.")
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

                                Functions.EquipWeapon(Config, NotAutoEquip)

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

                                    -- BringMob: puxa mobs para o chão embaixo do player
                                    if Config.BringMob then
                                        local function GetGroundBelow2(pos)
                                            local rp = workspace:Raycast(
                                                pos + Vector3.new(0, 5, 0),
                                                Vector3.new(0, -200, 0),
                                                RaycastParams.new()
                                            )
                                            return rp and (rp.Position.Y + 3) or (pos.Y - 3)
                                        end
                                        local pp2 = HumanoidRootPart.Position
                                        local playerBringPos = CFrame.new(pp2.X, GetGroundBelow2(pp2), pp2.Z)
                                        if playerBringPos then
                                            local enemiesFolder = workspace:FindFirstChild("Enemies")
                                            if enemiesFolder then
                                                for _, otherMob in ipairs(enemiesFolder:GetChildren()) do
                                                    if otherMob.Name == quest.Mob then
                                                        local ohrp = otherMob:FindFirstChild("HumanoidRootPart")
                                                        local ohum = otherMob:FindFirstChild("Humanoid")
                                                        if ohrp and ohum and ohum.Health > 0 then
                                                            local distOther = (ohrp.Position - HumanoidRootPart.Position).Magnitude
                                                            if distOther <= Config.BringDistance then
                                                                Functions.BringMobFunc(otherMob, playerBringPos)
                                                            end
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
                            -- Voa ate a posicao dos mobs (CFrameMon) com NoClip ativo
                            -- Funciona tanto na superficie quanto na Submerged Island
                            NoClip.value = true
                            Functions.FlyToPosition(quest.CFrameMon * CFrame.new(0, Config.FlyOffset, 0),
                                TweenService, Config, isTeleporting, NotAutoEquip)
                            NoClip.value = false
                            task.wait(1)
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

-- Variavel separada para FarmWeapon (evita bug da redzlib que sobrescreve Config com tabela)
_G._FarmWeapon = "Melee"
Main:AddDropdown({
    Title    = T("ui_farm_weapon"),
    Options  = { "Melee", "Sword", "Gun", "BloxFruits" },
    Default  = "Melee",
    Callback = function(v)
        -- Extrai string do valor (a redzlib pode passar tabela ou string)
        local weaponStr = type(v) == "table" and (v.Value or v[1] or v.Name or v.Text) or tostring(v)
        -- Valida e seta _G._FarmWeapon
        local validos = { Melee=true, Sword=true, Gun=true, BloxFruits=true }
        if validos[weaponStr] then
            _G._FarmWeapon = weaponStr
        end
        Config.SelectedWeaponName = ""
        -- Equipa a nova arma imediatamente
        task.spawn(function()
            task.wait(0.1)
            Functions.EquipWeapon(Config, NotAutoEquip)
        end)
        Notify({ Title = "Farm Weapon: " .. (_G._FarmWeapon or "Melee"), Image = IMG, Type = "Info", Duration = 2 })
    end,
})
Main:AddDropdown({
    Title    = T("ui_farm_attack"),
    Options  = { "Normal", "FastAttack", "SuperFastAttack" },
    Default  = "Normal",
    Callback = function(v) Config.FarmAttack = (type(v) == "table" and (v[1] or next(v)) or tostring(v)) end,
})

Main:AddSection("Farm Normal")
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

Main:AddSection("Farm Sea 3")
Main:AddToggle({ Title = "Auto Pirate Raid",   Default = false, Flag = "AutoPirateRaid", Callback = function(v) Config.AutoPirateRaid   = v end })
Main:AddToggle({ Title = "Auto Rip Indra",     Default = false, Flag = "AutoRipIndra", Callback = function(v) Config.AutoRipIndra     = v end })
Main:AddToggle({ Title = "Auto Tyrant Spawn",  Default = false, Flag = "AutoTyrantSpawn", Callback = function(v) Config.AutoTyrantSpawn  = v end })
Main:AddToggle({ Title = "Auto Soul Reaper",   Default = false, Flag = "AutoSoulReaper", Callback = function(v) Config.AutoSoulReaper   = v end })
Main:AddToggle({ Title = "Auto Big Mom",        Default = false, Flag = "AutoBigMom", Callback = function(v) Config.AutoBigMom       = v end })
Main:AddToggle({ Title = "Auto Farm Bone",      Default = false, Flag = "AutoFarmBone", Callback = function(v) Config.AutoFarmBone     = v end })
Main:AddToggle({ Title = "Auto Cake Prince",    Default = false, Flag = "AutoCakePrince", Callback = function(v) Config.AutoCakePrince   = v end })
Main:AddToggle({ Title = "Auto Dough King",     Default = false, Flag = "AutoDoughKing", Callback = function(v) Config.AutoDoughKing    = v end })

Main:AddSection("Farming (Sea 2)")
Main:AddToggle({ Title = "Auto Sea 3",          Default = false, Flag = "AutoSea3", Callback = function(v) Config.AutoSea3        = v end })
Main:AddToggle({ Title = "Auto Factory",        Default = false, Flag = "AutoFactory", Callback = function(v) Config.AutoFactory     = v end })

Main:AddSection("Farming (Sea 1)")
Main:AddToggle({ Title = "Auto Sea 2",          Default = false, Flag = "AutoSea2", Callback = function(v) Config.AutoSea2        = v end })
Main:AddToggle({ Title = "Auto Spawn Darkbeard",Default = false, Flag = "AutoDarkBeard", Callback = function(v) Config.AutoDarkBeard   = v end })

Main:AddSection("Farm Boss")
Main:AddDropdown({ Title = T("ui_select_boss"), Options = Bosses[CurrentSea], Default = Bosses[CurrentSea][1],
    Callback = function(v) Config.SelectedBoss = (type(v) == "table" and (v[1] or next(v)) or tostring(v)) end })
Main:AddToggle({ Title = T("ui_auto_farm_boss"),      Default = false, Flag = "AutoFarmBoss", Callback = function(v) Config.AutoFarmBoss     = v end })
Main:AddToggle({ Title = T("ui_auto_farm_all_boss"),  Default = false, Flag = "AutoFarmAllBoss", Callback = function(v) Config.AutoFarmAllBoss  = v end })
Main:AddToggle({ Title = T("ui_auto_farm_raid_boss"), Default = false, Flag = "AutoFarmRaidBoss", Callback = function(v) Config.AutoFarmRaidBoss = v end })

Main:AddSection("Material")
Main:AddDropdown({ Title = T("ui_select_material"), Options = Materials[CurrentSea], Default = Materials[CurrentSea][1],
    Callback = function(v) Config.SelectedMaterial = (type(v) == "table" and (v[1] or next(v)) or tostring(v)) end })
Main:AddToggle({ Title = T("ui_auto_material"), Default = false, Flag = "AutoFarmMaterial", Callback = function(v) Config.AutoFarmMaterial = v end })

Main:AddSection("Mastery")
Main:AddDropdown({ Title = T("ui_mastery_weapon"), Options = { "Gun","Sword","Melee","BloxFruits" }, Default = "Gun",
    Callback = function(v) Config.MasteryWeapon = (type(v) == "table" and (v[1] or next(v)) or tostring(v)) end })
Main:AddSlider({ Title = "Health Kill Mob (%)", Min = 1, Max = 100, Default = 30,
    Flag = "HealthKillMob", Callback = function(v) Config.HealthKillMob = v end })
Main:AddDropdown({ Title = T("ui_selection_island"), Options = Islands[CurrentSea], Default = Islands[CurrentSea][1],
    Callback = function(v) Config.MasteryIsland = (type(v) == "table" and (v[1] or next(v)) or tostring(v)) end })
Main:AddDropdown({
    Title       = "Mastery Skills",
    Options     = { "Z", "X", "C", "V", "F" },
    Default     = {},
    MultiSelect = true,
    Flag = "MasterySkills", Callback    = function(v)
        Config.MasterySkills = v
    end,
})
Main:AddToggle({ Title = T("ui_auto_mastery"), Default = false,
    Flag = "AutoFarmMastery", Callback = function(v)
        Config.AutoFarmMastery = v
        if v then
            task.spawn(function()
                local keyMap = {
                    Z = Enum.KeyCode.Z,
                    X = Enum.KeyCode.X,
                    C = Enum.KeyCode.C,
                    V = Enum.KeyCode.V,
                    F = Enum.KeyCode.F,
                }
                while Config.AutoFarmMastery do
                    local skills = Config.MasterySkills or {}
                    for key, _ in pairs(skills) do
                        if not Config.AutoFarmMastery then break end
                        local kc = keyMap[key]
                        if kc then
                            pcall(function()
                                game:GetService("VirtualInputManager"):SendKeyEvent(true,  kc, false, game)
                                task.wait(0.05)
                                game:GetService("VirtualInputManager"):SendKeyEvent(false, kc, false, game)
                            end)
                            task.wait(0.3)
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
        Notify({ Title = v and "Auto Mastery ON" or "Auto Mastery OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })

Main:AddSection("Collect Chest")
Main:AddToggle({ Title = T("ui_farm_chest"), Default = false,
    Flag = "FarmChest", Callback = function(v)
        Config.FarmChest = v
        if v then task.spawn(function() Functions.StartFarmChest(Config, isTeleporting, NotAutoEquip) end) end
        Notify({ Title = v and "Farm Chest ON" or "Farm Chest OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
Main:AddToggle({ Title = "Auto Hop (sem baú)", Default = false, Flag = "AutoCollectBerryHop", Callback = function(v) Config.AutoCollectBerryHop = v end })
Main:AddToggle({ Title = "Auto Store Fruit", Default = false,
    Flag = "AutoStoreFruit", Callback = function(v)
        Config.AutoStoreFruit = v
        if v then task.spawn(function() while Config.AutoStoreFruit do Functions.StoreFruit() task.wait(2) end end) end
        Notify({ Title = v and "Auto Store Fruit ON" or "OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })

Main:AddSection("Collect Berry")
Main:AddToggle({ Title = T("ui_auto_berry"), Default = false,
    Flag = "AutoCollectBerry", Callback = function(v)
        Config.AutoCollectBerry = v
        if v then Functions.StartAutoCollectBerry(Config) end
        Notify({ Title = v and "Auto Berry ON" or "Auto Berry OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
Main:AddToggle({ Title = "Auto Hop (sem berry)", Default = false, Flag = "AutoCollectBerryHop", Callback = function(v) Config.AutoCollectBerryHop = v end })

Main:AddSection("Elite Hunter")
Main:AddParagraph({ Title = "Elite Spawn", Text = "0" })
Main:AddToggle({ Title = "Auto Elite Hunter (Diablo/Deandre/Urban)", Default = false,
    Flag = "AutoEliteHunter", Callback = function(v) Config.AutoEliteHunter = v end })
Main:AddToggle({ Title = "Server Hop se sem Elite Hunter", Default = false,
    Flag = "AutoEliteHunterHop", Callback = function(v) Config.AutoEliteHunterHop = v end })

Main:AddSection("Farming Bone")
Main:AddToggle({ Title = "Auto Farm Bone (Prehistoric)", Default = false,
    Flag = "AutoFarmBone", Callback = function(v) Config.AutoFarmBone = v end })
Main:AddToggle({ Title = "Auto Soul Reaper", Default = false, Flag = "AutoSoulReaper", Callback = function(v) Config.AutoSoulReaper = v end })
Main:AddToggle({ Title = "Auto Try Luck Gravestone", Default = false,
    Flag = "AutoTryLuck", Callback = function(v)
        Config.AutoTryLuck = v
        if v then task.spawn(function() Functions.StartAutoTryLuck(Config) end) end
    end })
Main:AddToggle({ Title = "Auto Pray Gravestone", Default = false,
    Flag = "AutoPray", Callback = function(v)
        Config.AutoPray = v
        if v then task.spawn(function() Functions.StartAutoPray(Config) end) end
    end })
Main:AddToggle({ Title = "Auto Trade Bone (DinoBone)", Default = false,
    Flag = "AutoTradeBone", Callback = function(v)
        Config.AutoTradeBone = v
        if v then task.spawn(function() Functions.StartAutoTradeBone(Config) end) end
    end })

-- =====================================================
-- TAB: SETTINGS
-- =====================================================
local Settings = Window:MakeTab({ Title = T("tab_settings"), Icon = "settings" })

Settings:AddSection("Farm Settings")
Settings:AddToggle({ Title = T("ui_auto_click"),  Default = true, Flag = "AutoClick", Callback = function(v) Config.AutoClick = v end })
Settings:AddToggle({ Title = T("ui_bring_mob"), Default = Config.BringMob, Flag = "BringMob", Callback = function(v)
    Config.BringMob = v
    print("[BringMob] " .. (v and "Ativado" or "Desativado"))
    if SaveSystem then SaveSystem.SaveConfig(Config) end
end })
Settings:AddSlider({ Title = "Bring Mob Distancia (studs)", Min = 100, Max = 1000, Default = Config.BringDistance or 350,
    Flag = "BringDistance", Callback = function(v)
        Config.BringDistance = v
        print("[BringMob] Distancia: " .. tostring(v) .. " studs")
        if SaveSystem then SaveSystem.SaveConfig(Config) end
    end })
-- Slider usa valores positivos (0-30) e inverte para negativo no Config
-- pois a biblioteca nao suporta Min negativo (retorna nan)
Settings:AddSlider({ Title = "Bring Mob Offset Y (studs abaixo)", Min = 0, Max = 30, Default = math.abs(Config.BringYOffset or 10),
    Flag = "BringYOffset", Callback = function(v)
        Config.BringYOffset = -v  -- inverte: slider 10 = Config -10 (abaixo)
        print("[BringMob] Offset Y: -" .. tostring(v) .. " studs")
        if SaveSystem then SaveSystem.SaveConfig(Config) end
    end })
Settings:AddSlider({ Title = "Tween Fly Speed (studs/s)", Min = 10, Max = 800, Default = 300,
    Flag = "FlySpeed", Callback = function(v) Config.FlySpeed = v end })
Settings:AddSlider({ Title = "Fly Offset (altura acima do mob)", Min = 5, Max = 50, Default = 15,
    Flag = "FlyOffset", Callback = function(v) Config.FlyOffset = v end })
Settings:AddToggle({ Title = T("ui_auto_spawn"),  Default = false, Flag = "AutoSetSpawn", Callback = function(v) Config.AutoSetSpawn = v end })
Settings:AddToggle({ Title = T("ui_auto_buso"),   Default = true,
    Flag = "AutoBusoHaki", Callback = function(v)
        Config.AutoBusoHaki = v
        if v then Functions.ActivateBuso(CommF_) end
    end })
Settings:AddToggle({ Title = T("ui_auto_obs"),    Default = false, Flag = "AutoObservation", Callback = function(v) Config.AutoObservation = v end })
Settings:AddToggle({ Title = "Auto Use V3 (tecla T)", Default = false,
    Flag = "AutoRaceV3", Callback = function(v)
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
    end })
Settings:AddToggle({ Title = "Auto Use V4 (tecla Y)", Default = false,
    Flag = "AutoRaceV4", Callback = function(v)
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
    end })

Settings:AddSection("Extras")
Settings:AddToggle({ Title = T("ui_auto_speed"), Default = true, Flag = "AutoSpeed", Callback = function(v) Config.AutoSpeed = v end })
Settings:AddSlider({ Title = T("ui_speed"), Min = 20, Max = 100, Default = 20,
    Flag = "Speed", Callback = function(v) Config.Speed = v; if Humanoid then Humanoid.WalkSpeed = v end end })
Settings:AddToggle({ Title = T("ui_auto_jump"), Default = true, Flag = "AutoSetJump", Callback = function(v) Config.AutoSetJump = v end })
Settings:AddSlider({ Title = T("ui_jump"), Min = 50, Max = 200, Default = 50,
    Flag = "Jump", Callback = function(v) Config.Jump = v; if Humanoid then Humanoid.JumpPower = v end end })

Settings:AddSection("PvP / Kill Aura")
Settings:AddToggle({ Title = "Kill Aura", Default = false,
    Flag = "KillAura", Callback = function(v)
        Config.KillAura = v
        Notify({ Title = v and "Kill Aura ON" or "Kill Aura OFF", Image = IMG, Type = v and "Warning" or "Info", Duration = 2 })
    end })
Settings:AddSlider({ Title = "Kill Aura Raio (studs)", Min = 100, Max = 5000, Default = 1000,
    Flag = "KillAuraRadius", Callback = function(v) Config.KillAuraRadius = v end })
Settings:AddToggle({ Title = "Auto Enable PvP", Default = false,
    Flag = "EnabledPvP", Callback = function(v)
        Config.EnabledPvP = v
        pcall(function() (CommF_ or {}):InvokeServer("EnablePvP", v) end)
        Notify({ Title = v and "PvP ATIVADO" or "PvP Desativado", Image = IMG, Type = v and "Warning" or "Info", Duration = 2 })
    end })
Settings:AddToggle({ Title = "Aimbot (Gun)", Default = false,
    Flag = "AimbotGun", Callback = function(v) Config.AimbotGun = v end })
Settings:AddToggle({ Title = "Aimbot (Skills)", Default = false,
    Flag = "AimbotSkill", Callback = function(v) Config.AimbotSkill = v end })

Settings:AddSection("Visual")
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
Settings:AddToggle({ Title = T("ui_disable_notify"), Default = false, Flag = "DisableGameNotify", Callback = function(v) Config.DisableGameNotify = v end })
Settings:AddToggle({ Title = T("ui_no_fog"), Default = true,
    Flag = "NoFog", Callback = function(v)
        Config.NoFog    = v
        Lighting.FogEnd = v and 100000 or 1000
    end })
Settings:AddToggle({ Title = T("ui_notify_error"), Default = false, Flag = "NotifyErroScript", Callback = function(v) Config.NotifyErroScript = v end })
Settings:AddButton({ Title = T("ui_test_notify"),
    Callback = function()
        Notify({ Title = "Lotux Hub v3.0", Description = "Script funcionando!", Image = IMG, Type = "Success", Duration = 3 })
    end })
Settings:AddToggle({ Title = T("ui_noclip"), Default = false,
    Flag = "NoClip", Callback = function(v)
        Config.NoClip = v
        NoClip.value  = v
        Notify({ Title = T(v and "noclip_on" or "noclip_off"), Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })

Settings:AddSection("Select Language")
Settings:AddDropdown({
    Title    = T("ui_lang_dropdown"),
    Options  = { "English","Portugues_Brazil","Portugues_Portugal","Espanol","Vietnam" },
    Default  = CurrentLang,
    Callback = function(v)
        -- A library passa { Selected } para dropdown single-select
        local lang = type(v) == "table" and (v[1] or next(v)) or tostring(v)
        CurrentLang = tostring(lang)
        Config.Language = CurrentLang
        SaveLanguage(CurrentLang)
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

Settings:AddSection("Interface")
Settings:AddToggle({
    Title   = "Reset UI Button",
    Default = true,
    Flag    = "ShowResetUIBtn",
    Callback = function(v)
        pcall(function()
            local gui = Player.PlayerGui:FindFirstChild("LotuxResetUIBtn")
            if gui then
                local btn = gui:FindFirstChildWhichIsA("TextButton", true)
                if btn then btn.Visible = v end
            end
        end)
    end,
})

-- =====================================================
-- TAB: ITEMS / QUEST
-- =====================================================
local ItemsQuest = Window:MakeTab({ Title = T("tab_itemquest"), Icon = "swords" })

ItemsQuest:AddSection("Items Sea 3")
ItemsQuest:AddToggle({ Title = "Auto Dragon Taylor",           Default = false, Flag = "AutoDragonTaylor", Callback = function(v) Config.AutoDragonTaylor  = v end })
ItemsQuest:AddToggle({ Title = "Auto Electric Claw",           Default = false, Flag = "AutoElectricClaw", Callback = function(v) Config.AutoElectricClaw  = v end })
ItemsQuest:AddToggle({ Title = "Auto God Human",               Default = false, Flag = "AutoGodHuman", Callback = function(v) Config.AutoGodHuman      = v end })
ItemsQuest:AddToggle({ Title = "Auto Pegar Tushita (Farm Longma)", Default = false,
    Flag = "AutoGetTushita", Callback = function(v)
        Config.AutoGetTushita = v
        Notify({ Title = v and "Auto Tushita ON" or "Auto Tushita OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
ItemsQuest:AddToggle({ Title = "Auto Holy Torch (Tochas Tushita)", Default = false,
    Flag = "AutoHolyTorch", Callback = function(v) Config.AutoHolyTorch = v end })
ItemsQuest:AddToggle({ Title = "Auto Yama (30 Elite Hunter kills)", Default = false,
    Flag = "AutoYama", Callback = function(v) Config.AutoYama = v end })
ItemsQuest:AddToggle({ Title = "Auto Rengoku (Ice Admiral)",   Default = false,
    Flag = "AutoRengoku", Callback = function(v) Config.AutoRengoku = v end })
ItemsQuest:AddToggle({ Title = "Auto Electric Claw (Sea 3)",   Default = false, Flag = "AutoElectricClaw", Callback = function(v) Config.AutoElectricClaw = v end })

ItemsQuest:AddSection("Items Sea 2")
ItemsQuest:AddToggle({ Title = T("ui_auto_buy_sword_legends"), Default = false,
    Flag = "AutoBuyLegendarySword", Callback = function(v)
        Config.AutoBuyLegendarySword = v
        if v then task.spawn(function() Functions.StartAutoBuyLegendarySword(Config) end) end
    end })
ItemsQuest:AddToggle({ Title = T("ui_auto_buy_ttk"), Default = false,
    Flag = "AutoBuyTTK", Callback = function(v) Config.AutoBuyTTK = v end })
ItemsQuest:AddToggle({ Title = "Auto Death Step (Sea 2)",      Default = false, Flag = "AutoDeathStep", Callback = function(v) Config.AutoDeathStep    = v end })
ItemsQuest:AddToggle({ Title = "Auto Sharkman V2 (Sea 2)",     Default = false, Flag = "AutoSharkmanV2", Callback = function(v) Config.AutoSharkmanV2   = v end })
ItemsQuest:AddButton({ Title = "Buy Dragon Style V1",  Callback = function()
    pcall(function() (CommF_ or {}):InvokeServer("BuyFightingStyle", "Dragon Talon") end)
    Notify({ Title = "Dragon Style V1 comprado!", Image = IMG, Type = "Success", Duration = 3 })
end })
ItemsQuest:AddButton({ Title = "Buy Kabucha",  Callback = function()
    pcall(function() (CommF_ or {}):InvokeServer("BuyWeapon", "Kabucha") end)
    Notify({ Title = "Kabucha comprada!", Image = IMG, Type = "Success", Duration = 3 })
end })
ItemsQuest:AddToggle({ Title = "Auto Pegar Rengoku (Ice Admiral)", Default = false,
    Flag = "AutoRengoku", Callback = function(v) Config.AutoRengoku = v end })
ItemsQuest:AddToggle({ Title = "Auto Thunder Pole (Thunder God)", Default = false,
    Flag = "AutoGetPole", Callback = function(v)
        Config.AutoGetPole = v
        if v then task.spawn(function() Functions.StartAutoGetPole(Config) end) end
        Notify({ Title = v and "Auto Pole ON" or "Auto Pole OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
ItemsQuest:AddToggle({ Title = "Auto Pegar The Saw",           Default = false,
    Flag = "AutoGetSaw", Callback = function(v)
        Config.AutoGetSaw = v
        if v then task.spawn(function() Functions.StartAutoGetSaw(Config) end) end
        Notify({ Title = v and "Auto Saw ON" or "Auto Saw OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
ItemsQuest:AddToggle({ Title = "Auto Dark Blade V2",           Default = false, Flag = "AutoDarkBladeV2", Callback = function(v) Config.AutoDarkBladeV2  = v end })
ItemsQuest:AddToggle({ Title = "Auto Comprar Cor de Haki",     Default = false,
    Flag = "AutoBuyEnhancementColour", Callback = function(v)
        Config.AutoBuyEnhancementColour = v
        if v then task.spawn(function() Functions.StartAutoBuyEnhancement(Config) end) end
    end })

ItemsQuest:AddSection("Items Sea 1")
ItemsQuest:AddToggle({ Title = "Auto Gray Beard (Sea 1)",      Default = false, Flag = "AutoGrayBeard", Callback = function(v) Config.AutoGrayBeard    = v end })
ItemsQuest:AddToggle({ Title = "Auto Saber Sword",             Default = false, Flag = "AutoSaber", Callback = function(v) Config.AutoSaber        = v end })
ItemsQuest:AddToggle({ Title = "Auto The Saw",                 Default = false, Flag = "AutoGetSaw", Callback = function(v) Config.AutoGetSaw       = v end })
ItemsQuest:AddToggle({ Title = "Auto Dark Blade V2 (Sea 1)",   Default = false, Flag = "AutoDarkBladeV2", Callback = function(v) Config.AutoDarkBladeV2  = v end })

ItemsQuest:AddSection("Quest")
ItemsQuest:AddToggle({ Title = "Auto Bartilo Quest (acesso Sea 3)", Default = false,
    Flag = "AutoBartilo", Callback = function(v) Config.AutoBartilo = v
        Notify({ Title = v and "Auto Bartilo ON" or "Auto Bartilo OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
ItemsQuest:AddToggle({ Title = "Auto Rip Indra Unlock",        Default = false, Flag = "AutoRipIndra", Callback = function(v) Config.AutoRipIndra     = v end })
ItemsQuest:AddToggle({ Title = "Auto Dough King Unlock Raid",  Default = false, Flag = "AutoDoughKing", Callback = function(v) Config.AutoDoughKing    = v end })
ItemsQuest:AddToggle({ Title = "Auto Big Mom Quest",           Default = false, Flag = "AutoBigMom", Callback = function(v) Config.AutoBigMom       = v end })

ItemsQuest:AddSection("Buso")
ItemsQuest:AddToggle({ Title = T("ui_auto_barista"),           Default = false,
    Flag = "AutoBarista", Callback = function(v)
        Config.AutoBarista = v
        if v then Functions.StartAutoBarista(Config) end
    end })
ItemsQuest:AddDropdown({ Title = "Cor do Haki (Barista)",
    Options = { "White","Black","Red","Blue","Green","Yellow","Purple","Pink" }, Default = "White",
    Callback = function(v) Config.HakiColor = (type(v) == "table" and (v[1] or next(v)) or tostring(v)) end })
ItemsQuest:AddButton({ Title = "Buy Buso Colors",  Callback = function()
    pcall(function() (CommF_ or {}):InvokeServer("BuyBuso") end)
    Notify({ Title = "Comprando cores Buso!", Image = IMG, Type = "Success", Duration = 3 })
end })

ItemsQuest:AddSection("Instinct / Observation")
ItemsQuest:AddToggle({ Title = "Auto Farm Observation Haki",   Default = false, Flag = "AutoFarmObsHaki", Callback = function(v) Config.AutoFarmObsHaki  = v end })
ItemsQuest:AddToggle({ Title = "Auto Haki V2",                 Default = false, Flag = "AutoHakiV2", Callback = function(v) Config.AutoHakiV2       = v end })
ItemsQuest:AddToggle({ Title = "Auto Unlock Temple",           Default = false, Flag = "AutoUnlockTemple", Callback = function(v) Config.AutoUnlockTemple = v end })

-- =====================================================
-- TAB: FISHING
-- =====================================================
local FishingTab = Window:MakeTab({ Title = "Fishing", Icon = "fish" })
FishingTab:AddSection("Auto Fishing")
FishingTab:AddToggle({ Title = "Auto Quest Fishing",   Default = false, Flag = "G_AutoQuestFishing", Callback = function(v)
    _G.AutoQuestFishing = v
end })
FishingTab:AddToggle({ Title = "Auto Complete Quest",  Default = false, Flag = "G_AutoCompleteQuestFishing", Callback = function(v)
    _G.AutoCompleteQuestFishing = v
end })
FishingTab:AddToggle({ Title = "Auto Sell Fish",       Default = false, Flag = "G_AutoSellFish", Callback = function(v)
    _G.AutoSellFish = v
end })
FishingTab:AddToggle({ Title = "Auto Spam Skill Z",    Default = false, Flag = "AutoSkillZ", Callback = function(v)
    Config.AutoSkillZ = v
end })

-- =====================================================
-- TAB: SEA EVENT
-- =====================================================
local SeaEventTab = Window:MakeTab({ Title = T("tab_seaevent"), Icon = "waves" })

SeaEventTab:AddSection("Boat")
SeaEventTab:AddToggle({ Title = "No Clip Ship",        Default = false, Flag = "G_NoClipShip", Callback = function(v) _G.NoClipShip = v end })
SeaEventTab:AddToggle({ Title = "Boat ESP",            Default = false, Flag = "G_BoatESP", Callback = function(v) _G.BoatESP    = v end })
SeaEventTab:AddToggle({ Title = "Auto Navegar Barco",  Default = false,
    Flag = "SailBoat", Callback = function(v)
        Config.SailBoat = v
        Notify({ Title = v and "Sail Boat ON" or "Sail Boat OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
SeaEventTab:AddToggle({ Title = "Walk on Water",       Default = false,
    Flag = "WalkWater", Callback = function(v)
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

SeaEventTab:AddSection("Crafting Items")
SeaEventTab:AddButton({ Title = "Craft SharkTooth",      Callback = function() pcall(function() (CommF_ or {}):InvokeServer("CraftItem","SharkTooth") end); Notify({ Title = "Crafting SharkTooth!", Image = IMG, Type = "Success", Duration = 2 }) end })
SeaEventTab:AddButton({ Title = "Craft TerrorJaw",       Callback = function() pcall(function() (CommF_ or {}):InvokeServer("CraftItem","TerrorJaw") end); Notify({ Title = "Crafting TerrorJaw!", Image = IMG, Type = "Success", Duration = 2 }) end })
SeaEventTab:AddButton({ Title = "Craft SharkAnchor",     Callback = function() pcall(function() (CommF_ or {}):InvokeServer("CraftItem","SharkAnchor") end); Notify({ Title = "Crafting SharkAnchor!", Image = IMG, Type = "Success", Duration = 2 }) end })
SeaEventTab:AddButton({ Title = "Craft LeviathanCrown",  Callback = function() pcall(function() (CommF_ or {}):InvokeServer("CraftItem","LeviathanCrown") end); Notify({ Title = "Crafting LeviathanCrown!", Image = IMG, Type = "Success", Duration = 2 }) end })
SeaEventTab:AddButton({ Title = "Craft LeviathanShield", Callback = function() pcall(function() (CommF_ or {}):InvokeServer("CraftItem","LeviathanShield") end); Notify({ Title = "Crafting LeviathanShield!", Image = IMG, Type = "Success", Duration = 2 }) end })
SeaEventTab:AddButton({ Title = "Craft Leviathan Boat",  Callback = function() pcall(function() (CommF_ or {}):InvokeServer("CraftItem","LeviathanBoat") end); Notify({ Title = "Crafting Leviathan Boat!", Image = IMG, Type = "Success", Duration = 2 }) end })
SeaEventTab:AddButton({ Title = "Craft LegendaryScroll", Callback = function() pcall(function() (CommF_ or {}):InvokeServer("CraftItem","LegendaryScroll") end); Notify({ Title = "Crafting LegendaryScroll!", Image = IMG, Type = "Success", Duration = 2 }) end })
SeaEventTab:AddButton({ Title = "Craft MythicalScroll",  Callback = function() pcall(function() (CommF_ or {}):InvokeServer("CraftItem","MythicalScroll") end); Notify({ Title = "Crafting MythicalScroll!", Image = IMG, Type = "Success", Duration = 2 }) end })

SeaEventTab:AddSection("Settings Sea Event")
SeaEventTab:AddToggle({ Title = "Skip Terror Shark",   Default = false, Flag = "G_SkipTerroShark", Callback = function(v) _G.SkipTerroShark = v end })

SeaEventTab:AddSection("Choose Sea Event")
SeaEventTab:AddDropdown({ Title = "Select Boats",      Options = { "Bicrement", "Dinghy", "Caravel", "Galleon", "Raft" }, Default = "Bicrement",
    Callback = function(v) _G.SelectedBoat = (type(v) == "table" and (v[1] or next(v)) or tostring(v)) end })
SeaEventTab:AddButton({ Title = "Buy Boat",  Callback = function()
    pcall(function() (CommF_ or {}):InvokeServer("BuyBoat", _G.SelectedBoat or "Bicrement") end)
    Notify({ Title = "Comprando barco!", Image = IMG, Type = "Success", Duration = 2 })
end })
SeaEventTab:AddDropdown({ Title = "Select Sea Level",  Options = { "Sea 1", "Sea 2", "Sea 3" }, Default = "Sea 1",
    Callback = function(v) _G.SelectedSeaLevel = (type(v) == "table" and (v[1] or next(v)) or tostring(v)) end })

SeaEventTab:AddSection("Entity Sea")
SeaEventTab:AddToggle({ Title = "Auto Shark",                      Default = false, Flag = "AutoKillShark", Callback = function(v) Config.AutoKillShark    = v end })
SeaEventTab:AddToggle({ Title = "Auto Piranha",                    Default = false, Flag = "AutoKillPiranha", Callback = function(v) Config.AutoKillPiranha  = v end })
SeaEventTab:AddToggle({ Title = "Auto Terror Shark",               Default = false, Flag = "AutoTerrorshark", Callback = function(v) Config.AutoTerrorshark  = v end })
SeaEventTab:AddToggle({ Title = "Auto Fish Crew Member",           Default = false, Flag = "AutoKillFishCrew", Callback = function(v) Config.AutoKillFishCrew = v end })
SeaEventTab:AddToggle({ Title = "Auto Attack Pirate Grand Brigade",Default = false, Flag = "G_AutoAttackPirateBrigade", Callback = function(v) _G.AutoAttackPirateBrigade = v end })
SeaEventTab:AddToggle({ Title = "Auto Attack Sea Beast",           Default = false, Flag = "G_AutoAttackSeaBeast", Callback = function(v) _G.AutoAttackSeaBeast   = v end })

SeaEventTab:AddSection("Kitsune Island")
SeaEventTab:AddToggle({ Title = "Auto Find Kitsune Island",        Default = false,
    Flag = "TweenToKitsune", Callback = function(v)
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
SeaEventTab:AddToggle({ Title = "Auto Azure Ember",                Default = false,
    Flag = "AutoAzuerEmber", Callback = function(v)
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
SeaEventTab:AddToggle({ Title = "Auto Trade Azure Ember",          Default = false,
    Flag = "G_AutoTradeAzureEmber", Callback = function(v) _G.AutoTradeAzureEmber = v end })
SeaEventTab:AddButton({ Title = "Trade Items Azure",  Callback = function()
    pcall(function() (CommF_ or {}):InvokeServer("TradeAzureEmber") end)
    Notify({ Title = "Trading Azure Ember!", Image = IMG, Type = "Success", Duration = 2 })
end })

SeaEventTab:AddSection("Frozen Dimension Event")
SeaEventTab:AddParagraph({ Title = "Spy Status", Text = "0" })
SeaEventTab:AddButton({ Title = "Buy Spy",  Callback = function()
    pcall(function() (CommF_ or {}):InvokeServer("BuySpy") end)
    Notify({ Title = "Comprando Spy!", Image = IMG, Type = "Success", Duration = 2 })
end })
SeaEventTab:AddToggle({ Title = "Auto Find Leviathan",            Default = false, Flag = "G_AutoFindLeviathan", Callback = function(v) _G.AutoFindLeviathan     = v end })
SeaEventTab:AddToggle({ Title = "Auto Drive To Hydra Island",     Default = false, Flag = "G_AutoDriveHydra", Callback = function(v) _G.AutoDriveHydra         = v end })
SeaEventTab:AddToggle({ Title = "Auto Attack Leviathan",          Default = false, Flag = "G_AutoAttackLeviathan", Callback = function(v) _G.AutoAttackLeviathan    = v end })

SeaEventTab:AddSection("Farm Especial")
SeaEventTab:AddToggle({ Title = "Auto Farm Hydra Tree (Hydra Island)", Default = false,
    Flag = "AutoHydraTree", Callback = function(v) Config.AutoHydraTree = v end })
SeaEventTab:AddToggle({ Title = "Auto Tween para Mirage Island",  Default = false,
    Flag = "AutoMysticIsland", Callback = function(v)
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
        Notify({ Title = v and "Auto Mirage Island ON" or "OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
SeaEventTab:AddToggle({ Title = "Auto Blaze Ember",               Default = false,
    Flag = "AutoBlazeEmber", Callback = function(v)
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
SeaEventTab:AddToggle({ Title = "Auto Tween M-Gear (Mystic Island)", Default = false,
    Flag = "TweenMGear", Callback = function(v)
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
-- TAB: RACE
-- =====================================================
local RaceTab = Window:MakeTab({ Title = T("tab_race"), Icon = "flag" })

RaceTab:AddSection("Mirage")
RaceTab:AddToggle({ Title = "Auto Find Mirage",             Default = false,
    Flag = "AutoMysticIsland", Callback = function(v)
        Config.AutoMysticIsland = v
    end })
RaceTab:AddToggle({ Title = "Auto Tween To Highest Point",  Default = false, Flag = "G_AutoTweenHighest", Callback = function(v) _G.AutoTweenHighest  = v end })
RaceTab:AddToggle({ Title = "Auto Collect Gear",            Default = false, Flag = "G_AutoCollectGear", Callback = function(v) _G.AutoCollectGear   = v end })
RaceTab:AddToggle({ Title = "Auto Tween Advanced Fruit Dealer", Default = false, Flag = "G_AutoTweenFruitDealer", Callback = function(v) _G.AutoTweenFruitDealer = v end })
RaceTab:AddToggle({ Title = "Auto Collect Mirage Chest",    Default = false, Flag = "G_AutoMirageChest", Callback = function(v) _G.AutoMirageChest   = v end })
RaceTab:AddToggle({ Title = "Talk With Stone",              Default = false, Flag = "G_TalkWithStone", Callback = function(v) _G.TalkWithStone     = v end })
RaceTab:AddToggle({ Title = "Auto Look At Moon",            Default = false, Flag = "AutoDooHee", Callback = function(v)
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
RaceTab:AddToggle({ Title = "Look Moon + Auto V3",          Default = false, Flag = "G_LookMoonAutoV3", Callback = function(v) _G.LookMoonAutoV3   = v end })

RaceTab:AddSection("Upgrade Races (V2 e V3)")
RaceTab:AddToggle({ Title = "Auto Upgrade Mink",            Default = false, Flag = "G_AutoUpgradeMink", Callback = function(v) _G.AutoUpgradeMink    = v end })
RaceTab:AddToggle({ Title = "Auto Upgrade Human",           Default = false, Flag = "G_AutoUpgradeHuman", Callback = function(v) _G.AutoUpgradeHuman   = v end })
RaceTab:AddToggle({ Title = "Auto Upgrade Fishman",         Default = false, Flag = "G_AutoUpgradeFishman", Callback = function(v) _G.AutoUpgradeFishman = v end })
RaceTab:AddToggle({ Title = "Auto Upgrade Cyborg",          Default = false, Flag = "G_AutoUpgradeCyborg", Callback = function(v) _G.AutoUpgradeCyborg  = v end })

RaceTab:AddSection("Trials")
RaceTab:AddToggle({ Title = "Auto Quest Race (trial de raça)", Default = false,
    Flag = "AutoQuestRace", Callback = function(v)
        Config.AutoQuestRace = v
        Notify({ Title = v and "Auto Quest Race ON" or "OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
RaceTab:AddToggle({ Title = "Auto Train V4",                Default = false, Flag = "G_AutoTrainV4", Callback = function(v) _G.AutoTrainV4       = v end })
RaceTab:AddToggle({ Title = "Auto Teleport to Race Doors",  Default = false, Flag = "G_AutoTPRaceDoors", Callback = function(v) _G.AutoTPRaceDoors   = v end })
RaceTab:AddToggle({ Title = "Auto Complete Trial Race",     Default = false, Flag = "G_AutoCompleteTrialRace", Callback = function(v) _G.AutoCompleteTrialRace = v end })
RaceTab:AddToggle({ Title = "Auto Kill Player After Trial", Default = false, Flag = "G_AutoKillAfterTrial", Callback = function(v) _G.AutoKillAfterTrial = v end })
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
RaceTab:AddButton({ Title = "Comprar Ancient One Quest", Callback = function()
    pcall(function() (CommF_ or {}):InvokeServer("UpgradeRace", "Buy") end)
    Notify({ Title = "Comprando Ancient One Quest", Image = IMG, Type = "Success", Duration = 3 })
end })

-- =====================================================
-- TAB: VOLCANO EVENT
-- =====================================================
local VulcaoTab = Window:MakeTab({ Title = T("tab_vulcano"), Icon = "flame" })

VulcaoTab:AddSection("Dojo")
VulcaoTab:AddToggle({ Title = "Auto Dojo Trainer",          Default = false, Flag = "G_AutoDojoTrainer", Callback = function(v) _G.AutoDojoTrainer   = v end })
VulcaoTab:AddToggle({ Title = "Auto Dragon Hunter",         Default = false, Flag = "G_AutoDragonHunter", Callback = function(v) _G.AutoDragonHunter  = v end })

VulcaoTab:AddSection("Drago Trial")
VulcaoTab:AddToggle({ Title = "Tween To Upgrade Draco Trial", Default = false, Flag = "G_TweenUpgradeDraco", Callback = function(v) _G.TweenUpgradeDraco = v end })
VulcaoTab:AddToggle({ Title = "Auto Train Drago V4",        Default = false, Flag = "G_AutoTrainDragoV4", Callback = function(v) _G.AutoTrainDragoV4  = v end })
VulcaoTab:AddToggle({ Title = "Tween to Drago Trials",      Default = false, Flag = "G_TweenDragoTrials", Callback = function(v) _G.TweenDragoTrials  = v end })
VulcaoTab:AddToggle({ Title = "Swap Dragon Race",           Default = false, Flag = "G_SwapDragonRace", Callback = function(v) _G.SwapDragonRace    = v end })
VulcaoTab:AddToggle({ Title = "Upgrade Dragon Talon With Uzoth", Default = false, Flag = "G_UpgradeDragonTalon", Callback = function(v) _G.UpgradeDragonTalon = v end })

VulcaoTab:AddSection("Volcano Crafting")
VulcaoTab:AddButton({ Title = "Craft DragonHeart",  Callback = function() pcall(function() (CommF_ or {}):InvokeServer("CraftItem","DragonHeart") end); Notify({ Title = "Crafting DragonHeart!", Image = IMG, Type = "Success", Duration = 2 }) end })
VulcaoTab:AddButton({ Title = "Craft Dragonstorm",  Callback = function() pcall(function() (CommF_ or {}):InvokeServer("CraftItem","Dragonstorm") end); Notify({ Title = "Crafting Dragonstorm!", Image = IMG, Type = "Success", Duration = 2 }) end })
VulcaoTab:AddButton({ Title = "Craft Dino Hood",    Callback = function() pcall(function() (CommF_ or {}):InvokeServer("CraftItem","DinoHood") end); Notify({ Title = "Crafting Dino Hood!", Image = IMG, Type = "Success", Duration = 2 }) end })
VulcaoTab:AddButton({ Title = "Craft T-Rex Skull",  Callback = function() pcall(function() (CommF_ or {}):InvokeServer("CraftItem","TRexSkull") end); Notify({ Title = "Crafting T-Rex Skull!", Image = IMG, Type = "Success", Duration = 2 }) end })

VulcaoTab:AddSection("Prehistoric Island")
VulcaoTab:AddButton({ Title = "Craft Volcanic Magnet",  Callback = function() pcall(function() (CommF_ or {}):InvokeServer("CraftItem","VolcanicMagnet") end); Notify({ Title = "Crafting Volcanic Magnet!", Image = IMG, Type = "Success", Duration = 2 }) end })
VulcaoTab:AddToggle({ Title = "Auto Craft Volcanic Magnet", Default = false, Flag = "G_AutoCraftVolcanicMagnet", Callback = function(v) _G.AutoCraftVolcanicMagnet = v end })
VulcaoTab:AddToggle({ Title = "Auto Find Prehistoric Island", Default = false,
    Flag = "AutoFindPrehistoric", Callback = function(v)
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
VulcaoTab:AddToggle({ Title = "Auto Start Prehistoric Event", Default = false, Flag = "G_AutoStartPrehistoric", Callback = function(v) _G.AutoStartPrehistoric  = v end })
VulcaoTab:AddToggle({ Title = "Auto Patch Prehistoric Event", Default = false, Flag = "G_AutoPatchPrehistoric", Callback = function(v) _G.AutoPatchPrehistoric  = v end })
VulcaoTab:AddToggle({ Title = "Kill Aura (Prehistoric)",      Default = false,
    Flag = "KillAura", Callback = function(v)
        Config.KillAura = v
        Notify({ Title = v and "Kill Aura ON" or "Kill Aura OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
VulcaoTab:AddToggle({ Title = "Auto Collect Dino Bones",      Default = false,
    Flag = "AutoCollectBone", Callback = function(v)
        Config.AutoCollectBone = v
        if v then
            task.spawn(function()
                while Config.AutoCollectBone do
                    pcall(function()
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj.Name == "DinoBone" or obj.Name == "Bone" then
                                if HumanoidRootPart then HumanoidRootPart.CFrame = obj.CFrame end
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end })
VulcaoTab:AddToggle({ Title = "Auto Collect Dragon Eggs",     Default = false,
    Flag = "CollectEgg", Callback = function(v)
        Config.CollectEgg = v
        if v then
            task.spawn(function()
                while Config.CollectEgg do
                    pcall(function() (CommF_ or {}):InvokeServer("CollectEgg") end)
                    task.wait(2)
                end
            end)
        end
    end })
VulcaoTab:AddToggle({ Title = "Auto Reset When Complete Volcano", Default = false, Flag = "G_AutoResetVolcano", Callback = function(v) _G.AutoResetVolcano = v end })
VulcaoTab:AddToggle({ Title = "Auto Defender Vulcão",         Default = false,
    Flag = "DefendVolcano", Callback = function(v)
        Config.DefendVolcano = v
        Notify({ Title = v and "Defend Vulcão ON" or "OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
VulcaoTab:AddToggle({ Title = "Tween para o Vulcão",          Default = false,
    Flag = "TweenVolcano", Callback = function(v)
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
VulcaoTab:AddToggle({ Title = "Auto Kill Lava Golem",         Default = false,
    Flag = "AutoKillGolem", Callback = function(v)
        Config.AutoKillGolem = v
        if v then task.spawn(function() Functions.StartAutoKillGolem(Config) end) end
        Notify({ Title = v and "Kill Golem ON" or "Kill Golem OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
VulcaoTab:AddToggle({ Title = "Auto Farm Mob Dragon (Floating Turtle)", Default = false,
    Flag = "AutoMobDragon", Callback = function(v) Config.AutoMobDragon = v end })

-- =====================================================
-- TAB: STATS / ESP
-- =====================================================
local StatsEspTab = Window:MakeTab({ Title = "Stats/ESP", Icon = "eye" })

StatsEspTab:AddSection("Status")
StatsEspTab:AddSlider({ Title = "Set Status Value", Min = 1, Max = 10, Default = 1,
    Flag = "G_StatusValue", Callback = function(v) _G.StatusValue = v end })
StatsEspTab:AddToggle({ Title = "Auto Blox Fruits Status",    Default = false, Flag = "G_AutoBloxFruitStatus", Callback = function(v) _G.AutoBloxFruitStatus = v end })
StatsEspTab:AddToggle({ Title = "Auto Melee Status",          Default = false, Flag = "G_AutoMeleeStatus", Callback = function(v) _G.AutoMeleeStatus     = v end })
StatsEspTab:AddToggle({ Title = "Auto Defense Status",        Default = false, Flag = "G_AutoDefenseStatus", Callback = function(v) _G.AutoDefenseStatus   = v end })
StatsEspTab:AddToggle({ Title = "Auto Gun Status",            Default = false, Flag = "G_AutoGunStatus", Callback = function(v) _G.AutoGunStatus       = v end })
StatsEspTab:AddToggle({ Title = "Auto Sword Status",          Default = false, Flag = "G_AutoSwordStatus", Callback = function(v) _G.AutoSwordStatus     = v end })
StatsEspTab:AddToggle({ Title = "Auto Status (geral)",        Default = false, Flag = "G_AutoStatus", Callback = function(v) _G.AutoStatus         = v end })

StatsEspTab:AddSection("ESP")
StatsEspTab:AddToggle({
    Title    = T("ui_esp_mobs"),
    Default  = false,
    Flag = "ESPEnabled", Callback = function(v)
        Config.ESPEnabled = v
        if v then
            _initMobCircleESP()
            _startMobCircleLoop()
        else
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("SelectionBox") and obj.Name == "ESP_Lotux" then obj:Destroy() end
            end
            _stopMobCircleLoop()
            _clearAllMobCircles()
        end
        Notify({ Title = T(v and "esp_on" or "esp_off"), Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end,
})
StatsEspTab:AddToggle({ Title = "ESP Players (nome + HP + distância)", Default = false,
    Flag = "ESPTeammates", Callback = function(v)
        Config.ESPTeammates = v
        if not v then
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
        Notify({ Title = v and "ESP Players ON" or "ESP Players OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end,
})
StatsEspTab:AddToggle({ Title = "ESP Sea Beasts",             Default = false,
    Flag = "ESPSeaBeasts", Callback = function(v)
        Config.ESPSeaBeasts = v
        Notify({ Title = v and "ESP Sea Beasts ON" or "OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
StatsEspTab:AddToggle({ Title = "ESP NPCs",                   Default = false,
    Flag = "ESPNpcs", Callback = function(v)
        Config.ESPNpcs = v
        Notify({ Title = v and "ESP NPCs ON" or "OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
StatsEspTab:AddToggle({ Title = "ESP Ilhas",                  Default = false,
    Flag = "ESPIslands", Callback = function(v)
        Config.ESPIslands = v
        Notify({ Title = v and "ESP Ilhas ON" or "OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
StatsEspTab:AddToggle({ Title = "ESP Frutas do Diabo",        Default = false,
    Flag = "ESPFruits", Callback = function(v)
        Config.ESPFruits = v
        Notify({ Title = v and "ESP Frutas ON" or "OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
StatsEspTab:AddToggle({ Title = "ESP Baus (Chests)",          Default = false,
    Flag = "ESPChests", Callback = function(v)
        Config.ESPChests = v
        Notify({ Title = v and "ESP Baus ON" or "OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
StatsEspTab:AddToggle({ Title = "ESP Berries",                Default = false,
    Flag = "ESPBerries", Callback = function(v)
        Config.ESPBerries = v
        Notify({ Title = v and "ESP Berries ON" or "OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
StatsEspTab:AddToggle({ Title = "ESP Mirage Island",          Default = false,
    Flag = "ESPMirage", Callback = function(v)
        Config.ESPMirage = v
        Notify({ Title = v and "ESP Mirage ON" or "OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })

-- Loop de update de todos os ESPs (Heartbeat)
RunService.Heartbeat:Connect(function()
    pcall(function() Functions.UpdatePlayerESP(Config.ESPTeammates, false) end)
    pcall(function() Functions.UpdateSeaBeastESP(Config.ESPSeaBeasts) end)
    pcall(function() Functions.UpdateNpcESP(Config.ESPNpcs) end)
    pcall(function() Functions.UpdateIslandESP(Config.ESPIslands) end)
    pcall(function() Functions.UpdateDevilFruitESP(Config.ESPFruits) end)
    pcall(function() Functions.UpdateChestESP(Config.ESPChests) end)
    pcall(function() Functions.UpdateBerriesESP(Config.ESPBerries) end)
    pcall(function() Functions.UpdateMirageESP(Config.ESPMirage) end)
end)

-- =====================================================
-- TAB: FRUIT / RAID
-- =====================================================
local FruitRaidTab = Window:MakeTab({ Title = T("tab_fruitraid"), Icon = "apple" })

FruitRaidTab:AddSection("Fruit")
FruitRaidTab:AddToggle({ Title = "Auto Random Fruit", Default = false, Flag = "AutoTryLuck", Callback = function(v) Config.AutoTryLuck = v end })
FruitRaidTab:AddToggle({ Title = "Auto Drop Fruit",           Default = false, Flag = "G_AutoDropFruit", Callback = function(v) _G.AutoDropFruit     = v end })
FruitRaidTab:AddToggle({ Title = "Auto Store Fruit (guardar no storage)", Default = false,
    Flag = "AutoStoreFruit", Callback = function(v)
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
        Notify({ Title = v and "Auto Store Fruit ON" or "OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
FruitRaidTab:AddToggle({ Title = T("ui_twenfly_fruit"), Default = false,
    Flag = "TweenFlyFruit", Callback = function(v)
        Config.TweenFlyFruit = v
        if v then task.spawn(function() Functions.StartTweenFlyFruit(Config, isTeleporting, NotAutoEquip) end) end
        Notify({ Title = v and "TweenFly Fruit ON" or "OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
FruitRaidTab:AddDropdown({ Title = "Select Fruit Shop",
    Options = { "Devil Fruit Shop", "Advanced Fruit Dealer" }, Default = "Devil Fruit Shop",
    Callback = function(v) _G.SelectedFruitShop = (type(v) == "table" and (v[1] or next(v)) or tostring(v)) end })
FruitRaidTab:AddToggle({ Title = "Auto Buy Fruit Shop",       Default = false, Flag = "G_AutoBuyFruitShop", Callback = function(v) _G.AutoBuyFruitShop = v end })

FruitRaidTab:AddSection("Raid")
_G.SelectedRaidChip = _G.SelectedRaidChip or Config.SelectChipRaid or "Flame"
FruitRaidTab:AddDropdown({ Title = "Select Chip",
    Options = { "Flame", "Ice", "Quake", "Light", "Dark", "Spider", "Magma", "Buddha", "Sand", "Dough", "Phoenix" }, Default = "Flame",
    Callback = function(v) local val = (type(v) == "table") and (v.Value or v.value or v[1] or v.Name or v.Option or "Flame") or tostring(v); _G.SelectedRaidChip = val; Config.SelectChipRaid = val end })
FruitRaidTab:AddToggle({ Title = "Auto Buy Chip (Beli)",      Default = false, Flag = "AutoBuyChipRaid", Callback = function(v) Config.AutoBuyChipRaid = v end })
FruitRaidTab:AddToggle({ Title = "Auto Buy Chip (Devil Fruit)", Default = false, Flag = "G_AutoBuyChipDF", Callback = function(v) _G.AutoBuyChipDF       = v end })
FruitRaidTab:AddToggle({ Title = "Get Fruit In Inventory Below 1M", Default = false, Flag = "G_AutoGetFruitBelow1M", Callback = function(v) _G.AutoGetFruitBelow1M = v end })
FruitRaidTab:AddToggle({ Title = "Auto Start Raid",           Default = false, Flag = "AutoStartRaid", Callback = function(v) Config.AutoStartRaid  = v end })
FruitRaidTab:AddToggle({ Title = "Auto Farm Raid + Next Island", Default = false, Flag = "AutoRaid", Callback = function(v) Config.AutoRaid    = v end })
FruitRaidTab:AddToggle({ Title = "Auto Awakening",            Default = false, Flag = "G_AutoAwakening", Callback = function(v) _G.AutoAwakening        = v end })

FruitRaidTab:AddSection("Items Law")
FruitRaidTab:AddButton({ Title = "Buy Microchip Law",  Callback = function()
    pcall(function() (CommF_ or {}):InvokeServer("BuyChipLaw") end)
    Notify({ Title = "Comprando Microchip Law!", Image = IMG, Type = "Success", Duration = 2 })
end })
FruitRaidTab:AddButton({ Title = "Start Law Raid",  Callback = function()
    pcall(function() (CommF_ or {}):InvokeServer("StartRaidLaw") end)
    Notify({ Title = "Iniciando Law Raid!", Image = IMG, Type = "Success", Duration = 2 })
end })
FruitRaidTab:AddToggle({ Title = "Auto Buy Microchip",        Default = false, Flag = "AutoBuyChipRaidLaw", Callback = function(v) Config.AutoBuyChipRaidLaw = v end })
FruitRaidTab:AddToggle({ Title = "Auto Start Law Raids",      Default = false, Flag = "AutoStartRaidLaw", Callback = function(v) Config.AutoStartRaidLaw   = v end })
FruitRaidTab:AddToggle({ Title = "Auto Attack Law",           Default = false, Flag = "AutoRaidLaw", Callback = function(v) Config.AutoRaidLaw        = v end })

-- =====================================================
-- TAB: LOCAL PLAYER
-- =====================================================
local LPTab = Window:MakeTab({ Title = T("tab_localplayer"), Icon = "users" })

LPTab:AddSection("Aimbot")
LPTab:AddDropdown({ Title = "Select Player",
    Options = (function()
        local names = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Player then table.insert(names, plr.Name) end
        end
        if #names == 0 then names = { "Nenhum" } end
        return names
    end)(),
    Default = "Nenhum",
    Callback = function(v) Config.SelectedPlayer = (type(v) == "table" and (v[1] or next(v)) or tostring(v)) end })
LPTab:AddToggle({ Title = "Aimbot Method Skill",     Default = false,
    Flag = "AimbotSkill", Callback = function(v)
        Config.AimbotSkill = v
        if v then task.spawn(function() Functions.StartAimbotSkill(Config) end) end
        Notify({ Title = v and "Aimbot Skill ON" or "OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
LPTab:AddToggle({ Title = "Aimbot Camera Closest Player", Default = false,
    Flag = "AimbotGun", Callback = function(v)
        Config.AimbotGun = v
        if v then task.spawn(function() Functions.StartAimbotGun(Config) end) end
        Notify({ Title = v and "Aimbot Gun ON" or "OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })

LPTab:AddSection("Quests Players")
LPTab:AddToggle({ Title = "Auto Get Player Quest",    Default = false, Flag = "G_AutoGetPlayerQuest", Callback = function(v) _G.AutoGetPlayerQuest  = v end })
LPTab:AddToggle({ Title = "Auto Kill Player Quest",   Default = false, Flag = "AutoKillPlayer", Callback = function(v) Config.AutoKillPlayer  = v end })
LPTab:AddToggle({ Title = "Auto Enable PvP",          Default = false,
    Flag = "EnabledPvP", Callback = function(v)
        Config.EnabledPvP = v
        Notify({ Title = v and "Modo PvP ATIVADO" or "Modo PvP Desativado", Image = IMG, Type = v and "Warning" or "Info", Duration = 2 })
    end })
LPTab:AddToggle({ Title = "Auto Safe Mode",           Default = false,
    Flag = "SafeMode", Callback = function(v)
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
    end })
LPTab:AddToggle({ Title = "Enable Invisible",         Default = false, Flag = "G_EnableInvisible", Callback = function(v) _G.EnableInvisible = v end })

LPTab:AddSection("Player Settings")
LPTab:AddToggle({ Title = "Enable Fly",               Default = false, Flag = "G_EnableFly", Callback = function(v) _G.EnableFly = v end })
LPTab:AddSlider({ Title = "Fly Speed", Min = 10, Max = 800, Default = 300,
    Flag = "FlySpeed", Callback = function(v) Config.FlySpeed = v end })
LPTab:AddToggle({ Title = "Dash No Cooldown",         Default = false, Flag = "G_DashNoCD", Callback = function(v) _G.DashNoCD = v end })
LPTab:AddToggle({ Title = "Instance Mink V3",         Default = false, Flag = "G_InstanceMink", Callback = function(v) _G.InstanceMink = v end })
LPTab:AddToggle({ Title = "Instance Energy",          Default = false, Flag = "G_InstanceEnergy", Callback = function(v) _G.InstanceEnergy = v end })
LPTab:AddToggle({ Title = "Instance Soru",            Default = false, Flag = "G_InstanceSoru", Callback = function(v) _G.InstanceSoru   = v end })
LPTab:AddToggle({ Title = "Instance Observation Range", Default = false, Flag = "G_InstanceObsRange", Callback = function(v) _G.InstanceObsRange = v end })
LPTab:AddToggle({ Title = "Ignore Same Teams",        Default = false, Flag = "G_IgnoreSameTeams", Callback = function(v) _G.IgnoreSameTeams = v end })
LPTab:AddToggle({ Title = "Accept Allies",            Default = false, Flag = "G_AcceptAllies", Callback = function(v) _G.AcceptAllies   = v end })
LPTab:AddToggle({ Title = T("ui_auto_speed"),         Default = true,  Flag = "AutoSpeed", Callback = function(v) Config.AutoSpeed = v end })
LPTab:AddSlider({ Title = T("ui_speed"), Min = 20, Max = 100, Default = 20,
    Flag = "Speed", Callback = function(v) Config.Speed = v; if Humanoid then Humanoid.WalkSpeed = v end end })
LPTab:AddToggle({ Title = T("ui_auto_jump"),          Default = true,  Flag = "AutoSetJump", Callback = function(v) Config.AutoSetJump = v end })
LPTab:AddSlider({ Title = T("ui_jump"), Min = 50, Max = 200, Default = 50,
    Flag = "Jump", Callback = function(v) Config.Jump = v; if Humanoid then Humanoid.JumpPower = v end end })
LPTab:AddToggle({ Title = "Turn on Walk on Water",    Default = false,
    Flag = "WalkWater", Callback = function(v)
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
LPTab:AddToggle({ Title = T("ui_infinite_jump"),      Default = false,
    Flag = "InfiniteJump", Callback = function(v)
        Config.InfiniteJump = v
        Notify({ Title = T(v and "infinitejump_on" or "infinitejump_off"), Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })
LPTab:AddToggle({ Title = T("ui_anti_afk"),           Default = false,
    Flag = "AntiAFK", Callback = function(v)
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
LPTab:AddSection("Actions")
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

Teleport:AddSection("Teleport For Island")
Teleport:AddDropdown({ Title = "Select Island",
    Options  = Islands[CurrentSea],
    Default  = Islands[CurrentSea][1],
    Callback = function(v) Config.FarmIsland = (type(v) == "table" and (v[1] or next(v)) or tostring(v)) end,
})
Teleport:AddButton({ Title = "Auto Teleport Island",
    Callback = function()
        local islandName = Config.FarmIsland or Islands[CurrentSea][1]
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

Teleport:AddSection("Teleport Portal")
Teleport:AddDropdown({ Title = "Select Portal",
    Options = { "Sky Island", "Underwater City", "Snow Mountain", "Flower Garden", "Cake Island", "Hydra Island", "Floating Turtle" },
    Default = "Sky Island",
    Callback = function(v) _G.SelectedPortal = (type(v) == "table" and (v[1] or next(v)) or tostring(v)) end })
Teleport:AddButton({ Title = "Request Entrance",
    Callback = function()
        pcall(function()
            (CommF_ or {}):InvokeServer("requestEntrance", _G.SelectedPortal or "Sky Island")
        end)
        Notify({ Title = "Teleportando via portal!", Image = IMG, Type = "Success", Duration = 3 })
    end })

Teleport:AddSection("Teleport for NPCs")
Teleport:AddDropdown({ Title = "Select NPC",
    Options = { "Sword Dealer", "Blox Fruit Dealer", "Pirate Bartender", "Marine Admiral", "Spy", "Chief Warden", "Sick Man" },
    Default = "Sword Dealer",
    Callback = function(v) _G.SelectedNPC = (type(v) == "table" and (v[1] or next(v)) or tostring(v)) end })
Teleport:AddToggle({ Title = "Auto Tween to NPC",
    Default = false,
    Flag = "G_AutoTweenToNPC", Callback = function(v)
        _G.AutoTweenToNPC = v
        if v then
            task.spawn(function()
                while _G.AutoTweenToNPC do
                    pcall(function()
                        local npc = _G.SelectedNPC or "Sword Dealer"
                        local found = workspace:FindFirstChild(npc, true)
                        if found and HumanoidRootPart then
                            local cf = found:IsA("BasePart") and found.CFrame or (found:FindFirstChild("HumanoidRootPart") and found.HumanoidRootPart.CFrame)
                            if cf then Functions.FlyToPosition(cf, TweenService, Config, isTeleporting, NotAutoEquip) end
                        end
                    end)
                    task.wait(3)
                end
            end)
        end
    end })

Teleport:AddSection("Quick TP (Quest Atual)")
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
Teleport:AddSection("Custom Coords")
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

-- =====================================================
-- TAB: SHOP
-- =====================================================
local ShopTab = Window:MakeTab({ Title = "Shop", Icon = "shoppingbag" })

ShopTab:AddSection("Style")
ShopTab:AddButton({ Title = "Buy Black Leg",      Callback = function() pcall(function() (CommF_ or {}):InvokeServer("BuyFightingStyle","Black Leg") end); Notify({ Title = "Comprado: Black Leg", Image = IMG, Type = "Success", Duration = 2 }) end })
ShopTab:AddButton({ Title = "Buy Electro",        Callback = function() pcall(function() (CommF_ or {}):InvokeServer("BuyFightingStyle","Electro") end); Notify({ Title = "Comprado: Electro", Image = IMG, Type = "Success", Duration = 2 }) end })
ShopTab:AddButton({ Title = "Buy Fishman Karate", Callback = function() pcall(function() (CommF_ or {}):InvokeServer("BuyFightingStyle","Fishman Karate") end); Notify({ Title = "Comprado: Fishman Karate", Image = IMG, Type = "Success", Duration = 2 }) end })
ShopTab:AddButton({ Title = "Buy Dragon Claw",    Callback = function() pcall(function() (CommF_ or {}):InvokeServer("BuyFightingStyle","Dragon Talon") end); Notify({ Title = "Comprado: Dragon Claw", Image = IMG, Type = "Success", Duration = 2 }) end })
ShopTab:AddButton({ Title = "Buy Superhuman",     Callback = function() pcall(function() (CommF_ or {}):InvokeServer("BuyFightingStyle","Superhuman") end); Notify({ Title = "Comprado: Superhuman", Image = IMG, Type = "Success", Duration = 2 }) end })

ShopTab:AddSection("Accessory")
ShopTab:AddButton({ Title = "Buy Tomoe Ring",    Callback = function() pcall(function() (CommF_ or {}):InvokeServer("BuyItem","Tomoe Ring") end); Notify({ Title = "Comprado: Tomoe Ring", Image = IMG, Type = "Success", Duration = 2 }) end })
ShopTab:AddButton({ Title = "Buy Black Cape",    Callback = function() pcall(function() (CommF_ or {}):InvokeServer("BuyItem","Black Cape") end); Notify({ Title = "Comprado: Black Cape", Image = IMG, Type = "Success", Duration = 2 }) end })
ShopTab:AddButton({ Title = "Buy Swordsman Hat", Callback = function() pcall(function() (CommF_ or {}):InvokeServer("BuyItem","Swordsman Hat") end); Notify({ Title = "Comprado: Swordsman Hat", Image = IMG, Type = "Success", Duration = 2 }) end })
ShopTab:AddButton({ Title = "Buy Bizarre Rifle", Callback = function() pcall(function() (CommF_ or {}):InvokeServer("BuyWeapon","Bizarre Rifle") end); Notify({ Title = "Comprado: Bizarre Rifle", Image = IMG, Type = "Success", Duration = 2 }) end })
ShopTab:AddButton({ Title = "Buy Ghoul Mask",    Callback = function() pcall(function() (CommF_ or {}):InvokeServer("BuyItem","Ghoul Mask") end); Notify({ Title = "Comprado: Ghoul Mask", Image = IMG, Type = "Success", Duration = 2 }) end })

ShopTab:AddSection("Weapon World 1")
local world1Weapons = { "Cutlass","Katana","Iron Mace","Dual Katana","Pipe","Bisento","Soul Cane","Slingshot","Musket","Dual Flintlock","Flintlock","Refined Flintlock","Cannon","Kabucha" }
for _, wep in ipairs(world1Weapons) do
    local name = wep
    ShopTab:AddButton({ Title = "Buy " .. name, Callback = function()
        pcall(function() (CommF_ or {}):InvokeServer("BuyWeapon", name) end)
        Notify({ Title = "Comprado: " .. name, Image = IMG, Type = "Success", Duration = 2 })
    end })
end

ShopTab:AddSection("Fragments Shop")
ShopTab:AddButton({ Title = "Buy Refund Stats",  Callback = function() pcall(function() (CommF_ or {}):InvokeServer("BuyItem","Refund Stats") end); Notify({ Title = "Comprado: Refund Stats", Image = IMG, Type = "Success", Duration = 2 }) end })
ShopTab:AddButton({ Title = "Buy Reroll Race",   Callback = function() pcall(function() (CommF_ or {}):InvokeServer("BuyItem","Reroll Race") end); Notify({ Title = "Comprado: Reroll Race", Image = IMG, Type = "Success", Duration = 2 }) end })
ShopTab:AddButton({ Title = "Buy Ghoul Race",    Callback = function() pcall(function() (CommF_ or {}):InvokeServer("BuyRace","Ghoul") end); Notify({ Title = "Comprado: Ghoul Race", Image = IMG, Type = "Success", Duration = 2 }) end })
ShopTab:AddButton({ Title = "Buy Cyborg Race (2.5k)", Callback = function() pcall(function() (CommF_ or {}):InvokeServer("BuyRace","Cyborg") end); Notify({ Title = "Comprado: Cyborg Race", Image = IMG, Type = "Success", Duration = 2 }) end })
ShopTab:AddButton({ Title = "Buy Draco Race",    Callback = function() pcall(function() (CommF_ or {}):InvokeServer("BuyRace","Draco") end); Notify({ Title = "Comprado: Draco Race", Image = IMG, Type = "Success", Duration = 2 }) end })

-- =====================================================
-- TAB: MISCELLANEOUS
-- =====================================================
local Misc = Window:MakeTab({ Title = "Misc", Icon = "calendarsearch" })

-- =====================================================
-- TAB: DEBUG CONFIG
-- =====================================================
local DebugCfg = Window:MakeTab({ Title = "Debug Config", Icon = "settings" })

DebugCfg:AddSection("Painel de Debug")
DebugCfg:AddToggle({ Title = "Mostrar Painel Debug", Default = true,
    Callback = function(v)
        pcall(function()
            local m = _G._debugGuiMain
            if m then m.Visible = v end
            if _G._debugSave then
                _G._debugSave.visible = v
                if _G._saveDebugPanel then _G._saveDebugPanel() end
            end
        end)
    end })
DebugCfg:AddButton({ Title = "Resetar Posição do Painel", Callback = function()
    pcall(function()
        local m = _G._debugGuiMain
        if m then m.Position = UDim2.fromOffset(14, 14) end
        if _G._debugSave then
            _G._debugSave.x = 14
            _G._debugSave.y = 14
            if _G._saveDebugPanel then _G._saveDebugPanel() end
        end
    end)
end })

DebugCfg:AddSection("Linhas Visíveis")
local _lineNames = {
    { key = "show_mode",    title = "Modo"    },
    { key = "show_status",  title = "Status"  },
    { key = "show_target",  title = "Alvo"    },
    { key = "show_island",  title = "Ilha"    },
    { key = "show_sea",     title = "Mar"     },
    { key = "show_kills",   title = "Kills"   },
    { key = "show_bring",   title = "BringMob"},
    { key = "show_weapon",  title = "Arma"    },
    { key = "show_skills",  title = "Skills"  },
    { key = "show_uptime",  title = "Uptime"  },
    { key = "show_moon",    title = "🌙 Lua"  },
    { key = "show_chalice", title = "🏆 Cálice"},
    { key = "show_server",  title = "🕐 Server"},
}
for _, entry in ipairs(_lineNames) do
    local key = entry.key
    DebugCfg:AddToggle({ Title = entry.title,
        Default = (_G._debugSave == nil or _G._debugSave[key] ~= false),
        Callback = function(v)
            pcall(function()
                if _G._debugSave then _G._debugSave[key] = v end
                if _G._applyDebugLineVisibility then _G._applyDebugLineVisibility() end
                if _G._saveDebugPanel then _G._saveDebugPanel() end
            end)
        end })
end

-- =====================================================
-- BOTÃO TWEEN FLY STOP + TOGGLE
-- =====================================================
DebugCfg:AddSection("Tween Fly")
DebugCfg:AddToggle({ Title = "Mostrar Botão Stop Fly", Default = true,
    Callback = function(v)
        pcall(function()
            local gui = Player.PlayerGui:FindFirstChild("LotuxStopFlyBtn")
            if gui then
                local btn = gui:FindFirstChildWhichIsA("TextButton", true)
                if btn then btn.Visible = v end
            end
        end)
    end })
DebugCfg:AddButton({ Title = "⏹ Stop Tween Fly Agora", Callback = function()
    pcall(function()
        isTeleporting.value = false
        Functions.StopTeleport()
        local char = Player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, obj in ipairs(hrp:GetChildren()) do
                if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
                    obj:Destroy()
                end
            end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) end
        end
    end)
    Notify({ Title = "Tween Fly parado!", Image = IMG, Type = "Info", Duration = 2 })
end })

Misc:AddSection("Job ID")
local jobIDBox = Misc:AddTextBox({ Title = "Job ID", Default = game.JobId, PlaceholderText = "Cole ou copie o Job ID", ClearText = false,
    Callback = function(v) _G.TargetJobID = (type(v) == "table" and (v[1] or next(v)) or tostring(v)) end })
Misc:AddButton({ Title = "Teleport Job ID", Callback = function()
    local id = _G.TargetJobID or ""
    if id ~= "" then
        pcall(function()
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, id, Player)
        end)
        Notify({ Title = "Teleportando para: " .. id, Image = IMG, Type = "Info", Duration = 3 })
    else
        Notify({ Title = "Digite um Job ID primeiro!", Image = IMG, Type = "Error", Duration = 3 })
    end
end })
Misc:AddButton({ Title = "Copy JobID", Callback = function()
    pcall(function() setclipboard(game.JobId) end)
    Notify({ Title = "Job ID copiado!", Description = game.JobId, Image = IMG, Type = "Success", Duration = 3 })
end })

Misc:AddSection("Player GUI")
Misc:AddButton({ Title = "Devil Fruit Shop",        Callback = function() pcall(function() (CommF_ or {}):InvokeServer("OpenShop","FruitShop") end) end })
Misc:AddButton({ Title = "Advanced Fruit Dealer",   Callback = function() pcall(function() (CommF_ or {}):InvokeServer("OpenShop","AdvancedFruitDealer") end) end })
Misc:AddButton({ Title = "Open Awakenings Expert",  Callback = function() pcall(function() (CommF_ or {}):InvokeServer("OpenShop","AwakeningExpert") end) end })
Misc:AddButton({ Title = "Open Title Selection",    Callback = function() pcall(function() (CommF_ or {}):InvokeServer("OpenTitleSelection") end) end })
Misc:AddButton({ Title = "Set Pirate Team",         Callback = function() pcall(function() (CommF_ or {}):InvokeServer("SetTeam","Pirates") end); Notify({ Title = "Time: Pirata!", Image = IMG, Type = "Success", Duration = 2 }) end })
Misc:AddButton({ Title = "Set Marine Team",         Callback = function() pcall(function() (CommF_ or {}):InvokeServer("SetTeam","Marines") end); Notify({ Title = "Time: Marine!", Image = IMG, Type = "Success", Duration = 2 }) end })
Misc:AddButton({ Title = "Unlock All Portals",      Callback = function()
    pcall(function()
        local portals = { "Sky Island", "Underwater City", "Snow Mountain", "Flower Garden", "Cake Island", "Hydra Island", "Floating Turtle" }
        for _, p in ipairs(portals) do
            (CommF_ or {}):InvokeServer("requestEntrance", p)
            task.wait(0.2)
        end
    end)
    Notify({ Title = "Portais desbloqueados!", Image = IMG, Type = "Success", Duration = 3 })
end })

Misc:AddSection("Configure")
Misc:AddButton({ Title = "Rain Fruits", Callback = function()
    pcall(function()
        for i = 1, 20 do
            (CommF_ or {}):InvokeServer("GetFruit", math.random(1, 100))
            task.wait(0.1)
        end
    end)
    Notify({ Title = "Frutas chovendo!", Image = IMG, Type = "Success", Duration = 3 })
end })
Misc:AddToggle({ Title = "Turn on Full Bright", Default = false,
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
        Notify({ Title = v and "Full Bright ON" or "Full Bright OFF", Image = IMG, Type = v and "Success" or "Info", Duration = 2 })
    end })

Misc:AddSection("Server")
Misc:AddButton({ Title = "Server Hop",
    Callback = function()
        Notify({ Title = "Server Hop", Description = "Procurando servidor...", Image = IMG, Type = "Info", Duration = 3 })
        task.spawn(function() Functions.ServerHop() end)
    end,
})
Misc:AddButton({ Title = "Hop (sair e re-entrar servidor)", Callback = function()
    task.spawn(function() Functions.Hop() end)
end })

Misc:AddSection(T("sec_script_info"))
Misc:AddParagraph({ Title = "Lotux Hub v3.0", Text =
    "by LoadFlint/lucas\n" ..
    "[>] Auto Farm Level + Quest Fix\n" ..
    "[>] ESP completo (mobs, players, ilhas, frutas, baus)\n" ..
    "[>] Race V4, Items Quest, Sea Events\n" ..
    "[>] Volcano, Fishing, Kitsune, Mirage\n" ..
    "[>] Sea 1/2/3 detectado automaticamente"
})
Misc:AddButton({ Title = T("ui_close_ui"), Callback = function() Window:CloseBtn() end })
-- =====================================================
-- INICIA FEATURES ATIVAS POR PADRAO
-- =====================================================

-- Sem neblina por padrao
Lighting.FogEnd = Config.NoFog and 100000 or 1000

-- =====================================================
-- PAINEL DE DEBUG (STATUS DO SCRIPT)
-- Estilo Hoho Hub - mostra o que o script está fazendo
-- Arrastável, minimizável, atualiza a cada 0.5s
-- =====================================================
task.spawn(function()
    local PGui      = Player:WaitForChild("PlayerGui")
    local TS        = game:GetService("TweenService")

    -- ── Save/Load do painel ────────────────────────
    local DEBUG_SAVE_FILE = "lotux_debug_panel.json"
    local debugSave = {
        x          = 14,
        y          = 14,
        minimized  = false,
        visible    = true,
        -- quais linhas mostrar
        show_mode    = true,
        show_status  = true,
        show_target  = true,
        show_island  = true,
        show_sea     = true,
        show_kills   = true,
        show_bring   = true,
        show_weapon  = true,
        show_skills  = true,
        show_uptime  = true,
        show_moon    = true,
        show_chalice = true,
        show_server  = true,
        w            = 240,
        h            = 285,
    }
    pcall(function()
        if readfile and isfile and isfile(DEBUG_SAVE_FILE) then
            local ok, data = pcall(function()
                return HttpService:JSONDecode(readfile(DEBUG_SAVE_FILE))
            end)
            if ok and type(data) == "table" then
                for k, v in pairs(data) do debugSave[k] = v end
            end
        end
    end)
    local function SaveDebugPanel()
        pcall(function()
            if writefile then
                writefile(DEBUG_SAVE_FILE, HttpService:JSONEncode(debugSave))
            end
        end)
    end
    -- Expõe para a tab Debug Config poder ler/escrever
    _G._debugSave        = debugSave
    _G._saveDebugPanel   = SaveDebugPanel

    -- ── Fecha painel anterior se existir (re-execução) ──
    pcall(function()
        local old = PGui:FindFirstChild("LotuxDebugPanel")
        if old then old:Destroy() end
    end)

    -- ── GUI container ──────────────────────────────
    local DebugGui  = Instance.new("ScreenGui")
    DebugGui.Name              = "LotuxDebugPanel"
    DebugGui.ResetOnSpawn      = false
    DebugGui.ZIndexBehavior    = Enum.ZIndexBehavior.Sibling
    DebugGui.DisplayOrder      = 999
    DebugGui.IgnoreGuiInset    = true
    DebugGui.Parent            = PGui

    -- ── Frame principal ────────────────────────────
    local Main = Instance.new("Frame")
    Main.Name                  = "Main"
    Main.Size = UDim2.fromOffset(debugSave.w or 240, debugSave.h or 285)
    Main.Position              = UDim2.fromOffset(debugSave.x, debugSave.y)
    Main.Visible               = debugSave.visible
    Main.BackgroundColor3      = Color3.fromRGB(10, 10, 18)
    Main.BackgroundTransparency = 0.12
    Main.BorderSizePixel       = 0
    Main.ClipsDescendants      = true
    Main.Parent                = DebugGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

    -- borda roxa
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color     = Color3.fromRGB(100, 50, 220)
    Stroke.Thickness = 1.5
    Stroke.Transparency = 0.3

    -- ── Barra de título (drag handle) ──────────────
    local TitleBar = Instance.new("Frame")
    TitleBar.Name              = "TitleBar"
    TitleBar.Size              = UDim2.new(1, 0, 0, 28)
    TitleBar.BackgroundColor3  = Color3.fromRGB(22, 12, 45)
    TitleBar.BorderSizePixel   = 0
    TitleBar.Parent            = Main
    Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)
    -- fixa só o topo
    local TitleFix = Instance.new("Frame")
    TitleFix.Size = UDim2.new(1, 0, 0.5, 0)
    TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
    TitleFix.BackgroundColor3 = Color3.fromRGB(22, 12, 45)
    TitleFix.BorderSizePixel  = 0
    TitleFix.Parent           = TitleBar

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Text              = "Lotux Debug"
    TitleLbl.Font              = Enum.Font.GothamBold
    TitleLbl.TextSize          = 12
    TitleLbl.TextColor3        = Color3.fromRGB(180, 140, 255)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Size              = UDim2.new(1, -50, 1, 0)
    TitleLbl.Position          = UDim2.fromOffset(10, 0)
    TitleLbl.TextXAlignment    = Enum.TextXAlignment.Left
    TitleLbl.Parent            = TitleBar

    -- botão minimizar
    local MinBtn = Instance.new("TextButton")
    MinBtn.Text                = "—"
    MinBtn.Font                = Enum.Font.GothamBold
    MinBtn.TextSize            = 14
    MinBtn.TextColor3          = Color3.fromRGB(200, 200, 200)
    MinBtn.BackgroundColor3    = Color3.fromRGB(40, 20, 80)
    MinBtn.Size                = UDim2.fromOffset(22, 18)
    MinBtn.Position            = UDim2.new(1, -48, 0.5, -9)
    MinBtn.BorderSizePixel     = 0
    MinBtn.Parent              = TitleBar
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)

    -- botão fechar
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Text              = "X"
    CloseBtn.Font              = Enum.Font.GothamBold
    CloseBtn.TextSize          = 12
    CloseBtn.TextColor3        = Color3.fromRGB(255, 100, 100)
    CloseBtn.BackgroundColor3  = Color3.fromRGB(60, 15, 15)
    CloseBtn.Size              = UDim2.fromOffset(22, 18)
    CloseBtn.Position          = UDim2.new(1, -24, 0.5, -9)
    CloseBtn.BorderSizePixel   = 0
    CloseBtn.Parent            = TitleBar
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

    -- ── Área de linhas de status ───────────────────
    local Body = Instance.new("Frame")
    Body.Name                  = "Body"
    Body.Size                  = UDim2.new(1, -12, 1, -36)
    Body.Position              = UDim2.fromOffset(6, 32)
    Body.BackgroundTransparency = 1
    Body.Parent                = Main

    local BodyLayout = Instance.new("UIListLayout", Body)
    BodyLayout.SortOrder       = Enum.SortOrder.LayoutOrder
    BodyLayout.Padding         = UDim.new(0, 3)

    -- helper: cria uma linha "Label: Valor"
    local function MakeLine(label, order)
        local row = Instance.new("Frame")
        row.Size               = UDim2.new(1, 0, 0, 18)
        row.BackgroundTransparency = 1
        row.LayoutOrder        = order
        row.Parent             = Body

        local lbl = Instance.new("TextLabel")
        lbl.Text               = label .. ":"
        lbl.Font               = Enum.Font.Gotham
        lbl.TextSize           = 11
        lbl.TextColor3         = Color3.fromRGB(140, 120, 200)
        lbl.BackgroundTransparency = 1
        lbl.Size               = UDim2.new(0.45, 0, 1, 0)
        lbl.TextXAlignment     = Enum.TextXAlignment.Left
        lbl.Parent             = row

        local val = Instance.new("TextLabel")
        val.Text               = "—"
        val.Font               = Enum.Font.GothamBold
        val.TextSize           = 11
        val.TextColor3         = Color3.fromRGB(230, 230, 255)
        val.BackgroundTransparency = 1
        val.Size               = UDim2.new(0.55, 0, 1, 0)
        val.Position           = UDim2.new(0.45, 0, 0, 0)
        val.TextXAlignment     = Enum.TextXAlignment.Left
        val.ClipsDescendants   = true
        val.Parent             = row

        return val
    end

    local V_Mode     = MakeLine("Modo",       1)
    local V_Status   = MakeLine("Status",     2)
    local V_Target   = MakeLine("Alvo",       3)
    local V_Island   = MakeLine("Ilha",       4)
    local V_Sea      = MakeLine("Mar",        5)
    local V_Kills    = MakeLine("Kills",      6)
    local V_Bring    = MakeLine("BringMob",   7)
    local V_Weapon   = MakeLine("Arma",       8)
    local V_Skills   = MakeLine("Skills",     9)
    local V_Uptime   = MakeLine("Uptime",     10)
    local V_Moon     = MakeLine("Lua",     11)
    local V_Chalice  = MakeLine("Cálice",  12)
    local V_Server   = MakeLine("Server",  13)

    -- linha de log (última ação)
    local LogRow = Instance.new("TextLabel")
    LogRow.Name                = "LastLog"
    LogRow.Size                = UDim2.new(1, 0, 0, 18)
    LogRow.BackgroundTransparency = 1
    LogRow.Font                = Enum.Font.Gotham
    LogRow.TextSize            = 10
    LogRow.TextColor3          = Color3.fromRGB(100, 200, 140)
    LogRow.TextXAlignment      = Enum.TextXAlignment.Left
    LogRow.ClipsDescendants    = true
    LogRow.LayoutOrder         = 14
    LogRow.Parent              = Body

    -- ── Log global: qualquer print("[AutoRaid]") aparece aqui ──
    _G.LotuxDebugLog = function(msg)
        if LogRow and LogRow.Parent then
            LogRow.Text = "› " .. tostring(msg):sub(1, 38)
        end
    end
    -- Hook no print: captura TODOS os prints do script
    local _origPrint = print
    print = function(...)
        _origPrint(...)
        local msg = table.concat({...}, " ")
        pcall(function() _G.LotuxDebugLog(msg) end)
    end
    -- Captura warn também
    local _origWarn = warn
    warn = function(...)
        _origWarn(...)
        local msg = "⚠ " .. table.concat({...}, " ")
        pcall(function() _G.LotuxDebugLog(msg) end)
    end

    -- ── Drag (salva posição ao soltar) ────────────
    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = inp.Position
            startPos  = Main.Position
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
                      or inp.UserInputType == Enum.UserInputType.Touch) then
            local delta = inp.Position - dragStart
            local nx = startPos.X.Offset + delta.X
            local ny = startPos.Y.Offset + delta.Y
            Main.Position = UDim2.fromOffset(nx, ny)
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                -- Salva a posição final
                debugSave.x = Main.Position.X.Offset
                debugSave.y = Main.Position.Y.Offset
                SaveDebugPanel()
            end
            dragging = false
        end
    end)

    -- ── Resize handle (canto inferior direito) ────────
    local MIN_W, MIN_H = 200, 120
    local ResizeHandle = Instance.new("TextButton")
    ResizeHandle.Text              = ""
    ResizeHandle.Size              = UDim2.fromOffset(14, 14)
    ResizeHandle.Position          = UDim2.new(1, -14, 1, -14)
    ResizeHandle.BackgroundColor3  = Color3.fromRGB(100, 50, 220)
    ResizeHandle.BackgroundTransparency = 0.4
    ResizeHandle.BorderSizePixel   = 0
    ResizeHandle.ZIndex            = 10
    ResizeHandle.Parent            = Main
    Instance.new("UICorner", ResizeHandle).CornerRadius = UDim.new(0, 3)
    local ResizeIcon = Instance.new("TextLabel")
    ResizeIcon.Text              = "25E2"
    ResizeIcon.TextSize          = 10
    ResizeIcon.Font              = Enum.Font.GothamBold
    ResizeIcon.TextColor3        = Color3.fromRGB(255, 255, 255)
    ResizeIcon.BackgroundTransparency = 1
    ResizeIcon.Size              = UDim2.fromScale(1, 1)
    ResizeIcon.ZIndex            = 11
    ResizeIcon.Parent            = ResizeHandle

    local resizing, resizeStart, resizeStartSize = false, Vector3.new(), Vector2.new()
    ResizeHandle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            resizing        = true
            resizeStart     = inp.Position
            resizeStartSize = Vector2.new(Main.Size.X.Offset, Main.Size.Y.Offset)
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(inp)
        if resizing and (inp.UserInputType == Enum.UserInputType.MouseMovement
                      or inp.UserInputType == Enum.UserInputType.Touch) then
            local delta = inp.Position - resizeStart
            local nw = math.max(MIN_W, resizeStartSize.X + delta.X)
            local nh = math.max(MIN_H, resizeStartSize.Y + delta.Y)
            Main.Size = UDim2.fromOffset(nw, nh)
            Body.Size = UDim2.new(1, -12, 1, -36)
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            if resizing then
                debugSave.w = Main.Size.X.Offset
                debugSave.h = Main.Size.Y.Offset
                SaveDebugPanel()
            end
            resizing = false
        end
    end)

    -- ── Minimizar (salva estado) ───────────────────
    local minimized = debugSave.minimized or false
    -- Aplica estado salvo imediatamente
    if minimized then
        Main.Size    = UDim2.fromOffset(debugSave.w or 240, 28)
        Body.Visible = false
        MinBtn.Text  = "▢"
    end
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        local fullH = debugSave.h or 285
        local targetH = minimized and 28 or fullH
        TS:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Size = UDim2.fromOffset(Main.Size.X.Offset, targetH)
        }):Play()
        MinBtn.Text  = minimized and "▢" or "—"
        Body.Visible = not minimized
        debugSave.minimized = minimized
        SaveDebugPanel()
    end)

    -- ── Fechar (salva estado) ─────────────────────
    CloseBtn.MouseButton1Click:Connect(function()
        debugSave.visible = false
        SaveDebugPanel()
        DebugGui:Destroy()
    end)

    -- Expõe referências para a tab Debug Config
    _G._debugGuiMain  = Main
    _G._debugGui      = DebugGui

    -- Mapa linha -> chave do save (para a tab Debug Config ocultar/mostrar)
    local _lineRefs = {
        { ref = V_Mode,    key = "show_mode"    },
        { ref = V_Status,  key = "show_status"  },
        { ref = V_Target,  key = "show_target"  },
        { ref = V_Island,  key = "show_island"  },
        { ref = V_Sea,     key = "show_sea"     },
        { ref = V_Kills,   key = "show_kills"   },
        { ref = V_Bring,   key = "show_bring"   },
        { ref = V_Weapon,  key = "show_weapon"  },
        { ref = V_Skills,  key = "show_skills"  },
        { ref = V_Uptime,  key = "show_uptime"  },
        { ref = V_Moon,    key = "show_moon"    },
        { ref = V_Chalice, key = "show_chalice" },
        { ref = V_Server,  key = "show_server"  },
    }
    -- Aplica visibilidade salva em cada linha (a row é o pai do val)
    local function ApplyLineVisibility()
        for _, entry in ipairs(_lineRefs) do
            local row = entry.ref and entry.ref.Parent
            if row then row.Visible = (debugSave[entry.key] ~= false) end
        end
    end
    ApplyLineVisibility()
    _G._applyDebugLineVisibility = ApplyLineVisibility
    _G._debugLineRefs = _lineRefs

    -- ── Update loop ───────────────────────────────
    local function ColorStatus(lbl, ok)
        lbl.TextColor3 = ok
            and Color3.fromRGB(100, 255, 150)
            or  Color3.fromRGB(255, 100, 100)
    end

    while DebugGui and DebugGui.Parent do
        task.wait(0.5)
        pcall(function()
            local elapsed = os.time() - (Config.ScriptStartTime or os.time())
            local h = math.floor(elapsed / 3600)
            local m = math.floor((elapsed % 3600) / 60)
            local s = elapsed % 60
            V_Uptime.Text = string.format("%02d:%02d:%02d", h, m, s)

            V_Sea.Text    = "Sea " .. tostring(CurrentSea or "?")
            -- Kills com kills/min
            local kTotal = Config.KillCount or 0
            local kElapsed = math.max(1, os.time() - (Config.ScriptStartTime or os.time()))
            local kpm = math.floor((kTotal / kElapsed) * 60)
            V_Kills.Text  = tostring(kTotal) .. "  (" .. kpm .. "/min)"

            -- ── Lua: quantas noites faltam para lua cheia ──────────
            -- BF sincroniza o ciclo via workspace:GetServerTimeNow() (Unix timestamp).
            -- Cada dia BF = 1200s (20min). Noite = metade par do ciclo.
            -- Lua cheia ocorre a cada 3 noites (ciclo real do BF = 3 noites).
            -- Fonte de verdade: Lighting.ClockTime (0-24) indica dia/noite agora.
            pcall(function()
                local Lighting        = game:GetService("Lighting")
                local BF_DAY_SECS     = 1200   -- 20 min por ciclo completo dia+noite
                local FULL_MOON_EVERY = 3      -- lua cheia a cada 3 noites no BF
                -- Usa GetServerTimeNow para o número do dia (é isso que o BF usa internamente)
                local serverTime      = workspace:GetServerTimeNow()
                local halfDay         = BF_DAY_SECS / 2   -- 600s = metade do ciclo
                local cyclePos        = serverTime % BF_DAY_SECS
                local isNight         = cyclePos >= halfDay
                local secInPhase      = cyclePos - (isNight and halfDay or 0)
                local secsLeftPhase   = halfDay - secInPhase

                -- Número de noites que já passaram no servidor
                local totalNights     = math.floor(serverTime / halfDay / 2)
                -- Dentro do ciclo de lua cheia
                local nightInCycle    = totalNights % FULL_MOON_EVERY
                local nightsLeft      = FULL_MOON_EVERY - nightInCycle  -- noites até lua cheia

                -- Valida com Lighting: ClockTime 18-6 = noite
                local clock = Lighting.ClockTime
                local isNightLighting = (clock >= 18 or clock < 6)

                if nightsLeft == FULL_MOON_EVERY and isNightLighting then
                    -- Lua cheia agora
                    V_Moon.Text = "🌕 CHEIA! " .. string.format("%dm%02ds", math.floor(secsLeftPhase/60), secsLeftPhase%60)
                    V_Moon.TextColor3 = Color3.fromRGB(255, 230, 80)
                elseif nightsLeft == 1 and not isNightLighting then
                    -- Próxima noite é lua cheia
                    V_Moon.Text = "🌔 Hoje! " .. string.format("%dm%02ds", math.floor(secsLeftPhase/60), secsLeftPhase%60)
                    V_Moon.TextColor3 = Color3.fromRGB(220, 210, 80)
                else
                    -- N noites restantes
                    local nightsToWait = nightsLeft - (isNightLighting and 0 or 0)
                    local secsTotal    = (nightsToWait * BF_DAY_SECS) - secInPhase
                    if secsTotal < 0 then secsTotal = 0 end
                    local h = math.floor(secsTotal / 3600)
                    local m = math.floor((secsTotal % 3600) / 60)
                    if h > 0 then
                        V_Moon.Text = nightsLeft .. " noites  " .. h .. "h" .. string.format("%02dm", m)
                    else
                        V_Moon.Text = nightsLeft .. " noites  " .. m .. "min"
                    end
                    V_Moon.TextColor3 = Color3.fromRGB(170, 170, 255)
                end
            end)

            -- ── Cálice: tempo até o próximo cálice no baú ─────────
            -- No BF o God's Chalice aparece no baú especial a cada 4h de server.
            -- O timer reseta quando o server inicia.
            -- DistributedGameTime = segundos desde que o server iniciou (correto)
            pcall(function()
                local CHALICE_INTERVAL = 4 * 3600  -- 4 horas em segundos
                local serverAge = math.floor(workspace.DistributedGameTime)
                local secSinceLast = serverAge % CHALICE_INTERVAL
                local secsLeft     = CHALICE_INTERVAL - secSinceLast
                local h  = math.floor(secsLeft / 3600)
                local m  = math.floor((secsLeft % 3600) / 60)
                local s  = secsLeft % 60
                if secsLeft < 300 then  -- menos de 5 min: destaca em verde
                    V_Chalice.Text = string.format("⚡ %dm%02ds!", m, s)
                    V_Chalice.TextColor3 = Color3.fromRGB(80, 255, 120)
                elseif h > 0 then
                    V_Chalice.Text = string.format("%dh %02dm", h, m)
                    V_Chalice.TextColor3 = Color3.fromRGB(230, 230, 255)
                else
                    V_Chalice.Text = string.format("%dm %02ds", m, s)
                    V_Chalice.TextColor3 = Color3.fromRGB(230, 230, 255)
                end
            end)

            -- ── Tempo do server (idade real desde o início) ────────
            -- DistributedGameTime = segundos reais desde que o server iniciou
            pcall(function()
                local secs = math.floor(workspace.DistributedGameTime)
                local h = math.floor(secs / 3600)
                local m = math.floor((secs % 3600) / 60)
                local s = secs % 60
                if h > 0 then
                    V_Server.Text = string.format("%dh %02dm %02ds", h, m, s)
                else
                    V_Server.Text = string.format("%dm %02ds", m, s)
                end
                -- Destaca servidores velhos (>2h) em amarelo, >4h em vermelho
                if h >= 4 then
                    V_Server.TextColor3 = Color3.fromRGB(255, 100, 100)
                elseif h >= 2 then
                    V_Server.TextColor3 = Color3.fromRGB(255, 200, 80)
                else
                    V_Server.TextColor3 = Color3.fromRGB(230, 230, 255)
                end
            end)
            V_Bring.Text  = Config.BringMob and ("ON  " .. tostring(Config.BringDistance) .. "st") or "OFF"
            ColorStatus(V_Bring, Config.BringMob)

            -- Arma
            local wName = Config.SelectedWeaponName ~= "" and Config.SelectedWeaponName or Config.FarmWeapon
            V_Weapon.Text = tostring(wName):sub(1, 18) or "—"

            -- Skills
            local sk = {}
            if Config.AutoSkillZ then sk[#sk+1] = "Z" end
            if Config.AutoSkillX then sk[#sk+1] = "X" end
            if Config.AutoSkillC then sk[#sk+1] = "C" end
            V_Skills.Text = #sk > 0 and table.concat(sk, "+") or "OFF"

            -- Modo principal
            if Config.AutoRaid then
                V_Mode.Text = "Auto Raid"
                V_Mode.TextColor3 = Color3.fromRGB(255, 200, 80)

                -- Status da raid
                local map     = workspace:FindFirstChild("Map")
                local raidMap = map and map:FindFirstChild("RaidMap")
                local islandNum = 0
                if raidMap then
                    for i = 5, 1, -1 do
                        if raidMap:FindFirstChild("RaidIsland" .. i) then
                            islandNum = i; break
                        end
                    end
                end
                if islandNum > 0 then
                    V_Island.Text = "RaidIsland " .. islandNum .. "/5"
                    V_Island.TextColor3 = Color3.fromRGB(100, 220, 255)
                    V_Status.Text = "Farmando"
                    V_Status.TextColor3 = Color3.fromRGB(100, 255, 150)
                else
                    V_Island.Text = "Aguardando..."
                    V_Island.TextColor3 = Color3.fromRGB(200, 200, 200)
                    V_Status.Text = "Na fila"
                    V_Status.TextColor3 = Color3.fromRGB(255, 200, 80)
                end

                -- Alvo (boss ou mob)
                local enemies = workspace:FindFirstChild("Enemies")
                local targetName = "—"
                if enemies then
                    for _, v in ipairs(enemies:GetChildren()) do
                        local vHum = v:FindFirstChild("Humanoid")
                        if vHum and vHum.Health > 0 then
                            targetName = v.Name:sub(1, 18)
                            break
                        end
                    end
                end
                V_Target.Text = targetName

            elseif Config.AutoFarmLevel then
                V_Mode.Text = "Farm Level"
                V_Mode.TextColor3 = Color3.fromRGB(100, 200, 255)

                -- Pega o nome da ilha da quest atual (não o Config.FarmIsland que pode ser tabela)
                local islandText = "—"
                pcall(function()
                    local q = Functions.GetQuestForLevel(QuestList, CurrentSea, Player)
                    if q and q.NameQuest then
                        -- NameQuest é algo como "DeepForestIsland3", formata bonito
                        islandText = q.NameQuest:gsub("Quest%d*$", ""):gsub("Island%d*$", ""):gsub("(%l)(%u)", "%1 %2"):sub(1, 18)
                    end
                end)
                V_Island.Text = islandText
                V_Island.TextColor3 = Color3.fromRGB(200, 200, 200)
                V_Status.Text = farmRunning and "Farmando" or "Aguardando"
                ColorStatus(V_Status, farmRunning)
                V_Target.Text = currentTarget and currentTarget.Name:sub(1, 18) or "—"

            elseif Config.AutoFarmNearest then
                V_Mode.Text = "Farm Nearest"
                V_Mode.TextColor3 = Color3.fromRGB(100, 200, 255)
                V_Island.Text = "—"
                V_Status.Text = farmRunning and "Farmando" or "Aguardando"
                ColorStatus(V_Status, farmRunning)
                V_Target.Text = currentTarget and currentTarget.Name:sub(1, 18) or "—"
            else
                V_Mode.Text = "Inativo"
                V_Mode.TextColor3 = Color3.fromRGB(150, 150, 150)
                V_Status.Text = "—"
                V_Status.TextColor3 = Color3.fromRGB(150, 150, 150)
                V_Target.Text = "—"
                V_Island.Text = "—"
            end
        end)
    end
end)

-- =====================================================
-- HELPER: botão flutuante draggable com save de posição
-- =====================================================
local function MakeDraggableFloatBtn(opts)
    -- opts: { GuiName, SaveKey, DefaultX, DefaultY, BtnText, BtnColor, StrokeColor, OnClick }
    local PGuiF = Player:WaitForChild("PlayerGui")
    -- Destroi instância anterior (re-execução)
    pcall(function()
        local old = PGuiF:FindFirstChild(opts.GuiName)
        if old then old:Destroy() end
    end)

    -- Carrega posição salva
    local savedX, savedY = opts.DefaultX, opts.DefaultY
    pcall(function()
        if readfile and isfile and isfile(opts.SaveKey) then
            local ok, data = pcall(function()
                return HttpService:JSONDecode(readfile(opts.SaveKey))
            end)
            if ok and type(data) == "table" then
                savedX = data.x or savedX
                savedY = data.y or savedY
            end
        end
    end)

    local Gui = Instance.new("ScreenGui")
    Gui.Name           = opts.GuiName
    Gui.ResetOnSpawn   = false
    Gui.DisplayOrder   = opts.DisplayOrder or 997
    Gui.IgnoreGuiInset = true
    Gui.Parent         = PGuiF

    local Btn = Instance.new("TextButton")
    Btn.Text                  = opts.BtnText
    Btn.Font                  = Enum.Font.GothamBold
    Btn.TextSize              = 12
    Btn.TextColor3            = Color3.fromRGB(255, 255, 255)
    Btn.BackgroundColor3      = opts.BtnColor
    Btn.BackgroundTransparency = 0.15
    Btn.Size                  = UDim2.fromOffset(108, 32)
    Btn.Position              = UDim2.fromOffset(savedX, savedY)
    Btn.BorderSizePixel       = 0
    Btn.Active                = true
    Btn.Parent                = Gui
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    local Stroke = Instance.new("UIStroke", Btn)
    Stroke.Color        = opts.StrokeColor
    Stroke.Thickness    = 1.2
    Stroke.Transparency = 0.4

    -- Drag logic
    local UIS        = game:GetService("UserInputService")
    local dragging   = false
    local dragStart  = Vector3.new()
    local startPos   = UDim2.fromOffset(0, 0)
    local didDrag    = false

    Btn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            didDrag   = false
            dragStart = inp.Position
            startPos  = Btn.Position
        end
    end)

    UIS.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
                      or inp.UserInputType == Enum.UserInputType.Touch) then
            local delta = inp.Position - dragStart
            if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then
                didDrag = true
            end
            Btn.Position = UDim2.fromOffset(
                startPos.X.Offset + delta.X,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                -- Salva posição nova
                pcall(function()
                    if writefile then
                        writefile(opts.SaveKey, HttpService:JSONEncode({
                            x = Btn.Position.X.Offset,
                            y = Btn.Position.Y.Offset,
                        }))
                    end
                end)
            end
            dragging = false
        end
    end)

    -- Click só dispara se NÃO arrastou
    Btn.MouseButton1Click:Connect(function()
        if didDrag then didDrag = false return end
        opts.OnClick(Btn)
    end)

    return Btn, Gui
end

-- =====================================================
-- BOTÃO FLUTUANTE: RESET UI  (draggable)
-- =====================================================
task.spawn(function()
    local ResetBtn = MakeDraggableFloatBtn({
        GuiName      = "LotuxResetUIBtn",
        SaveKey      = "lotux_resetbtn_pos.json",
        DefaultX     = math.floor((workspace.CurrentCamera.ViewportSize.X or 800) - 105),
        DefaultY     = 44,
        DisplayOrder = 997,
        BtnText      = "Reset UI",
        BtnColor     = Color3.fromRGB(55, 35, 120),
        StrokeColor  = Color3.fromRGB(100, 60, 220),
        OnClick = function(btn)
            pcall(function()
                local coreGui   = game:GetService("CoreGui")
                local libGui    = coreGui:FindFirstChild("redz Library V5")
                local mainFrame = libGui and libGui:FindFirstChild("Hub")
                if mainFrame then
                    mainFrame.Position = UDim2.new(0.5, -mainFrame.Size.X.Offset/2, 0.5, -mainFrame.Size.Y.Offset/2)
                end
            end)
            btn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
            btn.Text = "Resetado!"
            task.delay(0.8, function()
                if btn and btn.Parent then
                    btn.BackgroundColor3 = Color3.fromRGB(55, 35, 120)
                    btn.Text = "Reset UI"
                end
            end)
        end,
    })
end)

-- =====================================================
-- BOTÃO FLUTUANTE: STOP TWEEN FLY  (draggable)
-- Pode ser ocultado pelo toggle na tab Debug Config.
-- =====================================================
task.spawn(function()
    local StopBtn = MakeDraggableFloatBtn({
        GuiName      = "LotuxStopFlyBtn",
        SaveKey      = "lotux_stopbtn_pos.json",
        DefaultX     = math.floor((workspace.CurrentCamera.ViewportSize.X or 800) - 105),
        DefaultY     = 10,
        DisplayOrder = 998,
        BtnText      = "Stop Fly",
        BtnColor     = Color3.fromRGB(170, 35, 35),
        StrokeColor  = Color3.fromRGB(220, 60, 60),
        OnClick = function(btn)
            pcall(function()
                -- Para o voo
                isTeleporting.value = false
                Functions.StopTeleport()
                -- Desativa todos os loops de farm/teleporte para não reinicar o fly
                Config.AutoFarmLevel    = false
                Config.AutoFarmNearest  = false
                Config.AutoFarmMastery  = false
                Config.TweenFlyFruit    = false
                Config.AutoRaid         = false
                Config.AutoRaidLaw      = false
                Config.AutoDungeon      = false
                -- Atualiza os toggles da UI (se a library expõe Flags)
                pcall(function()
                    if Flags then
                        if Flags["AutoFarmLevel"]   then Flags["AutoFarmLevel"]:Set(false)   end
                        if Flags["AutoFarmNearest"] then Flags["AutoFarmNearest"]:Set(false) end
                        if Flags["AutoFarmMastery"] then Flags["AutoFarmMastery"]:Set(false) end
                        if Flags["TweenFlyFruit"]   then Flags["TweenFlyFruit"]:Set(false)   end
                        if Flags["AutoRaid"]        then Flags["AutoRaid"]:Set(false)        end
                        if Flags["AutoRaidLaw"]     then Flags["AutoRaidLaw"]:Set(false)     end
                        if Flags["AutoDungeon"]     then Flags["AutoDungeon"]:Set(false)     end
                    end
                end)
                -- Remove BodyMovers do HRP
                local char = Player.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, obj in ipairs(hrp:GetChildren()) do
                        if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
                            obj:Destroy()
                        end
                    end
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) end
                end
            end)
            btn.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
            btn.Text = "Parado!"
            task.delay(0.8, function()
                if btn and btn.Parent then
                    btn.BackgroundColor3 = Color3.fromRGB(170, 35, 35)
                    btn.Text = "Stop Fly"
                end
            end)
        end,
    })

    -- Keybind E para parar o fly rapidamente
    UserInputService.InputBegan:Connect(function(inp, gameProcessed)
        if gameProcessed then return end
        if inp.KeyCode == Enum.KeyCode.E then
            if Config.AutoRaid or Config.AutoFarmLevel or Config.AutoFarmNearest then return end
            if StopBtn then StopBtn.MouseButton1Click:Fire() end
        end
    end)
end)


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

print("UI Loaded v4.4.0")