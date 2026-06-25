local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local S = {
    ESP_On = true, ESP_Box = true, ESP_Name = true, ESP_HP = true, ESP_Tracer = true, ESP_Dist = true,
    ESP_Chams = true, ESP_ChamsColor = Color3.fromRGB(255, 0, 0),
    AIM_On = false, AIM_Team = false, AIM_Vis = true, AIM_FOV = 120, AIM_Smooth = 3,
    AIM_ShowFOV = true,
    NoClip = false,
    Fly = false
}

local ESP_Data = {}
local Chams_Data = {}
local FOV_Circle = nil
local RightMouseDown = false
local FlySpeed = 50
local SelectedPlayer = nil

local function CreateFOVCircle()
    if FOV_Circle then pcall(function() FOV_Circle:Remove() end) FOV_Circle = nil end
    if not S.AIM_ShowFOV or not Drawing then return end
    FOV_Circle = Drawing.new("Circle")
    FOV_Circle.Radius = S.AIM_FOV
    FOV_Circle.Thickness = 1
    FOV_Circle.Color = Color3.fromRGB(0, 255, 255)
    FOV_Circle.Filled = false
    FOV_Circle.Visible = true
    FOV_Circle.Position = UserInputService:GetMouseLocation()
end

local function UpdateFOVCircle()
    if FOV_Circle then
        FOV_Circle.Position = UserInputService:GetMouseLocation()
        FOV_Circle.Radius = S.AIM_FOV
        FOV_Circle.Visible = S.AIM_On and S.AIM_ShowFOV and RightMouseDown
    end
end

