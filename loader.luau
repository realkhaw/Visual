repeat
	task.wait()
until game:IsLoaded() and game:GetService('Players').LocalPlayer

local PlaceId = game.GameId
local Path = "https://raw.githubusercontent.com/realkhaw/Visual/refs/heads/main/Data/"

local DATA = {
	[5750914919] = 'Fisch'
}

loadstring(game:HttpGet(`{Path}{DATA[PlaceId]}`))()
