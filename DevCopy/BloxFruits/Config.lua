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

    -- =====================================================
    -- SEA 1
    -- =====================================================
    AutoSea2            = false,
    AutoSaber           = false,
    AutoGrayBeard       = false,
    AutoDarkBladeV2     = false,

    -- =====================================================
    -- EXTRAS
    -- =====================================================
    AutoCollectBerry    = false,
    AutoCollectBerryHop = false,
    AutoBarista         = false,
    HakiColor           = "White",
    AutoFarmObsHaki     = false,

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