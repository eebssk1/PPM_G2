local DISABLE_HOOFSTEP_SOUND_CLIENT
if game.SinglePlayer() then
  if SERVER then
    DISABLE_HOOFSTEP_SOUND_CLIENT = CreateConVar('ppm2_cl_no_hoofsound', '0', {
      FCVAR_ARCHIVE
    }, 'Disable hoofstep sound play time')
  end
else
  if CLIENT then
    DISABLE_HOOFSTEP_SOUND_CLIENT = CreateConVar('ppm2_cl_no_hoofsound', '0', {
      FCVAR_ARCHIVE,
      FCVAR_USERINFO
    }, 'Disable hoofstep sound play time')
  end
end
local DISABLE_HOOFSTEP_SOUND = CreateConVar('ppm2_no_hoofsound', '0', {
  FCVAR_REPLICATED
}, 'Disable hoofstep sound play time')
hook.Remove('PlayerStepSoundTime', 'PPM2.Hooks')
hook.Add('PlayerStepSoundTime', 'PPM2.Hoofstep', function(self, stepType, isWalking)
  if stepType == nil then
    stepType = STEPSOUNDTIME_NORMAL
  end
  if isWalking == nil then
    isWalking = false
  end
  if not self:IsPonyCached() or DISABLE_HOOFSTEP_SOUND_CLIENT and DISABLE_HOOFSTEP_SOUND_CLIENT:GetBool() or DISABLE_HOOFSTEP_SOUND:GetBool() then
    return 
  end
  local rate = self:GetPlaybackRate() * .5
  if self:Crouching() then
    local _exp_0 = stepType
    if STEPSOUNDTIME_NORMAL == _exp_0 then
      return not isWalking and (300 / rate) or (600 / rate)
    elseif STEPSOUNDTIME_ON_LADDER == _exp_0 then
      return 500 / rate
    elseif STEPSOUNDTIME_WATER_KNEE == _exp_0 then
      return not isWalking and (400 / rate) or (800 / rate)
    elseif STEPSOUNDTIME_WATER_FOOT == _exp_0 then
      return not isWalking and (350 / rate) or (700 / rate)
    end
  else
    local _exp_0 = stepType
    if STEPSOUNDTIME_NORMAL == _exp_0 then
      return not isWalking and (150 / rate) or (300 / rate)
    elseif STEPSOUNDTIME_ON_LADDER == _exp_0 then
      return 500 / rate
    elseif STEPSOUNDTIME_WATER_KNEE == _exp_0 then
      return not isWalking and (250 / rate) or (500 / rate)
    elseif STEPSOUNDTIME_WATER_FOOT == _exp_0 then
      return not isWalking and (175 / rate) or (350 / rate)
    end
  end
end)
if SERVER then
  net.pool('ppm2_workaround_emitsound')
end
local SOUND_STRINGS_POOL = { }
local SOUND_STRINGS_POOL_EXCP = { }
local SOUND_STRINGS_POOL_INV = { }
local AddSoundString
AddSoundString = function(sound)
  local nextid = #SOUND_STRINGS_POOL_INV + 1
  SOUND_STRINGS_POOL[sound] = nextid
  SOUND_STRINGS_POOL_INV[nextid] = sound
end
local AddSoundStringEx
AddSoundStringEx = function(sound)
  local nextid = #SOUND_STRINGS_POOL_INV + 1
  SOUND_STRINGS_POOL[sound] = nextid
  SOUND_STRINGS_POOL_EXCP[sound] = nextid
  SOUND_STRINGS_POOL_INV[nextid] = sound
