local DISABLE_FLEXES = CreateConVar('ppm2_disable_flexes', '0', {
  FCVAR_ARCHIVE
}, 'Disable pony flexes controllers. Saves some FPS.')
local FlexState
do
  local _class_0
  local _parent_0 = PPM2.ModifierBase
  local _base_0 = {
    __tostring = function(self)
      return "[" .. tostring(self.__class.__name) .. ":" .. tostring(self.flexName) .. "[" .. tostring(self.flexID) .. "]|" .. tostring(self:GetData()) .. "]"
    end,
    GetFlexID = function(self)
      return self.flexID
    end,
    GetFlexName = function(self)
      return self.flexName
    end,
    SetUseLerp = function(self, val)
      if val == nil then
        val = true
      end
      self.useLerp = val
    end,
    GetUseLerp = function(self)
      return self.useLerp
    end,
    UseLerp = function(self)
      return self.useLerp
    end,
    SetLerpModify = function(self, val)
      if val == nil then
        val = 1
      end
      self.lerpMultiplier = val
    end,
    GetLerpModify = function(self)
      return self.lerpMultiplier
    end,
    LerpModify = function(self)
      return self.lerpMultiplier
    end,
    GetEntity = function(self)
      return self.controller:GetEntity()
    end,
    GetData = function(self)
      return self.controller
    end,
    GetController = function(self)
      return self.controller
    end,
    GetValue = function(self)
      return self.current
    end,
    GetRealValue = function(self)
      return self.target
    end,
    SetValue = function(self, val)
      if val == nil then
        val = self.target
      end
      self.current = math.Clamp(val, self.min, self.max) * self.scale * self.scaleModify
      self.target = self.target
    end,
    SetRealValue = function(self, val)
      if val == nil then
        val = self.target
      end
      self.target = math.Clamp(val, self.min, self.max) * self.scale * self.scaleModify
    end,
    GetScale = function(self)
      return self.scale
    end,
    GetSpeed = function(self)
      return self.speed
    end,
    GetScaleModify = function(self)
      return self.scaleModify
    end,
    GetSpeedModify = function(self)
      return self.speedModify
    end,
    GetOriginalScale = function(self)
      return self.originalscale
    end,
    GetOriginalSpeed = function(self)
      return self.originalspeed
    end,
    SetScale = function(self, val)
      if val == nil then
        val = self.scale
      end
      self.scale = val
    end,
    GetSpeed = function(self, val)
      if val == nil then
        val = self.speed
      end
      self.speed = val
    end,
    SetScaleModify = function(self, val)
      if val == nil then
        val = self.scaleModify
      end
      self.scaleModify = val
    end,
    GetSpeedModify = function(self, val)
      if val == nil then
        val = self.speedModify
      end
      self.speedModify = val
    end,
    GetIsActive = function(self)
      return self.active
    end,
    SetIsActive = function(self, val)
      if val == nil then
        val = true
      end
      self.active = val
    end,
    AddValue = function(self, val)
      if val == nil then
        val = 0
      end
      return self:SetValue(self.current + val)
    end,
    AddRealValue = function(self, val)
      if val == nil then
        val = 0
      end
      return self:SetRealValue(self.target + val)
    end,
    Think = function(self, ent, delta)
      if ent == nil then
        ent = self:GetEntity()
      end
      if delta == nil then
        delta = 0
      end
      if not self.active then
        return 
      end
      if self.useModifiers then
        self.current = 0
        self.scale = self.originalscale * self.scaleModify
        self.speed = self.originalspeed * self.speedModify
        for i = 1, #self.WeightModifiers do
          self.modifiers[i] = Lerp(delta * 15 * self.speed * self.speedModify * self.lerpMultiplier, self.modifiers[i] or 0, self.WeightModifiers[i])
          self.current = self.current + self.modifiers[i]
        end
        for _, modif in ipairs(self.ScaleModifiers) do
          self.scale = self.scale + modif
        end
        for _, modif in ipairs(self.SpeedModifiers) do
          self.speed = self.speed + modif
        end
        self.current = math.Clamp(self.current, self.min, self.max) * self.scale
      end
      return ent:SetFlexWeight(self.flexID, self.current)
    end,
    DataChanges = function(self, state)
      if state:GetKey() ~= self.activeID then
        return 
      end
      self:SetIsActive(not state:GetValue())
      self:GetController():RebuildIterableList()
      return self:Reset()
    end,
    Reset = function(self, resetVars)
      if resetVars == nil then
        resetVars = true
      end
      for name, id in pairs(self.modifiersNames) do
        self:ResetModifiers(name)
      end
      if resetVars then
        self.scaleModify = 1
        self.speedModify = 1
      end
      self.scale = self.originalscale * self.scaleModify
      self.speed = self.originalspeed * self.speedModify
      self.target = 0
      self.current = 0
      if IsValid(self:GetEntity()) then
        return self:GetEntity():SetFlexWeight(self.flexID, 0)
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, controller, flexName, flexID, scale, speed, active, min, max, useModifiers)
      if flexName == nil then
        flexName = ''
      end
      if flexID == nil then
        flexID = 0
      end
      if scale == nil then
        scale = 1
      end
      if speed == nil then
        speed = 1
      end
      if active == nil then
        active = true
      end
      if min == nil then
        min = 0
      end
      if max == nil then
        max = 1
      end
      if useModifiers == nil then
        useModifiers = true
      end
      _class_0.__parent.__init(self)
      self.controller = controller
      self.name = flexName
      self.flexName = flexName
      self.flexID = flexID
      self.id = flexID
      self.scale = scale
      self.speed = speed
      self.originalscale = scale
      self.originalspeed = speed
      self.min = min
      self.max = max
      self.current = -1
      self.target = 0
      self.speedModify = 1
      self.scaleModify = 1
      self.modifiers = { }
      self.useModifiers = useModifiers
      self.active = active
      self.useLerp = true
      self.lerpMultiplier = 1
      self.activeID = "DisableFlex" .. tostring(self.flexName)
    end,
    __base = _base_0,
    __name = "FlexState",
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
  self.SetupModifiers = function(self)
    self:RegisterModifier('Speed', 0)
    self:RegisterModifier('Scale', 0)
    return self:RegisterModifier('Weight', 0)
  end
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  FlexState = _class_0
end
PPM2.FlexState = FlexState
local FlexSequence
do
  local _class_0
  local _parent_0 = PPM2.SequenceBase
  local _base_0 = {
    GetController = function(self)
      return self.controller
    end,
    GetModifierID = function(self, id)
      if id == nil then
        id = ''
      end
      return self.flexIDS[id]
    end,
    GetFlexState = function(self, id)
      if id == nil then
        id = ''
      end
      return self.flexStates[id]
    end,
    Think = function(self, delta)
      if delta == nil then
        delta = 0
      end
      if not IsValid(self:GetEntity()) then
        return false
      end
      return _class_0.__parent.__base.Think(self, delta)
    end,
    Stop = function(self)
      _class_0.__parent.__base.Stop(self)
      if not (self.parent) then
        return 
      end
      for _, id in ipairs(self.flexIDsIterable) do
        self.parent:GetFlexState(id):ResetModifiers(self.name)
      end
    end,
    SetModifierWeight = function(self, id, val)
      if id == nil then
        id = ''
      end
      if val == nil then
        val = 0
      end
      return self:GetFlexState(id):SetModifierWeight(self:GetModifierID(id), val)
    end,
    SetModifierSpeed = function(self, id, val)
      if id == nil then
        id = ''
      end
      if val == nil then
        val = 0
      end
      return self:GetFlexState(id):SetModifierSpeed(self:GetModifierID(id), val)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, controller, data)
      _class_0.__parent.__init(self, controller, data)
      self.flexIDsIterable, self.numid = data['ids'], data['numid']
      self.flexIDS = { }
      self.flexStates = { }
      local i = 1
      for _, id in ipairs(data.ids) do
        local state = controller:GetFlexState(id)
        local num = state:GetModifierID(self.name)
        self["flex_" .. tostring(id)] = num
        self.flexIDS[id] = num
        self.flexStates[id] = state
        self.flexStates[i] = state
        self.flexIDS[i] = num
        i = i + 1
      end
      self.controller = controller
      return self:Launch()
    end,
    __base = _base_0,
    __name = "FlexSequence",
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
  FlexSequence = _class_0
