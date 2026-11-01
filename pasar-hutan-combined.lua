-- [[ NOOB-HUB: COMBINED LOADER & GARDEN AUTO-FARM + AUTO-BUY ]]
print("[Noob-Hub] Running Combined Script...")

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

-- Anti-AFK Bypasser
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- Konfigurasi & Pengaturan Fitur
local Config = {
    AutoFarm = true,
    AutoBuySeed = true,    -- Aktifkan beli bibit otomatis
    SeedName = "Kubis",   -- Nama bibit yang ingin ditanam & dibeli (Ganti sesuai kebutuhan)
    BuyAmount = 10,        -- Jumlah bibit yang dibeli setiap kali habis
    MinWait = 0.2,         -- Jeda minimal keamanan (detik)
    MaxWait = 0.5          -- Jeda maksimal keamanan (detik)
}

-- Fungsi Cek Sisa Bibit di Inventory / Tas Pemain
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

-- Fungsi Mendapatkan Plot Lahan Milik Pemain
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

-- Fungsi Utama Siklus Pertanian & Pembelian Otomatis
task.spawn(function()
    while Config.AutoFarm do
        task.wait(0.1)
        
        local myPlot = getMyPlot()
        if not myPlot then
            task.wait(3)
            continue
        end

        -- Jalankan Pengecekan Stok Bibit jika Fitur Auto-Buy Aktif
        if Config.AutoBuySeed and getSeedCount(Config.SeedName) <= 0 then
            pcall(function()
                game:GetService("ReplicatedStorage").RemoteEvents.BuySeed:FireServer(Config.SeedName, Config.BuyAmount)
            end)
            task.wait(1)
        end

        -- Proses Menanam, Menyiram, dan Memanen
        if myPlot:FindFirstChild("GardenBeds") then
            for _, bed in pairs(myPlot.GardenBeds:GetChildren()) do
                if not Config.AutoFarm then break end
                
                local randomWait = math.random(Config.MinWait * 100, Config.MaxWait * 100) / 100
                
                -- 1. Tanam Otomatis instan
                if bed:FindFirstChild("Status") and bed.Status.Value == "Empty" then
                    if getSeedCount(Config.SeedName) > 0 then
                        pcall(function()
                            game:GetService("ReplicatedStorage").RemoteEvents.PlantSeed:FireServer(bed, Config.SeedName)
                        end)
                        task.wait(randomWait)
                    end
                end
                
                -- 2. Siram Cepat (Instant Water)
                if bed:FindFirstChild("Status") and bed.Status.Value == "Dry" then
                    pcall(function()
                        game:GetService("ReplicatedStorage").RemoteEvents.WaterPlant:FireServer(bed)
                    end)
                    task.wait(randomWait)
                end
                
                -- 3. Panen Otomatis (Harvest)
                if bed:FindFirstChild("Status") and bed.Status.Value == "Ready" then
                    pcall(function()
                        game:GetService("ReplicatedStorage").RemoteEvents.HarvestPlant:FireServer(bed)
                    end)
                    task.wait(randomWait)
                end
            end
        end
    end
end)

print("[Noob-Hub] Skrip Pertanian Gabungan Berhasil Dijalankan!")
