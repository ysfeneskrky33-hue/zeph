local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- /////////////// AYARLAR ///////////////
local Settings = {
    Master = true,
    Players = true,
    NPCs = true,
    Boxes = true,
    Names = true,
    Health = true,
    Tracers = true,
    Distance = true
}

-- /////////////// ESP KLASÖRÜ ///////////////
local ESP_Folder = Instance.new("Folder", CoreGui)
ESP_Folder.Name = "ESP_System"
local ESP_List = {}

-- /////////////// ANA KONTROL PANELI (SAĞ ÜST) ///////////////
local function CreateMainGUI()
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "ESP_Panel"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 200, 0, 260)
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
        if Minimized then
            Main.Size = UDim2.new(0, 200, 0, 28)
            CloseBtn.Text = "+"
        else
            Main.Size = UDim2.new(0, 200, 0, 260)
            CloseBtn.Text = "-"
        end
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
        return Toggle, Label
    end
    
    AddToggle("ESP Acik/Kapali", true, function(v) Settings.Master = v end)
    AddToggle("Oyuncu ESP", true, function(v) Settings.Players = v end)
    AddToggle("NPC ESP (Sari)", true, function(v) Settings.NPCs = v end)
    AddToggle("Kutular", true, function(v) Settings.Boxes = v end)
    AddToggle("Isimler", true, function(v) Settings.Names = v end)
    AddToggle("Can Bari", true, function(v) Settings.Health = v end)
    AddToggle("Cizgiler", true, function(v) Settings.Tracers = v end)
    AddToggle("Mesafe", true, function(v) Settings.Distance = v end)
    
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Y + 5)
end

-- /////////////// DOKUNMATIK HIZLI BUTONLAR (SOL ALT) ///////////////
local function CreateTouchButtons()
    local TouchGui = Instance.new("ScreenGui", CoreGui)
    TouchGui.Name = "ESP_TouchButtons"
    TouchGui.ResetOnSpawn = false
    TouchGui.IgnoreGuiInset = true
    TouchGui.DisplayOrder = 999
    
    -- Arka plan çerçevesi
    local BG = Instance.new("Frame", TouchGui)
    BG.Size = UDim2.new(0, 220, 0, 55)
    BG.Position = UDim2.new(0, 10, 1, -65)
    BG.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    BG.BackgroundTransparency = 0.4
    BG.BorderSizePixel = 0
    BG.Active = true
    BG.Draggable = true
    
    local function CreateButton(Text, XPos, Default, Callback)
        local Btn = Instance.new("TextButton", BG)
        Btn.Size = UDim2.new(0, 50, 0, 45)
        Btn.Position = UDim2.new(0, XPos, 0, 5)
        Btn.BackgroundColor3 = Default and Color3.fromRGB(0, 140, 0) or Color3.fromRGB(140, 0, 0)
        Btn.BorderSizePixel = 0
        Btn.Text = Text
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 11
        Btn.AutoButtonColor = false
        
        local State = Default
        Btn.MouseButton1Click:Connect(function()
            State = not State
            Btn.BackgroundColor3 = State and Color3.fromRGB(0, 140, 0) or Color3.fromRGB(140, 0, 0)
            Callback(State)
        end)
        -- Dokunmatik için
        Btn.TouchTap:Connect(function()
            State = not State
            Btn.BackgroundColor3 = State and Color3.fromRGB(0, 140, 0) or Color3.fromRGB(140, 0, 0)
            Callback(State)
        end)
        return Btn
    end
    
    -- Buton 1: UZAKLIK
    CreateButton("UZAKLIK", 5, true, function(v) Settings.Distance = v end)
    -- Buton 2: CHARM (Can barı)
    CreateButton("CAN", 60, true, function(v) Settings.Health = v end)
    -- Buton 3: ISIM
    CreateButton("ISIM", 115, true, function(v) Settings.Names = v end)
    -- Buton 4: ESP AÇ/KAPA
    CreateButton("ESP", 170, true, function(v) Settings.Master = v end)
    
    -- Başlık
    local TitleLabel = Instance.new("TextLabel", BG)
    TitleLabel.Size = UDim2.new(1, 0, 0, 14)
    TitleLabel.Position = UDim2.new(0, 0, 1, -2)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "HIZLI KONTROL | SURUKLENEBILIR"
    TitleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    TitleLabel.Font = Enum.Font.Gotham
    TitleLabel.TextSize = 9
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
end

