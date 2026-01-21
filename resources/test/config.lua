Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)

        NetworkSetFriendlyFireOption(true)
        SetCanAttackFriendly(playerPed, true, true)
        local stuntVehicles = {
            'entityxf',
            'turismor',
            'zentorno',
            'bf400'
        }
        
        -- Ajuster les paramètres de physique lorsque le joueur entre dans un véhicule
        AddEventHandler('playerEnteredVehicle', function(vehicle, seat)
            if seat == -1 then -- Le joueur est le conducteur
                local model = GetEntityModel(vehicle)
                local modelName = GetDisplayNameFromVehicleModel(model)
                
                if contains(stuntVehicles, modelName) then
                    -- Ajuster les paramètres de physique ici
                    SetVehicleGravityAmount(vehicle, 0.5) -- Exemple : ajuster la gravité
                    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMax", 3.0) -- Exemple : ajuster l'adhérence
                end
            end
        end)
        
        -- Fonction utilitaire pour vérifier si un tableau contient une valeur
        function contains(table, val)
            for i = 1, #table do
                if table[i] == val then
                    return true
                end
            end
            return false
        end

        if IsControlJustPressed(1, 166) then
            menu()
        end
    end
end)


etat = false
vehetat = false
Ragdoll = false
noclip = false
invisible = false
seatbealt = false
radioOff = false
parachute = false
engine = false

save1 = null


function showNotification(msg) 
    SetNotificationTextEntry('STRING')
    AddTextComponentString(msg)
    DrawNotification(false, true)
end

function menu()
    local menuTest = RageUI.CreateMenu("Monpote's Mode menu", "Trop BG")
    RageUI.Visible(menuTest, not RageUI.Visible(menuTest))
    while menuTest do
        Citizen.Wait(0)
        RageUI.IsVisible(menuTest, true, true, true, function()
            RageUI.ButtonWithStyle("Vehicule", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    menuTest = RMenu:DeleteType("Titre", true)
                    RageUI.Visible(menuTest, not RageUI.Visible(menuTest))
                    veh()
                end
            end)
            RageUI.ButtonWithStyle("Weapon", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    menuTest = RMenu:DeleteType("Monpote's Mode menu", true)
                    RageUI.Visible(menuTest, not RageUI.Visible(menuTest))
                    weapon()
                end
            end)
            RageUI.ButtonWithStyle("Teleport", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    menuTest = RMenu:DeleteType("Monpote's Mode menu", true)
                    RageUI.Visible(menuTest, not RageUI.Visible(menuTest))
                    tp()
                end
            end)
            RageUI.ButtonWithStyle("World", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    menuTest = RMenu:DeleteType("Titre", true)
                    RageUI.Visible(menuTest, not RageUI.Visible(menuTest))
                    world()
                end
            end)
            RageUI.Checkbox("GodMode", nil, etat, {}, function(Hovered, Active, Selected, Checked)
                if Selected then
                    etat = Checked
                    if etat == true then
                        SetEntityInvincible(PlayerPedId(), true)
                        print("Je suis en GodMode")
                    else
                        SetEntityInvincible(PlayerPedId(), false)
                        print("Je ne suis plus en GodMode")
                    end
                end
            end)
            RageUI.Checkbox("Noclip", nil, noclip, {}, function(Hovered, Active, Selected, Checked)
                if Selected then
                    noclip = Checked
                    local playerPed = PlayerPedId()
                    local isInVehicle = IsPedInAnyVehicle(playerPed, false)
                    local vehicle = nil
                    local speed = 2.0

                    if isInVehicle then
                        vehicle = GetVehiclePedIsIn(playerPed, false)
                    end

                    if noclip == true then
                        SetEntityCollision(playerPed, false, true)
                        SetEntityInvincible(playerPed, true)
                        if isInVehicle then
                            SetEntityCollision(vehicle, false, false)
                            SetEntityInvincible(vehicle, true)
                        end
                        print("NOCLIP ON")
                    else
                        SetEntityCollision(playerPed, true, true)
                        SetEntityInvincible(playerPed, false)
                        if isInVehicle then
                            SetEntityCollision(vehicle, true, true)
                            SetEntityInvincible(vehicle, false)
                        end
                        print("NOCLIP OFF")
                    end
                end
            end)
            local speed = 0.005
            Citizen.CreateThread(function()
                while true do
                    Citizen.Wait(0)
                    if noclip then
                        local playerPed = PlayerPedId()
                        local coords = GetEntityCoords(playerPed)
                        local camCoords = GetGameplayCamCoord()
                        local direction = GetCamRot(camCoords, 2)
                        local isControlPressed = false

                        if IsControlPressed(0, 32) then
                            local directionVector = GetDirectionFromRotation(direction) * speed
                            coords = vector3(coords.x + directionVector.x, coords.y + directionVector.y, coords.z + directionVector.z)
                            isControlPressed = true
                        end
                        if IsControlPressed(0, 33) then
                            local directionVector = GetDirectionFromRotation(direction) * speed
                            coords = vector3(coords.x - directionVector.x, coords.y - directionVector.y, coords.z - directionVector.z)
                            isControlPressed = true
                        end
                        if IsControlPressed(0, 34) then -- Gauche
                            local directionVector = GetDirectionFromRotation(direction) * speed
                            coords = vector3(coords.x - directionVector.y, coords.y + directionVector.x, coords.z)
                            isControlPressed = true
                        end
                        if IsControlPressed(0, 35) then -- Droite
                            local directionVector = GetDirectionFromRotation(direction) * speed
                            coords = vector3(coords.x + directionVector.y, coords.y - directionVector.x, coords.z)
                            isControlPressed = true
                        end
                        if IsControlPressed(0, 22) then
                            coords = vector3(coords.x, coords.y, coords.z + speed)
                            isControlPressed = true
                        end
                        if IsControlPressed(0, 36) then
                            coords = vector3(coords.x, coords.y, coords.z - speed)
                            isControlPressed = true
                        end
                        if isControlPressed then
                            SetEntityCoordsNoOffset(playerPed, coords, true, true, true)
                        end
                    end
                end
            end)
            function GetDirectionFromRotation(rotation)
                local adjustedRotation = (math.pi / 180.0) * rotation
                return vector3(-math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), math.sin(adjustedRotation.x))
            end
            RageUI.Checkbox("No Ragdoll", nil, Ragdoll, {}, function(Hovered, Active, Selected, Checked)
                if Selected then
                    Ragdoll = Checked
                    if Ragdoll == true then
                        SetPedCanRagdoll(PlayerPedId(), false)
                    else
                        SetPedCanRagdoll(PlayerPedId(), true)
                    end
                end
            end)
            RageUI.Checkbox("invisible", nil, invisible, {}, function(Hovered, Active, Selected, Checked)
                if Selected then
                    invisible = Checked
                    if invisible == true then
                        SetEntityVisible(PlayerPedId(), false, 0)
                    else
                        SetEntityVisible(PlayerPedId(), true, 0)
                    end
                end
            end)
        end, function()
        end)
        if not RageUI.Visible(menuTest) then
            menuTest = RMenu:DeleteType("Monpote's Mode menu", true)
        end
    end
