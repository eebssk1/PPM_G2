local FrameNumberL, RealTimeL, PPM2
do
  local _obj_0 = _G
  FrameNumberL, RealTimeL, PPM2 = _obj_0.FrameNumberL, _obj_0.RealTimeL, _obj_0.PPM2
end
local GetPonyData, IsDormant, PPMBonesModifier, IsPony
do
  local _obj_0 = FindMetaTable('Entity')
  GetPonyData, IsDormant, PPMBonesModifier, IsPony = _obj_0.GetPonyData, _obj_0.IsDormant, _obj_0.PPMBonesModifier, _obj_0.IsPony
end
local RENDER_HORN_GLOW = CreateConVar('ppm2_horn_glow', '1', {
  FCVAR_ARCHIVE,
  FCVAR_NOTIFY
}, 'Visual horn glow when player uses physgun')
local HORN_PARTICLES = CreateConVar('ppm2_horn_particles', '1', {
  FCVAR_ARCHIVE,
  FCVAR_NOTIFY
}, 'Visual horn particles when player uses physgun')
local HORN_FP = CreateConVar('ppm2_horn_firstperson', '1', {
  FCVAR_ARCHIVE,
  FCVAR_NOTIFY
}, 'Visual horn effetcs in first person')
local HORN_HIDE_BEAM = CreateConVar('ppm2_horn_nobeam', '1', {
  FCVAR_ARCHIVE,
  FCVAR_NOTIFY
}, 'Hide physgun beam')
local DRAW_LEGS_DEPTH = CreateConVar('ppm2_render_legsdepth', '1', {
  FCVAR_ARCHIVE,
  FCVAR_NOTIFY
}, 'Render legs in depth pass. Useful with Boken DoF enabled')
local LEGS_RENDER_TYPE = CreateConVar('ppm2_render_legstype', '0', {
  FCVAR_ARCHIVE,
  FCVAR_NOTIFY
}, 'When render legs. 0 - Before Opaque renderables; 1 - after Translucent renderables')
PPM2.ENABLE_NEW_RAGDOLLS = CreateConVar('ppm2_sv_new_ragdolls', '1', {
  FCVAR_NOTIFY,
  FCVAR_REPLICATED
}, 'Enable new ragdolls')
local ENABLE_NEW_RAGDOLLS = PPM2.ENABLE_NEW_RAGDOLLS
local SHOULD_DRAW_VIEWMODEL = CreateConVar('ppm2_cl_draw_hands', '1', {
  FCVAR_ARCHIVE
}, 'Should draw hooves as viewmodel')
local SV_SHOULD_DRAW_VIEWMODEL = CreateConVar('ppm2_sv_draw_hands', '1', {
  FCVAR_NOTIFY,
  FCVAR_REPLICATED
}, 'Should draw hooves as viewmodel')
hook.Add('PreDrawPlayerHands', 'PPM2.ViewModel', function(arms, viewmodel, ply, weapon)
  if arms == nil then
    arms = NULL
  end
  if viewmodel == nil then
    viewmodel = NULL
  end
  if ply == nil then
    ply = LocalPlayer()
  end
  if weapon == nil then
    weapon = NULL
  end
  if PPM2.__RENDERING_REFLECTIONS then
    return 
  end
  if not (IsValid(arms)) then
    return 
  end
  if not (ply.__cachedIsPony) then
    return 
  end
  local observer = ply:GetObserverTarget()
  if IsValid(observer) then
    if not (observer.__cachedIsPony) then
      return 
    end
  end
  if not (SV_SHOULD_DRAW_VIEWMODEL:GetBool()) then
    return true
  end
  if not (SHOULD_DRAW_VIEWMODEL:GetBool()) then
    return true
  end
  if not (ply:Alive()) then
    return 
  end
  arms:SetPos(ply:EyePos() + Vector(0, 0, 100))
  local wep = ply:GetActiveWeapon()
  if IsValid(wep) and wep.UseHands == false then
    return true
  end
  if arms:GetModel() ~= 'models/cppm/pony_arms.mdl' then
    return 
  end
  local data = ply:GetPonyData()
  if not (data) then
    return 
  end
  local status = data:GetRenderController():PreDrawArms(arms)
  if status ~= nil then
    return status
  end
  arms.__ppm2_draw = true
end)
hook.Add('PostDrawPlayerHands', 'PPM2.ViewModel', function(arms, viewmodel, ply, weapon)
  if arms == nil then
    arms = NULL
  end
  if viewmodel == nil then
    viewmodel = NULL
  end
  if ply == nil then
    ply = LocalPlayer()
  end
  if weapon == nil then
    weapon = NULL
  end
  if PPM2.__RENDERING_REFLECTIONS then
    return 
  end
  if not (IsValid(arms)) then
    return 
  end
  if not (arms.__ppm2_draw) then
    return 
  end
  local data = ply:GetPonyData()
  if not (data) then
    return 
  end
  data:GetRenderController():PostDrawArms(arms)
  arms.__ppm2_draw = false
end)
local mat_dxlevel = GetConVar('mat_dxlevel')
timer.Create('PPM2.CheckDXLevel', 180, 0, function()
  if mat_dxlevel:GetInt() > 90 then
    timer.Remove('PPM2.CheckDXLevel')
    return 
  end
  return PPM2.Message('Direct3D Level is LESS THAN 9.1! This will not work!')
end)
local IN_DRAW = false
local MARKED_FOR_DRAW = { }
PPM2.PreDrawOpaqueRenderables = function(bDrawingDepth, bDrawingSkybox)
  if IN_DRAW or PPM2.__RENDERING_REFLECTIONS then
    return 
  end
  MARKED_FOR_DRAW = { }
  for _, ply in ipairs(player.GetAll()) do
    if not IsDormant(ply) then
      local p = IsPony(ply)
      ply.__cachedIsPony = p
      if p then
        local data = GetPonyData(ply)
        if data then
          local renderController = data:GetRenderController()
          if renderController then
            renderController:PreDraw()
            table.insert(MARKED_FOR_DRAW, renderController)
          end
        end
      end
    end
  end
  if bDrawingDepth and DRAW_LEGS_DEPTH:GetBool() then
    do
      local _with_0 = LocalPlayer()
      if _with_0.__cachedIsPony and _with_0:Alive() then
        do
          local data = _with_0:GetPonyData()
          if data then
            IN_DRAW = true
            data:GetRenderController():DrawLegsDepth()
            IN_DRAW = false
          end
        end
      end
    end
  end
  if bDrawingDepth or bDrawingSkybox then
    return 
  end
  if not LEGS_RENDER_TYPE:GetBool() then
    do
      local _with_0 = LocalPlayer()
      if _with_0.__cachedIsPony and _with_0:Alive() then
        do
          local data = _with_0:GetPonyData()
          if data then
            IN_DRAW = true
            data:GetRenderController():DrawLegs()
            IN_DRAW = false
          end
        end
      end
      return _with_0
    end
  end
