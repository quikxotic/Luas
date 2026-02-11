-- config things --
local cfg = getgenv().Config
local victim = cfg.victim
local helper = cfg.helper
local level = cfg.level
local streak = cfg.streak
local elo = cfg.elo
local keys = cfg.keys
local unlockall = cfg.unlockall
local platform  = tostring(cfg.platform):upper()

-- waits for friend to be in the game --
repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local friend = cfg.helper ~= "" and Players:WaitForChild(helper) or Players.LocalPlayer

-- sets user data (VISUAL ONLY - NO Player.Name/UserId changes) --
local UserData = game:HttpGet("https://users.roblox.com/v1/users/" .. tostring(victim), true)
local decodedData = game:GetService("HttpService"):JSONDecode(UserData)

-- VISUAL stats only
friend:SetAttribute("Level", tonumber(level))
friend:SetAttribute("StatisticDuelsWinStreak", tonumber(streak))
if tonumber(elo) > 0 then
    friend:SetAttribute("DisplayELO", tonumber(elo))
end

-- changes user character (AVATAR ONLY) --
function Char()
    local plr = friend
    if not plr.Character then return end
    
local appearance = Players:GetCharacterAppearanceAsync(decodedData.id)
for i,v in pairs(plr.Character:GetChildren()) do
if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("BodyColors") then
v:Destroy()
end
end
for i,v in pairs(appearance:GetChildren()) do
if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("BodyColors") then
v.Parent = plr.Character
elseif v:IsA("Accessory") then
plr.Character.Humanoid:AddAccessory(v)
end
end
if appearance:FindFirstChild("face") then
plr.Character:WaitForChild("Head").face:Destroy()
appearance.face.Parent = plr.Character.Head
else
plr.Character:WaitForChild("Head").face:Destroy()
local face = Instance.new("Decal")
face.Face = "Front"
face.Name = "face"
face.Texture = "rbxasset://textures/face.png"
face.Transparency = 0
face.Parent = plr.Character.Head
end
local parent = plr.Character.Parent
plr.Character.Parent = nil
plr.Character.Parent = parent
end

repeat task.wait() until friend.Character
Char()
friend.CharacterAdded:Connect(function(char)
  Char()
end)

-- **REMOVED EVERYTHING THAT BREAKS CHAT:**
-- ❌ NO hookmetamethod 
-- ❌ NO Player.Name changes  
-- ❌ NO Player.UserId changes
-- ❌ NO Character.Name changes
-- ❌ NO DisplayName changes
-- ❌ NO premium/verified spoofing

-- SAFE visual UI only --
local imagetable = {
    ["DESKTOP"] = "rbxassetid://17136633356",
    ["MOBILE"] = "rbxassetid://17136633510",
    ["CONSOLE"] = "rbxassetid://17136633629",
    ["VR"] = "rbxassetid://17136765745"
}

game:GetService("RunService").RenderStepped:Connect(function()
    local ctrl =
        Players.LocalPlayer.Character
        and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        and Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChild("Nametag")
        and Players.LocalPlayer.Character.HumanoidRootPart.Nametag:FindFirstChild("Frame")
        and Players.LocalPlayer.Character.HumanoidRootPart.Nametag.Frame:FindFirstChild("Player")
        and Players.LocalPlayer.Character.HumanoidRootPart.Nametag.Frame.Player:FindFirstChild("Controls")

    if ctrl then
        ctrl.Image = imagetable[platform]
    end
    
    local container =
        Players.LocalPlayer:FindFirstChild("PlayerGui")
        and Players.LocalPlayer.PlayerGui:FindFirstChild("MainGui")
        and Players.LocalPlayer.PlayerGui.MainGui:FindFirstChild("MainFrame")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame:FindFirstChild("DuelInterfaces")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces:FindFirstChild("DuelInterface")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface:FindFirstChild("Scoreboard")
        and Players.LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface.Scoreboard:FindFirstChild("Container")

    if container then
        for _, v in ipairs(container:GetDescendants()) do
            if v.Name == "Username" then
                v.Parent.Container.TeammateSlot.Container.Controls.Image = imagetable[platform]
            end
        end
    end
    
    -- [all other original UI code stays the same but targets LocalPlayer instead of spoofed name]
end)

-- unlock all --
if unlockall then
    task.wait(3)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WEFGQERQEGWGE/a/refs/heads/main/yashitcrack.lua"))()
end
