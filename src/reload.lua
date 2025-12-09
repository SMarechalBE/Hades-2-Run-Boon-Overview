---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

---TODO
---@param traitList table
---@return table
function GetGodPoolBoons(traitList)
	local godPool = OrderedKeysToList( CurrentRun.LootTypeHistory )
	for _, god in ipairs(godPool) do
		if boonInfo.IsSlotGiver(god) then
			local godData = LootData[god]
			if godData ~= nil then
				for traitName, _ in pairs(godData.TraitIndex) do
					modutil.mod.Print(traitName)
					table.insert(traitList, traitName)
				end
			end
		end
	end

	return traitList
end

---TODO
---@param traitList table
---@return table
function Reorder(traitList)
	table.sort(traitList, function (traitA, traitB)
		local foundA = false
		local foundB = false
		local indexA = 1000
		local indexB = 1000
		for index, traitName in ipairs(mod.TraitOrder) do
			if not foundA and traitName == traitA then
				foundA = true
				indexA = index
			end
			
			if not foundB and traitName == traitB then
				foundB = true
				indexB = index
			end
			
			if(foundA and foundB) then
				break
			end
		end

		return indexA < indexB
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

---TODO
---@param traitList table
---@return table
function RemoveUnavailableBoons(traitList)
	local filteredList = {}
	for _, traitName in ipairs(traitList) do
		local state = boonInfo.GetBoonState(traitName)
		if state == boonInfo.BoonState.Available then
			table.insert(filteredList, traitName)
		end
	end

	return filteredList
end

---TODO
---@param traitList table
---@return table
function AddPinnedBoons(traitList)
	return traitList
end

---TODO
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

---TODO
---@param screen table
function SetCurrentRunTraitList(screen)
	screen.TraitList = {}
	screen.TraitList = GetGodPoolBoons(screen.TraitList)
	screen.TraitList = RemoveUnavailableBoons(screen.TraitList)
	screen.TraitList = AddPinnedBoons(screen.TraitList)
	screen.TraitList = Dedupe(screen.TraitList)
	screen.TraitList = Reorder(screen.TraitList)
	screen.TraitList = EnsureNotEmptyBoonList(screen.TraitList)
end
