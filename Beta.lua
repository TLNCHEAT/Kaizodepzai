local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VIM        = game:GetService("VirtualInputManager")
local LP = Players.LocalPlayer

local Cfg = {
    AimOn=true, ESPOn=true, FOV=150, Smooth=0.35, Part="Head",
    TeamCheck=false, MaxDist=600, MenuOpen=true, Predict=0.12,
    WallCheck=false, ShowFOV=true, Tracers=true,
}

local function GetCam() return workspace.CurrentCamera end

local AimAPI = "vim"
if syn and syn.mouse_moverel then AimAPI = "syn"
elseif rawget(_G, "mousemoverel") then AimAPI = "moverel"
elseif rawget(_G, "mousemoveto") then AimAPI = "moveto" end

local VCursor = UIS:GetMouseLocation()
UIS.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement then VCursor = UIS:GetMouseLocation() end
end)

local function MoveAim(tx, ty)
    local cam = GetCam(); if not cam then return end
    local dx = (tx - VCursor.X) * Cfg.Smooth
    local dy = (ty - VCursor.Y) * Cfg.Smooth
    if math.abs(dx) < 0.01 and math.abs(dy) < 0.01 then return end
    if AimAPI == "syn" then pcall(function() syn.mouse_moverel(dx,dy) end); VCursor = VCursor + Vector2.new(dx,dy)
    elseif AimAPI == "moverel" then pcall(mousemoverel,dx,dy); VCursor = VCursor + Vector2.new(dx,dy)
    elseif AimAPI == "moveto" then local n = VCursor + Vector2.new(dx,dy); pcall(mousemoveto,n.X,n.Y); VCursor = n
    else local n = VCursor + Vector2.new(dx,dy); pcall(function() VIM:SendMouseMoveEvent(n.X,n.Y,cam) end); VCursor = n end
end

local C = {
    Bg=Color3.fromRGB(14,14,16), Panel=Color3.fromRGB(22,22,26), Row=Color3.fromRGB(28,28,33),
    RowHover=Color3.fromRGB(36,36,42), Stroke=Color3.fromRGB(48,48,56),
    Accent=Color3.fromRGB(220,40,45), Accent2=Color3.fromRGB(255,90,90),
    Text=Color3.fromRGB(230,230,235), TextDim=Color3.fromRGB(140,140,150),
    Off=Color3.fromRGB(60,60,68), Green=Color3.fromRGB(60,210,100),
}

local function Corner(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=o; return c end
local function Stroke(o,col,th) local s=Instance.new("UIStroke"); s.Color=col or C.Stroke; s.Thickness=th or 1; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=o; return s end
local function Tween(o,t,p) local ti=TweenInfo.new(t,Enum.EasingStyle.Quad,Enum.EasingDirection.Out); local tw=TweenService:Create(o,ti,p); tw:Play(); return tw end

local SG = Instance.new("ScreenGui")
SG.Name="KaizoPrime"; SG.ResetOnSpawn=false; SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; SG.IgnoreGuiInset=true
pcall(function() SG.Parent=game:GetService("CoreGui") end)
if not SG.Parent then SG.Parent=LP:WaitForChild("PlayerGui") end

local W, H = 260, 420
local Main = Instance.new("Frame")
Main.Name="Main"; Main.Size=UDim2.new(0,W,0,0); Main.Position=UDim2.new(0,60,0,60)
Main.BackgroundColor3=C.Bg; Main.BorderSizePixel=0; Main.ClipsDescendants=true; Main.Active=true; Main.Parent=SG
Corner(Main,12)
local MStroke = Stroke(Main,C.Stroke,1.2)

local Glow = Instance.new("Frame")
Glow.Size=UDim2.new(1,6,1,6); Glow.Position=UDim2.new(0,-3,0,-3); Glow.BackgroundColor3=C.Accent
Glow.BackgroundTransparency=1; Glow.BorderSizePixel=0; Glow.ZIndex=-1; Glow.Parent=Main
Corner(Glow,14)
local GStroke = Stroke(Glow,C.Accent,2); GStroke.Transparency=0.85
local TB = Instance.new("Frame")
TB.Size=UDim2.new(1,0,0,46); TB.BackgroundColor3=C.Panel; TB.BorderSizePixel=0; TB.Parent=Main
Corner(TB,12)
local TBMask=Instance.new("Frame")
TBMask.Size=UDim2.new(1,0,0,12); TBMask.Position=UDim2.new(0,0,1,-12); TBMask.BackgroundColor3=C.Panel; TBMask.BorderSizePixel=0; TBMask.Parent=TB

local AccentBar=Instance.new("Frame")
AccentBar.Size=UDim2.new(1,0,0,2); AccentBar.Position=UDim2.new(0,0,1,-2); AccentBar.BackgroundColor3=C.Accent; AccentBar.BorderSizePixel=0; AccentBar.Parent=TB
local ABGrad=Instance.new("UIGradient")
ABGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,C.Accent),ColorSequenceKeypoint.new(0.5,C.Accent2),ColorSequenceKeypoint.new(1,C.Accent)})
ABGrad.Parent=AccentBar