end
PPM2.PostDrawTranslucentRenderables = function(bDrawingDepth, bDrawingSkybox)
  if not bDrawingDepth and not bDrawingSkybox then
    for _, draw in ipairs(MARKED_FOR_DRAW) do
      draw:PostDraw()
    end
  end
end
PPM2.PostDrawOpaqueRenderables = function(bDrawingDepth, bDrawingSkybox)
  if IN_DRAW or PPM2.__RENDERING_REFLECTIONS then
    return 
  end
  if bDrawingDepth and DRAW_LEGS_DEPTH:GetBool() then
    do
      local _with_0 = LocalPlayer()
      if _with_0.__cachedIsPony and _with_0:Alive() then
        do
          local data = _with_0:GetPonyData()
          if data then
            IN_DRAW = true
            data:GetRenderController():DrawLegsDepth()
            IN_DRAW = false
          end
        end
      end
    end
  end
  if bDrawingDepth or bDrawingSkybox then
    return 
  end
  if not ENABLE_NEW_RAGDOLLS:GetBool() then
    for _, ply in ipairs(player.GetAll()) do
      local alive = ply:Alive()
      if not alive then
        ply.__ppm2_last_dead = RealTimeL() + 2
      end
      if ply.__cachedIsPony then
        if ply:GetPonyData() and not alive then
          local data = ply:GetPonyData()
          local rag = ply:GetRagdollEntity()
          if IsValid(rag) then
            local renderController = data:GetRenderController()
            data:DoRagdollMerge()
            if renderController then
              renderController:PreDraw(rag)
              IN_DRAW = true
              rag:DrawModel()
              IN_DRAW = false
              renderController:PostDraw(rag)
            end
          end
        end
      end
    end
  end
  if LEGS_RENDER_TYPE:GetBool() then
    do
      local _with_0 = LocalPlayer()
      if _with_0.__cachedIsPony and _with_0:Alive() then
        do
          local data = _with_0:GetPonyData()
          if data then
            IN_DRAW = true
            data:GetRenderController():DrawLegs()
            IN_DRAW = false
          end
        end
      end
      return _with_0
    end
  end
