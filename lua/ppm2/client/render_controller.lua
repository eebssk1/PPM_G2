local PPM2
PPM2 = _G.PPM2
local ENABLE_FLASHLIGHT_PASS = CreateConVar('ppm2_flashlight_pass', '1', {
  FCVAR_ARCHIVE
}, 'Enable flashlight render pass. This kills FPS.')
local ENABLE_LEGS = CreateConVar('ppm2_draw_legs', '1', {
  FCVAR_ARCHIVE
}, 'Draw pony legs.')
local USE_RENDER_OVERRIDE = CreateConVar('ppm2_legs_new', '1', {
  FCVAR_ARCHIVE
}, 'Use RenderOverride function for legs drawing')
local LEGS_RENDER_TYPE = CreateConVar('ppm2_render_legstype', '0', {
  FCVAR_ARCHIVE
}, 'When render legs. 0 - Before Opaque renderables; 1 - after Translucent renderables')
local ENABLE_STARE = CreateConVar('ppm2_render_stare', '1', {
  FCVAR_ARCHIVE
}, 'Make eyes follow players and move when idling')
local PonyRenderController
do
  local _class_0
  local _parent_0 = PPM2.ControllerChildren
  local _base_0 = {
    CompileTextures = function(self)
      if self.GetTextureController and self:GetTextureController() then
        return self:GetTextureController():CompileTextures()
      end
    end,
    GetModel = function(self)
      return self.controller:GetModel()
    end,
    GetLegs = function(self)
      if not self.isValid then
        return NULL
      end
      if self:GetEntity() ~= LocalPlayer() then
        return NULL
      end
      if not IsValid() then
        self:CreateLegs()
      end
      return self.legsModel
    end,
    CreateLegs = function(self)
      if not self.isValid then
        return NULL
      end
      if self:GetEntity() ~= LocalPlayer() then
        return NULL
      end
      for _, ent in ipairs(ents.GetAll()) do
        if ent.isPonyLegsModel then
          ent:Remove()
        end
      end
      do
        local _with_0 = ClientsideModel(self.modelCached)
        self.legsModel = _with_0
        _with_0.isPonyLegsModel = true
        _with_0.lastRedrawFix = 0
        _with_0:SetNoDraw(true)
        _with_0.__PPM2_PonyData = self:GetData()
      end
      self:GetData():GetWeightController():UpdateWeight(self.legsModel)
      self.lastLegUpdate = CurTimeL()
      self.legClipPlanePos = Vector(0, 0, 0)
      self.legBGSetup = CurTimeL()
      self.legUpdateFrame = 0
      self.legClipDot = 0
      self.duckOffsetHack = self.__class.LEG_CLIP_OFFSET_STAND
      self.legsClipPlane = self.__class.LEG_CLIP_VECTOR
      return self.legsModel
    end,
    UpdateLegs = function(self)
      if not self.isValid then
        return 
      end
      if not ENABLE_LEGS:GetBool() then
        return 
      end
      if not (IsValid(self.legsModel)) then
        return 
      end
      if self.legUpdateFrame == FrameNumberL() then
        return 
      end
      self.legUpdateFrame = FrameNumberL()
      local ctime = CurTimeL()
      local ply = self:GetEntity()
      local seq = ply:GetSequence()
      local legsModel = self.legsModel
      do
        local _with_0 = self.legsModel
        if ply.__ppmBonesModifiers then
          PPM2.EntityBonesModifier.ThinkObject(ply.__ppmBonesModifiers)
        end
        for boneid = 0, ply:GetBoneCount() - 1 do
          _with_0:ManipulateBonePosition(0, ply:GetManipulateBonePosition(0))
          _with_0:ManipulateBoneAngles(0, ply:GetManipulateBoneAngles(0))
          _with_0:ManipulateBoneScale(0, ply:GetManipulateBoneScale(0))
        end
        if seq ~= self.legSeq then
          self.legSeq = seq
          _with_0:ResetSequence(seq)
        end
        if self.legBGSetup < ctime then
          self.legBGSetup = ctime + 1
          for _, group in ipairs(ply:GetBodyGroups()) do
            _with_0:SetBodygroup(group.id, ply:GetBodygroup(group.id))
          end
        end
        _with_0:FrameAdvance(ctime - self.lastLegUpdate)
        _with_0:SetPlaybackRate(self.__class.LEG_ANIM_SPEED_CONST * ply:GetPlaybackRate())
        self.lastLegUpdate = ctime
        _with_0:SetPoseParameter('move_x', (ply:GetPoseParameter('move_x') * 2) - 1)
        _with_0:SetPoseParameter('move_y', (ply:GetPoseParameter('move_y') * 2) - 1)
        _with_0:SetPoseParameter('move_yaw', (ply:GetPoseParameter('move_yaw') * 360) - 180)
        _with_0:SetPoseParameter('body_yaw', (ply:GetPoseParameter('body_yaw') * 180) - 90)
        _with_0:SetPoseParameter('spine_yaw', (ply:GetPoseParameter('spine_yaw') * 180) - 90)
      end
      if ply:InVehicle() then
        local bonePos
        do
          local bone = self.legsModel:LookupBone('LrigNeck1')
          if bone then
            do
              local boneData = self.legsModel:GetBonePosition(bone)
              if boneData then
                bonePos = boneData
              end
            end
          end
        end
        local veh = ply:GetVehicle()
        local vehAng = veh:GetAngles()
        local eyepos = EyePos()
        vehAng:RotateAroundAxis(vehAng:Up(), 90)
        local clipAng = Angle(vehAng.p, vehAng.y, vehAng.r)
        clipAng:RotateAroundAxis(clipAng:Right(), -90)
        self.legsClipPlane = clipAng:Forward()
        self.legsModel:SetRenderAngles(vehAng)
        local drawPos = Vector(self.__class.LEG_SHIFT_CONST_VEHICLE, 0, self.__class.LEG_Z_CONST_VEHICLE)
        drawPos:Rotate(vehAng)
        self.legsModel:SetPos(eyepos - drawPos)
        self.legsModel:SetRenderOrigin(eyepos - drawPos)
        if not bonePos then
          local legClipPlanePos = Vector(0, 0, self.__class.LEG_CLIP_OFFSET_VEHICLE)
          legClipPlanePos:Rotate(vehAng)
          self.legClipPlanePos = eyepos - legClipPlanePos
        else
          self.legClipPlanePos = bonePos
        end
      else
        self.legsClipPlane = self.__class.LEG_CLIP_VECTOR
        local eangles = EyeAngles()
        local yaw = eangles.y - ply:GetPoseParameter('head_yaw') * 180 + 90
        local newAng = Angle(0, yaw, 0)
        local rad = math.rad(yaw)
        local sin, cos = math.sin(rad), math.cos(rad)
        local pos = ply:GetPos()
        local x, y, z
        x, y, z = pos.x, pos.y, pos.z
        local newPos = Vector(x - cos * self.__class.LEG_SHIFT_CONST, y - sin * self.__class.LEG_SHIFT_CONST, z + self.__class.LEG_Z_CONST)
        if ply:Crouching() then
          self.duckOffsetHack = self.__class.LEG_CLIP_OFFSET_DUCK
        else
          self.duckOffsetHack = Lerp(0.1, self.duckOffsetHack, self.__class.LEG_CLIP_OFFSET_STAND)
        end
        self.legsModel:SetRenderAngles(newAng)
        self.legsModel:SetAngles(newAng)
        self.legsModel:SetRenderOrigin(newPos)
        self.legsModel:SetPos(newPos)
        do
          local bone = self.legsModel:LookupBone('LrigNeck1')
          if bone then
            do
              local boneData = self.legsModel:GetBonePosition(bone)
              if boneData then
                self.legClipPlanePos = boneData
              else
                self.legClipPlanePos = Vector(x, y, z + self.duckOffsetHack)
              end
            end
          else
            self.legClipPlanePos = Vector(x, y, z + self.duckOffsetHack)
          end
        end
      end
      self.legClipDot = self.legsClipPlane:Dot(self.legClipPlanePos)
    end,
    DrawLegs = function(self, start3D)
      if start3D == nil then
        start3D = false
      end
      if not self.isValid then
        return 
      end
      if not ENABLE_LEGS:GetBool() then
        return 
      end
      if not self:GetEntity():Alive() then
        return 
      end
      if self:GetEntity():InVehicle() and EyeAngles().p < 30 then
        return 
      end
      if not self:GetEntity():InVehicle() and EyeAngles().p < 60 then
        return 
      end
      if not (IsValid(self.legsModel)) then
        self:CreateLegs()
      end
      if not (IsValid(self.legsModel)) then
        return 
      end
      if self:GetEntity():ShouldDrawLocalPlayer() then
        return 
      end
      if (self:GetEntity():GetPos() + self:GetEntity():GetViewOffset()):DistToSqr(EyePos()) > self.__class.LEGS_MAX_DISTANCE then
        return 
      end
      if USE_RENDER_OVERRIDE:GetBool() then
        self.legsModel:SetNoDraw(false)
        local rTime = RealTimeL()
        if self.legsModel.lastRedrawFix < rTime then
          self.legsModel:DrawModel()
          self.legsModel.lastRedrawFix = rTime + 5
        end
        if not self.legsModel.RenderOverride then
          self.legsModel.RenderOverride = function()
            return self:DrawLegsOverride()
          end
          self.legsModel:DrawModel()
        end
        return 
      else
        self.legsModel:SetNoDraw(true)
      end
      self:UpdateLegs()
      local oldClip = render.EnableClipping(true)
      render.PushCustomClipPlane(self.legsClipPlane, self.legClipDot)
      if start3D then
        cam.Start3D()
      end
      self:GetTextureController():PreDrawLegs(self.legsModel)
      self.legsModel:DrawModel()
      self:GetTextureController():PostDrawLegs(self.legsModel)
      if LEGS_RENDER_TYPE:GetBool() and ENABLE_FLASHLIGHT_PASS:GetBool() then
        render.PushFlashlightMode(true)
        self:GetTextureController():PreDrawLegs(self.legsModel)
        do
          local sizes = self:GetData():GetSizeController()
          if sizes then
            sizes:ModifyNeck(self.legsModel)
            sizes:ModifyLegs(self.legsModel)
            sizes:ModifyScale(self.legsModel)
          end
        end
        self.legsModel:DrawModel()
        self:GetTextureController():PostDrawLegs(self.legsModel)
        render.PopFlashlightMode()
      end
      render.PopCustomClipPlane()
      if start3D then
        cam.End3D()
      end
      return render.EnableClipping(oldClip)
    end,
    DrawLegsOverride = function(self)
      if not self.isValid then
        return 
      end
      if not ENABLE_LEGS:GetBool() then
        return 
      end
      if not self:GetEntity():Alive() then
        return 
      end
      if self:GetEntity():InVehicle() and EyeAngles().p < 30 then
        return 
      end
      if not self:GetEntity():InVehicle() and EyeAngles().p < 60 then
        return 
      end
      if self:GetEntity():ShouldDrawLocalPlayer() then
        return 
      end
      if (self:GetEntity():GetPos() + self:GetEntity():GetViewOffset()):DistToSqr(EyePos()) > self.__class.LEGS_MAX_DISTANCE then
        return 
      end
      self:UpdateLegs()
      local oldClip = render.EnableClipping(true)
      render.PushCustomClipPlane(self.legsClipPlane, self.legClipDot)
      self:GetTextureController():PreDrawLegs(self.legsModel)
      self.legsModel:DrawModel()
      self:GetTextureController():PostDrawLegs(self.legsModel)
      render.PopCustomClipPlane()
      return render.EnableClipping(oldClip)
    end,
    DrawLegsDepth = function(self, start3D)
      if start3D == nil then
        start3D = false
      end
      if not self.isValid then
        return 
      end
      if not ENABLE_LEGS:GetBool() then
        return 
      end
      if not self:GetEntity():Alive() then
        return 
      end
      if self:GetEntity():InVehicle() and EyeAngles().p < 30 then
        return 
      end
      if not self:GetEntity():InVehicle() and EyeAngles().p < 60 then
        return 
      end
      if not (IsValid(self.legsModel)) then
        self:CreateLegs()
      end
      if not (IsValid(self.legsModel)) then
        return 
      end
      if self:GetEntity():ShouldDrawLocalPlayer() then
        return 
      end
      if (self:GetEntity():GetPos() + self:GetEntity():GetViewOffset()):DistToSqr(EyePos()) > self.__class.LEGS_MAX_DISTANCE then
        return 
      end
      self:UpdateLegs()
      local oldClip = render.EnableClipping(true)
      render.PushCustomClipPlane(self.legsClipPlane, self.legClipDot)
      if start3D then
        cam.Start3D()
      end
      self:GetTextureController():PreDrawLegs(self.legsModel)
      do
        local sizes = self:GetData():GetSizeController()
        if sizes then
          sizes:ModifyNeck(self.legsModel)
          sizes:ModifyLegs(self.legsModel)
          sizes:ModifyScale(self.legsModel)
        end
      end
      self.legsModel:DrawModel()
      self:GetTextureController():PostDrawLegs()
      render.PopCustomClipPlane()
      if start3D then
        cam.End3D()
      end
      return render.EnableClipping(oldClip)
    end,
    IsValid = function(self)
      return IsValid(self:GetEntity()) and self.isValid
    end,
    Reset = function(self)
      if self.flexes and self.flexes.Reset then
        self.flexes:Reset()
      end
      if self.emotes and self.emotes.Reset then
        self.emotes:Reset()
      end
      if self.GetTextureController and self:GetTextureController() and self:GetTextureController().Reset then
        self:GetTextureController():Reset()
      end
      if self.GetTextureController and self:GetTextureController() then
        return self:GetTextureController():ResetTextures()
      end
    end,
    Remove = function(self)
      if self.flexes then
        self.flexes:Remove()
      end
      if self.emotes then
        self.emotes:Remove()
      end
      if self.GetTextureController and self:GetTextureController() then
        self:GetTextureController():Remove()
      end
      self.isValid = false
    end,
    PlayerDeath = function(self)
      if not self.isValid then
        return 
      end
      if self.emotes then
        self.emotes:Remove()
        self.emotes = nil
      end
      if PPM2.ENABLE_NEW_RAGDOLLS:GetBool() then
        self:HideModels(true)
      end
      if self:GetTextureController() and self:GetEntity():IsPony() then
        return self:GetTextureController():ResetTextures()
      end
    end,
    PlayerRespawn = function(self)
      if not self.isValid then
        return 
      end
      self:GetEmotesController()
      if self:GetEntity():IsPony() then
        self:HideModels(false)
      end
      if self.flexes then
        self.flexes:PlayerRespawn()
      end
      if self:GetTextureController() then
        return self:GetTextureController():ResetTextures()
      end
    end,
    DrawModels = function(self)
      if IsValid(self.socksModel) then
        self.socksModel:DrawModel()
      end
      if IsValid(self.newSocksModel) then
        return self.newSocksModel:DrawModel()
      end
    end,
    ShouldHideModels = function(self)
      return self.hideModels or self:GetEntity():GetNoDraw()
    end,
    DoHideModels = function(self, status)
      if IsValid(self.socksModel) then
        self.socksModel:SetNoDraw(status)
      end
      if IsValid(self.newSocksModel) then
        return self.newSocksModel:SetNoDraw(status)
      end
    end,
    HideModels = function(self, status)
      if status == nil then
        status = true
      end
      if self.hideModels == status then
        return 
      end
      self:DoHideModels(status)
      self.hideModels = status
    end,
    CheckTarget = function(self, epos, pos)
      return not util.TraceLine({
        start = epos,
        endpos = pos,
        filter = self:GetEntity(),
        mask = MASK_BLOCKLOS
      }).Hit
    end,
    UpdateStare = function(self)
      local ctime = RealTimeL()
      if self.lastStareUpdate > ctime then
        return 
      end
      if (not self.idleEyes or not ENABLE_STARE:GetBool()) and self.idleEyesActive then
        self.staringAt = NULL
        self:GetEntity():SetEyeTarget(Vector())
        self.idleEyesActive = false
        return 
      end
      if not self.idleEyes or not ENABLE_STARE:GetBool() then
        return 
      end
      self.idleEyesActive = true
      self.lastStareUpdate = ctime + 0.2
      local lpos = self:GetEntity():EyePos()
      if IsValid(self.staringAt) and self.staringAt:IsPlayer() and not self.staringAt:Alive() then
        self.staringAt = NULL
      end
      if IsValid(self.staringAt) then
        local trNew = util.TraceLine({
          start = lpos,
          endpos = lpos + self:GetEntity():EyeAnglesFixed():Forward() * 270,
          filter = self:GetEntity()
        })
        if trNew.Entity:IsValid() and trNew.Entity:IsPlayer() then
          self.staringAt = trNew.Entity
        end
        local epos = self.staringAt:EyePos()
        if epos:Distance(lpos) < 300 and DLib.combat.inPVS(self:GetEntity(), self.staringAt) and self:CheckTarget(lpos, epos) then
          self:GetEntity():SetEyeTarget(epos)
          return 
        end
        self.staringAt = NULL
        self:GetEntity():SetEyeTarget(Vector())
      end
      if player.GetCount() ~= 1 then
        local last
        local max = 300
        local lastpos
        for _, ply in ipairs(player.GetAll()) do
          if self:GetEntity() ~= ply and ply:Alive() then
            local epos = ply:EyePos()
            local dist = epos:Distance(lpos)
            if dist < max and DLib.combat.inPVS(self:GetEntity(), ply) and self:CheckTarget(lpos, epos) then
              max = dist
              last = ply
              lastpos = epos
            end
          end
        end
        if last then
          self:GetEntity():SetEyeTarget(lastpos)
          self.staringAt = last
          return 
        end
      end
      if self.nextRollEyes > ctime then
        return 
      end
      self.nextRollEyes = ctime + math.random(4, 16) / 6
      local ang = self:GetEntity():EyeAnglesFixed()
      self.eyeRollTargetPos = Vector(math.random(200, 400), math.random(-80, 80), math.random(-20, 20))
      self.prevRollTargetPos = self.prevRollTargetPos or self.eyeRollTargetPos
    end,
    UpdateEyeRoll = function(self)
      if not ENABLE_STARE:GetBool() or not self.idleEyes or not self.eyeRollTargetPos or IsValid(self.staringAt) then
        return 
      end
      self.prevRollTargetPos = LerpVector(FrameTime() * 6, self.prevRollTargetPos, self.eyeRollTargetPos)
      local roll = Vector(self.prevRollTargetPos)
      roll:Rotate(self:GetEntity():EyeAnglesFixed())
      return self:GetEntity():SetEyeTarget(self:GetEntity():EyePos() + roll)
    end,
    PreDraw = function(self, ent, drawingNewTask)
      if ent == nil then
        ent = self:GetEntity()
      end
      if drawingNewTask == nil then
        drawingNewTask = false
      end
      if not self.isValid then
        return 
      end
      do
        local _with_0 = self:GetTextureController()
        _with_0:PreDraw(ent, drawingNewTask)
      end
      if drawingNewTask then
        do
          local bones = ent:PPMBonesModifier()
          ent:ResetBoneManipCache()
          bones:ResetBones()
          hook.Call('PPM2.SetupBones', nil, ent, self.controller)
          bones:Think(true)
          ent.__ppmBonesModified = true
          ent:ApplyBoneManipulations()
        end
      end
      if self.flexes then
        self.flexes:Think(ent)
      end
      if self.emotes then
        self.emotes:Think(ent)
      end
      if self:GetEntity():IsPlayer() then
        self:UpdateStare()
        self:UpdateEyeRoll()
      end
      if ent.RenderOverride and not ent.__ppm2RenderOverride and self:GrabData('HideManes') and self:GrabData('HideManesSocks') then
        if IsValid(self.socksModel) then
          self.socksModel:SetNoDraw(true)
        end
        if IsValid(self.newSocksModel) then
          return self.newSocksModel:SetNoDraw(true)
        end
      else
        if IsValid(self.socksModel) then
          self.socksModel:SetNoDraw(self:ShouldHideModels())
        end
        if IsValid(self.newSocksModel) then
          return self.newSocksModel:SetNoDraw(self:ShouldHideModels())
        end
      end
    end,
    PostDraw = function(self, ent, drawingNewTask)
      if ent == nil then
        ent = self:GetEntity()
      end
      if drawingNewTask == nil then
        drawingNewTask = false
      end
      if not self.isValid then
        return 
      end
      return self:GetTextureController():PostDraw(ent, drawingNewTask)
    end,
    PreDrawArms = function(self, ent)
      if not self.isValid then
        return 
      end
      if ent and not self.armsWeightSetup then
        self.armsWeightSetup = true
        local weight = 1 + (self:GetData():GetWeight() - 1) * 0.4
        local vec = LVector(weight, weight, weight)
        for i = 1, 13 do
          ent:ManipulateBoneScale2Safe(i, vec)
        end
      end
      return ent:SetSubMaterial(self.__class.ARMS_MATERIAL_INDEX, self:GetTextureController():GetBodyName())
    end,
    PostDrawArms = function(self, ent)
      if not self.isValid then
        return 
      end
      return ent:SetSubMaterial(self.__class.ARMS_MATERIAL_INDEX, '')
    end,
    DataChanges = function(self, state)
      if not self.isValid then
        return 
      end
      if not self:GetEntity() then
        return 
      end
      self:GetTextureController():DataChanges(state)
      if self.flexes then
        self.flexes:DataChanges(state)
      end
      if self.emotes then
        self.emotes:DataChanges(state)
      end
      local _exp_0 = state:GetKey()
      if 'Weight' == _exp_0 then
        self.armsWeightSetup = false
        if IsValid(self.legsModel) then
          return self:GetData():GetWeightController():UpdateWeight(self.legsModel)
        end
      elseif 'SocksModel' == _exp_0 then
        self.socksModel = self:GetData():GetSocksModel()
        if IsValid(self.socksModel) then
          self.socksModel:SetNoDraw(self:ShouldHideModels())
        end
        if self:GetTextureController() and IsValid(self.socksModel) then
          return self:GetTextureController():UpdateSocks(self:GetEntity(), self.socksModel)
        end
      elseif 'NewSocksModel' == _exp_0 then
        self.newSocksModel = self:GetData():GetNewSocksModel()
        if IsValid(self.newSocksModel) then
          self.newSocksModel:SetNoDraw(self:ShouldHideModels())
        end
        if self:GetTextureController() and IsValid(self.newSocksModel) then
          return self:GetTextureController():UpdateNewSocks(self:GetEntity(), self.newSocksModel)
        end
      elseif 'NoFlex' == _exp_0 then
        if state:GetValue() then
          if self.flexes then
            self.flexes:ResetSequences()
          end
          self.flexes = nil
        else
          return self:CreateFlexController()
        end
      end
    end,
    GetTextureController = function(self)
      if not self.isValid then
        return self.renderController
      end
      if not self.renderController then
        local cls = PPM2.GetTextureController(self.modelCached)
        self.renderController = cls(self)
      end
      self.renderController.ent = self:GetEntity()
      return self.renderController
    end,
    CreateFlexController = function(self)
      if not self.isValid then
        return self.flexes
      end
      if self:GetData():GetNoFlex() then
        return 
      end
      if not self.flexes then
        local cls = PPM2.GetFlexController(self.modelCached)
        if not cls then
          return 
        end
        self.flexes = cls(self)
      end
      self.flexes.ent = self:GetEntity()
      return self.flexes
    end,
    CreateEmotesController = function(self)
      if not self.isValid then
        return self.emotes
      end
      if not self.emotes or not self.emotes:IsValid() then
        local cls = PPM2.GetPonyExpressionsController(self.modelCached)
        if not cls then
          return 
        end
        self.emotes = cls(self)
      end
      self.emotes.ent = self:GetEntity()
      return self.emotes
    end,
    GetFlexController = function(self)
      return self.flexes
    end,
    GetEmotesController = function(self)
      return self.emotes
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, controller)
      _class_0.__parent.__init(self, controller)
      self.hideModels = false
      self.modelCached = controller:GetModel()
      self.IGNORE_DRAW = false
      if self:GetEntity():IsValid() then
        self:CompileTextures()
      end
      if self:GetEntity() == LocalPlayer() then
        self:CreateLegs()
      end
      self.socksModel = controller:GetSocksModel()
      if IsValid(self.socksModel) then
        self.socksModel:SetNoDraw(false)
      end
      self.newSocksModel = controller:GetNewSocksModel()
      if IsValid(self.newSocksModel) then
        self.newSocksModel:SetNoDraw(false)
      end
      self.lastStareUpdate = 0
      self.staringAt = NULL
      self.rotatedHeadTarget = false
      self.idleEyes = true
      self.idleEyesActive = false
      self.nextRollEyes = 0
      if self:GetEntity():IsValid() then
        self:CreateFlexController()
        return self:CreateEmotesController()
      end
    end,
    __base = _base_0,
    __name = "PonyRenderController",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.AVALIABLE_CONTROLLERS = { }
  self.MODELS = {
    'models/ppm/player_default_base.mdl',
    'models/ppm/player_default_base_nj.mdl',
    'models/cppm/player_default_base.mdl',
    'models/cppm/player_default_base_nj.mdl'
  }
  self.LEG_SHIFT_CONST = 24
  self.LEG_SHIFT_CONST_VEHICLE = 14
  self.LEG_Z_CONST = 0
  self.LEG_Z_CONST_VEHICLE = 20
  self.LEG_ANIM_SPEED_CONST = 1
  self.LEG_CLIP_OFFSET_STAND = 28
  self.LEG_CLIP_OFFSET_DUCK = 12
  self.LEG_CLIP_OFFSET_VEHICLE = 11
  self.LEG_CLIP_VECTOR = Vector(0, 0, -1)
  self.LEGS_MAX_DISTANCE = 60 ^ 2
  self.ARMS_MATERIAL_INDEX = 0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  PonyRenderController = _class_0
