--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
_G.Ignore = {}
_G.Settings = {
	Players = {
		["Ignore Me"] = false,
		["Ignore Others"] = false,
		["Ignore Tools"] = false
	},
	Meshes = {
		NoMesh = true,
		NoTexture = true,
		Destroy = false
	},
	Images = {
		Invisible = true,
		Destroy = false
	},
	Explosions = {
		Smaller = true,
		Invisible = true, -- Not for PVP games
		Destroy = false -- Not for PVP games
	},
	Particles = {
		Invisible = true,
		Destroy = false
	},
	TextLabels = {
		LowerQuality = true,
		Invisible = false,
		Destroy = false
	},
	MeshParts = {
		LowerQuality = true,
		Invisible = false,
		NoTexture = false,
		NoMesh = true,
		Destroy = false
	},
	Other = {
		["FPS Cap"] = 120, -- true to uncap
		["No Camera Effects"] = true,
		["No Clothes"] = true,
		["Low Water Graphics"] = true,
		["No Shadows"] = true,
		["Low Rendering"] = true,
		["Low Quality Parts"] = true,
		["Low Quality Models"] = true,
		["Reset Materials"] = true,
	}
}
loadstring(game:HttpGet("https://raw.githubusercontent.com/CasperFlyModz/discord.gg-rips/main/FPSBooster.lua"))()
