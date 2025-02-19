local QBCore = exports['qb-core']:GetCoreObject()
local kordinatrandom = 1
-- local sonkomut = 0
-- local Cooldown = 0 
local araccord = Config.AracSpawmncoord
local CurrentBlip = nil
local CurrentBlip2 = nil
local notified = false
local notified2 = false
local arac = nil
local KutuObjesi = nil
local KutuObjesi2 = nil
local paketaracta = false
local gorev = false
local sa = false



Citizen.CreateThread(function()
    RequestModel(GetHashKey(Config.Ped))                -- ped kodu
    while not HasModelLoaded(GetHashKey(Config.Ped)) do -- ped kodu
        Wait(1)
    end
    npc = CreatePed(1, GetHashKey(Config.Ped), Config.PedKordinat.x, Config.PedKordinat.y, Config.PedKordinat.z, Config.PedKordinat.h, false, true) -- ped kodu ve kordinatı
    SetPedCombatAttributes(npc, 46, true)
    SetPedFleeAttributes(npc, 0, 0)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetEntityAsMissionEntity(npc, true, true)
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)
end)



local function Aracspawmn ()
    local player = PlayerPedId()
    local carmodel = Config.AracModel
    local hash = GetHashKey(carmodel)
    RequestModel(hash)

    while not HasModelLoaded(hash) do
        Wait(500)
    end
    SetVehicleEngineHealth(carmodel, 1000.0)
    SetVehicleFixed(carmodel)
    SetVehicleDeformationFixed(carmodel)



    arac = CreateVehicle(carmodel, araccord.x, araccord.y, araccord.z, 349,44, 0, 0)
    TaskWarpPedIntoVehicle(player, arac, -1)
    exports["LegacyFuel"]:SetFuel(arac, 100)
    TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(arac))
    return arac
end


RegisterNetEvent("Wonev-Kargo")
AddEventHandler("Wonev-Kargo", function ()
    if not gorev then
        QBCore.Functions.Notify(Config.GorevAlKomutBildirim)
        gorev = true
        Aracspawmn()
    else
        QBCore.Functions.Notify(Config.Bekle)
    end

    -- if Config.PolisBildirim <= 15 then
    --     TriggerServerEvent('police:server:policeAlert', 'SA')
    -- end
end)


Citizen.CreateThread(function ()
    while true do 
        local bekle = 2000
        local Player = PlayerPedId()
        local PlayerCoords = GetEntityCoords(Player)
        local ped = Config.PedKordinat
        local distance = Vdist(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, ped.x, ped.y, ped.z)
        if distance < 10 then
            bekle = 0
            QBCore.Functions.DrawText3D(ped.x, ped.y, ped.z + 0.9, Config.PedEtkilesim )
            if IsControlJustPressed(0, 38) then
                TriggerEvent("Wonev-Kargo")
            end
        end
        Citizen.Wait(bekle)
    end
    
end)

Citizen.CreateThread(function ()
    local cord = Config.BlipKordinat
    local wonevkargo = AddBlipForCoord(cord.x, cord.y, cord.z)
    SetBlipSprite(wonevkargo, Config.BlipSprite)
    SetBlipScale(wonevkargo, Config.BlipScale)
    SetBlipColour(wonevkargo, Config.BlipColour)
    SetBlipAsShortRange(wonevkargo, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.BlipIsmi)
    EndTextCommandSetBlipName(wonevkargo)
    
end)


RegisterCommand("goreval", function ()
    while true do
        Citizen.Wait(1000)
    if gorev then
        QBCore.Functions.Notify(Config.GorevAraniyor, "primary")
        Citizen.Wait(Config.BeklemeSuresi)
    QBCore.Functions.Notify("Görev Konumu Haritanızda İşaretlendi", "success")
    kordinatrandom = math.random(1, #Config.kordinatlar)
    local cord = Config.kordinatlar[kordinatrandom]  -- Rastgele seçilen koordinat
    CurrentBlip = AddBlipForCoord(cord.x, cord.y, cord.z)  -- Yeni blip ekle
    SetBlipSprite(CurrentBlip, 1)
    SetBlipColour(CurrentBlip, 3)
    SetBlipScale(CurrentBlip, 0.8)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.KargoTeslimBlip)
    EndTextCommandSetBlipName(CurrentBlip)
    SetBlipRoute(CurrentBlip, true)
    SetBlipRouteColour(CurrentBlip, 3)
    notified2 = false
    paketaracta = false
    sa = true
    else
        QBCore.Functions.Notify(Config.NpcIleEtkilesimeGec, "error")
        return
    end
    break
end
-- gorev = false
    
end)





