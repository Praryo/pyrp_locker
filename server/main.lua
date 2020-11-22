--=====================
-- Praryo Locker Room
--=====================

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('pyrp_locker:checkLocker', function(source, cb, lockerId)
	local pyrp = source
	local xPlayer = ESX.GetPlayerFromId(pyrp)
	MySQL.Async.fetchAll('SELECT * FROM pyrp_locker WHERE lockerName = @lockerId AND identifier = @identifier', { ['@lockerId'] = lockerId, ['@identifier'] = xPlayer.identifier }, function(result) 
		if result[1] ~= nil then
			cb(true)
		else
			cb(false)
		end	
	end)
end)

--===========================
-- Locker Start/Stop Renting
--===========================

RegisterServerEvent('pyrp_locker:startRentingLocker')
AddEventHandler('pyrp_locker:startRentingLocker', function(lockerId, lockerName) 
	local pyrp = source
	local xPlayer = ESX.GetPlayerFromId(pyrp)
	MySQL.Async.fetchAll('SELECT * FROM pyrp_locker WHERE identifier = @identifier', { ['@identifier'] = xPlayer.identifier }, function(result)
		if result[1] == nil then
			if xPlayer.getMoney() >= Config.InitialRentPrice then
				MySQL.Async.execute('INSERT INTO pyrp_locker (identifier, lockerName) VALUES (@identifier, @lockerId)', {
					['@identifier'] = xPlayer.identifier,
					['@lockerId'] = lockerId
				})
				xPlayer.removeMoney(Config.InitialRentPrice)
				TriggerClientEvent('mythic_notify:client:SendAlert', pyrp, { type = 'success', text = "You started renting " ..lockerName.. ". You will be charged $"..Config.DailyRentPrice.." daily (IRL)", length = 5000 })
			else
				TriggerClientEvent('mythic_notify:client:SendAlert', pyrp, { type = 'error', text = "You don't have enough cash to pay the initial rent price.", length = 5000 })
			end
		else
			TriggerClientEvent('mythic_notify:client:SendAlert', pyrp, { type = 'error', text = "You already have a locker.", length = 5000 })
		end
	end)
end)

RegisterServerEvent('pyrp_locker:stopRentingLocker')
AddEventHandler('pyrp_locker:stopRentingLocker', function(lockerId, lockerName) 
	local pyrp = source
	local xPlayer = ESX.GetPlayerFromId(pyrp)
	MySQL.Async.fetchAll('SELECT * FROM pyrp_locker WHERE lockerName = @lockerId AND identifier = @identifier', { ['@lockerId'] = lockerId, ['@identifier'] = xPlayer.identifier }, function(result)
		if result[1] ~= nil then
			MySQL.Async.execute('DELETE from pyrp_locker WHERE lockerName = @lockerId AND identifier = @identifier', {
				['@lockerId'] = lockerId,
				['@identifier'] = xPlayer.identifier
			})
			TriggerClientEvent('mythic_notify:client:SendAlert', pyrp, { type = 'inform', text = "You cancelled renting this locker.", length = 5000 })
		else
			TriggerClientEvent('mythic_notify:client:SendAlert', pyrp, { type = 'error', text = "You don't own this locker mate.", length = 5000 })
		end
	end)
end)

--=============
-- Pay Rent
--=============

function PayLockerRent(d, h, m)
	MySQL.Async.fetchAll('SELECT * FROM pyrp_locker', {}, function(result)
		for i=1, #result, 1 do
			local xPlayer = ESX.GetPlayerFromIdentifier(result[i].identifier)
			if xPlayer then
				xPlayer.removeAccountMoney('bank', Config.DailyRentPrice)
				TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, { type = 'inform', text = "You paid $"..Config.DailyRentPrice.." for the locker rental.", length = 8000 })
				MySQL.Async.execute('UPDATE pyrp_city_stats SET Funds = Funds + @funds WHERE id = 1', {
					['@funds'] = Config.DailyRentPrice,
				})
			else
				MySQL.Sync.execute('UPDATE users SET bank = bank - @bank WHERE identifier = @identifier', { ['@bank'] = Config.DailyRentPrice, ['@identifier'] = result[i].identifier })
				MySQL.Async.execute('UPDATE pyrp_city_stats SET Funds = Funds + @funds WHERE id = 1', {
					['@funds'] = Config.DailyRentPrice,
				})
			end
		end
	end)
end

TriggerEvent('cron:runAt', 5, 10, PayLockerRent)

--=============
-- Stash
--=============


