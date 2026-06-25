-- SADECE ESP + AIMBOT + ADMIN - BASIT VE CALISIR
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local S = {
    ESP_On = true,
    AIM_On = false,
    AIM_FOV = 120,
    AIM_Smooth = 0.5,
    NoClip = false,
    Fly = false
}

local ESP_Data = {}
local FOV_Circle = nil
local RightMouseDown = false
local FlySpeed = 50

local function CreateFOVCircle()
    if FOV_Circle then FOV_Circle:Remove() end
    if not Drawing then return end
    FOV_Circle = Drawing.new("Circle")
    FOV_Circle.Radius = S.AIM_FOV
    FOV_Circle.Thickness = 1
    FOV_Circle.Color = Color3.fromRGB(0, 255, 255)
    FOV_Circle.Filled = false
    FOV_Circle.Visible = true
    FOV_Circle.Position = UserInputService:GetMouseLocation()
end

UserInputService.InputBegan:Connect(function(Input, GPE)
    if GPE then return end
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightMouseDown = true
        if FOV_Circle then FOV_Circle.Visible = true end
    end
end)

UserInputService.InputEnded:Connect(function(Input, GPE)
    if GPE then return end
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightMouseDown = false
        if FOV_Circle then FOV_Circle.Visible = false end
    end
end)

local function IsVisible(Part)
    if not Part then return false end
    local RP = RaycastParams.new()
    RP.FilterType = Enum.RaycastFilterType.Blacklist
    RP.FilterDescendantsInstances = {LocalPlayer.Character, Part.Parent}
    local Result = workspace:Raycast(Camera.CFrame.Position, (Part.Position - Camera.CFrame.Position).Unit * 500, RP)
    return Result == nil
end

local function GetTarget()
    local Best, BestDist = nil, S.AIM_FOV
    local MousePos = UserInputService:GetMouseLocation()
    for _, Plr in ipairs(Players:GetPlayers()) do
        if Plr == LocalPlayer then continue end
        local Char = Plr.Character
        if not Char then continue end
        local Part = Char:FindFirstChild("Head")
        if not Part then continue end
        if not IsVisible(Part) then continue end
        local SPos, On = Camera:WorldToViewportPoint(Part.Position)
        if not On then continue end
        local Dist = (Vector2.new(SPos.X, SPos.Y) - MousePos).Magnitude
        if Dist < BestDist then
            BestDist = Dist
            Best = Plr
        end
    end
    return Best
end

local function CreateESP(Plr)
    if Plr == LocalPlayer then return end
    local Char = Plr.Character
    if not Char then return end
    local Root = Char:FindFirstChild("HumanoidRootPart")
    local Head = Char:FindFirstChild("Head")
    local Hum = Char:FindFirstChild("Humanoid")
    if not Root or not Head or not Hum then return end
    
    if ESP_Data[Plr] then
        for _, v in pairs(ESP_Data[Plr]) do v:Remove() end
        ESP_Data[Plr] = nil
    end
    
    if not Drawing then return end
    
    local D = {}
    D.Box = Drawing.new("Square")
    D.Box.Thickness = 1
    D.Box.Filled = false
    D.Box.Color = Color3.new(1,1,1)
    D.Box.Visible = false
    
    D.Name = Drawing.new("Text")
    D.Name.Size = 13
    D.Name.Center = true
    D.Name.Outline = true
    D.Name.Color = Color3.new(1,1,1)
    D.Name.Visible = false
    
    D.HPbg = Drawing.new("Square")
    D.HPbg.Filled = true
    D.HPbg.Color = Color3.new(0,0,0)
    D.HPbg.Visible = false
    
    D.HP = Drawing.new("Square")
    D.HP.Filled = true
    D.HP.Visible = false
    
    D.Tracer = Drawing.new("Line")
    D.Tracer.Thickness = 1
    D.Tracer.Color = Color3.new(1,1,1)
    D.Tracer.Visible = false
    
    ESP_Data[Plr] = D
    
    local Conn
    Conn = RunService.RenderStepped:Connect(function()
        if not S.ESP_On then
            for _, v in pairs(D) do v.Visible = false end
            return
        end
        if not Char or not Char.Parent or not Root or not Root.Parent then
            Conn:Disconnect()
            for _, v in pairs(D) do v:Remove() end
            ESP_Data[Plr] = nil
            return
        end
        local Pos, On = Camera:WorldToViewportPoint(Root.Position)
        if not On then
            for _, v in pairs(D) do v.Visible = false end
            return
        end
        local Dist = (Camera.CFrame.Position - Root.Position).Magnitude
        local Scale = 1000 / Dist
        local H = math.abs((Head.Position.Y - Root.Position.Y) * 2.5) * Scale
        local W = H / 2
        
        D.Box.Position = Vector2.new(Pos.X - W/2, Pos.Y - H/2)
        D.Box.Size = Vector2.new(W, H)
        D.Box.Visible = true
        
        local Txt = Plr.Name .. " [" .. math.floor(Dist) .. "m]"
        D.Name.Text = Txt
        D.Name.Position = Vector2.new(Pos.X, Pos.Y - H/2 - 15)
        D.Name.Visible = true
        
        local hp = Hum.Health / Hum.MaxHealth
        local bh = H * hp
        D.HPbg.Position = Vector2.new(Pos.X - W/2 - 6, Pos.Y - H/2)
        D.HPbg.Size = Vector2.new(3, H)
        D.HPbg.Visible = true
        D.HP.Position = Vector2.new(Pos.X - W/2 - 6, Pos.Y + H/2 - bh)
        D.HP.Size = Vector2.new(3, bh)
        D.HP.Color = Color3.new(1 - hp, hp, 0)
        D.HP.Visible = true
        
        D.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
        D.Tracer.To = Vector2.new(Pos.X, Pos.Y + H/2)
        D.Tracer.Visible = true
    end)