Citizen.CreateThread(function ()
    while true do
        local sleep = 2000

        local player = PlayerPedId()  
        local PlayerCoords = GetEntityCoords(player)  
        local cord = Config.kordinatlar[kordinatrandom]  

        local distance = Vdist(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, cord.x, cord.y, cord.z)  -- Oyuncu ile görev konumu arasındaki mesafeyi hesapla
        if distance < 5 then
            sleep = 0
            if CurrentBlip then
                DrawMarker(2,cord.x, cord.y, cord.z,1.0, 0.0, 0.0,0.0, 0.0, 0.0,0.3, 0.1, 0.3,100, 0, 254, 150,false, false, false,0, false, false, false)
                -- QBCore.Functions.DrawText3D(cord.x, cord.y, cord.z, "[E] Kargoyu Al")
            end
            if distance < 10 and not notified and CurrentBlip then
                QBCore.Functions.Notify(Config.KargoAl, "primary")
                notified = true
            elseif distance >= 5 and notified then  
                notified = false  
            end
            if distance < 5 then 
                if IsControlJustPressed(0, 38) then
                    if CurrentBlip then
                        TriggerEvent("Wonev:progress")
                        RemoveBlip(CurrentBlip)  -- Blip'i kaldır
                        CurrentBlip = nil  -- Blip'i sıfırla
                    end
                end
            end
            
        end
        Citizen.Wait(sleep)
    end

end)


