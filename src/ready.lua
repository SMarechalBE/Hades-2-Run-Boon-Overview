---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global


---`BoonInfoPopulateTraits` is called from `ShowBoonInfoScreen` it is responsible for populating the `screen.TraitList` content
---It uses screen.TraitSortOrder to populate screen.TraitList, so we hijack the value first then restore it afterwards to not leave crumbles
modutil.mod.Path.Wrap("BoonInfoPopulateTraits", function(base, screen)
	if screen.LootName ~= Melinoe.LootName then
		return base(screen)
	end

	screen.TraitSortOrder[Melinoe.LootName] = GetMelinoeTraits()
	local returnValue = base(screen)
	screen.TraitSortOrder[Melinoe.LootName] = nil

	return returnValue
end)


--Compute whether we should show or not the BoonOfferingButton for Melinoe
modutil.mod.Path.Wrap("UpdateCodexContextualAction", function(base, ...)
	UpdateCodexMelinoeBoonOfferingButton()
	return base(...)
end)

---Wrap SelectNearbyUnlockedEntry and set Melinoe as default codex entry for chtonic gods only if
---the base function has made any change and new chapter isn't chtonic gods.
modutil.mod.Path.Wrap("SelectNearbyUnlockedEntry", function (base, ...)
	local beforeSelectedChapter, beforeSelectedEntry = GetSelectedCodexElements()
	local returnValue = base(...)

	local afterSelectedChapter, afterSelectedEntry = GetSelectedCodexElements()
	if beforeSelectedChapter ~= afterSelectedChapter or beforeSelectedEntry ~= afterSelectedEntry then
		if afterSelectedChapter ~= Melinoe.CodexChapter then
			SetDefaultCodexEntry()
		end
	end

	return returnValue
end)

--Always set Melinoe Chapter and Entry as default in the Codex when entering a new room
modutil.mod.Path.Wrap("StartRoom", function (base, ...)
	SetDefaultCodexChapter()
	SetDefaultCodexEntry()
	return base(...)
end)

--When opening Codex Boon Info from offering page, force Melinoe's page instead only if the config flag is set
modutil.mod.Path.Wrap("AttemptOpenUpgradeChoiceBoonInfo", function (base, screen, button)
	if not config.openMelinoeBoonInfoInsteadOfGodDuringOffering then 
		return base(screen, button) 
	end
	
	local originalSourceName = screen and screen.Source and screen.Source.Name
	if not originalSourceName then
		return base(screen, button)
	end
	
	local sourceData = game.LootData and game.LootData[originalSourceName]
	if not sourceData or not sourceData.GodLoot then
		return base(screen, button)
	end

	screen.Source.Name = Melinoe.LootName
	local returnValue = base(screen, button)
	screen.Source.Name = originalSourceName

	return returnValue
end)
