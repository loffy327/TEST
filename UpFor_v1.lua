--[[
    ================================================================

        U P F O R   Framework
        Roblox Luau Premium UI Library

        Version   : 1.0.0
        Build     : 2026.06.21
        License   : Lifetime Full Source — 3,000,000 VND

        FEATURES
          Cinematic multi-phase boot sequence
          Particle convergence logo reveal
          Neon glow animated border system
          Window : Minimize  Maximize  Close
          Tab sidebar with indicator animations
          Toggle  Slider  Button  Dropdown
          Input   Keybind  ColorSwatch  Label
          Toast notification system (4 types)
          Config read / write (JSON)
          Draggable window  Keybind toggle
          Per-element micro-animations + glow
          Zero external dependencies

    ================================================================
--]]

-- ════════════════════════════════════════════════════════════════
--  SERVICES
-- ════════════════════════════════════════════════════════════════

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")
local Players          = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════════
--  COLOR SYSTEM
-- ════════════════════════════════════════════════════════════════

local Color = {
    -- Base layers
    Void     = Color3.fromRGB(4,   4,  12),
    Abyss    = Color3.fromRGB(8,   8,  18),
    Deep     = Color3.fromRGB(12, 12,  24),
    Surface  = Color3.fromRGB(17, 17,  34),
    Lift     = Color3.fromRGB(22, 22,  44),
    Rise     = Color3.fromRGB(28, 28,  56),

    -- Electric violet accent
    E1       = Color3.fromRGB(108, 92, 255),
    E2       = Color3.fromRGB(138,122, 255),
    E3       = Color3.fromRGB(80,  68, 210),
    Glow     = Color3.fromRGB(108, 92, 255),

    -- Cyan highlight
    C1       = Color3.fromRGB(60, 210, 255),
    C2       = Color3.fromRGB(30, 160, 210),

    -- Text
    T1       = Color3.fromRGB(235, 235, 248),
    T2       = Color3.fromRGB(145, 145, 175),
    T3       = Color3.fromRGB(72,  72, 108),

    -- Edges
    Edge     = Color3.fromRGB(38,  38,  72),
    EdgeHi   = Color3.fromRGB(58,  58, 105),

    -- Status
    Green    = Color3.fromRGB(40,  205, 120),
    Yellow   = Color3.fromRGB(255, 195,  55),
    Red      = Color3.fromRGB(235,  65,  75),
    Blue     = Color3.fromRGB(60,  190, 255),

    -- Misc
    Pure     = Color3.new(1, 1, 1),
    Black    = Color3.new(0, 0, 0),
    Divider  = Color3.fromRGB(30, 30, 58),
}

-- ════════════════════════════════════════════════════════════════
--  TWEEN ENGINE
-- ════════════════════════════════════════════════════════════════

local function tw(obj, props, t, style, dir)
    local i = TweenInfo.new(
        t     or 0.25,
        style or Enum.EasingStyle.Quint,
        dir   or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(obj, i, props)
    tween:Play()
    return tween
end

local function twBack(obj, p, t)    return tw(obj, p, t, Enum.EasingStyle.Back) end
local function twSine(obj, p, t)    return tw(obj, p, t, Enum.EasingStyle.Sine) end
local function twLinear(obj, p, t)  return tw(obj, p, t, Enum.EasingStyle.Linear) end
local function twElastic(obj, p, t) return tw(obj, p, t, Enum.EasingStyle.Elastic) end
local function twSpring(obj, p, t)  return tw(obj, p, t, Enum.EasingStyle.Spring) end

-- ════════════════════════════════════════════════════════════════
--  INSTANCE BUILDER
-- ════════════════════════════════════════════════════════════════

local function new(class, props, parent)
    local o = Instance.new(class)
    if props then for k, v in pairs(props) do o[k] = v end end
    if parent then o.Parent = parent end
    return o
end

local function corner(obj, r)
    return new("UICorner", { CornerRadius = r or UDim.new(0, 8) }, obj)
end

local function stroke(obj, col, thick, transp)
    return new("UIStroke", {
        Color        = col   or Color.Edge,
        Thickness    = thick or 1,
        Transparency = transp or 0,
    }, obj)
end

local function gradient(obj, cs, ts, rot)
    return new("UIGradient", {
        Color        = cs  or ColorSequence.new(Color.E1, Color.C1),
        Transparency = ts  or NumberSequence.new(0),
        Rotation     = rot or 0,
    }, obj)
end

local function shadow(obj)
    return new("ImageLabel", {
        Name              = "_Shadow",
        BackgroundTransparency = 1,
        Image             = "rbxassetid://6014261993",
        ImageColor3       = Color.Black,
        ImageTransparency = 0.48,
        Size              = UDim2.new(1, 46, 1, 46),
        Position          = UDim2.new(0, -23, 0, -23),
        ZIndex            = obj.ZIndex - 1,
        ScaleType         = Enum.ScaleType.Slice,
        SliceCenter       = Rect.new(49, 49, 450, 450),
    }, obj)
end

local function listH(obj, pad, ha, va)
    return new("UIListLayout", {
        FillDirection       = Enum.FillDirection.Horizontal,
        Padding             = pad or UDim.new(0, 6),
        SortOrder           = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = ha or Enum.HorizontalAlignment.Left,
        VerticalAlignment   = va or Enum.VerticalAlignment.Center,
    }, obj)
end

local function listV(obj, pad, va)
    return new("UIListLayout", {
        FillDirection       = Enum.FillDirection.Vertical,
        Padding             = pad or UDim.new(0, 5),
        SortOrder           = Enum.SortOrder.LayoutOrder,
        VerticalAlignment   = va  or Enum.VerticalAlignment.Top,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    }, obj)
end

local function pad(obj, t, r, b, l)
    return new("UIPadding", {
        PaddingTop    = UDim.new(0, t or 8),
        PaddingRight  = UDim.new(0, r or 8),
        PaddingBottom = UDim.new(0, b or 8),
        PaddingLeft   = UDim.new(0, l or 8),
    }, obj)
end

local function glowCircle(parent, size, pos, col, transp, zi)
    return new("ImageLabel", {
        BackgroundTransparency = 1,
        Image             = "rbxassetid://5028857472",
        ImageColor3       = col   or Color.E1,
        ImageTransparency = transp or 0.55,
        Size              = size,
        Position          = pos,
        AnchorPoint       = Vector2.new(0.5, 0.5),
        ZIndex            = zi or parent.ZIndex,
        ScaleType         = Enum.ScaleType.Stretch,
    }, parent)
end

-- Ripple from cursor position
local function ripple(btn, col)
    local mp = UserInputService:GetMouseLocation()
    local rel = mp - Vector2.new(btn.AbsolutePosition.X, btn.AbsolutePosition.Y)
    local r = new("Frame", {
        BackgroundColor3       = col or Color.E2,
        BackgroundTransparency = 0.62,
        Size                   = UDim2.new(0, 0, 0, 0),
        Position               = UDim2.new(0, rel.X, 0, rel.Y),
        AnchorPoint            = Vector2.new(0.5, 0.5),
        ZIndex                 = btn.ZIndex + 20,
        ClipsDescendants       = false,
    }, btn)
    corner(r, UDim.new(1, 0))
    twSine(r, { Size = UDim2.new(3, 0, 3, 0), BackgroundTransparency = 1 }, 0.6)
    task.delay(0.65, function() if r and r.Parent then r:Destroy() end end)
end

local function hoverBind(f, norm, hov)
    f.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then tw(f, { BackgroundColor3 = hov }, 0.14) end
    end)
    f.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then tw(f, { BackgroundColor3 = norm }, 0.14) end
    end)
