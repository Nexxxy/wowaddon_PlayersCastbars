local function HookExternalCooldownViewers()
    local function hookFrame(name)
        local f = _G[name]
        if f and not f.__pcbWidthHooked then
            f:HookScript("OnSizeChanged", function()
                if PlayersCastbars and PlayersCastbars.UpdateCastBarLayout then
                    local cfg = GetConfig()
                    if cfg.widthSyncMode == "essential" and name == "EssentialCooldownViewer" then
                        PlayersCastbars:UpdateCastBarLayout()
                    elseif cfg.widthSyncMode == "utility" and name == "UtilityCooldownViewer" then
                        PlayersCastbars:UpdateCastBarLayout()
                    end
                end
            end)
            f.__pcbWidthHooked = true
        end
    end
    hookFrame("EssentialCooldownViewer")
    hookFrame("UtilityCooldownViewer")
end
HookExternalCooldownViewers()
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    HookExternalCooldownViewers()
end)
local function RegisterPlayerLoginUpdate()
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_LOGIN")
    f:SetScript("OnEvent", function()
        if PlayersCastbars and PlayersCastbars.UpdateCastBarLayout then
            PlayersCastbars:UpdateCastBarLayout()
        end
    end)
end
RegisterPlayerLoginUpdate()
local AceAddon = _G.LibStub and _G.LibStub("AceAddon-3.0", true)
local AceDB = _G.LibStub and _G.LibStub("AceDB-3.0", true)
local PlayersCastbars
if AceAddon then
    PlayersCastbars = AceAddon:NewAddon("PlayersCastbars", "AceConsole-3.0")
    print("PlayersCastbars AceAddon loaded and global set.")
else
    PlayersCastbars = {}
    print("PlayersCastbars AceAddon NOT loaded! Using table fallback.")
end
_G["PlayersCastbars"] = PlayersCastbars

function GetConfig()
    return PlayersCastbars and PlayersCastbars.db and PlayersCastbars.db.profile or (defaults and defaults.profile) or {}
end

-- Preview Cast Bar Logic
function PlayersCastbars:ShowPreviewCastBar()
    if self.previewActive then return end
    self.previewActive = true
    local bar = self:GetCastBar()
    self:UpdateCastBarLayout()
    bar:Show()
    bar.spellName:SetText("Preview")
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
            PlayersCastbars:HidePreviewCastBar()
        end
    end)
end

function PlayersCastbars:HidePreviewCastBar()
    if not self.previewActive then return end
    self.previewActive = false
    local bar = self:GetCastBar()
    bar:SetScript("OnUpdate", nil)
    bar:Hide()
end

-- Utility: Safely unpack color tables for WoW API
local function SafeUnpackColor(color, default)
    if type(color) ~= "table" then
        return unpack(default or {1,1,1,1})
    end
    local r = tonumber(color[1]) or (default and default[1]) or 1
    local g = tonumber(color[2]) or (default and default[2]) or 1
    local b = tonumber(color[3]) or (default and default[3]) or 1
    local a = tonumber(color[4]) or (default and default[4]) or 1
    return r, g, b, a
end
local ADDON_NAME = ...

-- AceDB defaults

local defaults = {
    profile = {
            queueWindow = 0.4, 
            queueWindowColor = {1, 0, 1, 0.5}, 
        enabled = true,
        height = 18,
        width = 220,
        offsetX = 0,
        offsetY = 0,
        anchorPoint = "CENTER",
        texture = "Interface\\TargetingFrame\\UI-StatusBar",
        textureName = "Blizzard",
        bgColor = {0, 0, 0, 1},
        textSize = 12,
        iconSize = 18,
        iconOffsetX = 0,
        iconOffsetY = 0,
        blizzBarScale = 0.01,
        hideDefaultBar = true,
        -- Empower Cast stage/tick colors
        empowerStageColors = {
            {0, 1, 0, 0.8},    -- Stage 1 (Green)
            {1, 1, 0, 0.8},    -- Stage 2 (Yellow)
            {1, 0.5, 0, 0.8},  -- Stage 3 (Orange)
            {1, 0, 0, 0.8},    -- Stage 4 (Red)
            {1, 0, 1, 0.8},    -- Stage 5 (Magenta, example)
        },
        empowerSegColors = {
            {0, 1, 0, 0.25},   -- Segment 1
            {1, 1, 0, 0.25},   -- Segment 2
            {1, 0.5, 0, 0.25}, -- Segment 3
            {1, 0, 0, 0.25},   -- Segment 4
            {1, 0, 1, 0.25},   -- Segment 5 (Magenta, example)
        },
        empowerFillColors = {
            {0, 1, 0, 0.5},    -- Stage 1 Fill
            {1, 1, 0, 0.5},    -- Stage 2 Fill
            {1, 0.5, 0, 0.5},  -- Stage 3 Fill
            {1, 0, 0, 0.5},    -- Stage 4 Fill
        },
        ombre = true,
        colorMode = "class", -- "class", "ombre", "custom"
        customColor = {1, 1, 1, 1}, -- default white
        customColor2 = {1, 1, 1, 1}, -- default white for gradient end
        showCastIcon = true,
        castNameAlpha = 1,
        timeTextAlpha = 1,
        target = {
            enabled = true,
            height = 18,
            width = 220,
            offsetX = 0,
            offsetY = -50,
            anchorPoint = "CENTER",
            texture = "Interface\\TARGETINGFRAME\\UI-StatusBar",
            textureName = "Blizzard",
            bgColor = {0, 0, 0, 1},
            textSize = 12,
            iconSize = 18,
            iconOffsetX = 0,
            iconOffsetY = 0,
            blizzBarScale = 0.01,
            hideDefaultBar = true,
            castBarColor = {0, 1, 0, 1},
            castBarProtectedColor = {1, 0.5, 0, 1},
            castNameOffsetX = 0,
            castNameOffsetY = 0,
            showCastIcon = true,
        },
        focus = {
            enabled = true,
            height = 18,
            width = 220,
            offsetX = 0,
            offsetY = -100,
            anchorPoint = "CENTER",
            texture = "Interface\\TARGETINGFRAME\\UI-StatusBar",
            textureName = "Blizzard",
            bgColor = {0, 0, 0, 1},
            textSize = 12,
            iconSize = 18,
            iconOffsetX = 0,
            iconOffsetY = 0,
            blizzBarScale = 0.01,
            hideDefaultBar = true,
            castBarColor = {0, 1, 0, 1},
            castBarProtectedColor = {1, 0.5, 0, 1},
            castNameOffsetX = 0,
            castNameOffsetY = 0,
            showCastIcon = true,
        },
    }
}


function PlayersCastbars:OnInitialize()
    if AceDB then
        self.db = AceDB:New("PlayersCastbarsDB", defaults, true)
        local LibDualSpec = LibStub and LibStub("LibDualSpec-1.0", true)
        if LibDualSpec and self.db then
            LibDualSpec:EnhanceDatabase(self.db, ADDON_NAME)
        end
    else
        print("|cffff0000[PlayersCastbars]|r AceDB-3.0 not found! Saved variables will not be profile-based.")
        self.db = { profile = defaults.profile }
    end
end

local function GetConfig()
    return PlayersCastbars.db and PlayersCastbars.db.profile or defaults.profile
end

local function SaveConfig()
    -- No-op: AceDB handles saving
end



