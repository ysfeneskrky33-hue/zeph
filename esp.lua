local Oyuncular = game:GetService("Players")
local YerelOyuncu = Oyuncular.LocalPlayer
local Kamera = workspace.CurrentCamera
local Calisiyor = true
local RastgeleID = math.random(100000, 999999)

-- ESP Aktif/Pasif Değişkenleri
local ESP_Aktif = true
local Kutu_Aktif = true
local Isim_Aktif = true
local SaglikBari_Aktif = true
local Vurgu_Aktif = true
local Mesafe_Aktif = true
local DostRenk = Color3.fromRGB(50, 255, 50)
local DusmanRenk = Color3.fromRGB(255, 50, 50)

-- ESP Veri Deposu
local ESP_Listesi = {}

-- Ana ESP Ekranı (PlayerGui)
local ESP_Ekran = Instance.new("ScreenGui")
ESP_Ekran.Name = "FLUXO_GUI_" .. RastgeleID
ESP_Ekran.Parent = YerelOyuncu:WaitForChild("PlayerGui")
ESP_Ekran.ResetOnSpawn = false
ESP_Ekran.Enabled = true

-- // GUI KONTROL PANELİ \ --
local AnaPanel = Instance.new("ScreenGui")
AnaPanel.Name = "ESP_KONTROL_" .. RastgeleID
AnaPanel.Parent = game.CoreGui:FindFirstChild("RobloxGui") and game.CoreGui.RobloxGui or YerelOyuncu:WaitForChild("PlayerGui")
AnaPanel.ResetOnSpawn = false

local AnaCerceve = Instance.new("Frame")
AnaCerceve.Name = "AnaCerceve"
AnaCerceve.Size = UDim2.new(0, 280, 0, 340)
AnaCerceve.Position = UDim2.new(0.01, 0, 0.15, 0)
AnaCerceve.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
AnaCerceve.BorderSizePixel = 0
AnaCerceve.Active = true
AnaCerceve.Draggable = true
AnaCerceve.Parent = AnaPanel

-- Kenarlık
local Kenarlik = Instance.new("Frame")
Kenarlik.Size = UDim2.new(1, 4, 1, 4)
Kenarlik.Position = UDim2.new(0, -2, 0, -2)
Kenarlik.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
Kenarlik.BorderSizePixel = 0
Kenarlik.BackgroundTransparency = 0.5
Kenarlik.ZIndex = 0
Kenarlik.Parent = AnaCerceve

-- Başlık
local Baslik = Instance.new("TextLabel")
Baslik.Text = "FLUXO ESP | v1.0"
Baslik.Size = UDim2.new(1, 0, 0, 30)
Baslik.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Baslik.TextColor3 = Color3.fromRGB(0, 255, 120)
Baslik.Font = Enum.Font.Code
Baslik.TextSize = 14
Baslik.BorderSizePixel = 0
Baslik.Parent = AnaCerceve

-- Kapatma Butonu
local KapatButon = Instance.new("TextButton")
KapatButon.Text = "X"
KapatButon.Size = UDim2.new(0, 30, 0, 30)
KapatButon.Position = UDim2.new(1, -30, 0, 0)
KapatButon.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
KapatButon.TextColor3 = Color3.new(1,1,1)
KapatButon.Font = Enum.Font.Code
KapatButon.TextSize = 16
KapatButon.BorderSizePixel = 0
KapatButon.Parent = AnaCerceve

-- Gizle/Göster Butonu
local GizleButon = Instance.new("TextButton")
GizleButon.Text = "-"
GizleButon.Size = UDim2.new(0, 30, 0, 30)
GizleButon.Position = UDim2.new(1, -60, 0, 0)
GizleButon.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
GizleButon.TextColor3 = Color3.new(1,1,1)
GizleButon.Font = Enum.Font.Code
GizleButon.TextSize = 16
GizleButon.BorderSizePixel = 0
GizleButon.Parent = AnaCerceve

-- İçerik Alanı
local IcerikAlani = Instance.new("ScrollingFrame")
IcerikAlani.Size = UDim2.new(1, -10, 1, -40)
IcerikAlani.Position = UDim2.new(0, 5, 0, 35)
IcerikAlani.BackgroundTransparency = 1
IcerikAlani.BorderSizePixel = 0
IcerikAlani.ScrollBarThickness = 4
IcerikAlani.CanvasSize = UDim2.new(0, 0, 0, 620)
IcerikAlani.Parent = AnaCerceve

