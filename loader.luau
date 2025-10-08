repeat
	task.wait()
until game:IsLoaded() and game:GetService('Players').LocalPlayer

local PlaceId = game.PlaceId
local Path = "https://raw.githubusercontent.com/realkhaw/Visual/refs/heads/main/Data/"

local DATA = {
	[131716211654599] = 'Fisch'
}

loadstring(game:HttpGet(`{Path}{DATA[PlaceId]}`))()
