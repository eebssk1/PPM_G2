PPM2 = PPM2 or { }
local shared
shared = function(filein)
  if SERVER then
    AddCSLuaFile('ppm2/' .. filein)
  end
  return include('ppm2/' .. filein)
end
local server
server = function(filein)
  if SERVER then
    return include('ppm2/' .. filein)
  end
end
local client
client = function(filein)
  if SERVER then
    AddCSLuaFile('ppm2/' .. filein)
  end
  if CLIENT then
    return include('ppm2/' .. filein)
  end
end
shared('common/modifier_base.lua')
shared('common/sequence_base.lua')
shared('common/sequence_holder.lua')
shared('common/controller_children.lua')
shared('common/registry.lua')
shared('common/functions.lua')
shared('common/bodygroup_controller.lua')
shared('common/weight_controller.lua')
shared('common/pony_expressions_controller.lua')
shared('common/emotes.lua')
shared('common/flex_controller.lua')
shared('common/registry_data.lua')
shared('common/ponydata.lua')
shared('common/bones_modifier.lua')
shared('common/ponyfly.lua')
shared('common/size_controller.lua')
shared('common/hooks.lua')
shared('common/hoofsteps.lua')
client('client/data_instance.lua')
client('client/materials_registry.lua')
client('client/texture_controller.lua')
client('client/new_texture_controller.lua')
client('client/hooks.lua')
client('client/functions.lua')
client('client/render_controller.lua')
client('client/emotes.lua')
client('client/player_menu.lua')
client('client/editor.lua')
client('client/editor3.lua')
client('client/rag_edit.lua')
client('client/render.lua')
server('server/misc.lua')
server('server/hooks.lua')
server('server/emotes.lua')
server('server/hitgroups.lua')
server('server/rag_edit.lua')
return nil