local Logo=Instance.new("Frame")
Logo.Size=UDim2.new(0,26,0,26); Logo.Position=UDim2.new(0,14,0.5,-13); Logo.BackgroundColor3=C.Accent; Logo.BorderSizePixel=0; Logo.Parent=TB
Corner(Logo,7)
local LogoDot=Instance.new("Frame")
LogoDot.Size=UDim2.new(0,8,0,8); LogoDot.Position=UDim2.new(0.5,-4,0.5,-4); LogoDot.BackgroundColor3=Color3.new(1,1,1); LogoDot.BorderSizePixel=0; LogoDot.Parent=Logo
Corner(LogoDot,8)

local Title=Instance.new("TextLabel")
Title.Size=UDim2.new(1,-110,0,20); Title.Position=UDim2.new(0,50,0,9); Title.BackgroundTransparency=1
Title.Text="KAIZO PRIME"; Title.TextColor3=C.Text; Title.TextSize=15; Title.Font=Enum.Font.GothamBold
Title.TextXAlignment=Enum.TextXAlignment.Left; Title.Parent=TB

local Sub=Instance.new("TextLabel")
Sub.Size=UDim2.new(1,-110,0,14); Sub.Position=UDim2.new(0,50,0,26); Sub.BackgroundTransparency=1
Sub.Text="api: "..AimAPI; Sub.TextColor3=C.TextDim; Sub.TextSize=10; Sub.Font=Enum.Font.Gotham
Sub.TextXAlignment=Enum.TextXAlignment.Left; Sub.Parent=TB

local CloseBtn=Instance.new("TextButton")
CloseBtn.Size=UDim2.new(0,28,0,28); CloseBtn.Position=UDim2.new(1,-38,0.5,-14); CloseBtn.BackgroundColor3=C.Row
CloseBtn.BorderSizePixel=0; CloseBtn.Text="×"; CloseBtn.TextColor3=C.TextDim; CloseBtn.TextSize=20
CloseBtn.Font=Enum.Font.GothamBold; CloseBtn.AutoButtonColor=false; CloseBtn.Parent=TB
Corner(CloseBtn,7)
CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn,0.15,{BackgroundColor3=C.Accent,TextColor3=C.Text}) end)
CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn,0.15,{BackgroundColor3=C.Row,TextColor3=C.TextDim}) end)

local Body=Instance.new("ScrollingFrame")
Body.Size=UDim2.new(1,0,1,-46); Body.Position=UDim2.new(0,0,0,46); Body.BackgroundTransparency=1
Body.BorderSizePixel=0; Body.ScrollBarThickness=3; Body.ScrollBarImageColor3=C.Accent
Body.CanvasSize=UDim2.new(0,0,0,0); Body.AutomaticCanvasSize=Enum.AutomaticSize.Y
Body.ScrollBarImageTransparency=0.2; Body.Parent=Main
local BodyPad=Instance.new("UIPadding")
BodyPad.PaddingTop=UDim.new(0,10); BodyPad.PaddingBottom=UDim.new(0,10); BodyPad.Parent=Body
local Layout=Instance.new("UIListLayout")
Layout.SortOrder=Enum.SortOrder.LayoutOrder; Layout.Padding=UDim.new(0,6); Layout.Parent=Body

