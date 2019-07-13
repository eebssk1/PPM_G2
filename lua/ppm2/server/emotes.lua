util.AddNetworkString('PPM2.DamageAnimation')
util.AddNetworkString('PPM2.KillAnimation')
util.AddNetworkString('PPM2.AngerAnimation')
util.AddNetworkString('PPM2.PlayEmote')
hook.Add('EntityTakeDamage', 'PPM2.Emotes', function(ent, dmg)
  do
    local self = ent
    if self:GetPonyData() then
      self.__ppm2_last_hurt_anim = self.__ppm2_last_hurt_anim or 0
      if self.__ppm2_last_hurt_anim < CurTimeL() then
        self.__ppm2_last_hurt_anim = CurTimeL() + 1
        net.Start('PPM2.DamageAnimation', true)
        net.WriteEntity(self)
        net.Broadcast()
      end
    end
  end
  do
    local self = dmg:GetAttacker()
    if self:GetPonyData() and IsValid(ent) and (ent:IsNPC() or ent:IsPlayer() or ent.Type == 'nextbot') then
      self.__ppm2_last_anger_anim = self.__ppm2_last_anger_anim or 0
      if self.__ppm2_last_anger_anim < CurTimeL() then
        self.__ppm2_last_anger_anim = CurTimeL() + 1
        net.Start('PPM2.AngerAnimation', true)
        net.WriteEntity(self)
        return net.Broadcast()
      end
    end
  end
end)
local killGrin
killGrin = function(self)
  if not IsValid(self) then
    return 
  end
  if not self:GetPonyData() then
    return 
  end
  self.__ppm2_grin_hurt_anim = self.__ppm2_grin_hurt_anim or 0
  if self.__ppm2_grin_hurt_anim > CurTimeL() then
    return 
  end
  self.__ppm2_grin_hurt_anim = CurTimeL() + 1
  net.Start('PPM2.KillAnimation', true)
  net.WriteEntity(self)
  return net.Broadcast()
end
hook.Add('OnNPCKilled', 'PPM2.Emotes', function(self, npc, attacker, weapon)
  if npc == nil then
    npc = NULL
  end
  if attacker == nil then
    attacker = NULL
  end
  if weapon == nil then
    weapon = NULL
  end
  return killGrin(attacker)
end)
hook.Add('DoPlayerDeath', 'PPM2.Emotes', function(self, ply, attacker)
  if ply == nil then
    ply = NULL
  end
  if attacker == nil then
    attacker = NULL
  end
  return killGrin(attacker)
end)
return net.Receive('PPM2.PlayEmote', function(len, ply)
  if len == nil then
    len = 0
  end
  if ply == nil then
    ply = NULL
  end
  if not IsValid(ply) then
    return 
  end
  local self = ply
  local emoteID = net.ReadUInt(8)
  local isEndless = net.ReadBool()
  local shouldStop = net.ReadBool()
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
  net.WriteEntity(ply)
  net.WriteBool(isEndless)
  net.WriteBool(shouldStop)
  return net.SendOmit(ply)
end)
