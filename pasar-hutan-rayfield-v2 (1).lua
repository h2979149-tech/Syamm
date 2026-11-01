-- [[ NOOB-HUB: PASAR HUTAN AUTO-FARM V2 WITH RAYFIELD UI ]]
if not game:IsLoaded() then game.Loaded:Wait() end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Noob-Hub: Pasar Hutan",
   LoadingTitle = "Loading Script Hub...",
   LoadingSubtitle = "by Noob-Hub",
   ConfigurationSaving = {
      Enabled = false
   },
   Discord = {
      Enabled = false
   },
   KeySystem = false
})

local Tab = Window:CreateTab("Lahan & Bibit", nil)

local Config = {
    AutoFarm = false,
    AutoBuySeed = false,
    SeedName = "Kubis",
    BuyAmount = 10,
    MinWait = 0.2,
    MaxWait = 0.5
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

local function getSeedCount(seedName)
    local count = 0
    pcall(function()
        local inventory = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("Backpack") or LocalPlayer.Character:FindFirstChild("Tools")
        if inventory then
            local seedItem = inventory:FindFirstChild(seedName)
            if seedItem and seedItem:FindFirstChild("Amount") then
                count = seedItem.Amount.Value
            else
                for _, item in pairs(inventory:GetChildren()) do
                    if item.Name == seedName then
                        count = count + 1
                    end
                end
            end
        end
    end)
    return count
end

local function getMyPlot()
    for _, plot in pairs(workspace.Plots:GetChildren()) do
        if plot:FindFirstChild("Owner") and (plot.Owner.Value == LocalPlayer.Name or plot.Owner.Value == LocalPlayer.DisplayName) then
            return plot
        end
    end
    return nil
end

Tab:CreateToggle({
   Name = "Otomatis Tanam & Siram (Auto Farm)",
   CurrentValue = false,
   Callback = function(Value)
      Config.AutoFarm = Value
   end,
})

Tab:CreateToggle({
   Name = "Beli Bibit Otomatis (Auto Buy Seed)",
   CurrentValue = false,
   Callback = function(Value)
      Config.AutoBuySeed = Value
   end,
})

Tab:CreateDropdown({
   Name = "Pilih Jenis Bibit",
   Options = {"Kubis","Kentang","Jagung","Paprika","Corn"},
   CurrentOption = {"Kubis"},
   MultipleOptions = false,
   Callback = function(Option)
      Config.SeedName = Option[1]
   end,
})

Tab:CreateSlider({
   Name = "Jumlah Beli Bibit",
   Min = 5,
   Max = 50,
   CurrentValue = 10,
   Increment = 5,
   ValueName = "Bibit",
   Callback = function(Value)
      Config.BuyAmount = Value
   end,
})

task.spawn(function()
    while true do
        task.wait(0.1)
        if Config.AutoFarm then
            local myPlot = getMyPlot()
            if myPlot and myPlot:FindFirstChild("GardenBeds") then
                if Config.AutoBuySeed and getSeedCount(Config.SeedName) <= 0 then
                    pcall(function()
                        game:GetService("ReplicatedStorage").RemoteEvents.BuySeed:FireServer(Config.SeedName, Config.BuyAmount)
                    end)
                    task.wait(1)
                end

                for _, bed in pairs(myPlot.GardenBeds:GetChildren()) do
                    if not Config.AutoFarm then break end
                    local randomWait = math.random(Config.MinWait * 100, Config.MaxWait * 100) / 100

                    if bed:FindFirstChild("Status") and bed.Status.Value == "Empty" then
                        if getSeedCount(Config.SeedName) > 0 then
                            pcall(function()
                                game:GetService("ReplicatedStorage").RemoteEvents.PlantSeed:FireServer(bed, Config.SeedName)
                            end)
                            task.wait(randomWait)
                        end
                    end

                    if bed:FindFirstChild("Status") and bed.Status.Value == "Dry" then
                        pcall(function()
                            game:GetService("ReplicatedStorage").RemoteEvents.WaterPlant:FireServer(bed)
                        end)
                        task.wait(randomWait)
                    end

                    if bed:FindFirstChild("Status") and bed.Status.Value == "Ready" then
                        pcall(function()
                            game:GetService("ReplicatedStorage").RemoteEvents.HarvestPlant:FireServer(bed)
                        end)
                        task.wait(randomWait)
                    end
                end
            end
        end
    end
end)

Rayfield:Notify({
   Title = "Noob-Hub Loaded!",
   Content = "Skrip berhasil diaktifkan. Klaim lahan sebelum mengaktifkan fitur.",
   Duration = 5,
   Image = nil,
})
