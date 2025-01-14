--[[
Created by: Apergos
Description: Module for creating buffers out of tables and the opposite.
Notes: Supports only strings, numbers and nested tables as table items.
       Toggle ERROR_MODE attribute to stop execution on error.
       More efficient encoding methods may be added in the future.
Version: 1.1b
Last update: 2024/11/7
]]
--

type Header = { number & number } -- {data_t, size}
--[[
data_t:
	0x1 - unsigned integer
	0x2 - signed integer
	0x3 - string
	0x4 - table
	0x5 - homogenous table
	max - 0xF
size:
	integer: 1, 2, 4
	string: any
	table: any
	max - 4095
]]
--
type BufOperation = (buf: buffer, offset: number, value: number?) -> ()

local function choose_buf_oper(elm_size: number, positive: boolean, is_write: boolean): BufOperation
	local func

	if elm_size <= 1 then
		if is_write then
			func = positive and buffer.writeu8 or buffer.writei8
		else
			func = positive and buffer.readu8 or buffer.readi8
		end
	elseif elm_size <= 2 then
		if is_write then
			func = positive and buffer.writeu16 or buffer.writei16
		else
			func = positive and buffer.readu16 or buffer.readi16
		end
	elseif elm_size <= 4 then
		if is_write then
			func = positive and buffer.writeu32 or buffer.writei32
		else
			func = positive and buffer.readu32 or buffer.readi32
		end
	end

	return func
end

local function sizeofNumber(num: number): number
	local size: number, max: number
	if num > 0 then
		max = 0xff + 1
	else
		max = 0x80 + 1
		num = -num
	end

	if num < max then
		size = 1
	elseif num < max * 256 then
		size = 2
	else
		size = 4
	end
	return size
end

--Returns a table containing data type and size
local function headerofElement(elm: any): Header
	local t = typeof(elm)
	local size: number, data_t: number

	if t == "string" then
		data_t = 0x3
		size = #elm
	elseif t == "table" then
		data_t = 0x4
		size = #elm
	else
		if t ~= "number" then
			local message = "Unsupported data type encountered while encoding."
			local void = script:GetAttribute("ERROR_MODE") and error(message)
				or warn(message .. " Assuming one byte integer.")
			size = 1
		end

		if elm < 0 then
			data_t = 0x2
		else
			data_t = 0x1
		end
		size = size or sizeofNumber(elm)
	end

	if size >= 256 then
		local message = "Element size is too large while encoding."
		local void = script:GetAttribute("ERROR_MODE") and error(message) or warn(message .. " Data truncated.")
		size = 255
	end

	return { data_t, size }
end

--Returns a header of homogenous table elements or nil if not homogenous
local function headerofRepeatElems(tbl: { any }): Header?
	if #tbl < 2 then return end
	local header = headerofElement(tbl[1])

	for i = 2, #tbl do
		local cmp_header = headerofElement(tbl[i])
		if (header[1] ~= cmp_header[1]) or (header[1] >= 0x03 and header[2] ~= cmp_header[2]) then return end

		if header[1] <= 0x2 then
			if header[2] > cmp_header[2] then cmp_header[2] = header[2] end
			header[2] = cmp_header[2]
		end
	end
	return header
end