end

function loadModel(modelHash)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(1)
        RequestModel(modelHash)
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if radioOff == true then
            if IsPedInAnyVehicle(PlayerPedId(), false) then
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                SetVehRadioStation(vehicle, "OFF")
            end
        end
    end
end)

Citizen.CreateThread(function()
    while True do
        Citizen.Wait(0)
        if engine == true then
            SetVehicleGravityAmount(GetVehiclePedIsIn(PlayerPedId(),false),0.1)
        end
    end
end)

function veh()
    local veh = RageUI.CreateMenu("Veh", "Vehicule")
    RageUI.Visible(veh, not RageUI.Visible(veh))
    while veh do
        Citizen.Wait(0)
        RageUI.IsVisible(veh, true, true, true, function()

            RageUI.ButtonWithStyle("Chercher la voiture", "Entrez le nom du modèle pour obtenir la voiture", {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 30)
                    while (UpdateOnscreenKeyboard() == 0) do
                        DisableAllControlActions(0);
                        Wait(0);
                    end
                    if (GetOnscreenKeyboardResult()) then
                        local result = GetOnscreenKeyboardResult()
                        local vehicleHash = GetHashKey(result)
                        if IsModelInCdimage(vehicleHash) and IsModelAVehicle(vehicleHash) then
                            loadModel(vehicleHash)
                            DeleteEntity(GetVehiclePedIsIn(PlayerPedId(),false))
                            local coords = GetEntityCoords(PlayerPedId(), true)
                            local vehicle = CreateVehicle(vehicleHash, coords, GetEntityHeading(PlayerPedId()), true, false)
                            TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
                            print("Voiture spawnée")
                        else
                            print("Le modèle de voiture n'existe pas")
                        end
                    else 
                        menu()
                    end
                end
              end)

            RageUI.ButtonWithStyle("Repaire", "Repare la voiture", {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                  SetVehicleFixed(GetVehiclePedIsIn(PlayerPedId(), false))
                end
            end)

            RageUI.ButtonWithStyle("Voiture", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    local ped = PlayerPedId()
                    local pos = GetEntityCoords(ped)
                    loadModel("zentorno")
                    DeleteEntity(GetVehiclePedIsIn(PlayerPedId(),false))
                    local vehicle = CreateVehicle("zentorno", pos.x, pos.y, pos.z, GetEntityHeading(ped), true, false)
                    TaskWarpPedIntoVehicle(ped, vehicle, -1)
                end
            end)
            RageUI.ButtonWithStyle("Moto", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    local ped = PlayerPedId()
                    local pos = GetEntityCoords(ped)
                    loadModel("bf400")
                    DeleteEntity(GetVehiclePedIsIn(PlayerPedId(),false))
                    local vehicle = CreateVehicle("bf400", pos.x, pos.y, pos.z, GetEntityHeading(ped), true, false)
                    TaskWarpPedIntoVehicle(ped, vehicle, -1)
                end
            end)

            RageUI.Checkbox("Vehicul GodMode",nil, vehetat, {}, function(Hovered, Active, Selected, Checked)
                if Selected then
                  vehetat = Checked
                  if vehetat==true then
                    SetEntityInvincible(GetVehiclePedIsIn(PlayerPedId(), false), true)
                  else
                    SetEntityInvincible(GetVehiclePedIsIn(PlayerPedId(), false), false)
                  end
                end
              end)
            RageUI.Checkbox("Seat bealt", "IMPOSSIBLE DE QUITTER LE VEHICULE", seatbealt, {}, function(Hovered, Active, Selected, Checked)
              if Selected then
                seatbealt = Checked
                if seatbealt == true then
                  SetPedCanBeKnockedOffVehicle(PlayerPedId(), true)
                else
                  SetPedCanBeKnockedOffVehicle(PlayerPedId(), false)
                end
              end
            end)
            RageUI.Checkbox("Radio auto OFF", "étain directemand la radio", radioOff, {}, function(Hovered, Active, Selected, Checked)
              if Selected then
                radioOff = Checked
              end
            end)
            RageUI.Checkbox("Keep Engine on", "Always Keeps the engine on", engine, {}, function(Hovered, Active, Selected, Checked)
                if Selected then
                    engine = Checked
                end
            end)
            

        end, function()
        end)
        if not RageUI.Visible(veh) then
            veh = RMenu:DeleteType("Veh", true)

            menu()
        end
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if parachute == true then
            GiveWeaponToPed(PlayerPedId(),GetHashKey("gadget_parachute"), 2, false, true)
        end
    end
end)

