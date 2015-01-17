NPC_STATS = NPC_STATS or {}
NPC_STATS.NPCS = NPC_STATS.NPCS or {}

if SERVER then
	AddCSLuaFile()
	resource.AddFile("materials/nook/npc_information/hp_bar.png")
	
	local NPCLevels = CreateConVar("NPC_STATS_Enable_Levels", "true",  {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE})
	local NPCHealth = CreateConVar("NPC_STATS_SetCHealth", 0, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE})
	local NPCSize = CreateConVar("NPC_STATS_Size", "true", {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE})
	local NPCInfoTrace = CreateConVar("NPC_STATS_InfoTrace", "false", {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE})
	local NPCInfoTraceFade = CreateConVar("NPC_STATS_InfoTraceFade", 3, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}) --Fadeout time in seconds
	
	util.AddNetworkString("NPC_STATS_send_Info")
	
	hook.Add("PlayerInitialSpawn", "NPC_STATS.PlayerInitialSpawn", function(ply)
		for k,v in pairs(NPC_STATS.NPCS) do
			net.Start("NPC_STATS_send_Info")
				net.WriteInt(k, 16)
				net.WriteTable(NPC_STATS.NPCS[k])
			net.Send(ply)
		end
	end)
	
	hook.Add("OnEntityCreated", "NPC_STATS.OnEntityCreated", function(ent)
		if !ent:IsNPC() then return end
		
		timer.Simple(0, function()
			if !IsValid(ent) then return end
			
			local NPC_Level = math.random(1,100)
			local NPC_MaxHealth
			if tonumber(NPCHealth:GetString()) >= 1 then
				NPC_MaxHealth = tonumber(NPCHealth:GetString())
			elseif tonumber(NPCHealth:GetString()) == 0 then
				if tobool(NPCLevels:GetString()) then
					NPC_MaxHealth = math.Round((NPC_Level * ent:Health())/10)
				else
					NPC_MaxHealth = ent:Health()
				end
			end
			ent:SetHealth(NPC_MaxHealth)
			
			local entID = ent:EntIndex()
			NPC_STATS.NPCS[entID] = {MaxHealth = NPC_MaxHealth, Level = NPC_Level}
			net.Start("NPC_STATS_send_Info")
				net.WriteInt(entID, 16)
				net.WriteTable(NPC_STATS.NPCS[entID])
			net.Broadcast()
		end)
	end)
	
	hook.Add("ShowSpare1", "NPC_STATS.ShowSpare1", function(ply)
		if !ply:IsSuperAdmin() then return end
		ply:ConCommand("NPC_STATS_configMenu")
	end)
