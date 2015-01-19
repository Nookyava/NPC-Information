/* Convars */
local NPCLevels = GetConVar("NPC_STATS_Enable_Levels");
local NPCHealthEnabled = GetConVar("NPC_STATS_Enable_CHealth");
local NPCHealth = GetConVar("NPC_STATS_SetCHealth");
local NPCColorBar = GetConVar("NPC_STATS_BarColor");
local NPCInfoTrace = GetConVar("NPC_STATS_InfoTrace")
local NPCInfoTraceFade = GetConVar("NPC_STATS_InfoTraceFade")

/* Player Functions*/
local plyMeta = FindMetaTable("Player");

/*
	Name: createNPCInfoOptionsMenu (sh)
	Arguments: nil
	Returns: nil
	Desc: Opens the options menu for the addon
*/
function plyMeta:createNPCInfoOptionsMenu()
	if SERVER then
		net.Start("NPC_STATS_open_Menu")
		net.Send(self)
	else
		local mWidth, mHeight = 600, 400;
		local mPadding = 20;
			
		local mMain = vgui.Create("FlatBody")
		local mBody = mMain.Body; -- For easy calling later on
		mMain:SetSize(mWidth, mHeight);
		mMain:SetPos(ScrW() / 2 - mWidth / 2, ScrH() / 2 - mHeight / 2);
		mMain:SetHeaderName("NPC Info Addon");
		mMain:SetColors(Color(233, 233, 233, 255), Color(0, 163, 0, 255), Color(225, 225, 255, 255));
		
		local mListing = vgui.Create("DIconLayout", mBody)
		mListing:SetSize(mWidth, mHeight);
		mListing:SetPos(0, 0);
		
		local mlW, mlH = mListing:GetSize();
		
		/* Random Level */
		local mRandomLevel = mListing:Add("FlatItem");
		mRandomLevel:SetSize(mlW, mlH / 8);
		mRandomLevel:SetLabelText("Random Levels");
	
			/* Checkbox */
			local w, h = mRandomLevel:GetSize();
			mRandomLevel.CheckBox = vgui.Create("FlatCheckBox", mRandomLevel)
			mRandomLevel.CheckBox:SetSize(32, 32);
			mRandomLevel.CheckBox:SetPos(w - mRandomLevel.CheckBox:GetWide() - 11, (h / 2) - (mRandomLevel.CheckBox:GetTall() / 2));
			mRandomLevel.CheckBox:SetChecked(tobool(NPCLevels:GetString()));
			mRandomLevel.CheckBox.OnChange = function()
				RunConsoleCommand("NPC_STATS_Enable_Levels", tostring(!tobool(NPCLevels:GetString())));
				mRandomLevel.CheckBox:ChangeImage();
			end
		
		/* Custom Health */
		local mCustomHealthEntry;
		local mCustomHealth = mListing:Add("FlatItem");
		mCustomHealth:SetSize(mlW, mlH / 8);
		mCustomHealth:SetLabelText("Custom Health for all NPCS");
		
			/* Checkbox */
			local w, h = mCustomHealth:GetSize();
			mCustomHealth.CheckBox = vgui.Create("FlatCheckBox", mCustomHealth)
			mCustomHealth.CheckBox:SetSize(32, 32);
			mCustomHealth.CheckBox:SetPos(w - mCustomHealth.CheckBox:GetWide() - 11, (h / 2) - (mCustomHealth.CheckBox:GetTall() / 2));
			mCustomHealth.CheckBox:SetChecked(tobool(NPCHealthEnabled:GetString()));
			mCustomHealth.CheckBox.OnChange = function()
				RunConsoleCommand("NPC_STATS_Enable_CHealth", tostring(!tobool(NPCHealthEnabled:GetString())));
				mCustomHealth.CheckBox:ChangeImage();
				mCustomHealthEntry:SetDisabled(!mCustomHealth.CheckBox:GetChecked());
			end
			
			/* Text Entry */
			mCustomHealthEntry = vgui.Create("DTextEntry", mCustomHealth)
			mCustomHealthEntry:SetSize(150, 25);
			mCustomHealthEntry:SetText(NPCHealth:GetInt());
			mCustomHealthEntry:SetPos((mCustomHealth:GetWide() / 2 - mCustomHealthEntry:GetWide() / 2) + 90, mCustomHealth:GetTall() / 2 - mCustomHealthEntry:GetTall() / 2);
			mCustomHealthEntry:SetDisabled(!mCustomHealth.CheckBox:GetChecked());
			mCustomHealthEntry:SetTooltip("Custom health for all NPCs spawned with this setting on");
			mCustomHealthEntry.OnEnter = function(self)
				local val = self:GetValue();
				local CHealthE = tonumber(val);
				self:SetText(CHealthE or 100);
				
				RunConsoleCommand("NPC_STATS_SetCHealth", CHealthE or 100);
			end
		
		/* Bar Color */
		local mColorChooserBase;
		local mColorBarVar = string.ToColor(NPCColorBar:GetString());
		local mColorBar = mListing:Add("FlatItem");
		mColorBar:SetSize(mlW, mlH / 8);
		mColorBar:SetLabelText("Health Bar Color");
		mColorBar.ColorWheel = vgui.Create("DImageButton", mColorBar);
		mColorBar.ColorWheel:SetSize(16, 16);
		mColorBar.ColorWheel:SetImage("icon16/color_wheel.png");
		mColorBar.ColorWheel:SetPos(w - mColorBar.ColorWheel:GetWide() - 19, (h / 2) - (mColorBar.ColorWheel:GetTall() / 2));
		mColorBar.ColorWheel.DoClick = function()
			mMain:SetVisible(!mMain:IsVisible());
			mColorChooserBase:SetVisible(!mColorChooserBase:IsVisible());
		end
		
			/* Color Choice Base */
			mColorChooserBase = vgui.Create("FlatBody")
			mColorChooserBase:SetSize(350, 400);
			mColorChooserBase:SetPos(ScrW() / 2 - mColorChooserBase:GetWide() / 2, ScrH() / 2 - mColorChooserBase:GetTall() / 2);
			mColorChooserBase:SetVisible(false);
			mColorChooserBase:SetHeaderName("Health Bar Color");
			mColorChooserBase:SetColors(Color(233, 233, 233, 255), mColorBarVar, Color(225, 225, 255, 255));
			mColorChooserBase.CloseButton.DoClick = function()
				mMain:SetVisible(!mMain:IsVisible());
				mColorChooserBase:SetVisible(!mColorChooserBase:IsVisible());
			end
			
			/* Color Choice Menu */
			local mColorChooser = vgui.Create("DColorMixer", mColorChooserBase.Body)
			mColorChooser:SetPos(mColorChooserBase:GetWide() / 2 - mColorChooser:GetWide() / 2, 25);
			mColorChooser:SetColor(mColorBarVar);
			mColorChooser:SetAlphaBar(false);
			mColorChooser.ValueChanged = function(self, col)
				RunConsoleCommand("NPC_STATS_BarColor", string.FromColor(col));
				mColorBarVar = col;
				mColorChooserBase:SetColors(Color(233, 233, 233, 255), mColorBarVar, Color(225, 225, 255, 255));
			end
			
		/* Fade Away */
		local mFadeLook = mListing:Add("FlatItem");
		mFadeLook:SetSize(mlW, mlH / 8);
		mFadeLook:SetLabelText("Fade when not looking at NPC");
		
			/* Checkbox */
			local w, h = mFadeLook:GetSize();
			mFadeLook.CheckBox = vgui.Create("FlatCheckBox", mFadeLook)
			mFadeLook.CheckBox:SetSize(32, 32);
			mFadeLook.CheckBox:SetPos(w - mFadeLook.CheckBox:GetWide() - 11, (h / 2) - (mFadeLook.CheckBox:GetTall() / 2));
			mFadeLook.CheckBox:SetChecked(tobool(NPCInfoTrace:GetString()));
			mFadeLook.CheckBox.OnChange = function()
				RunConsoleCommand("NPC_STATS_InfoTrace", tostring(!tobool(NPCInfoTrace:GetString())));
				mFadeLook.CheckBox:ChangeImage();
			end
	end
end
