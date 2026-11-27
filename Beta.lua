-- Kaizo Prime | FULL | Vex
local P=game:GetService("Players")
local R=game:GetService("RunService")
local U=game:GetService("UserInputService")
local T=game:GetService("TweenService")
local VIM=game:GetService("VirtualInputManager")
local L=game:GetService("Lighting")
local LP=P.LocalPlayer

local Cfg={AimOn=true,ESPOn=true,FOV=200,Smooth=0.6,Part="Head",TeamCheck=false,MaxDist=600,Predict=0.1,WallCheck=false,ShowFOV=true,Tracers=true,LowGfx=true,CullRange=300}

local function cam() return workspace.CurrentCamera end

local api="vim"
if syn and syn.mouse_moverel then api="syn"
elseif rawget(_G,"mousemoverel") then api="moverel"
elseif rawget(_G,"mousemoveto") then api="moveto" end
print("[Kaizo] api="..api)

local cur=U:GetMouseLocation()
local held=false
U.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement then cur=U:GetMouseLocation() end end)

local function move(tx,ty)
    local dx=(tx-cur.X)*Cfg.Smooth
    local dy=(ty-cur.Y)*Cfg.Smooth
    if math.abs(dx)<0.01 and math.abs(dy)<0.01 then return end
    if api=="syn" then pcall(function() syn.mouse_moverel(dx,dy) end)
    elseif api=="moverel" then pcall(mousemoverel,dx,dy)
    elseif api=="moveto" then pcall(mousemoveto,cur.X+dx,cur.Y+dy)
    else local c=cam(); if c then pcall(function() VIM:SendMouseMoveEvent(cur.X+dx,cur.Y+dy,c) end) end end
    cur=cur+Vector2.new(dx,dy)
end

local C={Bg=Color3.fromRGB(15,15,17),Panel=Color3.fromRGB(22,22,25),Row=Color3.fromRGB(30,30,34),RowHover=Color3.fromRGB(38,38,44),Accent=Color3.fromRGB(220,45,50),Accent2=Color3.fromRGB(255,95,95),Text=Color3.fromRGB(232,232,236),Dim=Color3.fromRGB(140,140,150),Off=Color3.fromRGB(58,58,64)}

local function Corner(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=o; return c end
local function Stroke(o,c,t) local s=Instance.new("UIStroke"); s.Color=c or C.Row; s.Thickness=t or 1; s.Parent=o; return s end
local function Tween(o,t,p) local tw=T:Create(o,TweenInfo.new(t,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),p); tw:Play(); return tw end

local SG=Instance.new("ScreenGui")
SG.Name="KaizoPrime"; SG.ResetOnSpawn=false; SG.IgnoreGuiInset=true; SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
pcall(function() SG.Parent=game:GetService("CoreGui") end)
if not SG.Parent then SG.Parent=LP:WaitForChild("PlayerGui") end

local W,H=240,420
local Main=Instance.new("Frame")
Main.Size=UDim2.new(0,W,0,H); Main.Position=UDim2.new(0,80,0,80); Main.BackgroundColor3=C.Bg
Main.BorderSizePixel=0; Main.Active=true; Main.ClipsDescendants=true; Main.Parent=SG
Corner(Main,10); Stroke(Main,C.Accent,1.2)

local TB=Instance.new("Frame")
TB.Size=UDim2.new(1,0,0,42); TB.BackgroundColor3=C.Panel; TB.BorderSizePixel=0; TB.Parent=Main
Corner(TB,10)
local TBMask=Instance.new("Frame")
TBMask.Size=UDim2.new(1,0,0,10); TBMask.Position=UDim2.new(0,0,1,-10); TBMask.BackgroundColor3=C.Panel
TBMask.BorderSizePixel=0; TBMask.Parent=TB
local Bar=Instance.new("Frame")
Bar.Size=UDim2.new(1,0,0,2); Bar.Position=UDim2.new(0,0,1,-2); Bar.BackgroundColor3=C.Accent
Bar.BorderSizePixel=0; Bar.Parent=TB

local TL=Instance.new("TextLabel")
TL.Size=UDim2.new(1,-100,1,0); TL.Position=UDim2.new(0,14,0,0); TL.BackgroundTransparency=1
TL.Text="KAIZO  ·  "..api; TL.TextColor3=C.Text; TL.TextSize=14; TL.Font=Enum.Font.GothamBold
TL.TextXAlignment=Enum.TextXAlignment.Left; TL.Parent=TB

local CloseBtn=Instance.new("TextButton")
CloseBtn.Size=UDim2.new(0,26,0,26); CloseBtn.Position=UDim2.new(1,-34,0.5,-13); CloseBtn.BackgroundColor3=C.Row
CloseBtn.BorderSizePixel=0; CloseBtn.Text="×"; CloseBtn.TextColor3=C.Text; CloseBtn.TextSize=18
CloseBtn.Font=Enum.Font.GothamBold; CloseBtn.AutoButtonColor=false; CloseBtn.Parent=TB
Corner(CloseBtn,6)
CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn,0.12,{BackgroundColor3=C.Accent}) end)
CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn,0.12,{BackgroundColor3=C.Row}) end)

