--[[
	Name: Shime
	Version: 1.0.1
	Description: Shime is a module that allows you to easily create a shimmer effect on any GuiObject.
	By: @WinnersTakesAll on Roblox & @RyanLua on GitHub

	Creator Marketplace: https://create.roblox.com/marketplace/asset/12959615382
	GitHub: https://github.com/RyanLua/Shime

	Wiki: https://github.com/RyanLua/Shime/wiki
	Getting Started: https://github.com/RyanLua/Shime/wiki/Getting-Started
	Documentation: https://github.com/RyanLua/Shime/wiki/Documentation
]]

--[[
	Copyright 2023 RyanLua
	
	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
	
		http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
]]

local Shime = {}
Shime.__index = Shime

local TweenService = game:GetService("TweenService")

-- Create a shimmer frame and return it
local function createShimmer(parent: GuiObject): Frame
	-- Create a new frame to hold the shimmer
	local frame = Instance.new("Frame")
	frame.Name = "UIShimmer"
	frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	frame.BackgroundTransparency = 0
	frame.ClipsDescendants = true
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.Parent = parent

	-- Update the corner radius of the frame when the UICorner or Parent changes
	local function updateCornerRadius()
		pcall(function() --// Silence incase frame.Parent is nil (Destroy())
			if frame.Parent:FindFirstChildOfClass("UICorner") then
				local parentCorner = frame.Parent:FindFirstChildOfClass("UICorner")

				-- Create a new UICorner for the frame
				local corner = Instance.new("UICorner")
				corner.CornerRadius = parentCorner.CornerRadius
				corner.Parent = frame

				-- Update the corner radius of the frame when the UICorner changes
				corner:GetPropertyChangedSignal("CornerRadius"):Connect(updateCornerRadius)
			end
		end)
	end
	frame:GetPropertyChangedSignal("Parent"):Connect(updateCornerRadius)
	updateCornerRadius()

	-- Update the size of the frame when the UIPadding changes
	local function updatePaddingOffset()
		pcall(function() --// Silence incase frame.Parent is nil (Destroy())
			if frame.Parent:FindFirstChildOfClass("UIPadding") then
				local padding = frame.Parent:FindFirstChildOfClass("UIPadding")

				local widthScale = padding.PaddingLeft.Scale + padding.PaddingRight.Scale
				local heightScale = padding.PaddingTop.Scale + padding.PaddingBottom.Scale
				local widthOffset = padding.PaddingLeft.Offset + padding.PaddingRight.Offset
				local heightOffset = padding.PaddingTop.Offset + padding.PaddingBottom.Offset
				local heightDiffOffset = padding.PaddingTop.Offset - padding.PaddingBottom.Offset
				local widthDiffOffset = padding.PaddingLeft.Offset - padding.PaddingRight.Offset
				local widthSize = 1 / (1 - widthScale)
				local heightSize = 1 / (1 - heightScale)

				frame.Size = UDim2.new(widthSize, widthOffset, heightSize, heightOffset)

				-- Update the position of the frame so it is centered
				frame.Position = UDim2.new(0.5, -widthDiffOffset / 2, 0.5, -heightDiffOffset / 2)
				print(frame.Position)

				-- Update the padding offset when the UIPadding changes
				padding:GetPropertyChangedSignal("PaddingLeft"):Connect(updatePaddingOffset)
				padding:GetPropertyChangedSignal("PaddingRight"):Connect(updatePaddingOffset)
				padding:GetPropertyChangedSignal("PaddingTop"):Connect(updatePaddingOffset)
				padding:GetPropertyChangedSignal("PaddingBottom"):Connect(updatePaddingOffset)
			end
		end)
	end
	frame:GetPropertyChangedSignal("Parent"):Connect(updatePaddingOffset)
	updatePaddingOffset()

	-- Create a new gradient for the frame
	local gradient = Instance.new("UIGradient")
	gradient.Rotation = 15
	gradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.15, 1),
		NumberSequenceKeypoint.new(0.5, 0.55),
		NumberSequenceKeypoint.new(0.85, 1),
		NumberSequenceKeypoint.new(1, 1),
	})
	gradient.Offset = Vector2.new(-1, 0)
	gradient.Parent = frame

	return frame
