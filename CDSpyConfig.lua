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
  
  local function CheckEditBoxRaid(self)
    local msg = self:GetText()
    CDSpyDB.raid_channel_name = msg
    CDSpyDB.raid_channel_id = GetChannelName(msg)
    options.update()
  end
  
  local function CheckEditBoxParty(self)
    local msg = self:GetText()
    CDSpyDB.party_channel_name = msg
    CDSpyDB.party_channel_id = GetChannelName(msg)
    options.update()
  end
  
  local function CheckEditBoxPug(self)
    local msg = self:GetText()
    CDSpyDB.pug_channel_name = msg
    CDSpyDB.pug_channel_id = GetChannelName(msg)
    options.update()
  end

  -- fancy "CDSpy" in the top left
	local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText(addonName)
  
  -- authors info
  local author_label = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	author_label:SetPoint("TOPLEFT", title, 0, -32)
	author_label:SetText("Authors:")
  
  local author_info = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	author_info:SetPoint("TOPLEFT",author_label,"TOPRIGHT",4,0)
	author_info:SetText("Madsushi and Perfect, Mal'Ganis-US")

  -- emaiil info
  local email_label = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	email_label:SetPoint("TOPLEFT", author_label, 0, -16)
	email_label:SetText("Email:")
  
  local email_info = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	email_info:SetPoint("TOPLEFT",email_label,"TOPRIGHT",4,0)
	email_info:SetText("madsushi@gmail.com")

	local override_box = newCheckbox(
		"Override (requires reload)",
		"are you sure y/n",
		function(self, value)
      CDSpyDB.override = value
      ReloadUI()
    end)
	override_box:SetChecked(CDSpyDB.override)
	override_box:SetPoint("TOPLEFT", email_label, "BOTTOMLEFT", -2, -16)
  
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
    local channels = {"RAID", "PARTY", "INSTANCE_CHAT", "GUILD", "SAY", "CHANNEL"}
    local names = {"RAID", "PARTY", "INSTANCE", "GUILD", "SAY", "CHANNEL"}
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
  
  
  
  local raid_channel_label = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	raid_channel_label:SetPoint("TOPLEFT", raidChannelDropdown, 20, -35)
	raid_channel_label:SetText("Custom Raid Channel")
  
  
  
  local raid_channel_id_box = CreateFrame("EditBox", "CDSpyRaidChannelID", frame, "InputBoxTemplate")
  
  function raid_channel_id_box:OnEditFocusGained()
    self.value = self:GetValue()
  end

  function raid_channel_id_box:OnEnterPressed()
    local value = self:GetValue()
    self:CDSpy('OnTextChanged', value)
    self:CDSpy('OnInput', value)
    self:CDSpy('OnUpdate')
    self:ClearFocus()
  end

  function raid_channel_id_box:OnEscapePressed()
    self:SetValue(self.value or '')
    self:ClearFocus()
  end
  
  
	raid_channel_id_box:SetPoint("TOPLEFT", raidChannelDropdown, "BOTTOMLEFT", 25, -20)
  raid_channel_id_box:SetSize(125, 20)
  raid_channel_id_box:SetAutoFocus(false)
	raid_channel_id_box:SetScript("OnShow", frame.update)
	raid_channel_id_box:SetScript("OnEnterPressed", CheckEditBoxRaid)
  raid_channel_id_box:SetScript("OnEditFocusLost", CheckEditBoxRaid)
  raid_channel_id_box:SetScript("OnTextChanged", CheckEditBoxRaid)
  raid_channel_id_box:SetText(CDSpyDB.raid_channel_name)
  
  


  
  local partyChannelDropdown = CreateFrame("Frame", "CDSpyPartyChannel", frame, "UIDropDownMenuTemplate")
  partyChannelDropdown:SetPoint("LEFT", raidChannelDropdown, "RIGHT", 150, 0)
  partyChannelDropdown.initialize = function()
    wipe(info)
    local channels = {"RAID", "PARTY", "INSTANCE_CHAT", "GUILD", "SAY", "CHANNEL"}
    local names = {"RAID", "PARTY", "INSTANCE", "GUILD", "SAY", "CHANNEL"}
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
  
  
  local party_channel_label = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	party_channel_label:SetPoint("TOPLEFT", partyChannelDropdown, 20, -35)
	party_channel_label:SetText("Custom Party Channel")
  
  
  local party_channel_id_box = CreateFrame("EditBox", "CDSpyPartyChannelID", frame, "InputBoxTemplate")
  
  function party_channel_id_box:OnEditFocusGained()
    self.value = self:GetValue()
  end

  function party_channel_id_box:OnEnterPressed()
    local value = self:GetValue()
    self:CDSpy('OnTextChanged', value)
    self:CDSpy('OnInput', value)
    self:CDSpy('OnUpdate')
    self:ClearFocus()
  end

  function party_channel_id_box:OnEscapePressed()
    self:SetValue(self.value or '')
    self:ClearFocus()
  end
  
  
	party_channel_id_box:SetPoint("TOPLEFT", partyChannelDropdown, "BOTTOMLEFT", 25, -20)
  party_channel_id_box:SetSize(125, 20)
  party_channel_id_box:SetAutoFocus(false)
	party_channel_id_box:SetScript("OnShow", frame.update)
	party_channel_id_box:SetScript("OnEnterPressed", CheckEditBoxParty)
  party_channel_id_box:SetScript("OnEditFocusLost", CheckEditBoxParty)
  party_channel_id_box:SetScript("OnTextChanged", CheckEditBoxParty)  
  party_channel_id_box:SetText(CDSpyDB.party_channel_id)
  
  
  
  
  local pugChannelDropdown = CreateFrame("Frame", "CDSpyPugChannel", frame, "UIDropDownMenuTemplate")
  pugChannelDropdown:SetPoint("LEFT", partyChannelDropdown, "RIGHT", 150, 0)
  pugChannelDropdown.initialize = function()
    wipe(info)
    local channels = {"RAID", "PARTY", "INSTANCE_CHAT", "GUILD", "SAY", "CHANNEL"}
    local names = {"RAID", "PARTY", "INSTANCE", "GUILD", "SAY", "CHANNEL"}
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
  
  
  local pug_channel_label = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	pug_channel_label:SetPoint("TOPLEFT", pugChannelDropdown, 20, -35)
	pug_channel_label:SetText("Custom PUG Channel")
  
  
  local pug_channel_id_box = CreateFrame("EditBox", "CDSpyPugChannelID", frame, "InputBoxTemplate")
  
  function pug_channel_id_box:OnEditFocusGained()
    self.value = self:GetValue()
  end

  function pug_channel_id_box:OnEnterPressed()
    local value = self:GetValue()
    self:CDSpy('OnTextChanged', value)
    self:CDSpy('OnInput', value)
    self:CDSpy('OnUpdate')
    self:ClearFocus()
  end

  function pug_channel_id_box:OnEscapePressed()
    self:SetValue(self.value or '')
    self:ClearFocus()
  end
  
  
	pug_channel_id_box:SetPoint("TOPLEFT", pugChannelDropdown, "BOTTOMLEFT", 25, -20)
  pug_channel_id_box:SetSize(125, 20)
  pug_channel_id_box:SetAutoFocus(false)
	pug_channel_id_box:SetScript("OnShow", frame.update)
	pug_channel_id_box:SetScript("OnEnterPressed", CheckEditBoxPug)
  pug_channel_id_box:SetScript("OnEditFocusLost", CheckEditBoxPug)
  pug_channel_id_box:SetScript("OnTextChanged", CheckEditBoxPug)
  pug_channel_id_box:SetText(CDSpyDB.pug_channel_id)
  


	frame:SetScript("OnShow", nil)
end)
InterfaceOptions_AddCategory(frame)

