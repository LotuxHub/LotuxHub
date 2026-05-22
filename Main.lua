-- Lotux Hub Loader v2.0
-- by LoadFlint/lucas

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ╔══════════════════════════════════════════╗
-- ║   ⬇️  URL PRINCIPAL DO SCRIPT (UI.lua)  ║
-- ║   Deixe "" para exibir "Em Desenvolvimento"
-- ╚══════════════════════════════════════════╝
local SCRIPT_URL = "https://raw.githubusercontent.com/LotuxHub/LotuxHub/refs/heads/main/DevCopy/BloxFruits/UI.lua"

-- =====================================================
-- PAINEL "EM DESENVOLVIMENTO" (SCRIPT_URL vazio)
-- =====================================================
local function criarPainelDesenvolvimento()
    if PlayerGui:FindFirstChild("LotuxHubErro") then
        PlayerGui.LotuxHubErro:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LotuxHubErro"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Overlay.BackgroundTransparency = 0.5
    Overlay.BorderSizePixel = 0
    Overlay.ZIndex = 1
    Overlay.Parent = ScreenGui

    local Painel = Instance.new("Frame")
    Painel.Name = "Painel"
    Painel.Size = UDim2.new(0, 420, 0, 260)
    Painel.Position = UDim2.new(0.5, -210, 0.6, -130)
    Painel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Painel.BackgroundTransparency = 1
    Painel.BorderSizePixel = 0
    Painel.ZIndex = 2
    Painel.Parent = ScreenGui
    Instance.new("UICorner", Painel).CornerRadius = UDim.new(0, 12)

    local PainelStroke = Instance.new("UIStroke")
    PainelStroke.Color = Color3.fromRGB(180, 30, 30)
    PainelStroke.Thickness = 1.5
    PainelStroke.Transparency = 0.2
    PainelStroke.Parent = Painel

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 52)
    Header.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    Header.BorderSizePixel = 0
    Header.ZIndex = 3
    Header.Parent = Painel
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

    local HeaderFix = Instance.new("Frame")
    HeaderFix.Size = UDim2.new(1, 0, 0, 12)
    HeaderFix.Position = UDim2.new(0, 0, 1, -12)
    HeaderFix.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    HeaderFix.BorderSizePixel = 0
    HeaderFix.ZIndex = 3
    HeaderFix.Parent = Header

    local Icone = Instance.new("ImageLabel")
    Icone.Size = UDim2.new(0, 30, 0, 30)
    Icone.Position = UDim2.new(0, 14, 0.5, -15)
    Icone.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    Icone.Image = "rbxassetid://111672166073808"
    Icone.ScaleType = Enum.ScaleType.Fit
    Icone.ZIndex = 4
    Icone.Parent = Header
    Instance.new("UICorner", Icone).CornerRadius = UDim.new(0, 6)

    local TituloHub = Instance.new("TextLabel")
    TituloHub.Size = UDim2.new(1, -60, 1, 0)
    TituloHub.Position = UDim2.new(0, 54, 0, 0)
    TituloHub.BackgroundTransparency = 1
    TituloHub.Text = "Lotux Hub"
    TituloHub.TextColor3 = Color3.fromRGB(210, 210, 220)
    TituloHub.TextSize = 15
    TituloHub.Font = Enum.Font.GothamBold
    TituloHub.TextXAlignment = Enum.TextXAlignment.Left
    TituloHub.ZIndex = 4
    TituloHub.Parent = Header

    local Linha = Instance.new("Frame")
    Linha.Size = UDim2.new(1, -40, 0, 1)
    Linha.Position = UDim2.new(0, 20, 0, 52)
    Linha.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    Linha.BackgroundTransparency = 0.6
    Linha.BorderSizePixel = 0
    Linha.ZIndex = 3
    Linha.Parent = Painel

    local MsgPrincipal = Instance.new("TextLabel")
    MsgPrincipal.Size = UDim2.new(1, -40, 0, 36)
    MsgPrincipal.Position = UDim2.new(0, 20, 0, 68)
    MsgPrincipal.BackgroundTransparency = 1
    MsgPrincipal.Text = "Não Foi Possível Executar o Lotux Hub"
    MsgPrincipal.TextColor3 = Color3.fromRGB(240, 240, 245)
    MsgPrincipal.TextSize = 17
    MsgPrincipal.Font = Enum.Font.GothamBold
    MsgPrincipal.TextWrapped = true
    MsgPrincipal.TextXAlignment = Enum.TextXAlignment.Center
    MsgPrincipal.ZIndex = 3
    MsgPrincipal.Parent = Painel

    local LabelMotivo = Instance.new("TextLabel")
    LabelMotivo.Size = UDim2.new(1, -40, 0, 20)
    LabelMotivo.Position = UDim2.new(0, 20, 0, 112)
    LabelMotivo.BackgroundTransparency = 1
    LabelMotivo.Text = "Motivo:"
    LabelMotivo.TextColor3 = Color3.fromRGB(150, 150, 165)
    LabelMotivo.TextSize = 13
    LabelMotivo.Font = Enum.Font.Gotham
    LabelMotivo.TextXAlignment = Enum.TextXAlignment.Center
    LabelMotivo.ZIndex = 3
    LabelMotivo.Parent = Painel

    local CaixaMotivo = Instance.new("Frame")
    CaixaMotivo.Size = UDim2.new(1, -60, 0, 36)
    CaixaMotivo.Position = UDim2.new(0, 30, 0, 136)
    CaixaMotivo.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    CaixaMotivo.BorderSizePixel = 0
    CaixaMotivo.ZIndex = 3
    CaixaMotivo.Parent = Painel
    Instance.new("UICorner", CaixaMotivo).CornerRadius = UDim.new(0, 8)

    local CaixaStroke = Instance.new("UIStroke")
    CaixaStroke.Color = Color3.fromRGB(180, 30, 30)
    CaixaStroke.Thickness = 1
    CaixaStroke.Transparency = 0.5
    CaixaStroke.Parent = CaixaMotivo

    local TextoMotivo = Instance.new("TextLabel")
    TextoMotivo.Size = UDim2.new(1, 0, 1, 0)
    TextoMotivo.BackgroundTransparency = 1
    TextoMotivo.Text = "⚙  Em Desenvolvimento"
    TextoMotivo.TextColor3 = Color3.fromRGB(220, 80, 80)
    TextoMotivo.TextSize = 14
    TextoMotivo.Font = Enum.Font.GothamSemibold
    TextoMotivo.ZIndex = 4
    TextoMotivo.Parent = CaixaMotivo

    local BotoesFrame = Instance.new("Frame")
    BotoesFrame.Size = UDim2.new(1, -40, 0, 42)
    BotoesFrame.Position = UDim2.new(0, 20, 0, 196)
    BotoesFrame.BackgroundTransparency = 1
    BotoesFrame.ZIndex = 3
    BotoesFrame.Parent = Painel

    local BotoesLayout = Instance.new("UIListLayout")
    BotoesLayout.FillDirection = Enum.FillDirection.Horizontal
    BotoesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    BotoesLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    BotoesLayout.Padding = UDim.new(0, 12)
    BotoesLayout.Parent = BotoesFrame

    local function criarBotao(texto, cor)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 170, 0, 38)
        btn.BackgroundColor3 = cor
        btn.Text = texto
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamSemibold
        btn.BorderSizePixel = 0
        btn.ZIndex = 4
        btn.Parent = BotoesFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        local corHover = Color3.new(math.min(cor.R*1.3,1), math.min(cor.G*1.3,1), math.min(cor.B*1.3,1))
        btn.MouseEnter:Connect(function() btn.BackgroundColor3 = corHover end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = cor end)
        return btn
    end

    local BotaoFechar  = criarBotao("✕  Fechar Script",  Color3.fromRGB(160, 25, 25))
    local BotaoDiscord = criarBotao("🔗  Link do Discord", Color3.fromRGB(30, 80, 180))

    BotaoFechar.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    BotaoDiscord.MouseButton1Click:Connect(function()
        pcall(function() setclipboard("https://discord.gg/HkB97N772p") end)
        BotaoDiscord.Text = "✔ Link copiado!"
        task.delay(2, function()
            if BotaoDiscord and BotaoDiscord.Parent then
                BotaoDiscord.Text = "🔗  Link do Discord"
            end
        end)
    end)

    TweenService:Create(Painel,
        TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Position = UDim2.new(0.5, -210, 0.5, -130), BackgroundTransparency = 0 }
    ):Play()
