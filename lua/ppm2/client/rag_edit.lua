local ALLOW_ONLY_RAGDOLLS = CreateConVar('ppm2_sv_edit_ragdolls_only', '0', {
  FCVAR_NOTIFY,
  FCVAR_REPLICATED
}, 'Allow to edit only ragdolls')
local DISALLOW_PLAYERS = CreateConVar('ppm2_sv_edit_no_players', '1', {
  FCVAR_NOTIFY,
  FCVAR_REPLICATED
}, 'When unrestricted edit allowed, do not allow to edit players.')
local genericEditFilter
genericEditFilter = function(self, ent, ply)
  if ent == nil then
    ent = NULL
  end
  if ply == nil then
    ply = NULL
  end
  if not IsValid(ent) then
    return false
  end
  if not IsValid(ply) then
    return false
  end
  if not ent:IsPony() then
    return false
  end
  if ALLOW_ONLY_RAGDOLLS:GetBool() and ent:GetClass() ~= 'prop_ragdoll' then
    return false
  end
  if DISALLOW_PLAYERS:GetBool() and ent:IsPlayer() then
    return false
  end
  if not ply:GetPonyData() then
    return false
  end
  if not hook.Run('CanProperty', ply, 'ponydata', ent) then
    return false
  end
  if not hook.Run('CanTool', ply, {
    Entity = ent,
    HitPos = ent:GetPos(),
    HitNormal = Vector()
  }, 'ponydata') then
    return false
  end
  return true
end
local applyPonyData = {
  MenuLabel = 'Apply pony data...',
  Order = 2500,
  MenuIcon = 'icon16/user.png',
  MenuOpen = function(self, menu, ent, tr)
    if ent == nil then
      ent = NULL
    end
    if not IsValid(ent) then
      return 
    end
    do
      local _with_0 = menu:AddSubMenu()
      _with_0:AddOption('Use Local data', function()
        net.Start('PPM2.RagdollEdit')
        net.WriteEntity(ent)
        net.WriteBool(true)
        return net.SendToServer()
      end)
      _with_0:AddSpacer()
      for _, fil in ipairs(PPM2.PonyDataInstance:FindFiles()) do
        _with_0:AddOption("Use '" .. tostring(fil) .. "' data", function()
          net.Start('PPM2.RagdollEdit')
          net.WriteEntity(ent)
          net.WriteBool(false)
          local data = PPM2.PonyDataInstance(fil, nil, true, true, false)
          data:WriteNetworkData()
          return net.SendToServer()
        end)
      end
      return _with_0
    end
  end,
  Filter = genericEditFilter,
  Action = function(self, ent)
    if ent == nil then
      ent = NULL
    end
  end
}
local ponyDataFlexEnable = {
  MenuLabel = 'Enable flexes',
  Order = 2501,
  MenuIcon = 'icon16/emoticon_smile.png',
  MenuOpen = function(self, menu, ent, tr)
    if ent == nil then
      ent = NULL
    end
  end,
  Filter = function(self, ent, ply)
    if ent == nil then
      ent = NULL
    end
    if ply == nil then
      ply = NULL
    end
    if not genericEditFilter(self, ent, ply) then
      return false
    end
    if not ent:GetPonyData() then
      return false
    end
    if not ent:GetPonyData():GetNoFlex() then
      return false
    end
    return true
  end,
  Action = function(self, ent)
    if ent == nil then
      ent = NULL
    end
    if not IsValid(ent) then
      return 
    end
    net.Start('PPM2.RagdollEditFlex')
    net.WriteEntity(ent)
    net.WriteBool(false)
    return net.SendToServer()
  end
}
local ponyDataFlexDisable = {
  MenuLabel = 'Disable flexes',
  Order = 2501,
  MenuIcon = 'icon16/emoticon_unhappy.png',
  MenuOpen = function(self, menu, ent, tr)
    if ent == nil then
      ent = NULL
    end
  end,
  Filter = function(self, ent, ply)
    if ent == nil then
      ent = NULL
    end
    if ply == nil then
      ply = NULL
    end
    if not genericEditFilter(self, ent, ply) then
      return false
    end
    if not ent:GetPonyData() then
      return false
    end
    if ent:GetPonyData():GetNoFlex() then
      return false
    end
    return true
  end,
  Action = function(self, ent)
    if ent == nil then
      ent = NULL
    end
    if not IsValid(ent) then
      return 
    end
    net.Start('PPM2.RagdollEditFlex')
    net.WriteEntity(ent)
    net.WriteBool(true)
    return net.SendToServer()
  end
}
local playEmote = {
  MenuLabel = 'Play pony emote',
  Order = 2502,
  MenuIcon = 'icon16/emoticon_wink.png',
  MenuOpen = function(self, menu, ent, tr)
    if ent == nil then
      ent = NULL
    end
    if not IsValid(ent) then
      return 
    end
    do
      local _with_0 = menu:AddSubMenu()
      for _, _des_0 in ipairs(PPM2.AVALIABLE_EMOTES) do
        local name, sequence, id, time
        name, sequence, id, time = _des_0.name, _des_0.sequence, _des_0.id, _des_0.time
        _with_0:AddOption("Play '" .. tostring(name) .. "' emote", function()
          net.Start('PPM2.RagdollEditEmote')
          net.WriteEntity(ent)
          net.WriteUInt(id, 8)
          net.SendToServer()
          return hook.Call('PPM2_EmoteAnimation', nil, ent, sequence, time)
        end)
      end
      return _with_0
    end
  end,
  Filter = function(self, ent, ply)
    if ent == nil then
      ent = NULL
    end
    if ply == nil then
      ply = NULL
    end
    if not genericEditFilter(self, ent, ply) then
      return false
    end
    if not ent:GetPonyData() then
      return false
    end
    if ent:GetPonyData():GetNoFlex() then
      return false
    end
    return true
  end,
  Action = function(self, ent)
    if ent == nil then
      ent = NULL
    end
  end
}
properties.Add('ppm2.applyponydata', applyPonyData)
properties.Add('ppm2.enableflex', ponyDataFlexEnable)
properties.Add('ppm2.disableflex', ponyDataFlexDisable)
return properties.Add('ppm2.playemote', playEmote)
