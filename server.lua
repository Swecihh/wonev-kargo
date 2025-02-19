local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("Wonev-Paket")
AddEventHandler("Wonev-Paket", function() 
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        Player.Functions.AddItem(Config.Item, Config.ItemMiktar)
        TriggerClientEvent('QBCore:Notify', source, Config.KargoPaketiAldiniz, "success", 3000)
    end
end)

RegisterNetEvent("WonevOdeme")
AddEventHandler("WonevOdeme", function ()
    local source = source 
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        Player.Functions.RemoveItem(Config.Item, Config.ItemMiktar)
        Player.Functions.AddMoney(Config.OdemeSekli , Config.VerilecekPara , Config.TeslimatSonu)
    end
end)