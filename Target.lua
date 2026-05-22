-- PlayersCastbars Target Cast Bar
local ADDON_NAME = ...

-- Use shared PlayersCastbars global (initialized by Playercastbar.lua)
local PlayersCastbars = _G.PlayersCastbars or {}
if not _G.PlayersCastbars then _G.PlayersCastbars = PlayersCastbars end

-- Default settings (only applied for missing keys)
local defaults = {
    enabled = true,
    height = 18,
    width = 220,
    offsetX = 0,
    offsetY = 0,
    anchorPoint = "CENTER",
    texture = "Interface\\TARGETINGFRAME\\UI-StatusBar",
    textureName = "Blizzard",
    bgColor = {0, 0, 0, 1},
    textSize = 12,
    iconSize = 18,
    iconOffsetX = 0,
    iconOffsetY = 0,
    blizzBarScale = 1.01, -- Default scale for Blizzard cast bar hiding
    empowerSeg4Color = {1, 0, 0, 0.25},
    empowerSeg5Color = {1, 0, 0, 0.25},
}

-- Helper for boolean vertex color (must be global for use in other functions)
function SetVertexColorFromBoolean(tex, bool, colorTrue, colorFalse)
    if not tex then return end
    local r, g, b, a = (bool and colorTrue or colorFalse):GetRGBA()
    if tex.SetStatusBarColor then
        tex:SetStatusBarColor(r, g, b, a)
    elseif tex.SetVertexColor then
        tex:SetVertexColor(r, g, b, a)
    end
end

-- Example: Use green for interruptible, red for not interruptible
interruptibleColorObj = CreateColor(0, 1, 0, 1) -- Green
notinterruptibleColorObj = CreateColor(1, 0, 0, 1) -- Red

-- Get target bar config from shared AceDB profile (falls back to local defaults)
local function GetConfig()
    return (PlayersCastbars.db and PlayersCastbars.db.profile and PlayersCastbars.db.profile.target)
        or defaults
end

-- Empowered stage markers initialization (target bar)
function PlayersCastbars:InitializeTargetEmpoweredStages(bar)
    if not bar or not bar.isEmpowered or not bar.numStages or bar.numStages <= 0 then return end
    bar.empoweredStages = bar.empoweredStages or {}
    bar.empoweredSegments = bar.empoweredSegments or {}
    local status = bar.status
    if not status then return end
    C_Timer.After(0, function()
        if not status:IsVisible() then
            C_Timer.After(0.05, function() PlayersCastbars:InitializeTargetEmpoweredStages(bar) end)
            return
        end
        local num = bar.numStages or 0
        local width = status:GetWidth() or 1
        for i = 1, num do
            local seg = bar.empoweredSegments[i]
            if not seg then
                seg = status:CreateTexture(nil, "OVERLAY")
                seg:SetWidth(2)
                seg:SetColorTexture(unpack(GetConfig().empowerSeg4Color or {1,0,0,0.25}))
                seg:SetPoint("TOP", status, "TOP")
                seg:SetPoint("BOTTOM", status, "BOTTOM")
                bar.empoweredSegments[i] = seg
            end
            local rel = (i / (num + 1))
            local x = (status:GetWidth() or width) * rel
            seg:ClearAllPoints()
            seg:SetPoint("LEFT", status, "LEFT", x, 0)
            seg:Show()
        end
        for i = (num + 1), #bar.empoweredSegments do
            if bar.empoweredSegments[i] then bar.empoweredSegments[i]:Hide() end
        end
    end)
end

-- Target cast bar creation (stored separately from player bar)
function PlayersCastbars:GetTargetCastBar()
    if self.targetCastBar then return self.targetCastBar end
    local cfg = GetConfig()
    local anchor = UIParent
    local bar = CreateFrame("Frame", ADDON_NAME .. "Target", anchor, "BackdropTemplate")
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
    bar.empoweredSegments = {}
    self.targetCastBar = bar
    return bar
end

function PlayersCastbars:UpdateTargetCastBarLayout()
    local cfg = GetConfig()
    if self.targetCastBar then
        self.targetCastBar:SetWidth(cfg.width)
        self.targetCastBar:SetHeight(cfg.height)
        self.targetCastBar.iconFrame:SetSize(cfg.iconSize, cfg.iconSize)
        local iconX = cfg.iconOffsetX or 0
        local iconY = cfg.iconOffsetY or 0
        self.targetCastBar.iconFrame:ClearAllPoints()
        self.targetCastBar.iconFrame:SetPoint("RIGHT", self.targetCastBar, "LEFT", -4 + iconX, iconY)
        if cfg.texture then
            self.targetCastBar.status:SetStatusBarTexture(cfg.texture)
        end
        self.targetCastBar:ClearAllPoints()
        self.targetCastBar:SetPoint(cfg.anchorPoint, UIParent, cfg.anchorPoint, cfg.offsetX, cfg.offsetY)
    end
