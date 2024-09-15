local QuickBlur = {} :: QuickBlurImpl

type QuickBlurImpl = {
	Blur : (self : QuickBlurImpl, Image : EditableImage, Size : number?, Desample : number?) -> EditableImage
}

function QuickBlur:Blur(Image, Size, Desample)
	
	-- Arguments
	-- Image : Feed me an EditableImage
	-- Size [OPTIONAL] : How blury the image should be. Large values may take some time to compute, < 8 is good enough
	-- Desample  [OPTIONAL] : Lowers the image resolution for faster processing, doesn't really effect the blur result
	
	Size = Size or 3
	Desample = Desample or 8

	local ImageWidth = Image.Size.X//Desample
	local ImageHeight = Image.Size.Y//Desample
	
	local OrginalSize = Image.Size
	local DownsampledSize = Vector2.new(ImageWidth,ImageHeight)

	local TotalRGBA = (ImageWidth*ImageHeight) * 4

	-- Resample image to improve speed
	-- Maybe that's cheating but whateverr
	Image = Image:Clone()
	Image:Resize(DownsampledSize)
	
	local ImageData = Image:ReadPixels(Vector2.new(),DownsampledSize)
	
	local buffer_index

	local top_left_index
	local top_right_index
	local low_left_index
	local low_right_index

	local top_left 
	local top_right
	local low_left
	local low_right
	
	local top_centre
	local low_centre
	local mid_left
	local mid_right
	local pixel
	local default
	
	for pass = 1, Size do

		for y = 0, ImageHeight - 1 do
			
			for x = 0, ImageWidth - 1 do
				
				top_left_index =  ((ImageWidth * 4 * (y + 1) + (x - 1) * 4) + 1) 
				top_right_index = ((ImageWidth * 4 * (y + 1) + (x + 1) * 4) + 1) 
				low_left_index =  ((ImageWidth * 4 * (y - 1) + (x - 1) * 4) + 1) 
				low_right_index = ((ImageWidth * 4 * (y - 1) + (x + 1) * 4) + 1) 
				buffer_index = ((ImageWidth * 4 * (y) + (x) * 4) + 1) 
				
				for offset = 0,2 do
					
					pixel = ImageData[buffer_index + offset]
					
					top_left 	= ImageData[top_left_index + offset]  or pixel 
					top_right   = ImageData[top_right_index + offset]  or pixel 			
					low_left    = ImageData[low_left_index + offset]  or top_left
					low_right   = ImageData[low_right_index + offset]  or top_right
					
					top_centre = top_left + (top_right - top_left) * 0.5;
					low_centre = low_left + (low_right - low_left) * 0.5;
					mid_left   = top_left + (low_left - top_left) * 0.5;
					mid_right  = top_right + (low_right - top_right) * 0.5;
					
					ImageData[buffer_index + offset] = (
						top_left + top_right + low_left + low_right + top_centre + low_centre + mid_left + mid_left + pixel
					) / 9
					
				end
			
			end
			
		end

	end
	
	Image:WritePixels(Vector2.new(),DownsampledSize,ImageData)
	Image:Resize(OrginalSize)
	return Image
	
end

return QuickBlur
