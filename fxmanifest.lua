fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Vector'
description 'The Coke run!'

version 'v1.0.0'

shared_scripts {
  'config.lua',
  '@es_extended/imports.lua'
}

client_scripts {
  'client/cl.lua',
  'client/clFunctions.lua',
} 

server_scripts {
  '@es_extended/imports.lua',
  'server/sv.lua'
}

escrow_ignore {
  'config.lua'
}