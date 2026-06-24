local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

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
    Aimbot_FOVRadius = 120,
    Aimbot_Smoothness = 4,
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

local function GetClosestPlayer(FOVRadius, TeamCheck, VisibleCheck)
    local Closest = nil
    local ClosestDist = FOVRadius or math.huge
    local MousePos = UserInputService:GetMouseLocation()
    for _, Plr in ipairs(Players:GetPlayers()) do
        if Plr == LocalPlayer then continue end
        if TeamCheck and Plr.Team == LocalPlayer.Team then continue end
        local Char = Plr.Character
        if not Char then continue end
        local TargetPart = Char:FindFirstChild(Settings.Aimbot_TargetPart) or Char:FindFirstChild("Head")
        if not TargetPart then continue end
        if VisibleCheck and not IsVisible(TargetPart) then continue end
        local SPos, OnScreen = Camera:WorldToViewportPoint(TargetPart.Position)
        if not OnScreen then continue end
        local Dist = (Vector2.new(SPos.X, SPos.Y) - MousePos).Magnitude
        if Dist < ClosestDist then
            ClosestDist = Dist
            Closest = Plr
        end
    end
    return Closest
end

-- /////////////// GUI - 3 SEKME ///////////////
local function CreateGUI()
    local SG = Instance.new("ScreenGui", CoreGui)
    SG.Name = "GINS_Panel"
    SG.ResetOnSpawn = false
    SG.IgnoreGuiInset = true

    local Main = Instance.new("Frame", SG)
    Main.Size = UDim2.new(0, 210, 0, 310)
    Main.Position = UDim2.new(1, -220, 0.25, 0)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true

    -- Başlık
    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 26)
    Title.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    Title.BorderSizePixel = 0
    Title.Text = "GINS v2.0"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 12

    -- Sekme butonları
    local TabFrame = Instance.new("Frame", Main)
    TabFrame.Size = UDim2.new(1, 0, 0, 24)
    TabFrame.Position = UDim2.new(0, 0, 0, 26)
    TabFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    TabFrame.BorderSizePixel = 0

    local Tabs = {}
    local Pages = {}
    local CurrentTab = "ESP"

    local function CreateTab(Name)
        local Btn = Instance.new("TextButton", TabFrame)
        Btn.Size = UDim2.new(1/3, -2, 1, 0)
        Btn.Position = UDim2.new(#Tabs/3, 1, 0, 0)
        Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        Btn.BorderSizePixel = 0
        Btn.Text = Name
        Btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 10
        Btn.AutoButtonColor = false

        local Page = Instance.new("ScrollingFrame", Main)
        Page.Size = UDim2.new(1, -6, 1, -55)
        Page.Position = UDim2.new(0, 3, 0, 53)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 3
        Page.CanvasSize = UDim2.new(0, 0, 0, 300)
        Page.Visible = false

        Btn.MouseButton1Click:Connect(function()
            CurrentTab = Name
            for _, t in ipairs(Tabs) do t.BackgroundColor3 = Color3.fromRGB(28, 28, 28) end
            Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            for _, p in ipairs(Pages) do p.Visible = false end
            Page.Visible = true
        end)

        table.insert(Tabs, Btn)
        table.insert(Pages, Page)
        return Page, Btn
    end

    local ESP_Page, ESP_Btn = CreateTab("ESP")
    local AIM_Page, AIM_Btn = CreateTab("AIMBOT")
    local SIL_Page, SIL_Btn = CreateTab("SILENT")

    -- Varsayılan sekme
    ESP_Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    ESP_Page.Visible = true

    -- Toggle ekleme fonksiyonu
    local function AddToggle(Page, Name, Default, Callback, YRef)
        local Y = YRef[1]
        local Frame = Instance.new("Frame", Page)
        Frame.Size = UDim2.new(1, 0, 0, 22)
        Frame.Position = UDim2.new(0, 0, 0, Y)
        Frame.BackgroundTransparency = 1

        local Lbl = Instance.new("TextLabel", Frame)
        Lbl.Size = UDim2.new(0.62, 0, 1, 0)
        Lbl.BackgroundTransparency = 1
        Lbl.Text = Name
        Lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
        Lbl.Font = Enum.Font.Gotham
        Lbl.TextSize = 10
        Lbl.TextXAlignment = Enum.TextXAlignment.Left

        local Btn = Instance.new("TextButton", Frame)
        Btn.Size = UDim2.new(0, 26, 0, 16)
        Btn.Position = UDim2.new(1, -30, 0, 2)
        Btn.BorderSizePixel = 0
        Btn.Text = ""
        Btn.BackgroundColor3 = Default and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)

        local State = Default
        Btn.MouseButton1Click:Connect(function()
            State = not State
            Btn.BackgroundColor3 = State and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
            Callback(State)
        end)
        YRef[1] = Y + 23
    end

    -- === ESP TOGGLE'LARI ===
    local EY = {0}
    AddToggle(ESP_Page, "ESP Acik", true, function(v) Settings.ESP_Master = v end, EY)
    AddToggle(ESP_Page, "Kutular", true, function(v) Settings.ESP_Boxes = v end, EY)
    AddToggle(ESP_Page, "Isimler", true, function(v) Settings.ESP_Names = v end, EY)
    AddToggle(ESP_Page, "Can Bari", true, function(v) Settings.ESP_Health = v end, EY)
    AddToggle(ESP_Page, "Cizgiler", true, function(v) Settings.ESP_Tracers = v end, EY)
    AddToggle(ESP_Page, "Mesafe", true, function(v) Settings.ESP_Distance = v end, EY)
    AddToggle(ESP_Page, "Chams", true, function(v) Settings.ESP_Chams = v end, EY)
    ESP_Page.CanvasSize = UDim2.new(0, 0, 0, EY[1] + 5)

    -- === AIMBOT TOGGLE'LARI ===
    local AY = {0}
    AddToggle(AIM_Page, "Aimbot Acik", false, function(v) Settings.Aimbot_Master = v end, AY)
    AddToggle(AIM_Page, "Takim Kontrol", false, function(v) Settings.Aimbot_TeamCheck = v end, AY)
    AddToggle(AIM_Page, "Gorunurluk", true, function(v) Settings.Aimbot_VisibleCheck = v end, AY)
    AIM_Page.CanvasSize = UDim2.new(0, 0, 0, AY[1] + 5)

    -- === SILENT AIM TOGGLE'LARI ===
    local SY = {0}
    AddToggle(SIL_Page, "Silent Acik", false, function(v) Settings.Silent_Master = v end, SY)
    AddToggle(SIL_Page, "Takim Kontrol", false, function(v) Settings.Silent_TeamCheck = v end, SY)
    AddToggle(SIL_Page, "Gorunurluk", true, function(v) Settings.Silent_VisibleCheck = v end, SY)
    SIL_Page.CanvasSize = UDim2.new(0, 0, 0, SY[1] + 5)

    print("GINS GUI: 3 Sekme Hazir")