-- // YARDIMCI FONKSİYONLAR \ --
local function ButonOlustur(Isim, Y, Ebeveyn)
local Buton = Instance.new("TextButton")
Buton.Text = Isim
Buton.Size = UDim2.new(1, -10, 0, 28)
Buton.Position = UDim2.new(0, 5, 0, Y)
Buton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Buton.TextColor3 = Color3.new(1,1,1)
Buton.Font = Enum.Font.Code
Buton.TextSize = 12
Buton.BorderSizePixel = 0
Buton.AutoButtonColor = true
Buton.Parent = Ebeveyn
return Buton
end

local function EtiketOlustur(Metin, Y, Ebeveyn, Renk)
local Etiket = Instance.new("TextLabel")
Etiket.Text = Metin
Etiket.Size = UDim2.new(1, -10, 0, 18)
Etiket.Position = UDim2.new(0, 5, 0, Y)
Etiket.BackgroundTransparency = 1
Etiket.TextColor3 = Renk or Color3.new(1,1,1)
Etiket.Font = Enum.Font.Code
Etiket.TextSize = 11
Etiket.TextXAlignment = Enum.TextXAlignment.Left
Etiket.Parent = Ebeveyn
return Etiket
end

-- // GUI BUTONLARI VE AYARLAR \ --
local y_offset = 5

EtiketOlustur("=== GENEL AYARLAR ===", y_offset, IcerikAlani, Color3.fromRGB(0, 200, 255))
y_offset = y_offset + 22

-- ESP Aç/Kapa Butonu
local ESButon = ButonOlustur("ESP: ACIK", y_offset, IcerikAlani)
ESButon.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
y_offset = y_offset + 32

-- Kutu ESP Aç/Kapa
local KutuButon = ButonOlustur("KUTU: ACIK", y_offset, IcerikAlani)
KutuButon.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
y_offset = y_offset + 32

-- İsim ESP Aç/Kapa
local IsimButon = ButonOlustur("ISIM: ACIK", y_offset, IcerikAlani)
IsimButon.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
y_offset = y_offset + 32

-- Sağlık Barı Aç/Kapa
local SaglikButon = ButonOlustur("SAGLIK BARI: ACIK", y_offset, IcerikAlani)
SaglikButon.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
y_offset = y_offset + 32

-- Vurgu Aç/Kapa
local VurguButon = ButonOlustur("VURGU: ACIK", y_offset, IcerikAlani)
VurguButon.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
y_offset = y_offset + 32

-- Mesafe Gösterimi Aç/Kapa
local MesafeButon = ButonOlustur("MESAFE: ACIK", y_offset, IcerikAlani)
MesafeButon.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
y_offset = y_offset + 40

EtiketOlustur("=== RENK AYARLARI ===", y_offset, IcerikAlani, Color3.fromRGB(255, 200, 50))
y_offset = y_offset + 22

-- Düşman Rengi
EtiketOlustur("Dusman Rengi:", y_offset, IcerikAlani, Color3.fromRGB(255, 100, 100))
y_offset = y_offset + 16

local DusmanKirmizi = ButonOlustur("KIRMIZI [SEÇILI]", y_offset, IcerikAlani)
DusmanKirmizi.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
y_offset = y_offset + 28

local DusmanMavi = ButonOlustur("MAVI", y_offset, IcerikAlani)
DusmanMavi.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
y_offset = y_offset + 28

local DusmanSari = ButonOlustur("SARI", y_offset, IcerikAlani)
DusmanSari.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
y_offset = y_offset + 28

local DusmanMor = ButonOlustur("MOR", y_offset, IcerikAlani)
DusmanMor.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
y_offset = y_offset + 35

-- Dost Rengi
EtiketOlustur("Dost Rengi:", y_offset, IcerikAlani, Color3.fromRGB(100, 255, 100))
y_offset = y_offset + 16

local DostYesil = ButonOlustur("YESIL [SEÇILI]", y_offset, IcerikAlani)
DostYesil.BackgroundColor3 = Color3.fromRGB(30, 200, 30)
y_offset = y_offset + 28

