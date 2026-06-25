local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local S = {
    ESP_On = true,
    ESP_Box = true,
    ESP_Name = true,
    ESP_HP = true,
    ESP_Tracer = true,
    ESP_Dist = true,
    AIM_On = false,
    AIM_FOV = 120,
    AIM_Smooth = 1,
    NoClip = false,
    Fly = false
}

local ESP_Data = {}
local FOV_Circle = nil
local RightMouseDown = false
local FlySpeed = 50
local SelectedPlayer = nil
local BringConnection = nil

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

local function KillPlayer(Plr)
    if Plr and Plr.Character then
        local Hum = Plr.Character:FindFirstChild("Humanoid")
        if Hum then
            Hum.Health = 0
            task.wait(0.05)
            Plr.Character:BreakJoints()
        end
    end
end

local function JailPlayer(Plr)
    if Plr and Plr.Character then
        local Root = Plr.Character:FindFirstChild("HumanoidRootPart")
        if Root then
            local Pos = Root.Position
            local Jail = Instance.new("Part")
            Jail.Size = Vector3.new(6, 6, 6)
            Jail.Position = Pos
            Jail.Anchored = true
            Jail.CanCollide = true
            Jail.BrickColor = BrickColor.new("Bright red")
            Jail.Transparency = 0.3
            Jail.Parent = workspace
            Jail.Name = "Jail_" .. Plr.Name
            Root.CFrame = CFrame.new(Jail.Position)
            task.wait(0.1)
            local Walls = {
                {Vector3.new(0, 0, 3), Vector3.new(0.5, 6, 0.5)},
                {Vector3.new(0, 0, -3), Vector3.new(0.5, 6, 0.5)},
                {Vector3.new(3, 0, 0), Vector3.new(0.5, 6, 0.5)},
                {Vector3.new(-3, 0, 0), Vector3.new(0.5, 6, 0.5)},
                {Vector3.new(0, 3, 0), Vector3.new(0.5, 0.5, 6)},
                {Vector3.new(0, -3, 0), Vector3.new(0.5, 0.5, 6)}
            }
            for _, Data in ipairs(Walls) do
                local Wall = Instance.new("Part")
                Wall.Size = Data[2]
                Wall.Position = Jail.Position + Data[1]
                Wall.Anchored = true
                Wall.CanCollide = true
                Wall.BrickColor = BrickColor.new("Bright red")
                Wall.Transparency = 0.2
                Wall.Parent = Jail
            end
        end
    end
end

local function TeleportToPlayer(Plr)
    if Plr and Plr.Character and LocalPlayer.Character then
        local Root = Plr.Character:FindFirstChild("HumanoidRootPart")
        local LRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if Root and LRoot then
            LRoot.CFrame = Root.CFrame * CFrame.new(0, 2, 0)
        end
    end
end

local function BringPlayer(Plr)
    if BringConnection then
        BringConnection:Disconnect()
        BringConnection = nil
    end
    if Plr and Plr.Character and LocalPlayer.Character then
        local Root = Plr.Character:FindFirstChild("HumanoidRootPart")
        local LRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if Root and LRoot then
            Root.CFrame = LRoot.CFrame * CFrame.new(0, 0, 3)
            BringConnection = RunService.RenderStepped:Connect(function()
                if not Plr or not Plr.Character or not LocalPlayer.Character then
                    if BringConnection then BringConnection:Disconnect() BringConnection = nil end
                    return
                end
                local NewRoot = Plr.Character:FindFirstChild("HumanoidRootPart")
                local NewLRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if NewRoot and NewLRoot then
                    NewRoot.CFrame = NewLRoot.CFrame * CFrame.new(0, 0, 3)
                end
            end)
        end
    end
end