local function Section(text)
    local S=Instance.new("Frame")
    S.Size=UDim2.new(1,-24,0,20); S.BackgroundTransparency=1; S.Parent=Body
    local L=Instance.new("TextLabel")
    L.Size=UDim2.new(1,0,1,0); L.Position=UDim2.new(0,12,0,0); L.BackgroundTransparency=1
    L.Text=string.upper(text); L.TextColor3=C.TextDim; L.TextSize=10; L.Font=Enum.Font.GothamBold
    L.TextXAlignment=Enum.TextXAlignment.Left; L.Parent=S
    return S
end

local function Toggle(name, default, onChange)
    local Row=Instance.new("Frame")
    Row.Size=UDim2.new(1,-24,0,34); Row.BackgroundColor3=C.Row; Row.BorderSizePixel=0; Row.Parent=Body
    Corner(Row,8); Stroke(Row,C.Stroke,1)
    local Lbl=Instance.new("TextLabel")
    Lbl.Size=UDim2.new(1,-80,1,0); Lbl.Position=UDim2.new(0,12,0,0); Lbl.BackgroundTransparency=1
    Lbl.Text=name; Lbl.TextColor3=C.Text; Lbl.TextSize=13; Lbl.Font=Enum.Font.Gotham
    Lbl.TextXAlignment=Enum.TextXAlignment.Left; Lbl.Parent=Row
    local Track=Instance.new("Frame")
    Track.Size=UDim2.new(0,34,0,18); Track.Position=UDim2.new(1,-46,0.5,-9)
    Track.BackgroundColor3=default and C.Accent or C.Off; Track.BorderSizePixel=0; Track.Parent=Row
    Corner(Track,9)
    local Knob=Instance.new("Frame")
    Knob.Size=UDim2.new(0,14,0,14); Knob.Position=default and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
    Knob.BackgroundColor3=Color3.new(1,1,1); Knob.BorderSizePixel=0; Knob.Parent=Track
    Corner(Knob,7)
    local Hit=Instance.new("TextButton")
    Hit.Size=UDim2.new(1,0,1,0); Hit.BackgroundTransparency=1; Hit.Text=""; Hit.Parent=Row
    local state=default
    local function Set(v, doCb)
        state=v
        Tween(Track,0.18,{BackgroundColor3=v and C.Accent or C.Off})
        Tween(Knob,0.18,{Position=v and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)})
        if doCb~=false and onChange then onChange(v) end
    end
    Set(default,false)
    Hit.MouseButton1Click:Connect(function() Set(not state) end)
    Row.MouseEnter:Connect(function() Tween(Row,0.12,{BackgroundColor3=C.RowHover}) end)
    Row.MouseLeave:Connect(function() Tween(Row,0.12,{BackgroundColor3=C.Row}) end)
    return Set
end

local function Selector(name, options, default, onChange)
    local Row=Instance.new("Frame")
    Row.Size=UDim2.new(1,-24,0,34); Row.BackgroundColor3=C.Row; Row.BorderSizePixel=0; Row.Parent=Body
    Corner(Row,8); Stroke(Row,C.Stroke,1)
    local Lbl=Instance.new("TextLabel")
    Lbl.Size=UDim2.new(0.5,0,1,0); Lbl.Position=UDim2.new(0,12,0,0); Lbl.BackgroundTransparency=1
    Lbl.Text=name; Lbl.TextColor3=C.Text; Lbl.TextSize=13; Lbl.Font=Enum.Font.Gotham
    Lbl.TextXAlignment=Enum.TextXAlignment.Left; Lbl.Parent=Row
    local idx=table.find(options,default) or 1
    local Val=Instance.new("TextButton")
    Val.Size=UDim2.new(0,92,0,24); Val.Position=UDim2.new(1,-100,0.5,-12); Val.BackgroundColor3=C.Accent
    Val.BorderSizePixel=0; Val.Text=options[idx]; Val.TextColor3=C.Text; Val.TextSize=12
    Val.Font=Enum.Font.GothamBold; Val.AutoButtonColor=false; Val.Parent=Row
    Corner(Val,6)
    Val.MouseButton1Click:Connect(function()
        idx=idx%#options+1; Val.Text=options[idx]
        if onChange then onChange(options[idx]) end
    end)
    return function(v)
        idx=table.find(options,v) or idx; Val.Text=options[idx]
        if onChange then onChange(options[idx]) end
    end