end
PPM2.FlexSequence = FlexSequence
local PonyFlexController
do
  local _class_0
  local _parent_0 = PPM2.ControllerChildren
  local _base_0 = {
    IsValid = function(self)
      return self.isValid
    end,
    GetFlexState = function(self, name)
      if name == nil then
        name = ''
      end
      return self.statesTable[name]
    end,
    RebuildIterableList = function(self)
      if not self.isValid then
        return false
      end
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _, state in ipairs(self.states) do
          if state:GetIsActive() then
            _accum_0[_len_0] = state
            _len_0 = _len_0 + 1
          end
        end
        self.statesIterable = _accum_0
      end
    end,
    DataChanges = function(self, state)
      if not self.isValid then
        return 
      end
      for _, flexState in ipairs(self.states) do
        flexState:DataChanges(state)
      end
      if state:GetKey() == 'UseFlexLerp' then
        for _, flex in ipairs(self.states) do
          flex:SetUseLerp(state:GetValue())
        end
      end
      if state:GetKey() == 'FlexLerpMultiplier' then
        for _, flex in ipairs(self.states) do
          flex:SetLerpModify(state:GetValue())
        end
      end
    end,
    GetEntity = function(self)
      return self.controller:GetEntity()
    end,
    GetData = function(self)
      return self.controller
    end,
    GetController = function(self)
      return self.controller
    end,
    PlayerStartVoice = function(self, ply)
      if ply == nil then
        ply = NULL
      end
      if ply ~= self:GetEntity() then
        return 
      end
      return self:StartSequence('talk_endless')
    end,
    PlayerEndVoice = function(self, ply)
      if ply == nil then
        ply = NULL
      end
      if ply ~= self:GetEntity() then
        return 
      end
      return self:EndSequence('talk_endless')
    end,
    ResetSequences = function(self)
      _class_0.__parent.__base.ResetSequences(self)
      for _, state in ipairs(self.statesIterable) do
        state:Reset(false)
      end
    end,
    Think = function(self, ent)
      if ent == nil then
        ent = self:GetEntity()
      end
      if DISABLE_FLEXES:GetBool() then
        return 
      end
      local delta = _class_0.__parent.__base.Think(self, ent)
      if not delta then
        return 
      end
      for _, state in ipairs(self.statesIterable) do
        state:Think(ent, delta)
      end
      return delta
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, data)
      _class_0.__parent.__init(self, data)
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _, _des_0 in ipairs(self.__class.FLEX_LIST) do
          local flex, id, scale, speed, active
          flex, id, scale, speed, active = _des_0.flex, _des_0.id, _des_0.scale, _des_0.speed, _des_0.active
          _accum_0[_len_0] = FlexState(self, flex, id, scale, speed, active)
          _len_0 = _len_0 + 1
        end
        self.states = _accum_0
      end
      do
        local _tbl_0 = { }
        for _, state in ipairs(self.states) do
          _tbl_0[state:GetFlexName()] = state
        end
        self.statesTable = _tbl_0
      end
      for _, state in ipairs(self.states) do
        self.statesTable[state:GetFlexName():lower()] = state
      end
      for _, state in ipairs(self.states) do
        self.statesTable[state:GetFlexID()] = state
      end
      self:RebuildIterableList()
      local ponyData = data:GetData()
      for _, flex in ipairs(self.states) do
        flex:SetUseLerp(ponyData:GetUseFlexLerp())
      end
      for _, flex in ipairs(self.states) do
        flex:SetLerpModify(ponyData:GetFlexLerpMultiplier())
      end
      self:Hook('PlayerStartVoice', self.PlayerStartVoice)
      self:Hook('PlayerEndVoice', self.PlayerEndVoice)
      self:ResetSequences()
      return PPM2.DebugPrint('Created new flex controller for ', self:GetEntity(), ' as part of ', data, '; internal ID is ', self.fid)
    end,
    __base = _base_0,
    __name = "PonyFlexController",
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
    'models/ppm/player_default_base_new.mdl',
    'models/ppm/player_default_base_new_nj.mdl'
  }
  self.FLEX_LIST = {
    {
      flex = 'eyes_updown',
      scale = 1,
      speed = 1,
      active = false
    },
    {
      flex = 'eyes_rightleft',
      scale = 1,
      speed = 1,
      active = false
    },
    {
      flex = 'JawOpen',
      scale = 1,
      speed = 1,
      active = true
    },
    {
      flex = 'JawClose',
      scale = 1,
      speed = 1,
      active = true
    },
    {
      flex = 'Smirk',
      scale = 1,
      speed = 1,
      active = true
    },
    {
      flex = 'Frown',
      scale = 1,
      speed = 1,
      active = true
    },
    {
      flex = 'Stretch',
      scale = 1,
      speed = 1,
      active = false
    },
    {
      flex = 'Pucker',
      scale = 1,
      speed = 1,
      active = false
    },
    {
      flex = 'Grin',
      scale = 1,
      speed = 1,
      active = true
    },
    {
      flex = 'CatFace',
      scale = 1,
      speed = 1,
      active = true
    },
    {
      flex = 'Mouth_O',
      scale = 1,
      speed = 1,
      active = true
    },
    {
      flex = 'Mouth_O2',
      scale = 1,
      speed = 1,
      active = true
    },
    {
      flex = 'Mouth_Full',
      scale = 1,
      speed = 1,
      active = false
    },
    {
      flex = 'Tongue_Out',
      scale = 1,
      speed = 1,
      active = true
    },
    {
      flex = 'Tongue_Up',
      scale = 1,
      speed = 1,
      active = true
    },
    {
      flex = 'Tongue_Down',
      scale = 1,
      speed = 1,
      active = true
    },
    {
      flex = 'NoEyelashes',
      scale = 1,
      speed = 1,
      active = false
    },
    {
      flex = 'Eyes_Blink',
      scale = 1,
      speed = 1,
      active = false
    },
    {
      flex = 'Left_Blink',
      scale = 1,
      speed = 1,
      active = true
    },
    {
      flex = 'Right_Blink',
      scale = 1,
      speed = 1,
      active = true
    },
    {
      flex = 'Scrunch',
      scale = 1,
      speed = 1,
      active = true
    },
    {
      flex = 'FatButt',
      scale = 1,
      speed = 1,
      active = false
    },
    {
      flex = 'Stomach_Out',
      scale = 1,
      speed = 1,
      active = true
    },
    {
      flex = 'Stomach_In',
      scale = 1,
      speed = 1,
      active = true
    },
    {
      flex = 'Throat_Bulge',
      scale = 1,
      speed = 1,
      active = true
    },
    {
      flex = 'Male',
      scale = 1,
      speed = 1,
      active = false
    },
    {
      flex = 'Hoof_Fluffers',
      scale = 1,
      speed = 1,
      active = false
    },
    {
      flex = 'o3o',
      scale = 1,
      speed = 1,
      active = true
    },
    {
      flex = 'Ear_Fluffers',
      scale = 1,
      speed = 1,
      active = false
    },
    {
      flex = 'Fangs',
      scale = 1,
      speed = 1,
      active = false
    },
    {
      flex = 'Claw_Teeth',
      scale = 1,
      speed = 1,
      active = false
    },
    {
      flex = 'Fang_Test',
      scale = 1,
      speed = 1,
      active = false
    },
    {
      flex = 'angry_eyes',
      scale = 1,
      speed = 1,
      active = true
    },
    {
      flex = 'sad_eyes',
      scale = 1,
      speed = 1,
      active = true
    },
    {
      flex = 'Eyes_Blink_Lower',
      scale = 1,
      speed = 1,
      active = true
    },
    {
      flex = 'Male_2',
      scale = 1,
      speed = 1,
      active = false
    },
    {
      flex = 'Buff_Body',
      scale = 1,
      speed = 1,
      active = false
    },
    {
      flex = 'Manliest_Chin',
      scale = 1,
      speed = 1,
      active = false
    },
    {
      flex = 'Lowerlid_Raise',
      scale = 1,
      speed = 1,
      active = false
    },
    {
      flex = 'Happy_Eyes',
      scale = 1,
      speed = 1,
      active = true
    },
    {
      flex = 'Duck',
      scale = 1,
      speed = 1,
      active = true
    }
  }
  self.SEQUENCES = {
    {
      ['name'] = 'anger',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 5,
      ['ids'] = {
        'Frown',
        'Grin',
        'angry_eyes',
        'Scrunch'
      },
      ['reset'] = function(self)
        self:SetTime(math.random(15, 45) / 10)
        self.lastStrengthUpdate = self.lastStrengthUpdate or 0
        if self.lastStrengthUpdate < CurTimeL() then
          self.lastStrengthUpdate = CurTimeL() + 2
          self.frownStrength = math.random(40, 100) / 100
          self.grinStrength = math.random(15, 40) / 100
          self.angryStrength = math.random(30, 80) / 100
          self.scrunchStrength = math.random(50, 100) / 100
          self:SetModifierWeight(1, self.frownStrength)
          self:SetModifierWeight(2, self.grinStrength)
          self:SetModifierWeight(3, self.angryStrength)
          return self:SetModifierWeight(4, self.scrunchStrength)
        end
      end
    },
    {
      ['name'] = 'sad',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 5,
      ['ids'] = {
        'Frown',
        'Grin',
        'sad_eyes'
      },
      ['reset'] = function(self)
        self:SetTime(math.random(15, 45) / 10)
        self.lastStrengthUpdate = self.lastStrengthUpdate or 0
        if self.lastStrengthUpdate < CurTimeL() then
          self.lastStrengthUpdate = CurTimeL() + 2
          self.frownStrength = math.random(40, 100) / 100
          self.grinStrength = math.random(15, 40) / 100
          self.angryStrength = math.random(30, 80) / 100
        end
      end,
      ['func'] = function(self, delta, timeOfAnim)
        self:SetModifierWeight(1, self.frownStrength)
        self:SetModifierWeight(2, self.grinStrength)
        return self:SetModifierWeight(3, self.angryStrength)
      end
    },
    {
      ['name'] = 'ugh',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 5,
      ['ids'] = {
        'sad_eyes',
        'Eyes_Blink_Lower'
      },
      ['reset'] = function(self)
        self:SetModifierWeight(1, math.Rand(0.27, 0.34))
        self:SetModifierWeight(2, math.Rand(0.3, 0.35))
        self:PauseSequence('eyes_blink')
        return self:PauseSequence('eyes_idle')
      end
    },
    {
      ['name'] = 'suggestive_eyes',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 5,
      ['ids'] = {
        'sad_eyes',
        'Eyes_Blink_Lower'
      },
      ['reset'] = function(self)
        self:SetModifierWeight(1, 0.28)
        self:SetModifierWeight(2, 0.4)
        self:PauseSequence('eyes_blink')
        return self:PauseSequence('eyes_idle')
      end
    },
    {
      ['name'] = 'lips_lick',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 5,
      ['ids'] = {
        'Tongue_Out',
        'Tongue_Up'
      },
      ['reset'] = function(self)
        return self:SetModifierWeight(1, 0.9)
      end,
      ['func'] = function(self, delta, timeOfAnim)
        return self:SetModifierWeight(2, 0.75 + math.sin(CurTimeL() * 7) * 0.25)
      end
    },
    {
      ['name'] = 'tongue_pullout',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 5,
      ['ids'] = {
        'Tongue_Out'
      },
      ['func'] = function(self, delta, timeOfAnim)
        return self:SetModifierWeight(1, 0.15 + math.sin(CurTimeL() * 10) * 0.1)
      end
    },
    {
      ['name'] = 'tongue_pullout_twitch',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 5,
      ['ids'] = {
        'Tongue_Out'
      },
      ['func'] = function(self, delta, timeOfAnim)
        return self:SetModifierWeight(1, 0.5 + math.sin(CurTimeL() * 4) * 0.5)
      end
    },
    {
      ['name'] = 'tongue_pullout_twitch_fast',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 5,
      ['ids'] = {
        'Tongue_Out'
      },
      ['func'] = function(self, delta, timeOfAnim)
        return self:SetModifierWeight(1, 0.5 + math.sin(CurTimeL() * 8) * 0.5)
      end
    },
    {
      ['name'] = 'suggestive_open',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 5,
      ['ids'] = {
        'Pucker',
        'JawOpen',
        'Scrunch'
      },
      ['reset'] = function(self)
        self:SetModifierWeight(1, math.Rand(0.28, 0.34))
        self:SetModifierWeight(2, math.Rand(0.35, 0.40))
        return self:SetModifierWeight(3, math.Rand(0.45, 0.50))
      end
    },
    {
      ['name'] = 'suggestive_open_anim',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 5,
      ['ids'] = {
        'Pucker',
        'JawOpen',
        'Scrunch'
      },
      ['reset'] = function(self)
        self:SetModifierWeight(1, math.Rand(0.28, 0.34))
        return self:SetModifierWeight(3, math.Rand(0.45, 0.50))
      end,
      ['func'] = function(self, delta, timeOfAnim)
        return self:SetModifierWeight(2, 0.2 + math.sin(CurTimeL() * 16) * 0.07)
      end
    },
    {
      ['name'] = 'face_smirk',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 5,
      ['ids'] = {
        'Smirk',
        'Frown'
      },
      ['reset'] = function(self)
        self:SetModifierWeight(1, 0.78)
        return self:SetModifierWeight(2, 0.61)
      end
    },
    {
      ['name'] = 'eyes_idle',
      ['autostart'] = true,
      ['repeat'] = true,
      ['time'] = 5,
      ['ids'] = {
        'Left_Blink',
        'Right_Blink'
      },
      ['func'] = function(self, delta, timeOfAnim)
        if self:GetEntity():GetNWBool('PPM2.IsDeathRagdoll') then
          return false
        end
        local value = math.abs(math.sin(CurTimeL() * .5) * .15)
        self:SetModifierWeight(1, value)
        return self:SetModifierWeight(2, value)
      end
    },
    {
      ['name'] = 'eyes_close',
      ['autostart'] = true,
      ['repeat'] = true,
      ['time'] = 5,
      ['ids'] = {
        'Left_Blink',
        'Right_Blink',
        'Frown'
      },
      ['func'] = function(self, delta, timeOfAnim)
        if not self:GetEntity():GetNWBool('PPM2.IsDeathRagdoll') then
          return 
        end
        self:SetModifierWeight(1, 1)
        self:SetModifierWeight(2, 1)
        return self:SetModifierWeight(3, 0.5)
      end
    },
    {
      ['name'] = 'body_idle',
      ['autostart'] = true,
      ['repeat'] = true,
      ['time'] = 2,
      ['ids'] = {
        'Stomach_Out',
        'Stomach_In'
      },
      ['func'] = function(self, delta, timeOfAnim)
        if self:GetEntity():GetNWBool('PPM2.IsDeathRagdoll') then
          return false
        end
        local In, Out = self:GetModifierID(1), self:GetModifierID(2)
        local InState, OutState = self:GetFlexState(1), self:GetFlexState(2)
        local abs = math.abs(0.5 - timeOfAnim)
        InState:SetModifierWeight(In, abs)
        return OutState:SetModifierWeight(Out, abs)
      end
    },
    {
      ['name'] = 'health_idle',
      ['autostart'] = true,
      ['repeat'] = true,
      ['time'] = 5,
      ['ids'] = {
        'Frown',
        'Left_Blink',
        'Right_Blink',
        'Scrunch',
        'Mouth_O',
        'JawOpen',
        'Grin'
      },
      ['func'] = function(self, delta, timeOfAnim)
        if not self:GetEntity():IsPlayer() and not self:GetEntity():IsNPC() and self:GetEntity().Type ~= 'nextbot' then
          return false
        end
        local frown = self:GetModifierID(1)
        local frownState = self:GetFlexState(1)
        local left, right = self:GetModifierID(2), self:GetModifierID(3)
        local leftState, rightState = self:GetFlexState(2), self:GetFlexState(3)
        local Mouth_O, Mouth_OState = self:GetModifierID(4), self:GetFlexState(4)
        local Scrunch = self:GetModifierID(4)
        local ScrunchState = self:GetFlexState(4)
        local hp, mhp = self:GetEntity():Health(), self:GetEntity():GetMaxHealth()
        if mhp == 0 then
          mhp = 1
        end
        local div = hp / mhp
        local strength = math.Clamp(1.5 - div * 1.5, 0, 1)
        frownState:SetModifierWeight(frown, strength)
        ScrunchState:SetModifierWeight(Scrunch, strength * .5)
        leftState:SetModifierWeight(left, strength * .1)
        rightState:SetModifierWeight(right, strength * .1)
        Mouth_OState:SetModifierWeight(Mouth_O, strength * .8)
        local JawOpen = self:GetModifierID(6)
        local JawOpenState = self:GetFlexState(6)
        if strength > .75 then
          JawOpenState:SetModifierWeight(JawOpen, strength * .2 + math.sin(CurTimeL() * strength * 3) * .1)
        else
          JawOpenState:SetModifierWeight(JawOpen, 0)
        end
        if div >= 2 then
          return self:SetModifierWeight(7, .5)
        else
          return self:SetModifierWeight(7, 0)
        end
      end
    },
    {
      ['name'] = 'greeny',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 2,
      ['ids'] = {
        'Grin'
      },
      ['func'] = function(self, delta, timeOfAnim)
        local Grin = self:GetModifierID(1)
        local GrinState = self:GetFlexState(1)
        local strength = .5 + math.sin(CurTimeL() * 2) * .25
        return GrinState:SetModifierWeight(Grin, strength)
      end
    },
    {
      ['name'] = 'big_grin',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 3,
      ['ids'] = {
        'Grin'
      },
      ['func'] = function(self, delta, timeOfAnim)
        local Grin = self:GetModifierID(1)
        local GrinState = self:GetFlexState(1)
        return GrinState:SetModifierWeight(Grin, 1)
      end
    },
    {
      ['name'] = 'o3o',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 3,
      ['ids'] = {
        'o3o'
      },
      ['func'] = function(self, delta, timeOfAnim)
        return self:SetModifierWeight(1, 1)
      end
    },
    {
      ['name'] = 'owo_alternative',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 5,
      ['ids'] = {
        'o3o',
        'JawOpen'
      },
      ['reset'] = function(self, delta, timeOfAnim)
        self:SetModifierWeight(1, math.Rand(0.8, 1))
        return self:SetModifierWeight(2, math.Rand(0.05, 0.1))
      end
    },
    {
      ['name'] = 'xd',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 3,
      ['ids'] = {
        'Grin',
        'Left_Blink',
        'Right_Blink',
        'JawOpen'
      },
      ['func'] = function(self, delta, timeOfAnim)
        local Grin = self:GetModifierID(1)
        local GrinState = self:GetFlexState(1)
        GrinState:SetModifierWeight(Grin, .6)
        local Left_Blink = self:GetModifierID(2)
        local Left_BlinkState = self:GetFlexState(2)
        Left_BlinkState:SetModifierWeight(Left_Blink, .9)
        local Right_Blink = self:GetModifierID(3)
        local Right_BlinkState = self:GetFlexState(3)
        Right_BlinkState:SetModifierWeight(Right_Blink, .9)
        local JawOpen = self:GetModifierID(4)
        local JawOpenState = self:GetFlexState(4)
        JawOpenState:SetModifierScale(JawOpen, 2)
        return JawOpenState:SetModifierWeight(JawOpen, (timeOfAnim % .1) * 2)
      end
    },
    {
      ['name'] = 'tongue',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 3,
      ['ids'] = {
        'JawOpen',
        'Tongue_Out'
      },
      ['func'] = function(self, delta, timeOfAnim)
        self:SetModifierWeight(1, .1)
        return self:SetModifierWeight(2, 1)
      end
    },
    {
      ['name'] = 'angry_tongue',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 6,
      ['ids'] = {
        'Frown',
        'Grin',
        'angry_eyes',
        'Scrunch',
        'JawOpen',
        'Tongue_Out'
      },
      ['reset'] = function(self, delta, timeOfAnim)
        self:SetModifierWeight(1, math.random(40, 100) / 100)
        self:SetModifierWeight(2, math.random(15, 40) / 100)
        self:SetModifierWeight(3, math.random(30, 80) / 100)
        self:SetModifierWeight(4, math.random(50, 100) / 100)
        self:SetModifierWeight(5, math.random(10, 15) / 100)
        return self:SetModifierWeight(6, math.random(80, 100) / 100)
      end
    },
    {
      ['name'] = 'pffff',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 6,
      ['ids'] = {
        'Frown',
        'Grin',
        'angry_eyes',
        'Scrunch',
        'JawOpen',
        'Tongue_Out',
        'Tongue_Down',
        'Tongue_Up'
      },
      ['reset'] = function(self)
        self:SetModifierWeight(1, math.random(40, 100) / 100)
        self:SetModifierWeight(2, math.random(15, 40) / 100)
        self:SetModifierWeight(3, math.random(30, 80) / 100)
        self:SetModifierWeight(4, math.random(50, 100) / 100)
        self:SetModifierWeight(5, math.random(10, 15) / 100)
        return self:SetModifierWeight(6, math.random(80, 100) / 100)
      end,
      ['func'] = function(self, delta, timeOfAnim)
        local val = math.sin(CurTimeL() * 8) * .6
        if val > 0 then
          self:SetModifierWeight(7, val)
          return self:SetModifierWeight(8, 0)
        else
          self:SetModifierWeight(7, 0)
          return self:SetModifierWeight(8, -val)
        end
      end
    },
    {
      ['name'] = 'cat',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 5,
      ['ids'] = {
        'CatFace'
      },
      ['func'] = function(self, delta, timeOfAnim)
        local Grin = self:GetModifierID(1)
        local GrinState = self:GetFlexState(1)
        return GrinState:SetModifierWeight(Grin, 1)
      end
    },
    {
      ['name'] = 'ooo',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 2,
      ['ids'] = {
        'Mouth_O2',
        'Mouth_O'
      },
      ['func'] = function(self, delta, timeOfAnim)
        timeOfAnim = timeOfAnim * 2
        local Grin = self:GetModifierID(1)
        local GrinState = self:GetFlexState(1)
        GrinState:SetModifierWeight(Grin, timeOfAnim)
        Grin = self:GetModifierID(2)
        GrinState = self:GetFlexState(2)
        return GrinState:SetModifierWeight(Grin, timeOfAnim)
      end
    },
    {
      ['name'] = 'talk',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 2,
      ['ids'] = {
        'JawOpen',
        'Tongue_Out',
        'Tongue_Up',
        'Tongue_Down'
      },
      ['create'] = function(self)
        do
          local _accum_0 = { }
          local _len_0 = 1
          for i = 0, 1, 0.05 do
            local rand = math.random(1, 100) / 100
            local _value_0
            if rand <= .25 then
              _value_0 = {
                1 * rand,
                0.4 * rand,
                2 * rand,
                0
              }
            elseif rand >= .25 and rand < .4 then
              rand = rand * .8
              _value_0 = {
                2 * rand,
                .6 * rand,
                0,
                1 * rand
              }
            elseif rand >= .4 and rand < .75 then
              rand = rand * .6
              _value_0 = {
                1 * rand,
                0,
                1 * rand,
                2 * rand
              }
            elseif rand >= .75 then
              rand = rand * .4
              _value_0 = {
                1.5 * rand,
                0,
                1 * rand,
                0
              }
            end
            _accum_0[_len_0] = _value_0
            _len_0 = _len_0 + 1
          end
          self.talkAnim = _accum_0
        end
        self:SetModifierSpeed(1, 2)
        self:SetModifierSpeed(2, 2)
        self:SetModifierSpeed(3, 2)
        return self:SetModifierSpeed(4, 2)
      end,
      ['func'] = function(self, delta, timeOfAnim)
        local JawOpen = self:GetModifierID(1)
        local JawOpenState = self:GetFlexState(1)
        local Tongue_OutOpen = self:GetModifierID(2)
        local Tongue_OutOpenState = self:GetFlexState(2)
        local Tongue_UpOpen = self:GetModifierID(3)
        local Tongue_UpOpenState = self:GetFlexState(3)
        local Tongue_DownOpen = self:GetModifierID(4)
        local Tongue_DownOpenState = self:GetFlexState(4)
        local cPos = math.floor(timeOfAnim * 20) + 1
        local data = self.talkAnim[cPos]
        if not data then
          return 
        end
        local jaw, out, up, down
        jaw, out, up, down = data[1], data[2], data[3], data[4]
        JawOpenState:SetModifierWeight(JawOpen, jaw)
        Tongue_OutOpenState:SetModifierWeight(Tongue_OutOpen, out)
        Tongue_UpOpenState:SetModifierWeight(Tongue_UpOpen, up)
        return Tongue_DownOpenState:SetModifierWeight(Tongue_DownOpen, down)
      end
    },
    {
      ['name'] = 'talk_endless',
      ['autostart'] = false,
      ['repeat'] = true,
      ['time'] = 4,
      ['ids'] = {
        'JawOpen',
        'Tongue_Out',
        'Tongue_Up',
        'Tongue_Down'
      },
      ['create'] = function(self)
        do
          local _accum_0 = { }
          local _len_0 = 1
          for i = 0, 1, 0.05 do
            local rand = math.random(1, 100) / 100
            local _value_0
            if rand <= .25 then
              _value_0 = {
                1 * rand,
                0.4 * rand,
                2 * rand,
                0
              }
            elseif rand >= .25 and rand < .4 then
              rand = rand * .8
              _value_0 = {
                2 * rand,
                .6 * rand,
                0,
                1 * rand
              }
            elseif rand >= .4 and rand < .75 then
              rand = rand * .6
              _value_0 = {
                1 * rand,
                0,
                1 * rand,
                2 * rand
              }
            elseif rand >= .75 then
              rand = rand * .4
              _value_0 = {
                1.5 * rand,
                0,
                1 * rand,
                0
              }
            end
            _accum_0[_len_0] = _value_0
            _len_0 = _len_0 + 1
          end
          self.talkAnim = _accum_0
        end
        self:SetModifierSpeed(1, 2)
        self:SetModifierSpeed(2, 2)
        self:SetModifierSpeed(3, 2)
        return self:SetModifierSpeed(4, 2)
      end,
      ['func'] = function(self, delta, timeOfAnim)
        local JawOpen = self:GetModifierID(1)
        local JawOpenState = self:GetFlexState(1)
        local Tongue_OutOpen = self:GetModifierID(2)
        local Tongue_OutOpenState = self:GetFlexState(2)
        local Tongue_UpOpen = self:GetModifierID(3)
        local Tongue_UpOpenState = self:GetFlexState(3)
        local Tongue_DownOpen = self:GetModifierID(4)
        local Tongue_DownOpenState = self:GetFlexState(4)
        local cPos = math.floor(timeOfAnim * 20) + 1
        local data = self.talkAnim[cPos]
        if not data then
          return 
        end
        local jaw, out, up, down
        jaw, out, up, down = data[1], data[2], data[3], data[4]
        local volume = self:GetEntity():VoiceVolume() * 6
        jaw = jaw * volume
        out = out * volume
        up = up * volume
        down = down * volume
        JawOpenState:SetModifierWeight(JawOpen, jaw)
        Tongue_OutOpenState:SetModifierWeight(Tongue_OutOpen, out)
        Tongue_UpOpenState:SetModifierWeight(Tongue_UpOpen, up)
        return Tongue_DownOpenState:SetModifierWeight(Tongue_DownOpen, down)
      end
    },
    {
      ['name'] = 'eyes_blink',
      ['autostart'] = true,
      ['repeat'] = true,
      ['time'] = 7,
      ['ids'] = {
        'Left_Blink',
        'Right_Blink'
      },
      ['create'] = function(self)
        self:SetModifierSpeed(1, 5)
        return self:SetModifierSpeed(2, 5)
      end,
      ['reset'] = function(self)
        self.nextBlink = math.random(300, 600) / 1000
        self.nextBlinkLength = math.random(15, 30) / 1000
        self.min, self.max = self.nextBlink, self.nextBlink + self.nextBlinkLength
      end,
      ['func'] = function(self, delta, timeOfAnim)
        if self.min > timeOfAnim or self.max < timeOfAnim then
          if self.blinkHit then
            self.blinkHit = false
            self:SetModifierWeight(1, 0)
            self:SetModifierWeight(2, 0)
          end
          return 
        end
        local len = (timeOfAnim - self.min) / self.nextBlinkLength
        self:SetModifierWeight(1, math.sin(len * math.pi))
        self:SetModifierWeight(2, math.sin(len * math.pi))
        self.blinkHit = true
      end
    },
    {
      ['name'] = 'hurt',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 4,
      ['ids'] = {
        'JawOpen',
        'Frown',
        'Grin',
        'Scrunch'
      },
      ['reset'] = function(self, delta, timeOfAnim)
        self:SetModifierWeight(1, math.random(4, 16) / 100)
        self:SetModifierWeight(2, math.random(60, 70) / 100)
        self:SetModifierWeight(3, math.random(30, 40) / 100)
        return self:SetModifierWeight(4, math.random(70, 90) / 100)
      end
    },
    {
      ['name'] = 'kill_grin',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 8,
      ['ids'] = {
        'Smirk',
        'Frown',
        'Grin'
      },
      ['func'] = function(self, delta, timeOfAnim)
        self:SetModifierWeight(1, .51)
        self:SetModifierWeight(2, .38)
        return self:SetModifierWeight(3, .66)
      end
    },
    {
      ['name'] = 'sorry',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 8,
      ['ids'] = {
        'Frown',
        'Stretch',
        'Grin',
        'Scrunch',
        'sad_eyes'
      },
      ['create'] = function(self)
        self:SetModifierWeight(1, math.random(45, 75) / 100)
        self:SetModifierWeight(2, math.random(45, 75) / 100)
        self:SetModifierWeight(3, math.random(70, 100) / 100)
        return self:SetModifierWeight(4, math.random(7090, 100) / 100)
      end
    },
    {
      ['name'] = 'scrunch',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 6,
      ['ids'] = {
        'Scrunch'
      },
      ['create'] = function(self)
        return self:SetModifierWeight(1, math.random(80, 100) / 100)
      end
    },
    {
      ['name'] = 'gulp',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 2,
      ['ids'] = {
        'Throat_Bulge',
        'Frown',
        'Grin'
      },
      ['create'] = function(self)
        self:SetModifierWeight(2, 1)
        return self:SetModifierWeight(3, math.random(35, 55) / 100)
      end,
      ['func'] = function(self, delta, timeOfAnim)
        if timeOfAnim > 0.5 then
          return self:SetModifierWeight(1, (1 - timeOfAnim) * 2)
        else
          return self:SetModifierWeight(1, timeOfAnim * 2)
        end
      end
    },
    {
      ['name'] = 'blahblah',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 3,
      ['ids'] = {
        'o3o',
        'Mouth_O'
      },
      ['create'] = function(self)
        self:SetModifierWeight(1, 1)
        do
          local _accum_0 = { }
          local _len_0 = 1
          for i = 0, 1, 0.05 do
            _accum_0[_len_0] = math.random(50, 70) / 100
            _len_0 = _len_0 + 1
          end
          self.talkAnim = _accum_0
        end
      end,
      ['func'] = function(self, delta, timeOfAnim)
        local cPos = math.floor(timeOfAnim * 20) + 1
        local data = self.talkAnim[cPos]
        if not data then
          return 
        end
        return self:SetModifierWeight(2, data)
      end
    },
    {
      ['name'] = 'wink_left',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 2,
      ['ids'] = {
        'Frown',
        'Stretch',
        'Grin',
        'Left_Blink'
      },
      ['create'] = function(self)
        self:SetModifierWeight(1, math.random(40, 60) / 100)
        self:SetModifierWeight(2, math.random(30, 50) / 100)
        self:SetModifierWeight(3, math.random(60, 100) / 100)
        self:SetModifierWeight(4, 1)
        return self:PauseSequence('eyes_blink')
      end
    },
    {
      ['name'] = 'wink_right',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 2,
      ['ids'] = {
        'Frown',
        'Stretch',
        'Grin',
        'Right_Blink'
      },
      ['create'] = function(self)
        self:SetModifierWeight(1, math.random(40, 60) / 100)
        self:SetModifierWeight(2, math.random(30, 50) / 100)
        self:SetModifierWeight(3, math.random(60, 100) / 100)
        self:SetModifierWeight(4, 1)
        return self:PauseSequence('eyes_blink')
      end
    },
    {
      ['name'] = 'happy_eyes',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 3,
      ['ids'] = {
        'Happy_Eyes'
      },
      ['create'] = function(self)
        self:SetModifierWeight(1, 1)
        return self:PauseSequence('eyes_blink')
      end
    },
    {
      ['name'] = 'happy_grin',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 3,
      ['ids'] = {
        'Happy_Eyes',
        'Grin'
      },
      ['create'] = function(self)
        self:SetModifierWeight(1, 1)
        self:SetModifierWeight(2, 1)
        return self:PauseSequence('eyes_blink')
      end
    },
    {
      ['name'] = 'duck',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 3,
      ['ids'] = {
        'Duck'
      },
      ['create'] = function(self)
        return self:SetModifierWeight(1, math.random(70, 90) / 100)
      end
    },
    {
      ['name'] = 'duck_insanity',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 3,
      ['ids'] = {
        'Duck'
      },
      ['func'] = function(self, delta, timeOfAnim)
        return self:SetModifierWeight(1, math.abs(math.sin(timeOfAnim * self:GetTime() * 4)))
      end
    },
    {
      ['name'] = 'duck_quack',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 5,
      ['ids'] = {
        'Duck',
        'JawOpen'
      },
      ['create'] = function(self)
        do
          local _accum_0 = { }
          local _len_0 = 1
          for i = 0, 1, 0.1 do
            local rand = math.random(1, 100)
            local _value_0 = rand > 50 and 1 or 0
            _accum_0[_len_0] = _value_0
            _len_0 = _len_0 + 1
          end
          self.talkAnim = _accum_0
        end
        return self:SetModifierWeight(1, math.random(70, 90) / 100)
      end,
      ['func'] = function(self, delta, timeOfAnim)
        local cPos = math.floor(timeOfAnim * 10) + 1
        local data = self.talkAnim[cPos]
        if not data then
          return 
        end
        return self:SetModifierWeight(2, data)
      end
    }
  }
  self.SetupFlexesTables = function(self)
    for i, flex in pairs(self.FLEX_LIST) do
      flex.id = i - 1
      flex.targetName = "target" .. tostring(flex.flex)
    end
    do
      local _tbl_0 = { }
      for _, flex in ipairs(self.FLEX_LIST) do
        _tbl_0[flex.id] = flex
      end
      self.FLEX_IDS = _tbl_0
    end
    do
      local _tbl_0 = { }
      for _, flex in ipairs(self.FLEX_LIST) do
        _tbl_0[flex.flex] = flex
      end
      self.FLEX_TABLE = _tbl_0
    end
  end
  self:SetupFlexesTables()
  self.NEXT_HOOK_ID = 0
  self.SequenceObject = FlexSequence
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  PonyFlexController = _class_0
end
do
  local ppm2_disable_flexes
  ppm2_disable_flexes = function(cvar, oldval, newval)
    for _, ply in ipairs(player.GetAll()) do
      local _continue_0 = false
      repeat
        local data = ply:GetPonyData()
        if not data then
          _continue_0 = true
          break
        end
        local renderer = data:GetRenderController()
        if not renderer then
          _continue_0 = true
          break
        end
        local flex = renderer:GetFlexController()
        if not flex then
          _continue_0 = true
          break
        end
        flex:ResetSequences()
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
  end
  cvars.AddChangeCallback('ppm2_disable_flexes', ppm2_disable_flexes, 'ppm2_disable_flexes')
end
PPM2.PonyFlexController = PonyFlexController
PPM2.GetFlexController = function(model)
  if model == nil then
    model = 'models/ppm/player_default_base_new.mdl'
  end
  return PonyFlexController.AVALIABLE_CONTROLLERS[model]
end
