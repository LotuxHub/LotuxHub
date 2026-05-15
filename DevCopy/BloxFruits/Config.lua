-- Config.lua
-- Configuracoes do Lotux Hub by LoadFlint/lucas

local Config = {

    -- =====================================================
    -- FARM
    -- =====================================================
    FarmWeapon          = "Melee",   -- "Melee" | "Sword" | "Gun" | "BloxFruits"
    SelectedWeaponName  = "",        -- resolvido automaticamente pelo WeaponResolver
    FarmAttack          = "Normal",  -- "Normal" | "FastAttack" | "SuperFastAttack"
    AutoFarmLevel       = false,
    AutoFarmNearest     = false,
    FarmIsland          = "",
    FlySpeed            = 300,
    FlyOffset           = 15,
    BringMob            = true,
    BringDistance       = 350,

    -- =====================================================
    -- SEA 3
    -- =====================================================
    AutoPirateRaid      = false,
    AutoRipIndra        = false,
    AutoTyrantSpawn     = false,
    AutoSoulReaper      = false,
    AutoBigMom          = false,
    AutoFarmBone        = false,
    AutoHakiV2          = false,
    AutoUnlockTemple    = false,
    AutoGodHuman        = false,
    AutoDragonTaylor    = false,
    AutoElectricClaw    = false,
    AutoCakePrince      = false,
    AutoDoughKing       = false,

    -- Espadas Lendarias (Sea 3)
    AutoGetTushita      = false,    -- Farm Longma para pegar Tushita
    AutoHolyTorch       = false,    -- Acender tochas para quest Tushita
    AutoYama            = false,    -- Pegar espada Yama (requer 30 EliteHunter kills)
    AutoRengoku         = false,    -- Pegar espada Rengoku (Awakened Ice Admiral)
    AutoEliteHunter     = false,    -- Farm Elite Hunters (Diablo/Deandre/Urban)
    AutoEliteHunterHop  = false,    -- Hop se nao tiver Elite Hunter disponivel

    -- Sea 3 Eventos / Ilhas
    AutoMysticIsland    = false,    -- Tween para Mirage Island quando spawnar
    TweenToKitsune      = false,    -- Tween para Kitsune Island (shrine ativo)
    AutoAzuerEmber      = false,    -- Teleportar para Azure Ember quando aparecer
    AutoBlazeEmber      = false,    -- Teleportar para Blaze Ember quando aparecer
    AutoHydraTree       = false,    -- Farm arvore da Hydra Island
    AutoMobDragon       = false,    -- Farm mob Dragon na Floating Turtle
    DefendVolcano       = false,    -- Defender o vulcao (Prehistoric Island)
    TweenVolcano        = false,    -- Tween para o vulcao
    AutoFindPrehistoric = false,    -- Procurar/encontrar Prehistoric Island
    AutoCollectBone     = false,    -- Coletar ossos (DinoBone) no mapa
    CollectEgg          = false,    -- Coletar ovo de dragao via remote

    -- Sea 3 Bosses / NPCs
    AutoBartilo         = false,    -- Quest do Bartilo para desbloquear acesso ao Sea 3
    ChiefWarden         = false,    -- Farm Chief Warden
    CursedCaptain       = false,    -- Farm Cursed Captain

    -- Barco / Navegacao
    SailBoat            = false,    -- Auto navegar barco (PirateBrigade) para Sea 3
    AutoTerrorshark     = false,    -- Farm Terrorshark / criaturas do mar
    WalkWater           = false,    -- Aumentar base de agua para andar

    -- =====================================================
    -- SEA 2
    -- =====================================================
    AutoSea3            = false,
    AutoFactory         = false,
    AutoRaidLaw         = false,
    AutoBuyChipRaidLaw  = false,
    AutoStartRaidLaw    = false,
    AutoDarkBeard       = false,
    AutoSharkmanV2      = false,
    AutoDeathStep       = false,
    AutoBuyEnhancementColour = false, -- Comprar cores de Haki automaticamente
    AutoBuyLegendarySword    = false, -- Comprar espada lendaria automaticamente

    -- =====================================================
    -- SEA 1
    -- =====================================================
    AutoSea2            = false,
    AutoSaber           = false,
    AutoGrayBeard       = false,
    AutoDarkBladeV2     = false,

    -- =====================================================
    -- RACE / EVOLUCAO
    -- =====================================================
    AutoRaceV3          = false,    -- Ativar habilidade de raca V3 automaticamente
    AutoRaceV4          = false,    -- Pressionar Y para ativar raca V4
    AutoQuestRace       = false,    -- Completar quest de evolucao de raca automaticamente
    AutoDooHee          = false,    -- Olhar para a lua + pressionar T (V3 Moon unlock)

    -- =====================================================
    -- FRUTAS
    -- =====================================================
    AutoStoreFruit      = false,    -- Guardar frutas no storage automaticamente
    TweenFruit          = false,    -- Tween para frutas que spawnam no mapa
    GrabFruit           = false,    -- Teleportar personagem ate frutas no mapa
    AutoFruit           = false,    -- Carregar frutas baratas via LoadFruit remote

    -- =====================================================
    -- EXTRAS
    -- =====================================================
    AutoCollectBerry    = false,
    AutoCollectBerryHop = false,
    AutoBarista         = false,    -- Pegar cores de Haki com o NPC Barista
    HakiColor           = "White",
    AutoFarmObsHaki     = false,
    FarmChest           = false,    -- Coletar baus no mapa
    FarmChocola         = false,    -- Farm Chocolate Island (mobs)
    AutoSkill           = false,    -- Usar skills automaticamente (Z/X/C)
    AutoDungeon         = false,    -- Auto dungeon (atacar inimigos e avancar ilhas)
    TweenMGear          = false,    -- Tween para partes Neon da Mystic Island (M-Gear)

    -- =====================================================
    -- PVP / PLAYER HUNTER
    -- =====================================================
    EnabledPvP          = false,    -- Ativar modo PvP
    KillAura            = false,    -- Matar todos os inimigos no raio de 1000
    AimbotGun           = false,    -- Aimbot com arma de fogo
    AimbotSkill         = false,    -- Aimbot com skills
    AutoKillPlayer      = false,    -- Matar players selecionados automaticamente
    AutoPlayerHunter    = false,    -- Cacar players (teleportar para o alvo)
    SelectedPlayer      = "",       -- Nome do player alvo para hunter/kill

    -- =====================================================
    -- BOSS
    -- =====================================================
    SelectedBoss        = "None",
    AutoFarmBoss        = false,
    AutoFarmAllBoss     = false,
    AutoFarmRaidBoss    = false,

    -- =====================================================
    -- MATERIAL
    -- =====================================================
    SelectedMaterial    = "",
    AutoFarmMaterial    = false,

    -- =====================================================
    -- MASTERY
    -- =====================================================
    MasteryWeapon       = "Gun",
    HealthKillMob       = 30,
    MasteryIsland       = "",
    AutoFarmMastery     = false,

    -- =====================================================
    -- PLAYER
    -- =====================================================
    AutoClick           = true,
    AutoSetSpawn        = false,
    AutoBusoHaki        = true,
    AutoObservation     = false,
    AutoSpeed           = true,
    Speed               = 20,
    AutoSetJump         = true,
    Jump                = 50,
    WalkSpeed           = 16,
    JumpPower           = 50,
    InfiniteJump        = false,
    AntiAFK             = false,
    SafeMode            = false,    -- sobe se HP ficar baixo

    -- =====================================================
    -- VISUAL / EFEITOS
    -- =====================================================
    DisableGameNotify   = false,
    NoFog               = true,
    NotifyErroScript    = false,
    NoClip              = false,
    ESPEnabled          = false,
    ESPTeammates        = false,
    ESPIslands          = false,
    ESPFruits           = false,
    ESPChests           = false,
    ESPBerries          = false,
    ESPMirage           = false,
    ESPSeaBeasts        = false,
    ESPNpcs             = false,
    AquaAura            = false,    -- aura aqua ao flutuar
    RainbowSkills       = false,    -- skills com cor arco-iris
    FPSCounter          = false,    -- contador de FPS na tela
    RainbowBillboard    = false,    -- label rainbow no personagem
    SelfHighlight       = false,    -- highlight branco no proprio personagem
    RenderOnFocus       = true,     -- para render 3D quando janela perde foco

    -- =====================================================
    -- UI
    -- =====================================================
    UIScale             = 450,      -- redzlib:SetScale (450 = padrao)

    -- =====================================================
    -- ESTADO INTERNO
    -- =====================================================
    ScriptStartTime     = os.time(),
    KillCount           = 0,
    StartBring          = false,
    MonFarm             = "",
}

return Config