end

-- ════════════════════════════════════════════════════════════════
--  ANIMATED NEON BORDER
-- ════════════════════════════════════════════════════════════════

local function neonBorder(parent, col1, col2)
    col1 = col1 or Color.E1
    col2 = col2 or Color.C1

    local line = new("Frame", {
        BackgroundTransparency = 1,
        Size       = UDim2.new(1, 0, 0, 2),
        BorderSizePixel = 0,
        ZIndex     = parent.ZIndex + 2,
    }, parent)

    local g = gradient(line, ColorSequence.new({
        ColorSequenceKeypoint.new(0,    col1),
        ColorSequenceKeypoint.new(0.3,  col2),
        ColorSequenceKeypoint.new(0.7,  col1),
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
--  BOOT SEQUENCE  –  Cinematic intro on execute
-- ════════════════════════════════════════════════════════════════

local function bootSequence(gui, onDone)
    -- ── Layer stack ──────────────────────────────────────────────

    -- Full dark curtain
    local curtain = new("Frame", {
        BackgroundColor3       = Color.Black,
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 1, 0),
        ZIndex = 500,
    }, gui)

    twSine(curtain, { BackgroundTransparency = 0 }, 0.4)
    task.wait(0.42)

    -- ── Phase 1 : Ambient nebula glow ────────────────────────────

    local nebula = new("Frame", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 1, 0),
        ZIndex = 501,
    }, gui)

    local neb1 = glowCircle(nebula, UDim2.new(0, 0, 0, 0), UDim2.new(0.5, 0, 0.5, 0), Color.E1, 1, 501)
    local neb2 = glowCircle(nebula, UDim2.new(0, 0, 0, 0), UDim2.new(0.5, 0, 0.5, 0), Color.C1, 1, 501)

    twSine(neb1, { Size = UDim2.new(0, 700, 0, 700), ImageTransparency = 0.62 }, 0.9)
    twSine(neb2, { Size = UDim2.new(0, 400, 0, 400), ImageTransparency = 0.72 }, 0.7)

    task.wait(0.35)

    -- ── Phase 2 : Particles converge to center ───────────────────

    local particleHolder = new("Frame", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 1, 0),
        ZIndex = 502,
    }, gui)

    local particles = {}
    local rng = Random.new()

    for i = 1, 22 do
        local angle  = rng:NextNumber(0, math.pi * 2)
        local dist   = rng:NextNumber(280, 580)
        local size   = rng:NextNumber(3, 7)
        local startX = 0.5 + math.cos(angle) * dist / (workspace.CurrentCamera.ViewportSize.X)
        local startY = 0.5 + math.sin(angle) * dist / (workspace.CurrentCamera.ViewportSize.Y)

        local p = new("Frame", {
            BackgroundColor3       = i % 3 == 0 and Color.C1 or Color.E2,
            BackgroundTransparency = 0.1,
            Size     = UDim2.new(0, size, 0, size),
            Position = UDim2.new(startX, 0, startY, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            ZIndex   = 503,
        }, particleHolder)
        corner(p, UDim.new(1, 0))

        -- Fade in
        p.BackgroundTransparency = 1
        twSine(p, { BackgroundTransparency = 0.1 }, 0.3)

        table.insert(particles, { frame = p, delay = rng:NextNumber(0.05, 0.35) })
    end

    -- Converge toward center
    task.wait(0.2)
    for _, pt in ipairs(particles) do
        task.delay(pt.delay, function()
            if pt.frame and pt.frame.Parent then
                tw(pt.frame, {
                    Position             = UDim2.new(0.5, 0, 0.5, 0),
                    BackgroundTransparency = 0.7,
                    Size                 = UDim2.new(0, 2, 0, 2),
                }, 0.7, Enum.EasingStyle.Quint)
            end
        end)
    end

    task.wait(0.9)

    -- ── Phase 3 : Logo card materializes ─────────────────────────

    local logoCard = new("Frame", {
        BackgroundColor3       = Color.Deep,
        BackgroundTransparency = 1,
        Size     = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex   = 505,
    }, gui)
    corner(logoCard, UDim.new(0, 16))

    -- Logo inner gradient
    local logoGrad = new("Frame", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 1, 0),
        ZIndex = 505,
    }, logoCard)
    gradient(logoGrad,
        ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color.E3),
            ColorSequenceKeypoint.new(1,   Color.Black),
        }),
        NumberSequence.new({
            NumberSequenceKeypoint.new(0,   0.82),
            NumberSequenceKeypoint.new(1,   0.96),
        }), 135
    )
    corner(logoGrad, UDim.new(0, 16))

    local logoStroke = stroke(logoCard, Color.E1, 1, 0.2)

    -- Expand card
    twBack(logoCard, {
        Size                 = UDim2.new(0, 110, 0, 110),
        BackgroundTransparency = 0,
    }, 0.6)

    task.wait(0.3)

    -- Logo rings
    local ring1 = new("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex   = 504,
    }, gui)
    stroke(ring1, Color.E1, 1, 0.3)
    corner(ring1, UDim.new(1, 0))

    local ring2 = new("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex   = 504,
    }, gui)
    stroke(ring2, Color.C1, 1, 0.55)
    corner(ring2, UDim.new(1, 0))

    twBack(ring1, { Size = UDim2.new(0, 148, 0, 148) }, 0.55)
    twBack(ring2, { Size = UDim2.new(0, 180, 0, 180) }, 0.7)

    task.wait(0.2)

    -- ── Logo text — typewriter character by character ─────────────

    local logoLabel = new("TextLabel", {
        BackgroundTransparency = 1,
        Size       = UDim2.new(1, 0, 0.55, 0),
        Position   = UDim2.new(0, 0, 0.08, 0),
        Font       = Enum.Font.GothamBold,
        Text       = "",
        TextColor3 = Color.Pure,
        TextTransparency = 1,
        TextSize   = 32,
        ZIndex     = 507,
    }, logoCard)

    local tagLabel = new("TextLabel", {
        BackgroundTransparency = 1,
        Size       = UDim2.new(1, 0, 0.3, 0),
        Position   = UDim2.new(0, 0, 0.65, 0),
        Font       = Enum.Font.GothamMedium,
        Text       = "",
        TextColor3 = Color.T3,
        TextTransparency = 1,
        TextSize   = 10,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex     = 507,
    }, logoCard)

    twSine(logoLabel, { TextTransparency = 0 }, 0.35)

    local chars = { "U", "p", "F", "o", "r" }
    local built = ""
    for i, c in ipairs(chars) do
        task.wait(0.08)
        built = built .. c
        logoLabel.Text = built
    end

    task.wait(0.18)
    twSine(tagLabel, { TextTransparency = 0 }, 0.4)
    tagLabel.Text = "PREMIUM  UI"

    -- ── Phase 4 : Progress bar ────────────────────────────────────

    local barHolder = new("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(0, 210, 0, 3),
        Position = UDim2.new(0.5, 0, 0.5, 90),
        AnchorPoint = Vector2.new(0.5, 0),
        ZIndex   = 506,
    }, gui)

    local barBg = new("Frame", {
        BackgroundColor3 = Color.Rise,
        BackgroundTransparency = 0.5,
        Size   = UDim2.new(1, 0, 1, 0),
        ZIndex = 506,
    }, barHolder)
    corner(barBg, UDim.new(1, 0))

    local barFill = new("Frame", {
        BackgroundColor3 = Color.E1,
        Size   = UDim2.new(0, 0, 1, 0),
        ZIndex = 507,
    }, barBg)
    corner(barFill, UDim.new(1, 0))
    gradient(barFill,
        ColorSequence.new({ ColorSequenceKeypoint.new(0, Color.E1), ColorSequenceKeypoint.new(1, Color.C1) }),
        NumberSequence.new(0)
    )

    -- Glow dot on bar end
    local barDot = new("Frame", {
        BackgroundColor3 = Color.E2,
        BackgroundTransparency = 0.2,
        Size     = UDim2.new(0, 8, 0, 8),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex   = 508,
    }, barFill)
    corner(barDot, UDim.new(1, 0))

    local status = new("TextLabel", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(0, 210, 0, 16),
        Position = UDim2.new(0.5, 0, 0.5, 100),
        AnchorPoint = Vector2.new(0.5, 0),
        Font     = Enum.Font.Code,
        Text     = "Initializing...",
        TextColor3 = Color.T3,
        TextTransparency = 1,
        TextSize = 10,
        ZIndex   = 506,
    }, gui)

    barHolder.BackgroundTransparency = 1
    twSine(barHolder, {}, 0)
    twSine(status, { TextTransparency = 0 }, 0.3)

    -- Fill bar in steps with status text
    local steps = {
        { pct = 0.25, label = "Loading components..." },
        { pct = 0.55, label = "Applying theme..." },
        { pct = 0.82, label = "Configuring elements..." },
        { pct = 1.0,  label = "Ready." },
    }

    for _, step in ipairs(steps) do
        status.Text = step.label
        twLinear(barFill, { Size = UDim2.new(step.pct, 0, 1, 0) }, 0.28)
        task.wait(0.32)
    end

    task.wait(0.2)

    -- ── Phase 5 : Pulse ring + white flash collapse ───────────────

    -- Ring pulse outward
    twSine(ring1, { Size = UDim2.new(0, 200, 0, 200) }, 0.3)
    tw(ring1, { Size = UDim2.new(0, 0, 0, 0) }, 0.35, Enum.EasingStyle.Quint, nil, 0.3)
    twSine(ring2, { Size = UDim2.new(0, 250, 0, 250) }, 0.35)
    tw(ring2, { Size = UDim2.new(0, 0, 0, 0) }, 0.35, Enum.EasingStyle.Quint, nil, 0.35)

    -- Glow burst
    twSine(neb1, { ImageTransparency = 0.2 }, 0.25)
    task.wait(0.2)
    twSine(neb1, { ImageTransparency = 1 }, 0.4)
    twSine(neb2, { ImageTransparency = 1 }, 0.4)

    -- Collapse logo card
    twBack(logoCard, {
        Size                 = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
    }, 0.42, Enum.EasingStyle.Back, Enum.EasingDirection.In)

    twSine(logoLabel, { TextTransparency = 1 }, 0.25)
    twSine(tagLabel,  { TextTransparency = 1 }, 0.25)
    twSine(barHolder, {}, 0)
    twSine(status,    { TextTransparency = 1 }, 0.2)

    task.wait(0.28)

    -- White flash
    local flash = new("Frame", {
        BackgroundColor3       = Color.Pure,
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 1, 0),
        ZIndex = 600,
    }, gui)
    twSine(flash, { BackgroundTransparency = 0.1 }, 0.12)
    task.wait(0.12)
    twSine(flash, { BackgroundTransparency = 1 }, 0.35)

    -- Fade curtain
    twSine(curtain, { BackgroundTransparency = 1 }, 0.45)

    task.wait(0.48)

    -- Destroy all boot layers
    curtain:Destroy()
    nebula:Destroy()
    particleHolder:Destroy()
    logoCard:Destroy()
    ring1:Destroy()
    ring2:Destroy()
    barHolder:Destroy()
    status:Destroy()
    flash:Destroy()

    if onDone then onDone() end
