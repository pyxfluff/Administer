-- fractality

local module = {}

local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

do
	local function IsNotNaN(x)
		return x == x
	end
	local continue = IsNotNaN(camera:ScreenPointToRay(0, 0).Origin.x)
	while not continue do
		RunService.RenderStepped:wait()
		continue = IsNotNaN(camera:ScreenPointToRay(0, 0).Origin.x)
	end
end

local binds = {}
local root = Instance.new("Folder", camera)
root.Name = "neon"

local GenUid
do -- Generate unique names for RenderStepped bindings
	local id = 0
	function GenUid()
		id = id + 1
		return "neon::" .. tostring(id)
	end
end

local DrawQuad
do
	local acos, max, pi, sqrt = math.acos, math.max, math.pi, math.sqrt
	local sz = 0.2

	function DrawTriangle(v1, v2, v3, p0, p1) -- I think Stravant wrote this function
		local s1 = (v1 - v2).magnitude
		local s2 = (v2 - v3).magnitude
		local s3 = (v3 - v1).magnitude
		local smax = max(s1, s2, s3)
		local A, B, C
		if s1 == smax then
			A, B, C = v1, v2, v3
		elseif s2 == smax then
			A, B, C = v2, v3, v1
		elseif s3 == smax then
			A, B, C = v3, v1, v2
		end

		local para = ((B - A).x * (C - A).x + (B - A).y * (C - A).y + (B - A).z * (C - A).z) / (A - B).magnitude
		local perp = sqrt((C - A).magnitude ^ 2 - para * para)
		local dif_para = (A - B).magnitude - para

		local st = CFrame.new(B, A)
		local za = CFrame.Angles(pi / 2, 0, 0)

		local cf0 = st

		local Top_Look = (cf0 * za).lookVector
		local Mid_Point = A + CFrame.new(A, B).lookVector * para
		local Needed_Look = CFrame.new(Mid_Point, C).lookVector
		local dot = Top_Look.x * Needed_Look.x + Top_Look.y * Needed_Look.y + Top_Look.z * Needed_Look.z

		local ac = CFrame.Angles(0, 0, acos(dot))

		cf0 = cf0 * ac
		if ((cf0 * za).lookVector - Needed_Look).magnitude > 0.01 then
			cf0 = cf0 * CFrame.Angles(0, 0, -2 * acos(dot))
		end
		cf0 = cf0 * CFrame.new(0, perp / 2, -(dif_para + para / 2))

		local cf1 = st * ac * CFrame.Angles(0, pi, 0)
		if ((cf1 * za).lookVector - Needed_Look).magnitude > 0.01 then
			cf1 = cf1 * CFrame.Angles(0, 0, 2 * acos(dot))
		end
		cf1 = cf1 * CFrame.new(0, perp / 2, dif_para / 2)

		if not p0 then
			p0 = Instance.new("Part")
			p0.FormFactor = "Custom"
			p0.TopSurface = 0
			p0.BottomSurface = 0
			p0.Anchored = true
			p0.CanCollide = false
			p0.Material = "Glass"
			p0.Size = Vector3.new(sz, sz, sz)
			local mesh = Instance.new("SpecialMesh", p0)
			mesh.MeshType = 2
			mesh.Name = "WedgeMesh"
		end
		p0.WedgeMesh.Scale = Vector3.new(0, perp / sz, para / sz)
		p0.CFrame = cf0

		if not p1 then p1 = p0:clone() end
		p1.WedgeMesh.Scale = Vector3.new(0, perp / sz, dif_para / sz)
		p1.CFrame = cf1

		return p0, p1
	end

	function DrawQuad(v1, v2, v3, v4, parts)
		parts[1], parts[2] = DrawTriangle(v1, v2, v3, parts[1], parts[2])
		parts[3], parts[4] = DrawTriangle(v3, v2, v4, parts[3], parts[4])
	end
end

--------------------------------
---- Module API --------------------------------
----------------------------------------------------------------

-- Create a part binding for a GuiObject.
function module:BindFrame(frame, properties)
	if binds[frame] then return binds[frame].parts end

	local uid = GenUid()
	local parts = {}
	local f = Instance.new("Folder", root)
	f.Name = frame.Name

	local parents = {} -- construct hierarchy tree for rotation
	do
		local function add(child)
			if child:IsA "GuiObject" then
				parents[#parents + 1] = child
				add(child.Parent)
			end
		end
		add(frame)
	end

	local function UpdateOrientation(fetchProps)
		local zIndex = 1 - 0.05 * frame.ZIndex
		-- the transparency inversion bug still surfaces when there's z-fighting
		local tl, br = frame.AbsolutePosition, frame.AbsolutePosition + frame.AbsoluteSize
		local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)
		do
			local rot = 0
			for _, v in ipairs(parents) do
				rot = rot + v.Rotation
			end
			if rot ~= 0 and rot % 180 ~= 0 then
				local mid = tl:lerp(br, 0.5)
				local s, c = math.sin(math.rad(rot)), math.cos(math.rad(rot))
				local vec = tl
				tl = Vector2.new(c * (tl.x - mid.x) - s * (tl.y - mid.y), s * (tl.x - mid.x) + c * (tl.y - mid.y)) + mid
				tr = Vector2.new(c * (tr.x - mid.x) - s * (tr.y - mid.y), s * (tr.x - mid.x) + c * (tr.y - mid.y)) + mid
				bl = Vector2.new(c * (bl.x - mid.x) - s * (bl.y - mid.y), s * (bl.x - mid.x) + c * (bl.y - mid.y)) + mid
				br = Vector2.new(c * (br.x - mid.x) - s * (br.y - mid.y), s * (br.x - mid.x) + c * (br.y - mid.y)) + mid
			end
		end
		DrawQuad(
			camera:ScreenPointToRay(tl.x, tl.y, zIndex).Origin,
			camera:ScreenPointToRay(tr.x, tr.y, zIndex).Origin,
			camera:ScreenPointToRay(bl.x, bl.y, zIndex).Origin,
			camera:ScreenPointToRay(br.x, br.y, zIndex).Origin,
			parts
		)
		if fetchProps then
			for _, pt in pairs(parts) do
				pt.Parent = f
			end
			for propName, propValue in pairs(properties) do
				for _, pt in pairs(parts) do
					pt[propName] = propValue
				end
			end
		end
	end

	UpdateOrientation(true)
	RunService:BindToRenderStep(uid, 2000, UpdateOrientation)

	binds[frame] = {
		uid = uid,
		parts = parts,
	}
	return binds[frame].parts
end

-- Applies the `properties` table to bound parts.
function module:Modify(frame, properties)
	local parts = module:GetBoundParts(frame)
	if parts then
		for propName, propValue in pairs(properties) do
			for _, pt in pairs(parts) do
				pt[propName] = propValue
			end
		end
	else
	end
end

-- Removes the part binding from a gui object if one exists.
function module:UnbindFrame(frame)
	local cb = binds[frame]
	if cb then
		RunService:UnbindFromRenderStep(cb.uid)
		for _, v in pairs(cb.parts) do
			v:Destroy()
		end
		binds[frame] = nil
	else
	end
end

-- Returns true if a part binding exists for the gui object.
function module:HasBinding(frame)
	return binds[frame] ~= nil
end

-- Returns an array using this.
function module:GetBoundParts(frame)
	return binds[frame] and binds[frame].parts
end

return module