end

-- /////////////// CHAMS (TAŞMA DÜZELTİLDİ) ///////////////
local function ApplyChams(Plr, Char)
    -- Öncekini temizle
    if Chams_List[Plr] and Chams_List[Plr].Remove then
        Chams_List[Plr]:Remove()
        Chams_List[Plr] = nil
    end
    if not Settings.ESP_Chams or not Settings.ESP_Master then return end
    
    -- SADECE karakter modeline Highlight ekle (alt parçalara değil)
    local Highlight = Instance.new("Highlight")
    Highlight.Name = "GINS_Chams"
    Highlight.FillColor = Settings.ESP_ChamsColor
    Highlight.FillTransparency = 0.5
    Highlight.OutlineColor = Settings.ESP_ChamsColor
    Highlight.OutlineTransparency = 0
    -- DepthMode KALDIRILDI - sadece görünen yüzeyleri boyar, taşma yapmaz
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
        Obj.Nam = Drawing.new("Text")
        Obj.Nam.Size = 13
        Obj.Nam.Center = true
        Obj.Nam.Outline = true
        Obj.Nam.Color = Color3.fromRGB(255, 255, 255)
        Obj.Nam.Visible = false
        Obj.HBg = Drawing.new("Square")
        Obj.HBg.Filled = true
        Obj.HBg.Color = Color3.new(0, 0, 0)
        Obj.HBg.Visible = false
        Obj.HP = Drawing.new("Square")
        Obj.HP.Filled = true
        Obj.HP.Visible = false
        Obj.Tr = Drawing.new("Line")
        Obj.Tr.Thickness = 1
        Obj.Tr.Color = Color3.fromRGB(255, 255, 255)
        Obj.Tr.Visible = false
    end

    local Conn
    Conn = RunService.RenderStepped:Connect(function()
        if not Settings.ESP_Master then
            for _, v in pairs(Obj) do if v and v.Visible ~= nil then v.Visible = false end end
            if Chams_List[Plr] and Chams_List[Plr].Remove then Chams_List[Plr]:Remove() Chams_List[Plr] = nil end
            return
        end

        if Settings.ESP_Chams and not Chams_List[Plr] then
            ApplyChams(Plr, Char)
        elseif not Settings.ESP_Chams and Chams_List[Plr] and Chams_List[Plr].Remove then
            Chams_List[Plr]:Remove()
            Chams_List[Plr] = nil
        end

        if not Char or not Char.Parent or not Root or not Root.Parent then
            Conn:Disconnect() ClearESP(Plr) return
        end

        local Pos, On = Camera:WorldToViewportPoint(Root.Position)
        if not On then
            for _, v in pairs(Obj) do if v and v.Visible ~= nil then v.Visible = false end end
            return
        end

        local Dist = (Camera.CFrame.Position - Root.Position).Magnitude
        local S = 1000 / Dist
        local H = math.abs((Head.Position.Y - Root.Position.Y) * 2.5) * S
        local W = H / 2

        if Settings.ESP_Boxes and Obj.Box then
            Obj.Box.Position = Vector2.new(Pos.X - W/2, Pos.Y - H/2)
            Obj.Box.Size = Vector2.new(W, H)
            Obj.Box.Visible = true
        elseif Obj.Box then Obj.Box.Visible = false end

        if Settings.ESP_Names and Obj.Nam then
            local T = Plr.Name
            if Settings.ESP_Distance then T = T .. " [" .. math.floor(Dist) .. "m]" end
            Obj.Nam.Text = T
            Obj.Nam.Position = Vector2.new(Pos.X, Pos.Y - H/2 - 15)
            Obj.Nam.Visible = true
        elseif Obj.Nam then Obj.Nam.Visible = false end

        if Settings.ESP_Health and Obj.HP then
            local HP = Hum.Health / Hum.MaxHealth
            local BH = H * HP
            Obj.HBg.Position = Vector2.new(Pos.X - W/2 - 6, Pos.Y - H/2)
            Obj.HBg.Size = Vector2.new(3, H)
            Obj.HBg.Visible = true
            Obj.HP.Position = Vector2.new(Pos.X - W/2 - 6, Pos.Y + H/2 - BH)
            Obj.HP.Size = Vector2.new(3, BH)
            Obj.HP.Color = Color3.new(1 - HP, HP, 0)
            Obj.HP.Visible = true
        elseif Obj.HP then Obj.HP.Visible = false Obj.HBg.Visible = false end

        if Settings.ESP_Tracers and Obj.Tr then
            Obj.Tr.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            Obj.Tr.To = Vector2.new(Pos.X, Pos.Y + H/2)
            Obj.Tr.Visible = true
        elseif Obj.Tr then Obj.Tr.Visible = false end
    end)