UserInputService.InputBegan:Connect(function(Input, GPE)
    if GPE then return end
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightMouseDown = true
        if S.AIM_ShowFOV and FOV_Circle then FOV_Circle.Visible = true end
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
    local Origin = Camera.CFrame.Position
    local Direction = (Part.Position - Origin).Unit * 500
    local RP = RaycastParams.new()
    RP.FilterType = Enum.RaycastFilterType.Blacklist
    RP.FilterDescendantsInstances = {LocalPlayer.Character, Part.Parent}
    local Result = workspace:Raycast(Origin, Direction, RP)
    if Result then
        local DistToPart = (Origin - Part.Position).Magnitude
        local DistToHit = (Origin - Result.Position).Magnitude
        return DistToHit >= DistToPart - 2
    end
    return true
end

local function GetTarget(FOV, TeamCheck, VisCheck)
    local Best = nil
    local BestDist = FOV
    local MousePos = UserInputService:GetMouseLocation()
    for _, Plr in ipairs(Players:GetPlayers()) do
        if Plr == LocalPlayer then continue end
        if TeamCheck and Plr.Team == LocalPlayer.Team then continue end
        local Char = Plr.Character
        if not Char or not Char.Parent then continue end
        local Part = Char:FindFirstChild("Head")
        if not Part then continue end
        if VisCheck and not IsVisible(Part) then continue end
        local SPos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
        if not OnScreen then continue end
        local Dist = (Vector2.new(SPos.X, SPos.Y) - MousePos).Magnitude
        if Dist < BestDist then
            BestDist = Dist
            Best = Plr
        end
    end
    return Best
end

local function UpdateChams(Plr, Char)
    if Chams_Data[Plr] then pcall(function() Chams_Data[Plr]:Destroy() end) Chams_Data[Plr] = nil end
    if S.ESP_On and S.ESP_Chams and Char and Char.Parent then
        local H = Instance.new("Highlight")
        H.Name = "GINS_Chams"
        H.FillColor = S.ESP_ChamsColor
        H.FillTransparency = 0.4
        H.OutlineColor = S.ESP_ChamsColor
        H.OutlineTransparency = 0
        H.Enabled = true
        H.Parent = Char
        Chams_Data[Plr] = H
    end
end

local function ClearAll(Plr)
    if ESP_Data[Plr] then for _, Obj in pairs(ESP_Data[Plr]) do pcall(function() Obj:Remove() end) end ESP_Data[Plr] = nil end
    if Chams_Data[Plr] then pcall(function() Chams_Data[Plr]:Destroy() end) Chams_Data[Plr] = nil end
end

local function CreateESP(Plr)
    ClearAll(Plr)
    local Char = Plr.Character if not Char then return end
    local Root = Char:FindFirstChild("HumanoidRootPart")
    local Head = Char:FindFirstChild("Head")
    local Hum = Char:FindFirstChild("Humanoid")
    if not Root or not Head or not Hum then return end
    ESP_Data[Plr] = {}
    local D = ESP_Data[Plr]
    UpdateChams(Plr, Char)
    if Drawing then
        D.Box = Drawing.new("Square"); D.Box.Thickness = 1; D.Box.Filled = false; D.Box.Color = Color3.new(1,1,1); D.Box.Visible = false
        D.Nam = Drawing.new("Text"); D.Nam.Size = 13; D.Nam.Center = true; D.Nam.Outline = true; D.Nam.Color = Color3.new(1,1,1); D.Nam.Visible = false
        D.Hbg = Drawing.new("Square"); D.Hbg.Filled = true; D.Hbg.Color = Color3.new(0,0,0); D.Hbg.Visible = false
        D.HP = Drawing.new("Square"); D.HP.Filled = true; D.HP.Visible = false
        D.Tr = Drawing.new("Line"); D.Tr.Thickness = 1; D.Tr.Color = Color3.new(1,1,1); D.Tr.Visible = false
    end
    local Conn
    Conn = RunService.RenderStepped:Connect(function()
        if not S.ESP_On then
            for _, v in pairs(D) do pcall(function() v.Visible = false end) end
            if Chams_Data[Plr] then pcall(function() Chams_Data[Plr]:Destroy() end) Chams_Data[Plr] = nil end
            return
        end
        if S.ESP_Chams and not Chams_Data[Plr] and Char and Char.Parent then UpdateChams(Plr, Char)
        elseif not S.ESP_Chams and Chams_Data[Plr] then pcall(function() Chams_Data[Plr]:Destroy() end) Chams_Data[Plr] = nil end
        if not Char or not Char.Parent or not Root or not Root.Parent then Conn:Disconnect() ClearAll(Plr) return end
        local Pos, On = Camera:WorldToViewportPoint(Root.Position)
        if not On then for _, v in pairs(D) do pcall(function() v.Visible = false end) end return end
        local Dist = (Camera.CFrame.Position - Root.Position).Magnitude
        local Scale = 1000 / Dist
        local H = math.abs((Head.Position.Y - Root.Position.Y) * 2.5) * Scale
        local W = H / 2
        if S.ESP_Box and D.Box then D.Box.Position = Vector2.new(Pos.X - W/2, Pos.Y - H/2) D.Box.Size = Vector2.new(W, H) D.Box.Visible = true elseif D.Box then D.Box.Visible = false end
        if S.ESP_Name and D.Nam then local Txt = Plr.Name if S.ESP_Dist then Txt = Txt .. " [" .. math.floor(Dist) .. "m]" end D.Nam.Text = Txt D.Nam.Position = Vector2.new(Pos.X, Pos.Y - H/2 - 15) D.Nam.Visible = true elseif D.Nam then D.Nam.Visible = false end
        if S.ESP_HP and D.HP then local hp = Hum.Health / Hum.MaxHealth local bh = H * hp D.Hbg.Position = Vector2.new(Pos.X - W/2 - 6, Pos.Y - H/2) D.Hbg.Size = Vector2.new(3, H) D.Hbg.Visible = true D.HP.Position = Vector2.new(Pos.X - W/2 - 6, Pos.Y + H/2 - bh) D.HP.Size = Vector2.new(3, bh) D.HP.Color = Color3.new(1 - hp, hp, 0) D.HP.Visible = true elseif D.HP then D.HP.Visible = false D.Hbg.Visible = false end
        if S.ESP_Tracer and D.Tr then D.Tr.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y) D.Tr.To = Vector2.new(Pos.X, Pos.Y + H/2) D.Tr.Visible = true elseif D.Tr then D.Tr.Visible = false end
    end)
