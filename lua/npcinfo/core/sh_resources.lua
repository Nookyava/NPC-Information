NPC_STATS = {};

if SERVER then	
	/* Downloads */
	resource.AddFile("materials/nook/npc_information/hp_bar.png");
	
	/* Networking */
	util.AddNetworkString("NPC_STATS_receive_Table");
	util.AddNetworkString("NPC_STATS_send_Info");
	util.AddNetworkString("NPC_STATS_open_Menu");
	util.AddNetworkString("NPC_STATS_remove_Info");
else
	surface.CreateFont("npcdisplayfont", {
		font = "Roboto Condensed Regular", 
		size = 100, 
		weight = 500, 
		blursize = 0, 
		scanlines = 0, 
		antialias = true, 
		underline = false, 
		italic = false, 
		strikeout = false, 
		symbol = false, 
		rotary = false, 
		shadow = false, 
		additive = false, 
		outline = false, 
	});
	
	surface.CreateFont("npcmainfont", {
		font = "Roboto Condensed Regular", 
		size = 25, 
		weight = 500, 
		blursize = 0, 
		scanlines = 0, 
		antialias = true, 
		underline = false, 
		italic = false, 
		strikeout = false, 
		symbol = false, 
		rotary = false, 
		shadow = false, 
		additive = false, 
		outline = false, 
	});
	
	surface.CreateFont("npcsmallerfont", {
		font = "Roboto Condensed Regular", 
		size = 20, 
		weight = 500, 
		blursize = 0, 
		scanlines = 0, 
		antialias = true, 
		underline = false, 
		italic = false, 
		strikeout = false, 
		symbol = false, 
		rotary = false, 
		shadow = false, 
		additive = false, 
		outline = false, 
	});
end