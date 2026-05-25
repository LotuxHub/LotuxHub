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
    AutoKillShark       = false,    -- Matar Shark (mar)
    AutoKillPiranha     = false,    -- Matar Piranha (mar)
    AutoKillFishCrew    = false,    -- Matar Fish Crew Member (mar)

    -- Volcanic / Prehistoric Extras
    AutoKillGolem       = false,    -- Farm Lava Golem (Prehistoric Island)

    -- =====================================================
    -- SEA 2
    -- =====================================================
    AutoSea3            = false,
    AutoFactory         = false,
    AutoRaid         = false,
    AutoBuyChipRaid  = false,
    AutoStartRaid   = false,
    AutoDarkBeard       = false,
    AutoSharkmanV2      = false,
    AutoDeathStep       = false,
    AutoBuyEnhancementColour = false, -- Comprar cores de Haki automaticamente
    AutoBuyLegendarySword    = false, -- Auto Buy Sword Legends (slots 1/2/3 do dealer)
    AutoGetPole         = false,      -- Pegar espada Thunder Pole (Thunder God)
    AutoGetSaw          = false,      -- Pegar espada The Saw

    -- =====================================================
    -- SEA 1
    -- =====================================================
    AutoSea2            = false,
    AutoBuyTTK          = false,    -- Auto Buy True Triple Katana (farm Saber Expert)
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
    TweenFlyFruit       = false,    -- TweenFly ate frutas que spawnam no mapa
    GrabFruit           = false,    -- Teleportar personagem ate frutas no mapa (TP direto)
    AutoFruit           = false,    -- Carregar frutas baratas via LoadFruit remote
    AutoFarmFruits      = false,    -- Farm mobs usando frutas (mastery)
    SelectFruitFarm     = "Farm Level Mastery", -- Opcao de farm de frutas
    SelectChipRaid      + "Flame"

    -- =====================================================
    -- EXTRAS
    -- =====================================================
    AutoCollectBerry    = false,
    AutoCollectBerryHop = false,
    AutoBarista         = false,    -- Pegar cores de Haki com o NPC Barista
    HakiColor           = "White",
    AutoFarmObsHaki     = false,
    FarmChest           = false,    -- TweenFly ate baus no mapa automaticamente
    FarmChocola         = false,    -- Farm Chocolate Island (mobs)
    AutoSkill           = false,    -- Usar skills automaticamente (Z/X/C integrado no farm)
    AutoSkillZ          = false,    -- Usar skill Z automaticamente no farm/mastery
    AutoSkillX          = false,    -- Usar skill X automaticamente no farm/mastery
    AutoSkillC          = false,    -- Usar skill C automaticamente no farm/mastery
    AutoDungeon         = false,    -- Auto dungeon (atacar inimigos e avancar ilhas)
    TweenMGear          = false,    -- Tween para partes Neon da Mystic Island (M-Gear)
    AutoTryLuck         = false,    -- Auto Try Luck (frutas/item aleatorio)
    AutoTradeBone       = false,    -- Auto trocar ossos (DinoBone Trade)
    AutoPray            = false,    -- Auto Pray (Altar/Shrine)

    -- =====================================================
    -- PVP / PLAYER HUNTER
    -- =====================================================
    EnabledPvP          = false,    -- Ativar modo PvP
    KillAura            = false,    -- Kill Aura (matar todos no raio)
    KillAuraRadius      = 1000,     -- Raio do Kill Aura em studs
    AimbotGun           = false,    -- Aimbot com arma de fogo
    AimbotSkill         = false,    -- Aimbot com skills
    AutoKillPlayer      = false,    -- Matar players selecionados automaticamente
    AutoPlayerHunter    = false,    -- Cacar players (teleportar para o alvo)
    SelectedPlayer      = "",       -- Nome do player alvo para hunter/kill
    FastAttack          = false,    -- Modo de ataque rapido
    FastAttackDelay     = 0.1,      -- Delay do fast attack

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
    -- LANGUAGE (salvo automaticamente via writefile)
    -- =====================================================
    Language            = "English", -- idioma atual (salvo entre sessoes)

    -- =====================================================
    -- ESTADO INTERNO
    -- =====================================================
    ScriptStartTime     = os.time(),
    KillCount           = 0,
    StartBring          = false,
    MonFarm             = "",
}

print("[LotuxHub]Configuration Loaded")
return Config
