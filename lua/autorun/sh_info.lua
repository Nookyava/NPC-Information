/*
	NPC-Information
	Created by Nookyava
	Last update was 1/17/15
*/

if SERVER then
	local folder, files;
	
	-- CORE --
	folder = "npcinfo/core";
	files, folders = file.Find(folder.."/*", "LUA");
	for _, file in pairs(files) do
		if string.StartWith(file, "sv") then
			include(folder.."/"..file);
		elseif string.StartWith(file, "sh") then
			include(folder.."/"..file);
			AddCSLuaFile(folder.."/"..file);
		elseif string.StartWith(file, "cl") then
			AddCSLuaFile(folder.."/"..file);
		end
	end
	
	-- VGUI --	
	folder = "npcinfo/vgui";
	files = file.Find(folder.."/*.lua", "LUA");
	for _, file in ipairs(files) do
		AddCSLuaFile(folder.."/"..file);
	end
else
	local folder, files;
	
	-- CORE --
	folder = "npcinfo/core";
	files, folders = file.Find(folder.."/*", "LUA");
		for _, file in pairs(files) do
		if string.StartWith(file, "sh") then
			include(folder.."/"..file);
		elseif string.StartWith(file, "cl") then
			include(folder.."/"..file);
		end
	end
	
	-- VGUI --
	folder = "npcinfo/vgui";
	files = file.Find(folder.."/*.lua", "LUA");
	for _, file in ipairs(files) do
		include(folder.."/"..file);
	end
end