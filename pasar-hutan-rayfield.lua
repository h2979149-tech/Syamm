-- [[ NOOB-HUB: PASAR HUTAN RAYFIELD UI ]]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Noob-Hub | Pasar Hutan",
   LoadingTitle = "Loading Script Hub...",
   LoadingSubtitle = "by Noob-Hub",
   ConfigurationSaving = {
      Enabled = true,
      Folder = "NoobHubConfig",
      FileName = "PasarHutan"
   },
   Discord = {
      Enabled = false,
      Invite = "",
      RememberJoins = true
   },
   KeySystem = false
})

local Tab = Window:CreateTab("Auto Farm", 4483362458)

local Config = {
    AutoFarm = false,
    AutoBuySeed = false,
    SeedName = "Tomato",
    BuyAmount = 10,
    MinWait = 0.2,
    MaxWait = 0.5
}

-- Anti-AFK
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
        local inventory = LocalPlayer:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("Backpack")
        if inventory then
            local seedItem = inventory:FindFirstChild(seedName)
            if seedItem and seedItem:FindFirstChild("Amount") then
                count = seedItem.Amount.Value
            elseif seedItem then
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
    local success, result = pcall(function()
        for _, plot in pairs(workspace.Plots:GetChildren()) do
            if plot:FindFirstChild("Owner") and plot.Owner.Value == LocalPlayer.Name then
                return plot
            end
        end
    end)
    return success and result or nil
end

Tab:CreateToggle({
   Name = "Auto Farm (Tanam, Siram, Panen)",
   CurrentValue = false,
   Flag = "ToggleAutoFarm",
   Callback = function(Value)
      Config.AutoFarm = Value
   end,
})

Tab:CreateToggle({
   Name = "Auto Buy Seed",
   CurrentValue = false,
   Flag = "ToggleAutoBuy",
   Callback = function(Value)
      Config.AutoBuySeed = Value
   end,
})

Tab:CreateDropdown({
   Name = "Pilih Jenis Bibit",
   Options = {"Tomato","Carrot","Berry"},
   CurrentOption = {"Tomato"},
   MultipleOptions = false,
   Flag = "DropdownSeed",
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
   Flag = "SliderBuyAmount",
   Callback = function(Value)
      Config.BuyAmount = Value
   end,
})

task.spawn(function()
    while true do
        task.wait(0.1)
        if Config.AutoFarm then
            local myPlot = getMyPlot()
            if myPlot then
                if Config.AutoBuySeed and getSeedCount(Config.SeedName) <= 0 then
                    pcall(function()
                        game:GetService("ReplicatedStorage").RemoteEvents.BuySeed:FireServer(Config.SeedName, Config.BuyAmount)
                    end)
                    task.wait(1)
                end

                if myPlot:FindFirstChild("GardenBeds") then
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
    end
end)

Rayfield:Notify({
   Title = "Noob-Hub Active",
   Content = "Skrip Berhasil Dimuat!",
   Duration = 5,
   Image = 4483362458,
})
