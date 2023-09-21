-- "inspired" from https://v3rmillion.net/showthread.php?tid=1216908
    while true do
        wait(0.1)
        for _, player in pairs(game.Players:GetChildren()) do
            if player.Character and player.Character:FindFirstChild("Head") then
                local imbrickedup = player.Character.Head.BrickColor
                if imbrickedup == BrickColor.new("Medium brown") or imbrickedup == BrickColor.new("Burnt Sienna") or
                    imbrickedup == BrickColor.new("Really black") or imbrickedup == BrickColor.new("Black") or
                    imbrickedup == BrickColor.new("Pine Cone") or imbrickedup == BrickColor.new("Dark taupe") or
                    imbrickedup == BrickColor.new("Reddish brown") or imbrickedup == BrickColor.new("Brown") or
                    imbrickedup == BrickColor.new("CGA brown") or imbrickedup == BrickColor.new("Rust") then
                    if player.Character.Head:FindFirstChild("bootylickermunching") == nil then
                        local bootylickermunching = Instance.new("BillboardGui")
                        local textLabel = Instance.new("TextLabel")
                        bootylickermunching.Adornee = player.Character.Head
                        bootylickermunching.Size = UDim2.new(0, 100, 0, 50)
                        bootylickermunching.StudsOffset = Vector3.new(0, 3, 0)
                        bootylickermunching.AlwaysOnTop = true
                        bootylickermunching.Name = "bootylickermunching"
                        textLabel.BackgroundTransparency = 1
                        textLabel.Size = UDim2.new(0, 100, 0, 50)
                        textLabel.Font = Enum.Font.SourceSans
                        textLabel.Text = ("Blackie: " .. player.Name)
                        textLabel.TextColor3 = Color3.new(1, 0, 0)
                        textLabel.TextScaled = true
                        textLabel.Parent = bootylickermunching;
                        bootylickermunching.Parent = player.Character.Head
                    end
                end
            end
        end
    end

-- for black booty munchers
