local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ESP veri klasörü
local Holder = Instance.new("Folder")
Holder.Name = "ESP_Data"
Holder.Parent = CoreGui

-- Ayarlar
local ESP = {
    Enabled = true,
    TeamCheck = false,
    Boxes = true,
    Names = true,
    Distance = true,
    Health = true,
    Tracers = true
}

-- Renkler
local Colors = {
    Box = Color3.fromRGB(255, 255, 255),
    Name = Color3.fromRGB(255, 255, 255),
    Tracer = Color3.fromRGB(255, 255, 255),
    NPC_Box = Color3.fromRGB(255, 255, 0),
    NPC_Name = Color3.fromRGB(255, 255, 0)
}

-- ESP nesnelerini tutan tablo
local ESPObjects = {}

-- 3D dünya koordinatlarını 2D ekran koordinatlarına çevir
local function WorldToScreen(Position)
    local Point, OnScreen = Camera:WorldToViewportPoint(Position)
    return Vector2.new(Point.X, Point.Y), OnScreen
end

-- ESP oluştur
local function CreateESP(Player)
    local Character = Player.Character
    if not Character then return end
    
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    local Head = Character:FindFirstChild("Head")
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not RootPart or not Head or not Humanoid then return end
    
    -- Mevcut ESP'yi temizle
    if ESPObjects[Player] then
        for _, v in pairs(ESPObjects[Player]) do
            if v and v.Remove then
                v:Remove()
            end
        end
    end
    ESPObjects[Player] = {}
    
    -- Drawing kütüphanesi kontrolü
    local Draw = Drawing
    if not Draw then
        warn("Drawing kütüphanesi bulunamadı. Executor'unuz desteklemiyor olabilir.")
        return
    end
    
    -- ESP nesnelerini oluştur
    local Box = Draw.new("Square")
    Box.Thickness = 1
    Box.Filled = false
    Box.Color = Colors.Box
    Box.Visible = false
    ESPObjects[Player].Box = Box
    
    local NameTag = Draw.new("Text")
    NameTag.Size = 13
    NameTag.Center = true
    NameTag.Outline = true
    NameTag.Color = Colors.Name
    NameTag.Visible = false
    ESPObjects[Player].NameTag = NameTag
    
    local HealthBar = Draw.new("Square")
    HealthBar.Filled = true
    HealthBar.Visible = false
    ESPObjects[Player].HealthBar = HealthBar
    
    local HealthBg = Draw.new("Square")
    HealthBg.Filled = true
    HealthBg.Color = Color3.new(0, 0, 0)
    HealthBg.Visible = false
    ESPObjects[Player].HealthBg = HealthBg
    
    local Tracer = Draw.new("Line")
    Tracer.Thickness = 1
    Tracer.Color = Colors.Tracer
    Tracer.Visible = false
    ESPObjects[Player].Tracer = Tracer
    
    -- NPC kontrolü
    local IsNPC = false
    pcall(function()
        IsNPC = not Players:GetPlayerFromCharacter(Character)
    end)
    
    -- Güncelleme döngüsü
    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        if not ESP.Enabled then
            for _, v in pairs(ESPObjects[Player]) do
                if v then v.Visible = false end
            end
            return
        end
        
        if not Character or not Character.Parent then
            Connection:Disconnect()
            if ESPObjects[Player] then
                for _, v in pairs(ESPObjects[Player]) do
                    if v and v.Remove then v:Remove() end
                end
                ESPObjects[Player] = nil
            end
            return
        end
        
        local RootPos = RootPart.Position
        local HeadPos = Head.Position
        local ScreenPos, OnScreen = WorldToScreen(RootPos)
        
        if not OnScreen then
            for _, v in pairs(ESPObjects[Player]) do
                if v then v.Visible = false end
            end
            return
        end
        
        -- Mesafe hesapla
        local Distance = (Camera.CFrame.Position - RootPos).Magnitude
        local Scale = 1000 / Distance
        
        -- Boyut hesapla
        local Height = math.abs((HeadPos.Y - RootPos.Y) * 2.5) * Scale
        local Width = Height / 2
        
        -- Kutu
        if ESP.Boxes and ESPObjects[Player].Box then
            ESPObjects[Player].Box.Position = Vector2.new(ScreenPos.X - Width/2, ScreenPos.Y - Height/2)
            ESPObjects[Player].Box.Size = Vector2.new(Width, Height)
            ESPObjects[Player].Box.Color = IsNPC and Colors.NPC_Box or Colors.Box
            ESPObjects[Player].Box.Visible = true
        end
        
        -- İsim
        if ESP.Names and ESPObjects[Player].NameTag then
            local NameText = Player.Name
            if ESP.Distance then
                NameText = NameText .. " [" .. math.floor(Distance) .. "m]"
            end
            ESPObjects[Player].NameTag.Text = NameText
            ESPObjects[Player].NameTag.Position = Vector2.new(ScreenPos.X, ScreenPos.Y - Height/2 - 15)
            ESPObjects[Player].NameTag.Color = IsNPC and Colors.NPC_Name or Colors.Name
            ESPObjects[Player].NameTag.Visible = true
        end
        
        -- Can barı
        if ESP.Health and ESPObjects[Player].HealthBar and ESPObjects[Player].HealthBg then
            local Health = Humanoid.Health / Humanoid.MaxHealth
            local BarHeight = Height * Health
            ESPObjects[Player].HealthBg.Position = Vector2.new(ScreenPos.X - Width/2 - 6, ScreenPos.Y - Height/2)
            ESPObjects[Player].HealthBg.Size = Vector2.new(3, Height)
            ESPObjects[Player].HealthBg.Visible = true
            ESPObjects[Player].HealthBar.Position = Vector2.new(ScreenPos.X - Width/2 - 6, ScreenPos.Y + Height/2 - BarHeight)
            ESPObjects[Player].HealthBar.Size = Vector2.new(3, BarHeight)
            ESPObjects[Player].HealthBar.Color = Color3.new(1 - Health, Health, 0)
            ESPObjects[Player].HealthBar.Visible = true
        end
        
        -- Çizgi
        if ESP.Tracers and ESPObjects[Player].Tracer then
            local ScreenSize = Camera.ViewportSize
            ESPObjects[Player].Tracer.From = Vector2.new(ScreenSize.X/2, ScreenSize.Y)
            ESPObjects[Player].Tracer.To = Vector2.new(ScreenPos.X, ScreenPos.Y + Height/2)
            ESPObjects[Player].Tracer.Visible = true
        end
    end)
    
    return Connection
