local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- /////////////// AYARLAR ///////////////
local Settings = {
    -- ESP
    ESP_Master = true,
    ESP_Boxes = true,
    ESP_Names = true,
    ESP_Health = true,
    ESP_Tracers = true,
    ESP_Distance = true,
    ESP_Chams = true,
    ESP_ChamsColor = Color3.fromRGB(255, 0, 0),
    -- AIMBOT
    Aimbot_Master = false,
    Aimbot_TeamCheck = false,
    Aimbot_VisibleCheck = true,
    Aimbot_FOVRadius = 100,
    Aimbot_Smoothness = 5,
    Aimbot_TargetPart = "Head",
    -- SILENT AIM
    Silent_Master = false,
    Silent_TeamCheck = false,
    Silent_VisibleCheck = true,
    Silent_TargetPart = "Head",
    Silent_FOVRadius = 150,
    Silent_HitChance = 100
}

-- /////////////// VERİ DEPOSU ///////////////
local ESP_Folder = Instance.new("Folder", CoreGui)
ESP_Folder.Name = "GINS_System"
local ESP_List = {}
local Chams_List = {}
local FOV_Circle = nil

-- /////////////// YARDIMCI FONKSİYONLAR ///////////////
local function IsVisible(TargetPart)
    if not TargetPart then return false end
    local Origin = Camera.CFrame.Position
    local Direction = (TargetPart.Position - Origin).Unit * 500
    local RayParams = RaycastParams.new()
    RayParams.FilterType = Enum.RaycastFilterType.Blacklist
    RayParams.FilterDescendantsInstances = {LocalPlayer.Character, TargetPart.Parent}
    local RayResult = workspace:Raycast(Origin, Direction, RayParams)
    return RayResult == nil
end

local function GetClosestPlayerToCursor(FOVRadius, TeamCheck, VisibleCheck)
    local ClosestPlayer = nil
    local ClosestDistance = FOVRadius or math.huge
    local MousePos = UserInputService:GetMouseLocation()
    
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player == LocalPlayer then continue end
        if TeamCheck and Player.Team == LocalPlayer.Team then continue end
        local Char = Player.Character
        if not Char then continue end
        local TargetPart = Char:FindFirstChild(Settings.Aimbot_TargetPart) or Char:FindFirstChild("Head")
        if not TargetPart then continue end
        if VisibleCheck and not IsVisible(TargetPart) then continue end
        
        local ScreenPos, OnScreen = Camera:WorldToViewportPoint(TargetPart.Position)
        if not OnScreen then continue end
        
        local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MousePos).Magnitude
        if Distance < ClosestDistance then
            ClosestDistance = Distance
            ClosestPlayer = Player
        end
    end
    return ClosestPlayer
end

