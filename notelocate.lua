local UILIB_URL  = "https://raw.githubusercontent.com/elocateuser/elocate/refs/heads/main/uiui"
local VERIFY_URL = "https://key-management-worker.trackdown.workers.dev/api/validate"
local KEY_URL    = "https://key-management-worker.trackdown.workers.dev/"

-- LOADSTRING-ONLY MODE: Always fetches UI library from remote URL above
local KEY_FILE   = "elocate/savedkey.json"
local DEFAULT_CFG = "elocate/Configs/default.json"
local Players          = game:GetService("Players")
local HttpService      = game:GetService("HttpService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")
local CoreGui          = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
local LocalPlayer      = Players.LocalPlayer
local Camera           = workspace.CurrentCamera
local C                = Color3.fromRGB
local HttpReq = syn and syn.request
    or (http and http.request)
    or (typeof(request) == "function" and request)
    or http_request
    or (fluxus and fluxus.request)
    or error("[elocate] No HTTP request API found")
local FS = {
    isfile     = isfile     or function() return false end,
    readfile   = readfile   or function() return "" end,
    writefile  = writefile  or function() end,
    delfile    = delfile    or function() end,
    isfolder   = isfolder   or function() return false end,
    makefolder = makefolder or function() end,
}
local Clipboard    = setclipboard or toclipboard or function() end
local GetHui       = gethui       or function() return CoreGui end
local HasDrawing   = pcall(function() return Drawing.new end)
local HasHook      = getrawmetatable and setreadonly and newcclosure and getnamecallmethod
pcall(function()
    if not FS.isfolder("elocate") then FS.makefolder("elocate") end
    if not FS.isfolder("elocate/Configs") then FS.makefolder("elocate/Configs") end
end)
local savedKey = nil
pcall(function()
    if FS.isfile(KEY_FILE) then
        local d = HttpService:JSONDecode(FS.readfile(KEY_FILE))
        if d and d.userId == tostring(LocalPlayer.UserId) and type(d.key) == "string" and #d.key > 4 then
            savedKey = d.key
        end
    end
end)
print(savedKey and "key found!" or "waiting for key...")
print("userid: "..tostring(LocalPlayer.UserId))
print("rblx username: "..tostring(LocalPlayer.Name))
local KT = { Bg=C(10,10,10), Border=C(30,30,30), Elem=C(33,33,33), Hover=C(45,45,45),
             Outline=C(58,58,58), Accent=C(215,215,215), Text=C(240,240,240), Sub=C(150,150,150) }
local function Tw(i,p,t) TweenService:Create(i,TweenInfo.new(t or .13,Enum.EasingStyle.Quad),p):Play() end
local function MkStroke(p,c,a) local s=Instance.new("UIStroke",p);s.Color=c or KT.Outline;s.LineJoinMode=Enum.LineJoinMode.Miter;s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;s.Transparency=a or 0;return s end
local function MkTSt(p,a) local s=Instance.new("UIStroke",p);s.Color=C(0,0,0);s.Thickness=1;s.Transparency=a or .6;return s end
local function MkGrad(p) local g=Instance.new("UIGradient",p);g.Rotation=-165;g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,KT.Accent)});return g end
local function Lbl(parent,text,size,col,xalign,pos,sz) local l=Instance.new("TextLabel",parent);l.BackgroundTransparency=1;l.BorderSizePixel=0;l.TextColor3=col;l.TextSize=size;l.Font=Enum.Font.Code;l.Text=text;l.TextXAlignment=xalign or Enum.TextXAlignment.Left;l.Position=pos or UDim2.new(0,0,0,0);l.Size=sz or UDim2.new(1,0,1,0);l.ZIndex=3;MkTSt(l);return l end
local KeyGui = Instance.new("ScreenGui")
KeyGui.Name="elocate_Key";KeyGui.ResetOnSpawn=false;KeyGui.DisplayOrder=9999
KeyGui.IgnoreGuiInset=true;KeyGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
KeyGui.Parent = GetHui()
local Overlay=Instance.new("Frame",KeyGui);Overlay.Size=UDim2.new(1,0,1,0);Overlay.BackgroundColor3=C(0,0,0);Overlay.BackgroundTransparency=1;Overlay.BorderSizePixel=0;Overlay.ZIndex=1
local Card=Instance.new("Frame",KeyGui);Card.Name="Card";Card.Size=UDim2.new(0,360,0,220);Card.AnchorPoint=Vector2.new(.5,.5);Card.Position=UDim2.new(.5,0,.5,0);Card.BackgroundColor3=KT.Bg;Card.BorderSizePixel=0;Card.ZIndex=2;MkStroke(Card,KT.Outline)
local TopBar=Instance.new("Frame",Card);TopBar.Size=UDim2.new(1,0,0,1);TopBar.BackgroundColor3=KT.Accent;TopBar.BorderSizePixel=0;TopBar.ZIndex=3
Lbl(Card,"elocate.lol",11,KT.Accent,nil,UDim2.new(0,10,0,12),UDim2.new(1,-20,0,16))
Lbl(Card,"enter your license key to continue",9,KT.Sub,nil,UDim2.new(0,10,0,31),UDim2.new(1,-20,0,12))
do local d=Instance.new("Frame",Card);d.Size=UDim2.new(1,0,0,1);d.Position=UDim2.new(0,0,0,50);d.BackgroundColor3=KT.Outline;d.BorderSizePixel=0;d.ZIndex=3 end
local InputBg=Instance.new("Frame",Card);InputBg.Size=UDim2.new(1,-20,0,26);InputBg.Position=UDim2.new(0,10,0,62);InputBg.BackgroundColor3=KT.Elem;InputBg.BorderSizePixel=0;InputBg.ZIndex=3;MkStroke(InputBg,KT.Outline);MkGrad(InputBg)
do local p=Instance.new("UIPadding",InputBg);p.PaddingLeft=UDim.new(0,8);p.PaddingRight=UDim.new(0,8) end
local KeyInput=Instance.new("TextBox",InputBg);KeyInput.Size=UDim2.new(1,0,1,0);KeyInput.BackgroundTransparency=1;KeyInput.BorderSizePixel=0;KeyInput.TextColor3=KT.Text;KeyInput.PlaceholderColor3=KT.Sub;KeyInput.PlaceholderText="XXXX-XXXX-XXXX-XXXX";KeyInput.Text="";KeyInput.TextSize=9;KeyInput.Font=Enum.Font.Code;KeyInput.TextXAlignment=Enum.TextXAlignment.Left;KeyInput.ClearTextOnFocus=false;KeyInput.ZIndex=4;MkTSt(KeyInput)
Lbl(Card,"userid: "..tostring(LocalPlayer.UserId),8,KT.Sub,nil,UDim2.new(0,10,0,93),UDim2.new(1,-20,0,12))
local StatusLbl=Instance.new("TextLabel",Card);StatusLbl.Size=UDim2.new(1,-20,0,12);StatusLbl.Position=UDim2.new(0,10,0,108);StatusLbl.BackgroundTransparency=1;StatusLbl.BorderSizePixel=0;StatusLbl.TextColor3=C(255,100,100);StatusLbl.TextSize=8;StatusLbl.Font=Enum.Font.Code;StatusLbl.Text="";StatusLbl.TextXAlignment=Enum.TextXAlignment.Left;StatusLbl.TextTransparency=1;StatusLbl.ZIndex=3;local SSt=MkTSt(StatusLbl,1)
local VerifyBtn=Instance.new("TextButton",Card);VerifyBtn.Size=UDim2.new(1,-20,0,26);VerifyBtn.Position=UDim2.new(0,10,0,124);VerifyBtn.BackgroundColor3=KT.Elem;VerifyBtn.BorderSizePixel=0;VerifyBtn.Text="";VerifyBtn.AutoButtonColor=false;VerifyBtn.ZIndex=3;MkStroke(VerifyBtn,KT.Outline);MkGrad(VerifyBtn)
local VTxt=Lbl(VerifyBtn,"verify key",9,KT.Text,Enum.TextXAlignment.Center,UDim2.new(0,0,0,0),UDim2.new(1,0,1,0));VTxt.ZIndex=4
do local sep=Instance.new("Frame",Card);sep.Size=UDim2.new(1,-20,0,1);sep.Position=UDim2.new(0,10,0,160);sep.BackgroundColor3=KT.Outline;sep.BorderSizePixel=0;sep.ZIndex=3 end
local GKBtn=Instance.new("TextButton",Card);GKBtn.Size=UDim2.new(1,-20,0,22);GKBtn.Position=UDim2.new(0,10,0,165);GKBtn.BackgroundColor3=KT.Bg;GKBtn.BorderSizePixel=0;GKBtn.Text="";GKBtn.AutoButtonColor=false;GKBtn.ZIndex=3
local GKL=Lbl(GKBtn,"don't have a key?",8,KT.Sub,Enum.TextXAlignment.Left,UDim2.new(0,0,0,0),UDim2.new(.6,0,1,0));GKL.ZIndex=4
local GKR=Lbl(GKBtn,"get key →",8,KT.Accent,Enum.TextXAlignment.Right,UDim2.new(.6,0,0,0),UDim2.new(.4,0,1,0));GKR.ZIndex=4
VerifyBtn.MouseEnter:Connect(function() Tw(VerifyBtn,{BackgroundColor3=KT.Hover}) end)
VerifyBtn.MouseLeave:Connect(function() Tw(VerifyBtn,{BackgroundColor3=KT.Elem}) end)
GKBtn.MouseEnter:Connect(function() Tw(GKR,{TextColor3=Color3.new(1,1,1)}) end)
GKBtn.MouseLeave:Connect(function() Tw(GKR,{TextColor3=KT.Accent}) end)
KeyInput.Focused:Connect(function() Tw(InputBg,{BackgroundColor3=KT.Hover}) end)
KeyInput.FocusLost:Connect(function() Tw(InputBg,{BackgroundColor3=KT.Elem}) end)
for _,o in Card:GetDescendants() do
    if o:IsA("TextLabel") or o:IsA("TextBox") then o.TextTransparency=1 end
    if o:IsA("UIStroke") then o.Transparency=1 end
end
Card.BackgroundTransparency=1;TopBar.BackgroundTransparency=1
task.wait(.05)
Tw(Overlay,{BackgroundTransparency=.55},.3);Tw(Card,{BackgroundTransparency=0},.3);Tw(TopBar,{BackgroundTransparency=0},.3)
task.wait(.08)
for _,o in Card:GetDescendants() do
    if o:IsA("TextLabel") or o:IsA("TextBox") then Tw(o,{TextTransparency=0},.22) end
    if o:IsA("UIStroke") and o.Parent~=StatusLbl then Tw(o,{Transparency=.5},.2) end
end
local function SetStatus(msg,err)
    StatusLbl.Text=msg;StatusLbl.TextColor3=err and C(255,90,90) or KT.Accent
    Tw(StatusLbl,{TextTransparency=0},.12);Tw(SSt,{Transparency=.5},.12)