local function StopBring()
    if BringConnection then
        BringConnection:Disconnect()
        BringConnection = nil
    end
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
        for _, v in pairs(ESP_Data[Plr]) do
            pcall(function() v:Remove() end)
        end
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
            for _, v in pairs(D) do
                pcall(function() v.Visible = false end)
            end
            return
        end
        if not Char or not Char.Parent or not Root or not Root.Parent then
            Conn:Disconnect()
            for _, v in pairs(D) do
                pcall(function() v:Remove() end)
            end
            ESP_Data[Plr] = nil
            return
        end
        local Pos, On = Camera:WorldToViewportPoint(Root.Position)
        if not On then
            for _, v in pairs(D) do
                pcall(function() v.Visible = false end)
            end
            return
        end
        local Dist = (Camera.CFrame.Position - Root.Position).Magnitude
        local Scale = 1000 / Dist
        local H = math.abs((Head.Position.Y - Root.Position.Y) * 2.5) * Scale
        local W = H / 2
        
        if S.ESP_Box then
            D.Box.Position = Vector2.new(Pos.X - W/2, Pos.Y - H/2)
            D.Box.Size = Vector2.new(W, H)
            D.Box.Visible = true
        else
            D.Box.Visible = false
        end
        
        if S.ESP_Name then
            local Txt = Plr.Name
            if S.ESP_Dist then Txt = Txt .. " [" .. math.floor(Dist) .. "m]" end
            D.Name.Text = Txt
            D.Name.Position = Vector2.new(Pos.X, Pos.Y - H/2 - 15)
            D.Name.Visible = true
        else
            D.Name.Visible = false
        end
        
        if S.ESP_HP then
            local hp = Hum.Health / Hum.MaxHealth
            local bh = H * hp
            D.HPbg.Position = Vector2.new(Pos.X - W/2 - 6, Pos.Y - H/2)
            D.HPbg.Size = Vector2.new(3, H)
            D.HPbg.Visible = true
            D.HP.Position = Vector2.new(Pos.X - W/2 - 6, Pos.Y + H/2 - bh)
            D.HP.Size = Vector2.new(3, bh)
            D.HP.Color = Color3.new(1 - hp, hp, 0)
            D.HP.Visible = true
        else
            D.HP.Visible = false
            D.HPbg.Visible = false
        end
        
        if S.ESP_Tracer then
            D.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            D.Tracer.To = Vector2.new(Pos.X, Pos.Y + H/2)
            D.Tracer.Visible = true
        else
            D.Tracer.Visible = false
        end
    end)
end

-- Aimbot - Sert kitleme (Smooth=1)
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

-- NoClip
RunService.RenderStepped:Connect(function()
    if S.NoClip and LocalPlayer.Character then
        for _, Part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if Part:IsA("BasePart") then
                pcall(function() Part.CanCollide = false end)
            end
        end
    end
end)

