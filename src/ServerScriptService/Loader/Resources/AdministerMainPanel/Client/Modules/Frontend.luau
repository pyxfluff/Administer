--!strict
--// Administer (2.0.0)

--// Administer Team (2024-2025)

local Frontend = {}

function Frontend.CloneElement(
	Element: GuiObject, 
	Props: {},
	OnClone: ((Clone: GuiObject) -> ())?
): ()
	local Clone = Element:Clone()
	
	for Property, Value in Props do
		Clone[Property] = Value
	end
	
	Clone.Parent = Element
	
	if typeof(OnClone) == "nil" then
		return Clone
	else
		return OnClone(Clone)
	end
end



return Frontend