end
local function Slider(name, min, max, default, onChange)
    local Row=Instance.new("Frame")
    Row.Size=UDim2.new(1,-24,0,50); Row.BackgroundColor3=C.Row; Row.BorderSizePixel=0; Row.Parent=Body
    Corner(Row,8); Stroke(Row,C.Stroke,1)
    local Lbl=Instance.new("TextLabel")
    Lbl.Size=UDim2.new(1,-80,0,18); Lbl.Position=UDim2.new(0,12,0,6); Lbl.BackgroundTransparency=1
    Lbl.Text=name; Lbl.TextColor3=C.Text; Lbl.TextSize=13; Lbl.Font=Enum.Font.Gotham
    Lbl.TextXAlignment=Enum.TextXAlignment.Left; Lbl.Parent=Row
    local Val=Instance.new("TextLabel")
    Val.Size=UDim2.new(0,60,0,18); Val.Position=UDim2.new(1,-72,0,6); Val.BackgroundTransparency=1
    Val.Text=tostring(default); Val.TextColor3=C.Accent2; Val.TextSize=13; Val.Font=Enum.Font.GothamBold
    Val.TextXAlignment=Enum.TextXAlignment.Right; Val.Parent=Row
    local Track=Instance.new("Frame")
    Track.Size=UDim2.new(1,-24,0,4); Track.Position=UDim2.new(0,12,0,34); Track.BackgroundColor3=C.Off
    Track.BorderSizePixel=0; Track.Parent=Row
    Corner(Track,2)
    local rel0=(default-min)/(max-min)
    local Fill=Instance.new("Frame")
    Fill.Size=UDim2.new(rel0,0,1,0); Fill.BackgroundColor3=C.Accent; Fill.BorderSizePixel=0; Fill.Parent=Track
    Corner(Fill,2)
    local Knob=Instance.new("Frame")
    Knob.Size=UDim2.new(0,12,0,12); Knob.Position=UDim2.new(rel0,-6,0.5,-6); Knob.BackgroundColor3=Color3.new(1,1,1)
    Knob.BorderSizePixel=0; Knob.Parent=Track
    Corner(Knob,6); Stroke(Knob,C.Accent,2)
    local dragging=false
    local function update(inpX)
        local rel=math.clamp((inpX-Track.AbsolutePosition.X)/Track.AbsoluteSize.X,0,1)
        local v=math.floor(min+(max-min)*rel+0.5)
        Fill.Size=UDim2.new(rel,0,1,0); Knob.Position=UDim2.new(rel,-6,0.5,-6)
        Val.Text=tostring(v); if onChange then onChange(v) end; return v
    end
    Track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; update(i.Position.X) end end)
    UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then update(i.Position.X) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    return function(v)
        local rel=math.clamp((v-min)/(max-min),0,1)
        Fill.Size=UDim2.new(rel,0,1,0); Knob.Position=UDim2.new(rel,-6,0.5,-6); Val.Text=tostring(v)
        if onChange then onChange(v) end
    end
end