else
	surface.CreateFont("InfoText", {
		font = "MenuLarge",
		size = 30,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		shadow = true,
		outline = true
	})

	surface.CreateFont("HPText", {
		font = "MenuLarge",
		size = 15,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		shadow = true
	})
	
	hook.Add("OnPlayerChat", "npc_chatcommand", function(ply, strtext)
		if strtext == "/npcinfo" then
			ply:ConCommand("NPC_STATS_configMenu")
		end
	end)	

	local NPCLevels = GetConVar("NPC_STATS_Enable_Levels")
	local NPCHealth = GetConVar("NPC_STATS_SetCHealth")
	local NPCSize = GetConVar("NPC_STATS_Size")
	local NPCInfoTrace = GetConVar("NPC_STATS_InfoTrace")
	local NPCInfoTraceFade = GetConVar("NPC_STATS_InfoTraceFade")
	
	function NPC_STATS:ConfigMenu()
		local DMain = vgui.Create("DFrame")
		DMain:SetSize(500, 150)
		DMain:SetPos(ScrW()/2 - 200, ScrH()/2 - 100)
		DMain:MakePopup()
		DMain:SetTitle("NPC Config Menu")
	   
		local CLevels = vgui.Create( "DCheckBoxLabel", DMain)
		CLevels:SetPos(5, 32)
		CLevels:SetText("Random Levels (Disables HP based on Levels)")
		CLevels:SetChecked(tobool(NPCLevels:GetString()))
		CLevels.OnChange = function(self, val)
			RunConsoleCommand("NPC_STATS_Enable_Levels", tostring(!tobool(NPCLevels:GetString())))
		end
		CLevels:SizeToContents()
		
		local CHealth
		local CHS = vgui.Create("DCheckBoxLabel", DMain)
		CHS:SetText("Custom Health for all NPCs")
		CHS:SetChecked(NPCHealth:GetInt() >= 1)
		CHS:CopyPos(CLevels)
		CHS:MoveBelow(CLevels, 1)
		CHS:SizeToContents()
		CHS.OnChange = function(self, val)
			CHealth:SetDisabled(!val)
			if val then
				RunConsoleCommand("NPC_STATS_SetCHealth", 100)
				CHealth:SetText(100)
			else
				RunConsoleCommand("NPC_STATS_SetCHealth", 0)
				CHealth:SetText(0)
			end
		end
			
		CHealth = vgui.Create("DTextEntry", DMain)
		CHealth:CopyPos(CHS)
		CHealth:MoveRightOf(CHS, 5)
		CHealth:SetTall(20)
		CHealth:SetWide(37)
		CHealth:SetEnterAllowed(true)
		CHealth:SetText(NPCHealth:GetInt())
		CHealth:SetDisabled(!CHS:GetChecked())
		CHealth.OnEnter = function(self)
			local val = self:GetValue()
			local CHealthE = tonumber(val)
			self:SetText(CHealthE or 100)
			RunConsoleCommand("NPC_STATS_SetCHealth", CHealthE or 100)
		end
		
		local CSize = vgui.Create( "DCheckBoxLabel", DMain)
		CSize:SetText("Size Based on NPC's Level")
		CSize:CopyPos(CHS)
		CSize:MoveBelow(CHS, 1)
		CSize:SizeToContents()
		CSize:SetChecked(tobool(NPCSize:GetString()))
		CSize.OnChange = function(self, val)
			RunConsoleCommand("NPC_STATS_Size", tostring(!tobool(NPCSize:GetString())))
		end
		
		local InfoTrace
		local ITrace = vgui.Create("DCheckBoxLabel", DMain)
		ITrace:SetText("Crosshair on NPC's to see info")
		ITrace:SetChecked(tobool(NPCInfoTrace:GetString()))
		ITrace:CopyPos(CSize)
		ITrace:MoveBelow(CSize, 1)
		ITrace:SizeToContents()
		ITrace.OnChange = function(self, val)
			InfoTrace:SetDisabled(!val)
			RunConsoleCommand("NPC_STATS_InfoTrace", tostring(!tobool(NPCInfoTrace:GetString())))
		end
			
		InfoTrace = vgui.Create("DTextEntry", DMain)
		InfoTrace:CopyPos(ITrace)
		InfoTrace:MoveRightOf(ITrace, 5)
		InfoTrace:SetTall(20)
		InfoTrace:SetWide(37)
		InfoTrace:SetEnterAllowed(true)
		InfoTrace:SetText(NPCInfoTraceFade:GetInt())
		InfoTrace:SetDisabled(!ITrace:GetChecked())
		InfoTrace.OnEnter = function(self)
			local val = self:GetValue()
			local ITraceFade = tonumber(val)
			self:SetText(ITraceFade or 3)
			RunConsoleCommand("NPC_STATS_InfoTraceFade", ITraceFade)
		end
	end
	concommand.Add("NPC_STATS_configMenu", NPC_STATS.ConfigMenu)

	local hpBarMat = Material("nook/npc_information/hp_bar.png")
	local hpBarW, hpBarH = 155, 29
	local hpBarPadding = 12
	local zOffset = 75
	hook.Add("PostDrawOpaqueRenderables", "NPC_STATS.PostDrawOpaqueRenderables", function()
		local ply = LocalPlayer()
		if !IsValid(ply) then return end
		
		for _,npc in ipairs(ents.FindByClass("npc_*")) do
			if !IsValid(npc) or npc:Health() <= 0 then continue end
			
			local npcID = npc:EntIndex()
			local npcStats = NPC_STATS.NPCS[npcID]
			if !npcStats then continue end
			
			local npcHP = npc:Health()
			local npcMaxHP = npcStats.MaxHealth
			local npcLevel = npcStats.Level
			local npcInfo = npc.Name or (language.GetPhrase(npc:GetClass()))
			
			local hpBarLen = (npcHP/npcMaxHP) * hpBarW
			npc.InfoPos = ((npc:LocalToWorld(npc:OBBCenter()*2)) + (vector_up * 34))
			
			if tobool(NPCInfoTrace:GetString()) then
				local plyTrace = ply:GetEyeTrace()
				local plyTraceEnt = plyTrace.Entity				
				if plyTraceEnt != npc and npcStats.IsTraced then
					npcStats.IsTraced = false
				elseif plyTraceEnt == npc and !npcStats.IsTraced then
					npcStats.IsTraced = true
					npcStats.CAlpha = 255
				end
				
				
				if !npcStats.IsTraced then
					if !npcStats.CAlpha then
						npcStats.CAlpha = 255
					end
					
					if npcStats.CAlpha != 0 then
						if !npcStats.TFaded then
							npcStats.TFaded = true
							npcStats.CAlpha = 255
							npcStats.CAStart = CurTime()
							npcStats.CAEnd = CurTime()+NPCInfoTraceFade:GetInt()
						end

						local frac = math.TimeFraction(npcStats.CAStart, npcStats.CAEnd, CurTime())
						frac = math.Clamp(frac, 0, 1)

						npcStats.CAlpha = Lerp(frac, 255, 0)
						
						if npcStats.CAlpha == 0 then
							npcStats.TFaded = true
						end
					end
				else
					if !npcStats.CAlpha or npcStats.CAlpha != 255 then
						npcStats.CAlpha = 255
					end
					if npcStats.TFaded then
						npcStats.TFaded = false
					end
				end
			end
			
			cam.Start3D2D(npc.InfoPos, Angle(0, EyeAngles().y-90, 90), 0.25 )
				if tobool(NPCLevels:GetString()) then
					npcInfo = "("..npcLevel..") "..npcInfo
				end
				draw.DrawText(npcInfo, "InfoText", 2, 32, Color(155, 155, 155, npcStats.CAlpha), TEXT_ALIGN_CENTER)			
				
				local topBarH = 15
				local lowBarH = 4
				local totalBarHeight = topBarH+lowBarH+hpBarPadding
				surface.SetMaterial(hpBarMat)
				surface.SetDrawColor(255,255,255,npcStats.CAlpha or 255)
				surface.DrawTexturedRect(-(hpBarW/2)-(hpBarPadding/2), zOffset, hpBarW+hpBarPadding, totalBarHeight)
				
				--Top Bar
				surface.SetDrawColor(92,173,90,npcStats.CAlpha or 255)
				surface.DrawRect(-(hpBarW/2), zOffset+((totalBarHeight)/2)-(topBarH/2)-(lowBarH/2), hpBarLen, topBarH)
			
				--Lower Bar
				surface.SetDrawColor(56,104,56,npcStats.CAlpha or 255)
				surface.DrawRect(-(hpBarW/2), zOffset+((totalBarHeight)/2)-(topBarH/2)-(lowBarH/2)+topBarH, hpBarLen, 4)
				
				draw.DrawText(npcHP.. "/"..npcMaxHP, "HPText", 0, zOffset+((totalBarHeight)/2)-(topBarH/2)-(lowBarH/2), Color(55, 55, 55, npcStats.CAlpha or 255), TEXT_ALIGN_CENTER)
			cam.End3D2D()
		end
	end)
	
	net.Receive("NPC_STATS_send_Info", function(len)
		local npcID = net.ReadInt(16)
		local npc = Entity(npcID)
		if !IsValid(npc) then return end
		
		NPC_STATS.NPCS[npcID] = net.ReadTable()
		npc.Name = (language.GetPhrase(npc:GetClass()))

		if tobool(NPCSize:GetString()) then
			local npcLevel = NPC_STATS.NPCS[npcID].Level
			local maxLevel = 100
			local npcScale = npc:GetModelScale()
			local diff = 1+(npcLevel/maxLevel)
			npc:SetModelScale(npcScale*diff, 0)
		end
	end)
end