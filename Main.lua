local gamesList = {
    [1494262959] = 'Criminality';
    [1390601379] = 'Combat Warriors';
    [358276974]  = 'Apoc 2';
    [3495983524] = 'Apoc 2';
    [187796008]  = 'Those Who Remain';
    [171336322]  = 'testing';
}

local RemoteEvent = Instance.new("RemoteEvent")
local RemoteFunction = Instance.new("RemoteFunction")

local BindableEvent = Instance.new("BindableEvent")
local BindableFunction = Instance.new("BindableFunction")

local safeFireServer = RemoteEvent["FireServer\0"]
local safeInvokeServer = RemoteFunction["InvokeServer\0"]
local safeFireBindable = BindableEvent["Fire\0"]
local safeInvokeBindable = BindableFunction["Invoke\0"]

local MessageBox = function(Msg, Option)
    messagebox(Msg, "samuelhook", 0)
end;

if not game.Players.LocalPlayer.Character then MessageBox("Please spawn in before executing", 0) return end
if _G.ShIn then MessageBox("You're already executed!") return end _G.ShIn = true

--// Sound related stuff (Loads sounds from website)
local SoundsFolder = "samuelhook/sounds/"

local LoadSound = function(FileName)
    return getsynasset('samuelhook/sounds/' .. FileName)
end
--// End of sound related stuff

--// Loads all files and puts them into the hitsound table
local SoundsLoaded = false
local HitSoundTable = {}
local KillSoundTable = {}

task.spawn(function()
    table.foreach(listfiles(SoundsFolder), function(Index, FileName)
        local Split = string.split(FileName, "samuelhook\\sounds\\")
        local Split2 = string.split(Split[2], ".")
        
        if table.find(Split2, "mp3") or table.find(Split2, "wav") then
            local Split3 = string.split(Split2[1], "-")

            if string.find(FileName, "Hitsound") then HitSoundTable[Split3[1]] = LoadSound(Split[2]) end
            if string.find(FileName, "Killsound") then KillSoundTable[Split3[1]] = LoadSound(Split[2]) end
        end
    end)

    SoundsLoaded = true
end)

--// Load the libraries
local Repo         = "https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/"
local Library      = loadstring(game:HttpGet( Repo .. "Library.lua" ))()
local SaveManager  = loadstring(game:HttpGet( Repo .. "addons/SaveManager.lua" ))()
local ThemeManager = loadstring(game:HttpGet( Repo .. "addons/ThemeManager.lua" ))()

repeat wait() until Library and Library.CreateWindow

--// Services
local CoreGui           = game:GetService("CoreGui")
local Players           = game:GetService("Players")
local Lighting          = game:GetService("Lighting")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Variables
local Tool      = nil
local Player    = Players.LocalPlayer
local Mouse     = Player:GetMouse()
local Camera    = workspace.CurrentCamera
local Character = Player.Character or Player.CharacterAdded:Wait()
local SetThread = syn.set_thread_identity

--// Ongoing connections table
local Connections = {}

--// Main Functions to update Character/Tool variables
local OnCharacterAdded = function(NewChar)
    Character = NewChar

    local ToolAddedCon   = Connections["ToolAddedCon"]
    local ToolRemovedCon = Connections["ToolRemovedCon"]

    if ToolAddedCon then
        ToolAddedCon:Disconnect()
        Connections["ToolAddedCon"] = nil
    end

    if ToolRemovedCon then
        ToolRemovedCon:Disconnect()
        Connections["ToolRemovedCon"] = nil
    end

    Connections["ToolAddedCon"] = NewChar.ChildAdded:Connect(function(Obj)
        if Obj:IsA("Model") or Obj:IsA("Tool") then
            Tool = Obj
        end
    end)

    Connections["ToolRemovedCon"] = NewChar.ChildRemoved:Connect(function(Obj)
        if Obj == Tool then 
            Tool = nil 
        end
    end)
end
Player.CharacterAdded:Connect(OnCharacterAdded)
OnCharacterAdded(Character)

--// Create our library window so we can use it later on
local Window = Library:CreateWindow({
    Title = "$amuelhook",
    Center = true,
    AutoShow = true
})

--// Stupid beam function
local CreateBeam = function(Origin, Direction, StartColor, EndColor)
    local StartPart        = Instance.new('Part', workspace);
    local StartAttachment  = Instance.new('Attachment', StartPart);
    StartPart.Size         = Vector3.new(0.5,0.5,0.5);
    StartPart.CFrame       = CFrame.new(Origin);
    StartPart.Anchored     = true;
    StartPart.CanCollide   = false;
    StartPart.Transparency = 1;
    
    local EndPart        = Instance.new('Part', workspace);
    local EndAttachment  = Instance.new('Attachment', EndPart);
    EndPart.Size         = Vector3.new(1,1,1);
    EndPart.CFrame       = CFrame.new(Direction);
    EndPart.Anchored     = true;
    EndPart.CanCollide   = false;
    EndPart.Transparency = 1;
    
    local Beam = Instance.new('Beam', StartPart);
    Beam.FaceCamera = true
    Beam.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, StartColor), ColorSequenceKeypoint.new(1, EndColor) })
    Beam.Texture = 'http://www.roblox.com/asset/?id=7151778302';
    Beam.TextureLength = 3;
    Beam.TextureMode = Enum.TextureMode.Wrap;
    Beam.Attachment0 = StartAttachment
    Beam.Attachment1 = EndAttachment
    Beam.Transparency = NumberSequence.new(0)
    Beam.LightEmission = 6
    Beam.LightInfluence = 1
    Beam.Width0 = 4
    Beam.Width1 = 4

    task.spawn(function()
        task.wait(2)
        for i = 0.5, 1, 0.02 do task.wait()
            Beam.Transparency = NumberSequence.new(i)
        end
        StartPart:Destroy()
        EndPart:Destroy()
    end)
end

--// Kill say table
local KillSays = {
    '🤑 Cry more kid, you died to $amuelhook 🤑';
    '🥶 $ samuelhook $ on top, get it today to become a real gamer! 😲';
    '🤠 Get $amuelhook today if you wanna be as good as me (your a bot rn) 😪';
    '😲 Sit down doggy! You just got 1\'d by $amuelhook $ 🥶';
    '🤑🤑 $$ Couple thousand on my wrist $$ 🤑🤑';
    '🧠🧠 You must really like spectating your team, you\'ll keep losing until you get $ samuelhook $ 🧠🧠';
    '🤓 How do you change your difficulty settings? My game is stuck on easy with all the bots I\'m destroying 🤓';
    'Had fun getting rolled 🤐🤐? 🧠 If you wanna win use $amuelhook🧠';
}