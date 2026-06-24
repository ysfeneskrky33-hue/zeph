ocal Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- =============================================
-- AYARLAR
-- =============================================
local S = {
ESP_On = true,
ESP_Box = true,
ESP_Name = true,
ESP_HP = true,
ESP_Tracer = true,
ESP_Dist = true,
ESP_Chams = true,
ESP_ChamsColor = Color3.fromRGB(255, 0, 0),

AIM_On = false,
AIM_Team = false,
AIM_Vis = true,
AIM_FOV = 120,
AIM_Smooth = 4,
AIM_Part = "Head",

SIL_On = false,
SIL_Team = false,
SIL_Vis = true,
SIL_Part = "Head",
SIL_FOV = 150,
SIL_Chance = 100
}

-- =============================================
-- VERİ TABLOLARI
-- =============================================
local ESP_Data = {}
local Chams_Data = {}

-- =============================================
-- GÖRÜNÜRLÜK KONTROLÜ
-- =============================================
local function IsVisible(Part)
if not Part then return false end
local Origin = Camera.CFrame.Position
local Dir = (Part.Position - Origin).Unit * 500
local RP = RaycastParams.new()
RP.FilterType = Enum.RaycastFilterType.Blacklist
RP.FilterDescendantsInstances = {LocalPlayer.Character, Part.Parent}
local Ray = workspace:Raycast(Origin, Dir, RP)
return Ray == nil
end

-- =============================================
-- FOV'E EN YAKIN OYUNCU
-- =============================================
local function GetTarget(FOV, TeamCheck, VisCheck)
local Best = nil
local BestDist = FOV
local MousePos = UserInputService:GetMouseLocation()
for _, Plr in ipairs(Players:GetPlayers()) do
if Plr == LocalPlayer then continue end
if TeamCheck and Plr.Team == LocalPlayer.Team then continue end
local Char = Plr.Character
if not Char then continue end
local Part = Char:FindFirstChild(S.AIM_Part) or Char:FindFirstChild("Head")
if not Part then continue end
if VisCheck and not IsVisible(Part) then continue end
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

-- =============================================
-- CHAMS UYGULA / KALDIR
-- =============================================
local function UpdateChams(Plr, Char)
if Chams_Data[Plr] then
pcall(function() Chams_Data[Plr]:Destroy() end)
Chams_Data[Plr] = nil
end
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

-- =============================================
-- TÜM ESP'Yİ TEMİZLE
-- =============================================
local function ClearAll(Plr)
if ESP_Data[Plr] then
for _, Obj in pairs(ESP_Data[Plr]) do
pcall(function() Obj:Remove() end)
end
ESP_Data[Plr] = nil
end
if Chams_Data[Plr] then
pcall(function() Chams_Data[Plr]:Destroy() end)
Chams_Data[Plr] = nil
end
end

-- =============================================
-- ESP OLUŞTUR
-- =============================================
local function CreateESP(Plr)
ClearAll(Plr)
local Char = Plr.Character
if not Char then return end
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

if S.ESP_Chams and not Chams_Data[Plr] and Char and Char.Parent then
UpdateChams(Plr, Char)
elseif not S.ESP_Chams and Chams_Data[Plr] then
pcall(function() Chams_Data[Plr]:Destroy() end) Chams_Data[Plr] = nil
end

if not Char or not Char.Parent or not Root or not Root.Parent then
Conn:Disconnect() ClearAll(Plr) return
end

local Pos, On = Camera:WorldToViewportPoint(Root.Position)
if not On then
for _, v in pairs(D) do pcall(function() v.Visible = false end) end
return
end

local Dist = (Camera.CFrame.Position - Root.Position).Magnitude
local Scale = 1000 / Dist
local H = math.abs((Head.Position.Y - Root.Position.Y) * 2.5) * Scale
local W = H / 2

if S.ESP_Box and D.Box then
D.Box.Position = Vector2.new(Pos.X - W/2, Pos.Y - H/2)
D.Box.Size = Vector2.new(W, H)
D.Box.Visible = true
elseif D.Box then D.Box.Visible = false end

if S.ESP_Name and D.Nam then
local Txt = Plr.Name
if S.ESP_Dist then Txt = Txt .. " [" .. math.floor(Dist) .. "m]" end
D.Nam.Text = Txt
D.Nam.Position = Vector2.new(Pos.X, Pos.Y - H/2 - 15)
D.Nam.Visible = true
elseif D.Nam then D.Nam.Visible = false end

if S.ESP_HP and D.HP then
local hp = Hum.Health / Hum.MaxHealth
local bh = H * hp
D.Hbg.Position = Vector2.new(Pos.X - W/2 - 6, Pos.Y - H/2)
D.Hbg.Size = Vector2.new(3, H)
D.Hbg.Visible = true
D.HP.Position = Vector2.new(Pos.X - W/2 - 6, Pos.Y + H/2 - bh)
D.HP.Size = Vector2.new(3, bh)
D.HP.Color = Color3.new(1 - hp, hp, 0)
D.HP.Visible = true
elseif D.HP then D.HP.Visible = false D.Hbg.Visible = false end

