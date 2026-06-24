local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local ESP_Folder = Instance.new("Folder")
ESP_Folder.Name = "ESP_Holder"
ESP_Folder.Parent = CoreGui

local Settings = {
    Players = {
        Enabled = true,
        ShowBox = true,
        ShowName = true,
        ShowDistance = true,
        ShowHealth = true,
        ShowTracers = true,
        BoxColor = Color3.fromRGB(255, 255, 255),
        NameColor = Color3.fromRGB(255, 255, 255),
        TracerColor = Color3.fromRGB(255, 255, 255)
    },
    NPCs = {
        Enabled = true,
        ShowBox = true,
        ShowName = true,
        BoxColor = Color3.fromRGB(255, 255, 0),
        NameColor = Color3.fromRGB(255, 255, 0)
    }
}

local function GetCharacterData(Character)
    if not Character then return nil end
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChild("Humanoid")
    local Head = Character:FindFirstChild("Head")
    if not HumanoidRootPart or not Humanoid or not Head then return nil end
    local Position, OnScreen = Camera:WorldToViewportPoint(HumanoidRootPart.Position)
    local RootPos = HumanoidRootPart.Position
    local HeadPos = Head.Position
    local Height = math.abs((HeadPos.Y - RootPos.Y) * 2.5)
    local Width = Height / 2
    return {
        Position = Vector2.new(Position.X, Position.Y),
        OnScreen = OnScreen,
        Height = Height,
        Width = Width,
        Humanoid = Humanoid,
        Name = Character.Name,
        IsNPC = not Players:GetPlayerFromCharacter(Character)
    }
end

local TrackedCharacters = {}

local function CreateESP(TargetData)
    local ESPObjects = {}
    local Draw = Drawing or nil
    if Draw then
        if TargetData.IsNPC and Settings.NPCs.ShowName or not TargetData.IsNPC and Settings.Players.ShowName then
            local NameText = Draw.new("Text")
            NameText.Text = TargetData.Name
            NameText.Size = 13
            NameText.Center = true
            NameText.Outline = true
            NameText.Color = TargetData.IsNPC and Settings.NPCs.NameColor or Settings.Players.NameColor
            NameText.Visible = false
            ESPObjects.NameText = NameText
        end
        if TargetData.IsNPC and Settings.NPCs.ShowBox or not TargetData.IsNPC and Settings.Players.ShowBox then
            local BoxOutline = Draw.new("Square")
            BoxOutline.Thickness = 1
            BoxOutline.Filled = false
            BoxOutline.Color = TargetData.IsNPC and Settings.NPCs.BoxColor or Settings.Players.BoxColor
            BoxOutline.Visible = false
            ESPObjects.BoxOutline = BoxOutline
        end
        if not TargetData.IsNPC and Settings.Players.ShowHealth then
            local HealthBarBg = Draw.new("Square")
            HealthBarBg.Filled = true
            HealthBarBg.Color = Color3.new(0,0,0)
            HealthBarBg.Visible = false
            ESPObjects.HealthBarBg = HealthBarBg
            local HealthBar = Draw.new("Square")
            HealthBar.Filled = true
            HealthBar.Color = Color3.new(0,1,0)
            HealthBar.Visible = false
            ESPObjects.HealthBar = HealthBar
        end
        if not TargetData.IsNPC and Settings.Players.ShowTracers then
            local Tracer = Draw.new("Line")
            Tracer.Color = Settings.Players.TracerColor
            Tracer.Thickness = 1
            Tracer.Visible = false
            ESPObjects.Tracer = Tracer
        end
    end

    local function UpdateESP(Character)
        local Data = GetCharacterData(Character)
        if not Data or not Data.OnScreen then
            for _, v in pairs(ESPObjects) do if v then v.Visible = false end end
            return
        end
        local ScreenPos = Data.Position
        local Height = Data.Height
        local Width = Data.Width
        local ScaleFactor = 1000 / (Camera.CFrame.Position - Character.HumanoidRootPart.Position).Magnitude
        Height = Height * ScaleFactor
        Width = Width * ScaleFactor
        local ScreenSize = Camera.ViewportSize
        
        if ESPObjects.NameText then
            ESPObjects.NameText.Position = Vector2.new(ScreenPos.X, ScreenPos.Y - Height/2 - 15)
            ESPObjects.NameText.Visible = true
            if Settings.Players.ShowDistance and not Data.IsNPC then
                local Dist = math.floor((LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude) or 0)
                ESPObjects.NameText.Text = Data.Name .. " [" .. Dist .. "m]"
            end
        end
        if ESPObjects.BoxOutline then
            ESPObjects.BoxOutline.Position = Vector2.new(ScreenPos.X - Width/2, ScreenPos.Y - Height/2)
            ESPObjects.BoxOutline.Size = Vector2.new(Width, Height)
            ESPObjects.BoxOutline.Visible = true
        end
        if ESPObjects.HealthBar and not Data.IsNPC then
            local Health = Data.Humanoid.Health / Data.Humanoid.MaxHealth
            local BarHeight = Height * Health
            ESPObjects.HealthBarBg.Position = Vector2.new(ScreenPos.X - Width/2 - 6, ScreenPos.Y - Height/2)
            ESPObjects.HealthBarBg.Size = Vector2.new(3, Height)
            ESPObjects.HealthBarBg.Visible = true
            ESPObjects.HealthBar.Position = Vector2.new(ScreenPos.X - Width/2 - 6, ScreenPos.Y + Height/2 - BarHeight)
            ESPObjects.HealthBar.Size = Vector2.new(3, BarHeight)
            ESPObjects.HealthBar.Color = Color3.new(1 - Health, Health, 0)
            ESPObjects.HealthBar.Visible = true
        end
        if ESPObjects.Tracer and not Data.IsNPC then
            ESPObjects.Tracer.From = Vector2.new(ScreenSize.X/2, ScreenSize.Y)
            ESPObjects.Tracer.To = Vector2.new(ScreenPos.X, ScreenPos.Y + Height/2)
            ESPObjects.Tracer.Visible = true
        end
    end
    return UpdateESP
end

RunService.RenderStepped:Connect(function()
    local TargetList = {}
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            table.insert(TargetList, Player.Character)
        end
    end
    if Settings.NPCs.Enabled then
        for _, Model in ipairs(workspace:GetChildren()) do
            if Model:IsA("Model") and Model:FindFirstChild("Humanoid") and Model:FindFirstChild("Head") then
                if not Players:GetPlayerFromCharacter(Model) then
                    table.insert(TargetList, Model)
                end
            end
        end
    end
    local ActiveChars = {}
    for _, Char in ipairs(TargetList) do
        ActiveChars[Char] = true
        if not TrackedCharacters[Char] then
            local Data = GetCharacterData(Char)
            if Data then
                TrackedCharacters[Char] = CreateESP(Data)
            end
        end
        if TrackedCharacters[Char] then
            TrackedCharacters[Char](Char)
        end
    end
    for Char, _ in pairs(TrackedCharacters) do
        if not ActiveChars[Char] then
            TrackedCharacters[Char] = nil
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    TrackedCharacters = {}
end)

print("ESP Aktif - GitHub Raw Link Versiyon")