end

-- Oyuncu ekleme
local function OnPlayerAdded(Player)
    if Player == LocalPlayer then return end
    Player.CharacterAdded:Connect(function(Character)
        task.wait(0.5)
        CreateESP(Player)
    end)
    if Player.Character then
        task.wait(0.5)
        CreateESP(Player)
    end
end

-- Tüm oyuncuları tara
for _, Player in ipairs(Players:GetPlayers()) do
    OnPlayerAdded(Player)
end
Players.PlayerAdded:Connect(OnPlayerAdded)

-- Oyuncu çıkarma
Players.PlayerRemoving:Connect(function(Player)
    if ESPObjects[Player] then
        for _, v in pairs(ESPObjects[Player]) do
            if v and v.Remove then v:Remove() end
        end
        ESPObjects[Player] = nil
    end
end)

-- NPC ESP
task.spawn(function()
    while task.wait(1) do
        if not ESP.Enabled then continue end
        for _, Object in ipairs(workspace:GetDescendants()) do
            if Object:IsA("Model") and Object:FindFirstChild("Humanoid") and Object:FindFirstChild("Head") then
                local IsPlayer = false
                pcall(function()
                    IsPlayer = Players:GetPlayerFromCharacter(Object) ~= nil
                end)
                if not IsPlayer and not ESPObjects[Object] then
                    local FakePlayer = {Name = Object.Name, Character = Object}
                    ESPObjects[Object] = {}
                    CreateESP(FakePlayer)
                end
            end
        end
    end
end)

-- Kendi karakterimiz yeniden doğduğunda ESP'leri temizle
LocalPlayer.CharacterAdded:Connect(function()
    for Player, Objects in pairs(ESPObjects) do
        if typeof(Player) == "Instance" and Player:IsA("Player") then continue end
        for _, v in pairs(Objects) do
            if v and v.Remove then v:Remove() end
        end
        ESPObjects[Player] = nil
    end
end)

print("ESP v3.2 Yüklendi - GitHub Raw Uyumlu - Tüm Executorlar")
