local gui = script.Parent.Parent.Parent

local types = script:WaitForChild("ConfettiTypes")

local deleteConfettiAfter = 10 --Increasing the time will decrease performance

local rnd = Random.new()


--Creates a single confetti with random size
function CreateOne(origin, colors, minSize, maxSize)

	local allTypes = types:GetChildren()

	local confetti = allTypes[rnd:NextInteger(1, #allTypes)]:Clone()

	confetti.Position = origin

	local size = rnd:NextInteger(minSize, maxSize) * (gui.AbsoluteSize.X / 1920)
	local sizeScaleX = size / gui.AbsoluteSize.X
	local sizeScaleY = size / gui.AbsoluteSize.Y
	local sizeUDim = UDim2.new(sizeScaleX, 0, sizeScaleY, 0)

	confetti.Size = sizeUDim
	
	local color = colors[rnd:NextInteger(1, #colors)]
	if confetti:IsA("ImageLabel") then
		confetti.ImageColor3 = color
	end
	confetti.BackgroundColor3 = color

	confetti.Parent = gui

	game:GetService("Debris"):AddItem(confetti, deleteConfettiAfter)

	return confetti
end

--Moves a single confetti in a projectile motion
function MoveOne(confetti, upwardVelocity, horizontalVelocity, downwardAcceleration, angularVelocity)
	
	local origin = Vector2.new(confetti.AbsolutePosition.X, confetti.AbsolutePosition.Y)

	local sx = 0
	local sy = 0

	local u  = -upwardVelocity

	local a  = downwardAcceleration

	local t = 0


	local function GetS_Y()

		local S_Y = u*t + 1/2 * (a * t)^2
		return S_Y
	end
	
	local loopStart = tick()
	
	while confetti and confetti.Parent == gui do

		t = tick() - loopStart
		
		sx += horizontalVelocity
		sy = GetS_Y()
		
		local newX = origin.X + sx
		local newY = origin.Y + sy
		
		local newPos = UDim2.new(newX / gui.AbsoluteSize.X, 0, newY / gui.AbsoluteSize.Y, 0)
		
		local newRot = confetti.Rotation + angularVelocity
		
		confetti.Position = newPos
		confetti.Rotation = newRot
		
		if confetti.Position.X.Scale < 0 or confetti.Position.X.Scale > 1 or confetti.Position.Y.Scale > 1 then
			confetti:Destroy()
			break
		end

		game:GetService("RunService").Heartbeat:Wait()
	end
end

--Creates a group of confetti
function CreateConfetti(
	origin: UDim2, 

	count: number, 
	
	colors: {Color3},

	minSize: number, 
	maxSize: number, 

	minUpwardVelocity: number, 
	maxUpwardVelocity: number,

	minHorizontalSpeed: number, 
	maxHorizontalSpeed: number, 

	minDownwardAcceleration: number,
	maxDownwardAcceleration: number, 

	minAngularSpeed: number, 
	maxAngularSpeed: number
)

--  Parameters                Given values               Default values if no given value
	origin                  = origin                  or UDim2.new(0.5, 0, -.5, 0)
	count                   = count                   or 200
	colors                  = colors                  or {Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 119, 0), Color3.fromRGB(255, 234, 0), Color3.fromRGB(47, 255, 0), Color3.fromRGB(0, 255, 247), Color3.fromRGB(0, 4, 255), Color3.fromRGB(140, 0, 255), Color3.fromRGB(255, 0, 212)}
	minSize                 = minSize                 or 10
	maxSize                 = maxSize                 or 20
	minUpwardVelocity       = minUpwardVelocity       or 200
	maxUpwardVelocity       = maxUpwardVelocity       or 750
	minHorizontalSpeed      = minHorizontalSpeed      or 0
	maxHorizontalSpeed      = maxHorizontalSpeed      or 5
	minDownwardAcceleration = minDownwardAcceleration or 25
	maxDownwardAcceleration = maxDownwardAcceleration or 50
	minAngularSpeed         = minAngularSpeed         or 0
	maxAngularSpeed         = maxAngularSpeed         or 7

	for i = 1, count do

		task.wait(rnd:NextNumber(0, 0.05))

		local confetti = CreateOne(origin, colors, minSize, maxSize)

		local upwardVelocity = rnd:NextNumber(minUpwardVelocity, maxUpwardVelocity)

		local horizontalVelocity = rnd:NextNumber(minHorizontalSpeed, maxHorizontalSpeed)
		if rnd:NextNumber() > 0.5 then
			horizontalVelocity = -horizontalVelocity
		end

		local downwardAcceleration = rnd:NextNumber(minDownwardAcceleration, maxDownwardAcceleration)

		local angularVelocity = rnd:NextNumber(minAngularSpeed, maxAngularSpeed)
		if horizontalVelocity == 0 then
			angularVelocity = 0
		elseif horizontalVelocity < 0 then
			angularVelocity = -angularVelocity
		end

		upwardVelocity = upwardVelocity * (gui.AbsoluteSize.Y / 1080)
		downwardAcceleration = downwardAcceleration * (gui.AbsoluteSize.Y / 1080)
		horizontalVelocity = horizontalVelocity * (gui.AbsoluteSize.X / 1920)

		task.spawn(
			MoveOne, 
			confetti, upwardVelocity, horizontalVelocity, downwardAcceleration, angularVelocity
		)
	end
end

return CreateConfetti