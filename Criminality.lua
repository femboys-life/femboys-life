if gamesList[game.GameId] == "Criminality" then
    --// Gun metadata and grabbing gun functions
    local GunClient   = require(ReplicatedStorage.Modules.GunClient)
    local GunMetadata = getrawmetatable(GunClient)
    local GunNewFunction = GunMetadata.__index.new
    
    local EffectsTable   = getupvalue(GunNewFunction, 31)
    local RandomFunction = getupvalue(GunNewFunction, 29)

    --// Initiate anticheat bypass
    local HookMainFunctions = function()
        --// Wait until everything is fully loaded
        repeat wait() until getrenv()._G.S_Take and getupvalue(getupvalue(getrenv()._G.S_Take, 2), 1) and  getupvalue(getupvalue(getrenv()._G.S_Take, 1), 6)
        
        --// Main func
        local SpreadHook = nil
        local StaminaHook = nil
        local AdonisMainFunc = nil
        
        --// Grab anticheat func (main adonis func)
        (function()
            for _, v in pairs( getgc() ) do
                if typeof(v) == "function" and islclosure(v) and not is_synapse_function(v) then
                    local Constants = getconstants(v)
        
                    if table.find(Constants, "Detected") and table.find(Constants, "Kick") and table.find(Constants, "IsStudio") then
                        AdonisMainFunc = v
                    end
    
                    if AdonisMainFunc then
                        break
                    end
                end
            end
        end)()

        --// Grab stamina/crash env
        local S_Take = getrenv()._G.S_Take
        local StaminaFunc = getupvalue(getupvalue(S_Take, 2), 1)
        local CrashUpval = getupvalue(getupvalue(S_Take, 1), 6)
        local CrashTable = getrawmetatable(CrashUpval).__index

        if not StaminaFunc then MessageBox("Please report to samuel if this error occurs! - FO2", 0) return end
        if not AdonisMainFunc then MessageBox("Please report to samuel if this error occurs! - FO3", 0) return end
    
    
        --// Yields the Adonis Main AC Func
        hookfunc(AdonisMainFunc, function()
            return Instance.new("BindableEvent").Event:Wait()
        end)

        --// Yields the crash func
        hookfunc(CrashTable.B, function()
            return Instance.new("BindableEvent").Event:Wait()
        end)
        
        --// Makes the stamina func return 100 everytime
        StaminaHook = hookfunc(StaminaFunc, function(...)
            if Toggles.InfiniteStamina and Toggles.InfiniteStamina.Value then
                return 100, 100
            end
            return StaminaHook(...)
        end)
        
        SpreadHook = hookfunc(getrenv().CFrame.Angles, function(...)
            local Args = { ... }
            
            if Toggles.NoSpread and Toggles.NoSpread.Value then
                
                local Info = debug.info(3, "f")
                if not getfenv(Info).script and getinfo(Info).name ~= "updtCam" then
                    local FuncUpvalue = getupvalue(getinfo(Info).func, 1)
                    
                    if FuncUpvalue and type(FuncUpvalue) == "userdata" then
                        Args[1] = 0
                        Args[2] = 0
                        Args[3] = 0
                    end
                end
            end
            
            return SpreadHook(unpack(Args))
        end)
    end
    task.spawn(HookMainFunctions)

    --// Add anti aim animation instance
    local AntiAnimation = Instance.new("Animation")
    AntiAnimation.AnimationId = "rbxassetid://215384594"
    AntiAnimation.Parent = CoreGui

    --// Load esp module
    local Esp = loadstring(game:HttpGet'https://kiriot22.com/releases/ESP.lua')()

    --// Current tabs for the UI
    local CurrentTabs = {
        ["Combat"] = Window:AddTab("Combat"),
        ["Character"] = Window:AddTab("Character"),
        ["Miscellaneous"] = Window:AddTab("Miscellaneous")
    }

    --// Combat tab boxes
    local CombatLeft  = CurrentTabs.Combat:AddLeftTabbox()
    local CombatRight = CurrentTabs.Combat:AddRightTabbox()
    local CombatRight2 = CurrentTabs.Combat:AddRightTabbox()

    --// Character tab boxes
    local CharacterLeft  = CurrentTabs.Character:AddLeftTabbox()
    local CharacterRight = CurrentTabs.Character:AddRightTabbox()

    --// Miscellaneous tab boxes
    local MiscLeft  = CurrentTabs.Miscellaneous:AddLeftTabbox()
    local MiscRight = CurrentTabs.Miscellaneous:AddRightTabbox()

    --// Aim settings tab
    local AimSettings = CombatLeft:AddTab("Aim Settings") do
        --// First feature column
        AimSettings:AddToggle("SilentAim", { Text = "Silent aim", Tooltip = "Redirects your bullet towards the person in your FOV" }):AddColorPicker("FovColor", { Default = Color3.fromRGB(1, 1, 1) })
        AimSettings:AddToggle("VisibilityCheck", { Text = "Visibility check", Tooltip = "Checks if the player is visible in your FOV" })
        AimSettings:AddSlider("Hitchance", { Text = 'Hitchance', Tooltip = "The chance of silent aim redirecting your bullet", Default = 1, Min = 1, Max = 100, Rounding = 0 })
    
        --// Second feature column
        AimSettings:AddDivider()
        AimSettings:AddSlider("FovSize", { Text = "Field of view", Tooltip = "Size of how big your fov will be", Default = 1, Min = 1, Max = 7000, Rounding = 0 })
        AimSettings:AddSlider("FovSides", { Text = "Fov sides", Tooltip = "Sides of how many sides you want", Default = 1, Min = 1, Max = 100, Rounding = 1 })
        AimSettings:AddSlider("FovTransparency", { Text = 'Fov transparency', Tooltip = "Transparency of your FOV", Default = 0, Min = 0, Max = 1, Rounding = 1 })

        --// Third feature column
        AimSettings:AddDivider()
        AimSettings:AddToggle("Autoshoot", { Text = "Autoshoot", Tooltip = "Automatically shoots your gun" })
        AimSettings:AddToggle("AlwaysHead", { Text = 'Always headshot', Tooltip = "Always will be a headshot each hit" })
        AimSettings:AddToggle("WhitelistFriends", { Text = "Whitelist friends", Tooltip = "Will whitelist all roblox friends" })
        AimSettings:AddDropdown("AimHitbox", { Text = "Aim hitbox", Default = 1, Values = { "Head", "Torso", "HumanoidRootPart", "Left Arm", "Right Arm", "Left Leg", "Right Leg" } })
    end

    --// Gun mods tab
    local GunSettings = CombatRight:AddTab("Gun modifications") do
        --// First feature column
        GunSettings:AddToggle("NoRecoil", { Text = "No recoil", Tooltip = "Gives your gun 0 recoil" })
        GunSettings:AddToggle("NoSpread", { Text = "No spread", Tooltip = "Gives your gun 0 spread" })
        GunSettings:AddToggle("InstantAim", { Text = "Instant aim", Tooltip = "Gives your the gun the ability to ADS instantly" })

        --// Second feature column
        GunSettings:AddDivider()
        GunSettings:AddToggle("AutoRevolver", { Text = "Auto revolver", Tooltip = "Gives your revolver the ability to shoot without delay" })
        GunSettings:AddToggle("InstantEquip", { Text = "Instant equip", Tooltip = "Gives your gun the ability to equip instantly" })
        GunSettings:AddToggle("CustomBullets", { Text = "Bullet color" }):AddColorPicker("BulletColor", { Default = Color3.fromRGB(1, 1, 1) })

        --// Third feature column
        GunSettings:AddDivider()
        GunSettings:AddToggle("InstantHit", { Text = "Instant hit", Tooltip = "Gives your gun the ability to instantly hit players (u need silent aim on)" })
        GunSettings:AddToggle("NoBulletDrop", { Text = "No bullet drop", Tooltip = "Gives your gun 0 dropoff" })

        Toggles.CustomBullets:OnChanged(function(state)
            if not state then
                local GunConfig = Tool and Tool:FindFirstChild("Config")
                
                if GunConfig then
                    local Config = require(GunConfig)
                    Config.BulletSettings.Color = Color3.new(1, 0.784314, 0.705882)
                    Config.BulletSettings.LightColor = Color3.new(1, 0.784314, 0.705882)
                end
            end
        end)
    end
    
    --// Combat tab
    local CombatSettings = CombatRight2:AddTab("Combat") do
        --// First feature column
        CombatSettings:AddToggle("KillAura", { Text = "Killaura", Tooltip = "Automatically hits near players" })
        CombatSettings:AddToggle("AutoFinish", { Text = "Auto finish", Tooltip = "Automatically stomps near downed players" })
        CombatSettings:AddToggle("InfiniteBlock", { Text = "Infinite block", Tooltip = "Infinitely blocks so you can't be hit" })
        CombatSettings:AddSlider("AuraRange", { Text = "Killaura range", Default = 1, Min = 1, Max = 15, Rounding = 0 })

        --// Second feature column
        CombatSettings:AddDivider()
        CombatSettings:AddToggle("TriggerBot", { Text = "Triggerbot", Tooltip = "Automatically shoots whenever your over a player" })
        CombatSettings:AddToggle("HitboxExpander", { Text = "Hitbox expander", Tooltip = "Expands players heads so it's easier to hit" })
        CombatSettings:AddToggle("PeppersprayAura", { Text = "Pepperspray aura", Tooltip = "Automatically pepperspray's near players" })
        CombatSettings:AddSlider("HitboxAmount", { Text = "Hitbox amount", Tooltip = "The hitbox amount you want it to expand", Default = 1, Min = 1, Max = 6, Rounding = 1 })
    
        Toggles.HitboxExpander:OnChanged(function(state)
            if not state then
                for i,v in pairs(Players:GetPlayers()) do
                    if v == Player then continue end
                    local Char = v.Character
                    local Head = Char and Char:FindFirstChild("Head")
                    
                    if Head then
                        Head.Size = Vector3.new(1.2000000476837, 1, 1);
                        Head.Transparency = 0;
                    end
                end
            end
        end)
    end

    --// Character tab
    local CharacterSettings = CharacterLeft:AddTab("Character") do
        --// First feature column
        CharacterSettings:AddToggle("WalkSpeed", { Text = "Walkspeed", Tooltip = "Changes how fast your player will move" })
        CharacterSettings:AddToggle("JumpPower", { Text = "Jump power", Tooltip = "Changes how high your character will jump" })
        CharacterSettings:AddToggle("CameraFov", { Text = "Camera fov" })

        CharacterSettings:AddSlider("FovAmount", { Text = "FOV amount", Default = 1, Min = 1, Max = 100, Rounding = 0 })
        CharacterSettings:AddSlider("JumpAmount", { Text = "Jump amount", Default = 1, Min = 1, Max = 25, Rounding = 0 })
        CharacterSettings:AddSlider("SpeedAmount", { Text = "Speed amount", Default = 1, Min = 1, Max = 40, Rounding = 0 })

        --// Second feature column
        CharacterSettings:AddDivider()
        CharacterSettings:AddToggle("AntiFire", { Text = "Antifire", Tooltip = "Makes you immune to fire" })
        CharacterSettings:AddToggle("Fullbright", { Text = "Fullbright", Tooltip = "Makes your game bright even when it's dark" })
        CharacterSettings:AddToggle("InfiniteStamina", { Text = "Infinite stamina", Tooltip = "Lets you sprint forever and never loose stamina" })

        --// Third feature column
        CharacterSettings:AddDivider()
        CharacterSettings:AddToggle("NoSmoke", { Text = "No smoke", Tooltip = "Makes smokes invisible" })
        CharacterSettings:AddToggle("NoFlash", { Text = "No flash", Tooltip = "Makes flashes not effect  you" })
        CharacterSettings:AddToggle("NoJumpCooldown", { Text = "No jump cooldown", Tooltip = "Lets you jump non-stop without cooldown" })

        --// Fourth feature column
        CharacterSettings:AddDivider()
        CharacterSettings:AddToggle("AlwaysSwim", { Text = "Always swim", Tooltip = "Gives you the ability to always swim" })
        CharacterSettings:AddToggle("NoSmokeScreen", { Text = "No smoke screen", Tooltip = "Removes the screen when stepping into a smoke" })
        CharacterSettings:AddToggle("ControlMode", { Text = "Control mode", Tooltip = "Lets you control the object you select in the dropdown below!" })
        CharacterSettings:AddSlider("ControlSpeed", { Text = "Control speed", Default = 1, Min = 1, Max = 5, Rounding = 1 })
        CharacterSettings:AddDropdown("ControlType", { Text = "Control type", Tooltip = "The object type you want to control! (for c4 u can only control it for 5-7 seconds)", Default = 1, Values = { "None", "Rocket", "C4" } })
       
       --// Fifth feature column
        CharacterSettings:AddDivider()
        CharacterSettings:AddButton("Open elevator", function()
            local Elevator = nil

            if not Elevator then
                for i,v in pairs(workspace.Map.Doors:GetChildren()) do
                    if string.find(v.Name, 'Elevator') then
                        Elevator = v
                    end
                end
            end
            
            if Character and Character:FindFirstChild'HumanoidRootPart' and Elevator and Elevator:FindFirstChild'Knob1' then
                local OldPos = Character.HumanoidRootPart.CFrame;
                Character:PivotTo(Elevator.Knob1.CFrame) task.wait(.2)
                Elevator.Events.Toggle:FireServer('Do', Elevator.Knob1)
                Character:PivotTo(OldPos)
            end
        end)

        --// Feature checks
        Toggles.CameraFov:OnChanged(function(state)
            if not state then
                local PlrStats = ReplicatedStorage.CharStats:FindFirstChild(Player.Name)
                local FOVs = PlrStats and PlrStats:FindFirstChild("FOVs")
                if not FOVs then return end
                
                for i,v in pairs(FOVs:GetChildren()) do
                    v.Value = 0
                end
            end
        end)

        Toggles.JumpPower:OnChanged(function(state)
            if Character and Character:FindFirstChild("Humanoid") then
                Character.Humanoid.UseJumpPower = not state
            end
        end)

        Toggles.Fullbright:OnChanged(function()
            Lighting.Ambient = Color3.new(201, 129, 123)
        end)
        --// End of feature checks
    end

    --// 2nd Character tab
    local CharacterSettings2 = CharacterRight:AddTab("Character") do
        --// First feature column
        CharacterSettings2:AddToggle("AntiDrown", { Text = "Antidrown", Tooltip = "Gives you immunity to drowning" })
        CharacterSettings2:AddToggle("AdminDetector", { Text = "Admin detector", Tooltip = "Kicks you upon an admin joining" })
        CharacterSettings2:AddToggle("NoCameraShake", { Text = "No camera shake", Tooltip = "Removes the camera shake" })

        --// Second feature column
        CharacterSettings2:AddDivider()
        CharacterSettings2:AddToggle("AntiHead", { Text = "Antihead", Tooltip = "Makes your head invis on the server" })
        CharacterSettings2:AddToggle("AutoTool", { Text = "Auto tool", Tooltip = "Equips the right tool when farming" })
        CharacterSettings2:AddToggle("NoBloodScreen", { Text = "No blood screen", Tooltip = "Removes the blood screen after being hit" })

        --// Third feature column
        CharacterSettings2:AddDivider()
        CharacterSettings2:AddToggle("Noclip", { Text = "Noclip", Tooltip = "Gives you the ability to walk through walls" })
        CharacterSettings2:AddToggle("NoSlowdown", { Text = "No slowdown", Tooltip = "Removes any sort of slowdown" })
        CharacterSettings2:AddToggle("InfiniteJump", { Text = "Infinite jump", Tooltip = "Gives you the ability to jump in the air" })
        
        --// Fourth feature column
        CharacterSettings2:AddDivider()
        CharacterSettings2:AddToggle("KeepLoot", { Text = "Keep loot", Tooltip = "Crashes you to keep your loot when out of combat (for resetting)" })
        CharacterSettings2:AddToggle("NoRagdoll", { Text = "No ragdoll", Tooltip = "Ragdolling will no longer effect you" })
        CharacterSettings2:AddToggle("NoFallDamage", { Text = "No fall damage", Tooltip = "Fall damage will no longer effect you" })
        
        --// Fifth feature column
        CharacterSettings2:AddDivider()
        CharacterSettings2:AddToggle("MeleeGod", { Text = "Melee god", Tooltip = "Makes you immune to melees" })
        CharacterSettings2:AddToggle("AutoRespawn", { Text = "Auto respawn", Tooltip = "Upon death you will automatically respawn" })
        CharacterSettings2:AddToggle("NoMareBlur", { Text = "No mare blur", Tooltip = "Removes the blur when ads with mare" })
    end

    --// Visual tab
    local VisualSettings = MiscLeft:AddTab("Visuals") do
        --// First feature column
        VisualSettings:AddToggle("Esp", { Text = "Esp" }):AddColorPicker("EspColor", { Default = Color3.new(1, 1, 1) })
        VisualSettings:AddToggle("BoxEsp", { Text = "Show boxes" })
        VisualSettings:AddToggle("NameEsp", { Text = "Show names" })

        --// Second feature column
        VisualSettings:AddDivider()
        VisualSettings:AddToggle("TracerEsp", { Text = "Show tracers" })
        VisualSettings:AddToggle("FaceCamera", { Text = "Face camera" })
        VisualSettings:AddToggle("DistanceEsp", { Text = "Show distance" })

        --// Third feature column
        VisualSettings:AddDivider()
        VisualSettings:AddToggle("ATMEsp", { Text = "Show ATMs" })
        VisualSettings:AddToggle("SafeEsp", { Text = "Show safes" })
        VisualSettings:AddToggle("ScrapEsp", { Text = "Show scraps" })


        --// Fourth feature column
        VisualSettings:AddDivider()
        VisualSettings:AddToggle("CustomShells", { Text = "Shell color" }):AddColorPicker("ShellColor", { Default = Color3.new(1, 1, 1) })
        VisualSettings:AddToggle("DealerEsp", { Text = "Show dealers" })
        VisualSettings:AddToggle("MysteryEsp", { Text = "Show mystery boxes" })

        --// Fifth feature column
        VisualSettings:AddDivider()
        VisualSettings:AddToggle("BulletBeam", { Text = "Bullet beam" }):AddColorPicker('BeamStartColor', { Default = Color3.new(1,1,1) }):AddColorPicker('BeamEndColor', { Default = Color3.new(1,1,1) });
        VisualSettings:AddToggle("HighlightTarget", { Text = "Highlight target" }):AddColorPicker('HighlightColor', { Default = Color3.new(1,1,1) });
        VisualSettings:AddToggle("BulletHoleColor", { Text = "Bullet hole color" }):AddColorPicker("HoleColor", { Default = Color3.new(1, 1, 1) })
    
        --// Sixth feature column
        VisualSettings:AddDivider()
        VisualSettings:AddSlider("EspDistance", { Text = "Esp distance", Default = 1, Min = 1, Max = 5000, Rounding = 0 })
        local DealerDrop = VisualSettings:AddDropdown("DealerStock", { Text = "Dealer stock", Multi = true, Default = 1, Values = {"None"} })
        DealerDrop.Values = {"None"}
        
        for _,v in pairs(workspace.Map.Shopz:GetDescendants()) do
            if v:IsA("IntConstrainedValue") and not string.find(v.Name, "val_") and not table.find(DealerDrop.Values, v.Name) then
                table.insert(DealerDrop.Values, v.Name)
            end
        end

        DealerDrop:SetValues()
        DealerDrop:Display()
        
        --// Esp toggle settings
        Toggles.Esp:OnChanged(function(state) Esp:Toggle(state) end)
        Toggles.BoxEsp:OnChanged(function(state) Esp.Boxes = state end)
        Toggles.NameEsp:OnChanged(function(state) Esp.Names = state end)

        Toggles.TracerEsp:OnChanged(function(state) Esp.Tracers = state end)
        Toggles.FaceCamera:OnChanged(function(state) Esp.FaceCamera = state end)
        Options.HighlightColor:OnChanged(function(state) Esp.HighlightColor = state end)

        Options.EspColor:OnChanged(function(state) Esp.Color = state end)
        --// End of esp toggle settings
    end

    --// Esp Offset tab
    local VisualSettings2 = MiscLeft:AddTab("Extra Visuals") do
        VisualSettings2:AddDropdown("EspMode", { Text = "Esp mode", Multi = true, Default = { "Players", "Objects" }, Values = {"Players", "Objects"} })
        
        Options.EspMode:OnChanged(function()
            Esp.Players = Options.EspMode.Value["Players"]
        end)
    end

    --// Miscellaneous tab
    local MiscTab = MiscRight:AddTab("Miscellaneous") do
        --// First feature column
        MiscTab:AddToggle("AutoPickup", { Text = "Auto pickup", Tooltip = "Automatically picks up near money/scraps" })
        MiscTab:AddToggle("AutoToolPickup", { Text = "Auto tool pickup", Tooltip = "Automatically picks up near tools" })
        MiscTab:AddToggle("AnnoyNearPlayers", { Text = "Annoy near players", Tooltip = "Makes an annoying sound around players" })
    
        --// Second feature column
        MiscTab:AddDivider()
        MiscTab:AddToggle("LoopLock", { Text = "Loop lock", Tooltip = "Continues to lock near doors" })
        MiscTab:AddToggle("BreakNearDoors", { Text = "Break near doors", Tooltip = "Kicks down near doors (u need to equip tool)" })
        MiscTab:AddToggle("KnockNearDoors", { Text = 'Knock near doors', Tooltip = "Knocks on near doors" })

        --// Third feature column
        MiscTab:AddDivider()
        MiscTab:AddToggle("AutoLockpick", { Text = "Auto lockpick", Tooltip = "Will automatically lockpick a near safe" })
        MiscTab:AddToggle("AutoBreakSafe", { Text = "Auto break safe", Tooltip = "Automatically breaks open near safes" })
        MiscTab:AddToggle("AutoRepairRefill", { Text = "Auto repair/refill", Tooltip = "Automatically repairs armor / refills your gun when near a dealer" })

        --// Fourth feature column
        MiscTab:AddDivider()
        MiscTab:AddToggle("CustomHitsound", { Text = "Custom hitsound", Tooltip = "Will play a sound whenever you hit someone" })
        local Test = MiscTab:AddDropdown("Hitsound", { Text = "Select hitsound", Default = 1, Values = { "None" } })

        --// Insert hitsound names
        Test.Values = {}
        
        task.spawn(function()
            repeat wait() until SoundsLoaded
            for i, v in pairs(HitSoundTable) do table.insert(Test.Values, i) end
            for i, v in pairs(KillSoundTable) do table.insert(Test.Values, i) end
            
            Test:SetValues()
            Test:Display()
        end)
        --// End of hitsound names
    
        --// Fifth feature column
        MiscTab:AddDivider()
        MiscTab:AddToggle("AntiBarbwire", { Text = "Anti barbwire", Tooltip = "Makes you immune to barbwire" })
        MiscTab:AddToggle("UnlockNearDoors", { Text = "Unlock near doors", Tooltip = "Will unlock near doors without a lockpick" })
        MiscTab:AddToggle("AutobuyLockpicks", { Text = "Autobuy lockpicks", Tooltip = "Automatically buys lockpicks when you're near a dealer" })


        --// Sixth feature column
        MiscTab:AddDivider()
        MiscTab:AddToggle("AntiAim", { Text = "Anti aim", Tooltip = "Makes it harder to get hit" })
        MiscTab:AddToggle("BreakNearAtms", { Text = "Break near ATMs", Tooltip = "Causes ATMs to completely break for the whole server :troll:" })
        MiscTab:AddToggle("InfinitePepperspray", { Text = "Infinite pepperspray", Tooltip = "Gives you infinite pepperspray" })
        MiscTab:AddToggle("AutoClaimAllowance", { Text = "Auto claim allowance", Tooltip = "Automatically claims your allowance when your near an atm" })
    
        Toggles.AntiAim:OnChanged(function(state)
            if not state then
                for _, v in pairs(Character.Humanoid:GetPlayingAnimationTracks()) do
                    if v.Animation.AnimationId == "rbxassetid://215384594" then
                        v:Stop()
                    end
                end
            else
                Character.Humanoid:LoadAnimation(AntiAnimation):Play(13, 57, 270)
            end
        end)

        --// Hitsound related stuff
        local StoreOldSounds = {}
        for _, v in pairs(ReplicatedStorage.Storage.HitStuff.Main:GetChildren()) do
            if not string.find(v.Name, 'Hit') then continue end

            for i, v in pairs(v:GetChildren()) do
                if v:IsA'Sound' then
                    StoreOldSounds[v] = v.SoundId
                end
            end
        end

        Toggles.CustomHitsound:OnChanged(function(state)
            if not state then
                local MouseGUI = Player.PlayerGui:FindFirstChild("MouseGUI")
                local HitmarkerSound = MouseGUI:FindFirstChild("HitmarkerSound")


                HitmarkerSound.SoundId = 'rbxassetid://160432334'
                ReplicatedStorage.Storage.MeleeClient.Hitmarker.SoundId = 'rbxassetid://4817809188'
                
                for i,v in pairs(ReplicatedStorage.Storage.HitStuff.Main:GetChildren()) do
                    if not string.find(v.Name, 'Hit') then continue end

                    for i,v in pairs(v:GetChildren()) do
                        if v:IsA'Sound' and StoreOldSounds[v] then
                            v.SoundId = StoreOldSounds[v]
                        end
                    end
                end
            end
        end)
        --// End of hitsound related stuff

        Toggles.AnnoyNearPlayers:OnChanged(function(state)
            if state then
                if Tool or Tool and not Tool:FindFirstChild("IsGun") then
                    MessageBox("You must equip a gun before using Annoy Players", 0)
                    Toggles.AnnoyNearPlayers:SetValue(false)
                end
            end
        end)
    end
    
    --// Chat settings tab
    local ChatSettings = MiscRight:AddTab("Chat settings") do
        --// First feature column
        ChatSettings:AddToggle("KillSay", { Text = "Kill say", Tooltip = "Says a message after killing someone" })
        ChatSettings:AddToggle("BypassEasy", { Text = "Bypass ez", Tooltip = "Bypasses the word 'ez'" })
        ChatSettings:AddToggle("EnableChat", { Text = "Enable chat", Tooltip = "Enables roblox chat" })
        
        local OriginalPosition = nil
        Toggles.EnableChat:OnChanged(function(state)
            local Chat = Player.PlayerGui:FindFirstChild("Chat")
            local ChatFrame = Chat and Chat:FindFirstChild("Frame")
            local BarChannel = ChatFrame and ChatFrame:FindFirstChild("ChatBarParentFrame")
            local ChatChannel = BarChannel and ChatFrame:FindFirstChild("ChatChannelParentFrame")
            
            ChatChannel.Visible = state
            
            if ChatChannel then
                if not OriginalPosition then
                    OriginalPosition = BarChannel.Position
                end
        
                if Toggles.EnableChat.Value then
                    BarChannel.Position = ChatChannel.Position + UDim2.new(UDim.new(), ChatChannel.Size.Y)
                else
                    BarChannel.Position = OriginalPosition
                end
            end
        end)
    end
    
    local OutlineCircle = Drawing.new("Circle")
    local Circle = Drawing.new("Circle")

    OutlineCircle.Color = Color3.fromRGB(0,0,0)
    OutlineCircle.Filled = false
    OutlineCircle.Thickness = 2
    OutlineCircle.Transparency = 1

    Circle.Filled = false
    Circle.Thickness = 1
    Circle.Transparency = 1

    do
        --// Main variables
        local Map        = workspace:WaitForChild("Map", 2)
        local Filter     = workspace:WaitForChild("Filter", 2)
        local Target     = nil
        local Events     = ReplicatedStorage:WaitForChild("Events", 2)
        local Events2    = ReplicatedStorage:WaitForChild("Events2", 2)
        local GrabConfig = nil
        
        --// Main important variables
        local ATMs    = Map:WaitForChild("ATMz", 5)
        local Safes   = Map:WaitForChild("BredMakurz", 5)
        local Doors   = Map:WaitForChild("Doors", 5)
        local Tools   = Filter:WaitForChild("SpawnedTools", 5)
        local Scraps  = Filter:WaitForChild("SpawnedPiles", 5)
        local Moneys  = Filter:WaitForChild("SpawnedBread", 5)
        local Dealers = Map:WaitForChild("Shopz", 5)
        local MysteryBoxes = Map:WaitForChild("MysteryBoxes", 5)

        --// Remote variables
        local RCLRemote   = Events2:WaitForChild("RCL", 5)
        local HitRemote   = Events:WaitForChild("XMHH2.1", 5)
        local SwingRemote = Events:WaitForChild("XMHH.1", 5)
        local ShootRemote = Events:WaitForChild("GZ_S", 5)
        local ShootDamage = Events:WaitForChild("ZFKLF_H", 5)

        --// Main folder variables
        local Storage     = ReplicatedStorage:WaitForChild("Storage", 5)
        local CharStats   = ReplicatedStorage:WaitForChild("CharStats", 5)
        local PlayerData  = ReplicatedStorage:WaitForChild("PlayerbaseData2", 5)
        local PlayerStats = CharStats and CharStats:WaitForChild(Player.Name, 5)
        local PlayerData2 = PlayerData and PlayerData:WaitForChild(Player.Name, 5)
        
        --// Autoshoot gun function
        local ShootDebounce = false
        local ShootGun = function(Pos, HitPart)
            if not ShootDebounce then
                ShootDebounce = true

                local Tick = GunMetadata.__index.cg()
                local RandomString = RandomFunction(30) .. tostring(0)
                local UpdateString = "FDS9I83"

                local CameraPos = Camera.CFrame.p
                local PositionOffset = { CFrame.new(CameraPos, Pos).LookVector.Unit }
    
                SetThread(2)

                EffectsTable:Effect("Shoot", nil, RandomString, true, Tool, CameraPos, PositionOffset, { BulletType = "Shoot", fpT = nil, NoHitEffect = false })
                
                safeFireServer(ShootRemote, Tick, RandomString, Tool, UpdateString, CameraPos, PositionOffset)
                safeFireServer(ShootDamage, "\240\159\166\146", Tick, Tool, RandomString, 1, HitPart, CameraPos, unpack(PositionOffset), nil, nil, 811.392)
                safeFireBindable(RCLRemote, Vector3.new(.001, 0, .001))

                SetThread(7)
    
                task.spawn(function()
                    task.wait(.18)
                    ShootDebounce = false
                end)
            end
        end

        --// Checks whether the player is visible or not
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

        --// Closest target in your fov function
        local ClosestTarget = function()
            local Range = math.huge
            local Target = nil

            for _, Enemy in pairs(Players:GetPlayers()) do
                if Enemy == Player then continue end

                local Char = Enemy.Character
                local BodyPart = Char and Char:FindFirstChild(Options.AimHitbox.Value)
                local Humanoid = BodyPart and Char:FindFirstChild("Humanoid")

                if Humanoid and Humanoid.Health > 0 then
                    local Position, OnScreen = Camera:WorldToScreenPoint( BodyPart.Position )
                    
                    if OnScreen then
                        local Magnitude = ( Vector2.new(Position.X, Position.Y) - Vector2.new(Mouse.X, Mouse.Y) ).Magnitude
                        
                        if Magnitude <= Range and Magnitude <= Options.FovSize.Value then
                            if Toggles.VisibilityCheck.Value and not IsVisible(Char, 2000, { Character }) then continue end
                            if Toggles.WhitelistFriends.Value and Enemy:IsFriendsWith(Player.UserId) then continue end

                            Range = Magnitude
                            Target = Char
                        end
                    end
                end
            end
            return Target
        end

        --// Gets the closest character to you
        local ClosestCharacter = function()
            local Range = math.huge
            local Target = nil

            for _,v in pairs(Players:GetPlayers()) do
                if v == Player then continue end

                local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
                local EnemyRoot = RootPart and v.Character and v.Character:FindFirstChild("HumanoidRootPart")

                if EnemyRoot then
                    Magnitude = (RootPart.Position - EnemyRoot.Position).Magnitude

                    if Magnitude < Range then
                        if Toggles.WhitelistFriends.Value and Player:IsFriendsWith(v.UserId) then continue end

                        Range = Magnitude
                        Target = v.Character
                    end
                end
            end
            return Target
        end

        --// Gets the closest in-game object to you
        local ClosestObject = function(Obj, PrimaryPart)
            local Range = math.huge
            local Object = nil
            local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
            
            if RootPart and Obj then
                for _, v in pairs(Obj:GetChildren()) do
                    local MainPart = v:FindFirstChild(PrimaryPart) or v:FindFirstChildWhichIsA(PrimaryPart)
                    
                    if MainPart then
                        if v:IsA("MeshPart") or v:IsA("Part") then
                            Magnitude = (RootPart.Position - v.Position).Magnitude
                        else
                            Magnitude = (RootPart.Position - MainPart.Position).Magnitude
                        end
                    end
                    
                    if Magnitude and Magnitude < Range then
                        Range = Magnitude
                        Object = v
                    end
                end
            end
            
            return Object
        end

        --// Gets the closest safe to you
        local ClosestSafe = function()
            local Safe = nil
            local Range = math.huge

            for _,v in pairs(Safes:GetChildren()) do
                local Values   = v and v:FindFirstChild("Values")
                local MainPart = Values and v:FindFirstChild("MainPart")
                local RootPart = MainPart and Character and Character:FindFirstChild("HumanoidRootPart")

                if RootPart and not Values.Broken.Value then
                    Magnitude = (RootPart.Position - MainPart.Position).Magnitude

                    if Magnitude < Range then
                        Safe = v
                        Range = Magnitude
                    end
                end
            end
            return Safe
        end

        --// Hit object with tool function
        local HitObject = function(Option, ToolHit, Target, WaitTime, Type)
            local Head = Target and Target:FindFirstChild("Head") or Target:FindFirstChild("DoorBase") or Target:FindFirstChild("MainPart")
            local Tick = GunMetadata.__index.cg()
            local SecurityArg = nil
            
            if Option == "Fist" or Option == "Other" then
                SecurityArg = safeInvokeServer(SwingRemote, "\240\159\154\168", Tick, Tool, "43TRFWJ", "Normal", Tick, true, true)
            else
                SecurityArg = safeInvokeServer(SwingRemote, "\240\159\154\168", Tick, Tool, "DZDRRRKI", Target, Type)
            end    
        
            if Head then
                if Option == "Fist" then
                    safeFireServer(HitRemote, "\240\159\154\168", Tick, Tool, "2389ZFX33", SecurityArg, true, ToolHit, Head, Target, ToolHit.Position, Head.Position)
                
                elseif Option == "Other" then
                    wait(WaitTime)
                    if Tool and Target and Target:FindFirstChild("Head") then
                        safeFireServer(HitRemote, "\240\159\154\168", Tick, Tool, "2389ZFX33", SecurityArg, true, ToolHit, Head, Target, ToolHit.Position, Head.Position)
                    end
                
                elseif Option == "Door" then
                    safeFireServer(HitRemote, "\240\159\154\168", Tick, Tool, "2389ZFX33", SecurityArg, false, ToolHit, Head, Target, Head.Position, Head.Position)
                
                elseif Option == "Safe" then
                    safeFireServer(HitRemote, "\240\159\154\168", Tick, Tool, "2389ZFX33", SecurityArg, false, ToolHit, Head, Target, Head.Position, Head.Position)
                end
            end
        end

        --// Auto pickup objects
        local PickupDebounce = false
        local PickupObject = function(WaitTime, Remote, ...)
            if not PickupDebounce then
                PickupDebounce = true

                safeFireServer(Remote, ...)

                task.spawn(function()
                    task.wait(WaitTime)
                    PickupDebounce = false
                end)
            end
        end

        --// Lockpick function
        local LockpickDebounce = false
        local Lockpick = function(Obj, Val)
            if not LockpickDebounce then
                LockpickDebounce = true
                local ToolRemote = Tool.Remote
                local SecurityArg = safeInvokeServer(ToolRemote, "S", Obj, Val)
                
                safeInvokeServer(ToolRemote, "D", Obj, Val, SecurityArg)
                safeInvokeServer(ToolRemote, "C")
                
                task.spawn(function()
                    task.wait(1)
                    LockpickDebounce = false
                end)
            end
        end

        --// Unlock door function
        local UnlockDebounce = false
        local UnlockDoor = function(Obj)
            if not UnlockDebounce then
                UnlockDebounce = true
                safeFireServer(Obj.Events.Toggle, "Unlock", Obj.Lock)

                task.spawn(function()
                    task.wait(1)
                    UnlockDebounce = false
                end)
            end
        end

        --// Finish character function
        local FinishCharacter = function(Target)
            local Tick = GunMetadata.__index.cg()
            local Torso = Target and Target:FindFirstChild("Torso")
            local TimeWait = require(Tool.Config).Mains.E.SwingTime;
            local SecurityArg = safeInvokeServer(SwingRemote, "\240\159\154\168", Tick, Tool, "EXECQQ")
        
            if Torso then
                wait(TimeWait)

                if Tool.Name == "Fists" then
                    safeFireServer(HitRemote, "\240\159\154\168", Tick, Tool, "2389ZFX33", SecurityArg, false, Character["Right Leg"], Torso, Target, Character["Right Leg"].Position, Torso.Position)

                elseif Tool.Name ~= "Fists" then
                    safeFireServer(HitRemote, "\240\159\154\168", Tick, Tool, "2389ZFX33", SecurityArg, false, Tool.Handle, Torso, Target, Tool.Handle.Position, Torso.Position)
                end
            end
        end

        --// Set character states function
        local SetAllStates = function(Val)
            local Humanoid = Character and Character:FindFirstChild("Humanoid")
            
            for _,v in pairs(Enum.HumanoidStateType:GetEnumItems()) do
                if v == Enum.HumanoidStateType.None then continue end
                Humanoid:SetStateEnabled(v, Val)
            end
        end

        Toggles.AlwaysSwim:OnChanged(function(state)
            if Character and Character:FindFirstChild("Humanoid") then
                SetAllStates(not state)
            end
        end)
    
        do
            --// Main hitbox expander shit
            local HitboxFunction1 = nil
            local HitboxFunction2 = nil
            
            (function()
                for _, Hitbox in pairs(getgc( true )) do
                    if typeof(Hitbox) == "table" and rawget(Hitbox, "lol") then 
                        HitboxFunction1 = Hitbox.lol
                    end
    
                    if typeof(Hitbox) == "table" and rawget(Hitbox, "ONRH_S4") then
                        HitboxFunction2 = Hitbox.ONRH_S4
                    end
    
                    if HitboxFunction1 and HitboxFunction2 then
                        break
                    end
                end
            end)()

            if not HitboxFunction1 or not HitboxFunction2 then MessageBox("Please report to samuel if this error happens! - X_1", 0) return end
            local HitboxConstants1 = getconstants(HitboxFunction1)
            local HitboxConstants2 = getconstants(HitboxFunction2)

            if not HitboxConstants1 or not HitboxConstants2 then MessageBox("Please report to samuel if this error happens! - X_2", 0) return end
            for Index, Value in pairs(HitboxConstants1) do
                if typeof(Value) ~= "number" then continue end
                setconstant(HitboxFunction1, Index, 12923)
            end

            for Index, Value in pairs(HitboxConstants2) do
                if typeof(Value) ~= "number" then continue end
                setconstant(HitboxFunction2, Index, 12923)
            end
            --// End of hitbox expander shit

            --// Silent aim shit
            local OldEffect = EffectsTable.Effect
            function EffectsTable:Effect(Type, ...)
                local Args = { ... }

                if (Type == "Shoot") then
                    local PlrTool = Args[4]
                    local Origin = Args[5]
                    local Bullets = Args[6]

                    local Hitbox = Target and Target:FindFirstChild(Options.AimHitbox.Value)
                    if PlrTool == Tool and typeof(Bullets) == "table" and typeof(Origin) == "Vector3" then

                        if Hitbox and Toggles.SilentAim.Value and math.random(1, 100) <= Options.Hitchance.Value then
                            for i = 1, #Bullets do
                                Bullets[i] = CFrame.lookAt(Origin, Hitbox.Position).LookVector
                                
                                if Toggles.BulletBeam.Value then
                                    CreateBeam(Origin, Hitbox.Position, Options.BeamStartColor.Value, Options.BeamEndColor.Value)
                                end
                            end
                        end

                        if not Target and Toggles.BulletBeam.Value then
                            for i = 1, #Bullets do
                                CreateBeam(Origin, Mouse.Hit.p, Options.BeamStartColor.Value, Options.BeamEndColor.Value)
                            end
                        end
                    end
                end

                return OldEffect(self, Type, unpack(Args))
            end
            --// End of silent aim shit

            --// Admin detector sound
            local AdminSound = Instance.new('Sound')
            AdminSound.Volume = 2
            AdminSound.Parent = CoreGui
            AdminSound.SoundId = 'rbxassetid://225320558'

            --// Gun mods function
            local ACTIIV = nil
            local OldWrap = getrenv().coroutine.wrap
            setreadonly(getrenv().coroutine, false)
            coroutine.wrap = function(...)
                local Args = { ... }
                local Info = getinfo(Args[1])
                
                if string.find(Info.short_src, "GunClient") and Info.currentline >= 2400 then
                    ACTIIV = Args[1]
                end
                
                return OldWrap(...)
            end
            setreadonly(getrenv().coroutine, true)

            GrabConfig = function()
                if typeof(ACTIIV) ~= "function" then return end
                if not ACTIIV or not getupvalues(ACTIIV) then return end
                if not ACTIIV or ACTIIV and typeof(ACTIIV) ~= "function" then return end
                
                local GetConfig = getupvalue(ACTIIV, 1)
                local Upvalues = getupvalues(GetConfig)
                if #Upvalues >= 4 then
                    local GunTable  = getupvalue(GetConfig, 4)
                    local GunConfig = GunTable and getrawmetatable(GunTable).__index
                    
                    if GunConfig then return GunConfig end
                end
            end
            --// End of gun mod function

            --// Connection functions
            local FlashAdded = function(Child)
                if string.find(Child.Name, "Blind") or string.find(Child.Name, "Flash") and Toggles.NoFlash and Toggles.NoFlash.Value then
                    task.wait(.3) Child:Destroy()
                end
            end

            local ShellAdded = function(Child)
                if Child:IsA("MeshPart") and Toggles.CustomShells and Toggles.CustomShells.Value then
                    Child.Color = Options.ShellColor.Value
                end
            end

            local OnAdminJoined = function(Plr)
                local IsInGroup = function(Plr, Id)
                    local Success, Response = pcall(Plr.IsInGroup, Plr, Id)
                    if Success then 
                        return Response 
                    end
                    return false
                end

                local GetRoleInGroup = function(Plr, Id)
                    local Success, Response = pcall(Plr.GetRoleInGroup, Plr, Id)
                    if Success then
                        return Response
                    end
                    return false
                end

                local GroupStates = { 
                    ["Blackout"] = IsInGroup(Plr, 10911475),
                    ["Criminality"] = IsInGroup(Plr, 4165692)
                }

                if GroupStates.Criminality or GroupStates.Blackout then
                    local Role = GetRoleInGroup(Plr, 4165692)
                    if Role ~= "Fan" or GroupStates.Blackout then
                        if Toggles.AdminDetector.Value then
                            Player:Kick("[Samuelhook] - Detected an Admin/Contributor within the server!")
                            return
                        end

                        AdminSound:Play()
                        Library:Notify("An Admin/Contributor is within this server, please be careful!")
                    end
                end
            end

            local OnCharacter = function(NewCharacter)
                local HumanoidCon1 = Connections["HumanoidCon1"]
                local HumanoidCon2 = Connections["HumanoidCon2"]
                local HumanoidCon3 = Connections["HumanoidCon3"]
                local ChildAddedCon = Connections["ChildAddedCon"]

                if HumanoidCon1 then
                    HumanoidCon1:Disconnect()
                    Connections["HumanoidCon1"] = nil
                end

                if HumanoidCon2 then
                    HumanoidCon2:Disconnect()
                    Connections["HumanoidCon2"] = nil
                end

                if HumanoidCon3 then
                    HumanoidCon3:Disconnect()
                    Connections["HumanoidCon3"] = nil
                end

                if ChildAddedCon then
                    ChildAddedCon:Disconnect()
                    Connections["ChildAddedCon"] = nil
                end

                NewCharacter:WaitForChild("Humanoid")
                NewCharacter:WaitForChild("HumanoidRootPart")
                local Humanoid = NewCharacter and NewCharacter:FindFirstChild("Humanoid")
                local RootPart = Humanoid and NewCharacter:FindFirstChild("HumanoidRootPart")
                
                Connections["HumanoidCon1"] = Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                    if Toggles.WalkSpeed.Value then
                        Humanoid.WalkSpeed = Options.SpeedAmount.Value
                    end

                    if Toggles.NoSlowdown.Value and Humanoid.WalkSpeed > 16 then
                        Humanoid.WalkSpeed = 16
                    end
                end)
                
                Connections["HumanoidCon2"] = RootPart:GetPropertyChangedSignal("CanCollide"):Connect(function()
                    RootPart.CanCollide = not Toggles.Noclip.Value
                end)

                Connections["HumanoidCon3"] = Humanoid.Died:Connect(function()
                    if Toggles.KeepLoot.Value then
                        local inCombat_DK = PlayerStats and PlayerStats.Tags:FindFirstChild("inCombat_DK")
                        
                        if inCombat_DK then
                            while true do end
                        end
                    end

                    if Toggles.AntiAim.Value and AntiAnimation then
                        task.spawn(function()
                            repeat wait() until Humanoid.Health >= 100
                            Humanoid:LoadAnimation(AntiAnimation):Play(13, 57, 270)
                        end)
                    end

                    if Toggles.AutoRespawn.Value then
                        task.spawn(function()
                            repeat safeInvokeServer(Events.DeathRespawn) until Humanoid.Health >= 100
                        end)
                    end
                end)

                Connections["ChildAddedCon"] = NewCharacter.ChildAdded:Connect(function(Child)
                    if Toggles.AntiFire.Value and Child:IsA("Script") and string.find(Child.Name, "BurningScript") then
                        if Child and Child.Parent == NewCharacter then
                            Child:Destroy()
                        end

                        for _,v in pairs(Humanoid:GetPlayingAnimationTracks()) do
                            v:Stop()
                        end

                        for _,v in pairs(NewCharacter:GetDescendants()) do
                            if string.find(v.Name, "Flames") or string.find(v.Name, "PointLight") then
                                v:Destroy()
                            end
                        end
                    end
                end)
            end
            Player.CharacterAdded:Connect(OnCharacter)
            OnCharacter(Character)
            --// End of connection functions

            --// Connections
            -- Controller stuff
            workspace.Debris.VParts.ChildAdded:Connect(function(Child)
                if Child.Name == "RPG_Rocket" then
                    while true do
                        if Toggles.ControlMode.Value and Options.ControlType.Value == "Rocket" then
                            local Index = table.find(workspace.Debris.VParts:GetChildren(), Child)

                            if Index and Child.Transparency < 1 and Child:FindFirstChild("RotPart") then
                                if isnetworkowner(Child.RotPart) then
                                    Child.Anchored = true
                                    Camera.CameraSubject = Child
                                    
                                    if not UserInputService:GetFocusedTextBox() then
                                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then Child.CFrame = Child.CFrame + (Camera.CFrame.LookVector * 1.3) Child.CFrame = CFrame.lookAt(Child.Position, Child.Position + Camera.CFrame.LookVector, Camera.CFrame.UpVector); end
                                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then Child.CFrame = Child.CFrame + (-Camera.CFrame.LookVector * 1.3) Child.CFrame = CFrame.lookAt(Child.Position, Child.Position + Camera.CFrame.LookVector, Camera.CFrame.UpVector); end
                                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then Child.CFrame = Child.CFrame + (-Camera.CFrame.RightVector * 1.3) Child.CFrame = CFrame.lookAt(Child.Position, Child.Position + Camera.CFrame.LookVector, Camera.CFrame.UpVector); end
                                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then Child.CFrame = Child.CFrame + (Camera.CFrame.RightVector * 1.3) Child.CFrame = CFrame.lookAt(Child.Position, Child.Position + Camera.CFrame.LookVector, Camera.CFrame.UpVector); end
                                    end
                                end
                                else Camera.CameraSubject = Character.Humanoid break
                            end
                            else break
                        end
                        task.wait()
                    end
                end
                
                if Child:IsA("Part") and Child.Name == "TransIgnore" then
                    while true do
                        if Toggles.ControlMode.Value and Options.ControlType.Value == "C4" then
                            local Index = table.find(workspace.Debris.VParts:GetChildren(), Child)
                            
                            if Index and Child.Transparency < 1 then
                                if isnetworkowner(Child) then
                                    Child.Anchored = true
                                    Camera.CameraSubject = Child
                                
                                    if not UserInputService:GetFocusedTextBox() then
                                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then Child.CFrame = Child.CFrame + (Camera.CFrame.LookVector * 1.3) Child.CFrame = CFrame.lookAt(Child.Position, Child.Position + Camera.CFrame.LookVector, Camera.CFrame.UpVector); end
                                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then Child.CFrame = Child.CFrame + (-Camera.CFrame.LookVector * 1.3) Child.CFrame = CFrame.lookAt(Child.Position, Child.Position + Camera.CFrame.LookVector, Camera.CFrame.UpVector); end
                                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then Child.CFrame = Child.CFrame + (-Camera.CFrame.RightVector * 1.3) Child.CFrame = CFrame.lookAt(Child.Position, Child.Position + Camera.CFrame.LookVector, Camera.CFrame.UpVector); end
                                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then Child.CFrame = Child.CFrame + (Camera.CFrame.RightVector * 1.3) Child.CFrame = CFrame.lookAt(Child.Position, Child.Position + Camera.CFrame.LookVector, Camera.CFrame.UpVector); end
                                    end
                                end
                                else Camera.CameraSubject = Character.Humanoid break
                            end
                            else break
                        end
                        task.wait()
                    end
                end
            end)
            
            -- Full bright
            Lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
                if Toggles.Fullbright.Value then
                    Lighting.Ambient = Color3.new(1,1,1)
                end
            end)

            -- Debris connection
            workspace.Debris.ChildAdded:Connect(function(Child)
                if string.find(Child.Name, "Smoke") and Toggles.NoSmoke and Toggles.NoSmoke.Value then
                    task.wait(.3) Child:Destroy()
                end

                if string.find(Child.Name, "Bullet") and Child:FindFirstChild("Decal") and Toggles.BulletHoleColor and Toggles.BulletHoleColor.Value then
                    Child.Decal.Color3 = Options.HoleColor.Value
                end
            end)

            -- Flash added
            Camera.ChildAdded:Connect(FlashAdded)
            Player.PlayerGui.ChildAdded:Connect(FlashAdded)

            -- Shell added
            workspace.Debris.VParts.ChildAdded:Connect(ShellAdded)

            -- Admin detection connection
            Players.PlayerAdded:Connect(OnAdminJoined)

            for _,v in pairs(Players:GetPlayers()) do
                if v == Player then continue end
                task.spawn(OnAdminJoined, v)
            end
            --// End of connections

            --// Metamethod hooks
            local OldNewIndex, OldNamecall, OldIndex

            -- Newindex hook
            OldNewIndex = hookmetamethod(workspace, "__newindex", function(t, k, v)
                if t == Camera and k == "CoordinateFrame" and Toggles.NoCameraShake and Toggles.NoCameraShake.Value then 
                    return Vector3.new(0,0,0) 
                end

                if t.ClassName == "Humanoid" and k == "WalkSpeed" and v == 6969 then 
                    return 
                end
                return OldNewIndex(t, k, v)
            end)

            -- Namecall hook
            local ArgTable = {
                ["R"] = {"__--r", "HITRGP"},
                ["F"] = {"FllH", "FlllD"}
            }
            OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                local Args = { ... }
                local Method = getnamecallmethod()
                
                if checkcaller() then
                    return OldNamecall(self, ...)
                end
                
                if Method == "FireServer" then

                    if self.Name == "__DFfDD" then
                        if table.find(ArgTable["R"], Args[1]) and Toggles.NoRagdoll.Value then return end
                        if table.find(ArgTable["F"], Args[1]) and Toggles.NoFallDamage.Value then return end
                        if Args[1] == "BHHh" and Toggles.AntiBarbwire.Value then return end
                    end

                    if Toggles.AntiDrown.Value and self.Name == "TK_DGM" then return end
                    if Toggles.BypassEasy.Value and self.Name == "SayMessageRequest" and string.find(string.lower(Args[1]), "ez") then
                        local Message = Args[1]
                        local SplitMsg = Message:split(" ")
                        local CombineT = {}

                        for i,v in pairs(SplitMsg) do
                            if string.find(string.lower(v), "ez") then
                                v = "˞Ez"
                            end
                            
                            CombineT[i] = v
                        end
                        
                        Message = table.concat(CombineT, " ")
                        Args[1] = Message
                    end
                    if Toggles.NoFlash.Value and self.Name == "Flash" then return end
                    if Toggles.AlwaysHead.Value and self.Name == "ZFKLF_H" and typeof(Args[6]) == "Instance" then Args[6] = Args[6].Parent.Head end
                    if self.Name == "FGRGJBHBEE" then return end
                end
                
                if Toggles.SilentAim.Value and Toggles.InstantHit.Value and Method == "Raycast" then
                    local Hitbox = Target and Target:FindFirstChild(Options.AimHitbox.Value)
                    if Hitbox then
                        Args[2] = (Hitbox.Position - Args[1]).Unit * 2500
                    end
                end

                setnamecallmethod(Method)
                return OldNamecall(self, unpack(Args))
            end))

            OldIndex = hookmetamethod(workspace, "__index", newcclosure(function(epic, epic2)
                if checkcaller() then
                    return OldIndex(epic, epic2)
                end

                if epic2 == "Size" and epic.Name == "Head" then return Vector3.new(1.2000000476837158, 1, 1) end
                if epic2 == "Value" and epic.Name == "Ammo" and Toggles.InfinitePepperspray.Value and Tool and string.find(Tool.Name, "Pepper") then return 100 end
                return OldIndex(epic, epic2)
            end))
            --// End of metamethod hooks
        end

        --// Killevent connection
        Events.KillEvent.OnClientEvent:Connect(function()
            if Toggles.KillSay.Value then
                safeFireServer(ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest, KillSay[math.random(1, #Killsay)], "All")
            end
        end)

        --// Antiaim connection
        PlayerStats:WaitForChild("Downed", 3):GetPropertyChangedSignal("Value"):Connect(function()
            if Toggles.AntiAim.Value then
                Character.Humanoid:LoadAnimation(AntiAnimation):Play(13, 57, 270)
            end
        end)
        
        local PressMouse = nil
        do
            --// Press mouse function
            PressMouse = function()
                local Epicness = UserInputService:GetMouseLocation()
                
                VirtualInputManager:SendMouseButtonEvent(Epicness.X, Epicness.Y, 0, true, game, 1)
                task.wait()
                VirtualInputManager:SendMouseButtonEvent(Epicness.X, Epicness.Y, 0, false, game, 1)
            end
    
            --//Ragdoll function & Anti ragdoll
            local OldRagdoll = getrenv()._G.RagdollChar
            getrenv()._G.RagdollChar = function(...)
                if Toggles.NoRagdoll.Value then
                    return
                end
                return OldRagdoll(...)
            end
    
            --// Bypass adding client things to character
            repeat wait() until Character and Character:FindFirstChild("HumanoidRootPart")
            for _,v in pairs(getconnections(Character.HumanoidRootPart.DescendantAdded)) do
                v:Disable()
            end
    
            --// Esp objects
            local AddObject = function(Obj, Table)
                Esp:AddObjectListener(Obj, Table)
            end
            
            AddObject(Safes, {
                Type = "Model",
                Color = function(Obj)
                    return Obj:FindFirstChild'MainPart' and Obj.MainPart:FindFirstChild'EffectA' and Obj.MainPart.EffectA:FindFirstChild'Sparkle' and Obj.MainPart.EffectA.Sparkle.Color.Keypoints[1].Value or Color3.new(1,1,1);
                end,
    
                PrimaryPart = function(Obj)
                    local MainPart = Obj:FindFirstChild("MainPart")
                    while not MainPart do
                        MainPart = Obj:FindFirstChild("MainPart")
                        task.wait()
                    end
                    return MainPart
                end,
    
                IsEnabled = function(Box)
                    if Toggles.SafeEsp.Value and Options.EspMode.Value["Objects"] then
                        local Obj = Box.PrimaryPart.Parent
                        local Values = Obj and Obj:FindFirstChild("Values")
    
                        if Values and Values:FindFirstChild("Broken") and not Obj.Values.Broken.Value then
                            local Root = Character and Character:FindFirstChild("HumanoidRootPart")
                            local MainPart = Obj and Obj:FindFirstChild("MainPart")
    
                            return true and (Root.Position - MainPart.Position).Magnitude <= Options.EspDistance.Value
                        else
                            return false
                        end
                    end
                end,
    
                CustomName = function(Obj)
                    return (string.find(Obj.Name, 'Register') and 'Register') or (string.find(Obj.Name, 'Small') and 'Small Safe') or (string.find(Obj.Name, 'Medium') and 'Big Safe')
                end
            })
            
            AddObject(Scraps, {
                Type = "Model",
                Color = function(Obj)
                    return Obj:FindFirstChild'MeshPart' and Obj.MeshPart:FindFirstChild'Particle' and Obj.MeshPart.Particle.Color.Keypoints[1].Value or Color3.new(1,1,1);
                end,
    
                PrimaryPart = function(Obj)
                    local MeshPart = Obj:FindFirstChildWhichIsA("MeshPart")
                    while not MeshPart do
                        MeshPart = Obj:FindFirstChildWhichIsA("MeshPart")
                        task.wait()
                    end
                    return MeshPart
                end,
    
                IsEnabled = function(Box)
                    local Obj = Box.PrimaryPart.Parent
    
                    local MeshPart = Obj and Obj:FindFirstChildWhichIsA("MeshPart")
                    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    
                    return Options.EspMode.Value["Objects"] and Toggles.ScrapEsp.Value and (RootPart.Position - MeshPart.Position).Magnitude <= Options.EspDistance.Value
                end,
                CustomName = "Scrap"
            })
    
            AddObject(ATMs, {
                Type = "Model",
                Color = Color3.fromRGB(5, 160, 69),
    
                PrimaryPart = function(Obj)
                    local MainPart = Obj:FindFirstChild("MainPart")
                    while not MainPart do
                        MainPart = Obj:FindFirstChild("MainPart")
                        task.wait()
                    end
                end,
    
                IsEnabled = function(Box)
                    local Obj = Box.PrimaryPart.Parent
                    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
                    local MainPart = Obj and Obj:FindFirstChild("MainPart")
    
                    return Options.EspMode.Value["Objects"] and Toggles.ATMEsp.Value and (RootPart.Position - MainPart.Position).Magnitude <= Options.EspDistance.Value
                end,
                CustomName = 'ATM'
            })
    
            AddObject(Dealers, {
                Type = "Model",
                Color = Color3.fromRGB(50, 100, 255),
    
                PrimaryPart = function(Obj)
                    local MainPart = Obj:FindFirstChild("MainPart")
                    while not MainPart do
                        MainPart = Obj:FindFirstChild("MainPart")
                        task.wait()
                    end
                end,
    
                IsEnabled = function(Box)
                    local Obj = Box.PrimaryPart.Parent
                    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
                    local MainPart = Obj and Obj:FindFirstChild("MainPart")
                    local CurrentStocks = Obj and Obj:FindFirstChild("CurrentStocks")
                    
                    --return Toggles.DealerEsp.Value and (RootPart.Position - MainPart.Position).Magnitude <= Options.EspDistance.Value
                    
                    if not Options.DealerStock.Value["None"] then
                        for _,v in pairs(CurrentStocks:GetChildren()) do
                            if v:IsA("IntConstrainedValue") and v.Value > 0 and Options.DealerStock.Value[v.Name] then
                                return Options.EspMode.Value["Objects"] and Toggles.DealerEsp.Value and (RootPart.Position - MainPart.Position).Magnitude <= Options.EspDistance.Value
                            end
                        end
                        else return Options.EspMode.Value["Objects"] and Toggles.DealerEsp.Value and (RootPart.Position - MainPart.Position).Magnitude <= Options.EspDistance.Value
                    end
                end,
                CustomName = 'Dealer'
            })
    
            AddObject(MysteryBoxes, {
                Type = "Model",
                Color = Color3.fromRGB(255, 1, 255),
                
                PrimaryPart = function(Obj)
                    local MainPart = Obj:FindFirstChild("MainPart")
    
                    while not MainPart do
                        MainPart = Obj:FindFirstChild("MainPart")
                        task.wait()
                    end
                end,
    
                IsEnabled = function(Box)
                    local Obj = Box.PrimaryPart.Parent
                    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
                    local MainPart = Obj and Obj:FindFirstChild("MainPart")
    
                    return Options.EspMode.Value["Objects"] and Toggles.MysteryEsp.Value and RootPart and MainPart and (RootPart.Position - MainPart.Position).Magnitude <= Options.EspDistance.Value
                end,
                CustomName = "Mystery box"
            })
            --// End of esp objects
        end

        --// Global variables
        local Dealer = nil

        --// Heartbeat loop for features
        coroutine.wrap(function()
            RunService.Heartbeat:Connect(function()
                if Circle and OutlineCircle then
                    local MousePosition = UserInputService:GetMouseLocation()
                    
                    OutlineCircle.Visible = Toggles.SilentAim.Value or false
                    OutlineCircle.Radius = Options.FovSize.Value or 1
                    OutlineCircle.NumSides = Options.FovSides.Value or 1
                    OutlineCircle.Position = MousePosition
                    OutlineCircle.Transparency = Options.FovTransparency.Value or 0

                    Circle.Color = Options.FovColor.Value or Color3.new(1,1,1)
                    Circle.Radius = Options.FovSize.Value or 1
                    Circle.NumSides = Options.FovSides.Value or 1
                    Circle.Visible = Toggles.SilentAim.Value or false
                    Circle.Position = Vector2.new(Mouse.X, Mouse.Y + 37)
                    Circle.Transparency = Options.FovTransparency.Value or 0
                end
    
                if Character and Character:FindFirstChild("HumanoidRootPart") then
                    if Toggles.Autoshoot.Value and Tool and Tool:FindFirstChild("IsGun") and not ShootDebounce then
                        local Head = Target and Target:FindFirstChild("Head")
    
                        if Head then
                            ShootGun(Head.Position, Head)
                        end
                    end
    
                    if Toggles.AutobuyLockpicks.Value then
                        local MainPart = Dealer and Dealer:FindFirstChild("MainPart")
                        
                        if MainPart and (Character.HumanoidRootPart.Position - MainPart.Position).Magnitude <= 9 then
                            safeInvokeServer(Events.SSHPRMTE1, Dealer.Type.Value, "Misc", "Lockpick", MainPart, nil, false)
                        end
                    end
                    
                    if Toggles.TriggerBot.Value and Mouse.Target and Mouse.Target.Parent.Parent == workspace.Characters then
                        PressMouse()
                    end
                end
            end)
        end)()

        --// Old gun settings
        local OldGunSettings = {}

        --// While loop for features
        while true do
            local Atm = ClosestObject(ATMs, "Part")
            local Safe = ClosestSafe()
            local Door = ClosestObject(Doors, "DFrame")
            local Enemy = ClosestCharacter()
            Target = ClosestTarget()
            Dealer = ClosestObject(Dealers, "MainPart")

            if Toggles.HighlightTarget.Value and Target then
                Esp.Highlighted = Target
                else Esp.Highlighted = nil
            end

            if Character and Character:FindFirstChild("Humanoid") and Character:FindFirstChild("HumanoidRootPart") and Character:FindFirstChild("Torso") then

                --// Atm related features
                if Atm and Atm:FindFirstChild("MainPart") then
                    if Toggles.AutoClaimAllowance.Value then
                        local NextAllowance = PlayerData2 and PlayerData2:FindFirstChild("NextAllowance")
                        
                        if NextAllowance and NextAllowance.Value <= 0 then
                            local MainPart = Atm:FindFirstChild("MainPart")
                            if (Character.HumanoidRootPart.Position - Atm.MainPart.Position).Magnitude <= 10 then
                                safeInvokeServer(Events.CLMZALOW, Atm.MainPart)
                            end
                        end
                    end

                    if Toggles.BreakNearAtms.Value and (Character.HumanoidRootPart.Position - Atm.MainPart.Position).Magnitude <= 20 then
                        pcall(function()
                            safeInvokeServer(Events.ATM, "WI", Vector3.new(), Atm.MainPart)
                            safeInvokeServer(Events.ATM, "DP", Vector3.new(), Atm.MainPart)
                        end)
                    end
                end

                --// Other related features
                if Toggles.MeleeGod.Value and Character.Humanoid:FindFirstChild("Animator") then
                    Character.Humanoid.Animator:Destroy()
                end

                if Toggles.NoMareBlur and Camera:FindFirstChild("sniper_Blur") then
                    Camera.sniper_Blur.Enabled = false
                end

                if Toggles.JumpPower.Value then
                    Character.Humanoid.JumpHeight = Options.JumpAmount.Value
                end

                if Toggles.NoJumpCooldown.Value and UserInputService:IsKeyDown(Enum.KeyCode.Space) and not UserInputService:GetFocusedTextBox() and Character.Humanoid:GetState() == Enum.HumanoidStateType.Landed then
                    Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end

                if Toggles.AlwaysSwim.Value then
                    SetAllStates(false)
                    Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
                end

                if Toggles.CustomHitsound.Value and Player.PlayerGui:FindFirstChild("MouseGUI") then
                    local MeleeClient = Storage:FindFirstChild("MeleeClient")
                    local Hitmarker = MeleeClient and MeleeClient:FindFirstChild("Hitmarker")
                    local HitmarkerSound = Hitmarker and Player.PlayerGui.MouseGUI:FindFirstChild("HitmarkerSound")

                    if HitmarkerSound and Options.Hitsound.Value ~= "None" then
                        Hitmarker.SoundId = HitSoundTable[Options.Hitsound.Value]
                        HitmarkerSound.SoundId = HitSoundTable[Options.Hitsound.Value]
                    
                        for _, v in pairs(Storage.HitStuff.Main:GetChildren()) do
                            if string.find(v.Name, "Hit") then
                                
                                for _, Obj in pairs(v:GetChildren()) do
                                    if Obj:IsA("Sound") then
                                        Obj.SoundId = HitSoundTable[Options.Hitsound.Value]
                                    end
                                end
                            end
                        end
                    end
                end

                if Toggles.NoBloodScreen.Value then
                    local CurrentGUI = Player.PlayerGui:FindFirstChild("CurrentGUI")
                    local BloodShot  = CurrentGUI:WaitForChild("BloodShot")

                    if BloodShot and BloodShot.Visible then
                        BloodShot.Visible = false

                        for _, v in pairs(Camera:GetChildren()) do
                            if string.find(v.Name, "ColorCorrection") and v.TintColor ~= Color3.fromRGB(255, 255, 255) then
                                v.Enabled = false
                            end
                        end
                    end
                end
                
                if Toggles.WalkSpeed.Value then
                    Character.Humanoid.WalkSpeed = Options.SpeedAmount.Value
                end

                if Toggles.AntiHead.Value then
                    local Neck = Character.Torso:FindFirstChild("Neck")
                    local LeftMotor = Neck and Character.Torso:FindFirstChild("RGAB_Left Shoulder")

                    if LeftMotor then
                        Neck:Destroy()
                        LeftMotor:Destroy()
                    end

                    Character.Head.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, -7, 0)
                end

                if Toggles.Noclip.Value then
                    local TorsoPart = Character.Torso:FindFirstChild("Part")

                    if TorsoPart then
                        TorsoPart.CanCollide = false
                        Character.Head.CanCollide = false
                        Character.Torso.CanCollide = false
                        Character.HumanoidRootPart.CanCollide = false
                    end
                end

                if Toggles.AutoRepairRefill.Value then
                    local MainPart = Dealer and Dealer:FindFirstChild("MainPart")
                    local Backpack = Player:FindFirstChild("Backpack")

                    if MainPart and (Character.HumanoidRootPart.Position - MainPart.Position).Magnitude <= 9 then
                        local BackpackTool = nil
                        if Backpack then
                            for _,v in pairs(Backpack:GetChildren()) do
                                if v:FindFirstChild("IsGun") then
                                    BackpackTool = v
                                end
                            end
                        end

                        local ArmorVest = nil
                        local ArmorHelmet = nil
                        for _,v in pairs(Character:GetChildren()) do
                            if string.find(v.Name, "Vest") then
                                ArmorVest = v
                            end

                            if string.find(v.Name, "Helmet") then
                                ArmorHelmet = v
                            end
                        end

                        local ToolName = ToolBackpack and not Tool and ToolBackpack.Name or not ToolBackpack and Tool and Tool.Name
                        if ToolName then
                            safeInvokeServer(Events.SSHPRMTE1, Dealer.Type.Value, "Guns", ToolName, MainPart, "ResupplyAmmo")
                        end

                        if ArmorVest then
                            safeInvokeServer(Events.SSHPRMTE1, Dealer.Type.Value, "Armour", ArmorVest.Name, MainPart, "ResupplyAmmo")
                        end

                        if ArmorHelmet then 
                            safeInvokeServer(Events.SSHPRMTE1, Dealer.Type.Value, "Armour", ArmorHelmet.Name, MainPart, "ResupplyAmmo")
                        end
                    end
                end

                if Toggles.AutoToolPickup.Value then
                    local Object = ClosestObject(Tools, "MeshPart")
                    local MeshPart = Object and Object:FindFirstChildWhichIsA("MeshPart")
    
                    if MeshPart and (Character.HumanoidRootPart.Position - MeshPart.Position).Magnitude <= 9 then
                        task.spawn(function()
                            task.wait(.3) PickupObject(0.4, Events.PIC_TLO, MeshPart)
                        end)
                    end
                end

                if Toggles.AutoPickup.Value then
                    local ScrapPart = ClosestObject(Scraps, "MeshPart")
                    local MoneyPart = ClosestObject(Moneys, "Value")

                    if ScrapPart and (Character.HumanoidRootPart.Position - ScrapPart.MeshPart.Position).Magnitude <= 9 then
                        local ZpValue = ScrapPart:GetAttribute("zp")
                        PickupObject(0.2, Events.PIC_PU, string.reverse(ZpValue))
                    
                    elseif MoneyPart and (Character.HumanoidRootPart.Position - MoneyPart.Position).Magnitude <= 9 then
                        PickupObject(0.2, Events.CZDPZUS, MoneyPart)
                    end
                end

                if Toggles.AutoTool.Value then
                    local Backpack = Player:FindFirstChild("Backpack")
                    local MainPart = Backpack and Safe:FindFirstChild("MainPart")
                    local SafeType = MainPart and Safe:FindFirstChild("Type")

                    if SafeType and (Character.HumanoidRootPart.Position - MainPart.Position).Magnitude <= 7 then

                        if SafeType.Value >= 2 and Backpack:FindFirstChild("Lockpick") and not Character:FindFirstChild("Lockpick") then
                            Character.Humanoid:EquipTool(Backpack.Lockpick)
                        elseif SafeType.Value < 2 and Backpack:FindFirstChild("Fists") and not Character:FindFirstChild("Fists") then
                            Character.Humanoid:EquipTool(Backpack.Fists)
                        end
                    end
                end

                if Toggles.CameraFov.Value and PlayerStats:FindFirstChild("FOVs") then
                    for _,v in pairs(PlayerStats.FOVs:GetChildren()) do
                        v.Value = Options.FovAmount.Value
                    end
                end

                if Toggles.HitboxExpander.Value then
                    for _,v in pairs(Players:GetPlayers()) do
                        if v == Player then continue end

                        local Char = v.Character
                        local Head = Char and Char:FindFirstChild("Head")

                        if Head then
                            Head.Size = Vector3.new(Options.HitboxAmount.Value, Options.HitboxAmount.Value, Options.HitboxAmount.Value)
                            Head.Transparency = 0.4
                        end
                    end
                end

                if Toggles.InfiniteJump.Value and UserInputService:IsKeyDown(Enum.KeyCode.Space) and not UserInputService:GetFocusedTextBox() then
                    Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
                
                if Toggles.NoSmokeScreen.Value and Player.PlayerGui:FindFirstChild("SmokeScreenGUI") then
                    Players.PlayerGui.SmokeScreenGUI:Destroy()
                end

                --// Closest target features
                if Enemy and Enemy:FindFirstChild("Head") and Enemy:FindFirstChild("HumanoidRootPart") then
                    local EnemyStats = CharStats and CharStats:FindFirstChild(Enemy.Name)
                    local Downed = EnemyStats and EnemyStats:FindFirstChild("Downed")
                    
                    if Toggles.InfiniteBlock.Value and (Character.HumanoidRootPart.Position - Enemy.HumanoidRootPart.Position).Magnitude <= 7 then
                        safeFireServer(HitRemote, "\240\159\154\168", tick(), Tool, "BLSTAZ1")
                    end

                    if Toggles.AutoFinish.Value and (Character.HumanoidRootPart.Position - Enemy.HumanoidRootPart.Position).Magnitude <= 15 and Downed and DownedValue then
                        FinishCharacter(Enemy)
                    end

                    if Toggles.KillAura.Value and Tool and Tool:FindFirstChild("MeleeClient") and (Character.HumanoidRootPart.Position - Enemy.HumanoidRootPart.Position).Magnitude <= Options.AuraRange.Value and Downed and not Downed.Value then

                        if Tool.Name == "Fists" then
                            HitObject("Fist", Character["Right Arm"], Enemy, nil, nil)
                        elseif Tool.Name ~= "Fists" then
                            local SwingTime = require(Tool.Config).Mains.E.SwingTime
                            HitObject("Other", Tool.Handle, Enemy, SwingTime, nil)
                        end
                    end

                    if Toggles.PeppersprayAura.Value and Tool and string.find(Tool.Name, "Pepper") and (Character.HumanoidRootPart.Position - Enemy.HumanoidRootPart.Position).Magnitude <= 9 then
                        safeFireServer(Tool.RemoteEvent, "Spray", true)
                        safeFireServer(Tool.RemoteEvent, "Hit", Enemy)

                        task.spawn(function()
                            task.wait(0.25)
                            if Tool and string.find(Tool.Name, "Pepper") then
                                safeFireServer(Tool.RemoteEvent, "Spray", false)
                            end
                        end)
                    end
                end

                --// Tool related stuff
                if Tool then
                    if Toggles.AutoBreakSafe.Value and Tool:FindFirstChild("MeleeClient") then
                        local Values = Safe and Safe:FindFirstChild("Values")
                        local Broken = Values and Values:FindFirstChild("Broken")
                        local MainPart = Safe and Safe:FindFirstChild("MainPart")

                        if Broken and MainPart and (Character.HumanoidRootPart.Position - MainPart.Position).Magnitude <= 9 then
                            local Handle = Tool.Name == "Fists" and Character["Right Arm"] or Tool.Name ~= "Fists" and Tool.Handle
                            HitObject("Safe", Handle, Safe, nil, "Register")
                        end
                    end

                    if Toggles.AnnoyNearPlayers.Value then
                        safeFireServer(Events.GZ_U, tick(), Tool, "Click")
                    end
                    
                    --// Gun related features
                    if Tool:FindFirstChild("IsGun") and Tool:FindFirstChild("Config") then
                        local Config = require(Tool.Config)
                        local GunConfig = GrabConfig()
                        
                        if Toggles.CustomBullets.Value then
                            Config.BulletSettings.Color = Options.BulletColor.Value
                            Config.BulletSettings.LightColor = Options.BulletColor.Value
                        end
                        
                        if Toggles.NoBulletDrop.Value then
                            Config.Dropoff = 0
                        end
                        
                        if GunConfig then
                            if not OldGunSettings[Tool] then
                                OldGunSettings[Tool] = {}

                                for i,v in pairs(GunConfig) do
                                    if typeof(v) == "table" then
                                        for z,x in pairs(v) do
                                            OldGunSettings[Tool][z] = x
                                        end
                                        else OldGunSettings[Tool][i] = v
                                    end
                                end
                            end
                            
                            local GunSettings = OldGunSettings[Tool]
                            if GunSettings then
                                if Toggles.NoRecoil.Value then
                                    GunConfig.Recoil = 0
                                    GunConfig.Accuracy = 100
                                    GunConfig.AngleX_Min = 0
                                    GunConfig.AngleX_Max = 0
                                    GunConfig.AngleY_Max = 0
                                else
                                    GunConfig.Recoil = GunSettings.Recoil
                                    GunConfig.Accuracy = GunSettings.Accuracy
                                    GunConfig.AngleX_Min = GunSettings.AngleX_Min
                                    GunConfig.AngleX_Max = GunSettings.AngleX_Max
                                    GunConfig.AngleY_Max = GunSettings.AngleY_Max
                                end
                                
                                if Toggles.InstantEquip.Value then
                                    GunConfig.EquipTime = 0.0001
                                    GunConfig.EquipAnimSpeed = 15
                                else
                                    GunConfig.EquipTime = GunSettings.EquipTime
                                    GunConfig.EquipAnimSpeed = GunSettings.EquipAnimSpeed
                                end
                                
                                if GunConfig.AimSettings then
                                    GunConfig.AimSettings.AimSpeed = Toggles.InstantAim.Value and 0.0001 or not Toggles.InstantAim.Value and GunSettings.AimSpeed
                                end
                                
                                if GunConfig.ChargeUpSettings then
                                    GunConfig.ChargeUpSettings.ChargeTime = Toggles.AutoRevolver.Value and 0 or not Toggles.AutoRevolver.Value and GunSettings.ChargeTime
                                end
                            end
                        end
                    end
                end

                --// Door related features
                if Door then
                    local DoorEvents = Door:FindFirstChild("Events")
                    local DoorValues = DoorEvents and Door:FindFirstChild("Values")
                    
                    if DoorValues and (Character.HumanoidRootPart.Position - Door.DFrame.Position).Magnitude <= 9 then
                        if Toggles.LoopLock.Value and not DoorValues.Locked.Value then
                            safeFireServer(DoorEvents.Toggle, "Lock", Door.Lock)
                        end

                        if Toggles.BreakNearDoors.Value and Tool and Tool:FindFirstChild("MeleeClient") then

                            if Tool.Name == "Fists" then
                                HitObject("Door", Character["Right Arm"], Door, nil, "Door")
                            elseif Tool.Name ~= "Fists" then
                                HitObject("Door", Tool.Handle, Door, nil, "Door")
                            end
                        end

                        if Toggles.KnockNearDoors.Value then
                            safeFireServer(DoorEvents.Toggle, "Knock", Door.Knob2)
                        end
                        
                        if Toggles.AutoLockpick.Value and Tool and string.find(Tool.Name, "Lockpick") and DoorValues.Locked.Value then
                            Lockpick(Door, "d")
                        end
                        
                        if Toggles.UnlockNearDoors.Value and DoorValues.Locked.Value then
                            UnlockDoor(Door)
                        end
                    end
                end
                
                --// Safe lockpick feature
                if Toggles.AutoLockpick.Value and Tool and string.find(Tool.Name, "Lockpick") then
                    local MainPart = Safe and Safe:FindFirstChild("MainPart")
                    local SafeValues = MainPart and Safe:FindFirstChild("Values")
                    local SafeType = SafeValues and Safe:FindFirstChild("Type")
                    
                    if SafeType and (Character.HumanoidRootPart.Position - MainPart.Position).Magnitude <= 7 and SafeType.Value >= 2 and not SafeValues.Broken.Value then
                        Lockpick(Safe, "s")
                    end
                end
            end

            task.wait()
        end
    end
end