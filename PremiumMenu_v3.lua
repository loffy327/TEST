--[[
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║                   PremiumMenu v3                             ║
║           Roblox Luau UI Library  |  Full Source             ║
║                                                              ║
║   Developer  :  loffy327                                     ║
║   Version    :  3.0.0                                        ║
║   License    :  Full Source  -  4,000,000 VND                ║
║                                                              ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║   NEW IN V3:                                                 ║
║   - Smooth scrolling Dropdowns (unlimited items)             ║
║   - Multi-Select Dropdowns                                   ║
║   - Paragraph Elements for large text blocks                 ║
║   - Sliders with Text Input (Manual typing support)          ║
║   - Upgraded micro-animations and aesthetic shadows          ║
║   - Seamless backwards compatibility                         ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
]]

local PremiumMenu = {}
PremiumMenu.__index = PremiumMenu
PremiumMenu.Version = "3.0.0"

-- ================================================================
--  SERVICES
-- ================================================================

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- ================================================================
--  DEFAULT THEME
-- ================================================================

local DefaultTheme = {
    -- Backgrounds
    BG          = Color3.fromRGB(15, 15, 20),
    BGAlt       = Color3.fromRGB(20, 20, 28),
    Surface     = Color3.fromRGB(25, 25, 35),
    SurfaceHov  = Color3.fromRGB(32, 32, 45),
    SurfaceAct  = Color3.fromRGB(40, 40, 55),

    -- Accent (overridable)
    Accent      = Color3.fromRGB(99, 102, 241),
    AccentHov   = Color3.fromRGB(120, 123, 255),
    AccentDim   = Color3.fromRGB(65, 68, 200),

    -- Text
    TxtHigh     = Color3.fromRGB(240, 240, 250),
    TxtMid      = Color3.fromRGB(160, 160, 180),
    TxtLow      = Color3.fromRGB(90, 90, 110),

    -- Borders
    Border      = Color3.fromRGB(45, 45, 60),
    BorderHov   = Color3.fromRGB(65, 65, 85),

    -- Status
    Green       = Color3.fromRGB(34, 197, 94),
    Yellow      = Color3.fromRGB(250, 204, 21),
    Red         = Color3.fromRGB(239, 68, 68),
    Blue        = Color3.fromRGB(56, 189, 248),

    -- Misc
    Divider     = Color3.fromRGB(35, 35, 50),
    Scrollbar   = Color3.fromRGB(60, 60, 80),

    -- Font
    FontBold    = Enum.Font.GothamBold,
    FontMed     = Enum.Font.GothamMedium,
    FontMono    = Enum.Font.Code,

    -- Radius
    RadiusLg    = UDim.new(0, 10),
    RadiusMd    = UDim.new(0, 8),
    RadiusSm    = UDim.new(0, 6),
    RadiusXs    = UDim.new(0, 4),

    -- Timing
    TweenTime   = 0.2,
    TweenStyle  = Enum.EasingStyle.Quint,
}

-- ================================================================
--  INTERNAL UTILITIES
-- ================================================================

local Util = {}

function Util.Tween(obj, props, t, style, dir)
    local info = TweenInfo.new(
        t     or DefaultTheme.TweenTime,
        style or DefaultTheme.TweenStyle,
        dir   or Enum.EasingDirection.Out
    )
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

function Util.New(class, props)
    local obj = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            obj[k] = v
        end
    end
    return obj
end

function Util.Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or DefaultTheme.RadiusMd
    c.Parent = parent
    return c
end

function Util.Stroke(parent, color, thick, transp)
    local s = Instance.new("UIStroke")
    s.Color        = color or DefaultTheme.Border
    s.Thickness    = thick or 1
    s.Transparency = transp or 0
    s.Parent       = parent
    return s
end

function Util.Padding(parent, t, r, b, l)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 8)
    p.PaddingRight  = UDim.new(0, r or 8)
    p.PaddingBottom = UDim.new(0, b or 8)
    p.PaddingLeft   = UDim.new(0, l or 8)
    p.Parent = parent
    return p
end

function Util.ListLayout(parent, dir, halign, valign, pad)
    local l = Instance.new("UIListLayout")
    l.FillDirection         = dir    or Enum.FillDirection.Vertical
    l.HorizontalAlignment   = halign or Enum.HorizontalAlignment.Left
    l.VerticalAlignment     = valign or Enum.VerticalAlignment.Top
    l.Padding               = pad    or UDim.new(0, 6)
    l.SortOrder             = Enum.SortOrder.LayoutOrder
    l.Parent = parent
    return l
end

function Util.Shadow(parent)
    local s = Util.New("ImageLabel", {
        Name               = "_Shadow",
        BackgroundTransparency = 1,
        Image              = "rbxassetid://6014261993",
        ImageColor3        = Color3.new(0, 0, 0),
        ImageTransparency  = 0.6,
        Size               = UDim2.new(1, 40, 1, 40),
        Position           = UDim2.new(0, -20, 0, -20),
        ZIndex             = parent.ZIndex - 1,
        ScaleType          = Enum.ScaleType.Slice,
        SliceCenter        = Rect.new(49, 49, 450, 450),
        Parent             = parent,
    })
    return s
end

function Util.Ripple(btn, color)
    local rip = Util.New("Frame", {
        Name                = "_Ripple",
        BackgroundColor3    = color or Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.8,
        Size                = UDim2.new(0, 0, 0, 0),
        Position            = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint         = Vector2.new(0.5, 0.5),
        ZIndex              = btn.ZIndex + 5,
        Parent              = btn,
    })
    Util.Corner(rip, UDim.new(1, 0))
    Util.Tween(rip, {
        Size = UDim2.new(2.5, 0, 2.5, 0),
        BackgroundTransparency = 1
    }, 0.5, Enum.EasingStyle.Quad)
    task.delay(0.6, function()
        if rip and rip.Parent then rip:Destroy() end
    end)
end

function Util.HoverBind(frame, normal, hover, prop)
    prop = prop or "BackgroundColor3"
    frame.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement then
            Util.Tween(frame, {[prop] = hover}, 0.15)
        end
    end)
    frame.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement then
            Util.Tween(frame, {[prop] = normal}, 0.15)
        end
    end)
end

function Util.GetTextBounds(text, font, size, bounds)
    local textLabel = Util.New("TextLabel", {
        Text = text,
        Font = font,
        TextSize = size,
        Size = UDim2.new(0, bounds.X, 0, bounds.Y),
        TextWrapped = true,
    })
    local result = textLabel.TextBounds
    textLabel:Destroy()
    return result
end


-- ================================================================
--  CREATE WINDOW
-- ================================================================

