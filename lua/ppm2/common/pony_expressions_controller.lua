local ExpressionSequence
do
  local _class_0
  local _parent_0 = PPM2.SequenceBase
  local _base_0 = {
    GetController = function(self)
      return self.controller
    end,
    SetControllerModifier = function(self, name, val)
      if name == nil then
        name = ''
      end
      return self.ponydata['SetModifier' .. name](self.ponydata, self.ponydataID, val)
    end,
    RestartChildren = function(self)
      if self.flexSequence then
        do
          local flexController = self.controller.renderController:GetFlexController()
          if flexController then
            self.flexController = flexController
            if type(self.flexSequence) == 'table' then
              for _, seq in ipairs(self.flexSequence) do
                flexController:StartSequence(seq, self.time):SetInfinite(self:GetInfinite())
              end
            else
              flexController:StartSequence(self.flexSequence, self.time):SetInfinite(self:GetInfinite())
            end
            if self.flexNames then
              do
                local _accum_0 = { }
                local _len_0 = 1
                for _, flex in ipairs(self.flexNames) do
                  _accum_0[_len_0] = {
                    flexController:GetFlexState(flex),
                    flexController:GetFlexState(flex):GetModifierID(self.name .. '_emote')
                  }
                  _len_0 = _len_0 + 1
                end
                self.flexStates = _accum_0
              end
            end
          end
        end
      end
      self.knownBonesSequences = { }
      do
        local bones = self:GetEntity():PPMBonesModifier()
        if bones then
          self.bonesController = bones
          if self.bonesSequence then
            if type(self.bonesSequence) == 'table' then
              for _, seq in ipairs(self.bonesSequence) do
                bones:StartSequence(seq, self.time):SetInfinite(self:GetInfinite())
                table.insert(self.knownBonesSequences, seq)
              end
            else
              bones:StartSequence(self.bonesSequence, self.time):SetInfinite(self:GetInfinite())
              table.insert(self.knownBonesSequences, self.bonesSequence)
            end
            self.bonesModifierID = bones:GetModifierID(self.name .. '_emote')
          end
        end
      end
    end,
    PlayBonesSequence = function(self, name, time)
      if time == nil then
        time = self.time
      end
      if not self.bonesController then
        return PPM2.Message('Bones controller not found for sequence ', self, '! This is a bug. ', self.controller)
      end
      table.insert(self.knownBonesSequences, name)
      return self.bonesController:StartSequence(name, time)
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
      self.ponydata:ResetModifiers(self.name .. '_emote')
      if self.flexController then
        if self.flexSequence then
          if type(self.flexSequence) == 'table' then
            for _, id in ipairs(self.flexSequence) do
              self.flexController:EndSequence(id)
            end
          else
            self.flexController:EndSequence(self.flexSequence)
          end
        end
        for _, _des_0 in ipairs(self.flexStates) do
          local flex, id
          flex, id = _des_0[1], _des_0[2]
          flex:ResetModifiers(id)
        end
      end
      if self.bonesController then
        for _, id in ipairs(self.knownBonesSequences) do
          self.bonesController:EndSequence(id)
        end
      end
    end,
    SetBonePosition = function(self, id, val)
      if id == nil then
        id = 1
      end
      if val == nil then
        val = Vector(0, 0, 0)
      end
      return self.controller[self.bonesFuncsPos[id]] and self.controller[self.bonesFuncsPos[id]](self.controller, self.bonesModifierID, val)
    end,
    SetBoneScale = function(self, id, val)
      if id == nil then
        id = 1
      end
      if val == nil then
        val = 0
      end
      return self.controller[self.bonesFuncsScale[id]] and self.controller[self.bonesFuncsScale[id]](self.controller, self.bonesModifierID, val)
    end,
    SetBoneAngles = function(self, id, val)
      if id == nil then
        id = 1
      end
      if val == nil then
        val = Angles(0, 0, 0)
      end
      return self.controller[self.bonesFuncsAngles[id]] and self.controller[self.bonesFuncsAngles[id]](self.controller, self.bonesModifierID, val)
    end,
    SetFlexWeight = function(self, id, val)
      if id == nil then
        id = 1
      end
      if val == nil then
        val = 0
      end
      return self.flexStates[id] and self.flexStates[id][1](self.flexStates[id][1], self.flexStates[id][2], val)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, controller, data)
      _class_0.__parent.__init(self, controller, data)
      self.flexSequence, self.bonesSequence, self.bonesNames, self.flexNames = data['flexSequence'], data['bonesSequence'], data['bones'], data['flexes']
      self.knownBonesSequences = { }
      self.controller = controller
      self.flexStates = { }
      self.bonesNames = self.bonesNames or { }
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
      self.ponydata = self.controller.renderController:GetData()
      self.ponydataID = self.ponydata:GetModifierID(self.name .. '_emote')
      self:RestartChildren()
      return self:Launch()
    end,
    __base = _base_0,
    __name = "ExpressionSequence",
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
  ExpressionSequence = _class_0