end
do
  local _class_0
  local _base_0 = {
    ShouldPlayHoofclap = function(self)
      return self.playHoofclap
    end,
    DisableHoofclap = function(self)
      self.playHoofclap = false
      return self
    end,
    GetWalkSound = function(self)
      if self.variantsWalk ~= 0 then
        return 'player/ppm2/' .. self.name .. '/' .. self.name .. '_walk' .. math.random(1, self.variantsWalk) .. '.ogg'
      end
      if self.variantsRun ~= 0 then
        return 'player/ppm2/' .. self.name .. '/' .. self.name .. '_run' .. math.random(1, self.variantsRun) .. '.ogg'
      end
    end,
    GetRunSound = function(self)
      if self.variantsRun ~= 0 then
        return 'player/ppm2/' .. self.name .. '/' .. self.name .. '_run' .. math.random(1, self.variantsRun) .. '.ogg'
      end
      if self.variantsWalk ~= 0 then
        return 'player/ppm2/' .. self.name .. '/' .. self.name .. '_walk' .. math.random(1, self.variantsWalk) .. '.ogg'
      end
    end,
    GetWanderSound = function(self)
      if self.variantsWander ~= 0 then
        return 'player/ppm2/' .. self.name .. '/' .. self.name .. '_wander' .. math.random(1, self.variantsWander) .. '.ogg'
      end
    end,
    GetLandSound = function(self)
      if self.variantsLand ~= 0 then
        return 'player/ppm2/' .. self.name .. '/' .. self.name .. '_land' .. math.random(1, self.variantsLand) .. '.ogg'
      end
    end,
    AddLandSounds = function(self, variants)
      self.variantsLand = variants
      for i = 1, variants do
        AddSoundString('player/ppm2/' .. self.name .. '/' .. self.name .. '_land' .. i .. '.ogg')
      end
      return self
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, name, material, variantsWalk, variantsRun, variantsWander)
      if variantsWalk == nil then
        variantsWalk = 0
      end
      if variantsRun == nil then
        variantsRun = 0
      end
      if variantsWander == nil then
        variantsWander = 0
      end
      table.insert(self.__class.REGISTRIES, self)
      self.name = name
      self.material = material
      self.variantsWalk = variantsWalk
      self.variantsRun = variantsRun
      self.variantsWander = variantsWander
      self.variantsLand = 0
      self.playHoofclap = true
      for i = 1, self.variantsWalk do
        AddSoundString('player/ppm2/' .. self.name .. '/' .. self.name .. '_walk' .. i .. '.ogg')
      end
      for i = 1, self.variantsRun do
        AddSoundString('player/ppm2/' .. self.name .. '/' .. self.name .. '_run' .. i .. '.ogg')
      end
      for i = 1, self.variantsWander do
        AddSoundString('player/ppm2/' .. self.name .. '/' .. self.name .. '_wander' .. i .. '.ogg')
      end
    end,
    __base = _base_0,
    __name = "MaterialSoundEntry"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.REGISTRIES = { }
  self.Ask = function(self, matType)
    if matType == nil then
      matType = MAT_DEFAULT
    end
    local _list_0 = self.REGISTRIES
    for _index_0 = 1, #_list_0 do
      local reg = _list_0[_index_0]
      if reg.material == matType then
        return reg
      end
    end
    return false
  end
  PPM2.MaterialSoundEntry = _class_0
end
for i = 1, 3 do
  AddSoundString('player/ppm2/hooves' .. i .. '.ogg')
end
AddSoundString('player/ppm2/falldown.ogg')
AddSoundStringEx('player/ppm2/jump.ogg')
local RECALL = false
local RecallPlayerFootstep
RecallPlayerFootstep = function(ply, pos, foot, sound, volume, filter)
  RECALL = true
  ProtectedCall(function()
    return hook.Run('PlayerFootstep', ply, pos, foot, sound, volume, filter)
  end)
  RECALL = false
end
local LEmitSound
LEmitSound = function(ply, name, level, volume, levelIfOnServer)
  if level == nil then
    level = 75
  end
  if volume == nil then
    volume = 1
  end
  if levelIfOnServer == nil then
    levelIfOnServer = level
  end
  if not IsValid(ply) then
    return 
  end
  if CLIENT then
    if not game.SinglePlayer() then
      ply:EmitSound(name, level, 100, volume)
    end
    return 
  end
  if game.SinglePlayer() then
    ply:EmitSound(name, level, 100, volume)
    return 
  end
  if not SOUND_STRINGS_POOL[name] then
    error('Tried to play unpooled sound: ' .. name)
  end
  local filter = RecipientFilter()
  filter:AddPAS(ply:GetPos())
  filter:RemovePlayer(ply)
  local _list_0 = filter:GetPlayers()
  for _index_0 = 1, #_list_0 do
    local ply2 = _list_0[_index_0]
    if ply2:GetInfoBool('ppm2_cl_no_hoofsound', false) then
      filter:RemovePlayer(ply2)
    end
  end
  if filter:GetCount() == 0 then
    return 
  end
  net.Start('ppm2_workaround_emitsound')
  net.WritePlayer(ply)
  net.WriteUInt8(SOUND_STRINGS_POOL[name])
  net.WriteUInt8(levelIfOnServer)
  net.WriteUInt8((volume * 100):floor())
  net.Send(filter)
  return filter