RegisterServerEvent('pyrp_locker:getItem')
AddEventHandler('pyrp_locker:getItem', function(owner, type, item, count)
	local _source      = source
	local xPlayer      = ESX.GetPlayerFromId(_source)
	local xPlayerOwner = ESX.GetPlayerFromIdentifier(owner)

	if type == 'item_standard' then

		local sourceItem = xPlayer.getInventoryItem(item)

		TriggerEvent('esx_addoninventory:getInventory', 'locker', xPlayerOwner.identifier, function(inventory)
			local inventoryItem = inventory.getItem(item)

			-- is there enough in the property?
			if count > 0 and inventoryItem.count >= count then
			
				-- can the player carry the said amount of x item?
				if sourceItem.limit ~= -1 and (sourceItem.count + count) > sourceItem.limit then
					TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = 'You cannot hold more of this item.', length = 5000 })
				else
					inventory.removeItem(item, count)
					xPlayer.addInventoryItem(item, count)
					TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'inform', text = 'You withdrawn '..count..'x '..inventoryItem.label..' from the stash.', length = 5000 })
				end
			else
				TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = 'You don\'t have more of this item in stash.', length = 5000 })
			end
		end)

	elseif type == 'item_account' then

		TriggerEvent('esx_addonaccount:getAccount', 'locker', xPlayerOwner.identifier, function(account)
			local roomAccountMoney = account.money

			if roomAccountMoney >= count then
				account.removeMoney(count)
				xPlayer.addAccountMoney(item, count)
			else
				TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = 'Invalid amount.', length = 5000 })
			end
		end)

	elseif type == 'item_weapon' then

		TriggerEvent('esx_datastore:getDataStore', 'locker', xPlayerOwner.identifier, function(store)
			local storeWeapons = store.get('weapons') or {}
			local weaponName   = nil
			local ammo         = nil

			for i=1, #storeWeapons, 1 do
				if storeWeapons[i].name == item then
					weaponName = storeWeapons[i].name
					ammo       = storeWeapons[i].ammo

					table.remove(storeWeapons, i)
					break
				end
			end

			store.set('weapons', storeWeapons)
			xPlayer.addWeapon(weaponName, ammo)
		end)

	end

end)

RegisterServerEvent('pyrp_locker:putItem')
AddEventHandler('pyrp_locker:putItem', function(owner, type, item, count)
	local _source      = source
	local xPlayer      = ESX.GetPlayerFromId(_source)
	local xPlayerOwner = ESX.GetPlayerFromIdentifier(owner)

	if type == 'item_standard' then

		local playerItemCount = xPlayer.getInventoryItem(item).count

		if playerItemCount >= count and count > 0 then
			TriggerEvent('esx_addoninventory:getInventory', 'locker', xPlayerOwner.identifier, function(inventory)
				xPlayer.removeInventoryItem(item, count)
				inventory.addItem(item, count)
				TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'inform', text = 'You deposited '..count..'x '..inventory.getItem(item).label..' in stash.', length = 5000 })
			end)
		else
			TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = 'Invalid quantity.', length = 5000 })
		end

	elseif type == 'item_account' then

		local playerAccountMoney = xPlayer.getAccount(item).money

		if playerAccountMoney >= count and count > 0 then
			xPlayer.removeAccountMoney(item, count)

			TriggerEvent('esx_addonaccount:getAccount', 'locker', xPlayerOwner.identifier, function(account)
				account.addMoney(count)
			end)
		else
			TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = 'Invalid amount.', length = 5000 })
		end

	elseif type == 'item_weapon' then

		TriggerEvent('esx_datastore:getDataStore', 'locker', xPlayerOwner.identifier, function(store)
			local storeWeapons = store.get('weapons') or {}

			table.insert(storeWeapons, {
				name = item,
				ammo = count
			})

			store.set('weapons', storeWeapons)
			xPlayer.removeWeapon(item)
		end)

	end

end)

ESX.RegisterServerCallback('pyrp_locker:getPropertyInventory', function(source, cb, owner, lockerName)
	local xPlayer    = ESX.GetPlayerFromIdentifier(owner)
	local blackMoney = 0
	local items      = {}
	local weapons    = {}

	TriggerEvent('esx_addonaccount:getAccount', 'locker', xPlayer.identifier, function(account)
		blackMoney = account.money
	end)

	TriggerEvent('esx_addoninventory:getInventory', 'locker', xPlayer.identifier, function(inventory)
		items = inventory.items
	end)

	TriggerEvent('esx_datastore:getDataStore', 'locker', xPlayer.identifier, function(store)
		weapons = store.get('weapons') or {}
	end)

	cb({
		blackMoney = blackMoney,
		items      = items,
		weapons    = weapons,
		stash_name    = lockerName
	})
end)
