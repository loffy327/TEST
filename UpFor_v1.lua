--[[
    ================================================================

        U P F O R   Framework
        Roblox Luau Premium UI Library

        Version   : 1.0.1
        Build     : 2026.06.21
        License   : Lifetime Full Source — 3,000,000 VND

    ================================================================
--]]

-- ════════════════════════════════════════════════════════════════
--  SERVICES
-- ════════════════════════════════════════════════════════════════

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")
local Players          = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════════
--  COLOR SYSTEM
-- ════════════════════════════════════════════════════════════════

local C = {
    Void     = Color3.fromRGB(6,   6,  14),
    Abyss    = Color3.fromRGB(10, 10,  22),
    Deep     = Color3.fromRGB(14, 14,  28),
    Surface  = Color3.fromRGB(18, 18,  36),
    Lift     = Color3.fromRGB(24, 24,  48),
    Rise     = Color3.fromRGB(30, 30,  60),

    E1       = Color3.fromRGB(108, 92, 255),
    E2       = Color3.fromRGB(138,122, 255),
    E3       = Color3.fromRGB(78,  65, 210),

    Cy       = Color3.fromRGB(60, 210, 255),

    T1       = Color3.fromRGB(235, 235, 248),
    T2       = Color3.fromRGB(145, 145, 180),
    T3       = Color3.fromRGB(70,  70, 110),

    Edge     = Color3.fromRGB(40,  40,  78),
    Divider  = Color3.fromRGB(28,  28,  55),

    Green    = Color3.fromRGB(40,  205, 120),
    Yellow   = Color3.fromRGB(255, 195,  55),
    Red      = Color3.fromRGB(235,  65,  75),
    Blue     = Color3.fromRGB(60,  190, 255),

    Pure     = Color3.new(1, 1, 1),
    Black    = Color3.new(0, 0, 0),
}

-- ════════════════════════════════════════════════════════════════
--  TWEEN HELPERS
-- ════════════════════════════════════════════════════════════════

local function tw(obj, props, t, style, dir)
    local tween = TweenService:Create(obj,
        TweenInfo.new(t or 0.25, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
        props
    )
    tween:Play()
    return tween
end

local function twBack(obj, p, t)   return tw(obj, p, t, Enum.EasingStyle.Back) end
local function twSine(obj, p, t)   return tw(obj, p, t, Enum.EasingStyle.Sine) end
local function twLinear(obj, p, t) return tw(obj, p, t, Enum.EasingStyle.Linear) end
local function twSpring(obj, p, t) return tw(obj, p, t, Enum.EasingStyle.Spring) end

-- ════════════════════════════════════════════════════════════════
--  INSTANCE FACTORY
-- ════════════════════════════════════════════════════════════════

local function N(cls, props, parent)
    local o = Instance.new(cls)
    if props   then for k, v in pairs(props) do o[k] = v end end
    if parent  then o.Parent = parent end
    return o
end

local function Corner(o, r)   return N("UICorner", { CornerRadius = r or UDim.new(0,8) }, o) end
local function Stroke(o, col, th, tr)
    return N("UIStroke", { Color = col or C.Edge, Thickness = th or 1, Transparency = tr or 0 }, o)
end
local function Gradient(o, cs, ts, rot)
    return N("UIGradient", {
        Color        = cs  or ColorSequence.new(C.E1, C.Cy),
        Transparency = ts  or NumberSequence.new(0),
        Rotation     = rot or 0,
    }, o)
end
local function ListH(o, pad)
    return N("UIListLayout", {
        FillDirection       = Enum.FillDirection.Horizontal,
        Padding             = pad or UDim.new(0, 6),
        SortOrder           = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment   = Enum.VerticalAlignment.Center,
    }, o)
end
local function ListV(o, pad)
    return N("UIListLayout", {
        FillDirection       = Enum.FillDirection.Vertical,
        Padding             = pad or UDim.new(0, 5),
        SortOrder           = Enum.SortOrder.LayoutOrder,
        VerticalAlignment   = Enum.VerticalAlignment.Top,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    }, o)
end
local function Pad(o, t, r, b, l)
    return N("UIPadding", {
        PaddingTop    = UDim.new(0, t or 8),
        PaddingRight  = UDim.new(0, r or 8),
        PaddingBottom = UDim.new(0, b or 8),
        PaddingLeft   = UDim.new(0, l or 8),
    }, o)
end

local function Shadow(o)
    return N("ImageLabel", {
        Name  = "_Shadow",
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3       = C.Black,
        ImageTransparency = 0.5,
        Size              = UDim2.new(1, 46, 1, 46),
        Position          = UDim2.new(0, -23, 0, -23),
        ZIndex            = o.ZIndex - 1,
        ScaleType         = Enum.ScaleType.Slice,
        SliceCenter       = Rect.new(49, 49, 450, 450),
    }, o)
end

local function Ripple(btn, col)
    local mp  = UserInputService:GetMouseLocation()
    local rel = mp - Vector2.new(btn.AbsolutePosition.X, btn.AbsolutePosition.Y)
    local r = N("Frame", {
        BackgroundColor3       = col or C.E2,
        BackgroundTransparency = 0.6,
        Size     = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, rel.X, 0, rel.Y),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex   = btn.ZIndex + 20,
        ClipsDescendants = false,
    }, btn)
    Corner(r, UDim.new(1, 0))
    twSine(r, { Size = UDim2.new(3, 0, 3, 0), BackgroundTransparency = 1 }, 0.55)
    task.delay(0.6, function() if r and r.Parent then r:Destroy() end end)
end

local function HoverRow(f, norm, hov)
    f.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then tw(f, { BackgroundColor3 = hov }, 0.14) end
    end)
    f.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then tw(f, { BackgroundColor3 = norm }, 0.14) end
    end)
end

-- ════════════════════════════════════════════════════════════════
--  ANIMATED NEON BORDER  (top line only, no image)
-- ════════════════════════════════════════════════════════════════

