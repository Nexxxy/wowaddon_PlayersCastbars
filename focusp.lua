if not _G.PlayersCastbars then _G.PlayersCastbars = {} end
local PlayersCastbars = _G.PlayersCastbars
-- FocusCastBar Focus Cast Bar
local function GetConfig()
    local PCB = _G.PlayersCastbars
    return (PCB and PCB.db and PCB.db.profile and PCB.db.profile.focus)
        or FocusSaves
        or {}
end

local FocusCastBar
local AceAddon = _G.LibStub and _G.LibStub("AceAddon-3.0", true)
if AceAddon then
    FocusCastBar = AceAddon:NewAddon("FocusCastBar")
else
    FocusCastBar = {}
end

local ADDON_NAME = ...

local function SaveConfig() end -- no-op: AceDB handles saving

function FocusCastBar:GetCastBar()
    if self.castBar then return self.castBar end
    local cfg = GetConfig()
    local anchor = UIParent
    local bar = CreateFrame("Frame", ADDON_NAME .. "FocusCastBar", anchor, "BackdropTemplate")
    bar:SetFrameStrata("MEDIUM")
    bar:SetHeight(cfg.height)
    bar:SetWidth(cfg.width)
    bar:SetPoint(cfg.anchorPoint, anchor, cfg.anchorPoint, cfg.offsetX, cfg.offsetY)
    bar:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        bgFile = nil,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    bar:SetBackdropBorderColor(0,0,0,1)
    bar.status = CreateFrame("StatusBar", nil, bar)
    bar.status:SetPoint("TOPLEFT", bar, "TOPLEFT", 1, -1)
    bar.status:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -1, 1)
    bar.status:SetStatusBarTexture(cfg.texture)
    bar.bg = bar.status:CreateTexture(nil, "BACKGROUND")
    bar.bg:SetAllPoints()
    bar.bg:SetColorTexture(unpack(cfg.bgColor))
    bar.iconFrame = CreateFrame("Frame", nil, bar, "BackdropTemplate")
    bar.iconFrame:SetSize(cfg.iconSize, cfg.iconSize)
    local iconX = cfg.iconOffsetX or 0
    local iconY = cfg.iconOffsetY or 0
    bar.iconFrame:SetPoint("RIGHT", bar, "LEFT", -4 + iconX, iconY)
    bar.iconFrame:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        bgFile = nil,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    bar.iconFrame:SetBackdropBorderColor(0,0,0,1)
    bar.icon = bar.iconFrame:CreateTexture(nil, "ARTWORK")
    bar.icon:SetAllPoints()
    bar.icon:SetTexCoord(0.06, 0.94, 0.06, 0.94)
    bar.spellName = bar.status:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bar.spellName:SetJustifyH("LEFT")
    bar.spellName:SetPoint("LEFT", bar.status, "LEFT", 4, 0)
    bar.spellName:SetFont(GameFontHighlightSmall:GetFont(), cfg.textSize, "OUTLINE")
    bar.spellName:SetShadowOffset(0, 0)
    bar.timeText = bar.status:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bar.timeText:SetJustifyH("RIGHT")
    bar.timeText:SetPoint("RIGHT", bar.status, "RIGHT", -4, 0)
    bar.timeText:SetFont(GameFontHighlightSmall:GetFont(), cfg.textSize, "OUTLINE")
    bar.timeText:SetShadowOffset(0, 0)


    bar:Hide()
    bar.empoweredStages = {}
    self.castBar = bar
    return bar
end

function FocusCastBar:UpdateCastBarLayout()
    local cfg = GetConfig()
    if self.castBar then
        self.castBar:SetWidth(cfg.width)
        self.castBar:SetHeight(cfg.height)
        self.castBar.iconFrame:SetSize(cfg.iconSize, cfg.iconSize)
        local iconX = cfg.iconOffsetX or 0
        local iconY = cfg.iconOffsetY or 0
        self.castBar.iconFrame:ClearAllPoints()
        self.castBar.iconFrame:SetPoint("RIGHT", self.castBar, "LEFT", -4 + iconX, iconY)
        if cfg.texture then
            self.castBar.status:SetStatusBarTexture(cfg.texture)
        end
        self.castBar:ClearAllPoints()
        self.castBar:SetPoint(cfg.anchorPoint, UIParent, cfg.anchorPoint, cfg.offsetX, cfg.offsetY)
    end