local DostMavi = ButonOlustur("MAVI", y_offset, IcerikAlani)
DostMavi.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
y_offset = y_offset + 28

local DostBeyaz = ButonOlustur("BEYAZ", y_offset, IcerikAlani)
DostBeyaz.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
y_offset = y_offset + 28

local DostTuruncu = ButonOlustur("TURUNCU", y_offset, IcerikAlani)
DostTuruncu.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
y_offset = y_offset + 35

-- ESP'yi Sıfırla Butonu
local SifirlaButon = ButonOlustur("TUM ESP'YI YENIDEN BASLAT", y_offset, IcerikAlani)
SifirlaButon.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
y_offset = y_offset + 40

-- Kredi
EtiketOlustur("palo | Fluxo Bypass", y_offset, IcerikAlani, Color3.fromRGB(100, 100, 100))

IcerikAlani.CanvasSize = UDim2.new(0, 0, 0, y_offset + 20)

-- // BUTON FONKSİYONLARI \ --
local function ButonGuncelle(Buton, Durum, MetinAcik, MetinKapali)
if Durum then
Buton.Text = MetinAcik
Buton.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
else
Buton.Text = MetinKapali
Buton.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
end
end

ESButon.MouseButton1Click:Connect(function()
ESP_Aktif = not ESP_Aktif
ButonGuncelle(ESButon, ESP_Aktif, "ESP: ACIK", "ESP: KAPALI")
end)

KutuButon.MouseButton1Click:Connect(function()
Kutu_Aktif = not Kutu_Aktif
ButonGuncelle(KutuButon, Kutu_Aktif, "KUTU: ACIK", "KUTU: KAPALI")
for _, Veri in pairs(ESP_Listesi) do
if Veri.KutuGovde then Veri.KutuGovde.Enabled = Kutu_Aktif end
end
end)

IsimButon.MouseButton1Click:Connect(function()
Isim_Aktif = not Isim_Aktif
ButonGuncelle(IsimButon, Isim_Aktif, "ISIM: ACIK", "ISIM: KAPALI")
for _, Veri in pairs(ESP_Listesi) do
if Veri.IsimEtiketi then Veri.IsimEtiketi.Enabled = Isim_Aktif end
end
end)

SaglikButon.MouseButton1Click:Connect(function()
SaglikBari_Aktif = not SaglikBari_Aktif
ButonGuncelle(SaglikButon, SaglikBari_Aktif, "SAGLIK BARI: ACIK", "SAGLIK BARI: KAPALI")
for _, Veri in pairs(ESP_Listesi) do
if Veri.SaglikBarArka then Veri.SaglikBarArka.Visible = SaglikBari_Aktif end
end
end)

VurguButon.MouseButton1Click:Connect(function()
Vurgu_Aktif = not Vurgu_Aktif
ButonGuncelle(VurguButon, Vurgu_Aktif, "VURGU: ACIK", "VURGU: KAPALI")
for _, Veri in pairs(ESP_Listesi) do
if Veri.VurguGovde then Veri.VurguGovde.Enabled = Vurgu_Aktif end
end
end)

MesafeButon.MouseButton1Click:Connect(function()
Mesafe_Aktif = not Mesafe_Aktif
ButonGuncelle(MesafeButon, Mesafe_Aktif, "MESAFE: ACIK", "MESAFE: KAPALI")
end)

-- Renk Butonları
local SeciliDusmanButon = DusmanKirmizi
local SeciliDostButon = DostYesil

local function DusmanRenkSec(Buton, Renk)
SeciliDusmanButon.Text = SeciliDusmanButon.Text:gsub(" %[SEÇILI%]", "")
SeciliDusmanButon.BackgroundColor3 = Color3.fromRGB(35,35,35)
Buton.Text = Buton.Text:gsub(" %[SEÇILI%]", "") .. " [SEÇILI]"
Buton.BackgroundColor3 = Renk
SeciliDusmanButon = Buton
DusmanRenk = Renk
end

local function DostRenkSec(Buton, Renk)
SeciliDostButon.Text = SeciliDostButon.Text:gsub(" %[SEÇILI%]", "")
SeciliDostButon.BackgroundColor3 = Color3.fromRGB(35,35,35)
Buton.Text = Buton.Text:gsub(" %[SEÇILI%]", "") .. " [SEÇILI]"
Buton.BackgroundColor3 = Renk
SeciliDostButon = Buton
DostRenk = Renk
end