local function NeonBorder(parent, col1, col2)
    local line = N("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(1, 0, 0, 2),
        BorderSizePixel = 0,
        ZIndex   = parent.ZIndex + 2,
    }, parent)

    local g = Gradient(line, ColorSequence.new({
        ColorSequenceKeypoint.new(0,    col1),
        ColorSequenceKeypoint.new(0.35, col2),
        ColorSequenceKeypoint.new(0.65, col1),
        ColorSequenceKeypoint.new(1,    col2),
    }), NumberSequence.new({
        NumberSequenceKeypoint.new(0,   0.7),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1,   0.7),
    }))
    g.Offset = Vector2.new(-1, 0)

    local alive = true
    task.spawn(function()
        while alive and line and line.Parent do
            twLinear(g, { Offset = Vector2.new(1, 0) }, 3)
            task.wait(3)
            g.Offset = Vector2.new(-1, 0)
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
--  BOOT OVERLAY  (cinematic intro, runs on top of built window)
-- ════════════════════════════════════════════════════════════════

local function PlayBoot(gui)
    -- Full curtain blocks the window until boot is done
    local curtain = N("Frame", {
        BackgroundColor3       = C.Black,
        BackgroundTransparency = 0,
        Size   = UDim2.new(1, 0, 1, 0),
        ZIndex = 500,
    }, gui)

    task.wait(0.08)

    -- ── Phase 1 : Ambient glow (Frame-based, no image) ────────────

    local ambFrame = N("Frame", {
        BackgroundColor3 = C.E1,
        BackgroundTransparency = 1,
        Size     = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex   = 501,
    }, gui)
    Corner(ambFrame, UDim.new(1, 0))

    local ambFrame2 = N("Frame", {
        BackgroundColor3 = C.Cy,
        BackgroundTransparency = 1,
        Size     = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex   = 501,
    }, gui)
    Corner(ambFrame2, UDim.new(1, 0))

    twSine(ambFrame,  { Size = UDim2.new(0, 540, 0, 540), BackgroundTransparency = 0.9 }, 0.75)
    twSine(ambFrame2, { Size = UDim2.new(0, 340, 0, 340), BackgroundTransparency = 0.93 }, 0.6)

    task.wait(0.32)

    -- ── Phase 2 : Particles converge ─────────────────────────────

    local particleRoot = N("Frame", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 1, 0),
        ZIndex = 502,
    }, gui)

    local rng = Random.new()
    local particles = {}

    for i = 1, 20 do
        local angle = rng:NextNumber(0, math.pi * 2)
        local dist  = rng:NextNumber(250, 520)
        local sz    = rng:NextNumber(3, 7)
        local vx = workspace.CurrentCamera.ViewportSize.X
        local vy = workspace.CurrentCamera.ViewportSize.Y
        local sx = 0.5 + math.cos(angle) * dist / vx
        local sy = 0.5 + math.sin(angle) * dist / vy

        local p = N("Frame", {
            BackgroundColor3       = i % 3 == 0 and C.Cy or C.E2,
            BackgroundTransparency = 1,
            Size     = UDim2.new(0, sz, 0, sz),
            Position = UDim2.new(sx, 0, sy, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            ZIndex   = 503,
        }, particleRoot)
        Corner(p, UDim.new(1, 0))

        twSine(p, { BackgroundTransparency = 0.1 }, 0.25)
        table.insert(particles, { frame = p, d = rng:NextNumber(0.04, 0.3) })
    end

    task.wait(0.18)

    for _, pt in ipairs(particles) do
        task.delay(pt.d, function()
            if pt.frame and pt.frame.Parent then
                tw(pt.frame, {
                    Position               = UDim2.new(0.5, 0, 0.5, 0),
                    BackgroundTransparency = 0.75,
                    Size                   = UDim2.new(0, 2, 0, 2),
                }, 0.65, Enum.EasingStyle.Quint)
            end
        end)
    end

    task.wait(0.75)

    -- ── Phase 3 : Logo card ───────────────────────────────────────

    local logoCard = N("Frame", {
        BackgroundColor3       = C.Deep,
        BackgroundTransparency = 1,
        Size     = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex   = 505,
    }, gui)
    Corner(logoCard, UDim.new(0, 16))

    -- Gradient overlay inside card
    local logoGradFrame = N("Frame", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 1, 0),
        ZIndex = 505,
    }, logoCard)
    Gradient(logoGradFrame,
        ColorSequence.new({ ColorSequenceKeypoint.new(0, C.E3), ColorSequenceKeypoint.new(1, C.Black) }),
        NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(1, 0.97) }),
        135
    )
    Corner(logoGradFrame, UDim.new(0, 16))

    Stroke(logoCard, C.E1, 1, 0.15)

    -- Expand
    twBack(logoCard, {
        Size = UDim2.new(0, 108, 0, 108),
        BackgroundTransparency = 0,
    }, 0.58)

    -- Rings (Frame-based circles)
    local ring1 = N("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex   = 504,
    }, gui)
    Stroke(ring1, C.E1, 1, 0.25)
    Corner(ring1, UDim.new(1, 0))

    local ring2 = N("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex   = 504,
    }, gui)
    Stroke(ring2, C.Cy, 1, 0.55)
    Corner(ring2, UDim.new(1, 0))

    twBack(ring1, { Size = UDim2.new(0, 145, 0, 145) }, 0.52)
    twBack(ring2, { Size = UDim2.new(0, 175, 0, 175) }, 0.65)

    task.wait(0.28)

    -- ── Phase 4 : Typewriter logo text ────────────────────────────

    local logoLbl = N("TextLabel", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(1, 0, 0.55, 0),
        Position = UDim2.new(0, 0, 0.08, 0),
        Font     = Enum.Font.GothamBold,
        Text     = "",
        TextColor3       = C.Pure,
        TextTransparency = 1,
        TextSize = 30,
        ZIndex   = 507,
    }, logoCard)

    local tagLbl = N("TextLabel", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(1, 0, 0.28, 0),
        Position = UDim2.new(0, 0, 0.67, 0),
        Font     = Enum.Font.GothamMedium,
        Text     = "",
        TextColor3       = C.T3,
        TextTransparency = 1,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex   = 507,
    }, logoCard)

    twSine(logoLbl, { TextTransparency = 0 }, 0.3)

    local built = ""
    for _, ch in ipairs({ "U", "p", "F", "o", "r" }) do
        task.wait(0.07)
        built = built .. ch
        logoLbl.Text = built
    end

    task.wait(0.15)
    twSine(tagLbl, { TextTransparency = 0 }, 0.4)
    tagLbl.Text = "PREMIUM  UI"

    -- ── Phase 5 : Progress bar ────────────────────────────────────

    local barBg = N("Frame", {
        BackgroundColor3 = C.Rise,
        BackgroundTransparency = 0.5,
        Size     = UDim2.new(0, 200, 0, 3),
        Position = UDim2.new(0.5, 0, 0.5, 90),
        AnchorPoint = Vector2.new(0.5, 0),
        ZIndex   = 506,
    }, gui)
    Corner(barBg, UDim.new(1, 0))

    local barFill = N("Frame", {
        BackgroundColor3 = C.E1,
        Size   = UDim2.new(0, 0, 1, 0),
        ZIndex = 507,
    }, barBg)
    Corner(barFill, UDim.new(1, 0))
    Gradient(barFill,
        ColorSequence.new({ ColorSequenceKeypoint.new(0, C.E1), ColorSequenceKeypoint.new(1, C.Cy) }),
        NumberSequence.new(0)
    )

    -- Glow dot on fill end
    local barDot = N("Frame", {
        BackgroundColor3       = C.E2,
        BackgroundTransparency = 0.25,
        Size     = UDim2.new(0, 8, 3, 0),
        Position = UDim2.new(1, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex   = 508,
    }, barFill)
    Corner(barDot, UDim.new(1, 0))

    local statusLbl = N("TextLabel", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(0, 200, 0, 16),
        Position = UDim2.new(0.5, 0, 0.5, 100),
        AnchorPoint = Vector2.new(0.5, 0),
        Font     = Enum.Font.Code,
        Text     = "Initializing...",
        TextColor3       = C.T3,
        TextTransparency = 0,
        TextSize = 10,
        ZIndex   = 506,
    }, gui)

    local steps = {
        { pct = 0.22, label = "Loading components..." },
        { pct = 0.55, label = "Applying theme..." },
        { pct = 0.82, label = "Building elements..." },
        { pct = 1.0,  label = "Ready." },
    }

    for _, step in ipairs(steps) do
        statusLbl.Text = step.label
        twLinear(barFill, { Size = UDim2.new(step.pct, 0, 1, 0) }, 0.26)
        task.wait(0.30)
    end

    task.wait(0.18)

    -- ── Phase 6 : Pulse rings out + collapse + flash ───────────────

    twSine(ring1, { Size = UDim2.new(0, 200, 0, 200) }, 0.28)
    tw(ring1, { Size = UDim2.new(0, 0, 0, 0) }, 0.3, Enum.EasingStyle.Quint, nil, 0.28)
    twSine(ring2, { Size = UDim2.new(0, 240, 0, 240) }, 0.32)
    tw(ring2, { Size = UDim2.new(0, 0, 0, 0) }, 0.3, Enum.EasingStyle.Quint, nil, 0.32)

    twSine(ambFrame,  { BackgroundTransparency = 1, Size = UDim2.new(0, 700, 0, 700) }, 0.38)
    twSine(ambFrame2, { BackgroundTransparency = 1 }, 0.3)

    twSine(logoLbl, { TextTransparency = 1 }, 0.22)
    twSine(tagLbl,  { TextTransparency = 1 }, 0.22)
    twSine(statusLbl, { TextTransparency = 1 }, 0.2)

    twBack(logoCard, {
        Size                   = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
    }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    twSine(barBg, { BackgroundTransparency = 1 }, 0.2)

    task.wait(0.26)

    -- White flash
    local flash = N("Frame", {
        BackgroundColor3       = C.Pure,
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 1, 0),
        ZIndex = 600,
    }, gui)
    twSine(flash, { BackgroundTransparency = 0.05 }, 0.1)
    task.wait(0.1)
    twSine(flash, { BackgroundTransparency = 1 }, 0.38)

    -- Curtain fades out revealing built window
    twSine(curtain, { BackgroundTransparency = 1 }, 0.42)

    task.wait(0.46)

    -- Cleanup all boot layers
    curtain:Destroy()
    ambFrame:Destroy()
    ambFrame2:Destroy()
    particleRoot:Destroy()
    logoCard:Destroy()
    ring1:Destroy()
    ring2:Destroy()
    barBg:Destroy()
    statusLbl:Destroy()
    flash:Destroy()
