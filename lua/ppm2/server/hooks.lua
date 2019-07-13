hook.Add('PlayerSpawn', 'PPM2.Hooks', function(self)
  if IsValid(self.__ppm2_ragdoll) then
    self.__ppm2_ragdoll:Remove()
    self:UnSpectate()
  end
  return timer.Simple(0, function()
    if not (self:IsValid()) then
      return 
    end
    if self:GetPonyData() then
      self:GetPonyData():PlayerRespawn()
      net.Start('PPM2.PlayerRespawn')
      net.WriteEntity(self)
      return net.Broadcast()
    end
  end)
end)
do
  local REQUIRE_CLIENTS = { }
  local safeSendFunction
  safeSendFunction = function()
    for ply, data in pairs(REQUIRE_CLIENTS) do
      local _continue_0 = false
      repeat
        if not IsValid(ply) then
          REQUIRE_CLIENTS[ply] = nil
          _continue_0 = true
          break
        end
        local ent = table.remove(data, 1)
        if not ent then
          REQUIRE_CLIENTS[ply] = nil
          _continue_0 = true
          break
        end
        data = ent:GetPonyData()
        if not data then
          _continue_0 = true
          break
        end
        data:NetworkTo(ply)
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
  end
  local errorTrack
  errorTrack = function(err)
    PPM2.Message('Networking Error: ', err)
    return PPM2.Message(debug.traceback())
  end
  timer.Create('PPM2.Require', 0.25, 0, function()
    return xpcall(safeSendFunction, errorTrack)
  end)
  net.Receive('PPM2.Require', function(len, ply)
    if len == nil then
      len = 0
    end
    if ply == nil then
      ply = NULL
    end
    if not IsValid(ply) then
      return 
    end
    REQUIRE_CLIENTS[ply] = { }
    local target = REQUIRE_CLIENTS[ply]
    for _, ent in ipairs(ents.GetAll()) do
      if ent ~= ply then
        local data = ent:GetPonyData()
        if data then
          table.insert(target, ent)
        end
      end
    end
  end)
end
PPM2.ENABLE_NEW_RAGDOLLS = CreateConVar('ppm2_sv_new_ragdolls', '1', {
  FCVAR_NOTIFY,
  FCVAR_REPLICATED
}, 'Enable new ragdolls')
local ENABLE_NEW_RAGDOLLS = PPM2.ENABLE_NEW_RAGDOLLS
local RAGDOLL_COLLISIONS = CreateConVar('ppm2_sv_ragdolls_collisions', '1', {
  FCVAR_NOTIFY,
  FCVAR_REPLICATED
}, 'Enable ragdolls collisions')
local createPlayerRagdoll
createPlayerRagdoll = function(self)
  if IsValid(self.__ppm2_ragdoll) then
    self.__ppm2_ragdoll:Remove()
  end
  self.__ppm2_ragdoll = ents.Create('prop_ragdoll')
  local rag = self:GetRagdollEntity()
  if IsValid(rag) then
    rag:Remove()
  end
  do
    local _with_0 = self.__ppm2_ragdoll
    _with_0:SetModel(self:GetModel())
    _with_0:SetPos(self:GetPos())
    _with_0:SetAngles(self:EyeAngles())
    if RAGDOLL_COLLISIONS:GetBool() then
      _with_0:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
    end
    if not RAGDOLL_COLLISIONS:GetBool() then
      _with_0:SetCollisionGroup(COLLISION_GROUP_WORLD)
    end
    _with_0:Spawn()
    _with_0:Activate()
    hook.Run('PlayerSpawnedRagdoll', self, self:GetModel(), self.__ppm2_ragdoll)
    _with_0.__ppm2_ragdoll_parent = self
    _with_0:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
    _with_0:SetNWBool('PPM2.IsDeathRagdoll', true)
    local vel = self:GetVelocity()
    _with_0:SetVelocity(vel)
    _with_0:SetAngles(self:EyeAngles())
    self:Spectate(OBS_MODE_CHASE)
    self:SpectateEntity(self.__ppm2_ragdoll)
    for boneID = 0, self.__ppm2_ragdoll:GetBoneCount() - 1 do
      local physobjID = self.__ppm2_ragdoll:TranslateBoneToPhysBone(boneID)
      local pos, ang = self:GetBonePosition(boneID)
      local physobj = self.__ppm2_ragdoll:GetPhysicsObjectNum(physobjID)
      physobj:SetVelocity(vel)
      physobj:SetMass(300)
      if pos then
        physobj:SetPos(pos, true)
      end
      if ang then
        physobj:SetAngles(ang)
      end
    end
    local copy = self:GetPonyData():Clone(self.__ppm2_ragdoll)
    copy:Create()
    return _with_0
  end
