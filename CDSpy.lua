local CDSpy = CreateFrame("Frame")
local addonName, addon = ...

--_G[addonName] = addon
addon.healthCheck = true

local eventFrame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
addon.frame = eventFrame

-- CastAnnounce
local cast              = "%s casts %s!"
local use               = "%s uses %s!"
local create_a          = "%s creates a %s!"
local create_an         = "%s creates an %s!"
local begin             = "%s begins a %s!"
local place             = "%s places a %s!"
local drink             = "%s drinks a %s!"
local beat              = "%s beats %s!"
local use_on            = "%s uses %s on %s!"
local cast_on           = "%s casts %s on %s!"
local awaken            = "%s awakens %s!"

 
-- FadeAnnounce
local fade_from_target  = "%s's %s fades from %s!" -- healer-style
local fade              = "%s's %s fades!"          -- generic raid-wide style
 
 
-- CastCriteria
--SPELL_CAST_SUCCESS  -- most
--SPELL_AURA_APPLIED  -- rarer (almost none)
--SPELL_HEAL      -- Guardian Spirit / Ardent Defender
--SPELL_CREATE    -- portals / toys
--SPELL_CAST_START-- feasts
--SPELL_SUMMON    -- Lightwell
--SPELL_RESURRECT -- Rez
 
 
-- FadeCriteria
--SPELL_AURA_REMOVED  -- most/all
 
 
-- RoleCriteria
--tank -- marked as tank in raid frames
--healer -- has >X max mana
 
-- SPECIAL SPELLZ
--Reincarnate
--Pet Lust -- (need owner name, not pet name)
--Soulstone -- died with a stone, not cast on someone

local _, instance
local raid_channel_id, party_channel_id, pug_channel_id
local sacrifice, soulstones, reincarnations = {}, {}, {}
local raid_toggle, party_toggle, pug_toggle, taunt_toggle
local override

