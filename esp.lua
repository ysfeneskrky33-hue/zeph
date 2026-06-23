local Oyuncular = game:GetService("Players")
local YerelOyuncu = Oyuncular.LocalPlayer
local Kamera = workspace.CurrentCamera
local Calisiyor = true

local ESP_Ekran = Instance.new("ScreenGui")
ESP_Ekran.Name = "PALO_ESP"
ESP_Ekran.Parent = game.CoreGui
ESP_Ekran.ResetOnSpawn = false

local ESP_Listesi = {}

local function OyuncuGecerliMi(Hedef)
return Hedef and Hedef ~= YerelOyuncu and Hedef.Character and Hedef.Character:FindFirstChild("Humanoid") and Hedef.Character:FindFirstChild("Head") and Hedef.Character.Humanoid.Health > 0
end

local function ESP_Olustur(Hedef)
if ESP_Listesi[Hedef] then return end
local Veri = {}

local Vurgulayici = Instance.new("Highlight")
Vurgulayici.Name = "ESP_Vurgu"
Vurgulayici.FillTransparency = 1
Vurgulayici.OutlineTransparency = 0.3
Vurgulayici.OutlineColor = Color3.fromRGB(255, 50, 50)
Vurgulayici.Parent = Hedef.Character
Veri.Vurgulayici = Vurgulayici

local IsimEtiketi = Instance.new("BillboardGui")
IsimEtiketi.Name = "ESP_Isim"
IsimEtiketi.Size = UDim2.new(0, 200, 0, 40)
IsimEtiketi.StudsOffset = Vector3.new(0, 2.5, 0)
IsimEtiketi.AlwaysOnTop = true
IsimEtiketi.MaxDistance = 2000
IsimEtiketi.Parent = Hedef.Character.Head

local EtiketMetni = Instance.new("TextLabel")
EtiketMetni.Size = UDim2.new(1, 0, 1, 0)
EtiketMetni.BackgroundTransparency = 1
EtiketMetni.TextColor3 = Color3.fromRGB(255, 255, 255)
EtiketMetni.TextStrokeTransparency = 0.3
EtiketMetni.TextStrokeColor3 = Color3.fromRGB(0,0,0)
EtiketMetni.Font = Enum.Font.Code
EtiketMetni.TextSize = 12
EtiketMetni.Parent = IsimEtiketi
Veri.IsimEtiketi = IsimEtiketi
Veri.EtiketMetni = EtiketMetni

local Kutu = Drawing.new("Square")
Kutu.Visible = true
Kutu.Color = Color3.fromRGB(255, 50, 50)
Kutu.Thickness = 1.5
Kutu.Transparency = 1
Kutu.Filled = false
Veri.Kutu = Kutu

local SaglikBar = Drawing.new("Square")
SaglikBar.Visible = true
SaglikBar.Filled = true
SaglikBar.Color = Color3.fromRGB(0, 255, 80)
SaglikBar.Thickness = 1
SaglikBar.Transparency = 1
Veri.SaglikBar = SaglikBar

ESP_Listesi[Hedef] = Veri
end

local function ESP_Sil(Hedef)
local Veri = ESP_Listesi[Hedef]
if not Veri then return end
if Veri.Vurgulayici then Veri.Vurgulayici:Destroy() end
if Veri.IsimEtiketi then Veri.IsimEtiketi:Destroy() end
if Veri.Kutu then Veri.Kutu:Remove() end
if Veri.SaglikBar then Veri.SaglikBar:Remove() end
ESP_Listesi[Hedef] = nil
end

local function ESP_Guncelle()
while Calisiyor do
for _, Hedef in pairs(Oyuncular:GetPlayers()) do
if OyuncuGecerliMi(Hedef) then
if not ESP_Listesi[Hedef] then
ESP_Olustur(Hedef)
end
local Veri = ESP_Listesi[Hedef]
if Veri then
local Karakter = Hedef.Character
local Kafa = Karakter.Head
local Govde = Karakter:FindFirstChild("HumanoidRootPart") or Karakter:FindFirstChild("UpperTorso")
local Insansi = Karakter.Humanoid
local Saglik = Insansi.Health
local MaxSaglik = Insansi.MaxHealth

local Mesafe = (YerelOyuncu.Character and YerelOyuncu.Character:FindFirstChild("HumanoidRootPart")) and (YerelOyuncu.Character.HumanoidRootPart.Position - Kafa.Position).Magnitude or 0
Veri.EtiketMetni.Text = string.format("%s\n[%d HP | %.0f m]", Hedef.Name, Saglik, Mesafe)

local DostMu = false
if YerelOyuncu.Team and Hedef.Team then
DostMu = YerelOyuncu.Team == Hedef.Team
end
local Renk = DostMu and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 80, 80)
Veri.Vurgulayici.OutlineColor = Renk
Veri.EtiketMetni.TextColor3 = Renk
Veri.Kutu.Color = Renk

local EkranPoz, EkranGorunur = Kamera:WorldToViewportPoint(Kafa.Position)
local GovdeEkran, _ = Kamera:WorldToViewportPoint((Govde or Kafa).Position - Vector3.new(0, 2.8, 0))
local AyakEkran, _ = Kamera:WorldToViewportPoint((Govde or Kafa).Position - Vector3.new(0, 5.5, 0))

if EkranGorunur then
local Yukseklik = math.abs(GovdeEkran.Y - AyakEkran.Y)
local Genislik = Yukseklik * 0.55
local KutuX = EkranPoz.X - Genislik / 2
local KutuY = EkranPoz.Y - Yukseklik * 0.1

Veri.Kutu.Size = Vector2.new(Genislik, Yukseklik)
Veri.Kutu.Position = Vector2.new(KutuX, KutuY)
Veri.Kutu.Visible = true

local BarGenislik = 3
local BarYukseklik = Yukseklik * (Saglik / MaxSaglik)
local BarX = KutuX - BarGenislik - 2
local BarY = KutuY + (Yukseklik - BarYukseklik)

Veri.SaglikBar.Size = Vector2.new(BarGenislik, BarYukseklik)
Veri.SaglikBar.Position = Vector2.new(BarX, BarY)
Veri.SaglikBar.Color = Color3.fromRGB(255 * (1 - Saglik/MaxSaglik), 255 * (Saglik/MaxSaglik), 40)
Veri.SaglikBar.Visible = true
else
Veri.Kutu.Visible = false
Veri.SaglikBar.Visible = false
end
end
else
if ESP_Listesi[Hedef] then
ESP_Sil(Hedef)
end
end
end
wait(0.03)
end
end

Oyuncular.PlayerAdded:Connect(function(Hedef)
Hedef.CharacterAdded:Connect(function()
wait(0.5)
if OyuncuGecerliMi(Hedef) then
ESP_Olustur(Hedef)
end
end)
end)

Oyuncular.PlayerRemoving:Connect(function(Hedef)
ESP_Sil(Hedef)
end)

for _, Hedef in pairs(Oyuncular:GetPlayers()) do
if Hedef ~= YerelOyuncu and Hedef.Character then
if OyuncuGecerliMi(Hedef) then
ESP_Olustur(Hedef)
end
end
Hedef.CharacterAdded:Connect(function()
wait(0.5)
if OyuncuGecerliMi(Hedef) then
ESP_Olustur(Hedef)
end
end)
end

spawn(ESP_Guncelle)

getgenv().ESP_Kapat = function()
Calisiyor = false
for Hedef, _ in pairs(ESP_Listesi) do
ESP_Sil(Hedef)
end
ESP_Ekran:Destroy()
end
