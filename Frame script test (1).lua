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

-- waits for friend to be in the game --
repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local friend = cfg.helper ~= "" and Players:WaitForChild(helper) or Players.LocalPlayer

-- sets user data (READ ONLY, do NOT overwrite Name/UserId) --
local UserData = game:HttpGet("https://users.roblox.com/v1/users/" .. tostring(victim), true)
local decodedData = game:GetService("HttpService"):JSONDecode(UserData)

repeat task.wait() until friend.Character
friend.Character:WaitForChild("Humanoid")

-- only spoof humanoid displayname (visual) and stats; keep Player.Name/UserId intact
friend.Character.Humanoid.DisplayName = decodedData.displayName

Players.LocalPlayer:SetAttribute("SpoofedLevel", tonumber(level))
Players.LocalPlayer:SetAttribute("SpoofedWinStreak", tonumber(streak))

local ls = Players.LocalPlayer:FindFirstChild("leaderstats")
if ls then
    if ls:FindFirstChild("Level") then
        ls.Level.Value = tonumber(level)
    end
    local ws = ls:FindFirstChild("Win Streak")
    if ws then
        ws.Value = tonumber(streak)
    end
end

if tonumber(elo) > 0 then
    Players.LocalPlayer:SetAttribute("SpoofedDisplayELO", tonumber(elo))
end