-- Empowered Cast Stage Markers
function PlayersCastbars:InitializeEmpoweredStages(bar)
    if not bar or not bar.isEmpowered or not bar.numStages or bar.numStages <= 0 then
        return
    end
    -- Clean up existing stages
    if bar.empoweredStages then
        for _, stage in ipairs(bar.empoweredStages) do
            if stage then
                stage:Hide()
            end
        end
    else
        bar.empoweredStages = {}
    end
    local status = bar.status
    if not status then return end
    C_Timer.After(0, function()
        if not status:IsVisible() then
            C_Timer.After(0.05, function()
                PlayersCastbars:InitializeEmpoweredStages(bar)
            end)
            return
        end
        local cfg = GetConfig()
        local barHeight = cfg.height or 18
        local iconWidth = bar.iconFrame and bar.iconFrame:GetWidth() or barHeight
        local barOk, barW = pcall(function() return bar:GetWidth() end)
        if not barOk then
            C_Timer.After(0.05, function()
                PlayersCastbars:InitializeEmpoweredStages(bar)
            end)
            return
        end
        -- TODO: fix
        --local barWidth = (tonumber(barW) or 200) - iconWidth 
        local barWidth = (tonumber(barW) or 200)
        if barWidth < 0 then barWidth = 100 end

        local numSegments = bar.numStages + 1
        local temp_tickPositions = {}
        local unitToken = "player"
        local totalDuration = 0
        local stage1StartPercent = 0
        
        if UnitEmpoweredStagePercentages then
            local percentages = UnitEmpoweredStagePercentages(unitToken, true)  -- includeHoldAtMaxTime = true
            if percentages and #percentages > 0 then
                -- The first percentage is the initial blank period (stage 0)
                stage1StartPercent = percentages[1] or 0
                
                -- Convert cumulative percentages to positions, starting from stage 1
                local cumulative = stage1StartPercent
                for i = 1, math.min(#percentages - 2, bar.numStages) do
                    cumulative = cumulative + (percentages[i + 1] or 0) 
                    temp_tickPositions[i] = cumulative
                end
            end
        end

        local tickPositions = {}
        tickPositions[0] = 0
        tickPositions[1] = stage1StartPercent
        for i = 1, #temp_tickPositions do
            tickPositions[i+1] = temp_tickPositions[i]
        end
        tickPositions[#temp_tickPositions+2] = 1

        local cfgColors = cfg.empowerStageColors or {}
        local tickColors = {}
        for i = 1, numSegments do
            tickColors[i] = cfgColors[i] or {1, 1, 1, 0.8}
        end
        -- Create/clear background segments
        if not bar.empoweredSegments then bar.empoweredSegments = {} end
        for i, seg in ipairs(bar.empoweredSegments) do seg:Hide() end
        local prevX = 0
        local segColors = cfg.empowerSegColors or {}
        for i = 1, numSegments do
            -- Remove 5th tick for all empower casts
            if i ~= numSegments then
                local stage = bar.empoweredStages[i]
                if not stage then
                    stage = status:CreateTexture(nil, "OVERLAY")
                    bar.empoweredStages[i] = stage
                end

                -- Adding the tick
                local color = tickColors[i] or {1, 1, 1, 0.8}
                stage:SetColorTexture(SafeUnpackColor(color, {1,1,1,0.8}))
                stage:SetWidth(2)
                local stageHeight = cfg.height or 18
                stage:SetHeight(stageHeight)
                local position = tickPositions[i] * barWidth
                stage:ClearAllPoints()
                stage:SetPoint("LEFT", status, "LEFT", position - 1, 0)
                stage:SetPoint("TOP", status, "TOP", 0, 0)
                stage:SetPoint("BOTTOM", status, "BOTTOM", 0, 0)
                stage:Show()

                -- Fill for each segment background (between ticks)
                local seg = bar.empoweredSegments[i]
                if not seg then
                    seg = status:CreateTexture(nil, "BACKGROUND")
                    bar.empoweredSegments[i] = seg
                end
                local segColor = segColors[i-1] or {1, 1, 1, 0.25}
                seg:SetColorTexture(SafeUnpackColor(segColor, {1,0,0,0.25}))
                seg:ClearAllPoints()
                seg:SetPoint("TOPLEFT", status, "TOPLEFT", prevX, 0)
                seg:SetPoint("BOTTOMLEFT", status, "BOTTOMLEFT", prevX, 0)
                local position = tickPositions[i] * barWidth
                seg:SetWidth((position - prevX))
                seg:SetHeight(cfg.height or 18)
                seg:Show()
                prevX = position
            end
        end
    end)
end

-- Utility

local function PixelSnap(value)
    return math.max(0, math.floor((value or 0) + 0.5))
end

local function GetGlobalFont()
    return GameFontHighlightSmall:GetFont()
end

-- Table of common channeled spells and their tick counts
--[[
local ChannelTicks = {
    -- [spellID] = number of ticks
    [5143]    = 5,   -- Arcane Missiles (Mage)
    [15407]   = 4,   -- Mind Flay (Priest)
    [47540]   = 3,   -- Penance (Priest, default 3, can be 4 with talent)
    [263165]  = 8,   -- Void Torrent (Priest, Shadowlands/BFA, can vary)
    [689]     = 6,   -- Drain Life (Warlock)
    [198590]  = 5,   -- Drain Soul (Warlock)
    [196447]  = 15,  -- Channel Demonfire (Warlock, 15 bolts)
    [257044]  = 7,   -- Rapid Fire (Hunter, 7 shots)
    [113656]  = 4,   -- Fists of Fury (Monk, 4 ticks)
    [115175]  = 8,   -- Soothing Mist (Monk, 8 ticks)
    [356995]  = 4,   -- Disintegrate (Evoker, 4 ticks)
    [48045]   = 5,   -- Mind Sear (Priest)
    [755]     = 10,  -- Health Funnel (Warlock)
    -- Add more or adjust as needed
    -- If you want to change a tick count, just update the value above.
}
--]]

local ChannelTicks = {
    -- [spellID] = number of ticks
    [62]    = 5,   -- Arcane Missiles (Mage) - Arcane
    [258]   = 4,   -- Mind Flay (Priest) - Shadow
    [256]   = 3,   -- Penance (Priest, default 3, can be 4 with talent) - Disc
    --[258]  = 8,   -- Void Torrent (Priest, Shadowlands/BFA, can vary) - Shadow
    [265]     = 6,   -- Drain Life (Warlock) - Affliction
    --[265]  = 5,   -- Drain Soul (Warlock) - Affliction
    [267]  = 15,  -- Channel Demonfire (Warlock, 15 bolts) - Destruction
    [254]  = 7,   -- Rapid Fire (Hunter, 7 shots) - MM
    [269]  = 4,   -- Fists of Fury (Monk, 4 ticks) - WW
    [270]  = 8,   -- Soothing Mist (Monk, 8 ticks) - Mist
    [1467]  = 4,   -- Disintegrate (Evoker, 4 ticks) - Dev
    --[258]   = 5,   -- Mind Sear (Priest) - Shadow
    [266]     = 10,  -- Health Funnel (Warlock) - Demo
}


-- Utility to get channel tick count for a spellID
local function ChannelTicksNum(specID)
    if not specID then
        return nil
    end
    return ChannelTicks[specID]
end

-- Draw channel ticks on the cast bar
function PlayersCastbars:ShowChannelTicks(bar, numTicks)
    if not bar or not numTicks or numTicks < 2 then
        if bar and bar.channelTicks then
            for _, tick in ipairs(bar.channelTicks) do tick:Hide() end
        end
        return
    end
    local status = bar.status
    if not bar.channelTicks then bar.channelTicks = {} end
    local cfg = GetConfig()
    local barWidth = (bar:GetWidth() or cfg.width or 200) - (bar.iconFrame and bar.iconFrame:GetWidth() or cfg.iconSize or 18)
    if barWidth < 10 then barWidth = 100 end
    for i = 1, numTicks - 1 do
        local tick = bar.channelTicks[i]
        if not tick then
            tick = status:CreateTexture(nil, "OVERLAY")
            bar.channelTicks[i] = tick
        end
        tick:SetColorTexture(1, 1, 1, 0.7)
        tick:SetWidth(2)
        tick:SetHeight(cfg.height or 18)
        local pos = (i / numTicks) * barWidth
        tick:ClearAllPoints()
        tick:SetPoint("LEFT", status, "LEFT", pos, 0)
        tick:SetPoint("TOP", status, "TOP", 0, 0)
        tick:SetPoint("BOTTOM", status, "BOTTOM", 0, 0)
        tick:Show()
    end
    -- Hide unused ticks
    for i = numTicks, #bar.channelTicks do
        if bar.channelTicks[i] then bar.channelTicks[i]:Hide() end
    end
end

function PlayersCastbars:HideChannelTicks(bar)
    if bar and bar.channelTicks then
        for _, tick in ipairs(bar.channelTicks) do tick:Hide() end
    end
end

-- Cast Bar Creation
function PlayersCastbars:GetCastBar()
    if self.castBar then return self.castBar end
    local cfg = GetConfig()
    local anchor = UIParent
    local bar = CreateFrame("Frame", ADDON_NAME .. "_PlayerCastBar", anchor, "BackdropTemplate")
    bar:SetFrameStrata("HIGH")
    bar:SetHeight(cfg.height)
    bar:SetWidth(cfg.width)
    bar:SetPoint(cfg.anchorPoint, anchor, cfg.offsetX, cfg.offsetY)

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
    bar.bg:SetColorTexture(SafeUnpackColor(cfg.bgColor, {0,0,0,1}))

    bar.iconFrame = CreateFrame("Frame", nil, bar, "BackdropTemplate")
    bar.iconFrame:SetSize(30, 30)
    local cfgX = cfg.iconOffsetX or 0
    local cfgY = cfg.iconOffsetY or 0
    bar.iconFrame:SetPoint("TOPLEFT", bar, "TOPLEFT", -26 + cfgX, cfgY)
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
    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    local font = GetConfig().font or (LSM and LSM:Fetch("font", GetConfig().fontName or LSM:GetDefault("font"))) or GetGlobalFont()
    bar.spellName:SetFont(font, cfg.textSize, "OUTLINE")
    bar.spellName:SetShadowOffset(0, 0)
    bar.spellName:SetAlpha(cfg.castNameAlpha or 1)

    bar.timeText = bar.status:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bar.timeText:SetJustifyH("RIGHT")
    bar.timeText:SetPoint("RIGHT", bar.status, "RIGHT", -4, 0)
    bar.timeText:SetFont(font, cfg.textSize, "OUTLINE")
    bar.timeText:SetShadowOffset(0, 0)
    bar.timeText:SetAlpha(cfg.timeTextAlpha or 1)

    -- Queue window overlay
    bar.queueWindowOverlay = bar.status:CreateTexture(nil, "ARTWORK")
    bar.queueWindowOverlay:Hide()

    bar:Hide()
    -- Add segment overlays for multi-color effect
    if not bar.segments then
        bar.segments = {}
        for i=1,3 do
            local tex = bar:CreateTexture(nil, "ARTWORK")
            tex:SetHeight(cfg.height-2)
            tex:SetPoint("TOPLEFT", bar, "TOPLEFT", 1, -1)
            tex:Hide()
            bar.segments[i] = tex
        end
    end
    bar.empoweredStages = {}
    self.castBar = bar
    return bar
end

function PlayersCastbars:UpdateCastBarLayout()
    local cfg = GetConfig()

    -- Helper to get width from EssentialCooldownViewer (span all visible child icons in the row)
    local function GetEssentialWidth()
        local ecv = _G["EssentialCooldownViewer"]
        if ecv and ecv.GetChildren then
            local left, right = nil, nil
            for i = 1, select('#', ecv:GetChildren()) do
                local child = select(i, ecv:GetChildren())
                if child and child:IsShown() and child.GetLeft and child.GetRight then
                    local l, r = child:GetLeft(), child:GetRight()
                    if l and r then
                        if not left or l < left then left = l end
                        if not right or r > right then right = r end
                    end
                end
            end
            if left and right and right > left then
                return right - left
            end
        end
        -- Fallbacks (legacy)
        local ecw = _G["EssentialCooldownManager"]
        if ecw and type(ecw.GetBarWidth) == "function" then
            local ok, w = pcall(function() return ecw:GetBarWidth() end)
            if ok and type(w) == "number" then return w end
        end
        if type(_G["ECV_BarWidth"]) == "number" then return _G["ECV_BarWidth"] end
        return nil
    end

    -- Helper to get width from UtilityCooldownViewer (span all visible child icons in the row)
    local function GetUtilityWidth()
        local ucv = _G["UtilityCooldownViewer"]
        if ucv and ucv.GetChildren then
            local left, right = nil, nil
            for i = 1, select('#', ucv:GetChildren()) do
                local child = select(i, ucv:GetChildren())
                if child and child:IsShown() and child.GetLeft and child.GetRight then
                    local l, r = child:GetLeft(), child:GetRight()
                    if l and r then
                        if not left or l < left then left = l end
                        if not right or r > right then right = r end
                    end
                end
            end
            if left and right and right > left then
                return right - left
            end
        end
        -- Fallbacks (legacy)
        if ucv and type(ucv.GetBarWidth) == "function" then
            local ok, w = pcall(function() return ucv:GetBarWidth() end)
            if ok and type(w) == "number" then return w end
        end
        if type(_G["UCV_BarWidth"]) == "number" then return _G["UCV_BarWidth"] end
        return nil
    end

    local width = cfg.width or 220
    if cfg.widthSyncMode == "essential" then
        width = GetEssentialWidth() or width
    elseif cfg.widthSyncMode == "utility" then
        width = GetUtilityWidth() or width
    else -- 'set' or any other fallback
        width = cfg.width or 220
    end

    if self.castBar then
        -- Update queue window overlay position and color
        if self.castBar.queueWindowOverlay then
            local cfgQ = cfg.queueWindow or 0.4
            local c = cfg.queueWindowColor or {1, 0, 1, 0.5}
            local barWidth = self.castBar.status:GetWidth() or width or 200
            local total = (self.castBar.endTime or 0) - (self.castBar.startTime or 0)
            if total > 0 and cfgQ > 0 and cfgQ < total then
                local px = barWidth * (cfgQ / total)
                self.castBar.queueWindowOverlay:SetColorTexture(c[1], c[2], c[3], c[4])
                self.castBar.queueWindowOverlay:ClearAllPoints()
                self.castBar.queueWindowOverlay:SetPoint("TOPRIGHT", self.castBar.status, "TOPRIGHT", 0, 0)
                self.castBar.queueWindowOverlay:SetPoint("BOTTOMRIGHT", self.castBar.status, "BOTTOMRIGHT", 0, 0)
                self.castBar.queueWindowOverlay:SetWidth(px)
                self.castBar.queueWindowOverlay:Show()
            else
                self.castBar.queueWindowOverlay:Hide()
            end
        end
        self.castBar:SetWidth(width)
        self.castBar:SetHeight(cfg.height)
        self.castBar.iconFrame:SetSize(cfg.iconSize, cfg.iconSize)
        local cfgX = cfg.iconOffsetX or 0
        local cfgY = cfg.iconOffsetY or 0
        self.castBar.iconFrame:ClearAllPoints()
        self.castBar.iconFrame:SetPoint("TOPLEFT", self.castBar, "TOPLEFT", -26 + cfgX, cfgY)
        if cfg.texture then
            self.castBar.status:SetStatusBarTexture(cfg.texture)
        end
        self.castBar:ClearAllPoints()
        self.castBar:SetPoint(cfg.anchorPoint, UIParent, cfg.anchorPoint, cfg.offsetX, cfg.offsetY)
        -- Show/hide icon based on config
        if self.castBar.iconFrame then
            if cfg.showCastIcon == false then
                self.castBar.iconFrame:Hide()
            else
                self.castBar.iconFrame:Show()
            end
        end
        -- Always update background color safely
        if self.castBar.bg then
            local c = cfg.bgColor or {0,0,0,1}
            if c.r then
                self.castBar.bg:SetColorTexture(c.r or 0, c.g or 0, c.b or 0, c.a or 1)
            else
                self.castBar.bg:SetColorTexture(c[1] or 0, c[2] or 0, c[3] or 0, c[4] or 1)
            end
        end
        -- Update cast name position and alpha
        if self.castBar.spellName then
            local x = cfg.castNameOffsetX or 4
            local y = cfg.castNameOffsetY or 0
            self.castBar.spellName:ClearAllPoints()
            self.castBar.spellName:SetPoint("LEFT", self.castBar.status, "LEFT", x, y)
            self.castBar.spellName:SetAlpha(cfg.castNameAlpha or 1)
        end
        -- Update timer text alpha
        if self.castBar.timeText then
            self.castBar.timeText:SetAlpha(cfg.timeTextAlpha or 1)
        end
    end
end

local function CastBar_OnUpdate(self, elapsed)
    if not self.startTime or not self.endTime then return end
    local now = GetTime()
    if now >= self.endTime then
        -- For active channels, verify with UnitChannelInfo before hiding;
        -- endTime can be slightly imprecise causing a premature disappear
        if self.isChannel then
            local _, _, _, _, endTimeMS = UnitChannelInfo("player")
            if endTimeMS then
                self.endTime = endTimeMS / 1000
                return -- channel still active, end time refreshed
            end
        end
        if self.empoweredStages then
            for _, stage in ipairs(self.empoweredStages) do
                stage:Hide()
            end
        end
        self:Hide()
        self:SetScript("OnUpdate", nil)
        -- Bug #5 fix: clear state AFTER hiding so STOP event handlers that fire
        -- in the same or next frame still see valid isChannel/isEmpowered state.
        self.castGUID    = nil
        self.isChannel   = nil
        self.isEmpowered = nil
        self.numStages   = nil
        return
    end
    local status = self.status
    if not status then return end
    local duration = self.endTime - self.startTime
    if duration <= 0 then duration = 0.001 end
    local remaining = self.endTime - now
    local progress
    if self.isChannel then
        progress = remaining
    else
        progress = now - self.startTime
    end
    status:SetMinMaxValues(0, duration)
    status:SetValue(progress)
    if self.timeText then
        self.timeText:SetText(string.format("%.1f/%.1f", remaining, duration))
    end

    local duration = self.endTime - self.startTime
    local percent = progress / duration
    local _, class = UnitClass("player")
    local classColor = RAID_CLASS_COLORS and RAID_CLASS_COLORS[class] or {r=1, g=1, b=1}
    local cfg = GetConfig()
    if self.overrideColor then
        local oc = self.overrideColor
        self.status:SetStatusBarColor(oc[1], oc[2], oc[3], oc[4] or 1)
    elseif cfg.colorMode == "ombre" or (cfg.colorMode == "class" and cfg.ombre) then
        -- Ombre coloring (unchanged)
        local stops = {
            {p=0.10, r=1,   g=0,   b=0},      -- Red
            {p=0.20, r=1,   g=0.5, b=0},      -- Orange
            {p=0.30, r=1,   g=1,   b=0},      -- Yellow
            {p=0.40, r=0,   g=1,   b=0},      -- Green
            {p=0.60, r=0,   g=0.5, b=1},      -- Blue
            {p=0.80, r=0.5, g=0,   b=1},      -- Purple
            {p=1.00, r=classColor.r, g=classColor.g, b=classColor.b}, -- Class color
        }
        local r, g, b = 1, 1, 1
        for i = 2, #stops do
            if percent <= stops[i].p then
                local prev, next = stops[i-1], stops[i]
                local range = next.p - prev.p
                local rel = (percent - prev.p) / (range > 0 and range or 1)
                r = prev.r + (next.r - prev.r) * rel
                g = prev.g + (next.g - prev.g) * rel
                b = prev.b + (next.b - prev.b) * rel
                break
            end
        end
        self.status:SetStatusBarColor(r, g, b, 1)
        if self.status:GetStatusBarTexture() and self.status:GetStatusBarTexture().SetGradient then
            self.status:GetStatusBarTexture():SetGradient("HORIZONTAL", CreateColor(r, g, b, 1), CreateColor(r, g, b, 1))
        end
    elseif cfg.colorMode == "custom" then
        local c1 = cfg.customColor or {1,1,1,1}
        local c2 = cfg.customColor2 or {1,1,1,1}
        -- Support both array and table forms
        local function getColorVals(c)
            if c.r then return c.r or 1, c.g or 1, c.b or 1, c.a or 1 end
            return c[1] or 1, c[2] or 1, c[3] or 1, c[4] or 1
        end
        local r1,g1,b1,a1 = getColorVals(c1)
        local r2,g2,b2,a2 = getColorVals(c2)
        if self.status:GetStatusBarTexture() and self.status:GetStatusBarTexture().SetGradient then
            self.status:GetStatusBarTexture():SetGradient("HORIZONTAL",
                CreateColor(r1,g1,b1,a1),
                CreateColor(r2,g2,b2,a2)
            )
        else
            -- fallback: just set to start color
            self.status:SetStatusBarColor(r1,g1,b1,a1)
        end
    else
        -- Class color only
        self.status:SetStatusBarColor(classColor.r, classColor.g, classColor.b, 1)
        if self.status:GetStatusBarTexture() and self.status:GetStatusBarTexture().SetGradient then
            self.status:GetStatusBarTexture():SetGradient("HORIZONTAL", CreateColor(classColor.r, classColor.g, classColor.b, 1), CreateColor(classColor.r, classColor.g, classColor.b, 1))
        end
    end

end

function PlayersCastbars:OnPlayerSpellcastStart(unit, castGUID, spellID)
    local cfg = GetConfig()
    if not cfg.enabled or unit ~= "player" then return end
    local name, _, texture, startTimeMS, endTimeMS = UnitCastingInfo("player")
    if not name or not startTimeMS or not endTimeMS then
        -- Bug #1 fix: don't hide if a channel (e.g. Disintegrate) is still active;
        -- an instant/proc can fire UNIT_SPELLCAST_START mid-channel.
        if UnitChannelInfo("player") then return end
        if self.castBar then self.castBar:Hide() end
        return
    end
    local bar = self:GetCastBar()
    self:UpdateCastBarLayout()
    -- Always hide both channel ticks and empowered stages before showing relevant ones
    self:HideChannelTicks(bar)
    if bar.empoweredStages then
        for _, stage in ipairs(bar.empoweredStages) do stage:Hide() end
    end
    if bar.empoweredSegments then
        for _, seg in ipairs(bar.empoweredSegments) do seg:Hide() end
    end
    bar.isChannel = false
    bar.isEmpowered = false
    bar.castGUID  = castGUID
    bar.icon:SetTexture(texture)
    bar.spellName:SetText(name)
    bar.startTime = startTimeMS / 1000
    bar.endTime   = endTimeMS / 1000
    local _, class = UnitClass("player")
    
    local color = RAID_CLASS_COLORS and RAID_CLASS_COLORS[class] or {r=1, g=1, b=1}
    -- Show channel ticks for spells in ChannelTicks even if not a channel
    --[[
    local currentSpecId = PlayerUtil.GetCurrentSpecID()
    if currentSpecId then
        local numTicks = ChannelTicksNum(currentSpecId)
        if numTicks then
            self:ShowChannelTicks(bar, numTicks)
        end
    end
    --]]
    bar:SetScript("OnUpdate", CastBar_OnUpdate)
    bar:Show()
end

function PlayersCastbars:OnPlayerSpellcastStop(unit, castGUID, spellID)
    if not self.castBar then return end
    if unit ~= "player" then return end
    -- WoW fires UNIT_SPELLCAST_STOP when transitioning into a channel;
    -- if the bar is already showing a channel, let CHANNEL_STOP handle hiding
    if self.castBar.isChannel then return end
    -- Only hide if not casting or channeling anymore
    local nameCast = UnitCastingInfo("player")
    local nameChannel = UnitChannelInfo("player")
    if nameCast or nameChannel then
        -- Still casting or channeling, do not hide
        return
    end
    self.castBar:Hide()
    self.castBar:SetScript("OnUpdate", nil)
end

-- Hide bar on channel stop event (for interrupted channels)
function PlayersCastbars:OnPlayerSpellcastChannelStop(unit, castGUID, spellID)
    if not self.castBar then return end
    if unit ~= "player" then return end
    -- Bug #4 fix: defer one frame so that when chain-casting (e.g. Disintegrate→
    -- Disintegrate) the CHANNEL_STOP for cast N doesn't fire before UnitChannelInfo
    -- has registered cast N+1, which would cause a false ~50ms disappear.
    C_Timer.After(0, function()
        if not self.castBar then return end
        if UnitChannelInfo("player") then return end
        if UnitCastingInfo("player") then return end
        self.castBar.overrideColor = nil
        self.castBar:Hide()
        self.castBar:SetScript("OnUpdate", nil)
    end)
end

-- Handle spell delayed (cast time changed after push-back)
function PlayersCastbars:OnPlayerSpellcastDelayed(unit, castGUID, spellID)
    if unit ~= "player" then return end
    if not self.castBar or not self.castBar:IsShown() then return end
    -- 12.0.5: UnitCastingInfo pos 7=castID, pos 8=notInterruptible
    local name, _, texture, startTimeMS, endTimeMS = UnitCastingInfo("player")
    if not name or not startTimeMS or not endTimeMS then return end
    local bar = self.castBar
    bar.startTime = startTimeMS / 1000
    bar.endTime   = endTimeMS / 1000
end

-- =========================================================================
-- Mass Disintegrate (Scalecommander hero talent) detection
-- -------------------------------------------------------------------------
-- The proc has NO dedicated cast spell ID: the channel fires with 356995
-- (Disintegrate). The only reliable marker is the buff aura 436335
-- ("Your next Disintegrate hits up to 3 targets"). Since the proc is consumed
-- on cast, we snapshot the aura state at UNIT_SPELLCAST_SENT (fires before the
-- buff is gone) and use it as a fallback.
local DISINTEGRATE_SPELL    = 356995
local MASS_DISINTEGRATE_ID  = 436335   -- for the localized name ("Mass Disintegrate")
local MASS_PENDING_TIMEOUT  = 15       -- buff duration; after this the proc expires unused
local MASS_MAX_STACKS       = 2        -- the buff stacks up to 2

-- Empower-based detection (both secret- AND taint-free):
-- The buff 436336 is "secret" in combat (unusable via aura API/combat log), and
-- the channel fires with the same spellID 356995. BUT: Mass Disintegrate is
-- ALWAYS granted by a completed empower, and Devastation only has the two
-- empower spells Fire Breath & Eternity Surge. So: after every completed
-- empower, the next Disintegrate is a Mass Disintegrate.
--
-- The buff STACKS to 2 and resets its duration to ~14s on every empower.
-- Therefore we count stacks (instead of just true/false) so that two chained
-- Mass Disintegrates in a row are also detected correctly.
local massStacks      = 0
local massPendingTime = 0

-- Called after a completed empower: increment stack (max 2) and reset the
-- duration (refresh, like the buff itself).
function PlayersCastbars:MarkMassPending()
    massStacks      = math.min(massStacks + 1, MASS_MAX_STACKS)
    massPendingTime = GetTime()
end

-- Checks (and consumes ONE stack): every Disintegrate cast within the buff
-- duration consumes exactly one mass stack.
local function ConsumeMassPending()
    if massStacks > 0 and (GetTime() - massPendingTime) < MASS_PENDING_TIMEOUT then
        massStacks = massStacks - 1
        return true
    end
    massStacks = 0   -- expired -> all stacks lapse
    return false
end

-- Localized name of 436335 ("Mass Disintegrate").
local function GetMassDisintegrateName()
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(MASS_DISINTEGRATE_ID)
        if info and info.name then return info.name end
    end
    if GetSpellInfo then
        return (GetSpellInfo(MASS_DISINTEGRATE_ID))
    end
    return nil
end
-- =========================================================================

-- Re-check for active cast after zone change or UI reload
function PlayersCastbars:OnPlayerEnteringWorld()
    if not GetConfig().enabled then return end
    local name, _, texture, startTimeMS, endTimeMS = UnitCastingInfo("player")
    if name and startTimeMS and endTimeMS then
        self:OnPlayerSpellcastStart("player", nil, nil)
        return
    end
    name, _, texture, startTimeMS, endTimeMS = UnitChannelInfo("player")
    if name and startTimeMS and endTimeMS then
        self:OnPlayerSpellcastChannelStart("player", nil, nil)
        return
    end
    if self.castBar then self.castBar:Hide() end
end

function PlayersCastbars:OnPlayerSpellcastChannelStart(unit, castGUID, spellID, retryCount)
    local cfg = GetConfig()
    if not cfg.enabled or unit ~= "player" then return end
    local name, _, texture, startTimeMS, endTimeMS = UnitChannelInfo("player")
    if not name or not startTimeMS or not endTimeMS then
        -- Bug #3 fix: cap retries at 5 (~250 ms total) so a cancelled channel
        -- doesn't spin the timer forever.
        if (retryCount or 0) >= 5 then return end
        C_Timer.After(0.05, function()
            PlayersCastbars:OnPlayerSpellcastChannelStart(unit, castGUID, spellID, (retryCount or 0) + 1)
        end)
        return
    end
    local bar = self:GetCastBar()
    self:UpdateCastBarLayout()
    -- Always hide both channel ticks and empowered stages before showing relevant ones
    self:HideChannelTicks(bar)
    if bar.empoweredStages then
        for _, stage in ipairs(bar.empoweredStages) do stage:Hide() end
    end
    if bar.empoweredSegments then
        for _, seg in ipairs(bar.empoweredSegments) do seg:Hide() end
    end
    bar.isChannel = true
    bar.isEmpowered = false
    bar.castGUID  = castGUID
    bar.icon:SetTexture(texture)
    local isMass = (spellID == DISINTEGRATE_SPELL) and ConsumeMassPending()
    bar.isMassDisintegrate = isMass
    if isMass then
        local massName = GetMassDisintegrateName()
        if massName then name = massName end
    end
    bar.spellName:SetText(name)
    bar.startTime = startTimeMS / 1000
    bar.endTime   = endTimeMS / 1000
    local _, class = UnitClass("player")
    local color = RAID_CLASS_COLORS and RAID_CLASS_COLORS[class] or {r=1, g=1, b=1}
    if isMass then
        -- Mass Disintegrate: highlight in green
        bar.overrideColor = {0.5, 1, 0.5, 1}
        bar.status:SetStatusBarColor(0.5, 1, 0.5, 1)
    else
        bar.overrideColor = nil
        bar.status:SetStatusBarColor(color.r, color.g, color.b, 1)
    end
    -- Show channel ticks if known
    local currentSpecId = PlayerUtil.GetCurrentSpecID()
    if currentSpecId then
        local numTicks = ChannelTicksNum(currentSpecId)
        if numTicks then
            self:ShowChannelTicks(bar, numTicks)
        end
    end
    bar:SetScript("OnUpdate", CastBar_OnUpdate)
    bar:Show()
end

function PlayersCastbars:OnPlayerSpellcastChannelUpdate(unit, castGUID, spellID)
    if unit ~= "player" then return end -- Bug #6 fix: filter non-player units
    if not self.castBar then return end
    -- Do not compare castGUID; protected value can cause errors
    local name, _, texture, startTimeMS, endTimeMS = UnitChannelInfo("player")
    if not name or not startTimeMS or not endTimeMS then return end
    local bar = self.castBar
    bar.isChannel = true
    bar.castGUID  = castGUID
    if bar.icon then
        bar.icon:SetTexture(texture)
    end
    if bar.isMassDisintegrate then
        local massName = GetMassDisintegrateName()
        if massName then name = massName end
    end
    bar.spellName:SetText(name)
    bar.startTime = startTimeMS / 1000
    bar.endTime   = endTimeMS / 1000
    local currentSpecId = PlayerUtil.GetCurrentSpecID()
    if currentSpecId then
        local numTicks = ChannelTicksNum(currentSpecId)
        if numTicks then
            self:ShowChannelTicks(bar, numTicks)
        else
            self:HideChannelTicks(bar)
        end
    else
        self:HideChannelTicks(bar)
    end
end

function PlayersCastbars:OnPlayerSpellcastEmpowerStart(unit, castGUID, spellID)
    local cfg = GetConfig()
    if not cfg.enabled or unit ~= "player" then return end
    -- Prevent Font of Magic (spellID 411212) from showing empower stages
    if spellID == 411212 then return end
    local bar = self:GetCastBar()
    bar.spellID = spellID
    self:UpdateCastBarLayout()

    -- Empowered casts use channel API in 12.0.5 (UNIT_SPELLCAST_EMPOWER_START fires with UnitChannelInfo data)
    -- UnitChannelInfo: pos 7=notInterruptible, pos 10=numStages
    local name, _, texture, startTimeMS, endTimeMS, _, _, _, _, numStages = UnitChannelInfo("player")
    -- Fallback: Try UnitCastingInfo if UnitChannelInfo fails
    if (not name or not startTimeMS or not endTimeMS) then
        name, _, texture, startTimeMS, endTimeMS = UnitCastingInfo("player")
    end

    -- Fallback: Try C_Spell.GetSpellInfo if available
    if (not name or not startTimeMS or not endTimeMS) and spellID and C_Spell and C_Spell.GetSpellInfo then
        local spellInfo = C_Spell.GetSpellInfo(spellID)
        if spellInfo then
            if not name then name = spellInfo.name end
            if not texture then texture = spellInfo.iconID or 136243 end
        end
    end

    -- Fallback: Try global GetSpellInfo if available
    if (not name or not startTimeMS or not endTimeMS) and spellID and GetSpellInfo then
        local gName, gTexture = GetSpellInfo(spellID)
        if not name and gName then name = gName end
        if not texture and gTexture then texture = gTexture end
    end

    -- Fallback: Use default name and icon
    if not name then name = "Empowered Cast" end
    if not texture then texture = 136243 end

    -- Fallback: Use UnitEmpoweredChannelDuration for timing if available
    if (not startTimeMS or not endTimeMS) then
        local now = GetTime()
        if UnitEmpoweredChannelDuration then
            local durationObj = UnitEmpoweredChannelDuration("player", true)
            if durationObj and durationObj.totalTimeMS then
                startTimeMS = now * 1000
                endTimeMS = startTimeMS + durationObj.totalTimeMS
            else
                startTimeMS = now * 1000
                endTimeMS = (now + 3) * 1000
            end
        else
            startTimeMS = now * 1000
            endTimeMS = (now + 3) * 1000
        end
    end

    -- Try to get numStages from C_Spell if available (overrides previous value)
    if spellID and C_Spell and C_Spell.GetSpellEmpowerInfo then
        local empowerInfo = C_Spell.GetSpellEmpowerInfo(spellID)
        if empowerInfo and empowerInfo.numStages and empowerInfo.numStages > 0 then
            numStages = empowerInfo.numStages
        end
    end

    bar.isEmpowered = true
    bar.numStages = numStages or 3
    -- Always hide both channel ticks and empowered stages before showing relevant ones
    self:HideChannelTicks(bar)
    if bar.empoweredStages then
        for _, stage in ipairs(bar.empoweredStages) do stage:Hide() end
    end
    if bar.empoweredSegments then
        for _, seg in ipairs(bar.empoweredSegments) do seg:Hide() end
    end
    bar.isChannel = false
    bar.isEmpowered = true
    bar.castGUID = castGUID
    bar.isChannel = false
    bar.spellName:SetText(name)
    -- Set icon using robust fallback logic
    if bar.icon then
        bar.icon:SetTexture(texture)
    end
    -- Set font and shadow for spell name and time text
    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    local font = GetConfig().font or (LSM and LSM:Fetch("font", GetConfig().fontName or LSM:GetDefault("font"))) or GetGlobalFont()
    bar.spellName:SetFont(font, cfg.textSize or 12, "OUTLINE")
    bar.spellName:SetShadowOffset(0, 0)
    if bar.timeText then
        bar.timeText:SetFont(font, cfg.textSize or 12, "OUTLINE")
        bar.timeText:SetShadowOffset(0, 0)
    end
    local now = GetTime()
    bar.startTime = startTimeMS / 1000
    bar.endTime = (endTimeMS / 1000) + 1.0 -- Add 1s for hold-at-max
    -- Clamp start time if very old
    if bar.startTime < now - 5 then
        local dur = (endTimeMS - startTimeMS) / 1000
        bar.startTime = now
        bar.endTime = now + dur + 1.0 -- Add 1s for hold-at-max
    end
    -- Draw empowered stage markers
    if bar.numStages and bar.numStages > 0 then
        C_Timer.After(0.01, function()
            if bar.isEmpowered and bar.numStages > 0 then
                PlayersCastbars:InitializeEmpoweredStages(bar)
            end
        end)
    end
    -- Empowered cast color curve: green, yellow, orange, red, red
    if not bar.empoweredColorCurve then
        local curve = C_CurveUtil.CreateColorCurve()
        curve:SetType(Enum.LuaCurveType.Step)
        curve:AddPoint(0.0, CreateColor(0, 1, 0, 1))      -- Green
        curve:AddPoint(0.25, CreateColor(1, 1, 0, 1))     -- Yellow
        curve:AddPoint(0.5, CreateColor(1, 0.5, 0, 1))    -- Orange
        -- Make red start after the 3rd tick (at 0.6, not 0.75)
        curve:AddPoint(0.6, CreateColor(1, 0, 0, 1))      -- Red
        curve:AddPoint(1.0, CreateColor(1, 0, 0, 1))      -- Red
        bar.empoweredColorCurve = curve
    end
    bar:SetScript("OnUpdate", function(self, elapsed)
        if not self.startTime or not self.endTime then return end
        local now = GetTime()
        if now >= self.endTime then
            if self.empoweredStages then
                for _, stage in ipairs(self.empoweredStages) do
                    stage:Hide()
                end
            end
            self:Hide()
            self:SetScript("OnUpdate", nil)
            -- Clear state AFTER hiding so STOP handlers still see valid state
            self.castGUID    = nil
            self.isChannel   = nil
            self.isEmpowered = nil
            self.numStages   = nil
            return
        end
        local status = self.status
        if not status then return end
        local duration = self.endTime - self.startTime
        if duration <= 0 then duration = 0.001 end
        local progress = now - self.startTime
        status:SetMinMaxValues(0, duration)
        status:SetValue(progress)
        if self.timeText then
            local remaining = self.endTime - now
            self.timeText:SetText(string.format("%.1f/%.1f", remaining, duration))
        end
        -- Only apply color curve if empowered
        if self.isEmpowered and self.empoweredColorCurve then
            local percent = math.min(math.max(progress / duration, 0), 1)
            local color = self.empoweredColorCurve:Evaluate(percent)
                local r, g, b = color:GetRGB()
                status:GetStatusBarTexture():SetVertexColor(tonumber(r) or 1, tonumber(g) or 1, tonumber(b) or 1, 1)
        end
    end)
    bar:Show()
end

function PlayersCastbars:OnPlayerSpellcastEmpowerUpdate(unit, castGUID, spellID)
    if unit ~= "player" then return end -- Bug #6 fix: filter non-player units
    if not self.castBar then return end
    -- Do not compare castGUID; protected value can cause errors
    local bar = self.castBar
    local name, _, texture, startTimeMS, endTimeMS = UnitChannelInfo("player")
    if not name or not startTimeMS or not endTimeMS then
        name, _, texture, startTimeMS, endTimeMS = UnitCastingInfo("player")
    end
    if not name or not startTimeMS or not endTimeMS then return end
    bar.isChannel = false
    bar.castGUID  = castGUID
    if bar.icon then
        bar.icon:SetTexture(texture)
    end
    bar.spellName:SetText(name)
    bar.startTime = startTimeMS / 1000
    bar.endTime   = endTimeMS / 1000
end

function PlayersCastbars:OnPlayerSpellcastEmpowerStop(unit, castGUID, spellID)
    if not self.castBar then return end
    if unit ~= "player" then return end
    if castGUID and self.castBar.castGUID and castGUID ~= self.castBar.castGUID then return end
    local name, _, texture, startTimeMS, endTimeMS = UnitCastingInfo("player")
    if name and startTimeMS and endTimeMS then
        if self.castBar.icon and texture then
            self.castBar.icon:SetTexture(texture)
        end
        self.castBar.spellName:SetText(name)
        self.castBar.startTime = startTimeMS / 1000
        self.castBar.endTime = endTimeMS / 1000
        self.castBar.isEmpowered = false
        self.castBar.numStages = 0
        if self.castBar.empoweredStages then
            for _, stage in ipairs(self.castBar.empoweredStages) do
                stage:Hide()
            end
        end
        -- Hide empowered segments
        if self.castBar.empoweredSegments then
            for _, seg in ipairs(self.castBar.empoweredSegments) do
                seg:Hide()
            end
        end
        return
    end
    -- Bug #2 fix: if a channel (e.g. Disintegrate) took over immediately after the
    -- empower, don't hide the bar — hand off to the channel handler instead.
    local chanName, _, _, chanStartMS, chanEndMS = UnitChannelInfo("player")
    if chanName and chanStartMS and chanEndMS then
        self:OnPlayerSpellcastChannelStart(unit, castGUID, spellID)
        return
    end
    if self.castBar.empoweredStages then
        for _, stage in ipairs(self.castBar.empoweredStages) do
            stage:Hide()
        end
    end
    -- Hide empowered segments
    if self.castBar.empoweredSegments then
        for _, seg in ipairs(self.castBar.empoweredSegments) do
            seg:Hide()
        end
    end
    self.castBar:Hide()
    self.castBar:SetScript("OnUpdate", nil)
end


local function RobustlyHideBlizzardCastBar()
    local cfg = GetConfig()
    if cfg.hideDefaultBar == false then
        -- Restore Blizzard cast bar
        local frames = { _G["PlayerCastingBarFrame"], _G["CastingBarFrame"] }
        for _, f in ipairs(frames) do
            if f then
                if f.SetAlpha then f:SetAlpha(1) end
                if f.SetScale then f:SetScale(1) end
            end
        end
        return
    end
    -- Always use 0.01 scale when hiding — do NOT rely on blizzBarScale slider value
    -- (alpha alone can be reset by Blizzard's Show(); scale 0.01 makes the bar invisible regardless)
    local frames = { _G["PlayerCastingBarFrame"], _G["CastingBarFrame"] }
    for _, f in ipairs(frames) do
        if f then
            if f.SetAlpha then f:SetAlpha(0) end
            if f.SetScale then f:SetScale(0.01) end
        end
    end
end

local function HideBlizzardTargetCastBar()
    local cfg = PlayersCastbars.db and PlayersCastbars.db.profile and PlayersCastbars.db.profile.target
    if not cfg then return end
    local f = _G["TargetFrameSpellBar"]
    if not f then return end
    if cfg.hideDefaultBar == false then
        if f.SetAlpha then f:SetAlpha(1) end
        if f.SetScale then f:SetScale(1) end
    else
        if f.SetAlpha then f:SetAlpha(0) end
        if f.SetScale then f:SetScale(0.01) end
    end
end

local function HideBlizzardFocusCastBar()
    local cfg = PlayersCastbars.db and PlayersCastbars.db.profile and PlayersCastbars.db.profile.focus
    if not cfg then return end
    local f = _G["FocusFrameSpellBar"]
    if not f then return end
    if cfg.hideDefaultBar == false then
        if f.SetAlpha then f:SetAlpha(1) end
        if f.SetScale then f:SetScale(1) end
    else
        if f.SetAlpha then f:SetAlpha(0) end
        if f.SetScale then f:SetScale(0.01) end
    end
end

-- Register events on login — split into TWO frames so event frame setup
-- never runs in the same execution context as the Blizzard bar hide call.
-- If hiding PlayerCastingBarFrame (EditMode secure frame) causes any taint,
-- it stays isolated to the blizzHideFrame handler and cannot infect the
-- clean _eventFrame registration.
local blizzHideFrame = CreateFrame("Frame")
blizzHideFrame:RegisterEvent("PLAYER_LOGIN")
blizzHideFrame:SetScript("OnEvent", function()
    RobustlyHideBlizzardCastBar()
    HideBlizzardTargetCastBar()
    HideBlizzardFocusCastBar()
    -- Hook Show() on Blizzard cast bar frames so hide re-applies on every cast,
    -- even if Blizzard's code resets alpha/scale when showing the bar.
    local blizzFrameNames = { "PlayerCastingBarFrame", "CastingBarFrame" }
    for _, name in ipairs(blizzFrameNames) do
        local f = _G[name]
        if f and not f._psbHooked then
            f._psbHooked = true
            hooksecurefunc(f, "Show", function(self)
                local cfg = GetConfig()
                if cfg.hideDefaultBar ~= false then
                    if self.SetAlpha then self:SetAlpha(0) end
                    if self.SetScale then self:SetScale(0.01) end
                end
            end)
        end
    end
    -- Hook Show() on target/focus Blizzard cast bar frames too
    local targetBar = _G["TargetFrameSpellBar"]
    if targetBar and not targetBar._psbHooked then
        targetBar._psbHooked = true
        hooksecurefunc(targetBar, "Show", function(self)
            local cfg = PlayersCastbars.db and PlayersCastbars.db.profile and PlayersCastbars.db.profile.target
            if cfg and cfg.hideDefaultBar ~= false then
                if self.SetAlpha then self:SetAlpha(0) end
                if self.SetScale then self:SetScale(0.01) end
            end
        end)
    end
    local focusBar = _G["FocusFrameSpellBar"]
    if focusBar and not focusBar._psbHooked then
        focusBar._psbHooked = true
        hooksecurefunc(focusBar, "Show", function(self)
            local cfg = PlayersCastbars.db and PlayersCastbars.db.profile and PlayersCastbars.db.profile.focus
            if cfg and cfg.hideDefaultBar ~= false then
                if self.SetAlpha then self:SetAlpha(0) end
                if self.SetScale then self:SetScale(0.01) end
            end
        end)
    end
end)

local eventSetupFrame = CreateFrame("Frame")
eventSetupFrame:RegisterEvent("PLAYER_LOGIN")
eventSetupFrame:SetScript("OnEvent", function()
    if not PlayersCastbars._eventFrame then
        local f = CreateFrame("Frame")
        f:RegisterEvent("UNIT_SPELLCAST_START")
        f:RegisterEvent("UNIT_SPELLCAST_STOP")
        f:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
        f:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
        f:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
        f:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START")
        f:RegisterEvent("UNIT_SPELLCAST_EMPOWER_UPDATE")
        f:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP")
        f:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
        f:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
        f:RegisterEvent("UNIT_SPELLCAST_DELAYED")
        f:RegisterEvent("PLAYER_ENTERING_WORLD")
        f:SetScript("OnEvent", function(_, event, unit, castGUID, spellID, arg4)
            if event == "UNIT_SPELLCAST_START" then PlayersCastbars:OnPlayerSpellcastStart(unit, castGUID, spellID)
            elseif event == "UNIT_SPELLCAST_STOP" then PlayersCastbars:OnPlayerSpellcastStop(unit, castGUID, spellID)
            elseif event == "UNIT_SPELLCAST_CHANNEL_START" then PlayersCastbars:OnPlayerSpellcastChannelStart(unit, castGUID, spellID)
            elseif event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then PlayersCastbars:OnPlayerSpellcastChannelUpdate(unit, castGUID, spellID)
            elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then PlayersCastbars:OnPlayerSpellcastChannelStop(unit, castGUID, spellID)
            elseif event == "UNIT_SPELLCAST_EMPOWER_START" then PlayersCastbars:OnPlayerSpellcastEmpowerStart(unit, castGUID, spellID)
            elseif event == "UNIT_SPELLCAST_EMPOWER_UPDATE" then PlayersCastbars:OnPlayerSpellcastEmpowerUpdate(unit, castGUID, spellID)
            elseif event == "UNIT_SPELLCAST_EMPOWER_STOP" then
                -- arg4 == complete (if provided by the event): only a fully
                -- released empower grants Mass Disintegrate. If the event
                -- provides no complete flag (arg4 == nil), mark anyway --
                -- only skip on an explicit cancel (arg4 == false).
                if unit == "player" and arg4 ~= false then PlayersCastbars:MarkMassPending() end
                PlayersCastbars:OnPlayerSpellcastEmpowerStop(unit, castGUID, spellID)
            elseif event == "UNIT_SPELLCAST_DELAYED" then PlayersCastbars:OnPlayerSpellcastDelayed(unit, castGUID, spellID)
            elseif event == "PLAYER_ENTERING_WORLD" then PlayersCastbars:OnPlayerEnteringWorld()
            end
        end)
        PlayersCastbars._eventFrame = f
    end
end)

SLASH_PLAYERSCASTBAR1 = "/pcb"
SLASH_PLAYERSCASTBAR2 = "/tcb"
SLASH_PLAYERSCASTBAR3 = "/fcb"
SlashCmdList["PLAYERSCASTBAR"] = function()
    -- Open the AceConfigDialog options window for profile management
    local AceConfig = LibStub("AceConfig-3.0")
    local AceConfigDialog = LibStub("AceConfigDialog-3.0")
    local AceDBOptions = LibStub("AceDBOptions-3.0")
    if not PlayersCastbars.optionsTable then
        local LSM = LibStub("LibSharedMedia-3.0")

        PlayersCastbars.optionsTable = {
            type = "group",
            name = "PlayersCastbars",
            args = {
                playercastbar = {
                    type = "group",
                    name = "Player Cast Bar",
                    order = 1,
                    args = {
                        previewbutton = {
                            type = "execute",
                            name = "Preview Cast Bar (click again to lock)",
                            order = 0.5,
                            width = "full",
                            func = function()
                                local bar = PlayersCastbars:GetCastBar()
                                if not PlayersCastbars.previewActive then
                                    PlayersCastbars:ShowPreviewCastBar()
                                    bar:EnableMouse(true)
                                    bar:SetMovable(true)
                                    bar:RegisterForDrag("LeftButton")
                                    bar:SetScript("OnDragStart", function(self) self:StartMoving() end)
                                    bar:SetScript("OnDragStop", function(self)
                                        self:StopMovingOrSizing()
                                        local point, _, _, x, y = self:GetPoint()
                                        local cfg = PlayersCastbars.db and PlayersCastbars.db.profile or {}
                                        cfg.anchorPoint = point
                                        cfg.offsetX = x
                                        cfg.offsetY = y
                                    end)
                                else
                                    PlayersCastbars:HidePreviewCastBar()
                                    bar:EnableMouse(false)
                                    bar:SetMovable(false)
                                    bar:RegisterForDrag()
                                    bar:SetScript("OnDragStart", nil)
                                    bar:SetScript("OnDragStop", nil)
                                end
                            end,
                        },
                        enabled = {
                            type = "toggle",
                            name = "Enable Cast Bar",
                            order = 1,
                            get = function() return GetConfig().enabled ~= false end,
                            set = function(_, val)
                                GetConfig().enabled = val
                                if PlayersCastbars.castBar then
                                    if val then PlayersCastbars.castBar:Show() else PlayersCastbars.castBar:Hide() end
                                end
                            end,
                        },
                        widthSyncMode = {
                            type = "select",
                            name = "Width Mode",
                            desc = "Choose how to set the bar width.",
                            order = 1.5,
                            values = {
                                set = "Set Width (Manual)",
                                essential = "Sync with Essential Cooldown Manager",
                                utility = "Sync with Utility Cooldown Manager",
                            },
                            get = function()
                                local cfg = GetConfig()
                                return cfg.widthSyncMode or "set"
                            end,
                            set = function(_, v)
                                local cfg = GetConfig()
                                cfg.widthSyncMode = v
                                if PlayersCastbars.castBar then
                                    PlayersCastbars:UpdateCastBarLayout()
                                end
                            end,
                        },
                        width = {
                            type = "range",
                            name = "Width",
                            min = 100, max = 600, step = 1,
                            order = 2,
                            get = function()
                                local cfg = GetConfig()
                                return tonumber(cfg.width) or 220
                            end,
                            set = function(_, val)
                                local cfg = GetConfig()
                                cfg.width = val
                                if PlayersCastbars.castBar then PlayersCastbars:UpdateCastBarLayout() end
                            end,
                            disabled = function()
                                local cfg = GetConfig()
                                local mode = cfg and cfg.widthSyncMode or "set"
                                return mode ~= "set"
                            end,
                        },
                        height = {
                            type = "range",
                            name = "Height",
                            min = 10, max = 100, step = 1,
                            order = 3,
                            get = function()
                                local cfg = GetConfig()
                                return tonumber(cfg.height) or 24
                            end,
                            set = function(_, val)
                                local cfg = GetConfig()
                                cfg.height = val
                                if PlayersCastbars.castBar then PlayersCastbars:UpdateCastBarLayout() end
                            end,
                        },
                        iconOffsetY = {
                            type = "range",
                            name = "Icon Y Offset",
                            min = -100, max = 100, step = 1,
                            order = 4.2,
                            get = function() return GetConfig().iconOffsetY or 0 end,
                            set = function(_, val)
                                GetConfig().iconOffsetY = val
                                if PlayersCastbars.castBar and PlayersCastbars.castBar.iconFrame then
                                    local cfg = GetConfig()
                                    PlayersCastbars.castBar.iconFrame:ClearAllPoints()
                                    PlayersCastbars.castBar.iconFrame:SetPoint("TOPLEFT", PlayersCastbars.castBar, "TOPLEFT", -26 + (cfg.iconOffsetX or 0), cfg.iconOffsetY or 0)
                                end
                            end,
                        },
                        iconOffsetX = {
                            type = "range",
                            name = "Icon X Offset",
                            min = -100, max = 100, step = 1,
                            order = 4.21,
                            get = function() return GetConfig().iconOffsetX or 0 end,
                            set = function(_, val)
                                GetConfig().iconOffsetX = val
                                if PlayersCastbars.castBar and PlayersCastbars.castBar.iconFrame then
                                    local cfg = GetConfig()
                                    PlayersCastbars.castBar.iconFrame:ClearAllPoints()
                                    PlayersCastbars.castBar.iconFrame:SetPoint("TOPLEFT", PlayersCastbars.castBar, "TOPLEFT", -26 + (cfg.iconOffsetX or 0), cfg.iconOffsetY or 0)
                                end
                            end,
                        },
                        iconSize = {
                            type = "range",
                            name = "Icon Size",
                            min = 16, max = 64, step = 1,
                            order = 4.22,
                            get = function() return GetConfig().iconSize or 24 end,
                            set = function(_, val)
                                GetConfig().iconSize = val
                                if PlayersCastbars.castBar and PlayersCastbars.castBar.iconFrame then
                                    PlayersCastbars.castBar.iconFrame:SetSize(val, val)
                                end
                            end,
                        },
                        bgColor = {
                            type = "color",
                            name = "Background Color",
                            order = 4.3,
                            hasAlpha = true,
                            get = function()
                                local c = GetConfig().bgColor or {0,0,0,1}
                                if c.r then return c.r, c.g, c.b, c.a end
                                return c[1] or 0, c[2] or 0, c[3] or 0, c[4] or 1
                            end,
                            set = function(_, r, g, b, a)
                                GetConfig().bgColor = {r, g, b, a}
                                if PlayersCastbars.castBar and PlayersCastbars.castBar.bg then
                                    PlayersCastbars.castBar.bg:SetColorTexture(r, g, b, a)
                                end
                            end,
                        },
                        bgAlpha = {
                            type = "range",
                            name = "Background Transparency",
                            min = 0, max = 1, step = 0.01,
                            order = 4.31,
                            get = function()
                                local c = GetConfig().bgColor or {0,0,0,1}
                                return c[4] or c.a or 1
                            end,
                            set = function(_, val)
                                local c = GetConfig().bgColor or {0,0,0,1}
                                c[4] = val
                                GetConfig().bgColor = c
                                if PlayersCastbars.castBar and PlayersCastbars.castBar.bg then
                                    local r, g, b = c[1] or 0, c[2] or 0, c[3] or 0
                                    PlayersCastbars.castBar.bg:SetColorTexture(r, g, b, val)
                                end
                            end,
                        },
                        showCastIcon = {
                            type = "toggle",
                            name = "Show Cast Icon",
                            order = 5,
                            get = function() return GetConfig().showCastIcon ~= false end,
                            set = function(_, val)
                                GetConfig().showCastIcon = val
                                if PlayersCastbars.castBar and PlayersCastbars.castBar.iconFrame then
                                    if val then
                                        PlayersCastbars.castBar.iconFrame:Show()
                                    else
                                        PlayersCastbars.castBar.iconFrame:Hide()
                                    end
                                end
                            end,
                        },
                        fontName = LSM and {
                            type = "select",
                            dialogControl = "LSM30_Font",
                            name = "Font",
                            order = 5.9,
                            values = function() return LSM:HashTable("font") end,
                            get = function() return GetConfig().fontName or LSM:GetDefault("font") end,
                            set = function(_, val)
                                GetConfig().fontName = val
                                GetConfig().font = LSM:Fetch("font", val)
                                if PlayersCastbars.castBar and GetConfig().font then
                                    local size = GetConfig().textSize or 12
                                    PlayersCastbars.castBar.spellName:SetFont(GetConfig().font, size, "OUTLINE")
                                    PlayersCastbars.castBar.timeText:SetFont(GetConfig().font, size, "OUTLINE")
                                end
                            end,
                        } or nil,
                        textSize = {
                            type = "range",
                            name = "Text Size",
                            min = 8, max = 32, step = 1,
                            order = 6,
                            get = function() return GetConfig().textSize end,
                            set = function(_, val)
                                GetConfig().textSize = val
                                if PlayersCastbars.castBar then
                                    local font = GetConfig().font or (LSM and LSM:Fetch("font", GetConfig().fontName or LSM:GetDefault("font"))) or GetGlobalFont()
                                    PlayersCastbars.castBar.spellName:SetFont(font, val, "OUTLINE")
                                    PlayersCastbars.castBar.timeText:SetFont(font, val, "OUTLINE")
                                end
                            end,
                        },
                        castNameAlpha = {
                        type = "range",
                        name = "Cast Name Text Visibility",
                        desc = "Set to 0 to hide cast name text, 1 to show fully.",
                        min = 0, max = 1, step = 0.01,
                        order = 5.05,
                        get = function() return GetConfig().castNameAlpha or 1 end,
                        set = function(_, val)
                            if PlayersCastbars.db and PlayersCastbars.db.profile then
                                PlayersCastbars.db.profile.castNameAlpha = val
                            else
                                GetConfig().castNameAlpha = val
                            end
                            if PlayersCastbars.castBar and PlayersCastbars.castBar.spellName then
                                PlayersCastbars.castBar.spellName:SetAlpha(val)
                                PlayersCastbars:UpdateCastBarLayout()
                            end
                        end,
                        },
                        timeTextAlpha = {
                        type = "range",
                        name = "Timer Text Visibility",
                        desc = "Set to 0 to hide the timer text, 1 to show fully.",
                        min = 0, max = 1, step = 0.01,
                        order = 5.06,
                        get = function() return GetConfig().timeTextAlpha or 1 end,
                        set = function(_, val)
                            if PlayersCastbars.db and PlayersCastbars.db.profile then
                                PlayersCastbars.db.profile.timeTextAlpha = val
                            else
                                GetConfig().timeTextAlpha = val
                            end
                            if PlayersCastbars.castBar and PlayersCastbars.castBar.timeText then
                                PlayersCastbars.castBar.timeText:SetAlpha(val)
                                PlayersCastbars:UpdateCastBarLayout()
                            end
                        end,
},
                        queueWindow = {
                            type = "range",
                            name = "Queue Window (s)",
                            min = 0.1, max = 1.0, step = 0.01,
                            order = 6.3,
                            get = function() return GetConfig().queueWindow or 0.4 end,
                            set = function(_, val)
                                GetConfig().queueWindow = val
                                if PlayersCastbars.castBar then PlayersCastbars:UpdateCastBarLayout() end
                            end,
                        },
                        queueWindowColor = {
                            type = "color",
                            name = "Queue Window Color",
                            hasAlpha = true,
                            order = 6.4,
                            get = function()
                                local c = GetConfig().queueWindowColor or {1, 0, 1, 0.5}
                                return c[1], c[2], c[3], c[4]
                            end,
                            set = function(_, r, g, b, a)
                                GetConfig().queueWindowColor = {r, g, b, a}
                                if PlayersCastbars.castBar then PlayersCastbars:UpdateCastBarLayout() end
                            end,
                        },
                        castNameOffsetX = {
                            type = "range",
                            name = "Cast Name X Offset",
                            min = -200, max = 200, step = 1,
                            order = 6.1,
                            get = function() return GetConfig().castNameOffsetX or 4 end,
                            set = function(_, val)
                                GetConfig().castNameOffsetX = val
                                if PlayersCastbars.castBar then PlayersCastbars:UpdateCastBarLayout() end
                            end,
                        },
                        castNameOffsetY = {
                            type = "range",
                            name = "Cast Name Y Offset",
                            min = -100, max = 100, step = 1,
                            order = 6.2,
                            get = function() return GetConfig().castNameOffsetY or 0 end,
                            set = function(_, val)
                                GetConfig().castNameOffsetY = val
                                if PlayersCastbars.castBar then PlayersCastbars:UpdateCastBarLayout() end
                            end,
                        },
                        offsetX = {
                            type = "range",
                            name = "X Position",
                            min = -500, max = 500, step = 1,
                            order = 7,
                            get = function() return GetConfig().offsetX end,
                            set = function(_, val)
                                GetConfig().offsetX = val
                                if PlayersCastbars.castBar then
                                    PlayersCastbars.castBar:SetPoint(GetConfig().anchorPoint, UIParent, GetConfig().anchorPoint, val, GetConfig().offsetY)
                                end
                            end,
                        },
                        offsetY = {
                            type = "range",
                            name = "Y Position",
                            min = -500, max = 500, step = 1,
                            order = 8,
                            get = function() return GetConfig().offsetY end,
                            set = function(_, val)
                                GetConfig().offsetY = val
                                if PlayersCastbars.castBar then
                                    PlayersCastbars.castBar:SetPoint(GetConfig().anchorPoint, UIParent, GetConfig().anchorPoint, GetConfig().offsetX, val)
                                end
                            end,
                        },
                        hideDefaultBar = {
                            type = "toggle",
                            name = "Hide Default Cast Bar",
                            order = 8.5,
                            get = function() return GetConfig().hideDefaultBar ~= false end,
                            set = function(_, val)
                                GetConfig().hideDefaultBar = val
                                if type(RobustlyHideBlizzardCastBar) == "function" then RobustlyHideBlizzardCastBar() end
                            end,
                        },
                        blizzBarScale = {
                            type = "range",
                            name = "Blizzard Cast Bar Scale (for hiding)",
                            min = 0.01, max = 1, step = 0.01,
                            order = 9,
                            get = function() return GetConfig().blizzBarScale or 0.01 end,
                            set = function(_, val)
                                GetConfig().blizzBarScale = val
                                if type(RobustlyHideBlizzardCastBar) == "function" then RobustlyHideBlizzardCastBar() end
                            end,
                        },
                        textureName = {
                            type = "select",
                            dialogControl = "LSM30_Statusbar",
                            name = "Cast Bar Texture",
                            order = 10,
                            values = function() return LSM:HashTable("statusbar") end,
                            get = function() return GetConfig().textureName or "Blizzard" end,
                            set = function(_, val)
                                GetConfig().textureName = val
                                GetConfig().texture = LSM:Fetch("statusbar", val)
                                if PlayersCastbars.castBar and GetConfig().texture then
                                    PlayersCastbars.castBar.status:SetStatusBarTexture(GetConfig().texture)
                                end
                            end,
                        },
                        ombre = {
                            type = "toggle",
                            name = "Ombre (Rainbow) Cast Bar",
                            order = 11,
                            get = function() return GetConfig().ombre ~= false end,
                            set = function(_, val)
                                GetConfig().ombre = val
                            end,
                        },
                        colorMode = {
                            type = "select",
                            name = "Cast Bar Color Mode",
                            order = 12,
                            values = { class = "Class Color", ombre = "Ombre (Rainbow)", custom = "Custom Color" },
                            get = function() return GetConfig().colorMode or "class" end,
                            set = function(_, val)
                                GetConfig().colorMode = val
                                if PlayersCastbars.castBar then PlayersCastbars:UpdateCastBarLayout() end
                            end,
                        },
                        customColor = {
                            type = "color",
                            name = "Gradient Start Color",
                            order = 13,
                            hasAlpha = true,
                            get = function()
                                local c = GetConfig().customColor or {1,1,1,1}
                                if type(c) == "table" then
                                    if c.r then
                                        return tonumber(c.r) or 1, tonumber(c.g) or 1, tonumber(c.b) or 1, tonumber(c.a) or 1
                                    else
                                        return tonumber(c[1]) or 1, tonumber(c[2]) or 1, tonumber(c[3]) or 1, tonumber(c[4]) or 1
                                    end
                                end
                                return 1,1,1,1
                            end,
                            set = function(_, r, g, b, a)
                                GetConfig().customColor = {r=r, g=g, b=b, a=a}
                                if PlayersCastbars.castBar then PlayersCastbars:UpdateCastBarLayout() end
                            end,
                            hidden = function() return GetConfig().colorMode ~= "custom" end,
                        },
                        customColor2 = {
                            type = "color",
                            name = "Gradient End Color",
                            order = 14,
                            hasAlpha = true,
                            get = function()
                                local c = GetConfig().customColor2 or {1,1,1,1}
                                if type(c) == "table" then
                                    if c.r then
                                        return tonumber(c.r) or 1, tonumber(c.g) or 1, tonumber(c.b) or 1, tonumber(c.a) or 1
                                    else
                                        return tonumber(c[1]) or 1, tonumber(c[2]) or 1, tonumber(c[3]) or 1, tonumber(c[4]) or 1
                                    end
                                end
                                return 1,1,1,1
                            end,
                            set = function(_, r, g, b, a)
                                GetConfig().customColor2 = {r=r, g=g, b=b, a=a}
                                if PlayersCastbars.castBar then PlayersCastbars:UpdateCastBarLayout() end
                            end,
                            hidden = function() return GetConfig().colorMode ~= "custom" end,
                        },
                        empowerColors = {
                            type = "group",
                            name = "Empower Cast Colors",
                            inline = true,
                            order = 100,
                            args = (function()
                                local args = {
                                    header = {
                                        type = "header",
                                        name = "Empower Cast Colors",
                                        order = 1,
                                    },
                                }
                                for i = 1, 4 do
                                    for i = 1, 5 do
                                        args["stage"..i] = {
                                            type = "color",
                                            name = "Stage "..i.." Tick",
                                            hasAlpha = true,
                                            order = 10 + i,
                                            get = function()
                                                local cfg = GetConfig()
                                                local c = cfg and cfg.empowerStageColors and cfg.empowerStageColors[i] or {1,1,1,1}
                                                return c[1], c[2], c[3], c[4]
                                            end,
                                            set = function(_, r, g, b, a)
                                                local cfg = GetConfig()
                                                if cfg and cfg.empowerStageColors then cfg.empowerStageColors[i] = {r, g, b, a} end
                                                if PlayersCastbars.castBar then PlayersCastbars:UpdateCastBarLayout() end
                                            end,
                                        }
                                        args["seg"..i] = {
                                            type = "color",
                                            name = "Stage "..i.." Segment",
                                            hasAlpha = true,
                                            order = 20 + i,
                                            get = function()
                                                local cfg = GetConfig()
                                                local c = cfg and cfg.empowerSegColors and cfg.empowerSegColors[i] or {1,1,1,1}
                                                return c[1], c[2], c[3], c[4]
                                            end,
                                            set = function(_, r, g, b, a)
                                                local cfg = GetConfig()
                                                if cfg and cfg.empowerSegColors then cfg.empowerSegColors[i] = {r, g, b, a} end
                                                if PlayersCastbars.castBar then PlayersCastbars:UpdateCastBarLayout() end
                                            end,
                                        }
                                    end
                                end
                                return args
                            end)(),
                        },
                    },
                },
            },
        }
        -- Target Cast Bar options group
        PlayersCastbars.optionsTable.args.targetcastbar = {
            type = "group",
            name = "Target Cast Bar",
            order = 2,
            args = {
                previewbutton = {
                    type = "execute",
                    name = "Preview (click again to lock)",
                    order = 0.5,
                    width = "full",
                    func = function()
                        if not PlayersCastbars.targetPreviewActive then
                            PlayersCastbars:ShowTargetPreviewCastBar()
                            local bar = PlayersCastbars.targetCastBar
                            if bar then
                                bar:EnableMouse(true); bar:SetMovable(true); bar:RegisterForDrag("LeftButton")
                                bar:SetScript("OnDragStart", function(s) s:StartMoving() end)
                                bar:SetScript("OnDragStop", function(s)
                                    s:StopMovingOrSizing()
                                    local point, _, _, x, y = s:GetPoint()
                                    local cfg = PlayersCastbars.db.profile.target
                                    cfg.anchorPoint = point; cfg.offsetX = x; cfg.offsetY = y
                                end)
                            end
                        else
                            PlayersCastbars:HideTargetPreviewCastBar()
                            local bar = PlayersCastbars.targetCastBar
                            if bar then
                                bar:EnableMouse(false); bar:SetMovable(false); bar:RegisterForDrag()
                                bar:SetScript("OnDragStart", nil); bar:SetScript("OnDragStop", nil)
                            end
                        end
                    end,
                },
                enabled = {
                    type = "toggle", name = "Enable", order = 1,
                    get = function() return PlayersCastbars.db.profile.target.enabled ~= false end,
                    set = function(_, val)
                        PlayersCastbars.db.profile.target.enabled = val
                        if PlayersCastbars.targetCastBar then
                            if val then PlayersCastbars.targetCastBar:Show() else PlayersCastbars.targetCastBar:Hide() end
                        end
                    end,
                },
                interruptibleColor = {
                    type = "color", name = "Interruptible Color", order = 2, hasAlpha = true,
                    get = function()
                        local c = PlayersCastbars.db.profile.target.castBarColor or {0,1,0,1}
                        return c[1], c[2], c[3], c[4]
                    end,
                    set = function(_, r, g, b, a)
                        PlayersCastbars.db.profile.target.castBarColor = {r,g,b,a}
                    end,
                },
                protectedColor = {
                    type = "color", name = "Protected Color", order = 3, hasAlpha = true,
                    get = function()
                        local c = PlayersCastbars.db.profile.target.castBarProtectedColor or {1,0.5,0,1}
                        return c[1], c[2], c[3], c[4]
                    end,
                    set = function(_, r, g, b, a)
                        PlayersCastbars.db.profile.target.castBarProtectedColor = {r,g,b,a}
                    end,
                },
                textureName = {
                    type = "select", dialogControl = "LSM30_Statusbar", name = "Texture", order = 4,
                    values = function() local LSM = LibStub("LibSharedMedia-3.0", true); return LSM and LSM:HashTable("statusbar") or {} end,
                    get = function() return PlayersCastbars.db.profile.target.textureName or "Blizzard" end,
                    set = function(_, val)
                        local LSM = LibStub("LibSharedMedia-3.0", true)
                        PlayersCastbars.db.profile.target.textureName = val
                        if LSM then PlayersCastbars.db.profile.target.texture = LSM:Fetch("statusbar", val) end
                        if PlayersCastbars.targetCastBar and PlayersCastbars.db.profile.target.texture then
                            PlayersCastbars.targetCastBar.status:SetStatusBarTexture(PlayersCastbars.db.profile.target.texture)
                        end
                    end,
                },
                width = {
                    type = "range", name = "Width", order = 5, min = 100, max = 600, step = 1,
                    get = function() return PlayersCastbars.db.profile.target.width or 220 end,
                    set = function(_, val)
                        PlayersCastbars.db.profile.target.width = val
                        if PlayersCastbars.targetCastBar then PlayersCastbars.targetCastBar:SetWidth(val) end
                    end,
                },
                height = {
                    type = "range", name = "Height", order = 6, min = 10, max = 60, step = 1,
                    get = function() return PlayersCastbars.db.profile.target.height or 18 end,
                    set = function(_, val)
                        PlayersCastbars.db.profile.target.height = val
                        if PlayersCastbars.targetCastBar then PlayersCastbars.targetCastBar:SetHeight(val) end
                    end,
                },
                iconSize = {
                    type = "range", name = "Icon Size", order = 7, min = 10, max = 60, step = 1,
                    get = function() return PlayersCastbars.db.profile.target.iconSize or 18 end,
                    set = function(_, val)
                        PlayersCastbars.db.profile.target.iconSize = val
                        if PlayersCastbars.targetCastBar and PlayersCastbars.targetCastBar.iconFrame then
                            PlayersCastbars.targetCastBar.iconFrame:SetSize(val, val)
                        end
                    end,
                },
                iconOffsetX = {
                    type = "range", name = "Icon X Offset", order = 8, min = -100, max = 100, step = 1,
                    get = function() return PlayersCastbars.db.profile.target.iconOffsetX or 0 end,
                    set = function(_, val)
                        PlayersCastbars.db.profile.target.iconOffsetX = val
                        if PlayersCastbars.targetCastBar and PlayersCastbars.targetCastBar.iconFrame then
                            local y = PlayersCastbars.db.profile.target.iconOffsetY or 0
                            PlayersCastbars.targetCastBar.iconFrame:ClearAllPoints()
                            PlayersCastbars.targetCastBar.iconFrame:SetPoint("RIGHT", PlayersCastbars.targetCastBar, "LEFT", -4 + val, y)
                        end
                    end,
                },
                iconOffsetY = {
                    type = "range", name = "Icon Y Offset", order = 9, min = -100, max = 100, step = 1,
                    get = function() return PlayersCastbars.db.profile.target.iconOffsetY or 0 end,
                    set = function(_, val)
                        PlayersCastbars.db.profile.target.iconOffsetY = val
                        if PlayersCastbars.targetCastBar and PlayersCastbars.targetCastBar.iconFrame then
                            local x = PlayersCastbars.db.profile.target.iconOffsetX or 0
                            PlayersCastbars.targetCastBar.iconFrame:ClearAllPoints()
                            PlayersCastbars.targetCastBar.iconFrame:SetPoint("RIGHT", PlayersCastbars.targetCastBar, "LEFT", -4 + x, val)
                        end
                    end,
                },
                textSize = {
                    type = "range", name = "Text Size", order = 10, min = 8, max = 32, step = 1,
                    get = function() return PlayersCastbars.db.profile.target.textSize or 12 end,
                    set = function(_, val)
                        PlayersCastbars.db.profile.target.textSize = val
                        if PlayersCastbars.targetCastBar then
                            local LSM = LibStub("LibSharedMedia-3.0", true)
                            local font = PlayersCastbars.db.profile.target.font
                                or (LSM and LSM:Fetch("font", PlayersCastbars.db.profile.target.fontName or (LSM.GetDefault and LSM:GetDefault("font"))))
                                or GameFontHighlightSmall:GetFont()
                            PlayersCastbars.targetCastBar.spellName:SetFont(font, val, "OUTLINE")
                            PlayersCastbars.targetCastBar.timeText:SetFont(font, val, "OUTLINE")
                        end
                    end,
                },
                fontName = {
                    type = "select", dialogControl = "LSM30_Font", name = "Font", order = 11,
                    values = function() local LSM = LibStub("LibSharedMedia-3.0", true); return LSM and LSM:HashTable("font") or {} end,
                    get = function()
                        local LSM = LibStub("LibSharedMedia-3.0", true)
                        return PlayersCastbars.db.profile.target.fontName or (LSM and LSM.GetDefault and LSM:GetDefault("font")) or ""
                    end,
                    set = function(_, val)
                        local LSM = LibStub("LibSharedMedia-3.0", true)
                        PlayersCastbars.db.profile.target.fontName = val
                        if LSM then PlayersCastbars.db.profile.target.font = LSM:Fetch("font", val) end
                        if PlayersCastbars.targetCastBar and PlayersCastbars.db.profile.target.font then
                            local size = PlayersCastbars.db.profile.target.textSize or 12
                            PlayersCastbars.targetCastBar.spellName:SetFont(PlayersCastbars.db.profile.target.font, size, "OUTLINE")
                            PlayersCastbars.targetCastBar.timeText:SetFont(PlayersCastbars.db.profile.target.font, size, "OUTLINE")
                        end
                    end,
                },
                offsetX = {
                    type = "range", name = "X Position", order = 12, min = -1000, max = 1000, step = 1,
                    get = function() return PlayersCastbars.db.profile.target.offsetX or 0 end,
                    set = function(_, val)
                        PlayersCastbars.db.profile.target.offsetX = val
                        if PlayersCastbars.targetCastBar then
                            local cfg = PlayersCastbars.db.profile.target
                            PlayersCastbars.targetCastBar:ClearAllPoints()
                            PlayersCastbars.targetCastBar:SetPoint(cfg.anchorPoint or "CENTER", UIParent, cfg.anchorPoint or "CENTER", val, cfg.offsetY or 0)
                        end
                    end,
                },
                offsetY = {
                    type = "range", name = "Y Position", order = 13, min = -1000, max = 1000, step = 1,
                    get = function() return PlayersCastbars.db.profile.target.offsetY or 0 end,
                    set = function(_, val)
                        PlayersCastbars.db.profile.target.offsetY = val
                        if PlayersCastbars.targetCastBar then
                            local cfg = PlayersCastbars.db.profile.target
                            PlayersCastbars.targetCastBar:ClearAllPoints()
                            PlayersCastbars.targetCastBar:SetPoint(cfg.anchorPoint or "CENTER", UIParent, cfg.anchorPoint or "CENTER", cfg.offsetX or 0, val)
                        end
                    end,
                },
                castNameOffsetX = {
                    type = "range", name = "Cast Name X Offset", order = 14, min = -200, max = 200, step = 1,
                    get = function() return PlayersCastbars.db.profile.target.castNameOffsetX or 0 end,
                    set = function(_, val)
                        PlayersCastbars.db.profile.target.castNameOffsetX = val
                        if PlayersCastbars.targetCastBar and PlayersCastbars.targetCastBar.spellName then
                            local y = PlayersCastbars.db.profile.target.castNameOffsetY or 0
                            PlayersCastbars.targetCastBar.spellName:ClearAllPoints()
                            PlayersCastbars.targetCastBar.spellName:SetPoint("LEFT", PlayersCastbars.targetCastBar.status, "LEFT", 4 + val, y)
                        end
                    end,
                },
                castNameOffsetY = {
                    type = "range", name = "Cast Name Y Offset", order = 15, min = -100, max = 100, step = 1,
                    get = function() return PlayersCastbars.db.profile.target.castNameOffsetY or 0 end,
                    set = function(_, val)
                        PlayersCastbars.db.profile.target.castNameOffsetY = val
                        if PlayersCastbars.targetCastBar and PlayersCastbars.targetCastBar.spellName then
                            local x = PlayersCastbars.db.profile.target.castNameOffsetX or 0
                            PlayersCastbars.targetCastBar.spellName:ClearAllPoints()
                            PlayersCastbars.targetCastBar.spellName:SetPoint("LEFT", PlayersCastbars.targetCastBar.status, "LEFT", 4 + x, val)
                        end
                    end,
                },
                showCastIcon = {
                    type = "toggle", name = "Show Icon", order = 16,
                    get = function() return PlayersCastbars.db.profile.target.showCastIcon ~= false end,
                    set = function(_, val)
                        PlayersCastbars.db.profile.target.showCastIcon = val
                        if PlayersCastbars.targetCastBar and PlayersCastbars.targetCastBar.iconFrame then
                            PlayersCastbars.targetCastBar.iconFrame:SetShown(val)
                        end
                    end,
                },
                hideDefaultBar = {
                    type = "toggle", name = "Hide Default Target Cast Bar", order = 17,
                    get = function() return PlayersCastbars.db.profile.target.hideDefaultBar ~= false end,
                    set = function(_, val)
                        PlayersCastbars.db.profile.target.hideDefaultBar = val
                        HideBlizzardTargetCastBar()
                    end,
                },
                blizzBarScale = {
                    type = "range", name = "Blizzard Bar Scale (hide = near 0)", order = 17, min = 0, max = 1, step = 0.01,
                    get = function() return PlayersCastbars.db.profile.target.blizzBarScale or 0.01 end,
                    set = function(_, val)
                        PlayersCastbars.db.profile.target.blizzBarScale = val
                        if PlayersCastbars.ApplyBlizzCastbarScale then PlayersCastbars:ApplyBlizzCastbarScale(val) end
                    end,
                },
                bgColor = {
                    type = "color", name = "Background Color", order = 18, hasAlpha = true,
                    get = function()
                        local c = PlayersCastbars.db.profile.target.bgColor or {0,0,0,1}
                        return c[1], c[2], c[3], c[4]
                    end,
                    set = function(_, r, g, b, a)
                        PlayersCastbars.db.profile.target.bgColor = {r,g,b,a}
                        if PlayersCastbars.targetCastBar and PlayersCastbars.targetCastBar.bg then
                            PlayersCastbars.targetCastBar.bg:SetColorTexture(r,g,b,a)
                        end
                    end,
                },
            },
        }
        -- Focus Cast Bar options group
        PlayersCastbars.optionsTable.args.focuscastbar = {
            type = "group",
            name = "Focus Cast Bar",
            order = 3,
            args = {
                previewbutton = {
                    type = "execute",
                    name = "Preview (click again to lock)",
                    order = 0.5,
                    width = "full",
                    func = function()
                        local FCB = _G.FocusCastBar
                        if not FCB then return end
                        if not FCB.focusPreviewActive then
                            FCB:ShowFocusPreviewCastBar()
                            local bar = FCB.castBar
                            if bar then
                                bar:EnableMouse(true); bar:SetMovable(true); bar:RegisterForDrag("LeftButton")
                                bar:SetScript("OnDragStart", function(s) s:StartMoving() end)
                                bar:SetScript("OnDragStop", function(s)
                                    s:StopMovingOrSizing()
                                    local point, _, _, x, y = s:GetPoint()
                                    local cfg = PlayersCastbars.db.profile.focus
                                    cfg.anchorPoint = point; cfg.offsetX = x; cfg.offsetY = y
                                end)
                            end
                        else
                            FCB:HideFocusPreviewCastBar()
                            local bar = FCB.castBar
                            if bar then
                                bar:EnableMouse(false); bar:SetMovable(false); bar:RegisterForDrag()
                                bar:SetScript("OnDragStart", nil); bar:SetScript("OnDragStop", nil)
                            end
                        end
                    end,
                },
                enabled = {
                    type = "toggle", name = "Enable", order = 1,
                    get = function() return PlayersCastbars.db.profile.focus.enabled ~= false end,
                    set = function(_, val)
                        PlayersCastbars.db.profile.focus.enabled = val
                        local FCB = _G.FocusCastBar
                        if FCB and FCB.castBar then
                            if val then FCB.castBar:Show() else FCB.castBar:Hide() end
                        end
                    end,
                },
                interruptibleColor = {
                    type = "color", name = "Interruptible Color", order = 2, hasAlpha = true,
                    get = function()
                        local c = PlayersCastbars.db.profile.focus.castBarColor or {0,1,0,1}
                        return c[1], c[2], c[3], c[4]
                    end,
                    set = function(_, r, g, b, a)
                        PlayersCastbars.db.profile.focus.castBarColor = {r,g,b,a}
                    end,
                },
                protectedColor = {
                    type = "color", name = "Protected Color", order = 3, hasAlpha = true,
                    get = function()
                        local c = PlayersCastbars.db.profile.focus.castBarProtectedColor or {1,0.5,0,1}
                        return c[1], c[2], c[3], c[4]
                    end,
                    set = function(_, r, g, b, a)
                        PlayersCastbars.db.profile.focus.castBarProtectedColor = {r,g,b,a}
                    end,
                },
                textureName = {
                    type = "select", dialogControl = "LSM30_Statusbar", name = "Texture", order = 4,
                    values = function() local LSM = LibStub("LibSharedMedia-3.0", true); return LSM and LSM:HashTable("statusbar") or {} end,
                    get = function() return PlayersCastbars.db.profile.focus.textureName or "Blizzard" end,
                    set = function(_, val)
                        local LSM = LibStub("LibSharedMedia-3.0", true)
                        PlayersCastbars.db.profile.focus.textureName = val
                        if LSM then PlayersCastbars.db.profile.focus.texture = LSM:Fetch("statusbar", val) end
                        local FCB = _G.FocusCastBar
                        if FCB and FCB.castBar and PlayersCastbars.db.profile.focus.texture then
                            FCB.castBar.status:SetStatusBarTexture(PlayersCastbars.db.profile.focus.texture)
                        end
                    end,
                },
                width = {
                    type = "range", name = "Width", order = 5, min = 100, max = 600, step = 1,
                    get = function() return PlayersCastbars.db.profile.focus.width or 220 end,
                    set = function(_, val)
                        PlayersCastbars.db.profile.focus.width = val
                        local FCB = _G.FocusCastBar
                        if FCB and FCB.castBar then FCB.castBar:SetWidth(val) end
                    end,
                },
                height = {
                    type = "range", name = "Height", order = 6, min = 10, max = 60, step = 1,
                    get = function() return PlayersCastbars.db.profile.focus.height or 18 end,
                    set = function(_, val)
                        PlayersCastbars.db.profile.focus.height = val
                        local FCB = _G.FocusCastBar
                        if FCB and FCB.castBar then FCB.castBar:SetHeight(val) end
                    end,
                },
                iconSize = {
                    type = "range", name = "Icon Size", order = 7, min = 10, max = 60, step = 1,
                    get = function() return PlayersCastbars.db.profile.focus.iconSize or 18 end,
                    set = function(_, val)
                        PlayersCastbars.db.profile.focus.iconSize = val
                        local FCB = _G.FocusCastBar
                        if FCB and FCB.castBar and FCB.castBar.iconFrame then
                            FCB.castBar.iconFrame:SetSize(val, val)
                        end
                    end,
                },
                iconOffsetX = {
                    type = "range", name = "Icon X Offset", order = 8, min = -100, max = 100, step = 1,
                    get = function() return PlayersCastbars.db.profile.focus.iconOffsetX or 0 end,
                    set = function(_, val)
                        PlayersCastbars.db.profile.focus.iconOffsetX = val
                        local FCB = _G.FocusCastBar
                        if FCB and FCB.castBar and FCB.castBar.iconFrame then
                            local y = PlayersCastbars.db.profile.focus.iconOffsetY or 0
                            FCB.castBar.iconFrame:ClearAllPoints()
                            FCB.castBar.iconFrame:SetPoint("RIGHT", FCB.castBar, "LEFT", -4 + val, y)
                        end
                    end,
                },
                iconOffsetY = {
                    type = "range", name = "Icon Y Offset", order = 9, min = -100, max = 100, step = 1,
                    get = function() return PlayersCastbars.db.profile.focus.iconOffsetY or 0 end,
                    set = function(_, val)
                        PlayersCastbars.db.profile.focus.iconOffsetY = val
                        local FCB = _G.FocusCastBar
                        if FCB and FCB.castBar and FCB.castBar.iconFrame then
                            local x = PlayersCastbars.db.profile.focus.iconOffsetX or 0
                            FCB.castBar.iconFrame:ClearAllPoints()
                            FCB.castBar.iconFrame:SetPoint("RIGHT", FCB.castBar, "LEFT", -4 + x, val)
                        end
                    end,
                },
                textSize = {
                    type = "range", name = "Text Size", order = 10, min = 8, max = 32, step = 1,
                    get = function() return PlayersCastbars.db.profile.focus.textSize or 12 end,
                    set = function(_, val)
                        PlayersCastbars.db.profile.focus.textSize = val
                        local FCB = _G.FocusCastBar
                        if FCB and FCB.castBar then
                            local LSM = LibStub("LibSharedMedia-3.0", true)
                            local font = PlayersCastbars.db.profile.focus.font
                                or (LSM and LSM:Fetch("font", PlayersCastbars.db.profile.focus.fontName or (LSM.GetDefault and LSM:GetDefault("font"))))
                                or GameFontHighlightSmall:GetFont()
                            FCB.castBar.spellName:SetFont(font, val, "OUTLINE")
                            FCB.castBar.timeText:SetFont(font, val, "OUTLINE")
                        end
                    end,
                },
                fontName = {
                    type = "select", dialogControl = "LSM30_Font", name = "Font", order = 11,
                    values = function() local LSM = LibStub("LibSharedMedia-3.0", true); return LSM and LSM:HashTable("font") or {} end,
                    get = function()
                        local LSM = LibStub("LibSharedMedia-3.0", true)
                        return PlayersCastbars.db.profile.focus.fontName or (LSM and LSM.GetDefault and LSM:GetDefault("font")) or ""
                    end,
                    set = function(_, val)
                        local LSM = LibStub("LibSharedMedia-3.0", true)
                        PlayersCastbars.db.profile.focus.fontName = val
                        if LSM then PlayersCastbars.db.profile.focus.font = LSM:Fetch("font", val) end
                        local FCB = _G.FocusCastBar
                        if FCB and FCB.castBar and PlayersCastbars.db.profile.focus.font then
                            local size = PlayersCastbars.db.profile.focus.textSize or 12
                            FCB.castBar.spellName:SetFont(PlayersCastbars.db.profile.focus.font, size, "OUTLINE")
                            FCB.castBar.timeText:SetFont(PlayersCastbars.db.profile.focus.font, size, "OUTLINE")
                        end
                    end,
                },
                offsetX = {
                    type = "range", name = "X Position", order = 12, min = -1000, max = 1000, step = 1,
                    get = function() return PlayersCastbars.db.profile.focus.offsetX or 0 end,
                    set = function(_, val)
                        PlayersCastbars.db.profile.focus.offsetX = val
                        local FCB = _G.FocusCastBar
                        if FCB and FCB.castBar then
                            local cfg = PlayersCastbars.db.profile.focus
                            FCB.castBar:ClearAllPoints()
                            FCB.castBar:SetPoint(cfg.anchorPoint or "CENTER", UIParent, cfg.anchorPoint or "CENTER", val, cfg.offsetY or 0)
                        end
                    end,
                },
                offsetY = {
                    type = "range", name = "Y Position", order = 13, min = -1000, max = 1000, step = 1,
                    get = function() return PlayersCastbars.db.profile.focus.offsetY or 0 end,
                    set = function(_, val)
                        PlayersCastbars.db.profile.focus.offsetY = val
                        local FCB = _G.FocusCastBar
                        if FCB and FCB.castBar then
                            local cfg = PlayersCastbars.db.profile.focus
                            FCB.castBar:ClearAllPoints()
                            FCB.castBar:SetPoint(cfg.anchorPoint or "CENTER", UIParent, cfg.anchorPoint or "CENTER", cfg.offsetX or 0, val)
                        end
                    end,
                },
                castNameOffsetX = {
                    type = "range", name = "Cast Name X Offset", order = 14, min = -200, max = 200, step = 1,
                    get = function() return PlayersCastbars.db.profile.focus.castNameOffsetX or 0 end,
                    set = function(_, val)
                        PlayersCastbars.db.profile.focus.castNameOffsetX = val
                        local FCB = _G.FocusCastBar
                        if FCB and FCB.castBar and FCB.castBar.spellName then
                            local y = PlayersCastbars.db.profile.focus.castNameOffsetY or 0
                            FCB.castBar.spellName:ClearAllPoints()
                            FCB.castBar.spellName:SetPoint("LEFT", FCB.castBar.status, "LEFT", 4 + val, y)
                        end
                    end,
                },
                castNameOffsetY = {
                    type = "range", name = "Cast Name Y Offset", order = 15, min = -100, max = 100, step = 1,
                    get = function() return PlayersCastbars.db.profile.focus.castNameOffsetY or 0 end,
                    set = function(_, val)
                        PlayersCastbars.db.profile.focus.castNameOffsetY = val
                        local FCB = _G.FocusCastBar
                        if FCB and FCB.castBar and FCB.castBar.spellName then
                            local x = PlayersCastbars.db.profile.focus.castNameOffsetX or 0
                            FCB.castBar.spellName:ClearAllPoints()
                            FCB.castBar.spellName:SetPoint("LEFT", FCB.castBar.status, "LEFT", 4 + x, val)
                        end
                    end,
                },
                showCastIcon = {
                    type = "toggle", name = "Show Icon", order = 16,
                    get = function() return PlayersCastbars.db.profile.focus.showCastIcon ~= false end,
                    set = function(_, val)
                        PlayersCastbars.db.profile.focus.showCastIcon = val
                        local FCB = _G.FocusCastBar
                        if FCB and FCB.castBar and FCB.castBar.iconFrame then
                            FCB.castBar.iconFrame:SetShown(val)
                        end
                    end,
                },
                hideDefaultBar = {
                    type = "toggle", name = "Hide Default Focus Cast Bar", order = 17,
                    get = function() return PlayersCastbars.db.profile.focus.hideDefaultBar ~= false end,
                    set = function(_, val)
                        PlayersCastbars.db.profile.focus.hideDefaultBar = val
                        HideBlizzardFocusCastBar()
                    end,
                },
                blizzBarScale = {
                    type = "range", name = "Blizzard Bar Scale (hide = near 0)", order = 17, min = 0, max = 1, step = 0.01,
                    get = function() return PlayersCastbars.db.profile.focus.blizzBarScale or 0.01 end,
                    set = function(_, val)
                        PlayersCastbars.db.profile.focus.blizzBarScale = val
                        local FCB = _G.FocusCastBar
                        if FCB and FCB.ApplyBlizzCastbarScale then FCB:ApplyBlizzCastbarScale(val) end
                    end,
                },
                bgColor = {
                    type = "color", name = "Background Color", order = 18, hasAlpha = true,
                    get = function()
                        local c = PlayersCastbars.db.profile.focus.bgColor or {0,0,0,1}
                        return c[1], c[2], c[3], c[4]
                    end,
                    set = function(_, r, g, b, a)
                        PlayersCastbars.db.profile.focus.bgColor = {r,g,b,a}
                        local FCB = _G.FocusCastBar
                        if FCB and FCB.castBar and FCB.castBar.bg then
                            FCB.castBar.bg:SetColorTexture(r,g,b,a)
                        end
                    end,
                },
            },
        }
        PlayersCastbars.optionsTable.args.profiles = AceDBOptions:GetOptionsTable(PlayersCastbars.db)
PlayersCastbars.optionsTable.args.profiles.order = 100

-- Add LibDualSpec support for profile options
local LibDualSpec = LibStub and LibStub("LibDualSpec-1.0", true)
if LibDualSpec then
    LibDualSpec:EnhanceOptions(PlayersCastbars.optionsTable.args.profiles, PlayersCastbars.db)
end

AceConfig:RegisterOptionsTable("PlayersCastbars", PlayersCastbars.optionsTable)
    end
    AceConfigDialog:Open("PlayersCastbars")

end-- Use this function for Essential sync mode to match the Edit Mode selection box:
local function GetEssentialWidthEditModeBox()
    local selectionBox = _G["EssentialCooldownViewer.Selection"]
    if selectionBox and selectionBox:IsShown() then
        return selectionBox:GetWidth()
    end
    return nil
end

-- Replace your current Essential sync width logic with:
-- width = GetEssentialWidthEditModeBox() or fallbackWidth

-- Use this function for Utility sync mode to match the Edit Mode selection box:
local function GetUtilityWidthEditModeBox()
    local selectionBox = _G["UtilityCooldownViewer.Selection"]
    if selectionBox and selectionBox:IsShown() then
        return selectionBox:GetWidth()
    end
    return nil
end

-- Replace your current Utility sync width logic with:
-- width = GetUtilityWidthEditModeBox() or fallbackWidth