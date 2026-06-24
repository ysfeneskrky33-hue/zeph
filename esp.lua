local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local ESP_List = {}
local ESP_Folder = Instance.new("Folder", CoreGui)
ESP_Folder.Name = "ESP_Holder"

local function CreateESP(Player)
    local Char = Player.Character
    if not Char then return end
    local Root = Char:FindFirstChild("HumanoidRootPart")
    local Head = Char:FindFirstChild("Head")
    local Hum = Char:FindFirstChild("Humanoid")
    if not Root or not Head or not Hum then return end
    if ESP_List[Player] then
        for _,v in pairs(ESP_List[Player]) do if v.Remove then v:Remove() end end
    end
    ESP_List[Player] = {}
    if Drawing then
        local Box = Drawing.new("Square")
        Box.Thickness = 1
        Box.Filled = false
        Box.Color = Color3.new(1,1,1)
        Box.Visible = false
        ESP_List[Player].Box = Box
        local Name = Drawing.new("Text")
        Name.Size = 13
        Name.Center = true
        Name.Outline = true
        Name.Color = Color3.new(1,1,1)
        Name.Visible = false
        ESP_List[Player].Name = Name
        local HPbg = Drawing.new("Square")
        HPbg.Filled = true
        HPbg.Color = Color3.new(0,0,0)
        HPbg.Visible = false
        ESP_List[Player].HPbg = HPbg
        local HP = Drawing.new("Square")
        HP.Filled = true
        HP.Visible = false
        ESP_List[Player].HP = HP
        local Tracer = Drawing.new("Line")
        Tracer.Thickness = 1
        Tracer.Color = Color3.new(1,1,1)
        Tracer.Visible = false
        ESP_List[Player].Tracer = Tracer
    end
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not Char or not Char.Parent then conn:Disconnect() return end
        local pos, on = Camera:WorldToViewportPoint(Root.Position)
        if not on then for _,v in pairs(ESP_List[Player]) do v.Visible = false end return end
        local dist = (Camera.CFrame.Position - Root.Position).Magnitude
        local s = 1000 / dist
        local h = math.abs((Head.Position.Y - Root.Position.Y)*2.5)*s
        local w = h/2
        if ESP_List[Player].Box then
            ESP_List[Player].Box.Position = Vector2.new(pos.X-w/2, pos.Y-h/2)
            ESP_List[Player].Box.Size = Vector2.new(w,h)
            ESP_List[Player].Box.Visible = true
        end
        if ESP_List[Player].Name then
            ESP_List[Player].Name.Text = Player.Name.." ["..math.floor(dist).."m]"
            ESP_List[Player].Name.Position = Vector2.new(pos.X, pos.Y-h/2-15)
            ESP_List[Player].Name.Visible = true
        end
        if ESP_List[Player].HP then
            local hp = Hum.Health/Hum.MaxHealth
            local bh = h*hp
            ESP_List[Player].HPbg.Position = Vector2.new(pos.X-w/2-6, pos.Y-h/2)
            ESP_List[Player].HPbg.Size = Vector2.new(3,h)
            ESP_List[Player].HPbg.Visible = true
            ESP_List[Player].HP.Position = Vector2.new(pos.X-w/2-6, pos.Y+h/2-bh)
            ESP_List[Player].HP.Size = Vector2.new(3,bh)
            ESP_List[Player].HP.Color = Color3.new(1-hp,hp,0)
            ESP_List[Player].HP.Visible = true
        end
        if ESP_List[Player].Tracer then
            ESP_List[Player].Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            ESP_List[Player].Tracer.To = Vector2.new(pos.X, pos.Y+h/2)
            ESP_List[Player].Tracer.Visible = true
        end
    end)
end

for _,p in ipairs(Players:GetPlayers()) do
    if p~=LocalPlayer then p.CharacterAdded:Connect(function() task.wait(0.3) CreateESP(p) end) if p.Character then CreateESP(p) end end
end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(0.3) CreateESP(p) end) end)
print("ESP Hazir")
