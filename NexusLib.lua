--[[
╔══════════════════════════════════════════════════════════════════════╗
║                                                                      ║
║                     N E X U S   L I B                                ║
║              Roblox Luau Premium UI Framework                        ║
║                                                                      ║
║   Style     :  Glassmorphism / Fluent                                ║
║   Version   :  2.0.0                                                 ║
║   Build     :  2026.06.21                                            ║
║                                                                      ║
║   FEATURES                                                           ║
║     Layered Glassmorphism window (sheen + edge + base)               ║
║     Compact Mode  →  floating draggable pill                         ║
║     Command Palette  (Ctrl + Shift + P)  searchable commands         ║
║     Animated neon top border                                         ║
║     8 element types + Section dividers                               ║
║     Tab sidebar + animated indicator                                 ║
║     Toast notification (4 types)                                     ║
║     Config  JSON  save / load                                        ║
║     Draggable  |  Keybind toggle  |  Min/Max/Close                   ║
║     Zero RunService idle loops                                       ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
--]]

-- ════════════════════════════════════════════════════════════════════
--  SERVICES
-- ════════════════════════════════════════════════════════════════════

local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local HttpService       = game:GetService("HttpService")
local Players           = game:GetService("Players")

local LP = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════════════
--  STRICT TWEEN ENGINE
--  TweenInfo.new(Time, EasingStyle, EasingDirection, RepeatCount, Reverses, DelayTime)
--  arg3 MUST be Enum.EasingDirection — never pass EasingStyle there
-- ════════════════════════════════════════════════════════════════════

local EStyle = Enum.EasingStyle
local EDir   = Enum.EasingDirection

local function Tw(obj, props, t, style, dir)
    local info = TweenInfo.new(
        t     or 0.22,
        style or EStyle.Quint,
        dir   or EDir.Out
    )
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

-- Named shortcuts — all directions explicit, no ambiguity
local function TwQuint(obj, p, t)     return Tw(obj, p, t, EStyle.Quint, EDir.Out)  end
local function TwSine(obj, p, t)      return Tw(obj, p, t, EStyle.Sine,  EDir.Out)  end
local function TwLinear(obj, p, t)    return Tw(obj, p, t, EStyle.Linear,EDir.Out)  end
local function TwBack(obj, p, t)      return Tw(obj, p, t, EStyle.Back,  EDir.Out)  end
local function TwBackIn(obj, p, t)    return Tw(obj, p, t, EStyle.Back,  EDir.In)   end
local function TwSpring(obj, p, t)    return Tw(obj, p, t, EStyle.Spring,EDir.Out)  end
local function TwElastic(obj, p, t)   return Tw(obj, p, t, EStyle.Elastic,EDir.Out) end

-- ════════════════════════════════════════════════════════════════════
--  DESIGN TOKENS
-- ════════════════════════════════════════════════════════════════════

local G = {
    -- Glass base layers (dark, desaturated blue)
    Base      = Color3.fromRGB(8,   8,  18),
    Plate     = Color3.fromRGB(12,  12, 26),
    Panel     = Color3.fromRGB(16,  16, 34),
    Surface   = Color3.fromRGB(21,  21, 44),
    Lift      = Color3.fromRGB(27,  27, 55),
    Rise      = Color3.fromRGB(34,  34, 68),

    -- Accent — electric indigo
    A1        = Color3.fromRGB(100, 90, 248),
    A2        = Color3.fromRGB(132,122, 255),
    A3        = Color3.fromRGB(70,  62, 200),

    -- Cyan secondary
    Cy        = Color3.fromRGB(50,  205, 255),
    CyDim     = Color3.fromRGB(30,  150, 210),

    -- Text hierarchy
    TxtHi     = Color3.fromRGB(230, 230, 248),
    TxtMd     = Color3.fromRGB(138, 138, 178),
    TxtLo     = Color3.fromRGB(64,  64, 106),
    TxtGhost  = Color3.fromRGB(38,  38,  72),

    -- Glass edges
    EdgeHi    = Color3.fromRGB(255, 255, 255),   -- white sheen
    EdgeMd    = Color3.fromRGB(55,  55,  98),    -- standard
    EdgeLo    = Color3.fromRGB(28,  28,  58),    -- divider

    -- Status
    Green     = Color3.fromRGB(46,  213, 115),
    Yellow    = Color3.fromRGB(255, 196,  55),
    Red       = Color3.fromRGB(232,  60,  72),
    Blue      = Color3.fromRGB(50,  190, 255),

    -- Primitives
    White     = Color3.new(1, 1, 1),
    Black     = Color3.new(0, 0, 0),
}

-- ════════════════════════════════════════════════════════════════════
--  INSTANCE HELPERS
-- ════════════════════════════════════════════════════════════════════

local function N(class, props, parent)
    local o = Instance.new(class)
    if props  then for k, v in pairs(props) do o[k] = v end end
    if parent then o.Parent = parent end
    return o
end

local function Corner(o, r)
    return N("UICorner", { CornerRadius = r or UDim.new(0, 8) }, o)
end

local function Stroke(o, col, thick, transp)
    return N("UIStroke", {
        Color        = col   or G.EdgeMd,
        Thickness    = thick or 1,
        Transparency = transp or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, o)
end

local function Grad(o, cs, ts, rot)
    return N("UIGradient", {
        Color        = cs  or ColorSequence.new(G.A1, G.Cy),
        Transparency = ts  or NumberSequence.new(0),
        Rotation     = rot or 0,
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

local function ListH(o, gap, ha, va)
    return N("UIListLayout", {
        FillDirection       = Enum.FillDirection.Horizontal,
        Padding             = gap or UDim.new(0, 6),
        SortOrder           = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = ha or Enum.HorizontalAlignment.Left,
        VerticalAlignment   = va or Enum.VerticalAlignment.Center,
    }, o)
end

local function ListV(o, gap)
    return N("UIListLayout", {
        FillDirection       = Enum.FillDirection.Vertical,
        Padding             = gap or UDim.new(0, 6),
        SortOrder           = Enum.SortOrder.LayoutOrder,
        VerticalAlignment   = Enum.VerticalAlignment.Top,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    }, o)
end

local function Shadow(o, transp)
    return N("ImageLabel", {
        Name              = "_Shadow",
        BackgroundTransparency = 1,
        Image             = "rbxassetid://6014261993",
        ImageColor3       = G.Black,
        ImageTransparency = transp or 0.44,
        Size              = UDim2.new(1, 50, 1, 50),
        Position          = UDim2.new(0, -25, 0, -25),
        ZIndex            = o.ZIndex - 1,
        ScaleType         = Enum.ScaleType.Slice,
        SliceCenter       = Rect.new(49, 49, 450, 450),
    }, o)
end

-- Ripple from actual cursor position
local function Ripple(btn, col)
    local mp  = UserInputService:GetMouseLocation()
    local rel = mp - Vector2.new(btn.AbsolutePosition.X, btn.AbsolutePosition.Y)
    local r = N("Frame", {
        BackgroundColor3       = col or G.A2,
        BackgroundTransparency = 0.58,
        Size     = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, rel.X, 0, rel.Y),
        AnchorPoint            = Vector2.new(0.5, 0.5),
        ZIndex   = btn.ZIndex + 30,
    }, btn)
    Corner(r, UDim.new(1, 0))
    TwSine(r, { Size = UDim2.new(3.5, 0, 3.5, 0), BackgroundTransparency = 1 }, 0.55)
    task.delay(0.6, function()
        if r and r.Parent then r:Destroy() end
    end)
end

local function HoverRow(f, norm, hov)
    f.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then
            TwQuint(f, { BackgroundColor3 = hov, BackgroundTransparency = 0.04 }, 0.13)
        end
    end)
    f.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then
            TwQuint(f, { BackgroundColor3 = norm, BackgroundTransparency = 0.08 }, 0.13)
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════
--  GLASS COMPOSITE  —  core visual primitive
--  Creates: base frame + top-sheen gradient + edge stroke
-- ════════════════════════════════════════════════════════════════════

local function GlassFrame(parent, size, pos, zi, radius, col, transp)
    local f = N("Frame", {
        BackgroundColor3       = col    or G.Panel,
        BackgroundTransparency = transp or 0.08,
        Size     = size or UDim2.new(1, 0, 1, 0),
        Position = pos  or UDim2.new(0, 0, 0, 0),
        ZIndex   = zi   or 10,
        ClipsDescendants = false,
    }, parent)
    local rad = radius or 10
    Corner(f, UDim.new(0, rad))

    -- Top sheen — simulates frosted glass highlight
    local sheen = N("Frame", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 0.48, 0),
        ZIndex = zi and zi + 1 or 11,
    }, f)
    Corner(sheen, UDim.new(0, rad))
    Grad(sheen,
        ColorSequence.new(G.White, G.White),
        NumberSequence.new({
            NumberSequenceKeypoint.new(0,   0.88),
            NumberSequenceKeypoint.new(0.65, 0.97),
            NumberSequenceKeypoint.new(1,   1.0),
        }), 180
    )

    -- Edge highlight — white, very transparent
    local edge = Stroke(f, G.EdgeHi, 1, 0.74)

    return f, sheen, edge
