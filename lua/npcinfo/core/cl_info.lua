/* Convars */
local NPCLevels = GetConVar("NPC_STATS_Enable_Levels");
local NPCHealthEnabled = GetConVar("NPC_STATS_Enable_CHealth");
local NPCHealth = GetConVar("NPC_STATS_SetCHealth");
local NPCColorBar = GetConVar("NPC_STATS_BarColor");
local NPCInfoTrace = GetConVar("NPC_STATS_InfoTrace");
local NPCInfoTraceFade = GetConVar("NPC_STATS_InfoTraceFade");

/* Custom Functions*/
local function drawShadowedText(txt, font, x, y, col, shadowcol, xalign, yalign)
	draw.SimpleText(txt, font, x + 2, y + 2, shadowcol, xalign, yalign);
	draw.SimpleText(txt, font, x, y, col, xalign, yalign);
end

/* Hooks */
local vectorOffset = 16;
local barWidth, barHeight = 500, 100;
local boxWidth, boxHeight = 250, 195;
local outlineWidth = 20;
hook.Add("PostDrawOpaqueRenderables", "NPC_STATS.PostDrawOpaqueRenderables", function()	
	local ply = LocalPlayer();
	if !IsValid(ply) then return; end
	
	for _, npc in ipairs(ents.FindByClass("npc_*")) do
		if !IsValid(npc) or npc:Health() <= 0 then continue; end
		
		local npcID = npc:EntIndex();
		local npcStats = NPC_STATS[npcID];
		if !npcStats then continue; end
		
		local bumpRight = -5; -- Positioning for the bar
		local barColor = string.ToColor(NPCColorBar:GetString());
		barColor = Color(barColor.r, barColor.g, barColor.b, npcStats.CAlpha);
		
		if !barColor.r then
			RunConsoleCommand("NPC_STATS_BarColor", string.FromColor(Color(0, 160, 0)));
			print("[NPC-Information] You don't seem to have a color for the bar, adjusting.");
		end
		
		local npcHP, npcMaxHP, npcLevel, npcName = npc:Health(), npc:GetMaxHealth(), npcStats.Level, npc.Name or (language.GetPhrase(npc:GetClass()));
		npc.InfoPos = ((npc:LocalToWorld(npc:OBBCenter()*2)) + (vector_up * vectorOffset));
		
		if string.len(npcName) >= 15 then
			npcName = string.sub(npcName, 1, 11) .. "...";
		end
		
		if tobool(NPCInfoTrace:GetString()) then
			local plyTrace = ply:GetEyeTrace();
			local plyTraceEnt = plyTrace.Entity;		
			if plyTraceEnt != npc and npcStats.IsTraced then
				npcStats.IsTraced = false;
			elseif plyTraceEnt == npc and !npcStats.IsTraced then
				npcStats.IsTraced = true;
				npcStats.CAlpha = 255;
			end
			
			if !npcStats.IsTraced then
				if !npcStats.CAlpha then
					npcStats.CAlpha = 255;
				end
				
				if npcStats.CAlpha != 0 then
					if !npcStats.TFaded then
						npcStats.TFaded = true;
						npcStats.CAlpha = 255;
						npcStats.CAStart = CurTime();
						npcStats.CAEnd = CurTime()+NPCInfoTraceFade:GetInt();
					end

					local frac = math.TimeFraction(npcStats.CAStart, npcStats.CAEnd, CurTime());
					frac = math.Clamp(frac, 0, 1);

					npcStats.CAlpha = Lerp(frac, 255, 0);
					
					if npcStats.CAlpha == 0 then
						npcStats.TFaded = true;
					end
				end
			else
				if !npcStats.CAlpha or npcStats.CAlpha != 255 then
					npcStats.CAlpha = 255;
				end
				
				if npcStats.TFaded then
					npcStats.TFaded = false;
				end
			end
		else
			npcStats.CAlpha = 255;
		end
		
		local outlineColor = Color(66, 66, 66, npcStats.CAlpha)
		cam.Start3D2D(npc.InfoPos, Angle(0, EyeAngles().y - 90, 90), .05)
			/* Level */
			draw.RoundedBox(0, -1 * (barWidth), 200 - boxHeight, boxWidth, boxHeight, outlineColor);
			draw.RoundedBox(0, -1 * (barWidth) + outlineWidth / 2, 200 - boxHeight + outlineWidth / 2, boxWidth - outlineWidth, boxHeight - outlineWidth, Color(33, 33, 33, npcStats.CAlpha));
			local levelPosY = (195 - boxHeight) + boxHeight / 2;
			
			drawShadowedText(npcLevel, "npcdisplayfont", -1 * (barWidth) + boxWidth / 2, levelPosY, Color(233, 233, 233, npcStats.CAlpha), Color(0, 0, 0, npcStats.CAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
			
			/* Name */
			draw.RoundedBox(0, -1 * (barWidth / 2) - 10, 200 - boxHeight, barWidth, barHeight, outlineColor);
			draw.RoundedBox(0, -1 * (barWidth / 2) + outlineWidth / 2 - 10, 210 - boxHeight, barWidth - outlineWidth, barHeight - outlineWidth, Color(166, 166, 166, npcStats.CAlpha));
			local namePosY = (205 - boxHeight) + barHeight / 2 - outlineWidth / 2;
			
			drawShadowedText(npcName, "npcdisplayfont", 2, namePosY, Color(233, 233, 233, npcStats.CAlpha), Color(0, 0, 0, npcStats.CAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
			
			/* Health */
			draw.RoundedBox(0, -1 * (barWidth / 2) - 10, 295 - boxHeight, barWidth, barHeight, outlineColor);
			draw.RoundedBox(0, -1 * (barWidth / 2) + outlineWidth / 2 - 10, 305 - boxHeight, barWidth - outlineWidth, barHeight - outlineWidth, barColor);
			local healthPosY = (303 - boxHeight) + barHeight / 2 - outlineWidth / 2;
			
			drawShadowedText(npcHP .. "/" .. npcMaxHP, "npcdisplayfont", 2, healthPosY, Color(233, 233, 233, npcStats.CAlpha), Color(0, 0, 0, npcStats.CAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
		cam.End3D2D();
	end
end);

/* Net Receives */
net.Receive("NPC_STATS_open_Menu", function(len, CLIENT) // Opens the menu for the player
	LocalPlayer():createNPCInfoOptionsMenu();
end);

net.Receive("NPC_STATS_send_Info", function(len, CLIENT) // Gets the NPCs info
	local npcID = net.ReadInt(16);
	local npcTable = net.ReadTable();
	
	timer.Simple(0.1, function() // Need to do another slight delay here so the entity becomes valid for the client
		local npc = Entity(npcID);
		if !IsValid(npc) then return; end
		
		NPC_STATS[npcID] = npcTable;
		npc.Name = (language.GetPhrase(npc:GetClass()));
	end);
end);

net.Receive("NPC_STATS_remove_Info", function(len, CLIENT) // Removes the NPCs info from the client's table
	local npcID = net.ReadInt(16);
	
	NPC_STATS[npcID] = nil;
end);

net.Receive("NPC_STATS_receive_Table", function(len, CLIENT) // First joining, you'll receive the table
	NPC_STATS = net.ReadTable();
end);