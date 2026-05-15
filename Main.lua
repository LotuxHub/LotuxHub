-- Lotux Hub Loader
-- Verifica se loadstring está disponível antes de executar

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ╔══════════════════════════════════════╗
-- ║        VERIFICAÇÃO DE LOADSTRING     ║
-- ╚══════════════════════════════════════╝

local function loadstringDisponivel()
    return type(loadstring) == "function"
end

-- ╔══════════════════════════════════════╗
-- ║         PAINEL DE ERRO DARK          ║
-- ╚══════════════════════════════════════╝

local function criarPainelErro()

    -- Remove painel anterior se existir
    if PlayerGui:FindFirstChild("LotuxHubErro") then
        PlayerGui.LotuxHubErro:Destroy()
    end

    -- ScreenGui principal
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LotuxHubErro"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    -- Fundo escurecido (overlay)
    local Overlay = Instance.new("Frame")
    Overlay.Name = "Overlay"
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.Position = UDim2.new(0, 0, 0, 0)
    Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Overlay.BackgroundTransparency = 0.5
    Overlay.BorderSizePixel = 0
    Overlay.ZIndex = 1
    Overlay.Parent = ScreenGui

    -- Container principal do painel
    local Painel = Instance.new("Frame")
    Painel.Name = "Painel"
    Painel.Size = UDim2.new(0, 420, 0, 260)
    Painel.Position = UDim2.new(0.5, -210, 0.5, -130)
    Painel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Painel.BorderSizePixel = 0
    Painel.ZIndex = 2
    Painel.Parent = ScreenGui

    -- Borda arredondada no painel
    local PainelCorner = Instance.new("UICorner")
    PainelCorner.CornerRadius = UDim.new(0, 12)
    PainelCorner.Parent = Painel

    -- Borda colorida (stroke)
    local PainelStroke = Instance.new("UIStroke")
    PainelStroke.Color = Color3.fromRGB(180, 30, 30)
    PainelStroke.Thickness = 1.5
    PainelStroke.Transparency = 0.2
    PainelStroke.Parent = Painel

    -- Sombra do painel
    local Sombra = Instance.new("ImageLabel")
    Sombra.Name = "Sombra"
    Sombra.AnchorPoint = Vector2.new(0.5, 0.5)
    Sombra.BackgroundTransparency = 1
    Sombra.Position = UDim2.new(0.5, 0, 0.5, 8)
    Sombra.Size = UDim2.new(1, 30, 1, 30)
    Sombra.ZIndex = 1
    Sombra.Image = "rbxassetid://6014261993"
    Sombra.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Sombra.ImageTransparency = 0.5
    Sombra.ScaleType = Enum.ScaleType.Slice
    Sombra.SliceCenter = Rect.new(49, 49, 450, 450)
    Sombra.Parent = Painel

    -- Barra do topo (header)
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 52)
    Header.Position = UDim2.new(0, 0, 0, 0)
    Header.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    Header.BorderSizePixel = 0
    Header.ZIndex = 3
    Header.Parent = Painel

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 12)
    HeaderCorner.Parent = Header

    -- Cobre os cantos inferiores do header (para parecer reto embaixo)
    local HeaderFix = Instance.new("Frame")
    HeaderFix.Size = UDim2.new(1, 0, 0, 12)
    HeaderFix.Position = UDim2.new(0, 0, 1, -12)
    HeaderFix.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    HeaderFix.BorderSizePixel = 0
    HeaderFix.ZIndex = 3
    HeaderFix.Parent = Header

    -- Ícone de erro (X vermelho) no header
    local IconeErro = Instance.new("TextLabel")
    IconeErro.Name = "IconeErro"
    IconeErro.Size = UDim2.new(0, 30, 0, 30)
    IconeErro.Position = UDim2.new(0, 14, 0.5, -15)
    IconeErro.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    IconeErro.Text = "✕"
    IconeErro.TextColor3 = Color3.fromRGB(255, 255, 255)
    IconeErro.TextSize = 14
    IconeErro.Font = Enum.Font.GothamBold
    IconeErro.ZIndex = 4
    IconeErro.Parent = Header

    local IconeCorner = Instance.new("UICorner")
    IconeCorner.CornerRadius = UDim.new(0, 6)
    IconeCorner.Parent = IconeErro

    -- Título do hub no header
    local TituloHub = Instance.new("TextLabel")
    TituloHub.Name = "TituloHub"
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

    -- Linha separadora abaixo do header
    local Linha = Instance.new("Frame")
    Linha.Name = "Linha"
    Linha.Size = UDim2.new(1, -40, 0, 1)
    Linha.Position = UDim2.new(0, 20, 0, 52)
    Linha.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    Linha.BackgroundTransparency = 0.6
    Linha.BorderSizePixel = 0
    Linha.ZIndex = 3
    Linha.Parent = Painel

    -- Mensagem principal
    local MsgPrincipal = Instance.new("TextLabel")
    MsgPrincipal.Name = "MsgPrincipal"
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

    -- Label "Motivo:"
    local LabelMotivo = Instance.new("TextLabel")
    LabelMotivo.Name = "LabelMotivo"
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

    -- Caixa do motivo
    local CaixaMotivo = Instance.new("Frame")
    CaixaMotivo.Name = "CaixaMotivo"
    CaixaMotivo.Size = UDim2.new(1, -60, 0, 36)
    CaixaMotivo.Position = UDim2.new(0, 30, 0, 136)
    CaixaMotivo.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    CaixaMotivo.BorderSizePixel = 0
    CaixaMotivo.ZIndex = 3
    CaixaMotivo.Parent = Painel

    local CaixaCorner = Instance.new("UICorner")
    CaixaCorner.CornerRadius = UDim.new(0, 8)
    CaixaCorner.Parent = CaixaMotivo

    local CaixaStroke = Instance.new("UIStroke")
    CaixaStroke.Color = Color3.fromRGB(180, 30, 30)
    CaixaStroke.Thickness = 1
    CaixaStroke.Transparency = 0.5
    CaixaStroke.Parent = CaixaMotivo

    -- Texto do motivo
    local TextoMotivo = Instance.new("TextLabel")
    TextoMotivo.Name = "TextoMotivo"
    TextoMotivo.Size = UDim2.new(1, 0, 1, 0)
    TextoMotivo.Position = UDim2.new(0, 0, 0, 0)
    TextoMotivo.BackgroundTransparency = 1
    TextoMotivo.Text = "⚙  Em Desenvolvimento"
    TextoMotivo.TextColor3 = Color3.fromRGB(220, 80, 80)
    TextoMotivo.TextSize = 14
    TextoMotivo.Font = Enum.Font.GothamSemibold
    TextoMotivo.ZIndex = 4
    TextoMotivo.Parent = CaixaMotivo

    -- Container dos botões
    local BotoesFrame = Instance.new("Frame")
    BotoesFrame.Name = "BotoesFrame"
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

    -- Botão: Fechar Script
    local BotaoFechar = Instance.new("TextButton")
    BotaoFechar.Name = "BotaoFechar"
    BotaoFechar.Size = UDim2.new(0, 170, 0, 38)
    BotaoFechar.BackgroundColor3 = Color3.fromRGB(160, 25, 25)
    BotaoFechar.Text = "✕  Fechar Script"
    BotaoFechar.TextColor3 = Color3.fromRGB(255, 255, 255)
    BotaoFechar.TextSize = 13
    BotaoFechar.Font = Enum.Font.GothamSemibold
    BotaoFechar.BorderSizePixel = 0
    BotaoFechar.ZIndex = 4
    BotaoFechar.Parent = BotoesFrame

    local FecharCorner = Instance.new("UICorner")
    FecharCorner.CornerRadius = UDim.new(0, 8)
    FecharCorner.Parent = BotaoFechar

    -- Botão: Link do Discord
    local BotaoDiscord = Instance.new("TextButton")
    BotaoDiscord.Name = "BotaoDiscord"
    BotaoDiscord.Size = UDim2.new(0, 170, 0, 38)
    BotaoDiscord.BackgroundColor3 = Color3.fromRGB(30, 80, 180)
    BotaoDiscord.Text = "🔗  Link do Discord"
    BotaoDiscord.TextColor3 = Color3.fromRGB(255, 255, 255)
    BotaoDiscord.TextSize = 13
    BotaoDiscord.Font = Enum.Font.GothamSemibold
    BotaoDiscord.BorderSizePixel = 0
    BotaoDiscord.ZIndex = 4
    BotaoDiscord.Parent = BotoesFrame

    local DiscordCorner = Instance.new("UICorner")
    DiscordCorner.CornerRadius = UDim.new(0, 8)
    DiscordCorner.Parent = BotaoDiscord

    -- ╔══════════════════════════════════════╗
    -- ║         HOVER / ANIMAÇÕES            ║
    -- ╚══════════════════════════════════════╝

    -- Hover botão Fechar
    BotaoFechar.MouseEnter:Connect(function()
        BotaoFechar.BackgroundColor3 = Color3.fromRGB(200, 35, 35)
    end)
    BotaoFechar.MouseLeave:Connect(function()
        BotaoFechar.BackgroundColor3 = Color3.fromRGB(160, 25, 25)
    end)

    -- Hover botão Discord
    BotaoDiscord.MouseEnter:Connect(function()
        BotaoDiscord.BackgroundColor3 = Color3.fromRGB(50, 100, 220)
    end)
    BotaoDiscord.MouseLeave:Connect(function()
        BotaoDiscord.BackgroundColor3 = Color3.fromRGB(30, 80, 180)
    end)

    -- ╔══════════════════════════════════════╗
    -- ║            AÇÕES DOS BOTÕES          ║
    -- ╚══════════════════════════════════════╝

    -- Fechar: destrói o painel e encerra
    BotaoFechar.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Discord: copia o link e mostra notificação
    BotaoDiscord.MouseButton1Click:Connect(function()
        setclipboard("https://discord.gg/cnNMHq8WGZ")

        -- Notificação de copiado
        local Notif = Instance.new("TextLabel")
        Notif.Size = UDim2.new(1, -40, 0, 24)
        Notif.Position = UDim2.new(0, 20, 1, -30)
        Notif.BackgroundTransparency = 1
        Notif.Text = "✔ Link copiado para a área de transferência!"
        Notif.TextColor3 = Color3.fromRGB(80, 200, 120)
        Notif.TextSize = 12
        Notif.Font = Enum.Font.Gotham
        Notif.ZIndex = 5
        Notif.Parent = Painel

        task.delay(2.5, function()
            if Notif and Notif.Parent then
                Notif:Destroy()
            end
        end)
    end)

    -- Animação de entrada do painel
    Painel.Position = UDim2.new(0.5, -210, 0.5, -150)
    Painel.BackgroundTransparency = 1

    local TweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    local tween = TweenService:Create(Painel, tweenInfo, {
        Position = UDim2.new(0.5, -210, 0.5, -130),
        BackgroundTransparency = 0
    })
    tween:Play()
end

-- ╔══════════════════════════════════════╗
-- ║              EXECUÇÃO                ║
-- ╚══════════════════════════════════════╝

if not loadstringDisponivel() then
    -- loadstring não encontrado: exibe painel de erro
    warn("[LotuxHub] loadstring não detectado. Exibindo painel de erro.")
    criarPainelErro()
else
    -- loadstring disponível: carrega o script principal normalmente
    print("[LotuxHub] loadstring detectado. Carregando main.lua...")

    -- ═══════════════════════════════════════════════════
    -- ⬇️  COLE O SEU LOADSTRING AQUI ABAIXO:
    -- ═══════════════════════════════════════════════════
end