end
local function ClearStatus() Tw(StatusLbl,{TextTransparency=1},.1);Tw(SSt,{Transparency=1},.1) end
GKBtn.MouseButton1Click:Connect(function() pcall(Clipboard,KEY_URL);SetStatus("url copied to clipboard!",false) end)
local Verifying,WasAuto = false,false
local function DoVerify(autoKey)
    if Verifying then return end
    local key = autoKey or KeyInput.Text
    if key=="" or #key<4 then SetStatus("enter a valid key",true) return end
    Verifying=true;WasAuto=(autoKey~=nil);VTxt.Text="verifying...";ClearStatus()
    if autoKey then SetStatus("checking saved key...",false) end
    local ok,result = pcall(function()
        local r = HttpReq({Url=VERIFY_URL,Method="POST",Headers={["Content-Type"]="application/json"},
            Body=HttpService:JSONEncode({key=key,userId=tostring(LocalPlayer.UserId)})})
        return HttpService:JSONDecode(r.Body)
    end)
    if not ok then SetStatus("connection error",true);VTxt.Text="verify key";Verifying=false;return end
    if result and result.valid then
        pcall(function() FS.writefile(KEY_FILE,HttpService:JSONEncode({userId=tostring(LocalPlayer.UserId),key=key})) end)
        VTxt.Text="✓ verified";SetStatus("loading elocate.lol...",false)
        print("elocate.lol loading")
        task.wait(.6)
        Tw(Overlay,{BackgroundTransparency=1},.25);Tw(Card,{BackgroundTransparency=1},.25)
        for _,o in Card:GetDescendants() do
            if o:IsA("TextLabel") or o:IsA("TextBox") then Tw(o,{TextTransparency=1},.2) end
        end
        task.wait(.35);KeyGui:Destroy()
        local Lib = nil
        local libOk,libErr = pcall(function()
            print("[elocate] fetching UI library...")
            local libBody = HttpReq({Url=UILIB_URL,Method="GET"}).Body
            loadstring(libBody)()
            Lib = getgenv().Library
        end)
        if not libOk then 
            print("[elocate] library load error: " .. tostring(libErr))
            return 
        end
        if not Lib then 
            print("[elocate] Library failed to initialize")
            return 
        end
        local function FC(flag,dr,dg,db)
            local f=Lib.Flags[flag]
            if f and type(f)=="table" and f.Color then
                local ok2,col=pcall(Color3.fromHex,"#"..tostring(f.Color))
                if ok2 then return col end
            end
            return C(dr or 255,dg or 255,db or 255)
        end
        local function FV(flag,default)
            local v=Lib.Flags[flag]
            if v==nil then return default end
            -- Ensure numeric defaults return numbers (fixes obfuscation string issues)
            if type(default)=="number" then
                local n=tonumber(v)
                if n~=nil then return n end
            end
            return v
        end
        local function KB(flag)
            local kb=Lib.Flags[flag]; if not kb then return false end
            local mode=kb.Mode or "Toggle"
            if mode=="Toggle" then return kb.Toggled==true
            elseif mode=="Hold" then
                local nm=(tostring(kb.Key or "")):match("%.([^%.]+)$") or ""
                local ok2,kc=pcall(function() return Enum.KeyCode[nm] end)
                return ok2 and kc and UserInputService:IsKeyDown(kc) or false
            elseif mode=="Always" then return true end
            return false
        end
        local function GetHum(char)  return char and char:FindFirstChildWhichIsA("Humanoid") end
        local function GetRoot(char) return char and char:FindFirstChild("HumanoidRootPart") end
        local function IsAlive(p)
            local c=p.Character;local h=GetHum(c)
            if not c or not h then return false end
            if h.Health<=0 then return false end
            -- DaHood/Hood Customs KO check
            local be=c:FindFirstChild("BodyEffects")
            if be then
                local ko=be:FindFirstChild("K.O")
                if ko and ko:IsA("BoolValue") and ko.Value then return false end
            end
            return true
        end
        local function IsTargetAlive(target)
            if not target then return false end
            local char=target.Char
            local hum=GetHum(char)
            if not char or not hum then return false end
            if hum.Health<=0 then return false end
            -- For players, use IsAlive (checks BodyEffects.K.O)
            local plr=target.Plr or target.Player
            if plr then return IsAlive(plr) end
            -- For NPCs, just check Humanoid health
            return true
        end
        local function IsGrabbed(char)
            local be=char and char:FindFirstChild("BodyEffects")
            if be then
                return be:FindFirstChild("GRABBING_CONSTRAINT")~=nil
            end
            return false
        end
        local function W2V(pos)
            local v,on=Camera:WorldToViewportPoint(pos);return Vector2.new(v.X,v.Y),on,v.Z
        end
        local function IsDescOf(inst,anc)
            return inst and anc and inst:IsDescendantOf(anc)
        end
        local _npcCache={}
        local _lastNpcScan=0
        local _npcScanInterval=0.4
        local _mouseRef=nil
        pcall(function() _mouseRef=LocalPlayer:GetMouse() end)
        local _guiInsetY=0
        pcall(function() _guiInsetY=game:GetService("GuiService"):GetGuiInset().Y end)
        local _stickyTarget=nil
        local _aimablePart
        local _collectNpcModels
        local function ClosestPlayer(fovRadius, bone, teamFlag, wallFlag)
            bone = bone or "Head"
            local center=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
            local best,bestDist=nil,fovRadius or math.huge
            local doWall=FV(wallFlag or "AimbotWallCheck",false)
            local function tryTarget(char, plr)
                local part=char:FindFirstChild(bone) or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
                if not part then return end
                if doWall then
                    local p=RaycastParams.new()
                    p.FilterDescendantsInstances={LocalPlayer.Character,char}
                    p.FilterType=Enum.RaycastFilterType.Exclude
                    local hit=workspace:Raycast(Camera.CFrame.Position,(part.Position-Camera.CFrame.Position).Unit*1000,p)
                    if hit then return end
                end
                local sp,on=W2V(part.Position)
                if not on then return end
                local d=(sp-center).Magnitude
                if d<bestDist then
                    bestDist=d
                    best={Plr=plr,Player=plr,Part=part,Pos=part.Position,Char=char,IsNPC=(plr==nil)}
                end
            end
            for _,plr in Players:GetPlayers() do
                if plr==LocalPlayer then continue end
                if not IsAlive(plr) then continue end
                if FV(teamFlag or "AimbotTeamCheck",false) and LocalPlayer.Team and plr.Team==LocalPlayer.Team then continue end
                tryTarget(plr.Character, plr)
            end
            if FV("GlobalNPC",false) and _collectNpcModels then
                for _,npc in ipairs(_collectNpcModels()) do
                    tryTarget(npc, nil)
                end
            end
            return best
        end
        local State = {
            AimbotFov=nil, SilentFov=nil,
            FlyBV=nil, FlyBG=nil,
            ESPObjects={},
            HitboxSizes={},
            RainConn=nil, RainParts={},
            SpinAngle=0,
            OrigLighting={
                FogStart=Lighting.FogStart, FogEnd=Lighting.FogEnd, FogColor=Lighting.FogColor,
                Brightness=Lighting.Brightness, ClockTime=Lighting.ClockTime,
                ExposureComp=Lighting.ExposureCompensation, ShadowSoft=Lighting.ShadowSoftness,
                Ambient=Lighting.Ambient, OutdoorAmbient=Lighting.OutdoorAmbient,
            },
            OrigSky=nil,
        }
        local _highlights  = {}
        local _toolHls     = {}
        local _chRgbT, _chTRgbT = 0, 0
        local _matOrig      = setmetatable({}, {__mode="k"})
        local _matColorOrig = setmetatable({}, {__mode="k"})
        local _matApplied   = false
        local _matLast      = nil
        local _matColorOn   = false
        local _matColorLast = nil
        do local sky=Lighting:FindFirstChildOfClass("Sky")
            if sky then State.OrigSky={Bk=sky.SkyboxBk,Dn=sky.SkyboxDn,Ft=sky.SkyboxFt,Lf=sky.SkyboxLf,Rt=sky.SkyboxRt,Up=sky.SkyboxUp} end
        end
        if HasDrawing then
            local function MkCircle()
                local c=Drawing.new("Circle");c.NumSides=64;c.Filled=false;c.Thickness=1;c.Visible=false;return c
            end
            local function MkSquareDraw()
                local s=Drawing.new("Square");s.Filled=false;s.Thickness=1;s.Visible=false;return s
            end
            local function MkLine()
                local l=Drawing.new("Line");l.Thickness=1;l.Visible=false;return l
            end
            State.AimbotFov=MkCircle();State.SilentFov=MkCircle()
            State.AimbotFovSq=MkSquareDraw();State.SilentFovSq=MkSquareDraw()
            State.AimbotFovOut=MkCircle();State.AimbotFovOut.Thickness=3
            State.AimbotFovOutSq=MkSquareDraw();State.AimbotFovOutSq.Thickness=3
            State.SilentFovOut=MkCircle();State.SilentFovOut.Thickness=3
            State.SilentFovOutSq=MkSquareDraw();State.SilentFovOutSq.Thickness=3
            State.TargetTracer  = MkLine()
            State.TargetTracerOut=MkLine();State.TargetTracerOut.Thickness=3
            State.TargetDot=(function() local c=Drawing.new("Circle");c.Filled=true;c.Radius=5;c.NumSides=32;c.Visible=false;return c end)()
            local function MkText(sz,center)
                local t=Drawing.new("Text");t.Visible=false;t.Size=sz or 13;t.Center=center~=false
                t.Outline=true;t.Color=C(255,255,255)
                pcall(function() t.Font=Drawing.Fonts.Plex end)
                return t
            end
            State.ChOutLines = {MkLine(),MkLine(),MkLine(),MkLine()}
            State.ChLines    = {MkLine(),MkLine(),MkLine(),MkLine()}
            State.ChDot      = (function() local c=Drawing.new("Circle");c.Filled=true;c.Radius=2;c.NumSides=16;c.Visible=false;return c end)()
            State.ChText1    = (function() local t=Drawing.new("Text");t.Text="elocate";t.Size=11;t.Center=true;t.Visible=false;t.Font=Drawing.Fonts.Monospace;return t end)()
            State.ChText2    = (function() local t=Drawing.new("Text");t.Text=".lol";t.Size=11;t.Center=true;t.Visible=false;t.Font=Drawing.Fonts.Monospace;return t end)()
        end
        local _hudGui,_hudFrame=nil,nil
        local _hudNameLabel,_hudHpBarBg,_hudHpBarFill,_hudHpText,_hudDistLabel,_hudAvatar=nil,nil,nil,nil,nil,nil
        local _voidSavedCF=nil
        local _specActive=false
        local _desyncTick=0
        local _mDeltaX=0
        local _mDeltaY=0
        pcall(function()
            _hudGui=Instance.new("ScreenGui")
            _hudGui.Name="_elocate_hud";_hudGui.ResetOnSpawn=false
            _hudGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;_hudGui.IgnoreGuiInset=true
            local ok=pcall(function() _hudGui.Parent=game:GetService("CoreGui") end)
            if not ok then _hudGui.Parent=LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer end
            _hudFrame=Instance.new("Frame")
            _hudFrame.Name="_hf";_hudFrame.BackgroundColor3=KT.Bg
            _hudFrame.BorderSizePixel=0;_hudFrame.AutomaticSize=Enum.AutomaticSize.Y
            _hudFrame.Size=UDim2.new(0,220,0,0);_hudFrame.Visible=false
            _hudFrame.Parent=_hudGui
            MkStroke(_hudFrame,KT.Outline)
            MkGrad(_hudFrame)
            local pad=Instance.new("UIPadding",_hudFrame)
            pad.PaddingTop=UDim.new(0,10);pad.PaddingBottom=UDim.new(0,8)
            pad.PaddingLeft=UDim.new(0,10);pad.PaddingRight=UDim.new(0,10)
            local topBar=Instance.new("Frame",_hudFrame)
            topBar.Size=UDim2.new(1,0,0,1);topBar.Position=UDim2.new(0,-10,0,-10)
            topBar.BackgroundColor3=KT.Accent;topBar.BorderSizePixel=0
            local layout=Instance.new("UIListLayout",_hudFrame)
            layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Padding=UDim.new(0,4)
            local headerRow=Instance.new("Frame",_hudFrame)
            headerRow.LayoutOrder=1;headerRow.BackgroundTransparency=1
            headerRow.Size=UDim2.new(1,0,0,36)
            local hrl=Instance.new("UIListLayout",headerRow)
            hrl.FillDirection=Enum.FillDirection.Horizontal
            hrl.VerticalAlignment=Enum.VerticalAlignment.Center
            hrl.Padding=UDim.new(0,6);hrl.SortOrder=Enum.SortOrder.LayoutOrder
            _hudAvatar=Instance.new("ImageLabel",headerRow)
            _hudAvatar.LayoutOrder=1;_hudAvatar.BackgroundColor3=KT.Elem
            _hudAvatar.BorderSizePixel=0;_hudAvatar.Size=UDim2.new(0,32,0,32)
            _hudAvatar.ScaleType=Enum.ScaleType.Fit;_hudAvatar.Image=""
            MkStroke(_hudAvatar,KT.Outline)
            local _nw=Instance.new("Frame",headerRow)
            _nw.LayoutOrder=2;_nw.BackgroundTransparency=1
            _nw.Size=UDim2.new(1,-38,1,0)
            _hudNameLabel=Instance.new("TextLabel",_nw)
            _hudNameLabel.BackgroundTransparency=1
            _hudNameLabel.TextColor3=KT.Accent;_hudNameLabel.TextSize=11
            _hudNameLabel.Font=Enum.Font.Code;_hudNameLabel.Text=""
            _hudNameLabel.Size=UDim2.new(1,0,1,0)
            _hudNameLabel.TextXAlignment=Enum.TextXAlignment.Left
            _hudNameLabel.TextWrapped=true
            MkTSt(_hudNameLabel)
            local sep1=Instance.new("Frame",_hudFrame)
            sep1.LayoutOrder=2;sep1.BackgroundColor3=KT.Outline
            sep1.BorderSizePixel=0;sep1.Size=UDim2.new(1,0,0,1)
            _hudHpBarBg=Instance.new("Frame",_hudFrame)
            _hudHpBarBg.LayoutOrder=3;_hudHpBarBg.BackgroundColor3=KT.Elem
            _hudHpBarBg.BorderSizePixel=0;_hudHpBarBg.Size=UDim2.new(1,0,0,4)
            MkStroke(_hudHpBarBg,KT.Outline)
            _hudHpBarFill=Instance.new("Frame",_hudHpBarBg)
            _hudHpBarFill.BackgroundColor3=KT.Accent;_hudHpBarFill.BorderSizePixel=0
            _hudHpBarFill.Size=UDim2.new(1,0,1,0)
            _hudHpText=Instance.new("TextLabel",_hudFrame)
            _hudHpText.LayoutOrder=4;_hudHpText.BackgroundTransparency=1
            _hudHpText.TextColor3=KT.Sub;_hudHpText.TextSize=10
            _hudHpText.Font=Enum.Font.Code;_hudHpText.Text=""
            _hudHpText.Size=UDim2.new(1,0,0,11)
            _hudHpText.TextXAlignment=Enum.TextXAlignment.Left
            MkTSt(_hudHpText)
            _hudDistLabel=Instance.new("TextLabel",_hudFrame)
            _hudDistLabel.LayoutOrder=5;_hudDistLabel.BackgroundTransparency=1
            _hudDistLabel.TextColor3=KT.Sub;_hudDistLabel.TextSize=10
            _hudDistLabel.Font=Enum.Font.Code;_hudDistLabel.Text=""
            _hudDistLabel.Size=UDim2.new(1,0,0,11)
            _hudDistLabel.TextXAlignment=Enum.TextXAlignment.Left
            MkTSt(_hudDistLabel)
            Lib:OnUnload(function() pcall(function() _hudGui:Destroy() end) end)
        end)
        local _fpsSmooth    = 60
        local _pingCache    = 0
        local _pingTick     = 0
        local _gameId       = tostring(game.GameId)
        local _placeId      = tostring(game.PlaceId)
        -- DaHood / Hood Customs detection
        local _isDaHood     = (_gameId=="2788229376" or _placeId=="2788229376" or 
                               _placeId=="7213786345" or _placeId=="12856530796") -- Hood Customs
        local _espThrottleDt = 0
        -- Easing functions
        local EasingFunctions = {
            Linear = function(t) return t end,
            Quad = function(t) return t*t end,
            Cubic = function(t) return t*t*t end,
            Quart = function(t) return t*t*t*t end,
            Quint = function(t) return t*t*t*t*t end,
            Sine = function(t) return 1-math.cos(t*math.pi/2) end,
            Expo = function(t) return t==0 and 0 or math.pow(2,10*(t-1)) end,
            Circ = function(t) return 1-math.sqrt(1-t*t) end,
            Back = function(t) local c1=1.70158;local c3=c1+1;return c3*t*t*t-c1*t*t end,
            Elastic = function(t) local c4=(2*math.pi)/3;if t==0 then return 0 elseif t==1 then return 1 else return -math.pow(2,10*(t-1))*math.sin((t*10-0.75)*c4) end end,
            Bounce = function(t) local n1=7.5625;local d1=2.75;if t<1/d1 then return n1*t*t elseif t<2/d1 then local t1=t-1.5/d1;return n1*t1*t1+0.75 elseif t<2.5/d1 then local t2=t-2.25/d1;return n1*t2*t2+0.9375 else local t3=t-2.625/d1;return n1*t3*t3+0.984375 end end
        }
        local function ApplyEasing(t, style, dir)
            local fn=EasingFunctions[style] or EasingFunctions.Cubic
            if dir=="In" then return fn(t)
            elseif dir=="Out" then return 1-fn(1-t)
            else -- InOut
                if t<0.5 then return fn(t*2)/2 else return 1-fn((1-t)*2)/2 end
            end
        end
        local _frameTarget  = nil
        local _prevNotifTarget = nil
        local function MkDraw(class)
            if not HasDrawing then return {Visible=false,Remove=function()end,From=Vector2.new(),To=Vector2.new(),Position=Vector2.new(),Size=Vector2.new(),Color=C(255,255,255),Text="",Thickness=1,Filled=false} end
            return Drawing.new(class)
        end
        local function NewESP(plr)
            if State.ESPObjects[plr] then return end
            local o={}
            o.BoxOut=MkDraw("Square");o.BoxOut.Filled=false;o.BoxOut.Thickness=3;o.BoxOut.Visible=false
            o.Box=MkDraw("Square");o.Box.Filled=false;o.Box.Thickness=1;o.Box.Visible=false
            o.Name=MkDraw("Text");o.Name.Visible=false;o.Name.Size=13;o.Name.Center=true;o.Name.Outline=true
            pcall(function() o.Name.Font=Drawing.Fonts.Plex end)
            o.Dist=MkDraw("Text");o.Dist.Visible=false;o.Dist.Size=11;o.Dist.Center=true;o.Dist.Outline=true
            pcall(function() o.Dist.Font=Drawing.Fonts.Plex end)
            o.Tool=MkDraw("Text");o.Tool.Visible=false;o.Tool.Size=11;o.Tool.Center=true;o.Tool.Outline=true
            pcall(function() o.Tool.Font=Drawing.Fonts.Plex end)
            o.HpBg=MkDraw("Square");o.HpBg.Filled=true;o.HpBg.Color=C(0,0,0);o.HpBg.Visible=false
            o.Hp=MkDraw("Square");o.Hp.Filled=true;o.Hp.Visible=false
            o.HpText=MkDraw("Text");o.HpText.Visible=false;o.HpText.Size=10;o.HpText.Center=true;o.HpText.Outline=true
            pcall(function() o.HpText.Font=Drawing.Fonts.Plex end)
            o.Tracer=MkDraw("Line");o.Tracer.Visible=false;o.Tracer.Thickness=1
            o.TracerOut=MkDraw("Line");o.TracerOut.Visible=false;o.TracerOut.Thickness=3
            o.Corners={}
            for i=1,8 do o.Corners[i]=MkDraw("Line");o.Corners[i].Visible=false;o.Corners[i].Thickness=1 end
            State.ESPObjects[plr]=o
        end
        local function HideESP(plr)
            local o=State.ESPObjects[plr];if not o then return end
            for k,v in o do
                if k~="Corners" then pcall(function() v.Visible=false end)
                else for _,ln in v do pcall(function() ln.Visible=false end) end end
            end
        end
        local function RemoveESP(plr)
            local o=State.ESPObjects[plr];if not o then return end
            for k,v in o do
                if k~="Corners" then pcall(function() v.Visible=false;v:Remove() end)
                else for _,ln in v do pcall(function() ln.Visible=false;ln:Remove() end) end end
            end
            State.ESPObjects[plr]=nil
        end
        local SKYBOXES = {
            ["Piss"]     = {Up="2651437350",Rt="2651436979",Lf="2651436494",Ft="2651435990",Bk="2651432901",Dn="2651434974"},
            ["Peach"]    = {Up="566616187",  Rt="566616082",  Lf="566616044",  Ft="566616141",  Bk="566616113",  Dn="566616232"},
            ["Saku"]     = {Up="271077958",  Rt="271042467",  Lf="271042310",  Ft="271042556",  Bk="271042516",  Dn="271077243"},
            ["Purple"]   = {Up="570557727",  Rt="570557672",  Lf="570557620",  Ft="570557559",  Bk="570557514",  Dn="570557775"},
            ["Retro"]    = {Up="18164890128",Rt="18164873920",Lf="18164877945",Ft="18164870251",Bk="18164881924",Dn="18166113875"},
            ["Space"]    = {Up="15983964246",Rt="15983966246",Lf="15983967420",Ft="15983965025",Bk="15983968922",Dn="15983966825"},
            ["Sea"]      = {Up="321846070",  Rt="321846207",  Lf="321846162",  Ft="321845951",  Bk="321846018",  Dn="321846104"},
            ["Night V2"] = {Up="12064131",   Rt="12064115",   Lf="12063984",   Ft="12064121",   Bk="12064107",   Dn="12064152"},
            ["Dark"]     = {Up="15470160563",Rt="15470158022",Lf="15470155938",Ft="15470153860",Bk="15470149279",Dn="15470151245"},
            ["Anime"]    = {Up="104038404823203",Rt="99961685452126",Lf="84924000207295",Ft="95687237979398",Bk="81858382098344",Dn="138472117789684"},
            ["Beach"]    = {Up="151165227",  Rt="151165206",  Lf="151165191",  Ft="151165224",  Bk="151165214",  Dn="151165197"},
            ["Space V2"] = {Up="16262366016",Rt="16262363873",Lf="16262362003",Ft="16262360469",Bk="16262356578",Dn="16262358026"},
            ["Pink"]     = {Up="12635316856",Rt="12635315817",Lf="12635313718",Ft="12635312870",Bk="12635309703",Dn="12635311686"},
            ["Rainbow"]  = {Up="12877083856",Rt="12877085497",Lf="12877085497",Ft="12877085497",Bk="12877085497",Dn="12877086914"},
            ["Forest"]   = {Up="237593929",  Rt="237593835",  Lf="237593861",  Ft="237593922",  Bk="237593887",  Dn="237593849"},
            ["Night"]    = {Up="154185031",  Rt="154184972",  Lf="154184943",  Ft="154185021",  Bk="154185004",  Dn="154184960"},
            ["Lava"]     = {Up="4776130793", Rt="4776133150", Lf="4776128425", Ft="4776131365", Bk="4776124334", Dn="4776125375"},
            ["Rainy"]    = {Up="4495867486", Rt="4495866584", Lf="4495866035", Ft="4495865458", Bk="4495864450", Dn="4495864887"},
            ["Green"]    = {Up="566611218",  Rt="566611300",  Lf="566611266",  Ft="566611142",  Bk="566611187",  Dn="566613198"},
            ["Volcanic"] = {Up="150281471",  Rt="150281426",  Lf="150281400",  Ft="150281461",  Bk="150281446",  Dn="150281418"},
            ["Minecraft"]= {Up="8735166729", Rt="8735166751", Lf="8735166755", Ft="8735231668", Bk="8735166756", Dn="8735166707"},
            ["Lucid"]    = {Up="8508112781", Rt="8508111092", Lf="8508107681", Ft="8508104949", Bk="8508098796", Dn="8508103588"},
            ["Nebulous"]= {Up="131036626982613",Rt="103716549795832",Lf="126542804346203",Ft="107665368823185",Bk="95020137072033",Dn="92862258103959"},
        }
        local SkyboxSpin = 0
        local function ApplySkybox(name)
            local d=SKYBOXES[name];if not d then return end
            local sky=Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky",Lighting)
            sky.SkyboxBk="rbxassetid://"..d.Bk;sky.SkyboxDn="rbxassetid://"..d.Dn
            sky.SkyboxFt="rbxassetid://"..d.Ft;sky.SkyboxLf="rbxassetid://"..d.Lf
            sky.SkyboxRt="rbxassetid://"..d.Rt;sky.SkyboxUp="rbxassetid://"..d.Up
        end
        local function RestoreSkybox()
            local sky=Lighting:FindFirstChildOfClass("Sky")
            if State.OrigSky then
                if not sky then sky=Instance.new("Sky",Lighting) end
                sky.SkyboxBk=State.OrigSky.Bk;sky.SkyboxDn=State.OrigSky.Dn
                sky.SkyboxFt=State.OrigSky.Ft;sky.SkyboxLf=State.OrigSky.Lf
                sky.SkyboxRt=State.OrigSky.Rt;sky.SkyboxUp=State.OrigSky.Up
                pcall(function() sky.SkyboxOrientation=Vector3.new(0,0,0) end)
            elseif sky then sky:Destroy() end
        end
        local function clearHighlights()
            for plr,hl in pairs(_highlights) do
                if hl and hl.Parent then hl:Destroy() end
                _highlights[plr]=nil
            end
        end
        local function clearToolHls()
            for tool,hl in pairs(_toolHls) do
                if hl and hl.Parent then hl:Destroy() end
                _toolHls[tool]=nil
            end
        end
        local function _distToChar(otherChar)
            local lc=LocalPlayer.Character
            local lh=lc and lc:FindFirstChild("HumanoidRootPart")
            local oh=otherChar and otherChar:FindFirstChild("HumanoidRootPart")
            if not (lh and oh) then return math.huge end
            return (lh.Position-oh.Position).Magnitude
        end
        local _ffParts = {}
        local function clearFFChams()
            for plr,parts in pairs(_ffParts) do
                for part,mat in pairs(parts) do pcall(function() part.Material=mat end) end
            end
            _ffParts={}
        end
        local function applyChams(dt)
            if not FV("ChamsPlayerEnabled",false) then
                clearHighlights();clearFFChams()
            else
                local fill=FC("ChamsPlayerColor",147,112,219)
                local out=FC("ChamsPlayerOutColor",0,0,0)
                if FV("ChamsPlayerRGB",false) then
                    _chRgbT=(_chRgbT+(dt or 0)*(FV("ChamsPlayerRGBSpeed",5)*0.05))%1
                    fill=Color3.fromHSV(_chRgbT,0.85,1)
                end
                local includeSelf = FV("ChamsOnLocal",false)
                local showOthers  = FV("ChamsShowOthers",false)
                local ffOn        = FV("ChamsPlayerFF",false)
                local teamCheck   = FV("ChamsPlayerTeam",false)
                local useTeamCol  = FV("ChamsPlayerTeamCol",false)
                local fillT       = FV("ChamsPlayerFillT",50)/100
                local outT        = FV("ChamsPlayerOutT",0)/100
                local depthMode   = FV("ChamsPlayerDepth",false) and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
                for _,plr in ipairs(Players:GetPlayers()) do
                    local skip=false
                    if plr==LocalPlayer and not includeSelf then skip=true end
                    if plr~=LocalPlayer and not showOthers then skip=true end
                    if (not skip) and teamCheck and LocalPlayer.Team and plr.Team and plr.Team==LocalPlayer.Team then skip=true end
                    if (not skip) and plr.Character then
                        local hl=_highlights[plr]
                        if not hl or not hl.Parent then
                            hl=Instance.new("Highlight")
                            hl.Name="_elocate_hl"
                            hl.Adornee=plr.Character
                            hl.Parent=plr.Character
                            _highlights[plr]=hl
                        end
                        if hl.Adornee~=plr.Character then hl.Adornee=plr.Character end
                        local fc= ffOn and FC("ChamsPlayerFFColor",0,200,255)
                            or (useTeamCol and plr.Team) and plr.TeamColor.Color
                            or fill
                        if hl.FillColor~=fc          then hl.FillColor=fc end
                        if hl.OutlineColor~=out       then hl.OutlineColor=out end
                        if hl.FillTransparency~=fillT  then hl.FillTransparency=fillT end
                        if hl.OutlineTransparency~=outT then hl.OutlineTransparency=outT end
                        pcall(function() if hl.DepthMode~=depthMode then hl.DepthMode=depthMode end end)
                        if ffOn then
                            if not _ffParts[plr] then
                                _ffParts[plr]={}
                                for _,part in ipairs(plr.Character:GetDescendants()) do
                                    if part:IsA("BasePart") then
                                        _ffParts[plr][part]=part.Material
                                        pcall(function() part.Material=Enum.Material.ForceField end)
                                    end
                                end
                            end
                        elseif _ffParts[plr] then
                            for part,mat in pairs(_ffParts[plr]) do pcall(function() part.Material=mat end) end
                            _ffParts[plr]=nil
                        end
                    elseif _highlights[plr] then
                        _highlights[plr]:Destroy();_highlights[plr]=nil
                        if _ffParts[plr] then
                            for part,mat in pairs(_ffParts[plr]) do pcall(function() part.Material=mat end) end
                            _ffParts[plr]=nil
                        end
                    end
                end
                for plr,hl in pairs(_highlights) do
                    if not plr.Parent or not plr.Character then
                        if hl then hl:Destroy() end
                        _highlights[plr]=nil
                    end
                end
            end
            if not FV("ChamsToolEnabled",false) then
                clearToolHls()
                return
            end
            local tfill=FC("ChamsToolColor",255,200,100)
            local tout=FC("ChamsToolOutColor",0,0,0)
            if FV("ChamsToolRGB",false) then
                _chTRgbT=(_chTRgbT+(dt or 0)*(FV("ChamsToolRGBSpeed",5)*0.05))%1
                tfill=Color3.fromHSV(_chTRgbT,0.85,1)
            end
            local tIncSelf  = FV("ChamsToolSelf",false)
            local tShowOthers=FV("ChamsToolShowOthers",false)
            local tTeamCheck= FV("ChamsToolTeam",false)
            local tTeamCol  = FV("ChamsToolTeamCol",false)
            local tFF       = FV("ChamsToolFF",false)
            local tFillT    = FV("ChamsToolFillT",50)/100
            local tOutT     = FV("ChamsToolOutT",0)/100
            local tDepth    = FV("ChamsToolDepth",false)
            local seen={}
            local function _adornTool(tool, fillCol)
                if not tool or not tool:IsA("Tool") then return end
                seen[tool]=true
                local hl=_toolHls[tool]
                if not hl or not hl.Parent then
                    hl=Instance.new("Highlight")
                    hl.Name="_elocate_thl";hl.Adornee=tool;hl.Parent=tool
                    _toolHls[tool]=hl
                end
                if hl.Adornee~=tool then hl.Adornee=tool end
                hl.FillColor          = fillCol or tfill
                hl.OutlineColor       = tout
                hl.FillTransparency   = tFF and 1 or tFillT
                hl.OutlineTransparency= tFF and 0 or tOutT
                hl.DepthMode          = tDepth and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
                if tFF then
                    for _,p in ipairs(tool:GetDescendants()) do
                        if p:IsA("BasePart") then
                            pcall(function() p.Material=Enum.Material.ForceField end)
                        end
                    end
                end
            end
            for _,plr in ipairs(Players:GetPlayers()) do
                local isSelf = plr==LocalPlayer
                local skip = false
                if isSelf and not tIncSelf then skip=true end
                if not isSelf and not tShowOthers then skip=true end
                if not isSelf and tTeamCheck and LocalPlayer.Team and plr.Team==LocalPlayer.Team then skip=true end
                if not skip then
                    local fillCol = tfill
                    if tTeamCol and plr.Team then
                        fillCol = plr.TeamColor.Color
                    end
                    local char=plr.Character
                    if char then
                        local function scanForTools(parent)
                            for _,t in ipairs(parent:GetChildren()) do
                                if t:IsA("Tool") then _adornTool(t,fillCol)
                                elseif t:IsA("Model") or t:IsA("Folder") or t:IsA("BasePart") then scanForTools(t) end
                            end
                        end
                        scanForTools(char)
                    end
                    local bp=plr:FindFirstChildOfClass("Backpack")
                    if bp then for _,t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then _adornTool(t,fillCol) end end end
                end
            end
            for tool,hl in pairs(_toolHls) do
                if not seen[tool] or not tool.Parent then
                    if hl then hl:Destroy() end;_toolHls[tool]=nil
                end
            end
        end
        local function _isCharacterPart(inst)
            local m=inst:FindFirstAncestorOfClass("Model")
            while m do
                if m:FindFirstChildOfClass("Humanoid") then return true end
                m=m.Parent and m.Parent:FindFirstAncestorOfClass("Model") or nil
            end
            return false
        end
        local function _enumMat(name)
            local ok,m=pcall(function() return Enum.Material[name] end)
            if ok and m then return m end
            return Enum.Material.Plastic
        end
        local function applyMaterialOverride(name, useColor, color)
            local mat=_enumMat(name)
            for _,inst in ipairs(workspace:GetDescendants()) do
                if inst:IsA("BasePart") and not _isCharacterPart(inst) then
                    if _matOrig[inst]==nil then _matOrig[inst]=inst.Material end
                    pcall(function() inst.Material=mat end)
                    if useColor then
                        if _matColorOrig[inst]==nil then _matColorOrig[inst]=inst.Color end
                        pcall(function() inst.Color=color end)
                    end
                end
            end
            _matApplied=true;_matLast=name;_matColorOn=useColor and true or false;_matColorLast=color
        end
        local function restoreMaterials()
            for inst,mat in pairs(_matOrig) do
                if inst and inst.Parent then pcall(function() inst.Material=mat end) end
            end
            for inst,col in pairs(_matColorOrig) do
                if inst and inst.Parent then pcall(function() inst.Color=col end) end
            end
            _matOrig=setmetatable({},{__mode="k"});_matColorOrig=setmetatable({},{__mode="k"})
            _matApplied=false;_matColorOn=false;_matLast=nil;_matColorLast=nil
        end
        pcall(function()
            workspace.DescendantAdded:Connect(function(inst)
                if _matApplied and inst:IsA("BasePart") and not _isCharacterPart(inst) then
                    if _matOrig[inst]==nil then _matOrig[inst]=inst.Material end
                    pcall(function() inst.Material=_enumMat(_matLast or "Plastic") end)
                    if _matColorOn and _matColorLast then
                        if _matColorOrig[inst]==nil then _matColorOrig[inst]=inst.Color end
                        pcall(function() inst.Color=_matColorLast end)
                    end
                end
            end)
        end)
        local _L={}
        local function applyWorld(dt)
            pcall(function()
                if FV("MatChangerEnabled",false) then
                    local sel     = FV("MatType","Plastic")
                    local useCol  = FV("MatColorEnabled",false)
                    local col     = FC("MatColor",255,255,255)
                    if (not _matApplied) or _matLast~=sel or _matColorOn~=useCol or _matColorLast~=col then
                        applyMaterialOverride(sel,useCol,col)
                    end
                elseif _matApplied then
                    restoreMaterials()
                end
            end)
        end
        _aimablePart = function(model)
            return model:FindFirstChild("HumanoidRootPart")
                or model:FindFirstChild("Head")
                or model:FindFirstChild("Torso")
                or model:FindFirstChild("UpperTorso")
        end
        _collectNpcModels = function()
            local now=tick()
            if now-_lastNpcScan<_npcScanInterval then
                local valid={}
                for _,npc in ipairs(_npcCache) do
                    if npc and npc.Parent then
                        local hum=npc:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health>0 then table.insert(valid,npc) end
                    end
                end
                _npcCache=valid
                return valid
            end
            _lastNpcScan=now
            local out={}
            local owned={}
            for _,p in ipairs(Players:GetPlayers()) do
                if p.Character then owned[p.Character]=true end
            end
            local containers={workspace}
            for _,name in ipairs({"NPCs","Bots","Enemies","Mobs","Dummies","Targets","AI"}) do
                local folder=workspace:FindFirstChild(name)
                if folder then table.insert(containers,folder) end
            end
            for _,container in ipairs(containers) do
                for _,inst in ipairs(container:GetChildren()) do
                    if inst:IsA("Model") and not owned[inst] then
                        local hum=inst:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health>0 and _aimablePart(inst) then
                            table.insert(out,inst)
                        end
                    end
                end
            end
            _npcCache=out;return out
        end
        local function StartRain()
            for _,p in State.RainParts do pcall(function() p:Destroy() end) end
            State.RainParts={}
            if State.RainConn then State.RainConn:Disconnect();State.RainConn=nil end
            local count=math.floor(FV("RainIntensity",0.5)*300)
            local height=FV("RainHeight",30)
            local color=FC("RainColor",180,200,220)
            local model=Instance.new("Model");model.Name="elocate_Rain";model.Parent=workspace
            table.insert(State.RainParts,model)
            local drops={}
            for i=1,count do
                local p=Instance.new("Part",model)
                p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CastShadow=false
                p.Size=Vector3.new(0.04,1.5,0.04)
                p.Material=Enum.Material.Neon;p.Color=color
                p.Transparency=FV("RainAlpha",0.2)
                local spread=80
                p.CFrame=CFrame.new(
                    math.random(-spread,spread),
                    height+math.random(-20,20),
                    math.random(-spread,spread))
                    * CFrame.Angles(0.05,0,0)
                table.insert(drops,p)
                table.insert(State.RainParts,p)
            end
            State.RainConn=RunService.Heartbeat:Connect(function(dt)
                if not FV("RainEnabled",false) then return end
                local char=LocalPlayer.Character
                local root=GetRoot(char)
                local base=root and root.Position or Vector3.new(0,0,0)
                local spd=FV("RainSpeed",2)*35
                local spread=80
                local floorY=base.Y-15
                local roofY=base.Y+FV("RainHeight",30)+5
                for _,p in drops do
                    if not p.Parent then continue end
                    local pos=p.Position
                    local newY=pos.Y-spd*dt
                    if newY<floorY then
                        p.CFrame=CFrame.new(
                            base.X+math.random(-spread,spread),
                            roofY,
                            base.Z+math.random(-spread,spread))
                            *CFrame.Angles(0.05,0,0)
                    else
                        local cf=p.CFrame
                        p.CFrame=CFrame.new(cf.Position-Vector3.new(0,spd*dt,0))*CFrame.Angles(0.05,0,0)
                    end
                    end
                local rc=FC("RainColor",180,200,220);local ra=FV("RainAlpha",0.2)
                for _,p in drops do
                    if p.Parent then p.Color=rc;p.Transparency=ra end
                end
            end)
        end
        local function StopRain()
            if State.RainConn then State.RainConn:Disconnect();State.RainConn=nil end
            for _,p in State.RainParts do pcall(function() p:Destroy() end) end
            State.RainParts={}
        end
        local Window     = Lib:Window({Logo="77218680285262", FadeTime=0.3})
        local Watermark  = Lib:Watermark("elocate.lol")

        -- Load saved config
        pcall(function()
            if FS.isfile(DEFAULT_CFG) then
                local cfgData = FS.readfile(DEFAULT_CFG)
                if cfgData and #cfgData > 0 then
                    Lib:LoadConfig(cfgData)
                end
            end
        end)
        local _wmLabel = nil
        task.defer(function()
            pcall(function()
                for _,d in game:GetService("CoreGui"):GetDescendants() do
                    if d:IsA("TextLabel") and d.Text=="elocate.lol" and d.TextSize==11 then
                        _wmLabel=d; break
                    end
                end
            end)
        end)
        local KeybindList= Lib:KeybindList()
        local PlayerList = Lib:PlayerList(Window)
        local CombatPage  = Window:Page({Name="Combat",  SubPages=true})
        local VisualsPage = Window:Page({Name="Visuals", SubPages=true})
        local MiscPage    = Window:Page({Name="Misc",    SubPages=true})
        local SettingsPage= Lib:CreateSettingsPage(Window,Watermark,KeybindList,PlayerList)
        do
            local AimbotSub=CombatPage:SubPage({Name="Aimbot",Columns=2})
            do
                local S=AimbotSub:Section({Name="Main",Side=1})
                S:Toggle({Name="Enabled",        Flag="AimbotEnabled",   Default=false,Callback=function()end}):Keybind({Flag="AimbotHotkey",Default=Enum.KeyCode.E,Mode="Toggle",Callback=function()end})
                S:Toggle({Name="Smoothness",     Flag="AimbotUseSmooth", Default=false,Callback=function()end})
                S:Toggle({Name="Prediction",     Flag="AimbotUsePred",   Default=false,Callback=function()end})
                S:Toggle({Name="Offset",         Flag="AimbotUseOffset", Default=false,Callback=function()end})
                S:Toggle({Name="Velocity",       Flag="AimbotUseVel",    Default=false,Callback=function()end})
                S:Toggle({Name="Mouse Sens",     Flag="AimbotUseSens",   Default=false,Callback=function()end})
                S:Toggle({Name="Team Check",     Flag="AimbotTeamCheck", Default=false,Callback=function()end})
                S:Toggle({Name="Wall Check",     Flag="AimbotWallCheck", Default=false,Callback=function()end})
                S:Toggle({Name="Target NPCs",    Flag="GlobalNPC",       Default=false,Callback=function(v)
                    if not v then _npcCache={} end
                end})
                S:Toggle({Name="Sticky Aim",     Flag="AimbotSticky",    Default=false,Callback=function()end})
                S:Toggle({Name="Auto Lock",      Flag="AimbotAutoLock",  Default=false,Callback=function()end})
                S:Toggle({Name="Stop on Death",  Flag="AimbotStopDeath", Default=false,Callback=function()end})
                S:Dropdown({Name="Default Hitpart",Flag="AimbotDefaultPart",Items={"Head","Neck","UpperTorso","LowerTorso","Torso","HumanoidRootPart","LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm","LeftArm","RightArm","LeftUpperLeg","RightUpperLeg","LeftLeg","RightLeg"},Default="Head",Callback=function()end})
                S:Dropdown({Name="Jump Hitpart",   Flag="AimbotJumpPart",  Items={"Head","Neck","UpperTorso","LowerTorso","Torso","HumanoidRootPart","LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm","LeftArm","RightArm","LeftUpperLeg","RightUpperLeg","LeftLeg","RightLeg"},Default="Torso",Callback=function()end})
                S:Dropdown({Name="Fall Hitpart",   Flag="AimbotFallPart",  Items={"Head","Neck","UpperTorso","LowerTorso","Torso","HumanoidRootPart","LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm","LeftArm","RightArm","LeftUpperLeg","RightUpperLeg","LeftLeg","RightLeg"},Default="Torso",Callback=function()end})
            end
            do
                local S=AimbotSub:Section({Name="Sliders",Side=1})
                S:Slider({Name="X Smoothness",Flag="AimbotXSmooth",Min=0,   Max=0.99,Default=0.5, Decimals=0.01,Callback=function()end})
                S:Slider({Name="Y Smoothness",Flag="AimbotYSmooth",Min=0,   Max=0.99,Default=0.5, Decimals=0.01,Callback=function()end})
                S:Slider({Name="Strength",    Flag="AimbotStrength",Min=0.01,Max=1,  Default=0.7, Decimals=0.01,Callback=function()end})
                S:Slider({Name="X Prediction",Flag="AimbotXPred",  Min=-1,  Max=1,   Default=0,   Decimals=0.01,Callback=function()end})
                S:Slider({Name="Y Prediction",Flag="AimbotYPred",  Min=-1,  Max=1,   Default=0,   Decimals=0.01,Callback=function()end})
                S:Slider({Name="X Deadzone",  Flag="AimbotDeadzoneX",Min=0, Max=60,  Default=0,   Decimals=1,   Callback=function()end})
                S:Slider({Name="Y Deadzone",  Flag="AimbotDeadzoneY",Min=0, Max=60,  Default=0,   Decimals=1,   Callback=function()end})
                S:Slider({Name="X Offset",    Flag="AimbotXOff",   Min=-50,Max=50,  Default=0,   Decimals=0.1, Callback=function()end})
                S:Slider({Name="Y Offset",    Flag="AimbotYOff",   Min=-50,Max=50,  Default=0,   Decimals=0.1, Callback=function()end})
                S:Slider({Name="Z Offset",    Flag="AimbotZOff",   Min=-50,Max=50,  Default=0,   Decimals=0.1, Callback=function()end})
                S:Slider({Name="X Jump Off",  Flag="AimbotXJump",  Min=-50,Max=50,  Default=0,   Decimals=0.1, Callback=function()end})
                S:Slider({Name="Y Jump Off",  Flag="AimbotYJump",  Min=-50,Max=50,  Default=0,   Decimals=0.1, Callback=function()end})
                S:Slider({Name="Z Jump Off",  Flag="AimbotZJump",  Min=-50,Max=50,  Default=0,   Decimals=0.1, Callback=function()end})
            end
            do
                local S=AimbotSub:Section({Name="FOV",Side=2})
                S:Toggle({Name="Use FOV",  Flag="AimbotUseFov",  Default=false,Callback=function()end})
                S:Toggle({Name="Show FOV", Flag="AimbotShowFov", Default=false,Callback=function()end}):Colorpicker({Flag="AimbotFovColor",Default=C(255,255,255),Alpha=0,Callback=function()end})
                S:Slider({Name="FOV Size",    Flag="AimbotFovSize",  Min=10,Max=800,Default=150,Decimals=1,Suffix="px",Callback=function()end})
                S:Slider({Name="FOV Alpha",   Flag="AimbotFovAlpha", Min=0, Max=1,  Default=0.5,Decimals=0.01,   Callback=function()end})
                S:Dropdown({Name="FOV Shape", Flag="AimbotFovShape", Items={"Circle","Square"},Default="Circle",Callback=function()end})
                S:Toggle({Name="FOV Outline", Flag="AimbotFovOut",   Default=false,Callback=function()end}):Colorpicker({Flag="AimbotFovOutColor",Default=C(0,0,0),Alpha=0,Callback=function()end})
                S:Slider({Name="Out Thickness",Flag="AimbotFovOutThick",Min=0.5,Max=5,Default=1,Decimals=0.5,Callback=function()end})
                S:Slider({Name="Out Alpha",    Flag="AimbotFovOutAlpha",Min=0,  Max=1,Default=0,Decimals=0.01,Callback=function()end})
            end
            do
                local S=AimbotSub:Section({Name="Extras",Side=2})
                S:Toggle({Name="Triggerbot",    Flag="TriggerEnabled",Default=false,Callback=function()end}):Keybind({Flag="TriggerHotkey",Default=Enum.KeyCode.T,Mode="Hold",Callback=function()end})
                S:Slider({Name="Trigger Delay", Flag="TriggerDelay",  Min=0,Max=1,   Default=0.05,Decimals=0.01,Suffix="s",Callback=function()end})
                S:Slider({Name="Trigger Dist",  Flag="TriggerDist",   Min=1,Max=1000,Default=300, Decimals=1,           Callback=function()end})
                S:Toggle({Name="Hitbox Expander",Flag="HitboxEnabled",Default=false,Callback=function(v)
                    if not v then
                        for plr,sz in State.HitboxSizes do
                            local root=GetRoot(plr.Character);if root then pcall(function()root.Size=sz end) end
                        end
                        State.HitboxSizes={}
                    end
                end})
                S:Slider({Name="Hitbox Size",   Flag="HitboxSize",    Min=1,Max=100, Default=5,   Decimals=0.5,         Callback=function()end})
                S:Dropdown({Name="Hitbox Part",  Flag="HitboxPart",    Items={"HumanoidRootPart","Head","Torso","All"},Default="HumanoidRootPart",Callback=function()end})
            end
            do
                local S=AimbotSub:Section({Name="Mouse",Side=1})
                S:Toggle({Name="Custom Sensitivity",Flag="MouseSensEnabled",Default=false,Callback=function(v)
                    if not v then pcall(function() UserInputService.MouseDeltaSensitivity=1 end) end
                end})
                S:Slider({Name="Sensitivity",Flag="MouseSensValue",Min=0.1,Max=5,Default=1,Decimals=0.1,Callback=function(v) if FV("MouseSensEnabled",false) then pcall(function() UserInputService.MouseDeltaSensitivity=v end) end end})
                S:Toggle({Name="Acceleration",  Flag="MouseAccel",    Default=false,Callback=function()end})
                S:Toggle({Name="Disable Accel", Flag="MouseDisable",  Default=false,Callback=function()end})
                S:Toggle({Name="Hide Cursor",Flag="MouseIconHide",Default=false,Callback=function(v)
                    pcall(function() UserInputService.MouseIconEnabled=not v end)
                end})
                S:Toggle({Name="Lock Cursor",Flag="MouseLockEnabled",Default=false,Callback=function(v)
                    if not v then pcall(function() UserInputService.MouseBehavior=Enum.MouseBehavior.Default end) end
                end})
            end
            do
                local S=AimbotSub:Section({Name="Notifications",Side=2})
                S:Toggle({Name="Notify: Lock",     Flag="NotifAimbotLock", Default=false,Callback=function()end})
            end
            local SilentSub=CombatPage:SubPage({Name="Silent Aim",Columns=2})
            do
                local S=SilentSub:Section({Name="Main",Side=1})
                S:Toggle({Name="Enabled",      Flag="SilentEnabled",  Default=false,Callback=function()end}):Keybind({Flag="SilentHotkey",Default=Enum.KeyCode.R,Mode="Toggle",Callback=function()end})
                S:Toggle({Name="Team Check",   Flag="SilentTeamCheck",Default=false,Callback=function()end})
                S:Toggle({Name="Prediction",   Flag="SilentUsePred",  Default=false,Callback=function()end})
                S:Toggle({Name="Use Resolver", Flag="SilentUseRes",   Default=false,Callback=function()end})
                S:Toggle({Name="Da Hood Mode", Flag="SilentDaHood",   Default=false,Callback=function()end})
                S:Toggle({Name="Raycast Hook", Flag="SilentRaycast",  Default=false,Callback=function()end})
                S:Dropdown({Name="Hitpart",    Flag="SilentHitpart",  Items={"Head","Neck","UpperTorso","LowerTorso","Torso","HumanoidRootPart","LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm","LeftArm","RightArm","LeftUpperLeg","RightUpperLeg","LeftLeg","RightLeg"},Default="Head",Callback=function()end})
                S:Dropdown({Name="Resolver Mode",Flag="SilentResolverMode",Items={"Off","Stand","Slow","Air","All"},Default="Off",Callback=function()end})
                S:Slider({Name="X Pred",       Flag="SilentXPred",    Min=-1,Max=1,  Default=0,Decimals=0.001,Callback=function()end})
                S:Slider({Name="Y Pred",       Flag="SilentYPred",    Min=-1,Max=1,  Default=0,Decimals=0.001,Callback=function()end})
                S:Slider({Name="Z Pred",       Flag="SilentZPred",    Min=-1,Max=1,  Default=0,Decimals=0.001,Callback=function()end})
                S:Slider({Name="Hit Chance",   Flag="SilentHitChance",Min=0,Max=100,Default=100,  Decimals=1,   Suffix="%",Callback=function()end})
            end
            do
                local S=SilentSub:Section({Name="FOV",Side=2})
                S:Toggle({Name="Use FOV",  Flag="SilentUseFov",  Default=false,Callback=function()end})
                S:Toggle({Name="Show FOV", Flag="SilentShowFov", Default=false,Callback=function()end}):Colorpicker({Flag="SilentFovColor",Default=C(255,255,255),Alpha=0,Callback=function()end})
                S:Slider({Name="FOV Size", Flag="SilentFovSize",  Min=10,Max=800,Default=150,Decimals=1,Suffix="px",Callback=function()end})
                S:Slider({Name="FOV Alpha",Flag="SilentFovAlpha", Min=0, Max=1,  Default=0.5,Decimals=0.01,       Callback=function()end})
                S:Dropdown({Name="FOV Shape",Flag="SilentFovShape",Items={"Circle","Square"},Default="Circle",Callback=function()end})
            end
            local OtherSub=CombatPage:SubPage({Name="Other",Columns=2})
            do
                local S=OtherSub:Section({Name="Target Visuals",Side=1})
                S:Toggle({Name="Target HUD",    Flag="TargetHudEnabled",Default=false,Callback=function()end})
                S:Dropdown({Name="HUD Position",Flag="TargetHudPos",Items={"Bottom Center","Top Center","Left","Right"},Default="Bottom Center",Callback=function()end})
                S:Toggle({Name="Target Tracer", Flag="TargetTracerEnabled",Default=false,Callback=function()end}):Colorpicker({Flag="TargetTracerColor",Default=C(255,255,255),Alpha=0,Callback=function()end})
                S:Toggle({Name="Tracer Outline",Flag="TargetTracerOutEnabled",Default=false,Callback=function()end}):Colorpicker({Flag="TargetTracerOutColor",Default=C(0,0,0),Alpha=0,Callback=function()end})
                S:Slider({Name="Tracer Thick",       Flag="TargetTracerThick",    Min=0.5,Max=10,Default=1,Decimals=0.5, Callback=function()end})
                S:Slider({Name="Tracer Out Thick",   Flag="TargetTracerOutThick", Min=0.5,Max=10,Default=1.5,Decimals=0.5,Callback=function()end})
                S:Slider({Name="Tracer Alpha",       Flag="TargetTracerAlpha",    Min=0,  Max=1, Default=0,Decimals=0.01,Callback=function()end})
                S:Slider({Name="Outline Alpha",      Flag="TargetTracerOutAlpha", Min=0,  Max=1, Default=0,Decimals=0.01,Callback=function()end})
                S:Toggle({Name="Spectate Target",    Flag="TargetSpec",Default=false,Callback=function()end}):Keybind({Flag="TargetSpecHotkey",Default=Enum.KeyCode.F,Mode="Toggle",Callback=function()end})
                S:Toggle({Name="Target Dot",Flag="TargetDotEnabled",Default=false,Callback=function()end}):Colorpicker({Flag="TargetDotColor",Default=C(255,50,50),Alpha=0,Callback=function()end})
                S:Slider({Name="Dot Radius",Flag="TargetDotRadius",Min=1,Max=20,Default=5,Decimals=0.5,Callback=function()end})
                S:Slider({Name="Dot Alpha",Flag="TargetDotAlpha",Min=0,Max=1,Default=0,Decimals=0.01,Callback=function()end})
            end
        end
        do
            local ESPSub=VisualsPage:SubPage({Name="ESP",Columns=2})
            do
                local S=ESPSub:Section({Name="Box",Side=1})
                S:Toggle({Name="Enable ESP",  Flag="ESPEnabled",    Default=false,Callback=function()end})
                S:Toggle({Name="Box ESP",     Flag="ESPBox",        Default=false,Callback=function()end}):Colorpicker({Flag="ESPBoxColor",Default=C(255,255,255),Alpha=0,Callback=function()end})
                S:Dropdown({Name="Box Type",  Flag="ESPBoxType",    Items={"Full","Cornered"},Default="Full",Callback=function()end})
                S:Toggle({Name="Box Outline", Flag="ESPBoxOutline", Default=false,Callback=function()end}):Colorpicker({Flag="ESPBoxOutlineColor",Default=C(0,0,0),Alpha=0,Callback=function()end})
                S:Slider({Name="Box Thickness",Flag="ESPBoxThick",  Min=0.5,Max=5,Default=1,Decimals=0.5,Callback=function()end})
                S:Toggle({Name="Name ESP",    Flag="ESPName",       Default=false,Callback=function()end}):Colorpicker({Flag="ESPNameColor",Default=C(255,255,255),Alpha=0,Callback=function()end})
                S:Dropdown({Name="Name Pos",  Flag="ESPNamePos",    Items={"Top","Bottom","Center"},Default="Top",Callback=function()end})
                S:Toggle({Name="Name Outline",Flag="ESPNameOut",    Default=false,Callback=function()end}):Colorpicker({Flag="ESPNameOutColor",Default=C(0,0,0),Alpha=0,Callback=function()end})
                S:Slider({Name="Name Size",   Flag="ESPNameSize",   Min=8,Max=24,Default=13,Decimals=1,Callback=function()end})
                S:Toggle({Name="Distance",    Flag="ESPDist",       Default=false,Callback=function()end}):Colorpicker({Flag="ESPDistColor",Default=C(200,200,200),Alpha=0,Callback=function()end})
                S:Dropdown({Name="Dist Pos",  Flag="ESPDistPos",    Items={"Top","Bottom","Center"},Default="Bottom",Callback=function()end})
                S:Dropdown({Name="Dist Units",Flag="ESPDistType",   Items={"Studs","Meters","Yards"},Default="Studs",Callback=function()end})
                S:Toggle({Name="Dist Outline",Flag="ESPDistOut",    Default=false,Callback=function()end}):Colorpicker({Flag="ESPDistOutColor",Default=C(0,0,0),Alpha=0,Callback=function()end})
                S:Toggle({Name="Tool ESP",    Flag="ESPTool",       Default=false,Callback=function()end}):Colorpicker({Flag="ESPToolColor",Default=C(255,200,100),Alpha=0,Callback=function()end})
                S:Dropdown({Name="Tool Pos",  Flag="ESPToolPos",    Items={"Top","Bottom"},Default="Top",Callback=function()end})
                S:Toggle({Name="Tool Outline",Flag="ESPToolOut",    Default=false,Callback=function()end}):Colorpicker({Flag="ESPToolOutColor",Default=C(0,0,0),Alpha=0,Callback=function()end})
                S:Toggle({Name="Tracer",      Flag="ESPTracer",     Default=false,Callback=function()end}):Colorpicker({Flag="ESPTracerColor",Default=C(255,255,255),Alpha=0,Callback=function()end})
                S:Slider({Name="Tracer Thick",Flag="ESPTracerThick",Min=0.5,Max=5,Default=1,Decimals=0.5,Callback=function()end})
                S:Toggle({Name="Tracer Outline",Flag="ESPTracerOut",Default=false,Callback=function()end}):Colorpicker({Flag="ESPTracerOutColor",Default=C(0,0,0),Alpha=0,Callback=function()end})
                S:Dropdown({Name="Tracer Origin",Flag="ESPTracerOrigin",Items={"Bottom","Top","Middle","Mouse"},Default="Bottom",Callback=function()end})
                S:Toggle({Name="Target Indicator",Flag="ESPTargetInd",Default=false,Callback=function()end}):Colorpicker({Flag="ESPTargetIndColor",Default=C(255,220,0),Alpha=0,Callback=function()end})
            end
            do
                local S=ESPSub:Section({Name="Health & Filters",Side=2})
                S:Toggle({Name="Health Bar",    Flag="ESPHpBar",     Default=false,Callback=function()end}):Colorpicker({Flag="ESPHpColor",Default=C(0,255,0),Alpha=0,Callback=function()end})
                S:Toggle({Name="HP Gradient",   Flag="ESPHpGrad",    Default=false,Callback=function()end})
                S:Label("Gradient High"):Colorpicker({Flag="ESPHpGradHigh",Default=C(0,255,0),  Alpha=0,Callback=function()end})
                S:Label("Gradient Mid") :Colorpicker({Flag="ESPHpGradMid", Default=C(255,255,0),Alpha=0,Callback=function()end})
                S:Label("Gradient Low") :Colorpicker({Flag="ESPHpGradLow", Default=C(255,0,0),  Alpha=0,Callback=function()end})
                S:Toggle({Name="HP Text",       Flag="ESPHpText",    Default=false,Callback=function()end}):Colorpicker({Flag="ESPHpTextColor",Default=C(255,255,255),Alpha=0,Callback=function()end})
                S:Dropdown({Name="HP Text Pos", Flag="ESPHpTextPos", Items={"Top","Center","Bottom"},Default="Center",Callback=function()end})
                S:Slider({Name="Bar Width",     Flag="ESPHpBarW",    Min=2,Max=8,Default=4,Decimals=1,Callback=function()end})
                S:Toggle({Name="Team Colors",   Flag="ESPTeamColor", Default=false,Callback=function()end})
                S:Toggle({Name="Visible Check", Flag="ESPVisible",   Default=false,Callback=function()end})
                S:Toggle({Name="Team Check",    Flag="ESPTeam",      Default=false,Callback=function()end})
                S:Toggle({Name="Dead Check",    Flag="ESPDead",      Default=false,Callback=function()end})
                S:Toggle({Name="Show On Self",  Flag="ESPShowSelf",  Default=false,Callback=function()end})
                S:Toggle({Name="NPC ESP",       Flag="ESPNpc",       Default=false,Callback=function()end}):Colorpicker({Flag="ESPNpcColor",Default=C(255,100,100),Alpha=0,Callback=function()end})
            end
            local ChamsSub=VisualsPage:SubPage({Name="Chams",Columns=2})
            do
                local S=ChamsSub:Section({Name="Player Chams",Side=1})
                S:Toggle({Name="Player Chams",Flag="ChamsPlayerEnabled",Default=false,Callback=function(v)
                    if not v then clearHighlights() end
                end}):Colorpicker({Flag="ChamsPlayerColor",Default=C(147,112,219),Alpha=0,Callback=function()end})
                S:Slider({Name="Fill Transparency", Flag="ChamsPlayerFillT", Min=0,Max=95,Default=50,Decimals=1,Callback=function()end})
                S:Label("Outline Color"):Colorpicker({Flag="ChamsPlayerOutColor",Default=C(0,0,0),Alpha=0,Callback=function()end})
                S:Slider({Name="Outline Transparency",Flag="ChamsPlayerOutT",Min=0,Max=95,Default=0,Decimals=1,Callback=function()end})
                S:Toggle({Name="RGB",             Flag="ChamsPlayerRGB",     Default=false,Callback=function()end})
                S:Slider({Name="RGB Speed",       Flag="ChamsPlayerRGBSpeed",Min=0.1,Max=10,Default=5,Decimals=0.1,Callback=function()end})
                S:Toggle({Name="Team Check",      Flag="ChamsPlayerTeam",    Default=false,Callback=function()end})
                S:Toggle({Name="Team Color",      Flag="ChamsPlayerTeamCol", Default=false,Callback=function()end})
                S:Toggle({Name="Show On Local",   Flag="ChamsOnLocal",       Default=false,Callback=function()end})
                S:Toggle({Name="Show On Others",  Flag="ChamsShowOthers",    Default=false,Callback=function()end})
                S:Toggle({Name="Depth Mode",      Flag="ChamsPlayerDepth",   Default=false,Callback=function()end})
                S:Toggle({Name="ForceField Style",Flag="ChamsPlayerFF",      Default=false,Callback=function(v) if not v then clearFFChams() end end})
                S:Label("FF Highlight Color"):Colorpicker({Flag="ChamsPlayerFFColor",Default=C(0,200,255),Alpha=0,Callback=function()end})
            end
            do
                local S=ChamsSub:Section({Name="Tool Chams",Side=2})
                S:Toggle({Name="Tool Chams",   Flag="ChamsToolEnabled",Default=false,Callback=function(v)
                    if not v then clearToolHls() end
                end}):Colorpicker({Flag="ChamsToolColor",Default=C(255,200,100),Alpha=0,Callback=function()end})
                S:Slider({Name="Fill Transparency", Flag="ChamsToolFillT",   Min=0,Max=95,Default=50,Decimals=1,Callback=function()end})
                S:Label("Outline Color"):Colorpicker({Flag="ChamsToolOutColor",Default=C(0,0,0),Alpha=0,Callback=function()end})
                S:Slider({Name="Outline Transparency",Flag="ChamsToolOutT",  Min=0,Max=95,Default=0,Decimals=1,Callback=function()end})
                S:Toggle({Name="RGB",             Flag="ChamsToolRGB",       Default=false,Callback=function()end})
                S:Slider({Name="RGB Speed",       Flag="ChamsToolRGBSpeed",  Min=0.1,Max=10,Default=5,Decimals=0.1,Callback=function()end})
                S:Toggle({Name="Team Check",      Flag="ChamsToolTeam",      Default=false,Callback=function()end})
                S:Toggle({Name="Team Color",      Flag="ChamsToolTeamCol",   Default=false,Callback=function()end})
                S:Toggle({Name="Show On Others",  Flag="ChamsToolShowOthers",Default=false,Callback=function()end})
                S:Toggle({Name="Include Self",    Flag="ChamsToolSelf",      Default=false,Callback=function()end})
                S:Toggle({Name="Depth Mode",      Flag="ChamsToolDepth",     Default=false,Callback=function()end})
                S:Toggle({Name="ForceField Style",Flag="ChamsToolFF",        Default=false,Callback=function(v) if not v then clearToolHls() end end})
            end
            local WorldSub=VisualsPage:SubPage({Name="World",Columns=2})
            do
                local S=WorldSub:Section({Name="Fog",Side=1})
                S:Toggle({Name="Custom Fog",Flag="FogEnabled",Default=false,Callback=function(v)
                    if not v then Lighting.FogStart=State.OrigLighting.FogStart;Lighting.FogEnd=State.OrigLighting.FogEnd;Lighting.FogColor=State.OrigLighting.FogColor end
                end}):Colorpicker({Flag="FogColor",Default=C(128,128,128),Alpha=0,Callback=function()
                    if FV("FogEnabled",false) then Lighting.FogColor=FC("FogColor",128,128,128) end
                end})
                S:Toggle({Name="Fog Gradient",Flag="FogGrad",Default=false,Callback=function()end})
                S:Label("Fog Color A"):Colorpicker({Flag="FogGradA",Default=C(100,100,150),Alpha=0,Callback=function()end})
                S:Label("Fog Color B"):Colorpicker({Flag="FogGradB",Default=C(200,200,220),Alpha=0,Callback=function()end})
                S:Slider({Name="Fog Start",Flag="FogStart",Min=0,Max=1000, Default=0,   Decimals=1,Callback=function(v) if FV("FogEnabled",false) then Lighting.FogStart=v end end})
                S:Slider({Name="Fog End",  Flag="FogEnd",  Min=0,Max=10000,Default=1000,Decimals=1,Callback=function(v) if FV("FogEnabled",false) then Lighting.FogEnd=v end end})
                S:Slider({Name="Fog Density",Flag="FogDensity",Min=0,Max=1,Default=0.3,Decimals=0.01,Callback=function()end})
            end
            do
                local S=WorldSub:Section({Name="Material Changer",Side=1})
                S:Toggle({Name="Material Changer",Flag="MatChangerEnabled",Default=false,Callback=function(v)
                    if not v then restoreMaterials() end
                end})
                S:Dropdown({Name="Material",Flag="MatType",
                    Items={"SmoothPlastic","Grass","Concrete","Wood","Sand","Ice","Snow","Rock",
                           "Cobblestone","Pebble","WoodPlanks","Brick","Marble","Granite","SandRock",
                           "Basalt","Sandstone","CrackedLava","Ground","Limestone","CorrodedMetal","Metal","Fabric"},
                    Default="SmoothPlastic",Callback=function()
                        _matLast=nil
                    end})
                S:Toggle({Name="Material Color",Flag="MatColorEnabled",Default=false,Callback=function()
                    _matColorOn=false
                end}):Colorpicker({Flag="MatColor",Default=C(106,127,63),Alpha=0,Callback=function()
                    _matColorLast=nil
                end})
            end
            do
                local S=WorldSub:Section({Name="Skybox",Side=1})
                S:Toggle({Name="Custom Skybox",Flag="SkyboxEnabled",Default=false,Callback=function(v)
                    if v then ApplySkybox(FV("SkyboxPreset","Space")) else RestoreSkybox() end
                end})
                S:Dropdown({Name="Skybox Preset",Flag="SkyboxPreset",
                    Items={"Space","Space V2","Night","Night V2","Dark","Purple","Piss","Peach","Saku","Anime",
                           "Beach","Pink","Rainbow","Forest","Retro","Sea","Lava","Rainy","Green",
                           "Volcanic","Minecraft","Lucid","Nebulous"},
                    Default="Space",Callback=function(v)
                        if FV("SkyboxEnabled",false) then ApplySkybox(v) end
                    end})
                S:Toggle({Name="Skybox Spin",     Flag="SkyboxSpin",    Default=false,Callback=function()end})
                S:Slider({Name="Spin Speed",      Flag="SkyboxSpinSpeed",Min=0.1,Max=100,Default=30,Decimals=0.1,Callback=function()end})
                S:Dropdown({Name="Spin Direction",Flag="SkyboxSpinDir",  Items={"Horizontal","Vertical","Diagonal"},Default="Horizontal",Callback=function()end})
            end
            do
                local S=WorldSub:Section({Name="Lighting",Side=2})
                S:Toggle({Name="Custom Lighting",Flag="LightingEnabled",Default=false,Callback=function(v)
                    if not v then
                        Lighting.Brightness=State.OrigLighting.Brightness
                        Lighting.ExposureCompensation=State.OrigLighting.ExposureComp
                        Lighting.ClockTime=State.OrigLighting.ClockTime
                        Lighting.ShadowSoftness=State.OrigLighting.ShadowSoft
                        Lighting.Ambient=State.OrigLighting.Ambient
                        Lighting.OutdoorAmbient=State.OrigLighting.OutdoorAmbient
                    end
                end})
                S:Slider({Name="Brightness",     Flag="LightingBright",Min=0,  Max=5,  Default=2,   Decimals=0.1, Callback=function(v) if FV("LightingEnabled",false) then Lighting.Brightness=v end end})
                S:Slider({Name="Exposure",       Flag="LightingExpose",Min=-5, Max=5,  Default=0,   Decimals=0.1, Callback=function(v) if FV("LightingEnabled",false) then Lighting.ExposureCompensation=v end end})
                S:Slider({Name="Clock Time",     Flag="LightingClock", Min=0,  Max=24, Default=14,  Decimals=0.1, Callback=function(v) if FV("LightingEnabled",false) then Lighting.ClockTime=v end end})
                S:Slider({Name="Shadow Soft",    Flag="LightingShadow",Min=0,  Max=1,  Default=0.2, Decimals=0.01,Callback=function(v) if FV("LightingEnabled",false) then Lighting.ShadowSoftness=v end end})
                S:Toggle({Name="Fullbright",     Flag="Fullbright",    Default=false,Callback=function(v)
                    if v then Lighting.Brightness=10;Lighting.ClockTime=12;Lighting.FogEnd=100000
                    else Lighting.Brightness=State.OrigLighting.Brightness;Lighting.ClockTime=State.OrigLighting.ClockTime end
                end})
                S:Toggle({Name="Ambience",       Flag="AmbEnabled",    Default=false,Callback=function(v)
                    if not v then Lighting.Ambient=State.OrigLighting.Ambient;Lighting.OutdoorAmbient=State.OrigLighting.OutdoorAmbient end
                end})
                S:Label("Ambient A"):Colorpicker({Flag="AmbA",Default=C(70,70,70), Alpha=0,Callback=function()
                    if FV("AmbEnabled",false) then Lighting.Ambient=FC("AmbA",70,70,70) end
                end})
                S:Label("Ambient B"):Colorpicker({Flag="AmbB",Default=C(130,130,130),Alpha=0,Callback=function()
                    if FV("AmbEnabled",false) then Lighting.OutdoorAmbient=FC("AmbB",130,130,130) end
                end})
            end
            do
                local S=WorldSub:Section({Name="Weather",Side=2})
                S:Toggle({Name="Rain",Flag="RainEnabled",Default=false,Callback=function(v)
                    if v then StartRain() else StopRain() end
                end}):Colorpicker({Flag="RainColor",Default=C(180,200,220),Alpha=0,Callback=function()end})
                S:Slider({Name="Intensity",   Flag="RainIntensity",Min=0.01,Max=1,  Default=0.5,Decimals=0.01,Callback=function(v)
                    if FV("RainEnabled",false) then StopRain();StartRain() end
                end})
                S:Slider({Name="Height",      Flag="RainHeight",   Min=-50, Max=150,Default=30, Decimals=0.5, Callback=function()end})
                S:Slider({Name="Speed",       Flag="RainSpeed",    Min=0.1, Max=10, Default=2,  Decimals=0.1, Callback=function()end})
                S:Slider({Name="Transparency",Flag="RainAlpha",    Min=0,   Max=1,  Default=0.2,Decimals=0.01,Callback=function()end})
            end
        end
        do
            local MiscSub=MiscPage:SubPage({Name="Movement",Columns=2})
            do
                local S=MiscSub:Section({Name="Speed & Fly",Side=1})
                S:Toggle({Name="Speed",Flag="SpeedEnabled",Default=false,Callback=function(v)
                    if not v then local h=GetHum(LocalPlayer.Character);if h then h.WalkSpeed=16 end end
                end}):Keybind({Flag="SpeedHotkey",Default=Enum.KeyCode.G,Mode="Toggle",Callback=function()end})
                S:Slider({Name="Speed Value",Flag="SpeedValue",Min=16,Max=500,Default=50,Decimals=1,Callback=function()end})
                S:Dropdown({Name="Speed Type",Flag="SpeedType",Items={"WalkSpeed","CFrame","Velo"},Default="WalkSpeed",Callback=function()end})
                S:Toggle({Name="Fly",Flag="FlyEnabled",Default=false,Callback=function(v)
                    local char=LocalPlayer.Character;local root=GetRoot(char);local hum=GetHum(char)
                    if v and root then
                        local bv=Instance.new("BodyVelocity",root);bv.MaxForce=Vector3.new(math.huge,math.huge,math.huge);bv.Velocity=Vector3.new()
                        local bg=Instance.new("BodyGyro",root);bg.MaxTorque=Vector3.new(math.huge,math.huge,math.huge);bg.D=10;bg.P=10000
                        State.FlyBV=bv;State.FlyBG=bg;if hum then hum.PlatformStand=true end
                    else
                        if State.FlyBV then State.FlyBV:Destroy();State.FlyBV=nil end
                        if State.FlyBG then State.FlyBG:Destroy();State.FlyBG=nil end
                        if hum then hum.PlatformStand=false end
                    end
                end}):Keybind({Flag="FlyHotkey",Default=Enum.KeyCode.V,Mode="Toggle",Callback=function()end})
                S:Slider({Name="Fly Speed",Flag="FlySpeed",Min=1,Max=500,Default=50,Decimals=1,Callback=function()end})
                S:Dropdown({Name="Fly Type",Flag="FlyType",Items={"BodyVelocity","HumanoidState"},Default="BodyVelocity",Callback=function()end})
                S:Toggle({Name="Jump Power",Flag="JumpEnabled",Default=false,Callback=function(v)
                    if not v then local h=GetHum(LocalPlayer.Character);if h then h.JumpPower=50 end end
                end}):Keybind({Flag="JumpHotkey",Default=Enum.KeyCode.Space,Mode="Toggle",Callback=function()end})
                S:Slider({Name="Jump Power",Flag="JumpPower",Min=0,Max=500,Default=100,Decimals=1,Callback=function()end})
                S:Toggle({Name="Inf Jump",Flag="InfJumpEnabled",Default=false,Callback=function()end}):Keybind({Flag="InfJumpHotkey",Default=Enum.KeyCode.Space,Mode="Hold",Callback=function()end})
                S:Toggle({Name="No Clip",Flag="NoClipEnabled",Default=false,Callback=function()end}):Keybind({Flag="NoClipHotkey",Default=Enum.KeyCode.N,Mode="Toggle",Callback=function()end})
            end
            do
                local S=MiscSub:Section({Name="Advanced",Side=2})
                S:Toggle({Name="BHop",     Flag="BHopEnabled",    Default=false,Callback=function()end}):Keybind({Flag="BHopHotkey",Default=Enum.KeyCode.Space,Mode="Hold",Callback=function()end})
                S:Toggle({Name="Void Hide",Flag="VoidHideEnabled",Default=false,Callback=function()end}):Keybind({Flag="VoidHideHotkey",Default=Enum.KeyCode.K,Mode="Toggle",Callback=function()end})
                S:Dropdown({Name="Void Pos",Flag="VoidHidePos",Items={"Last Position","Random","High Altitude"},Default="Last Position",Callback=function()end})
                S:Toggle({Name="Anti-AFK", Flag="AntiAFKEnabled", Default=false,Callback=function()end})
                S:Toggle({Name="Gravity",  Flag="GravityEnabled", Default=false,Callback=function(v)
                    if not v then workspace.Gravity=196.2 end
                end})
                S:Slider({Name="Gravity Value",Flag="GravityValue",Min=0,Max=400,Default=50,Decimals=1,Callback=function()end})
                S:Toggle({Name="Anti-Aim",Flag="AntiAimEnabled",Default=false,Callback=function()end})
                S:Dropdown({Name="AA Type",Flag="AntiAimType",Items={"180 Flip","Down","Jitter","Random"},Default="180 Flip",Callback=function()end})
                S:Toggle({Name="Desync",  Flag="DesyncEnabled", Default=false,Callback=function()end}):Keybind({Flag="DesyncHotkey",Default=Enum.KeyCode.H,Mode="Toggle",Callback=function()end})
                S:Slider({Name="Desync Offset",Flag="DesyncAmount",Min=10,Max=500,Default=80,Decimals=1,Callback=function()end})
                S:Toggle({Name="Spin Bot",Flag="SpinEnabled",   Default=false,Callback=function()end}):Keybind({Flag="SpinHotkey",Default=Enum.KeyCode.J,Mode="Toggle",Callback=function()end})
                S:Slider({Name="Spin Speed",Flag="SpinSpeed",   Min=1,Max=2000,Default=400,Decimals=1,Callback=function()end})
                S:Dropdown({Name="Spin Dir",Flag="SpinDir",     Items={"Clockwise","Counter-Clockwise"},Default="Clockwise",Callback=function()end})
            end
        end
        local CrossSub=MiscPage:SubPage({Name="Crosshair",Columns=2})
        do
            local S=CrossSub:Section({Name="Crosshair",Side=1})
            S:Toggle({Name="Enabled",     Flag="ChEnabled",   Default=false,Callback=function()end})
            S:Dropdown({Name="Position",  Flag="ChPosType",   Items={"Center","Mouse"},Default="Center",Callback=function()end})
            S:Toggle({Name="Center Dot",  Flag="ChDot",       Default=true, Callback=function()end})
            S:Slider({Name="Dot Size",    Flag="ChDotSize",   Min=1,Max=10,Default=2,Decimals=0.5,Callback=function()end})
            S:Slider({Name="Size",        Flag="ChSize",      Min=2,Max=60,Default=10,Decimals=1,Callback=function()end})
            S:Slider({Name="Gap",         Flag="ChGap",       Min=0,Max=20,Default=3,Decimals=0.5,Callback=function()end})
            S:Slider({Name="Thickness",   Flag="ChThick",     Min=0.5,Max=6,Default=1,Decimals=0.5,Callback=function()end})
            S:Label("Color"):Colorpicker({Flag="ChColor",     Default=C(255,255,255),Alpha=0,Callback=function()end})
            S:Toggle({Name="Outline",     Flag="ChOutline",   Default=false,Callback=function()end}):Colorpicker({Flag="ChOutColor",Default=C(0,0,0),Alpha=0,Callback=function()end})
        end
        do
            local S=CrossSub:Section({Name="Crosshair Extras",Side=2})
            S:Toggle({Name="Spin",             Flag="ChSpin",          Default=false,Callback=function()end})
            S:Slider({Name="Spin Speed",       Flag="ChSpinSpeed",     Min=10,Max=720,Default=90,Decimals=1,Callback=function()end})
            S:Toggle({Name="Watermark",        Flag="WatermarkEnabled",Default=true,Callback=function(v) Watermark:SetVisibility(v) end})
            S:Toggle({Name="Crosshair Text",   Flag="ChTextEnabled",   Default=true, Callback=function()end}):Colorpicker({Flag="ChTextColor",Default=C(202,243,255),Alpha=0,Callback=function()end})
        end
        local lastInfJump = false
        local _espSmooth  = {}
        local _chSpinAngle = 0
        Lib:Connect(UserInputService.InputChanged, function(input)
            if input.UserInputType==Enum.UserInputType.MouseMovement then
                _mDeltaX=input.Delta.X
                _mDeltaY=input.Delta.Y
            end
        end)
        Lib:Connect(RunService.RenderStepped, function(dt)
            local viewCenter=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
            do
                local bn=FV("AimbotDefaultPart","Head")
                local fv=FV("AimbotUseFov",false) and FV("AimbotFovSize",150) or math.huge
                _frameTarget=ClosestPlayer(fv,bn,"AimbotTeamCheck","AimbotWallCheck")
                if _frameTarget~=_prevNotifTarget then
                    if _frameTarget and not _prevNotifTarget then
                        if FV("NotifAimbotLock",false) then
                            pcall(function() Lib:Notification("elocate","locked: "..(_frameTarget.IsNPC and _frameTarget.Char.Name or (_frameTarget.Player and _frameTarget.Player.Name or "?")),2) end)
                        end
                    elseif not _frameTarget and _prevNotifTarget then
                        if FV("NotifTargetLost",false) then
                            pcall(function() Lib:Notification("elocate","target lost",1.5) end)
                        end
                    end
                    _prevNotifTarget=_frameTarget
                end
            end
            do
                local aShow=FV("AimbotShowFov",false) and FV("AimbotEnabled",false)
                local aShape=FV("AimbotFovShape","Circle")
                local aR=FV("AimbotFovSize",150);local aCol=FC("AimbotFovColor",255,255,255);local aAlpha=FV("AimbotFovAlpha",0.5)
                local aOutOn=FV("AimbotFovOut",false);local aOutCol=FC("AimbotFovOutColor",0,0,0)
                if State.AimbotFovOut then
                    State.AimbotFovOut.Visible=aShow and aShape=="Circle" and aOutOn
                    if aShow and aShape=="Circle" and aOutOn then
                        State.AimbotFovOut.Position=viewCenter;State.AimbotFovOut.Radius=aR+2
                        State.AimbotFovOut.Color=aOutCol;State.AimbotFovOut.Transparency=aAlpha
                    end
                end
                if State.AimbotFovOutSq then
                    State.AimbotFovOutSq.Visible=aShow and aShape=="Square" and aOutOn
                    if aShow and aShape=="Square" and aOutOn then
                        State.AimbotFovOutSq.Position=Vector2.new(viewCenter.X-aR-2,viewCenter.Y-aR-2)
                        State.AimbotFovOutSq.Size=Vector2.new((aR+2)*2,(aR+2)*2)
                        State.AimbotFovOutSq.Color=aOutCol;State.AimbotFovOutSq.Transparency=aAlpha
                    end
                end
                if State.AimbotFov then
                    State.AimbotFov.Visible=aShow and aShape=="Circle"
                    if aShow and aShape=="Circle" then
                        State.AimbotFov.Position=viewCenter;State.AimbotFov.Radius=aR
                        State.AimbotFov.Color=aCol;State.AimbotFov.Transparency=aAlpha
                    end
                end
                if State.AimbotFovSq then
                    State.AimbotFovSq.Visible=aShow and aShape=="Square"
                    if aShow and aShape=="Square" then
                        State.AimbotFovSq.Position=Vector2.new(viewCenter.X-aR,viewCenter.Y-aR)
                        State.AimbotFovSq.Size=Vector2.new(aR*2,aR*2)
                        State.AimbotFovSq.Color=aCol;State.AimbotFovSq.Transparency=aAlpha
                    end
                end
            end
            do
                local sShow=FV("SilentShowFov",false) and FV("SilentEnabled",false)
                local sShape=FV("SilentFovShape","Circle")
                local sR=FV("SilentFovSize",150);local sCol=FC("SilentFovColor",255,255,255);local sAlpha=FV("SilentFovAlpha",0.5)
                local sOutOn=FV("SilentFovOut",false);local sOutCol=FC("SilentFovOutColor",0,0,0)
                if State.SilentFovOut then
                    State.SilentFovOut.Visible=sShow and sShape=="Circle" and sOutOn
                    if sShow and sShape=="Circle" and sOutOn then
                        State.SilentFovOut.Position=viewCenter;State.SilentFovOut.Radius=sR+2
                        State.SilentFovOut.Color=sOutCol;State.SilentFovOut.Transparency=sAlpha
                    end
                end
                if State.SilentFovOutSq then
                    State.SilentFovOutSq.Visible=sShow and sShape=="Square" and sOutOn
                    if sShow and sShape=="Square" and sOutOn then
                        State.SilentFovOutSq.Position=Vector2.new(viewCenter.X-sR-2,viewCenter.Y-sR-2)
                        State.SilentFovOutSq.Size=Vector2.new((sR+2)*2,(sR+2)*2)
                        State.SilentFovOutSq.Color=sOutCol;State.SilentFovOutSq.Transparency=sAlpha
                    end
                end
                if State.SilentFov then
                    State.SilentFov.Visible=sShow and sShape=="Circle"
                    if sShow and sShape=="Circle" then
                        State.SilentFov.Position=viewCenter;State.SilentFov.Radius=sR
                        State.SilentFov.Color=sCol;State.SilentFov.Transparency=sAlpha
                    end
                end
                if State.SilentFovSq then
                    State.SilentFovSq.Visible=sShow and sShape=="Square"
                    if sShow and sShape=="Square" then
                        State.SilentFovSq.Position=Vector2.new(viewCenter.X-sR,viewCenter.Y-sR)
                        State.SilentFovSq.Size=Vector2.new(sR*2,sR*2)
                        State.SilentFovSq.Color=sCol;State.SilentFovSq.Transparency=sAlpha
                    end
                end
            end
            local aimbotActive=FV("AimbotEnabled",false) and KB("AimbotHotkey")
            -- Sticky Aim / Auto Lock: Lock target ONCE when hotkey is first pressed (FreezyVIP style)
            local stickyEnabled=FV("AimbotSticky",false) or FV("AimbotAutoLock",false)
            if stickyEnabled and aimbotActive and not _stickyTarget then
                _stickyTarget=_frameTarget  -- Lock onto whatever _frameTarget found
            end
            -- Clear sticky target ONLY when hotkey is released
            if not aimbotActive then
                _stickyTarget=nil
            end
            if aimbotActive then
                local t=stickyEnabled and _stickyTarget or _frameTarget
                if t then
                    local boneName=FV("AimbotDefaultPart","Head")
                    local humT=GetHum(t.Char)
                    if humT then
                        local st=humT:GetState()
                        if st==Enum.HumanoidStateType.Jumping or st==Enum.HumanoidStateType.Freefall then
                            boneName=FV("AimbotJumpPart","Torso")
                        end
                        local rootT=GetRoot(t.Char)
                        if rootT and rootT.AssemblyLinearVelocity.Y < -5 then
                            boneName=FV("AimbotFallPart","Torso")
                        end
                    end
                    local bonePart=t.Char and (t.Char:FindFirstChild(boneName) or t.Char:FindFirstChild("HumanoidRootPart") or t.Char:FindFirstChild("Head"))
                    if bonePart then t=table.clone(t);t.Part=bonePart;t.Pos=bonePart.Position end
                end
                if t then
                    local tHum=GetHum(t.Char)
                    local stopOnDeath=FV("AimbotStopDeath",false)
                    -- DaHood: Check if grabbed
                    if IsGrabbed(t.Char) then
                        _stickyTarget=nil
                        t=_frameTarget
                        if t then tHum=GetHum(t.Char) end
                    end
                    -- If using sticky aim and target is dead (NPC or player), fall back to finding new target
                    if stickyEnabled and not IsTargetAlive(t) then
                        _stickyTarget=nil  -- Clear sticky target since dead
                        t=_frameTarget      -- Switch to current closest target
                        if t then
                            tHum=GetHum(t.Char)
                            _stickyTarget=t   -- Lock onto new target
                        end
                    end
                    if t and stopOnDeath and not IsTargetAlive(t) then
                        -- Stop aiming at dead targets
                    elseif t then
                        local pos=t.Pos
                        if FV("AimbotUsePred",false) then
                            local root2=GetRoot(t.Char)
                            if root2 then
                                local vel=root2.AssemblyLinearVelocity
                                pos=pos+Vector3.new(vel.X*FV("AimbotXPred",0),vel.Y*FV("AimbotYPred",0),0)
                            end
                        end
                        if FV("AimbotUseOffset",false) then
                            local hum2=GetHum(t.Char)
                            local isAir=hum2 and (hum2:GetState()==Enum.HumanoidStateType.Jumping or hum2:GetState()==Enum.HumanoidStateType.Freefall)
                            if isAir then
                                pos=pos+Vector3.new(FV("AimbotXJump",0),FV("AimbotYJump",0),FV("AimbotZJump",0))
                            else
                                pos=pos+Vector3.new(FV("AimbotXOff",0),FV("AimbotYOff",0),FV("AimbotZOff",0))
                            end
                        end
                        local mDX,mDY=_mDeltaX,_mDeltaY;_mDeltaX=0;_mDeltaY=0
                        local dzX=FV("AimbotDeadzoneX",0);local dzY=FV("AimbotDeadzoneY",0)
                        local suppressed=(dzX>0 and math.abs(mDX)>dzX) or (dzY>0 and math.abs(mDY)>dzY)
                        if not suppressed then
                            local useSmooth=FV("AimbotUseSmooth",false)
                            local sx=useSmooth and FV("AimbotXSmooth",0.5) or 0
                            local sy=useSmooth and FV("AimbotYSmooth",0.5) or 0
                            local str=math.clamp(FV("AimbotStrength",0.7),0.01,1)
                            -- Apply easing
                            local easeStyle=FV("AimbotEaseStyle","Cubic")
                            local easeDir=FV("AimbotEaseDir","Out")
                            local easeX=ApplyEasing(math.clamp((1-sx)*str,0,1),easeStyle,easeDir)
                            local easeY=ApplyEasing(math.clamp((1-sy)*str,0,1),easeStyle,easeDir)
                            local alphaX=easeX*0.6
                            local alphaY=easeY*0.6
                            local camCF=Camera.CFrame
                            local tCF=CFrame.new(camCF.Position,pos)
                            local cp,cy,cr=camCF:ToEulerAnglesYXZ()
                            local tp,ty=tCF:ToEulerAnglesYXZ()
                            local dyaw=ty-cy
                            if dyaw>math.pi then dyaw=dyaw-2*math.pi elseif dyaw<-math.pi then dyaw=dyaw+2*math.pi end
                            local nextPitch=cp+(tp-cp)*alphaY
                            local nextYaw=cy+dyaw*alphaX
                            Camera.CFrame=camCF:Lerp(CFrame.new(camCF.Position)*CFrame.fromEulerAnglesYXZ(nextPitch,nextYaw,cr),0.35)
                        end
                    end
                end
            end
            if FV("FlyEnabled",false) and State.FlyBV and State.FlyBG then
                local spd=FV("FlySpeed",50);local dir=Vector3.new();local ui=UserInputService
                if ui:IsKeyDown(Enum.KeyCode.W) then dir=dir+Camera.CFrame.LookVector end
                if ui:IsKeyDown(Enum.KeyCode.S) then dir=dir-Camera.CFrame.LookVector end
                if ui:IsKeyDown(Enum.KeyCode.A) then dir=dir-Camera.CFrame.RightVector end
                if ui:IsKeyDown(Enum.KeyCode.D) then dir=dir+Camera.CFrame.RightVector end
                if ui:IsKeyDown(Enum.KeyCode.Space) then dir=dir+Vector3.new(0,1,0) end
                if ui:IsKeyDown(Enum.KeyCode.LeftControl) or ui:IsKeyDown(Enum.KeyCode.LeftShift) then dir=dir-Vector3.new(0,1,0) end
                State.FlyBV.Velocity=dir.Magnitude>0 and dir.Unit*spd or Vector3.new()
                State.FlyBG.CFrame=Camera.CFrame
            end
            if FV("SkyboxEnabled",false) and FV("SkyboxSpin",false) then
                local sky=Lighting:FindFirstChildOfClass("Sky")
                if sky then
                    local spd=FV("SkyboxSpinSpeed",30)*dt
                    SkyboxSpin=(SkyboxSpin+spd)%360
                    local dir=FV("SkyboxSpinDir","Horizontal")
                    if dir=="Horizontal" then
                        pcall(function() sky.SkyboxOrientation=Vector3.new(0,SkyboxSpin,0) end)
                    elseif dir=="Vertical" then
                        pcall(function() sky.SkyboxOrientation=Vector3.new(SkyboxSpin,0,0) end)
                    else
                        pcall(function() sky.SkyboxOrientation=Vector3.new(SkyboxSpin,SkyboxSpin,0) end)
                    end
                end
            end
            if FV("FogEnabled",false) and FV("FogGrad",false) then
                local t2=(math.sin(tick()*0.5)+1)*0.5
                Lighting.FogColor=FC("FogGradA",100,100,150):Lerp(FC("FogGradB",200,200,220),t2)
            end
            local espOn=FV("ESPEnabled",false)
            if not espOn then
                for key,_ in State.ESPObjects do HideESP(key) end
            end
            _espThrottleDt = _espThrottleDt + dt
            if espOn and _espThrottleDt < 0.033 then
            elseif espOn then
            _espThrottleDt = 0
            local espShowSelf     = FV("ESPShowSelf",false)
            local espDeadCheck    = FV("ESPDead",false)
            local espTeamCheck    = FV("ESPTeam",false)
            local espVisCheck     = FV("ESPVisible",false)
            local espTeamColor    = FV("ESPTeamColor",false)
            local espBoxOn        = FV("ESPBox",false)
            local espBoxType      = FV("ESPBoxType","Full")
            local espBoxOutOn     = FV("ESPBoxOutline",false)
            local espBoxThick     = FV("ESPBoxThick",1)
            local espNameOn       = FV("ESPName",false)
            local espNamePos      = FV("ESPNamePos","Top")
            local espNameOut      = FV("ESPNameOut",false)
            local espNameSize     = FV("ESPNameSize",13)
            local espDistOn       = FV("ESPDist",false)
            local espDistPos      = FV("ESPDistPos","Bottom")
            local espDistType     = FV("ESPDistType","Studs")
            local espDistOut      = FV("ESPDistOut",false)
            local espToolOn       = FV("ESPTool",false)
            local espToolPos      = FV("ESPToolPos","Top")
            local espToolOut      = FV("ESPToolOut",false)
            local espHpBarOn      = FV("ESPHpBar",false)
            local espHpGrad       = FV("ESPHpGrad",false)
            local espHpText       = FV("ESPHpText",false)
            local espHpTextPos    = FV("ESPHpTextPos","Center")
            local espHpBarW       = FV("ESPHpBarW",4)
            local espTracerOn     = FV("ESPTracer",false)
            local espTracerThick  = FV("ESPTracerThick",1)
            local espTracerOut    = FV("ESPTracerOut",false)
            local espNpcOn        = FV("ESPNpc",false)
            local espBoxColor     = FC("ESPBoxColor",255,255,255)
            local espBoxOutColor  = FC("ESPBoxOutlineColor",0,0,0)
            local espNameColor    = FC("ESPNameColor",255,255,255)
            local espNameOutColor = FC("ESPNameOutColor",0,0,0)
            local espDistColor    = FC("ESPDistColor",200,200,200)
            local espDistOutColor = FC("ESPDistOutColor",0,0,0)
            local espToolColor    = FC("ESPToolColor",255,200,100)
            local espToolOutColor = FC("ESPToolOutColor",0,0,0)
            local espHpColor      = FC("ESPHpColor",0,255,0)
            local espHpGradHigh   = FC("ESPHpGradHigh",0,255,0)
            local espHpGradMid    = FC("ESPHpGradMid",255,255,0)
            local espHpGradLow    = FC("ESPHpGradLow",255,0,0)
            local espHpTextColor  = FC("ESPHpTextColor",255,255,255)
            local espTracerColor  = FC("ESPTracerColor",255,255,255)
            local espTracerOutColor=FC("ESPTracerOutColor",0,0,0)
            local espNpcColor      = FC("ESPNpcColor",255,100,100)
            local espBoxCornerT    = espBoxThick
            local espTracerOrigin  = FV("ESPTracerOrigin","Bottom")
            local espTargetInd     = FV("ESPTargetInd",false)
            local espTargetIndColor= FC("ESPTargetIndColor",255,220,0)
            local vp               = Camera.ViewportSize
            local _mouse = _mouseRef
            local tracerOX = vp.X/2
            local tracerOY = vp.Y
            if espTracerOrigin=="Top"    then tracerOY=0
            elseif espTracerOrigin=="Middle" then tracerOY=vp.Y/2
            elseif espTracerOrigin=="Mouse" and _mouse then
                tracerOX=_mouse.X; tracerOY=_mouse.Y+_guiInsetY
            end
            local _espFrameTarget=_frameTarget
            local function _drawESP(key, char, hum, root, nameStr, isPlayer, plrRef, isTarget)
                if not char or not hum or not root then HideESP(key);return end
                if espDeadCheck and (hum.Health<=0 or (plrRef and not IsAlive(plrRef))) then HideESP(key);return end
                if isPlayer and espTeamCheck and LocalPlayer.Team and plrRef and plrRef.Team==LocalPlayer.Team then HideESP(key);return end
                if espVisCheck then
                    local rp=RaycastParams.new();rp.FilterDescendantsInstances={LocalPlayer.Character,char};rp.FilterType=Enum.RaycastFilterType.Exclude
                    local hit=workspace:Raycast(Camera.CFrame.Position,(root.Position-Camera.CFrame.Position).Unit*500,rp)
                    if hit then HideESP(key);return end
                end
                local headPos,headOn=W2V(root.Position+Vector3.new(0,3,0))
                local feetPos,feetOn=W2V(root.Position-Vector3.new(0,3,0))
                local scrPos,onScreen=W2V(root.Position)
                if not onScreen or not headOn or not feetOn then HideESP(key);return end
                NewESP(key)
                local o=State.ESPObjects[key];if not o then return end
                local bH=math.abs(headPos.Y-feetPos.Y);local bW=bH*0.55
                local bX=scrPos.X-bW/2;local bY=headPos.Y
                if FV("ESPSmooth",false) then
                    local sf=math.clamp(FV("ESPSmoothFactor",0.5),0.01,0.99)
                    local prev=_espSmooth[key]
                    if prev then
                        bX=prev.bX+(bX-prev.bX)*(1-sf)
                        bY=prev.bY+(bY-prev.bY)*(1-sf)
                        bW=prev.bW+(bW-prev.bW)*(1-sf)
                        bH=prev.bH+(bH-prev.bH)*(1-sf)
                    end
                    _espSmooth[key]={bX=bX,bY=bY,bW=bW,bH=bH}
                end
                local boxColor= (espTargetInd and isTarget) and espTargetIndColor
                    or (espTeamColor and isPlayer and plrRef and plrRef.TeamColor) and plrRef.TeamColor.Color
                    or espBoxColor
                local hpPct=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
                if espBoxOn then
                    if espBoxType=="Full" then
                        if espBoxOutOn then
                            local outT=espBoxThick+2
                            o.BoxOut.Visible=true
                            o.BoxOut.Position=Vector2.new(bX-espBoxThick,bY-espBoxThick)
                            o.BoxOut.Size=Vector2.new(bW+espBoxThick*2,bH+espBoxThick*2)
                            o.BoxOut.Color=espBoxOutColor;o.BoxOut.Thickness=outT
                        else o.BoxOut.Visible=false end
                        o.Box.Visible=true;o.Box.Position=Vector2.new(bX,bY);o.Box.Size=Vector2.new(bW,bH)
                        o.Box.Color=boxColor;o.Box.Thickness=espBoxThick
                        for _,ln in o.Corners do ln.Visible=false end
                    elseif espBoxType=="Cornered" then
                        o.Box.Visible=false;o.BoxOut.Visible=false
                        local cL=bW*0.28;local cH2=bH*0.18
                        local cd={{Vector2.new(bX,bY),Vector2.new(bX+cL,bY)},{Vector2.new(bX,bY),Vector2.new(bX,bY+cH2)},
                                   {Vector2.new(bX+bW,bY),Vector2.new(bX+bW-cL,bY)},{Vector2.new(bX+bW,bY),Vector2.new(bX+bW,bY+cH2)},
                                   {Vector2.new(bX,bY+bH),Vector2.new(bX+cL,bY+bH)},{Vector2.new(bX,bY+bH),Vector2.new(bX,bY+bH-cH2)},
                                   {Vector2.new(bX+bW,bY+bH),Vector2.new(bX+bW-cL,bY+bH)},{Vector2.new(bX+bW,bY+bH),Vector2.new(bX+bW,bY+bH-cH2)}}
                        for i,d in cd do
                            local ln=o.Corners[i];if not ln then continue end
                            ln.Visible=true;ln.From=d[1];ln.To=d[2];ln.Color=boxColor;ln.Thickness=espBoxCornerT
                        end
                    end
                else o.Box.Visible=false;o.BoxOut.Visible=false;for _,ln in o.Corners do ln.Visible=false end end
                if espNameOn then
                    local nameY= espNamePos=="Top" and bY-espNameSize-2
                        or espNamePos=="Bottom" and bY+bH+2
                        or bY+bH/2-espNameSize/2
                    o.Name.Visible=true;o.Name.Text=nameStr;o.Name.Color=espNameColor
                    o.Name.Size=espNameSize;o.Name.Outline=espNameOut
                    pcall(function() o.Name.OutlineColor=espNameOutColor end)
                    o.Name.Position=Vector2.new(scrPos.X,nameY)
                else o.Name.Visible=false end
                if espDistOn then
                    local dist=(Camera.CFrame.Position-root.Position).Magnitude
                    local dval=espDistType=="Meters" and dist*0.28 or espDistType=="Yards" and dist*0.33 or dist
                    local dsufx=espDistType=="Meters" and "m" or espDistType=="Yards" and "yd" or "st"
                    local distY= espDistPos=="Top" and bY-25
                        or espDistPos=="Center" and bY+bH/2-5
                        or bY+bH+2
                    o.Dist.Visible=true;o.Dist.Text=string.format("%.0f%s",dval,dsufx);o.Dist.Color=espDistColor
                    o.Dist.Outline=espDistOut
                    pcall(function() o.Dist.OutlineColor=espDistOutColor end)
                    o.Dist.Position=Vector2.new(scrPos.X,distY)
                else o.Dist.Visible=false end
                if espToolOn then
                    local tool=char:FindFirstChildWhichIsA("Tool")
                    if tool then
                        local toolY=espToolPos=="Top" and bY-38 or bY+bH+14
                        o.Tool.Visible=true;o.Tool.Text=tool.Name;o.Tool.Color=espToolColor
                        o.Tool.Outline=espToolOut
                        pcall(function() o.Tool.OutlineColor=espToolOutColor end)
                        o.Tool.Position=Vector2.new(scrPos.X,toolY)
                    else o.Tool.Visible=false end
                else o.Tool.Visible=false end
                if espHpBarOn then
                    local barW=espHpBarW;local barX=bX-barW-3;local barFH=math.max(1,bH*hpPct)
                    o.HpBg.Visible=true;o.HpBg.Position=Vector2.new(barX,bY);o.HpBg.Size=Vector2.new(barW,bH);o.HpBg.Color=C(20,20,20)
                    local hpCol
                    if espHpGrad then
                        if hpPct>0.5 then hpCol=espHpGradHigh:Lerp(espHpGradMid,1-(hpPct-0.5)*2)
                        else hpCol=espHpGradMid:Lerp(espHpGradLow,1-hpPct*2) end
                    else hpCol=espHpColor end
                    o.Hp.Visible=true;o.Hp.Position=Vector2.new(barX,bY+bH-barFH);o.Hp.Size=Vector2.new(barW,barFH);o.Hp.Color=hpCol
                    if espHpText then
                        o.HpText.Visible=true;o.HpText.Text=math.floor(hum.Health).."hp";o.HpText.Color=espHpTextColor
                        if espHpTextPos=="Top" then o.HpText.Position=Vector2.new(barX+barW/2,bY-12)
                        elseif espHpTextPos=="Bottom" then o.HpText.Position=Vector2.new(barX+barW/2,bY+bH)
                        else o.HpText.Position=Vector2.new(barX+barW/2,bY+bH/2-5) end
                    else o.HpText.Visible=false end
                else o.HpBg.Visible=false;o.Hp.Visible=false;o.HpText.Visible=false end
                if espTracerOn then
                    local tTo=Vector2.new(scrPos.X, espTracerOrigin=="Top" and bY or bY+bH)
                    local tFrom=Vector2.new(tracerOX,tracerOY)
                    o.Tracer.Visible=true;o.Tracer.From=tFrom
                    o.Tracer.To=tTo;o.Tracer.Color=espTracerColor;o.Tracer.Thickness=espTracerThick
                    if espTracerOut and o.TracerOut then
                        o.TracerOut.Visible=true;o.TracerOut.From=tFrom
                        o.TracerOut.To=tTo;o.TracerOut.Color=espTracerOutColor
                        o.TracerOut.Thickness=espTracerThick+2
                    elseif o.TracerOut then o.TracerOut.Visible=false end
                else
                    o.Tracer.Visible=false
                    if o.TracerOut then o.TracerOut.Visible=false end
                end
            end
            local seenESP={}
            for _,plr in Players:GetPlayers() do
                if (not espShowSelf) and plr==LocalPlayer then HideESP(plr);continue end
                local char=plr.Character;local hum=GetHum(char);local root=GetRoot(char)
                seenESP[plr]=true
                local isTarget=_espFrameTarget and _espFrameTarget.Plr==plr
                _drawESP(plr,char,hum,root,plr.DisplayName,true,plr,isTarget)
            end
            if espNpcOn then
                local npcs=_collectNpcModels()
                local npcKeys={}
                for _,npc in ipairs(npcs) do npcKeys[npc]=true end
                for key,_ in State.ESPObjects do
                    if not seenESP[key] and not npcKeys[key] then HideESP(key) end
                end
                for _,npc in ipairs(npcs) do
                    local hum=npc:FindFirstChildOfClass("Humanoid")
                    local root=_aimablePart(npc)
                    local npcBoxCol=espNpcColor
                    local savedBoxCol=espBoxColor
                    espBoxColor=npcBoxCol
                    _drawESP(npc,npc,hum,root,npc.Name,false,nil)
                    espBoxColor=savedBoxCol
                end
            else
                for key,_ in State.ESPObjects do
                    if not seenESP[key] then HideESP(key) end
                end
            end
            end
            local _aimbotLive=FV("AimbotEnabled",false) and KB("AimbotHotkey")
            local _silentLive=FV("SilentEnabled",false) and KB("SilentHotkey")
            local _targetGate=(_aimbotLive or _silentLive) and _frameTarget~=nil
            local ttOn=FV("TargetTracerEnabled",false) and _targetGate
            if ttOn and HasDrawing then
                local tgt=_frameTarget
                if tgt then
                    local tRoot=GetRoot(tgt.Char)
                    if tRoot then
                        local tHead,tHeadOn=W2V(tRoot.Position+Vector3.new(0,3,0))
                        local tFeet,tFeetOn=W2V(tRoot.Position-Vector3.new(0,3,0))
                        local tScr,tOn=W2V(tRoot.Position)
                        local tvp=Camera.ViewportSize
                        local tvOX=_mouseRef and _mouseRef.X or tvp.X/2
                        local tvOY=_mouseRef and (_mouseRef.Y+_guiInsetY) or tvp.Y
                        if tOn and tHeadOn and tFeetOn and State.TargetTracer then
                            local tH=math.abs(tHead.Y-tFeet.Y);local tY=tHead.Y
                            local ttFrom=Vector2.new(tvOX,tvOY)
                            local ttTo=Vector2.new(tScr.X, tY+tH)
                            if FV("TargetTracerOutEnabled",false) and State.TargetTracerOut then
                                State.TargetTracerOut.Visible=true
                                State.TargetTracerOut.From=ttFrom;State.TargetTracerOut.To=ttTo
                                State.TargetTracerOut.Color=FC("TargetTracerOutColor",0,0,0)
                                State.TargetTracerOut.Thickness=FV("TargetTracerOutThick",1.5)
                                State.TargetTracerOut.Transparency=FV("TargetTracerOutAlpha",0)
                            elseif State.TargetTracerOut then State.TargetTracerOut.Visible=false end
                            State.TargetTracer.Visible=true
                            State.TargetTracer.From=ttFrom;State.TargetTracer.To=ttTo
                            State.TargetTracer.Color=FC("TargetTracerColor",255,255,255)
                            State.TargetTracer.Thickness=FV("TargetTracerThick",1)
                            State.TargetTracer.Transparency=FV("TargetTracerAlpha",0)
                        else
                            if State.TargetTracer    then State.TargetTracer.Visible=false end
                            if State.TargetTracerOut then State.TargetTracerOut.Visible=false end
                        end
                    end
                else
                    if State.TargetTracer    then State.TargetTracer.Visible=false end
                    if State.TargetTracerOut then State.TargetTracerOut.Visible=false end
                end
            else
                if State.TargetTracer    then State.TargetTracer.Visible=false end
                if State.TargetTracerOut then State.TargetTracerOut.Visible=false end
            end
            if FV("TargetDotEnabled",false) and _targetGate and HasDrawing and State.TargetDot then
                local tgt3=_frameTarget
                local tRoot3=tgt3 and GetRoot(tgt3.Char)
                if tRoot3 then
                    local scrPos,scrOn=W2V(tRoot3.Position+Vector3.new(0,2.5,0))
                    if scrOn then
                        State.TargetDot.Visible=true
                        State.TargetDot.Position=scrPos
                        State.TargetDot.Radius=FV("TargetDotRadius",5)
                        State.TargetDot.Color=FC("TargetDotColor",255,50,50)
                        State.TargetDot.Transparency=FV("TargetDotAlpha",0)
                    else
                        State.TargetDot.Visible=false
                    end
                else
                    State.TargetDot.Visible=false
                end
            else
                if State.TargetDot then State.TargetDot.Visible=false end
            end
            local hudOn=FV("TargetHudEnabled",false) and _targetGate
            if hudOn and _hudFrame then
                local tgt2=_frameTarget
                local tRoot2 = tgt2 and GetRoot(tgt2.Char)
                local tHum2  = tgt2 and tgt2.Char and tgt2.Char:FindFirstChildOfClass("Humanoid")
                if tgt2 and tRoot2 and tHum2 then
                    _hudFrame.Visible=true
                    local hudPos=FV("TargetHudPos","Bottom Center")
                    if hudPos=="Bottom Center" then
                        _hudFrame.AnchorPoint=Vector2.new(0.5,1)
                        _hudFrame.Position=UDim2.new(0.5,0,1,-20)
                    elseif hudPos=="Top Center" then
                        _hudFrame.AnchorPoint=Vector2.new(0.5,0)
                        _hudFrame.Position=UDim2.new(0.5,0,0,20)
                    elseif hudPos=="Left" then
                        _hudFrame.AnchorPoint=Vector2.new(0,0.5)
                        _hudFrame.Position=UDim2.new(0,10,0.5,0)
                    else
                        _hudFrame.AnchorPoint=Vector2.new(1,0.5)
                        _hudFrame.Position=UDim2.new(1,-10,0.5,0)
                    end
                    local tName=tgt2.IsNPC and tgt2.Char.Name or (tgt2.Player and tgt2.Player.DisplayName or "?")
                    if _hudNameLabel then _hudNameLabel.Text=tName end
                    if _hudAvatar then
                        if not tgt2.IsNPC and tgt2.Player then
                            local uid=tgt2.Player.UserId
                            if _hudAvatar:GetAttribute("_uid")~=uid then
                                _hudAvatar:SetAttribute("_uid",uid)
                                task.spawn(function()
                                    local ok,img=pcall(function() return Players:GetUserThumbnailAsync(uid,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48) end)
                                    if ok and img then pcall(function() _hudAvatar.Image=img end) end
                                end)
                            end
                        else
                            _hudAvatar.Image=""
                        end
                    end
                    local hpP=math.clamp(tHum2.Health/math.max(tHum2.MaxHealth,1),0,1)
                    if _hudHpBarFill then
                        _hudHpBarFill.Size=UDim2.new(hpP,0,1,0)
                        _hudHpBarFill.BackgroundColor3=Color3.fromRGB(0,210,80):Lerp(Color3.fromRGB(220,50,50),1-hpP)
                    end
                    if _hudHpText then _hudHpText.Text=math.floor(tHum2.Health).." / "..math.floor(tHum2.MaxHealth).." HP" end
                    local tDist2=(Camera.CFrame.Position-tRoot2.Position).Magnitude
                    if _hudDistLabel then _hudDistLabel.Text=string.format("%.0f studs away",tDist2) end
                else
                    if _hudFrame then _hudFrame.Visible=false end
                end
            else
                if _hudFrame then _hudFrame.Visible=false end
            end
            if HasDrawing then
                _fpsSmooth = _fpsSmooth*0.9 + (1/math.max(dt,0.001))*0.1
                local now2=tick()
                if now2-_pingTick > 2 then
                    _pingTick=now2
                    pcall(function() _pingCache=math.round(LocalPlayer:GetNetworkPing()*1000) end)
                end
                if _wmLabel then
                    local wmStr=string.format("elocate.lol  |  fps: %d  |  ping: %dms  |  gameid: %s",
                        math.round(_fpsSmooth), _pingCache, _gameId)
                    _wmLabel.Text=wmStr
                end
                local chOn=FV("ChEnabled",false)
                if chOn and State.ChLines and State.ChDot then
                    local mouse=LocalPlayer:GetMouse()
                    local cX,cY
                    if FV("ChPosType","Center")=="Mouse" then cX=mouse.X;cY=mouse.Y+_guiInsetY
                    else cX=viewCenter.X;cY=viewCenter.Y end
                    if FV("ChSpin",false) then
                        _chSpinAngle=(_chSpinAngle+FV("ChSpinSpeed",90)*dt)%360
                    end
                    local rad=math.rad(_chSpinAngle)
                    local cs=math.cos(rad);local sn=math.sin(rad)
                    local sz=FV("ChSize",10);local gap=FV("ChGap",3)
                    local thick=FV("ChThick",1);local col=FC("ChColor",255,255,255)
                    local outOn=FV("ChOutline",false);local outCol=FC("ChOutColor",0,0,0)
                    local arms={{0,-gap,0,-(gap+sz)},{0,gap,0,gap+sz},{-gap,0,-(gap+sz),0},{gap,0,gap+sz,0}}
                    for i=1,4 do
                        local a=arms[i]
                        local x1=cX+a[1]*cs-a[2]*sn;local y1=cY+a[1]*sn+a[2]*cs
                        local x2=cX+a[3]*cs-a[4]*sn;local y2=cY+a[3]*sn+a[4]*cs
                        local ln=State.ChLines[i]
                        if ln then ln.Visible=true;ln.From=Vector2.new(x1,y1);ln.To=Vector2.new(x2,y2);ln.Color=col;ln.Thickness=thick end
                        if outOn and State.ChOutLines then
                            local lo=State.ChOutLines[i]
                            if lo then lo.Visible=true;lo.From=Vector2.new(x1,y1);lo.To=Vector2.new(x2,y2);lo.Color=outCol;lo.Thickness=thick+2 end
                        elseif State.ChOutLines then
                            local lo=State.ChOutLines[i];if lo then lo.Visible=false end
                        end
                    end
                    if State.ChDot then
                        State.ChDot.Visible=FV("ChDot",true)
                        State.ChDot.Position=Vector2.new(cX,cY)
                        State.ChDot.Radius=FV("ChDotSize",2)
                        State.ChDot.Color=col
                    end
                    -- Crosshair watermark text: elocate.lol
                    if FV("ChTextEnabled",true) and State.ChText1 and State.ChText2 then
                        local textCol=FC("ChTextColor",202,243,255)
                        local textY=cY+gap+sz+5
                        State.ChText1.Visible=true
                        State.ChText1.Position=Vector2.new(cX-1,textY)
                        State.ChText1.Color=textCol
                        State.ChText2.Visible=true
                        State.ChText2.Position=Vector2.new(cX+State.ChText1.TextBounds.X-1,textY)
                    elseif State.ChText1 then
                        State.ChText1.Visible=false
                        if State.ChText2 then State.ChText2.Visible=false end
                    end
                else
                    if State.ChLines then for _,ln in ipairs(State.ChLines) do if ln then ln.Visible=false end end end
                    if State.ChOutLines then for _,ln in ipairs(State.ChOutLines) do if ln then ln.Visible=false end end end
                    if State.ChDot then State.ChDot.Visible=false end
                    if State.ChText1 then State.ChText1.Visible=false end
                    if State.ChText2 then State.ChText2.Visible=false end
                end
            end
        end)
        local _chamsThrottleTick = 0
        Lib:Connect(RunService.Heartbeat, function(dt)
            local char=LocalPlayer.Character;local hum=GetHum(char);local root=GetRoot(char)
            if hum and FV("SpeedEnabled",false) and KB("SpeedHotkey") then
                local spType=FV("SpeedType","WalkSpeed")
                if spType=="WalkSpeed" then
                    hum.WalkSpeed=FV("SpeedValue",50)
                elseif root and spType=="CFrame" then
                    local mv=Vector3.new();local ui=UserInputService
                    if ui:IsKeyDown(Enum.KeyCode.W) then mv=mv+Camera.CFrame.LookVector end
                    if ui:IsKeyDown(Enum.KeyCode.S) then mv=mv-Camera.CFrame.LookVector end
                    if mv.Magnitude>0 then root.CFrame=root.CFrame+mv.Unit*FV("SpeedValue",50)*dt end
                elseif root and spType=="Velo" then
                    local mv=hum.MoveDirection
                    if mv.Magnitude>0 then
                        local spd=FV("SpeedValue",50)
                        root.Velocity=Vector3.new(mv.X*spd,root.Velocity.Y,mv.Z*spd)
                    end
                end
            elseif hum and not FV("SpeedEnabled",false) and hum.WalkSpeed~=16 and not FV("FlyEnabled",false) then
                hum.WalkSpeed=16
            end
            if hum then
                if FV("JumpEnabled",false) then hum.JumpPower=FV("JumpPower",100)
                elseif hum.JumpPower~=50 and not FV("JumpEnabled",false) then hum.JumpPower=50 end
            end
            if hum and FV("InfJumpEnabled",false) then
                local jumping=UserInputService:IsKeyDown(Enum.KeyCode.Space)
                if jumping and not lastInfJump and hum.FloorMaterial~=Enum.Material.Air then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
                lastInfJump=jumping
            end
            if char and FV("NoClipEnabled",false) and KB("NoClipHotkey") then
                for _,p in char:GetDescendants() do if p:IsA("BasePart") then p.CanCollide=false end end
            end
            if root and FV("SpinEnabled",false) and KB("SpinHotkey") then
                local spd=FV("SpinSpeed",400);local mult=FV("SpinDir","Clockwise")=="Clockwise" and 1 or -1
                State.SpinAngle=State.SpinAngle+spd*dt*mult
                root.CFrame=CFrame.new(root.CFrame.Position)*CFrame.Angles(0,math.rad(State.SpinAngle),0)
            end
            if root and hum and FV("AntiAimEnabled",false) then
                local t=FV("AntiAimType","180 Flip");local cf=root.CFrame
                if t=="180 Flip" then root.CFrame=cf*CFrame.Angles(0,math.pi,0)
                elseif t=="Down" then root.CFrame=cf*CFrame.Angles(math.pi,0,0)
                elseif t=="Jitter" then root.CFrame=cf*CFrame.Angles(0,math.rad(math.random(-180,180)),0)
                elseif t=="Random" then root.CFrame=cf*CFrame.Angles(math.rad(math.random(-180,180)),math.rad(math.random(-180,180)),0) end
            end
            if root and FV("DesyncEnabled",false) and KB("DesyncHotkey") then
                local now3=tick()
                if now3-_desyncTick > 0.08 then
                    _desyncTick=now3
                    local realCF=root.CFrame
                    local off=FV("DesyncAmount",80)
                    pcall(function() root.CFrame=CFrame.new(realCF.Position+Vector3.new(off,0,0)) end)
                    task.defer(function()
                        if root and root.Parent then pcall(function() root.CFrame=realCF end) end
                    end)
                end
            end
            if hum and FV("BHopEnabled",false) and KB("BHopHotkey") then
                if hum.FloorMaterial~=Enum.Material.Air then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
            if FV("VoidHideEnabled",false) and KB("VoidHideHotkey") then
                if root then
                    if not _voidSavedCF then _voidSavedCF=root.CFrame end
                    local vp2=FV("VoidHidePos","Last Position")
                    local vy=vp2=="High Altitude" and 10000 or -5000
                    local vx2=_voidSavedCF.Position.X;local vz2=_voidSavedCF.Position.Z
                    if vp2=="Random" then vx2=math.random(-5000,5000);vz2=math.random(-5000,5000) end
                    pcall(function() root.CFrame=CFrame.new(vx2,vy,vz2) end)
                end
            elseif _voidSavedCF then
                if root then pcall(function() root.CFrame=_voidSavedCF end) end
                _voidSavedCF=nil
            end
            if FV("TargetSpec",false) and KB("TargetSpecHotkey") and _frameTarget and _frameTarget.Char then
                local tHum3=_frameTarget.Char:FindFirstChildOfClass("Humanoid")
                if tHum3 and Camera.CameraSubject~=tHum3 then Camera.CameraSubject=tHum3 end
                _specActive=true
            elseif _specActive then
                local lHum=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if lHum then Camera.CameraSubject=lHum end
                _specActive=false
            end
            if FV("TriggerEnabled",false) and KB("TriggerHotkey") then
                local now2=tick()
                local delay2=FV("TriggerDelay",0.05)
                if not State._triggerCD then State._triggerCD=0 end
                if now2-State._triggerCD > delay2*2+0.05 then
                    local rp=RaycastParams.new();rp.FilterDescendantsInstances={LocalPlayer.Character};rp.FilterType=Enum.RaycastFilterType.Exclude
                    local hit=workspace:Raycast(Camera.CFrame.Position,Camera.CFrame.LookVector*FV("TriggerDist",300),rp)
                    if hit and hit.Instance then
                        local m=hit.Instance:FindFirstAncestorOfClass("Model")
                        if m then
                            local plr2=Players:GetPlayerFromCharacter(m)
                            local isValidPlayer = plr2 and plr2~=LocalPlayer
                            local isNPC = (not plr2) and FV("GlobalNPC",false) and m:FindFirstChildOfClass("Humanoid")
                            if isValidPlayer or isNPC then
                                State._triggerCD=now2
                                task.delay(delay2,function()
                                    local clicked=false
                                    if mouse1click then pcall(function() mouse1click();clicked=true end) end
                                    if not clicked and mouse1press then pcall(function() mouse1press();task.wait(0.01);mouse1release() end) end
                                    if not clicked then
                                        pcall(function()
                                            local vim=game:GetService("VirtualInputManager")
                                            vim:SendMouseButtonEvent(0,0,0,true,game,0)
                                            task.wait(0.01)
                                            vim:SendMouseButtonEvent(0,0,0,false,game,0)
                                        end)
                                    end
                                end)
                            end
                        end
                    end
                end
            end
            if FV("HitboxEnabled",false) then
                for _,plr in Players:GetPlayers() do
                    if plr==LocalPlayer then continue end
                    local c2=plr.Character
                    local partName=FV("HitboxPart","HumanoidRootPart")
                    if partName=="All" then
                        if c2 then
                            for _,p in c2:GetDescendants() do
                                if p:IsA("BasePart") then
                                    if not State.HitboxSizes[plr] then State.HitboxSizes[plr]=p.Size end
                                    local sz=FV("HitboxSize",5);pcall(function() p.Size=Vector3.new(sz,sz,sz) end)
                                end
                            end
                        end
                    else
                        local r2=c2 and c2:FindFirstChild(partName)
                        if r2 then
                            if not State.HitboxSizes[plr] then State.HitboxSizes[plr]=r2.Size end
                            local sz=FV("HitboxSize",5);pcall(function() r2.Size=Vector3.new(sz,sz,sz) end)
                        end
                    end
                end
            end
            if FV("AntiAFKEnabled",false) then
                pcall(function()
                    local vip=game:GetService("VirtualInputManager")
                    vip:SendKeyEvent(true,Enum.KeyCode.ButtonL3,false,game)
                    vip:SendKeyEvent(false,Enum.KeyCode.ButtonL3,false,game)
                end)
            end
            if FV("GravityEnabled",false) then
                pcall(function() workspace.Gravity=FV("GravityValue",50) end)
            end
            if FV("MouseSensEnabled",false) then
                pcall(function() UserInputService.MouseDeltaSensitivity=FV("MouseSensValue",1) end)
            end
            if FV("MouseLockEnabled",false) then
                pcall(function() UserInputService.MouseBehavior=Enum.MouseBehavior.LockCenter end)
            end
            if FV("MouseIconHide",false) then
                pcall(function() UserInputService.MouseIconEnabled=false end)
            end
            _chamsThrottleTick=_chamsThrottleTick+1
            if _chamsThrottleTick>=10 then _chamsThrottleTick=0;pcall(applyChams,dt) end
            pcall(applyWorld, dt)
        end)
        if HasHook then
            local _saTarget      = nil
            local _saLastScan    = 0
            local _saLastTgtName = nil
            local function getSilentAimTarget()
                if not FV("SilentEnabled",false) then _saTarget=nil;return nil end
                if not KB("SilentHotkey")         then _saTarget=nil;return nil end
                local now=tick()
                if now-_saLastScan < 0.03 then return _saTarget end
                _saLastScan=now
                local hitchance=FV("SilentHitChance",100)
                if hitchance<100 and math.random()*100>hitchance then
                    _saTarget=nil;return nil
                end
                local maxFov=FV("SilentUseFov",false) and FV("SilentFovSize",80) or 9999
                if FV("SilentDaHood",false) then maxFov=maxFov+math.random(-5,5) end
                local teamFlag=FV("SilentTeamCheck",false) and "AimbotTeamCheck" or nil
                local t=ClosestPlayer(maxFov,FV("SilentHitpart","Head"),teamFlag,nil)
                if t then
                    _saTarget=t.Part
                    _saLastTgtName=t.Player and t.Player.Name or ""
                    return _saTarget
                end
                _saTarget=nil;_saLastTgtName=nil;return nil
            end
            local function getPredictedPosition(part)
                if not part then return nil end
                local ok,pos=pcall(function() return part.Position end)
                if not ok then return nil end
                local resolverMode=FV("SilentResolverMode","Off")
                local useResolver=FV("SilentUseRes",false) and resolverMode~="Off"
                if FV("SilentUsePred",false) or useResolver then
                    local ok2,vel=pcall(function() return part.AssemblyLinearVelocity end)
                    if ok2 and vel then
                        local px=FV("SilentXPred",0)
                        local py=FV("SilentYPred",0)
                        local pz=FV("SilentZPred",0)
                        if useResolver then
                            local char=part.Parent
                            local hum=char and char:FindFirstChildOfClass("Humanoid")
                            local state=hum and hum:GetState() or nil
                            local speed=vel.Magnitude
                            if resolverMode=="Stand" then
                                if speed<1 then vel=Vector3.zero end
                            elseif resolverMode=="Slow" then
                                if speed<16 then vel=vel*0.5 end
                            elseif resolverMode=="Air" then
                                if state==Enum.HumanoidStateType.Jumping or state==Enum.HumanoidStateType.Freefall then
                                    vel=Vector3.new(vel.X*1.5,vel.Y,vel.Z*1.5)
                                end
                            elseif resolverMode=="All" then
                                local rv=vel
                                if speed<1 then rv=Vector3.zero
                                elseif speed<16 then rv=rv*0.7 end
                                if state==Enum.HumanoidStateType.Jumping or state==Enum.HumanoidStateType.Freefall then
                                    rv=Vector3.new(rv.X*1.3,rv.Y,rv.Z*1.3)
                                end
                                vel=rv
                            end
                        end
                        pos=pos+Vector3.new(vel.X*px,vel.Y*py,vel.Z*pz)
                    end
                end
                if FV("SilentDaHood",false) then
                    pos=pos+Vector3.new((math.random()-0.5)*0.2,(math.random()-0.5)*0.2,(math.random()-0.5)*0.2)
                end
                return pos
            end
            local _saMouseRef=nil
            pcall(function() _saMouseRef=LocalPlayer:GetMouse() end)
            pcall(function()
                local grm=getrawmetatable(game)
                local oldIdx=rawget(grm,"__index")
                local oldNC=rawget(grm,"__namecall")
                setreadonly(grm,false)
                grm.__index=newcclosure(function(self,key)
                    local isScriptCaller=checkcaller()
                    local isMouse=_saMouseRef~=nil and self==_saMouseRef
                    if (not isScriptCaller) and isMouse and FV("SilentEnabled",false) then
                        if key=="Hit" or key=="hit" then
                            local part=getSilentAimTarget()
                            if part then
                                local pos=getPredictedPosition(part)
                                if pos then
                                    local camPos=Camera.CFrame.Position
                                    local ok,cf=pcall(CFrame.lookAt,pos,camPos)
                                    return ok and cf or CFrame.new(pos,camPos)
                                end
                            end
                        elseif key=="Target" or key=="target" then
                            local part=getSilentAimTarget()
                            if part then return part end
                        elseif key=="Origin" or key=="origin" then
                            if FV("SilentDaHood",false) then
                                local part=getSilentAimTarget()
                                if part then return Camera.CFrame end
                            end
                        end
                    end
                    return oldIdx(self,key)
                end)
                grm.__namecall=newcclosure(function(self,...)
                    local method=getnamecallmethod()
                    if FV("SilentRaycast",false) and FV("SilentEnabled",false) and KB("SilentHotkey") then
                        local args={...}
                        local part=getSilentAimTarget()
                        if part then
                            local tPos=getPredictedPosition(part)
                            if tPos then
                                if method=="Raycast" and args[1] and typeof(args[1])=="Vector3" and args[2] and typeof(args[2])=="Vector3" then
                                    args[2]=(tPos-args[1]).Unit*args[2].Magnitude
                                    return oldNC(self,table.unpack(args))
                                end
                                if (method=="FindPartOnRayWithIgnoreList" or method=="FindPartOnRayWithWhitelist") and args[1] and typeof(args[1])=="Ray" then
                                    local nr=Ray.new(args[1].Origin,(tPos-args[1].Origin).Unit*args[1].Direction.Magnitude)
                                    args[1]=nr;return oldNC(self,table.unpack(args))
                                end
                            end
                        end
                    end
                    return oldNC(self,...)
                end)
                setreadonly(grm,true)
                Lib:OnUnload(function()
                    pcall(function()
                        setreadonly(grm,false)
                        grm.__index=oldIdx
                        grm.__namecall=oldNC
                        setreadonly(grm,true)
                    end)
                end)
            end)
        end
        Lib:Connect(Players.PlayerRemoving,function(plr)
            RemoveESP(plr)
            if _highlights[plr] then pcall(function()_highlights[plr]:Destroy()end);_highlights[plr]=nil end
            State.HitboxSizes[plr]=nil
        end)
        local function _connectHitNotif(plr)
            if plr==LocalPlayer then return end
            local function connectChar(char)
                if not char then return end
                local hum2=char:FindFirstChildOfClass("Humanoid")
                if not hum2 then return end
                local prevHp={hum2.Health}
                Lib:Connect(hum2.HealthChanged,function(hp)
                    if hp<prevHp[1] and FV("NotifHitLanded",false) then
                        local dmg=prevHp[1]-hp
                        pcall(function() Lib:Notification("elocate","-"..math.floor(dmg).." hp",1) end)
                    end
                    prevHp[1]=hp
                end)
            end
            Lib:Connect(plr.CharacterAdded,connectChar)
            connectChar(plr.Character)
        end
        for _,plr2 in Players:GetPlayers() do _connectHitNotif(plr2) end
        Lib:Connect(Players.PlayerAdded,_connectHitNotif)
        task.spawn(function()
            while Lib and Lib.Flags do
                task.wait(120)
                pcall(function() if Lib and Lib.Flags then FS.writefile(DEFAULT_CFG,Lib:GetConfig()) end end)
            end
        end)
        Lib:OnUnload(function()
            Lighting.FogStart=State.OrigLighting.FogStart;Lighting.FogEnd=State.OrigLighting.FogEnd
            Lighting.FogColor=State.OrigLighting.FogColor;Lighting.Brightness=State.OrigLighting.Brightness
            Lighting.ExposureCompensation=State.OrigLighting.ExposureComp
            Lighting.ClockTime=State.OrigLighting.ClockTime;Lighting.ShadowSoftness=State.OrigLighting.ShadowSoft
            Lighting.Ambient=State.OrigLighting.Ambient;Lighting.OutdoorAmbient=State.OrigLighting.OutdoorAmbient
            if FV("SkyboxEnabled",false) then RestoreSkybox() end
            for plr,sz in State.HitboxSizes do
                local root=GetRoot(plr.Character);if root then pcall(function()root.Size=sz end) end
            end
            StopRain()
            clearHighlights()
            clearToolHls()
            if _matApplied then restoreMaterials() end
            local c=LocalPlayer.Character;local h=GetHum(c)
            if h then h.PlatformStand=false;h.WalkSpeed=16;h.JumpPower=50 end
            if _specActive then
                local lHum2=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if lHum2 then pcall(function() Camera.CameraSubject=lHum2 end) end
            end
            if _voidSavedCF then
                local c2=LocalPlayer.Character;local r2=GetRoot(c2)
                if r2 then pcall(function() r2.CFrame=_voidSavedCF end) end
            end
            if State.FlyBV then pcall(State.FlyBV.Destroy,State.FlyBV) end
            if State.FlyBG then pcall(State.FlyBG.Destroy,State.FlyBG) end
            if State.AimbotFov      then pcall(function()State.AimbotFov:Remove()end) end
            if State.SilentFov      then pcall(function()State.SilentFov:Remove()end) end
            if State.AimbotFovSq    then pcall(function()State.AimbotFovSq:Remove()end) end
            if State.SilentFovSq    then pcall(function()State.SilentFovSq:Remove()end) end
            if State.AimbotFovOut   then pcall(function()State.AimbotFovOut:Remove()end) end
            if State.AimbotFovOutSq then pcall(function()State.AimbotFovOutSq:Remove()end) end
            if State.SilentFovOut   then pcall(function()State.SilentFovOut:Remove()end) end
            if State.SilentFovOutSq then pcall(function()State.SilentFovOutSq:Remove()end) end
            if State.TargetTracer   then pcall(function()State.TargetTracer:Remove()end) end
            if State.TargetTracerOut then pcall(function()State.TargetTracerOut:Remove()end) end
            if State.TargetDot      then pcall(function()State.TargetDot:Remove()end) end
            if State.ChLines    then for _,ln in ipairs(State.ChLines)    do pcall(function()ln:Remove()end) end end
            if State.ChOutLines then for _,ln in ipairs(State.ChOutLines) do pcall(function()ln:Remove()end) end end
            if State.ChDot  then pcall(function()State.ChDot:Remove()end) end
            if State.ChText1 then pcall(function()State.ChText1:Remove()end) end
            if State.ChText2 then pcall(function()State.ChText2:Remove()end) end
            for key,_ in State.ESPObjects do RemoveESP(key) end
            pcall(clearFFChams)
            pcall(function() workspace.Gravity=196.2 end)
            pcall(function() UserInputService.MouseDeltaSensitivity=1 end)
            pcall(function() UserInputService.MouseIconEnabled=true end)
            pcall(function() UserInputService.MouseBehavior=Enum.MouseBehavior.Default end)
            pcall(function() FS.writefile(DEFAULT_CFG,Lib:GetConfig()) end)
        end)
        if FV("NotifKeyLoad",true) then Lib:Notification("elocate.lol","loaded — press INSERT to toggle",5) end
    else
        if WasAuto then pcall(FS.delfile,KEY_FILE);savedKey=nil;SetStatus("saved key expired — enter new key",true)
        else SetStatus((result and result.error) or "invalid key",true) end
        VTxt.Text="verify key";Verifying=false
    end
end
UserInputService.InputBegan:Connect(function(input)
    if (input.KeyCode==Enum.KeyCode.Return or input.KeyCode==Enum.KeyCode.KeypadEnter)
        and KeyInput:IsFocused() then DoVerify() end
end)
VerifyBtn.MouseButton1Click:Connect(DoVerify)
if savedKey then task.delay(.55,function() DoVerify(savedKey) end) end
