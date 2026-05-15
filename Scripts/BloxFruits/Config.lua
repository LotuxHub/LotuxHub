-- Config.lua
-- Configuracoes padrao do Redux Hub
local Config = {
    -- Farm
    FarmWeapon         = "Melee",   -- "Melee" | "Sword" | "Gun" | "Blox Fruit"
    SelectedWeaponName = "",        -- nome real resolvido pelo loop de arma (igual ao Tiroreal)
    FarmAttack         = "Normal",
    AutoFarmLevel      = false,
    AutoFarmNearest    = false,
    FarmIsland         = "",
    FlySpeed           = 300,
    BringMob           = true,
    BringDistance      = 350,
    FlyOffset          = 15,

    -- Sea 3
    AutoPirateRaid     = false,
    AutoRipIndra       = false,
    AutoTyrantSpawn    = false,
    AutoSoulReaper     = false,
    AutoBigMom         = false,
    AutoFarmBone       = false,
    AutoHakiV2         = false,
    AutoUnlockTemple   = false,
    AutoGodHuman       = false,
    AutoDragonTaylor   = false,
    AutoElectricClaw   = false,
    AutoCakePrince     = false,
    AutoDoughKing      = false,

    -- Sea 2
    AutoSea3           = false,
    AutoFactory        = false,
    AutoRaidLaw        = false,
    AutoBuyChipRaidLaw = false,
    AutoStartRaidLaw   = false,
    AutoDarkBeard      = false,
    AutoSharkmanV2     = false,
    AutoDeathStep      = false,

    -- Sea 1
    AutoSea2           = false,
    AutoSaber          = false,
    AutoGrayBeard      = false,
    AutoDarkBladeV2    = false,

    -- Extras
    AutoCollectBerry   = false,
    AutoBarista        = false,
    HakiColor          = "White",
    AutoFarmObsHaki    = false,

    -- Boss
    SelectedBoss       = "None",
    AutoFarmBoss       = false,
    AutoFarmAllBoss    = false,
    AutoFarmRaidBoss   = false,

    -- Material
    SelectedMaterial   = "",
    AutoFarmMaterial   = false,

    -- Mastery
    MasteryWeapon      = "Gun",
    HealthKillMob      = 30,
    MasteryIsland      = "",
    AutoFarmMastery    = false,

    -- Player
    AutoClick          = true,
    AutoSetSpawn       = false,
    AutoBusoHaki       = true,
    AutoObservation    = false,
    AutoSpeed          = true,
    Speed              = 20,
    AutoSetJump        = true,
    Jump               = 50,
    WalkSpeed          = 16,
    JumpPower          = 50,
    InfiniteJump       = false,
    AntiAFK            = false,

    -- Visual
    DisableGameNotify  = false,
    NoFog              = true,
    NotifyErroScript   = false,
    NoClip             = false,
    ESPEnabled         = false,
    ESPTeammates       = false,
    UIScale            = 450,   -- valor para redzlib:SetScale (450 = tamanho padrao)

    -- Estado interno
    ScriptStartTime    = os.time(),
    KillCount          = 0,
}

return Config