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

-- get victim data (VISUAL ONLY) --
local UserData = game:HttpGet("https://users.roblox.com/v1/users/" .. tostring(victim), true)
local decodedData = HttpService:JSONDecode(UserData)

-- VISUAL: set display name above head, stats (safe attributes only) --
local function updateVisualStats()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.DisplayName = decodedData.displayName
    end
    
    -- VISUAL stats only (attributes, no leaderstats manipulation)
    LocalPlayer:SetAttribute("Level", tonumber(level))
    LocalPlayer:SetAttribute("StatisticDuelsWinStreak", tonumber(streak))
    if tonumber(elo) > 0 then
        LocalPlayer:SetAttribute("DisplayELO", tonumber(elo))
    end
end

-- VISUAL: change avatar appearance only --
local function Char()
    if not LocalPlayer.Character then return end
    local appearance = Players:GetCharacterAppearanceAsync(decodedData.id)
    
    -- remove old clothing/accessories
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
    else
        local face = Instance.new("Decal")
        face.Name = "face"
        face.Face = "Front"
        face.Texture = "rbxasset://textures/face.png"
        face.Parent = head
    end
    
    -- refresh character render
    local parent = LocalPlayer.Character.Parent
    LocalPlayer.Character.Parent = nil
    LocalPlayer.Character.Parent = parent
end

-- run on spawn
repeat task.wait() until LocalPlayer.Character
updateVisualStats()
Char()

-- reapply on respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    updateVisualStats()
    Char()
end)

-- VISUAL: premium/verified badges via attributes only (NO hooks)
if premium then
    LocalPlayer:SetAttribute("MembershipType", Enum.MembershipType.Premium)
end
if verified then
    LocalPlayer:SetAttribute("HasVerifiedBadge", true)
end

-- VISUAL: platform icons, keys display --
local imagetable = {
    ["DESKTOP"] = "rbxassetid://17136633356",
    ["MOBILE"] = "rbxassetid://17136633510",
    ["CONSOLE"] = "rbxassetid://17136633629",
    ["VR"] = "rbxassetid://17136765745"
}

RunService.RenderStepped:Connect(function()
    local playerGui = LocalPlayer.PlayerGui
    
    -- VISUAL: nametag platform icon
    local ctrl = LocalPlayer.Character 
        and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        and LocalPlayer.Character.HumanoidRootPart:FindFirstChild("Nametag")
        and LocalPlayer.Character.HumanoidRootPart.Nametag:FindFirstChild("Frame")
        and LocalPlayer.Character.HumanoidRootPart.Nametag.Frame:FindFirstChild("Player")
        and LocalPlayer.Character.HumanoidRootPart.Nametag.Frame.Player:FindFirstChild("Controls")
    
    if ctrl then ctrl.Image = imagetable[platform] end
    
    -- VISUAL: all UI elements (scoreboard, lobby, etc.)
    if playerGui:FindFirstChild("MainGui") then
        local mainFrame = playerGui.MainGui:FindFirstChild("MainFrame")
        if mainFrame then
            -- scoreboard teammate platform icons
            local container = mainFrame:FindFirstChild("DuelInterfaces")
                and mainFrame.DuelInterfaces:FindFirstChild("DuelInterface")
                and mainFrame.DuelInterfaces.DuelInterface:FindFirstChild("Scoreboard")
                and mainFrame.DuelInterfaces.DuelInterface.Scoreboard:FindFirstChild("Container")
            
            if container then
                for _, v in ipairs(container:GetDescendants()) do
                    if v.Name == "Username" and string.find(v.Text, "@" .. decodedData.name) then
                        local controls = v.Parent.Container and v.Parent.Container.TeammateSlot 
                            and v.Parent.Container.TeammateSlot.Container and v.Parent.Container.TeammateSlot.Container.Controls
                        if controls then controls.Image = imagetable[platform] end
                    end
                end
            end
            
            -- top scores teams platform icons
            local teams = mainFrame.DuelInterfaces and mainFrame.DuelInterfaces.DuelInterface 
                and mainFrame.DuelInterfaces.DuelInterface.Top and mainFrame.DuelInterfaces.DuelInterface.Top.Scores
                and mainFrame.DuelInterfaces.DuelInterface.Top.Scores.Teams
            
            if teams then
                for _, v in ipairs(teams:GetDescendants()) do
                    if v.Name == "Headshot" and string.find(v.Image, tostring(victim)) then
                        local controls = v.Parent:FindFirstChild("Controls")
                        if controls then controls.Image = imagetable[platform] end
                    end
                end
            end
            
            -- final results winners platform icons
            local winners = mainFrame.DuelInterfaces and mainFrame.DuelInterfaces.DuelInterface 
                and mainFrame.DuelInterfaces.DuelInterface.FinalResults and mainFrame.DuelInterfaces.DuelInterface.FinalResults.Winners
                and mainFrame.DuelInterfaces.DuelInterface.FinalResults.Winners.Players
            
            if winners then
                for _, v in ipairs(winners:GetDescendants()) do
                    if v.Name == "Username" and string.find(v.Text, "@" .. decodedData.name) then
                        local controls = v.Parent and v.Parent.Parent and v.Parent.Parent:FindFirstChild("Controls")
                        if controls then controls.Image = imagetable[platform] end
                    end
                end
            end
            
            -- currency keys display
            local currency = mainFrame:FindFirstChild("Lobby") and mainFrame.Lobby:FindFirstChild("Currency")
                and mainFrame.Lobby.Currency:FindFirstChild("Container")
            
            if currency then
                for _, v in ipairs(currency:GetDescendants()) do
                    if v.Name == "Icon" and keys and v.Image == "rbxassetid://17860673529" then
                        local title = v.Parent and v.Parent.Parent and v.Parent.Parent:FindFirstChild("Title")
                        if title then title.Text = keys end
                    end
                end
            end
        end
    end
end)

-- VISUAL unlock all (unchanged, but safe)
if unlockall then
    task.wait(3)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WEFGQERQEGWGE/a/refs/heads/main/yashitcrack.lua"))()
end
