local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- AYARLAR
local Settings = {
    Master = true,
    Boxes = true,
    Names = true,
    Health = true,
    Tracers = true,
    Distance = true,
    Chams = true,
    ChamsColor = Color3.fromRGB(255, 0, 0) -- Kırmızı chams
}

local ESP_Folder = Instance.new("Folder", CoreGui)
ESP_Folder.Name = "ESP_System"
local ESP_List = {}        -- Drawing nesneleri
local Chams_List = {}      -- Highlight nesneleri

-- /////////////// GUI ///////////////
local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "ESP_Panel"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 200, 0, 245)
    Main.Position = UDim2.new(1, -210, 0.25, 0)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.ClipsDescendants = true
    local Title = Instance.new("Frame", Main)
    Title.Size = UDim2.new(1, 0, 0, 28)
    Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Title.BorderSizePixel = 0
    local TitleText = Instance.new("TextLabel", Title)
    TitleText.Size = UDim2.new(1, -10, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "ESP KONTROL PANELI"
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextSize = 12
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    local Minimized = false
    local CloseBtn = Instance.new("TextButton", Title)
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -28, 0, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Text = "-"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    CloseBtn.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        if Minimized then Main.Size = UDim2.new(0, 200, 0, 28) CloseBtn.Text = "+"
        else Main.Size = UDim2.new(0, 200, 0, 245) CloseBtn.Text = "-" end
    end)
    local Scroll = Instance.new("ScrollingFrame", Main)
    Scroll.Size = UDim2.new(1, -8, 1, -33)
    Scroll.Position = UDim2.new(0, 4, 0, 31)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 4
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 400)
    local Y = 0
    local function AddToggle(Text, Default, Callback)
        local Frame = Instance.new("Frame", Scroll)
        Frame.Size = UDim2.new(1, 0, 0, 24)
        Frame.Position = UDim2.new(0, 0, 0, Y)
        Frame.BackgroundTransparency = 1
        local Label = Instance.new("TextLabel", Frame)
        Label.Size = UDim2.new(0.65, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = Text
        Label.TextColor3 = Color3.fromRGB(200, 200, 200)
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 11
        Label.TextXAlignment = Enum.TextXAlignment.Left
        local Toggle = Instance.new("TextButton", Frame)
        Toggle.Size = UDim2.new(0, 28, 0, 18)
        Toggle.Position = UDim2.new(1, -32, 0, 3)
        Toggle.BorderSizePixel = 0
        Toggle.Text = ""
        Toggle.BackgroundColor3 = Default and Color3.fromRGB(0, 160, 0) or Color3.fromRGB(160, 0, 0)
        local State = Default
        Toggle.MouseButton1Click:Connect(function()
            State = not State
            Toggle.BackgroundColor3 = State and Color3.fromRGB(0, 160, 0) or Color3.fromRGB(160, 0, 0)
            Callback(State)
        end)
        Y = Y + 25
        return Toggle
    end
    AddToggle("ESP Acik/Kapali", true, function(v) Settings.Master = v end)
    AddToggle("Kutular", true, function(v) Settings.Boxes = v end)
    AddToggle("Isimler", true, function(v) Settings.Names = v end)
    AddToggle("Can Bari", true, function(v) Settings.Health = v end)
    AddToggle("Cizgiler", true, function(v) Settings.Tracers = v end)
    AddToggle("Mesafe", true, function(v) Settings.Distance = v end)
    AddToggle("CHAMS (Model Boya)", true, function(v) Settings.Chams = v end)
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Y + 5)
end

-- /////////////// YARDIMCI: Tüm ESP nesnelerini temizle ///////////////
local function ClearESP(Plr)
    if ESP_List[Plr] then
        for _, v in pairs(ESP_List[Plr]) do
            if v and v.Remove then v:Remove() end
        end
        ESP_List[Plr] = nil
    end
    if Chams_List[Plr] then
        if Chams_List[Plr].Remove then Chams_List[Plr]:Remove() end
        Chams_List[Plr] = nil
    end
end

-- /////////////// CHAMS UYGULA (Highlight ile karakterin tam hatlarını boya) ///////////////
local function ApplyChams(Plr, Char)
    if not Char then return end
    -- Önceki chams'i temizle
    if Chams_List[Plr] and Chams_List[Plr].Remove then
        Chams_List[Plr]:Remove()
        Chams_List[Plr] = nil
    end
    
    -- Yeni Highlight oluştur
    local Highlight = Instance.new("Highlight")
    Highlight.Name = "ESP_Chams"
    Highlight.FillColor = Settings.ChamsColor
    Highlight.FillTransparency = 0.4
    Highlight.OutlineColor = Settings.ChamsColor
    Highlight.OutlineTransparency = 0
    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Duvarların arkasından da görünür
    Highlight.Parent = Char
    Chams_List[Plr] = Highlight
end