end

RunService.RenderStepped:Connect(function()
    if FOV_Circle then
        FOV_Circle.Position = UserInputService:GetMouseLocation()
        FOV_Circle.Radius = S.AIM_FOV
        FOV_Circle.Visible = S.AIM_On and RightMouseDown
    end
    if S.AIM_On and RightMouseDown then
        local T = GetTarget()
        if T and T.Character then
            local Part = T.Character:FindFirstChild("Head")
            if Part then
                local TP, On = Camera:WorldToViewportPoint(Part.Position)
                if On then
                    local MP = UserInputService:GetMouseLocation()
                    local DX = (TP.X - MP.X) * S.AIM_Smooth
                    local DY = (TP.Y - MP.Y) * S.AIM_Smooth
                    if math.abs(DX) > 0.5 or math.abs(DY) > 0.5 then
                        mousemoverel(DX, DY)
                    end
                end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if S.NoClip and LocalPlayer.Character then
        for _, Part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if Part:IsA("BasePart") then Part.CanCollide = false end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if S.Fly and LocalPlayer.Character then
        local Root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local Hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if Root and Hum then
            Hum.PlatformStand = true
            local V = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then V = V + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then V = V - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then V = V - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then V = V + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then V = V + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then V = V - Vector3.new(0,1,0) end
            if V.Magnitude > 0 then V = V.Unit * FlySpeed end
            Root.Velocity = V
        end
    elseif not S.Fly and LocalPlayer.Character then
        local Hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if Hum then Hum.PlatformStand = false end
    end
end)

