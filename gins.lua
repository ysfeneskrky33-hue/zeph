local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    ESP_Master = true,
    ESP_Boxes = true,
    ESP_Names = true,
    ESP_Health = true,
    ESP_Tracers = true,
    ESP_Distance = true,
    ESP_Chams = true,
    ESP_ChamsColor = Color3.fromRGB(255, 0, 0)
}

local ESP_List = {}
local Chams_List = {}

local function CreateGUI()
    local SG = Instance.new("ScreenGui")
    SG.Name = "ESP_GUI"
    SG.Parent = CoreGui
    SG.ResetOnSpawn = false
    
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 200, 0, 220)
    Main.Position = UDim2.new(1, -210, 0.3, 0)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = SG
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 25)
    Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Title.BorderSizePixel = 0
    Title.Text = "ESP KONTROL"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 12
    Title.Parent = Main
    
    local Y = 30
    local function AddToggle(Text, Default, Callback)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 22)
        Frame.Position = UDim2.new(0, 8, 0, Y)
        Frame.BackgroundTransparency = 1
        Frame.Parent = Main
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.65, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = Text
        Label.TextColor3 = Color3.fromRGB(200, 200, 200)
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 11
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Frame
        
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(0, 26, 0, 16)
        Btn.Position = UDim2.new(1, -30, 0, 3)
        Btn.BorderSizePixel = 0
        Btn.Text = ""
        Btn.BackgroundColor3 = Default and Color3.fromRGB(0, 160, 0) or Color3.fromRGB(160, 0, 0)
        Btn.Parent = Frame
        
        local State = Default
        Btn.MouseButton1Click:Connect(function()
            State = not State
            Btn.BackgroundColor3 = State and Color3.fromRGB(0, 160, 0) or Color3.fromRGB(160, 0, 0)
            Callback(State)
        end)
        Y = Y + 24
    end
    
    AddToggle("ESP Acik/Kapali", true, function(v) Settings.ESP_Master = v end)
    AddToggle("Kutular", true, function(v) Settings.ESP_Boxes = v end)
    AddToggle("Isimler", true, function(v) Settings.ESP_Names = v end)
    AddToggle("Can Bari", true, function(v) Settings.ESP_Health = v end)
    AddToggle("Cizgiler", true, function(v) Settings.ESP_Tracers = v end)
    AddToggle("Mesafe", true, function(v) Settings.ESP_Distance = v end)
    AddToggle("CHAMS", true, function(v) Settings.ESP_Chams = v end)
    
    print("GUI Acildi - Sag Ust Kosede")
end

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

local function ApplyChams(Plr, Char)
    if Chams_List[Plr] and Chams_List[Plr].Remove then
        Chams_List[Plr]:Remove()
        Chams_List[Plr] = nil
    end
    if not Settings.ESP_Chams or not Settings.ESP_Master then return end
    local H = Instance.new("Highlight")
    H.FillColor = Settings.ESP_ChamsColor
    H.FillTransparency = 0.4
    H.OutlineColor = Settings.ESP_ChamsColor
    H.OutlineTransparency = 0
    H.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    H.Parent = Char
    Chams_List[Plr] = H
end

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
            if Chams_List[Plr] then Chams_List[Plr]:Remove() Chams_List[Plr] = nil end
            return
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
        if Settings.ESP_Names and Obj.Name then
            local T = Plr.Name
            if Settings.ESP_Distance then T = T .. " [" .. math.floor(Dist) .. "m]" end
            Obj.Name.Text = T
            Obj.Name.Position = Vector2.new(Pos.X, Pos.Y - H/2 - 15)
            Obj.Name.Visible = true
        elseif Obj.Name then Obj.Name.Visible = false end
        if Settings.ESP_Health and Obj.HP then
            local HP = Hum.Health / Hum.MaxHealth
            local BH = H * HP
            Obj.HPbg.Position = Vector2.new(Pos.X - W/2 - 6, Pos.Y - H/2)
            Obj.HPbg.Size = Vector2.new(3, H)
            Obj.HPbg.Visible = true
            Obj.HP.Position = Vector2.new(Pos.X - W/2 - 6, Pos.Y + H/2 - BH)
            Obj.HP.Size = Vector2.new(3, BH)
            Obj.HP.Color = Color3.new(1 - HP, HP, 0)
            Obj.HP.Visible = true
        elseif Obj.HP then Obj.HP.Visible = false Obj.HPbg.Visible = false end
        if Settings.ESP_Tracers and Obj.Tracer then
            Obj.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            Obj.Tracer.To = Vector2.new(Pos.X, Pos.Y + H/2)
            Obj.Tracer.Visible = true
        elseif Obj.Tracer then Obj.Tracer.Visible = false end
    end)
end

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
print("ESP Hazir - Test Basarili")