end

-- /////////////// FOV DAİRESİ ///////////////
local function UpdateFOV()
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
    UpdateFOV()
    if not Settings.Aimbot_Master then
        if FOV_Circle and Settings.Silent_Master then
            FOV_Circle.Radius = Settings.Silent_FOVRadius
        elseif FOV_Circle then
            FOV_Circle:Remove() FOV_Circle = nil
        end
        return
    end
    local Target = GetClosestPlayer(Settings.Aimbot_FOVRadius, Settings.Aimbot_TeamCheck, Settings.Aimbot_VisibleCheck)
    if Target and Target.Character then
        local TP = Target.Character:FindFirstChild(Settings.Aimbot_TargetPart) or Target.Character:FindFirstChild("Head")
        if TP then
            local TPos = Camera:WorldToViewportPoint(TP.Position)
            local MPos = UserInputService:GetMouseLocation()
            local Sm = Settings.Aimbot_Smoothness / 10
            mousemoverel((TPos.X - MPos.X) * Sm, (TPos.Y - MPos.Y) * Sm)
        end
    end
end)

-- /////////////// SILENT AIM ///////////////
local OldNC
OldNC = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if method == "FireServer" and self.Name == "RemoteEvent" and Settings.Silent_Master then
        local Target = GetClosestPlayer(Settings.Silent_FOVRadius, Settings.Silent_TeamCheck, Settings.Silent_VisibleCheck)
        if Target and Target.Character then
            local TP = Target.Character:FindFirstChild(Settings.Silent_TargetPart) or Target.Character:FindFirstChild("Head")
            if TP and math.random(1, 100) <= Settings.Silent_HitChance then
                if args[1] and typeof(args[1]) == "table" and args[1].Position then
                    args[1] = TP
                end
            end
        end
    end
    return OldNC(self, unpack(args))
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

-- Chams renk güncelleme
task.spawn(function()
    while task.wait(0.1) do
        for Plr, H in pairs(Chams_List) do
            if H and H.Parent then
                H.FillColor = Settings.ESP_ChamsColor
                H.OutlineColor = Settings.ESP_ChamsColor
                H.Enabled = Settings.ESP_Master and Settings.ESP_Chams
            end
        end
    end
end)

CreateGUI()
print("GINS v2.0 Aktif | ESP + Aimbot + Silent | 3 Sekme | Chams Tasmasiz")
