---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

---TODO
---@param trait_list table
---@return table
function GetGodPoolBoons(trait_list)
	local god_pool = OrderedKeysToList( CurrentRun.LootTypeHistory )
	for _, god in ipairs(god_pool) do
		if boonInfo.IsSlotGiver(god) then
			local god_data = LootData[god]
			if god_data ~= nil then
				for traitName, _ in pairs(god_data.TraitIndex) do
					modutil.mod.Print(traitName)
					table.insert(trait_list, traitName)
				end
			end
		end
	end

	return trait_list
end

---TODO
---@param trait_list table
---@return table
function Reorder(trait_list)
	table.sort(trait_list, function (traitA, traitB)
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

	return trait_list
end

---Ensures the passed trait list is not empty.<br>
---If it is the case, then adds the best boon for safety reasons since the game crashes when it<br>
---tries to display an empty boon page.<br>
---Nonetheless, we should ideally try to prevent the user from opening the page if there's no<br>
---boon. For example, that could be controlled by not showing the trait button at all.
---@param trait_list table
---@return table
function EnsureNotEmptyBoonList(trait_list)
	if #trait_list == 0 then
		table.insert(trait_list, "RoomRewardBonusBoon")
	end

	return trait_list
end

---TODO
---@param trait_list table
---@return table
function RemoveUnavailableBoons(trait_list)
	local filtered_list = {}
	for _, trait_name in ipairs(trait_list) do
		local state = boonInfo.GetBoonState(trait_name)
		if state == boonInfo.BoonState.Available then
			table.insert(filtered_list, trait_name)
		end
	end

	return filtered_list
end

---TODO
---@param trait_list table
---@return table
function AddPinnedBoons(trait_list)
	return trait_list
end

---TODO
---@param trait_list table
---@return table
function Dedupe(trait_list)
	-- Build a map using traits as keys to naturally dedupe
	local trait_table = {}
	for i=1, #trait_list do
		trait_table[trait_list[i]] = true
	end

	-- Reconstruct the list from the table
	local deduped_list = {}
	for trait_name, _ in pairs(trait_table) do
		table.insert(deduped_list, trait_name)
	end

	return deduped_list
end

-- function DumpTraitList(traitList)
-- 	modutil.mod.Print("==Dump start")
-- 	for _, trait in ipairs(traitList) do
-- 		modutil.mod.Print(trait)
-- 	end
-- 	modutil.mod.Print("Dump end==")
-- end

---TODO
---@param screen table
function SetCurrentRunTraitList(screen)
	screen.TraitList = {}
	screen.TraitList = GetGodPoolBoons(screen.TraitList)
	-- modutil.mod.Print("GetGodPoolBoons:")
	-- DumpTraitList(screen.TraitList)
	screen.TraitList = RemoveUnavailableBoons(screen.TraitList)
	-- modutil.mod.Print("RemoveUnavailableBoons:")
	-- DumpTraitList(screen.TraitList)
	screen.TraitList = AddPinnedBoons(screen.TraitList)
	screen.TraitList = Dedupe(screen.TraitList)
	-- modutil.mod.Print("Dedupe:")
	-- DumpTraitList(screen.TraitList)
	screen.TraitList = Reorder(screen.TraitList)
	-- modutil.mod.Print("Reorder:")
	-- DumpTraitList(screen.TraitList)
	screen.TraitList = EnsureNotEmptyBoonList(screen.TraitList)
end