end

-- Apply interruptible color and label to the focus cast bar
-- NEVER do Lua boolean test on notInterruptible — it is a secret value from UnitCastingInfo/UnitChannelInfo.
-- C_CurveUtil.EvaluateColorValueFromBoolean(secretBool, trueVal, falseVal) handles it in C safely.
local function ApplyFocusInterruptColor(bar, notInterruptible)
    local cfg = GetConfig()
    local castColor = cfg.castBarColor or {0, 1, 0, 1}
    local protColor = cfg.castBarProtectedColor or {1, 0.5, 0, 1}
    -- notInterruptible=true → protColor, notInterruptible=false → castColor
    local r = C_CurveUtil.EvaluateColorValueFromBoolean(notInterruptible, protColor[1], castColor[1])
    local g = C_CurveUtil.EvaluateColorValueFromBoolean(notInterruptible, protColor[2], castColor[2])
    local b = C_CurveUtil.EvaluateColorValueFromBoolean(notInterruptible, protColor[3], castColor[3])
    local a = C_CurveUtil.EvaluateColorValueFromBoolean(notInterruptible, protColor[4] or 1, castColor[4] or 1)
    bar.status:SetStatusBarColor(r, g, b, a)
end

-- Focus bar OnUpdate progress driver.
-- Uses durationObject methods (UCB technique).
-- NEVER do Lua arithmetic or comparison on durationObject values — they are secret numbers.
-- Pass directly to C API (SetValue, SetMinMaxValues) which handles secret values in C.
-- Bar hiding is done via _pendingHide flag processed by the poll frame (clean context).
local function FocusCastBar_OnUpdate(self, elapsed)
    local dur = self.durationObject
    if not dur then return end
    local status = self.status
    if not status then return end
    local total     = dur:GetTotalDuration()
    local remaining = dur:GetRemainingDuration()
    local elapsed_t = dur:GetElapsedDuration()
    -- Use explicit if/else on the clean isChannel bool.
    -- The ternary 'self.isChannel and remaining or elapsed_t' would test 'remaining'
    -- for truthiness when isChannel=true — that crashes on a secret number.
    local value
    if self.isChannel then
        value = remaining
    else
        value = elapsed_t
    end
    status:SetMinMaxValues(0, total)
    status:SetValue(value)
    if self.timeText then
        self.timeText:SetFormattedText("%.1f", remaining)
    end
end

-- Direct event-driven handlers for focus unit
-- NOTE: UnitCastingInfo/UnitChannelInfo are NOT called here.
-- The poll frame below calls UnitCastingInfo from a clean OnUpdate context
-- to avoid taint from event dispatch when Blizzard frames process the same events
-- using secretwrap CastingBarType values.

function FocusCastBar:OnFocusSpellcastStop(unit, castGUID, spellID)
    if unit ~= "focus" then return end
    if not self.castBar then return end
    self.castBar._pendingHide  = true  -- poll frame hides from clean context
    self.castBar._pollCastID   = nil
    self.castBar.durationObject = nil
end

function FocusCastBar:OnFocusSpellcastFailed(unit, castGUID, spellID)
    if unit ~= "focus" then return end
    if not self.castBar then return end
    self.castBar._pendingHide  = true
    self.castBar._pollCastID   = nil
    self.castBar.durationObject = nil
end

function FocusCastBar:OnFocusSpellcastInterrupted(unit, castGUID, spellID)
    self:OnFocusSpellcastFailed(unit, castGUID, spellID)
end

