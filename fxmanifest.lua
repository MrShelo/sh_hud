fx_version 'cerulean'
games {'gta5'}

author 'MrShelo'
version '1.0.0'

lua54 'yes'

ui_page 'ui/ui.html' 

files {
    "ui/assets/*",
    'ui/ui.html',
    'ui/style.css',
    'ui/script.js',
}

shared_scripts {
    'config.lua',
}

client_scripts {
	'client/client.lua'
}
