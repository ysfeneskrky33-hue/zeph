-- Roblox ESP Scripti - GUI Kontrol Panelli Versiyon
-- Yürütücü: Lua Executor (Synapse X, Script-Ware, KRNL vb.)
-- Açıklama: Açılır kapanır GUI paneli ile ESP özelliklerini anlık kontrol eder.

-- 1. Gerekli servisler ve temel değişkenler
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 2. ESP Veri deposu ve ayarlar
local ESP_Holder = Instance.new("Folder")
ESP_Holder.Name = "ESP_Data"
ESP_Holder.Parent = CoreGui

local ESP_Connections = {}
local TrackedCharacters = {}

local Settings = {
    MasterEnabled = true,
    Players = {
        Enabled = true,
        ShowBox = true,
        ShowName = true,
        ShowHealth = true,
        ShowDistance = true,
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

-- 3. GUI Oluşturma Fonksiyonu (ScreenGui tabanlı)
local function CreateGUI()
    -- 3a. Ana ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ESP_Control_Panel"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true

    -- 3b. Ana Panel (Sağ üst köşede)
    local MainPanel = Instance.new("Frame")
    MainPanel.Name = "MainPanel"
    MainPanel.Size = UDim2.new(0, 220, 0, 300)
    MainPanel.Position = UDim2.new(1, -230, 0.3, 0)
    MainPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainPanel.BorderSizePixel = 0
    MainPanel.Active = true
    MainPanel.Draggable = true
    MainPanel.Parent = ScreenGui

    -- 3c. Başlık Çubuğu
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainPanel
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -10, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "ESP Kontrol Paneli"
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextSize = 14
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar

    -- 3d. Aç/Kapat Butonu (Başlıkta sağda)
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    CloseButton.Text = "-"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 18
    CloseButton.Parent = TitleBar
    local PanelMinimized = false
    CloseButton.MouseButton1Click:Connect(function()
        PanelMinimized = not PanelMinimized
        if PanelMinimized then
            MainPanel.Size = UDim2.new(0, 220, 0, 30)
            CloseButton.Text = "+"
        else
            MainPanel.Size = UDim2.new(0, 220, 0, 300)
            CloseButton.Text = "-"
        end
    end)

    -- 3e. ScrollFrame (İçerik için)
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, -10, 1, -35)
    ScrollFrame.Position = UDim2.new(0, 5, 0, 35)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.ScrollBarThickness = 5
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
    ScrollFrame.Parent = MainPanel

    local YOffset = 0
    local function AddToggle(Text, Callback, Default)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 25)
        ToggleFrame.Position = UDim2.new(0, 0, 0, YOffset)
        ToggleFrame.BackgroundTransparency = 1
        ToggleFrame.Parent = ScrollFrame
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = Text
        Label.TextColor3 = Color3.fromRGB(200, 200, 200)
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleFrame
        local Toggle = Instance.new("TextButton")
        Toggle.Size = UDim2.new(0, 30, 0, 20)
        Toggle.Position = UDim2.new(1, -35, 0, 2)
        Toggle.Text = ""
        Toggle.BorderSizePixel = 0
        Toggle.BackgroundColor3 = Default and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        Toggle.Parent = ToggleFrame
        local IsOn = Default
        Toggle.MouseButton1Click:Connect(function()
            IsOn = not IsOn
            Toggle.BackgroundColor3 = IsOn and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
            Callback(IsOn)
        end)
        YOffset = YOffset + 25
        return Toggle
    end

    -- 3f. Toggle'ları ekle
    AddToggle("ESP Açık", function(val) Settings.MasterEnabled = val end, true)
    AddToggle("Oyuncu ESP", function(val) Settings.Players.Enabled = val end, true)
    AddToggle("Oyuncu Kutu", function(val) Settings.Players.ShowBox = val end, true)
    AddToggle("Oyuncu İsim", function(val) Settings.Players.ShowName = val end, true)
    AddToggle("Oyuncu Can", function(val) Settings.Players.ShowHealth = val end, true)
    AddToggle("Oyuncu Mesafe", function(val) Settings.Players.ShowDistance = val end, true)
    AddToggle("Oyuncu Çizgi", function(val) Settings.Players.ShowTracers = val end, true)
    AddToggle("NPC ESP", function(val) Settings.NPCs.Enabled = val end, true)
    AddToggle("NPC Kutu", function(val) Settings.NPCs.ShowBox = val end, true)
    AddToggle("NPC İsim", function(val) Settings.NPCs.ShowName = val end, true)

    -- 3g. Scroll canvas'ı güncelle
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, YOffset + 10)
    return ScreenGui