function PremiumMenu:CreateWindow(cfg)
    cfg = cfg or {}

    local T = cfg.Theme or DefaultTheme

    if cfg.AccentColor then
        T = {}
        for k, v in pairs(DefaultTheme) do T[k] = v end
        T.Accent    = cfg.AccentColor
        T.AccentHov = cfg.AccentColor
        T.AccentDim = cfg.AccentColor
    end

    local WCfg = {
        Title        = cfg.Title        or "PremiumMenu",
        Subtitle     = cfg.Subtitle     or "v3.0",
        LogoText     = cfg.LogoText     or "P",
        LogoImage    = cfg.LogoImage    or nil,
        Size         = cfg.Size         or UDim2.new(0, 620, 0, 450),
        MinSize      = cfg.MinSize      or UDim2.new(0, 620, 0, 52),
        ConfigKey    = cfg.ConfigKey    or "PMv3Config",
        ToggleKey    = cfg.ToggleKey    or Enum.KeyCode.RightShift,
        TutorialMode = (cfg.TutorialMode == nil) and true or cfg.TutorialMode,
    }

    -- ============================================================
    --  STATE
    -- ============================================================

    local State = {
        Minimized  = false,
        Maximized  = false,
        Dragging   = false,
        DragOrigin = nil,
        DragPos    = nil,
        ActiveTab  = nil,
        Tabs       = {},
        Data       = {},
    }

    -- ============================================================
    --  SCREEN GUI
    -- ============================================================

    local Gui = Util.New("ScreenGui", {
        Name            = "PremiumMenuV3",
        ResetOnSpawn    = false,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
        DisplayOrder    = 999,
        IgnoreGuiInset  = true,
        Parent          = LocalPlayer:WaitForChild("PlayerGui"),
    })

    -- ============================================================
    --  MAIN WINDOW
    -- ============================================================

    local Win = Util.New("Frame", {
        Name              = "Window",
        BackgroundColor3  = T.BG,
        Size              = UDim2.new(0, 0, 0, 0),
        Position          = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint       = Vector2.new(0.5, 0.5),
        ClipsDescendants  = true,
        Parent            = Gui,
    })
    Util.Corner(Win, T.RadiusLg)
    Util.Stroke(Win, T.Border, 1, 0.4)
    Util.Shadow(Win)

    Win.BackgroundTransparency = 1
    Util.Tween(Win, {
        Size = WCfg.Size,
        BackgroundTransparency = 0,
    }, 0.5, Enum.EasingStyle.Back)

    -- ============================================================
    --  TOP ACCENT LINE (Glow)
    -- ============================================================

    local AccentLine = Util.New("Frame", {
        BackgroundColor3 = T.Accent,
        Size             = UDim2.new(1, 0, 0, 2),
        BorderSizePixel  = 0,
        ZIndex           = 5,
        Parent           = Win,
    })

    do
        local g = Util.New("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,   Color3.new(1,1,1)),
                ColorSequenceKeypoint.new(0.5, T.Accent),
                ColorSequenceKeypoint.new(1,   Color3.new(1,1,1)),
            }),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0,   0.85),
                NumberSequenceKeypoint.new(0.5, 0),
                NumberSequenceKeypoint.new(1,   0.85),
            }),
            Parent = AccentLine,
        })
        task.spawn(function()
            while AccentLine and AccentLine.Parent do
                Util.Tween(g, {Offset = Vector2.new(1, 0)}, 2, Enum.EasingStyle.Linear)
                task.wait(2)
                g.Offset = Vector2.new(-1, 0)
            end
        end)
    end

    -- ============================================================
    --  TITLE BAR
    -- ============================================================

    local TitleBar = Util.New("Frame", {
        Name             = "TitleBar",
        BackgroundColor3 = T.BGAlt,
        BackgroundTransparency = 0.2,
        Size             = UDim2.new(1, 0, 0, 52),
        Position         = UDim2.new(0, 0, 0, 2),
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = Win,
    })

    Util.New("Frame", {
        BackgroundColor3 = T.Divider,
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, 0),
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = TitleBar,
    })

    -- Logo badge
    local LogoBadge = Util.New("Frame", {
        BackgroundColor3 = T.Accent,
        Size             = UDim2.new(0, 32, 0, 32),
        Position         = UDim2.new(0, 16, 0.5, 0),
        AnchorPoint      = Vector2.new(0, 0.5),
        ZIndex           = 4,
        Parent           = TitleBar,
    })
    Util.Corner(LogoBadge, UDim.new(0, 8))

    if WCfg.LogoImage then
        Util.New("ImageLabel", {
            BackgroundTransparency = 1,
            Size        = UDim2.new(0.7, 0, 0.7, 0),
            Position    = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Image       = WCfg.LogoImage,
            ZIndex      = 5,
            Parent      = LogoBadge,
        })
    else
        Util.New("TextLabel", {
            BackgroundTransparency = 1,
            Size        = UDim2.new(1, 0, 1, 0),
            Font        = T.FontBold,
            Text        = WCfg.LogoText,
            TextColor3  = Color3.new(1, 1, 1),
            TextSize    = 18,
            ZIndex      = 5,
            Parent      = LogoBadge,
        })
    end

    -- Title text
    Util.New("TextLabel", {
        BackgroundTransparency = 1,
        Size        = UDim2.new(0.45, -55, 0, 22),
        Position    = UDim2.new(0, 60, 0, 8),
        Font        = T.FontBold,
        Text        = WCfg.Title,
        TextColor3  = T.TxtHigh,
        TextSize    = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex      = 4,
        Parent      = TitleBar,
    })

    Util.New("TextLabel", {
        BackgroundTransparency = 1,
        Size        = UDim2.new(0.45, -55, 0, 14),
        Position    = UDim2.new(0, 60, 0, 30),
        Font        = T.FontMed,
        Text        = WCfg.Subtitle,
        TextColor3  = T.TxtLow,
        TextSize    = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex      = 4,
        Parent      = TitleBar,
    })

    -- ============================================================
    --  WINDOW CONTROLS  [Minimize]  [Maximize]  [Close]
    -- ============================================================

    local CtrlFrame = Util.New("Frame", {
        BackgroundTransparency = 1,
        Size        = UDim2.new(0, 114, 0, 34),
        Position    = UDim2.new(1, -122, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex      = 5,
        Parent      = TitleBar,
    })

    Util.New("UIListLayout", {
        FillDirection       = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment   = Enum.VerticalAlignment.Center,
        Padding             = UDim.new(0, 8),
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Parent              = CtrlFrame,
    })

    local function MakeCtrlBtn(name, label, hoverCol, layoutOrder, cb)
        local btn = Util.New("TextButton", {
            Name             = name,
            BackgroundColor3 = T.SurfaceAct,
            Size             = UDim2.new(0, 34, 0, 34),
            Font             = T.FontBold,
            Text             = label,
            TextColor3       = T.TxtMid,
            TextSize         = 16,
            AutoButtonColor  = false,
            LayoutOrder      = layoutOrder,
            ZIndex           = 6,
            Parent           = CtrlFrame,
        })
        Util.Corner(btn, T.RadiusSm)

        btn.MouseEnter:Connect(function()
            Util.Tween(btn, {BackgroundColor3 = hoverCol, TextColor3 = Color3.new(1,1,1)}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Util.Tween(btn, {BackgroundColor3 = T.SurfaceAct, TextColor3 = T.TxtMid}, 0.15)
        end)
        btn.MouseButton1Click:Connect(function()
            Util.Ripple(btn)
            if cb then cb() end
        end)

        return btn
    end

    -- [1] Minimize
    MakeCtrlBtn("Minimize", "-", T.Yellow, 1, function()
        State.Minimized = not State.Minimized
        if State.Minimized then
            Util.Tween(Win, {Size = WCfg.MinSize}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        else
            local target = State.Maximized and UDim2.new(1,-40,1,-40) or WCfg.Size
            Util.Tween(Win, {Size = target}, 0.35, Enum.EasingStyle.Back)
        end
    end)

    -- [2] Maximize
    MakeCtrlBtn("Maximize", "+", T.Green, 2, function()
        if State.Minimized then State.Minimized = false end
        State.Maximized = not State.Maximized
        if State.Maximized then
            Util.Tween(Win, {Size = UDim2.new(1,-40,1,-40), Position = UDim2.new(0.5,0,0.5,0)}, 0.35, Enum.EasingStyle.Back)
        else
            Util.Tween(Win, {Size = WCfg.Size, Position = UDim2.new(0.5,0,0.5,0)}, 0.35, Enum.EasingStyle.Back)
        end
    end)

    -- [3] Close
    MakeCtrlBtn("Close", "X", T.Red, 3, function()
        Util.Tween(Win, {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.delay(0.45, function() Gui:Destroy() end)
    end)

    -- ============================================================
    --  DRAG
    -- ============================================================

    TitleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            State.Dragging  = true
            State.DragOrigin = inp.Position
            State.DragPos    = Win.Position
        end
    end)
    TitleBar.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            State.Dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if State.Dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local delta = inp.Position - State.DragOrigin
            Win.Position = UDim2.new(
                State.DragPos.X.Scale, State.DragPos.X.Offset + delta.X,
                State.DragPos.Y.Scale, State.DragPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Toggle key
    UserInputService.InputBegan:Connect(function(inp, gpe)
        if not gpe and inp.KeyCode == WCfg.ToggleKey then
            Win.Visible = not Win.Visible
        end
    end)

    -- ============================================================
    --  BODY  (Sidebar | Content)
    -- ============================================================

    local Body = Util.New("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(1, 0, 1, -54),
        Position = UDim2.new(0, 0, 0, 54),
        ZIndex   = 2,
        Parent   = Win,
    })

    -- ---- SIDEBAR ----

    local Sidebar = Util.New("Frame", {
        BackgroundColor3       = T.BGAlt,
        BackgroundTransparency = 0.1,
        Size        = UDim2.new(0, 170, 1, 0),
        BorderSizePixel = 0,
        ZIndex      = 2,
        Parent      = Body,
    })

    Util.New("Frame", {
        BackgroundColor3 = T.Divider,
        Size        = UDim2.new(0, 1, 1, 0),
        Position    = UDim2.new(1, 0, 0, 0),
        BorderSizePixel = 0,
        ZIndex      = 3,
        Parent      = Sidebar,
    })

    local SideScroll = Util.New("ScrollingFrame", {
        BackgroundTransparency  = 1,
        Size        = UDim2.new(1, -12, 1, -16),
        Position    = UDim2.new(0, 6, 0, 8),
        CanvasSize  = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize    = Enum.AutomaticSize.Y,
        ScrollBarThickness     = 2,
        ScrollBarImageColor3   = T.Scrollbar,
        BorderSizePixel = 0,
        ZIndex      = 2,
        Parent      = Sidebar,
    })
    Util.ListLayout(SideScroll, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, UDim.new(0, 4))

    -- ---- CONTENT ----

    local Content = Util.New("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(1, -172, 1, 0),
        Position = UDim2.new(0, 172, 0, 0),
        ClipsDescendants = true,
        ZIndex   = 2,
        Parent   = Body,
    })

    -- ============================================================
    --  NOTIFICATION SYSTEM
    -- ============================================================

    local NotifContainer = Util.New("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(0, 320, 1, -20),
        Position = UDim2.new(1, -330, 0, 10),
        ZIndex   = 100,
        Parent   = Gui,
    })
    do
        local nl = Instance.new("UIListLayout")
        nl.SortOrder           = Enum.SortOrder.LayoutOrder
        nl.VerticalAlignment   = Enum.VerticalAlignment.Bottom
        nl.Padding             = UDim.new(0, 10)
        nl.Parent              = NotifContainer
    end

    local NotifCount = 0

    local function Notify(opts)
        opts = opts or {}
        NotifCount = NotifCount + 1

        local typeMap = {
            Success = T.Green,
            Warning = T.Yellow,
            Error   = T.Red,
            Info    = T.Blue,
        }
        local barColor = typeMap[opts.Type] or T.Accent

        local nf = Util.New("Frame", {
            BackgroundColor3 = T.Surface,
            Size    = UDim2.new(1, 0, 0, 75),
            ZIndex  = 101,
            LayoutOrder = NotifCount,
            Parent  = NotifContainer,
        })
        Util.Corner(nf, T.RadiusMd)
        Util.Stroke(nf, barColor, 1, 0.6)

        local bar = Util.New("Frame", {
            BackgroundColor3 = barColor,
            Size     = UDim2.new(0, 4, 0.65, 0),
            Position = UDim2.new(0, 8, 0.175, 0),
            BorderSizePixel = 0,
            ZIndex   = 102,
            Parent   = nf,
        })
        Util.Corner(bar, UDim.new(1, 0))

        Util.New("TextLabel", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(1, -30, 0, 20),
            Position = UDim2.new(0, 22, 0, 10),
            Font     = T.FontBold,
            Text     = opts.Title   or "Notification",
            TextColor3 = T.TxtHigh,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex   = 102,
            Parent   = nf,
        })
        Util.New("TextLabel", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(1, -30, 0, 34),
            Position = UDim2.new(0, 22, 0, 32),
            Font     = T.FontMed,
            Text     = opts.Content or "",
            TextColor3 = T.TxtMid,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            ZIndex   = 102,
            Parent   = nf,
        })

        nf.Position = UDim2.new(1, 50, 0, 0)
        nf.BackgroundTransparency = 0.5
        Util.Tween(nf, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0}, 0.35)

        task.delay(opts.Duration or 4, function()
            Util.Tween(nf, {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1}, 0.35)
            task.delay(0.4, function()
                if nf and nf.Parent then nf:Destroy() end
            end)
        end)
    end

    -- ============================================================
    --  WINDOW API
    -- ============================================================

    local Window = {}
    Window.Notify = Notify

    -- ============================================================
    --  TAB BUILDER
    -- ============================================================

    function Window:CreateTab(tabCfg)
        tabCfg = tabCfg or {}
        local tabName  = tabCfg.Name  or "Tab"
        local tabIcon  = tabCfg.Icon  or ""
        local tabOrder = tabCfg.Order or (#State.Tabs + 1)

        -- Sidebar button
        local TabBtn = Util.New("TextButton", {
            BackgroundColor3       = T.Surface,
            BackgroundTransparency = 1,
            Size        = UDim2.new(1, -4, 0, 42),
            Font        = T.FontMed,
            Text        = "",
            AutoButtonColor = false,
            LayoutOrder = tabOrder,
            ZIndex      = 3,
            Parent      = SideScroll,
        })
        Util.Corner(TabBtn, T.RadiusSm)

        local TabIconLbl = Util.New("TextLabel", {
            BackgroundTransparency = 1,
            Size        = UDim2.new(0, 34, 1, 0),
            Position    = UDim2.new(0, 8, 0, 0),
            Font        = T.FontMed,
            Text        = tabIcon,
            TextColor3  = T.TxtLow,
            TextSize    = 16,
            ZIndex      = 4,
            Parent      = TabBtn,
        })

        local TabLbl = Util.New("TextLabel", {
            BackgroundTransparency = 1,
            Size        = UDim2.new(1, -50, 1, 0),
            Position    = UDim2.new(0, 42, 0, 0),
            Font        = T.FontMed,
            Text        = tabName,
            TextColor3  = T.TxtMid,
            TextSize    = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex      = 4,
            Parent      = TabBtn,
        })

        local TabIndicator = Util.New("Frame", {
            BackgroundColor3 = T.Accent,
            Size        = UDim2.new(0, 4, 0, 0),
            Position    = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BorderSizePixel = 0,
            ZIndex      = 4,
            Parent      = TabBtn,
        })
        Util.Corner(TabIndicator, UDim.new(1, 0))

        -- Content page
        local Page = Util.New("ScrollingFrame", {
            BackgroundTransparency = 1,
            Size        = UDim2.new(1, -16, 1, -16),
            Position    = UDim2.new(0, 8, 0, 8),
            CanvasSize  = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness  = 3,
            ScrollBarImageColor3 = T.Scrollbar,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex  = 2,
            Parent  = Content,
        })
        Util.ListLayout(Page, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, UDim.new(0, 8))
        Util.Padding(Page, 6, 6, 6, 6)

        local td = {
            Btn = TabBtn, Page = Page,
            Ind = TabIndicator, IconLbl = TabIconLbl, Lbl = TabLbl,
        }
        table.insert(State.Tabs, td)

        local function Select()
            for _, t in ipairs(State.Tabs) do
                t.Page.Visible = false
                Util.Tween(t.Btn,     {BackgroundTransparency = 1},       0.2)
                Util.Tween(t.Ind,     {Size = UDim2.new(0, 4, 0, 0)},    0.2)
                Util.Tween(t.Lbl,     {TextColor3 = T.TxtMid},            0.2)
                Util.Tween(t.IconLbl, {TextColor3 = T.TxtLow},            0.2)
            end
            td.Page.Visible = true
            State.ActiveTab = td
            Util.Tween(td.Btn,     {BackgroundTransparency = 0.6},    0.2)
            Util.Tween(td.Ind,     {Size = UDim2.new(0, 4, 0, 24)},  0.25, Enum.EasingStyle.Back)
            Util.Tween(td.Lbl,     {TextColor3 = T.TxtHigh},          0.2)
            Util.Tween(td.IconLbl, {TextColor3 = T.Accent},           0.2)
        end

        TabBtn.MouseEnter:Connect(function()
            if State.ActiveTab ~= td then
                Util.Tween(TabBtn, {BackgroundTransparency = 0.75}, 0.15)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if State.ActiveTab ~= td then
                Util.Tween(TabBtn, {BackgroundTransparency = 1}, 0.15)
            end
        end)
        TabBtn.MouseButton1Click:Connect(Select)

        if #State.Tabs == 1 then Select() end

        -- ============================================================
        --  TAB ELEMENTS API
        -- ============================================================

        local Tab = {}

        -- ---- SECTION ----

        function Tab:CreateSection(name)
            local sf = Util.New("Frame", {
                BackgroundTransparency = 1,
                Size        = UDim2.new(1, 0, 0, 30),
                LayoutOrder = #Page:GetChildren(),
                ZIndex      = 3,
                Parent      = Page,
            })

            Util.New("Frame", {
                BackgroundColor3 = T.Divider,
                Size     = UDim2.new(0, 24, 0, 1),
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BorderSizePixel = 0,
                ZIndex   = 3,
                Parent   = sf,
            })

            Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0.65, -5, 1, 0),
                Position = UDim2.new(0, 32, 0, 0),
                Font     = T.FontBold,
                Text     = string.upper(name or "SECTION"),
                TextColor3 = T.TxtLow,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 3,
                Parent   = sf,
            })

            Util.New("Frame", {
                BackgroundColor3 = T.Divider,
                Size     = UDim2.new(0.42, 0, 0, 1),
                Position = UDim2.new(0.58, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BorderSizePixel = 0,
                ZIndex   = 3,
                Parent   = sf,
            })
        end

        -- ---- TOGGLE ----

        function Tab:CreateToggle(opts)
            opts = opts or {}
            local val = opts.Default or false

            local row = Util.New("Frame", {
                BackgroundColor3 = T.Surface,
                Size     = UDim2.new(1, 0, 0, 46),
                LayoutOrder = #Page:GetChildren(),
                ZIndex   = 3,
                Parent   = Page,
            })
            Util.Corner(row, T.RadiusSm)
            Util.HoverBind(row, T.Surface, T.SurfaceHov)

            Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0.65, -14, 0, 20),
                Position = UDim2.new(0, 16, 0, opts.Description and 5 or 13),
                Font     = T.FontMed,
                Text     = opts.Name or "Toggle",
                TextColor3 = T.TxtHigh,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 4,
                Parent   = row,
            })

            if opts.Description then
                Util.New("TextLabel", {
                    BackgroundTransparency = 1,
                    Size     = UDim2.new(0.65, -14, 0, 14),
                    Position = UDim2.new(0, 16, 0, 26),
                    Font     = T.FontMed,
                    Text     = opts.Description,
                    TextColor3 = T.TxtLow,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex   = 4,
                    Parent   = row,
                })
            end

            local track = Util.New("Frame", {
                BackgroundColor3 = val and T.Accent or T.SurfaceAct,
                Size     = UDim2.new(0, 48, 0, 26),
                Position = UDim2.new(1, -64, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                ZIndex   = 4,
                Parent   = row,
            })
            Util.Corner(track, UDim.new(1, 0))
            Util.Stroke(track, T.Border, 1)

            local knob = Util.New("Frame", {
                BackgroundColor3 = Color3.new(1, 1, 1),
                Size     = UDim2.new(0, 20, 0, 20),
                Position = val and UDim2.new(1, -23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                ZIndex   = 5,
                Parent   = track,
            })
            Util.Corner(knob, UDim.new(1, 0))
            Util.Shadow(knob)

            local function Refresh()
                if val then
                    Util.Tween(track, {BackgroundColor3 = T.Accent}, 0.25)
                    Util.Tween(knob,  {Position = UDim2.new(1, -23, 0.5, 0)}, 0.25, Enum.EasingStyle.Back)
                else
                    Util.Tween(track, {BackgroundColor3 = T.SurfaceAct}, 0.25)
                    Util.Tween(knob,  {Position = UDim2.new(0, 3, 0.5, 0)}, 0.25, Enum.EasingStyle.Back)
                end
                if opts.Callback then opts.Callback(val) end
            end

            local clickZone = Util.New("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "", ZIndex = 5, Parent = row,
            })
            clickZone.MouseButton1Click:Connect(function()
                val = not val
                Refresh()
            end)

            local API = {}
            function API:Set(v) val = v; Refresh() end
            function API:Get() return val end
            return API
        end

        -- ---- SLIDER (With Text Input) ----

        function Tab:CreateSlider(opts)
            opts = opts or {}
            local min  = opts.Min      or 0
            local max  = opts.Max      or 100
            local cur  = opts.Default  or min
            local step = opts.Increment or 1

            local row = Util.New("Frame", {
                BackgroundColor3 = T.Surface,
                Size     = UDim2.new(1, 0, 0, 56),
                LayoutOrder = #Page:GetChildren(),
                ZIndex   = 3,
                Parent   = Page,
            })
            Util.Corner(row, T.RadiusSm)
            Util.HoverBind(row, T.Surface, T.SurfaceHov)

            Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0.65, -14, 0, 20),
                Position = UDim2.new(0, 16, 0, 6),
                Font     = T.FontMed,
                Text     = opts.Name or "Slider",
                TextColor3 = T.TxtHigh,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 4,
                Parent   = row,
            })

            -- Manual Input TextBox for slider
            local ValInput = Util.New("TextBox", {
                BackgroundColor3 = T.SurfaceAct,
                Size     = UDim2.new(0, 60, 0, 22),
                Position = UDim2.new(1, -76, 0, 5),
                Font     = T.FontMono,
                Text     = tostring(cur),
                TextColor3 = T.Accent,
                TextSize = 12,
                ZIndex   = 5,
                Parent   = row,
            })
            Util.Corner(ValInput, T.RadiusXs)
            Util.Stroke(ValInput, T.Border, 1)

            local track = Util.New("Frame", {
                BackgroundColor3 = T.SurfaceAct,
                Size     = UDim2.new(1, -32, 0, 6),
                Position = UDim2.new(0, 16, 0, 40),
                ZIndex   = 4,
                Parent   = row,
            })
            Util.Corner(track, UDim.new(1, 0))

            local pct0 = (cur - min) / (max - min)

            local fill = Util.New("Frame", {
                BackgroundColor3 = T.Accent,
                Size     = UDim2.new(pct0, 0, 1, 0),
                ZIndex   = 5,
                Parent   = track,
            })
            Util.Corner(fill, UDim.new(1, 0))

            local knob = Util.New("Frame", {
                BackgroundColor3 = Color3.new(1, 1, 1),
                Size     = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(pct0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                ZIndex   = 6,
                Parent   = track,
            })
            Util.Corner(knob, UDim.new(1, 0))
            Util.Stroke(knob, T.Accent, 2)
            Util.Shadow(knob)

            local dragging = false

            local function UpdateVisuals()
                local pct = (cur - min) / (max - min)
                fill.Size     = UDim2.new(pct, 0, 1, 0)
                knob.Position = UDim2.new(pct, 0, 0.5, 0)
                ValInput.Text   = tostring(cur)
                if opts.Callback then opts.Callback(cur) end
            end

            local function ApplyX(px)
                local abs  = track.AbsolutePosition.X
                local sz   = track.AbsoluteSize.X
                local rel  = math.clamp((px - abs) / sz, 0, 1)
                local raw  = min + (max - min) * rel
                cur = math.clamp(math.floor(raw / step + 0.5) * step, min, max)
                UpdateVisuals()
            end

            track.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    ApplyX(inp.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                    ApplyX(inp.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            ValInput.FocusLost:Connect(function()
                local num = tonumber(ValInput.Text)
                if num then
                    cur = math.clamp(math.floor(num / step + 0.5) * step, min, max)
                end
                UpdateVisuals()
            end)

            local API = {}
            function API:Set(v)
                cur = math.clamp(v, min, max)
                UpdateVisuals()
            end
            function API:Get() return cur end
            return API
        end

        -- ---- BUTTON ----

        function Tab:CreateButton(opts)
            opts = opts or {}

            local row = Util.New("Frame", {
                BackgroundColor3 = T.Surface,
                Size     = UDim2.new(1, 0, 0, 42),
                LayoutOrder = #Page:GetChildren(),
                ZIndex   = 3,
                Parent   = Page,
            })
            Util.Corner(row, T.RadiusSm)
            Util.HoverBind(row, T.Surface, T.SurfaceHov)

            Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0.65, -14, 1, 0),
                Position = UDim2.new(0, 16, 0, 0),
                Font     = T.FontMed,
                Text     = opts.Name or "Button",
                TextColor3 = T.TxtHigh,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 4,
                Parent   = row,
            })

            local btn = Util.New("TextButton", {
                BackgroundColor3 = T.Accent,
                Size     = UDim2.new(0, 76, 0, 30),
                Position = UDim2.new(1, -92, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Font     = T.FontBold,
                Text     = opts.ButtonText or "Run",
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 13,
                AutoButtonColor = false,
                ZIndex   = 5,
                Parent   = row,
            })
            Util.Corner(btn, T.RadiusSm)

            btn.MouseEnter:Connect(function() Util.Tween(btn, {BackgroundColor3 = T.AccentHov}, 0.15) end)
            btn.MouseLeave:Connect(function() Util.Tween(btn, {BackgroundColor3 = T.Accent},    0.15) end)
            btn.MouseButton1Click:Connect(function()
                Util.Ripple(btn)
                if opts.Callback then opts.Callback() end
            end)
        end

        -- ---- DROPDOWN (Scrollable) ----

        function Tab:CreateDropdown(opts)
            opts = opts or {}
            local items   = opts.Items   or {}
            local current = opts.Default or (items[1] or "")
            local open    = false

            local wrap = Util.New("Frame", {
                BackgroundColor3 = T.Surface,
                Size     = UDim2.new(1, 0, 0, 44),
                ClipsDescendants = true,
                LayoutOrder = #Page:GetChildren(),
                ZIndex   = 3,
                Parent   = Page,
            })
            Util.Corner(wrap, T.RadiusSm)

            Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0.45, -8, 0, 44),
                Position = UDim2.new(0, 16, 0, 0),
                Font     = T.FontMed,
                Text     = opts.Name or "Dropdown",
                TextColor3 = T.TxtHigh,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 4,
                Parent   = wrap,
            })

            local selBtn = Util.New("TextButton", {
                BackgroundColor3 = T.SurfaceAct,
                Size     = UDim2.new(0.5, -16, 0, 30),
                Position = UDim2.new(0.5, 0, 0, 7),
                Font     = T.FontMed,
                Text     = current .. "  v",
                TextColor3 = T.TxtMid,
                TextSize = 13,
                AutoButtonColor = false,
                ZIndex   = 5,
                Parent   = wrap,
            })
            Util.Corner(selBtn, T.RadiusXs)
            Util.Stroke(selBtn, T.Border, 1)

            -- Scrollable Item Container
            local itemScroll = Util.New("ScrollingFrame", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, -16, 0, 0),
                Position = UDim2.new(0, 8, 0, 46),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = T.Scrollbar,
                BorderSizePixel = 0,
                ZIndex   = 5,
                Parent   = wrap,
            })
            Util.ListLayout(itemScroll, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, UDim.new(0, 4))
            Util.Padding(itemScroll, 0, 4, 4, 0)

            local function BuildItems()
                for _, c in ipairs(itemScroll:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for i, item in ipairs(items) do
                    local ib = Util.New("TextButton", {
                        BackgroundColor3 = T.SurfaceHov,
                        BackgroundTransparency = 0.5,
                        Size     = UDim2.new(1, 0, 0, 30),
                        Font     = T.FontMed,
                        Text     = item,
                        TextColor3 = item == current and T.Accent or T.TxtMid,
                        TextSize = 13,
                        AutoButtonColor = false,
                        LayoutOrder = i,
                        ZIndex   = 6,
                        Parent   = itemScroll,
                    })
                    Util.Corner(ib, T.RadiusXs)
                    ib.MouseEnter:Connect(function() Util.Tween(ib, {BackgroundTransparency = 0, TextColor3 = T.TxtHigh}, 0.15) end)
                    ib.MouseLeave:Connect(function() Util.Tween(ib, {BackgroundTransparency = 0.5, TextColor3 = item == current and T.Accent or T.TxtMid}, 0.15) end)
                    ib.MouseButton1Click:Connect(function()
                        current = item
                        selBtn.Text = item .. "  v"
                        open = false
                        Util.Tween(wrap, {Size = UDim2.new(1, 0, 0, 44)}, 0.25)
                        BuildItems()
                        if opts.Callback then opts.Callback(item) end
                    end)
                end
            end
            BuildItems()

            selBtn.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    -- Calc height (max 4 items visible without scrolling = ~136px)
                    local listHeight = math.min(#items * 34, 140)
                    Util.Tween(itemScroll, {Size = UDim2.new(1, -16, 0, listHeight)}, 0.25)
                    Util.Tween(wrap, {Size = UDim2.new(1, 0, 0, 46 + listHeight)}, 0.3, Enum.EasingStyle.Back)
                    selBtn.Text = current .. "  ^"
                else
                    Util.Tween(wrap, {Size = UDim2.new(1, 0, 0, 44)}, 0.25)
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

        -- ---- MULTI-DROPDOWN ----

        function Tab:CreateMultiDropdown(opts)
            opts = opts or {}
            local items   = opts.Items   or {}
            local current = opts.Default or {} -- array of strings
            local open    = false

            -- Ensure current is table
            if type(current) ~= "table" then current = {current} end
            
            -- Helper to check if item is selected
            local function IsSelected(item)
                for _, v in ipairs(current) do
                    if v == item then return true end
                end
                return false
            end

            local wrap = Util.New("Frame", {
                BackgroundColor3 = T.Surface,
                Size     = UDim2.new(1, 0, 0, 44),
                ClipsDescendants = true,
                LayoutOrder = #Page:GetChildren(),
                ZIndex   = 3,
                Parent   = Page,
            })
            Util.Corner(wrap, T.RadiusSm)

            Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0.45, -8, 0, 44),
                Position = UDim2.new(0, 16, 0, 0),
                Font     = T.FontMed,
                Text     = opts.Name or "Multi Dropdown",
                TextColor3 = T.TxtHigh,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 4,
                Parent   = wrap,
            })

            local function GetPreviewText()
                if #current == 0 then return "None  v" end
                if #current == 1 then return current[1] .. "  v" end
                return #current .. " Selected  v"
            end

            local selBtn = Util.New("TextButton", {
                BackgroundColor3 = T.SurfaceAct,
                Size     = UDim2.new(0.5, -16, 0, 30),
                Position = UDim2.new(0.5, 0, 0, 7),
                Font     = T.FontMed,
                Text     = GetPreviewText(),
                TextColor3 = T.TxtMid,
                TextSize = 13,
                AutoButtonColor = false,
                ZIndex   = 5,
                Parent   = wrap,
            })
            Util.Corner(selBtn, T.RadiusXs)
            Util.Stroke(selBtn, T.Border, 1)

            local itemScroll = Util.New("ScrollingFrame", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, -16, 0, 0),
                Position = UDim2.new(0, 8, 0, 46),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = T.Scrollbar,
                BorderSizePixel = 0,
                ZIndex   = 5,
                Parent   = wrap,
            })
            Util.ListLayout(itemScroll, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, UDim.new(0, 4))
            Util.Padding(itemScroll, 0, 4, 4, 0)

            local function BuildItems()
                for _, c in ipairs(itemScroll:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for i, item in ipairs(items) do
                    local selected = IsSelected(item)
                    local ib = Util.New("TextButton", {
                        BackgroundColor3 = T.SurfaceHov,
                        BackgroundTransparency = 0.5,
                        Size     = UDim2.new(1, 0, 0, 30),
                        Font     = T.FontMed,
                        Text     = item,
                        TextColor3 = selected and T.Accent or T.TxtMid,
                        TextSize = 13,
                        AutoButtonColor = false,
                        LayoutOrder = i,
                        ZIndex   = 6,
                        Parent   = itemScroll,
                    })
                    Util.Corner(ib, T.RadiusXs)
                    
                    local check = Util.New("Frame", {
                        BackgroundColor3 = selected and T.Accent or T.SurfaceAct,
                        Size = UDim2.new(0, 16, 0, 16),
                        Position = UDim2.new(1, -24, 0.5, 0),
                        AnchorPoint = Vector2.new(0, 0.5),
                        ZIndex = 7,
                        Parent = ib,
                    })
                    Util.Corner(check, T.RadiusXs)

                    ib.MouseEnter:Connect(function() Util.Tween(ib, {BackgroundTransparency = 0, TextColor3 = T.TxtHigh}, 0.15) end)
                    ib.MouseLeave:Connect(function() Util.Tween(ib, {BackgroundTransparency = 0.5, TextColor3 = selected and T.Accent or T.TxtMid}, 0.15) end)
                    
                    ib.MouseButton1Click:Connect(function()
                        if IsSelected(item) then
                            -- Remove
                            for idx, v in ipairs(current) do
                                if v == item then table.remove(current, idx); break end
                            end
                        else
                            -- Add
                            table.insert(current, item)
                        end
                        selBtn.Text = string.gsub(GetPreviewText(), "v", open and "^" or "v")
                        BuildItems()
                        if opts.Callback then opts.Callback(current) end
                    end)
                end
            end
            BuildItems()

            selBtn.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    local listHeight = math.min(#items * 34, 140)
                    Util.Tween(itemScroll, {Size = UDim2.new(1, -16, 0, listHeight)}, 0.25)
                    Util.Tween(wrap, {Size = UDim2.new(1, 0, 0, 46 + listHeight)}, 0.3, Enum.EasingStyle.Back)
                    selBtn.Text = string.gsub(selBtn.Text, "v", "^")
                else
                    Util.Tween(wrap, {Size = UDim2.new(1, 0, 0, 44)}, 0.25)
                    selBtn.Text = string.gsub(selBtn.Text, "%^", "v")
                end
            end)

            local API = {}
            function API:Set(v) current = type(v) == "table" and v or {v}; selBtn.Text = GetPreviewText(); BuildItems() end
            function API:Refresh(list, def)
                items = list
                if def then current = type(def) == "table" and def or {def}; selBtn.Text = GetPreviewText() end
                BuildItems()
            end
            function API:Get() return current end
            return API
        end

        -- ---- INPUT ----

        function Tab:CreateInput(opts)
            opts = opts or {}

            local row = Util.New("Frame", {
                BackgroundColor3 = T.Surface,
                Size     = UDim2.new(1, 0, 0, 44),
                LayoutOrder = #Page:GetChildren(),
                ZIndex   = 3,
                Parent   = Page,
            })
            Util.Corner(row, T.RadiusSm)
            Util.HoverBind(row, T.Surface, T.SurfaceHov)

            Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0.4, -8, 1, 0),
                Position = UDim2.new(0, 16, 0, 0),
                Font     = T.FontMed,
                Text     = opts.Name or "Input",
                TextColor3 = T.TxtHigh,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 4,
                Parent   = row,
            })

            local box = Util.New("TextBox", {
                BackgroundColor3 = T.SurfaceAct,
                Size     = UDim2.new(0.55, -16, 0, 30),
                Position = UDim2.new(0.45, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Font     = T.FontMed,
                PlaceholderText  = opts.Placeholder or "Type here...",
                PlaceholderColor3 = T.TxtLow,
                Text     = opts.Default or "",
                TextColor3 = T.TxtHigh,
                TextSize = 13,
                ClearTextOnFocus = opts.ClearOnFocus or false,
                ZIndex   = 5,
                Parent   = row,
            })
            Util.Corner(box, T.RadiusXs)
            Util.Padding(box, 0, 8, 0, 8)
            local bstroke = Util.Stroke(box, T.Border, 1, 0.5)

            box.Focused:Connect(function()
                Util.Tween(bstroke, {Color = T.Accent, Transparency = 0}, 0.2)
            end)
            box.FocusLost:Connect(function(enter)
                Util.Tween(bstroke, {Color = T.Border, Transparency = 0.5}, 0.2)
                if opts.Callback then opts.Callback(box.Text, enter) end
            end)

            local API = {}
            function API:Set(v) box.Text = v end
            function API:Get() return box.Text end
            return API
        end

        -- ---- KEYBIND ----

        function Tab:CreateKeybind(opts)
            opts = opts or {}
            local key      = opts.Default or Enum.KeyCode.E
            local listening = false

            local row = Util.New("Frame", {
                BackgroundColor3 = T.Surface,
                Size     = UDim2.new(1, 0, 0, 44),
                LayoutOrder = #Page:GetChildren(),
                ZIndex   = 3,
                Parent   = Page,
            })
            Util.Corner(row, T.RadiusSm)
            Util.HoverBind(row, T.Surface, T.SurfaceHov)

            Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0.65, -14, 1, 0),
                Position = UDim2.new(0, 16, 0, 0),
                Font     = T.FontMed,
                Text     = opts.Name or "Keybind",
                TextColor3 = T.TxtHigh,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 4,
                Parent   = row,
            })

            local kbtn = Util.New("TextButton", {
                BackgroundColor3 = T.SurfaceAct,
                Size     = UDim2.new(0, 80, 0, 30),
                Position = UDim2.new(1, -96, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Font     = T.FontMono,
                Text     = key.Name,
                TextColor3 = T.Accent,
                TextSize = 13,
                AutoButtonColor = false,
                ZIndex   = 5,
                Parent   = row,
            })
            Util.Corner(kbtn, T.RadiusXs)
            Util.Stroke(kbtn, T.Border, 1, 0.5)

            kbtn.MouseButton1Click:Connect(function()
                listening = true
                kbtn.Text = "..."
                Util.Tween(kbtn, {BackgroundColor3 = T.Accent}, 0.15)
                kbtn.TextColor3 = Color3.new(1, 1, 1)
            end)

            UserInputService.InputBegan:Connect(function(inp, gpe)
                if listening and inp.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    key = inp.KeyCode
                    kbtn.Text = key.Name
                    Util.Tween(kbtn, {BackgroundColor3 = T.SurfaceAct}, 0.15)
                    kbtn.TextColor3 = T.Accent
                    if opts.Callback then opts.Callback(key) end
                end
            end)

            local API = {}
            function API:Set(k) key = k; kbtn.Text = k.Name end
            function API:Get() return key end
            return API
        end

        -- ---- LABEL ----

        function Tab:CreateLabel(opts)
            opts = opts or {}

            local row = Util.New("Frame", {
                BackgroundColor3       = T.Surface,
                BackgroundTransparency = 0.35,
                Size     = UDim2.new(1, 0, 0, 34),
                LayoutOrder = #Page:GetChildren(),
                ZIndex   = 3,
                Parent   = Page,
            })
            Util.Corner(row, T.RadiusSm)

            local dot = Util.New("Frame", {
                BackgroundColor3 = T.Accent,
                Size     = UDim2.new(0, 6, 0, 6),
                Position = UDim2.new(0, 14, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                ZIndex   = 4,
                Parent   = row,
            })
            Util.Corner(dot, UDim.new(1, 0))

            local lbl = Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, -34, 1, 0),
                Position = UDim2.new(0, 28, 0, 0),
                Font     = T.FontMed,
                Text     = opts.Text or "Label",
                TextColor3 = T.TxtMid,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 4,
                Parent   = row,
            })

            local API = {}
            function API:Set(v) lbl.Text = v end
            function API:Get() return lbl.Text end
            return API
        end

        -- ---- PARAGRAPH (Multi-line text) ----

        function Tab:CreateParagraph(opts)
            opts = opts or {}
            
            local text = opts.Text or "Paragraph text"
            local title = opts.Title or "Information"

            local row = Util.New("Frame", {
                BackgroundColor3 = T.Surface,
                Size     = UDim2.new(1, 0, 0, 60), -- Initial size, will adjust
                LayoutOrder = #Page:GetChildren(),
                ZIndex   = 3,
                Parent   = Page,
            })
            Util.Corner(row, T.RadiusSm)
            Util.Stroke(row, T.Border, 1, 0.5)

            local titleLbl = Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, -24, 0, 20),
                Position = UDim2.new(0, 12, 0, 8),
                Font     = T.FontBold,
                Text     = title,
                TextColor3 = T.TxtHigh,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 4,
                Parent   = row,
            })

            local textLbl = Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, -24, 0, 0),
                Position = UDim2.new(0, 12, 0, 30),
                Font     = T.FontMed,
                Text     = text,
                TextColor3 = T.TxtMid,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true,
                ZIndex   = 4,
                Parent   = row,
            })

            local function AdjustSize()
                local bounds = Util.GetTextBounds(textLbl.Text, T.FontMed, 13, Vector2.new(Page.AbsoluteSize.X - 40, 10000))
                textLbl.Size = UDim2.new(1, -24, 0, bounds.Y)
                row.Size = UDim2.new(1, 0, 0, bounds.Y + 42)
            end

            -- Need to wait a tick for AbsoluteSize to be accurate in some executors
            task.delay(0.1, AdjustSize)

            local API = {}
            function API:Set(newProps) 
                if newProps.Title then titleLbl.Text = newProps.Title end
                if newProps.Text then textLbl.Text = newProps.Text end
                AdjustSize()
            end
            return API
        end

        -- ---- COLOR PICKER (swatch) ----

        function Tab:CreateColorPicker(opts)
            opts = opts or {}
            local color = opts.Default or Color3.new(1, 1, 1)

            local row = Util.New("Frame", {
                BackgroundColor3 = T.Surface,
                Size     = UDim2.new(1, 0, 0, 44),
                LayoutOrder = #Page:GetChildren(),
                ZIndex   = 3,
                Parent   = Page,
            })
            Util.Corner(row, T.RadiusSm)
            Util.HoverBind(row, T.Surface, T.SurfaceHov)

            Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0.65, -14, 1, 0),
                Position = UDim2.new(0, 16, 0, 0),
                Font     = T.FontMed,
                Text     = opts.Name or "Color",
                TextColor3 = T.TxtHigh,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 4,
                Parent   = row,
            })

            local swatch = Util.New("Frame", {
                BackgroundColor3 = color,
                Size     = UDim2.new(0, 32, 0, 32),
                Position = UDim2.new(1, -48, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                ZIndex   = 5,
                Parent   = row,
            })
            Util.Corner(swatch, UDim.new(0, 6))
            Util.Stroke(swatch, T.Border, 1)

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

    -- ============================================================
    --  CONFIG API
    -- ============================================================

    function Window:SetValue(k, v) State.Data[k] = v end
    function Window:GetValue(k)    return State.Data[k] end

    function Window:SaveConfig(name)
        local out = {}
        for k, v in pairs(State.Data) do out[k] = v end
        pcall(function()
            if writefile then
                writefile((name or WCfg.ConfigKey) .. ".json", HttpService:JSONEncode(out))
            end
        end)
        Notify({Title = "Config Saved", Content = (name or WCfg.ConfigKey) .. ".json written.", Type = "Success", Duration = 3})
        return out
    end

    function Window:LoadConfig(name, data)
        if type(data) == "table" then
            for k, v in pairs(data) do State.Data[k] = v end
            Notify({Title = "Config Loaded", Content = "Loaded " .. (name or "config") .. ".", Type = "Info", Duration = 3})
        else
            pcall(function()
                if readfile and isfile then
                    local path = (name or WCfg.ConfigKey) .. ".json"
                    if isfile(path) then
                        local tbl = HttpService:JSONDecode(readfile(path))
                        for k, v in pairs(tbl) do State.Data[k] = v end
                        Notify({Title = "Config Loaded", Content = path .. " loaded.", Type = "Info", Duration = 3})
                    end
                end
            end)
        end
    end

    function Window:Destroy()
        Util.Tween(Win, {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.delay(0.4, function() Gui:Destroy() end)
    end

    -- ============================================================
    --  TUTORIAL OVERLAY
    -- ============================================================

    if WCfg.TutorialMode then
        task.spawn(function()
            task.wait(1)

            local Pages = {
                {
                    Title = "Welcome to PremiumMenu v3",
                    Body  = {
                        "Welcome! PremiumMenu v3 is a premium Roblox Luau",
                        "UI framework for building clean script hubs.",
                        "",
                        "New features include Scrollable Dropdowns,",
                        "Multi-Selects, Paragraphs, and Manual Slider Input.",
                        "",
                        "To disable this guide, add to your config:",
                    },
                    Code = "TutorialMode = false",
                },
                {
                    Title = "Step 1  |  Load and Create Window",
                    Body  = {
                        "Load the library with loadstring + HttpGet.",
                        "Then call CreateWindow() with your config.",
                    },
                    Code = 'local PM = loadstring(game:HttpGet("URL_HERE"))()\n\nlocal Window = PM:CreateWindow({\n    Title        = "My Hub",\n    Subtitle     = "v1.0",\n    LogoText     = "M",\n    AccentColor  = Color3.fromRGB(99, 102, 241),\n    ToggleKey    = Enum.KeyCode.RightShift,\n    TutorialMode = false,\n})',
                },
                {
                    Title = "Step 2  |  Create Tabs",
                    Body  = {
                        "Tabs live in the sidebar on the left.",
                        "Give each tab a Name and optional Icon text.",
                    },
                    Code = 'local Main = Window:CreateTab({\n    Name  = "Main",\n    Icon  = "",\n    Order = 1,\n})\n\nlocal Settings = Window:CreateTab({\n    Name  = "Settings",\n    Icon  = "",\n    Order = 2,\n})',
                },
                {
                    Title = "Step 3  |  Sections and Basic Elements",
                    Body  = {
                        "Use CreateSection to visually group elements.",
                        "Then add Toggles, Sliders, Buttons inside.",
                    },
                    Code = 'Main:CreateSection("Combat")\n\nMain:CreateToggle({\n    Name        = "Auto Farm",\n    Description = "Automatically farm mobs",\n    Default     = false,\n    Callback    = function(v) print("AutoFarm:", v) end,\n})\n\nMain:CreateSlider({\n    Name      = "Walk Speed",\n    Min       = 16, Max = 300,\n    Default   = 16, Increment = 1,\n    Callback  = function(v)\n        game.Players.LocalPlayer.Character\n            .Humanoid.WalkSpeed = v\n    end,\n})',
                },
                {
                    Title = "Step 4  |  More Element Types",
                    Body = {
                        "Every element type available in PremiumMenu v3:",
                    },
                    Code = 'Tab:CreateButton({ Name = "Teleport", ButtonText = "Go", Callback = function() end })\n\nTab:CreateDropdown({\n    Name  = "Mode",\n    Items = {"Option A", "Option B", "Option C"},\n    Default = "Option A",\n    Callback = function(v) print(v) end,\n})\n\nTab:CreateMultiDropdown({\n    Name  = "ESP Options",\n    Items = {"Players", "Items", "Chests"},\n    Default = {"Players"},\n    Callback = function(table) print(table) end,\n})\n\nTab:CreateInput({ Name = "Player", Placeholder = "Type...", Callback = function(t, e) end })\n\nTab:CreateKeybind({ Name = "Toggle", Default = Enum.KeyCode.Q, Callback = function(k) end })\n\nTab:CreateParagraph({ Title = "Info", Text = "This is a long multi-line paragraph block." })',
                },
                {
                    Title = "Step 5  |  Notifications and Config",
                    Body  = {
                        "Show toast notifications and persist settings.",
                    },
                    Code = 'Window:Notify({\n    Title    = "Done!",\n    Content  = "Action completed successfully.",\n    Type     = "Success",\n    Duration = 4,\n})\n\nWindow:SetValue("speed", 100)\nprint(Window:GetValue("speed"))\n\nWindow:SaveConfig("MyHub")\n\nWindow:LoadConfig("MyHub")',
                },
                {
                    Title = "Step 6  |  Fire Remote Events and Functions",
                    Body  = {
                        "Connect your UI to server remotes.",
                        "Use ReplicatedStorage to find remotes by name.",
                        "FireServer sends data, InvokeServer returns data.",
                    },
                    Code = 'local RS = game:GetService("ReplicatedStorage")\n\nTab:CreateButton({\n    Name = "Fire Remote Event",\n    ButtonText = "Fire",\n    Callback = function()\n        local re = RS:FindFirstChild("MyEvent")\n        if re and re:IsA("RemoteEvent") then\n            re:FireServer("data", 123)\n            Window:Notify({\n                Title   = "Fired",\n                Content = "MyEvent sent to server.",\n                Type    = "Success",\n            })\n        end\n    end,\n})\n\nTab:CreateInput({\n    Name        = "Remote Name",\n    Placeholder = "RemoteEvent name...",\n    Callback    = function(text, enter)\n        if not enter then return end\n        local re = RS:FindFirstChild(text)\n        if re and re:IsA("RemoteEvent") then\n            re:FireServer()\n        end\n    end,\n})\n',
                },
                {
                    Title = "You Are Ready!",
                    Body  = {
                        "PremiumMenu v3 is fully set up.",
                        "",
                        "Controls:",
                        "  RightShift   Toggle window visibility",
                        "  Title bar    Drag to move window",
                        "  -  button    Minimize to title bar",
                        "  +  button    Maximize to full screen",
                        "  X  button    Close and destroy UI",
                        "",
                        "To hide this tutorial permanently:",
                    },
                    Code = "TutorialMode = false",
                },
            }

            local pageIdx = 1

            local Overlay = Util.New("Frame", {
                BackgroundColor3       = Color3.new(0, 0, 0),
                BackgroundTransparency = 1,
                Size   = UDim2.new(1, 0, 1, 0),
                ZIndex = 60,
                Parent = Gui,
            })

            local Card = Util.New("Frame", {
                BackgroundColor3 = T.BG,
                Size     = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint      = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                ClipsDescendants = true,
                ZIndex  = 61,
                Parent  = Gui,
            })
            Util.Corner(Card, T.RadiusLg)
            Util.Stroke(Card, T.Accent, 1, 0.3)
            Util.Shadow(Card)

            Util.Tween(Overlay, {BackgroundTransparency = 0.4}, 0.38)
            Util.Tween(Card, {
                Size = UDim2.new(0, 540, 0, 480),
                BackgroundTransparency = 0,
            }, 0.48, Enum.EasingStyle.Back)

            -- Accent top bar
            Util.New("Frame", {
                BackgroundColor3 = T.Accent,
                Size    = UDim2.new(1, 0, 0, 3),
                BorderSizePixel = 0,
                ZIndex  = 62,
                Parent  = Card,
            })

            -- Header
            local Hdr = Util.New("Frame", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, 0, 0, 56),
                Position = UDim2.new(0, 0, 0, 4),
                ZIndex   = 62,
                Parent   = Card,
            })

            local HdrTitle = Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, -60, 0, 26),
                Position = UDim2.new(0, 20, 0, 8),
                Font     = T.FontBold,
                Text     = Pages[1].Title,
                TextColor3 = T.TxtHigh,
                TextSize = 17,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 63,
                Parent   = Hdr,
            })

            local HdrSub = Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, -60, 0, 16),
                Position = UDim2.new(0, 20, 0, 36),
                Font     = T.FontMed,
                Text     = "Step 1 of " .. #Pages,
                TextColor3 = T.TxtLow,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 63,
                Parent   = Hdr,
            })

            -- X Close button
            local XBtn = Util.New("TextButton", {
                BackgroundColor3 = T.SurfaceAct,
                Size     = UDim2.new(0, 32, 0, 32),
                Position = UDim2.new(1, -48, 0, 14),
                Font     = T.FontBold,
                Text     = "X",
                TextColor3 = T.TxtMid,
                TextSize = 15,
                AutoButtonColor = false,
                ZIndex   = 64,
                Parent   = Hdr,
            })
            Util.Corner(XBtn, T.RadiusSm)
            XBtn.MouseEnter:Connect(function() Util.Tween(XBtn, {BackgroundColor3 = T.Red, TextColor3 = Color3.new(1,1,1)}, 0.15) end)
            XBtn.MouseLeave:Connect(function() Util.Tween(XBtn, {BackgroundColor3 = T.SurfaceAct, TextColor3 = T.TxtMid}, 0.15) end)

            -- Divider
            Util.New("Frame", {
                BackgroundColor3 = T.Divider,
                Size     = UDim2.new(1, -36, 0, 1),
                Position = UDim2.new(0, 18, 0, 62),
                BorderSizePixel = 0,
                ZIndex   = 62,
                Parent   = Card,
            })

            -- Body scroll
            local Body2 = Util.New("ScrollingFrame", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, -36, 1, -140),
                Position = UDim2.new(0, 18, 0, 68),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness  = 4,
                ScrollBarImageColor3 = T.Scrollbar,
                BorderSizePixel = 0,
                ZIndex  = 62,
                Parent  = Card,
            })
            Util.ListLayout(Body2, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top, UDim.new(0, 6))

            -- Progress bar
            local ProgBg = Util.New("Frame", {
                BackgroundColor3 = T.SurfaceAct,
                Size     = UDim2.new(1, -36, 0, 5),
                Position = UDim2.new(0, 18, 1, -60),
                BorderSizePixel = 0,
                ZIndex   = 62,
                Parent   = Card,
            })
            Util.Corner(ProgBg, UDim.new(1, 0))

            local ProgFill = Util.New("Frame", {
                BackgroundColor3 = T.Accent,
                Size    = UDim2.new(1 / #Pages, 0, 1, 0),
                BorderSizePixel = 0,
                ZIndex  = 63,
                Parent  = ProgBg,
            })
            Util.Corner(ProgFill, UDim.new(1, 0))

            -- Page dots
            local DotsHolder = Util.New("Frame", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0, #Pages * 20, 0, 12),
                Position = UDim2.new(0.5, 0, 1, -66),
                AnchorPoint = Vector2.new(0.5, 0),
                ZIndex   = 62,
                Parent   = Card,
            })
            Util.New("UIListLayout", {
                FillDirection       = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment   = Enum.VerticalAlignment.Center,
                Padding             = UDim.new(0, 6),
                SortOrder           = Enum.SortOrder.LayoutOrder,
                Parent              = DotsHolder,
            })

            local Dots = {}
            for i = 1, #Pages do
                local d = Util.New("Frame", {
                    BackgroundColor3 = i == 1 and T.Accent or T.SurfaceAct,
                    Size    = i == 1 and UDim2.new(0, 22, 0, 6) or UDim2.new(0, 6, 0, 6),
                    ZIndex  = 63,
                    Parent  = DotsHolder,
                })
                Util.Corner(d, UDim.new(1, 0))
                table.insert(Dots, d)
            end

            -- Footer
            local Footer = Util.New("Frame", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, -36, 0, 38),
                Position = UDim2.new(0, 18, 1, -48),
                ZIndex   = 62,
                Parent   = Card,
            })

            local BackBtn2 = Util.New("TextButton", {
                BackgroundColor3 = T.Surface,
                Size     = UDim2.new(0, 90, 0, 36),
                Position = UDim2.new(0, 0, 0, 0),
                Font     = T.FontMed,
                Text     = "< Back",
                TextColor3 = T.TxtMid,
                TextSize = 14,
                AutoButtonColor = false,
                Visible  = false,
                ZIndex   = 63,
                Parent   = Footer,
            })
            Util.Corner(BackBtn2, T.RadiusSm)
            BackBtn2.MouseEnter:Connect(function() Util.Tween(BackBtn2, {BackgroundColor3 = T.SurfaceHov}, 0.15) end)
            BackBtn2.MouseLeave:Connect(function() Util.Tween(BackBtn2, {BackgroundColor3 = T.Surface},    0.15) end)

            local NextBtn2 = Util.New("TextButton", {
                BackgroundColor3 = T.Accent,
                Size     = UDim2.new(0, 90, 0, 36),
                Position = UDim2.new(1, -90, 0, 0),
                Font     = T.FontBold,
                Text     = "Next >",
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 14,
                AutoButtonColor = false,
                ZIndex   = 63,
                Parent   = Footer,
            })
            Util.Corner(NextBtn2, T.RadiusSm)
            NextBtn2.MouseEnter:Connect(function() Util.Tween(NextBtn2, {BackgroundColor3 = T.AccentHov}, 0.15) end)
            NextBtn2.MouseLeave:Connect(function() Util.Tween(NextBtn2, {BackgroundColor3 = T.Accent},    0.15) end)

            local lastCode = ""

            local function DrawPage(idx)
                local pg = Pages[idx]
                if not pg then return end

                HdrTitle.Text = pg.Title
                HdrSub.Text   = "Step " .. idx .. " of " .. #Pages

                Util.Tween(ProgFill, {Size = UDim2.new(idx / #Pages, 0, 1, 0)}, 0.3)

                for i, d in ipairs(Dots) do
                    if i == idx then
                        Util.Tween(d, {BackgroundColor3 = T.Accent, Size = UDim2.new(0, 22, 0, 6)}, 0.25)
                    else
                        Util.Tween(d, {BackgroundColor3 = T.SurfaceAct, Size = UDim2.new(0, 6, 0, 6)}, 0.25)
                    end
                end

                BackBtn2.Visible = idx > 1
                if idx == #Pages then
                    NextBtn2.Text = "Finish"
                    Util.Tween(NextBtn2, {BackgroundColor3 = T.Green}, 0.25)
                else
                    NextBtn2.Text = "Next >"
                    Util.Tween(NextBtn2, {BackgroundColor3 = T.Accent}, 0.25)
                end

                -- Clear body
                for _, c in ipairs(Body2:GetChildren()) do
                    if not c:IsA("UIListLayout") then c:Destroy() end
                end

                -- Body text lines
                for i2, line in ipairs(pg.Body) do
                    if line == "" then
                        Util.New("Frame", {
                            BackgroundTransparency = 1,
                            Size   = UDim2.new(1, 0, 0, 6),
                            LayoutOrder = i2, ZIndex = 62, Parent = Body2,
                        })
                    else
                        Util.New("TextLabel", {
                            BackgroundTransparency = 1,
                            Size   = UDim2.new(1, 0, 0, 18),
                            Font   = T.FontMed,
                            Text   = line,
                            TextColor3 = T.TxtMid,
                            TextSize = 14,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            TextWrapped = true,
                            LayoutOrder = i2,
                            ZIndex = 62,
                            Parent = Body2,
                        })
                    end
                end

                -- Code block
                if pg.Code then
                    lastCode = pg.Code

                    Util.New("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 8),
                        LayoutOrder = 100, ZIndex = 62, Parent = Body2,
                    })

                    local lines   = string.split(pg.Code, "\n")
                    local codeH   = math.max(#lines * 17 + 20, 48)

                    local CodeWrap = Util.New("Frame", {
                        BackgroundColor3 = Color3.fromRGB(12, 12, 18),
                        Size   = UDim2.new(1, 0, 0, codeH + 30),
                        ClipsDescendants = true,
                        LayoutOrder = 101, ZIndex = 62, Parent = Body2,
                    })
                    Util.Corner(CodeWrap, T.RadiusMd)
                    Util.Stroke(CodeWrap, T.Border, 1, 0.6)

                    -- Code header bar
                    local CodeHdr = Util.New("Frame", {
                        BackgroundColor3 = Color3.fromRGB(18, 18, 28),
                        Size    = UDim2.new(1, 0, 0, 28),
                        BorderSizePixel = 0,
                        ZIndex  = 63,
                        Parent  = CodeWrap,
                    })

                    -- macOS-style dots
                    for di = 0, 2 do
                        local dc = ({Color3.fromRGB(255,95,87), Color3.fromRGB(255,189,46), Color3.fromRGB(39,201,63)})[di+1]
                        Util.Corner(Util.New("Frame", {
                            BackgroundColor3 = dc,
                            Size     = UDim2.new(0, 10, 0, 10),
                            Position = UDim2.new(0, 12 + di * 18, 0.5, 0),
                            AnchorPoint = Vector2.new(0, 0.5),
                            ZIndex   = 64,
                            Parent   = CodeHdr,
                        }), UDim.new(1, 0))
                    end

                    Util.New("TextLabel", {
                        BackgroundTransparency = 1,
                        Size     = UDim2.new(0.4, 0, 1, 0),
                        Position = UDim2.new(0, 75, 0, 0),
                        Font     = T.FontMono,
                        Text     = "example.lua",
                        TextColor3 = T.TxtLow,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex   = 64,
                        Parent   = CodeHdr,
                    })

                    -- Copy button
                    local CopyBtn = Util.New("TextButton", {
                        BackgroundColor3 = T.SurfaceAct,
                        Size     = UDim2.new(0, 56, 0, 20),
                        Position = UDim2.new(1, -64, 0.5, 0),
                        AnchorPoint = Vector2.new(0, 0.5),
                        Font     = T.FontMed,
                        Text     = "Copy",
                        TextColor3 = T.TxtMid,
                        TextSize = 12,
                        AutoButtonColor = false,
                        ZIndex   = 65,
                        Parent   = CodeHdr,
                    })
                    Util.Corner(CopyBtn, UDim.new(0, 4))

                    CopyBtn.MouseEnter:Connect(function() Util.Tween(CopyBtn, {BackgroundColor3 = T.Accent, TextColor3 = Color3.new(1,1,1)}, 0.15) end)
                    CopyBtn.MouseLeave:Connect(function() Util.Tween(CopyBtn, {BackgroundColor3 = T.SurfaceAct, TextColor3 = T.TxtMid},       0.15) end)
                    CopyBtn.MouseButton1Click:Connect(function()
                        local ok = pcall(function()
                            if setclipboard   then setclipboard(lastCode)
                            elseif toclipboard then toclipboard(lastCode)
                            end
                        end)
                        CopyBtn.Text = ok and "Done!" or "N/A"
                        Util.Tween(CopyBtn, {BackgroundColor3 = ok and T.Green or T.Yellow}, 0.15)
                        task.delay(1.5, function()
                            CopyBtn.Text = "Copy"
                            Util.Tween(CopyBtn, {BackgroundColor3 = T.SurfaceAct}, 0.15)
                        end)
                    end)

                    -- Separator
                    Util.New("Frame", {
                        BackgroundColor3 = T.Divider,
                        Size    = UDim2.new(1, 0, 0, 1),
                        Position = UDim2.new(0, 0, 1, 0),
                        BorderSizePixel = 0,
                        ZIndex  = 64,
                        Parent  = CodeHdr,
                    })

                    -- Formatted code with line numbers
                    local formatted = ""
                    for li, codeLine in ipairs(lines) do
                        formatted = formatted .. string.format("%3d  ", li) .. codeLine
                        if li < #lines then formatted = formatted .. "\n" end
                    end

                    Util.New("TextLabel", {
                        BackgroundTransparency = 1,
                        Size     = UDim2.new(1, -20, 1, -34),
                        Position = UDim2.new(0, 10, 0, 32),
                        Font     = T.FontMono,
                        Text     = formatted,
                        TextColor3 = Color3.fromRGB(180, 215, 255),
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        TextWrapped    = false,
                        ZIndex   = 63,
                        Parent   = CodeWrap,
                    })
                end
            end

            local function CloseTutorial()
                Util.Tween(Card,    {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                Util.Tween(Overlay, {BackgroundTransparency = 1}, 0.35)
                task.delay(0.4, function()
                    if Overlay and Overlay.Parent then Overlay:Destroy() end
                    if Card    and Card.Parent    then Card:Destroy()    end
                end)
                Notify({
                    Title   = "Tutorial Closed",
                    Content = "Set TutorialMode = false to skip next time.",
                    Type    = "Info",
                    Duration = 5,
                })
            end

            XBtn.MouseButton1Click:Connect(function()
                Util.Ripple(XBtn)
                CloseTutorial()
            end)

            NextBtn2.MouseButton1Click:Connect(function()
                Util.Ripple(NextBtn2)
                if pageIdx >= #Pages then
                    CloseTutorial()
                else
                    pageIdx = pageIdx + 1
                    DrawPage(pageIdx)
                end
            end)

            BackBtn2.MouseButton1Click:Connect(function()
                Util.Ripple(BackBtn2)
                if pageIdx > 1 then
                    pageIdx = pageIdx - 1
                    DrawPage(pageIdx)
                end
            end)

            DrawPage(1)
        end)
    end

    return Window
end

return PremiumMenu
