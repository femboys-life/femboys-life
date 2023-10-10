local niggers = { --blackies color
   "Dark orange",
   "Earth orange",
   "Earth yellow",
   "Brown",
   "CGA Brown",
   "Reddish brown",
   "Burnt Sienna",
   "Rust",
   "Really black",
   "Dirt brown",
   "Black"
}
local LocalPlayer = game:GetService("Players").LocalPlayer
if table.find(niggers, tostring(LocalPlayer.Character.Head.BrickColor)) then
   LocalPlayer:Kick("no blackies")
end
