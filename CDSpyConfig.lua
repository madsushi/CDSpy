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
		"Global Enable",
		"Really?",
		function(self, value) CDSpyDB.override = value end)
	override_box:SetChecked(CDSpyDB.override)
	override_box:SetPoint("TOPLEFT", title, "BOTTOMLEFT", -2, -16)

	local taunt_toggle_box = newCheckbox(
		"Enable Taunt announcements",
		"OK whatever",
		function(self, value) CDSpyDB.taunt_toggle = value end)
	taunt_toggle_box:SetChecked(CDSpyDB.taunt_toggle)
	taunt_toggle_box:SetPoint("TOPLEFT", override_box, "BOTTOMLEFT", 0, -8)

	local pug_toggle_box = newCheckbox(
		"Enable LFR",
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
  CDSpyRaidChannelText:SetText("Raid Output Channel")


	frame:SetScript("OnShow", nil)
end)
InterfaceOptions_AddCategory(frame)