-- /////////////// ESP OLUŞTUR ///////////////
local function CreateESP(Plr)
    local Char = Plr.Character
    if not Char then return end
    local Root = Char:FindFirstChild("HumanoidRootPart")
    local Head = Char:FindFirstChild("Head")
    local Hum = Char:FindFirstChild("Humanoid")
    if not Root or not Head or not Hum then return end
    
    ClearESP(Plr)
    ESP_List[Plr] = {}
    local Obj = ESP_List[Plr]
    
    -- Chams uygula
    if Settings.Chams then
        ApplyChams(Plr, Char)
    end
    
    if Drawing then
        Obj.Box = Drawing.new("Square")
        Obj.Box.Thickness = 1
        Obj.Box.Filled = false
        Obj.Box.Color = Color3.fromRGB(255, 255, 255)
        Obj.Box.Visible = false
        
        Obj.Name = Drawing.new("Text")
        Obj.Name.Size = 13
        Obj.Name.Center = true
        Obj.Name.Outline = true
        Obj.Name.Color = Color3.fromRGB(255, 255, 255)
        Obj.Name.Visible = false
        
        Obj.HPbg = Drawing.new("Square")
        Obj.HPbg.Filled = true
        Obj.HPbg.Color = Color3.new(0, 0, 0)
        Obj.HPbg.Visible = false
        
        Obj.HP = Drawing.new("Square")
        Obj.HP.Filled = true
        Obj.HP.Visible = false
        
        Obj.Tracer = Drawing.new("Line")
        Obj.Tracer.Thickness = 1
        Obj.Tracer.Color = Color3.fromRGB(255, 255, 255)
        Obj.Tracer.Visible = false
    end
    
    local Conn
    Conn = RunService.RenderStepped:Connect(function()
        -- ESP kapalıysa TÜM nesneleri gizle
        if not Settings.Master then
            for _, v in pairs(Obj) do
                if v and v.Visible ~= nil then v.Visible = false end
            end
            -- Chams'i de kaldır
            if Chams_List[Plr] and Chams_List[Plr].Remove then
                Chams_List[Plr]:Remove()
                Chams_List[Plr] = nil
            end
            return
        end
        
        -- Chams kontrolü
        if Settings.Chams and not Chams_List[Plr] then
            ApplyChams(Plr, Char)
        elseif not Settings.Chams and Chams_List[Plr] then
            if Chams_List[Plr].Remove then Chams_List[Plr]:Remove() end
            Chams_List[Plr] = nil
        end
        
        -- Karakter geçerlilik kontrolü
        if not Char or not Char.Parent or not Root or not Root.Parent then
            Conn:Disconnect()
            ClearESP(Plr)
            return
        end
        
        local RootPos, RootOnScreen = Camera:WorldToViewportPoint(Root.Position)
        if not RootOnScreen then
            for _, v in pairs(Obj) do
                if v and v.Visible ~= nil then v.Visible = false end
            end
            return
        end
        
        local Dist = (Camera.CFrame.Position - Root.Position).Magnitude
        local Scale = 1000 / Dist
        local H = math.abs((Head.Position.Y - Root.Position.Y) * 2.5) * Scale
        local W = H / 2
        
        if Settings.Boxes and Obj.Box then
            Obj.Box.Position = Vector2.new(RootPos.X - W/2, RootPos.Y - H/2)
            Obj.Box.Size = Vector2.new(W, H)
            Obj.Box.Visible = true
        elseif Obj.Box then Obj.Box.Visible = false end
        
        if Settings.Names and Obj.Name then
            local Txt = Plr.Name
            if Settings.Distance then Txt = Txt .. " [" .. math.floor(Dist) .. "m]" end
            Obj.Name.Text = Txt
            Obj.Name.Position = Vector2.new(RootPos.X, RootPos.Y - H/2 - 15)
            Obj.Name.Visible = true
        elseif Obj.Name then Obj.Name.Visible = false end
        
        if Settings.Health and Obj.HP then
            local HP = Hum.Health / Hum.MaxHealth
            local BH = H * HP
            Obj.HPbg.Position = Vector2.new(RootPos.X - W/2 - 6, RootPos.Y - H/2)
            Obj.HPbg.Size = Vector2.new(3, H)
            Obj.HPbg.Visible = true
            Obj.HP.Position = Vector2.new(RootPos.X - W/2 - 6, RootPos.Y + H/2 - BH)
            Obj.HP.Size = Vector2.new(3, BH)
            Obj.HP.Color = Color3.new(1 - HP, HP, 0)
            Obj.HP.Visible = true
        elseif Obj.HP then
            Obj.HP.Visible = false
            Obj.HPbg.Visible = false
        end
        
        if Settings.Tracers and Obj.Tracer then
            Obj.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            Obj.Tracer.To = Vector2.new(RootPos.X, RootPos.Y + H/2)
            Obj.Tracer.Visible = true
        elseif Obj.Tracer then Obj.Tracer.Visible = false end
    end)
end

-- /////////////// OYUNCU TAKİBİ ///////////////
local function AddPlayer(Plr)
    if Plr == LocalPlayer then return end
    Plr.CharacterAdded:Connect(function(Char)
        task.wait(0.3)
        CreateESP(Plr)
        -- Chams yeniden uygula (karakter değişince)
        if Settings.Chams and Settings.Master then
            ApplyChams(Plr, Char)
        end
    end)
    if Plr.Character then CreateESP(Plr) end
end

for _, p in ipairs(Players:GetPlayers()) do AddPlayer(p) end
Players.PlayerAdded:Connect(AddPlayer)
Players.PlayerRemoving:Connect(ClearESP)

-- /////////////// RESPAWN TEMİZLİK ///////////////
LocalPlayer.CharacterAdded:Connect(function()
    for Plr, _ in pairs(ESP_List) do ClearESP(Plr) end
    for Plr, _ in pairs(Chams_List) do ClearESP(Plr) end
end)

-- /////////////// CHAMS RENK GÜNCELLEME DÖNGÜSÜ ///////////////
task.spawn(function()
    while task.wait(0.1) do
        for Plr, Highlight in pairs(Chams_List) do
            if Highlight and Highlight.Parent then
                Highlight.FillColor = Settings.ChamsColor
                Highlight.OutlineColor = Settings.ChamsColor
                Highlight.Enabled = Settings.Master and Settings.Chams
            end
        end
    end
end)

-- /////////////// BAŞLAT ///////////////
CreateGUI()
print("ESP vFinal: Hatalar giderildi. ESP kapaninca her sey silinir. Chams: Karakterin tam hatlarini boyar.")
