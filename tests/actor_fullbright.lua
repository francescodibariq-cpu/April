-- Actor-only fullbright test for Volt.
-- Fallen often has zero actors, so we create one, then run_on_actor into it.

assert(typeof(run_on_actor) == "function", "[ActorFB] missing run_on_actor")

local Players = game:GetService("Players")
local lp = Players.LocalPlayer or Players.PlayerAdded:Wait()
local parent = lp:FindFirstChild("PlayerScripts") or lp:WaitForChild("PlayerGui")

local function find_actor()
    if typeof(getactors) == "function" then
        local list = getactors()
        if type(list) == "table" then
            for i = 1, #list do
                local a = list[i]
                if typeof(a) == "Instance" and a:IsA("Actor") then
                    return a
                end
            end
        end
    end

    for _, d in ipairs(game:GetDescendants()) do
        if d:IsA("Actor") then
            return d
        end
    end

    return nil
end

local actor = find_actor()
if not actor then
    actor = Instance.new("Actor")
    actor.Name = "ActorFB_Test"

    -- LocalScript child helps some builds mark the Actor as having a Lua state.
    local boot = Instance.new("LocalScript")
    boot.Name = "Boot"
    boot.Parent = actor

    actor.Parent = parent
    print("[ActorFB] created Actor under", parent:GetFullName())

    -- Wait until Volt reports the Actor state (if the API exists).
    if typeof(on_actor_added) == "RBXScriptSignal" or typeof(on_actor_added) == "table" then
        local ok, conn
        ok, conn = pcall(function()
            return on_actor_added:Connect(function(a)
                if a == actor then
                    print("[ActorFB] on_actor_added fired")
                end
            end)
        end)
        task.wait(0.15)
        if ok and conn then
            pcall(function()
                conn:Disconnect()
            end)
        end
    else
        task.wait(0.15)
    end
else
    print("[ActorFB] found actor", actor:GetFullName())
end

run_on_actor(actor, [[
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

if shared.__ActorFB_conn then
    pcall(function()
        shared.__ActorFB_conn:Disconnect()
    end)
    shared.__ActorFB_conn = nil
end

local function apply()
    Lighting.Brightness = 2
    Lighting.Ambient = Color3.new(1, 1, 1)
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    Lighting.ColorShift_Top = Color3.new(0, 0, 0)
    Lighting.ColorShift_Bottom = Color3.new(0, 0, 0)
    Lighting.FogStart = 0
    Lighting.FogEnd = 1000000000
    Lighting.GlobalShadows = false
    Lighting.ClockTime = 12
    pcall(function()
        Lighting.ExposureCompensation = 0.6
    end)
end

apply()
shared.__ActorFB_conn = RunService.RenderStepped:Connect(apply)
print("[ActorFB] fullbright running inside Actor VM")
]])

print("[ActorFB] run_on_actor dispatched")