end

-- Playback state of the shimmer
Shime.PlaybackState = nil

-- Create a new Shimmer object
function Shime.new(
	parent: GuiObject,
	time: number?,
	style: Enum.EasingStyle?,
	direction: Enum.EasingDirection?,
	repeatCount: number?,
	reverses: boolean?,
	delayTime: number?
)
	-- Parameter validation
	assert(typeof(parent) == "Instance" and parent:IsA("GuiObject"), "Invalid parent argument. Expected GuiObject.")

	time = time or 1
	assert(typeof(time) == "number", "Invalid time argument. Expected number.")

	style = style or Enum.EasingStyle.Linear
	assert(
		typeof(style) == "EnumItem" and style.EnumType == Enum.EasingStyle,
		"Invalid style argument. Expected EasingStyle enum."
	)

	direction = direction or Enum.EasingDirection.InOut
	assert(
		typeof(direction) == "EnumItem" and direction.EnumType == Enum.EasingDirection,
		"Invalid direction argument. Expected EasingDirection enum."
	)

	repeatCount = repeatCount or -1
	assert(typeof(repeatCount) == "number", "Invalid repeatCount argument. Expected number.")

	reverses = reverses or false
	assert(typeof(reverses) == "boolean", "Invalid reverses argument. Expected boolean.")

	delayTime = delayTime or 0
	assert(typeof(delayTime) == "number", "Invalid delayTime argument. Expected number.")

	local self = setmetatable({}, Shime)

	-- Constants for the shimmer animation
	local EASING_TIME = time or 1 -- Time for shimmer animation
	local EASING_STYLE = style or Enum.EasingStyle.Linear -- Easing style for shimmer animation
	local EASING_DIRECTION = direction or Enum.EasingDirection.InOut -- Easing direction for easing style
	local REPEAT_COUNT = repeatCount or -1 -- Repeat amount for shimmer (negative number means infinite)
	local REVERSES = reverses or false -- Reverse direction of shimmer when it reaches the end
	local DELAY_TIME = delayTime or 0 -- Delay between each shimmer

	-- Create the shimmer frame and animation
	local shimmer = createShimmer(parent)
	self._frame = shimmer
	self._gradient = shimmer:FindFirstChildOfClass("UIGradient")
	self._corner = shimmer:FindFirstChildOfClass("UICorner")

	-- Create the tween
	self._tween = TweenService:Create(
		self._gradient,
		TweenInfo.new(EASING_TIME, EASING_STYLE, EASING_DIRECTION, REPEAT_COUNT, REVERSES, DELAY_TIME),
		{ Offset = Vector2.new(1, 0) }
	)

	-- Setup tween completion callback. Under default constants this will never be called as the tween will repeat infinitely
	self._tween.Completed:Connect(function()
		self:_TweenCompleted()
	end)

	return self
end

-- Setup tween completion callback
function Shime:_TweenCompleted()
	self._frame.Visible = false
	self.PlaybackState = Enum.PlaybackState.Completed
end

-- Get the shimmer frame
function Shime:GetFrame(): Frame
	return self._frame
end

-- Get the shimmer gradient
function Shime:GetGradient(): UIGradient
	return self._gradient
end

-- Get the ui corner of the shimmer frame
function Shime:GetCorner(): UICorner
	return self._corner
end

-- Start shimmering
function Shime:Play()
	self.PlaybackState = Enum.PlaybackState.Begin
	self._frame.Visible = true
	self._tween:Play()
	self.PlaybackState = Enum.PlaybackState.Playing
end

-- Pause shimmering
function Shime:Pause()
	if self.PlaybackState == Enum.PlaybackState.Playing then
		self._tween:Pause()
		self.PlaybackState = Enum.PlaybackState.Paused
	end
end

-- Cancel shimmering
function Shime:Cancel()
	self._tween:Cancel()
	self._frame.Visible = false
	self.PlaybackState = Enum.PlaybackState.Cancelled
end

return Shime
