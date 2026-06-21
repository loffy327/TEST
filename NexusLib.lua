--[[
╔══════════════════════════════════════════════════════════════════════╗
║                                                                      ║
║                     N E X U S   L I B                                ║
║              Roblox Luau Premium UI Framework                        ║
║                                                                      ║
║   Style     :  Glassmorphism / Fluent                                ║
║   Version   :  1.0.0                                                 ║
║   Build     :  2026.06.21                                            ║
║   Budget    :  10,000,000 VND                                        ║
║                                                                      ║
║   FEATURES                                                           ║
║     Glassmorphism layered window system                              ║
║     Compact Mode  —  collapses to floating pill                      ║
║     Command Palette  (hidden  Ctrl + Shift + P)                      ║
║     Full element suite  (8 types + Section)                          ║
║     Tab sidebar with animated indicator                              ║
║     Toast notification system  (4 types)                            ║
║     Config JSON  read / write                                        ║
║     Extensible module registration                                   ║
║     Draggable window + keybind toggle                                ║
║     Zero memory leak  —  no idle RunService loops                    ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
--]]

-- ════════════════════════════════════════════════════════════════════
--  SERVICES
-- ════════════════════════════════════════════════════════════════════

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService       = game:GetService("HttpService")
local Players          = game:GetService("Players")

local LP = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════════════
--  DESIGN TOKENS
-- ════════════════════════════════════════════════════════════════════

local Token = {
    -- Glass layers (simulate frosted glass via transparency stacking)
    GlassBase    = Color3.fromRGB(10,  10,  22),
    GlassPanel   = Color3.fromRGB(15,  15,  32),
    GlassSurface = Color3.fromRGB(20,  20,  42),
    GlassLift    = Color3.fromRGB(26,  26,  52),
    GlassRise    = Color3.fromRGB(32,  32,  64),

    -- Accent — electric indigo
    A1           = Color3.fromRGB(99,  90, 245),
    A2           = Color3.fromRGB(130, 120, 255),
    A3           = Color3.fromRGB(72,  65, 200),

    -- Highlight — cool white blue
    H1           = Color3.fromRGB(200, 200, 240),
    H2           = Color3.fromRGB(255, 255, 255),

    -- Cyan secondary
    Cy1          = Color3.fromRGB(56,  205, 255),
    Cy2          = Color3.fromRGB(30,  155, 210),

    -- Text
    T1           = Color3.fromRGB(232, 232, 248),   -- primary
    T2           = Color3.fromRGB(140, 140, 180),   -- secondary
    T3           = Color3.fromRGB(65,  65, 105),    -- muted
    T4           = Color3.fromRGB(40,  40,  72),    -- very muted

    -- Borders (glass edges)
    B1           = Color3.fromRGB(255, 255, 255),   -- glass highlight edge
    B2           = Color3.fromRGB(60,  60, 100),    -- standard edge
    B3           = Color3.fromRGB(30,  30,  60),    -- divider

    -- Status
    Ok           = Color3.fromRGB(46,  213, 115),
    Warn         = Color3.fromRGB(255, 196,  57),
    Err          = Color3.fromRGB(232,  65,  75),
    Info         = Color3.fromRGB(56,  190, 255),

    -- Misc
    Pure         = Color3.new(1, 1, 1),
    Black        = Color3.new(0, 0, 0),
    Divider      = Color3.fromRGB(255, 255, 255),   -- glass divider (white, set transp high)
}

-- ════════════════════════════════════════════════════════════════════
--  TWEEN ENGINE
-- ════════════════════════════════════════════════════════════════════

local function tw(obj, props, t, sty, dir)
    local tween = TweenService:Create(obj,
        TweenInfo.new(t or 0.22, sty or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
        props
    )
    tween:Play()
    return tween
end

local function twBack(obj, p, t, dir)
    return tw(obj, p, t, Enum.EasingStyle.Back, dir)
end
local function twSine(obj, p, t)
    return tw(obj, p, t, Enum.EasingStyle.Sine)
end
local function twQuad(obj, p, t)
    return tw(obj, p, t, Enum.EasingStyle.Quad)
end
local function twLinear(obj, p, t)
    return tw(obj, p, t, Enum.EasingStyle.Linear)
end
local function twSpring(obj, p, t)
    return tw(obj, p, t, Enum.EasingStyle.Spring)
end

-- ════════════════════════════════════════════════════════════════════
--  INSTANCE FACTORY
-- ════════════════════════════════════════════════════════════════════

local function N(class, props, parent)
    local obj = Instance.new(class)
    if props  then for k, v in pairs(props) do obj[k] = v end end
    if parent then obj.Parent = parent end
    return obj
end

local function Corner(obj, r)
    return N("UICorner", { CornerRadius = r or UDim.new(0, 8) }, obj)
end

local function Stroke(obj, col, thick, transp)
    return N("UIStroke", {
        Color        = col   or Token.B2,
        Thickness    = thick or 1,
        Transparency = transp or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, obj)
end

local function Grad(obj, cs, ts, rot)
    return N("UIGradient", {
        Color        = cs  or ColorSequence.new(Token.A1, Token.Cy1),
        Transparency = ts  or NumberSequence.new(0),
        Rotation     = rot or 0,
    }, obj)
end

local function ListH(obj, gap, ha, va)
    return N("UIListLayout", {
        FillDirection       = Enum.FillDirection.Horizontal,
        Padding             = gap or UDim.new(0, 6),
        SortOrder           = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = ha or Enum.HorizontalAlignment.Left,
        VerticalAlignment   = va or Enum.VerticalAlignment.Center,
    }, obj)
end

local function ListV(obj, gap, va)
    return N("UIListLayout", {
        FillDirection       = Enum.FillDirection.Vertical,
        Padding             = gap or UDim.new(0, 6),
        SortOrder           = Enum.SortOrder.LayoutOrder,
        VerticalAlignment   = va or Enum.VerticalAlignment.Top,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    }, obj)
end

local function Pad(obj, t, r, b, l)
    return N("UIPadding", {
        PaddingTop    = UDim.new(0, t or 8),
        PaddingRight  = UDim.new(0, r or 8),
        PaddingBottom = UDim.new(0, b or 8),
        PaddingLeft   = UDim.new(0, l or 8),
    }, obj)
end

local function Shadow(obj, transp)
    return N("ImageLabel", {
        Name              = "_Shadow",
        BackgroundTransparency = 1,
        Image             = "rbxassetid://6014261993",
        ImageColor3       = Token.Black,
        ImageTransparency = transp or 0.45,
        Size              = UDim2.new(1, 50, 1, 50),
        Position          = UDim2.new(0, -25, 0, -25),
        ZIndex            = obj.ZIndex - 1,
        ScaleType         = Enum.ScaleType.Slice,
        SliceCenter       = Rect.new(49, 49, 450, 450),
    }, obj)
end

-- Cursor-aware ripple
local function Ripple(btn, col)
    local mp  = UserInputService:GetMouseLocation()
    local rel = mp - Vector2.new(btn.AbsolutePosition.X, btn.AbsolutePosition.Y)
    local r = N("Frame", {
        BackgroundColor3       = col or Token.A2,
        BackgroundTransparency = 0.6,
        Size     = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, rel.X, 0, rel.Y),
        AnchorPoint            = Vector2.new(0.5, 0.5),
        ZIndex   = btn.ZIndex + 30,
    }, btn)
    Corner(r, UDim.new(1, 0))
    twSine(r, { Size = UDim2.new(3.5, 0, 3.5, 0), BackgroundTransparency = 1 }, 0.58)
    task.delay(0.62, function() if r and r.Parent then r:Destroy() end end)
end

local function HoverBind(f, norm, hov)
    f.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then
            tw(f, { BackgroundColor3 = hov }, 0.13)
        end
    end)
    f.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then
            tw(f, { BackgroundColor3 = norm }, 0.13)
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════
--  GLASS PANEL  (core visual primitive)
-- ════════════════════════════════════════════════════════════════════

