--=====================
-- Praryo Locker Room
--=====================


Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local ESX = nil

function Draw3DText(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)

    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
	ESX.PlayerData = ESX.GetPlayerData()


    playerIdent = ESX.GetPlayerData().identifier
	
    CreateBlips()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)


--===============================
-- Start of the Locker Functions
--===============================

function CreateBlips()
    for k,v in pairs(Config.LockerBlips) do
		local blip = AddBlipForCoord(tonumber(v.mapBlip.x), tonumber(v.mapBlip.y), tonumber(v.mapBlip.z))
		SetBlipSprite(blip, v.mapBlip.sprite)
		SetBlipDisplay(blip, 4)
		SetBlipScale(blip, v.mapBlip.size)
		SetBlipColour(blip, v.mapBlip.color)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(v.name)
		EndTextCommandSetBlipName(blip)
    end
end


Citizen.CreateThread(function()

    while true do
		Citizen.Wait(0)
        local playerCoords = GetEntityCoords(GetPlayerPed(-1))
		local playerPed = PlayerPedId()
        local isClose = false
		
		for k, v in pairs (Config.Lockers) do
			local locker_name = v.locker_name
            local locker_loc = v.location
			local locker_dist = GetDistanceBetweenCoords(playerCoords, locker_loc.x, locker_loc.y, locker_loc.z, 1)
			
			if locker_dist <= 1.0 then
				isClose = true
                Draw3DText(locker_loc.x, locker_loc.y, locker_loc.z, "[E] ".. locker_name)
				if IsControlJustReleased(0, 38) then
					ESX.TriggerServerCallback('pyrp_locker:checkLocker', function(checkLocker)
						LockerMenu(k, checkLocker, locker_name)
					end, k)
				end
			end
			
		end
		
		local lockerExterior = GetDistanceBetweenCoords(playerCoords, Config.LockerExterior.x, Config.LockerExterior.y, Config.LockerExterior.z, 1)
		local lockerInterior = GetDistanceBetweenCoords(playerCoords, Config.LockerInterior.x, Config.LockerInterior.y, Config.LockerInterior.z, 1)
		
		if lockerExterior <= 4.0 then
			isClose = true
			Draw3DText(Config.LockerExterior.x, Config.LockerExterior.y, Config.LockerExterior.z, '[E] Enter Locker Room')
			if IsControlJustReleased(0, 38) then
				SetEntityCoords(playerPed, Config.LockerInterior.x, Config.LockerInterior.y, Config.LockerInterior.z)
				SetEntityHeading(playerPed, 90.0)
				DoScreenFadeIn(800)       
			end
		end
		
		if lockerInterior <= 1.0 then
			isClose = true
			Draw3DText(Config.LockerInterior.x, Config.LockerInterior.y, Config.LockerInterior.z, '[E] Exit Locker Room')
			if IsControlJustReleased(0, 38) then
				SetEntityCoords(playerPed, Config.LockerExterior.x, Config.LockerExterior.y, Config.LockerExterior.z)
				SetEntityHeading(playerPed, 185.0)
				DoScreenFadeIn(800)       
			end
		end
		
		if not isClose then
			Citizen.Wait(3000)
        end
		
	end
	
end)

function LockerMenu(k, hasLocker, lockerName)

	local elements = {}
	
	if hasLocker then
		table.insert(elements, {label = 'Open Locker Stash', value = 'open_locker'})
		table.insert(elements, {label = 'Stop Renting Locker', value = 'stop_renting'})
	end
	
	if not hasLocker then
		table.insert(elements, {label = 'Rent | Initial Rent: <span style="color: green;">$' .. ESX.Math.GroupDigits(Config.InitialRentPrice) .. '</span> | Monthly - <span style="color: green;">$' .. ESX.Math.GroupDigits(Config.DailyRentPrice) .. '</span>', value = 'start_locker'})
	end
	
	ESX.UI.Menu.CloseAll()
	
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'locker_menu', {
		title    = lockerName,
		align    = 'center',
		elements = elements
	}, function(data, menu)

		if data.current.value == 'start_locker' then
			--TriggerServerEvent('pyrp_locker:startRentingLocker', k, lockerName)
			ConfirmLockerRent(k, lockerName)
			menu.close()
		elseif data.current.value == 'stop_renting' then
			--TriggerServerEvent('pyrp_locker:stopRentingLocker', k, lockerName)
			StopLockerRent(k, lockerName)
			menu.close()
		elseif data.current.value == 'open_locker' then
			OpenStash(k, playerIdent, lockerName)
			menu.close()
		end

	end, function(data, menu)
		menu.close()
	end)

end

function ConfirmLockerRent(k, lockerName)

    local elements = {
        {label = 'Yes', value = 'buy_yes'},
        {label = 'No', value = 'buy_no'}
    }

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'confirm_rent_locker', {
        title    = 'Do you want to rent ' .. lockerName .. '',
        align    = 'center',
        elements = elements
    }, function(data, menu)

        if data.current.value == 'buy_yes' then
            menu.close()
			TriggerServerEvent('pyrp_locker:startRentingLocker', k, lockerName)
        elseif data.current.value == 'buy_no' then
            menu.close()
        end

    end, function(data, menu)
        menu.close()
    end)  
end

function StopLockerRent(k, lockerName)

    local elements = {
        {label = 'Yes', value = 'buy_yes'},
        {label = 'No', value = 'buy_no'}
    }

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'cancel_rent_locker', {
        title    = 'Do you want to stop renting the ' .. lockerName .. '',
        align    = 'center',
        elements = elements
    }, function(data, menu)

        if data.current.value == 'buy_yes' then
            menu.close()
			TriggerServerEvent('pyrp_locker:stopRentingLocker', k, lockerName)
        elseif data.current.value == 'buy_no' then
            menu.close()
        end

    end, function(data, menu)
        menu.close()
    end)  
end

function OpenStash(lockerId, identifier, lockerName)
	ESX.TriggerServerCallback("pyrp_locker:getPropertyInventory", function(inventory)
		TriggerEvent("esx_inventoryhud:openLockerInventory", inventory)
	end, identifier, lockerName)
end
