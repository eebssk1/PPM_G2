local ALLOW_FLIGHT = CreateConVar('ppm2_sv_flight', '1', {
  FCVAR_REPLICATED,
  FCVAR_NOTIFY
}, 'Allow flight for pegasus and alicorns. It obeys PlayerNoClip hook.')
local FORCE_ALLOW_FLIGHT = CreateConVar('ppm2_sv_flight_force', '0', {
  FCVAR_REPLICATED,
  FCVAR_NOTIFY
}, 'Ignore PlayerNoClip hook')
local SUPPRESS_CLIENTSIDE_CHECK = CreateConVar('ppm2_sv_flight_nocheck', '0', {
  FCVAR_REPLICATED,
  FCVAR_NOTIFY
}, 'Suppress PlayerNoClip clientside check (useful with bad coded addons. known are - ULX, Cinema, FAdmin)')
local FLIGHT_DAMAGE = CreateConVar('ppm2_sv_flightdmg', '1', {
  FCVAR_REPLICATED,
  FCVAR_NOTIFY
}, 'Damage players in flight')
local PonyflyController
do
  local _class_0
  local _base_0 = {
    GetEntity = function(self)
      return self.controller:GetEntity()
    end,
    GetData = function(self)
      return self.controller
    end,
    GetController = function(self)
      return self.controller
    end,
    Switch = function(self, status)
      if status == nil then
        status = false
      end
      if not IsValid(self:GetEntity()) or not self:GetEntity():IsPlayer() then
        return 
      end
      if self.lastState == status then
        return 
      end
      self.lastState = status
      if not status then
        local p, y, r
        do
          local _obj_0 = self:GetEntity():EyeAngles()
          p, y, r = _obj_0.p, _obj_0.y, _obj_0.r
        end
        local newAng = Angle(p, y, 0)
        self:GetEntity():SetEyeAngles(newAng)
        self:GetEntity():SetMoveType(MOVETYPE_WALK)
        self.roll = 0
        self.pitch = 0
        self.yaw = 0
        self:GetEntity():SetVelocity(self.lastVelocity * 50)
        self.lastVelocity = Vector(0, 0, 0)
      else
        self.lastVelocity = Vector(0, 0, 0)
        self:GetEntity():SetVelocity(-self:GetEntity():GetVelocity() * .97)
        self:GetEntity():SetMoveType(MOVETYPE_CUSTOM)
        self.obbCenter = self:GetEntity():OBBCenter()
        self.obbMins = self:GetEntity():OBBMins()
        self.obbMaxs = self:GetEntity():OBBMaxs()
        self.roll = 0
        self.pitch = 0
        self.yaw = 0
      end
    end,
    Think = function(self, movedata)
      local pos = movedata:GetOrigin()
      local ang = movedata:GetAngles()
      local fwd = ang:Forward()
      local bcwd = -ang:Forward()
      local right = ang:Right()
      local left = -ang:Right()
      local up = ang:Up()
      local down = -ang:Up()
      local W = movedata:KeyDown(IN_FORWARD)
      local S = movedata:KeyDown(IN_BACK)
      local D = movedata:KeyDown(IN_MOVERIGHT)
      local A = movedata:KeyDown(IN_MOVELEFT)
      local CTRL = movedata:KeyDown(IN_DUCK)
      local MULT = FrameTime() * 66
      local velocity = movedata:GetVelocity()
      local cSpeed = velocity:Length()
      if cSpeed < 1 then
        cSpeed = 1
      end
      local dragSqrt = math.min(math.sqrt(cSpeed) / cSpeed * 2, 0.99)
      local cSpeedMult = self.speedMultDiv / cSpeed
      if cSpeedMult ~= cSpeedMult then
        cSpeedMult = self.speedMultDiv
      end
      local cSpeedLiftMult = self.speedMultLift / cSpeed
      if cSpeedLiftMult ~= cSpeedLiftMult then
        cSpeedLiftMult = self.speedMultLift
      end
      local dragCalc = math.Clamp(self.dragMult / dragSqrt, 0, 0.99)
      local pitch = 0
      local yaw = 0
      local roll = 0
      local hit = false
      local hitLift = false
      if W then
        velocity = velocity + (fwd * MULT * self.speedMult * cSpeedMult * self.speedMultDirections)
        hit = true
        pitch = pitch + 20
      end
      if S then
        velocity = velocity + (bcwd * MULT * self.speedMult * cSpeedMult * self.speedMultDirections)
        hit = true
        pitch = pitch - 20
      end
      if A then
        velocity = velocity + (left * MULT * self.speedMult * cSpeedMult * self.speedMultDirections)
        hit = true
        roll = roll - 20
      end
      if D then
        velocity = velocity + (right * MULT * self.speedMult * cSpeedMult * self.speedMultDirections)
        hit = true
        roll = roll + 20
      end
      if CTRL then
        velocity = velocity + Vector(0, 0, -MULT * self.speedMult * cSpeedLiftMult)
        hitLift = true
      end
      if self.isLiftingUp then
        velocity = velocity + Vector(0, 0, MULT * self.speedMult * cSpeedLiftMult)
        hitLift = true
      end
      if CLIENT then
        local lerpMult = FrameTime() * self.angleLerp
        local p, y, r
        p, y, r = ang.p, ang.y, ang.r
        p = p - self.pitch
        y = y - self.yaw
        self.pitch = Lerp(lerpMult, self.pitch, pitch)
        self.yaw = Lerp(lerpMult, self.yaw, yaw)
        self.roll = Lerp(lerpMult, self.roll, roll)
        p = p + self.pitch
        y = y + self.yaw
        r = self.roll + math.sin(RealTimeL()) * 2
        local newAng = Angle(p, y, r)
        self:GetEntity():SetEyeAngles(newAng)
      end
      if not hit then
        velocity.x = velocity.x * dragCalc
        velocity.y = velocity.y * dragCalc
      end
      if not hitLift then
        velocity.z = velocity.z * dragCalc
        velocity.z = velocity.z + (math.sin(RealTimeL() * 2) * .01)
      end
      pos = pos + velocity
      movedata:SetVelocity(velocity)
      movedata:SetOrigin(pos)
      return true
    end,
    SetupMove = function(self, movedata, cmd)
      self.isLiftingUp = movedata:KeyDown(IN_JUMP)
      if self.isLiftingUp then
        movedata:SetButtons(movedata:GetButtons() - IN_JUMP)
      end
      if cmd:KeyDown(IN_JUMP) then
        return cmd:SetButtons(cmd:GetButtons() - IN_JUMP)
      end
    end,
    FinishMove = function(self, movedata)
      local nativeEntity = self:GetEntity()
      local mvPos = movedata:GetOrigin()
      local pos = nativeEntity:GetPos()
      local rpos = pos
      local tryMove = util.TraceHull({
        filter = function(ent)
          if nativeEntity == ent then
            return false
          end
          if not IsValid(ent) then
            return true
          end
          local collision = ent:GetCollisionGroup()
          return collision ~= COLLISION_GROUP_WORLD and collision ~= COLLISION_GROUP_DEBRIS_TRIGGER and collision ~= COLLISION_GROUP_WEAPON and collision ~= COLLISION_GROUP_PASSABLE_DOOR and collision ~= COLLISION_GROUP_DEBRIS and ent:GetOwner() ~= nativeEntity and ent:GetParent() ~= nativeEntity and ent:IsSolid()
        end,
        mins = self.obbMins,
        maxs = self.obbMaxs,
        start = rpos,
        endpos = mvPos
      })
      local velocity = movedata:GetVelocity()
      local newVelocity = velocity
      local length = velocity:Length()
      if not tryMove.Hit then
        nativeEntity:SetPos(mvPos)
      else
        if IsValid(tryMove.Entity) then
          newVelocity = Vector(0, 0, 0)
          movedata:SetVelocity(newVelocity)
          local newPos = tryMove.HitPos + tryMove.HitNormal
          nativeEntity:SetPos(newPos)
          movedata:SetOrigin(newPos)
        else
          newVelocity = velocity - tryMove.HitNormal * velocity:Dot(tryMove.HitNormal * 1.1)
          movedata:SetVelocity(newVelocity)
          local newPos = tryMove.HitPos + tryMove.HitNormal
          nativeEntity:SetPos(newPos)
          movedata:SetOrigin(newPos)
        end
        if length > 7 and SERVER and FLIGHT_DAMAGE:GetBool() then
          local dmgInfo = DamageInfo()
          dmgInfo:SetAttacker(nativeEntity)
          dmgInfo:SetInflictor(nativeEntity)
          dmgInfo:SetDamageType(DMG_CRUSH)
          local calcDamage = math.Clamp((length / 4) ^ 2, 1, 100)
          if calcDamage >= 100 then
            nativeEntity:EmitSound('physics/flesh/flesh_bloody_break.wav', 100)
          elseif calcDamage > 70 then
            nativeEntity:EmitSound('physics/flesh/flesh_bloody_break.wav', 100)
          elseif calcDamage > 50 then
            nativeEntity:EmitSound("physics/body/body_medium_break" .. tostring(math.random(2, 4)) .. ".wav", 75)
          elseif calcDamage > 25 then
            nativeEntity:EmitSound("physics/body/body_medium_impact_hard" .. tostring(math.random(1, 6)) .. ".wav", 75)
          elseif calcDamage > 10 then
            nativeEntity:EmitSound("physics/body/body_medium_impact_soft" .. tostring(math.random(1, 7)) .. ".wav", 75)
          else
            nativeEntity:EmitSound("physics/flesh/flesh_impact_bullet" .. tostring(math.random(1, 5)) .. ".wav", 75)
          end
          dmgInfo:SetDamage(calcDamage)
          nativeEntity:TakeDamageInfo(dmgInfo)
        end
      end
      self.lastVelocity = newVelocity
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, controller)
      self.controller = controller
      self.speedMult = 0.5
      self.speedMultDirections = 1.25
      self.dragMult = 0.95
      self.obbCenter = Vector(0, 0, 0)
      self.obbMins = Vector(0, 0, 0)
      self.obbMaxs = Vector(0, 0, 0)
      self.speedMultDiv = 2
      self.speedMultLift = 2
      self.pitch = 0
      self.yaw = 0
      self.roll = 0
      self.angleLerp = 1
      self.lastVelocity = Vector(0, 0, 0)
      self.lastState = false
    end,
    __base = _base_0,
    __name = "PonyflyController"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  PonyflyController = _class_0
