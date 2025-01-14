local QuickBlur = {} :: QuickBlurImpl

type QuickBlurImpl = {
	Blur: (self: QuickBlurImpl, Image: EditableImage, Size: number?, Desample: number?) -> EditableImage,
}

function QuickBlur:Blur(Image, Size, Desample)
	Size = Size or 3
	Desample = Desample or 12

	local ImageWidth = Image.Size.X // Desample
	local ImageHeight = Image.Size.Y // Desample
	local OrginalSize = Image.Size
	local TotalRGBA = ImageWidth * ImageHeight * 4

	local ImageData = Image:ReadPixelsBuffer(Vector2.zero, Vector2.new(ImageWidth, ImageHeight))
	local rpx = {}

	for i = 0, TotalRGBA - 1 do
		table.insert(rpx, buffer.readu8(ImageData, i))
	end

	ImageData = rpx

	-- Apply blur effect
	for pass = 1, Size do
		for y = 0, ImageHeight - 1 do
			for x = 0, ImageWidth - 1 do
				-- Get indices for the neighboring pixels
				local function clamp(val, min, max)
					return math.max(min, math.min(max, val))
				end

				local top_left_index = clamp((y + 1) * ImageWidth * 4 + (x - 1) * 4 + 1, 1, TotalRGBA)
				local top_right_index = clamp((y + 1) * ImageWidth * 4 + (x + 1) * 4 + 1, 1, TotalRGBA)
				local low_left_index = clamp((y - 1) * ImageWidth * 4 + (x - 1) * 4 + 1, 1, TotalRGBA)
				local low_right_index = clamp((y - 1) * ImageWidth * 4 + (x + 1) * 4 + 1, 1, TotalRGBA)
				local buffer_index = clamp(y * ImageWidth * 4 + x * 4 + 1, 1, TotalRGBA)

				for offset = 0, 2 do
					local pixel = ImageData[buffer_index + offset]

					-- Neighboring pixels or defaults
					local top_left = ImageData[top_left_index + offset] or pixel
					local top_right = ImageData[top_right_index + offset] or pixel
					local low_left = ImageData[low_left_index + offset] or pixel
					local low_right = ImageData[low_right_index + offset] or pixel

					local top_centre = (top_right + top_left) / 2
					local low_centre = (low_right + low_left) / 2
					local mid_left = (low_left + top_left) / 2
					local mid_right = (low_right + top_right) / 2

					ImageData[buffer_index + offset] = (
						top_left
						+ top_right
						+ low_left
						+ low_right
						+ top_centre
						+ low_centre
						+ mid_left
						+ mid_right
						+ pixel
					) / 9
				end
			end
		end
	end

	-- Convert ImageData back to buffer format for WritePixelsBuffer
	local FinalBuffer = buffer.create(TotalRGBA)
	for i = 1, #ImageData do
		buffer.writeu8(FinalBuffer, i - 1, ImageData[i])
	end

	-- Write the modified buffer back to the image
	Image:WritePixelsBuffer(Vector2.zero, Vector2.new(ImageWidth, ImageHeight), FinalBuffer)

	return Image
end

return QuickBlur