-- Upvalues
local UnitAffectingCombat, UnitName, UnitHealthMax, UnitManaMax, UnitExists = UnitAffectingCombat, UnitName, UnitHealthMax, UnitManaMax, UnitExists
local GetSpellLink, format, match = GetSpellLink, string.format, string.match

 
local SpellArray = {
 
  [48982] = {
--  Death Knight
--  Rune Tap
    SpellID = "48982",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade,
    TankCriteria = true,
--  HealerCriteria = ,
    
  },
 
  [48707] = {
--  Death Knight
--  Anti Magic Shell
    SpellID = "48707",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade,
    TankCriteria = true,
--  HealerCriteria = ,
    
  },
 
  [48792] = {
--  Death Knight
--  Icebound Fortitude
    SpellID = "48792",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade,
    TankCriteria = true,
--  HealerCriteria = ,
    
  },
 
  [51052] = {
--  Death Knight
--  Anti Magic Zone
    SpellID = "51052",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = use,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [61999] = {
--  Death Knight
--  Raise Ally
    SpellID = "61999",
    CastCriteria = "SPELL_RESURRECT",
    CastAnnounce = cast_on,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [108199] = {
--  Death Knight
--  Gorefiend's Grasp
    SpellID = "108199",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = use,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [56222] = {
--  Death Knight
--  Dark Command
    SpellID = "56222",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
--  FadeCriteria = ,
--  FadeAnnounce = ,
    TankCriteria = true,
--  HealerCriteria = ,
    TauntCriteria = true,
    
  },
 
  [22812] = {
--  Druid
--  Barkskin
    SpellID = "22812",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade,
    TankCriteria = true,
--  HealerCriteria = ,
    
  },
 
  [61336] = {
--  Druid
--  Survival Instincts
    SpellID = "61336",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade,
    TankCriteria = true,
--  HealerCriteria = ,
    
  },
 
  [33891] = {
--  Druid
--  Tree of Life
    SpellID = "33891",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade,
--  TankCriteria = ,
    HealerCriteria = true,
    
  },
 
  [740] = {
--  Druid
--  Tranquility
    SpellID = "740",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade,
--  TankCriteria = ,
    HealerCriteria = true,
    
  },
 
  [102342] = {
--  Druid
--  Ironbark
    SpellID = "102342",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast_on,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade_from_target,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [20484] = {
--  Druid
--  Rebirth
    SpellID = "20484",
    CastCriteria = "SPELL_RESURRECT",
    CastAnnounce = cast_on,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [6795] = {
--  Druid
--  Growl
    SpellID = "6795",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    TauntCriteria = true,
    
  },
 
  [90355] = {
--  Hunter
--  Ancient Hysteria
    SpellID = "90355",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
--  [172106] = { -- removed in 6.2
--  Hunter
--  Aspect of the Fox
--    SpellID = "172106",
--    CastCriteria = "SPELL_CAST_SUCCESS",
--    CastAnnounce = cast,
--   FadeCriteria = "SPELL_AURA_REMOVED",
--    FadeAnnounce = fade,
--  TankCriteria = ,
--  HealerCriteria = ,
--    SpamCriteria = true,
    
--  },
 
  [34477] = {
--  Hunter
--  Misdirection
    SpellID = "34477",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = use_on,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [126393] = {
--  Hunter
--  Eternal Guardian
    SpellID = "126393",
    CastCriteria = "SPELL_RESURRECT",
    CastAnnounce = cast_on,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [2649] = {
--  Hunter
--  Pet Growl
    SpellID = "2649",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = use,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [53142] = {
--  Mage
--  Portal: Dalaran (H/A)
    SpellID = "53142",
    CastCriteria = "SPELL_CREATE",
    CastAnnounce = create_a,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [11417] = {
--  Mage
--  Portal: Orgrimmar (H)
    SpellID = "11417",
    CastCriteria = "SPELL_CREATE",
    CastAnnounce = create_a,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [11418] = {
--  Mage
--  Portal: Undercity (H)
    SpellID = "11418",
    CastCriteria = "SPELL_CREATE",
    CastAnnounce = create_a,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [11420] = {
--  Mage
--  Portal: Thunder Bluff (H)
    SpellID = "11420",
    CastCriteria = "SPELL_CREATE",
    CastAnnounce = create_a,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [32267] = {
--  Mage
--  Portal: Silvermoon (H)
    SpellID = "32267",
    CastCriteria = "SPELL_CREATE",
    CastAnnounce = create_a,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [35717] = {
--  Mage
--  Portal: Shattrath (H)
    SpellID = "35717",
    CastCriteria = "SPELL_CREATE",
    CastAnnounce = create_a,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [49361] = {
--  Mage
--  Portal: Stonard (H)
    SpellID = "49361",
    CastCriteria = "SPELL_CREATE",
    CastAnnounce = create_a,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [88346] = {
--  Mage
--  Portal: Tol Barad (H)
    SpellID = "88346",
    CastCriteria = "SPELL_CREATE",
    CastAnnounce = create_a,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [132626] = {
--  Mage
--  Portal: Vale of the Eternal Blossoms (H)
    SpellID = "132626",
    CastCriteria = "SPELL_CREATE",
    CastAnnounce = create_a,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [176244] = {
--  Mage
--  Portal: Warspear (H)
    SpellID = "176244",
    CastCriteria = "SPELL_CREATE",
    CastAnnounce = create_a,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [10059] = {
--  Mage
--  Portal: Stormwind (A)
    SpellID = "10059",
    CastCriteria = "SPELL_CREATE",
    CastAnnounce = create_a,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [11416] = {
--  Mage
--  Portal: Ironforge (A)
    SpellID = "11416",
    CastCriteria = "SPELL_CREATE",
--  CastAnnounce = ,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [11419] = {
--  Mage
--  Portal: Darnassus (A)
    SpellID = "11419",
    CastCriteria = "SPELL_CREATE",
    CastAnnounce = create_a,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [32266] = {
--  Mage
--  Portal: Exodar (A)
    SpellID = "32266",
    CastCriteria = "SPELL_CREATE",
    CastAnnounce = create_a,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [33691] = {
--  Mage
--  Portal: Shattrath (A)
    SpellID = "33691",
    CastCriteria = "SPELL_CREATE",
    CastAnnounce = create_a,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [49360] = {
--  Mage
--  Portal: Theramore (A)
    SpellID = "49360",
    CastCriteria = "SPELL_CREATE",
    CastAnnounce = create_a,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [88345] = {
--  Mage
--  Portal: Tol Barad (A)
    SpellID = "88345",
    CastCriteria = "SPELL_CREATE",
    CastAnnounce = create_a,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [132620] = {
--  Mage
--  Portal: Vale of the Eternal Blossoms (A)
    SpellID = "132620",
    CastCriteria = "SPELL_CREATE",
    CastAnnounce = create_a,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [176246] = {
--  Mage
--  Portal: Stormshield (A)
    SpellID = "176246",
    CastCriteria = "SPELL_CREATE",
    CastAnnounce = create_a,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [120146] = {
--  Mage
--  Ancient Portal: Dalaran (A/H)
    SpellID = "120146",
    CastCriteria = "SPELL_CREATE",
    CastAnnounce = create_an,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [80353] = {
--  Mage
--  Time Warp
    SpellID = "80353",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
--  [159916] = {
--  Mage
--  Amplify Magic
--    SpellID = "159916",
--    CastCriteria = "SPELL_CAST_SUCCESS",
--    CastAnnounce = cast,
--    FadeCriteria = "SPELL_AURA_REMOVED",
--    FadeAnnounce = fade,
--  TankCriteria = ,
--  HealerCriteria = ,
--    SpamCriteria = true,
    
--  },
 
  [115203] = {
--  Monk
--  Fortifying Brew
    SpellID = "115203",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade,
    TankCriteria = true,
--  HealerCriteria = ,
    
  },
 
  [122783] = {
--  Monk
--  Diffuse Magic
    SpellID = "122783",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade,
    TankCriteria = true,
--  HealerCriteria = ,
    
  },
 
  [122278] = {
--  Monk
--  Dampen Harm
    SpellID = "122278",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade,
    TankCriteria = true,
--  HealerCriteria = ,
    
  },
 
  [116849] = {
--  Monk
--  Life Cocoon
    SpellID = "116849",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast_on,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade_from_target,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [115546] = {
--  Monk
--  Provoke
    SpellID = "115546",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    TauntCriteria = true,
    
  },
  
  [115310] = {
--  Monk
--  Revival
    SpellID = "115310",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },  
 
  [31850] = {
--  Paladin
--  Ardent Defender
    SpellID = "31850",
    CastCriteria = "SPELL_AURA_APPLIED",
    CastAnnounce = cast,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade,
    TankCriteria = true,
--  HealerCriteria = ,
    
  },
 
  [86659] = {
--  Paladin
--  Guardian of Ancient Kings
    SpellID = "86659",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade,
    TankCriteria = true,
--  HealerCriteria = ,
    
  },
 
  [498] = {
--  Paladin
--  Divine Protection
    SpellID = "498",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade,
    TankCriteria = true,
--  HealerCriteria = ,
    
  },
 
  [31842] = {
--  Paladin
--  Avenging Wrath
    SpellID = "31842",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade,
--  TankCriteria = ,
    HealerCriteria = true,
    
  },
 
  [105809] = {
--  Paladin
--  Holy Avenger
    SpellID = "105809",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade,
--  TankCriteria = ,
    HealerCriteria = true,
    
  },
 
  [31821] = {
--  Paladin
--  Devotion Aura
    SpellID = "31821",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade,
--  TankCriteria = ,
    HealerCriteria = true,
    SpamCriteria = true,
    
  },
 
  [6940] = {
--  Paladin
--  Hand of Sacrifice
    SpellID = "6940",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast_on,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade_from_target,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [1022] = {
--  Paladin
--  Hand of Protection
    SpellID = "1022",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast_on,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade_from_target,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [633] = {
--  Paladin
--  Lay on Hands
    SpellID = "633",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast_on,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [62124] = {
--  Paladin
--  Reckoning
    SpellID = "62124",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    TauntCriteria = true,
    
  },
 
  [109964] = {
--  Priest
--  Spirit Shell
    SpellID = "109964",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
    HealerCriteria = true,
    
  },
 
  [64843] = {
--  Priest
--  Divine Hymn
    SpellID = "64843",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade,
--  TankCriteria = ,
    HealerCriteria = true,
    
  },
 
  [47788] = {
--  Priest
--  Guardian Spirit
    SpellID = "47788",
    CastCriteria = "SPELL_HEAL",
    CastAnnounce = cast_on,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade_from_target,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [33206] = {
--  Priest
--  Pain Suppression
    SpellID = "33206",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast_on,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade_from_target,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [62618] = {
--  Priest
--  Power Word: Barrier
    SpellID = "62618",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [724] = {
--  Priest
--  Lightwell
    SpellID = "724",
    CastCriteria = "SPELL_SUMMON",
    CastAnnounce = cast,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [76577] = {
--  Rogue
--  Smoke Bomb
    SpellID = "76577",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [57934] = {
--  Rogue
--  Tricks of the Trade
    SpellID = "57934",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = use_on,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [2825] = {
--  Shaman
--  Bloodlust
    SpellID = "2825",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [32182] = {
--  Shaman
--  Heroism
    SpellID = "32182",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [114052] = {
--  Shaman
--  Ascendance
    SpellID = "114052",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade,
--  TankCriteria = ,
    HealerCriteria = true,
    
  },
 
  [152256] = {
--  Shaman
--  Storm Elemental Totem
    SpellID = "152256",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade,
--  TankCriteria = ,
    HealerCriteria = true,
    
  },
 
  [108280] = {
--  Shaman
--  Healing Tide Totem
    SpellID = "108280",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [98008] = {
--  Shaman
--  Spirit Link Totem
    SpellID = "98008",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [20608] = {
--  Shaman
--  Reincarnation
    SpellID = "20608",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = use,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [157764] = {
--  Shaman
--  Improved Reincarnation
    SpellID = "157764",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = use,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
  
  },
 
  [698] = {
--  Warlock
--  Ritual of Summoning
    SpellID = "698",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = begin,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [698] = {
--  Warlock
--  Soulstone Ressurection
    SpellID = "95750",
    CastCriteria = "SPELL_RESURRECT",
    CastAnnounce = cast_on,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [29893] = {
--  Warlock
--  Create Soulwell
    SpellID = "29893",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [12975] = {
--  Warrior
--  Last Stand
    SpellID = "12975",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade,
    TankCriteria = true,
--  HealerCriteria = ,
  
  },
 
  [871] = {
--  Warrior
--  Shield Wall
    SpellID = "871",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade,
    TankCriteria = true,
--  HealerCriteria = ,
    
  },
 
  [1160] = {
--  Warrior
--  Demoralizing Shout
    SpellID = "1160",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
--  FadeCriteria = ,
--  FadeAnnounce = ,
    TankCriteria = true,
--  HealerCriteria = ,
    
  },
 
  [114030] = {
--  Warrior
--  Vigilance
    SpellID = "114030",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast_on,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade_from_target,
    TankCriteria = true,
--  HealerCriteria = ,
   
  },
 
  [97462] = {
--  Warrior
--  Rallying Cry (Success)
    SpellID = "97462",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade,
--  TankCriteria = ,
--  HealerCriteria = ,
    SpamCriteria = true,
    
  },
 
  [97463] = {
--  Warrior
--  Rallying Cry (Removed)
    SpellID = "97463",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
    FadeCriteria = "SPELL_AURA_REMOVED",
    FadeAnnounce = fade,
--  TankCriteria = ,
--  HealerCriteria = ,
    SpamCriteria = true,
    
  },
 
  [114192] = {
--  Warrior
--  Mocking Banner
    SpellID = "114192",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = use,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [355] = {
--  Warrior
--  Taunt
    SpellID = "355",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = cast,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    TauntCriteria = true,
    
  },
 
  [111458] = {
--  Item
--  Feast of the Waters
    SpellID = "111458",
    CastCriteria = "SPELL_CAST_START",
    CastAnnounce = place,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [111457] = {
--  Item
--  Feast of Blood
    SpellID = "111457",
    CastCriteria = "SPELL_CAST_START",
    CastAnnounce = place,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [118576] = {
--  Item
--  Savage Feast
    SpellID = "118576",
    CastCriteria = "SPELL_CAST_START",
    CastAnnounce = place,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [22700] = {
--  Item
--  Field Repair Bot 74A
    SpellID = "22700",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = place,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [44389] = {
--  Item
--  Field Repair Bot 110G
    SpellID = "44389",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = place,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [67826] = {
--  Item
--  Jeeves
    SpellID = "67826",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = place,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [54710] = {
--  Item
--  MOLL-E
    SpellID = "54710",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = place,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [54711] = {
--  Item
--  Scrapbot
    SpellID = "54711",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = place,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [87214] = {
--  Item
--  Blingtron 4000
    SpellID = "87214",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = place,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [111821] = {
--  Item
--  Blingtron 5000
    SpellID = "111821",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = place,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [109644] = {
--  Item
--  Walter
    SpellID = "109644",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = place,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [156436] = {
--  Item
--  Draenic Mana Potion
    SpellID = "156436",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = drink,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [156432] = {
--  Item
--  Draenic Channeled Mana Potion
    SpellID = "156432",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = drink,
    FadeCriteria = "SPELL_AURA_REMOVED",
--  FadeAnnounce = ,
--  TankCriteria = ,
--  HealerCriteria = ,
    
  },
 
  [178208] = {
--  Item
--  Drums of Fury
    SpellID = "178208",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = beat,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
    
  },
  
  [187615] = {
--  Item
--  Maalus, the Blood Drinker
    SpellID = "187615",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = awaken,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
    
  },

  [187611] = {
--  Item
--  Nithramus, the All-Seer
    SpellID = "187611",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = awaken,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
    
  },

  [187612] = {
--  Item
--  Etheralus, the Eternal Reward
    SpellID = "187612",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = awaken,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
    
  },

  [187614] = {
--  Item
--  Thorasus, the Stone Heart of Draenor
    SpellID = "187614",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = awaken,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
    
  },

  [187613] = {
--  Item
--  Sanctus, Sigil of the Unbroken
    SpellID = "187613",
    CastCriteria = "SPELL_CAST_SUCCESS",
    CastAnnounce = awaken,
--  FadeCriteria = ,
--  FadeAnnounce = ,
--  TankCriteria = ,
    
  },  
 
}

local function printf(s,...)
  print("|cff39d7e5CDSpy:|r " .. s:format(...))
end

CDSpy:SetScript("OnEvent", function(self, event, ...)
  self[event](self, ...)
end)

local function send(message)
  if instance == "raid" and not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and (CDSpyDB.raid_toggle or CDSpyDB.override) then
    SendChatMessage(message, CDSpyDB.raid_output, nil, CDSpyDB.raid_channel_id)
  elseif instance == "party" and not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and (CDSpyDB.party_toggle or CDSpyDB.override) then
    SendChatMessage(message, CDSpyDB.party_output, nil, CDSpyDB.party_channel_id)
  elseif (select(3,GetInstanceInfo())==17 or IsLFGModeActive(LE_LFG_CATEGORY_LFD)) and (CDSpyDB.pug_toggle or CDSpyDB.override) then
    SendChatMessage(message, CDSpyDB.pug_output, nil, CDSpyDB.pug_channel_id)
  elseif CDSpyDB.override then
    SendChatMessage(message, CDSpyDB.raid_output, nil, CDSpyDB.raid_channel_id)
  end
  
  if CDSpyDB.debug_toggle then
    print(message)
  end
  
end
 

local function is_tank(name)
  return GetPartyAssignment("MAINTANK", name, 1) or UnitGroupRolesAssigned(name) == "TANK"
end

local function is_healer(name)
  return UnitGroupRolesAssigned(name) == "HEALER"
end
 
function CDSpy:COMBAT_LOG_EVENT_UNFILTERED(timestamp, event, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, school, ...)
 
  if not UnitExists(srcName) then return end -- If the source isn't in the raid/party
  
  if not CDSpyDB.enable_toggle then return end -- If Global Announce is off
 
  if UnitAffectingCombat(srcName) then -- If the caster is in combat
  
    if SpellArray[spellID] then
    
      if event == SpellArray[spellID]["CastCriteria"] then
      
        if CDSpyDB.taunt_toggle == false and SpellArray[spellID]["TauntCriteria"] then return end
      
        if SpellArray[spellID]["TankCriteria"] then
        
          if is_tank(srcName) == SpellArray[spellID]["TankCriteria"] then
            
            send(SpellArray[spellID]["CastAnnounce"]:format(srcName, GetSpellLink(spellID), destName))
              
          end
            
        elseif SpellArray[spellID]["HealerCriteria"] then
        
          if is_healer(srcName) == SpellArray[spellID]["HealerCriteria"] then

            send(SpellArray[spellID]["CastAnnounce"]:format(srcName, GetSpellLink(spellID), destName))
          
          end
        
        else
        
          send(SpellArray[spellID]["CastAnnounce"]:format(srcName, GetSpellLink(spellID), destName))
        
        end
        
      end
      
      
      
      
      if event == SpellArray[spellID]["FadeCriteria"] then
      
        if SpellArray[spellID]["SpamCriteria"] and srcName ~= destName then return end -- Block spammy things
      
        if SpellArray[spellID]["TankCriteria"] then
            
          if is_tank(srcName) == SpellArray[spellID]["TankCriteria"] then

            send(SpellArray[spellID]["FadeAnnounce"]:format(srcName, GetSpellLink(spellID), destName))
              
          end
            
        elseif SpellArray[spellID]["HealerCriteria"] then
            
          if is_healer(srcName) == SpellArray[spellID]["HealerCriteria"] then

            send(SpellArray[spellID]["FadeAnnounce"]:format(srcName, GetSpellLink(spellID), destName))
              
          end
            
        else
            
          send(SpellArray[spellID]["FadeAnnounce"]:format(srcName, GetSpellLink(spellID), destName))
            
        end
        
      end
        
    end
    
  end
  
end



function CDSpy:PLAYER_REGEN_DISABLED()
  wipe(reincarnations)
  self:UnregisterEvent("UNIT_HEALTH")
end



function CDSpy:CheckEnable(isEnteringWorld)
  _, instance = IsInInstance()
  
  if CDSpyDB.enable_toggle and (instance == "raid" or instance == "party") then
    self:RegisterEvents()
  elseif CDSpyDB.override then
    self:RegisterEvents()
  else
   self:UnregisterEvents()
  end
  
end

function CDSpy:PLAYER_ENTERING_WORLD()
	self:CheckEnable(true)
end

function CDSpy:RegisterEvents()
  self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  self:RegisterEvent("PLAYER_REGEN_DISABLED")
  print("CDSpy is ONLINE in this zone")
  raid_channel_id = GetChannelName(CDSpyDB.raid_channel_id)
  party_channel_id = GetChannelName(CDSpyDB.party_channel_id)
  pug_channel_id = GetChannelName(CDSpyDB.pug_channel_id)
end

function CDSpy:UnregisterEvents()
  self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  self:UnregisterEvent("PLAYER_REGEN_DISABLED")
  self:UnregisterEvent("UNIT_HEALTH")
  print("CDSpy is OFFLINE in this zone")
  wipe(reincarnations)
end

function CDSpy:CreateSlashCommands()

	SLASH_CDSPY1 = "/cdspy"
	SlashCmdList.CDSPY = function(msg)
    InterfaceOptionsFrame_OpenToCategory("CDSpy")
    InterfaceOptionsFrame_OpenToCategory("CDSpy")
  end
	
end

function CDSpy:ADDON_LOADED(loadedAddon)

  if loadedAddon ~= "CDSpy" then return end
  
  local defaults = {
    override = true,
    enable_toggle = true,
    debug_toggle = true,
    taunt_toggle = true,
    party = true,
    fade = true,
    tricks = true,
    manacd = true,
    mana = 80000,
    raid_output = "RAID",
    raid_channel_id = "5",
    raid_channel_name = "CDSpyReports",
    raid_toggle = true,
    party_output = "PARTY",    
    party_channel_id = "5",
    party_channel_name = "CDSpyReports",
    party_toggle = true,
    pug_output = "INSTANCE_CHAT",    
    pug_channel_id = "5",
    pug_channel_name = "CDSpyReports",
    pug_toggle = false,
  }
  
  CDSpyDB = CDSpyDB or {}
  for k,v in pairs(defaults) do
    if CDSpyDB[k] == nil then
      CDSpyDB[k] = v
    end
  end
  
  self.db = CDSpyDB
  addon.db = CDSpyDB
 
  self:CreateSlashCommands()
  self:CheckEnable()
  self:RegisterEvent("PLAYER_ENTERING_WORLD")
  
end


CDSpy:RegisterEvent("ADDON_LOADED")
