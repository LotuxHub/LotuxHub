local HttpService = game:GetService("HttpService")
local Players     = game:GetService("Players")
local Player      = Players.LocalPlayer

local SaveSystem = {}

local ROOT_FOLDER    = "Lotux Hub"
local ACCOUNT_NAME   = Player.Name
local ACCOUNT_FOLDER = ROOT_FOLDER .. "\\" .. ACCOUNT_NAME
local SAVE_FILE    = ACCOUNT_FOLDER .. "\\LotuxHub_Save.json"
local LANG_FILE    = ACCOUNT_FOLDER .. "\\LotuxHub_Language.json"
local DEBUG_FILE   = ACCOUNT_FOLDER .. "\\lotux_debug_painel.json"
local REDZ_FILE    = ROOT_FOLDER    .. "\\redz library V5.json"

local SKIP_KEYS = {
    ScriptStartTime = true,
    KillCount       = true,
    StartBring      = true,
    MonFarm         = true,
}

local function IsSerializable(v)
    local t = type(v)
    return t == "boolean" or t == "number" or t == "string" or t == "table"
end

local function EnsureFolders()
    if not isfolder(ROOT_FOLDER) then
        makefolder(ROOT_FOLDER)
    end
    if not isfolder(ACCOUNT_FOLDER) then
        makefolder(ACCOUNT_FOLDER)
    end
end

function SaveSystem.SaveConfig(Config)
    local ok, err = pcall(function()
        EnsureFolders()

        local toSave = {}
        for k, v in pairs(Config) do
            if not SKIP_KEYS[k] and IsSerializable(v) then
                toSave[k] = v
            end
        end

        writefile(SAVE_FILE, HttpService:JSONEncode(toSave))
    end)
    if not ok then
        warn("[SaveSystem] Erro ao salvar Config: " .. tostring(err))
    end
end

function SaveSystem.LoadConfig(Config)
    if not isfile(SAVE_FILE) then
        print("[SaveSystem] Nenhum save encontrado para: " .. ACCOUNT_NAME)
        return false
    end
    local ok, err = pcall(function()
        local raw     = readfile(SAVE_FILE)
        local decoded = HttpService:JSONDecode(raw)

        for k, v in pairs(decoded) do
            -- Só aplica se a chave existe no Config padrão e não é runtime
            if Config[k] ~= nil and not SKIP_KEYS[k] and IsSerializable(v) then
                Config[k] = v
            end
        end
    end)
    if not ok then
        warn("[SaveSystem] Erro ao carregar Config: " .. tostring(err))
        return false
    end
    print("[SaveSystem] Config carregada para: " .. ACCOUNT_NAME)
    return true
end

function SaveSystem.SaveLanguage(lang)
    pcall(function()
        EnsureFolders()
        writefile(LANG_FILE, HttpService:JSONEncode({ Language = lang }))
    end)
end

function SaveSystem.LoadLanguage()
    if not isfile(LANG_FILE) then return nil end

    local ok, result = pcall(function()
        local decoded = HttpService:JSONDecode(readfile(LANG_FILE))
        return decoded.Language
    end)

    return (ok and type(result) == "string") and result or nil
end


function SaveSystem.SaveDebug(data)
    pcall(function()
        EnsureFolders()
        writefile(DEBUG_FILE, HttpService:JSONEncode(data))
    end)
end

function SaveSystem.LoadDebug()
    if not isfile(DEBUG_FILE) then return {} end

    local ok, result = pcall(function()
        return HttpService:JSONDecode(readfile(DEBUG_FILE))
    end)

    return (ok and type(result) == "table") and result or {}
end

function SaveSystem.SaveRedzLibrary(content)
    pcall(function()
        EnsureFolders()
        writefile(REDZ_FILE, content)
    end)
end

function SaveSystem.LoadRedzLibrary()
    if not isfile(REDZ_FILE) then return nil end
    local ok, result = pcall(function() return readfile(REDZ_FILE) end)
    return ok and result or nil
end

function SaveSystem.DeleteSave()
    pcall(function()
        if isfile(SAVE_FILE) then
            delfile(SAVE_FILE)
            print("[SaveSystem] Save deletado para: " .. ACCOUNT_NAME)
        end
    end)
end

function SaveSystem.GetInfo()
    return {
        account      = ACCOUNT_NAME,
        rootFolder   = ROOT_FOLDER,
        accountFolder = ACCOUNT_FOLDER,
        hasSave      = isfile(SAVE_FILE),
        hasLanguage  = isfile(LANG_FILE),
        hasDebug     = isfile(DEBUG_FILE),
        hasRedz      = isfile(REDZ_FILE),
    }
end

function SaveSystem.StartAutoSave(Config, intervalSeconds)
    local interval = intervalSeconds or 30
    task.spawn(function()
        while task.wait(interval) do
            SaveSystem.SaveConfig(Config)
        end
    end)
    print(("[SaveSystem] AutoSave ativado a cada %ds para: %s"):format(interval, ACCOUNT_NAME))
end

function SaveSystem.Init(Config)
    local hadSave = SaveSystem.LoadConfig(Config)
    local savedLang = SaveSystem.LoadLanguage()
    if savedLang then
        Config.Language = savedLang
    end
    SaveSystem.StartAutoSave(Config, 30)
    if hadSave then
        print("[SaveSystem] ✅ Configs restauradas para: " .. ACCOUNT_NAME)
    else
        print("[SaveSystem] 🆕 Primeira execução para: " .. ACCOUNT_NAME .. " — usando padrões.")
    end
    return hadSave
end

return SaveSystem