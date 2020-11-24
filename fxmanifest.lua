fx_version 'adamant'
game 'gta5'

description 'Praryo RP Locker'
version '1.0.0'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'config.lua',
	'client/main.lua',
}