function weapon()
    local weapon = RageUI.CreateMenu("Weapon", "Weapon")
    RageUI.Visible(weapon, not RageUI.Visible(weapon))
    while weapon do
        Citizen.Wait(0)
        RageUI.IsVisible(weapon, true, true, true, function()

            RageUI.ButtonWithStyle("Chercher l'arme", "Entrez le nom du modèle pour obtenir l'arme", {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 30)
                    while (UpdateOnscreenKeyboard() == 0) do
                        DisableAllControlActions(0);
                        Wait(0);
                    end
                    if (GetOnscreenKeyboardResult()) then
                        local result = GetOnscreenKeyboardResult()
                        local weaponHash = GetHashKey(result)
                        if IsWeaponValid(weaponHash) then
                            GiveWeaponToPed(PlayerPedId(), weaponHash, 9999, false, true)
                            print("Arme donnée")
                        else
                            print("Le modèle d'arme n'existe pas")
                        end
                    else
                        menu()
                    end
                end
            end)
            RageUI.ButtonWithStyle("Pistolet", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    GiveWeaponToPed(PlayerPedId(), "weapon_pistol", 250, false, true)
                end
            end)
            RageUI.ButtonWithStyle("AK47", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    GiveWeaponToPed(PlayerPedId(), "weapon_assaultrifle", 250, false, true)
                end
            end)
            RageUI.ButtonWithStyle("Sniper", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    GiveWeaponToPed(PlayerPedId(), "weapon_sniperrifle", 250, false, true)
                end
            end)
            RageUI.Checkbox("Infinite Parachutes","Gives Infinite Parachutes",parachute,{},function(Hovered,Active,Selected,Checked)
                if Selected then
                    parachute = Checked
                end
                
            end)
        end, function()
        end)
        if not RageUI.Visible(weapon) then
            weapon = RMenu:DeleteType("Weapon", true)

            menu()
        end
    end