end
local ALLOW_RAGDOLL_DAMAGE = CreateConVar('ppm2_sv_ragdoll_damage', '1', {
  FCVAR_ARCHIVE,
  FCVAR_NOTIFY
}, 'Should death ragdoll cause damage?')
hook.Add('EntityTakeDamage', 'PPM2.DeathRagdoll', function(self, dmg)
  local attacker = dmg:GetAttacker()
  if not IsValid(attacker) then
    return 
  end
  if attacker.__ppm2_ragdoll_parent then
    dmg:SetAttacker(attacker.__ppm2_ragdoll_parent)
    if not ALLOW_RAGDOLL_DAMAGE:GetBool() then
      dmg:SetDamage(0)
      return dmg:SetMaxDamage(0)
    end
  end
end)
hook.Add('PostPlayerDeath', 'PPM2.Hooks', function(self)
  if not self:GetPonyData() then
    return 
  end
  self:GetPonyData():PlayerDeath()
  net.Start('PPM2.PlayerDeath')
  net.WriteEntity(self)
  net.Broadcast()
  if ENABLE_NEW_RAGDOLLS:GetBool() and self:IsPony() then
    createPlayerRagdoll(self)
  end
end)
hook.Add('PlayerDeath', 'PPM2.Hooks', function(self)
  if not self:GetPonyData() then
    return 
  end
  if ENABLE_NEW_RAGDOLLS:GetBool() and self:IsPony() then
    createPlayerRagdoll(self)
  end
end)
hook.Add('EntityRemoved', 'PPM2.PonyDataRemove', function(self)
  if self:IsPlayer() then
    return 
  end
  if not self:GetPonyData() then
    return 
  end
  do
    local _with_0 = self:GetPonyData()
    net.Start('PPM2.PonyDataRemove')
    net.WriteUInt(_with_0.netID, 16)
    net.Broadcast()
    _with_0:Remove()
  end
end)
hook.Add('PlayerDisconnected', 'PPM2.NotifyClients', function(self)
  if IsValid(self.__ppm2_ragdoll) then
    self.__ppm2_ragdoll:Remove()
  end
  local data = self:GetPonyData()
  if not data then
    return 
  end
  net.Start('PPM2.NotifyDisconnect')
  net.WriteUInt(data.netID, 16)
  return net.Broadcast()
end)
local BOTS_ARE_PONIES = CreateConVar('ppm2_bots', '1', {
  FCVAR_ARCHIVE,
  FCVAR_NOTIFY
}, 'Whatever spawn bots as ponies')
hook.Add('PlayerSetModel', 'PPM2.Bots', function(self)
  if not BOTS_ARE_PONIES:GetBool() then
    return 
  end
  if not self:IsBot() then
    return 
  end
  self:SetModel('models/ppm/player_default_base_new.mdl')
  return true
end)
local PlayerSpawnBot
PlayerSpawnBot = function(self)
  if not BOTS_ARE_PONIES:GetBool() then
    return 
  end
  if not self:IsBot() then
    return 
  end
  return timer.Simple(1, function()
    if not IsValid(self) then
      return 
    end
    self:SetViewOffset(Vector(0, 0, PPM2.PLAYER_VIEW_OFFSET))
    self:SetViewOffsetDucked(Vector(0, 0, PPM2.PLAYER_VIEW_OFFSET_DUCK))
    if not self:GetPonyData() then
      local data = PPM2.NetworkedPonyData(nil, self)
      PPM2.Randomize(data)
      return data:Create()
    end
  end)
end
hook.Add('PlayerSpawn', 'PPM2.Bots', PlayerSpawnBot)
return timer.Simple(0, function()
  for _, ply in ipairs(player.GetAll()) do
    PlayerSpawnBot(ply)
  end
end)
