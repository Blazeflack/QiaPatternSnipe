-- Qia Pattern Snipe - World of Warcraft Addon

-- Cache global calls
local GetMerchantItemLink = GetMerchantItemLink
local BuyMerchantItem = BuyMerchantItem
local UnitName = UnitName
local CloseMerchant = CloseMerchant

-- Saved Variables
QiaPatternSnipeDB = QiaPatternSnipeDB or {
    autoScanEnabled = false,
    itemsToBuy = {
        ["Pattern: Runecloth Bag"] = true,
        ["Pattern: Runecloth Gloves"] = true,
        ["Pattern: Frostsaber Boots"] = false,
        ["Formula: Enchant Chest - Major Health"] = false
    }
}

-- Event Frame
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("MERCHANT_SHOW")

-- Options Frame
local optionsFrame = CreateFrame("Frame", "QiaPatternSnipeOptions", UIParent, "BasicFrameTemplateWithInset")
optionsFrame:SetSize(320, 220)
optionsFrame:SetPoint("CENTER")
optionsFrame:SetMovable(true)
optionsFrame:EnableMouse(true)
optionsFrame:RegisterForDrag("LeftButton")
optionsFrame:SetScript("OnDragStart", optionsFrame.StartMoving)
optionsFrame:SetScript("OnDragStop", optionsFrame.StopMovingOrSizing)
optionsFrame:Hide()

optionsFrame.title = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
optionsFrame.title:SetPoint("TOP", 0, -5)
optionsFrame.title:SetText("Qia Pattern Snipe Options")

local toggleButton = CreateFrame("Button", nil, optionsFrame, "UIPanelButtonTemplate")
toggleButton:SetSize(120, 30)
toggleButton:SetPoint("TOP", 0, -40)

toggleButton:SetScript("OnClick", function()
    QiaPatternSnipeDB.autoScanEnabled = not QiaPatternSnipeDB.autoScanEnabled
    toggleButton:SetText(QiaPatternSnipeDB.autoScanEnabled and "Enabled" or "Disabled")
    if QiaPatternSnipeDB.autoScanEnabled then
        print("|cff00ff00ENABLED|r: Qia Pattern Snipe auto-buy.")
    else
        print("|cffff0000DISABLED|r: Qia Pattern Snipe auto-buy.")
    end
end)

-- Event Handler
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == "QiaPatternSnipe" then
        C_Timer.After(2, function() print("Qia Pattern Snipe Loaded! Type /qia to open options.") end)
        toggleButton:SetText(QiaPatternSnipeDB.autoScanEnabled and "Enabled" or "Disabled")
    elseif event == "MERCHANT_SHOW" then
        local merchantName = UnitName("npc")
        if QiaPatternSnipeDB.autoScanEnabled and merchantName == "Qia" then
            for i = 30, 33 do
                local l = GetMerchantItemLink(i)
                if l then
                    local itemName = l:match("%[(.-)%]") -- Extract item name from link
                    if itemName and QiaPatternSnipeDB.itemsToBuy[itemName] then
                        BuyMerchantItem(i, 1)
                        print("Bought: " .. itemName)
                    end
                end
            end
            CloseMerchant()
        end
    end
end)

local checkboxes = {}
local function CreateCheckbox(label, itemKey, yOffset)
    local checkbox = CreateFrame("CheckButton", nil, optionsFrame, "UICheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", 20, yOffset)
    checkbox.text = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    checkbox.text:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
    checkbox.text:SetText(label)
    checkbox:SetChecked(QiaPatternSnipeDB.itemsToBuy[itemKey])
    checkbox:SetScript("OnClick", function(self)
        QiaPatternSnipeDB.itemsToBuy[itemKey] = self:GetChecked()
    end)
    checkboxes[itemKey] = checkbox
    return checkbox
end

CreateCheckbox("Pattern: Runecloth Bag", "Pattern: Runecloth Bag", -80)
CreateCheckbox("Pattern: Runecloth Gloves", "Pattern: Runecloth Gloves", -110)
CreateCheckbox("Pattern: Frostsaber Boots", "Pattern: Frostsaber Boots", -140)
CreateCheckbox("Formula: Enchant Chest - Major Health", "Formula: Enchant Chest - Major Health", -170)

-- Ensure checkboxes reflect saved variables when options frame is shown
optionsFrame:SetScript("OnShow", function()
    for itemKey, checkbox in pairs(checkboxes) do
        checkbox:SetChecked(QiaPatternSnipeDB.itemsToBuy[itemKey])
    end
end)

-- Slash Command to Open Options
SLASH_QIAPATTERNSNIPE1 = "/qia"
SlashCmdList["QIAPATTERNSNIPE"] = function()
    if optionsFrame:IsShown() then
        optionsFrame:Hide()
    else
        optionsFrame:Show()
    end
end