-- changes user character (appearance only) --
local function Char()
    local plr = friend
    if not (plr and plr.Character) then return end

    local appearance = Players:GetCharacterAppearanceAsync(decodedData.id)
    for _, v in pairs(plr.Character:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("BodyColors") then
            v:Destroy()
        end
    end
    for _, v in pairs(appearance:GetChildren()) do
        if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("BodyColors") then
            v.Parent = plr.Character
        elseif v:IsA("Accessory") then
            plr.Character.Humanoid:AddAccessory(v)
        end
    end
    if appearance:FindFirstChild("face") then
        local head = plr.Character:WaitForChild("Head")
        if head:FindFirstChild("face") then
            head.face:Destroy()
        end
        appearance.face.Parent = head
    else
        local head = plr.Character:WaitForChild("Head")
        local oldFace = head:FindFirstChild("face")
        if oldFace then oldFace:Destroy() end
        local face = Instance.new("Decal")
        face.Face = "Front"
        face.Name = "face"
        face.Texture = "rbxasset://textures/face.png"
        face.Transparency = 0
        face.Parent = head
    end
    local parent = plr.Character.Parent
    plr.Character.Parent = nil
    plr.Character.Parent = parent
end

Char()
friend.CharacterAdded:Connect(function()
    task.defer(Char)
end)

-- premium / verified spoof done via attributes (avoids __index hooks)
if premium then
    Players.LocalPlayer:SetAttribute("SpoofedPremium", true)
end
if verified then
    Players.LocalPlayer:SetAttribute("SpoofedVerified", true)
end

-- gpt code below to handle keys, platform, and other unhandled data --
local imagetable = {
    ["DESKTOP"] = "rbxassetid://17136633356",
    ["MOBILE"] = "rbxassetid://17136633510",
    ["CONSOLE"] = "rbxassetid://17136633629",
    ["VR"] = "rbxassetid://17136765745"
}

game:GetService("RunService").RenderStepped:Connect(function()
    local spoofName = decodedData.name

    local plr = Players.LocalPlayer
    local char = plr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local nametag = hrp and hrp:FindFirstChild("Nametag")
    local frame = nametag and nametag:FindFirstChild("Frame")
    local playerFrame = frame and frame:FindFirstChild("Player")
    local ctrl = playerFrame and playerFrame:FindFirstChild("Controls")

    if ctrl then
        ctrl.Image = imagetable[platform]
    end

    local container =
        plr:FindFirstChild("PlayerGui")
        and plr.PlayerGui:FindFirstChild("MainGui")
        and plr.PlayerGui.MainGui:FindFirstChild("MainFrame")
        and plr.PlayerGui.MainGui.MainFrame:FindFirstChild("DuelInterfaces")
        and plr.PlayerGui.MainGui.MainFrame.DuelInterfaces:FindFirstChild("DuelInterface")
        and plr.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface:FindFirstChild("Scoreboard")
        and plr.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface.Scoreboard:FindFirstChild("Container")

    if container then
        for _, v in ipairs(container:GetDescendants()) do
            if v.Name == "Username" and string.find(v.Text, "@" .. spoofName) then
                if v.Parent and v.Parent:FindFirstChild("Container") then
                    local teammateSlot = v.Parent.Container:FindFirstChild("TeammateSlot")
                    if teammateSlot and teammateSlot:FindFirstChild("Container") and teammateSlot.Container:FindFirstChild("Controls") then
                        teammateSlot.Container.Controls.Image = imagetable[platform]
                    end
                end
            end
        end
    end

    local scoresTeams =
        plr:FindFirstChild("PlayerGui")
        and plr.PlayerGui:FindFirstChild("MainGui")
        and plr.PlayerGui.MainGui:FindFirstChild("MainFrame")
        and plr.PlayerGui.MainGui.MainFrame:FindFirstChild("DuelInterfaces")
        and plr.PlayerGui.MainGui.MainFrame.DuelInterfaces:FindFirstChild("DuelInterface")
        and plr.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface:FindFirstChild("Top")
        and plr.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface.Top:FindFirstChild("Scores")
        and plr.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface.Top.Scores:FindFirstChild("Teams")

    for _, v in ipairs(scoresTeams and scoresTeams:GetDescendants() or {}) do
        if v.Name == "Headshot" and string.find(v.Image, tostring(victim)) then
            local controls = v.Parent and v.Parent:FindFirstChild("Controls")
            if controls then
                controls.Image = imagetable[platform]
            end
        end
    end

    local winnersPlayers =
        plr:FindFirstChild("PlayerGui")
        and plr.PlayerGui:FindFirstChild("MainGui")
        and plr.PlayerGui.MainGui:FindFirstChild("MainFrame")
        and plr.PlayerGui.MainGui.MainFrame:FindFirstChild("DuelInterfaces")
        and plr.PlayerGui.MainGui.MainFrame.DuelInterfaces:FindFirstChild("DuelInterface")
        and plr.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface:FindFirstChild("FinalResults")
        and plr.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface.FinalResults:FindFirstChild("Winners")
        and plr.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface.FinalResults.Winners:FindFirstChild("Players")

    for _, v in ipairs(winnersPlayers and winnersPlayers:GetDescendants() or {}) do
        if v.Name == "Username" and string.find(v.Text, "@" .. spoofName) then
            local controls = v.Parent and v.Parent.Parent and v.Parent.Parent:FindFirstChild("Controls")
            if controls then
                controls.Image = imagetable[platform]
            end
        end
    end

    local currencyContainer =
        plr:FindFirstChild("PlayerGui")
        and plr.PlayerGui:FindFirstChild("MainGui")
        and plr.PlayerGui.MainGui:FindFirstChild("MainFrame")
        and plr.PlayerGui.MainGui.MainFrame:FindFirstChild("Lobby")
        and plr.PlayerGui.MainGui.MainFrame.Lobby:FindFirstChild("Currency")
        and plr.PlayerGui.MainGui.MainFrame.Lobby.Currency:FindFirstChild("Container")

    for _, v in ipairs(currencyContainer and currencyContainer:GetDescendants() or {}) do
        if v.Name == "Icon" and keys and v.Image == "rbxassetid://17860673529" then
            if v.Parent and v.Parent.Parent and v.Parent.Parent:FindFirstChild("Title") then
                v.Parent.Parent.Title.Text = keys
            end
        end
    end
end)

-- unlock all --
if unlockall then
    task.wait(3)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WEFGQERQEGWGE/a/refs/heads/main/yashitcrack.lua"))()
end
