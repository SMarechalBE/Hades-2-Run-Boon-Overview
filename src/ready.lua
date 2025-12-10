---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global


---`BoonInfoPopulateTraits` is called from `ShowBoonInfoScreen` it is responsible for populating the `screen.TraitList` content.<br>
---`ShowBoonInfoScreen` gets called from 2 sources:<br>
---	 1. During an "Upgrade Choice" screen<br>
---  2. From the Codex on its respective data<br>
---We're hooking on the BoonInfoPopulateTraits call and populating the data with the boons available to our run<br>
---TODO: Add Forget-me-not boons to the list<br>
---@param base any
---@param screen any
modutil.mod.Path.Wrap("BoonInfoPopulateTraits", function(base, screen)
	if screen and screen.LootName == "PlayerUnit" then
		BoonInfoPopulateTraits_SetCurrentRunTraitList(screen)
	else
		base(screen)
	end
end)

-- Forces the Boon button to appear for Melinoe
ScreenData.BoonInfo.TraitDictionary["PlayerUnit"] = {}

--[[
	Hard coded ordering for the Olympian boons, by type then by God
	  Type:
	    1. Slot
		  a. Weapon
		  b. Special
		  c. Cast
		  d. Sprint
		  e. Mana
		2. Non-slot
	    3. Infusion
		4. Legendary
		5. Duos
]]--
mod.TraitOrder = {
	-- Slots

	-- Weapon
	"ZeusWeaponBoon",
	"HeraWeaponBoon",
	"PoseidonWeaponBoon",
	"DemeterWeaponBoon",
	"ApolloWeaponBoon",
	"AphroditeWeaponBoon",
	"HephaestusWeaponBoon",
	"HestiaWeaponBoon",
	"AresWeaponBoon", 

	-- Special
	"ZeusSpecialBoon",
	"HeraSpecialBoon",
	"PoseidonSpecialBoon",
	"DemeterSpecialBoon",
	"ApolloSpecialBoon",
	"AphroditeSpecialBoon",
	"HephaestusSpecialBoon",
	"HestiaSpecialBoon",
	"AresSpecialBoon", 

	-- Cast
	"ZeusCastBoon",
	"HeraCastBoon",
	"PoseidonCastBoon",
	"DemeterCastBoon",
	"ApolloCastBoon",
	"AphroditeCastBoon",
	"HephaestusCastBoon",
	"HestiaCastBoon",
	"AresCastBoon", 

	-- Sprint
	"ZeusSprintBoon",
	"HeraSprintBoon",
	"PoseidonSprintBoon",
	"DemeterSprintBoon",
	"ApolloSprintBoon",
	"AphroditeSprintBoon",
	"HephaestusSprintBoon",
	"HestiaSprintBoon",
	"AresSprintBoon", 

	-- Mana
	"ZeusManaBoon",
	"HeraManaBoon",
	"PoseidonManaBoon",
	"DemeterManaBoon",
	"ApolloManaBoon",
	"AphroditeManaBoon",
	"HephaestusManaBoon",
	"HestiaManaBoon",
	"AresManaBoon",

	-- Non-Slot
	"ZeusManaBoltBoon",
	"BoltRetaliateBoon",
	"CastAnywhereBoon",
	"FocusLightningBoon",
	"DoubleBoltBoon",
	"EchoExpirationBoon",
	"LightningDebuffGeneratorBoon",
	"DamageShareRetaliateBoon",
	"LinkedDeathDamageBoon",
	"BoonDecayBoon",
	"DamageSharePotencyBoon",
	"SpawnCastDamageBoon",
	"CommonGlobalDamageBoon",
	"OmegaHeraProjectileBoon",
	"EncounterStartOffenseBuffBoon",
	"RoomRewardBonusBoon",
	"FocusDamageShaveBoon",
	"DoubleRewardBoon",
	"PoseidonStatusBoon",
	"PoseidonExCastBoon",
	"OmegaPoseidonProjectileBoon",
	"CastNovaBoon",
	"PlantHealthBoon",
	"BoonGrowthBoon",
	"ReserveManaHitShieldBoon",
	"SlowExAttackBoon",
	"CastAttachBoon",
	"RootDurationBoon",
	"ApolloRetaliateBoon",
	"PerfectDamageBonusBoon",
	"BlindChanceBoon",
	"ApolloBlindBoon",
	"ApolloExCastBoon",
	"ApolloCastAreaBoon",
	"DoubleStrikeChanceBoon",
	"HighHealthOffenseBoon",
	"HealthRewardBonusBoon",
	"DoorHealToFullBoon",
	"WeakPotencyBoon",
	"WeakVulnerabilityBoon",
	"ManaBurstBoon",
	"FocusRawDamageBoon",
	"MassiveDamageBoon",
	"AntiArmorBoon",
	"HeavyArmorBoon",
	"ArmorBoon",
	"EncounterStartDefenseBuffBoon",
	"ManaToHealthBoon",
	"MassiveKnockupBoon",
	"OmegaZeroBurnBoon",
	"CastProjectileBoon",
	"FireballManaSpecialBoon",
	"BurnExplodeBoon",
	"BurnArmorBoon",
	"BurnStackBoon",
	"AloneDamageBoon",
	"AresExCastBoon",
	"RendBloodDropBoon",
	"AresStatusDoubleDamageBoon",
	"BloodDropRevengeBoon",
	"MissingHealthCritBoon",
	"LowHealthLifestealBoon",
	"OmegaDelayedDamageBoon",

	-- Elemental
	"ElementalDamageFloorBoon",
	"ElementalRarityUpgradeBoon",
	"ElementalHealthBoon",
	"ElementalDamageCapBoon",
	"ElementalRallyBoon",
	"ElementalDodgeBoon",
	"ElementalDamageBoon",
	"ElementalBaseDamageBoon",
	"ElementalOlympianDamageBoon",

	-- Legendary
	"SpawnKillBoon",
	"AllElementalBoon",
	"AmplifyConeBoon",
	"InstantRootKill",
	"DoubleExManaBoon",
	"RandomStatusBoon",
	"WeaponUpgradeBoon",
	"BurnSprintBoon",
	"DoubleBloodDropBoon",

	-- Duos
	"SuperSacrificeBoonZeus",
	"LightningVulnerabilityBoon",
	"RootStrikeBoon",
	"ApolloSecondStageCastBoon",
	"SprintEchoBoon",
	"EchoBurnBoon",
	"ReboundingSparkBoon",
	"AutoRevengeBoon",
	"SuperSacrificeBoonHera",
	"MoneyDamageBoon",
	"KeepsakeLevelBoon",
	"RaiseDeadBoon",
	"ManaRestoreDamageBoon",
	"CharmCrowdBoon",
	"ManaShieldBoon",
	"BloodRetentionBoon",
	"GoodStuffBoon",
	"PoseidonSplashSprintBoon",
	"AllCloseBoon",
	"SteamBoon",
	"MassiveCastBoon",
	"DoubleSplashBoon",
	"StormSpawnBoon",
	"MaxHealthDamageBoon",
	"BurnConsumeBoon",
	"ClearRootBoon",
	"SelfCastBoon",
	"ManaBurstCountBoon",
	"CoverRegenerationBoon",
	"BlindClearBoon",
	"DoubleSwordBoon",
	"BurnRefreshBoon",
	"SlamManaBurstBoon",
	"BloodManaBurstBoon",
	"DoubleMassiveAttackBoon",
	"RapidSwordBoon",
	"ManaRestoreDamageBoon",
	"FireballRendBoon",
}
