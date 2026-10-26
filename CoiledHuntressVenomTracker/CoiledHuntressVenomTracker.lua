-- The Coiled Huntress Venom Tracker
-- Shows the current Venom/Toxin stack on "The Coiled Huntress" (item 244790)
-- and the Coiled Filament currency (id 3546) as a small movable text on
-- screen, since Blizzard only exposes the venom value inside the item
-- tooltip.

local ITEM_ID = 244790 -- The Coiled Huntress
local CURRENCY_ID = 3546 -- Coiled Filament
local MAX_INVENTORY_SLOT = 40

-- Keyword used to find the venom line in the tooltip, depends on client
-- locale. All entries below are confirmed via Wowhead item pages or
-- in-game /venom dump.
local LOCALE_KEYWORDS = {
    deDE = "Toxin",
    enUS = "Venom",
    enGB = "Venom",
    frFR = "venin",
    esES = "veneno",
    esMX = "Veneno",
    ruRU = "яд", -- lowercase; tooltip uses genitive "яда"
    itIT = "veleno",
    ptBR = "Peçonha",
    koKR = "맹독",
    zhCN = "毒液",
    zhTW = "毒液",
}
local LABEL = LOCALE_KEYWORDS[GetLocale()] or "Venom"

local PREFIX = "|cff33ff99Venom Tracker|r"
local ERROR_PREFIX = "|cffff0000Venom Tracker:|r"

NWVenomTrackerDB = NWVenomTrackerDB or {}
NWVenomTrackerDB.warnedLocaleMismatch = nil -- legacy key, the warning is per session now

-- ---------------------------------------------------------------------
-- UI
-- ---------------------------------------------------------------------

local frame = CreateFrame("Frame", "NWVenomTrackerFrame", UIParent, "BackdropTemplate")
frame:SetSize(160, 46)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetClampedToScreen(true)

frame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
frame:SetBackdropColor(0, 0, 0, 0.6)

local text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
text:SetPoint("TOP", 0, -8)
text:SetText(LABEL .. ": n/a")

local currencyText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
currencyText:SetPoint("BOTTOM", 0, 6)
currencyText:SetText("...")

local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
closeButton:SetSize(20, 20)
closeButton:SetPoint("TOPRIGHT", 2, 2)
closeButton:SetScript("OnClick", function()
    NWVenomTrackerDB.userHidden = true
    frame:Hide()
end)

frame:Hide() -- only shown while the item is actually equipped

-- ---------------------------------------------------------------------
-- ElvUI skin (optional, only applied if ElvUI is loaded)
-- ---------------------------------------------------------------------

local function ApplyElvUISkin()
    if not C_AddOns.IsAddOnLoaded("ElvUI") then
        return
    end

    local E = unpack(ElvUI)
    local S = E:GetModule("Skins")

    -- Replace the plain tooltip-style backdrop with ElvUI's own template
    -- so the frame matches the rest of the skinned UI.
    frame:SetTemplate("Transparent")
    S:HandleCloseButton(closeButton)
end

frame:SetScript("OnDragStart", function(self)
    if not NWVenomTrackerDB.locked then
        self:StartMoving()
    end
end)

frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Store position relative to UIParent only, ignore relativeTo frame
    -- to avoid saving a region name that may not exist on next login.
    local point, _, _, x, y = self:GetPoint()
    NWVenomTrackerDB.point = { point, x, y }
end)

local function ApplyPosition()
    local saved = NWVenomTrackerDB.point
    if saved then
        frame:ClearAllPoints()
        frame:SetPoint(saved[1], UIParent, saved[1], saved[2], saved[3])
    end
end

-- ---------------------------------------------------------------------
-- Venom scan
-- ---------------------------------------------------------------------

local MIN_WIDTH = 160
local PADDING = 24

local function FindItemSlot()
    for slot = 1, MAX_INVENTORY_SLOT do
        if GetInventoryItemID("player", slot) == ITEM_ID then
            return slot
        end
    end
    return nil
end

local function UpdateFrameWidth()
    local neededWidth = math.max(text:GetStringWidth(), currencyText:GetStringWidth()) + PADDING
    frame:SetWidth(math.max(MIN_WIDTH, neededWidth))
end

local function ScanCurrency()
    local info = C_CurrencyInfo.GetCurrencyInfo(CURRENCY_ID)
    if info then
        currencyText:SetText(info.name .. ": " .. info.quantity)
        UpdateFrameWidth()
    end
end

-- The tooltip is filled in lazily (sparse data, e.g. right after login), so
-- a missing keyword line is only reported once it stays missing for a while.
local MISMATCH_WARN_DELAY = 5
local warnedLocaleMismatch = false
local firstMismatchTime
local rodTooltipID -- dataInstanceID of the last rod tooltip, see TOOLTIP_DATA_UPDATE below