--[[
    Glassmorphism simulation via 3 layers:
      1. Dark base (BackgroundColor3 + semi-transparent)
      2. Subtle white inner gradient at top (glass sheen)
      3. UIStroke with very low opacity white (glass edge highlight)
--]]

local function GlassPanel(parent, size, pos, zi, radius, baseColor, baseTransp)
    local panel = N("Frame", {
        BackgroundColor3       = baseColor or Token.GlassPanel,
        BackgroundTransparency = baseTransp or 0.1,
        Size     = size     or UDim2.new(1, 0, 1, 0),
        Position = pos      or UDim2.new(0, 0, 0, 0),
        ZIndex   = zi       or 10,
        ClipsDescendants = false,
    }, parent)
    local r = Corner(panel, UDim.new(0, radius or 12))

    -- Glass sheen overlay (white-ish gradient at top)
    local sheen = N("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(1, 0, 0.45, 0),
        ZIndex   = zi and zi + 1 or 11,
    }, panel)
    Corner(sheen, UDim.new(0, radius or 12))
    Grad(sheen,
        ColorSequence.new({
            ColorSequenceKeypoint.new(0, Token.Pure),
            ColorSequenceKeypoint.new(1, Token.Pure),
        }),
        NumberSequence.new({
            NumberSequenceKeypoint.new(0,   0.88),
            NumberSequenceKeypoint.new(0.6, 0.96),
            NumberSequenceKeypoint.new(1,   1),
        }),
        180
    )

    -- Glass edge highlight (top-left brighter)
    local edgeStk = Stroke(panel, Token.B1, 1, 0.72)

    return panel, sheen, edgeStk
end

-- ════════════════════════════════════════════════════════════════════
--  ANIMATED NEON TOP BORDER
-- ════════════════════════════════════════════════════════════════════