if S.ESP_Tracer and D.Tr then
D.Tr.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
D.Tr.To = Vector2.new(Pos.X, Pos.Y + H/2)
D.Tr.Visible = true
elseif D.Tr then D.Tr.Visible = false end
end)
end

-- =============================================
-- GUI (3 SEKME) - FIX: PlayerGui'ye ekle, CoreGui fallback
-- =============================================
local function CreateGUI()
local SG
local Success, Err = pcall(function()
-- Önce PlayerGui dene (çoğu oyunda çalışır)
local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
if not PlayerGui then
PlayerGui = Instance.new("ScreenGui")
PlayerGui.Name = "PlayerGui"
PlayerGui.Parent = LocalPlayer
end
SG = Instance.new("ScreenGui")
SG.Name = "GINSv3"
SG.ResetOnSpawn = false
SG.Parent = PlayerGui
end)

if not Success or not SG then
-- Fallback: CoreGui
pcall(function()
SG = Instance.new("ScreenGui")
SG.Name = "GINSv3"
SG.ResetOnSpawn = false
SG.Parent = CoreGui
end)
end

if not SG then
warn("GUI oluşturulamadı!")
return
end

local Main = Instance.new("Frame", SG)
Main.Size = UDim2.new(0, 210, 0, 300)
Main.Position = UDim2.new(1, -225, 0.2, 0) -- Düzeltildi: ekranın sağında görünür
Main.BackgroundColor3 = Color3.fromRGB(10,10,10)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,24)
Title.BackgroundColor3 = Color3.fromRGB(20,20,20)
Title.Text = "GINS v3.0"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12

local TabF = Instance.new("Frame", Main)
TabF.Size = UDim2.new(1,0,0,22)
TabF.Position = UDim2.new(0,0,0,24)
TabF.BackgroundColor3 = Color3.fromRGB(15,15,15)

local Pages = {}
local Tabs = {}

