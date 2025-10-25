fx_version 'cerulean'
game 'gta5'

name "bel_handling"
description "Handling Vehicle System for All GTA 5 Cars by Belmont0101"
author "Belmont0101"
version "0.0.1"

shared_scripts {
	'shared/config.lua',
	'shared/vehicles.lua'
}

client_scripts {
	'client/main.lua',
	'client/menu.lua',
	'client/debug.lua'
}

server_scripts {
	'server/*.lua'
}