end

-- ════════════════════════════════════════════════════════════════
--  LIBRARY ENTRY POINT
-- ════════════════════════════════════════════════════════════════

local UpFor = {}
UpFor.__index = UpFor

function UpFor:CreateWindow(cfg)
    cfg = cfg or {}

    local accent    = cfg.AccentColor  or Color.E1
    local accentHi  = cfg.AccentBright or Color.E2
    local accentCy  = cfg.AccentCyan   or Color.C1

    local WCfg = {
        Title        = cfg.Title       or "UpFor",
        Subtitle     = cfg.Subtitle    or "v1.0",
        LogoText     = cfg.LogoText    or "UF",
        Size         = cfg.Size        or UDim2.new(0, 630, 0, 450),
        MinSize      = cfg.MinSize     or UDim2.new(0, 630, 0, 56),
        ToggleKey    = cfg.ToggleKey   or Enum.KeyCode.RightShift,
        ConfigName   = cfg.ConfigName  or "UpFor",
        TutorialMode = cfg.TutorialMode ~= false,
    }

    local State = {
        Minimized = false, Maximized = false,
        Dragging = false, DragOrigin = nil, DragPos = nil,
        ActiveTab = nil, Tabs = {}, Data = {},
    }

    -- ── Screen GUI ────────────────────────────────────────────────

    local Gui = new("ScreenGui", {
        Name           = "UpFor_GUI",
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder   = 999,
        IgnoreGuiInset = true,
    }, LocalPlayer:WaitForChild("PlayerGui"))

    -- ── Notification system (defined early so boot can use it) ────

    local NotifFrame = new("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(0, 320, 1, -20),
        Position = UDim2.new(1, -330, 0, 10),
        ZIndex   = 300,
    }, Gui)
    new("UIListLayout", {
        VerticalAlignment   = Enum.VerticalAlignment.Bottom,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Padding             = UDim.new(0, 8),
    }, NotifFrame)

    local notifIdx = 0

    local function Notify(opts)
        opts = opts or {}
        notifIdx += 1
        local colMap = { Success = Color.Green, Warning = Color.Yellow, Error = Color.Red, Info = Color.Blue }
        local ac = colMap[opts.Type] or accent

        local nf = new("Frame", {
            BackgroundColor3 = Color.Surface,
            BackgroundTransparency = 0.06,
            Size         = UDim2.new(1, 0, 0, 72),
            ZIndex       = 301,
            LayoutOrder  = notifIdx,
        }, NotifFrame)
        corner(nf, UDim.new(0, 10))
        stroke(nf, ac, 1, 0.5)

        -- Accent bar
        local nb = new("Frame", {
            BackgroundColor3 = ac,
            Size     = UDim2.new(0, 3, 0.6, 0),
            Position = UDim2.new(0, 8, 0.2, 0),
            ZIndex   = 302,
        }, nf)
        corner(nb, UDim.new(1, 0))

        -- Bar glow
        glowCircle(nf, UDim2.new(0, 90, 0, 90), UDim2.new(0, 10, 0.5, 0), ac, 0.72, 301)

        new("TextLabel", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(1, -30, 0, 20),
            Position = UDim2.new(0, 22, 0, 12),
            Font     = Enum.Font.GothamBold,
            Text     = opts.Title   or "Notice",
            TextColor3 = Color.T1, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex   = 302,
        }, nf)
        new("TextLabel", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(1, -30, 0, 28),
            Position = UDim2.new(0, 22, 0, 32),
            Font     = Enum.Font.GothamMedium,
            Text     = opts.Content or "",
            TextColor3 = Color.T2, TextSize = 11, TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex   = 302,
        }, nf)

        nf.Position = UDim2.new(1, 40, 0, 0)
        nf.BackgroundTransparency = 0.5
        twBack(nf, { Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0.06 }, 0.38)

        task.delay(opts.Duration or 4, function()
            tw(nf, { Position = UDim2.new(1, 40, 0, 0), BackgroundTransparency = 1 }, 0.32)
            task.delay(0.35, function() if nf and nf.Parent then nf:Destroy() end end)
        end)
    end

    -- ── Build main window (called after boot finishes) ────────────

    local Window = { Notify = Notify }
    local windowBuilt = false

    local function buildWindow()
        if windowBuilt then return end
        windowBuilt = true

        -- ── Main frame ───────────────────────────────────────────

        local Win = new("Frame", {
            Name             = "Window",
            BackgroundColor3 = Color.Abyss,
            BackgroundTransparency = 1,
            Size     = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint      = Vector2.new(0.5, 0.5),
            ClipsDescendants = true,
            ZIndex           = 10,
        }, Gui)
        corner(Win, UDim.new(0, 14))
        stroke(Win, Color.Edge, 1, 0.28)
        shadow(Win)

        -- Background ambient glow behind window
        local winGlow = glowCircle(Gui,
            UDim2.new(0, 0, 0, 0),
            UDim2.new(0.5, 0, 0.5, 0),
            accent, 1, 9
        )

        -- Neon animated border
        neonBorder(Win, accent, accentCy)

        -- Reveal animation
        twBack(Win, {
            Size = WCfg.Size,
            BackgroundTransparency = 0,
        }, 0.7)
        twSine(winGlow, {
            Size             = UDim2.new(0, 760, 0, 560),
            ImageTransparency = 0.8,
        }, 0.7)

        -- ── Title bar ────────────────────────────────────────────

        local TBar = new("Frame", {
            BackgroundColor3       = Color.Deep,
            BackgroundTransparency = 0.2,
            Size     = UDim2.new(1, 0, 0, 56),
            Position = UDim2.new(0, 0, 0, 2),
            ZIndex   = 12,
        }, Win)

        -- Subtle gradient on title bar
        local tbarGrad = new("Frame", {
            BackgroundTransparency = 1,
            Size   = UDim2.new(1, 0, 1, 0),
            ZIndex = 13,
        }, TBar)
        gradient(tbarGrad,
            ColorSequence.new({ ColorSequenceKeypoint.new(0, accent), ColorSequenceKeypoint.new(1, Color.Black) }),
            NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.88), NumberSequenceKeypoint.new(1, 1) }),
            180
        )

        new("Frame", {
            BackgroundColor3 = Color.Divider,
            BackgroundTransparency = 0.45,
            Size     = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, 0),
            ZIndex   = 13,
        }, TBar)

        -- ── Logo badge ───────────────────────────────────────────

        local badge = new("Frame", {
            BackgroundColor3 = accent,
            Size     = UDim2.new(0, 36, 0, 36),
            Position = UDim2.new(0, 14, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            ZIndex   = 14,
        }, TBar)
        corner(badge, UDim.new(0, 9))

        -- Pulsing glow behind badge
        local badgePulse = new("Frame", {
            BackgroundColor3 = accent,
            BackgroundTransparency = 0.72,
            Size     = UDim2.new(1, 8, 1, 8),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            ZIndex   = 13,
        }, badge)
        corner(badgePulse, UDim.new(0, 10))

        task.spawn(function()
            while badge and badge.Parent do
                twSpring(badgePulse, { Size = UDim2.new(1, 14, 1, 14), BackgroundTransparency = 0.45 }, 1.8)
                task.wait(1.8)
                twSpring(badgePulse, { Size = UDim2.new(1, 6, 1, 6), BackgroundTransparency = 0.72 }, 1.8)
                task.wait(1.8)
            end
        end)

        new("TextLabel", {
            BackgroundTransparency = 1,
            Size       = UDim2.new(1, 0, 1, 0),
            Font       = Enum.Font.GothamBold,
            Text       = WCfg.LogoText,
            TextColor3 = Color.Pure,
            TextSize   = 17,
            ZIndex     = 15,
        }, badge)

        -- Title + Subtitle
        new("TextLabel", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(0.4, -60, 0, 20),
            Position = UDim2.new(0, 62, 0, 9),
            Font     = Enum.Font.GothamBold,
            Text     = WCfg.Title,
            TextColor3 = Color.T1, TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex   = 14,
        }, TBar)

        new("TextLabel", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(0.4, -60, 0, 14),
            Position = UDim2.new(0, 62, 0, 32),
            Font     = Enum.Font.GothamMedium,
            Text     = WCfg.Subtitle,
            TextColor3 = Color.T3, TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex   = 14,
        }, TBar)

        -- ── Window controls  [ - ]  [ + ]  [ X ] ────────────────

        local ctrlWrap = new("Frame", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(0, 123, 0, 38),
            Position = UDim2.new(1, -132, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            ZIndex   = 14,
        }, TBar)
        listH(ctrlWrap, UDim.new(0, 7))

        local function ctrlBtn(lbl, hovColor, order, cb)
            local b = new("TextButton", {
                Name             = lbl,
                BackgroundColor3 = Color.Rise,
                Size             = UDim2.new(0, 36, 0, 36),
                Font             = Enum.Font.GothamBold,
                Text             = lbl,
                TextColor3       = Color.T2,
                TextSize         = 16,
                AutoButtonColor  = false,
                LayoutOrder      = order,
                ZIndex           = 15,
            }, ctrlWrap)
            corner(b, UDim.new(0, 9))

            b.MouseEnter:Connect(function()
                tw(b, { BackgroundColor3 = hovColor, TextColor3 = Color.Pure }, 0.14)
            end)
            b.MouseLeave:Connect(function()
                tw(b, { BackgroundColor3 = Color.Rise, TextColor3 = Color.T2 }, 0.14)
            end)
            b.MouseButton1Click:Connect(function()
                ripple(b, hovColor)
                if cb then cb() end
            end)
        end

        ctrlBtn("-", Color.Yellow, 1, function()
            State.Minimized = not State.Minimized
            if State.Minimized then
                twBack(Win, { Size = WCfg.MinSize }, 0.32, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            else
                local t = State.Maximized and UDim2.new(1, -40, 1, -40) or WCfg.Size
                twBack(Win, { Size = t }, 0.32)
            end
        end)

        ctrlBtn("+", Color.Green, 2, function()
            State.Minimized = false
            State.Maximized = not State.Maximized
            if State.Maximized then
                twBack(Win, { Size = UDim2.new(1, -40, 1, -40), Position = UDim2.new(0.5, 0, 0.5, 0) }, 0.32)
            else
                twBack(Win, { Size = WCfg.Size, Position = UDim2.new(0.5, 0, 0.5, 0) }, 0.32)
            end
        end)

        ctrlBtn("X", Color.Red, 3, function()
            twBack(Win,    { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }, 0.38, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            twSine(winGlow, { ImageTransparency = 1 }, 0.3)
            task.delay(0.42, function() Gui:Destroy() end)
        end)

        -- ── Drag ─────────────────────────────────────────────────

        TBar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                State.Dragging = true
                State.DragOrigin = i.Position
                State.DragPos    = Win.Position
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
                Win.Position = UDim2.new(
                    State.DragPos.X.Scale, State.DragPos.X.Offset + d.X,
                    State.DragPos.Y.Scale, State.DragPos.Y.Offset + d.Y
                )
                winGlow.Position = Win.Position
            end
        end)

        UserInputService.InputBegan:Connect(function(i, gpe)
            if not gpe and i.KeyCode == WCfg.ToggleKey then
                Win.Visible = not Win.Visible
            end
        end)

        -- ── Body ─────────────────────────────────────────────────

        local body = new("Frame", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(1, 0, 1, -58),
            Position = UDim2.new(0, 0, 0, 58),
            ZIndex   = 11,
        }, Win)

        -- ── Sidebar ──────────────────────────────────────────────

        local sidebar = new("Frame", {
            BackgroundColor3       = Color.Deep,
            BackgroundTransparency = 0.18,
            Size     = UDim2.new(0, 165, 1, 0),
            ZIndex   = 11,
        }, body)

        new("Frame", {
            BackgroundColor3 = Color.Divider,
            BackgroundTransparency = 0.42,
            Size     = UDim2.new(0, 1, 1, 0),
            Position = UDim2.new(1, 0, 0, 0),
            ZIndex   = 12,
        }, sidebar)

        local sideScroll = new("ScrollingFrame", {
            BackgroundTransparency  = 1,
            Size     = UDim2.new(1, -10, 1, -14),
            Position = UDim2.new(0, 5, 0, 7),
            CanvasSize           = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize  = Enum.AutomaticSize.Y,
            ScrollBarThickness   = 2,
            ScrollBarImageColor3 = Color.Edge,
            BorderSizePixel = 0,
            ZIndex = 12,
        }, sidebar)
        listV(sideScroll, UDim.new(0, 4))

        -- ── Content ──────────────────────────────────────────────

        local content = new("Frame", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(1, -167, 1, 0),
            Position = UDim2.new(0, 167, 0, 0),
            ClipsDescendants = true,
            ZIndex   = 11,
        }, body)

        -- ── TAB BUILDER ──────────────────────────────────────────

        function Window:CreateTab(tabCfg)
            tabCfg = tabCfg or {}
            local tName  = tabCfg.Name  or "Tab"
            local tIcon  = tabCfg.Icon  or ""
            local tOrder = tabCfg.Order or (#State.Tabs + 1)

            -- Sidebar button
            local tabBtn = new("TextButton", {
                BackgroundColor3       = Color.Lift,
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, -6, 0, 44),
                Text     = "",
                AutoButtonColor = false,
                LayoutOrder = tOrder,
                ZIndex   = 13,
            }, sideScroll)
            corner(tabBtn, UDim.new(0, 9))

            -- Active glow background
            local tabGlow = new("Frame", {
                BackgroundColor3 = accent,
                BackgroundTransparency = 1,
                Size   = UDim2.new(1, 0, 1, 0),
                ZIndex = 12,
            }, tabBtn)
            corner(tabGlow, UDim.new(0, 9))
            gradient(tabGlow,
                ColorSequence.new({ ColorSequenceKeypoint.new(0, accent), ColorSequenceKeypoint.new(1, Color.Black) }),
                NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.82), NumberSequenceKeypoint.new(1, 1) }),
                0
            )

            local tabIcn = new("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0, 36, 1, 0),
                Position = UDim2.new(0, 6, 0, 0),
                Font     = Enum.Font.GothamMedium,
                Text     = tIcon,
                TextColor3 = Color.Edge, TextSize = 15,
                ZIndex   = 14,
            }, tabBtn)

            local tabLbl = new("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, -50, 1, 0),
                Position = UDim2.new(0, 44, 0, 0),
                Font     = Enum.Font.GothamMedium,
                Text     = tName,
                TextColor3 = Color.T2, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 14,
            }, tabBtn)

            local tabInd = new("Frame", {
                BackgroundColor3 = accent,
                Size     = UDim2.new(0, 3, 0, 0),
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                ZIndex   = 14,
            }, tabBtn)
            corner(tabInd, UDim.new(1, 0))

            -- Content page
            local page = new("ScrollingFrame", {
                BackgroundTransparency  = 1,
                Size     = UDim2.new(1, -14, 1, -14),
                Position = UDim2.new(0, 7, 0, 7),
                CanvasSize           = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize  = Enum.AutomaticSize.Y,
                ScrollBarThickness   = 3,
                ScrollBarImageColor3 = Color.Edge,
                BorderSizePixel = 0,
                Visible  = false,
                ZIndex   = 12,
            }, content)
            listV(page, UDim.new(0, 6))
            pad(page, 5, 5, 5, 5)

            local td = {
                Btn = tabBtn, Page = page, Ind = tabInd,
                Glow = tabGlow, Icn = tabIcn, Lbl = tabLbl,
            }
            table.insert(State.Tabs, td)

            local function selectTab()
                for _, t in ipairs(State.Tabs) do
                    t.Page.Visible = false
                    tw(t.Btn,  { BackgroundTransparency = 1 },             0.18)
                    tw(t.Glow, { BackgroundTransparency = 1 },             0.18)
                    tw(t.Ind,  { Size = UDim2.new(0, 3, 0, 0) },          0.18)
                    tw(t.Lbl,  { TextColor3 = Color.T2 },                  0.18)
                    tw(t.Icn,  { TextColor3 = Color.Edge },                0.18)
                end
                td.Page.Visible = true
                State.ActiveTab = td
                tw(td.Btn,  { BackgroundTransparency = 0.72 },         0.18)
                tw(td.Glow, { BackgroundTransparency = 0.86 },         0.18)
                tw(td.Lbl,  { TextColor3 = Color.T1 },                 0.18)
                tw(td.Icn,  { TextColor3 = accent },                   0.18)
                twBack(td.Ind, { Size = UDim2.new(0, 3, 0, 26) },     0.28)
            end

            tabBtn.MouseEnter:Connect(function()
                if State.ActiveTab ~= td then tw(tabBtn, { BackgroundTransparency = 0.84 }, 0.14) end
            end)
            tabBtn.MouseLeave:Connect(function()
                if State.ActiveTab ~= td then tw(tabBtn, { BackgroundTransparency = 1 }, 0.14) end
            end)
            tabBtn.MouseButton1Click:Connect(selectTab)

            if #State.Tabs == 1 then selectTab() end

            -- ── Element API ───────────────────────────────────────

            local Tab = {}

            -- SECTION ─────────────────────────────────────────────

            function Tab:CreateSection(name)
                local sf = new("Frame", {
                    BackgroundTransparency = 1,
                    Size     = UDim2.new(1, 0, 0, 26),
                    LayoutOrder = #page:GetChildren(),
                    ZIndex   = 13,
                }, page)

                new("Frame", {
                    BackgroundColor3 = Color.Divider,
                    BackgroundTransparency = 0.4,
                    Size     = UDim2.new(0, 18, 0, 1),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    ZIndex   = 13,
                }, sf)

                local dot = new("Frame", {
                    BackgroundColor3 = accent,
                    Size     = UDim2.new(0, 5, 0, 5),
                    Position = UDim2.new(0, 24, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    ZIndex   = 13,
                }, sf)
                corner(dot, UDim.new(1, 0))

                new("TextLabel", {
                    BackgroundTransparency = 1,
                    Size     = UDim2.new(0.65, -5, 1, 0),
                    Position = UDim2.new(0, 36, 0, 0),
                    Font     = Enum.Font.GothamBold,
                    Text     = string.upper(name or "SECTION"),
                    TextColor3 = Color.T3, TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex   = 13,
                }, sf)

                new("Frame", {
                    BackgroundColor3 = Color.Divider,
                    BackgroundTransparency = 0.4,
                    Size     = UDim2.new(0.48, -10, 0, 1),
                    Position = UDim2.new(0.52, 10, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    ZIndex   = 13,
                }, sf)
            end

            -- TOGGLE ──────────────────────────────────────────────

            function Tab:CreateToggle(opts)
                opts = opts or {}
                local val = opts.Default or false

                local h = opts.Description and 48 or 44

                local row = new("Frame", {
                    BackgroundColor3 = Color.Surface,
                    Size     = UDim2.new(1, 0, 0, h),
                    LayoutOrder = #page:GetChildren(),
                    ZIndex   = 13,
                }, page)
                corner(row, UDim.new(0, 9))
                hoverBind(row, Color.Surface, Color.Lift)

                -- Left active accent strip
                local strip = new("Frame", {
                    BackgroundColor3 = accent,
                    BackgroundTransparency = val and 0 or 1,
                    Size     = UDim2.new(0, 2, 0.55, 0),
                    Position = UDim2.new(0, 0, 0.225, 0),
                    ZIndex   = 14,
                }, row)

                new("TextLabel", {
                    BackgroundTransparency = 1,
                    Size     = UDim2.new(0.65, -14, 0, 18),
                    Position = UDim2.new(0, 14, 0, opts.Description and 5 or 13),
                    Font     = Enum.Font.GothamMedium,
                    Text     = opts.Name or "Toggle",
                    TextColor3 = Color.T1, TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex   = 14,
                }, row)

                if opts.Description then
                    new("TextLabel", {
                        BackgroundTransparency = 1,
                        Size     = UDim2.new(0.65, -14, 0, 13),
                        Position = UDim2.new(0, 14, 0, 26),
                        Font     = Enum.Font.GothamMedium,
                        Text     = opts.Description,
                        TextColor3 = Color.T3, TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex   = 14,
                    }, row)
                end

                local track = new("Frame", {
                    BackgroundColor3 = val and accent or Color.Rise,
                    Size     = UDim2.new(0, 48, 0, 26),
                    Position = UDim2.new(1, -62, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    ZIndex   = 14,
                }, row)
                corner(track, UDim.new(1, 0))

                -- Track glow
                local trackGlow = new("Frame", {
                    BackgroundColor3 = accent,
                    BackgroundTransparency = val and 0.6 or 1,
                    Size     = UDim2.new(1, 10, 1, 10),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    ZIndex   = 13,
                }, row)
                trackGlow.Position = UDim2.new(1, -57, 0.5, 0)
                corner(trackGlow, UDim.new(1, 0))

                local knob = new("Frame", {
                    BackgroundColor3 = Color.Pure,
                    Size     = UDim2.new(0, 20, 0, 20),
                    Position = val and UDim2.new(1, -23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    ZIndex   = 16,
                }, track)
                corner(knob, UDim.new(1, 0))

                local function refresh()
                    if val then
                        tw(track,     { BackgroundColor3 = accent },            0.2)
                        tw(trackGlow, { BackgroundTransparency = 0.6 },         0.2)
                        tw(strip,     { BackgroundTransparency = 0 },           0.2)
                        twBack(knob,  { Position = UDim2.new(1, -23, 0.5, 0) }, 0.24)
                    else
                        tw(track,     { BackgroundColor3 = Color.Rise },        0.2)
                        tw(trackGlow, { BackgroundTransparency = 1 },           0.2)
                        tw(strip,     { BackgroundTransparency = 1 },           0.2)
                        twBack(knob,  { Position = UDim2.new(0, 3, 0.5, 0) },  0.24)
                    end
                    if opts.Callback then opts.Callback(val) end
                end

                local cz = new("TextButton", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
                    Text = "", ZIndex = 17,
                }, row)
                cz.MouseButton1Click:Connect(function() val = not val; refresh() end)

                local API = {}
                function API:Set(v) val = v; refresh() end
                function API:Get() return val end
                return API
            end

            -- SLIDER ──────────────────────────────────────────────

            function Tab:CreateSlider(opts)
                opts = opts or {}
                local mn  = opts.Min       or 0
                local mx  = opts.Max       or 100
                local cur = opts.Default   or mn
                local stp = opts.Increment or 1

                local row = new("Frame", {
                    BackgroundColor3 = Color.Surface,
                    Size     = UDim2.new(1, 0, 0, 58),
                    LayoutOrder = #page:GetChildren(),
                    ZIndex   = 13,
                }, page)
                corner(row, UDim.new(0, 9))
                hoverBind(row, Color.Surface, Color.Lift)

                new("TextLabel", {
                    BackgroundTransparency = 1,
                    Size     = UDim2.new(0.65, -14, 0, 18),
                    Position = UDim2.new(0, 14, 0, 7),
                    Font     = Enum.Font.GothamMedium,
                    Text     = opts.Name or "Slider",
                    TextColor3 = Color.T1, TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex   = 14,
                }, row)

                local vLbl = new("TextLabel", {
                    BackgroundTransparency = 1,
                    Size     = UDim2.new(0.3, -14, 0, 18),
                    Position = UDim2.new(0.7, 0, 0, 7),
                    Font     = Enum.Font.Code,
                    Text     = tostring(cur),
                    TextColor3 = accent, TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex   = 14,
                }, row)

                local track = new("Frame", {
                    BackgroundColor3 = Color.Rise,
                    Size     = UDim2.new(1, -28, 0, 6),
                    Position = UDim2.new(0, 14, 0, 40),
                    ZIndex   = 14,
                }, row)
                corner(track, UDim.new(1, 0))

                local p0   = (cur - mn) / (mx - mn)

                local fill = new("Frame", {
                    BackgroundColor3 = accent,
                    Size   = UDim2.new(p0, 0, 1, 0),
                    ZIndex = 15,
                }, track)
                corner(fill, UDim.new(1, 0))
                gradient(fill,
                    ColorSequence.new({ ColorSequenceKeypoint.new(0, accent), ColorSequenceKeypoint.new(1, accentCy) }),
                    NumberSequence.new(0)
                )

                local knob = new("Frame", {
                    BackgroundColor3 = Color.Pure,
                    Size     = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(p0, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    ZIndex   = 17,
                }, track)
                corner(knob, UDim.new(1, 0))
                stroke(knob, accent, 2)

                local knobGlow = new("Frame", {
                    BackgroundColor3 = accent,
                    BackgroundTransparency = 0.72,
                    Size     = UDim2.new(0, 28, 0, 28),
                    Position = UDim2.new(p0, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    ZIndex   = 16,
                }, track)
                corner(knobGlow, UDim.new(1, 0))

                local dragging = false

                local function applyX(px)
                    local ax = track.AbsolutePosition.X
                    local as = track.AbsoluteSize.X
                    local rel = math.clamp((px - ax) / as, 0, 1)
                    cur = math.clamp(math.floor((mn + (mx - mn) * rel) / stp + 0.5) * stp, mn, mx)
                    local pct = (cur - mn) / (mx - mn)
                    fill.Size          = UDim2.new(pct, 0, 1, 0)
                    knob.Position      = UDim2.new(pct, 0, 0.5, 0)
                    knobGlow.Position  = UDim2.new(pct, 0, 0.5, 0)
                    vLbl.Text          = tostring(cur)
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
                    local pct = (cur - mn) / (mx - mn)
                    fill.Size = UDim2.new(pct, 0, 1, 0)
                    knob.Position = UDim2.new(pct, 0, 0.5, 0)
                    knobGlow.Position = UDim2.new(pct, 0, 0.5, 0)
                    vLbl.Text = tostring(cur)
                end
                function API:Get() return cur end
                return API
            end

            -- BUTTON ──────────────────────────────────────────────

            function Tab:CreateButton(opts)
                opts = opts or {}

                local row = new("Frame", {
                    BackgroundColor3 = Color.Surface,
                    Size     = UDim2.new(1, 0, 0, 44),
                    LayoutOrder = #page:GetChildren(),
                    ZIndex   = 13,
                }, page)
                corner(row, UDim.new(0, 9))
                hoverBind(row, Color.Surface, Color.Lift)

                new("TextLabel", {
                    BackgroundTransparency = 1,
                    Size     = UDim2.new(0.65, -14, 1, 0),
                    Position = UDim2.new(0, 14, 0, 0),
                    Font     = Enum.Font.GothamMedium,
                    Text     = opts.Name or "Button",
                    TextColor3 = Color.T1, TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex   = 14,
                }, row)

                local btn = new("TextButton", {
                    BackgroundColor3 = accent,
                    Size     = UDim2.new(0, 78, 0, 30),
                    Position = UDim2.new(1, -92, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Font     = Enum.Font.GothamBold,
                    Text     = opts.ButtonText or "Run",
                    TextColor3 = Color.Pure, TextSize = 12,
                    AutoButtonColor = false,
                    ZIndex   = 15,
                }, row)
                corner(btn, UDim.new(0, 9))

                -- Button glow frame
                local bGlow = new("Frame", {
                    BackgroundColor3 = accent,
                    BackgroundTransparency = 0.78,
                    Size     = UDim2.new(1, 12, 1, 12),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    ZIndex   = 14,
                }, btn)
                corner(bGlow, UDim.new(0, 11))

                btn.MouseEnter:Connect(function()
                    tw(btn,   { BackgroundColor3 = accentHi },         0.14)
                    tw(bGlow, { BackgroundTransparency = 0.6 },        0.14)
                end)
                btn.MouseLeave:Connect(function()
                    tw(btn,   { BackgroundColor3 = accent },           0.14)
                    tw(bGlow, { BackgroundTransparency = 0.78 },       0.14)
                end)
                btn.MouseButton1Click:Connect(function()
                    ripple(btn, accentHi)
                    if opts.Callback then opts.Callback() end
                end)
            end

            -- DROPDOWN ────────────────────────────────────────────

            function Tab:CreateDropdown(opts)
                opts = opts or {}
                local items   = opts.Items   or {}
                local current = opts.Default or (items[1] or "")
                local isOpen  = false

                local wrap = new("Frame", {
                    BackgroundColor3 = Color.Surface,
                    Size     = UDim2.new(1, 0, 0, 44),
                    ClipsDescendants = true,
                    LayoutOrder = #page:GetChildren(),
                    ZIndex   = 13,
                }, page)
                corner(wrap, UDim.new(0, 9))

                new("TextLabel", {
                    BackgroundTransparency = 1,
                    Size     = UDim2.new(0.45, -8, 0, 44),
                    Position = UDim2.new(0, 14, 0, 0),
                    Font     = Enum.Font.GothamMedium,
                    Text     = opts.Name or "Dropdown",
                    TextColor3 = Color.T1, TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex   = 14,
                }, wrap)

                local selBtn = new("TextButton", {
                    BackgroundColor3 = Color.Rise,
                    Size     = UDim2.new(0.5, -14, 0, 30),
                    Position = UDim2.new(0.5, 0, 0, 7),
                    Font     = Enum.Font.GothamMedium,
                    Text     = current .. "  v",
                    TextColor3 = Color.T2, TextSize = 12,
                    AutoButtonColor = false,
                    ZIndex   = 15,
                }, wrap)
                corner(selBtn, UDim.new(0, 7))

                local ibox = new("Frame", {
                    BackgroundTransparency = 1,
                    Size     = UDim2.new(1, -16, 0, 0),
                    Position = UDim2.new(0, 8, 0, 46),
                    ZIndex   = 15,
                }, wrap)
                listV(ibox, UDim.new(0, 3))

                local function buildItems()
                    for _, c in ipairs(ibox:GetChildren()) do
                        if c:IsA("TextButton") then c:Destroy() end
                    end
                    for i, item in ipairs(items) do
                        local ib = new("TextButton", {
                            BackgroundColor3 = Color.Lift,
                            BackgroundTransparency = 0.35,
                            Size     = UDim2.new(1, 0, 0, 30),
                            Font     = Enum.Font.GothamMedium,
                            Text     = item,
                            TextColor3 = item == current and accent or Color.T2,
                            TextSize = 12, AutoButtonColor = false,
                            LayoutOrder = i, ZIndex = 16,
                        }, ibox)
                        corner(ib, UDim.new(0, 7))
                        ib.MouseEnter:Connect(function() tw(ib, { BackgroundTransparency = 0, TextColor3 = Color.T1 }, 0.12) end)
                        ib.MouseLeave:Connect(function() tw(ib, { BackgroundTransparency = 0.35, TextColor3 = item == current and accent or Color.T2 }, 0.12) end)
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
                function API:Refresh(list, def)
                    items = list
                    if def then current = def; selBtn.Text = def .. "  v" end
                    buildItems()
                end
                function API:Get() return current end
                return API
            end

            -- INPUT ───────────────────────────────────────────────

            function Tab:CreateInput(opts)
                opts = opts or {}

                local row = new("Frame", {
                    BackgroundColor3 = Color.Surface,
                    Size     = UDim2.new(1, 0, 0, 44),
                    LayoutOrder = #page:GetChildren(),
                    ZIndex   = 13,
                }, page)
                corner(row, UDim.new(0, 9))
                hoverBind(row, Color.Surface, Color.Lift)

                new("TextLabel", {
                    BackgroundTransparency = 1,
                    Size     = UDim2.new(0.42, -8, 1, 0),
                    Position = UDim2.new(0, 14, 0, 0),
                    Font     = Enum.Font.GothamMedium,
                    Text     = opts.Name or "Input",
                    TextColor3 = Color.T1, TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex   = 14,
                }, row)

                local box = new("TextBox", {
                    BackgroundColor3  = Color.Rise,
                    Size     = UDim2.new(0.54, -14, 0, 30),
                    Position = UDim2.new(0.46, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Font     = Enum.Font.GothamMedium,
                    PlaceholderText  = opts.Placeholder or "Enter value...",
                    PlaceholderColor3 = Color.T3,
                    Text     = opts.Default or "",
                    TextColor3 = Color.T1, TextSize = 12,
                    ClearTextOnFocus = opts.ClearOnFocus or false,
                    ZIndex   = 15,
                }, row)
                corner(box, UDim.new(0, 7))
                new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, box)
                local bstk = stroke(box, Color.Edge, 1, 0.38)

                box.Focused:Connect(function()
                    tw(bstk, { Color = accent, Transparency = 0 }, 0.18)
                    tw(box,  { BackgroundColor3 = Color.Lift }, 0.18)
                end)
                box.FocusLost:Connect(function(enter)
                    tw(bstk, { Color = Color.Edge, Transparency = 0.38 }, 0.18)
                    tw(box,  { BackgroundColor3 = Color.Rise }, 0.18)
                    if opts.Callback then opts.Callback(box.Text, enter) end
                end)

                local API = {}
                function API:Set(v) box.Text = v end
                function API:Get() return box.Text end
                return API
            end

            -- KEYBIND ─────────────────────────────────────────────

            function Tab:CreateKeybind(opts)
                opts = opts or {}
                local key       = opts.Default or Enum.KeyCode.E
                local listening = false

                local row = new("Frame", {
                    BackgroundColor3 = Color.Surface,
                    Size     = UDim2.new(1, 0, 0, 44),
                    LayoutOrder = #page:GetChildren(),
                    ZIndex   = 13,
                }, page)
                corner(row, UDim.new(0, 9))
                hoverBind(row, Color.Surface, Color.Lift)

                new("TextLabel", {
                    BackgroundTransparency = 1,
                    Size     = UDim2.new(0.62, -14, 1, 0),
                    Position = UDim2.new(0, 14, 0, 0),
                    Font     = Enum.Font.GothamMedium,
                    Text     = opts.Name or "Keybind",
                    TextColor3 = Color.T1, TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex   = 14,
                }, row)

                local kbtn = new("TextButton", {
                    BackgroundColor3 = Color.Rise,
                    Size     = UDim2.new(0, 80, 0, 30),
                    Position = UDim2.new(1, -94, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Font     = Enum.Font.Code,
                    Text     = key.Name,
                    TextColor3 = accent, TextSize = 12,
                    AutoButtonColor = false,
                    ZIndex   = 15,
                }, row)
                corner(kbtn, UDim.new(0, 7))
                stroke(kbtn, Color.Edge, 1, 0.4)

                kbtn.MouseButton1Click:Connect(function()
                    listening = true; kbtn.Text = "..."
                    tw(kbtn, { BackgroundColor3 = accent }, 0.14)
                    kbtn.TextColor3 = Color.Pure
                end)

                UserInputService.InputBegan:Connect(function(i)
                    if listening and i.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false; key = i.KeyCode; kbtn.Text = key.Name
                        tw(kbtn, { BackgroundColor3 = Color.Rise }, 0.14)
                        kbtn.TextColor3 = accent
                        if opts.Callback then opts.Callback(key) end
                    end
                end)

                local API = {}
                function API:Set(k) key = k; kbtn.Text = k.Name end
                function API:Get() return key end
                return API
            end

            -- LABEL ───────────────────────────────────────────────

            function Tab:CreateLabel(opts)
                opts = opts or {}

                local row = new("Frame", {
                    BackgroundColor3       = Color.Surface,
                    BackgroundTransparency = 0.42,
                    Size     = UDim2.new(1, 0, 0, 34),
                    LayoutOrder = #page:GetChildren(),
                    ZIndex   = 13,
                }, page)
                corner(row, UDim.new(0, 9))

                local dot = new("Frame", {
                    BackgroundColor3 = accent,
                    Size     = UDim2.new(0, 5, 0, 5),
                    Position = UDim2.new(0, 13, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    ZIndex   = 14,
                }, row)
                corner(dot, UDim.new(1, 0))

                local lbl = new("TextLabel", {
                    BackgroundTransparency = 1,
                    Size     = UDim2.new(1, -30, 1, 0),
                    Position = UDim2.new(0, 28, 0, 0),
                    Font     = Enum.Font.GothamMedium,
                    Text     = opts.Text or "Label",
                    TextColor3 = Color.T2, TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex   = 14,
                }, row)

                local API = {}
                function API:Set(v) lbl.Text = v end
                function API:Get() return lbl.Text end
                return API
            end

            -- COLOR SWATCH ────────────────────────────────────────

            function Tab:CreateColorPicker(opts)
                opts = opts or {}
                local color = opts.Default or Color3.new(1, 1, 1)

                local row = new("Frame", {
                    BackgroundColor3 = Color.Surface,
                    Size     = UDim2.new(1, 0, 0, 44),
                    LayoutOrder = #page:GetChildren(),
                    ZIndex   = 13,
                }, page)
                corner(row, UDim.new(0, 9))
                hoverBind(row, Color.Surface, Color.Lift)

                new("TextLabel", {
                    BackgroundTransparency = 1,
                    Size     = UDim2.new(0.65, -14, 1, 0),
                    Position = UDim2.new(0, 14, 0, 0),
                    Font     = Enum.Font.GothamMedium,
                    Text     = opts.Name or "Color",
                    TextColor3 = Color.T1, TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex   = 14,
                }, row)

                local swatch = new("Frame", {
                    BackgroundColor3 = color,
                    Size     = UDim2.new(0, 32, 0, 32),
                    Position = UDim2.new(1, -46, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    ZIndex   = 15,
                }, row)
                corner(swatch, UDim.new(0, 8))
                stroke(swatch, Color.Edge, 1)

                local API = {}
                function API:Set(c)
                    color = c; swatch.BackgroundColor3 = c
                    if opts.Callback then opts.Callback(c) end
                end
                function API:Get() return color end
                return API
            end

            return Tab
        end

        -- ── CONFIG API ───────────────────────────────────────────

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
            Notify({ Title = "Config Saved", Content = (name or WCfg.ConfigName) .. ".json", Type = "Success", Duration = 3 })
            return out
        end

        function Window:LoadConfig(name, data)
            if type(data) == "table" then
                for k, v in pairs(data) do State.Data[k] = v end
                Notify({ Title = "Config Loaded", Content = "Loaded " .. (name or "config"), Type = "Info", Duration = 3 })
            else
                pcall(function()
                    if readfile and isfile then
                        local p = (name or WCfg.ConfigName) .. ".json"
                        if isfile(p) then
                            local t = HttpService:JSONDecode(readfile(p))
                            for k, v in pairs(t) do State.Data[k] = v end
                            Notify({ Title = "Config Loaded", Content = p .. " loaded.", Type = "Info", Duration = 3 })
                        end
                    end
                end)
            end
        end

        function Window:Destroy()
            twBack(Win, { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }, 0.38, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            twSine(winGlow, { ImageTransparency = 1 }, 0.3)
            task.delay(0.42, function() Gui:Destroy() end)
        end

        -- Startup notification
        task.delay(0.25, function()
            Notify({ Title = "UpFor Ready", Content = WCfg.Title .. "  |  " .. WCfg.Subtitle, Type = "Success", Duration = 4 })
        end)
    end -- buildWindow()

    -- Run boot sequence then build the window
    task.spawn(bootSequence, Gui, buildWindow)

    return Window
end

return UpFor