local function NeonLine(parent, col1, col2)
    local line = N("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(1, 0, 0, 2),
        BorderSizePixel = 0,
        ZIndex   = parent.ZIndex + 5,
    }, parent)

    local g = Grad(line, ColorSequence.new({
        ColorSequenceKeypoint.new(0,    col1),
        ColorSequenceKeypoint.new(0.4,  col2),
        ColorSequenceKeypoint.new(0.7,  col1),
        ColorSequenceKeypoint.new(1,    col2),
    }), NumberSequence.new({
        NumberSequenceKeypoint.new(0,   0.75),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1,   0.75),
    }))
    g.Offset = Vector2.new(-1, 0)

    local alive = true
    task.spawn(function()
        while alive and line and line.Parent do
            twLinear(g, { Offset = Vector2.new(1, 0) }, 2.8)
            task.wait(2.8)
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

    local accent    = cfg.Accent     or Token.A1
    local accentHi  = cfg.AccentHi   or Token.A2
    local accentCy  = cfg.AccentCy   or Token.Cy1

    local WCfg = {
        Title        = cfg.Title       or "Nexus Hub",
        Subtitle     = cfg.Subtitle    or "v1.0",
        LogoText     = cfg.LogoText    or "NX",
        Size         = cfg.Size        or UDim2.new(0, 640, 0, 460),
        ToggleKey    = cfg.ToggleKey   or Enum.KeyCode.RightShift,
        ConfigName   = cfg.ConfigName  or "NexusConfig",
        PaletteKey   = cfg.PaletteKey  or Enum.KeyCode.P,
    }

    -- Whether PaletteKey triggers palette (requires Ctrl+Shift held)
    local State = {
        Minimized    = false,
        Maximized    = false,
        Compact      = false,
        PaletteOpen  = false,
        Dragging     = false,
        DragOrigin   = nil,
        DragPos      = nil,
        ActiveTab    = nil,
        Tabs         = {},
        Data         = {},
        Commands     = {},    -- registered command palette entries
    }

    -- ── Screen GUI ────────────────────────────────────────────────

    local Gui = N("ScreenGui", {
        Name           = "NexusLib_GUI",
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder   = 999,
        IgnoreGuiInset = true,
    }, LP:WaitForChild("PlayerGui"))

    -- ────────────────────────────────────────────────────────────
    --  NOTIFICATIONS (built first so everything can use them)
    -- ────────────────────────────────────────────────────────────

    local NotifStack = N("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(0, 320, 1, -20),
        Position = UDim2.new(1, -332, 0, 10),
        ZIndex   = 400,
    }, Gui)
    N("UIListLayout", {
        VerticalAlignment   = Enum.VerticalAlignment.Bottom,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Padding             = UDim.new(0, 8),
    }, NotifStack)

    local nIdx = 0
    local function Notify(opts)
        opts = opts or {}
        nIdx += 1
        local cm  = { Success = Token.Ok, Warning = Token.Warn, Error = Token.Err, Info = Token.Info }
        local ac  = cm[opts.Type] or accent

        local nf = N("Frame", {
            BackgroundColor3       = Token.GlassSurface,
            BackgroundTransparency = 0.08,
            Size        = UDim2.new(1, 0, 0, 72),
            ZIndex      = 401,
            LayoutOrder = nIdx,
        }, NotifStack)
        Corner(nf, UDim.new(0, 10))
        Stroke(nf, ac, 1, 0.5)

        -- Glass sheen
        local ns = N("Frame", {
            BackgroundTransparency = 1,
            Size   = UDim2.new(1, 0, 0.45, 0),
            ZIndex = 402,
        }, nf)
        Corner(ns, UDim.new(0, 10))
        Grad(ns, ColorSequence.new(Token.Pure, Token.Pure),
            NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.9), NumberSequenceKeypoint.new(1, 1) }), 180)

        local bar = N("Frame", {
            BackgroundColor3 = ac,
            Size     = UDim2.new(0, 3, 0.58, 0),
            Position = UDim2.new(0, 8, 0.21, 0),
            ZIndex   = 402,
        }, nf)
        Corner(bar, UDim.new(1, 0))

        N("TextLabel", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(1, -30, 0, 20),
            Position = UDim2.new(0, 22, 0, 12),
            Font     = Enum.Font.GothamBold,
            Text     = opts.Title or "Notice",
            TextColor3 = Token.T1, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex   = 402,
        }, nf)

        N("TextLabel", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(1, -30, 0, 26),
            Position = UDim2.new(0, 22, 0, 34),
            Font     = Enum.Font.GothamMedium,
            Text     = opts.Content or "",
            TextColor3 = Token.T2, TextSize = 11, TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex   = 402,
        }, nf)

        nf.Position = UDim2.new(1, 40, 0, 0)
        nf.BackgroundTransparency = 0.5
        twBack(nf, { Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0.08 }, 0.38)

        task.delay(opts.Duration or 4, function()
            tw(nf, { Position = UDim2.new(1, 40, 0, 0), BackgroundTransparency = 1 }, 0.3)
            task.delay(0.35, function() if nf and nf.Parent then nf:Destroy() end end)
        end)
    end

    -- ────────────────────────────────────────────────────────────
    --  MAIN GLASS WINDOW
    -- ────────────────────────────────────────────────────────────

    local Win = N("Frame", {
        Name             = "NexusWindow",
        BackgroundColor3 = Token.GlassBase,
        BackgroundTransparency = 0.05,
        Size     = WCfg.Size,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint      = Vector2.new(0.5, 0.5),
        ClipsDescendants = true,
        ZIndex           = 10,
    }, Gui)
    Corner(Win, UDim.new(0, 14))

    -- Glass edge stroke (white, very transparent)
    local winEdge = Stroke(Win, Token.B1, 1, 0.72)

    Shadow(Win, 0.4)

    -- Animated neon top border
    NeonLine(Win, accent, accentCy)

    -- Background glass sheen layer
    local winSheen = N("Frame", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 0.35, 0),
        ZIndex = 11,
    }, Win)
    Corner(winSheen, UDim.new(0, 14))
    Grad(winSheen,
        ColorSequence.new(Token.Pure, Token.Pure),
        NumberSequence.new({
            NumberSequenceKeypoint.new(0,   0.93),
            NumberSequenceKeypoint.new(0.7, 0.98),
            NumberSequenceKeypoint.new(1,   1),
        }), 180
    )

    -- Reveal animation
    Win.Size             = UDim2.new(0, 0, 0, 0)
    Win.BackgroundTransparency = 1
    twBack(Win, { Size = WCfg.Size, BackgroundTransparency = 0.05 }, 0.65)

    -- ── Title Bar ─────────────────────────────────────────────────

    local TBar = N("Frame", {
        BackgroundColor3       = Token.GlassPanel,
        BackgroundTransparency = 0.12,
        Size     = UDim2.new(1, 0, 0, 56),
        Position = UDim2.new(0, 0, 0, 2),
        ZIndex   = 12,
    }, Win)

    -- TBar glass gradient
    local tbGrad = N("Frame", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 1, 0),
        ZIndex = 13,
    }, TBar)
    Grad(tbGrad,
        ColorSequence.new({ ColorSequenceKeypoint.new(0, Token.Pure), ColorSequenceKeypoint.new(1, Token.Black) }),
        NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.9), NumberSequenceKeypoint.new(1, 1) }),
        180
    )

    -- Bottom divider (glass white)
    N("Frame", {
        BackgroundColor3 = Token.Divider,
        BackgroundTransparency = 0.88,
        Size     = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        ZIndex   = 13,
    }, TBar)

    -- Logo badge
    local badge = N("Frame", {
        BackgroundColor3 = accent,
        Size     = UDim2.new(0, 34, 0, 34),
        Position = UDim2.new(0, 14, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex   = 14,
    }, TBar)
    Corner(badge, UDim.new(0, 8))

    -- Badge glass sheen
    local badgeSheen = N("Frame", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 0.5, 0),
        ZIndex = 15,
    }, badge)
    Corner(badgeSheen, UDim.new(0, 8))
    Grad(badgeSheen, ColorSequence.new(Token.Pure, Token.Pure),
        NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.72), NumberSequenceKeypoint.new(1, 1) }), 180)

    -- Badge pulse
    local bPulse = N("Frame", {
        BackgroundColor3 = accent,
        BackgroundTransparency = 0.75,
        Size     = UDim2.new(1, 6, 1, 6),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex   = 13,
    }, badge)
    Corner(bPulse, UDim.new(0, 10))

    task.spawn(function()
        while badge and badge.Parent do
            twSpring(bPulse, { Size = UDim2.new(1, 14, 1, 14), BackgroundTransparency = 0.5 }, 2)
            task.wait(2)
            twSpring(bPulse, { Size = UDim2.new(1, 6, 1, 6), BackgroundTransparency = 0.75 }, 2)
            task.wait(2)
        end
    end)

    N("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold, Text = WCfg.LogoText,
        TextColor3 = Token.Pure, TextSize = 16, ZIndex = 16,
    }, badge)

    N("TextLabel", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(0.45, -60, 0, 20),
        Position = UDim2.new(0, 60, 0, 8),
        Font     = Enum.Font.GothamBold, Text = WCfg.Title,
        TextColor3 = Token.T1, TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
    }, TBar)

    N("TextLabel", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(0.45, -60, 0, 14),
        Position = UDim2.new(0, 60, 0, 32),
        Font     = Enum.Font.GothamMedium, Text = WCfg.Subtitle,
        TextColor3 = Token.T3, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
    }, TBar)

    -- ── Controls  [ Compact ]  [ - ]  [ + ]  [ X ] ───────────────

    local ctrlRow = N("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(0, 166, 0, 40),
        Position = UDim2.new(1, -176, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex   = 14,
    }, TBar)
    ListH(ctrlRow, UDim.new(0, 6))

    local function CtrlBtn(label, hCol, order, cb)
        local b = N("TextButton", {
            Name             = label,
            BackgroundColor3 = Token.GlassRise,
            BackgroundTransparency = 0.2,
            Size             = UDim2.new(0, 34, 0, 34),
            Font             = Enum.Font.GothamBold,
            Text             = label,
            TextColor3       = Token.T2,
            TextSize         = 14,
            AutoButtonColor  = false,
            LayoutOrder      = order,
            ZIndex           = 15,
        }, ctrlRow)
        Corner(b, UDim.new(0, 8))
        Stroke(b, Token.B1, 1, 0.85)

        b.MouseEnter:Connect(function()
            tw(b, { BackgroundColor3 = hCol, TextColor3 = Token.Pure, BackgroundTransparency = 0 }, 0.14)
        end)
        b.MouseLeave:Connect(function()
            tw(b, { BackgroundColor3 = Token.GlassRise, TextColor3 = Token.T2, BackgroundTransparency = 0.2 }, 0.14)
        end)
        b.MouseButton1Click:Connect(function()
            Ripple(b, hCol)
            if cb then cb() end
        end)
        return b
    end

    -- Compact mode button
    CtrlBtn("[ ]", Token.A1, 1, function()
        State.Compact = not State.Compact
        if State.Compact then
            -- Shrink window to 0, show compact pill
            twBack(Win, { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 },
                0.38, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            task.delay(0.4, function()
                if State.Compact then
                    Win.Visible = false
                    if CompactPill then CompactPill.Visible = true end
                end
            end)
        end
    end)

    CtrlBtn("-", Token.Warn, 2, function()
        State.Minimized = not State.Minimized
        if State.Minimized then
            twBack(Win, { Size = UDim2.new(0, WCfg.Size.X.Offset, 0, 56) },
                0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        else
            local t = State.Maximized and UDim2.new(1, -40, 1, -40) or WCfg.Size
            twBack(Win, { Size = t }, 0.3)
        end
    end)

    CtrlBtn("+", Token.Ok, 3, function()
        State.Minimized = false
        State.Maximized = not State.Maximized
        if State.Maximized then
            twBack(Win, { Size = UDim2.new(1,-40,1,-40), Position = UDim2.new(0.5,0,0.5,0) }, 0.32)
        else
            twBack(Win, { Size = WCfg.Size, Position = UDim2.new(0.5,0,0.5,0) }, 0.32)
        end
    end)

    CtrlBtn("X", Token.Err, 4, function()
        twBack(Win, { Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1 },
            0.38, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.delay(0.42, function() Gui:Destroy() end)
    end)

    -- ────────────────────────────────────────────────────────────
    --  COMPACT PILL  (floating indicator in compact mode)
    -- ────────────────────────────────────────────────────────────

    local CompactPill = N("TextButton", {
        Name             = "CompactPill",
        BackgroundColor3 = Token.GlassPanel,
        BackgroundTransparency = 0.08,
        Size     = UDim2.new(0, 120, 0, 36),
        Position = UDim2.new(0, 20, 0, 20),
        Font     = Enum.Font.GothamBold,
        Text     = "",
        AutoButtonColor = false,
        Visible  = false,
        ZIndex   = 50,
    }, Gui)
    Corner(CompactPill, UDim.new(1, 0))
    Stroke(CompactPill, Token.B1, 1, 0.7)
    Shadow(CompactPill, 0.55)

    -- Pill accent bar
    local pillBar = N("Frame", {
        BackgroundColor3 = accent,
        Size     = UDim2.new(0, 3, 0.55, 0),
        Position = UDim2.new(0, 10, 0.225, 0),
        ZIndex   = 51,
    }, CompactPill)
    Corner(pillBar, UDim.new(1, 0))

    N("TextLabel", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(1, -28, 1, 0),
        Position = UDim2.new(0, 22, 0, 0),
        Font     = Enum.Font.GothamBold,
        Text     = WCfg.Title,
        TextColor3 = Token.T1, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex   = 51,
    }, CompactPill)

    -- Pill drag
    local pillDrag = false
    local pillOrigin, pillPos

    CompactPill.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            pillDrag = true; pillOrigin = i.Position; pillPos = CompactPill.Position
        end
    end)
    CompactPill.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            pillDrag = false
        end
    end)

    CompactPill.MouseButton1Click:Connect(function()
        State.Compact = false
        CompactPill.Visible = false
        Win.Visible = true
        Win.Size = UDim2.new(0, 0, 0, 0)
        Win.BackgroundTransparency = 1
        twBack(Win, { Size = WCfg.Size, BackgroundTransparency = 0.05 }, 0.5)
    end)

    UserInputService.InputChanged:Connect(function(i)
        if pillDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - pillOrigin
            CompactPill.Position = UDim2.new(pillPos.X.Scale, pillPos.X.Offset + d.X, pillPos.Y.Scale, pillPos.Y.Offset + d.Y)
        end
    end)

    -- ── Drag (window) ─────────────────────────────────────────────

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

    -- Toggle key
    UserInputService.InputBegan:Connect(function(i, gpe)
        if not gpe and i.KeyCode == WCfg.ToggleKey then
            if not State.Compact then
                Win.Visible = not Win.Visible
            end
        end
    end)

    -- ── Body ──────────────────────────────────────────────────────

    local Body = N("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(1, 0, 1, -58),
        Position = UDim2.new(0, 0, 0, 58),
        ZIndex   = 11,
    }, Win)

    -- ── Sidebar (glass) ───────────────────────────────────────────

    local Sidebar = N("Frame", {
        BackgroundColor3       = Token.GlassPanel,
        BackgroundTransparency = 0.1,
        Size     = UDim2.new(0, 164, 1, 0),
        ZIndex   = 11,
    }, Body)

    -- Sidebar glass sheen
    local sSheen = N("Frame", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 0.4, 0),
        ZIndex = 12,
    }, Sidebar)
    Grad(sSheen, ColorSequence.new(Token.Pure, Token.Pure),
        NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.93), NumberSequenceKeypoint.new(1, 1) }), 180)

    -- Divider
    N("Frame", {
        BackgroundColor3 = Token.Divider, BackgroundTransparency = 0.86,
        Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, 0, 0, 0), ZIndex = 12,
    }, Sidebar)

    -- Sidebar scroll
    local SideScroll = N("ScrollingFrame", {
        BackgroundTransparency  = 1,
        Size     = UDim2.new(1, -10, 1, -16),
        Position = UDim2.new(0, 5, 0, 8),
        CanvasSize           = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize  = Enum.AutomaticSize.Y,
        ScrollBarThickness   = 2,
        ScrollBarImageColor3 = Token.T4,
        BorderSizePixel = 0,
        ZIndex = 12,
    }, Sidebar)
    ListV(SideScroll, UDim.new(0, 4))

    -- ── Content area ──────────────────────────────────────────────

    local ContentWrap = N("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(1, -166, 1, 0),
        Position = UDim2.new(0, 166, 0, 0),
        ClipsDescendants = true,
        ZIndex   = 11,
    }, Body)

    -- ────────────────────────────────────────────────────────────
    --  COMMAND PALETTE  (Ctrl + Shift + P)
    -- ────────────────────────────────────────────────────────────

    local PaletteFrame = N("Frame", {
        BackgroundColor3       = Token.GlassBase,
        BackgroundTransparency = 0.05,
        Size     = UDim2.new(0, 440, 0, 56),
        Position = UDim2.new(0.5, 0, 0, -100),
        AnchorPoint = Vector2.new(0.5, 0),
        ZIndex   = 200,
        Visible  = false,
        ClipsDescendants = true,
    }, Gui)
    Corner(PaletteFrame, UDim.new(0, 12))
    Stroke(PaletteFrame, Token.B1, 1, 0.65)
    Shadow(PaletteFrame, 0.38)
    NeonLine(PaletteFrame, accent, accentCy)

    -- Palette input
    local PaletteBox = N("TextBox", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(1, 0, 0, 46),
        Position = UDim2.new(0, 0, 0, 0),
        Font     = Enum.Font.GothamMedium,
        PlaceholderText  = "Type a command...",
        PlaceholderColor3 = Token.T3,
        Text     = "",
        TextColor3 = Token.T1, TextSize = 14,
        ClearTextOnFocus = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex   = 201,
    }, PaletteFrame)
    Pad(PaletteBox, 0, 16, 0, 46)

    -- Palette search icon text
    N("TextLabel", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(0, 34, 0, 46),
        Position = UDim2.new(0, 0, 0, 0),
        Font     = Enum.Font.GothamBold,
        Text     = ">_",
        TextColor3 = accent, TextSize = 14, ZIndex = 201,
    }, PaletteFrame)

    -- Results list
    local PaletteResults = N("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 48),
        ZIndex   = 201,
    }, PaletteFrame)
    ListV(PaletteResults, UDim.new(0, 2))

    local function BuildPaletteResults(query)
        for _, c in ipairs(PaletteResults:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end
        local results = {}
        for _, cmd in ipairs(State.Commands) do
            local match = query == "" or string.find(string.lower(cmd.Name), string.lower(query), 1, true)
            if match then table.insert(results, cmd) end
        end

        local itemH = 36
        local listH = math.min(#results, 6) * (itemH + 2)
        local targetH = 56 + (listH > 0 and listH + 8 or 0)
        tw(PaletteFrame, { Size = UDim2.new(0, 440, 0, targetH) }, 0.18)

        for i, cmd in ipairs(results) do
            if i > 6 then break end
            local item = N("TextButton", {
                BackgroundColor3 = Token.GlassSurface,
                BackgroundTransparency = 0.15,
                Size     = UDim2.new(1, -16, 0, itemH),
                Font     = Enum.Font.GothamMedium,
                Text     = "",
                AutoButtonColor = false,
                LayoutOrder = i,
                ZIndex   = 202,
            }, PaletteResults)
            Corner(item, UDim.new(0, 7))

            -- Command name
            N("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0.7, -8, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                Font     = Enum.Font.GothamMedium,
                Text     = cmd.Name,
                TextColor3 = Token.T1, TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 203,
            }, item)

            -- Command tag
            if cmd.Tag then
                local tag = N("TextLabel", {
                    BackgroundColor3 = accent, BackgroundTransparency = 0.7,
                    Size     = UDim2.new(0, 0, 0, 20),
                    Position = UDim2.new(1, -8, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5),
                    Font     = Enum.Font.Code,
                    Text     = cmd.Tag,
                    TextColor3 = accentHi, TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    AutomaticSize = Enum.AutomaticSize.X,
                    ZIndex   = 203,
                }, item)
                Corner(tag, UDim.new(0, 5))
                Pad(tag, 0, 8, 0, 8)
            end

            item.MouseEnter:Connect(function()
                tw(item, { BackgroundTransparency = 0, BackgroundColor3 = Token.GlassLift }, 0.12)
            end)
            item.MouseLeave:Connect(function()
                tw(item, { BackgroundTransparency = 0.15, BackgroundColor3 = Token.GlassSurface }, 0.12)
            end)
            item.MouseButton1Click:Connect(function()
                Ripple(item, accent)
                task.delay(0.1, function()
                    if cmd.Action then cmd.Action() end
                    -- Close palette
                    State.PaletteOpen = false
                    PaletteBox.Text = ""
                    twSine(PaletteFrame, { Position = UDim2.new(0.5, 0, 0, -200) }, 0.28)
                    task.delay(0.3, function() PaletteFrame.Visible = false end)
                end)
            end)
        end
    end

    PaletteBox:GetPropertyChangedSignal("Text"):Connect(function()
        BuildPaletteResults(PaletteBox.Text)
    end)

    -- Ctrl + Shift + P to open palette
    UserInputService.InputBegan:Connect(function(i, gpe)
        if gpe then return end

        local ctrl  = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
        local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)   or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)

        if ctrl and shift and i.KeyCode == WCfg.PaletteKey then
            State.PaletteOpen = not State.PaletteOpen
            if State.PaletteOpen then
                PaletteFrame.Visible = true
                PaletteFrame.Size    = UDim2.new(0, 440, 0, 56)
                PaletteBox.Text      = ""
                BuildPaletteResults("")
                PaletteFrame.Position = UDim2.new(0.5, 0, 0, -100)
                twBack(PaletteFrame, { Position = UDim2.new(0.5, 0, 0, 40) }, 0.42)
                task.delay(0.1, function() PaletteBox:CaptureFocus() end)
            else
                twSine(PaletteFrame, { Position = UDim2.new(0.5, 0, 0, -200) }, 0.28)
                task.delay(0.3, function() PaletteFrame.Visible = false end)
            end
        end

        -- Escape closes palette
        if i.KeyCode == Enum.KeyCode.Escape and State.PaletteOpen then
            State.PaletteOpen = false
            twSine(PaletteFrame, { Position = UDim2.new(0.5, 0, 0, -200) }, 0.28)
            task.delay(0.3, function() PaletteFrame.Visible = false end)
        end
    end)

    -- ────────────────────────────────────────────────────────────
    --  WINDOW API
    -- ────────────────────────────────────────────────────────────

    local Window = { Notify = Notify }

    -- Register a command palette entry
    function Window:RegisterCommand(name, tag, action)
        table.insert(State.Commands, { Name = name, Tag = tag or nil, Action = action })
    end

    -- ── Tab Builder ───────────────────────────────────────────────

    function Window:CreateTab(tabCfg)
        tabCfg = tabCfg or {}
        local tName  = tabCfg.Name  or "Tab"
        local tIcon  = tabCfg.Icon  or ""
        local tOrder = tabCfg.Order or (#State.Tabs + 1)

        -- Sidebar button
        local TabBtn = N("TextButton", {
            BackgroundColor3       = Token.GlassLift,
            BackgroundTransparency = 1,
            Size     = UDim2.new(1, -6, 0, 44),
            Text     = "",
            AutoButtonColor = false,
            LayoutOrder = tOrder,
            ZIndex   = 13,
        }, SideScroll)
        Corner(TabBtn, UDim.new(0, 9))

        -- Active glow (glass-style)
        local TabGlow = N("Frame", {
            BackgroundColor3 = accent,
            BackgroundTransparency = 1,
            Size   = UDim2.new(1, 0, 1, 0),
            ZIndex = 12,
        }, TabBtn)
        Corner(TabGlow, UDim.new(0, 9))
        Grad(TabGlow,
            ColorSequence.new({ ColorSequenceKeypoint.new(0, accent), ColorSequenceKeypoint.new(1, Token.Black) }),
            NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.82), NumberSequenceKeypoint.new(1, 1) }),
            0
        )

        local TabIcn = N("TextLabel", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(0, 36, 1, 0),
            Position = UDim2.new(0, 6, 0, 0),
            Font     = Enum.Font.GothamMedium,
            Text     = tIcon, TextColor3 = Token.T4, TextSize = 15, ZIndex = 14,
        }, TabBtn)

        local TabLbl = N("TextLabel", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(1, -50, 1, 0),
            Position = UDim2.new(0, 44, 0, 0),
            Font     = Enum.Font.GothamMedium,
            Text     = tName, TextColor3 = Token.T2, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
        }, TabBtn)

        local TabInd = N("Frame", {
            BackgroundColor3 = accent,
            Size     = UDim2.new(0, 3, 0, 0),
            Position = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            ZIndex   = 14,
        }, TabBtn)
        Corner(TabInd, UDim.new(1, 0))

        -- Page
        local Page = N("ScrollingFrame", {
            BackgroundTransparency  = 1,
            Size     = UDim2.new(1, -14, 1, -14),
            Position = UDim2.new(0, 7, 0, 7),
            CanvasSize           = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize  = Enum.AutomaticSize.Y,
            ScrollBarThickness   = 3,
            ScrollBarImageColor3 = Token.T4,
            BorderSizePixel = 0,
            Visible = false, ZIndex = 12,
        }, ContentWrap)
        ListV(Page, UDim.new(0, 6))
        Pad(Page, 5, 5, 5, 5)

        local td = { Btn = TabBtn, Page = Page, Ind = TabInd, Glow = TabGlow, Icn = TabIcn, Lbl = TabLbl }
        table.insert(State.Tabs, td)

        local function Select()
            for _, t in ipairs(State.Tabs) do
                t.Page.Visible = false
                tw(t.Btn,  { BackgroundTransparency = 1 },           0.18)
                tw(t.Glow, { BackgroundTransparency = 1 },           0.18)
                tw(t.Ind,  { Size = UDim2.new(0, 3, 0, 0) },        0.18)
                tw(t.Lbl,  { TextColor3 = Token.T2 },                0.18)
                tw(t.Icn,  { TextColor3 = Token.T4 },                0.18)
            end
            td.Page.Visible = true
            State.ActiveTab = td
            tw(td.Btn,  { BackgroundTransparency = 0.72 },       0.18)
            tw(td.Glow, { BackgroundTransparency = 0.85 },       0.18)
            tw(td.Lbl,  { TextColor3 = Token.T1 },               0.18)
            tw(td.Icn,  { TextColor3 = accent },                 0.18)
            twBack(td.Ind, { Size = UDim2.new(0, 3, 0, 26) },   0.28)
        end

        TabBtn.MouseEnter:Connect(function()
            if State.ActiveTab ~= td then tw(TabBtn, { BackgroundTransparency = 0.84 }, 0.13) end
        end)
        TabBtn.MouseLeave:Connect(function()
            if State.ActiveTab ~= td then tw(TabBtn, { BackgroundTransparency = 1 }, 0.13) end
        end)
        TabBtn.MouseButton1Click:Connect(Select)
        if #State.Tabs == 1 then Select() end

        -- ──────────────────────────────────────────────────────
        --  ELEMENT BUILDERS
        -- ──────────────────────────────────────────────────────

        local Tab = {}

        -- helper: base glass row
        local function GlassRow(height)
            local row = N("Frame", {
                BackgroundColor3       = Token.GlassSurface,
                BackgroundTransparency = 0.08,
                Size     = UDim2.new(1, 0, 0, height),
                LayoutOrder = #Page:GetChildren(),
                ZIndex   = 13,
            }, Page)
            Corner(row, UDim.new(0, 9))
            Stroke(row, Token.B1, 1, 0.88)
            -- Row sheen
            local sh = N("Frame", {
                BackgroundTransparency = 1,
                Size   = UDim2.new(1, 0, 0.5, 0),
                ZIndex = 14,
            }, row)
            Corner(sh, UDim.new(0, 9))
            Grad(sh, ColorSequence.new(Token.Pure, Token.Pure),
                NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.93), NumberSequenceKeypoint.new(1, 1) }), 180)
            HoverBind(row, Token.GlassSurface, Token.GlassLift)
            return row
        end

        -- SECTION ─────────────────────────────────────────────

        function Tab:CreateSection(name)
            local sf = N("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 26),
                LayoutOrder = #Page:GetChildren(), ZIndex = 13,
            }, Page)

            N("Frame", {
                BackgroundColor3 = Token.Divider, BackgroundTransparency = 0.85,
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
                TextColor3 = Token.T3, TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13,
            }, sf)

            N("Frame", {
                BackgroundColor3 = Token.Divider, BackgroundTransparency = 0.85,
                Size = UDim2.new(0.44, 0, 0, 1),
                Position = UDim2.new(0.56, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), ZIndex = 13,
            }, sf)
        end

        -- TOGGLE ──────────────────────────────────────────────

        function Tab:CreateToggle(opts)
            opts = opts or {}
            local val = opts.Default or false
            local row = GlassRow(opts.Description and 50 or 44)

            local strip = N("Frame", {
                BackgroundColor3 = accent, BackgroundTransparency = val and 0 or 1,
                Size = UDim2.new(0, 2, 0.52, 0), Position = UDim2.new(0, 0, 0.24, 0), ZIndex = 15,
            }, row)

            N("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.65, -14, 0, 18),
                Position = UDim2.new(0, 14, 0, opts.Description and 6 or 13),
                Font = Enum.Font.GothamMedium, Text = opts.Name or "Toggle",
                TextColor3 = Token.T1, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 15,
            }, row)

            if opts.Description then
                N("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.65, -14, 0, 13),
                    Position = UDim2.new(0, 14, 0, 28),
                    Font = Enum.Font.GothamMedium, Text = opts.Description,
                    TextColor3 = Token.T3, TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 15,
                }, row)
            end

            local track = N("Frame", {
                BackgroundColor3 = val and accent or Token.GlassRise,
                Size = UDim2.new(0, 48, 0, 26),
                Position = UDim2.new(1, -62, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), ZIndex = 15,
            }, row)
            Corner(track, UDim.new(1, 0))

            -- Track glass sheen
            local tsh = N("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0.5, 0), ZIndex = 16,
            }, track)
            Corner(tsh, UDim.new(1, 0))
            Grad(tsh, ColorSequence.new(Token.Pure, Token.Pure),
                NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(1, 1) }), 180)

            local knob = N("Frame", {
                BackgroundColor3 = Token.Pure,
                Size = UDim2.new(0, 20, 0, 20),
                Position = val and UDim2.new(1, -23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5), ZIndex = 17,
            }, track)
            Corner(knob, UDim.new(1, 0))

            -- Knob subtle gradient
            local kGrad = N("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), ZIndex = 18 }, knob)
            Corner(kGrad, UDim.new(1, 0))
            Grad(kGrad, ColorSequence.new(Token.Pure, Token.H1), NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.35),
            }), 180)

            local function refresh()
                if val then
                    tw(track, { BackgroundColor3 = accent }, 0.2)
                    tw(strip, { BackgroundTransparency = 0 }, 0.2)
                    twBack(knob, { Position = UDim2.new(1, -23, 0.5, 0) }, 0.24)
                else
                    tw(track, { BackgroundColor3 = Token.GlassRise }, 0.2)
                    tw(strip, { BackgroundTransparency = 1 }, 0.2)
                    twBack(knob, { Position = UDim2.new(0, 3, 0.5, 0) }, 0.24)
                end
                if opts.Callback then opts.Callback(val) end
            end

            local cz = N("TextButton", { BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Text="", ZIndex=19 }, row)
            cz.MouseButton1Click:Connect(function() val = not val; refresh() end)

            local API = {}
            function API:Set(v) val = v; refresh() end
            function API:Get() return val end
            return API
        end

        -- SLIDER ──────────────────────────────────────────────

        function Tab:CreateSlider(opts)
            opts = opts or {}
            local mn, mx, cur, stp = opts.Min or 0, opts.Max or 100, opts.Default or 0, opts.Increment or 1

            local row = GlassRow(60)

            N("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.65, -14, 0, 18), Position = UDim2.new(0, 14, 0, 8),
                Font = Enum.Font.GothamMedium, Text = opts.Name or "Slider",
                TextColor3 = Token.T1, TextSize = 13,
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
                BackgroundColor3 = Token.GlassRise,
                Size = UDim2.new(1, -28, 0, 5), Position = UDim2.new(0, 14, 0, 42), ZIndex = 15,
            }, row)
            Corner(track, UDim.new(1, 0))

            local p0   = (cur - mn) / (mx - mn)
            local fill = N("Frame", { BackgroundColor3 = accent, Size = UDim2.new(p0, 0, 1, 0), ZIndex = 16 }, track)
            Corner(fill, UDim.new(1, 0))
            Grad(fill, ColorSequence.new({ ColorSequenceKeypoint.new(0, Token.A3), ColorSequenceKeypoint.new(1, accentCy) }), NumberSequence.new(0))

            local knob = N("Frame", {
                BackgroundColor3 = Token.Pure,
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(p0, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 18,
            }, track)
            Corner(knob, UDim.new(1, 0))
            Stroke(knob, accent, 2)

            local dragging = false
            local function applyX(px)
                local rel = math.clamp((px - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                cur = math.clamp(math.floor((mn + (mx - mn) * rel) / stp + 0.5) * stp, mn, mx)
                local p = (cur - mn) / (mx - mn)
                fill.Size = UDim2.new(p, 0, 1, 0)
                knob.Position = UDim2.new(p, 0, 0.5, 0)
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
                vLbl.Text = tostring(cur)
            end
            function API:Get() return cur end
            return API
        end

        -- BUTTON ──────────────────────────────────────────────

        function Tab:CreateButton(opts)
            opts = opts or {}
            local row = GlassRow(44)

            N("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.65, -14, 1, 0), Position = UDim2.new(0, 14, 0, 0),
                Font = Enum.Font.GothamMedium, Text = opts.Name or "Button",
                TextColor3 = Token.T1, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 15,
            }, row)

            local btn = N("TextButton", {
                BackgroundColor3 = accent,
                BackgroundTransparency = 0.08,
                Size = UDim2.new(0, 80, 0, 30),
                Position = UDim2.new(1, -92, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
                Font = Enum.Font.GothamBold, Text = opts.ButtonText or "Run",
                TextColor3 = Token.Pure, TextSize = 12,
                AutoButtonColor = false, ZIndex = 15,
            }, row)
            Corner(btn, UDim.new(0, 8))
            Stroke(btn, Token.B1, 1, 0.75)

            -- Button glass sheen
            local bsh = N("Frame", {
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0.5, 0), ZIndex = 16,
            }, btn)
            Corner(bsh, UDim.new(0, 8))
            Grad(bsh, ColorSequence.new(Token.Pure, Token.Pure),
                NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.75), NumberSequenceKeypoint.new(1, 1) }), 180)

            btn.MouseEnter:Connect(function()
                tw(btn, { BackgroundColor3 = accentHi, BackgroundTransparency = 0 }, 0.14)
            end)
            btn.MouseLeave:Connect(function()
                tw(btn, { BackgroundColor3 = accent, BackgroundTransparency = 0.08 }, 0.14)
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

            local wrap = N("Frame", {
                BackgroundColor3       = Token.GlassSurface,
                BackgroundTransparency = 0.08,
                Size = UDim2.new(1, 0, 0, 44),
                ClipsDescendants = true,
                LayoutOrder = #Page:GetChildren(), ZIndex = 13,
            }, Page)
            Corner(wrap, UDim.new(0, 9))
            Stroke(wrap, Token.B1, 1, 0.88)

            local wsh = N("Frame", { BackgroundTransparency=1, Size=UDim2.new(1,0,0.45,0), ZIndex=14 }, wrap)
            Corner(wsh, UDim.new(0, 9))
            Grad(wsh, ColorSequence.new(Token.Pure, Token.Pure),
                NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.93), NumberSequenceKeypoint.new(1, 1) }), 180)

            N("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.45, -8, 0, 44), Position = UDim2.new(0, 14, 0, 0),
                Font = Enum.Font.GothamMedium, Text = opts.Name or "Dropdown",
                TextColor3 = Token.T1, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 15,
            }, wrap)

            local selBtn = N("TextButton", {
                BackgroundColor3 = Token.GlassRise, BackgroundTransparency = 0.2,
                Size = UDim2.new(0.5, -14, 0, 28), Position = UDim2.new(0.5, 0, 0, 8),
                Font = Enum.Font.GothamMedium, Text = current .. "  v",
                TextColor3 = Token.T2, TextSize = 12, AutoButtonColor = false, ZIndex = 16,
            }, wrap)
            Corner(selBtn, UDim.new(0, 7))
            Stroke(selBtn, Token.B1, 1, 0.82)

            local ibox = N("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -16, 0, 0), Position = UDim2.new(0, 8, 0, 46), ZIndex = 16,
            }, wrap)
            ListV(ibox, UDim.new(0, 2))

            local function buildItems()
                for _, c in ipairs(ibox:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for i, item in ipairs(items) do
                    local ib = N("TextButton", {
                        BackgroundColor3 = Token.GlassLift, BackgroundTransparency = 0.3,
                        Size = UDim2.new(1, 0, 0, 30), Font = Enum.Font.GothamMedium,
                        Text = item, TextColor3 = item == current and accent or Token.T2,
                        TextSize = 12, AutoButtonColor = false, LayoutOrder = i, ZIndex = 17,
                    }, ibox)
                    Corner(ib, UDim.new(0, 6))
                    ib.MouseEnter:Connect(function() tw(ib, { BackgroundTransparency = 0, TextColor3 = Token.T1 }, 0.12) end)
                    ib.MouseLeave:Connect(function() tw(ib, { BackgroundTransparency = 0.3, TextColor3 = item == current and accent or Token.T2 }, 0.12) end)
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
                    twBack(wrap, { Size = UDim2.new(1, 0, 0, 52 + #items * 32) }, 0.3)
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

        -- INPUT ───────────────────────────────────────────────

        function Tab:CreateInput(opts)
            opts = opts or {}
            local row = GlassRow(44)

            N("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.4, -8, 1, 0), Position = UDim2.new(0, 14, 0, 0),
                Font = Enum.Font.GothamMedium, Text = opts.Name or "Input",
                TextColor3 = Token.T1, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 15,
            }, row)

            local box = N("TextBox", {
                BackgroundColor3 = Token.GlassRise, BackgroundTransparency = 0.18,
                Size = UDim2.new(0.56, -14, 0, 28),
                Position = UDim2.new(0.44, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
                Font = Enum.Font.GothamMedium,
                PlaceholderText = opts.Placeholder or "Value...",
                PlaceholderColor3 = Token.T3,
                Text = opts.Default or "",
                TextColor3 = Token.T1, TextSize = 12,
                ClearTextOnFocus = opts.ClearOnFocus or false, ZIndex = 15,
            }, row)
            Corner(box, UDim.new(0, 7))
            N("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, box)
            local bstk = Stroke(box, Token.B2, 1, 0.4)

            box.Focused:Connect(function()
                tw(bstk, { Color = accent, Transparency = 0 }, 0.18)
                tw(box,  { BackgroundColor3 = Token.GlassLift, BackgroundTransparency = 0.1 }, 0.18)
            end)
            box.FocusLost:Connect(function(enter)
                tw(bstk, { Color = Token.B2, Transparency = 0.4 }, 0.18)
                tw(box,  { BackgroundColor3 = Token.GlassRise, BackgroundTransparency = 0.18 }, 0.18)
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
            local key = opts.Default or Enum.KeyCode.E
            local listening = false

            local row = GlassRow(44)

            N("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.62, -14, 1, 0), Position = UDim2.new(0, 14, 0, 0),
                Font = Enum.Font.GothamMedium, Text = opts.Name or "Keybind",
                TextColor3 = Token.T1, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 15,
            }, row)

            local kbtn = N("TextButton", {
                BackgroundColor3 = Token.GlassRise, BackgroundTransparency = 0.18,
                Size = UDim2.new(0, 80, 0, 28),
                Position = UDim2.new(1, -94, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
                Font = Enum.Font.Code, Text = key.Name,
                TextColor3 = accent, TextSize = 12, AutoButtonColor = false, ZIndex = 15,
            }, row)
            Corner(kbtn, UDim.new(0, 7))
            Stroke(kbtn, accent, 1, 0.5)

            kbtn.MouseButton1Click:Connect(function()
                listening = true; kbtn.Text = "..."
                tw(kbtn, { BackgroundColor3 = accent, BackgroundTransparency = 0 }, 0.14)
                kbtn.TextColor3 = Token.Pure
            end)

            UserInputService.InputBegan:Connect(function(i)
                if listening and i.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false; key = i.KeyCode; kbtn.Text = key.Name
                    tw(kbtn, { BackgroundColor3 = Token.GlassRise, BackgroundTransparency = 0.18 }, 0.14)
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
            local row = N("Frame", {
                BackgroundColor3 = Token.GlassSurface, BackgroundTransparency = 0.35,
                Size = UDim2.new(1, 0, 0, 32),
                LayoutOrder = #Page:GetChildren(), ZIndex = 13,
            }, Page)
            Corner(row, UDim.new(0, 9))

            local dot = N("Frame", {
                BackgroundColor3 = accent, Size = UDim2.new(0, 4, 0, 4),
                Position = UDim2.new(0, 13, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), ZIndex = 14,
            }, row)
            Corner(dot, UDim.new(1, 0))

            local lbl = N("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -28, 1, 0), Position = UDim2.new(0, 26, 0, 0),
                Font = Enum.Font.GothamMedium, Text = opts.Text or "Label",
                TextColor3 = Token.T2, TextSize = 12,
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
            local color = opts.Default or Color3.new(1, 1, 1)
            local row   = GlassRow(44)

            N("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.65, -14, 1, 0), Position = UDim2.new(0, 14, 0, 0),
                Font = Enum.Font.GothamMedium, Text = opts.Name or "Color",
                TextColor3 = Token.T1, TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 15,
            }, row)

            local swatch = N("Frame", {
                BackgroundColor3 = color,
                Size = UDim2.new(0, 30, 0, 30),
                Position = UDim2.new(1, -44, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), ZIndex = 16,
            }, row)
            Corner(swatch, UDim.new(0, 7))
            Stroke(swatch, Token.B1, 1, 0.7)

            local API = {}
            function API:Set(c) color = c; swatch.BackgroundColor3 = c; if opts.Callback then opts.Callback(c) end end
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
        Notify({ Title = "Config Saved", Content = (name or WCfg.ConfigName) .. ".json", Type = "Success", Duration = 3 })
        return out
    end

    function Window:LoadConfig(name, data)
        if type(data) == "table" then
            for k, v in pairs(data) do State.Data[k] = v end
            Notify({ Title = "Config Loaded", Content = name or "config", Type = "Info", Duration = 3 })
        else
            pcall(function()
                if readfile and isfile then
                    local p = (name or WCfg.ConfigName) .. ".json"
                    if isfile(p) then
                        for k, v in pairs(HttpService:JSONDecode(readfile(p))) do State.Data[k] = v end
                        Notify({ Title = "Config Loaded", Content = p, Type = "Info", Duration = 3 })
                    end
                end
            end)
        end
    end

    function Window:SetCompact(bool)
        if bool and not State.Compact then
            State.Compact = true
            twBack(Win, { Size = UDim2.new(0,0,0,0), BackgroundTransparency=1 }, 0.38, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            task.delay(0.4, function()
                Win.Visible = false
                CompactPill.Visible = true
            end)
        elseif not bool and State.Compact then
            State.Compact = false
            CompactPill.Visible = false
            Win.Visible = true
            Win.Size = UDim2.new(0,0,0,0)
            Win.BackgroundTransparency = 1
            twBack(Win, { Size = WCfg.Size, BackgroundTransparency = 0.05 }, 0.5)
        end
    end

    function Window:Destroy()
        twBack(Win, { Size = UDim2.new(0,0,0,0), BackgroundTransparency=1 }, 0.38, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.delay(0.42, function() Gui:Destroy() end)
    end

    -- Startup notify
    task.delay(0.7, function()
        Notify({
            Title   = WCfg.Title .. " Ready",
            Content = "Press Ctrl+Shift+P for Command Palette  |  " .. tostring(WCfg.ToggleKey.Name) .. " to toggle",
            Type    = "Info",
            Duration = 5,
        })
    end)

    return Window
end

return NexusLib
