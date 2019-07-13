local BonesSequence
do
  local _class_0
  local _parent_0 = PPM2.SequenceBase
  local _base_0 = {
    GetController = function(self)
      return self.controller
    end,
    GetEntity = function(self)
      return self.ent
    end,
    Think = function(self, delta)
      if delta == nil then
        delta = 0
      end
      self.ent = self.controller.ent
      if not IsValid(self.ent) then
        return false
      end
      return _class_0.__parent.__base.Think(self, delta)
    end,
    Stop = function(self)
      _class_0.__parent.__base.Stop(self)
      return self.controller:ResetModifiers(self.name .. '_sequence')
    end,
    SetBonePosition = function(self, id, val)
      if id == nil then
        id = 1
      end
      if val == nil then
        val = LVector(0, 0, 0)
      end
      return self.controller[self.bonesFuncsPos[id]] and self.controller[self.bonesFuncsPos[id]](self.controller, self.modifierID, val)
    end,
    SetBoneScale = function(self, id, val)
      if id == nil then
        id = 1
      end
      if val == nil then
        val = 0
      end
      return self.controller[self.bonesFuncsScale[id]] and self.controller[self.bonesFuncsScale[id]](self.controller, self.modifierID, val)
    end,
    SetBoneAngles = function(self, id, val)
      if id == nil then
        id = 1
      end
      if val == nil then
        val = Angle(0, 0, 0)
      end
      return self.controller[self.bonesFuncsAngles[id]] and self.controller[self.bonesFuncsAngles[id]](self.controller, self.modifierID, val)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, controller, data)
      _class_0.__parent.__init(self, controller, data)
      self.bonesNames, self.numid = data['bones'], data['numid']
      self.modifierID = controller:GetModifierID(self.name .. '_sequence')
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _, boneName in ipairs(self.bonesNames) do
          _accum_0[_len_0] = 'SetModifier' .. boneName .. 'Position'
          _len_0 = _len_0 + 1
        end
        self.bonesFuncsPos = _accum_0
      end
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _, boneName in ipairs(self.bonesNames) do
          _accum_0[_len_0] = 'SetModifier' .. boneName .. 'Scale'
          _len_0 = _len_0 + 1
        end
        self.bonesFuncsScale = _accum_0
      end
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _, boneName in ipairs(self.bonesNames) do
          _accum_0[_len_0] = 'SetModifier' .. boneName .. 'Angles'
          _len_0 = _len_0 + 1
        end
        self.bonesFuncsAngles = _accum_0
      end
      self.ent = controller.ent
      self.controller = controller
      return self:Launch()
    end,
    __base = _base_0,
    __name = "BonesSequence",
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
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  BonesSequence = _class_0
end
PPM2.BonesSequence = BonesSequence
local RESET_BONE_POS = LVector(0, 0, 0)
local RESET_BONE_ANGLES = Angle(0, 0, 0)
local RESET_BONE_SCALE = LVector(1, 1, 1)
local resetBones
resetBones = function(ent)
  for i = 0, ent:GetBoneCount() - 1 do
    ent:ManipulateBonePosition2Safe(i, RESET_BONE_POS)
    ent:ManipulateBoneScale2Safe(i, RESET_BONE_SCALE)
    ent:ManipulateBoneAngles2Safe(i, RESET_BONE_ANGLES)
  end
end
for _, ent in ipairs(ents.GetAll()) do
  ent.__ppmBonesModifiers = nil