end
local NewPonyRenderController
do
  local _class_0
  local _parent_0 = PonyRenderController
  local _base_0 = {
    __tostring = function(self)
      return "[" .. tostring(self.__class.__name) .. ":" .. tostring(self.objID) .. "|" .. tostring(self:GetData()) .. "]"
    end,
    DataChanges = function(self, state)
      if not self:GetEntity() then
        return 
      end
      if not self.isValid then
        return 
      end
      local _exp_0 = state:GetKey()
      if 'UpperManeModel' == _exp_0 then
        self.upperManeModel = self:GetData():GetUpperManeModel()
        if IsValid(self.upperManeModel) then
          self.upperManeModel:SetNoDraw(self:ShouldHideModels())
        end
        if self:GetTextureController() and IsValid(self.upperManeModel) then
          self:GetTextureController():UpdateUpperMane(self:GetEntity(), self.upperManeModel)
        end
      elseif 'LowerManeModel' == _exp_0 then
        self.lowerManeModel = self:GetData():GetLowerManeModel()
        if IsValid(self.lowerManeModel) then
          self.lowerManeModel:SetNoDraw(self:ShouldHideModels())
        end
        if self:GetTextureController() and IsValid(self.lowerManeModel) then
          self:GetTextureController():UpdateLowerMane(self:GetEntity(), self.lowerManeModel)
        end
      elseif 'TailModel' == _exp_0 then
        self.tailModel = self:GetData():GetTailModel()
        if IsValid(self.tailModel) then
          self.tailModel:SetNoDraw(self:ShouldHideModels())
        end
        if self:GetTextureController() and IsValid(self.tailModel) then
          self:GetTextureController():UpdateTail(self:GetEntity(), self.tailModel)
        end
      end
      return _class_0.__parent.__base.DataChanges(self, state)
    end,
    DrawModels = function(self)
      if IsValid(self.upperManeModel) then
        self.upperManeModel:DrawModel()
      end
      if IsValid(self.lowerManeModel) then
        self.lowerManeModel:DrawModel()
      end
      if IsValid(self.tailModel) then
        self.tailModel:DrawModel()
      end
      return _class_0.__parent.__base.DrawModels(self)
    end,
    DoHideModels = function(self, status)
      _class_0.__parent.__base.DoHideModels(self, status)
      if IsValid(self.upperManeModel) then
        self.upperManeModel:SetNoDraw(status)
      end
      if IsValid(self.lowerManeModel) then
        self.lowerManeModel:SetNoDraw(status)
      end
      if IsValid(self.tailModel) then
        return self.tailModel:SetNoDraw(status)
      end
    end,
    PreDraw = function(self, ent, drawingNewTask)
      if ent == nil then
        ent = self:GetEntity()
      end
      if drawingNewTask == nil then
        drawingNewTask = false
      end
      _class_0.__parent.__base.PreDraw(self, ent, drawingNewTask)
      if ent.RenderOverride and not ent.__ppm2RenderOverride and self:GrabData('HideManes') then
        if IsValid(self.upperManeModel) and self:GrabData('HideManesMane') then
          self.upperManeModel:SetNoDraw(true)
        end
        if IsValid(self.lowerManeModel) and self:GrabData('HideManesMane') then
          self.lowerManeModel:SetNoDraw(true)
        end
        if IsValid(self.tailModel) and self:GrabData('HideManesTail') then
          return self.tailModel:SetNoDraw(true)
        end
      else
        if IsValid(self.upperManeModel) then
          self.upperManeModel:SetNoDraw(self:ShouldHideModels())
        end
        if IsValid(self.lowerManeModel) then
          self.lowerManeModel:SetNoDraw(self:ShouldHideModels())
        end
        if IsValid(self.tailModel) then
          return self.tailModel:SetNoDraw(self:ShouldHideModels())
        end
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, data)
      _class_0.__parent.__init(self, data)
      self.upperManeModel = data:GetUpperManeModel()
      self.lowerManeModel = data:GetLowerManeModel()
      self.tailModel = data:GetTailModel()
      if IsValid(self.upperManeModel) then
        self.upperManeModel:SetNoDraw(self:ShouldHideModels())
      end
      if IsValid(self.lowerManeModel) then
        self.lowerManeModel:SetNoDraw(self:ShouldHideModels())
      end
      if IsValid(self.tailModel) then
        return self.tailModel:SetNoDraw(self:ShouldHideModels())
      end
    end,
    __base = _base_0,
    __name = "NewPonyRenderController",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.MODELS = {
    'models/ppm/player_default_base_new.mdl',
    'models/ppm/player_default_base_new_nj.mdl'
  }
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  NewPonyRenderController = _class_0
end
hook.Add('NotifyShouldTransmit', 'PPM2.RenderController', function(self, should)
  do
    local data = self:GetPonyData()
    if data then
      do
        local renderer = data:GetRenderController()
        if renderer then
          return renderer:HideModels(not should)
        end
      end
    end
  end
end)
PPM2.PonyRenderController = PonyRenderController
PPM2.NewPonyRenderController = NewPonyRenderController
PPM2.GetPonyRenderController = function(model)
  if model == nil then
    model = 'models/ppm/player_default_base.mdl'
  end
  return PonyRenderController.AVALIABLE_CONTROLLERS[model:lower()] or PonyRenderController
end
PPM2.GetPonyRendererController = PPM2.GetPonyRenderController
PPM2.GetRenderController = PPM2.GetPonyRenderController
PPM2.GetRendererController = PPM2.GetPonyRenderController