end
if CLIENT then
  local EntityEmitSound
  EntityEmitSound = function(data)
    local ply = data.Entity
    if not IsValid(ply) or not ply:IsPlayer() then
      return 
    end
    local pdata = ply:GetPonyData()
    if not pdata or not pdata:ShouldMuffleHoosteps() then
      return 
    end
    if not SOUND_STRINGS_POOL[data.OriginalSoundName] or SOUND_STRINGS_POOL_EXCP[data.OriginalSoundName] then
      return 
    end
    data.DSP = 31
    return true
  end
  hook.Add('EntityEmitSound', 'PPM2.Hoofsteps', EntityEmitSound, -2)
end
do
  local _class_0
  local _base_0 = {
    IsValid = function(self)
      return self.ply:IsValid() and not self.playedWanderSound
    end,
    ParentCall = function(self, func, ifNone)
      do
        local data = self.ply:GetPonyData()
        if data then
          return data[func](data)
        end
      end
      return ifNone
    end,
    GetVolume = function(self)
      return self:ParentCall('GetHoofstepVolume', 1)
    end,
    Validate = function(self)
      local newMatType = self.lastTrace.MatType == 0 and MAT_DEFAULT or self.lastTrace.MatType
      if self.lastMatType == newMatType then
        return 
      end
      self.lastMatType = newMatType
      self.lastEntry = PPM2.MaterialSoundEntry:Ask(self.lastMatType)
    end,
    EmitSound = function(self, name, level, volume, levelIfOnServer)
      if level == nil then
        level = 75
      end
      if volume == nil then
        volume = 1
      end
      if levelIfOnServer == nil then
        levelIfOnServer = level
      end
      return LEmitSound(self.ply, name, level, volume, levelIfOnServer)
    end,
    PlayWalk = function(self)
      timer.Simple(0.13, self.lambdaEmitWalk)
      timer.Simple(0.21, self.lambdaEmitWalk)
      return self:lambdaEmitWalk()
    end,
    PlayWander = function(self)
      self.playedWanderSound = true
      timer.Simple(0.13, self.lambdaEmitWander)
      timer.Simple(0.17, self.lambdaEmitWander)
      return self:lambdaEmitWander()
    end,
    PlayRun = function(self)
      timer.Simple(0.18, self.lambdaEmitRun)
      return self:lambdaEmitRun()
    end,
    TraceNow = function(self)
      return self.__class:TraceNow(self.ply)
    end,
    PlayerFootstep = function(self, ply)
      if RECALL then
        return 
      end
      if ply ~= self.ply then
        return 
      end
      if CLIENT and self.ply ~= LocalPlayer() then
        return true
      end
      self.lastTrace = self:TraceNow()
      self:Validate()
      if self.running then
        return self:PlayRun()
      else
        return self:PlayWalk()
      end
    end,
    Think = function(self)
      self.lastVelocity = self.ply:GetVelocity()
      local vlen = self.lastVelocity:Length()
      self.onGround = self.ply:OnGround()
      self.running = vlen >= self.runSpeed
      if vlen < self.walkSpeed * 0.2 then
        self.ply.__ppm2_walkc = nil
        return self:PlayWander()
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, ply)
      ply.__ppm2_walkc = self
      self.ply = ply
      self.walkSpeed = ply:GetWalkSpeed()
      self.runSpeed = ply:GetRunSpeed()
      self.playedWanderSound = false
      self.running = false
      self.lastVelocity = self.ply:GetVelocity()
      self.initialVel = self.ply:GetVelocity()
      self.lastTrace = self:TraceNow()
      self.onGround = self.ply:OnGround()
      if self.onGround then
        self:Validate()
      end
      hook.Add('PlayerFootstep', self, self.PlayerFootstep, 8)
      hook.Add('Think', self, self.Think)
      self.nextWanderPos = 0
      self.nextWalkPos = 0
      self.nextRunPos = 0
      self.lambdaEmitWander = function()
        if not self.ply:IsValid() then
          return 
        end
        if self:ParentCall('GetDisableWanderSounds', false) then
          return 
        end
        if not self.onGround then
          return 
        end
        if not self.lastEntry then
          return 
        end
        local sound = self.lastEntry:GetWanderSound()
        if not sound then
          return 
        end
        local filter = self:EmitSound(sound, 50, self:GetVolume(), 70)
        if not self:ParentCall('GetCallPlayerFootstepHook', true) then
          return 
        end
        self.nextWanderPos = self.nextWanderPos + 1
        self.nextWanderPos = self.nextWanderPos % 4
        return RecallPlayerFootstep(self.ply, self.__class:GetPosForSide(self.nextWanderPos, self.ply), self.nextWanderPos, sound, self:GetVolume(), filter)
      end
      self.lambdaEmitWalk = function()
        if not self.ply:IsValid() then
          return 
        end
        if not self.onGround then
          return 
        end
        if not self.lastEntry then
          if not self:ParentCall('GetDisableHoofsteps', false) then
            local sound = self.__class:RandHoof()
            local filter = self:EmitSound(sound, 50, 0.8 * self:GetVolume(), 65)
            if not self:ParentCall('GetCallPlayerFootstepHook', true) then
              return 
            end
            self.nextWalkPos = self.nextWalkPos + 1
            self.nextWalkPos = self.nextWalkPos % 4
            RecallPlayerFootstep(self.ply, self.__class:GetPosForSide(self.nextWalkPos, self.ply), self.nextWalkPos, sound, 0.8 * self:GetVolume(), filter)
          end
          return 
        end
        if self.lastEntry:ShouldPlayHoofclap() and not self:ParentCall('GetDisableHoofsteps', false) then
          self:EmitSound(self.__class:RandHoof(), 50, 0.8 * self:GetVolume(), 65)
        end
        if self:ParentCall('GetDisableStepSounds', false) then
          return 
        end
        local sound = self.lastEntry:GetWalkSound()
        if not sound then
          return 
        end
        local filter = self:EmitSound(sound, 40, 0.8 * self:GetVolume(), 55)
        if not self:ParentCall('GetCallPlayerFootstepHook', true) then
          return true
        end
        self.nextWalkPos = self.nextWalkPos + 1
        self.nextWalkPos = self.nextWalkPos % 4
        RecallPlayerFootstep(self.ply, self.__class:GetPosForSide(self.nextWalkPos, self.ply), self.nextWalkPos, sound, 0.8 * self:GetVolume(), filter)
        return true
      end
      self.lambdaEmitRun = function()
        if not self.ply:IsValid() then
          return 
        end
        if not self.onGround then
          return 
        end
        if not self.lastEntry then
          if not self:ParentCall('GetDisableHoofsteps', false) then
            local sound = self.__class:RandHoof()
            local filter = self:EmitSound(sound, 60, self:GetVolume(), 70)
            if not self:ParentCall('GetCallPlayerFootstepHook', true) then
              return 
            end
            self.nextRunPos = self.nextRunPos + 1
            self.nextRunPos = self.nextRunPos % 4
            RecallPlayerFootstep(self.ply, self.__class:GetPosForSide(self.nextRunPos, self.ply), self.nextRunPos, sound, self:GetVolume(), filter)
          end
          return 
        end
        if self.lastEntry:ShouldPlayHoofclap() and not self:ParentCall('GetDisableHoofsteps', false) then
          self:EmitSound(self.__class:RandHoof(), 60, self:GetVolume(), 70)
        end
        if self:ParentCall('GetDisableStepSounds', false) then
          return 
        end
        local sound = self.lastEntry:GetRunSound()
        if not sound then
          return 
        end
        local filter = self:EmitSound(sound, 40, 0.7 * self:GetVolume(), 60)
        if not self:ParentCall('GetCallPlayerFootstepHook', true) then
          return true
        end
        self.nextRunPos = self.nextRunPos + 1
        self.nextRunPos = self.nextRunPos % 4
        RecallPlayerFootstep(self.ply, self.__class:GetPosForSide(self.nextRunPos, self.ply), self.nextRunPos, sound, 0.7 * self:GetVolume(), filter)
        return true
      end
    end,
    __base = _base_0,
    __name = "PlayerFootstepsListener"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.soundBones = {
    Vector(8.112172, 3.867798, 0),
    Vector(8.111097, -3.863072, 0),
    Vector(-14.863633, 4.491844, 0),
    Vector(-14.863256, -4.487118, 0)
  }
  self.GetPosForSide = function(self, side, ply)
    if side == nil then
      side = 0
    end
    do
      local data = ply:GetPonyData()
      if data then
        if not self.soundBones[side + 1] then
          return ply:GetPos()
        end
        return ply:GetPos() + self.soundBones[side + 1] * data:GetPonySize()
      end
    end
    if not self.soundBones[side + 1] then
      return ply:GetPos()
    end
    return ply:GetPos() + self.soundBones[side + 1]
  end
  self.RandHoof = function(self)
    return 'player/ppm2/hooves' .. math.random(1, 3) .. '.ogg'
  end
  self.TraceNow = function(self, ply, dropToGround)
    local mins, maxs = ply:GetHull()
    local trData = {
      start = ply:GetPos(),
      endpos = ply:GetPos() - Vector(0, 0, not dropToGround and 5 or 15),
      mins = mins,
      maxs = maxs,
      filter = ply
    }
    return util.TraceHull(trData)
  end
  PPM2.PlayerFootstepsListener = _class_0
