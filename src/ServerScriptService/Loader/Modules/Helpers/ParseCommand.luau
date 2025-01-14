--// pyxfluff 2025
--// This code sucks, hopefully it will never have to be seen

return function(
	Input: string
): {Command: string, Flags: {}}
	local Options: {} = {}
	local Split = {}
	local Quotes = false
	local Buff = ""

	-- Split the input while handling quoted strings
	for char in string.gmatch(Input .. " ", ".") do
		if char == "'" or char == '"' then
			Quotes = not Quotes
		elseif char == " " and not Quotes then
			if Buff ~= "" then
				table.insert(Split, Buff)
				Buff = ""
			end
		else
			Buff = Buff .. char
		end
	end

	local i = 1
	while i <= #Split do
		local Phrase = Split[i]

		if string.sub(Phrase, 1, 2) == "--" then
			local key = string.sub(Phrase, 3)
			if i < #Split and not string.match(Split[i + 1], "^%-") then
				Options[key] = Split[i + 1]
				i = i + 1
			else
				Options[key] = true
			end
		elseif string.sub(Phrase, 1, 1) == "-" then
			local key = string.sub(Phrase, 2)
			if i < #Split and not string.match(Split[i + 1], "^%-") then
				Options[key] = Split[i + 1]
				i = i + 1
			else
				Options[key] = true
			end
		end

		i = i + 1
	end

	return {
		Command = Split[1],
		Flags = Options
	}
end
