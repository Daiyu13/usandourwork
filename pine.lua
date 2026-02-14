-- Pine Tree Macro v2.1 - HiveLocation FIXED + Tool/Hive Debug Prints
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local hrp, hum
local function getChar()
    if player.Character then
        hrp = player.Character:FindFirstChild("HumanoidRootPart")
        hum = player.Character:FindFirstChild("Humanoid")
        return hrp and hum
    end
end

-- Wait for char
repeat task.wait(0.5) until getChar()
print("Char ready - farming Pine Tree")

player.CharacterAdded:Connect(function()
    task.wait(2)
    getChar()
    print("Respawn handled")
end)

local pineSpots = {
    CFrame.new(-353.397, 68, -202.474),
    CFrame.new(-351.471, 68, -154.119),
    CFrame.new(-356.450, 68, -176.416),
    CFrame.new(-334.548, 68, -182.163),
    CFrame.new(-323.657, 68, -215.605),
    CFrame.new(-319.870, 68, -187.892),
    CFrame.new(-309.298, 68, -188.580)
}

local function getRandomOffset()
    return Vector3.new(math.random(-2,2), 0, math.random(-2,2))
end

local function getHiveCFrame()
    local data = player:FindFirstChild("DataFolder")
    if data and data:FindFirstChild("HiveLocation") then
        local hiveLoc = data.HiveLocation.Value  -- 1-6 number
        print("Your hive slot:", hiveLoc)  -- Debug: confirms 1-6
        local hives = workspace:FindFirstChild("Hives")
        if hives then
            local hiveFolder = hives:FindFirstChild("Hive" .. tostring(hiveLoc))
            if hiveFolder and hiveFolder:FindFirstChild("Converter") and hiveFolder.Converter:FindFirstChild("TopPad") then
                local padCFrame = hiveFolder.Converter.TopPad.CFrame + Vector3.new(math.random(-1,1), 3, math.random(-1,1))
                print("Hive pad found - moving")  -- Debug
                return padCFrame
            end
        end
    end
    print("Hive not found - fallback")  -- Rare
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

-- MAIN LOOP: Patrol + Hive Check
task.spawn(function()
    while true do
        if not hrp then 
            task.wait(1) 
            getChar()
            continue 
        end

        -- FULL? -> HIVE (priority)
        local data = player:FindFirstChild("DataFolder")
        if data and data:FindFirstChild("CoreStats") then
            local stats = data.CoreStats
            local pollen = stats:FindFirstChild("Pollen")
            local capacity = stats:FindFirstChild("Capacity")
            if pollen and capacity and pollen.Value >= capacity.Value * 0.95 then
                print("95% FULL -> CONVERTING AT HIVE")
                moveTo(getHiveCFrame())
                task.wait(5)  -- Auto-deposit time
                continue
            end
        end

        -- PATROL
        local target = pineSpots[spotIndex]
        print("Patrol spot:", spotIndex)
        moveTo(target)
        spotIndex = (spotIndex % #pineSpots) + 1
        task.wait(0.5)
    end
end)

-- TOOL SWING LOOP (constant pollen collect)
task.spawn(function()
    local lastEquipTime = 0
    while true do
        if hrp and hum then
            local tool = hum:FindFirstChildOfClass("Tool")
            if not tool then
                if tick() - lastEquipTime > 4 then  -- Equip every 4s max
                    for _, item in player.Backpack:GetChildren() do
                        if item:IsA("Tool") then
                            hum:EquipTool(item)
                            print("Tool equipped:", item.Name)
                            lastEquipTime = tick()
                            break
                        end
                    end
                end
            else
                tool:Activate()  -- Swing for pollen
            end
        end
        task.wait(math.random(20,40)/100)  -- Human-like 0.2-0.4s taps
    end
end)

print("v2.1 LIVE - Watch console for 'Your hive slot: X' + 'FULL -> CONVERTING'")