function FocusCastBar:OnFocusSpellcastChannelStop(unit, castGUID, spellID)
    if unit ~= "focus" then return end
    if not self.castBar then return end
    self.castBar._pendingHide  = true
    self.castBar._pollCastID   = nil
    self.castBar.durationObject = nil
end

-- Poll frame: detects focus casts in clean OnUpdate context.
-- UnitCastingInfo/UnitChannelInfo must be called from here, never from event handlers,
-- because Blizzard frames process the same events with secretwrap CastingBarType
-- values which taints the event dispatch.
local focusPollFrame = CreateFrame("Frame")
focusPollFrame._timer = 0
focusPollFrame:SetScript("OnUpdate", function(self, elapsed)
    self._timer = self._timer + elapsed
    if self._timer < 0.05 then return end  -- poll at ~20 Hz
    self._timer = 0

    local cfg = GetConfig()
    if not cfg or not cfg.enabled then
        local bar = FocusCastBar.castBar
        if bar and bar:IsShown() then
            bar:SetScript("OnUpdate", nil)
            bar:Hide()
            bar._pollCastID    = nil
            bar.durationObject = nil
        end
        return
    end

    -- Don't interfere while the options preview is running
    if FocusCastBar.focusPreviewActive then return end

    -- Process pending hide (set by event handlers which may run in tainted context).
    -- Calling Hide/SetScript from here (clean poll-frame OnUpdate) keeps the bar un-tainted.
    local bar0 = FocusCastBar.castBar
    if bar0 and bar0._pendingHide then
        bar0._pendingHide = nil
        bar0:SetScript("OnUpdate", nil)
        bar0:Hide()
        -- Fall through to detect new cast immediately
    end

    -- Check regular cast.
    -- castID from UnitCastingInfo is a SECRET STRING in WoW 12.0.5 — never store or compare it.
    -- Use UnitCastingDuration (UCB technique): never do Lua arithmetic on startTimeMS/endTimeMS.
    -- Detect new cast by bar state (not shown, or was showing a channel) same as channel detection.
    local name, _, texture, _, _, _, _, notInterruptible = UnitCastingInfo("focus")
    if name then
        local durationObject = UnitCastingDuration("focus")
        if durationObject then
            local bar = FocusCastBar:GetCastBar()
            -- New cast when bar isn't already showing a regular cast
            if not bar:IsShown() or bar.isChannel then
                FocusCastBar:UpdateCastBarLayout()
                if bar.empoweredStages   then for _, s in ipairs(bar.empoweredStages)   do s:Hide() end end
                if bar.empoweredSegments then for _, s in ipairs(bar.empoweredSegments) do s:Hide() end end
                bar.isChannel      = false
                bar.isEmpowered    = false
                bar.durationObject = durationObject
                bar.icon:SetTexture(texture)
                bar.spellName:SetText(name)
                ApplyFocusInterruptColor(bar, notInterruptible)
                bar:SetScript("OnUpdate", FocusCastBar_OnUpdate)
                bar:Show()
            else
                bar.durationObject = durationObject  -- refresh each frame
            end
            return
        end
    end

    -- Check channel.
    -- IMPORTANT: UnitChannelInfo position 7 is notInterruptible (secret boolean), NOT a castID.
    -- Never store or compare it. Detect new channels by bar visibility instead.
    local chanName, _, chanTexture, _, _, _, chanNotInt = UnitChannelInfo("focus")
    if chanName then
        local durationObject = UnitChannelDuration("focus")
        if durationObject then
            local bar = FocusCastBar:GetCastBar()
            -- New channel when bar isn't showing as a channel (STOP event sets _pendingHide)
            if not bar:IsShown() or not bar.isChannel then
                FocusCastBar:UpdateCastBarLayout()
                if bar.empoweredStages   then for _, s in ipairs(bar.empoweredStages)   do s:Hide() end end
                if bar.empoweredSegments then for _, s in ipairs(bar.empoweredSegments) do s:Hide() end end
                bar.isChannel      = true
                bar.isEmpowered    = false
                bar._pollCastID    = "channel"  -- clean string marker
                bar.durationObject = durationObject
                bar.icon:SetTexture(chanTexture)
                bar.spellName:SetText(chanName)
                ApplyFocusInterruptColor(bar, chanNotInt)
                bar:SetScript("OnUpdate", FocusCastBar_OnUpdate)
                bar:Show()
            else
                bar.durationObject = durationObject  -- refresh each frame
            end
            return
        end
    end

    -- Not casting — hide bar
    local bar = FocusCastBar.castBar
    if bar and bar:IsShown() then
        bar:SetScript("OnUpdate", nil)
        bar:Hide()
        bar._pollCastID    = nil
        bar.durationObject = nil
    end
end)

