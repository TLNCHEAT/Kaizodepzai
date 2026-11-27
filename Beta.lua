-- Kaizo Prime | Urban Reload | Delta Full
-- RightShift = menu | RMB = aim
-- F=Head G=Body H=AimToggle E=ESPToggle

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

local Cfg = {
    AimOn = true,
    ESPOn = true,
    FOV = 150,
    Smooth = 0.15,
    Part = "Head",
    TeamCheck = false,
    MaxDist = 600,
    MenuOpen = true,
}

-- DETECT AIM API
local AimAPI = "none"
if pcall(function() mousemoveto(Mouse.X, Mouse.Y) end) then
    AimAPI = "moveto"
elseif pcall(function() mousemoverel(0, 0) end) then
    AimAPI = "moverel"
elseif pcall(function()
    local VIM = game:GetService("VirtualInputManager")
    local m = UIS:GetMouseLocation()
    VIM:SendMouseMoveEvent(m.X, m.Y, Camera)
end) then
    AimAPI = "vim"
elseif pcall(function() syn.mouse_moverel(0, 0) end) then
    AimAPI = "syn"
end
print("[Kaizo Prime] AimAPI: " .. AimAPI)

local function MoveAim(tx, ty)
    local mx = Mouse.X
    local my = Mouse.Y
    local nx = mx + (tx - mx) * Cfg.Smooth
    local ny = my + (ty - my) * Cfg.Smooth
    local dx = (tx - mx) * Cfg.Smooth
    local dy = (ty - my) * Cfg.Smooth
    if AimAPI == "moveto" then
        pcall(mousemoveto, nx, ny)
    elseif AimAPI == "moverel" then
        pcall(mousemoverel, dx, dy)
    elseif AimAPI == "vim" then
        pcall(function()
            local VIM = game:GetService("VirtualInputManager")
            VIM:SendMouseMoveEvent(nx, ny, Camera)
        end)
    elseif AimAPI == "syn" then
        pcall(function() syn.mouse_moverel(dx, dy) end)
    end
end

-- GUI
local SG = Instance.new("ScreenGui")
SG.Name = "KaizoPrime"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() SG.Parent = game:GetService("CoreGui") end)
if not SG.Parent then SG.Parent = LP.PlayerGui end

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 230, 0, 330)
Main.Position = UDim2.new(0, 60, 0, 60)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = SG
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(220, 30, 30)
Stroke.Thickness = 1.5

local TB = Instance.new("Frame", Main)
TB.Size = UDim2.new(1, 0, 0, 38)
TB.BackgroundColor3 = Color3.fromRGB(220, 30, 30)
TB.BorderSizePixel = 0
Instance.new("UICorner", TB).CornerRadius = UDim.new(0, 8)

local TL = Instance.new("TextLabel", TB)
TL.Size = UDim2.new(1, 0, 1, 0)
TL.BackgroundTransparency = 1
TL.Text = "⚡ KAIZO PRIME"
TL.TextColor3 = Color3.fromRGB(255, 255, 255)
TL.TextSize = 15
TL.Font = Enum.Font.GothamBold

local APILabel = Instance.new("TextLabel", Main)
APILabel.Size = UDim2.new(1, -10, 0, 14)
APILabel.Position = UDim2.new(0, 5, 0, 40)
APILabel.BackgroundTransparency = 1
APILabel.Text = "API: " .. AimAPI .. " | RightShift = toggle menu"
APILabel.TextColor3 = Color3.fromRGB(100, 100, 100)
APILabel.TextSize = 10
APILabel.Font = Enum.Font.Gotham
APILabel.TextXAlignment = Enum.TextXAlignment.Left