end
PPM2.PonyflyController = PonyflyController
local IsPonyCached, GetPonyData, GetTable, SetIK, IsNewPonyCached
do
  local _obj_0 = FindMetaTable('Entity')
  IsPonyCached, GetPonyData, GetTable, SetIK, IsNewPonyCached = _obj_0.IsPonyCached, _obj_0.GetPonyData, _obj_0.GetTable, _obj_0.SetIK, _obj_0.IsNewPonyCached
end
local AnimRestartGesture, AnimResetGestureSlot
do
  local _obj_0 = FindMetaTable('Player')
  AnimRestartGesture, AnimResetGestureSlot = _obj_0.AnimRestartGesture, _obj_0.AnimResetGestureSlot
end
hook.Add('SetupMove', 'PPM2.Ponyfly', function(self, movedata, cmd)
  if not IsPonyCached(self) then
    return 
  end
  local data = GetPonyData(self)
  if not data or not data:GetFly() then
    return 
  end
  local flight = data:GetFlightController()
  if not flight then
    return 
  end
  return flight:SetupMove(movedata, cmd)
end)
hook.Add('Move', 'PPM2.Ponyfly', function(self, movedata)
  if not IsPonyCached(self) then
    return 
  end
  local data = GetPonyData(self)
  if not data or not data:GetFly() then
    return 
  end
  local flight = data:GetFlightController()
  if not flight then
    return 
  end
  return flight:Think(movedata)
end)
hook.Add('FinishMove', 'PPM2.Ponyfly', function(self, movedata)
  if not IsPonyCached(self) then
    return 
  end
  local data = GetPonyData(self)
  if not data or not data:GetFly() then
    return 
  end
  local flight = data:GetFlightController()
  if not flight then
    return 
  end
  return flight:FinishMove(movedata)
end)
hook.Add('CalcMainActivity', 'PPM2.Ponyfly', function(self, movedata)
  if not IsNewPonyCached(self) then
    return 
  end
  do
    local data = GetPonyData(self)
    if data then
      if data:GetFly() then
        if not self.isPlayingPPM2Anim then
          self.isPlayingPPM2Anim = true
          AnimRestartGesture(self, GESTURE_SLOT_CUSTOM, ACT_GMOD_NOCLIP_LAYER, false)
          if CLIENT then
            SetIK(self, false)
          end
        end
        return ACT_GMOD_NOCLIP_LAYER, 370
      else
        if self.isPlayingPPM2Anim then
          self.isPlayingPPM2Anim = false
          AnimResetGestureSlot(self, GESTURE_SLOT_CUSTOM)
          if CLIENT then
            return SetIK(self, true)
          end
        end
      end
    end
  end
end)
if SERVER then
  return concommand.Add('ppm2_fly', function(self)
    if not ALLOW_FLIGHT:GetBool() then
      return 
    end
    if not IsValid(self) then
      return 
    end
    if not self:IsPonyCached() then
      return 
    end
    local data = self:GetPonyData()
    if not data then
      return 
    end
    if data:GetFly() then
      if FORCE_ALLOW_FLIGHT:GetBool() then
        return data:SetFly(false)
      end
      local can = hook.Run('PlayerNoClip', self, false) or hook.Run('PPM2Fly', self, false)
      if can then
        return data:SetFly(false)
      end
    else
      if data:GetRace() ~= PPM2.RACE_PEGASUS and data:GetRace() ~= PPM2.RACE_ALICORN then
        return 
      end
      if FORCE_ALLOW_FLIGHT:GetBool() then
        return data:SetFly(true)
      end
      local can = hook.Run('PlayerNoClip', self, true) or hook.Run('PPM2Fly', self, true)
      if can then
        return data:SetFly(true)
      end
    end
  end)
