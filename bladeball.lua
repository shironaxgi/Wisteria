local Services = setmetatable({}, {
    __index = function(self, key)
        local ok, svc = pcall(function()
            return game:GetService(key)
        end)
        if not ok or not svc then
            warn(("[Wisteria] Service '%s' unavailable."):format(tostring(key)))
            return nil
        end
        rawset(self, key, svc)
        return svc
    end,
})

local Players           = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local PLACE_ID    = 13772394625
local LOCAL_PLAYER = Players.LocalPlayer

local function bail(reason)
    warn(("[Wisteria] Bail: %s"):format(reason))
    if LOCAL_PLAYER then
        LOCAL_PLAYER:Kick("Wisteria: " .. reason)
    end
    return false
end

local function isVipServer()
    local ok, result = pcall(function()
        local probe = ReplicatedStorage:FindFirstChild("GetServerType")
        if not probe then return false end
        return probe:InvokeServer() == "VIPServer"
    end)
    return ok and result or false
end

local function boot()
    if game.PlaceId ~= PLACE_ID then
        return bail("Only works in Blade Ball")
    end
    if isVipServer() then
        return bail("Private servers not supported")
    end
    return true
end

if not boot() then return end

local function executeRemote(url)
    task.spawn(function()
        local fetched, body = pcall(function()
            return game:HttpGet(url)
        end)
        if not fetched or type(body) ~= "string" or #body == 0 then
            warn("[Wisteria] Remote fetch failed.")
            return
        end
        local compiled, chunk = pcall(function()
            return loadstring(body)
        end)
        if not compiled or type(chunk) ~= "function" then
            warn("[Wisteria] Payload failed to compile.")
            return
        end
        local ran, err = pcall(chunk)
        if not ran then
            warn(("[Wisteria] Runtime error: %s"):format(tostring(err)))
        end
    end)
end

executeRemote("https://raw.githubusercontent.com/shironaxgi/Wisteria/refs/heads/main/bladeball.lua")

print("[Wisteria] BB loader online.")