DusmanKirmizi.MouseButton1Click:Connect(function() DusmanRenkSec(DusmanKirmizi, Color3.fromRGB(255, 50, 50)) end)
DusmanMavi.MouseButton1Click:Connect(function() DusmanRenkSec(DusmanMavi, Color3.fromRGB(50, 100, 255)) end)
DusmanSari.MouseButton1Click:Connect(function() DusmanRenkSec(DusmanSari, Color3.fromRGB(255, 255, 50)) end)
DusmanMor.MouseButton1Click:Connect(function() DusmanRenkSec(DusmanMor, Color3.fromRGB(180, 50, 255)) end)

DostYesil.MouseButton1Click:Connect(function() DostRenkSec(DostYesil, Color3.fromRGB(50, 255, 50)) end)
DostMavi.MouseButton1Click:Connect(function() DostRenkSec(DostMavi, Color3.fromRGB(50, 100, 255)) end)
DostBeyaz.MouseButton1Click:Connect(function() DostRenkSec(DostBeyaz, Color3.fromRGB(255, 255, 255)) end)
DostTuruncu.MouseButton1Click:Connect(function() DostRenkSec(DostTuruncu, Color3.fromRGB(255, 150, 50)) end)

SifirlaButon.MouseButton1Click:Connect(function()
for Hedef, _ in pairs(ESP_Listesi) do
ESP_Sil(Hedef)
end
wait(0.2)
for _, Hedef in pairs(Oyuncular:GetPlayers()) do
if OyuncuGecerliMi(Hedef) then
ESP_Olustur(Hedef)
end
end
end)

KapatButon.MouseButton1Click:Connect(function()
AnaPanel:Destroy()
getgenv().ESP_Kapat()
end)

local PanelGizli = false
GizleButon.MouseButton1Click:Connect(function()
PanelGizli = not PanelGizli
IcerikAlani.Visible = not PanelGizli
GizleButon.Text = PanelGizli and "+" or "-"
AnaCerceve.Size = PanelGizli and UDim2.new(0, 280, 0, 35) or UDim2.new(0, 280, 0, 340)
end)

-- // ESP FONKSİYONLARI (GUI Kontrolleriyle Entegre) \ --
local function OyuncuGecerliMi(Hedef)
return Hedef and Hedef ~= YerelOyuncu and Hedef.Character and Hedef.Character:FindFirstChild("Humanoid") and Hedef.Character:FindFirstChild("Head") and Hedef.Character.Humanoid.Health > 0
end

function ESP_Olustur(Hedef)
if ESP_Listesi[Hedef] then return end
local Veri = {}
local Karakter = Hedef.Character
local Govde = Karakter:WaitForChild("HumanoidRootPart") or Karakter:FindFirstChild("UpperTorso")

-- Kutu Govde
local KutuGovde = Instance.new("BillboardGui")
KutuGovde.Name = "ESP_Kutu_" .. RastgeleID
KutuGovde.Size = UDim2.new(0, 0, 0, 0)
KutuGovde.StudsOffset = Vector3.new(0, -2.8, 0)
KutuGovde.AlwaysOnTop = true
KutuGovde.MaxDistance = 2000
KutuGovde.Enabled = Kutu_Aktif
KutuGovde.Parent = Govde or Karakter.Head

local UstCizgi = Instance.new("Frame"); UstCizgi.BackgroundColor3 = Color3.fromRGB(255,50,50); UstCizgi.BorderSizePixel = 0; UstCizgi.Parent = KutuGovde
local AltCizgi = Instance.new("Frame"); AltCizgi.BackgroundColor3 = Color3.fromRGB(255,50,50); AltCizgi.BorderSizePixel = 0; AltCizgi.Parent = KutuGovde
local SolCizgi = Instance.new("Frame"); SolCizgi.BackgroundColor3 = Color3.fromRGB(255,50,50); SolCizgi.BorderSizePixel = 0; SolCizgi.Parent = KutuGovde
local SagCizgi = Instance.new("Frame"); SagCizgi.BackgroundColor3 = Color3.fromRGB(255,50,50); SagCizgi.BorderSizePixel = 0; SagCizgi.Parent = KutuGovde