-- /////////////// ESP FONKSİYONU ///////////////
local function CreateESP(Target)
    local Char = Target.Character
    if not Char then return end
    local Root = Char:FindFirstChild("HumanoidRootPart")
    local Head = Char:FindFirstChild("Head")
    local Hum = Char:FindFirstChild("Humanoid")
    if not Root or not Head or not Hum then return end
    
    if ESP_List[Target] then
        for _, v in pairs(ESP_List[Target]) do
            if v and v.Remove then v:Remove() end
        end
    end
    ESP_List[Target] = {}
    local Obj = ESP_List[Target]
    
    if Drawing then
        Obj.Box = Drawing.new("Square")
        Obj.Box.Thickness = 1
        Obj.Box.Filled = false
        Obj.Box.Visible = false
        
        Obj.Name = Drawing.new("Text")
        Obj.Name.Size = 13
        Obj.Name.Center = true
        Obj.Name.Outline = true
        Obj.Name.Visible = false
        
        Obj.HPbg = Drawing.new("Square")
        Obj.HPbg.Filled = true
        Obj.HPbg.Visible = false
        
        Obj.HP = Drawing.new("Square")
        Obj.HP.Filled = true
        Obj.HP.Visible = false
        
        Obj.Tracer = Drawing.new("Line")
        Obj.Tracer.Thickness = 1
        Obj.Tracer.Visible = false
    end
    
    local IsNPC = false
    pcall(function()
        IsNPC = not Players:GetPlayerFromCharacter(Char)
    end)
    
    local Conn
    Conn = RunService.RenderStepped:Connect(function()
        if not Settings.Master then
            for _, v in pairs(Obj) do if v then v.Visible = false end end
            return
        end
        if IsNPC and not Settings.NPCs then
            for _, v in pairs(Obj) do if v then v.Visible = false end end
            return
        end
        if not IsNPC and not Settings.Players then
            for _, v in pairs(Obj) do if v then v.Visible = false end end
            return
        end
        if not Char or not Char.Parent or not Root or not Root.Parent then
            Conn:Disconnect()
            for _, v in pairs(Obj) do if v and v.Remove then v:Remove() end end
            ESP_List[Target] = nil
            return
        end
        
        local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
        if not OnScreen then
            for _, v in pairs(Obj) do if v then v.Visible = false end end
            return
        end
        
        local Dist = (Camera.CFrame.Position - Root.Position).Magnitude
        local Scale = 1000 / Dist
        local H = math.abs((Head.Position.Y - Root.Position.Y) * 2.5) * Scale
        local W = H / 2
        
        if Settings.Boxes and Obj.Box then
            Obj.Box.Position = Vector2.new(Pos.X - W/2, Pos.Y - H/2)
            Obj.Box.Size = Vector2.new(W, H)
            Obj.Box.Color = IsNPC and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 255, 255)
            Obj.Box.Visible = true
        elseif Obj.Box then
            Obj.Box.Visible = false
        end
        
        if Settings.Names and Obj.Name then
            local Txt = Target.Name
            if Settings.Distance then Txt = Txt .. " [" .. math.floor(Dist) .. "m]" end
            Obj.Name.Text = Txt
            Obj.Name.Position = Vector2.new(Pos.X, Pos.Y - H/2 - 15)
            Obj.Name.Color = IsNPC and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 255, 255)
            Obj.Name.Visible = true
        elseif Obj.Name then
            Obj.Name.Visible = false
        end
        
        if Settings.Health and Obj.HP and not IsNPC then
            local HP = Hum.Health / Hum.MaxHealth
            local BH = H * HP
            Obj.HPbg.Position = Vector2.new(Pos.X - W/2 - 6, Pos.Y - H/2)
            Obj.HPbg.Size = Vector2.new(3, H)
            Obj.HPbg.Color = Color3.new(0, 0, 0)
            Obj.HPbg.Visible = true
            Obj.HP.Position = Vector2.new(Pos.X - W/2 - 6, Pos.Y + H/2 - BH)
            Obj.HP.Size = Vector2.new(3, BH)
            Obj.HP.Color = Color3.new(1 - HP, HP, 0)
            Obj.HP.Visible = true
        elseif Obj.HP then
            Obj.HP.Visible = false
            Obj.HPbg.Visible = false
        end
        
        if Settings.Tracers and Obj.Tracer and not IsNPC then
            Obj.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            Obj.Tracer.To = Vector2.new(Pos.X, Pos.Y + H/2)
            Obj.Tracer.Color = Color3.fromRGB(255, 255, 255)
            Obj.Tracer.Visible = true
        elseif Obj.Tracer then
            Obj.Tracer.Visible = false
        end
    end)
end

-- /////////////// OYUNCU TAKİBİ ///////////////
local function AddPlayer(Plr)
    if Plr == LocalPlayer then return end
    Plr.CharacterAdded:Connect(function()
        task.wait(0.3)
        CreateESP(Plr)
    end)
    if Plr.Character then CreateESP(Plr) end
end

for _, p in ipairs(Players:GetPlayers()) do AddPlayer(p) end
Players.PlayerAdded:Connect(AddPlayer)
Players.PlayerRemoving:Connect(function(p)
    if ESP_List[p] then
        for _, v in pairs(ESP_List[p]) do if v and v.Remove then v:Remove() end end
        ESP_List[p] = nil
    end
end)

-- /////////////// NPC TAKİBİ ///////////////
task.spawn(function()
    while task.wait(2) do
        if not Settings.Master or not Settings.NPCs then continue end
        for _, Obj in ipairs(workspace:GetDescendants()) do
            if Obj:IsA("Model") and Obj:FindFirstChild("Humanoid") and Obj:FindFirstChild("Head") then
                local IsPlr = false
                pcall(function() IsPlr = Players:GetPlayerFromCharacter(Obj) ~= nil end)
                if not IsPlr and not ESP_List[Obj] then
                    local Fake = {Name = Obj.Name, Character = Obj}
                    CreateESP(Fake)
                end
            end
        end
    end
end)

-- /////////////// RESPAWN TEMİZLİK ///////////////
LocalPlayer.CharacterAdded:Connect(function()
    for Target, Objs in pairs(ESP_List) do
        if typeof(Target) == "Instance" and not Target:IsA("Player") then
            for _, v in pairs(Objs) do if v and v.Remove then v:Remove() end end
            ESP_List[Target] = nil
        end
    end
end)

-- /////////////// BAŞLAT ///////////////
CreateMainGUI()
CreateTouchButtons()
print("ESP Yuklendi | Uzaklik/Charm/Isim Dokunmatik Butonlari Sol Altta | Panel Sag Ustte")