end

function tp()
    local tp = RageUI.CreateMenu("Teleport", "Teleport")
    RageUI.Visible(tp, not RageUI.Visible(tp))
    while tp do
        Citizen.Wait(0)
        RageUI.IsVisible(tp, true, true, true, function()
            RageUI.ButtonWithStyle("TP ~r~Marker", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    local WaypointHandle = GetFirstBlipInfoId(8)
                    if DoesBlipExist(WaypointHandle) then
                        local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)
                        for height = 1, 1000 do
                            SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords.x, waypointCoords.y, height + 0.0)
                            local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords.x, waypointCoords.y, height + 0.0)
                            if foundGround then
                                SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords.x, waypointCoords.y, height + 0.0)
                                break
                            end
                            Citizen.Wait(5)
                        end
                    end
                end
            end)
            RageUI.ButtonWithStyle("TP ~g~Maze Bank", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    SetEntityCoords(PlayerPedId(), -75.20296, -819.1085, 326.1754)
                end
            end)
            RageUI.ButtonWithStyle("TP ~g~Areaport", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    SetEntityCoords(PlayerPedId(), -1720.43, -2921.617, 13.94443)
                end
            end)

            RageUI.ButtonWithStyle("~r~Get coords",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                  local coords = GetEntityCoords(PlayerPedId(), false)
                  print(coords)
                end
              end)

             RageUI.ButtonWithStyle("Save Tp",nil,{RightLabel = "→"},true, function(Hovered, Active, Selected)
                if Selected then
                    tp = RMenu:DeleteType("Teleport", true)
                    tpsave()
                end
            end)

        end, function()
        end)
        if not RageUI.Visible(tp) then
            tp = RMenu:DeleteType("Teleport", true)

            menu()
        end
    end
end

function tpsave()
    local tpsave = RageUI.CreateMenu("TP Save", "TP Save")
    RageUI.Visible(tpsave, not RageUI.Visible(tpsave))
    while tpsave do
        Citizen.Wait(0)
        RageUI.IsVisible(tpsave, true, true, true, function()
            RageUI.ButtonWithStyle("save coords 1", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    coords = GetEntityCoords(PlayerPedId(), false)
                    showNotification("Saved")
                    print(coords)
                end
            end)

            RageUI.ButtonWithStyle("Tp saved coords 1",nil,{RightLabel = "→"},true,function(Hovered,Active,Selected)
                if Selected then     
                    SetPedCoordsKeepVehicle(PlayerPedId(), coords.x, coords.y, coords.z)
                    print(save1)
                    showNotification("~g~Tped To the save Location")    
                end
            end)

        end,function()
        end)
        if not RageUI.Visible(tpsave) then
            tpsave = RMenu:DeleteType("TP Save", true)

            tp()
        end
    end
end

function world()
    local world = RageUI.CreateMenu("World", "World")
    RageUI.Visible(world, not RageUI.Visible(world))
    while world do
        Citizen.Wait(0)
        RageUI.IsVisible(world, true, true, true, function()
            RageUI.ButtonWithStyle("Change Time", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    local hours = KeyboardInput("Time Change (0-23)", "", 2)
                    if hours then
                        local hoursNum = tonumber(hours)
                        if hoursNum and hoursNum >= 0 and hoursNum <= 23 then
                            NetworkOverrideClockTime(hoursNum, 0, 0)
                            showNotification("~g~Time set to ".. hours)
                        else
                            showNotification("~r~Invalide Time prompte")
                        end
                    end
                end
            end)
            
        end, function()
        end)
        if not RageUI.Visible(world) then
            world = RMenu:DeleteType("World", true)

            menu()
        end
    end
end

function KeyboardInput(textEntry, exampleText, maxStringLength)
    AddTextEntry('FMMC_KEY_TIP1', textEntry)
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", exampleText, "", "", "", maxStringLength)
    blockinput = true

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
        blockinput = false
        return result
    else
        Citizen.Wait(500)
        blockinput = false
        return nil
    end
end