end

-- ════════════════════════════════════════════════════════════════
--  LIBRARY  —  CREATE WINDOW
-- ════════════════════════════════════════════════════════════════

local UpFor = {}
UpFor.__index = UpFor

function UpFor:CreateWindow(cfg)
    cfg = cfg or {}

    local accent   = cfg.AccentColor  or C.E1
    local accentHi = cfg.AccentBright or C.E2
    local accentCy = cfg.AccentCyan   or C.Cy

    local WCfg = {
        Title      = cfg.Title      or "UpFor",
        Subtitle   = cfg.Subtitle   or "v1.0",
        LogoText   = cfg.LogoText   or "UF",
        Size       = cfg.Size       or UDim2.new(0, 630, 0, 450),
        MinSize    = cfg.MinSize    or UDim2.new(0, 630, 0, 56),
        ToggleKey  = cfg.ToggleKey  or Enum.KeyCode.RightShift,
        ConfigName = cfg.ConfigName or "UpFor",
    }

    local State = {
        Minimized = false, Maximized = false,
        Dragging = false, DragOrigin = nil, DragPos = nil,
        ActiveTab = nil, Tabs = {}, Data = {},
    }

    -- ── Screen GUI ────────────────────────────────────────────────

    local Gui = N("ScreenGui", {
        Name           = "UpFor_GUI",
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder   = 999,
        IgnoreGuiInset = true,
    }, LocalPlayer:WaitForChild("PlayerGui"))

    -- ════════════════════════════════════════════════════════════
    --  BUILD MAIN WINDOW  (immediately, before boot overlay)
    -- ════════════════════════════════════════════════════════════

    local Win = N("Frame", {
        Name             = "Window",
        BackgroundColor3 = C.Abyss,
        Size             = WCfg.Size,
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint      = Vector2.new(0.5, 0.5),
        ClipsDescendants = true,
        ZIndex           = 10,
    }, Gui)
    Corner(Win, UDim.new(0, 14))
    Stroke(Win, C.Edge, 1, 0.28)
    Shadow(Win)

    NeonBorder(Win, accent, accentCy)

    -- ── Title Bar ────────────────────────────────────────────────

    local TBar = N("Frame", {
        BackgroundColor3       = C.Deep,
        BackgroundTransparency = 0.2,
        Size     = UDim2.new(1, 0, 0, 56),
        Position = UDim2.new(0, 0, 0, 2),
        ZIndex   = 12,
    }, Win)

    -- Subtle top gradient on title bar
    local tGrad = N("Frame", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 1, 0),
        ZIndex = 13,
    }, TBar)
    Gradient(tGrad,
        ColorSequence.new({ ColorSequenceKeypoint.new(0, accent), ColorSequenceKeypoint.new(1, C.Black) }),
        NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.88), NumberSequenceKeypoint.new(1, 1) }),
        180
    )

    N("Frame", {
        BackgroundColor3 = C.Divider,
        BackgroundTransparency = 0.4,
        Size     = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        ZIndex   = 13,
    }, TBar)

    -- Logo badge
    local badge = N("Frame", {
        BackgroundColor3 = accent,
        Size     = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(0, 14, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex   = 14,
    }, TBar)
    Corner(badge, UDim.new(0, 9))

    -- Badge pulse ring
    local badgePulse = N("Frame", {
        BackgroundColor3       = accent,
        BackgroundTransparency = 0.72,
        Size     = UDim2.new(1, 6, 1, 6),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex   = 13,
    }, badge)
    Corner(badgePulse, UDim.new(0, 11))

    task.spawn(function()
        while badge and badge.Parent do
            twSpring(badgePulse, { Size = UDim2.new(1, 14, 1, 14), BackgroundTransparency = 0.48 }, 2)
            task.wait(2)
            twSpring(badgePulse, { Size = UDim2.new(1, 6, 1, 6), BackgroundTransparency = 0.72 }, 2)
            task.wait(2)
        end
    end)

    N("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = WCfg.LogoText,
        TextColor3 = C.Pure, TextSize = 17, ZIndex = 15,
    }, badge)

    N("TextLabel", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(0.45, -62, 0, 20),
        Position = UDim2.new(0, 62, 0, 9),
        Font     = Enum.Font.GothamBold,
        Text     = WCfg.Title,
        TextColor3 = C.T1, TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex   = 14,
    }, TBar)

    N("TextLabel", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(0.45, -62, 0, 14),
        Position = UDim2.new(0, 62, 0, 32),
        Font     = Enum.Font.GothamMedium,
        Text     = WCfg.Subtitle,
        TextColor3 = C.T3, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex   = 14,
    }, TBar)

    -- ── Controls  [ - ]  [ + ]  [ X ] ───────────────────────────

    local ctrlWrap = N("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(0, 126, 0, 40),
        Position = UDim2.new(1, -136, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex   = 14,
    }, TBar)
    ListH(ctrlWrap, UDim.new(0, 7))

    local function CtrlBtn(lbl, hCol, order, cb)
        local b = N("TextButton", {
            Name             = lbl,
            BackgroundColor3 = C.Rise,
            Size             = UDim2.new(0, 36, 0, 36),
            Font             = Enum.Font.GothamBold,
            Text             = lbl,
            TextColor3       = C.T2,
            TextSize         = 16,
            AutoButtonColor  = false,
            LayoutOrder      = order,
            ZIndex           = 15,
        }, ctrlWrap)
        Corner(b, UDim.new(0, 9))

        b.MouseEnter:Connect(function() tw(b, { BackgroundColor3 = hCol, TextColor3 = C.Pure }, 0.14) end)
        b.MouseLeave:Connect(function() tw(b, { BackgroundColor3 = C.Rise, TextColor3 = C.T2 }, 0.14) end)
        b.MouseButton1Click:Connect(function()
            Ripple(b, hCol)
            if cb then cb() end
        end)
    end

    CtrlBtn("-", C.Yellow, 1, function()
        State.Minimized = not State.Minimized
        if State.Minimized then
            twBack(Win, { Size = WCfg.MinSize }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        else
            local t = State.Maximized and UDim2.new(1, -40, 1, -40) or WCfg.Size
            twBack(Win, { Size = t }, 0.3)
        end
    end)

    CtrlBtn("+", C.Green, 2, function()
        State.Minimized = false
        State.Maximized = not State.Maximized
        if State.Maximized then
            twBack(Win, { Size = UDim2.new(1, -40, 1, -40), Position = UDim2.new(0.5, 0, 0.5, 0) }, 0.3)
        else
            twBack(Win, { Size = WCfg.Size, Position = UDim2.new(0.5, 0, 0.5, 0) }, 0.3)
        end
    end)

    CtrlBtn("X", C.Red, 3, function()
        twBack(Win, { Size = UDim2.new(0, 0, 0, 0) }, 0.36, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.delay(0.4, function() Gui:Destroy() end)
    end)

    -- ── Drag ─────────────────────────────────────────────────────

    TBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            State.Dragging = true; State.DragOrigin = i.Position; State.DragPos = Win.Position
        end
    end)
    TBar.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            State.Dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if State.Dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - State.DragOrigin
            Win.Position = UDim2.new(State.DragPos.X.Scale, State.DragPos.X.Offset + d.X, State.DragPos.Y.Scale, State.DragPos.Y.Offset + d.Y)
        end
    end)

    UserInputService.InputBegan:Connect(function(i, gpe)
        if not gpe and i.KeyCode == WCfg.ToggleKey then Win.Visible = not Win.Visible end
    end)

    -- ── Body ─────────────────────────────────────────────────────

    local Body = N("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(1, 0, 1, -58),
        Position = UDim2.new(0, 0, 0, 58),
        ZIndex   = 11,
    }, Win)

    -- ── Sidebar ──────────────────────────────────────────────────

    local sidebar = N("Frame", {
        BackgroundColor3       = C.Deep,
        BackgroundTransparency = 0.15,
        Size     = UDim2.new(0, 165, 1, 0),
        ZIndex   = 11,
    }, Body)

    N("Frame", {
        BackgroundColor3 = C.Divider,
        BackgroundTransparency = 0.4,
        Size     = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        ZIndex   = 12,
    }, sidebar)

    local sideScroll = N("ScrollingFrame", {
        BackgroundTransparency  = 1,
        Size     = UDim2.new(1, -10, 1, -14),
        Position = UDim2.new(0, 5, 0, 7),
        CanvasSize           = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize  = Enum.AutomaticSize.Y,
        ScrollBarThickness   = 2,
        ScrollBarImageColor3 = C.Edge,
        BorderSizePixel = 0,
        ZIndex = 12,
    }, sidebar)
    ListV(sideScroll, UDim.new(0, 4))

    -- ── Content ──────────────────────────────────────────────────

    local contentWrap = N("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(1, -167, 1, 0),
        Position = UDim2.new(0, 167, 0, 0),
        ClipsDescendants = true,
        ZIndex   = 11,
    }, Body)

    -- ── Notification system ───────────────────────────────────────

    local notifStack = N("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(0, 320, 1, -20),
        Position = UDim2.new(1, -330, 0, 10),
        ZIndex   = 300,
    }, Gui)
    N("UIListLayout", {
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        SortOrder         = Enum.SortOrder.LayoutOrder,
        Padding           = UDim.new(0, 8),
    }, notifStack)

    local notifIdx = 0

    local function Notify(opts)
        opts = opts or {}
        notifIdx += 1
        local colMap = { Success = C.Green, Warning = C.Yellow, Error = C.Red, Info = C.Blue }
        local ac = colMap[opts.Type] or accent

        local nf = N("Frame", {
            BackgroundColor3       = C.Surface,
            BackgroundTransparency = 0.06,
            Size        = UDim2.new(1, 0, 0, 72),
            ZIndex      = 301,
            LayoutOrder = notifIdx,
        }, notifStack)
        Corner(nf, UDim.new(0, 10))
        Stroke(nf, ac, 1, 0.5)

        local bar = N("Frame", {
            BackgroundColor3 = ac,
            Size     = UDim2.new(0, 3, 0.6, 0),
            Position = UDim2.new(0, 8, 0.2, 0),
            ZIndex   = 302,
        }, nf)
        Corner(bar, UDim.new(1, 0))

        N("TextLabel", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(1, -30, 0, 20),
            Position = UDim2.new(0, 22, 0, 12),
            Font     = Enum.Font.GothamBold,
            Text     = opts.Title or "Notice",
            TextColor3 = C.T1, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex   = 302,
        }, nf)

        N("TextLabel", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(1, -30, 0, 28),
            Position = UDim2.new(0, 22, 0, 32),
            Font     = Enum.Font.GothamMedium,
            Text     = opts.Content or "",
            TextColor3 = C.T2, TextSize = 11, TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex   = 302,
        }, nf)

        nf.Position = UDim2.new(1, 40, 0, 0)
        nf.BackgroundTransparency = 0.5
        twBack(nf, { Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0.06 }, 0.36)

        task.delay(opts.Duration or 4, function()
            tw(nf, { Position = UDim2.new(1, 40, 0, 0), BackgroundTransparency = 1 }, 0.3)
            task.delay(0.35, function() if nf and nf.Parent then nf:Destroy() end end)
        end)
    end

    -- ════════════════════════════════════════════════════════════
    --  WINDOW API
    -- ════════════════════════════════════════════════════════════

    local Window = { Notify = Notify }

    -- ── Tab builder ───────────────────────────────────────────────

    function Window:CreateTab(tabCfg)
        tabCfg = tabCfg or {}
        local tName  = tabCfg.Name  or "Tab"
        local tIcon  = tabCfg.Icon  or ""
        local tOrder = tabCfg.Order or (#State.Tabs + 1)

        local tabBtn = N("TextButton", {
            BackgroundColor3       = C.Lift,
            BackgroundTransparency = 1,
            Size     = UDim2.new(1, -6, 0, 44),
            Text     = "",
            AutoButtonColor = false,
            LayoutOrder = tOrder,
            ZIndex   = 13,
        }, sideScroll)
        Corner(tabBtn, UDim.new(0, 9))

        local tabGlow = N("Frame", {
            BackgroundColor3 = accent,
            BackgroundTransparency = 1,
            Size   = UDim2.new(1, 0, 1, 0),
            ZIndex = 12,
        }, tabBtn)
        Corner(tabGlow, UDim.new(0, 9))
        Gradient(tabGlow,
            ColorSequence.new({ ColorSequenceKeypoint.new(0, accent), ColorSequenceKeypoint.new(1, C.Black) }),
            NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.82), NumberSequenceKeypoint.new(1, 1) }),
            0
        )

        local tabIcn = N("TextLabel", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(0, 36, 1, 0),
            Position = UDim2.new(0, 6, 0, 0),
            Font     = Enum.Font.GothamMedium,
            Text     = tIcon, TextColor3 = C.Edge, TextSize = 15, ZIndex = 14,
        }, tabBtn)

        local tabLbl = N("TextLabel", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(1, -50, 1, 0),
            Position = UDim2.new(0, 44, 0, 0),
            Font     = Enum.Font.GothamMedium,
            Text     = tName, TextColor3 = C.T2, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
        }, tabBtn)

        local tabInd = N("Frame", {
            BackgroundColor3 = accent,
            Size     = UDim2.new(0, 3, 0, 0),
            Position = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            ZIndex   = 14,
        }, tabBtn)
        Corner(tabInd, UDim.new(1, 0))

        local page = N("ScrollingFrame", {
            BackgroundTransparency  = 1,
            Size     = UDim2.new(1, -14, 1, -14),
            Position = UDim2.new(0, 7, 0, 7),
            CanvasSize           = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize  = Enum.AutomaticSize.Y,
            ScrollBarThickness   = 3,
            ScrollBarImageColor3 = C.Edge,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex  = 12,
        }, contentWrap)
        ListV(page, UDim.new(0, 6))
        Pad(page, 5, 5, 5, 5)

        local td = { Btn = tabBtn, Page = page, Ind = tabInd, Glow = tabGlow, Icn = tabIcn, Lbl = tabLbl }
        table.insert(State.Tabs, td)

        local function selectTab()
            for _, t in ipairs(State.Tabs) do
                t.Page.Visible = false
                tw(t.Btn,  { BackgroundTransparency = 1 },             0.18)
                tw(t.Glow, { BackgroundTransparency = 1 },             0.18)
                tw(t.Ind,  { Size = UDim2.new(0, 3, 0, 0) },          0.18)
                tw(t.Lbl,  { TextColor3 = C.T2 },                      0.18)
                tw(t.Icn,  { TextColor3 = C.Edge },                    0.18)
            end
            td.Page.Visible = true
            State.ActiveTab = td
            tw(td.Btn,  { BackgroundTransparency = 0.72 },         0.18)
            tw(td.Glow, { BackgroundTransparency = 0.86 },         0.18)
            tw(td.Lbl,  { TextColor3 = C.T1 },                    0.18)
            tw(td.Icn,  { TextColor3 = accent },                  0.18)
            twBack(td.Ind, { Size = UDim2.new(0, 3, 0, 26) },    0.28)
        end

        tabBtn.MouseEnter:Connect(function()
            if State.ActiveTab ~= td then tw(tabBtn, { BackgroundTransparency = 0.84 }, 0.14) end
        end)
        tabBtn.MouseLeave:Connect(function()
            if State.ActiveTab ~= td then tw(tabBtn, { BackgroundTransparency = 1 }, 0.14) end
        end)
        tabBtn.MouseButton1Click:Connect(selectTab)
        if #State.Tabs == 1 then selectTab() end

        -- ──────────────────────────────────────────────────────────
        --  ELEMENT BUILDERS
        -- ──────────────────────────────────────────────────────────

        local Tab = {}

        -- SECTION ─────────────────────────────────────────────────

        function Tab:CreateSection(name)
            local sf = N("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 26),
                LayoutOrder = #page:GetChildren(), ZIndex = 13,
            }, page)

            N("Frame", {
                BackgroundColor3 = C.Divider, BackgroundTransparency = 0.35,
                Size = UDim2.new(0, 18, 0, 1), Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5), ZIndex = 13,
            }, sf)

            local dot = N("Frame", {
                BackgroundColor3 = accent, Size = UDim2.new(0, 5, 0, 5),
                Position = UDim2.new(0, 24, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), ZIndex = 13,
            }, sf)
            Corner(dot, UDim.new(1, 0))

            N("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(0.65, 0, 1, 0),
                Position = UDim2.new(0, 36, 0, 0),
                Font = Enum.Font.GothamBold, Text = string.upper(name or "SECTION"),
                TextColor3 = C.T3, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13,
            }, sf)

            N("Frame", {
                BackgroundColor3 = C.Divider, BackgroundTransparency = 0.35,
                Size = UDim2.new(0.44, 0, 0, 1), Position = UDim2.new(0.56, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5), ZIndex = 13,
            }, sf)
        end

        -- TOGGLE ──────────────────────────────────────────────────

        function Tab:CreateToggle(opts)
            opts = opts or {}
            local val = opts.Default or false
            local h   = opts.Description and 48 or 44

            local row = N("Frame", {
                BackgroundColor3 = C.Surface,
                Size = UDim2.new(1, 0, 0, h), LayoutOrder = #page:GetChildren(), ZIndex = 13,
            }, page)
            Corner(row, UDim.new(0, 9))
            HoverRow(row, C.Surface, C.Lift)

            local strip = N("Frame", {
                BackgroundColor3 = accent, BackgroundTransparency = val and 0 or 1,
                Size = UDim2.new(0, 2, 0.55, 0), Position = UDim2.new(0, 0, 0.225, 0), ZIndex = 14,
            }, row)

            N("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(0.65, -14, 0, 18),
                Position = UDim2.new(0, 14, 0, opts.Description and 5 or 13),
                Font = Enum.Font.GothamMedium, Text = opts.Name or "Toggle",
                TextColor3 = C.T1, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
            }, row)

            if opts.Description then
                N("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(0.65, -14, 0, 13),
                    Position = UDim2.new(0, 14, 0, 26),
                    Font = Enum.Font.GothamMedium, Text = opts.Description,
                    TextColor3 = C.T3, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
                }, row)
            end

            local track = N("Frame", {
                BackgroundColor3 = val and accent or C.Rise,
                Size = UDim2.new(0, 48, 0, 26), Position = UDim2.new(1, -62, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5), ZIndex = 14,
            }, row)
            Corner(track, UDim.new(1, 0))

            local trackGlow = N("Frame", {
                BackgroundColor3 = accent, BackgroundTransparency = val and 0.6 or 1,
                Size = UDim2.new(1, 10, 1, 10), ZIndex = 13,
            }, row)
            trackGlow.Position = UDim2.new(1, -57, 0.5, 0)
            Corner(trackGlow, UDim.new(1, 0))

            local knob = N("Frame", {
                BackgroundColor3 = C.Pure,
                Size = UDim2.new(0, 20, 0, 20),
                Position = val and UDim2.new(1, -23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5), ZIndex = 16,
            }, track)
            Corner(knob, UDim.new(1, 0))

            local function refresh()
                if val then
                    tw(track,     { BackgroundColor3 = accent },             0.2)
                    tw(trackGlow, { BackgroundTransparency = 0.6 },          0.2)
                    tw(strip,     { BackgroundTransparency = 0 },            0.2)
                    twBack(knob,  { Position = UDim2.new(1, -23, 0.5, 0) }, 0.24)
                else
                    tw(track,     { BackgroundColor3 = C.Rise },             0.2)
                    tw(trackGlow, { BackgroundTransparency = 1 },            0.2)
                    tw(strip,     { BackgroundTransparency = 1 },            0.2)
                    twBack(knob,  { Position = UDim2.new(0, 3, 0.5, 0) },   0.24)
                end
                if opts.Callback then opts.Callback(val) end
            end

            local cz = N("TextButton", { BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Text="", ZIndex=17 }, row)
            cz.MouseButton1Click:Connect(function() val = not val; refresh() end)

            local API = {}
            function API:Set(v) val = v; refresh() end
            function API:Get() return val end
            return API
        end

        -- SLIDER ──────────────────────────────────────────────────

        function Tab:CreateSlider(opts)
            opts = opts or {}
            local mn, mx, cur, stp = opts.Min or 0, opts.Max or 100, opts.Default or 0, opts.Increment or 1

            local row = N("Frame", {
                BackgroundColor3 = C.Surface,
                Size = UDim2.new(1, 0, 0, 58), LayoutOrder = #page:GetChildren(), ZIndex = 13,
            }, page)
            Corner(row, UDim.new(0, 9))
            HoverRow(row, C.Surface, C.Lift)

            N("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(0.65, -14, 0, 18),
                Position = UDim2.new(0, 14, 0, 7), Font = Enum.Font.GothamMedium,
                Text = opts.Name or "Slider", TextColor3 = C.T1, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
            }, row)

            local vLbl = N("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(0.3, -14, 0, 18),
                Position = UDim2.new(0.7, 0, 0, 7), Font = Enum.Font.Code,
                Text = tostring(cur), TextColor3 = accent, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 14,
            }, row)

            local track = N("Frame", {
                BackgroundColor3 = C.Rise,
                Size = UDim2.new(1, -28, 0, 6), Position = UDim2.new(0, 14, 0, 40), ZIndex = 14,
            }, row)
            Corner(track, UDim.new(1, 0))

            local p0   = (cur - mn) / (mx - mn)
            local fill = N("Frame", { BackgroundColor3 = accent, Size = UDim2.new(p0, 0, 1, 0), ZIndex = 15 }, track)
            Corner(fill, UDim.new(1, 0))
            Gradient(fill, ColorSequence.new({ ColorSequenceKeypoint.new(0, accent), ColorSequenceKeypoint.new(1, accentCy) }), NumberSequence.new(0))

            local knob = N("Frame", {
                BackgroundColor3 = C.Pure, Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(p0, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 17,
            }, track)
            Corner(knob, UDim.new(1, 0))
            Stroke(knob, accent, 2)

            local knobGlow = N("Frame", {
                BackgroundColor3 = accent, BackgroundTransparency = 0.72,
                Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(p0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 16,
            }, track)
            Corner(knobGlow, UDim.new(1, 0))

            local dragging = false
            local function applyX(px)
                local rel = math.clamp((px - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                cur = math.clamp(math.floor((mn + (mx - mn) * rel) / stp + 0.5) * stp, mn, mx)
                local p = (cur - mn) / (mx - mn)
                fill.Size = UDim2.new(p, 0, 1, 0)
                knob.Position = UDim2.new(p, 0, 0.5, 0)
                knobGlow.Position = UDim2.new(p, 0, 0.5, 0)
                vLbl.Text = tostring(cur)
                if opts.Callback then opts.Callback(cur) end
            end

            track.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = true; applyX(i.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    applyX(i.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            local API = {}
            function API:Set(v)
                cur = math.clamp(v, mn, mx)
                local p = (cur - mn) / (mx - mn)
                fill.Size = UDim2.new(p, 0, 1, 0)
                knob.Position = UDim2.new(p, 0, 0.5, 0)
                knobGlow.Position = UDim2.new(p, 0, 0.5, 0)
                vLbl.Text = tostring(cur)
            end
            function API:Get() return cur end
            return API
        end

        -- BUTTON ──────────────────────────────────────────────────

        function Tab:CreateButton(opts)
            opts = opts or {}

            local row = N("Frame", {
                BackgroundColor3 = C.Surface,
                Size = UDim2.new(1, 0, 0, 44), LayoutOrder = #page:GetChildren(), ZIndex = 13,
            }, page)
            Corner(row, UDim.new(0, 9))
            HoverRow(row, C.Surface, C.Lift)

            N("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(0.65, -14, 1, 0),
                Position = UDim2.new(0, 14, 0, 0), Font = Enum.Font.GothamMedium,
                Text = opts.Name or "Button", TextColor3 = C.T1, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
            }, row)

            local btn = N("TextButton", {
                BackgroundColor3 = accent,
                Size = UDim2.new(0, 78, 0, 30), Position = UDim2.new(1, -92, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5), Font = Enum.Font.GothamBold,
                Text = opts.ButtonText or "Run", TextColor3 = C.Pure, TextSize = 12,
                AutoButtonColor = false, ZIndex = 15,
            }, row)
            Corner(btn, UDim.new(0, 9))

            local bGlow = N("Frame", {
                BackgroundColor3 = accent, BackgroundTransparency = 0.78,
                Size = UDim2.new(1, 12, 1, 12), Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 14,
            }, btn)
            Corner(bGlow, UDim.new(0, 11))

            btn.MouseEnter:Connect(function()
                tw(btn,   { BackgroundColor3 = accentHi },   0.14)
                tw(bGlow, { BackgroundTransparency = 0.6 },  0.14)
            end)
            btn.MouseLeave:Connect(function()
                tw(btn,   { BackgroundColor3 = accent },     0.14)
                tw(bGlow, { BackgroundTransparency = 0.78 }, 0.14)
            end)
            btn.MouseButton1Click:Connect(function()
                Ripple(btn, accentHi)
                if opts.Callback then opts.Callback() end
            end)
        end

        -- DROPDOWN ────────────────────────────────────────────────

        function Tab:CreateDropdown(opts)
            opts = opts or {}
            local items   = opts.Items   or {}
            local current = opts.Default or (items[1] or "")
            local isOpen  = false

            local wrap = N("Frame", {
                BackgroundColor3 = C.Surface,
                Size = UDim2.new(1, 0, 0, 44), ClipsDescendants = true,
                LayoutOrder = #page:GetChildren(), ZIndex = 13,
            }, page)
            Corner(wrap, UDim.new(0, 9))

            N("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(0.45, -8, 0, 44),
                Position = UDim2.new(0, 14, 0, 0), Font = Enum.Font.GothamMedium,
                Text = opts.Name or "Dropdown", TextColor3 = C.T1, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
            }, wrap)

            local selBtn = N("TextButton", {
                BackgroundColor3 = C.Rise, Size = UDim2.new(0.5, -14, 0, 30),
                Position = UDim2.new(0.5, 0, 0, 7), Font = Enum.Font.GothamMedium,
                Text = current .. "  v", TextColor3 = C.T2, TextSize = 12,
                AutoButtonColor = false, ZIndex = 15,
            }, wrap)
            Corner(selBtn, UDim.new(0, 7))

            local ibox = N("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -16, 0, 0), Position = UDim2.new(0, 8, 0, 46), ZIndex = 15,
            }, wrap)
            ListV(ibox, UDim.new(0, 3))

            local function buildItems()
                for _, c in ipairs(ibox:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for i, item in ipairs(items) do
                    local ib = N("TextButton", {
                        BackgroundColor3 = C.Lift, BackgroundTransparency = 0.35,
                        Size = UDim2.new(1, 0, 0, 30), Font = Enum.Font.GothamMedium,
                        Text = item, TextColor3 = item == current and accent or C.T2,
                        TextSize = 12, AutoButtonColor = false, LayoutOrder = i, ZIndex = 16,
                    }, ibox)
                    Corner(ib, UDim.new(0, 7))
                    ib.MouseEnter:Connect(function() tw(ib, { BackgroundTransparency = 0, TextColor3 = C.T1 }, 0.12) end)
                    ib.MouseLeave:Connect(function() tw(ib, { BackgroundTransparency = 0.35, TextColor3 = item == current and accent or C.T2 }, 0.12) end)
                    ib.MouseButton1Click:Connect(function()
                        current = item; selBtn.Text = item .. "  v"
                        isOpen = false; tw(wrap, { Size = UDim2.new(1, 0, 0, 44) }, 0.22)
                        buildItems()
                        if opts.Callback then opts.Callback(item) end
                    end)
                end
            end
            buildItems()

            selBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    twBack(wrap, { Size = UDim2.new(1, 0, 0, 52 + #items * 33) }, 0.3)
                    selBtn.Text = current .. "  ^"
                else
                    tw(wrap, { Size = UDim2.new(1, 0, 0, 44) }, 0.22)
                    selBtn.Text = current .. "  v"
                end
            end)

            local API = {}
            function API:Set(v) current = v; selBtn.Text = v .. "  v"; buildItems() end
            function API:Get() return current end
            return API
        end

        -- INPUT ───────────────────────────────────────────────────

        function Tab:CreateInput(opts)
            opts = opts or {}

            local row = N("Frame", {
                BackgroundColor3 = C.Surface,
                Size = UDim2.new(1, 0, 0, 44), LayoutOrder = #page:GetChildren(), ZIndex = 13,
            }, page)
            Corner(row, UDim.new(0, 9))
            HoverRow(row, C.Surface, C.Lift)

            N("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(0.42, -8, 1, 0),
                Position = UDim2.new(0, 14, 0, 0), Font = Enum.Font.GothamMedium,
                Text = opts.Name or "Input", TextColor3 = C.T1, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
            }, row)

            local box = N("TextBox", {
                BackgroundColor3 = C.Rise, Size = UDim2.new(0.54, -14, 0, 30),
                Position = UDim2.new(0.46, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
                Font = Enum.Font.GothamMedium, PlaceholderText = opts.Placeholder or "Enter value...",
                PlaceholderColor3 = C.T3, Text = opts.Default or "",
                TextColor3 = C.T1, TextSize = 12,
                ClearTextOnFocus = opts.ClearOnFocus or false, ZIndex = 15,
            }, row)
            Corner(box, UDim.new(0, 7))
            N("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, box)
            local bstk = Stroke(box, C.Edge, 1, 0.38)

            box.Focused:Connect(function()
                tw(bstk, { Color = accent, Transparency = 0 }, 0.18)
                tw(box,  { BackgroundColor3 = C.Lift }, 0.18)
            end)
            box.FocusLost:Connect(function(enter)
                tw(bstk, { Color = C.Edge, Transparency = 0.38 }, 0.18)
                tw(box,  { BackgroundColor3 = C.Rise }, 0.18)
                if opts.Callback then opts.Callback(box.Text, enter) end
            end)

            local API = {}
            function API:Set(v) box.Text = v end
            function API:Get() return box.Text end
            return API
        end

        -- KEYBIND ─────────────────────────────────────────────────

        function Tab:CreateKeybind(opts)
            opts = opts or {}
            local key = opts.Default or Enum.KeyCode.E
            local listening = false

            local row = N("Frame", {
                BackgroundColor3 = C.Surface,
                Size = UDim2.new(1, 0, 0, 44), LayoutOrder = #page:GetChildren(), ZIndex = 13,
            }, page)
            Corner(row, UDim.new(0, 9))
            HoverRow(row, C.Surface, C.Lift)

            N("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(0.62, -14, 1, 0),
                Position = UDim2.new(0, 14, 0, 0), Font = Enum.Font.GothamMedium,
                Text = opts.Name or "Keybind", TextColor3 = C.T1, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
            }, row)

            local kbtn = N("TextButton", {
                BackgroundColor3 = C.Rise, Size = UDim2.new(0, 80, 0, 30),
                Position = UDim2.new(1, -94, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
                Font = Enum.Font.Code, Text = key.Name, TextColor3 = accent, TextSize = 12,
                AutoButtonColor = false, ZIndex = 15,
            }, row)
            Corner(kbtn, UDim.new(0, 7))
            Stroke(kbtn, C.Edge, 1, 0.4)

            kbtn.MouseButton1Click:Connect(function()
                listening = true; kbtn.Text = "..."
                tw(kbtn, { BackgroundColor3 = accent }, 0.14)
                kbtn.TextColor3 = C.Pure
            end)
            UserInputService.InputBegan:Connect(function(i)
                if listening and i.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false; key = i.KeyCode; kbtn.Text = key.Name
                    tw(kbtn, { BackgroundColor3 = C.Rise }, 0.14)
                    kbtn.TextColor3 = accent
                    if opts.Callback then opts.Callback(key) end
                end
            end)

            local API = {}
            function API:Set(k) key = k; kbtn.Text = k.Name end
            function API:Get() return key end
            return API
        end

        -- LABEL ───────────────────────────────────────────────────

        function Tab:CreateLabel(opts)
            opts = opts or {}

            local row = N("Frame", {
                BackgroundColor3 = C.Surface, BackgroundTransparency = 0.4,
                Size = UDim2.new(1, 0, 0, 34), LayoutOrder = #page:GetChildren(), ZIndex = 13,
            }, page)
            Corner(row, UDim.new(0, 9))

            local dot = N("Frame", {
                BackgroundColor3 = accent, Size = UDim2.new(0, 5, 0, 5),
                Position = UDim2.new(0, 13, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), ZIndex = 14,
            }, row)
            Corner(dot, UDim.new(1, 0))

            local lbl = N("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(1, -30, 1, 0),
                Position = UDim2.new(0, 28, 0, 0), Font = Enum.Font.GothamMedium,
                Text = opts.Text or "Label", TextColor3 = C.T2, TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
            }, row)

            local API = {}
            function API:Set(v) lbl.Text = v end
            function API:Get() return lbl.Text end
            return API
        end

        -- COLOR SWATCH ────────────────────────────────────────────

        function Tab:CreateColorPicker(opts)
            opts = opts or {}
            local color = opts.Default or Color3.new(1, 1, 1)

            local row = N("Frame", {
                BackgroundColor3 = C.Surface,
                Size = UDim2.new(1, 0, 0, 44), LayoutOrder = #page:GetChildren(), ZIndex = 13,
            }, page)
            Corner(row, UDim.new(0, 9))
            HoverRow(row, C.Surface, C.Lift)

            N("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(0.65, -14, 1, 0),
                Position = UDim2.new(0, 14, 0, 0), Font = Enum.Font.GothamMedium,
                Text = opts.Name or "Color", TextColor3 = C.T1, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
            }, row)

            local swatch = N("Frame", {
                BackgroundColor3 = color, Size = UDim2.new(0, 32, 0, 32),
                Position = UDim2.new(1, -46, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), ZIndex = 15,
            }, row)
            Corner(swatch, UDim.new(0, 8))
            Stroke(swatch, C.Edge, 1)

            local API = {}
            function API:Set(col)
                color = col; swatch.BackgroundColor3 = col
                if opts.Callback then opts.Callback(col) end
            end
            function API:Get() return color end
            return API
        end

        return Tab
    end

    -- ── Config API ────────────────────────────────────────────────

    function Window:SetValue(k, v) State.Data[k] = v end
    function Window:GetValue(k)    return State.Data[k] end

    function Window:SaveConfig(name)
        local out = {}
        for k, v in pairs(State.Data) do out[k] = v end
        pcall(function()
            if writefile then
                writefile((name or WCfg.ConfigName) .. ".json", HttpService:JSONEncode(out))
            end
        end)
        Notify({ Title = "Saved", Content = (name or WCfg.ConfigName) .. ".json", Type = "Success", Duration = 3 })
        return out
    end

    function Window:LoadConfig(name, data)
        if type(data) == "table" then
            for k, v in pairs(data) do State.Data[k] = v end
            Notify({ Title = "Loaded", Content = name or "config", Type = "Info", Duration = 3 })
        else
            pcall(function()
                if readfile and isfile then
                    local p = (name or WCfg.ConfigName) .. ".json"
                    if isfile(p) then
                        for k, v in pairs(HttpService:JSONDecode(readfile(p))) do State.Data[k] = v end
                        Notify({ Title = "Loaded", Content = p, Type = "Info", Duration = 3 })
                    end
                end
            end)
        end
    end

    function Window:Destroy()
        twBack(Win, { Size = UDim2.new(0, 0, 0, 0) }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.delay(0.4, function() Gui:Destroy() end)
    end

    -- ── Play boot overlay (window is already built underneath) ────

    task.spawn(function()
        PlayBoot(Gui)
        task.delay(0.3, function()
            Notify({ Title = "UpFor Ready", Content = WCfg.Title .. "  |  " .. WCfg.Subtitle, Type = "Success", Duration = 4 })
        end)
    end)

    return Window
end

return UpFor