end

-- Apply interruptible color and label to the target cast bar
-- NEVER do Lua boolean test on notInterruptible — it is a secret value from UnitCastingInfo/UnitChannelInfo.
-- C_CurveUtil.EvaluateColorValueFromBoolean(secretBool, trueVal, falseVal) handles it in C safely.
-- Called with event=="UNIT_SPELLCAST_NOT_INTERRUPTIBLE" (plain bool) it also works fine.
local function ApplyTargetInterruptColor(bar, notInterruptible)
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

-- Target bar OnUpdate progress driver.
-- Uses durationObject methods (UCB technique).
-- NEVER do Lua arithmetic or comparison on durationObject values — they are secret numbers.
-- Pass directly to C API (SetValue, SetMinMaxValues) which handles secret values in C.
-- Bar hiding is done via _pendingHide flag processed by the poll frame (clean context).
local function TargetCastBar_OnUpdate(self, elapsed)
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

-- Direct event-driven handlers for target unit
-- NOTE: UnitCastingInfo/UnitChannelInfo are NOT called here.
-- TargetFrame.spellbar processes UNIT_SPELLCAST_* first using secretwrap CastingBarType values,
-- which taints subsequent UnitCastingInfo calls in the same event dispatch.
-- The poll frame below calls UnitCastingInfo from a clean OnUpdate context instead.

function PlayersCastbars:OnTargetSpellcastStop(unit, castGUID, spellID)
    if unit ~= "target" then return end
    if not self.targetCastBar then return end
    -- Set flag only — poll frame calls Hide/SetScript from clean context
    self.targetCastBar._pendingHide  = true
    self.targetCastBar._pollCastID   = nil
    self.targetCastBar.durationObject = nil
end

function PlayersCastbars:OnTargetSpellcastFailed(unit, castGUID, spellID)
    if unit ~= "target" then return end
    if not self.targetCastBar then return end
    self.targetCastBar._pendingHide  = true
    self.targetCastBar._pollCastID   = nil
    self.targetCastBar.durationObject = nil
end

function PlayersCastbars:OnTargetSpellcastInterrupted(unit, castGUID, spellID)
    self:OnTargetSpellcastFailed(unit, castGUID, spellID)
end

function PlayersCastbars:OnTargetSpellcastChannelStop(unit, castGUID, spellID)
    if unit ~= "target" then return end
    if not self.targetCastBar then return end
    self.targetCastBar._pendingHide  = true
    self.targetCastBar._pollCastID   = nil
    self.targetCastBar.durationObject = nil
end

function PlayersCastbars:OnTargetSpellcastEmpowerStart(unit, castGUID, spellID)
    local cfg = GetConfig()
    if not cfg.enabled or unit ~= "target" then return end
    local bar = self:GetTargetCastBar()
    self:UpdateTargetCastBarLayout()
    -- Use UnitEmpoweredChannelDuration (no secret arithmetic) + UnitChannelInfo for name/texture only
    local name, _, texture, _, _, _, empowerNotInterruptible, _, _, numStages = UnitChannelInfo("target")
    if spellID and C_Spell and C_Spell.GetSpellEmpowerInfo then
        local empowerInfo = C_Spell.GetSpellEmpowerInfo(spellID)
        if empowerInfo and empowerInfo.numStages and empowerInfo.numStages > 0 then
            numStages = empowerInfo.numStages
        end
    end
    if not name and spellID and C_Spell and C_Spell.GetSpellInfo then
        local spellInfo = C_Spell.GetSpellInfo(spellID)
        if spellInfo then
            name    = spellInfo.name
            texture = spellInfo.iconID or 136243
        end
    end
    if not name    then name    = "Empowered Cast" end
    if not texture then texture = 136243 end
    -- Use durationObject (no startTimeMS/endTimeMS arithmetic)
    local durationObject = UnitEmpoweredChannelDuration and UnitEmpoweredChannelDuration("target")
                        or UnitChannelDuration("target")
    bar.isEmpowered    = true
    bar.numStages      = numStages or 3
    bar.castGUID       = castGUID
    bar.isChannel      = false
    bar._pollCastID    = castGUID or "empower"
    bar.durationObject = durationObject
    bar.icon:SetTexture(texture)
    bar.spellName:SetText(name)
    local font = GetGlobalFont and GetGlobalFont() or GameFontHighlightSmall:GetFont()
    bar.spellName:SetFont(font, cfg.textSize or 12, "OUTLINE")
    bar.spellName:SetShadowOffset(0, 0)
    if bar.timeText then
        bar.timeText:SetFont(font, cfg.textSize or 12, "OUTLINE")
        bar.timeText:SetShadowOffset(0, 0)
    end
    ApplyTargetInterruptColor(bar, empowerNotInterruptible)
    if bar.numStages and bar.numStages > 0 then
        C_Timer.After(0.01, function()
            if bar.isEmpowered and bar.numStages > 0 then
                PlayersCastbars:InitializeTargetEmpoweredStages(bar)
            end
        end)
    end
    bar:SetScript("OnUpdate", TargetCastBar_OnUpdate)
    bar:Show()
