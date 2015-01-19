/*
	Name: Flat Body VGUI
	Author: Nookyava
*/

local PANEL = {};

function PANEL:Init()
	local w, h = self:GetSize();
	local sw, sh = ScrW(), ScrH();
	
	/* Blanks */
	self.BodyColor = Color(33, 33, 33, 155);
	
	self.HeaderName = "Header Name";
	self.HeaderColor = Color(255, 255, 255, 155);
	self.HeaderTextColor = Color(33, 33, 33, 255);
	
	/* Parent */
	self:MakePopup(true);
	self:ShowCloseButton(false);
	self:SetTitle("");
	
	/* Body */
	self.Body = vgui.Create("DPanel", self);
	
	/* Header */
	self.Header = vgui.Create("DPanel", self);
	
	/* Close Button */
	self.CloseButton = vgui.Create("FlatButton", self.Body);
	self.CloseButton:SetColors(Color(160, 0, 0, 225), Color(225, 225, 255));
	self.CloseButton:SetButtonText("Close");
	self.CloseButton.DoClick = function()
		self:Close();
	end
end

function PANEL:Paint()
	local w, h = self:GetSize();
	local sw, sh = ScrW(), ScrH();
	
	/* Header */
	local hw, hh = self.Header:GetSize();
	self.Header.Paint = function()
		draw.RoundedBox(0, 0, 0, hw, hh, self.HeaderColor);
		
		draw.SimpleText(self.HeaderName, "npcmainfont", hw / 2, hh / 2, self.HeaderTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
	end
	
	/* Body */
	local bw, bh = self.Body:GetSize();
	self.Body.Paint = function()
		draw.RoundedBox(0, 0, 0, bw, bh, self.BodyColor);
	end
end

function PANEL:SetHeaderName(txt)
	self.HeaderName = txt;
end

function PANEL:SetColors(bcol, hcol, htxtcol)
	self.BodyColor = bcol;
	
	self.HeaderColor = hcol;
	self.HeaderTextColor = htxtcol;
end

function PANEL:PerformLayout()
	local w, h = self:GetSize();
	
	/* Header */
	self.Header:SetSize(w, h / 6);
	
	/* Body */
	self.Body:SetSize(self:GetWide(), self:GetTall() - self.Header:GetTall());
	self.Body:SetPos(0, self.Header:GetTall());
	
	/* Close Button */
	self.CloseButton:SetSize(w / 2, h / 12);
	self.CloseButton:SetPos(self.Body:GetWide() / 2 - self.CloseButton:GetWide() / 2, self.Body:GetTall() - self.CloseButton:GetTall() - 25);
end

vgui.Register("FlatBody", PANEL, "DFrame")