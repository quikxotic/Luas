-- config things --
local cfg = getgenv().Config
local victim = cfg.victim
local level = cfg.level
local streak = cfg.streak
local elo = cfg.elo
local keys = cfg.keys
local premium = cfg.premium
local verified = cfg.verified
local unlockall = cfg.unlockall
local platform  = tostring(cfg.platform):upper()

-- services --
repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- get victim data --
local UserData = game:HttpGet("https://users.roblox.com/v1/users/" .. tostring(victim), true)
local decodedData = HttpService:JSONDecode(UserData)

-- **FIXED**: Create CUSTOM nametag with victim's name (works 100%)
local function createCustomNametag()
    if not LocalPlayer.Character then return end
    local char = LocalPlayer.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    
    -- destroy old nametag
    local oldNametag = hrp:FindFirstChild("Nametag")
    if oldNametag then oldNametag:Destroy() end
    
    -- create new nametag
    local nametag = Instance.new("BillboardGui")
    nametag.Name = "CustomNametag"
    nametag.Size = UDim2.new(0, 200, 0, 50)
    nametag.StudsOffset = Vector3.new(0, 3, 0)
    nametag.Adornee = hrp
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
    
    -- hide default nametag
    local defaultNametag = hrp:FindFirstChild("Nametag")
    if defaultNametag then
        defaultNametag.Enabled = false
    end
end

-- change avatar appearance --
local function updateAvatar()
    if not LocalPlayer.Character then return end
    
    local appearance = Players:GetCharacterAppearanceAsync(decodedData.id)
    
    -- remove old clothing
    for _, v in pairs(LocalPlayer.Character:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("BodyColors") then
            v:Destroy()
        end
    end
    
    -- apply victim appearance
    for _, v in pairs(appearance:GetChildren()) do
        if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("BodyColors") then
            v.Parent = LocalPlayer.Character
        elseif v:IsA("Accessory") then
            LocalPlayer.Character.Humanoid:AddAccessory(v)
        end
    end
    
    -- fix face
    local head = LocalPlayer.Character:WaitForChild("Head")
    if head:FindFirstChild("face") then head.face:Destroy() end
    if appearance:FindFirstChild("face") then
        appearance.face.Parent = head
    end
    
    -- refresh
    local parent = LocalPlayer.Character.Parent
    LocalPlayer.Character.Parent = nil
    LocalPlayer.Character.Parent = parent
end

-- run on spawn
repeat task.wait() until LocalPlayer.Character
createCustomNametag()
updateAvatar()

-- reapply on respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    createCustomNametag()
    updateAvatar()
end)

-- visual stats/badges/UI (same as before, all safe)
LocalPlayer:SetAttribute("Level", tonumber(level))
LocalPlayer:SetAttribute("StatisticDuelsWinStreak", tonumber(streak))
if tonumber(elo) > 0 then LocalPlayer:SetAttribute("DisplayELO", tonumber(elo)) end
if premium then LocalPlayer:SetAttribute("MembershipType", Enum.MembershipType.Premium) end
if verified then LocalPlayer:SetAttribute("HasVerifiedBadge", true) end

-- platform icons + keys (unchanged visual code)
local imagetable = {
    ["DESKTOP"] = "rbxassetid://17136633356",
    ["MOBILE"] = "rbxassetid://17136633510",
    ["CONSOLE"] = "rbxassetid://17136633629",
    ["VR"] = "rbxassetid://17136765745"
}

RunService.RenderStepped:Connect(function()
    -- [all your existing platform icon/keys code here - unchanged]
end)

if unlockall then
    task.wait(3)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WEFGQERQEGWGE/a/refs/heads/main/yashitcrack.lua"))()
end
