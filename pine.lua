-- Pine Tree Macro v2.3 - Simple Tool + Real Hive Convert (Atlas-style)
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local hrp, hum

local function getChar()
    if player.Character then
        hrp = player.Character:FindFirstChild("HumanoidRootPart")
        hum = player.Character:FindFirstChild("Humanoid")
    end
end

repeat task.wait(0.5) until player.Character
getChar()
print("v2.3 LOADED - Tool swings + Hive convert")

player.CharacterAdded:Connect(function() task.wait(2); getChar(); print("Respawn OK") end)

local pineSpots = {
    CFrame.new(-353.397, 68, -202.474),
    CFrame.new(-351.471, 68, -154.119),
    CFrame.new(-356.450, 68, -176.416),
    CFrame.new(-334.548, 68, -182.163),
    CFrame.new(-323.657, 68, -215.605),
    CFrame.new(-319.870, 68, -187.892),
    CFrame.new(-309.298, 68, -188.580)
}

local function getRandomOffset() return Vector3.new(math.random(-2,2), 0, math.random(-2,2)) end

local function getHivePad()
    local data = player:FindFirstChild("DataFolder")
    if data and data:FindFirstChild("HiveLocation") then
        local num = data.HiveLocation.Value  -- 1 to 6
        print("Your hive slot:", num)
        local hive = workspace.Hives:FindFirstChild("Hive" .. num)
        if hive and hive:FindFirstChild("Converter") and hive.Converter:FindFirstChild("TopPad") then
            return hive.Converter.TopPad.CFrame + Vector3.new(math.random(-1,1), 3, math.random(-1,1))
        end
    end
    print("Hive not found - using fallback")
    return hrp.CFrame
end

local function moveTo(target)
    if not hrp then return end
    target = target + getRandomOffset()
    local tween = TweenService:Create(hrp, TweenInfo.new(3.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {CFrame = target})
    tween:Play()
    tween.Completed:Wait()
end

local spotIndex = 1

-- MAIN FARM LOOP
task.spawn(function()
    while true do
        if not hrp then task.wait(1); getChar(); continue end

        -- POLLEN FULL? → HIVE
        local data = player:FindFirstChild("DataFolder")
        if data and data:FindFirstChild("CoreStats") then
            local stats = data.CoreStats
            local pollen = stats:FindFirstChild("Pollen")
            local cap = stats:FindFirstChild("Capacity")
            if pollen and cap then
                local pct = (pollen.Value / cap.Value) * 100
                print("Pollen:", math.floor(pct) .. "%")
                if pct >= 95 then
                    print("FULL → CONVERTING AT HIVE")
                    moveTo(getHivePad())
                    task.wait(1.5)
                    ReplicatedStorage.Events.PlayerHiveCommand:FireServer("ToggleHoneyMaking")
                    repeat task.wait(0.5) until pollen.Value < cap.Value * 0.1
                    ReplicatedStorage.Events.PlayerHiveCommand:FireServer("ToggleHoneyMaking")
                    task.wait(2)
                    continue
                end
            end
        end

        -- PATROL
        moveTo(pineSpots[spotIndex])
        print("Spot", spotIndex)
        spotIndex = (spotIndex % #pineSpots) + 1
        task.wait(0.6)
    end
end)

-- TOOL SWING LOOP (simple & reliable)
task.spawn(function()
    while true do
        if hum then
            local tool = hum:FindFirstChildOfClass("Tool")
            if not tool then
                for _, t in player.Backpack:GetChildren() do
                    if t:IsA("Tool") then
                        hum:EquipTool(t)
                        print("Equipped:", t.Name)
                        break
                    end
                end
            else
                tool:Activate()   -- THIS is what actually swings Porcelain Dipper etc.
            end
        end
        task.wait(math.random(18, 35) / 100)  -- 0.18–0.35s human timing
    end
end)

print("Ready - watch console for pollen % and hive slot")