local Body=Instance.new("ScrollingFrame")
Body.Size=UDim2.new(1,0,1,-42); Body.Position=UDim2.new(0,0,0,42); Body.BackgroundTransparency=1
Body.BorderSizePixel=0; Body.ScrollBarThickness=3; Body.ScrollBarImageColor3=C.Accent
Body.AutomaticCanvasSize=Enum.AutomaticSize.Y; Body.CanvasSize=UDim2.new(0,0,0,0); Body.Parent=Main
local BP=Instance.new("UIPadding"); BP.PaddingTop=UDim.new(0,8); BP.PaddingBottom=UDim.new(0,8); BP.Parent=Body
local LL=Instance.new("UIListLayout"); LL.SortOrder=Enum.SortOrder.LayoutOrder; LL.Padding=UDim.new(0,5); LL.Parent=Body

local function Section(t)
    local S=Instance.new("Frame"); S.Size=UDim2.new(1,-20,0,18); S.BackgroundTransparency=1; S.Parent=Body
    local Lb=Instance.new("TextLabel"); Lb.Size=UDim2.new(1,0,1,0); Lb.Position=UDim2.new(0,10,0,0)
    Lb.BackgroundTransparency=1; Lb.Text=string.upper(t); Lb.TextColor3=C.Dim; Lb.TextSize=10
    Lb.Font=Enum.Font.GothamBold; Lb.TextXAlignment=Enum.TextXAlignment.Left; Lb.Parent=S; return S
end

local function Toggle(name,def,cb)
    local Rw=Instance.new("Frame"); Rw.Size=UDim2.new(1,-20,0,32); Rw.BackgroundColor3=C.Row
    Rw.BorderSizePixel=0; Rw.Parent=Body; Corner(Rw,7)
    local Lb=Instance.new("TextLabel"); Lb.Size=UDim2.new(1,-70,1,0); Lb.Position=UDim2.new(0,10,0,0)
    Lb.BackgroundTransparency=1; Lb.Text=name; Lb.TextColor3=C.Text; Lb.TextSize=12
    Lb.Font=Enum.Font.Gotham; Lb.TextXAlignment=Enum.TextXAlignment.Left; Lb.Parent=Rw
    local Tr=Instance.new("Frame"); Tr.Size=UDim2.new(0,32,0,16); Tr.Position=UDim2.new(1,-42,0.5,-8)
    Tr.BackgroundColor3=def and C.Accent or C.Off; Tr.BorderSizePixel=0; Tr.Parent=Rw; Corner(Tr,8)
    local Kn=Instance.new("Frame"); Kn.Size=UDim2.new(0,12,0,12)
    Kn.Position=def and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6)
    Kn.BackgroundColor3=Color3.new(1,1,1); Kn.BorderSizePixel=0; Kn.Parent=Tr; Corner(Kn,6)
    local Hit=Instance.new("TextButton"); Hit.Size=UDim2.new(1,0,1,0); Hit.BackgroundTransparency=1
    Hit.Text=""; Hit.Parent=Rw
    local state=def
    local function Set(v,doCb)
        state=v; Tween(Tr,0.15,{BackgroundColor3=v and C.Accent or C.Off})
        Tween(Kn,0.15,{Position=v and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6)})
        if doCb~=false and cb then cb(v) end
    end
    Set(def,false)
    Hit.MouseButton1Click:Connect(function() Set(not state) end)
    Rw.MouseEnter:Connect(function() Tween(Rw,0.1,{BackgroundColor3=C.RowHover}) end)
    Rw.MouseLeave:Connect(function() Tween(Rw,0.1,{BackgroundColor3=C.Row}) end)
    return Set
end