-- /////////////// GUI ///////////////
local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "GINS_Panel"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    
    -- Ana çerçeve
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 220, 0, 420)
    Main.Position = UDim2.new(1, -230, 0.2, 0)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.ClipsDescendants = true
    
    -- Başlık
    local Title = Instance.new("Frame", Main)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Title.BorderSizePixel = 0
    local TitleText = Instance.new("TextLabel", Title)
    TitleText.Size = UDim2.new(1, 0, 1, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "GINS | ESP | AIMBOT | SILENT"
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextSize = 11
    TitleText.TextXAlignment = Enum.TextXAlignment.Center
    
    -- Sekme butonları
    local TabHolder = Instance.new("Frame", Main)
    TabHolder.Size = UDim2.new(1, 0, 0, 25)
    TabHolder.Position = UDim2.new(0, 0, 0, 30)
    TabHolder.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TabHolder.BorderSizePixel = 0
    
    local CurrentTab = "ESP"
    local TabButtons = {}
    local TabPages = {}
    
    local function CreateTab(TabName)
        local Btn = Instance.new("TextButton", TabHolder)
        Btn.Size = UDim2.new(1/3, -2, 1, 0)
        Btn.Position = UDim2.new((#TabButtons)/3, 1, 0, 0)
        Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Btn.BorderSizePixel = 0
        Btn.Text = TabName
        Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 11
        
        local Page = Instance.new("ScrollingFrame", Main)
        Page.Size = UDim2.new(1, -8, 1, -60)
        Page.Position = UDim2.new(0, 4, 0, 58)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 4
        Page.CanvasSize = UDim2.new(0, 0, 0, 500)
        Page.Visible = false
        
        Btn.MouseButton1Click:Connect(function()
            CurrentTab = TabName
            for _, t in pairs(TabButtons) do t.BackgroundColor3 = Color3.fromRGB(30, 30, 30) end
            Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            for _, p in pairs(TabPages) do p.Visible = false end
            Page.Visible = true
        end)
        
        table.insert(TabButtons, Btn)
        table.insert(TabPages, Page)
        return Page
    end
    
    local ESP_Page = CreateTab("ESP")
    local Aimbot_Page = CreateTab("AIMBOT")
    local Silent_Page = CreateTab("SILENT")
    
    -- Varsayılan olarak ESP sekmesini göster
    TabButtons[1].BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    TabPages[1].Visible = true
    
    -- Toggle ekleme fonksiyonu
    local function AddToggle(Page, Text, Default, Callback, YRef)
        local Y = YRef[1]
        local Frame = Instance.new("Frame", Page)
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
        YRef[1] = Y + 25
        return Toggle
    end
    
    -- ESP Sekmesi Toggle'ları
    local ESP_Y = {0}
    AddToggle(ESP_Page, "ESP Acik/Kapali", true, function(v) Settings.ESP_Master = v end, ESP_Y)
    AddToggle(ESP_Page, "Kutular", true, function(v) Settings.ESP_Boxes = v end, ESP_Y)
    AddToggle(ESP_Page, "Isimler", true, function(v) Settings.ESP_Names = v end, ESP_Y)
    AddToggle(ESP_Page, "Can Bari", true, function(v) Settings.ESP_Health = v end, ESP_Y)
    AddToggle(ESP_Page, "Cizgiler", true, function(v) Settings.ESP_Tracers = v end, ESP_Y)
    AddToggle(ESP_Page, "Mesafe", true, function(v) Settings.ESP_Distance = v end, ESP_Y)
    AddToggle(ESP_Page, "CHAMS (Model Boya)", true, function(v) Settings.ESP_Chams = v end, ESP_Y)
    ESP_Page.CanvasSize = UDim2.new(0, 0, 0, ESP_Y[1] + 5)
    
    -- Aimbot Sekmesi Toggle'ları
    local Aim_Y = {0}
    AddToggle(Aimbot_Page, "Aimbot Acik/Kapali", false, function(v) Settings.Aimbot_Master = v end, Aim_Y)
    AddToggle(Aimbot_Page, "Takim Kontrolu", false, function(v) Settings.Aimbot_TeamCheck = v end, Aim_Y)
    AddToggle(Aimbot_Page, "Gorunurluk Kontrolu", true, function(v) Settings.Aimbot_VisibleCheck = v end, Aim_Y)
    Aimbot_Page.CanvasSize = UDim2.new(0, 0, 0, Aim_Y[1] + 5)
    
    -- Silent Sekmesi Toggle'ları
    local Silent_Y = {0}
    AddToggle(Silent_Page, "Silent Aim Acik/Kapali", false, function(v) Settings.Silent_Master = v end, Silent_Y)
    AddToggle(Silent_Page, "Takim Kontrolu", false, function(v) Settings.Silent_TeamCheck = v end, Silent_Y)
    AddToggle(Silent_Page, "Gorunurluk Kontrolu", true, function(v) Settings.Silent_VisibleCheck = v end, Silent_Y)
    Silent_Page.CanvasSize = UDim2.new(0, 0, 0, Silent_Y[1] + 5)
end

-- /////////////// CHAMS (Highlight) ///////////////
local function ApplyChams(Plr, Char)
    if Chams_List[Plr] and Chams_List[Plr].Remove then
        Chams_List[Plr]:Remove()
        Chams_List[Plr] = nil
    end
    if not Settings.ESP_Chams or not Settings.ESP_Master then return end
    local Highlight = Instance.new("Highlight")
    Highlight.Name = "GINS_Chams"
    Highlight.FillColor = Settings.ESP_ChamsColor
    Highlight.FillTransparency = 0.4
    Highlight.OutlineColor = Settings.ESP_ChamsColor
    Highlight.OutlineTransparency = 0
    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    Highlight.Parent = Char
    Chams_List[Plr] = Highlight
end

-- /////////////// ESP TEMİZLİK ///////////////
local function ClearESP(Plr)
    if ESP_List[Plr] then
        for _, v in pairs(ESP_List[Plr]) do
            if v and v.Remove then v:Remove() end
        end
        ESP_List[Plr] = nil
    end
    if Chams_List[Plr] and Chams_List[Plr].Remove then
        Chams_List[Plr]:Remove()
        Chams_List[Plr] = nil
    end
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
    
    ApplyChams(Plr, Char)
    
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
        if not Settings.ESP_Master then
            for _, v in pairs(Obj) do if v and v.Visible ~= nil then v.Visible = false end end
            if Chams_List[Plr] and Chams_List[Plr].Remove then
                Chams_List[Plr]:Remove()
                Chams_List[Plr] = nil
            end
            return
        end
        
        if Settings.ESP_Chams and not Chams_List[Plr] then
            ApplyChams(Plr, Char)
        elseif not Settings.ESP_Chams and Chams_List[Plr] and Chams_List[Plr].Remove then
            Chams_List[Plr]:Remove()
            Chams_List[Plr] = nil
        end
        
        if not Char or not Char.Parent or not Root or not Root.Parent then
            Conn:Disconnect()
            ClearESP(Plr)
            return
        end
        
        local RootPos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
        if not OnScreen then
            for _, v in pairs(Obj) do if v and v.Visible ~= nil then v.Visible = false end end
            return
        end
        
        local Dist = (Camera.CFrame.Position - Root.Position).Magnitude
        local Scale = 1000 / Dist
        local H = math.abs((Head.Position.Y - Root.Position.Y) * 2.5) * Scale
        local W = H / 2
        
        if Settings.ESP_Boxes and Obj.Box then
            Obj.Box.Position = Vector2.new(RootPos.X - W/2, RootPos.Y - H/2)
            Obj.Box.Size = Vector2.new(W, H)
            Obj.Box.Visible = true
        elseif Obj.Box then Obj.Box.Visible = false end
        
        if Settings.ESP_Names and Obj.Name then
            local Txt = Plr.Name
            if Settings.ESP_Distance then Txt = Txt .. " [" .. math.floor(Dist) .. "m]" end
            Obj.Name.Text = Txt
            Obj.Name.Position = Vector2.new(RootPos.X, RootPos.Y - H/2 - 15)
            Obj.Name.Visible = true
        elseif Obj.Name then Obj.Name.Visible = false end
        
        if Settings.ESP_Health and Obj.HP then
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
        
        if Settings.ESP_Tracers and Obj.Tracer then
            Obj.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            Obj.Tracer.To = Vector2.new(RootPos.X, RootPos.Y + H/2)
            Obj.Tracer.Visible = true
        elseif Obj.Tracer then Obj.Tracer.Visible = false end
    end)
end

-- /////////////// FOV DAİRESİ ///////////////
local function UpdateFOVCircle()
    if FOV_Circle then FOV_Circle:Remove() FOV_Circle = nil end
    if not Drawing then return end
    if Settings.Aimbot_Master or Settings.Silent_Master then
        FOV_Circle = Drawing.new("Circle")
        FOV_Circle.Thickness = 1
        FOV_Circle.Filled = false
        FOV_Circle.Color = Color3.fromRGB(255, 255, 255)
        FOV_Circle.Radius = Settings.Aimbot_Master and Settings.Aimbot_FOVRadius or Settings.Silent_FOVRadius
        FOV_Circle.Position = UserInputService:GetMouseLocation()
        FOV_Circle.Visible = true
    end
end

-- /////////////// AIMBOT ///////////////
RunService.RenderStepped:Connect(function()
    UpdateFOVCircle()
    if not Settings.Aimbot_Master then
        if FOV_Circle and Settings.Silent_Master then
            FOV_Circle.Radius = Settings.Silent_FOVRadius
        elseif FOV_Circle then
            FOV_Circle:Remove()
            FOV_Circle = nil
        end
        return
    end
    if FOV_Circle then FOV_Circle.Radius = Settings.Aimbot_FOVRadius end
    
    local Target = GetClosestPlayerToCursor(Settings.Aimbot_FOVRadius, Settings.Aimbot_TeamCheck, Settings.Aimbot_VisibleCheck)
    if Target and Target.Character then
        local TargetPart = Target.Character:FindFirstChild(Settings.Aimbot_TargetPart) or Target.Character:FindFirstChild("Head")
        if TargetPart then
            local TargetPos = Camera:WorldToViewportPoint(TargetPart.Position)
            local MousePos = UserInputService:GetMouseLocation()
            local Smoothness = Settings.Aimbot_Smoothness / 10
            local NewX = MousePos.X + (TargetPos.X - MousePos.X) * Smoothness
            local NewY = MousePos.Y + (TargetPos.Y - MousePos.Y) * Smoothness
            mousemoverel(NewX - MousePos.X, NewY - MousePos.Y)
        end
    end
end)

-- /////////////// SILENT AIM ///////////////
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if method == "FireServer" and self.Name == "RemoteEvent" and Settings.Silent_Master then
        local Target = GetClosestPlayerToCursor(Settings.Silent_FOVRadius, Settings.Silent_TeamCheck, Settings.Silent_VisibleCheck)
        if Target and Target.Character then
            local TargetPart = Target.Character:FindFirstChild(Settings.Silent_TargetPart) or Target.Character:FindFirstChild("Head")
            if TargetPart and math.random(1, 100) <= Settings.Silent_HitChance then
                -- Sessiz hedef değiştirme (oyun motoruna göre değişir, temel yapı)
                if args[1] and typeof(args[1]) == "table" and args[1].Position then
                    args[1] = TargetPart
                end
            end
        end
    end
    return OldNamecall(self, unpack(args))
end)

-- /////////////// OYUNCU TAKİBİ ///////////////
local function AddPlayer(Plr)
    if Plr == LocalPlayer then return end
    Plr.CharacterAdded:Connect(function(Char)
        task.wait(0.3)
        CreateESP(Plr)
        if Settings.ESP_Chams and Settings.ESP_Master then ApplyChams(Plr, Char) end
    end)
    if Plr.Character then CreateESP(Plr) end
end

for _, p in ipairs(Players:GetPlayers()) do AddPlayer(p) end
Players.PlayerAdded:Connect(AddPlayer)
Players.PlayerRemoving:Connect(ClearESP)

LocalPlayer.CharacterAdded:Connect(function()
    for Plr, _ in pairs(ESP_List) do ClearESP(Plr) end
    for Plr, _ in pairs(Chams_List) do ClearESP(Plr) end
end)

task.spawn(function()
    while task.wait(0.1) do
        for Plr, Highlight in pairs(Chams_List) do
            if Highlight and Highlight.Parent then
                Highlight.FillColor = Settings.ESP_ChamsColor
                Highlight.OutlineColor = Settings.ESP_ChamsColor
                Highlight.Enabled = Settings.ESP_Master and Settings.ESP_Chams
            end
        end
    end
end)

-- /////////////// BAŞLAT ///////////////
CreateGUI()
print("GINS v1.0 Yuklendi | ESP + AIMBOT + SILENT AIM | 3 Sekmeli Panel")