RegisterNetEvent('Wonev:progress', function ()
    QBCore.Functions.Progressbar('progressbar', Config.KargoyuTeslimAliyorsun, Config.KargoTeslimAl, false, true, {
    disableMovement = true,
    disableCarMovement = true,
    disableMouse = true,
    disableCombat = true
    }, {
        animDict = Config.AnimDict,
        anim = Config.Anim,
        flags = 49,
    }, {}, {}, function()
        local player = PlayerPedId()
        local coords = GetEntityCoords(player)
        Citizen.Wait(1000)
        KutuObjesi = CreateObject(GetHashKey(Config.KutuObjesi), coords, true, true, true)
        AttachEntityToEntity(KutuObjesi, player, GetPedBoneIndex(player, 57005), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
        TriggerServerEvent('Wonev-Paket', function()
        end, function()
            QBCore.Functions.Notify(Config.IptalEdildi, 'Error', 2000)
        end)
    end)  
end)

RegisterNetEvent('Wonev:progress2', function ()
QBCore.Functions.Progressbar('progressbar2', Config.KargoyuTeslimEdiyorsun, Config.KargoyuTeslimEt, false, true, {
    disableMovement = true,
    disableCarMovement = true,
    disableMouse = true,
    disableCombat = true
    }, {
        animDict = Config.AnimDict,
        anim = Config.Anim,
        flags = 49,
    }, {}, {}, function()
        DeleteObject(KutuObjesi2)
        KutuObjesi2 = nil
        RemoveBlip(CurrentBlip2)
        TriggerServerEvent("WonevOdeme")
        end, function()
            QBCore.Functions.Notify(Config.IptalEdildi, 'Error', 2000)
        end)
end)



 
RegisterCommand("goreviptal", function ()
    if CurrentBlip then
        QBCore.Functions.Notify( Config.GoreviIptalEttiniz,"success")
        gorev = false
        RemoveBlip(CurrentBlip)  -- Blip'i kaldır
        CurrentBlip = nil  -- Blip'i sıfırla
        if arac then
            DeleteEntity(arac)
            arac = nil
        end
    else
        QBCore.Functions.Notify(Config.GorevinizBulunmamkta, "error")
    end

end)


Citizen.CreateThread(function ()
    while true do
        local sleep = 2000 

        local player = PlayerPedId() 
        local PlayerCoords = GetEntityCoords(player)  
        local araccord = GetEntityCoords(arac)  
        local mesafe = Vdist(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, araccord.x, araccord.y, araccord.z)  
        local teslimatcord = Config.TeslimatKordinat


        if mesafe >= 25.0 then
            if arac then
                DeleteEntity(arac)
                arac = nil
                gorev = false
                QBCore.Functions.Notify(Config.AracinizSilindi)
                if CurrentBlip then
                    RemoveBlip(CurrentBlip)  
                    CurrentBlip = nil  
                    RemoveBlip(CurrentBlip2)
                    CurrentBlip2 = nil  
                    gorev = false
                    QBCore.Functions.Notify(Config.GorevIptalEdildi)
                end
            end
        end
        sa = true

            if mesafe <= 10 and KutuObjesi and not notified2 then
                sleep = 0
                QBCore.Functions.DrawText3D(araccord.x, araccord.y, araccord.z, Config.PaketiAracYukle)
                if mesafe < 5 and sa and IsControlJustPressed(0, 38) then
                    notified2 = true
                    QBCore.Functions.Notify(Config.PaketAracYuklendi)
                    DeleteObject(KutuObjesi) 
                    KutuObjesi = nil
                    paketaracta = true
                    sa = false

                elseif mesafe >= 10 and notified2 then
                    notified2 = false
                    return
                end
            end
            local teslimat = Vdist(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, teslimatcord.x, teslimatcord.y, teslimatcord.z)

            if teslimat <= 10 and CurrentBlip2 then
                sleep = 0
                DrawMarker(2, teslimatcord.x, teslimatcord.y, teslimatcord.z, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.1, 0.3, 100, 0, 254, 150, false, false, false, 0, false, false, false)
            end
            if teslimat < 2 and KutuObjesi2 and IsControlJustPressed(0, 38) then
                TriggerEvent("Wonev:progress2")
                if CurrentBlip2 then
                    RemoveBlip(CurrentBlip2)
                    CurrentBlip2 = nil
                end
            end

            if paketaracta then
                if not CurrentBlip2 then
                    QBCore.Functions.Notify(Config.TeslimatKonumAraniyor, "primary")
                    Citizen.Wait(math.random(4000, 7000))
                    CurrentBlip2 = AddBlipForCoord(teslimatcord.x, teslimatcord.y, teslimatcord.z)  -- Yeni blip ekle
                    SetBlipSprite(CurrentBlip2, 1)
                    SetBlipColour(CurrentBlip2, 3)
                    SetBlipScale(CurrentBlip2, 0.8)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString("Aracın Konumu")
                    EndTextCommandSetBlipName(CurrentBlip2)
                    SetBlipRoute(CurrentBlip2, true)
                    SetBlipRouteColour(CurrentBlip2, 3)
                    QBCore.Functions.Notify(Config.KargoTeslimat, "primary")
                end
                    sleep = 0
                    if teslimat < 5 and not KutuObjesi2 then
                        QBCore.Functions.DrawText3D(araccord.x, araccord.y, araccord.z, Config.PaketiAractanAl)
                    end
                    if teslimat < 10 then
                        if teslimat < 5 and IsControlJustPressed(0, 38) then
                            KutuObjesi2 = CreateObject(GetHashKey(Config.KutuObjesi), PlayerCoords, true, true, true)
                            AttachEntityToEntity(KutuObjesi2, player, GetPedBoneIndex(player, 57005), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
                            QBCore.Functions.Notify(Config.GorevTamamla, "primary")
                            paketaracta = false
                        end
                    end
            end
            Citizen.Wait(sleep)
        end
    end)
  









        -- if mesafe <= 5 and paketaracta and IsControlJustPressed(0, 38) then
        --     print("sa")
        --     sleep = 0
        --     local player = PlayerPedId()
        --     local coords = GetEntityCoords(PlayerPedId())
        --     KutuObjesi2 = CreateObject(GetHashKey("xm3_prop_xm3_product_box_01"), coords, true, true, true)
        --     AttachEntityToEntity(KutuObjesi2, player, GetPedBoneIndex(player, 57005), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
        -- end




-- function Gorev()
--     local cord = Config.kordinatlar[kordinatrandom]
--     local blip = AddBlipForCoord(cord.x, cord.y, cord.z)

--     SetBlipSprite(blip, 1)
--     SetBlipColour(blip, 3)
--     SetBlipScale(blip, 0.8)
--     BeginTextCommandSetBlipName("STRING")
--     AddTextComponentString("Görev Konumu")
--     EndTextCommandSetBlipName(blip)

--     SetNewWaypoint(cord.x, cord.y) -- haritada işaretleme




-- RegisterCommand("goreviptal", function ()
--     if blip then
--         RemoveBlip(blip)
--         QBCore.Functions.Notify("Görev Sonlandırıldı")
--         blip = nil
--     else
--         QBCore.Functions.Notify("Göreviniz Bulunmamakta")
--     end
    
-- end)

-- RegisterCommand("gorev", function ()
--     local oyunsaati = GetGameTimer()
--     if oyunsaati - sonkomut >= Cooldown then
--         QBCore.Functions.Notify("Görev Konumu Haritada İşaretlendi")
--         kordinatrandom = math.random(1, #Config.kordinatlar)
--         Gorev()
--     sonkomut = oyunsaati
--     else
--         QBCore.Functions.Notify("Biraz Beklemelisin", "error")
--     end
-- end)

-- npc ile etkileşime geçilip e basınca mapte rastgele bir konum işaretlenir ve oyuncu o konuma gidince item üzerindeki X item silinip yerine para eklenir