local ALLOW_ONLY_RAGDOLLS = CreateConVar('ppm2_sv_edit_ragdolls_only', '0', {
  FCVAR_NOTIFY,
  FCVAR_REPLICATED
}, 'Allow to edit only ragdolls')
local DISALLOW_PLAYERS = CreateConVar('ppm2_sv_edit_no_players', '1', {
  FCVAR_NOTIFY,
  FCVAR_REPLICATED
}, 'When unrestricted edit allowed, do not allow to edit players.')
local genericUsageCheck
genericUsageCheck = function(ply, ent)
  if not IsValid(ply) then
    return false
  end
  if not IsValid(ent) then
    return false
  end
  if ALLOW_ONLY_RAGDOLLS:GetBool() and ent:GetClass() ~= 'prop_ragdoll' then
    return false
  end
  if DISALLOW_PLAYERS:GetBool() and ent:IsPlayer() then
    return false
  end
  if not ent:IsPony() then
    return false
  end
  if not hook.Run('CanTool', ply, {
    Entity = ent,
    HitPos = ent:GetPos(),
    HitNormal = Vector()
  }, 'ponydata') then
    return false
  end
  if not hook.Run('CanProperty', ply, 'ponydata', ent) then
    return false
  end
  return true
end
net.Receive('PPM2.RagdollEdit', function(len, ply)
  if len == nil then
    len = 0
  end
  if ply == nil then
    ply = NULL
  end
  local ent = net.ReadEntity()
  local useLocal = net.ReadBool()
  if not genericUsageCheck(ply, ent) then
    return 
  end
  if useLocal then
    if not ply:GetPonyData() then
      return 
    end
    if not ent:GetPonyData() then
      local data = PPM2.NetworkedPonyData(nil, ent)
    end
    local data = ent:GetPonyData()
    local plydata = ply:GetPonyData()
    plydata:ApplyDataToObject(data)
    if not data:IsNetworked() then
      data:Create()
    end
  else
    if not ent:GetPonyData() then
      local data = PPM2.NetworkedPonyData(nil, ent)
    end
    local data = ent:GetPonyData()
    data:ReadNetworkData(len, ply, false, false)
    data:ReBroadcast()
    if not data:IsNetworked() then
      data:Create()
    end
  end
  return duplicator.StoreEntityModifier(ent, 'ppm2_ragdolledit', ent:GetPonyData():NetworkedIterable(false))
end)
net.Receive('PPM2.RagdollEditFlex', function(len, ply)
  if len == nil then
    len = 0
  end
  if ply == nil then
    ply = NULL
  end
  local ent = net.ReadEntity()
  local status = net.ReadBool()
  if not genericUsageCheck(ply, ent) then
    return 
  end
  if not ent:GetPonyData() then
    local data = PPM2.NetworkedPonyData(nil, ent)
  end
  local data = ent:GetPonyData()
  data:SetNoFlex(status)
  if not data:IsNetworked() then
    return data:Create()
  end
end)
net.Receive('PPM2.RagdollEditEmote', function(len, ply)
  if len == nil then
    len = 0
  end
  if ply == nil then
    ply = NULL
  end
  local ent = net.ReadEntity()
  if not genericUsageCheck(ply, ent) then
    return 
  end
  local self = ply
  local emoteID = net.ReadUInt(8)
  if not PPM2.AVALIABLE_EMOTES[emoteID] then
    return 
  end
  self.__ppm2_last_played_emote = self.__ppm2_last_played_emote or 0
  if self.__ppm2_last_played_emote > RealTimeL() then
    return 
  end
  self.__ppm2_last_played_emote = RealTimeL() + 1
  net.Start('PPM2.PlayEmote')
  net.WriteUInt(emoteID, 8)
  net.WriteEntity(ent)
  return net.SendOmit(ply)
end)
return duplicator.RegisterEntityModifier('ppm2_ragdolledit', function(ply, ent, storeddata)
  if ply == nil then
    ply = NULL
  end
  if ent == nil then
    ent = NULL
  end
  if storeddata == nil then
    storeddata = { }
  end
  if not IsValid(ent) then
    return 
  end
  if not ent:GetPonyData() then
    local data = PPM2.NetworkedPonyData(nil, ent)
  end
  local data = ent:GetPonyData()
  for _, _des_0 in ipairs(storeddata) do
    local key, value
    key, value = _des_0[1], _des_0[2]
    if data["Set" .. tostring(key)] then
      data["Set" .. tostring(key)](data, value, false)
    end
  end
  data:ReBroadcast()
  return timer.Simple(0.5, function()
    if not data:IsNetworked() then
      return data:Create()
    end
  end)
end)
