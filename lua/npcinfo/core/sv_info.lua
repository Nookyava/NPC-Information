/* Convars */
local NPCLevels = CreateConVar("NPC_STATS_Enable_Levels", "true",  {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE})
local NPCHealthEnabled = CreateConVar("NPC_STATS_Enable_CHealth", "false", {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE})
local NPCHealth = CreateConVar("NPC_STATS_SetCHealth", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE})
local NPCColorBar = CreateConVar("NPC_STATS_BarColor", string.FromColor(Color(0, 160, 0)), {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE})
local NPCInfoTrace = CreateConVar("NPC_STATS_InfoTrace", "false", {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE})
local NPCInfoTraceFade = CreateConVar("NPC_STATS_InfoTraceFade", 3, {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}) --Fadeout time in seconds

/* Custom Functions */

/*
	Name: removeEntityFromTable (sv)
	Arguments: ent (entity)
	Returns: exists (boolean)
	Desc: Removes the NPC from the table, returns if it succeeded or not
*/

local function removeEntityFromTable(ent)
	local entID = ent:EntIndex()
	local exists = false
	
	for k, v in pairs(NPC_STATS) do
		if k != entID then continue end
		
		exists = true
	end
	
	if exists then		
		NPC_STATS[entID] = nil
		
		net.Start("NPC_STATS_remove_Info")
			net.WriteInt(entID, 16)
		net.Broadcast()
	end
	
	return exists
end

/* Hooks */
hook.Add("ShowSpare1", "NPC_STATS.ShowSpare1", function(ply)
	if !ply:IsSuperAdmin() then return end
	ply:createNPCInfoOptionsMenu()
end)

hook.Add("EntityRemoved", "NPC_STATS.CleanOnRemove", function(ent)
	removeEntityFromTable(ent)
end)

hook.Add("PlayerSay", "NPC_STATS.ChatCommand", function(ply, txt, team)
	if txt == "/npcinfo" and ply:IsSuperAdmin() then
		ply:createNPCInfoOptionsMenu()
		return ""
	end
end)

hook.Add("PlayerInitialSpawn", "NPC_STATS.PlayerInitialSpawn", function(ply)
	net.Start("NPC_STATS_receive_Table")
		net.WriteTable(NPC_STATS)
	net.Send(ply)
end)

hook.Add("OnNPCKilled", "NPC_STATS.CleanOnKill", function(ent, attacker, inflictor)
	removeEntityFromTable(ent)
end)

hook.Add("OnEntityCreated", "NPC_STATS.OnEntityCreated", function(ent)
	if !ent:IsNPC() or !IsValid(ent) then return end
	
	local NPC_Level, NPC_MaxHealth = math.random(1,100), 0
	local entID = ent:EntIndex()
	
	if !tobool(NPCLevels:GetString()) then
		NPC_Level = "??"
	end
	
	timer.Simple(0, function() // We need to do this for a frame later, network lag
		if !IsValid(ent) then
			print("[NPC-Information] Non-existant NPC found.") // Error catching, on certain NPCs it will error.
			return
		end
		
		if tobool(NPCHealthEnabled:GetString()) then
			NPC_MaxHealth = tonumber(NPCHealth:GetString())
		else
			if tobool(NPCLevels:GetString()) then
				NPC_MaxHealth = math.Round((NPC_Level * ent:Health()) / 10)
			else
				NPC_MaxHealth = ent:Health()
			end
		end
		
		ent:SetHealth(NPC_MaxHealth)
		ent:SetMaxHealth(NPC_MaxHealth)
	end)
	
	NPC_STATS[entID] = {
		Level = NPC_Level
	}
	
	// Instead of just sending the whole table of NPCs, we're just going to send the one we gave the values to
	net.Start("NPC_STATS_send_Info")
		net.WriteInt(entID, 16)
		net.WriteTable(NPC_STATS[entID])
	net.Broadcast()
end)