Section("combat")
local SetAim  = Toggle("Aimbot", Cfg.AimOn, function(v) Cfg.AimOn=v end)
local SetTeam = Toggle("Team Check", Cfg.TeamCheck, function(v) Cfg.TeamCheck=v end)
local SetWall = Toggle("Wall Check", Cfg.WallCheck, function(v) Cfg.WallCheck=v end)
local SetPart = Selector("Aim Part", {"Head","Body"}, Cfg.Part, function(v) Cfg.Part=v end)
Section("visuals")
local SetESP   = Toggle("ESP", Cfg.ESPOn, function(v) Cfg.ESPOn=v end)
local SetTrace = Toggle("Tracers", Cfg.Tracers, function(v) Cfg.Tracers=v end)
local SetFovV  = Toggle("Show FOV", Cfg.ShowFOV, function(v) Cfg.ShowFOV=v end)
Section("tuning")
local SetFOV    = Slider("FOV", 40, 600, Cfg.FOV, function(v) Cfg.FOV=v end)
local SetSmooth = Slider("Smooth", 5, 100, math.floor(Cfg.Smooth*100), function(v) Cfg.Smooth=v/100 end)
local SetMaxD   = Slider("Max Dist", 50, 2000, Cfg.MaxDist, function(v) Cfg.MaxDist=v end)
local SetPred   = Slider("Predict", 0, 100, math.floor(Cfg.Predict*100), function(v) Cfg.Predict=v/100 end)

local menuOpen=false
local function SetMenu(open)
    menuOpen=open; Cfg.MenuOpen=open
    if open then
        Main.Visible=true
        Tween(Main,0.28,{Size=UDim2.new(0,W,0,H)})
        Tween(MStroke,0.28,{Transparency=0})
    else
        Tween(Main,0.28,{Size=UDim2.new(0,W,0,46)})
        task.delay(0.3,function() if not menuOpen then Main.Visible=false end end)
    end
end

local Fab=Instance.new("TextButton")
Fab.Size=UDim2.new(0,46,0,46); Fab.Position=UDim2.new(0,60,0,60); Fab.BackgroundColor3=C.Accent
Fab.BorderSizePixel=0; Fab.Text="K"; Fab.TextColor3=C.Text; Fab.TextSize=18
Fab.Font=Enum.Font.GothamBold; Fab.AutoButtonColor=false; Fab.Visible=false; Fab.Parent=SG
Corner(Fab,12); local FabStroke=Stroke(Fab,C.Accent2,1.5); FabStroke.Transparency=0.3
Fab.MouseEnter:Connect(function() Tween(Fab,0.15,{Size=UDim2.new(0,50,0,50),Position=UDim2.new(0,58,0,58)}) end)
Fab.MouseLeave:Connect(function() Tween(Fab,0.15,{Size=UDim2.new(0,46,0,46),Position=UDim2.new(0,60,0,60)}) end)
Fab.MouseButton1Click:Connect(function() Fab.Visible=false; SetMenu(true) end)
CloseBtn.MouseButton1Click:Connect(function() SetMenu(false); task.delay(0.25,function() if not menuOpen then Fab.Visible=true end end) end)

Main.Size=UDim2.new(0,W,0,0); Main.Visible=false; Fab.Visible=true

UIS.InputBegan:Connect(function(i,gpe)
    if gpe then return end
    if i.KeyCode==Enum.KeyCode.RightShift then
        if menuOpen then SetMenu(false); task.delay(0.25,function() if not menuOpen then Fab.Visible=true end end)
        else Fab.Visible=false; SetMenu(true) end
    elseif i.KeyCode==Enum.KeyCode.F then SetPart("Head")
    elseif i.KeyCode==Enum.KeyCode.G then SetPart("Body")
    elseif i.KeyCode==Enum.KeyCode.H then SetAim(not Cfg.AimOn)
    elseif i.KeyCode==Enum.KeyCode.E then SetESP(not Cfg.ESPOn) end
end)

local function D(t,p)
    if not Drawing then return nil end
    local ok,d=pcall(Drawing.new,t); if not ok or not d then return nil end
    for k,v in pairs(p) do pcall(function() d[k]=v end) end; return d
end
local FovCircle=D("Circle",{Visible=false,Radius=Cfg.FOV,Color=Color3.fromRGB(255,255,255),Thickness=1,Filled=false,Transparency=0.4})
local TargetCircle=D("Circle",{Visible=false,Radius=6,Color=C.Accent,Thickness=2,Filled=false})

