/*
	Name: Flat Checkbox VGUI
	Author: Nookyava
*/

local PANEL = {};

function PANEL:Init()
	local w, h = self:GetSize();
	
	/* Blanks */
	self.DisabledImg = Material("icon16/tick.png");
	self.ActiveImg = Material("icon16/cross.png");
	
	timer.Simple(0, function() // Have to do a timer to get the correct values
		self.CurrentImg = self:GetActiveImg();
	end);
end

function PANEL:Paint()
	local w, h = self:GetSize();
	local imgW, imgH = 16, 16;
	
	/* Draw the Icon */
	surface.SetDrawColor(255, 255, 255, 255);
	surface.SetMaterial(self.CurrentImg);
	surface.DrawTexturedRect(w / 2 - imgW / 2, h / 2 - imgH / 2, imgW, imgH);
end

function PANEL:GetActiveImg()
	local isChecked = self:GetChecked();
	
	if !isChecked then
		return self.ActiveImg;
	else
		return self.DisabledImg;
	end
end

function PANEL:ChangeImage()
	local isChecked = self:GetChecked()
	self.CurrentImg = self:GetActiveImg();
end

vgui.Register("FlatCheckBox", PANEL, "DCheckBox")