--Returns the amount of bytes needed to encode given table
local function sizeofTable(tbl: { any } | any, optimized: boolean): number
	local t = typeof(tbl)
	local size = 2

	if t == "table" then
		for i = 1, #tbl do
			size += sizeofTable(tbl[i], optimized)
		end

		--Reduce size if can be optimized
		if optimized and headerofRepeatElems(tbl) then
			size -= (#tbl - 1) * 2
		end
	elseif t == "string" then
		size += #tbl
	else
		if t ~= "number" then
			local message = "Unsupported data type encountered while determining data size."
			local void = (
				script:GetAttribute("ERROR_MODE") and error(message)
				or warn(message .. " Assuming one byte integer.")
			)
			size += 1
		else
			size += sizeofNumber(tbl)
		end
	end

	return size
end

--Returns a table of data type and size read from buffer
local function bufferElmHeader(buf: buffer, offset: number): Header
	return { buffer.readu8(buf, offset + 1), buffer.readu8(buf, offset) }
end

TablesAndBuffers = {
	--Transforms table into buffer
	encode = function(tbl_in: { any }, optimized: boolean): buffer
		local buf_len: number = sizeofTable(tbl_in, optimized)
		local buf: buffer = buffer.create(buf_len)

		--Writes table data into a buffer
		--Returns the byte length of written data
		local function write_buf(tbl: { any } | any, buf: buffer, offset: number, write_head: Header?): number
			if typeof(tbl) == "table" then
				local header: Header
				if write_head then
					write_head = nil
				else --Not a homogenous table item:
					header = headerofElement(tbl)
					local displacement = 0
					if optimized then
						write_head = headerofRepeatElems(tbl)

						if write_head then
							buffer.writeu16(buf, offset + 2, write_head[1] * 256 + write_head[2])
							displacement += 2
						end
					end

					buffer.writeu16(buf, offset, (header[1] + (write_head and 1 or 0)) * 256 + header[2])
					offset += 2 + displacement
				end

				for i = 1, header[2] do
					offset = write_buf(tbl[i], buf, offset, write_head)
				end
			else --Not table:
				if write_head == nil then
					write_head = headerofElement(tbl)
					buffer.writeu16(buf, offset, write_head[1] * 256 + write_head[2])
					offset += 2
				end

				(write_head[1] == 0x03 and buffer.writestring or choose_buf_oper(
					write_head[2],
					write_head[1] == 0x01,
					true
				))(buf, offset, tbl)
				offset += write_head[2]
			end

			return offset
		end

		local length = write_buf(tbl_in, buf, 0)
		if buf_len ~= length then
			local message = "Buffer length and data length do not match."
			local void = script:GetAttribute("ERROR_MODE") and error(message) or warn(message .. " Continuing.")
		end
		return buf
	end,

	--Transforms buffer into table
	decode = function(buf_in: buffer): { any }
		print(buf_in)
		print(buffer.len(buf_in))

		--Writes buffer data into a table
		--Returns the byte length of read data
		local function read_buf(buf: buffer, tbl: { any }, offset: number, read_head: Header?): number
			local header: Header
			if read_head then
				header = read_head
				read_head = nil
			else --Not a homogenous table item:
				header = bufferElmHeader(buf, offset)
				offset += 2
			end

			if header[1] >= 0x04 and header[1] <= 0x05 then --Is table element:
				local sub_tbl = {}
				if header[1] == 0x05 then
					read_head = bufferElmHeader(buf, offset)
					offset += 2
				end

				for i = 1, header[2] do
					offset = read_buf(buf, sub_tbl, offset, read_head)
				end
				tbl[#tbl + 1] = sub_tbl
			elseif header[1] <= 0x02 then --Is an integer:
				tbl[#tbl + 1] = choose_buf_oper(header[2], header[1] == 0x01, false)(buf, offset)
				offset += header[2]
			else
				if header[1] > 0x05 then --Is unrecognized data type:
					local message = "Unrecognised data type when decoding."
					local void = script:GetAttribute("ERROR_MODE") and error(message)
						or warn(message .. " Assuming string.")
				end

				tbl[#tbl + 1] = buffer.readstring(buf, offset, header[2])
				offset += header[2]
			end
			return offset
		end

		local tbl_out = {}
		local length = read_buf(buf_in, tbl_out, 0)
		print(tbl_out)
		tbl_out = tbl_out[1]
		print(tbl_out)

		if buffer.len(buf_in) ~= length then
			local message = "Buffer length and data length do not match."
			local void = script:GetAttribute("ERROR_MODE") and error(message) or warn(message .. " Continuing.")
		end
		return tbl_out
	end,
}

return TablesAndBuffers
