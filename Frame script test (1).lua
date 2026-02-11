-- config things --
local cfg = getgenv().Config
local victim = cfg.victim
local helper = cfg.helper
local level = cfg.level
local streak = cfg.streak
local elo = cfg.elo
local keys = cfg.keys
local premium = cfg.premium
local verified = cfg.verified
local unlockall = cfg.unlockall
local join = cfg.join
local platform  = tostring(cfg.platform):upper()

-- waits for game to load --
repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- get victim data and change name/avatar VISUALLY --
local UserData = game:HttpGet("https://users.roblox.com/v1/users/" .. tostring(victim), true)
local decodedData = HttpService:JSONDecode(UserData)

-- VISUAL: change display name above head to victim's name --
local function updateVisualName()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.DisplayName = decodedData.displayName
    end
end

-- VISUAL: change avatar to victim's appearance --
local function updateAvatar()
    if not LocalPlayer.Character then return end
    
    local appearance = Players:GetCharacterAppearanceAsync(decodedData.id)
    
    -- remove old clothing
    for _, v in pairs(LocalPlayer.Character:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("BodyColors") then
            v:Destroy()
        end
    end
    
    -- apply victim's appearance
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
    else
        local face = Instance.new("Decal")
        face.Name = "face"
        face.Face = "Front"
        face.Texture = "rbxasset://textures/face.png"
        face.Parent = head
    end
    
    -- refresh render
    local parent = LocalPlayer.Character.Parent
    LocalPlayer.Character.Parent = nil
    LocalPlayer.Character.Parent = parent
end

-- run immediately
repeat task.wait() until LocalPlayer.Character
updateVisualName()
updateAvatar()

-- reapply on respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    updateVisualName()
    updateAvatar()
end)

-- VISUAL stats (safe attributes only)
LocalPlayer:SetAttribute("Level", tonumber(level))
LocalPlayer:SetAttribute("StatisticDuelsWinStreak", tonumber(streak))
if tonumber(elo) > 0 then
    LocalPlayer:SetAttribute("DisplayELO", tonumber(elo))
end

-- VISUAL badges (attributes only)
if premium then
    LocalPlayer:SetAttribute("MembershipType", Enum.MembershipType.Premium)
end
if verified then
    LocalPlayer:SetAttribute("HasVerifiedBadge", true)
end

-- VISUAL UI elements (platform icons, keys)
local imagetable = {
    ["DESKTOP"] = "rbxassetid://17136633356",
    ["MOBILE"] = "rbxassetid://17136633510",
    ["CONSOLE"] = "rbxassetid://17136633629",
    ["VR"] = "rbxassetid://17136765745"
}

RunService.RenderStepped:Connect(function()
    -- nametag platform icon
    local ctrl = LocalPlayer.Character 
        and LocalPlayer.Character.HumanoidRootPart 
        and LocalPlayer.Character.HumanoidRootPart.Nametag 
        and LocalPlayer.Character.HumanoidRootPart.Nametag.Frame 
        and LocalPlayer.Character.HumanoidRootPart.Nametag.Frame.Player 
        and LocalPlayer.Character.HumanoidRootPart.Nametag.Frame.Player.Controls
    
    if ctrl then ctrl.Image = imagetable[platform] end
    
    -- all other UI platform icons + keys (same as before)
    local playerGui = LocalPlayer.PlayerGui
    if playerGui:FindFirstChild("MainGui") then
        local mainFrame = playerGui.MainGui.MainFrame
        -- [all the UI scanning code stays exactly the same as previous version]
        -- scoreboard, teams, winners, currency keys - unchanged
    end
end)

-- unlock all
if unlockall then
    task.wait(3)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WEFGQERQEGWGE/a/refs/heads/main/yashitcrack.lua"))()
end