local SaglikBarArka = Instance.new("Frame"); SaglikBarArka.BackgroundColor3 = Color3.fromRGB(0,0,0); SaglikBarArka.BorderSizePixel = 0; SaglikBarArka.BackgroundTransparency = 0.5; SaglikBarArka.Visible = SaglikBari_Aktif; SaglikBarArka.Parent = KutuGovde
local SaglikBarDolgu = Instance.new("Frame"); SaglikBarDolgu.BackgroundColor3 = Color3.fromRGB(0,255,80); SaglikBarDolgu.BorderSizePixel = 0; SaglikBarDolgu.Parent = SaglikBarArka

-- İsim
local IsimEtiketi = Instance.new("BillboardGui")
IsimEtiketi.Name = "ESP_Isim_" .. RastgeleID
IsimEtiketi.Size = UDim2.new(0, 250, 0, 45)
IsimEtiketi.StudsOffset = Vector3.new(0, 2.5, 0)
IsimEtiketi.AlwaysOnTop = true
IsimEtiketi.MaxDistance = 2000
IsimEtiketi.Enabled = Isim_Aktif
IsimEtiketi.Parent = Karakter.Head

local EtiketMetni = Instance.new("TextLabel")
EtiketMetni.Size = UDim2.new(1,0,1,0); EtiketMetni.BackgroundTransparency = 1; EtiketMetni.TextColor3 = Color3.new(1,1,1)
EtiketMetni.TextStrokeTransparency = 0.4; EtiketMetni.TextStrokeColor3 = Color3.new(0,0,0)
EtiketMetni.Font = Enum.Font.Code; EtiketMetni.TextSize = 11; EtiketMetni.Parent = IsimEtiketi

-- Vurgu
local VurguGovde = Instance.new("BillboardGui")
VurguGovde.Name = "ESP_Vurgu_" .. RastgeleID
VurguGovde.Size = UDim2.new(0,0,0,0); VurguGovde.AlwaysOnTop = false; VurguGovde.MaxDistance = 500
VurguGovde.LightInfluence = 0; VurguGovde.Enabled = Vurgu_Aktif
VurguGovde.Parent = Govde or Karakter.Head

local VurguCerceve = Instance.new("Frame")
VurguCerceve.BackgroundTransparency = 0.7; VurguCerceve.BackgroundColor3 = Color3.fromRGB(255,50,50)
VurguCerceve.BorderSizePixel = 2; VurguCerceve.BorderColor3 = Color3.fromRGB(255,50,50); VurguCerceve.Parent = VurguGovde

Veri = {
KutuGovde = KutuGovde, UstCizgi = UstCizgi, AltCizgi = AltCizgi, SolCizgi = SolCizgi, SagCizgi = SagCizgi,
SaglikBarArka = SaglikBarArka, SaglikBarDolgu = SaglikBarDolgu,
IsimEtiketi = IsimEtiketi, EtiketMetni = EtiketMetni,
VurguGovde = VurguGovde, VurguCerceve = VurguCerceve
}
ESP_Listesi[Hedef] = Veri
end

function ESP_Sil(Hedef)
local Veri = ESP_Listesi[Hedef]
if not Veri then return end
if Veri.KutuGovde then Veri.KutuGovde:Destroy() end
if Veri.IsimEtiketi then Veri.IsimEtiketi:Destroy() end
if Veri.VurguGovde then Veri.VurguGovde:Destroy() end
ESP_Listesi[Hedef] = nil
end

local function ESP_Guncelle()
while Calisiyor do
if ESP_Aktif then
local YerelKarakter = YerelOyuncu.Character
local YerelPoz = YerelKarakter and YerelKarakter:FindFirstChild("HumanoidRootPart") and YerelKarakter.HumanoidRootPart.Position

for _, Hedef in pairs(Oyuncular:GetPlayers()) do
if OyuncuGecerliMi(Hedef) then
if not ESP_Listesi[Hedef] then ESP_Olustur(Hedef) end
local Veri = ESP_Listesi[Hedef]
if Veri then
local Karakter = Hedef.Character
local Kafa = Karakter.Head
local Govde = Karakter:FindFirstChild("HumanoidRootPart") or Karakter:FindFirstChild("UpperTorso")
local Insansi = Karakter.Humanoid
local Saglik = Insansi.Health; local MaxSaglik = Insansi.MaxHealth
local Mesafe = YerelPoz and (YerelPoz - Kafa.Position).Magnitude or 0