end

function PlayersCastbars:OnTargetSpellcastEmpowerUpdate(unit, castGUID, spellID)
    if not self.targetCastBar then return end
    if self.targetCastBar.castGUID and castGUID and castGUID ~= self.targetCastBar.castGUID then return end
    local bar = self.targetCastBar
    -- Refresh durationObject only (no startTimeMS arithmetic)
    local durationObject = UnitEmpoweredChannelDuration and UnitEmpoweredChannelDuration("target")
                        or UnitChannelDuration("target")
    if durationObject then bar.durationObject = durationObject end
    local _, _, _, _, _, _, _, _, _, numStages = UnitChannelInfo("target")
    if spellID and C_Spell and C_Spell.GetSpellEmpowerInfo then
        local empowerInfo = C_Spell.GetSpellEmpowerInfo(spellID)
        if empowerInfo and empowerInfo.numStages and empowerInfo.numStages > 0 then
            numStages = empowerInfo.numStages
        end
    end
    if numStages and numStages ~= bar.numStages then
        bar.numStages = numStages
        PlayersCastbars:InitializeTargetEmpoweredStages(bar)
    end
end

function PlayersCastbars:OnTargetSpellcastEmpowerStop(unit, castGUID, spellID)
    if not self.targetCastBar then return end
    if castGUID and self.targetCastBar.castGUID and castGUID ~= self.targetCastBar.castGUID then return end
    -- Hide empowered stages; poll frame will detect any follow-up cast
    if self.targetCastBar.empoweredStages then
        for _, stage in ipairs(self.targetCastBar.empoweredStages) do stage:Hide() end
    end
    if self.targetCastBar.empoweredSegments then
        for _, seg in ipairs(self.targetCastBar.empoweredSegments) do seg:Hide() end
    end
    self.targetCastBar._pendingHide  = true
    self.targetCastBar._pollCastID   = nil
    self.targetCastBar.durationObject = nil
end

-- Poll frame: detects target casts in clean OnUpdate context.
-- UnitCastingInfo/UnitChannelInfo must be called from here, never from event handlers,
-- because TargetFrame.spellbar processes the same events with secretwrap CastingBarType
-- values which taints the event dispatch and any subsequent UnitCastingInfo calls.
local targetPollFrame = CreateFrame("Frame")
targetPollFrame._timer = 0
targetPollFrame:SetScript("OnUpdate", function(self, elapsed)
    self._timer = self._timer + elapsed
    if self._timer < 0.05 then return end  -- poll at ~20 Hz
    self._timer = 0

    local cfg = GetConfig()
    if not cfg or not cfg.enabled then
        local bar = PlayersCastbars.targetCastBar
        if bar and bar:IsShown() then
            bar:SetScript("OnUpdate", nil)
            bar:Hide()
            bar._pollCastID    = nil
            bar.durationObject = nil
        end
        return
    end

    -- Don't interfere while the options preview is running
    if PlayersCastbars.targetPreviewActive then return end

    -- Process pending hide (set by event handlers which may run in tainted context).
    -- Calling Hide/SetScript from here (clean poll-frame OnUpdate) keeps the bar un-tainted.
    local bar0 = PlayersCastbars.targetCastBar
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
    local name, _, texture, _, _, _, _, notInterruptible = UnitCastingInfo("target")
    if name then
        local durationObject = UnitCastingDuration("target")
        if durationObject then
            local bar = PlayersCastbars:GetTargetCastBar()
            -- New cast when bar isn't already showing a regular cast
            if not bar:IsShown() or bar.isChannel then
                PlayersCastbars:UpdateTargetCastBarLayout()
                if bar.empoweredStages   then for _, s in ipairs(bar.empoweredStages)   do s:Hide() end end
                if bar.empoweredSegments then for _, s in ipairs(bar.empoweredSegments) do s:Hide() end end
                bar.isChannel      = false
                bar.isEmpowered    = false
                bar.durationObject = durationObject
                bar.icon:SetTexture(texture)
                bar.spellName:SetText(name)
                ApplyTargetInterruptColor(bar, notInterruptible)
                bar:SetScript("OnUpdate", TargetCastBar_OnUpdate)
                bar:Show()
            else
                bar.durationObject = durationObject  -- refresh each frame
            end
            return
        end
    end

    -- Check channel.
    -- IMPORTANT: UnitChannelInfo position 7 is notInterruptible (secret boolean), NOT a castID.
    -- Never compare it. Detect new channels by bar state (visibility + isChannel flag).
    local chanName, _, chanTexture, _, _, _, chanNotInt = UnitChannelInfo("target")
    if chanName then
        local durationObject = UnitChannelDuration("target")
        if durationObject then
            local bar = PlayersCastbars:GetTargetCastBar()
            -- New channel when bar isn't already showing as a channel
            if not bar:IsShown() or not bar.isChannel then
                PlayersCastbars:UpdateTargetCastBarLayout()
                if bar.empoweredStages   then for _, s in ipairs(bar.empoweredStages)   do s:Hide() end end
                if bar.empoweredSegments then for _, s in ipairs(bar.empoweredSegments) do s:Hide() end end
                bar.isChannel      = true
                bar.isEmpowered    = false
                bar._pollCastID    = "channel"  -- clean string marker; never compared to secret value
                bar.durationObject = durationObject
                bar.icon:SetTexture(chanTexture)
                bar.spellName:SetText(chanName)
                ApplyTargetInterruptColor(bar, chanNotInt)
                bar:SetScript("OnUpdate", TargetCastBar_OnUpdate)
                bar:Show()
            else
                bar.durationObject = durationObject  -- refresh each frame
            end
            return
        end
    end

    -- Not casting — hide bar
    local bar = PlayersCastbars.targetCastBar
    if bar and bar:IsShown() then
        bar:SetScript("OnUpdate", nil)
        bar:Hide()
        bar._pollCastID    = nil
        bar.durationObject = nil
    end
end)