end
PPM2.ExpressionSequence = ExpressionSequence
do
  local _class_0
  local _parent_0 = PPM2.ControllerChildren
  local _base_0 = {
    PPM2_HurtAnimation = function(self, ply)
      if ply == nil then
        ply = NULL
      end
      if ply ~= self:GetEntity() then
        return 
      end
      self:RestartSequence('hurt')
      return self:EndSequence('kill_grin')
    end,
    PPM2_KillAnimation = function(self, ply)
      if ply == nil then
        ply = NULL
      end
      if ply ~= self:GetEntity() then
        return 
      end
      self:RestartSequence('kill_grin')
      return self:EndSequence('anger')
    end,
    PPM2_AngerAnimation = function(self, ply)
      if ply == nil then
        ply = NULL
      end
      if ply ~= self:GetEntity() then
        return 
      end
      self:EndSequence('kill_grin')
      return self:RestartSequence('anger')
    end,
    OnPlayerChat = function(self, ply, text, teamOnly, isDead)
      if ply == nil then
        ply = NULL
      end
      if text == nil then
        text = ''
      end
      if teamOnly == nil then
        teamOnly = false
      end
      if isDead == nil then
        isDead = false
      end
      if ply ~= self:GetEntity() or teamOnly or isDead then
        return 
      end
      text = text:lower()
      local _exp_0 = text
      if 'o' == _exp_0 or ':o' == _exp_0 or 'о' == _exp_0 or 'О' == _exp_0 or ':о' == _exp_0 or ':О' == _exp_0 then
        return self:RestartSequence('ooo')
      elseif ':3' == _exp_0 or ':з' == _exp_0 then
        return self:RestartSequence('cat')
      elseif ':d' == _exp_0 then
        return self:RestartSequence('big_grin')
      elseif 'xd' == _exp_0 or 'exdi' == _exp_0 then
        return self:RestartSequence('xd')
      elseif ':p' == _exp_0 then
        return self:RestartSequence('tongue')
      elseif '>:p' == _exp_0 or '>:р' == _exp_0 or '>:Р' == _exp_0 then
        return self:RestartSequence('angry_tongue')
      elseif ':р' == _exp_0 or ':Р' == _exp_0 then
        return self:RestartSequence('tongue')
      elseif ':c' == _exp_0 or 'o3o' == _exp_0 or 'oops' == _exp_0 or ':С' == _exp_0 or ':с' == _exp_0 or '(' == _exp_0 or ':(' == _exp_0 then
        return self:RestartSequence('sad')
      elseif 'sorry' == _exp_0 then
        return self:RestartSequence('sorry')
      elseif 'okay mate' == _exp_0 or 'okay, mate' == _exp_0 then
        return self:RestartSequence('wink_left')
      else
        if text:find('hehehe') or text:find('hahaha') then
          return self:RestartSequence('greeny')
        elseif text:find('^pff+') then
          return self:RestartSequence('pffff')
        elseif text:find('^blah blah') then
          return self:RestartSequence('blahblah')
        else
          return self:RestartSequence('talk')
        end
      end
    end,
    PPM2_EmoteAnimation = function(self, ply, emote, time, isEndless, shouldStop)
      if ply == nil then
        ply = NULL
      end
      if emote == nil then
        emote = ''
      end
      if isEndless == nil then
        isEndless = false
      end
      if shouldStop == nil then
        shouldStop = false
      end
      if ply ~= self:GetEntity() then
        return 
      end
      for _, _des_0 in ipairs(PPM2.AVALIABLE_EMOTES) do
        local sequence
        sequence = _des_0.sequence
        if shouldStop or sequence ~= emote then
          self:EndSequence(sequence)
        end
      end
      if not shouldStop then
        local seqPlay = self:RestartSequence(emote, time)
        if not seqPlay then
          PPM2.Message("Unknown Emote - " .. tostring(emote) .. "!")
          print(seqPlay, self.isValid)
          print(debug.traceback())
          return 
        end
        seqPlay:SetInfinite(isEndless)
        return seqPlay:RestartChildren()
      end
    end,
    DataChanges = function(self, state) end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, controller)
      _class_0.__parent.__init(self, controller)
      self.renderController = controller
      self:Hook('PPM2_HurtAnimation', self.PPM2_HurtAnimation)
      self:Hook('PPM2_KillAnimation', self.PPM2_KillAnimation)
      self:Hook('PPM2_AngerAnimation', self.PPM2_AngerAnimation)
      self:Hook('PPM2_EmoteAnimation', self.PPM2_EmoteAnimation)
      self:Hook('OnPlayerChat', self.OnPlayerChat)
      self:ResetSequences()
      return PPM2.DebugPrint('Created new PonyExpressionsController for ', self:GetEntity(), ' as part of ', controller, '; internal ID is ', self.objID)
    end,
    __base = _base_0,
    __name = "PonyExpressionsController",
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
  self.SEQUENCES = {
    {
      ['name'] = 'sad',
      ['flexSequence'] = {
        'sad'
      },
      ['bonesSequence'] = {
        'floppy_ears'
      },
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 5,
      ['reset'] = function(self) end,
      ['func'] = function(self, delta, timeOfAnim) end
    },
    {
      ['name'] = 'sorry',
      ['flexSequence'] = 'sorry',
      ['bonesSequence'] = {
        'floppy_ears'
      },
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 8
    },
    {
      ['name'] = 'scrunch',
      ['flexSequence'] = 'scrunch',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 6
    },
    {
      ['name'] = 'gulp',
      ['flexSequence'] = 'gulp',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 2
    },
    {
      ['name'] = 'blahblah',
      ['flexSequence'] = 'blahblah',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 3
    },
    {
      ['name'] = 'wink_left',
      ['flexSequence'] = 'wink_left',
      ['bonesSequence'] = 'forward_left',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 2
    },
    {
      ['name'] = 'wink_right',
      ['flexSequence'] = 'wink_right',
      ['bonesSequence'] = 'forward_right',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 2
    },
    {
      ['name'] = 'happy_eyes',
      ['flexSequence'] = 'happy_eyes',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 3
    },
    {
      ['name'] = 'happy_grin',
      ['flexSequence'] = 'happy_grin',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 3
    },
    {
      ['name'] = 'duck',
      ['flexSequence'] = 'duck',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 3
    },
    {
      ['name'] = 'duck_insanity',
      ['flexSequence'] = 'duck_insanity',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 3
    },
    {
      ['name'] = 'duck_quack',
      ['flexSequence'] = 'duck_quack',
      ['flexSequence'] = 'duck_quack',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 5
    },
    {
      ['name'] = 'hurt',
      ['flexSequence'] = 'hurt',
      ['bonesSequence'] = 'floppy_ears_weak',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 4,
      ['reset'] = function(self)
        return self:SetControllerModifier('IrisSize', -0.3)
      end
    },
    {
      ['name'] = 'kill_grin',
      ['flexSequence'] = 'kill_grin',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 8
    },
    {
      ['name'] = 'greeny',
      ['flexSequence'] = 'greeny',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 2
    },
    {
      ['name'] = 'big_grin',
      ['flexSequence'] = 'big_grin',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 3
    },
    {
      ['name'] = 'o3o',
      ['flexSequence'] = 'o3o',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 3
    },
    {
      ['name'] = 'xd',
      ['flexSequence'] = 'xd',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 3
    },
    {
      ['name'] = 'tongue',
      ['flexSequence'] = 'tongue',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 3
    },
    {
      ['name'] = 'angry_tongue',
      ['flexSequence'] = 'angry_tongue',
      ['bonesSequence'] = 'forward_ears',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 6
    },
    {
      ['name'] = 'pffff',
      ['flexSequence'] = 'pffff',
      ['bonesSequence'] = 'forward_ears',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 6
    },
    {
      ['name'] = 'cat',
      ['flexSequence'] = 'cat',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 5
    },
    {
      ['name'] = 'talk',
      ['flexSequence'] = 'talk',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 1.25
    },
    {
      ['name'] = 'ooo',
      ['flexSequence'] = 'ooo',
      ['bonesSequence'] = 'neck_flopping_backward',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 2
    },
    {
      ['name'] = 'anger',
      ['flexSequence'] = 'anger',
      ['bonesSequence'] = 'forward_ears',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 4,
      ['reset'] = function(self)
        return self:SetControllerModifier('IrisSize', -0.2)
      end
    },
    {
      ['name'] = 'ugh',
      ['flexSequence'] = 'ugh',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 5,
      ['reset'] = function(self) end
    },
    {
      ['name'] = 'lips_licking',
      ['flexSequence'] = 'lips_lick',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 5,
      ['reset'] = function(self) end
    },
    {
      ['name'] = 'lips_licking_suggestive',
      ['bonesSequence'] = 'floppy_ears_weak',
      ['flexSequence'] = {
        'lips_lick',
        'face_smirk',
        'suggestive_eyes'
      },
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 4,
      ['reset'] = function(self) end
    },
    {
      ['name'] = 'suggestive_eyes',
      ['flexSequence'] = {
        'suggestive_eyes'
      },
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 4,
      ['reset'] = function(self) end
    },
    {
      ['name'] = 'suggestive',
      ['bonesSequence'] = 'floppy_ears_weak',
      ['flexSequence'] = {
        'suggestive_eyes',
        'tongue_pullout',
        'suggestive_open'
      },
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 4,
      ['reset'] = function(self) end
    },
    {
      ['name'] = 'suggestive_wo',
      ['bonesSequence'] = 'floppy_ears_weak',
      ['flexSequence'] = {
        'suggestive_eyes',
        'suggestive_open_anim'
      },
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 4,
      ['reset'] = function(self) end
    },
    {
      ['name'] = 'wild',
      ['bonesSequence'] = 'neck_backward',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 3,
      ['reset'] = function(self)
        self:SetControllerModifier('IrisSize', -1)
        return self:PlayBonesSequence(math.random(1, 100) > 50 and 'neck_left' or 'neck_right')
      end
    },
    {
      ['name'] = 'owo_alternative',
      ['flexSequence'] = 'owo_alternative',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 8,
      ['reset'] = function(self)
        return self:SetControllerModifier('IrisSize', math.Rand(0.3, 0.4))
      end
    },
    {
      ['name'] = 'licking',
      ['bonesSequence'] = 'neck_twitch_fast',
      ['flexSequence'] = 'tongue_pullout_twitch_fast',
      ['autostart'] = false,
      ['repeat'] = false,
      ['time'] = 6
    }
  }
  self.SequenceObject = ExpressionSequence
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  PPM2.PonyExpressionsController = _class_0
end
PPM2.GetPonyExpressionsController = function(...)
  return PPM2.PonyExpressionsController:SelectController(...)
end
