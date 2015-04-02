local addonName, addon = ...
if not addon.healthCheck then return end

local frame = addon.frame
frame.name = addonName
frame:Hide()

frame:SetScript("OnShow", function(frame)

	local function newCheckbox(label, description, onClick)
		local check = CreateFrame("CheckButton", "CDSpy" .. label, frame, "InterfaceOptionsCheckButtonTemplate")
		check:SetScript("OnClick", function(self)
			PlaySound(self:GetChecked() and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
			onClick(self, self:GetChecked() and true or false)
		end)
		check.label = _G[check:GetName() .. "Text"]
		check.label:SetText(label)
		check.tooltipText = label
		check.tooltipRequirement = description
		return check
	end

	local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText(addonName)

	local override_box = newCheckbox(
		"Override (requires reload)",
		"are you sure y/n",
		function(self, value)
      CDSpyDB.override = value
      ReloadUI()
    end)
	override_box:SetChecked(CDSpyDB.override)
	override_box:SetPoint("TOPLEFT", title, "BOTTOMLEFT", -2, -16)
  
  local debug_box = newCheckbox(
		"Enable debug mode",
		"spam inc",
		function(self, value) CDSpyDB.debug_toggle = value end)
	debug_box:SetChecked(CDSpyDB.debug_toggle)
	debug_box:SetPoint("TOPLEFT", override_box, "BOTTOMLEFT", 0, -8) 
  
	local enable_box = newCheckbox(
		"Enable Global announcements",
		"hmm what does this do",
		function(self, value) CDSpyDB.enable_toggle = value end)
	enable_box:SetChecked(CDSpyDB.enable_toggle)
	enable_box:SetPoint("TOPLEFT", debug_box, "BOTTOMLEFT", 0, -8)  

	local taunt_toggle_box = newCheckbox(
		"Enable Taunt announcements",
		"OK whatever",
		function(self, value) CDSpyDB.taunt_toggle = value end)
	taunt_toggle_box:SetChecked(CDSpyDB.taunt_toggle)
	taunt_toggle_box:SetPoint("TOPLEFT", enable_box, "BOTTOMLEFT", 0, -8)

	local pug_toggle_box = newCheckbox(
		"Enable LFR spamming",
    "dude",
		function(self, value) CDSpyDB.pug_toggle = value end)
  pug_toggle_box:SetChecked(CDSpyDB.pug_toggle)
	pug_toggle_box:SetPoint("TOPLEFT", taunt_toggle_box, "BOTTOMLEFT", 0, -8)
  
  local info = {}
  local raidChannelDropdown = CreateFrame("Frame", "CDSpyRaidChannel", frame, "UIDropDownMenuTemplate")
  raidChannelDropdown:SetPoint("TOPLEFT", pug_toggle_box, "BOTTOMLEFT", -15, -10)
  raidChannelDropdown.initialize = function()
    wipe(info)
    local channels = {"RAID", "PARTY", "INSTANCE_CHAT", "GUILD", "SAY"}
    local names = {"RAID", "PARTY", "INSTANCE", "GUILD", "SAY"}
    for i, channel in next, channels do
      info.text = names[i]
      info.value = channel
      info.func = function(self)
        CDSpyDB.raid_output = self.value
        CDSpyRaidChannelText:SetText(self:GetText())
      end
      info.checked = channel == CDSpyDB.raid_output
      UIDropDownMenu_AddButton(info)
    end
  end
  CDSpyRaidChannelText:SetText("Raid Output")
  
  local partyChannelDropdown = CreateFrame("Frame", "CDSpyPartyChannel", frame, "UIDropDownMenuTemplate")
  partyChannelDropdown:SetPoint("LEFT", raidChannelDropdown, "RIGHT", 150, 0)
  partyChannelDropdown.initialize = function()
    wipe(info)
    local channels = {"RAID", "PARTY", "INSTANCE_CHAT", "GUILD", "SAY"}
    local names = {"RAID", "PARTY", "INSTANCE", "GUILD", "SAY"}
    for i, channel in next, channels do
      info.text = names[i]
      info.value = channel
      info.func = function(self)
        CDSpyDB.party_output = self.value
        CDSpyPartyChannelText:SetText(self:GetText())
      end
      info.checked = channel == CDSpyDB.party_output
      UIDropDownMenu_AddButton(info)
    end
  end
  CDSpyPartyChannelText:SetText("Party Output")
  
  local pugChannelDropdown = CreateFrame("Frame", "CDSpyPugChannel", frame, "UIDropDownMenuTemplate")
  pugChannelDropdown:SetPoint("LEFT", partyChannelDropdown, "RIGHT", 150, 0)
  pugChannelDropdown.initialize = function()
    wipe(info)
    local channels = {"RAID", "PARTY", "INSTANCE_CHAT", "GUILD", "SAY"}
    local names = {"RAID", "PARTY", "INSTANCE", "GUILD", "SAY"}
    for i, channel in next, channels do
      info.text = names[i]
      info.value = channel
      info.func = function(self)
        CDSpyDB.pug_output = self.value
        CDSpyPugChannelText:SetText(self:GetText())
      end
      info.checked = channel == CDSpyDB.pug_output
      UIDropDownMenu_AddButton(info)
    end
  end
  CDSpyPugChannelText:SetText("LFR Output")
  
  


	frame:SetScript("OnShow", nil)
end)
InterfaceOptions_AddCategory(frame)