local function CreateGUI()
    local SG = Instance.new("ScreenGui")
    SG.Name = "GINS"
    SG.ResetOnSpawn = false
    SG.Parent = CoreGui
    
    local Main = Instance.new("Frame", SG)
    Main.Size = UDim2.new(0, 250, 0, 350)
    Main.Position = UDim2.new(0.5, -125, 0.3, 0)
    Main.BackgroundColor3 = Color3.fromRGB(15,15,15)
    Main.BorderSizePixel = 1
    Main.BorderColor3 = Color3.fromRGB(60,60,60)
    Main.Active = true
    Main.Draggable = true

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1,0,0,25)
    Title.BackgroundColor3 = Color3.fromRGB(30,30,30)
    Title.Text = "GINS"
    Title.TextColor3 = Color3.fromRGB(255,50,50)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14

    local function AddToggle(Text, Default, CB, Y)
        local F = Instance.new("Frame", Main)
        F.Size = UDim2.new(1,-10,0,22)
        F.Position = UDim2.new(0,5,0,Y)
        F.BackgroundTransparency = 1
        local L = Instance.new("TextLabel", F)
        L.Size = UDim2.new(0.6,0,1,0)
        L.BackgroundTransparency = 1
        L.Text = Text
        L.TextColor3 = Color3.new(0.9,0.9,0.9)
        L.Font = Enum.Font.Gotham
        L.TextSize = 11
        L.TextXAlignment = Enum.TextXAlignment.Left
        local B = Instance.new("TextButton", F)
        B.Size = UDim2.new(0,24,0,16)
        B.Position = UDim2.new(1,-28,0,3)
        B.Text = ""
        B.BorderSizePixel = 0
        B.BackgroundColor3 = Default and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        local State = Default
        B.MouseButton1Click:Connect(function()
            State = not State
            B.BackgroundColor3 = State and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
            CB(State)
        end)
        return Y + 24
    end

    local function AddSlider(Text, Min, Max, Default, CB, Y)
        local F = Instance.new("Frame", Main)
        F.Size = UDim2.new(1,-10,0,28)
        F.Position = UDim2.new(0,5,0,Y)
        F.BackgroundTransparency = 1
        local L = Instance.new("TextLabel", F)
        L.Size = UDim2.new(0.5,0,1,0)
        L.BackgroundTransparency = 1
        L.Text = Text .. ": " .. tostring(Default)
        L.TextColor3 = Color3.new(0.9,0.9,0.9)
        L.Font = Enum.Font.Gotham
        L.TextSize = 10
        L.TextXAlignment = Enum.TextXAlignment.Left
        local Slider = Instance.new("Frame", F)
        Slider.Size = UDim2.new(0.4,0,0,12)
        Slider.Position = UDim2.new(0.55,0,0.5,-6)
        Slider.BackgroundColor3 = Color3.fromRGB(40,40,40)
        local Fill = Instance.new("Frame", Slider)
        Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
        Fill.BackgroundColor3 = Color3.fromRGB(0,170,0)
        Fill.BorderSizePixel = 0
        local Val = Default
        local Dragging = false
        Slider.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = true
                local X = math.clamp((Input.Position.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
                Val = math.floor(Min + (Max - Min) * X)
                Fill.Size = UDim2.new(X, 0, 1, 0)
                L.Text = Text .. ": " .. tostring(Val)
                CB(Val)
            end
        end)
        UserInputService.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(Input)
            if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
                local X = math.clamp((Input.Position.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
                Val = math.floor(Min + (Max - Min) * X)
                Fill.Size = UDim2.new(X, 0, 1, 0)
                L.Text = Text .. ": " .. tostring(Val)
                CB(Val)
            end
        end)
        return Y + 30
    end

    local Y = 30
    Y = AddToggle("ESP", true, function(v) S.ESP_On = v end, Y)
    Y = AddToggle("Aimbot (Sag Tik)", false, function(v) S.AIM_On = v
        if v then CreateFOVCircle() elseif FOV_Circle then FOV_Circle:Remove() FOV_Circle = nil end
    end, Y)
    Y = AddSlider("FOV", 20, 300, 120, function(v) S.AIM_FOV = v if FOV_Circle then FOV_Circle.Radius = v end end, Y)
    Y = AddSlider("Smooth", 1, 10, 5, function(v) S.AIM_Smooth = v / 10 end, Y)
    Y = AddToggle("NoClip", false, function(v) S.NoClip = v end, Y)
    Y = AddToggle("Fly", false, function(v) S.Fly = v end, Y)
    Y = AddSlider("Fly Speed", 10, 100, 50, function(v) FlySpeed = v end, Y)
    
    Main.Size = UDim2.new(0, 250, 0, Y + 10)
end

for _, p in ipairs(Players:GetPlayers()) do
    p.CharacterAdded:Connect(function() task.wait(0.5) CreateESP(p) end)
    if p.Character then task.wait(0.5) CreateESP(p) end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.wait(0.5) CreateESP(p) end)
end)

task.spawn(function()
    while not LocalPlayer.Character do task.wait(0.5) end
    task.wait(1)
    CreateGUI()
    print("GINS HAZIR")
end)