end
do
  local _class_0
  local _parent_0 = PPM2.SequenceHolder
  local _base_0 = {
    Setup = function(self, ent)
      if ent == nil then
        ent = self.ent
      end
      if not IsValid(ent) then
        return false
      end
      self.lastModel = ent:GetModel()
      self.isLocalPlayer = CLIENT and ent == LocalPlayer()
      self:ClearModifiers()
      self.isValid = true
      self.ent = ent
      self.bonesMappingID = { }
      self.bonesMappingName = { }
      self.boneCount = ent:GetBoneCount()
      do
        local _accum_0 = { }
        local _len_0 = 1
        for i = 0, self.boneCount - 1 do
          local name = ent:GetBoneName(i)
          self.bonesMappingID[i] = name
          self.bonesMapping[i] = name
          self.bonesMappingName[name] = i
          self.bonesMapping[name] = i
          self.bonesMappingForName[name] = name
          self.bonesMappingForName[i] = name
          self.bonesMappingForID[name] = i
          self.bonesMappingForID[i] = i
          self:RegisterModifier(name .. 'Position', (function()
            return LVector(0, 0, 0)
          end), (function()
            return LVector(0, 0, 0)
          end))
          self:RegisterModifier(name .. 'Scale', (function()
            return LVector(0, 0, 0)
          end), (function()
            return LVector(0, 0, 0)
          end))
          self:RegisterModifier(name .. 'Angles', (function()
            return Angle(0, 0, 0)
          end), (function()
            return Angle(0, 0, 0)
          end))
          self:SetupLerpTables(name .. 'Position')
          self:SetupLerpTables(name .. 'Scale')
          self:SetupLerpTables(name .. 'Angles')
          self:SetLerpFunc(name .. 'Position', Lerp)
          self:SetLerpFunc(name .. 'Scale', Lerp)
          self:SetLerpFunc(name .. 'Angles', LerpAngle)
          local _value_0 = {
            i,
            name,
            'Calculate' .. name .. 'Position',
            'Calculate' .. name .. 'Scale',
            'Calculate' .. name .. 'Angles'
          }
          _accum_0[_len_0] = _value_0
          _len_0 = _len_0 + 1
        end
        self.bonesIterable = _accum_0
      end
    end,
    CanThink = function(self)
      if SERVER then
        return true
      end
      if self.isLocalPlayer and not self.ent:ShouldDrawLocalPlayer() then
        return false
      end
      return self.callFrame ~= FrameNumberL() and (not self.defferReset or self.defferReset < RealTimeL())
    end,
    Think = function(self, force)
      if force == nil then
        force = false
      end
      if not _class_0.__parent.__base.Think(self) or not force and CLIENT and self.callFrame == FrameNumberL() then
        return 
      end
      if CLIENT then
        self.callFrame = FrameNumberL()
      end
      do
        local _with_0 = self.ent
        local calcBonesPos = { }
        local calcBonesAngles = { }
        local calcBonesScale = { }
        for id = 0, self.boneCount - 1 do
          if self.fullBoneMove then
            calcBonesPos[id] = _with_0:GetManipulateBonePosition2Safe(id)
          end
          if not self.fullBoneMove then
            calcBonesPos[id] = Vector()
          end
          if self.fullBoneMove then
            calcBonesAngles[id] = _with_0:GetManipulateBoneAngles2Safe(id)
          end
          if not self.fullBoneMove then
            calcBonesAngles[id] = Angle()
          end
          calcBonesScale[id] = _with_0:GetManipulateBoneScale2Safe(id)
        end
        for i, data in ipairs(self.bonesIterable) do
          local id = data[1]
          if self.fullBoneMove then
            calcBonesPos[id] = calcBonesPos[id] + self[data[3]](self)
          end
          calcBonesScale[id] = calcBonesScale[id] + self[data[4]](self)
        end
        if self.fullBoneMove then
          for i, data in ipairs(self.bonesIterable) do
            calcBonesAngles[data[1]] = calcBonesAngles[data[1]] + self[data[5]](self)
          end
        end
        for id = 0, self.boneCount - 1 do
          if self.fullBoneMove then
            _with_0:ManipulateBonePosition2Safe(id, calcBonesPos[id]:ToNative())
          end
          _with_0:ManipulateBoneScale2Safe(id, calcBonesScale[id]:ToNative())
          if self.fullBoneMove then
            _with_0:ManipulateBoneAngles2Safe(id, calcBonesAngles[id])
          end
        end
        return _with_0
      end
    end,
    ResetBones = function(self)
      if self.defferReset and self.defferReset > RealTimeL() then
        return 
      end
      return resetBones(self.ent)
    end,
    IsValid = function(self)
      return self.isValid and self.ent:IsValid()
    end,
    GetEntity = function(self)
      return self.ent
    end,
    Remove = function(self)
      if not self.isValid then
        return 
      end
      self:ClearModifiers()
      _class_0.__parent.__base.Remove(self)
      if IsValid(self.ent) then
        self.ent.__ppmBonesModifiers = nil
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ent)
      if ent == nil then
        ent = NULL
      end
      _class_0.__parent.__init(self)
      self.fullBoneMove = SERVER or ent:GetClass() ~= 'prop_ragdoll'
      self.ent = ent
      self.isLocalPlayer = CLIENT and ent == LocalPlayer()
      self.bonesMappingID = { }
      self.bonesMappingName = { }
      self.bonesMapping = { }
      self.bonesMappingForName = { }
      self.bonesMappingForID = { }
      self.bonesIterable = { }
      self.boneCount = 0
      self.isValid = false
      table.insert(self.__class.OBJECTS, self)
      self.lastCall = RealTimeL()
      if IsValid(ent) then
        return self:Setup()
      end
    end,
    __base = _base_0,
    __name = "EntityBonesModifier",
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
  self.OBJECTS = { }
  self.resetBones = resetBones
  self.SEQUENCES = {
    {
      ['name'] = 'floppy_ears',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 5,
      ['bones'] = {
        'Ear_L',
        'Ear_R'
      },
      ['reset'] = function(self)
        self:SetBoneAngles(1, Angle(0, -84, -40))
        return self:SetBoneAngles(2, Angle(0, 84, -40))
      end,
      ['func'] = function(self, delta, timeOfAnim) end
    },
    {
      ['name'] = 'floppy_ears_weak',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 5,
      ['bones'] = {
        'Ear_L',
        'Ear_R'
      },
      ['reset'] = function(self)
        self:SetBoneAngles(1, Angle(0, -20, -20))
        return self:SetBoneAngles(2, Angle(0, 20, -20))
      end,
      ['func'] = function(self, delta, timeOfAnim) end
    },
    {
      ['name'] = 'forward_ears',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 5,
      ['bones'] = {
        'Ear_L',
        'Ear_R'
      },
      ['reset'] = function(self)
        self:SetBoneAngles(1, Angle(0, -15, -27))
        return self:SetBoneAngles(2, Angle(0, 15, -27))
      end,
      ['func'] = function(self, delta, timeOfAnim) end
    },
    {
      ['name'] = 'neck_flopping_backward',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 3,
      ['bones'] = {
        'LrigNeck3'
      },
      ['reset'] = function(self) end,
      ['func'] = function(self, delta, timeOfAnim)
        return self:SetBoneAngles(1, Angle(0, -12 * timeOfAnim, math.sin(CurTimeL() * 4) * 20))
      end
    },
    {
      ['name'] = 'neck_backward',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 5,
      ['bones'] = {
        'LrigNeck3'
      },
      ['reset'] = function(self)
        return self:SetBoneAngles(1, Angle(0, -12, 0))
      end
    },
    {
      ['name'] = 'neck_twitch',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 5,
      ['bones'] = {
        'LrigNeck3'
      },
      ['func'] = function(self, delta, timeOfAnim)
        return self:SetBoneAngles(1, Angle(0, math.cos(CurTimeL() * 4) * 20, 0))
      end
    },
    {
      ['name'] = 'neck_twitch_fast',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 5,
      ['bones'] = {
        'LrigNeck3'
      },
      ['func'] = function(self, delta, timeOfAnim)
        return self:SetBoneAngles(1, Angle(0, math.cos(CurTimeL() * 8) * 20, 0))
      end
    },
    {
      ['name'] = 'neck_left',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 5,
      ['bones'] = {
        'LrigNeck3'
      },
      ['reset'] = function(self)
        return self:SetBoneAngles(1, Angle(14, 0, 12))
      end
    },
    {
      ['name'] = 'neck_right',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 5,
      ['bones'] = {
        'LrigNeck3'
      },
      ['reset'] = function(self)
        return self:SetBoneAngles(1, Angle(-14, 0, -12))
      end
    },
    {
      ['name'] = 'forward_left',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 3,
      ['bones'] = {
        'LrigNeck3'
      },
      ['reset'] = function(self)
        return self:SetBoneAngles(1, Angle(10, 12, -9))
      end
    },
    {
      ['name'] = 'forward_right',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 3,
      ['bones'] = {
        'LrigNeck3'
      },
      ['reset'] = function(self)
        return self:SetBoneAngles(1, Angle(-10, 12, 9))
      end
    }
  }
  self.SequenceObject = BonesSequence
  if CLIENT then
    local PreDrawOpaqueRenderables
    PreDrawOpaqueRenderables = function(a, b)
      for _, obj in ipairs(self.OBJECTS) do
        if not obj:IsValid() then
          local oldObjects = self.OBJECTS
          self.OBJECTS = { }
          for _, obj2 in ipairs(oldObjects) do
            if obj2:IsValid() then
              table.insert(self.OBJECTS, obj2)
            else
              local lent = obj2.ent
              obj2.invalidate = true
              if IsValid(lent) then
                lent.__ppmBonesModifiers = nil
              end
            end
          end
          return 
        end
        if obj.ent:IsPony() and (not obj.ent:IsPlayer() and not obj.ent.__ppm2RenderOverride or obj.ent == LocalPlayer()) then
          if obj:CanThink() and not obj.ent:IsDormant() and not obj.ent:GetNoDraw() then
            obj.ent:ResetBoneManipCache()
            resetBones(obj.ent)
            local data = obj.ent:GetPonyData()
            if data then
              hook.Call('PPM2.SetupBones', nil, obj.ent, data)
            end
            obj:Think()
            obj.ent.__ppmBonesModified = true
            obj.ent:ApplyBoneManipulations()
          end
        elseif obj.ent.__ppmBonesModified and not obj.ent:IsPlayer() and not obj.ent.__ppm2RenderOverride then
          resetBones(obj.ent)
          obj.ent.__ppmBonesModified = false
        end
      end
    end
    hook.Add('PreDrawOpaqueRenderables', 'PPM2.EntityBonesModifier', PreDrawOpaqueRenderables, -5)
  else
    timer.Create('PPM2.ThinkBoneModifiers', 1, 0, function()
      for _, obj in ipairs(self.OBJECTS) do
        if not obj:IsValid() then
          local oldObjects = self.OBJECTS
          self.OBJECTS = { }
          for _, obj2 in ipairs(oldObjects) do
            if obj2:IsValid() then
              table.insert(self.OBJECTS, obj2)
            else
              local lent = obj2.ent
              obj2.invalidate = true
              if IsValid(lent) then
                if lent.__ppmBonesModifiers then
                  resetBones(lent)
                end
                lent.__ppmBonesModifiers = nil
              end
            end
          end
          return 
        end
        if obj.ent:IsPony() and obj:CanThink() then
          PPM2.EntityBonesModifier.ThinkObject(obj)
        elseif obj.ent.__ppmBonesModified then
          resetBones(obj.ent)
          obj.ent.__ppmBonesModified = false
        end
      end
    end)
  end
  self.ThinkObject = function(obj)
    obj.ent:ResetBoneManipCache()
    resetBones(obj.ent)
    local data = obj.ent:GetPonyData()
    if data then
      hook.Call('PPM2.SetupBones', nil, obj.ent, data)
    end
    obj:Think()
    obj.ent.__ppmBonesModified = true
    return obj.ent:ApplyBoneManipulations()
  end
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  PPM2.EntityBonesModifier = _class_0
end
do
  local _with_0 = FindMetaTable('Entity')
  _with_0.PPMBonesModifier = function(self)
    do
      local t = _with_0.GetTable(self)
      if not t then
        return 
      end
      if IsValid(t.__ppmBonesModifiers) and not t.__ppmBonesModifiers.invalidate then
        return t.__ppmBonesModifiers
      end
      t.__ppmBonesModifiers = PPM2.EntityBonesModifier(self)
      t.__ppmBonesModifiers.ent = self
      if t.__ppmBonesModifiers.lastModel ~= self:GetModel() then
        t.__ppmBonesModifiers:Setup(self)
      end
      return t.__ppmBonesModifiers
    end
  end
end
if CLIENT then
  hook.Add('PAC3ResetBones', 'PPM2.EntityBonesModifier', function(self)
    if not self:IsPony() then
      return 
    end
    local data = self:GetPonyData()
    self:ResetBoneManipCache()
    if data then
      hook.Call('PPM2.SetupBones', nil, data.ent, data)
    end
    if self.__ppmBonesModifiers then
      self.__ppmBonesModifiers:Think(true)
      self.__ppmBonesModifiers.defferReset = RealTimeL() + 0.2
    end
    return self:ApplyBoneManipulations()
  end)
end
for _, ent in ipairs(ents.GetAll()) do
  ent.__ppmBonesModifiers = nil
end