local Cache={}
local function MakeESP(p)
    Cache[p]={
        BoxOut=D("Square",{Visible=false,Color=Color3.fromRGB(0,0,0),Thickness=3,Filled=false}),
        Box=D("Square",{Visible=false,Color=Color3.fromRGB(255,255,255),Thickness=1.5,Filled=false}),
        Name=D("Text",{Visible=false,Color=Color3.fromRGB(255,255,255),Size=13,Center=true,Outline=true,OutlineColor=Color3.fromRGB(0,0,0),Text=p.Name}),
        Dist=D("Text",{Visible=false,Color=Color3.fromRGB(180,180,180),Size=11,Center=true,Outline=true,OutlineColor=Color3.fromRGB(0,0,0)}),
        HPBG=D("Square",{Visible=false,Color=Color3.fromRGB(0,0,0),Thickness=1,Filled=true}),
        HPFill=D("Square",{Visible=false,Color=Color3.fromRGB(50,255,50),Thickness=1,Filled=true}),
        Tracer=D("Line",{Visible=false,Color=Color3.fromRGB(255,255,255),Thickness=1,Transparency=0.45}),
    }
end
local function HideAll(e) for _,d in pairs(e) do if d then pcall(function() d.Visible=false end) end end end
local function RemoveESP(p) if Cache[p] then for _,d in pairs(Cache[p]) do if d then pcall(function() d:Remove() end) end end Cache[p]=nil end end

local function IsAlive(p) local c=p.Character; if not c then return false end; local h=c:FindFirstChildOfClass("Humanoid"); return h and h.Health>0 end
local function GetHP(p) local c=p.Character; if not c then return 100,100 end; local h=c:FindFirstChildOfClass("Humanoid"); if h then return h.Health,h.MaxHealth end; return 100,100 end
local function GetHead(c) for _,n in ipairs({"Head","head"}) do local v=c:FindFirstChild(n); if v and v:IsA("BasePart") then return v end end; local b,by=nil,-math.huge; for _,v in ipairs(c:GetDescendants()) do if v:IsA("BasePart") and v.Name~="HumanoidRootPart" and v.Position.Y>by then by=v.Position.Y; b=v end end; return b end
local function GetRoot(c) return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("LowerTorso") or c:FindFirstChild("Torso") or c:FindFirstChildWhichIsA("BasePart") end
local function GetAimPart(c) if Cfg.Part=="Head" then return GetHead(c) end; return c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso") or GetRoot(c) end
local function ToScreen(pos) local cam=GetCam(); if not cam then return Vector2.zero,false end; local v,on=cam:WorldToViewportPoint(pos); return Vector2.new(v.X,v.Y),(v.Z>0 and on) end
local function GetDist(p) local a,b=p.Character and GetRoot(p.Character),LP.Character and GetRoot(LP.Character); if a and b then return (a.Position-b.Position).Magnitude end; return math.huge end
local function BoxBounds(c)
    local h,r=GetHead(c),GetRoot(c); if not h or not r then return nil end
    local hum=c:FindFirstChildOfClass("Humanoid"); local hip=(hum and hum.HipHeight) or 2
    local t,to=ToScreen(h.Position+Vector3.new(0,h.Size.Y*0.5,0))
    local b,bo=ToScreen(r.Position-Vector3.new(0,hip+1,0))
    if not to and not bo then return nil end
    local hh=math.abs(t.Y-b.Y); if hh<6 then return nil end
    local w=hh*0.55; return t.X-w/2,math.min(t.Y,b.Y),w,hh
end
local function HPColor(p) if p>0.6 then return Color3.fromRGB(60,210,100) elseif p>0.3 then return Color3.fromRGB(255,180,0) else return C.Accent end end
local function Visible(c,part)
    local cam=GetCam(); if not cam or not part then return false end
    local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Exclude; rp.FilterDescendantsInstances={c,LP.Character}
    local o=cam.CFrame.Position; return workspace:Raycast(o,part.Position-o,rp)==nil
end