end

-- ════════════════════════════════════════════════════════════════════
--  ANIMATED NEON TOP LINE
-- ════════════════════════════════════════════════════════════════════

local function NeonLine(parent, col1, col2)
    local line = N("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(1, 0, 0, 2),
        BorderSizePixel = 0,
        ZIndex   = parent.ZIndex + 5,
    }, parent)

    local g = Grad(line,
        ColorSequence.new({
            ColorSequenceKeypoint.new(0,    col1),
            ColorSequenceKeypoint.new(0.38, col2),
            ColorSequenceKeypoint.new(0.62, col1),
            ColorSequenceKeypoint.new(1,    col2),
        }),
        NumberSequence.new({
            NumberSequenceKeypoint.new(0,   0.78),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1,   0.78),
        })
    )
    g.Offset = Vector2.new(-1, 0)

    local alive = true
    task.spawn(function()
        while alive and line and line.Parent do
            TwLinear(g, { Offset = Vector2.new(1, 0) }, 3.2)
            task.wait(3.2)
            g.Offset = Vector2.new(-1, 0)
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════
--  NEXUS LIBRARY
-- ════════════════════════════════════════════════════════════════════

local NexusLib = {}
NexusLib.__index = NexusLib

function NexusLib:CreateWindow(cfg)
    cfg = cfg or {}

    local accent   = cfg.Accent    or G.A1
    local accentHi = cfg.AccentHi  or G.A2
    local accentCy = cfg.AccentCy  or G.Cy

    local WCfg = {
        Title       = cfg.Title      or "Nexus",
        Subtitle    = cfg.Subtitle   or "Hub",
        LogoText    = cfg.LogoText   or "NX",
        Size        = cfg.Size       or UDim2.new(0, 650, 0, 465),
        ToggleKey   = cfg.ToggleKey  or Enum.KeyCode.RightShift,
        ConfigName  = cfg.ConfigName or "NexusConfig",
        PaletteKey  = cfg.PaletteKey or Enum.KeyCode.P,
    }

    -- ── Internal state ────────────────────────────────────────────

    local S = {
        Minimized   = false,
        Maximized   = false,
        Compact     = false,
        PaletteOpen = false,
        Dragging    = false,
        DragOrigin  = nil,
        DragPos     = nil,
        ActiveTab   = nil,
        Tabs        = {},
        Data        = {},
        Commands    = {},
    }

    -- ── ScreenGui ─────────────────────────────────────────────────

    local Gui = N("ScreenGui", {
        Name           = "NexusLib",
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder   = 999,
        IgnoreGuiInset = true,
    }, LP:WaitForChild("PlayerGui"))

    -- ════════════════════════════════════════════════════════════
    --  NOTIFICATION SYSTEM  (defined early — used everywhere)
    -- ════════════════════════════════════════════════════════════

    local NotifHolder = N("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(0, 325, 1, -20),
        Position = UDim2.new(1, -337, 0, 10),
        ZIndex   = 400,
    }, Gui)
    N("UIListLayout", {
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        SortOrder         = Enum.SortOrder.LayoutOrder,
        Padding           = UDim.new(0, 8),
    }, NotifHolder)

    local notifCount = 0

    local function Notify(opts)
        opts = opts or {}
        notifCount += 1

        local colorMap = {
            Success = G.Green,
            Warning = G.Yellow,
            Error   = G.Red,
            Info    = G.Blue,
        }
        local ac = colorMap[opts.Type] or accent

        -- Glass notification card
        local card, _, _ = GlassFrame(NotifHolder, UDim2.new(1, 0, 0, 74), nil, 401, 11, G.Surface, 0.06)
        card.LayoutOrder = notifCount
        Stroke(card, ac, 1, 0.52)

        -- Accent left bar
        local bar = N("Frame", {
            BackgroundColor3 = ac,
            Size     = UDim2.new(0, 3, 0.56, 0),
            Position = UDim2.new(0, 9, 0.22, 0),
            ZIndex   = 402,
        }, card)
        Corner(bar, UDim.new(1, 0))

        N("TextLabel", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(1, -32, 0, 20),
            Position = UDim2.new(0, 24, 0, 12),
            Font     = Enum.Font.GothamBold,
            Text     = opts.Title or "Notice",
            TextColor3 = G.TxtHi, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex   = 402,
        }, card)

        N("TextLabel", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(1, -32, 0, 28),
            Position = UDim2.new(0, 24, 0, 34),
            Font     = Enum.Font.GothamMedium,
            Text     = opts.Content or "",
            TextColor3 = G.TxtMd, TextSize = 11,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex   = 402,
        }, card)

        -- Slide in from right
        card.Position = UDim2.new(1, 40, 0, 0)
        card.BackgroundTransparency = 0.55
        TwBack(card, { Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0.06 }, 0.38)

        task.delay(opts.Duration or 4, function()
            TwQuint(card, { Position = UDim2.new(1, 40, 0, 0), BackgroundTransparency = 1 }, 0.32)
            task.delay(0.36, function()
                if card and card.Parent then card:Destroy() end
            end)
        end)
    end

    -- ════════════════════════════════════════════════════════════
    --  MAIN WINDOW
    -- ════════════════════════════════════════════════════════════

    local Win = N("Frame", {
        Name             = "Window",
        BackgroundColor3 = G.Base,
        BackgroundTransparency = 0.06,
        Size     = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint      = Vector2.new(0.5, 0.5),
        ClipsDescendants = true,
        ZIndex           = 10,
    }, Gui)
    Corner(Win, UDim.new(0, 14))

    -- Glass edge on window
    local winEdge = Stroke(Win, G.EdgeHi, 1, 0.72)

    Shadow(Win, 0.4)

    -- Window glass sheen (top)
    local winSheen = N("Frame", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 0.32, 0),
        ZIndex = 11,
    }, Win)
    Corner(winSheen, UDim.new(0, 14))
    Grad(winSheen,
        ColorSequence.new(G.White, G.White),
        NumberSequence.new({
            NumberSequenceKeypoint.new(0,   0.92),
            NumberSequenceKeypoint.new(0.7, 0.98),
            NumberSequenceKeypoint.new(1,   1.0),
        }), 180
    )

    NeonLine(Win, accent, accentCy)

    -- Window open animation
    TwBack(Win, {
        Size = WCfg.Size,
        BackgroundTransparency = 0.06,
    }, 0.65)

    -- ── Title Bar ─────────────────────────────────────────────────

    local TBar = N("Frame", {
        BackgroundColor3       = G.Plate,
        BackgroundTransparency = 0.12,
        Size     = UDim2.new(1, 0, 0, 56),
        Position = UDim2.new(0, 0, 0, 2),
        ZIndex   = 12,
    }, Win)

    -- TBar sheen
    local tbSheen = N("Frame", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 1, 0),
        ZIndex = 13,
    }, TBar)
    Grad(tbSheen,
        ColorSequence.new(G.White, G.White),
        NumberSequence.new({
            NumberSequenceKeypoint.new(0,   0.9),
            NumberSequenceKeypoint.new(0.6, 0.97),
            NumberSequenceKeypoint.new(1,   1.0),
        }), 180
    )

    -- TBar bottom divider
    N("Frame", {
        BackgroundColor3 = G.White,
        BackgroundTransparency = 0.88,
        Size     = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        ZIndex   = 13,
    }, TBar)

    -- ── Logo badge ────────────────────────────────────────────────

    local badge = N("Frame", {
        BackgroundColor3 = accent,
        Size     = UDim2.new(0, 35, 0, 35),
        Position = UDim2.new(0, 14, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex   = 14,
    }, TBar)
    Corner(badge, UDim.new(0, 8))

    -- Badge sheen
    local bSheen = N("Frame", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 0.52, 0),
        ZIndex = 15,
    }, badge)
    Corner(bSheen, UDim.new(0, 8))
    Grad(bSheen, ColorSequence.new(G.White, G.White),
        NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.72), NumberSequenceKeypoint.new(1, 1) }), 180)

    -- Badge pulse ring
    local bPulse = N("Frame", {
        BackgroundColor3 = accent,
        BackgroundTransparency = 0.78,
        Size     = UDim2.new(1, 6, 1, 6),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex   = 13,
    }, badge)
    Corner(bPulse, UDim.new(0, 10))

    N("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = WCfg.LogoText,
        TextColor3 = G.White, TextSize = 16,
        ZIndex = 16,
    }, badge)

    task.spawn(function()
        while badge and badge.Parent do
            TwSpring(bPulse, { Size = UDim2.new(1, 14, 1, 14), BackgroundTransparency = 0.52 }, 2.2)
            task.wait(2.2)
            TwSpring(bPulse, { Size = UDim2.new(1, 6, 1, 6),  BackgroundTransparency = 0.78 }, 2.2)
            task.wait(2.2)
        end
    end)

    N("TextLabel", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(0.45, -62, 0, 20),
        Position = UDim2.new(0, 61, 0, 8),
        Font     = Enum.Font.GothamBold,
        Text     = WCfg.Title,
        TextColor3 = G.TxtHi, TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex   = 14,
    }, TBar)

    N("TextLabel", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(0.45, -62, 0, 14),
        Position = UDim2.new(0, 61, 0, 32),
        Font     = Enum.Font.GothamMedium,
        Text     = WCfg.Subtitle,
        TextColor3 = G.TxtGhost, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex   = 14,
    }, TBar)

    -- ── Control buttons  [•]  [−]  [+]  [×] ─────────────────────

    local CtrlWrap = N("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(0, 168, 0, 38),
        Position = UDim2.new(1, -178, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex   = 14,
    }, TBar)
    ListH(CtrlWrap, UDim.new(0, 6))

    local function MakeCtrlBtn(label, hoverColor, order, callback)
        local btn = N("TextButton", {
            Name             = label,
            BackgroundColor3 = G.Rise,
            BackgroundTransparency = 0.18,
            Size             = UDim2.new(0, 36, 0, 36),
            Font             = Enum.Font.GothamBold,
            Text             = label,
            TextColor3       = G.TxtMd,
            TextSize         = 15,
            AutoButtonColor  = false,
            LayoutOrder      = order,
            ZIndex           = 15,
        }, CtrlWrap)
        Corner(btn, UDim.new(0, 9))
        Stroke(btn, G.EdgeHi, 1, 0.82)

        -- Button glass sheen
        local bsh = N("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0.5, 0), ZIndex = 16,
        }, btn)
        Corner(bsh, UDim.new(0, 9))
        Grad(bsh, ColorSequence.new(G.White, G.White),
            NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.78), NumberSequenceKeypoint.new(1, 1) }), 180)

        btn.MouseEnter:Connect(function()
            TwQuint(btn, { BackgroundColor3 = hoverColor, BackgroundTransparency = 0, TextColor3 = G.White }, 0.14)
        end)
        btn.MouseLeave:Connect(function()
            TwQuint(btn, { BackgroundColor3 = G.Rise, BackgroundTransparency = 0.18, TextColor3 = G.TxtMd }, 0.14)
        end)
        btn.MouseButton1Click:Connect(function()
            Ripple(btn, hoverColor)
            if callback then callback() end
        end)

        return btn
    end

    -- Compact
    MakeCtrlBtn("·", accent, 1, function()
        S.Compact = true
        TwBackIn(Win, { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }, 0.38)
        task.delay(0.42, function()
            if S.Compact then
                Win.Visible = false
                CompactPill.Visible = true
            end
        end)
    end)

    -- Minimize
    MakeCtrlBtn("−", G.Yellow, 2, function()
        S.Minimized = not S.Minimized
        if S.Minimized then
            TwBackIn(Win, { Size = UDim2.new(0, WCfg.Size.X.Offset, 0, 56) }, 0.3)
        else
            local target = S.Maximized and UDim2.new(1, -40, 1, -40) or WCfg.Size
            TwBack(Win, { Size = target }, 0.3)
        end
    end)

    -- Maximize
    MakeCtrlBtn("+", G.Green, 3, function()
        S.Minimized = false
        S.Maximized = not S.Maximized
        if S.Maximized then
            TwBack(Win, { Size = UDim2.new(1, -40, 1, -40), Position = UDim2.new(0.5, 0, 0.5, 0) }, 0.3)
        else
            TwBack(Win, { Size = WCfg.Size, Position = UDim2.new(0.5, 0, 0.5, 0) }, 0.3)
        end
    end)

    -- Close
    MakeCtrlBtn("×", G.Red, 4, function()
        TwBackIn(Win, { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }, 0.38)
        task.delay(0.42, function() Gui:Destroy() end)
    end)

    -- ── Drag ──────────────────────────────────────────────────────

    TBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            S.Dragging   = true
            S.DragOrigin = i.Position
            S.DragPos    = Win.Position
        end
    end)
    TBar.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            S.Dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if S.Dragging
        and (i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - S.DragOrigin
            Win.Position = UDim2.new(
                S.DragPos.X.Scale, S.DragPos.X.Offset + d.X,
                S.DragPos.Y.Scale, S.DragPos.Y.Offset + d.Y
            )
        end
    end)

    -- Toggle visibility
    UserInputService.InputBegan:Connect(function(i, gpe)
        if not gpe and i.KeyCode == WCfg.ToggleKey and not S.Compact then
            Win.Visible = not Win.Visible
        end
    end)

    -- ════════════════════════════════════════════════════════════
    --  COMPACT PILL
    -- ════════════════════════════════════════════════════════════

    local CompactPill = N("TextButton", {
        BackgroundColor3       = G.Panel,
        BackgroundTransparency = 0.07,
        Size     = UDim2.new(0, 128, 0, 36),
        Position = UDim2.new(0, 20, 0, 20),
        Font     = Enum.Font.GothamBold,
        Text     = "",
        AutoButtonColor = false,
        Visible  = false,
        ZIndex   = 60,
    }, Gui)
    Corner(CompactPill, UDim.new(1, 0))
    Stroke(CompactPill, G.EdgeHi, 1, 0.70)
    Shadow(CompactPill, 0.52)

    -- Pill sheen
    local pillSheen = N("Frame", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 0.5, 0),
        ZIndex = 61,
    }, CompactPill)
    Corner(pillSheen, UDim.new(1, 0))
    Grad(pillSheen, ColorSequence.new(G.White, G.White),
        NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.85), NumberSequenceKeypoint.new(1, 1) }), 180)

    -- Pill accent bar
    local pillBar = N("Frame", {
        BackgroundColor3 = accent,
        Size     = UDim2.new(0, 3, 0.52, 0),
        Position = UDim2.new(0, 10, 0.24, 0),
        ZIndex   = 62,
    }, CompactPill)
    Corner(pillBar, UDim.new(1, 0))

    N("TextLabel", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(1, -28, 1, 0),
        Position = UDim2.new(0, 22, 0, 0),
        Font     = Enum.Font.GothamBold,
        Text     = WCfg.Title,
        TextColor3 = G.TxtHi, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex   = 62,
    }, CompactPill)

    -- Pill drag
    local pillDrag = false
    local pillOrigin, pillPos

    CompactPill.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            pillDrag = true
            pillOrigin = i.Position
            pillPos    = CompactPill.Position
        end
    end)
    CompactPill.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            pillDrag = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if pillDrag
        and (i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - pillOrigin
            CompactPill.Position = UDim2.new(
                pillPos.X.Scale, pillPos.X.Offset + d.X,
                pillPos.Y.Scale, pillPos.Y.Offset + d.Y
            )
        end
    end)

    CompactPill.MouseButton1Click:Connect(function()
        S.Compact = false
        CompactPill.Visible = false
        Win.Visible = true
        Win.Size = UDim2.new(0, 0, 0, 0)
        Win.BackgroundTransparency = 1
        TwBack(Win, { Size = WCfg.Size, BackgroundTransparency = 0.06 }, 0.5)
    end)

    -- ════════════════════════════════════════════════════════════
    --  BODY
    -- ════════════════════════════════════════════════════════════

    local Body = N("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(1, 0, 1, -58),
        Position = UDim2.new(0, 0, 0, 58),
        ZIndex   = 11,
    }, Win)

    -- ── Sidebar ───────────────────────────────────────────────────

    local Sidebar = N("Frame", {
        BackgroundColor3       = G.Plate,
        BackgroundTransparency = 0.1,
        Size     = UDim2.new(0, 166, 1, 0),
        ZIndex   = 11,
    }, Body)

    -- Sidebar sheen
    local sideSheen = N("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0.42, 0), ZIndex = 12,
    }, Sidebar)
    Grad(sideSheen, ColorSequence.new(G.White, G.White),
        NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.93), NumberSequenceKeypoint.new(1, 1) }), 180)

    N("Frame", {
        BackgroundColor3 = G.White, BackgroundTransparency = 0.87,
        Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, 0, 0, 0), ZIndex = 12,
    }, Sidebar)

    local SideScroll = N("ScrollingFrame", {
        BackgroundTransparency  = 1,
        Size     = UDim2.new(1, -10, 1, -16),
        Position = UDim2.new(0, 5, 0, 8),
        CanvasSize           = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize  = Enum.AutomaticSize.Y,
        ScrollBarThickness   = 2,
        ScrollBarImageColor3 = G.TxtGhost,
        BorderSizePixel      = 0,
        ZIndex               = 12,
    }, Sidebar)
    ListV(SideScroll, UDim.new(0, 4))

    -- ── Content ───────────────────────────────────────────────────

    local ContentWrap = N("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(1, -168, 1, 0),
        Position = UDim2.new(0, 168, 0, 0),
        ClipsDescendants = true,
        ZIndex   = 11,
    }, Body)

    -- ════════════════════════════════════════════════════════════
    --  COMMAND PALETTE  (Ctrl + Shift + P)
    -- ════════════════════════════════════════════════════════════

    local Palette = N("Frame", {
        BackgroundColor3       = G.Base,
        BackgroundTransparency = 0.05,
        Size     = UDim2.new(0, 450, 0, 54),
        Position = UDim2.new(0.5, 0, 0, -120),
        AnchorPoint            = Vector2.new(0.5, 0),
        ClipsDescendants       = true,
        Visible  = false,
        ZIndex   = 200,
    }, Gui)
    Corner(Palette, UDim.new(0, 13))
    Stroke(Palette, G.EdgeHi, 1, 0.64)
    Shadow(Palette, 0.36)
    NeonLine(Palette, accent, accentCy)

    -- Palette glass sheen
    local palSheen = N("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0.45, 0), ZIndex = 201,
    }, Palette)
    Corner(palSheen, UDim.new(0, 13))
    Grad(palSheen, ColorSequence.new(G.White, G.White),
        NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.9), NumberSequenceKeypoint.new(1, 1) }), 180)

    -- Search icon
    N("TextLabel", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(0, 42, 0, 54),
        Font     = Enum.Font.GothamBold,
        Text     = ">_",
        TextColor3 = accent, TextSize = 14, ZIndex = 202,
    }, Palette)

    -- Input box
    local PaletteBox = N("TextBox", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(1, 0, 0, 54),
        Font     = Enum.Font.GothamMedium,
        PlaceholderText   = "Search commands...",
        PlaceholderColor3 = G.TxtGhost,
        Text     = "",
        TextColor3 = G.TxtHi, TextSize = 14,
        ClearTextOnFocus  = true,
        TextXAlignment    = Enum.TextXAlignment.Left,
        ZIndex   = 203,
    }, Palette)
    Pad(PaletteBox, 0, 16, 0, 46)

    -- Results container
    local PalResults = N("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 56),
        ZIndex   = 202,
    }, Palette)
    ListV(PalResults, UDim.new(0, 2))

    local ITEM_H = 36

    local function RebuildPalette(query)
        for _, c in ipairs(PalResults:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end

        local hits = {}
        local q = string.lower(query or "")
        for _, cmd in ipairs(S.Commands) do
            if q == "" or string.find(string.lower(cmd.Name), q, 1, true) then
                table.insert(hits, cmd)
            end
        end

        local count      = math.min(#hits, 6)
        local listHeight = count > 0 and (count * (ITEM_H + 2) + 8) or 0
        local totalH     = 56 + listHeight
        TwQuint(Palette, { Size = UDim2.new(0, 450, 0, totalH) }, 0.18)

        for i = 1, count do
            local cmd = hits[i]
            local item = N("TextButton", {
                BackgroundColor3       = G.Surface,
                BackgroundTransparency = 0.1,
                Size     = UDim2.new(1, -16, 0, ITEM_H),
                Text     = "",
                AutoButtonColor = false,
                LayoutOrder = i,
                ZIndex   = 204,
            }, PalResults)
            Corner(item, UDim.new(0, 7))

            N("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0.72, -10, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                Font     = Enum.Font.GothamMedium,
                Text     = cmd.Name,
                TextColor3 = G.TxtHi, TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 205,
            }, item)

            if cmd.Tag then
                local tag = N("TextLabel", {
                    BackgroundColor3 = accent,
                    BackgroundTransparency = 0.68,
                    Size     = UDim2.new(0, 0, 0, 20),
                    Position = UDim2.new(1, -10, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5),
                    Font     = Enum.Font.Code,
                    Text     = cmd.Tag,
                    TextColor3 = accentHi, TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    AutomaticSize  = Enum.AutomaticSize.X,
                    ZIndex   = 205,
                }, item)
                Corner(tag, UDim.new(0, 5))
                Pad(tag, 0, 8, 0, 8)
            end

            item.MouseEnter:Connect(function()
                TwQuint(item, { BackgroundColor3 = G.Lift, BackgroundTransparency = 0 }, 0.12)
            end)
            item.MouseLeave:Connect(function()
                TwQuint(item, { BackgroundColor3 = G.Surface, BackgroundTransparency = 0.1 }, 0.12)
            end)
            item.MouseButton1Click:Connect(function()
                Ripple(item, accent)
                task.delay(0.1, function()
                    if cmd.Action then cmd.Action() end
                    S.PaletteOpen = false
                    PaletteBox.Text = ""
                    TwSine(Palette, { Position = UDim2.new(0.5, 0, 0, -220) }, 0.28)
                    task.delay(0.32, function() Palette.Visible = false end)
                end)
            end)
        end
    end

    PaletteBox:GetPropertyChangedSignal("Text"):Connect(function()
        RebuildPalette(PaletteBox.Text)
    end)

    local function TogglePalette()
        S.PaletteOpen = not S.PaletteOpen
        if S.PaletteOpen then
            Palette.Visible  = true
            Palette.Size     = UDim2.new(0, 450, 0, 54)
            PaletteBox.Text  = ""
            RebuildPalette("")
            Palette.Position = UDim2.new(0.5, 0, 0, -120)
            TwBack(Palette, { Position = UDim2.new(0.5, 0, 0, 40) }, 0.44)
            task.delay(0.12, function() PaletteBox:CaptureFocus() end)
        else
            TwSine(Palette, { Position = UDim2.new(0.5, 0, 0, -220) }, 0.28)
            task.delay(0.32, function() Palette.Visible = false end)
        end
    end

    UserInputService.InputBegan:Connect(function(i, gpe)
        if gpe then return end

        local ctrl  = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
                   or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
        local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
                   or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)

        if ctrl and shift and i.KeyCode == WCfg.PaletteKey then
            TogglePalette()
        end

        if i.KeyCode == Enum.KeyCode.Escape and S.PaletteOpen then
            S.PaletteOpen = false
            TwSine(Palette, { Position = UDim2.new(0.5, 0, 0, -220) }, 0.28)
            task.delay(0.32, function() Palette.Visible = false end)
        end
    end)

    -- ════════════════════════════════════════════════════════════
    --  WINDOW API
    -- ════════════════════════════════════════════════════════════

    local Window = { Notify = Notify }

    function Window:RegisterCommand(name, tag, action)
        table.insert(S.Commands, { Name = name, Tag = tag, Action = action })
    end

    -- ════════════════════════════════════════════════════════════
    --  TAB BUILDER
    -- ════════════════════════════════════════════════════════════

    function Window:CreateTab(tabCfg)
        tabCfg = tabCfg or {}
        local tName  = tabCfg.Name  or "Tab"
        local tIcon  = tabCfg.Icon  or ""
        local tOrder = tabCfg.Order or (#S.Tabs + 1)

        -- Sidebar button
        local TBtn = N("TextButton", {
            BackgroundColor3       = G.Lift,
            BackgroundTransparency = 1,
            Size     = UDim2.new(1, -6, 0, 44),
            Text     = "",
            AutoButtonColor = false,
            LayoutOrder     = tOrder,
            ZIndex   = 13,
        }, SideScroll)
        Corner(TBtn, UDim.new(0, 9))

        -- Active glass glow
        local TGlow = N("Frame", {
            BackgroundColor3 = accent,
            BackgroundTransparency = 1,
            Size   = UDim2.new(1, 0, 1, 0),
            ZIndex = 12,
        }, TBtn)
        Corner(TGlow, UDim.new(0, 9))
        Grad(TGlow,
            ColorSequence.new({ ColorSequenceKeypoint.new(0, accent), ColorSequenceKeypoint.new(1, G.Black) }),
            NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.82), NumberSequenceKeypoint.new(1, 1) }),
            0
        )

        local TIcn = N("TextLabel", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(0, 36, 1, 0),
            Position = UDim2.new(0, 6, 0, 0),
            Font     = Enum.Font.GothamMedium,
            Text     = tIcon, TextColor3 = G.TxtGhost, TextSize = 15, ZIndex = 14,
        }, TBtn)

        local TLbl = N("TextLabel", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(1, -50, 1, 0),
            Position = UDim2.new(0, 44, 0, 0),
            Font     = Enum.Font.GothamMedium,
            Text     = tName, TextColor3 = G.TxtMd, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
        }, TBtn)

        local TInd = N("Frame", {
            BackgroundColor3 = accent,
            Size     = UDim2.new(0, 3, 0, 0),
            Position = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint      = Vector2.new(0, 0.5),
            ZIndex   = 14,
        }, TBtn)
        Corner(TInd, UDim.new(1, 0))

        -- Content page
        local Page = N("ScrollingFrame", {
            BackgroundTransparency  = 1,
            Size     = UDim2.new(1, -14, 1, -14),
            Position = UDim2.new(0, 7, 0, 7),
            CanvasSize              = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize     = Enum.AutomaticSize.Y,
            ScrollBarThickness      = 3,
            ScrollBarImageColor3    = G.TxtGhost,
            BorderSizePixel         = 0,
            Visible = false, ZIndex = 12,
        }, ContentWrap)
        ListV(Page, UDim.new(0, 6))
        Pad(Page, 5, 5, 5, 5)

        local td = {
            Btn = TBtn, Page = Page, Ind = TInd,
            Glow = TGlow, Icn = TIcn, Lbl = TLbl,
        }
        table.insert(S.Tabs, td)

        local function SelectTab()
            for _, t in ipairs(S.Tabs) do
                t.Page.Visible = false
                TwQuint(t.Btn,  { BackgroundTransparency = 1 },         0.18)
                TwQuint(t.Glow, { BackgroundTransparency = 1 },         0.18)
                TwQuint(t.Ind,  { Size = UDim2.new(0, 3, 0, 0) },      0.18)
                TwQuint(t.Lbl,  { TextColor3 = G.TxtMd },               0.18)
                TwQuint(t.Icn,  { TextColor3 = G.TxtGhost },            0.18)
            end
            td.Page.Visible = true
            S.ActiveTab     = td
            TwQuint(td.Btn,  { BackgroundTransparency = 0.72 },     0.18)
            TwQuint(td.Glow, { BackgroundTransparency = 0.85 },     0.18)
            TwQuint(td.Lbl,  { TextColor3 = G.TxtHi },              0.18)
            TwQuint(td.Icn,  { TextColor3 = accent },               0.18)
            TwBack (td.Ind,  { Size = UDim2.new(0, 3, 0, 26) },    0.28)
        end

        TBtn.MouseEnter:Connect(function()
            if S.ActiveTab ~= td then TwQuint(TBtn, { BackgroundTransparency = 0.84 }, 0.13) end
        end)
        TBtn.MouseLeave:Connect(function()
            if S.ActiveTab ~= td then TwQuint(TBtn, { BackgroundTransparency = 1 }, 0.13) end
        end)
        TBtn.MouseButton1Click:Connect(SelectTab)

        if #S.Tabs == 1 then SelectTab() end

        -- ──────────────────────────────────────────────────────
        --  ELEMENT BUILDERS
        -- ──────────────────────────────────────────────────────

        local Tab = {}

        -- Shared glass row factory
        local function Row(h, noHover)
            local f, sh, e = GlassFrame(Page, UDim2.new(1, 0, 0, h), nil, 13, 9, G.Surface, 0.08)
            f.LayoutOrder = #Page:GetChildren()
            if not noHover then HoverRow(f, G.Surface, G.Lift) end
            return f
        end

        -- SECTION ─────────────────────────────────────────────

        function Tab:CreateSection(name)
            local sf = N("Frame", {
                BackgroundTransparency = 1,
                Size        = UDim2.new(1, 0, 0, 26),
                LayoutOrder = #Page:GetChildren(),
                ZIndex      = 13,
            }, Page)

            N("Frame", {
                BackgroundColor3 = G.White, BackgroundTransparency = 0.86,
                Size = UDim2.new(0, 16, 0, 1),
                Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), ZIndex = 13,
            }, sf)

            local dot = N("Frame", {
                BackgroundColor3 = accent, Size = UDim2.new(0, 4, 0, 4),
                Position = UDim2.new(0, 22, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), ZIndex = 13,
            }, sf)
            Corner(dot, UDim.new(1, 0))

            N("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.65, 0, 1, 0), Position = UDim2.new(0, 32, 0, 0),
                Font = Enum.Font.GothamBold, Text = string.upper(name or "SECTION"),
                TextColor3 = G.TxtLo, TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13,
            }, sf)

            N("Frame", {
                BackgroundColor3 = G.White, BackgroundTransparency = 0.86,
                Size = UDim2.new(0.45, 0, 0, 1),
                Position = UDim2.new(0.55, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), ZIndex = 13,
            }, sf)
        end

        -- TOGGLE ──────────────────────────────────────────────

        function Tab:CreateToggle(opts)
            opts = opts or {}
            local val = opts.Default or false
            local row = Row(opts.Description and 50 or 44)

            -- Active strip
            local strip = N("Frame", {
                BackgroundColor3       = accent,
                BackgroundTransparency = val and 0 or 1,
                Size     = UDim2.new(0, 2, 0.52, 0),
                Position = UDim2.new(0, 0, 0.24, 0),
                ZIndex   = 15,
            }, row)

            N("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0.62, -14, 0, 18),
                Position = UDim2.new(0, 14, 0, opts.Description and 6 or 13),
                Font     = Enum.Font.GothamMedium, Text = opts.Name or "Toggle",
                TextColor3 = G.TxtHi, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 15,
            }, row)

            if opts.Description then
                N("TextLabel", {
                    BackgroundTransparency = 1,
                    Size     = UDim2.new(0.62, -14, 0, 13),
                    Position = UDim2.new(0, 14, 0, 27),
                    Font     = Enum.Font.GothamMedium, Text = opts.Description,
                    TextColor3 = G.TxtLo, TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 15,
                }, row)
            end

            local track = N("Frame", {
                BackgroundColor3 = val and accent or G.Rise,
                Size     = UDim2.new(0, 48, 0, 26),
                Position = UDim2.new(1, -62, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                ZIndex   = 15,
            }, row)
            Corner(track, UDim.new(1, 0))

            -- Track glass sheen
            local tsh = N("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0.5, 0), ZIndex = 16,
            }, track)
            Corner(tsh, UDim.new(1, 0))
            Grad(tsh, ColorSequence.new(G.White, G.White),
                NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.78), NumberSequenceKeypoint.new(1, 1) }), 180)

            local knob = N("Frame", {
                BackgroundColor3 = G.White,
                Size     = UDim2.new(0, 20, 0, 20),
                Position = val and UDim2.new(1, -23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                ZIndex   = 17,
            }, track)
            Corner(knob, UDim.new(1, 0))

            local function Refresh()
                if val then
                    TwQuint(track, { BackgroundColor3 = accent }, 0.2)
                    TwQuint(strip, { BackgroundTransparency = 0 }, 0.2)
                    TwBack (knob,  { Position = UDim2.new(1, -23, 0.5, 0) }, 0.24)
                else
                    TwQuint(track, { BackgroundColor3 = G.Rise }, 0.2)
                    TwQuint(strip, { BackgroundTransparency = 1 }, 0.2)
                    TwBack (knob,  { Position = UDim2.new(0, 3, 0.5, 0) }, 0.24)
                end
                if opts.Callback then opts.Callback(val) end
            end

            local cz = N("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "", ZIndex = 19,
            }, row)
            cz.MouseButton1Click:Connect(function()
                val = not val
                Refresh()
            end)

            local API = {}
            function API:Set(v) val = v; Refresh() end
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
            local row = Row(60)

            N("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.65, -14, 0, 18), Position = UDim2.new(0, 14, 0, 8),
                Font = Enum.Font.GothamMedium, Text = opts.Name or "Slider",
                TextColor3 = G.TxtHi, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 15,
            }, row)

            local vLbl = N("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.3, -14, 0, 18), Position = UDim2.new(0.7, 0, 0, 8),
                Font = Enum.Font.Code, Text = tostring(cur),
                TextColor3 = accent, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 15,
            }, row)

            local track = N("Frame", {
                BackgroundColor3 = G.Rise,
                Size = UDim2.new(1, -28, 0, 5),
                Position = UDim2.new(0, 14, 0, 42),
                ZIndex = 15,
            }, row)
            Corner(track, UDim.new(1, 0))

            local p0   = (cur - mn) / (mx - mn)
            local fill = N("Frame", {
                BackgroundColor3 = accent,
                Size = UDim2.new(p0, 0, 1, 0), ZIndex = 16,
            }, track)
            Corner(fill, UDim.new(1, 0))
            Grad(fill,
                ColorSequence.new({ ColorSequenceKeypoint.new(0, G.A3), ColorSequenceKeypoint.new(1, accentCy) }),
                NumberSequence.new(0)
            )

            local knob = N("Frame", {
                BackgroundColor3 = G.White,
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(p0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 18,
            }, track)
            Corner(knob, UDim.new(1, 0))
            Stroke(knob, accent, 2)

            local dragging = false

            local function ApplyX(px)
                local rel = math.clamp((px - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                cur = math.clamp(math.floor((mn + (mx - mn) * rel) / stp + 0.5) * stp, mn, mx)
                local p = (cur - mn) / (mx - mn)
                fill.Size     = UDim2.new(p, 0, 1, 0)
                knob.Position = UDim2.new(p, 0, 0.5, 0)
                vLbl.Text     = tostring(cur)
                if opts.Callback then opts.Callback(cur) end
            end

            track.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = true; ApplyX(i.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
                    or i.UserInputType == Enum.UserInputType.Touch) then
                    ApplyX(i.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            local API = {}
            function API:Set(v)
                cur = math.clamp(v, mn, mx)
                local p = (cur - mn) / (mx - mn)
                fill.Size     = UDim2.new(p, 0, 1, 0)
                knob.Position = UDim2.new(p, 0, 0.5, 0)
                vLbl.Text     = tostring(cur)
            end
            function API:Get() return cur end
            return API
        end

        -- BUTTON ──────────────────────────────────────────────

        function Tab:CreateButton(opts)
            opts = opts or {}
            local row = Row(44)

            N("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.65, -14, 1, 0), Position = UDim2.new(0, 14, 0, 0),
                Font = Enum.Font.GothamMedium, Text = opts.Name or "Button",
                TextColor3 = G.TxtHi, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 15,
            }, row)

            local btn = N("TextButton", {
                BackgroundColor3       = accent,
                BackgroundTransparency = 0.08,
                Size     = UDim2.new(0, 80, 0, 30),
                Position = UDim2.new(1, -92, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Font     = Enum.Font.GothamBold,
                Text     = opts.ButtonText or "Run",
                TextColor3 = G.White, TextSize = 12,
                AutoButtonColor = false, ZIndex = 15,
            }, row)
            Corner(btn, UDim.new(0, 8))
            Stroke(btn, G.EdgeHi, 1, 0.75)

            -- Button glass sheen
            local bsh = N("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0.5, 0), ZIndex = 16,
            }, btn)
            Corner(bsh, UDim.new(0, 8))
            Grad(bsh, ColorSequence.new(G.White, G.White),
                NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.74), NumberSequenceKeypoint.new(1, 1) }), 180)

            btn.MouseEnter:Connect(function()
                TwQuint(btn, { BackgroundColor3 = accentHi, BackgroundTransparency = 0 }, 0.14)
            end)
            btn.MouseLeave:Connect(function()
                TwQuint(btn, { BackgroundColor3 = accent, BackgroundTransparency = 0.08 }, 0.14)
            end)
            btn.MouseButton1Click:Connect(function()
                Ripple(btn, accentHi)
                if opts.Callback then opts.Callback() end
            end)
        end

        -- DROPDOWN ────────────────────────────────────────────

        function Tab:CreateDropdown(opts)
            opts = opts or {}
            local items   = opts.Items   or {}
            local current = opts.Default or (items[1] or "")
            local isOpen  = false

            local wrap, _, _ = GlassFrame(Page, UDim2.new(1, 0, 0, 44), nil, 13, 9, G.Surface, 0.08)
            wrap.ClipsDescendants = true
            wrap.LayoutOrder = #Page:GetChildren()

            N("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.44, -8, 0, 44), Position = UDim2.new(0, 14, 0, 0),
                Font = Enum.Font.GothamMedium, Text = opts.Name or "Dropdown",
                TextColor3 = G.TxtHi, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 15,
            }, wrap)

            local selBtn = N("TextButton", {
                BackgroundColor3       = G.Rise,
                BackgroundTransparency = 0.18,
                Size     = UDim2.new(0.51, -14, 0, 28),
                Position = UDim2.new(0.49, 0, 0, 8),
                Font     = Enum.Font.GothamMedium,
                Text     = current .. "  v",
                TextColor3 = G.TxtMd, TextSize = 12,
                AutoButtonColor = false, ZIndex = 16,
            }, wrap)
            Corner(selBtn, UDim.new(0, 7))
            Stroke(selBtn, G.EdgeHi, 1, 0.80)

            local ibox = N("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -16, 0, 0),
                Position = UDim2.new(0, 8, 0, 46),
                ZIndex = 16,
            }, wrap)
            ListV(ibox, UDim.new(0, 2))

            local function BuildItems()
                for _, c in ipairs(ibox:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for i, item in ipairs(items) do
                    local ib = N("TextButton", {
                        BackgroundColor3       = G.Lift,
                        BackgroundTransparency = 0.3,
                        Size        = UDim2.new(1, 0, 0, 30),
                        Font        = Enum.Font.GothamMedium,
                        Text        = item,
                        TextColor3  = item == current and accent or G.TxtMd,
                        TextSize    = 12,
                        AutoButtonColor = false,
                        LayoutOrder = i, ZIndex = 17,
                    }, ibox)
                    Corner(ib, UDim.new(0, 6))
                    ib.MouseEnter:Connect(function()
                        TwQuint(ib, { BackgroundTransparency = 0, TextColor3 = G.TxtHi }, 0.12)
                    end)
                    ib.MouseLeave:Connect(function()
                        TwQuint(ib, { BackgroundTransparency = 0.3, TextColor3 = item == current and accent or G.TxtMd }, 0.12)
                    end)
                    ib.MouseButton1Click:Connect(function()
                        current = item
                        selBtn.Text = item .. "  v"
                        isOpen = false
                        TwQuint(wrap, { Size = UDim2.new(1, 0, 0, 44) }, 0.22)
                        BuildItems()
                        if opts.Callback then opts.Callback(item) end
                    end)
                end
            end
            BuildItems()

            selBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    TwBack(wrap, { Size = UDim2.new(1, 0, 0, 52 + #items * 32) }, 0.3)
                    selBtn.Text = current .. "  ^"
                else
                    TwQuint(wrap, { Size = UDim2.new(1, 0, 0, 44) }, 0.22)
                    selBtn.Text = current .. "  v"
                end
            end)

            local API = {}
            function API:Set(v) current = v; selBtn.Text = v .. "  v"; BuildItems() end
            function API:Refresh(list, def)
                items = list
                if def then current = def; selBtn.Text = def .. "  v" end
                BuildItems()
            end
            function API:Get() return current end
            return API
        end

        -- INPUT ───────────────────────────────────────────────

        function Tab:CreateInput(opts)
            opts = opts or {}
            local row = Row(44)

            N("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.42, -8, 1, 0), Position = UDim2.new(0, 14, 0, 0),
                Font = Enum.Font.GothamMedium, Text = opts.Name or "Input",
                TextColor3 = G.TxtHi, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 15,
            }, row)

            local box = N("TextBox", {
                BackgroundColor3       = G.Rise,
                BackgroundTransparency = 0.18,
                Size     = UDim2.new(0.55, -14, 0, 29),
                Position = UDim2.new(0.45, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Font     = Enum.Font.GothamMedium,
                PlaceholderText   = opts.Placeholder or "Enter value...",
                PlaceholderColor3 = G.TxtGhost,
                Text     = opts.Default or "",
                TextColor3 = G.TxtHi, TextSize = 12,
                ClearTextOnFocus  = opts.ClearOnFocus or false,
                ZIndex   = 15,
            }, row)
            Corner(box, UDim.new(0, 7))
            N("UIPadding", { PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 9) }, box)
            local bStk = Stroke(box, G.EdgeMd, 1, 0.4)

            box.Focused:Connect(function()
                TwQuint(bStk, { Color = accent, Transparency = 0 }, 0.18)
                TwQuint(box,  { BackgroundColor3 = G.Lift, BackgroundTransparency = 0.1 }, 0.18)
            end)
            box.FocusLost:Connect(function(enter)
                TwQuint(bStk, { Color = G.EdgeMd, Transparency = 0.4 }, 0.18)
                TwQuint(box,  { BackgroundColor3 = G.Rise, BackgroundTransparency = 0.18 }, 0.18)
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
            local row       = Row(44)

            N("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.62, -14, 1, 0), Position = UDim2.new(0, 14, 0, 0),
                Font = Enum.Font.GothamMedium, Text = opts.Name or "Keybind",
                TextColor3 = G.TxtHi, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 15,
            }, row)

            local kbtn = N("TextButton", {
                BackgroundColor3       = G.Rise,
                BackgroundTransparency = 0.18,
                Size     = UDim2.new(0, 82, 0, 30),
                Position = UDim2.new(1, -95, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Font     = Enum.Font.Code,
                Text     = key.Name,
                TextColor3 = accent, TextSize = 12,
                AutoButtonColor = false, ZIndex = 15,
            }, row)
            Corner(kbtn, UDim.new(0, 7))
            Stroke(kbtn, accent, 1, 0.5)

            kbtn.MouseButton1Click:Connect(function()
                listening       = true
                kbtn.Text       = "..."
                kbtn.TextColor3 = G.White
                TwQuint(kbtn, { BackgroundColor3 = accent, BackgroundTransparency = 0 }, 0.14)
            end)

            UserInputService.InputBegan:Connect(function(i)
                if listening and i.UserInputType == Enum.UserInputType.Keyboard then
                    listening       = false
                    key             = i.KeyCode
                    kbtn.Text       = key.Name
                    kbtn.TextColor3 = accent
                    TwQuint(kbtn, { BackgroundColor3 = G.Rise, BackgroundTransparency = 0.18 }, 0.14)
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
            local row = Row(34, true)
            row.BackgroundTransparency = 0.38

            local dot = N("Frame", {
                BackgroundColor3 = accent,
                Size = UDim2.new(0, 4, 0, 4),
                Position = UDim2.new(0, 13, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5), ZIndex = 14,
            }, row)
            Corner(dot, UDim.new(1, 0))

            local lbl = N("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -28, 1, 0), Position = UDim2.new(0, 26, 0, 0),
                Font = Enum.Font.GothamMedium, Text = opts.Text or "Label",
                TextColor3 = G.TxtMd, TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
            }, row)

            local API = {}
            function API:Set(v) lbl.Text = v end
            function API:Get() return lbl.Text end
            return API
        end

        -- COLOR SWATCH ────────────────────────────────────────

        function Tab:CreateColorPicker(opts)
            opts = opts or {}
            local color = opts.Default or G.White
            local row   = Row(44)

            N("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.65, -14, 1, 0), Position = UDim2.new(0, 14, 0, 0),
                Font = Enum.Font.GothamMedium, Text = opts.Name or "Color",
                TextColor3 = G.TxtHi, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 15,
            }, row)

            local swatch = N("Frame", {
                BackgroundColor3 = color,
                Size = UDim2.new(0, 30, 0, 30),
                Position = UDim2.new(1, -44, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5), ZIndex = 16,
            }, row)
            Corner(swatch, UDim.new(0, 7))
            Stroke(swatch, G.EdgeHi, 1, 0.7)

            local API = {}
            function API:Set(c)
                color = c
                swatch.BackgroundColor3 = c
                if opts.Callback then opts.Callback(c) end
            end
            function API:Get() return color end
            return API
        end

        return Tab
    end

    -- ════════════════════════════════════════════════════════════
    --  CONFIG API
    -- ════════════════════════════════════════════════════════════

    function Window:SetValue(k, v) S.Data[k] = v end
    function Window:GetValue(k)    return S.Data[k] end

    function Window:SaveConfig(name)
        local out = {}
        for k, v in pairs(S.Data) do out[k] = v end
        pcall(function()
            if writefile then
                writefile((name or WCfg.ConfigName) .. ".json", HttpService:JSONEncode(out))
            end
        end)
        Notify({
            Title   = "Config Saved",
            Content = (name or WCfg.ConfigName) .. ".json",
            Type    = "Success", Duration = 3,
        })
        return out
    end

    function Window:LoadConfig(name, data)
        if type(data) == "table" then
            for k, v in pairs(data) do S.Data[k] = v end
            Notify({ Title = "Config Loaded", Content = name or "config", Type = "Info", Duration = 3 })
        else
            pcall(function()
                if readfile and isfile then
                    local path = (name or WCfg.ConfigName) .. ".json"
                    if isfile(path) then
                        local parsed = HttpService:JSONDecode(readfile(path))
                        for k, v in pairs(parsed) do S.Data[k] = v end
                        Notify({ Title = "Config Loaded", Content = path, Type = "Info", Duration = 3 })
                    end
                end
            end)
        end
    end

    function Window:SetCompact(bool)
        if bool and not S.Compact then
            S.Compact = true
            TwBackIn(Win, { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }, 0.38)
            task.delay(0.42, function()
                Win.Visible = false
                CompactPill.Visible = true
            end)
        elseif not bool and S.Compact then
            S.Compact = false
            CompactPill.Visible = false
            Win.Visible = true
            Win.Size = UDim2.new(0, 0, 0, 0)
            Win.BackgroundTransparency = 1
            TwBack(Win, { Size = WCfg.Size, BackgroundTransparency = 0.06 }, 0.5)
        end
    end

    function Window:Destroy()
        TwBackIn(Win, { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }, 0.38)
        task.delay(0.42, function() Gui:Destroy() end)
    end

    -- Startup hint
    task.delay(0.75, function()
        Notify({
            Title   = WCfg.Title .. " Ready",
            Content = "Ctrl+Shift+P  Command Palette  |  " .. WCfg.ToggleKey.Name .. "  Toggle  |  [·]  Compact",
            Type    = "Info",
            Duration = 6,
        })
    end)

    return Window
end

return NexusLib
