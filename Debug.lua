-- =========================================================================
-- PlayersCastbars debug logger (temporary)
-- -------------------------------------------------------------------------
-- Toggle with /pcbdebug. When enabled it prints every player spellcast event
-- with its spellID, castGUID and the current UnitChannelInfo/UnitCastingInfo
-- timing, so we can see exactly what fires when Hover is cast mid-channel.
-- This file is self-contained and does not touch the addon's normal logic.
-- =========================================================================

local DISINTEGRATE_SPELL   = 356995
local MASS_DISINTEGRATE_ID = 436335
local HOVER_SPELL          = 358267

local enabled = false
local startClock = 0

local function stamp()
    return string.format("%6.2f", GetTime() - startClock)
end

local function spellName(spellID)
    if not spellID then return "?" end
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellID)
        if info and info.name then return info.name end
    end
    return tostring(spellID)
end

-- Short tag for castGUID so the chat line stays readable
local function shortGUID(castGUID)
    if type(castGUID) ~= "string" then return tostring(castGUID) end
    return castGUID:sub(-8)
end

local function log(msg)
    if not enabled then return end
    DEFAULT_CHAT_FRAME:AddMessage("|cff66ccff[PCBdbg "..stamp().."]|r "..msg)
end

local events = {
    "UNIT_SPELLCAST_SENT",
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_SUCCEEDED",
    "UNIT_SPELLCAST_CHANNEL_START",
    "UNIT_SPELLCAST_CHANNEL_UPDATE",
    "UNIT_SPELLCAST_CHANNEL_STOP",
    "UNIT_SPELLCAST_EMPOWER_START",
    "UNIT_SPELLCAST_EMPOWER_UPDATE",
    "UNIT_SPELLCAST_EMPOWER_STOP",
    "UNIT_SPELLCAST_DELAYED",
    "UNIT_SPELLCAST_INTERRUPTED",
}

local f = CreateFrame("Frame")
for _, e in ipairs(events) do f:RegisterEvent(e) end

f:SetScript("OnEvent", function(_, event, unit, castGUID, spellID, arg4)
    if not enabled then return end
    if unit ~= "player" then return end

    -- Highlight the spells we care about
    local tag = ""
    if spellID == DISINTEGRATE_SPELL then tag = " <DISINTEGRATE>"
    elseif spellID == HOVER_SPELL then tag = " <HOVER>"
    end

    local cName, _, _, cStart, cEnd = UnitChannelInfo("player")
    local castName = UnitCastingInfo("player")
    local channelStr = cName and string.format("channel=%s start=%.2f end=%.2f", cName, (cStart or 0)/1000, (cEnd or 0)/1000) or "channel=nil"
    local castStr = castName and ("cast="..castName) or "cast=nil"

    log(string.format("%s sid=%s(%s) guid=%s arg4=%s | %s | %s",
        event, tostring(spellID), spellName(spellID), shortGUID(castGUID),
        tostring(arg4), channelStr, castStr) .. tag)
end)

SLASH_PCBDEBUG1 = "/pcbdebug"
SlashCmdList["PCBDEBUG"] = function()
    enabled = not enabled
    if enabled then
        startClock = GetTime()
        DEFAULT_CHAT_FRAME:AddMessage("|cff66ccff[PCBdbg]|r logging ENABLED")
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff66ccff[PCBdbg]|r logging DISABLED")
    end
end