local Target=nil
local function GetTarget()
    local cam=GetCam(); if not cam then return nil end
    local center=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/2); local best,bd=nil,Cfg.FOV
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and IsAlive(p) and not (Cfg.TeamCheck and p.Team==LP.Team) and GetDist(p)<=Cfg.MaxDist then
            local ch=p.Character; local ap=ch and GetAimPart(ch)
            if ap then local sp,on=ToScreen(ap.Position); if on then local d=(sp-center).Magnitude; if d<bd and (not Cfg.WallCheck or Visible(ch,ap)) then bd=d; best=p end end end
        end
    end
    return best
end
local function PredictPos(part) if not part then return Vector3.zero end; return part.Position+part.AssemblyLinearVelocity*Cfg.Predict end

RunService.Heartbeat:Connect(function()
    local cam=GetCam()
    if FovCircle and cam then pcall(function() FovCircle.Position=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/2); FovCircle.Radius=Cfg.FOV; FovCircle.Visible=Cfg.ShowFOV and Cfg.AimOn end) end
    if not Cfg.AimOn or not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then Target=nil; if TargetCircle then pcall(function() TargetCircle.Visible=false end) end; return end
    Target=GetTarget(); if not Target then if TargetCircle then pcall(function() TargetCircle.Visible=false end) end; return end
    local ap=GetAimPart(Target.Character); if not ap then return end
    local sp,on=ToScreen(PredictPos(ap)); if not on then return end
    MoveAim(sp.X,sp.Y)
    if TargetCircle then pcall(function() TargetCircle.Position=sp; TargetCircle.Visible=true end) end
end)

RunService.RenderStepped:Connect(function()
    local cam=GetCam()
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP then
            local esp=Cache[p]
            if esp then
                local ch=p.Character
                if not Cfg.ESPOn or not ch or not IsAlive(p) or GetDist(p)>Cfg.MaxDist then HideAll(esp)
                else
                    local x,y,w,h=BoxBounds(ch)
                    if not x then HideAll(esp) else
                        local col=(Target==p) and C.Accent or Color3.fromRGB(255,255,255)
                        pcall(function() esp.BoxOut.Position=Vector2.new(x-1,y-1); esp.BoxOut.Size=Vector2.new(w+2,h+2); esp.BoxOut.Visible=true; esp.Box.Color=col; esp.Box.Position=Vector2.new(x,y); esp.Box.Size=Vector2.new(w,h); esp.Box.Visible=true end)
                        pcall(function() local cur,mx=GetHP(p); local pct=math.clamp(cur/math.max(mx,1),0,1); local bW,bX=4,x-7; local fH=math.max(1,math.floor(h*pct)); esp.HPBG.Position=Vector2.new(bX,y); esp.HPBG.Size=Vector2.new(bW,h); esp.HPBG.Visible=true; esp.HPFill.Position=Vector2.new(bX,y+(h-fH)); esp.HPFill.Size=Vector2.new(bW,fH); esp.HPFill.Color=HPColor(pct); esp.HPFill.Visible=true end)
                        pcall(function() esp.Name.Text=p.Name; esp.Name.Position=Vector2.new(x+w/2,y-15); esp.Name.Visible=true; esp.Dist.Text="["..math.floor(GetDist(p)).."m]"; esp.Dist.Position=Vector2.new(x+w/2,y+h+2); esp.Dist.Visible=true end)
                        if Cfg.Tracers and cam then pcall(function() esp.Tracer.From=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y); esp.Tracer.To=Vector2.new(x+w/2,y+h); esp.Tracer.Color=col; esp.Tracer.Visible=true end)
                        else pcall(function() esp.Tracer.Visible=false end) end
                    end
                end
            end
        end
    end
end)

local function Setup(p) MakeESP(p); p.CharacterAdded:Connect(function() task.wait(0.4); RemoveESP(p); MakeESP(p) end) end
Players.PlayerAdded:Connect(Setup)
Players.PlayerRemoving:Connect(RemoveESP)
for _,p in ipairs(Players:GetPlayers()) do if p~=LP then Setup(p) end end
LP.CharacterAdded:Connect(function() task.wait(0.3); VCursor=UIS:GetMouseLocation() end)

print("[Kaizo] Loaded | API: "..AimAPI.." | RightShift = menu")