-- Event frame: handles stop/fail/interrupt events (no UnitCastingInfo calls here)
local focusCastEventFrame = CreateFrame("Frame")
focusCastEventFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
focusCastEventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
focusCastEventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
focusCastEventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
focusCastEventFrame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP")
focusCastEventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
focusCastEventFrame:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
focusCastEventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
focusCastEventFrame:SetScript("OnEvent", function(self, event, unit, castGUID, spellID)
    if event == "PLAYER_FOCUS_CHANGED" then
        if FocusCastBar.castBar then
            FocusCastBar.castBar._pendingHide  = true
            FocusCastBar.castBar._pollCastID   = nil
            FocusCastBar.castBar.durationObject = nil
        end
    elseif event == "UNIT_SPELLCAST_INTERRUPTIBLE" or event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
        if unit ~= "focus" then return end
        if not FocusCastBar.castBar or not FocusCastBar.castBar:IsShown() then return end
        ApplyFocusInterruptColor(FocusCastBar.castBar, event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
    elseif event == "UNIT_SPELLCAST_STOP"         then FocusCastBar:OnFocusSpellcastStop(unit, castGUID, spellID)
    elseif event == "UNIT_SPELLCAST_FAILED"       then FocusCastBar:OnFocusSpellcastFailed(unit, castGUID, spellID)
    elseif event == "UNIT_SPELLCAST_INTERRUPTED"  then FocusCastBar:OnFocusSpellcastInterrupted(unit, castGUID, spellID)
    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then FocusCastBar:OnFocusSpellcastChannelStop(unit, castGUID, spellID)
    elseif event == "UNIT_SPELLCAST_EMPOWER_STOP" then FocusCastBar:OnFocusSpellcastStop(unit, castGUID, spellID)
    end
end)

-- _focusStopFrame is now redundant (focusCastEventFrame handles stop/fail and sets _pendingHide)
local _focusStopFrame_UNUSED = nil

-- Expose API (focus bar config now lives in PlayersCastbars.db.profile.focus via /pcb)
_G["FocusCastBar"] = FocusCastBar
_G[ADDON_NAME .. "_FocusCastBar"] = FocusCastBar

-- Preview Focus Cast Bar Logic
function FocusCastBar:ShowFocusPreviewCastBar()
    if self.focusPreviewActive then return end
    self.focusPreviewActive = true
    local bar = self:GetCastBar()
    self:UpdateCastBarLayout()
    bar:Show()
    bar.spellName:SetText("Focus Preview")
    bar.status:SetMinMaxValues(0, 60)
    bar.status:SetValue(0)
    bar.timeText:SetText("60.0")
    bar.icon:SetTexture(134400) -- Generic spell icon
    bar.previewTimer = 0
    bar:SetScript("OnUpdate", function(self, elapsed)
        self.previewTimer = (self.previewTimer or 0) + elapsed
        self.status:SetValue(self.previewTimer)
        self.timeText:SetText(string.format("%.1f", 60 - self.previewTimer))
        if self.previewTimer >= 60 then
            FocusCastBar:HideFocusPreviewCastBar()
        end
    end)
end

function FocusCastBar:HideFocusPreviewCastBar()
    if not self.focusPreviewActive then return end
    self.focusPreviewActive = false
    local bar = self:GetCastBar()
    bar:SetScript("OnUpdate", nil)
    bar:Hide()
end