-- Event frame: handles stop/fail/interrupt events (no UnitCastingInfo calls here)
local targetCastEventFrame = CreateFrame("Frame")
targetCastEventFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
targetCastEventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
targetCastEventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
targetCastEventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
targetCastEventFrame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START")
targetCastEventFrame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_UPDATE")
targetCastEventFrame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP")
targetCastEventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
targetCastEventFrame:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
targetCastEventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
targetCastEventFrame:SetScript("OnEvent", function(self, event, unit, castGUID, spellID)
    if event == "PLAYER_TARGET_CHANGED" then
        if PlayersCastbars.targetCastBar then
            PlayersCastbars.targetCastBar._pendingHide  = true
            PlayersCastbars.targetCastBar._pollCastID   = nil
            PlayersCastbars.targetCastBar.durationObject = nil
        end
    elseif event == "UNIT_SPELLCAST_INTERRUPTIBLE" or event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
        if unit ~= "target" then return end
        if not PlayersCastbars.targetCastBar or not PlayersCastbars.targetCastBar:IsShown() then return end
        ApplyTargetInterruptColor(PlayersCastbars.targetCastBar, event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
    elseif event == "UNIT_SPELLCAST_STOP"          then PlayersCastbars:OnTargetSpellcastStop(unit, castGUID, spellID)
    elseif event == "UNIT_SPELLCAST_FAILED"        then PlayersCastbars:OnTargetSpellcastFailed(unit, castGUID, spellID)
    elseif event == "UNIT_SPELLCAST_INTERRUPTED"   then PlayersCastbars:OnTargetSpellcastInterrupted(unit, castGUID, spellID)
    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP"  then PlayersCastbars:OnTargetSpellcastChannelStop(unit, castGUID, spellID)
    elseif event == "UNIT_SPELLCAST_EMPOWER_START" then PlayersCastbars:OnTargetSpellcastEmpowerStart(unit, castGUID, spellID)
    elseif event == "UNIT_SPELLCAST_EMPOWER_UPDATE"then PlayersCastbars:OnTargetSpellcastEmpowerUpdate(unit, castGUID, spellID)
    elseif event == "UNIT_SPELLCAST_EMPOWER_STOP"  then PlayersCastbars:OnTargetSpellcastEmpowerStop(unit, castGUID, spellID)
    end
end)

-- Expose API (target bar config now lives in PlayersCastbars.db.profile.target via /pcb)
_G[ADDON_NAME .. "_PlayersCastbars"] = PlayersCastbars
-- Preview Target Cast Bar Logic
function PlayersCastbars:ShowTargetPreviewCastBar()
    if self.targetPreviewActive then return end
    self.targetPreviewActive = true
    local bar = self:GetTargetCastBar()
    self:UpdateTargetCastBarLayout()
    bar:Show()
    bar.spellName:SetText("Target Preview")
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
            PlayersCastbars:HideTargetPreviewCastBar()
        end
    end)
end

function PlayersCastbars:HideTargetPreviewCastBar()
    if not self.targetPreviewActive then return end
    self.targetPreviewActive = false
    local bar = self:GetTargetCastBar()
    bar:SetScript("OnUpdate", nil)
    bar:Hide()
end
