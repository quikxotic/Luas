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

-- sets user data --
local UserData = game:HttpGet("https://users.roblox.com/v1/users/" .. tostring(victim), true)
local decodedData = game:GetService("HttpService"):JSONDecode(UserData)
friend.Name = decodedData.name
friend.UserId = decodedData.id
friend.CharacterAppearanceId = decodedData.id
friend.DisplayName = decodedData.displayName

-- changes user character --
function Char()
    local plr = Players:FindFirstChild(decodedData.name)
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
    local parent = plr.Character.Parent
    plr.Character.Parent = nil
    plr.Character.Parent = parent
end
Char()

-- changes premium/verified status --
local spoofedPlayer = Players:FindFirstChild(decodedData.name) or friend
local oldNamecall
oldNamecall = hookmetamethod(game, "__index", function(self, key)
    if self == spoofedPlayer then
        if key == "MembershipType" and premium then
            return Enum.MembershipType.Premium
        end
        if key == "HasVerifiedBadge" and verified then
            return true
        end
    end
    return oldNamecall(self, key)
end)

-- gpt code below to handle keys, platform, and other unhandled data --
local imagetable = {
    ["DESKTOP"] = "rbxassetid://17136633356",
    ["MOBILE"] = "rbxassetid://17136633510",
    ["CONSOLE"] = "rbxassetid://17136633629",
    ["VR"] = "rbxassetid://17136765745"
}

game:GetService("RunService").RenderStepped:Connect(function()
    local ctrl =
        Players:FindFirstChild(decodedData.name)
        and Players[decodedData.name].Character
        and Players[decodedData.name].Character:FindFirstChild("HumanoidRootPart")
        and Players[decodedData.name].Character.HumanoidRootPart:FindFirstChild("Nametag")
        and Players[decodedData.name].Character.HumanoidRootPart.Nametag:FindFirstChild("Frame")
        and Players[decodedData.name].Character.HumanoidRootPart.Nametag.Frame:FindFirstChild("Player")
        and Players[decodedData.name].Character.HumanoidRootPart.Nametag.Frame.Player:FindFirstChild("Controls")

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
            if v.Name == "Username" and string.find(v.Text, "@" .. decodedData.name) then
                v.Parent.Container.TeammateSlot.Container.Controls.Image = imagetable[platform]
            end
        end
    end
    for _,v in ipairs(
        Players.LocalPlayer
        and Players.LocalPlayer:FindFirstChild("PlayerGui")
        and Players.LocalPlayer.PlayerGui:FindFirstChild("MainGui")
        and Players.LocalPlayer.PlayerGui.MainGui:FindFirstChild("MainFrame")
        and Players LocalPlayer.PlayerGui.MainFrame.Lobby:FindFirstChild("Currency")
        and Players LocalPlayer.PlayerGui.MainGui.MainFrame.Lobby.Currency:FindFirstChild("Container"):GetDescendants()
    ) do
        if v.Name == "Icon" and keys and v.Image == "rbxassetid://17860673529" then
            v.Parent.Parent.Title.Text = keys
        end
    end
end)

-- unlock all --
if unlockall then
    task.wait(3)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WEFGQERQEGWGE/a/refs/heads/main/yashitcrack.lua"))()
end
