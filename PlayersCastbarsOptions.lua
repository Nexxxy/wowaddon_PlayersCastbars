-- Inject custom AceGUI red preview button into AceConfig window
local AceGUI = LibStub("AceGUI-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")


local function InjectPreviewButton()
    local frame = AceConfigDialog and AceConfigDialog.OpenFrames and AceConfigDialog.OpenFrames["PlayersCastbars"]
    if frame and frame.frame and not frame.previewInjected then
        local btn = AceGUI:Create("Button")
        btn:SetText("")
        -- ...existing code for button setup...
    end
end

-- AceConfig options for Empower Cast colors
local function GetConfig()
    return PlayersCastbars and PlayersCastbars.db and PlayersCastbars.db.profile or nil
end

local empowerColorArgs = {
    header = {
        type = "header",
        name = "Empower Cast Colors",
        order = 10,
    },
}
for i = 1, 5 do
    empowerColorArgs["stage"..i] = {
        type = "color",
        name = "Stage "..i.." Tick",
        hasAlpha = true,
        get = function()
            local cfg = GetConfig()
            local c = cfg and cfg.empowerStageColors and cfg.empowerStageColors[i] or {1,1,1,1}
            return c[1], c[2], c[3], c[4]
        end,
        set = function(_, r, g, b, a)
            local cfg = GetConfig()
            if cfg and cfg.empowerStageColors then cfg.empowerStageColors[i] = {r, g, b, a} end
        end,
        order = 10 + i,
    }
    empowerColorArgs["seg"..i] = {
        type = "color",
        name = "Stage "..i.." Segment",
        hasAlpha = true,
        get = function()
            local cfg = GetConfig()
            local c = cfg and cfg.empowerSegColors and cfg.empowerSegColors[i] or {1,1,1,1}
            return c[1], c[2], c[3], c[4]
        end,
        set = function(_, r, g, b, a)
            local cfg = GetConfig()
            if cfg and cfg.empowerSegColors then cfg.empowerSegColors[i] = {r, g, b, a} end
        end,
        order = 20 + i,
    }
end

if AceConfig and AceConfigDialog then
    -- Register main options group with Empower Cast Colors included
    AceConfig:RegisterOptionsTable("PlayersCastbars", {
        type = "group",
        name = "PlayersCastbars",
        args = {
            desc = {
                type = "description",
                name = "PlayersCastbars main options.",
                order = 1,
            },
            customColor = {
                type = "color",
                name = "Gradient Start Color",
                hasAlpha = true,
                order = 8,
                get = function()
                    local cfg = GetConfig()
                    local c = cfg and cfg.customColor or {1,1,1,1}
                    return c[1], c[2], c[3], c[4]
                end,
                set = function(_, r, g, b, a)
                    local cfg = GetConfig()
                    if cfg then cfg.customColor = {r, g, b, a} end
                end,
            },
            customColor2 = {
                type = "color",
                name = "Gradient End Color",
                hasAlpha = true,
                order = 9,
                get = function()
                    local cfg = GetConfig()
                    local c = cfg and cfg.customColor2 or {1,1,1,1}
                    return c[1], c[2], c[3], c[4]
                end,
                set = function(_, r, g, b, a)
                    local cfg = GetConfig()
                    if cfg then cfg.customColor2 = {r, g, b, a} end
                end,
            },
            empowerColors = {
                type = "group",
                name = "Empower Cast Colors",
                inline = true,
                order = 10,
                args = empowerColorArgs,
            },
        },
    })
    AceConfigDialog:AddToBlizOptions("PlayersCastbars", "PlayersCastbars")

    -- Also register Empower Cast Colors as a child panel in Blizzard options
    AceConfig:RegisterOptionsTable("PlayersCastbars_EmpowerColors", {
        type = "group",
        name = "Empower Cast Colors",
        args = empowerColorArgs,
    })
    AceConfigDialog:AddToBlizOptions("PlayersCastbars_EmpowerColors", "Empower Cast Colors", "PlayersCastbars")
end



-- Options page removed; no registration
