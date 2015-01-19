/*
	Name: Flat Item VGUI
	Author: Nookyava
*/

local PANEL = {};

function PANEL:Init()
	local w, h = self:GetSize();
	
	/* Blanks */
	self.NameText = "Example";
end

function PANEL:Paint()
	local w, h = self:GetSize();
	
	draw.SimpleText(self.NameText, "npcmainfont", 15, h / 2, Color(33, 33, 33), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
	draw.RoundedBox(0, 16, h - 2, w - 32, 2, Color(213, 213, 213));
end

function PANEL:SetLabelText(txt)
	self.NameText = txt;
end

function PANEL:PerformLayout()
	local w, h = self:GetSize();
end

vgui.Register("FlatItem", PANEL, "DPanel")