end

-- =====================================================
-- PAINEL DE ERRO COM ARQUIVO + LINHA + MENSAGEM
-- =====================================================
local function criarPainelErro(arquivo, linha, mensagem)
    if PlayerGui:FindFirstChild("LotuxHubErro") then
        PlayerGui.LotuxHubErro:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LotuxHubErro"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Overlay.BackgroundTransparency = 0.5
    Overlay.BorderSizePixel = 0
    Overlay.ZIndex = 1
    Overlay.Parent = ScreenGui

    local Painel = Instance.new("Frame")
    Painel.Name = "Painel"
    Painel.Size = UDim2.new(0, 480, 0, 320)
    Painel.Position = UDim2.new(0.5, -240, 0.6, -160)
    Painel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Painel.BackgroundTransparency = 1
    Painel.BorderSizePixel = 0
    Painel.ZIndex = 2
    Painel.Parent = ScreenGui
    Instance.new("UICorner", Painel).CornerRadius = UDim.new(0, 12)

    local PainelStroke = Instance.new("UIStroke")
    PainelStroke.Color = Color3.fromRGB(180, 30, 30)
    PainelStroke.Thickness = 1.5
    PainelStroke.Transparency = 0.2
    PainelStroke.Parent = Painel

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 52)
    Header.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    Header.BorderSizePixel = 0
    Header.ZIndex = 3
    Header.Parent = Painel
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

    local HeaderFix = Instance.new("Frame")
    HeaderFix.Size = UDim2.new(1, 0, 0, 12)
    HeaderFix.Position = UDim2.new(0, 0, 1, -12)
    HeaderFix.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    HeaderFix.BorderSizePixel = 0
    HeaderFix.ZIndex = 3
    HeaderFix.Parent = Header

    local Icone = Instance.new("ImageLabel")
    Icone.Size = UDim2.new(0, 30, 0, 30)
    Icone.Position = UDim2.new(0, 14, 0.5, -15)
    Icone.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    Icone.Image = "rbxassetid://111672166073808"
    Icone.ScaleType = Enum.ScaleType.Fit
    Icone.ZIndex = 4
    Icone.Parent = Header
    Instance.new("UICorner", Icone).CornerRadius = UDim.new(0, 6)

    local TituloHub = Instance.new("TextLabel")
    TituloHub.Size = UDim2.new(1, -60, 1, 0)
    TituloHub.Position = UDim2.new(0, 54, 0, 0)
    TituloHub.BackgroundTransparency = 1
    TituloHub.Text = "Lotux Hub  —  Erro ao Carregar"
    TituloHub.TextColor3 = Color3.fromRGB(210, 210, 220)
    TituloHub.TextSize = 14
    TituloHub.Font = Enum.Font.GothamBold
    TituloHub.TextXAlignment = Enum.TextXAlignment.Left
    TituloHub.ZIndex = 4
    TituloHub.Parent = Header

    local Linha = Instance.new("Frame")
    Linha.Size = UDim2.new(1, -40, 0, 1)
    Linha.Position = UDim2.new(0, 20, 0, 52)
    Linha.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    Linha.BackgroundTransparency = 0.6
    Linha.BorderSizePixel = 0
    Linha.ZIndex = 3
    Linha.Parent = Painel

    local ArquivoLabel = Instance.new("TextLabel")
    ArquivoLabel.Size = UDim2.new(1, -40, 0, 22)
    ArquivoLabel.Position = UDim2.new(0, 20, 0, 62)
    ArquivoLabel.BackgroundTransparency = 1
    ArquivoLabel.Text = "📄  Arquivo:  " .. tostring(arquivo)
    ArquivoLabel.TextColor3 = Color3.fromRGB(255, 180, 60)
    ArquivoLabel.TextSize = 13
    ArquivoLabel.Font = Enum.Font.GothamSemibold
    ArquivoLabel.TextXAlignment = Enum.TextXAlignment.Left
    ArquivoLabel.ZIndex = 3
    ArquivoLabel.Parent = Painel

    local LinhaLabel = Instance.new("TextLabel")
    LinhaLabel.Size = UDim2.new(1, -40, 0, 22)
    LinhaLabel.Position = UDim2.new(0, 20, 0, 86)
    LinhaLabel.BackgroundTransparency = 1
    LinhaLabel.Text = "📍  Linha:    " .. tostring(linha)
    LinhaLabel.TextColor3 = Color3.fromRGB(255, 140, 140)
    LinhaLabel.TextSize = 13
    LinhaLabel.Font = Enum.Font.GothamSemibold
    LinhaLabel.TextXAlignment = Enum.TextXAlignment.Left
    LinhaLabel.ZIndex = 3
    LinhaLabel.Parent = Painel

    local Linha2 = Instance.new("Frame")
    Linha2.Size = UDim2.new(1, -40, 0, 1)
    Linha2.Position = UDim2.new(0, 20, 0, 114)
    Linha2.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    Linha2.BackgroundTransparency = 0.5
    Linha2.BorderSizePixel = 0
    Linha2.ZIndex = 3
    Linha2.Parent = Painel

    local CaixaMotivo = Instance.new("Frame")
    CaixaMotivo.Size = UDim2.new(1, -40, 0, 90)
    CaixaMotivo.Position = UDim2.new(0, 20, 0, 122)
    CaixaMotivo.BackgroundColor3 = Color3.fromRGB(20, 15, 25)
    CaixaMotivo.BorderSizePixel = 0
    CaixaMotivo.ZIndex = 3
    CaixaMotivo.Parent = Painel
    Instance.new("UICorner", CaixaMotivo).CornerRadius = UDim.new(0, 8)

    local CaixaStroke2 = Instance.new("UIStroke")
    CaixaStroke2.Color = Color3.fromRGB(180, 30, 30)
    CaixaStroke2.Thickness = 1
    CaixaStroke2.Transparency = 0.5
    CaixaStroke2.Parent = CaixaMotivo

    local TextoMotivo = Instance.new("TextLabel")
    TextoMotivo.Size = UDim2.new(1, -16, 1, -12)
    TextoMotivo.Position = UDim2.new(0, 8, 0, 6)
    TextoMotivo.BackgroundTransparency = 1
    TextoMotivo.Text = tostring(mensagem)
    TextoMotivo.TextColor3 = Color3.fromRGB(220, 100, 100)
    TextoMotivo.TextSize = 11
    TextoMotivo.Font = Enum.Font.Code
    TextoMotivo.TextWrapped = true
    TextoMotivo.TextXAlignment = Enum.TextXAlignment.Left
    TextoMotivo.TextYAlignment = Enum.TextYAlignment.Top
    TextoMotivo.ZIndex = 4
    TextoMotivo.Parent = CaixaMotivo

    local BotoesFrame = Instance.new("Frame")
    BotoesFrame.Size = UDim2.new(1, -40, 0, 44)
    BotoesFrame.Position = UDim2.new(0, 20, 0, 224)
    BotoesFrame.BackgroundTransparency = 1
    BotoesFrame.ZIndex = 3
    BotoesFrame.Parent = Painel

    local BotoesLayout = Instance.new("UIListLayout")
    BotoesLayout.FillDirection = Enum.FillDirection.Horizontal
    BotoesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    BotoesLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    BotoesLayout.Padding = UDim.new(0, 12)
    BotoesLayout.Parent = BotoesFrame

    local function criarBotao(texto, cor)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 185, 0, 38)
        btn.BackgroundColor3 = cor
        btn.Text = texto
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamSemibold
        btn.BorderSizePixel = 0
        btn.ZIndex = 4
        btn.Parent = BotoesFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        local corHover = Color3.new(math.min(cor.R*1.3,1), math.min(cor.G*1.3,1), math.min(cor.B*1.3,1))
        btn.MouseEnter:Connect(function() btn.BackgroundColor3 = corHover end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = cor end)
        return btn
    end

    local BotaoFechar  = criarBotao("✕  Fechar",   Color3.fromRGB(150, 25, 25))
    local BotaoDiscord = criarBotao("🔗  Discord",  Color3.fromRGB(30, 80, 180))

    local BotaoCopiar = Instance.new("TextButton")
    BotaoCopiar.Size = UDim2.new(1, -40, 0, 28)
    BotaoCopiar.Position = UDim2.new(0, 20, 0, 278)
    BotaoCopiar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    BotaoCopiar.Text = "📋  Copiar erro completo"
    BotaoCopiar.TextColor3 = Color3.fromRGB(160, 160, 200)
    BotaoCopiar.TextSize = 12
    BotaoCopiar.Font = Enum.Font.Gotham
    BotaoCopiar.BorderSizePixel = 0
    BotaoCopiar.ZIndex = 4
    BotaoCopiar.Parent = Painel
    Instance.new("UICorner", BotaoCopiar).CornerRadius = UDim.new(0, 6)

    BotaoFechar.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    BotaoDiscord.MouseButton1Click:Connect(function()
        pcall(function() setclipboard("https://discord.gg/HkB97N772p") end)
        BotaoDiscord.Text = "✔ Link copiado!"
        task.delay(2, function()
            if BotaoDiscord and BotaoDiscord.Parent then BotaoDiscord.Text = "🔗  Discord" end
        end)
    end)

    BotaoCopiar.MouseButton1Click:Connect(function()
        local erroCompleto = string.format(
            "[LotuxHub] ERRO\nArquivo: %s\nLinha: %s\nMensagem: %s",
            tostring(arquivo), tostring(linha), tostring(mensagem)
        )
        pcall(function() setclipboard(erroCompleto) end)
        BotaoCopiar.Text = "✔ Copiado!"
        BotaoCopiar.TextColor3 = Color3.fromRGB(80, 200, 120)
        task.delay(2, function()
            if BotaoCopiar and BotaoCopiar.Parent then
                BotaoCopiar.Text = "📋  Copiar erro completo"
                BotaoCopiar.TextColor3 = Color3.fromRGB(160, 160, 200)
            end
        end)
    end)

    TweenService:Create(Painel,
        TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Position = UDim2.new(0.5, -240, 0.5, -160), BackgroundTransparency = 0 }
    ):Play()