end
local Think
Think = function()
  for _, task in ipairs(PPM2.NetworkedPonyData.RenderTasks) do
    local ent = task.ent
    if IsValid(ent) and ent.__cachedIsPony then
      if ent.__ppm2_task_hit then
        ent.__ppm2_task_hit = false
        ent:SetNoDraw(false)
      end
      if not ent.__ppm2RenderOverride then
        ent = ent
        ent.__ppm2_oldRenderOverride = ent.RenderOverride
        ent.__ppm2RenderOverride = function()
          local renderController = task:GetRenderController()
          renderController:PreDraw(ent, true)
          ent:DrawModel()
          renderController:PostDraw(ent, true)
          if ent.__ppm2_oldRenderOverride then
            return ent.__ppm2_oldRenderOverride(ent)
          end
        end
        ent.RenderOverride = ent.__ppm2RenderOverride
      end
    end
  end
end
PPM2.PrePlayerDraw = function(self)
  if PPM2.__RENDERING_REFLECTIONS then
    return 
  end
  do
    local data = GetPonyData(self)
    if not data then
      return 
    end
    self.__cachedIsPony = IsPony(self)
    if not self.__cachedIsPony then
      return 
    end
    local f = FrameNumberL()
    if self.__ppm2_last_draw == f then
      return 
    end
    self.__ppm2_last_draw = f
    local bones = PPMBonesModifier(self)
    if data and bones:CanThink() then
      self:ResetBoneManipCache()
      bones:ResetBones()
      if data then
        hook.Call('PPM2.SetupBones', nil, self, data)
      end
      bones:Think()
      self:ApplyBoneManipulations()
      self._ppmBonesModified = true
    end
    return data
  end
end
PPM2.PostPlayerDraw = function(self)
  if PPM2.__RENDERING_REFLECTIONS then
    return 
  end
  do
    local data = GetPonyData(self)
    if not data or not self.__cachedIsPony then
      return 
    end
    local renderController = data:GetRenderController()
    if renderController then
      renderController:PostDraw()
    end
    return data
  end
