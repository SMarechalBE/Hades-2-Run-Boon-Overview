---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

Melinoe =
{
	LootName = "PlayerUnit",
	CodexChapter = "ChthonicGods"
}

---Retrieve all boons from GodLoot type gods that were encountered this run into a lookup table for naturally handling dupe values.
---@param traitLookup table<string,boolean>?
---@return table<string,boolean> traitLookup
function GetGodPoolBoonsLookup(traitLookup)
	traitLookup = traitLookup or {}

	if game.CurrentHubRoom then return traitLookup end

	local lootData = game.LootData
	if not lootData then return traitLookup end

	local godPool = game.GetInteractedGodsThisRun()
	if not godPool then return traitLookup end

	for _, god in ipairs(godPool) do
		local godData = lootData[god]
		if godData and godData.GodLoot and godData.TraitIndex then
			for traitName, _ in pairs(godData.TraitIndex) do
				traitLookup[traitName] = true
			end
		end
	end

	return traitLookup
end

---Reorder the traitList using TraitOrderLookup
---@param traitList table<integer,string>
---@param traitOrder table<string,table>
---@return table<integer,string>
function Reorder(traitList, traitOrder)
	table.sort(traitList, function (traitA, traitB)
		local orderA = traitOrder[traitA]
		if not orderA then
			modutil.mod.Print("Can't find ordering for "..traitA)
			return false
		end

		local orderB = traitOrder[traitB]
		if not orderB then
			modutil.mod.Print("Can't find ordering for "..traitB)
			return true
		end

		if orderA.Slot ~= orderB.Slot then
			return orderA.Slot < orderB.Slot
		end

		if orderA.PrimaryGod ~= orderB.PrimaryGod then
			return orderA.PrimaryGod < orderB.PrimaryGod
		end
		
		return orderA.SecondaryGod < orderB.SecondaryGod
	end)

	return traitList
end

---Ensures the passed trait list is not empty.
---This is only done for safety purposes as the button appears only if there are boons to display 
---@param traitList table
---@return table
function EnsureNotEmptyBoonList(traitList)
	if #traitList == 0 then
		table.insert(traitList, "RoomRewardBonusBoon")
	end

	return traitList
end

---Get pinned boons
---@param traitLookup table<string,boolean>
---@return table<string,boolean> traitLookup
function GetPinnedBoonsLookup(traitLookup)
	traitLookup = traitLookup or {}

	local storeItemPins = game.GameState and game.GameState.StoreItemPins
	if not storeItemPins then return traitLookup end

	for _, pin in ipairs( storeItemPins ) do
		if pin.StoreName == "TraitData" then
			traitLookup[pin.Name] = true
		end
	end

	return traitLookup
end

local TraitOrderLookup = GetTraitOrderLookup()

---Constructs the ordered boon list for Melinoe
---@return table<string> boons
function GetMelinoeTraits()
	local traitList = game.KeysToList(GetPinnedBoonsLookup(GetGodPoolBoonsLookup()))
	return EnsureNotEmptyBoonList(Reorder(traitList, TraitOrderLookup))
end

---Add or remove Melinoe from traitDictionary to control the boon offering button presence in the Codex
function UpdateCodexMelinoeBoonOfferingButton()
	local traitDictionary = game.ScreenData and game.ScreenData.BoonInfo and game.ScreenData.BoonInfo.TraitDictionary
	if not traitDictionary then return end

	traitDictionary[Melinoe.LootName] = (game.TableLength(GetPinnedBoonsLookup(GetGodPoolBoonsLookup())) > 0) and {} or nil
end

---Set Chtonic gods chapter as selected
function SetDefaultCodexChapter()
	if not game.CodexStatus.Enabled then
		return
	end

	game.CodexStatus.SelectedChapterName = Melinoe.CodexChapter
end

---Set Melinoe entry as selected entry in Chtonic gods chapter
function SetDefaultCodexEntry()
	if not game.CodexStatus.Enabled then
		return
	end

	if game.CodexStatus.SelectedEntryNames == nil then
		game.CodexStatus.SelectedEntryNames = {}
	end
	game.CodexStatus.SelectedEntryNames[Melinoe.CodexChapter] = Melinoe.LootName
end

---Retrieve selected codex chapter and entry
---@return string selectedChapterName Chapter name
---@return string selectedEntryName Entry name
function GetSelectedCodexElements()
	local selectedChapterName = game.CodexStatus.SelectedChapterName
	local selectedEntryName = game.CodexStatus.SelectedEntryNames and game.CodexStatus.SelectedEntryNames[selectedChapterName] or ""
	return selectedChapterName, selectedEntryName
end