end

RunService.RenderStepped:Connect(function()
    UpdateFOVCircle()
    if not S.AIM_On or not RightMouseDown then return end
    local T = GetTarget(S.AIM_FOV, S.AIM_Team, S.AIM_Vis)
    if T and T.Character then
        local Part = T.Character:FindFirstChild("Head")
        if Part then
            local TP, On = Camera:WorldToViewportPoint(Part.Position)
            if On then
                local MP = UserInputService:GetMouseLocation()
                local DX = TP.X - MP.X
                local DY = TP.Y - MP.Y
                if math.abs(DX) > 0.5 or math.abs(DY) > 0.5 then
                    local Power = (S.AIM_Smooth / 5) * 0.6
                    mousemoverel(DX * Power, DY * Power)
                end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if S.NoClip and LocalPlayer.Character then
        local Char = LocalPlayer.Character
        local Hum = Char:FindFirstChild("Humanoid")
        if Hum then
            Hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
            Hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            Hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            Hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
            Hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
        end
        for _, Part in ipairs(Char:GetDescendants()) do
            if Part:IsA("BasePart") then
                Part.CanCollide = false
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if S.Fly and LocalPlayer.Character then
        local Root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local Hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if Root and Hum then
            Hum.PlatformStand = true
            local V = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then V = V + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then V = V - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then V = V - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then V = V + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then V = V + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then V = V - Vector3.new(0, 1, 0) end
            if V.Magnitude > 0 then V = V.Unit * FlySpeed end
            Root.Velocity = V
            if V.Magnitude > 0 then
                Root.CFrame = CFrame.new(Root.Position, Root.Position + V.Unit)
            end
        end
    elseif not S.Fly and LocalPlayer.Character then
        local Hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if Hum then Hum.PlatformStand = false end
    end
end)

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
            Jail.Size = Vector3.new(8, 8, 8)
            Jail.Position = Pos
            Jail.Anchored = true
            Jail.CanCollide = true
            Jail.BrickColor = BrickColor.new("Bright red")
            Jail.Transparency = 0.3
            Jail.Parent = workspace
            Jail.Name = "Jail_" .. Plr.Name
            Root.CFrame = CFrame.new(Jail.Position)
            local Sizes = {
                {Vector3.new(0, 0, 4), Vector3.new(0.5, 8, 0.5)},
                {Vector3.new(0, 0, -4), Vector3.new(0.5, 8, 0.5)},
                {Vector3.new(4, 0, 0), Vector3.new(0.5, 8, 0.5)},
                {Vector3.new(-4, 0, 0), Vector3.new(0.5, 8, 0.5)},
                {Vector3.new(0, 4, 0), Vector3.new(0.5, 0.5, 8)},
                {Vector3.new(0, -4, 0), Vector3.new(0.5, 0.5, 8)}
            }
            for _, Data in ipairs(Sizes) do
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
    if Plr and Plr.Character and LocalPlayer.Character then
        local Root = Plr.Character:FindFirstChild("HumanoidRootPart")
        local LRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if Root and LRoot then
            Root.CFrame = LRoot.CFrame * CFrame.new(0, 0, 3)
        end
    end
end

