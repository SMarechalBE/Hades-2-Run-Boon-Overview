---Build the god lookup table: traits + order
---We then use CodexOrdering to get a better ordering from predefined value
---@return table<string,table>
local function GodLootTable()
	if not game.LootData then return
		modutil.mod.Print("Error: can't access game.LootData")
		{}
	end

	local godLookup = {}
	local unorderedIdx = 100
	for god, data in pairs(game.LootData) do
		if data.GodLoot then
			local traits = {}
			local dataWeaponUpgrades = data.WeaponUpgrades or {}
			for _, weaponTrait in ipairs(dataWeaponUpgrades) do
				table.insert(traits, weaponTrait)
			end

			local dataTraits = data.Traits  or {}
			for _, trait in ipairs(dataTraits) do
				table.insert(traits, trait)
			end

			if #traits > 0 then
				godLookup[god] = {
					Traits = game.ShallowCopyTable(traits),
					Order = unorderedIdx
				}
				unorderedIdx = unorderedIdx + 1
			end
		end
	end

	local godsOrdering = game.CodexOrdering and game.CodexOrdering.OlympianGods
	if not godsOrdering then 
		modutil.mod.Print("Error: can't access game.CodexOrdering.OlympianGods")
		return godLookup
	end

	for i, god in ipairs(godsOrdering) do
		if godLookup[god] then
			godLookup[god].Order = i
		end
	end

	return godLookup
end

local TraitTypes =
{
	Other = "other",
	Infusion = "infusion",
	Legendary = "legendary",
	Duo = "duo"
}

---Construct dynamically a lookup order for types of boons
---	{slot1, slot2, slot3, ..., non-slot, infusion, legendary, duo}
---Any custom slot will be taken into consideration for ordering
---@return table<string,integer>
local function TraitTypeOrder()
	local slottedTraitOrder = game.ScreenData and game.ScreenData.HUD and game.ScreenData.HUD.SlottedTraitOrder
	if not slottedTraitOrder then
		modutil.mod.Print("Error: can't access game.ScreenData.HUD.SlottedTraitOrder")
		return {}
	end

	local typesLookup = {}
	local idx = 1
	for _, slot in ipairs(slottedTraitOrder) do
		typesLookup[slot] = idx
		idx = idx + 1
	end

	for _, slot in pairs({TraitTypes.Other,
                          TraitTypes.Infusion,
                          TraitTypes.Legendary,
                          TraitTypes.Duo}) do
		typesLookup[slot] = idx
		idx = idx + 1
	end

	return typesLookup
end

---Get the slot name for the given trait if applicable
---@param traitName string
---@return string?
local function GetSlot(traitName)
	if not game.TraitData then
		modutil.mod.Print("Error: can't access game.TraitData")
		return
	end

	return game.TraitData[traitName] and game.TraitData[traitName].Slot
end

---Verify if trait is an infusion
---@param traitName string
---@return boolean
local function IsInfusion(traitName)
	local elementalBoons = game.GameData and game.GameData.AllElementalBoons
	if not elementalBoons then 
		modutil.mod.Print("Error: can't access game.GameData.AllElementalBoons")
		return false
	end

	return game.Contains(elementalBoons, traitName)
end

---Verify if trait is legendary
---@param traitName string
---@return boolean
local function IsLegendary(traitName)
	local legendaryBoons = game.GameData and game.GameData.AllLegendaryBoons
	if not legendaryBoons then 
		modutil.mod.Print("Error: can't access game.GameData.AllLegendaryBoons")
		return false
	end

	return game.Contains(legendaryBoons, traitName)
end

---Verify if trait is a duo
---@param traitName any
---@return boolean
local function IsDuo(traitName)
	local duoBoons = game.GameData and game.GameData.AllDuoBoons
	if not duoBoons then 
		modutil.mod.Print("Error: can't access game.GameData.AllDuoBoons")
		return false
	end

	return game.Contains(duoBoons, traitName)
end

---Get the trait type of the given trait
---@param traitName string
---@return string
local function GetTraitType(traitName)
	return GetSlot(traitName)
		or (IsInfusion(traitName) and TraitTypes.Infusion)
		or (IsLegendary(traitName) and TraitTypes.Legendary)
		or (IsDuo(traitName) and TraitTypes.Duo)
		or TraitTypes.Other
end

local function CreateTraitOrder(godOrder, slotOrder)
    return {
        Slot = slotOrder,
        PrimaryGod = godOrder,
        SecondaryGod = 99
    }
end

local function UpdateTraitOrder(traitOrder, godOrder)
    if godOrder < traitOrder.PrimaryGod then
        traitOrder.SecondaryGod = traitOrder.PrimaryGod
        traitOrder.PrimaryGod = godOrder
    else
        traitOrder.SecondaryGod = godOrder
    end
end


function GetTraitOrderLookup()
    local traitTypeOrder = TraitTypeOrder()
    local traitOrderLookup = {}
    for _, godData in pairs(GodLootTable()) do
        for _, traitName in ipairs(godData.Traits) do
            if not traitOrderLookup[traitName] then
                traitOrderLookup[traitName] = CreateTraitOrder(godData.Order, traitTypeOrder[GetTraitType(traitName)] or 99)
            else
                UpdateTraitOrder(traitOrderLookup[traitName], godData.Order)
            end
        end
    end

    return traitOrderLookup
end