-- Fly
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
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not PlayerGui then
        PlayerGui = Instance.new("ScreenGui")
        PlayerGui.Name = "PlayerGui"
        PlayerGui.Parent = LocalPlayer
    end
    
    local SG = Instance.new("ScreenGui")
    SG.Name = "GINS"
    SG.ResetOnSpawn = false
    SG.Parent = PlayerGui

    local Main = Instance.new("Frame", SG)
    Main.Size = UDim2.new(0, 300, 0, 480)
    Main.Position = UDim2.new(0.5, -150, 0.15, 0)
    Main.BackgroundColor3 = Color3.fromRGB(15,15,15)
    Main.BorderSizePixel = 1
    Main.BorderColor3 = Color3.fromRGB(60,60,60)
    Main.Active = true
    Main.Draggable = true

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1,0,0,28)
    Title.BackgroundColor3 = Color3.fromRGB(30,30,30)
    Title.Text = "GINS v5.1"
    Title.TextColor3 = Color3.fromRGB(255,50,50)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    
    local Close = Instance.new("TextButton", Main)
    Close.Size = UDim2.new(0,28,0,28)
    Close.Position = UDim2.new(1,-28,0,0)
    Close.BackgroundColor3 = Color3.fromRGB(60,0,0)
    Close.Text = "X"
    Close.TextColor3 = Color3.new(1,1,1)
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 14
    Close.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

    -- Tabs
    local TabF = Instance.new("Frame", Main)
    TabF.Size = UDim2.new(1,0,0,26)
    TabF.Position = UDim2.new(0,0,0,28)
    TabF.BackgroundColor3 = Color3.fromRGB(20,20,20)

    local Pages = {}
    local Tabs = {}
    
    local function MakeTab(Name)
        local Btn = Instance.new("TextButton", TabF)
        Btn.Size = UDim2.new(1/3, -2, 1, 0)
        Btn.Position = UDim2.new(#Tabs/3, 1, 0, 0)
        Btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
        Btn.Text = Name
        Btn.TextColor3 = Color3.new(0.8,0.8,0.8)
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 10
        Btn.AutoButtonColor = false
        
        local Page = Instance.new("ScrollingFrame", Main)
        Page.Size = UDim2.new(1,-6,1,-60)
        Page.Position = UDim2.new(0,3,0,58)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 4
        Page.CanvasSize = UDim2.new(0,0,0,400)
        Page.Visible = false
        
        Btn.MouseButton1Click:Connect(function()
            for _, t in ipairs(Tabs) do t.BackgroundColor3 = Color3.fromRGB(30,30,30) end
            Btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
            for _, p in ipairs(Pages) do p.Visible = false end
            Page.Visible = true
        end)
        
        table.insert(Tabs, Btn)
        table.insert(Pages, Page)
        return Page, Btn
    end

    local ESP_Page, ESP_Tab = MakeTab("ESP")
    local AIM_Page, AIM_Tab = MakeTab("AIMBOT")
    local ADMIN_Page, ADMIN_Tab = MakeTab("ADMIN")
    
    ESP_Tab.BackgroundColor3 = Color3.fromRGB(60,60,60)
    ESP_Page.Visible = true

    local function AddToggle(Page, Text, Default, CB, YT)
        local Y = YT[1]
        local F = Instance.new("Frame", Page)
        F.Size = UDim2.new(1,-4,0,22)
        F.Position = UDim2.new(0,2,0,Y)
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
        YT[1] = Y + 24
    end

    local function AddSlider(Page, Text, Min, Max, Default, CB, YT)
        local Y = YT[1]
        local F = Instance.new("Frame", Page)
        F.Size = UDim2.new(1,-4,0,28)
        F.Position = UDim2.new(0,2,0,Y)
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
        YT[1] = Y + 30
    end

    local function AddButton(Page, Text, CB, YT)
        local Y = YT[1]
        local B = Instance.new("TextButton", Page)
        B.Size = UDim2.new(1,-4,0,26)
        B.Position = UDim2.new(0,2,0,Y)
        B.BackgroundColor3 = Color3.fromRGB(40,40,40)
        B.Text = Text
        B.TextColor3 = Color3.new(1,1,1)
        B.Font = Enum.Font.GothamBold
        B.TextSize = 11
        B.MouseButton1Click:Connect(CB)
        YT[1] = Y + 28
    end

    local function AddDropdown(Page, Text, Options, CB, YT)
        local Y = YT[1]
        local F = Instance.new("Frame", Page)
        F.Size = UDim2.new(1,-4,0,26)
        F.Position = UDim2.new(0,2,0,Y)
        F.BackgroundTransparency = 1
        local L = Instance.new("TextLabel", F)
        L.Size = UDim2.new(0.35,0,1,0)
        L.BackgroundTransparency = 1
        L.Text = Text
        L.TextColor3 = Color3.new(0.9,0.9,0.9)
        L.Font = Enum.Font.Gotham
        L.TextSize = 10
        L.TextXAlignment = Enum.TextXAlignment.Left
        local Drop = Instance.new("TextButton", F)
        Drop.Size = UDim2.new(0.6,0,1,0)
        Drop.Position = UDim2.new(0.38,0,0,0)
        Drop.BackgroundColor3 = Color3.fromRGB(40,40,40)
        Drop.Text = Options[1]
        Drop.TextColor3 = Color3.new(1,1,1)
        Drop.Font = Enum.Font.Gotham
        Drop.TextSize = 10
        local State = Options[1]
        Drop.MouseButton1Click:Connect(function()
            local Current = 1
            for i, Opt in ipairs(Options) do
                if Opt == State then Current = i break end
            end
            Current = Current % #Options + 1
            State = Options[Current]
            Drop.Text = State
            CB(State)
        end)
        YT[1] = Y + 28
        return Drop
    end

    -- ESP PAGE
    local EY = {0}
    AddToggle(ESP_Page, "ESP On/Off", true, function(v) S.ESP_On = v end, EY)
    AddToggle(ESP_Page, "Box", true, function(v) S.ESP_Box = v end, EY)
    AddToggle(ESP_Page, "Name", true, function(v) S.ESP_Name = v end, EY)
    AddToggle(ESP_Page, "HP Bar", true, function(v) S.ESP_HP = v end, EY)
    AddToggle(ESP_Page, "Tracer", true, function(v) S.ESP_Tracer = v end, EY)
    AddToggle(ESP_Page, "Distance", true, function(v) S.ESP_Dist = v end, EY)
    ESP_Page.CanvasSize = UDim2.new(0,0,0,EY[1]+10)

    -- AIMBOT PAGE
    local AY = {0}
    AddToggle(AIM_Page, "Aimbot (Sag Tik)", false, function(v) 
        S.AIM_On = v
        if v then CreateFOVCircle() elseif FOV_Circle then FOV_Circle:Remove() FOV_Circle = nil end
    end, AY)
    AddSlider(AIM_Page, "FOV Size", 20, 300, 120, function(v) 
        S.AIM_FOV = v 
        if FOV_Circle then FOV_Circle.Radius = v end 
    end, AY)
    AddSlider(AIM_Page, "Smoothness (1=Sert)", 1, 10, 1, function(v) S.AIM_Smooth = v / 10 end, AY)
    AIM_Page.CanvasSize = UDim2.new(0,0,0,AY[1]+10)

    -- ADMIN PAGE
    local ADY = {0}
    local PlayerNames = {}
    local function UpdatePlayers()
        PlayerNames = {}
        for _, Plr in ipairs(Players:GetPlayers()) do
            if Plr ~= LocalPlayer then table.insert(PlayerNames, Plr.Name) end
        end
        if #PlayerNames == 0 then table.insert(PlayerNames, "None") end
        return PlayerNames
    end
    
    local SelectedPlayerName = "None"
    local Drop = AddDropdown(ADMIN_Page, "Target Player:", UpdatePlayers(), function(v)
        SelectedPlayerName = v
        for _, Plr in ipairs(Players:GetPlayers()) do
            if Plr.Name == v then SelectedPlayer = Plr break end
        end
    end, ADY)
    ADY[1] = ADY[1] + 28
    
    AddButton(ADMIN_Page, "Kill Player", function() 
        if SelectedPlayer then KillPlayer(SelectedPlayer) end 
    end, ADY)
    
    AddButton(ADMIN_Page, "Jail Player", function() 
        if SelectedPlayer then JailPlayer(SelectedPlayer) end 
    end, ADY)
    
    AddButton(ADMIN_Page, "TP To Player", function() 
        if SelectedPlayer then TeleportToPlayer(SelectedPlayer) end 
    end, ADY)
    
    AddButton(ADMIN_Page, "Bring Player", function() 
        if SelectedPlayer then BringPlayer(SelectedPlayer) end 
    end, ADY)
    
    AddButton(ADMIN_Page, "Stop Bring", function() 
        StopBring()
    end, ADY)
    
    AddToggle(ADMIN_Page, "NoClip", false, function(v) S.NoClip = v end, ADY)
    AddToggle(ADMIN_Page, "Fly", false, function(v) S.Fly = v end, ADY)
    AddSlider(ADMIN_Page, "Fly Speed", 10, 100, 50, function(v) FlySpeed = v end, ADY)
    
    ADMIN_Page.CanvasSize = UDim2.new(0,0,0,ADY[1]+20)
    
    Players.PlayerAdded:Connect(function()
        local Names = UpdatePlayers()
        if #Names > 0 then
            Drop.Text = Names[1]
            SelectedPlayerName = Names[1]
            for _, Plr in ipairs(Players:GetPlayers()) do
                if Plr.Name == Names[1] then SelectedPlayer = Plr break end
            end
        end
    end)
    Players.PlayerRemoving:Connect(function()
        local Names = UpdatePlayers()
        if #Names > 0 then
            Drop.Text = Names[1]
            SelectedPlayerName = Names[1]
            for _, Plr in ipairs(Players:GetPlayers()) do
                if Plr.Name == Names[1] then SelectedPlayer = Plr break end
            end
        end
    end)
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
    print("GINS v5.1 HAZIR - Tum hatalar fixlendi")
end)