local function MakeTab(Name)
local Btn = Instance.new("TextButton", TabF)
Btn.Size = UDim2.new(1/3, -2, 1, 0)
Btn.Position = UDim2.new(#Tabs/3, 1, 0, 0)
Btn.BackgroundColor3 = Color3.fromRGB(25,25,25)
Btn.Text = Name
Btn.TextColor3 = Color3.new(0.7,0.7,0.7)
Btn.Font = Enum.Font.GothamBold
Btn.TextSize = 10
Btn.AutoButtonColor = false

local Page = Instance.new("ScrollingFrame", Main)
Page.Size = UDim2.new(1,-4,1,-50)
Page.Position = UDim2.new(0,2,0,48)
Page.BackgroundTransparency = 1
Page.ScrollBarThickness = 3
Page.CanvasSize = UDim2.new(0,0,0,200)
Page.Visible = false

Btn.MouseButton1Click:Connect(function()
for _, t in ipairs(Tabs) do t.BackgroundColor3 = Color3.fromRGB(25,25,25) end
Btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
for _, p in ipairs(Pages) do p.Visible = false end
Page.Visible = true
end)

table.insert(Tabs, Btn)
table.insert(Pages, Page)
return Page, Btn
end

local ESP_Page, ESP_Tab = MakeTab("ESP")
local AIM_Page, AIM_Tab = MakeTab("AIMBOT")
local SIL_Page, SIL_Tab = MakeTab("SILENT")

ESP_Tab.BackgroundColor3 = Color3.fromRGB(45,45,45)
ESP_Page.Visible = true

local function AddToggle(Page, Text, Default, CB, YT)
local Y = YT[1]
local F = Instance.new("Frame", Page)
F.Size = UDim2.new(1,0,0,20)
F.Position = UDim2.new(0,0,0,Y)
F.BackgroundTransparency = 1

local L = Instance.new("TextLabel", F)
L.Size = UDim2.new(0.6,0,1,0)
L.BackgroundTransparency = 1
L.Text = Text
L.TextColor3 = Color3.new(0.8,0.8,0.8)
L.Font = Enum.Font.Gotham
L.TextSize = 10
L.TextXAlignment = Enum.TextXAlignment.Left

local B = Instance.new("TextButton", F)
B.Size = UDim2.new(0,24,0,14)
B.Position = UDim2.new(1,-28,0,3)
B.Text = ""
B.BorderSizePixel = 0
B.BackgroundColor3 = Default and Color3.fromRGB(0,140,0) or Color3.fromRGB(140,0,0)

local State = Default
B.MouseButton1Click:Connect(function()
State = not State
B.BackgroundColor3 = State and Color3.fromRGB(0,140,0) or Color3.fromRGB(140,0,0)
CB(State)
end)
YT[1] = Y + 21
end

local EY = {0}
AddToggle(ESP_Page, "ESP Acik", true, function(v) S.ESP_On = v end, EY)
AddToggle(ESP_Page, "Kutular", true, function(v) S.ESP_Box = v end, EY)
AddToggle(ESP_Page, "Isimler", true, function(v) S.ESP_Name = v end, EY)
AddToggle(ESP_Page, "Can Bari", true, function(v) S.ESP_HP = v end, EY)
AddToggle(ESP_Page, "Cizgiler", true, function(v) S.ESP_Tracer = v end, EY)
AddToggle(ESP_Page, "Mesafe", true, function(v) S.ESP_Dist = v end, EY)
AddToggle(ESP_Page, "Chams", true, function(v)
S.ESP_Chams = v
for Plr, _ in pairs(Chams_Data) do
if v then
if Plr.Character then UpdateChams(Plr, Plr.Character) end
else
pcall(function() Chams_Data[Plr]:Destroy() end)
Chams_Data[Plr] = nil
end
end
end, EY)
ESP_Page.CanvasSize = UDim2.new(0,0,0,EY[1]+5)

local AY = {0}
AddToggle(AIM_Page, "Aimbot Acik", false, function(v) S.AIM_On = v end, AY)
AddToggle(AIM_Page, "Takim Kontrol", false, function(v) S.AIM_Team = v end, AY)
AddToggle(AIM_Page, "Gorunurluk", true, function(v) S.AIM_Vis = v end, AY)
AIM_Page.CanvasSize = UDim2.new(0,0,0,AY[1]+5)

local SY = {0}
AddToggle(SIL_Page, "Silent Acik", false, function(v) S.SIL_On = v end, SY)
AddToggle(SIL_Page, "Takim Kontrol", false, function(v) S.SIL_Team = v end, SY)
AddToggle(SIL_Page, "Gorunurluk", true, function(v) S.SIL_Vis = v end, SY)
SIL_Page.CanvasSize = UDim2.new(0,0,0,SY[1]+5)
end

-- =============================================
-- AIMBOT DÖNGÜSÜ
-- =============================================
RunService.RenderStepped:Connect(function()
if not S.AIM_On then return end
local T = GetTarget(S.AIM_FOV, S.AIM_Team, S.AIM_Vis)
if T and T.Character then
local Part = T.Character:FindFirstChild(S.AIM_Part) or T.Character:FindFirstChild("Head")
if Part then
local TP = Camera:WorldToViewportPoint(Part.Position)
local MP = UserInputService:GetMouseLocation()
local Sm = S.AIM_Smooth / 10
mousemoverel((TP.X - MP.X) * Sm, (TP.Y - MP.Y) * Sm)
end
end
end)

-- =============================================
-- SILENT AIM
-- =============================================
local OldNC
pcall(function()
OldNC = hookmetamethod(game, "__namecall", function(self, ...)
local args = {...}
local method = getnamecallmethod()
if method == "FireServer" and self.Name == "RemoteEvent" and S.SIL_On then
local T = GetTarget(S.SIL_FOV, S.SIL_Team, S.SIL_Vis)
if T and T.Character then
local Part = T.Character:FindFirstChild(S.SIL_Part) or T.Character:FindFirstChild("Head")
if Part and math.random(1,100) <= S.SIL_Chance then
if args[1] and typeof(args[1]) == "table" and args[1].Position then
args[1] = Part
end
end
end
end
return OldNC(self, unpack(args))
end)
end)

-- =============================================
-- OYUNCU EKLE / ÇIKAR
-- =============================================
local function AddPlayer(Plr)
if Plr == LocalPlayer then return end
Plr.CharacterAdded:Connect(function(Char)
task.wait(0.3)
CreateESP(Plr)
end)
if Plr.Character then CreateESP(Plr) end
end

for _, p in ipairs(Players:GetPlayers()) do AddPlayer(p) end
Players.PlayerAdded:Connect(AddPlayer)
Players.PlayerRemoving:Connect(ClearAll)

LocalPlayer.CharacterAdded:Connect(function()
for Plr, _ in pairs(ESP_Data) do ClearAll(Plr) end
for Plr, _ in pairs(Chams_Data) do ClearAll(Plr) end
end)

-- =============================================
-- CHAMS RENK SENKRONİZASYONU
-- =============================================
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

-- =============================================
-- BAŞLAT - GUI'yi oyuncu hazır olunca aç
-- =============================================
task.spawn(function()
-- Oyuncu karakteri hazır olana kadar bekle
while not LocalPlayer.Character or not LocalPlayer.Character.Parent do
task.wait(0.5)
end
task.wait(0.5) -- Ekstra bekleme
CreateGUI()
print("GINS v3.0 FINAL: ESP + AIMBOT + SILENT | GUI Fix | 3 Sekme Hazir")
end)