local function Selector(name,opts,def,cb)
    local Rw=Instance.new("Frame"); Rw.Size=UDim2.new(1,-20,0,32); Rw.BackgroundColor3=C.Row
    Rw.BorderSizePixel=0; Rw.Parent=Body; Corner(Rw,7)
    local Lb=Instance.new("TextLabel"); Lb.Size=UDim2.new(0.5,0,1,0); Lb.Position=UDim2.new(0,10,0,0)
    Lb.BackgroundTransparency=1; Lb.Text=name; Lb.TextColor3=C.Text; Lb.TextSize=12
    Lb.Font=Enum.Font.Gotham; Lb.TextXAlignment=Enum.TextXAlignment.Left; Lb.Parent=Rw
    local idx=table.find(opts,def) or 1
    local V=Instance.new("TextButton"); V.Size=UDim2.new(0,86,0,24); V.Position=UDim2.new(1,-94,0.5,-12)
    V.BackgroundColor3=C.Accent; V.BorderSizePixel=0; V.Text=opts[idx]; V.TextColor3=C.Text
    V.TextSize=11; V.Font=Enum.Font.GothamBold; V.AutoButtonColor=false; V.Parent=Rw
    Corner(V,6)
    V.MouseButton1Click:Connect(function() idx=idx%#opts+1; V.Text=opts[idx]; if cb then cb(opts[idx]) end end)
    return function(x) idx=table.find(opts,x) or idx; V.Text=opts[idx]; if cb then cb(opts[idx]) end end
end

local function Slider(name,mn,mx,def,cb)
    local Rw=Instance.new("Frame"); Rw.Size=UDim2.new(1,-20,0,48); Rw.BackgroundColor3=C.Row
    Rw.BorderSizePixel=0; Rw.Parent=Body; Corner(Rw,7)
    local Lb=Instance.new("TextLabel"); Lb.Size=UDim2.new(1,-70,0,16); Lb.Position=UDim2.new(0,10,0,6)
    Lb.BackgroundTransparency=1; Lb.Text=name; Lb.TextColor3=C.Text; Lb.TextSize=12
    Lb.Font=Enum.Font.Gotham; Lb.TextXAlignment=Enum.TextXAlignment.Left; Lb.Parent=Rw
    local V=Instance.new("TextLabel"); V.Size=UDim2.new(0,60,0,16); V.Position=UDim2.new(1,-70,0,6)
    V.BackgroundTransparency=1; V.Text=tostring(def); V.TextColor3=C.Accent2; V.TextSize=12
    V.Font=Enum.Font.GothamBold; V.TextXAlignment=Enum.TextXAlignment.Right; V.Parent=Rw
    local Tr=Instance.new("Frame"); Tr.Size=UDim2.new(1,-20,0,4); Tr.Position=UDim2.new(0,10,0,32)
    Tr.BackgroundColor3=C.Off; Tr.BorderSizePixel=0; Tr.Parent=Rw; Corner(Tr,2)
    local rel0=(def-mn)/(mx-mn)
    local F=Instance.new("Frame"); F.Size=UDim2.new(rel0,0,1,0); F.BackgroundColor3=C.Accent
    F.BorderSizePixel=0; F.Parent=Tr; Corner(F,2)
    local Kn=Instance.new("Frame"); Kn.Size=UDim2.new(0,12,0,12); Kn.Position=UDim2.new(rel0,-6,0.5,-6)
    Kn.BackgroundColor3=Color3.new(1,1,1); Kn.BorderSizePixel=0; Kn.Parent=Tr; Corner(Kn,6)
    Stroke(Kn,C.Accent,2)
    local drag=false
    local function upd(x)
        local rel=math.clamp((x-Tr.AbsolutePosition.X)/Tr.AbsoluteSize.X,0,1)
        local v=math.floor(mn+(mx-mn)*rel+0.5)
        F.Size=UDim2.new(rel,0,1,0); Kn.Position=UDim2.new(rel,-6,0.5,-6); V.Text=tostring(v)
        if cb then cb(v) end
    end
    Tr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true; upd(i.Position.X) end end)
    U.InputChanged:Connect(function(i) if drag and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i.Position.X) end end)
    U.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
end

Section("combat")
local SetAim=Toggle("Aimbot",Cfg.AimOn,function(v) Cfg.AimOn=v end)
local SetTeam=Toggle("Team Check",Cfg.TeamCheck,function(v) Cfg.TeamCheck=v end)
local SetWall=Toggle("Wall Check",Cfg.WallCheck,function(v) Cfg.WallCheck=v end)
local SetPart=Selector("Aim Part",{"Head","Body"},Cfg.Part,function(v) Cfg.Part=v end)