end

-- 4. ESP Yardımcı Fonksiyonları
local function GetCharacterData(Character)
    if not Character then return nil end
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChild("Humanoid")
    local Head = Character:FindFirstChild("Head")
    if not HumanoidRootPart or not Humanoid or not Head then return nil end
    local Position, OnScreen = Camera:WorldToViewportPoint(HumanoidRootPart.Position)
    local RootPos, HeadPos = HumanoidRootPart.Position, Head.Position
    local Height = math.abs((HeadPos.Y - RootPos.Y) * 2.5)
    local Width = Height / 2
    return {
        Position = Vector2.new(Position.X, Position.Y),
        OnScreen = OnScreen,
        Height = Height,
        Width = Width,
        Humanoid = Humanoid,
        Name = Character.Name,
        IsNPC = not Players:GetPlayerFromCharacter(Character),
        RootPart = HumanoidRootPart
    }
end

-- 5. ESP Çizim Sınıfı (Drawing API)
local Draw = Drawing
local function CreateESP(TargetData)
    local ESPObjects = {}
    
    if ESPObjects and Draw then
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
        if not Settings.MasterEnabled then
            for _, v in pairs(ESPObjects) do
                if v then v.Visible = false end
            end
            return
        end
        if TargetData.IsNPC and not Settings.NPCs.Enabled then
            for _, v in pairs(ESPObjects) do
                if v then v.Visible = false end
            end
            return
        end
        if not TargetData.IsNPC and not Settings.Players.Enabled then
            for _, v in pairs(ESPObjects) do
                if v then v.Visible = false end
            end
            return
        end
        
        local Data = GetCharacterData(Character)
        if not Data or not Data.OnScreen then
            for _, v in pairs(ESPObjects) do
                if v then v.Visible = false end
            end
            return
        end
        
        local ScreenPos = Data.Position
        local Height = Data.Height
        local Width = Data.Width
        local ScaleFactor = 1000 / (Camera.CFrame.Position - Data.RootPart.Position).Magnitude
        Height = Height * ScaleFactor
        Width = Width * ScaleFactor
        local ScreenSize = Camera.ViewportSize
        
        if ESPObjects.NameText and (Data.IsNPC and Settings.NPCs.ShowName or not Data.IsNPC and Settings.Players.ShowName) then
            ESPObjects.NameText.Position = Vector2.new(ScreenPos.X, ScreenPos.Y - Height/2 - 15)
            ESPObjects.NameText.Visible = true
            if Settings.Players.ShowDistance and not Data.IsNPC then
                local Dist = math.floor((LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - Data.RootPart.Position).Magnitude) or 0)
                ESPObjects.NameText.Text = Data.Name .. " [" .. Dist .. "m]"
            end
        end
        if ESPObjects.BoxOutline and (Data.IsNPC and Settings.NPCs.ShowBox or not Data.IsNPC and Settings.Players.ShowBox) then
            ESPObjects.BoxOutline.Position = Vector2.new(ScreenPos.X - Width/2, ScreenPos.Y - Height/2)
            ESPObjects.BoxOutline.Size = Vector2.new(Width, Height)
            ESPObjects.BoxOutline.Visible = true
        end
        if ESPObjects.HealthBar and not Data.IsNPC and Settings.Players.ShowHealth then
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
        if ESPObjects.Tracer and not Data.IsNPC and Settings.Players.ShowTracers then
            ESPObjects.Tracer.From = Vector2.new(ScreenSize.X/2, ScreenSize.Y)
            ESPObjects.Tracer.To = Vector2.new(ScreenPos.X, ScreenPos.Y + Height/2)
            ESPObjects.Tracer.Visible = true
        end
    end
    return UpdateESP
end

-- 6. Ana ESP Döngüsü
local function StartESP()
    if ESP_Connections.RenderStep then ESP_Connections.RenderStep:Disconnect() end
    ESP_Connections.RenderStep = RunService.RenderStepped:Connect(function()
        local TargetList = {}
        if Settings.Players.Enabled or Settings.NPCs.Enabled then
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
end

-- 7. Oyuncu respawn'larında ESP'yi sıfırla
LocalPlayer.CharacterAdded:Connect(function()
    TrackedCharacters = {}
end)

-- 8. GUI'yi başlat ve ESP'yi çalıştır
CreateGUI()
StartESP()
print("ESP GUI Kontrol Paneli Aktif. Sağ üst köşedeki panelden kontrol edin.")