end
do
  local hornGlowStatus = { }
  local smokeMaterial = 'ppm2/hornsmoke'
  local fireMat = 'particle/fire'
  local hornShift = Vector(1, 0.15, 14.5)
  hook.Add('PreDrawHalos', 'PPM2.HornEffects', function(self)
    if not HORN_HIDE_BEAM:GetBool() then
      return 
    end
    local frame = FrameNumberL()
    local cTime = (RealTimeL() % 20) * 4
    for ent, status in pairs(hornGlowStatus) do
      if IsValid(ent) and status.frame == frame and IsValid(status.target) then
        local additional = math.sin(cTime / 2 + status.haloSeed * 3) * 40
        local newCol = status.color + Color(additional, additional, additional)
        halo.Add({
          status.target
        }, newCol, math.sin(cTime + status.haloSeed) * 4 + 8, math.cos(cTime + status.haloSeed) * 4 + 8, 2)
      end
    end
  end)
  hook.Add('Think', 'PPM2.HornEffects', function(self)
    local frame = FrameNumberL()
    for ent, status in pairs(hornGlowStatus) do
      if not IsValid(ent) then
        if IsValid(status.emmiter) then
          status.emmiter:Finish()
        end
        if IsValid(status.emmiterProp) then
          status.emmiterProp:Finish()
        end
        hornGlowStatus[ent] = nil
      elseif status.frame ~= frame then
        status.data:SetHornGlow(status.prevStatus)
        if IsValid(status.emmiter) then
          status.emmiter:Finish()
        end
        if IsValid(status.emmiterProp) then
          status.emmiterProp:Finish()
        end
        hornGlowStatus[ent] = nil
      else
        if not status.prevStatus and RENDER_HORN_GLOW:GetBool() and status.data:GetHornGlow() ~= status.isEnabled then
          status.data:SetHornGlow(status.isEnabled)
        end
        if status.attach and IsValid(status.target) then
          local grabHornPos = Vector(hornShift) * status.data:GetPonySize()
          local Pos, Ang
          do
            local _obj_0 = ent:GetAttachment(status.attach)
            Pos, Ang = _obj_0.Pos, _obj_0.Ang
          end
          grabHornPos:Rotate(Ang)
          if status.isEnabled and IsValid(status.emmiter) and status.nextSmokeParticle < RealTimeL() then
            status.nextSmokeParticle = RealTimeL() + math.Rand(0.1, 0.2)
            for i = 1, math.random(1, 4) do
              local vec = VectorRand()
              local calcPos = Pos + grabHornPos + vec
              do
                local particle = status.emmiter:Add(smokeMaterial, calcPos)
                particle:SetRollDelta(math.rad(math.random(0, 360)))
                particle:SetPos(calcPos)
                local life = math.Rand(0.6, 0.9)
                particle:SetStartAlpha(math.random(80, 170))
                particle:SetDieTime(life)
                particle:SetColor(status.color.r, status.color.g, status.color.b)
                particle:SetEndAlpha(0)
                local size = math.Rand(2, 3)
                particle:SetEndSize(math.Rand(2, size))
                particle:SetStartSize(size)
                particle:SetGravity(Vector())
                particle:SetAirResistance(10)
                local vecRand = VectorRand()
                vecRand.z = vecRand.z * 2
                particle:SetVelocity(ent:GetVelocity() + vecRand * status.data:GetPonySize() * 2)
                particle:SetCollide(false)
              end
            end
          end
          if status.isEnabled and IsValid(status.emmiterProp) and status.nextGrabParticle < RealTimeL() and status.mins and status.maxs then
            status.nextGrabParticle = RealTimeL() + math.Rand(0.05, 0.3)
            status.emmiterProp:SetPos(status.tpos)
            for i = 1, math.random(2, 6) do
              local calcPos = Vector(math.Rand(status.mins.x, status.maxs.x), math.Rand(status.mins.y, status.maxs.y), math.Rand(status.mins.z, status.maxs.z))
              do
                local particle = status.emmiterProp:Add(fireMat, calcPos)
                particle:SetRollDelta(math.rad(math.random(0, 360)))
                particle:SetPos(calcPos)
                local life = math.Rand(0.5, 0.9)
                particle:SetStartAlpha(math.random(130, 230))
                particle:SetDieTime(life)
                particle:SetColor(status.color.r, status.color.g, status.color.b)
                particle:SetEndAlpha(0)
                particle:SetEndSize(0)
                particle:SetStartSize(math.Rand(2, 6))
                particle:SetGravity(Vector())
                particle:SetAirResistance(15)
                particle:SetVelocity(VectorRand() * 6)
                particle:SetCollide(false)
              end
            end
          end
        end
      end
    end
  end)
  hook.Add('DrawPhysgunBeam', 'PPM2.HornEffects', function(self, physgun, isEnabled, target, bone, hitPos)
    if physgun == nil then
      physgun = NULL
    end
    if isEnabled == nil then
      isEnabled = false
    end
    if target == nil then
      target = NULL
    end
    if bone == nil then
      bone = 0
    end
    if hitPos == nil then
      hitPos = Vector()
    end
    if not self:IsPony() or not HORN_FP:GetBool() and self == LocalPlayer() and not self:ShouldDrawLocalPlayer() then
      return 
    end
    local data = self:GetPonyData()
    if not data then
      return 
    end
    if data:GetRace() ~= PPM2.RACE_UNICORN and data:GetRace() ~= PPM2.RACE_ALICORN then
      return 
    end
    if not hornGlowStatus[self] then
      hornGlowStatus[self] = {
        frame = FrameNumberL(),
        prevStatus = data:GetHornGlow(),
        data = data,
        isEnabled = isEnabled,
        hitPos = hitPos,
        target = target,
        bone = bone,
        tpos = self:GetPos(),
        attach = self:LookupAttachment('eyes'),
        nextSmokeParticle = 0,
        nextGrabParticle = 0
      }
      do
        local _with_0 = hornGlowStatus[self]
        if HORN_PARTICLES:GetBool() then
          _with_0.emmiter = ParticleEmitter(EyePos())
          _with_0.emmiterProp = ParticleEmitter(EyePos())
        end
        _with_0.color = data:GetHornMagicColor()
        _with_0.haloSeed = math.rad(math.random(-1000, 1000))
        if not data:GetSeparateMagicColor() then
          if not data:GetSeparateEyes() then
            _with_0.color = data:GetEyeIrisTop():Lerp(0.5, data:GetEyeIrisBottom())
          else
            local lerpLeft = data:GetEyeIrisTopLeft():Lerp(0.5, data:GetEyeIrisBottomLeft())
            local lerpRight = data:GetEyeIrisTopRight():Lerp(0.5, data:GetEyeIrisBottomRight())
            _with_0.color = lerpLeft:Lerp(0.5, lerpRight)
          end
        end
      end
    else
      do
        local _with_0 = hornGlowStatus[self]
        _with_0.frame = FrameNumberL()
        _with_0.isEnabled = isEnabled
        _with_0.target = target
        _with_0.bone = bone
        _with_0.hitPos = hitPos
        if IsValid(target) then
          _with_0.tpos = target:GetPos() + hitPos
          local center = target:WorldSpaceCenter()
          _with_0.center = center
          local mins, maxs = target:WorldSpaceAABB()
          _with_0.mins = center + (mins - center) * 1.2
          _with_0.maxs = center + (maxs - center) * 1.2
        end
      end
    end
    if HORN_HIDE_BEAM:GetBool() and IsValid(target) then
      return false
    end
  end)
end
hook.Add('PrePlayerDraw', 'PPM2.PlayerDraw', PPM2.PrePlayerDraw, -2)
hook.Add('PostPlayerDraw', 'PPM2.PostPlayerDraw', PPM2.PostPlayerDraw, -2)
hook.Add('PostDrawOpaqueRenderables', 'PPM2.PostDrawOpaqueRenderables', PPM2.PostDrawOpaqueRenderables, -2)
hook.Add('Think', 'PPM2.UpdateRenderTasks', Think, -2)
hook.Add('PreDrawOpaqueRenderables', 'PPM2.PreDrawOpaqueRenderables', PPM2.PreDrawOpaqueRenderables, -2)
return hook.Add('PostDrawTranslucentRenderables', 'PPM2.PostDrawTranslucentRenderables', PPM2.PostDrawTranslucentRenderables, -2)