else
  local lastDouble = 0
  local lastMessage = 0
  local lastMessage2 = 0
  local FLIGHT_BIND = CreateConVar('ppm2_flight_djump', '1', {
    FCVAR_ARCHIVE
  }, 'Double press of Jump activates flight')
  return hook.Add('PlayerBindPress', 'PPM2.Ponyfly', function(self, bind, pressed)
    if bind == nil then
      bind = ''
    end
    if pressed == nil then
      pressed = false
    end
    if not ALLOW_FLIGHT:GetBool() then
      return 
    end
    if not FLIGHT_BIND:GetBool() then
      return 
    end
    if not pressed then
      return 
    end
    if bind ~= '+jump' and bind ~= 'jump' then
      return 
    end
    if lastDouble > RealTimeL() then
      if not self:IsPonyCached() then
        return 
      end
      local data = self:GetPonyData()
      if not data then
        return 
      end
      if data:GetRace() ~= PPM2.RACE_PEGASUS and data:GetRace() ~= PPM2.RACE_ALICORN then
        if lastMessage < RealTimeL() then
          lastMessage = RealTimeL() + 1
          PPM2.LChatPrint('info.ppm2.fly.pegasus')
        end
        return 
      end
      if not FORCE_ALLOW_FLIGHT:GetBool() and not SUPPRESS_CLIENTSIDE_CHECK:GetBool() then
        local can = hook.Run('PlayerNoClip', self, not data:GetFly()) or hook.Run('PPM2Fly', self, not data:GetFly())
        if not can then
          if lastMessage2 < RealTimeL() then
            lastMessage2 = RealTimeL() + 1
            PPM2.LChatPrint('info.ppm2.fly.cannot', data:GetFly() and 'land' or 'fly')
          end
          return 
        end
      end
      RunConsoleCommand('ppm2_fly')
      lastDouble = 0
      return 
    end
    lastDouble = RealTimeL() + 0.2
  end)
end
