-- Pine Tree Macro - Hosted version (loadstring safe)
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer

local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
local hum = player.Character and player.Character:FindFirstChild("Humanoid")

if not hrp or not hum then
    print("Waiting for character...")
    player.CharacterAdded:Wait()
    hrp = player.Character:FindFirstChild("HumanoidRootPart")
    hum = player.Character:FindFirstChild("Humanoid")
end

local pineSpots = {
    CFrame.new(-353.397, 68, -202.474),
    CFrame.new(-351.471, 68, -154.119),
    CFrame.new(-356.450, 68, -176.416),
    CFrame.new(-334.548, 68, -182.163),
    CFrame.new(-323.657, 68, -215.605),
    CFrame.new(-319.870, 68, -187.892),
    CFrame.new(-309.298, 68, -188.580)
}

local spotIndex = 1

while true do
    -- Simple hive check (expand later)
    local data = player:FindFirstChild("DataFolder")
    if data and data.CoreStats then
        local pollen = data.CoreStats.Pollen.Value
        local cap = data.CoreStats.Capacity.Value
        if pollen >= cap * 0.95 then
            -- Go to hive (placeholder - replace with real path later)
            print("Would go to hive now")
            wait(5)
        end
    end

    local target = pineSpots[spotIndex] + Vector3.new(math.random(-2,2), 0, math.random(-2,2))
    local tween = TweenService:Create(hrp, TweenInfo.new(3.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {CFrame = target})
    tween:Play()
    tween.Completed:Wait()

    print("Reached spot", spotIndex)
    spotIndex = (spotIndex % #pineSpots) + 1

    -- Tool swing
    if hum then
        local tool = hum:FindFirstChildOfClass("Tool") or player.Backpack:FindFirstChildOfClass("Tool")
        if tool then
            if not tool.Parent == hum then hum:EquipTool(tool) end
            tool:Activate()
        end
    end

    wait(0.7)
end
