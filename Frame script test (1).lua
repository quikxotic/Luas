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

repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- get victim data --
local UserData = game:HttpGet("https://users.roblox.com/v1/users/" .. tostring(victim), true)
local decodedData = HttpService:JSONDecode(UserData)
local victimName = decodedData.name
local victimDisplayName = decodedData.displayName or decodedData.name

-- **AGGRESSIVE VISUAL NAME CHANGE** - hooks PlayerGui name displays
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    -- intercept all name displays and replace with victim's name
    if method == "GetPropertyChangedSignal" and tostring(self) == "Text" then
        if string.find(tostring(args[1]), LocalPlayer.Name) or string.find(tostring(args[1]), LocalPlayer.DisplayName) then
            return oldNamecall(self, victimDisplayName)
        end
    end
    
    if (method == "FireServer" or method == "InvokeServer") and typeof(self) == "Instance" then
        if string.find(tostring(self), LocalPlayer.Name) then
            return oldNamecall(self, victimDisplayName)
        end
    end
    
    return oldNamecall(self, ...)
end)

-- **FORCE NAMETAG REPLACE** every frame
RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        
        -- destroy ALL nametags
        for _, v in pairs(hrp:GetChildren()) do
            if v:IsA("BillboardGui") or v.Name == "Nametag" then
                v:Destroy()
            end
        end
        
        -- create OUR nametag with victim's name
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
        nameLabel.Text = "@" .. victimName
        nameLabel.TextColor3 = Color3.new(1,1,1)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.new(0,0,0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextScaled = true
        nameLabel.Parent = frame
    end
end)

-- avatar change (unchanged, works)
local function updateAvatar()
    if not LocalPlayer.Character then return end
    local appearance = Players:GetCharacterAppearanceAsync(decodedData.id)
    
    for _, v in pairs(LocalPlayer.Character:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("BodyColors") then
            v:Destroy()
        end
    end
    
    for _, v in pairs(appearance:GetChildren()) do
        if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("BodyColors") then
            v.Parent = LocalPlayer.Character
        elseif v:IsA("Accessory") then
            LocalPlayer.Character.Humanoid:AddAccessory(v)
        end
    end
    
    local head = LocalPlayer.Character:WaitForChild("Head")
    if head:FindFirstChild("face") then head.face:Destroy() end
    if appearance:FindFirstChild("face") then
        appearance.face.Parent = head
    end
end

repeat task.wait() until LocalPlayer.Character
updateAvatar()
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    updateAvatar()
end)

-- rest of visual features (stats, icons, etc. - same as before)
LocalPlayer:SetAttribute("Level", tonumber(level))
LocalPlayer:SetAttribute("StatisticDuelsWinStreak", tonumber(streak))
if tonumber(elo) > 0 then LocalPlayer:SetAttribute("DisplayELO", tonumber(elo)) end

local imagetable = {
    ["DESKTOP"] = "rbxassetid://17136633356",
    ["MOBILE"] = "rbxassetid://17136633510",
    ["CONSOLE"] = "rbxassetid://17136633629",
    ["VR"] = "rbxassetid://17136765745"
}

-- [platform icons, keys code stays same]

if unlockall then
    task.wait(3)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WEFGQERQEGWGE/a/refs/heads/main/yashitcrack.lua"))()
end
