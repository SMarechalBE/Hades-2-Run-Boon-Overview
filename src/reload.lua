---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

---Retrieve all boons from "slot" gods encountered this run.
---@param traitList table
---@return table
function GetGodPoolBoons(traitList)
	if not traitList or not game.LootData then return traitList end

	local godPool = game.GetInteractedGodsThisRun()
	if not godPool then return traitList end

	for _, god in ipairs(godPool) do
		if boonInfo.IsSlotGiver(god) then
			local godData = game.LootData[god]
			if godData then
				for traitName, _ in pairs(godData.TraitIndex) do
					table.insert(traitList, traitName)
				end
			end
		end
	end

	return traitList
end

---Reorder the traitList using TraitOrder
---@param traitList table
---@return table
function Reorder(traitList)
	table.sort(traitList, function (traitA, traitB)
		for _, traitName in ipairs(mod.TraitOrder) do
			if traitName == traitA then
				return true -- traitA < traitB
			elseif traitName == traitB then
				return false -- traitA > traitB
			end
		end
		return true -- We shouldn't get here
	end)

	return traitList
end

---Ensures the passed trait list is not empty.<br>
---If it is the case, then adds the best boon for safety reasons since the game crashes when it<br>
---tries to display an empty boon page.<br>
---Nonetheless, we should ideally try to prevent the user from opening the page if there's no<br>
---boon. For example, that could be controlled by not showing the trait button at all.
---@param traitList table
---@return table
function EnsureNotEmptyBoonList(traitList)
	if #traitList == 0 then
		table.insert(traitList, "RoomRewardBonusBoon")
	end

	return traitList
end

--- Filter out boons using the selected filtering method
--- TODO: Add filtering configurations, perhaps with buttons push
---@param traitList table
---@return table
function RemoveUnavailableBoons(traitList)
	local filteredList = {}
	for _, traitName in ipairs(traitList) do
		local state = boonInfo.GetBoonState(traitName)
		if state == boonInfo.BoonState.Available or state == boonInfo.BoonState.Unfulfilled then
			table.insert(filteredList, traitName)
		end
	end

	return filteredList
end

---TODO: Add pinned boons to the list
---@param traitList table
---@return table
function AddPinnedBoons(traitList)
	return traitList
end

---Dedupe traitList table
---TODO: perhaps it is not actually useful to dedupe, and we should instead build
---		 a lookup table directly with other functions. Meaning this would only convert
---		 it into a list instead.
---@param traitList table
---@return table
function Dedupe(traitList)
	-- Build a map using traits as keys to naturally dedupe
	local traitTable = {}
	for i=1, #traitList do
		traitTable[traitList[i]] = true
	end

	-- Reconstruct the list from the table
	local dedupedList = {}
	for traitName, _ in pairs(traitTable) do
		table.insert(dedupedList, traitName)
	end

	return dedupedList
end

---Wraps BoonInfoPopulateTraits: Constructs the boon info list for Melinoe
---@param screen table
function BoonInfoPopulateTraits_SetCurrentRunTraitList(screen)
	screen.TraitList = {}
	screen.TraitList = GetGodPoolBoons(screen.TraitList)
	screen.TraitList = RemoveUnavailableBoons(screen.TraitList)
	screen.TraitList = AddPinnedBoons(screen.TraitList)
	screen.TraitList = Dedupe(screen.TraitList)
	screen.TraitList = Reorder(screen.TraitList)
	screen.TraitList = EnsureNotEmptyBoonList(screen.TraitList)
end

---Wraps OpenCodexScreen: Add or remove traitDictionary["PlayerUnit"] (which controls boon offering button)
function OpenCodexScreen_UpdateMelinoeBoonOfferingButton()
	local traitDictionary = game.ScreenData and game.ScreenData.BoonInfo and game.ScreenData.BoonInfo.TraitDictionary
	if not traitDictionary then return end

	if not game.CurrentHubRoom then
		if traitDictionary["PlayerUnit"] then return end -- Avoid unnecessary checks

		local godPool = game.GetInteractedGodsThisRun()
		for _, god in ipairs(godPool) do
			if boonInfo.IsSlotGiver(god) then
				traitDictionary["PlayerUnit"] = {} -- Add button
				return
			end
		end
	end

	if traitDictionary["PlayerUnit"] then traitDictionary["PlayerUnit"] = nil end -- Remove button
end