local function CreateGUI()
    local SG = Instance.new("ScreenGui")
    SG.Name = "GINS"
    SG.ResetOnSpawn = false
    SG.Parent = CoreGui
    if not SG.Parent then
        local pg = Instance.new("ScreenGui")
        pg.Name = "PlayerGui"
        pg.Parent = LocalPlayer
        SG.Parent = pg
    end
    if not SG.Parent then return end

    local Main = Instance.new("Frame", SG)
    Main.Size = UDim2.new(0, 300, 0, 450)
    Main.Position = UDim2.new(0.5, -150, 0.2, 0)
    Main.BackgroundColor3 = Color3.fromRGB(15,15,15)
    Main.BorderSizePixel = 1
    Main.BorderColor3 = Color3.fromRGB(60,60,60)
    Main.Active = true
    Main.Draggable = true

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1,0,0,28)
    Title.BackgroundColor3 = Color3.fromRGB(30,30,30)
    Title.Text = "GINS v4.5"
    Title.TextColor3 = Color3.fromRGB(255,50,50)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14

    local CloseBtn = Instance.new("TextButton", Main)
    CloseBtn.Size = UDim2.new(0,28,0,28)
    CloseBtn.Position = UDim2.new(1,-28,0,0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(60,0,0)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.new(1,1,1)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    CloseBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

    local TabF = Instance.new("Frame", Main)
    TabF.Size = UDim2.new(1,0,0,26)
    TabF.Position = UDim2.new(0,0,0,28)
    TabF.BackgroundColor3 = Color3.fromRGB(20,20,20)

    local Pages, Tabs = {}, {}
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
        Page.Size = UDim2.new(1,-4,1,-60)
        Page.Position = UDim2.new(0,2,0,58)
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
        table.insert(Tabs, Btn) table.insert(Pages, Page)
        return Page, Btn
    end

    local ESP_Page, ESP_Tab = MakeTab("ESP")
    local AIM_Page, AIM_Tab = MakeTab("AIM")
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
        B.Size = UDim2.new(0,26,0,16)
        B.Position = UDim2.new(1,-30,0,3)
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
        L.Size = UDim2.new(0.6,0,1,0)
        L.BackgroundTransparency = 1
        L.Text = Text .. ": " .. tostring(Default)
        L.TextColor3 = Color3.new(0.9,0.9,0.9)
        L.Font = Enum.Font.Gotham
        L.TextSize = 10
        L.TextXAlignment = Enum.TextXAlignment.Left
        local Slider = Instance.new("Frame", F)
        Slider.Size = UDim2.new(0.35,0,0,12)
        Slider.Position = UDim2.new(0.6,0,0.5,-6)
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
        L.Size = UDim2.new(0.4,0,1,0)
        L.BackgroundTransparency = 1
        L.Text = Text
        L.TextColor3 = Color3.new(0.9,0.9,0.9)
        L.Font = Enum.Font.Gotham
        L.TextSize = 10
        L.TextXAlignment = Enum.TextXAlignment.Left
        local Drop = Instance.new("TextButton", F)
        Drop.Size = UDim2.new(0.55,0,1,0)
        Drop.Position = UDim2.new(0.42,0,0,0)
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
        CB(Options[1])
        return Drop
    end

    local EY = {0}
    AddToggle(ESP_Page, "ESP", true, function(v) S.ESP_On = v end, EY)
    AddToggle(ESP_Page, "Box", true, function(v) S.ESP_Box = v end, EY)
    AddToggle(ESP_Page, "Name", true, function(v) S.ESP_Name = v end, EY)
    AddToggle(ESP_Page, "HP", true, function(v) S.ESP_HP = v end, EY)
    AddToggle(ESP_Page, "Tracer", true, function(v) S.ESP_Tracer = v end, EY)
    AddToggle(ESP_Page, "Distance", true, function(v) S.ESP_Dist = v end, EY)
    AddToggle(ESP_Page, "Chams", true, function(v) S.ESP_Chams = v
        for Plr, _ in pairs(Chams_Data) do
            if v then if Plr.Character then UpdateChams(Plr, Plr.Character) end
            else pcall(function() Chams_Data[Plr]:Destroy() end) Chams_Data[Plr] = nil end
        end
    end, EY)
    ESP_Page.CanvasSize = UDim2.new(0,0,0,EY[1]+10)

    local AY = {0}
    AddToggle(AIM_Page, "Aimbot (Sag Tik)", false, function(v) S.AIM_On = v
        if v and S.AIM_ShowFOV then CreateFOVCircle() else if FOV_Circle then pcall(function() FOV_Circle:Remove() end) FOV_Circle = nil end end
    end, AY)
    AddToggle(AIM_Page, "Team Check", false, function(v) S.AIM_Team = v end, AY)
    AddToggle(AIM_Page, "Visible", true, function(v) S.AIM_Vis = v end, AY)
    AddToggle(AIM_Page, "FOV Circle", true, function(v) S.AIM_ShowFOV = v
        if v and S.AIM_On then CreateFOVCircle() else if FOV_Circle then pcall(function() FOV_Circle:Remove() end) FOV_Circle = nil end end
    end, AY)
    AddSlider(AIM_Page, "FOV", 20, 300, 120, function(v) S.AIM_FOV = v if FOV_Circle then FOV_Circle.Radius = v end end, AY)
    AddSlider(AIM_Page, "Power", 1, 5, 3, function(v) S.AIM_Smooth = v end, AY)
    AIM_Page.CanvasSize = UDim2.new(0,0,0,AY[1]+10)

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
    local Dropdown = AddDropdown(ADMIN_Page, "Target:", UpdatePlayers(), function(v)
        SelectedPlayerName = v
        for _, Plr in ipairs(Players:GetPlayers()) do
            if Plr.Name == v then SelectedPlayer = Plr break end
        end
    end, ADY)
    
    Players.PlayerAdded:Connect(function()
        local Names = UpdatePlayers()
        if #Names > 0 then Dropdown.Text = Names[1] SelectedPlayerName = Names[1]
        for _, Plr in ipairs(Players:GetPlayers()) do if Plr.Name == Names[1] then SelectedPlayer = Plr break end end
    end)
    Players.PlayerRemoving:Connect(function()
        local Names = UpdatePlayers()
        if #Names > 0 then Dropdown.Text = Names[1] SelectedPlayerName = Names[1]
        for _, Plr in ipairs(Players:GetPlayers()) do if Plr.Name == Names[1] then SelectedPlayer = Plr break end end
    end)
    
    AddButton(ADMIN_Page, "Kill", function() if SelectedPlayer then KillPlayer(SelectedPlayer) end end, ADY)
    AddButton(ADMIN_Page, "Jail", function() if SelectedPlayer then JailPlayer(SelectedPlayer) end end, ADY)
    AddButton(ADMIN_Page, "TP To", function() if SelectedPlayer then TeleportToPlayer(SelectedPlayer) end end, ADY)
    AddButton(ADMIN_Page, "Bring", function() if SelectedPlayer then BringPlayer(SelectedPlayer) end end, ADY)
    AddToggle(ADMIN_Page, "NoClip", false, function(v) S.NoClip = v end, ADY)
    AddToggle(ADMIN_Page, "Fly", false, function(v) S.Fly = v end, ADY)
    AddSlider(ADMIN_Page, "Fly Speed", 10, 100, 50, function(v) FlySpeed = v end, ADY)
    ADMIN_Page.CanvasSize = UDim2.new(0,0,0,ADY[1]+20)
end

local function AddPlayer(Plr)
    if Plr == LocalPlayer then return end
    Plr.CharacterAdded:Connect(function(Char) task.wait(0.3) CreateESP(Plr) end)
    if Plr.Character then CreateESP(Plr) end
end

for _, p in ipairs(Players:GetPlayers()) do AddPlayer(p) end
Players.PlayerAdded:Connect(AddPlayer)
Players.PlayerRemoving:Connect(ClearAll)
LocalPlayer.CharacterAdded:Connect(function()
    for Plr, _ in pairs(ESP_Data) do ClearAll(Plr) end
    for Plr, _ in pairs(Chams_Data) do ClearAll(Plr) end
end)

task.spawn(function()
    while task.wait(0.15) do
        for Plr, H in pairs(Chams_Data) do
            if H and H.Parent then
                H.FillColor = S.ESP_ChamsColor
                H.OutlineColor = S.ESP_ChamsColor
                H.Enabled = S.ESP_On and S.ESP_Chams
            end
        end
    end
end)

task.spawn(function()
    while not LocalPlayer.Character or not LocalPlayer.Character.Parent do task.wait(0.5) end
    task.wait(0.5)
    CreateGUI()
    print("GINS v4.5 YUKLENDI")
end)