Section("visuals")
local SetESP=Toggle("ESP",Cfg.ESPOn,function(v) Cfg.ESPOn=v end)
local SetTrace=Toggle("Tracers",Cfg.Tracers,function(v) Cfg.Tracers=v end)
local SetFovV=Toggle("Show FOV",Cfg.ShowFOV,function(v) Cfg.ShowFOV=v end)

Section("performance")
local SetLow=Toggle("Low GFX",Cfg.LowGfx,function(v) Cfg.LowGfx=v end)

Section("tuning")
Slider("FOV",40,600,Cfg.FOV,function(v) Cfg.FOV=v end)
Slider("Smooth",5,100,math.floor(Cfg.Smooth*100),function(v) Cfg.Smooth=v/100 end)
Slider("Max Dist",50,2000,Cfg.MaxDist,function(v) Cfg.MaxDist=v end)
Slider("Predict",0,100,math.floor(Cfg.Predict*100),function(v) Cfg.Predict=v/100 end)

local menuOpen=true
local ToggleBtn=Instance.new("TextButton")
ToggleBtn.Size=UDim2.new(0,50,0,50); ToggleBtn.Position=UDim2.new(0,20,0.5,-25)
ToggleBtn.BackgroundColor3=C.Accent; ToggleBtn.BorderSizePixel=0
ToggleBtn.Text="≡"; ToggleBtn.TextColor3=C.Text; ToggleBtn.TextSize=24
ToggleBtn.Font=Enum.Font.GothamBold; ToggleBtn.AutoButtonColor=false; ToggleBtn.ZIndex=999; ToggleBtn.Parent=SG
Corner(ToggleBtn,12); Stroke(ToggleBtn,C.Accent2,2)
ToggleBtn.MouseButton1Click:Connect(function() menuOpen=not menuOpen; Main.Visible=menuOpen end)
CloseBtn.MouseButton1Click:Connect(function() menuOpen=false; Main.Visible=false end)

local AimBtn=Instance.new("TextButton")
AimBtn.Size=UDim2.new(0,70,0,70); AimBtn.Position=UDim2.new(0,20,1,-110)
AimBtn.BackgroundColor3=C.Accent; AimBtn.BackgroundTransparency=0.35; AimBtn.BorderSizePixel=0
AimBtn.Text="AIM"; AimBtn.TextColor3=C.Text; AimBtn.TextSize=14
AimBtn.Font=Enum.Font.GothamBold; AimBtn.AutoButtonColor=false; AimBtn.ZIndex=999; AimBtn.Parent=SG
Corner(AimBtn,35); Stroke(AimBtn,C.Accent2,2)
AimBtn.MouseButton1Down:Connect(function() held=true; Tween(AimBtn,0.08,{BackgroundTransparency=0}) end)
AimBtn.MouseButton1Up:Connect(function() held=false; Tween(AimBtn,0.08,{BackgroundTransparency=0.35}) end)

U.InputBegan:Connect(function(i,g)
    if g then return end
    if i.KeyCode==Enum.KeyCode.RightShift then menuOpen=not menuOpen; Main.Visible=menuOpen
    elseif i.KeyCode==Enum.KeyCode.F then SetPart("Head")
    elseif i.KeyCode==Enum.KeyCode.G then SetPart("Body")
    elseif i.KeyCode==Enum.KeyCode.H then SetAim(not Cfg.AimOn)
    elseif i.KeyCode==Enum.KeyCode.E then SetESP(not Cfg.ESPOn) end
end)

local function applyLow()
    if not Cfg.LowGfx then return end
    pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end)
    L.GlobalShadows=false; L.FogEnd=100000; L.Brightness=1
    L.EnvironmentDiffuseScale=0; L.EnvironmentSpecularScale=0
    for _,v in ipairs(L:GetChildren()) do
        if v:IsA("PostEffect") or v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("Clouds") then
            pcall(function() v:Destroy() end)
        end
    end
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
            pcall(function() v.Enabled=false end)
        end
    end
end
applyLow()