end

-- =====================================================
-- PARSER DE ERRO
-- =====================================================
local function parseErro(nomeModulo, errMsg)
    errMsg = tostring(errMsg)
    local linha, msg = errMsg:match(":(%d+):%s*(.+)$")
    if linha then
        return nomeModulo .. ".lua", linha, msg:sub(1, 300)
    end
    linha = errMsg:match("[Ll]ine%s+(%d+)") or "?"
    return nomeModulo .. ".lua", linha, errMsg:sub(1, 300)
end

-- =====================================================
-- CARREGAMENTO SEGURO COM DETECÇÃO DE ERRO
-- =====================================================
local function safeLoad(modulo)
    local nome = modulo.name
    local url  = modulo.url

    print("[LotuxHub] Carregando: " .. nome .. "...")

    local okHttp, code = pcall(function()
        return game:HttpGet(url, true)
    end)
    if not okHttp or not code or #code < 10 then
        local msg = okHttp and "Resposta vazia/inválida" or tostring(code)
        criarPainelErro(nome .. ".lua", "HttpGet", "Falha ao baixar: " .. msg)
        error("[LotuxHub] Download falhou: " .. nome)
    end

    local fn, compErr = loadstring(code, "@" .. nome .. ".lua")
    if not fn then
        local arquivo, linha, msg = parseErro(nome, compErr)
        warn("[LotuxHub] Erro de compilação em " .. arquivo .. " linha " .. linha)
        criarPainelErro(arquivo, linha, msg)
        error("[LotuxHub] Compilação falhou: " .. nome)
    end

    local okRun, result = pcall(fn)
    if not okRun then
        local arquivo, linha, msg = parseErro(nome, result)
        warn("[LotuxHub] Erro de execução em " .. arquivo .. " linha " .. linha)
        criarPainelErro(arquivo, linha, msg)
        error("[LotuxHub] Execução falhou: " .. nome)
    end

    print("[LotuxHub] ✓ " .. nome .. " carregado!")
    return result
end

-- =====================================================
-- EXECUÇÃO PRINCIPAL
-- =====================================================
if not SCRIPT_URL or SCRIPT_URL == "" then
    -- URL vazia = script em desenvolvimento
    criarPainelDesenvolvimento()
else
    -- URL preenchida = carrega normalmente com detecção de erro
    print("[LotuxHub] Iniciando Lotux Hub...")
    local ok, err = pcall(function()
        loadstring(game:HttpGet(SCRIPT_URL, true))()
    end)
    if not ok then
        local arquivo, linha, msg = parseErro("UI", tostring(err))
        criarPainelErro(arquivo, linha, msg)
        warn("[LotuxHub] Erro fatal: " .. tostring(err))
    end
end