end
PPM2.MaterialSoundEntry('concrete', MAT_CONCRETE, 11, 11, 5)
PPM2.MaterialSoundEntry('dirt', MAT_DIRT, 11, 11, 5):AddLandSounds(4):DisableHoofclap()
PPM2.MaterialSoundEntry('grass', MAT_GRASS, 10, 4, 6):DisableHoofclap()
PPM2.MaterialSoundEntry('gravel', MAT_DEFAULT, 11, 11, 3):DisableHoofclap()
PPM2.MaterialSoundEntry('metalbar', MAT_METAL, 11, 11, 6)
PPM2.MaterialSoundEntry('metalbox', MAT_VENT, 10, 9, 4)
PPM2.MaterialSoundEntry('mud', MAT_SLOSH, 10, 9, 4):DisableHoofclap()
PPM2.MaterialSoundEntry('sand', MAT_SAND, 11, 11, 0):DisableHoofclap()
PPM2.MaterialSoundEntry('snow', MAT_SNOW, 11, 11, 5):DisableHoofclap()
PPM2.MaterialSoundEntry('squeakywood', MAT_WOOD, 11, 0, 7)
if CLIENT then
  net.receive('ppm2_workaround_emitsound', function()
    if DISABLE_HOOFSTEP_SOUND_CLIENT:GetBool() then
      return 
    end
    local ply, sound, level, volume = net.ReadPlayer(), SOUND_STRINGS_POOL_INV[net.ReadUInt8()], net.ReadUInt8(), net.ReadUInt8() / 100
    if not IsValid(ply) then
      return 
    end
    return ply:EmitSound(sound, level, 100, volume)
  end)