local info={}
local function refresh(p)
    local c=p.Character
    if not c then info[p]=nil; return end
    info[p]={char=c,hum=c:FindFirstChildOfClass("Humanoid"),root=c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso"),head=c:FindFirstChild("Head")}
end
local function alive(p) local i=info[p]; return i and i.hum and i.hum.Health>0 end
local function getr(p) local i=info[p]; return i and i.root end
local function geth(p) local i=info[p]; return i and i.head end
local function aimpart(p)
    local i=info[p]; if not i or not i.char then return nil end
    if Cfg.Part=="Head" then return i.head or i.char:FindFirstChild("Head") or i.root end
    return i.char:FindFirstChild("UpperTorso") or i.char:FindFirstChild("Torso") or i.root
end
local function toscreen(pos)
    local c=cam(); if not c then return Vector2.zero,false,0 end
    local v,on=c:WorldToViewportPoint(pos)
    return Vector2.new(v.X,v.Y),(v.Z>0 and on),v.Z
end
local function dist(p)
    local a=getr(p); local b=info[LP] and info[LP].root
    if a and b then return (a.Position-b.Position).Magnitude end
    return math.huge
end
local function vis(p)
    local c=cam(); local ap=aimpart(p)
    if not c or not ap then return false end
    local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances={info[p] and info[p].char,LP.Character}
    local o=c.CFrame.Position
    return workspace:Raycast(o,ap.Position-o,rp)==nil
end

local function D(t,pr)
    if not Drawing then return nil end
    local ok,d=pcall(Drawing.new,t); if not ok or not d then return nil end
    for k,v in pairs(pr) do pcall(function() d[k]=v end) end; return d
end
local FovCircle=D("Circle",{Visible=false,Radius=Cfg.FOV,Color=Color3.fromRGB(255,255,255),Thickness=1,Filled=false,Transparency=0.4})
local TargetCircle=D("Circle",{Visible=false,Radius=6,Color=C.Accent,Thickness=2,Filled=false})

local cache={}
local function mk(p)
    cache[p]={
        box=D("Square",{Visible=false,Color=Color3.fromRGB(255,255,255),Thickness=1.5,Filled=false}),
        name=D("Text",{Visible=false,Color=Color3.fromRGB(255,255,255),Size=13,Center=true,Outline=true,OutlineColor=Color3.fromRGB(0,0,0),Text=p.Name}),
        dst=D("Text",{Visible=false,Color=Color3.fromRGB(180,180,180),Size=11,Center=true,Outline=true,OutlineColor=Color3.fromRGB(0,0,0)}),
        hpbg=D("Square",{Visible=false,Color=Color3.fromRGB(0,0,0),Thickness=1,Filled=true}),
        hpfill=D("Square",{Visible=false,Color=Color3.fromRGB(50,255,50),Thickness=1,Filled=true}),
        tracer=D("Line",{Visible=false,Color=Color3.fromRGB(255,255,255),Thickness=1,Transparency=0.45}),
    }
end
local function hide(e) for _,x in pairs(e) do if x and x.Visible then pcall(function() x.Visible=false end) end end end
local function hpcolor(p) if p>0.6 then return Color3.fromRGB(60,210,100) elseif p>0.3 then return Color3.fromRGB(255,180,0) else return C.Accent end end

local target=nil
local function gettarget()
    local c=cam(); if not c then return nil end
    local center=Vector2.new(c.ViewportSize.X/2,c.ViewportSize.Y/2)
    local best,bd=nil,Cfg.FOV
    for _,p in ipairs(P:GetPlayers()) do
        if p~=LP and alive(p) and not (Cfg.TeamCheck and p.Team==LP.Team) and dist(p)<=Cfg.MaxDist then
            local ap=aimpart(p)
            if ap then
                local sp,on=toscreen(ap.Position)
                if on then
                    local d=(sp-center).Magnitude
                    if d<bd and (not Cfg.WallCheck or vis(p)) then bd=d; best=p end
                end
            end
        end
    end
    return best
end
local function predpos(part) if not part then return Vector3.zero end; return part.Position+part.AssemblyLinearVelocity*Cfg.Predict end

local cullAcc=0
local dbg=0
R.Heartbeat:Connect(function(dt)
    local rmb=U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    local c=cam()
    if c then
        if FovCircle then pcall(function() FovCircle.Position=Vector2.new(c.ViewportSize.X/2,c.ViewportSize.Y/2); FovCircle.Radius=Cfg.FOV; FovCircle.Visible=Cfg.ShowFOV and Cfg.AimOn end) end
        if Cfg.AimOn and (rmb or held) then
            target=gettarget()
            if target then
                local ap=aimpart(target)
                if ap then
                    local sp,on,z=toscreen(predpos(ap))
                    if on then
                        move(sp.X,sp.Y)
                        if TargetCircle then pcall(function() TargetCircle.Position=sp; TargetCircle.Visible=true end) end
                    end
                    dbg=dbg+dt
                    if dbg>1 then dbg=0; print("[aim] tgt:",target.Name,"sp:",sp,"on:",on,"z:",z,"api:",api) end
                end
            else
                dbg=dbg+dt
                if dbg>1 then dbg=0; print("[aim] no tgt | rmb:",rmb,"held:",held,"on:",Cfg.AimOn,"fov:",Cfg.FOV,"pl:",#P:GetPlayers()) end
            end
        else target=nil; if TargetCircle then pcall(function() TargetCircle.Visible=false end) end end
    end

    if Cfg.LowGfx then
        cullAcc=cullAcc+dt
        if cullAcc>=0.5 then
            cullAcc=0
            local ch=LP.Character
            local root=ch and ch:FindFirstChild("HumanoidRootPart")
            if root then
                local pos=root.Position
                for _,v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and v~=root then
                        local d=(v.Position-pos).Magnitude
                        pcall(function() v.LocalTransparencyModifier=(d>Cfg.CullRange) and 1 or 0 end)
                    end
                end
            end
        end
    end
end)

local espAcc=0
R.RenderStepped:Connect(function(dt)
    espAcc=espAcc+dt
    if espAcc<0.033 then return end
    espAcc=0
    local c=cam()
    if not c then return end
    for _,p in ipairs(P:GetPlayers()) do
        if p~=LP and cache[p] then
            local e=cache[p]
            if not Cfg.ESPOn or not alive(p) or dist(p)>Cfg.MaxDist then
                hide(e)
            else
                local r=getr(p); local hd=geth(p)
                if r and hd then
                    local t,to=toscreen(hd.Position+Vector3.new(0,1,0))
                    local b,bo=toscreen(r.Position-Vector3.new(0,3,0))
                    if to or bo then
                        local hh=math.abs(t.Y-b.Y)
                        if hh>6 then
                            local w=hh*0.55; local x=t.X-w/2; local y=math.min(t.Y,b.Y)
                            local col=(target==p) and C.Accent or Color3.fromRGB(255,255,255)
                            e.box.Position=Vector2.new(x,y); e.box.Size=Vector2.new(w,hh); e.box.Color=col; e.box.Visible=true
                            e.name.Position=Vector2.new(x+w/2,y-14); e.name.Visible=true
                            e.dst.Text="["..math.floor(dist(p)).."m]"; e.dst.Position=Vector2.new(x+w/2,y+hh+2); e.dst.Visible=true
                            local hum=info[p] and info[p].hum
                            if hum then
                                                            local hum=info[p] and info[p].hum
                            if hum then
                                local pct=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
                                local fh=math.max(1,math.floor(hh*pct))
                                e.hpbg.Position=Vector2.new(x-7,y); e.hpbg.Size=Vector2.new(4,hh); e.hpbg.Visible=true
                                e.hpfill.Position=Vector2.new(x-7,y+(hh-fh)); e.hpfill.Size=Vector2.new(4,fh); e.hpfill.Color=hpcolor(pct); e.hpfill.Visible=true
                            end
                            if Cfg.Tracers then
                                e.tracer.From=Vector2.new(c.ViewportSize.X/2,c.ViewportSize.Y)
                                e.tracer.To=Vector2.new(x+w/2,y+hh); e.tracer.Color=col; e.tracer.Visible=true
                            elseif e.tracer and e.tracer.Visible then e.tracer.Visible=false end
                        else hide(e) end
                    else hide(e) end
                else hide(e) end
            end
        end
    end
end)

local function setup(p)
    refresh(p); mk(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.3); refresh(p)
        if cache[p] then for _,x in pairs(cache[p]) do if x then pcall(function() x:Remove() end) end end end
        mk(p)
    end)
    p.CharacterRemoving:Connect(function() info[p]=nil end)
end
P.PlayerAdded:Connect(setup)
P.PlayerRemoving:Connect(function(p)
    info[p]=nil
    if cache[p] then for _,x in pairs(cache[p]) do if x then pcall(function() x:Remove() end) end end cache[p]=nil end
end)
for _,p in ipairs(P:GetPlayers()) do if p~=LP then setup(p) end end
LP.CharacterAdded:Connect(function() task.wait(0.3); refresh(LP); cur=U:GetMouseLocation() end)
refresh(LP)

print("[Kaizo] ready | api="..api.." | RightShift=menu")