-- Toggle factory
local function MakeToggle(name, ypos, default, onChange)
    local Row = Instance.new("Frame", Main)
    Row.Size = UDim2.new(1, -20, 0, 32)
    Row.Position = UDim2.new(0, 10, 0, ypos)
    Row.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Row.BorderSizePixel = 0
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

    local Lbl = Instance.new("TextLabel", Row)
    Lbl.Size = UDim2.new(0.6, 0, 1, 0)
    Lbl.Position = UDim2.new(0, 10, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = name
    Lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    Lbl.TextSize = 13
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextXAlignment = Enum.TextXAlignment.Left

    local state = default
    local Btn = Instance.new("TextButton", Row)
    Btn.Size = UDim2.new(0, 54, 0, 22)
    Btn.Position = UDim2.new(1, -64, 0.5, -11)
    Btn.BackgroundColor3 = state and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(180, 30, 30)
    Btn.BorderSizePixel = 0
    Btn.Text = state and "ON" or "OFF"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 12
    Btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

    local function Update(val)
        state = val
        Btn.Text = state and "ON" or "OFF"
        Btn.BackgroundColor3 = state and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(180, 30, 30)
        onChange(state)
    end

    Btn.MouseButton1Click:Connect(function() Update(not state) end)
    return Update
end

-- Selector factory
local function MakeSelector(name, ypos, options, default, onChange)
    local Row = Instance.new("Frame", Main)
    Row.Size = UDim2.new(1, -20, 0, 32)
    Row.Position = UDim2.new(0, 10, 0, ypos)
    Row.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Row.BorderSizePixel = 0
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

    local Lbl = Instance.new("TextLabel", Row)
    Lbl.Size = UDim2.new(0.5, 0, 1, 0)
    Lbl.Position = UDim2.new(0, 10, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = name
    Lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    Lbl.TextSize = 13
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextXAlignment = Enum.TextXAlignment.Left

    local idx = table.find(options, default) or 1
    local ValBtn = Instance.new("TextButton", Row)
    ValBtn.Size = UDim2.new(0, 80, 0, 22)
    ValBtn.Position = UDim2.new(1, -90, 0.5, -11)
    ValBtn.BackgroundColor3 = Color3.fromRGB(220, 30, 30)
    ValBtn.BorderSizePixel = 0
    ValBtn.Text = options[idx]
    ValBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ValBtn.TextSize = 12
    ValBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", ValBtn).CornerRadius = UDim.new(0, 4)

    ValBtn.MouseButton1Click:Connect(function()
        idx = idx % #options + 1
        ValBtn.Text = options[idx]
        onChange(options[idx])
    end)
end

-- Slider factory
local function MakeSlider(name, ypos, min, max, default, onChange)
    local Row = Instance.new("Frame", Main)
    Row.Size = UDim2.new(1, -20, 0, 44)
    Row.Position = UDim2.new(0, 10, 0, ypos)
    Row.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Row.BorderSizePixel = 0
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

    local Lbl = Instance.new("TextLabel", Row)
    Lbl.Size = UDim2.new(1, -10, 0, 18)
    Lbl.Position = UDim2.new(0, 10, 0, 2)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = name .. ": " .. tostring(default)
    Lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    Lbl.TextSize = 12
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextXAlignment = Enum.TextXAlignment.Left

    local Track = Instance.new("Frame", Row)
    Track.Size = UDim2.new(1, -20, 0, 6)
    Track.Position = UDim2.new(0, 10, 0, 30)
    Track.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Track.BorderSizePixel = 0
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame", Track)
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(220, 30, 30)
    Fill.BorderSizePixel = 0
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local dragging = false
    Track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((inp.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * rel)
            Fill.Size = UDim2.new(rel, 0, 1, 0)
            Lbl.Text = name .. ": " .. tostring(val)
            onChange(val)
        end
    end)
end

-- Build toggles
local SetAim  = MakeToggle("Aimbot",     60,  Cfg.AimOn,     function(v) Cfg.AimOn = v end)
local SetESP  = MakeToggle("ESP",        98,  Cfg.ESPOn,     function(v) Cfg.ESPOn = v end)
local SetTeam = MakeToggle("TeamCheck",  136, Cfg.TeamCheck, function(v) Cfg.TeamCheck = v end)
MakeSelector("AimPart", 174, {"Head", "Body"}, Cfg.Part, function(v) Cfg.Part = v end)
MakeSlider("FOV",    216, 50,  400, Cfg.FOV,                        function(v) Cfg.FOV = v end)
MakeSlider("Smooth", 266, 1,   30,  math.floor(Cfg.Smooth * 100),   function(v) Cfg.Smooth = v / 100 end)

-- Menu toggle key
UIS.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    local k = inp.KeyCode
    if k == Enum.KeyCode.RightShift then
        Cfg.MenuOpen = not Cfg.MenuOpen
        Main.Visible = Cfg.MenuOpen
    elseif k == Enum.KeyCode.F then Cfg.Part = "Head"
    elseif k == Enum.KeyCode.G then Cfg.Part = "Body"
    elseif k == Enum.KeyCode.H then
        Cfg.AimOn = not Cfg.AimOn
        SetAim(Cfg.AimOn)
    elseif k == Enum.KeyCode.E then
        Cfg.ESPOn = not Cfg.ESPOn
        SetESP(Cfg.ESPOn)
    end
end)

-- ESP Drawing
local Cache = {}

local function D(t, props)
    local ok, d = pcall(Drawing.new, t)
    if not ok then return nil end
    for k, v in pairs(props) do pcall(function() d[k] = v end) end
    return d
end

local function MakeESP(p)
    Cache[p] = {
        BoxOut = D("Square", {Visible=false,Color=Color3.fromRGB(0,0,0),Thickness=3,Filled=false}),
        Box    = D("Square", {Visible=false,Color=Color3.fromRGB(255,255,255),Thickness=1.5,Filled=false}),
        Name   = D("Text",   {Visible=false,Color=Color3.fromRGB(255,255,255),Size=13,Center=true,Outline=true,OutlineColor=Color3.fromRGB(0,0,0),Text=p.Name}),
        Dist   = D("Text",   {Visible=false,Color=Color3.fromRGB(180,180,180),Size=11,Center=true,Outline=true,OutlineColor=Color3.fromRGB(0,0,0)}),
        HPBG   = D("Square", {Visible=false,Color=Color3.fromRGB(0,0,0),Thickness=1,Filled=true}),
        HPFill = D("Square", {Visible=false,Color=Color3.fromRGB(50,255,50),Thickness=1,Filled=true}),
        HPTxt  = D("Text",   {Visible=false,Color=Color3.fromRGB(255,255,255),Size=10,Center=true,Outline=true,OutlineColor=Color3.fromRGB(0,0,0)}),
    }
end

local function HideAll(esp)
    for _, d in pairs(esp) do if d then pcall(function() d.Visible = false end) end end
end

local function RemoveESP(p)
    if Cache[p] then
        for _, d in pairs(Cache[p]) do if d then pcall(function() d:Remove() end) end end
        Cache[p] = nil
    end
end

-- Helpers
local function GetHead(char)
    for _, n in ipairs({"Head","head","UpperTorso","Torso"}) do
        local p = char:FindFirstChild(n)
        if p and p:IsA("BasePart") then return p end
    end
    local best, bestY = nil, -math.huge
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" and v.Position.Y > bestY then
            bestY = v.Position.Y
            best = v
        end
    end
    return best
end

local function GetRoot(char)
    return char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("LowerTorso")
        or char:FindFirstChild("Torso")
        or char:FindFirstChildWhichIsA("BasePart")
end

local function GetAimPart(char)
    return Cfg.Part == "Head" and GetHead(char) or GetRoot(char)
end

local function IsAlive(p)
    if not p.Character then return false end
    local h = p.Character:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function GetHP(p)
    if not p.Character then return 100, 100 end
    local h = p.Character:FindFirstChildOfClass("Humanoid")
    if h then return h.Health, h.MaxHealth end
    return 100, 100
end

local function ToScreen(pos)
    local v, on = Camera:WorldToViewportPoint(pos)
    return Vector2.new(v.X, v.Y), v.Z > 0 and on
end

local function GetDist(p)
    local char = p.Character
    local my = LP.Character
    if not char or not my then return math.huge end
    local r = GetRoot(char)
    local mr = GetRoot(my)
    if r and mr then return (r.Position - mr.Position).Magnitude end
    return math.huge
end

local function BoxBounds(char)
    local head = GetHead(char)
    local root = GetRoot(char)
    if not head or not root then return nil end
    local tVP, tOn = ToScreen(head.Position + Vector3.new(0, 1, 0))
    local bVP, bOn = ToScreen(root.Position - Vector3.new(0, 3, 0))
    if not tOn and not bOn then return nil end
    local h = math.abs(tVP.Y - bVP.Y)
    if h < 5 then return nil end
    local w = h * 0.55
    return tVP.X - w / 2, math.min(tVP.Y, bVP.Y), w, h
end

local function HPColor(pct)
    if pct > 0.6 then return Color3.fromRGB(50, 255, 50)
    elseif pct > 0.3 then return Color3.fromRGB(255, 180, 0)
    else return Color3.fromRGB(255, 50, 50) end
end

-- FOV Circle
local FovCircle = D("Circle", {
    Visible = true,
    Radius = Cfg.FOV,
    Color = Color3.fromRGB(255, 255, 255),
    Thickness = 1,
    Filled = false,
    Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
})

-- Target
local Target = nil

local function GetTarget()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local best, bestDist = nil, Cfg.FOV
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        if Cfg.TeamCheck and p.Team == LP.Team then continue end
        if not IsAlive(p) then continue end
        local char = p.Character
        if not char then continue end
        local ap = GetAimPart(char)
        if not ap then continue end
        local sp, on = ToScreen(ap.Position)
        if not on then continue end
        local d = (sp - center).Magnitude
        if d < bestDist then
            bestDist = d
            best = p
        end
    end
    return best
end

-- Aimbot loop
RunService.Heartbeat:Connect(function()
    if FovCircle then
        pcall(function()
            FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            FovCircle.Radius = Cfg.FOV
            FovCircle.Visible = true
        end)
    end

    if not Cfg.AimOn or not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        Target = nil
        return
    end

    Target = GetTarget()
    if not Target then return end
    local char = Target.Character
    if not char then return end
    local ap = GetAimPart(char)
    if not ap then return end
    local sp, on = ToScreen(ap.Position)
    if not on then return end
    MoveAim(sp.X, sp.Y)
end)

-- ESP loop
RunService.RenderStepped:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        if not Cache[p] then continue end
        local esp = Cache[p]
        local char = p.Character

        if not Cfg.ESPOn or not char or not IsAlive(p) or GetDist(p) > Cfg.MaxDist then
            HideAll(esp)
            continue
        end

        local x, y, w, h = BoxBounds(char)
        if not x then HideAll(esp) continue end

        local col = (Target == p) and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(255, 255, 255)

        pcall(function()
            esp.BoxOut.Position = Vector2.new(x-1, y-1)
            esp.BoxOut.Size = Vector2.new(w+2, h+2)
            esp.BoxOut.Visible = true
            esp.Box.Color = col
            esp.Box.Position = Vector2.new(x, y)
            esp.Box.Size = Vector2.new(w, h)
            esp.Box.Visible = true
        end)

        pcall(function()
            local cur, max = GetHP(p)
            local pct = math.clamp(cur / math.max(max, 1), 0, 1)
            local bW, bX = 4, x - 7
            local fH = math.max(1, math.floor(h * pct))
            esp.HPBG.Position = Vector2.new(bX, y)
            esp.HPBG.Size = Vector2.new(bW, h)
            esp.HPBG.Visible = true
            esp.HPFill.Position = Vector2.new(bX, y + (h - fH))
            esp.HPFill.Size = Vector2.new(bW, fH)
            esp.HPFill.Color = HPColor(pct)
            esp.HPFill.Visible = true
            esp.HPTxt.Text = math.floor(cur) .. "hp"
            esp.HPTxt.Position = Vector2.new(bX + bW/2, y - 14)
            esp.HPTxt.Visible = true
        end)

        pcall(function()
            esp.Name.Text = p.Name
            esp.Name.Position = Vector2.new(x + w/2, y - 15)
            esp.Name.Visible = true
            esp.Dist.Text = "[" .. math.floor(GetDist(p)) .. "m]"
            esp.Dist.Position = Vector2.new(x + w/2, y + h + 2)
            esp.Dist.Visible = true
        end)
    end
end)

-- Player events
local function Setup(p)
    MakeESP(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        RemoveESP(p)
        MakeESP(p)
    end)
end

Players.PlayerAdded:Connect(Setup)
Players.PlayerRemoving:Connect(RemoveESP)
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LP then Setup(p) end
end

print("[Kaizo Prime] Loaded | API: " .. AimAPI .. " | RightShift = menu")