end
hook.Add('PlayerFootstep', 'PPM2.Hoofstep', function(self, pos, foot, sound, volume, filter)
  if RECALL then
    return 
  end
  if CLIENT and game.SinglePlayer() then
    return 
  end
  if not self:IsPonyCached() or DISABLE_HOOFSTEP_SOUND_CLIENT and DISABLE_HOOFSTEP_SOUND_CLIENT:GetBool() or DISABLE_HOOFSTEP_SOUND:GetBool() then
    return 
  end
  if self.__ppm2_walkc then
    return 
  end
  return PPM2.PlayerFootstepsListener(self):PlayerFootstep(self)
end)
local LEmitSoundRecall
LEmitSoundRecall = function(self, sound, level, volume, levelIfOnServer, side)
  if levelIfOnServer == nil then
    levelIfOnServer = level
  end
  if not self:IsValid() then
    return 
  end
  local filter = LEmitSound(self, sound, level, volume, levelIfOnServer)
  RecallPlayerFootstep(self, PPM2.PlayerFootstepsListener:GetPosForSide(side, self), side, sound, volume, filter)
  return filter
end
local ProcessFalldownEvents
ProcessFalldownEvents = function(self, cmd)
  if not self:IsPonyCached() then
    return 
  end
  if DISABLE_HOOFSTEP_SOUND_CLIENT and DISABLE_HOOFSTEP_SOUND_CLIENT:GetBool() or DISABLE_HOOFSTEP_SOUND:GetBool() then
    return 
  end
  if self:GetMoveType() ~= MOVETYPE_WALK then
    self.__ppm2_jump = false
    return 
  end
  local self2 = self:GetTable()
  local ground = self:OnGround()
  local jump = cmd:KeyDown(IN_JUMP)
  local modifier = 1
  local disableFalldown = false
  local disableJumpSound = false
  local disableHoofsteps = false
  local disableWalkSounds = false
  do
    local data = self:GetPonyData()
    if data then
      modifier = data:GetHoofstepVolume()
      disableFalldown = data:GetDisableFalldownSound()
      disableJumpSound = data:GetDisableJumpSound()
      disableHoofsteps = data:GetDisableHoofsteps()
      disableWalkSounds = data:GetDisableStepSounds()
    end
  end
  if self.__ppm2_jump and ground then
    self.__ppm2_jump = false
    local tr = PPM2.PlayerFootstepsListener:TraceNow(self)
    local entry = PPM2.MaterialSoundEntry:Ask(tr.MatType == 0 and MAT_DEFAULT or tr.MatType)
    if entry then
      do
        local sound = entry:GetLandSound()
        if sound then
          if not disableFalldown then
            LEmitSound(self, sound, 60, modifier, 75)
          end
        elseif not self.__ppm2_walkc and not disableWalkSounds then
          do
            sound = entry:GetWalkSound()
            if sound then
              LEmitSoundRecall(self, sound, 45, 0.2 * modifier, 55, 0)
              timer.Simple(0.04, function()
                return LEmitSoundRecall(self, sound, 45, 0.3 * modifier, 55, 1)
              end)
              timer.Simple(0.07, function()
                return LEmitSoundRecall(self, sound, 45, 0.3 * modifier, 55, 2)
              end)
              timer.Simple(0.1, function()
                return LEmitSoundRecall(self, sound, 45, 0.3 * modifier, 55, 3)
              end)
            end
          end
        end
      end
      if not entry:ShouldPlayHoofclap() then
        return 
      end
    end
    if not disableFalldown then
      local filter = LEmitSound(self, 'player/ppm2/falldown.ogg', 60, 1, 75)
      for i = 0, 3 do
        timer.Simple(i * 0.1, function()
          return RecallPlayerFootstep(self, PPM2.PlayerFootstepsListener:GetPosForSide(i, self), i, 'player/ppm2/falldown.ogg', 1, filter)
        end)
      end
    end
  elseif jump and not ground and not self.__ppm2_jump then
    self.__ppm2_jump = true
    if not disableJumpSound then
      LEmitSound(self, 'player/ppm2/jump.ogg', 50, 1, 65)
    end
    local tr = PPM2.PlayerFootstepsListener:TraceNow(self, true)
    local entry = PPM2.MaterialSoundEntry:Ask(tr.MatType == 0 and MAT_DEFAULT or tr.MatType)
    if (not entry or entry:ShouldPlayHoofclap()) and not disableHoofsteps then
      LEmitSoundRecall(self, PPM2.PlayerFootstepsListener.RandHoof(), 55, 0.4 * modifier, 65, 0)
      timer.Simple(0.04, function()
        return LEmitSoundRecall(self, PPM2.PlayerFootstepsListener.RandHoof(), 55, 0.4 * modifier, 65, 1)
      end)
      timer.Simple(0.07, function()
        return LEmitSoundRecall(self, PPM2.PlayerFootstepsListener.RandHoof(), 55, 0.4 * modifier, 65, 2)
      end)
      return timer.Simple(0.1, function()
        return LEmitSoundRecall(self, PPM2.PlayerFootstepsListener.RandHoof(), 55, 0.4 * modifier, 65, 3)
      end)
    end
  end
end
return hook.Add('StartCommand', 'PPM2.Hoofsteps', ProcessFalldownEvents)
