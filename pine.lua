-- Pine Tree Macro v2.2 - FIXED: Tool Swing via ClickEvent + REAL Hive Convert (SpawnPos + Remote)
-- Load: loadstring(game:HttpGet("https://raw.githubusercontent.com/Daiyu13/usandourwork/refs/heads/main/pine.lua"))()

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local RS = ReplicatedStorage.Events
local hrp, hum
local function getChar()
    if player.Character then
        hrp = player.Character:FindFirstChild("HumanoidRootPart")
        hum = player.Character:FindFirstChild("Humanoid")
        return hrp and hum
    end
end

repeat task.wait(0.5) until getChar()
print("v2.2 READY - Tool ClickEvent + SpawnPos Convert")

player.CharacterAdded:Connect(function()
    task.wait(2)
    getChar()
    print("Respawned OK")
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

local function getSpawnPos()
    local spawnPos = player:FindFirstChild("SpawnPos")
    if spawnPos and spawnPos:IsA("Vector3Value") then
        print("SpawnPos found:", spawnPos.Value)
        return spawnPos.Value
    end
    print("No SpawnPos - fallback")
    return hrp.Position
end

local function moveTo(target)
    if not hrp then return end
    target = target + getRandomOffset()
    local tween = TweenService:Create(hrp, TweenInfo.new(3.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {CFrame = target})
    tween:Play()
    tween.Completed:Wait()
end

local spotIndex = 1

-- MAIN LOOP
task.spawn(function()
    while true do
        if not hrp then task.wait(1); getChar(); continue end

        -- POLLEN CHECK
        local data = player:FindFirstChild("DataFolder")
        if data and data:FindFirstChild("CoreStats") then
            local stats = data.CoreStats
            local pollen = stats:FindFirstChild("Pollen")
            local capacity = stats:FindFirstChild("Capacity")
            if pollen and capacity then
                local pct = (pollen.Value / capacity.Value) * 100
                print("Pollen:", math.floor(pct), "%")
                if pct >= 95 then
                    print("FULL! CONVERTING...")
                    local spawnPos = getSpawnPos()
                    local hiveTarget = spawnPos + Vector3.new(0, 0, 9)  -- Offset for pad
                    moveTo(CFrame.new(hiveTarget))
                    task.wait(1)
                    RS.PlayerHiveCommand:FireServer("ToggleHoneyMaking")  -- START CONVERT
                    repeat
                        task.wait(0.5)
                        print("Converting... Pollen:", pollen.Value)
                    until pollen.Value < capacity.Value * 0.1  -- UNTIL MOSTLY EMPTY
                    RS.PlayerHiveCommand:FireServer("ToggleHoneyMaking")  -- STOP
                    task.wait(2)
                    continue
                end
            end
        end

        -- PATROL
        local target = pineSpots[spotIndex]
        print("Spot", spotIndex)
        moveTo(target)
        spotIndex = (spotIndex % #pineSpots) + 1
        task.wait(0.5)
    end
end)

-- TOOL SWING (Remote Equip + ClickEvent)
task.spawn(function()
    local lastEquip = 0
    local currentTool = nil
    while true do
        if hrp and hum then
            -- FIND TOOL IN BACKPACK
            local backpackTool = nil
            for _, item in player.Backpack:GetChildren() do
                if item:IsA("Tool") then
                    backpackTool = item
                    break
                end
            end
            if backpackTool and (tick() - lastEquip > 3 or not currentTool) then
                local toolName = backpackTool.Name  -- e.g. "Porcelain Dipper"
                RS.ItemPackageEvent:InvokeServer("Equip", {
                    Mute = false,
                    Type = toolName,
                    Category = "Collector"
                })
                print("Equipped:", toolName)
                currentTool = toolName
                lastEquip = tick()
                task.wait(0.5)  -- Equip delay
            end

            -- SWING VIA CLICK EVENT
            if currentTool then
                local toolModel = workspace:FindFirstChild(player.Name) and workspace[player.Name]:FindFirstChild(currentTool)
                if toolModel and toolModel:FindFirstChild("ClickEvent") then
                    toolModel.ClickEvent:FireServer()
                end
            end
        end
        task.wait(math.random(20,40)/100)  -- 0.2-0.4s swings
    end
end)

print("v2.2 RUNNING - Pollen % prints + Tool swings + REAL convert!")
