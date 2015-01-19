/*
	Name: Flat Button VGUI
	Author: Nookyava
*/

local PANEL = {};

function PANEL:Init()
	local w, h = self:GetSize();
	
	/* Blanks */
	self.ButtonText = "Button";
	self.ButtonColor = Color(255, 255, 255, 155);
	self.ButtonTextColor = Color(33, 33, 33, 255);
	
	/* Button */
	self:SetText("");
end

function PANEL:Paint()
	local w, h = self:GetSize();
	
	draw.RoundedBox(0, 0, 0, w, h, self.ButtonColor);
	draw.SimpleText(self.ButtonText, "npcmainfont", w / 2, h / 2, self.ButtonTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
end

function PANEL:SetButtonText(txt)
	self.ButtonText = txt;
end

function PANEL:SetColors(bcol, btxtcol)
	self.ButtonColor = bcol;
	self.ButtonTextColor = btxtcol;
end

vgui.Register("FlatButton", PANEL, "DButton")