local DostMu = false
if YerelOyuncu.Team and Hedef.Team then DostMu = YerelOyuncu.Team == Hedef.Team end
local Renk = DostMu and DostRenk or DusmanRenk

-- İsim Güncelleme
if Mesafe_Aktif then
Veri.EtiketMetni.Text = string.format("%s\n[%d HP | %.0f m]", Hedef.Name, Saglik, Mesafe)
else
Veri.EtiketMetni.Text = string.format("%s\n[%d HP]", Hedef.Name, Saglik)
end
Veri.EtiketMetni.TextColor3 = Renk

-- Kutu Boyutlandırma
local EkranPoz, EkranGorunur = Kamera:WorldToViewportPoint(Kafa.Position)
if EkranGorunur then
local YukseklikStuds = math.clamp(Mesafe * 0.018, 4, 8)
local GenislikStuds = YukseklikStuds * 0.55
Veri.KutuGovde.Size = UDim2.new(0, GenislikStuds * 20, 0, YukseklikStuds * 20)
Veri.KutuGovde.StudsOffset = Vector3.new(0, -YukseklikStuds/2, 0)

Veri.UstCizgi.Size = UDim2.new(1,0,0,2); Veri.UstCizgi.Position = UDim2.new(0,0,0,0); Veri.UstCizgi.BackgroundColor3 = Renk
Veri.AltCizgi.Size = UDim2.new(1,0,0,2); Veri.AltCizgi.Position = UDim2.new(0,0,1,-2); Veri.AltCizgi.BackgroundColor3 = Renk
Veri.SolCizgi.Size = UDim2.new(0,2,1,0); Veri.SolCizgi.Position = UDim2.new(0,0,0,0); Veri.SolCizgi.BackgroundColor3 = Renk
Veri.SagCizgi.Size = UDim2.new(0,2,1,0); Veri.SagCizgi.Position = UDim2.new(1,-2,0,0); Veri.SagCizgi.BackgroundColor3 = Renk

local SaglikOrani = Saglik / MaxSaglik
Veri.SaglikBarArka.Size = UDim2.new(0,4,1,0); Veri.SaglikBarArka.Position = UDim2.new(0,-8,0,0)
Veri.SaglikBarDolgu.Size = UDim2.new(1,0,SaglikOrani,0); Veri.SaglikBarDolgu.Position = UDim2.new(0,0,1-SaglikOrani,0)
Veri.SaglikBarDolgu.BackgroundColor3 = Color3.fromRGB(255(1-SaglikOrani), 255SaglikOrani, 40)

Veri.KutuGovde.Enabled = Kutu_Aktif
Veri.SaglikBarArka.Visible = SaglikBari_Aktif
else
Veri.KutuGovde.Enabled = false
Veri.SaglikBarArka.Visible = false
end

Veri.VurguCerceve.BackgroundColor3 = Renk
Veri.VurguCerceve.BorderColor3 = Renk
Veri.VurguGovde.Enabled = Vurgu_Aktif
end
else
if ESP_Listesi[Hedef] then ESP_Sil(Hedef) end
end
end
end
wait(0.05)
end
end

-- Oyuncu Olayları
Oyuncular.PlayerAdded:Connect(function(Hedef)
Hedef.CharacterAdded:Connect(function()
wait(0.5)
if OyuncuGecerliMi(Hedef) then ESP_Olustur(Hedef) end
end)
end)

Oyuncular.PlayerRemoving:Connect(function(Hedef) ESP_Sil(Hedef) end)

-- Mevcut Oyuncular
for _, Hedef in pairs(Oyuncular:GetPlayers()) do
if Hedef ~= YerelOyuncu and Hedef.Character and OyuncuGecerliMi(Hedef) then ESP_Olustur(Hedef) end
Hedef.CharacterAdded:Connect(function()
wait(0.5)
if OyuncuGecerliMi(Hedef) then ESP_Olustur(Hedef) end
end)
end

spawn(ESP_Guncelle)

getgenv().ESP_Kapat = function()
Calisiyor = false
for Hedef, _ in pairs(ESP_Listesi) do ESP_Sil(Hedef) end
ESP_Ekran:Destroy()
if AnaPanel then AnaPanel:Destroy() end
end
