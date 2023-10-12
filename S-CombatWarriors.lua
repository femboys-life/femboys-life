if gamesList[game.GameId] == "Combat Warriors" then
	--// Esp & Long string
	local LongString = 'F'
	local Esp = loadstring(game:HttpGet("https://kiriot22.com/releases/ESP.lua"))()
	local SimplePath = loadstring(game:HttpGet("https://raw.githubusercontent.com/wicked-wlzard/simplepath/main/src/SimplePath.lua"))()
	local Path = nil

	local ShootSoundTable = {}
	local OldSounds = {}
	
	local Melee = game.ReplicatedStorage.Shared.Assets.Melee
	local Ranged = ReplicatedStorage.Shared.Assets.Ranged

	OldSounds["Mace"] = { Melee.Mace.Sounds.Hits["1"].SoundId, Melee.Mace.Sounds.Hits["2"].SoundId }
	OldSounds["Humanoid"] = Ranged.Sounds.MaterialsHit.Humanoid.SoundId
	OldSounds["HeavyBow"] = Ranged.Longbow.Sounds.Fire.SoundId
	OldSounds["Killsound"] = Ranged.Parent.Sounds.KillSound.SoundId
	OldSounds["IronSword"] = { Melee.IronSword.Sounds.Hits["1"].SoundId, Melee.IronSword.Sounds.Hits["2"].SoundId }

	for _,v in pairs(Ranged:GetChildren()) do
		local Sounds = v:FindFirstChild("Sounds")
		local Fire = Sounds and Sounds:FindFirstChild("Fire")

		if Fire then
			OldSounds[v.Name] = Fire.SoundId
		end
	end

	table.foreach(listfiles(SoundsFolder), function(Index, FileName)
		local Split = string.split(FileName, "samuelhook\\sounds\\")
		local Split2 = string.split(Split[2], ".")
		
		if table.find(Split2, "mp3") or table.find(Split2, "wav") then
			local Split3 = string.split(Split2[1], "-")

			if string.find(FileName, "Shoot") then ShootSoundTable[Split3[1]] = LoadSound(Split[2]) end
		end
	end)

	--// Main tabs
	local CombatTab = Window:AddTab("Combat")
	local LeftCombatTab = CombatTab:AddLeftTabbox()
	local LeftCombatTab2 = CombatTab:AddLeftTabbox()
	local RightCombatTab = CombatTab:AddRightTabbox()

	local MiscTab = Window:AddTab("Miscellaneous")
	local LeftMiscTab = MiscTab:AddLeftTabbox()
	local LeftMiscTab2 = MiscTab:AddLeftTabbox()
	local RightMiscTab = MiscTab:AddRightTabbox()

	--// Game modules
	local Network = nil
	local Nevermore  = require(ReplicatedStorage.Framework:WaitForChild("Nevermore"))

	for _,v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "__index") then
            local Index = v.__index
            
            if typeof(Index) == "function" and islclosure(Index) and not is_synapse_function(Index) then
                local Constants = getconstants(Index)
                if table.find(Constants, "BAC") then
                    Network = getupvalue(Index, 1)
                end
            end
        end
    end

	SetThread(2)
	local DataHandler = Nevermore("DataHandler")
	local StaminaHandler = Nevermore("DefaultStaminaHandlerClient")
	local AntiCheatHandler = Nevermore("AntiCheatHandler")
	
	local MeleeClient = Nevermore("MeleeWeaponClient")
	local JumpConstants = Nevermore("JumpConstants")
	local RagdollHandler = Nevermore("RagdollHandlerClient")
	
	local NumberUtil = Nevermore("NumberUtil")
	local EmoteMetadata = Nevermore("EmotesMetadata")
	local WeaponMetadata = Nevermore("WeaponMetadata")

	local RoduxStore = Nevermore("RoduxStore")
	local SoundHandler = Nevermore("SoundHandler")
	local DashConstants = Nevermore("DashConstants")

	local FastCast = Nevermore("FastCast")
	local RangedHandler = Nevermore("RangedWeaponHandler")
	local UtilityMetadata = Nevermore("UtilityMetadata")

	local RagdollUtil = Nevermore("RagdollUtil")
	local KnockbackHandler = Nevermore("KnockbackHandler")
	local RaycastUtilClient = Nevermore("RaycastUtilClient")

	local DamageConstants = Nevermore("DamageConstants")
	local KillStreakConfigs = Nevermore("KillStreakConfigs")
	local FinishConstants = Nevermore("FinishConstants")

	local GloryKillConstants = Nevermore("GloryKillConstants")
	SetThread(7)
	--// End of game modules

	--// Hooks anti-cheat punisher
	hookfunc(AntiCheatHandler.punish, function()
		return Instance.new("BindableEvent").Event:Wait()
	end)

	--// Hooks stupid FindService detection
	hookfunc(getrenv().game.FindService, function()
		return nil
	end)

	--// Hooks stupid NC shit
	for _,v in pairs(getgc()) do
		if typeof(v) == "function" and getinfo(v).name == "calculateMem" then
			hookfunc(v, function() return Instance.new("BindableEvent").Event:Wait() end)
		end
	end

	--// PolyLine for Arrow trajectory
	local PolyLine = PolyLineDynamic.new() 
	PolyLine.Color = Color3.new(1, 1, 1)
	PolyLine.Opacity = 1
	PolyLine.Outlined = true
	PolyLine.Thickness = 1.5
	PolyLine.OutlineColor = Color3.fromRGB(1, 1, 1)
	PolyLine.OutlineOpacity = 1

	--// Grab MainCaster
	local MainCaster = nil
	task.spawn(function()
        repeat wait()
        until Player.PlayerGui and Player.PlayerGui:FindFirstChild'RoactUI' and not Player.PlayerGui.RoactUI:FindFirstChild'MainMenu'
        
        for i,v in pairs(getgc(true)) do
            if (typeof(v) == 'table' and rawget(v, 'mainCasterBehavior') and rawget(v, 'tool') and rawget(v, 'handle')) then
                MainCaster = v;
            end
        end;
    end)

	local VirtualInputManager = game:GetService("VirtualInputManager")
	local AimSettings = LeftCombatTab:AddTab("Aim settings") do
		AimSettings:AddToggle("SilentAim", { Text = "Silent aim", Tooltip = "Redirects arrows to the nearest player to your fov" }):AddColorPicker("FovColor", { Default = Color3.new(1, 1, 1) })
		AimSettings:AddToggle("Wallbang", { Text = "Wallbang", Tooltip = "Lets arrows go through walls" })
		AimSettings:AddToggle("VisibilityCheck", { Text = "Visibility check", Tooltip = "Checks if player is visible if not it won't select them" })

		AimSettings:AddDivider()
		AimSettings:AddSlider("Hitchance", { Text = "Hitchance", Default = 1, Min = 1, Max = 100, Rounding = 0 })
		AimSettings:AddSlider("FovSides", { Text = "Fov sides", Default = 1, Min = 1, Max = 100, Rounding = 1 })
		AimSettings:AddSlider("FovSize", { Text = "Field of view", Default = 1, Min = 1, Max = 5000, Rounding = 0 })

		AimSettings:AddDivider()
		AimSettings:AddSlider("FovTransparency", { Text = "Fov transparency", Default = 1, Min = 0, Max = 1, Rounding = 1 })
		AimSettings:AddDropdown("Hitbox", { Text = "Hitbox", Default = 1, Values = { "Head", "HumanoidRootPart", "Left Arm", "Right Arm", "Left Leg", "Right Leg" } })
		AimSettings:AddDropdown("AimMode", { Text = "Aim mode", Default = 1, Values = { "Legit", "Rage" } })
	end

	local BowMods = LeftCombatTab2:AddTab("Bow mods") do
		BowMods:AddToggle("NoRecoil", { Text = "No recoil", Tooltip = "Makes your bow have 0 recoil" })
		BowMods:AddToggle("NoSpread", { Text = "No spread", Tooltip = "Makes your bow have 0 spread" })
		BowMods:AddToggle("NoDropoff", { Text = "No dropoff", Tooltip = "Gives your bow 0 dropoff" })

		BowMods:AddDivider()
		BowMods:AddToggle("InfiniteRange", { Text = "Infinite range", Tooltip = "Gives your bow the ability to shoot very far" })
		BowMods:AddToggle("InstantCharge", { Text = "Instant charge", Tooltip = "Instead of having to cock back bow it'll let you fire with no delay" })
		BowMods:AddToggle("NoReloadCancel", { Text = "No reload cancel", Tooltip = "Doesn't cancel reloads after you click" })
	end

	local BowMods2 = LeftCombatTab2:AddTab("Bow mods 2") do
		BowMods2:AddToggle("AlwaysHeadshot", { Text = "Always headshot", Tooltip = "Makes your bow always headshot no matter where you hit" })
		BowMods2:AddToggle("NoReloadSlowdown", { Text = "No reload slowdown", Tooltip = "Lets you walk normal speed when reloading" })
	end

	local Combat = RightCombatTab:AddTab("Combat") do
		Combat:AddToggle("Ragebot", { Text = "Ragebot", Tooltip = "(PROJECTILES ONLY NOT RPG THO) Will shoot your projectiles automatically very blantant and hit players" })
		Combat:AddToggle("KillAura", { Text = "Killaura", Tooltip = "Hits near players whenever you have a melee out" })
		Combat:AddToggle("AutoParry", { Text = "Auto parry", Tooltip = "Automatically parries near players whom are swinging" }):AddKeyPicker("AutoParryBind", { Text = "Autoparry", Default = "None" })
		Combat:AddToggle("SkillAura", { Text = "Skillaura", Tooltip = "Uses your skills endlessly to easily kill players" })
		--Combat:AddToggle("InfiniteMeleeRange", { Text = "Infinite melee range", Tooltip = "Lets you cross map hit people with melees (you need killaura on)" })
		
		Combat:AddSlider("AuraRange", { Text = "Aura range", Default = 1, Min = 1, Max = 12, Rounding = 0 })
		Combat:AddSlider("ParryRange", { Text = "Parry range", Default = 1, Min = 1, Max = 25, Rounding = 0 })
		Combat:AddSlider("ParryChance", { Text = "Parry chance", Default = 1, Min = 1, Max = 100, Rounding = 0 })

		Combat:AddDivider()
		Combat:AddToggle("FakeSwing", { Text = "Fake swing", Tooltip = "Will play swing animation to trick people trying to parry" })
		Combat:AddToggle("AutoGlory", { Text = "Auto glory", Tooltip = "Automatically glory kills near players" })
		Combat:AddToggle("WhitelistFriends", { Text = "Whitelist friends", Tooltip = "Whitelists roblox friends from combat features" })

		Combat:AddDivider()
		Combat:AddToggle("AntiHead", { Text = "Antihead", Tooltip = "Makes you have no head on the server" })
		Combat:AddToggle("HeadExpander", { Text = "Head expander", Tooltip = "Makes all players head bigger" })
		Combat:AddToggle("RangeExpander", { Text = "Range expander", Tooltip = "Basically a silent aim for melees" })
		Combat:AddSlider("HeadAmount", { Text = "Head amount", Default = 1, Min = 1, Max = 6, Rounding = 0 })
		Combat:AddSlider("RangeAmount", { Text = "Expander amount", Default = 1, Min = 1, Max = 30, Rounding = 0 })

		Combat:AddDivider()
		Combat:AddDropdown("ParryMode", { Text = "Parry mode", Default = 1, Values = { "Legit", "Rage" } })
		Combat:AddDropdown("AimPriority", { Text = "Aim priority", Default = 1, Values = { "Closest", "Lowest health" } })

		Toggles.HeadExpander:OnChanged(function(state)
			if not state then
				for _,v in pairs(Players:GetPlayers()) do
					local Target = v.Character
					local Head = Target and Target:FindFirstChild("Head")

					if Head then
						Head.Size = Vector3.new(1.2000000476837, 1, 1)
						Head.Transparency = 0
					end
				end
			end
		end)
	end

	local VisualTab = LeftMiscTab:AddTab("Visuals") do
		VisualTab:AddToggle("Esp", { Text = "Esp" }):AddColorPicker("EspColor", { Default = Color3.new(1, 1, 1) })
		VisualTab:AddToggle("EspBox", { Text = "Boxes" }):AddKeyPicker("EspBind", { Text = "Esp", Default = "None" })
		VisualTab:AddToggle("EspName", { Text = "Names" })

		VisualTab:AddDivider()
		VisualTab:AddToggle("EspTracer", { Text = "Tracers" })
		VisualTab:AddToggle("EspDistance", { Text = "Distance" })
		VisualTab:AddToggle("EspFaceCamera", { Text = "Face camera" })

		VisualTab:AddDivider()
		VisualTab:AddToggle("EspHighlight", { Text = "Highlight enemy" }):AddColorPicker("HighlightColor", { Default = Color3.new(1, 1, 1) })

		Toggles.Esp:OnChanged(function(State) Esp:Toggle(State) end)
		Toggles.EspBox:OnChanged(function(State) Esp.Boxes = State end)
		Toggles.EspName:OnChanged(function(State) Esp.Names = State end)

		Toggles.EspTracer:OnChanged(function(State) Esp.Tracers = State  end)
		Toggles.EspDistance:OnChanged(function(State) Esp.Distance = State end)
		Toggles.EspFaceCamera:OnChanged(function(State) Esp.FaceCamera = State end)

		Toggles.EspHighlight:OnChanged(function(State) end)
		Options.EspColor:OnChanged(function() Esp.Color = Options.EspColor.Value end)
	end

	local VisualTab2 = LeftMiscTab:AddTab("More Visuals") do
		VisualTab2:AddToggle("ArrowBeam", { Text = "Arrow beam" }):AddColorPicker("BeamStartColor", { Default = Color3.new(1, 1, 1) }):AddColorPicker("BeamEndColor", { Default = Color3.new(1, 1, 1) })
		VisualTab2:AddToggle("ArrowTrajectory", { Text = "Arrow trajectory" }):AddColorPicker("TrajectoryColor", { Default = Color3.new(1, 1, 1) })

		Options.TrajectoryColor:OnChanged(function(State)
			PolyLine.Color = State
		end)
	end

	local MiscTab = RightMiscTab:AddTab("Miscellaneous") do
		MiscTab:AddToggle("InfiniteAir", { Text = "Infinite air", Tooltip = "Never drown again" })
		MiscTab:AddToggle("InstantRevive", { Text = "Instant revive", Tooltip = "Instantly revives you upon being down" })
		MiscTab:AddToggle("InfiniteStamina", { Text = "Infinite stamina", Tooltip = "Allows you to run forever without consequences" })

		MiscTab:AddDivider()
		MiscTab:AddToggle("NoRagdoll", { Text = "No ragdoll", Tooltip = "You\'ll never ragdoll again" })
		MiscTab:AddToggle("NoFallDamage", { Text = "No fall damage", Tooltip = "Never take fall damage again" })
		MiscTab:AddToggle("NoUtilityDamage", { Text = "No utility damage", Tooltip = "You won\'t take damage from Fire/Bear traps (but not grenades)" })

		MiscTab:AddDivider()
		MiscTab:AddToggle("WalkSpeed", { Text = "Walkspeed", Tooltip = "Changes the speed you walk" })
		MiscTab:AddToggle("JumpPower", { Text = "Jump power", Tooltip = "Changes how high you jump" })
		MiscTab:AddToggle("EquipWeapon", { Text = "Equip weapon", Tooltip = "Equips your melee weapon" })
		MiscTab:AddSlider("SpeedAmount", { Text = "Walkspeed amount", Default = 1, Min = 1, Max = 75, Rounding = 0 })
		MiscTab:AddSlider("JumpPowerAmount", { Text = "Jumppower amount", Default = 1, Min = 1, Max = 150, Rounding = 0 })

		MiscTab:AddDivider()
		MiscTab:AddToggle("InfiniteJump", { Text = "Infinite jump", Tooltip = "Allows you to press space and jump infinitely" })
		MiscTab:AddToggle("NoDashCooldown", { Text = "No dash cooldown", Tooltip = "Removes the dash cooldown you have to wait for" })
		MiscTab:AddToggle("NoJumpCooldown", { Text = "No jump cooldown", Tooltip = "Removes the jump cooldown you have to wait for" })

		MiscTab:AddDivider()
		MiscTab:AddToggle("Killsay", { Text = "Kill say", Tooltip = "Says a funny message upon killing someone" })
		MiscTab:AddToggle("AutoShove", { Text = "Auto shove", Tooltip = "Automatically shoves a user after they\'re parried" })
		MiscTab:AddToggle("TeleportBehindEnemy", { Text = "Teleport behind enemy" })

		MiscTab:AddDivider()
		MiscTab:AddToggle("ResetOnEvent", { Text = "Reset on event", Tooltip = "Resets your character when a nuke/missle/blackout event happens (so they can't farm you)" })
		MiscTab:AddToggle("InstantBearTrap", { Text = "Instant bear trap", Tooltip = "Allows you place your bear trap instantly" })
		MiscTab:AddToggle("InstantGhostPotion", { Text = "Instant ghost potion", Tooltip = "Allows you to chug the ghost potion instantly" })
	
		Toggles.WalkSpeed:OnChanged(function(State)
			if not State and Character and Character:FindFirstChild("Humanoid") then
				Character.Humanoid.WalkSpeed = 16
			end
		end)

		Toggles.JumpPower:OnChanged(function(State)
			if not State and Character and Character:FindFirstChild("Humanoid") then
				JumpConstants.JUMP_DELAY_ADD = 1;
                Character.Humanoid.JumpPower = 50
			end
		end)
	end

	local MiscTab2 = LeftMiscTab2:AddTab("Misc") do
		local Debounce = false

		MiscTab2:AddToggle("FastRespawn", { Text = "Fast respawn", Tooltip = "Upon death, respawns you quicker" })
		MiscTab2:AddToggle("LongChatSpam", { Text = "Long chat spam", Tooltip = "Spams a really long text and floods chat" })
		MiscTab2:AddToggle("RepawnAtHealth", { Text = "Fast respawn below health", Tooltip = "Respawns you when you\'re a low health" })
		MiscTab2:AddSlider("RespawnHealth", { Text = "Health to respawn", Default = 1, Min = 1, Max = 115, Rounding = 0 })

		MiscTab2:AddDivider()
		MiscTab2:AddToggle("Desync", { Text = "Desync", Tooltip = "Makes it almost impossible for legit people to hit you & legit silent aims" })
		MiscTab2:AddToggle("UnequipOnParry", { Text = "Unequip on parry", Tooltip = "Unequips your weapon upon another player parrying" })
		MiscTab2:AddToggle("AutoclaimAirdrop", { Text = "Autoclaim airdrop", Tooltip = "Teleports you to an airdrop when they spawn" })
		
		MiscTab2:AddDivider()
		MiscTab2:AddToggle("BeartrapEnemy", { Text = "Beartrap enemy", Tooltip = "Instantly places your beartrap under a player if they're near you" })
		MiscTab2:AddToggle("InfiniteAbility", { Text = "Infinite ability", Tooltip = "Lets you use your ability you press 1st infinitely until death or no kills" })
		MiscTab2:AddButton("Unlock parry gamepass", function()
			for _,v in pairs(getgc(true)) do
				if type(v) == "table" and rawget(v, "ParryColor") then
					v.ParryColor.gamepassIdRequired = nil
					v.ParryColor.replicateToOtherClients = true
				end
			end
		end)
		MiscTab2:AddButton("Weird body", function()
			if not Debounce then
				Debounce = true
				Player:Move(Vector3.one / 0/0, false)

				task.wait(5)
				Debounce = false
			end
		end)
	end

	local MiscTab3 = LeftMiscTab2:AddTab("Misc 2") do
		MiscTab3:AddToggle("InstantC4", { Text = "Instant C4", Tooltip = "Allows you to throw your C4 instantly" })
		MiscTab3:AddToggle("AutoDetonate", { Text = "Auto detonate", Tooltip = "Automatically detonates your C4" })
		MiscTab3:AddToggle("AutoAttachC4", { Text = "Auto attach C4", Tooltip = "Attempts to attach C4 to near players" })

		MiscTab3:AddDivider()
		MiscTab3:AddToggle("Fly", { Text = "Fly" }):AddKeyPicker("FlyBind", { Text = "Fly", Default = "None" })
		MiscTab3:AddToggle("NoKnockback", { Text = "No knockback", Tooltip = "Removes the knockback from being hit" })
		MiscTab3:AddToggle("NoAnimations", { Text = "No animations", Tooltip = "Breaks your animations so you can avoid parries easier" })
		MiscTab3:AddSlider("FlySpeed", { Text = "Fly speed", Default = 0, Min = 0, Max = 0.8, Rounding = 1 })

		MiscTab3:AddDivider()
		MiscTab3:AddToggle("AvoidArrows", { Text = "Avoid arrows", Tooltip = "Teleports away from near arrows to avoid them hitting you" })
		MiscTab3:AddToggle("ImpossibleHit", { Text = "Impossible hit", Tooltip = "Makes it impossible for most legit/rage cheats to hit you" })
		MiscTab3:AddToggle("AutoReloadBow", { Text = "Auto reload bow", Tooltip = "Reloads your bows ammo" })

		MiscTab3:AddDivider()
		MiscTab3:AddToggle("PathfindFarm", { Text = "Pathfind farm", Tooltip = "Uses pathfinding to go to players and kill them" })
	end

	local MiscTab4 = LeftMiscTab2:AddTab("Misc 3") do
		MiscTab4:AddToggle("CrashServer", { Text = "Crash server", Tooltip = "Duud idek how I found this but gg lets have some fun" })

		local HitsoundDrop = MiscTab4:AddDropdown("HitSounds", { Text = "Hit sounds", Default = 1, Values = {"Default"} })
		local KillsoundDrop = MiscTab4:AddDropdown("KillSounds", { Text = "Kill sounds", Default = 1, Values = {"Default"} })
		local ShootsoundDrop = MiscTab4:AddDropdown("ShootSounds", { Text = "Shoot sounds", Default = 1, Values = {"Default"} })

		MiscTab4:AddSlider("HitVolume", { Text = "Hit volume", Default = 0.1, Min = 0.1, Max = 15, Rounding = 1 })
		MiscTab4:AddSlider("KillVolume", { Text = "Kill volume", Default = 0.1, Min = 0.1, Max = 15, Rounding = 1 })
		MiscTab4:AddSlider("ShootVolume", { Text = "Shoot volume", Default = 0.1, Min = 0.1, Max = 15, Rounding = 1 })

		--// Insert all the sounds into the dropdowns
		for i,v in pairs(HitSoundTable) do table.insert(HitsoundDrop.Values, i) end
		for i,v in pairs(KillSoundTable) do table.insert(KillsoundDrop.Values, i) end
		for i,v in pairs(ShootSoundTable) do table.insert(ShootsoundDrop.Values, i) end

		--// Set the dropdown values & display it to the dropdown
		HitsoundDrop:SetValues() 
		HitsoundDrop:Display()

		KillsoundDrop:SetValues() 
		KillsoundDrop:Display()

		ShootsoundDrop:SetValues()
		ShootsoundDrop:Display()

		Options.HitVolume:OnChanged(function(State)
			Ranged.Sounds.MaterialsHit.Humanoid.Volume = State 
		end)

		Options.KillVolume:OnChanged(function(State)
			Ranged.Parent.Sounds.KillSound.Volume = State
		end)

		Options.ShootVolume:OnChanged(function(State)
			for _,v in pairs(Ranged:GetChildren()) do
				local Sound = v:FindFirstChild("Sounds")
				local Fire = Sound and Sound:FindFirstChild("Fire")

				if Fire then Fire.Volume = State end
			end
		end)

		Options.HitSounds:OnChanged(function(State)
			if State == "Default" then
				Ranged.Sounds.MaterialsHit.Humanoid.SoundId = OldSounds["Humanoid"]
				Melee.Mace.Sounds.Hits["1"].SoundId = OldSounds["Mace"][1]
				Melee.Mace.Sounds.Hits["2"].SoundId = OldSounds["Mace"][2]
				Melee.IronSword.Sounds.Hits["1"].SoundId = OldSounds["IronSword"][1]
				Melee.IronSword.Sounds.Hits["2"].SoundId = OldSounds["IronSword"][2]
			else 
				Ranged.Sounds.MaterialsHit.Humanoid.SoundId = HitSoundTable[State]
				Melee.Mace.Sounds.Hits["1"].SoundId = HitSoundTable[State]
				Melee.Mace.Sounds.Hits["2"].SoundId = HitSoundTable[State]
				Melee.IronSword.Sounds.Hits["1"].SoundId = HitSoundTable[State]
				Melee.IronSword.Sounds.Hits["2"].SoundId = HitSoundTable[State]
			end
		end)

		Options.KillSounds:OnChanged(function(State)
			if State == "Default" then
				Ranged.Parent.Sounds.KillSound.SoundId = OldSounds["Killsound"]
			else Ranged.Parent.Sounds.KillSound.SoundId = KillSoundTable[State]
			end
		end)

		Options.ShootSounds:OnChanged(function(State)
			if State == "Default" then
				for _,v in pairs(Ranged:GetChildren()) do
					local Sound = v:FindFirstChild("Sounds")
					local Fire = Sound and Sound:FindFirstChild("Fire")

					if Fire then Fire.SoundId = OldSounds[v.Name] end
				end
			else
				for _,v in pairs(Ranged:GetChildren()) do
					local Sound = v:FindFirstChild("Sounds")
					local Fire = Sound and Sound:FindFirstChild("Fire")

					if Fire then Fire.SoundId = ShootSoundTable[State] end
				end
			end
		end)
	end

	function IsVisible(TargetCharacter, MaxDistance, IgnoreList)
		local PlayerHitbox = TargetCharacter and TargetCharacter:FindFirstChild(Options.Hitbox.Value)
		local PlayerPosition = PlayerHitbox and TargetCharacter[Options.Hitbox.Value].Position

		if not PlayerPosition then return false end
		if (PlayerPosition - Camera.CFrame.p).Magnitude > MaxDistance then return false end
		
		local NewRay = Ray.new(Camera.CFrame.p, PlayerPosition - Camera.CFrame.p)
		local HitPart, _, _ = workspace:FindPartOnRayWithIgnoreList(NewRay, IgnoreList)
		
		if HitPart and HitPart:IsDescendantOf(TargetCharacter) then return true end
		return false
	end

	local ClosestTargetInFov = function()
		local Range = math.huge
		local Target = nil

		for _,v in pairs(Players:GetPlayers()) do
			if v == Player then continue end

			local MyHitbox = Character and Character:FindFirstChild("HumanoidRootPart")
			local EnHitbox = MyHitbox and v.Character and v.Character:FindFirstChild(Options.Hitbox.Value)
			local Humanoid = EnHitbox and EnHitbox.Parent:FindFirstChild("Humanoid")

			if not Humanoid then continue end
            if Humanoid.Health <= 0 then continue end

			local WorldPoint, OnScreen = Camera:WorldToScreenPoint(EnHitbox.Position)
			local WorldPosition, MousePosition = Vector2.new(WorldPoint.X, WorldPoint.Y), Vector2.new(Mouse.X, Mouse.Y)
			local Magnitude = OnScreen and ( WorldPosition - MousePosition ).Magnitude

			if Magnitude and Magnitude <= Range and Magnitude <= Options.FovSize.Value then
				if Toggles.VisibilityCheck.Value and not IsVisible(EnHitbox.Parent, 800, { Character }) then continue end
				if Toggles.WhitelistFriends.Value and v:IsFriendsWith(Player.UserId) then continue end

				Range = Magnitude
				Target = EnHitbox.Parent
			end
		end

		return Target
	end

	local ClosestTarget = function()
		local Range = math.huge
		local Target = nil

		for _,v in pairs(Players:GetPlayers()) do
			if v == Player then continue end

			local MyHitbox = Character and Character:FindFirstChild("HumanoidRootPart")
			local EnHitbox = MyHitbox and v.Character and v.Character:FindFirstChild(Options.Hitbox.Value)
			local Humanoid = EnHitbox and EnHitbox.Parent:FindFirstChild("Humanoid")

			if not Humanoid then continue end
            if Humanoid.Health <= 0 then continue end

			if Humanoid then
				local Magnitude = ( MyHitbox.Position - EnHitbox.Position ).Magnitude
				
				if Options.AimPriority.Value == "Closest" and Magnitude < Range then
					Range = Magnitude
					Target = EnHitbox.Parent
				elseif Options.AimPriority.Value == "Lowest Health" and Magnitude < Range and Humanoid.Health >= Health then
					Range = Magnitude
					Health = Humanoid.Health
					Target = EnHitbox.Parent
				end
			end
		end
		return Target
	end

	local GetWeaponValue = function(Value, ToolName)
		local Bruh = nil
		for _,v in pairs(WeaponMetadata) do
			if type(v) == "table" and v.type == "weapon" then
				if string.find(v.displayName, ToolName) then
					Bruh = v[Value]
				end
			end
		end
		return Bruh
	end

	local NewRandom = Random.new()
	local OldFireDirection = RangedHandler.calculateFireDirection

	function CalculateTrajectory(startPos, gravity, endPos, bulletSpeed)
		local direction = (endPos - startPos).unit
		local distance = (endPos - startPos).magnitude
		local time = distance / bulletSpeed
		
		local yOffset = 0.5 * gravity * time * time
		local xOffset = direction * bulletSpeed * time
		return startPos + xOffset + Vector3.new(0, yOffset, 0)
	end

	function CalculateTrajectoryPoints(startPos, gravity, endPos, bulletSpeed, frequency)
		local direction = (endPos - startPos).unit
		local distance = (endPos - startPos).magnitude
		local time = distance / bulletSpeed

		local t = 0
		local trajectoryPoints = {}
		while t <= time do
			local yOffset = 0.5 * gravity * t * t
			local xOffset = direction * bulletSpeed * t
			local point = startPos + xOffset + Vector3.new(0, yOffset, 0)
			table.insert(trajectoryPoints, Point3D.new(point))
			t = t + frequency
		end
		return trajectoryPoints
	end

	-- Kalman filter algorithm for 3D position prediction with ping
	local KalmanFilter = {}
	KalmanFilter.__index = KalmanFilter

	function KalmanFilter.new()
		local self = setmetatable({}, KalmanFilter)

		-- Initialize state variables
		self.X = Vector3.new(0, 0, 0) -- predicted state
		self.P = Vector3.new(1, 1, 1) -- predicted error covariance
		self.Q = Vector3.new(0.1, 0.1, 0.1) -- process noise covariance
		self.R = Vector3.new(1, 1, 1) -- measurement noise covariance
		self.K = Vector3.new(0, 0, 0) -- Kalman gain

		return self
	end

	function KalmanFilter:predict()
		-- Predict next state
		self.X = self.X
		self.P = self.P + self.Q
	end

	function KalmanFilter:update(Z, R)
		-- Update state based on measurement
		self.K = self.P / (self.P + R)
		self.X = self.X + self.K * (Z - self.X)
		self.P = (Vector3.new(1, 1, 1) - self.K) * self.P
	end

	-- Function to predict character position using Kalman filter
	local PredictCharacterPosition = function(Origin, Hitbox, Position, ArrowSpeed, Ping)
		local Velocity = Hitbox.Velocity

		local Magnitude = (Origin - Position).Magnitude
		local TimeTaken = Magnitude / ArrowSpeed
		
		if Velocity.Y <= -15 or Velocity.Y >= 15 then
			Velocity = Vector3.new(Velocity.X, Velocity.Y * TimeTaken, Velocity.Z)
		end

		local FinalPosition = Position + (Velocity * TimeTaken)

		-- Use Kalman filter to smooth the prediction
		local filter = KalmanFilter.new()
		local prediction = FinalPosition
		filter.X = prediction
		filter:predict()
		filter:update(prediction, Vector3.new(Ping, Ping, Ping))

		-- Return smoothed prediction
		return filter.X
	end

    do
        local ReloadTable = nil
        local SimulateCast = nil
        local Bruh_Connection, Added_Connection, Reload_Connection = nil, nil, nil

        for _,v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "cancelReload") and rawget(v, "resetCharge") then
                ReloadTable = v
            end

            if typeof(v) == "function" and getinfo(v).name == "SimulateCast" then
            	SimulateCast = v
            end
        end

        local MarkedCasters = {}

        local OldNetwork = Network.FireServer
        local OldRagdoll = RagdollHandler.toggleRagdoll
        local OldCastFire = FastCast.Fire
        local OldSetupState = RagdollUtil.setupState
        local OldSlashRayHit = MeleeClient.onSlashRayHit
        local OldSimulateCast = nil
        local OldCancelReload = ReloadTable.cancelReload
        local OldKnockbackPart = KnockbackHandler.knockbackPart

        local function getHitPart(hitbox)
            for _, plr in next, game.Players:GetPlayers() do
                if plr == Player then continue end

                local character = plr.Character
                local head = character and character:FindFirstChild('Head')
                if not head then continue end

                local dist = math.floor((head.Position - hitbox.Position).magnitude)
                if dist <= Options.RangeAmount.Value then
                    return head
                end
            end
        end

        ReloadTable.cancelReload = function(...)
            if Toggles.NoReloadCancel.Value and Tool then return end
            return OldCancelReload(...)
        end

        RagdollHandler.toggleRagdoll = function(...)
            if Toggles.NoRagdoll.Value then return end
            return OldRagdoll(...)
        end

        KnockbackHandler.knockbackPart = function(...)
            if Toggles.NoKnockback.Value then return end
            return OldKnockbackPart(...)
        end

        RagdollUtil.setupState = function(...)
            if Toggles.AntiHead.Value then return true end
            return OldSetupState(...)
        end

        NumberUtil.getLargestDistanceFromOrigin = function()
            return 99999999999999
        end

        MeleeClient.onSlashRayHit = function(self, ...)
            local Args = { ... }
            local Hitbox = Args[1]
            local Part = Args[2]

            if not Players:GetPlayerFromCharacter(Part.Parent) and Toggles.RangeExpander.Value then
                local Target = getHitPart(Hitbox)
                if Target then
                    Args[2] = Target
                    Args[3] = { Position = Target.Position }
                    Args[4] = Target.Position
                end
            end

            return OldSlashRayHit(self, unpack(Args))
        end

        Network.FireServer = function(self, Action, ...)
            local Args = { ... }

            if Toggles.NoFallDamage.Value and Action == "TakeFallDamage" then return end
            if Toggles.InfiniteAir.Value and Action == "ChangeHasAir" then return end
			if Toggles.ImpossibleHit.Value and Action == "ReplicateBodyRotation" then Args[1] = { CFrame.new(), CFrame.new(), CFrame.new(), CFrame.new(0, -9.999999, 0) } end
            if Toggles.NoReloadCancel.Value and Action == "CancelRangedReload" then return end
            if Toggles.AlwaysHeadshot.Value and Action == "RangedHit" then Args[2] = Args[2].Parent.Head end
			if (Toggles.InfiniteAbility.Value or Toggles.SkillAura.Value or Toggles.CrashServer.Value) and Action == "EndSkill" then return end
            if Action == "BAC" then return end

            return OldNetwork(self, Action, unpack(Args))
        end

		local OldKillsay = nil
		local OnKilledPlayer = nil
		for _,v in pairs(getgc()) do
			
			if typeof(v) == "function" and getinfo(v).name == "onKilledPlayer" then
				OnKilledPlayer = v
			end
		end

		-- 1 = Full kill, 2 = Assists, 3 = Finishes, 4 = Glory kill
		local KillSays = {
			["1"] = {
				"Ez kill, git gud %s such a skrub",
				"Welcome to the spawn screen, %s",
				"Get rekt %s you\'re such a noob 🤣😂",
				"You\'re trash go back to playing bots %s.",
				"Lol %s you\'re so bad imaging dying to me...",
				"No, I'm not cheating %s I'm just really good!!",
				"I hope you enjoy the view from the bottom of the scoreboard %s",
				"You're so bad at this game, it's like you're not even trying %s",
				"Lool no way you got full killed, keep riding the death toll up %s 😂",
				"EZ clap, I'm basically playing against bots %s.",
				"You're so bad, I almost feel bad for killing you %s.",
				"Go back to the tutorial %s, you clearly need it.",
				"Uninstall the game now %s, you're just wasting everyone's time.",
				"You're not even worth the ammo I used to kill you %s.",
				"Haha, you're the reason why your team lost %s.",
				"Stop feeding me kills %s, it's getting boring.",
				"Nice try, but I'm just too good for you %s.",
				"Can't believe how easy it was to kill you %s, did you even fight back?",
				"I hope you enjoy respawning, %s, because that's all you're good at.",
				"Wow you're still respawning %s? Welp thanks for the %s XP",
				"Jesus you're so bad %s! I just got another %s XP from just killing you 😂"
			},
			["2"] = {
				"Haha I stole your kill %s",
				"Mate you got tag teamed %s that\'s a whole L",
				"How does it feel getting jumped by 50 dudes %s?!",
				"Couldn\'t have assisted without me, %s such a scrub 😂",
				"Thanks for the assist, but I still did all the work %s 😂🤣",
				"You just got absolutely streaded by the whole football team %s 😂🤣",
				"You\'re welcome for the carry! That assist was so easy for a noob like %s",
				"Wow, I had to save you from that one %s. Noob.",
				"Thanks for helping me get the kill, %s. You're basically useless otherwise.",
				"I only got the kill because you softened them up, %s. Don't get too excited.",
				"You're nothing without me, %s. Remember that.",
				"I guess even you can be useful sometimes, %s. Don't get too cocky though.",
				"Haha, you couldn't even finish the job, %s. How pathetic.",
				"I can't believe you needed my help to get that kill, %s. So weak.",
				"Nice try, but you couldn't have done it without me %s.",
				"Thanks for the assist, %s. Too bad you're still terrible at the game.",
				"Don't worry %s, you'll get a kill eventually... maybe."
			},
			["3"] = {  
				"Say goodnight, %s sweet prince",
				"Game over, time to uninstall %s",
				"GG, but only for me %s.",
				"Dawg %s try not to get finished next time your so bad",
				"You fought well, but not well enough %s you stupid scrub",
				"Damn no way you just got finished by me %s, how bad are you?",
				"Imma keep taking these W\'s the first step of taking them is to keep on finishing your trash ahhh %s",
				"You're so bad, it's almost sad %s.",
				"You fought well, but not well enough %s. Better luck next time... or not.",
				"I can't believe you thought you could take me on %s. So naive.",
				"I bet you regret challenging me now %s, don't you?",
				"That was too easy, %s. Step up your game if you want to stand a chance.",
				"Looks like you're just a stepping stone on my way to victory, %s.",
				"Better luck next time, %s... wait, no there won't be a next time for you.",
				"Haha, I can't believe you actually thought you had a chance %s. You're delusional.",
				"You were always going to lose that fight %s, let's be real.",
				"You're not even worth the effort it took to kill you %s.",
				"Imagine getting finished, you're so dog water %s. But thanks for the %s XP",
				"Saw that cool trick I did on you %s? Welp that just gave me %s XP so thank you.",
			},
			["4"] = { 
				"You must feel so humiliated right now %s.",
				"I bet you wish you had never respawned %s",
				"That was just embarrassing for %s he got glory killed.",
				"This is the easiest dub of my life glory killing %s all day 😂🤣😂",
				"My dawg, the glory kill animation lasts for like 5 minutes how the hell you that bad %s!?",
				"I feel bad for you %s how just died to a glory kill get better and try again next time buddy..",
				"Another day, another pathetic opponent, the oppenents name happens to be a stupid kid name %s 🤣😂",
				"Haha, that was almost too easy %s. I'm practically toying with you.",
				"You're so bad, you don't even deserve a regular kill %s. You're lucky I gave you a glory kill.",
				"Looks like it's time to send you back to the lobby, %s.",
				"You must feel so embarrassed right now %s, getting glory killed like that.",
				"Did you just forget how to play the game, %s? That was pitiful.",
				"Haha, I love the sound of a glory kill %s. It means I'm dominating you.",
				"Another one bites the dust, %s. When will you learn?",
				"You're not even worth the effort it took to glory kill you %s. Pathetic.",
				"Sorry not sorry, %s. I had to glory kill you, it was too easy.",
				"I bet you didn't see that glory kill coming, did you %s? You're too slow.",
				"Losing your good score, ego, and every fight %s. Imagine dying to a glory kill and profitting me %s XP!!! 😂🤣"
			}
		}

		local TextChannels = game.TextChatService:FindFirstChild("TextChannels")
		local RBXGeneral = TextChannels and TextChannels:FindFirstChild("RBXGeneral")

		OldKillsay = hookfunc(OnKilledPlayer, function(TargPlr, KillType, ...)
			local Args = { ... }

			if Toggles.Killsay.Value then
				local EarnedXp = nil
				local RandomKillsay = KillSays[KillType][math.random(1, #KillSays[KillType])]
				
				if not string.find(RandomKillsay, "XP") then
					local FormattedChat = string.format(RandomKillsay, TargPlr.DisplayName)
					RBXGeneral:SendAsync(FormattedChat)
				else
					if Args[1] > 1 then
						local Test = KillStreakConfigs[ Args[1] - 1 ]
						if not Test then
							Test = KillStreakConfigs[#KillStreakConfigs]
						end

						if Test then
							EarnedXp = Test.xpToGive * Args[3]
						end
					end

					if KillType == "1" then EarnedXp = DamageConstants.XP_PER_KILL * Args[3]
					elseif KillType == "3" then EarnedXp = FinishConstants.EXTRA_XP_PER_FINISH * Args[3]
					elseif KillType == "4" then EarnedXp = GloryKillConstants.EXTRA_XP_PER_GK * Args[3]
					end

					if EarnedXp then
						local FormattedChat = string.format(RandomKillsay, TargPlr.DisplayName, tostring(EarnedXp))
						RBXGeneral:SendAsync(FormattedChat)
					end
				end
			end

			return OldKillsay(TargPlr, KillType, ...)
		end)

        RangedHandler.calculateFireDirection = function(...)
            local Args = { ... }
            local Target = ClosestTargetInFov()
			
            if MainCaster and typeof(Args[1]) == "CFrame" and Tool and string.find(string.lower(Tool.Name), "bow") then
                MainCaster.tool = Tool
                MainCaster.handle = Tool.Contents.Handle

				if Toggles.ArrowBeam.Value then
					if not Target or not Toggles.SilentAim.Value then
						local Filter = {}
                		local CheatedOrigin = MainCaster:getCheatedBackOriginIfInObject(MainCaster)
						Filter.ignoreList = game.CollectionService:GetTagged("RANGED_CASTER_IGNORE_LIST")

						local _, FinalPosition = RaycastUtilClient.getMouseHitPosition(Filter)

						CreateBeam(CheatedOrigin, FinalPosition, Options.BeamStartColor.Value, Options.BeamEndColor.Value)
					end
				end

                if Toggles.SilentAim.Value and Target and NewRandom:NextNumber() <= Options.Hitchance.Value / 100 then
                    local Hitbox = Target[Options.Hitbox.Value]
					local MyPing = Player:GetNetworkPing() * 1000
                    local CheatedOrigin = MainCaster:getCheatedBackOriginIfInObject(MainCaster)
					local ProjectileSpeed = CheatedOrigin and GetWeaponValue("speed", Tool.Name)
					
					--local TrajectoryPos = ProjectileSpeed and CalculateTrajectory(CheatedOrigin, -GetWeaponValue("gravity", Tool.Name).Y, Hitbox.Position, ProjectileSpeed)
                    local FinalPosition = ProjectileSpeed and PredictCharacterPosition(CheatedOrigin, Hitbox, Hitbox.Position, ProjectileSpeed, MyPing)

                    if FinalPosition then
                        Args[1] = CFrame.new(Vector3.new(), ( FinalPosition - CheatedOrigin ).Unit )
						if Toggles.ArrowBeam.Value then 
							CreateBeam(CheatedOrigin, FinalPosition, Options.BeamStartColor.Value, Options.BeamEndColor.Value) 
						end
                    end
                end
            end
            return OldFireDirection(unpack(Args))
        end

        FastCast.Fire = function(...)
        	local Args = { ... }
        	local Caster = Args[1] 
        	local Behavior = Args[5]

        	if Toggles.Wallbang.Value then
        		Behavior["RaycastParams"].FilterDescendantsInstances = {
        			Behavior["RaycastParams"].FilterDescendantsInstances,
        			workspace.Map,
        			workspace.Terrain
        		}
        	end

        	if debug.info(2, "n") == "shoot" then
        		MarkedCasters[Caster] = true
        	end
        	return OldCastFire(unpack(Args))
    	end

		local OldPosCheck = false
		local OldCFrame = nil
    	local SimulateCastProxy = function(...)
    		local Args = { ... }
    		local Obj = Args[1]

    		if MarkedCasters[Obj.Caster] and Toggles.SilentAim.Value and Options.AimMode.Value == "Rage" and Tool then
    			local Target = ClosestTargetInFov()
    			local Hitbox = Target and Target[Options.Hitbox.Value]
    			local CurrentPos = Obj:GetPosition()

    			if Hitbox and (Hitbox.Position - CurrentPos).Magnitude <= 19 then
    				local Velocity = (Hitbox.Position - CurrentPos).Unit * 2500
    				Obj:SetVelocity(Velocity)
    			end
    		end

			if Toggles.AvoidArrows.Value and not MarkedCasters[Obj.Caster] then
				local MyRoot = Character and Character:FindFirstChild("HumanoidRootPart")
				local CurrentPos = MyRoot and Obj:GetPosition()

				if CurrentPos and ( MyRoot.Position - CurrentPos ).Magnitude <= 70 then
					if not OldPosCheck then
						OldCFrame = MyRoot.CFrame
					end
					
					task.spawn(function()
						OldPosCheck = true
						
						MyRoot.CFrame *= CFrame.new(60, 30, 0)
						RunService.RenderStepped:Wait()
						MyRoot.CFrame = OldCFrame

						task.wait(1)
						OldPosCheck = false
					end)
				end
			end
			
    		return OldSimulateCast(...)
    	end

    	OldSimulateCast = hookfunc(SimulateCast, function(...)
    		return SimulateCastProxy(...)
    	end)

        local OnCharacter = function(NewChar)
			Path = nil

            if Bruh_Connection then Bruh_Connection:Disconnect() Bruh_Connection = nil end
            if Added_Connection then Added_Connection:Disconnect() Added_Connection = nil end
            if Reload_Connection then Reload_Connection:Disconnect() Reload_Connection = nil end

            NewChar:WaitForChild("Humanoid")
            Bruh_Connection = NewChar.Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if Toggles.WalkSpeed.Value then
                    NewChar.Humanoid.WalkSpeed = Options.SpeedAmount.Value
                end
            end)
            
            Added_Connection = NewChar.ChildAdded:Connect(function(Child)
                if Toggles.AutoReloadBow.Value and Child:IsA("Tool") and Child:FindFirstChild("ReloadProgressClient") then
                    Reload_Connection = Child.ReloadProgressClient:GetPropertyChangedSignal("Value"):Connect(function()
                        local ClientAmmo = Child:FindFirstChild("ClientAmmo")
                        local ReloadProgress = ClientAmmo and Child.ReloadProgressClient
                        
                        if ReloadProgress and ClientAmmo.Value <= 0 then
                            ReloadProgress.Value = 0
                        end
                    end)
                end

				if Reload_Connection then
					warn("disconnected connection - SAMUELHOOK [999] [100%]")
					Reload_Connection:Disconnect()
                    Reload_Connection = nil
				end
            end)

			for _,v in pairs(getgc(true)) do
                if type(v) == "table" and rawget(v, "mainCasterBehavior") and rawget(v, "tool") and rawget(v, "handle") then
                    MainCaster = v
                end
            end

			Path = SimplePath.new(NewChar)
        end
        Player.CharacterAdded:Connect(OnCharacter)
        OnCharacter(Character)
    end

    local ModifyWeapon = function(Modify, Value)
    	for _,v in pairs(WeaponMetadata) do
    		if type(v) == "table" and v.type == "weapon" then
    			v[Modify] = Value
    		end
    	end
    end

    local ModifyUtility = function(ToolName, Modify, Value)
    	for _,v in pairs(UtilityMetadata) do
    		if type(v) == "table" and v.type == "utility" and v.displayName == ToolName then
    			v[Modify] = Value
    		end
    	end
    end

    local UtilityAdded = function(Child)
    	if Toggles.NoUtilityDamage.Value then
    		if string.find(Child.Name, "Bear") or Child.Name == "" then
    			task.wait(0.1)
    			Child:Destroy()
    		end
    	end
    end
    workspace.EffectsJunk.ChildAdded:Connect(UtilityAdded)

    local AirdropAdded = function(Child)
    	task.wait(.3)
    	if Toggles.AutoclaimAirdrop.Value then
    		local Crate = Child:FindFirstChild("Crate")
    		local Hitbox = Crate and Crate:FindFirstChild("Hitbox")
    		local MyRoot = Hitbox and Character and Character:FindFirstChild("HumanoidRootPart")

    		if MyRoot then
    			MyRoot.Position = Hitbox.Position
    			repeat wait() until (MyRoot.Position - Hitbox.Position).Magnitude <= 10

    			while true do
    				local Proximity = Hitbox:FindFirstChildWhichIsA("ProximityPrompt")

    				if Proximity then
	    				fireproximityprompt(Proximity)
	    			end

	    			if (MyRoot.Position - Hitbox.Position).Magnitude > 20 then break end
					task.wait(.01)
    			end
    		end
    	end
    end
    workspace.Airdrops.ChildAdded:Connect(AirdropAdded)

	local CanDo = false
	UserInputService.InputBegan:Connect(function(Key, IsTyping)
		if Key.UserInputType == Enum.UserInputType.MouseButton2 and not IsTyping then
			CanDo = true
		end
	end)

	UserInputService.InputEnded:Connect(function(Key, IsTyping)
		if Key.UserInputType == Enum.UserInputType.MouseButton2 and not IsTyping then
			CanDo = false
		end
	end)

    local Parry = function()
    	VirtualInputManager:SendKeyEvent(1, Enum.KeyCode.F, 0, game)
    	VirtualInputManager:SendKeyEvent(0, Enum.KeyCode.F, 0, game)
    end

    local OldPlaySound = SoundHandler.playSound
    SoundHandler.playSound = function(Arg)
		if typeof(Arg.parent) == "Instance" and Arg.parent and Arg.parent.Parent and Arg.parent.Parent and Arg.parent.Parent.Parent and Arg.parent.Parent.Parent.Parent then
			local MyRoot = Character and Character:FindFirstChild("HumanoidRootPart")
			local EnChar = MyRoot and Arg.parent.Parent.Parent.Parent
			local EnRoot = EnChar and EnChar:FindFirstChild("HumanoidRootPart")
			local Magnitude = EnRoot and (MyRoot.Position - EnRoot.Position).Magnitude

			if Magnitude and EnChar ~= Character then
				if Toggles.AutoParry.Value and Tool and NewRandom:NextNumber() <= Options.ParryChance.Value / 100 then
					local Magnitude = (MyRoot.Position - EnRoot.Position).Magnitude

					if Magnitude <= Options.ParryRange.Value and Arg.parent.Name == "Hitbox" then

						if Options.ParryMode.Value == "Rage" then Network:FireServer("Parry") end
						if Options.ParryMode.Value == "Legit" then SetThread(7) Parry() end
					end
				end

				if Magnitude <= 18 and Toggles.UnequipOnParry.Value and Arg.parent.Name == "SemiTransparentShield" then
					Character.Humanoid:UnequipTools()
				end
			end
		end

	    return OldPlaySound(Arg)
	end

	local OldIndex
	OldIndex = hookmetamethod(Character, '__index', function(epic, epic2)
        if tostring(epic) == "Humanoid" and tostring(epic2) == "WalkSpeed" then return 16 end
		if tostring(epic) == "Humanoid" and tostring(epic2) == "JumpPower" then return 50 end
        return OldIndex(epic, epic2)
    end)

	local Target = nil
	local HitDebounce = false
	local ChatDebounce = false
	local SwingDebounce = false
	local StompDebounce = false
	local ReloadDebounce = false
	local RagebotDebounce = false

	local SilentAim_Circle = CircleDynamic.new()
	SilentAim_Circle.Thickness = 1.5
	SilentAim_Circle.Outlined = true
	SilentAim_Circle.OutlineColor = Color3.new()

	local Tagged = game.CollectionService:GetTagged("RANGED_CASTER_IGNORE_LIST");
	table.insert(Tagged, Character)

	RunService.Heartbeat:Connect(function()
		Target = ClosestTargetInFov()

		if SilentAim_Circle then
			SilentAim_Circle.Radius = Options.FovSize.Value or 1
			SilentAim_Circle.Visible = Toggles.SilentAim.Value or false
			SilentAim_Circle.Opacity = Options.FovTransparency.Value or 0

			SilentAim_Circle.Color = Options.FovColor.Value or Color3.new(1, 1, 1)
			SilentAim_Circle.NumSides = Options.FovSides.Value or 1
			SilentAim_Circle.Position = UserInputService:GetMouseLocation()
		end

		local MyRoot = Character and Character:FindFirstChild("HumanoidRootPart")
		if MyRoot and Toggles.Desync.Value and MyRoot.AssemblyMass < math.huge and not Character:FindFirstChildWhichIsA("ForceField") then
			local OldCFrame = MyRoot.CFrame
			local OldVelocity = MyRoot.Velocity

			MyRoot.Velocity = Vector3.new( math.random(-1500, 1500), math.random(-300, 300), math.random(-1500, 1500) )
			MyRoot.CFrame *= CFrame.Angles(0, 0.0001, 0)

			RunService.RenderStepped:Wait()
			MyRoot.Velocity = OldVelocity
			MyRoot.CFrame = OldCFrame
		end
	end)

	while true do
		if Options.FlyBind.Mode ~= "None" then Toggles.Fly:SetValue(Options.FlyBind:GetState()) end
		if Options.EspBind.Mode ~= "None" then Toggles.Esp:SetValue(Options.EspBind:GetState()) end
		if Options.AutoParryBind.Mode ~= "None" then Toggles.AutoParry:SetValue(Options.AutoParryBind:GetState()) end

		local MyRoot = Character and Character:FindFirstChild("HumanoidRootPart")
		local MyHumanoid = MyRoot and MyRoot.Parent:FindFirstChild("Humanoid")

		if MyHumanoid then
			for _,v in pairs(getconnections(MyHumanoid:GetPropertyChangedSignal("JumpPower"))) do v:Disable() end

			if Toggles.HeadExpander.Value then
				for _,v in pairs(Players:GetPlayers()) do
					if v == Player then continue end

					local EnHead = v.Character and v.Character:FindFirstChild("Head")
					if EnHead then
						EnHead.Size = Vector3.new(Options.HeadAmount.Value, Options.HeadAmount.Value, Options.HeadAmount.Value)
						EnHead.Transparency = 0.4
					end
				end
			end

			if Toggles.NoAnimations.Value then
				for _,v in pairs(Character.Humanoid:GetPlayingAnimationTracks()) do
					v:Stop()
				end
			end

			if Toggles.Fly.Value then
				MyRoot.Velocity = Vector3.new(0,0,0)
				if UserInputService:IsKeyDown(Enum.KeyCode.W) then MyRoot.CFrame = MyRoot.CFrame + (Camera.CFrame.LookVector * Options.FlySpeed.Value); end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then MyRoot.CFrame = MyRoot.CFrame + (-Camera.CFrame.LookVector * Options.FlySpeed.Value); end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then MyRoot.CFrame = MyRoot.CFrame + (-Camera.CFrame.RightVector * Options.FlySpeed.Value); end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then MyRoot.CFrame = MyRoot.CFrame + (Camera.CFrame.RightVector * Options.FlySpeed.Value); end
			end

			if Toggles.AntiHead.Value and MyHumanoid.Health > 0 then
				local MyData = DataHandler.getSessionDataRoduxStoreForPlayer(Player)
				local MyHead = MyData and Character:FindFirstChild("Head")
				local MyTorso = MyHead and Character:FindFirstChild("Torso")

				if MyTorso and Player.PlayerGui:FindFirstChild("RoactUI") and not Player.PlayerGui.RoactUI:FindFirstChild("MainMenu") then
					if MyHead:FindFirstChild("RagdollBallSocket") then MyHead.RagdollBallSocket.Enabled = false end
					
					for _,v in pairs(MyTorso:GetChildren()) do
						if v.Name ~= "Neck" and v:IsA("Motor6D") then
							v.Enabled = true
						end
					end

					MyHead.CFrame = MyHead.CFrame * CFrame.new(0, 50000, 0)
					RagdollHandler.toggleRagdoll(MyHumanoid, true)

					if MyData:getState().ragdollClient then
						MyData:getState().ragdollClient.isRagdolled = false
					end
				end
			end

			if Toggles.FastRespawn.Value and MyHumanoid.Health <= 0 then
				Network:FireServer("StartFastRespawn")
				Network:InvokeServer("CompleteFastRespawn")
			end

			if Toggles.FastRespawn.Value and Toggles.RepawnAtHealth.Value and MyHumanoid.Health <= Options.RespawnHealth.Value then
				local RoactUI = Player.PlayerGui:FindFirstChild("RoactUI")

				if RoactUI and not RoactUI:FindFirstChild("MainMenu") then
					Network:FireServer("SelfDamage", math.huge, { ignoreForceField = true })
				end
			end

			if Toggles.FakeSwing.Value and Tool and not SwingDebounce then
				local MeleeAssets = ReplicatedStorage.Shared.Assets:WaitForChild("Melee")
				local ToolAsset = MeleeAssets and MeleeAssets:FindFirstChild(Tool.Name)

				task.spawn(function()
					if ToolAsset then 
						SwingDebounce = true
						MyHumanoid:LoadAnimation(ToolAsset.Animations.Slash1):Play()

						task.wait(0.5) SwingDebounce = false
					else 
						SwingDebounce = true
						MyHumanoid:LoadAnimation(MeleeAssets.BattleAxe.Animations.Slash1):Play()

						task.wait(0.5) SwingDebounce = false
					end
				end)
			end

			if Toggles.InfiniteJump.Value and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				MyHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end

			if Toggles.InstantRevive.Value then
				if MyHumanoid.Health > 15 then
					Network:FireServer("SelfReviveStart")
				else
					Network:FireServer('SelfRevive')
				end
			end

			if Toggles.ResetOnEvent.Value then
				local StoreState = RoduxStore.store:getState()
				local EventHappening = StoreState and StoreState.missileShower.isHappening or StoreState and StoreState.nuclearWarhead.isInPreExplosionStage or StoreState and StoreState.blackhole.isInGalaxy

				if EventHappening then
					Network:FireServer("SelfDamage", math.huge, { ignoreForceField = true })
				end
			end

			if Toggles.NoJumpCooldown.Value and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				JumpConstants.JUMP_DELAY_ADD = 0
				if Character.Humanoid:GetState() == Enum.HumanoidStateType.Landed then Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
			end

			if Toggles.EquipWeapon.Value then
				for _,v in pairs(Player.Backpack:GetChildren()) do
					if v:IsA("Tool") and v:FindFirstChild("Hitboxes") then
						MyHumanoid:EquipTool(v)
					end
				end
			end

			if Toggles.InfiniteStamina.Value then
				local GetDefaultStamina = StaminaHandler.getDefaultStamina
				local DefaultStamina = GetDefaultStamina and GetDefaultStamina()

				if DefaultStamina then
					DefaultStamina:setMaxStamina(555555)
					DefaultStamina:setStamina(555555)
				end
			end

			if Toggles.WalkSpeed.Value then
				MyHumanoid.WalkSpeed = Options.SpeedAmount.Value
			end

			if Toggles.JumpPower.Value then
				MyHumanoid.JumpPower = Options.JumpPowerAmount.Value
			end

			if Toggles.NoDashCooldown.Value then
				local MyData = DataHandler.getSessionDataRoduxStoreForPlayer(Player)
				local DataState = MyData and MyData:getState()

				if DataState then
					DashConstants.DASH_COOLDOWN = 0.01
					DataState.dashClient.isDashing = false
				end
			end
 		end

		if Tool then
			if MainCaster then
				MainCaster.tool = Tool
				MainCaster.handle = Tool.Contents.Handle
			end

			if Toggles.AutoReloadBow.Value then
				local ClientAmmo = Tool:FindFirstChild("ClientAmmo")
				local ServerAmmo = ClientAmmo and Tool:FindFirstChild("ServerAmmo")
				local ReloadProgressClient = ServerAmmo and Tool:FindFirstChild("ReloadProgressClient")

				if ReloadProgressClient and ClientAmmo.Value == 0 and not ReloadDebounce then
					task.spawn(function()
						if Tool.Name == "Longbow" then
							ReloadDebounce = true
							Network:FireServer("StartRangedReload", Tool)

							task.wait(.66)
							if Tool and ReloadProgressClient then
								ReloadProgressClient.Value = 1
								
								Network:FireServer("FinishedRangedReload", Tool)
								ClientAmmo.Value = 1
								ServerAmmo.Value = 1
							end

							ReloadDebounce = false
						else
							ReloadDebounce = true
							Network:FireServer("StartRangedReload", Tool)

							task.wait(1.5)
							if Tool and ReloadProgressClient then
								ReloadProgressClient.Value = 1
								Network:FireServer("FinishedRangedReload", Tool)
								ClientAmmo.Value = 1
								ServerAmmo.Value = 1
							end
							ReloadDebounce = false
						end
					end)
				end
			end

			if Toggles.InstantBearTrap.Value and Tool.Name == "Bear Trap" then
				ModifyUtility("Bear Trap", "useTime", 0.01)
			end

			if Toggles.InstantC4.Value and Tool.Name == "C4" then
				ModifyUtility("C4", "preThrowDuration", 0.01)
			end

			if Toggles.InstantBearTrap.Value and Tool.Name == "Ghost Potion" then
				ModifyUtility("Ghost Potion", "useTime", 0.01)
			end

			if string.find(string.lower(Tool.Name), "bow") then
				if Toggles.NoRecoil.Value then
					ModifyWeapon("recoilAmount", 0.1)
				end

				if Toggles.NoSpread.Value then
					ModifyWeapon("minSpread", 0.01)
					ModifyWeapon("maxSpread", 0.01)
					ModifyWeapon("adsSpreadMultiplier", 0.01)
				end

				if Toggles.InstantCharge.Value then
					ModifyWeapon("chargeOnDuration", 0.01)
					ModifyWeapon("chargeOffDuration", 0.01)
				end

				if Toggles.NoDropoff.Value then
					ModifyWeapon("gravity", Vector3.new(0, 0, 0))
				end

				if Toggles.NoReloadSlowdown.Value then
					ModifyWeapon("reloadWalkSpeedMultiplier", 1)
				end

				if Toggles.InfiniteRange.Value then
					ModifyWeapon("maxDistance", 5000)
				end
			end

			if Toggles.ArrowTrajectory.Value and Tool:FindFirstChild("ChargeProgressClient") then
				if (Tool.ChargeProgressClient.Value == 1 or CanDo) and Tool and MainCaster then
					PolyLine.Visible = true
					local StartPosition = MainCaster:getCheatedBackOriginIfInObject(MainCaster)
					local _, EndPosition = RaycastUtilClient.getMouseHitPosition({ ignoreList = Tagged })

					local Bruh = CalculateTrajectoryPoints(StartPosition, GetWeaponValue("gravity", Tool.Name).Y, EndPosition, GetWeaponValue("speed", Tool.Name), 0.005)
					PolyLine.Points = Bruh
				else
					PolyLine.Visible = false
				end
			end
		end

		if Toggles.LongChatSpam.Value and not ChatDebounce then
			local TextChannels = game.TextChatService:FindFirstChild("TextChannels")
			local RBXGeneral = TextChannels and TextChannels:FindFirstChild("RBXGeneral")

			task.spawn(function()
				ChatDebounce = true

				RBXGeneral:SendAsync(LongString)
				task.wait(NewRandom:NextNumber(2, 2.3))
				ChatDebounce = false
			end)
		end

		local Closest = ClosestTarget()
		if Closest and MyHumanoid then
			
			if Toggles.KillAura.Value and Tool and not HitDebounce then
				local Hitboxes = Tool:FindFirstChild("Hitboxes")
				local Hitbox = Hitboxes and Hitboxes:FindFirstChild("Hitbox")
				local EnHead = Hitbox and Closest:FindFirstChild("Head")
				local Magnitude = EnHead and ( MyRoot.Position - EnHead.Position ).Magnitude

				if Magnitude and Magnitude <= Options.AuraRange.Value then
					local TargetData = DataHandler.getSessionDataRoduxStoreForPlayer(Players:FindFirstChild(Closest.Name))
					local TargetState = TargetData and TargetData:getState()
					local WeaponCooldown = TargetState and GetWeaponValue("cooldown", Tool.Name)

					if WeaponCooldown and not TargetState.parry.isParrying then
						task.spawn(function()
							if Tool.Name ~= "Sickle" then
								HitDebounce = true

								Network:FireServer("MeleeSwing", Tool, math.random(1, 3))
								Network:FireServer("MeleeDamage", Tool, EnHead, Hitbox, EnHead.Position, EnHead.CFrame, EnHead.Position, EnHead.Position, EnHead.Position)
								task.wait(WeaponCooldown - 0.5)

								HitDebounce = false
							else
								HitDebounce = true

								Network:FireServer("MeleeSwing", Tool, math.random(1, 3))
								Network:FireServer("MeleeDamage", Tool, EnHead, Hitbox, EnHead.Position, EnHead.CFrame, EnHead.Position, EnHead.Position, EnHead.Position)
								task.wait(WeaponCooldown - 0.37)

								HitDebounce = false
							end
						end)
					end
				end
			end

			if Toggles.SkillAura.Value then
				local EnHead = Closest:FindFirstChild("Head")

				if EnHead and (MyRoot.Position - EnHead.Position).Magnitude <= Options.AuraRange.Value then
					Network:FireServer("GroundSlamStart", EnHead.CFrame)
					Network:FireServer("GroundSlamHit", EnHead)
				end
			end

			if Toggles.CrashServer.Value then
				local EnHead = Closest:FindFirstChild("Head")

				if EnHead then
					Network:FireServer("GroundSlamStart", MyRoot.CFrame)
					Network:FireServer("GroundSlamHit", EnHead)
				end
			end

			if Toggles.PathfindFarm.Value and Path then
				local EnHead = Closest:FindFirstChild("Head")

				if EnHead and EnHead.Parent.PrimaryPart then Path:Run(EnHead.Position) end
			end

			if Toggles.AutoAttachC4.Value and Tool and Tool.Name == "C4" then
				local EnHead = Closest:FindFirstChild("Head")
				local Magnitude = EnHead and ( MyRoot.Position - EnHead.Position ).Magnitude

				if Magnitude and Magnitude <= 15 then
					local EnVel = EnHead.Velocity
					local MySpeed = 100

					local TimeTaken = Magnitude / MySpeed
					local FinalEnPos = EnHead.Position + ( EnVel * TimeTaken )

					Network:FireServer("ReplicateThrowable", Tool, FinalEnPos, FinalEnPos)
				end
			end

			if Toggles.AutoDetonate.Value and Tool and Tool.Name == "C4" then
				Network:FireServer("DetonateC4", Tool)
			end

			if Toggles.AutoShove.Value and not StompDebounce then
				local Stomp = Character:FindFirstChild("Stomp")
				local Hitboxes = Stomp and Stomp:FindFirstChild("Hitboxes")
				local StompHitbox = Hitboxes and Hitboxes:FindFirstChild("SideKickHitbox")
				local EnHead = StompHitbox and Closest:FindFirstChild("Head")
				local Magnitude = EnHead and ( MyRoot.Position - EnHead.Position ).Magnitude

				if Magnitude and Magnitude <= 15 then
					local TargetData = DataHandler.getSessionDataRoduxStoreForPlayer(Players:FindFirstChild(Closest.Name))
					local TargetState = TargetData and TargetData:getState()

					if TargetState and TargetState.parry.isParried then
						task.spawn(function()
							StompDebounce = true

							Network:FireServer("MeleeSwing", Stomp, 2)
							Network:FireServer("MeleeDamage", Stomp, EnHead, StompHitbox, EnHead.Position, EnHead.CFrame, EnHead.Position, EnHead.Position, EnHead.Position)
						
							task.wait(0.8)
							StompDebounce = false
						end)
					end
				end
			end

			if Toggles.AutoGlory.Value and Tool then
				local EnRoot = Closest:FindFirstChild("HumanoidRootPart")
				local Magnitude = EnRoot and ( MyRoot.Position - EnRoot.Position ).Magnitude

				if Magnitude and Magnitude <= 9 then
					Network:FireServer("StartGloryKill", Tool, Closest, MyRoot.Position, EnRoot.Position)

					for _,v in pairs(Character:GetChildren()) do
						if v:IsA("Part") or v:IsA("MeshPart") then
							v.Anchored = false
						end
					end
				end
			end

			if Toggles.TeleportBehindEnemy.Value then
				local EnRoot = Closest:FindFirstChild("HumanoidRootPart")
				local Magnitude = EnRoot and ( MyRoot.Position - EnRoot.Position ).Magnitude

				if Magnitude and Magnitude <= 13 then
					MyRoot.CFrame = EnRoot.CFrame * CFrame.new(0, 0, 6)
				end
			end

			if Toggles.BeartrapEnemy.Value and Tool and Tool.Name == "Bear Trap" then
				local EnRoot = Closest:FindFirstChild("HumanoidRootPart")

				if EnRoot then
					Network:InvokeServer("PlaceBearTrap", Tool, EnRoot.CFrame * CFrame.new(0, -1, 0))
				end
			end

			if Toggles.Ragebot.Value and not RagebotDebounce and Tool and Tool:FindFirstChild("ClientAmmo") and MainCaster then
				local EnHead = Closest:FindFirstChild("Head")
				local ReloadTime = GetWeaponValue("reloadTime", Tool.Name)
				local MaxDistance = ReloadTime and GetWeaponValue("maxDistance", Tool.Name)
				local ProjectileSpeed = MaxDistance and GetWeaponValue("speed", Tool.Name)

				if ProjectileSpeed and EnHead and (EnHead.Position - MyRoot.Position).Magnitude <= MaxDistance then
					RagebotDebounce = true
					
					local MyPing = Player:GetNetworkPing() * 1000
					local Origin = MainCaster:getCheatedBackOriginIfInObject(MainCaster)
					--local TrajectoryPos = CalculateTrajectory(Origin, -GetWeaponValue("gravity", Tool.Name).Y, EnHead.Position, ProjectileSpeed)
					
					local PredictionPos = PredictCharacterPosition(Origin, EnHead, EnHead.Position, ProjectileSpeed, MyPing)
					local CF = CFrame.new(Vector3.new(), ( PredictionPos - Origin ).Unit)

					local Direction = OldFireDirection(CF, 0, 0, MaxDistance)
					local Distance = (EnHead.Position - Origin).magnitude
					local TimeToHit = Distance / ProjectileSpeed

					task.spawn(function()
						Network:FireServer("RangedFire", Tool, Origin, {["1"] = Direction.Unit}, {["1"] = Direction}, {["1"] = true})
						task.wait(TimeToHit)
						Network:FireServer("RangedHit", Tool, EnHead, EnHead.Position, EnHead.CFrame, EnHead.Position, "1")

						Network:FireServer("StartRangedReload", Tool)
						task.wait(ReloadTime)
						if Tool then Network:FireServer("FinishedRangedReload", Tool) end

						RagebotDebounce = false
					end)
				end
			end
		end

		task.wait()
	end
end