local function ScanVenom()
    rodTooltipID = nil
    -- No tooltip scanning in combat; PLAYER_REGEN_ENABLED re-scans afterwards.
    if InCombatLockdown() then
        return
    end

    local slot = FindItemSlot()
    if not slot or NWVenomTrackerDB.userHidden then
        firstMismatchTime = nil
        frame:Hide()
        return
    end

    frame:Show()

    local tooltipData = C_TooltipInfo.GetInventoryItem("player", slot)
    if not tooltipData then
        return
    end
    rodTooltipID = tooltipData.dataInstanceID

    for _, line in ipairs(tooltipData.lines) do
        local lineText = line.leftText
        if lineText and lineText:find(LABEL, 1, true) then
            local value = lineText:match("(%d+)")
            if value then
                firstMismatchTime = nil
                text:SetText(LABEL .. ": " .. value)
                UpdateFrameWidth()
                return
            end
        end
    end

    -- No line matched the locale keyword: this is NOT the same as "0
    -- venom". Showing "0" here would be misleading if the client locale's
    -- keyword is wrong, so surface it as unknown instead and warn once
    -- per session.
    text:SetText(LABEL .. ": n/a")
    UpdateFrameWidth()
    firstMismatchTime = firstMismatchTime or GetTime()
    if not warnedLocaleMismatch and GetTime() - firstMismatchTime >= MISMATCH_WARN_DELAY then
        warnedLocaleMismatch = true
        print(ERROR_PREFIX .. " couldn't find '" .. LABEL ..
            "' in the tooltip for locale " .. GetLocale() ..
            ". Run /venom dump and check LOCALE_KEYWORDS in the Lua file.")
    end
end

local function Refresh()
    ScanVenom()
    ScanCurrency()
end

-- Prints all tooltip lines of the equipped item to chat, used to find the
-- correct keyword for your client locale.
local function DumpTooltip()
    local slot = FindItemSlot()
    if not slot then
        print(ERROR_PREFIX .. " item not equipped.")
        return
    end
    local tooltipData = C_TooltipInfo.GetInventoryItem("player", slot)
    if not tooltipData then
        return
    end
    print(PREFIX .. " tooltip dump:")
    for i, line in ipairs(tooltipData.lines) do
        print(i .. ": " .. (line.leftText or ""))
    end
end

-- ---------------------------------------------------------------------
-- Events
-- ---------------------------------------------------------------------

local watcher = CreateFrame("Frame")
watcher:RegisterEvent("PLAYER_LOGIN")
watcher:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
watcher:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
watcher:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
watcher:RegisterEvent("PLAYER_REGEN_ENABLED")
watcher:RegisterEvent("TOOLTIP_DATA_UPDATE")

-- Tooltip data (C_TooltipInfo) can lag behind the actual value right
-- after an event fires (e.g. right after a catch), so a scan triggered
-- immediately can still show the previous number. The game reports the
-- refreshed data via TOOLTIP_DATA_UPDATE (payload: dataInstanceID of the
-- tooltip), so no fixed re-check timers are needed. RunNextFrame coalesces
-- event bursts into a single scan.
local scanQueued = false

local function QueueScan()
    if scanQueued then
        return
    end
    scanQueued = true
    RunNextFrame(function()
        scanQueued = false
        ScanVenom()
    end)
end

watcher:SetScript("OnEvent", function(_, event, arg)
    -- every spell the player casts lands here; only a catch with the rod
    -- equipped can change the venom value
    if event == "UNIT_SPELLCAST_SUCCEEDED" and not FindItemSlot() then
        return
    end

    if event == "PLAYER_LOGIN" then
        ApplyPosition()
        ApplyElvUISkin()
        Refresh()
    elseif event == "CURRENCY_DISPLAY_UPDATE" then
        ScanCurrency()
    elseif event == "TOOLTIP_DATA_UPDATE" then
        -- fires for every tooltip lookup in the game; only the rod's matters
        if rodTooltipID and arg == rodTooltipID then
            QueueScan()
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        Refresh()
    else
        ScanVenom()
        QueueScan()
        ScanCurrency()
    end
end)

-- ---------------------------------------------------------------------
-- Slash commands
-- ---------------------------------------------------------------------

SLASH_NWVENOM1 = "/venom"
SlashCmdList["NWVENOM"] = function(msg)
    msg = msg:lower():trim()
    if msg == "lock" then
        NWVenomTrackerDB.locked = true
        print(PREFIX .. ": locked.")
    elseif msg == "unlock" then
        NWVenomTrackerDB.locked = false
        print(PREFIX .. ": unlocked, drag to move.")
    elseif msg == "reset" then
        NWVenomTrackerDB.point = nil
        frame:ClearAllPoints()
        frame:SetPoint("CENTER")
        print(PREFIX .. ": position reset.")
    elseif msg == "dump" then
        DumpTooltip()
    elseif msg == "toggle" then
        NWVenomTrackerDB.userHidden = not NWVenomTrackerDB.userHidden
        if NWVenomTrackerDB.userHidden then
            frame:Hide()
            print(PREFIX .. ": hidden.")
        else
            Refresh()
            print(PREFIX .. ": shown.")
        end
    else
        Refresh()
        print(PREFIX .. ": /venom toggle | lock | unlock | reset | dump")
    end
end
