do
  local _class_0
  local _base_0 = {
    GetEntity = function(self)
      return self.parent:GetEntity()
    end,
    Launch = function(self)
      self.valid = true
      if self.createfunc then
        self:createfunc()
      end
      if self.resetfunc then
        return self:resetfunc()
      end
    end,
    __tostring = function(self)
      return "[" .. tostring(self.__class.__name) .. ":" .. tostring(self.name) .. "]"
    end,
    SetTime = function(self, newTime, refresh)
      if newTime == nil then
        newTime = self.time
      end
      if refresh == nil then
        refresh = true
      end
      self.frame = 0
      if refresh then
        self.start = CurTimeL()
      end
      self.time = newTime
      self.finish = self.start + self.time
    end,
    SetInfinite = function(self, val)
      self.dorepeat = val
    end,
    SetIsInfinite = function(self, val)
      self.dorepeat = val
    end,
    GetInfinite = function(self)
      return self.dorepeat
    end,
    GetIsInfinite = function(self)
      return self.dorepeat
    end,
    Reset = function(self)
      self.frame = 0
      self.start = CurTimeL()
      self.finish = self.start + self.time
      self.deltaAnim = 1
      if self.resetfunc then
        return self:resetfunc()
      end
    end,
    GetName = function(self)
      return self.name
    end,
    GetRepeat = function(self)
      return self.dorepeat
    end,
    GetFrames = function(self)
      return self.frames
    end,
    GetFrame = function(self)
      return self.frames
    end,
    GetTime = function(self)
      return self.time
    end,
    GetThinkFunc = function(self)
      return self.func
    end,
    GetCreatFunc = function(self)
      return self.createfunc
    end,
    GetSpeed = function(self)
      return self.speed
    end,
    GetAnimationSpeed = function(self)
      return self.speed
    end,
    GetScale = function(self)
      return self.scale
    end,
    IsValid = function(self)
      return self.valid
    end,
    Think = function(self, delta)
      if delta == nil then
        delta = 0
      end
      if self.paused then
        self.finish = self.finish + delta
        self.start = self.start + delta
      else
        if self:HasFinished() then
          self:Stop()
          return false
        end
        self.deltaAnim = (self.finish - CurTimeL()) / self.time
        if self.deltaAnim < 0 then
          self.deltaAnim = 1
          self.frame = 0
          self.start = CurTimeL()
          self.finish = self.start + self.time
        end
        self.frame = self.frame + 1
        if self.func then
          local status = self:func(delta, 1 - self.deltaAnim)
          if status == false then
            self:Stop()
            return false
          end
        end
      end
      return true
    end,
    Pause = function(self)
      if self.paused then
        return false
      end
      self.paused = true
      return true
    end,
    Resume = function(self)
      if not self.paused then
        return false
      end
      self.paused = false
      return true
    end,
    PauseSequence = function(self, id)
      if id == nil then
        id = ''
      end
      self.pausedSequences[id] = true
      if self.parent then
        return self.parent:PauseSequence(id)
      end
    end,
    ResumeSequence = function(self, id)
      if id == nil then
        id = ''
      end
      self.pausedSequences[id] = false
      if self.parent then
        return self.parent:ResumeSequence(id)
      end
    end,
    Stop = function(self)
      for id, bool in pairs(self.pausedSequences) do
        if bool then
          self.controller:ResumeSequence(id)
        end
      end
      self.valid = false
    end,
    Remove = function(self)
      return self:Stop()
    end,
    HasFinished = function(self)
      if self.dorepeat then
        return false
      end
      return CurTimeL() > self.finish
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, parent, data)
      self.name, self.dorepeat, self.frames, self.time, self.func, self.resetfunc, self.createfunc = data['name'], data['repeat'], data['frames'], data['time'], data['func'], data['reset'], data['create']
      self.valid = false
      self.paused = false
      self.pausedSequences = { }
      self.deltaAnim = 1
      self.speed = 1
      self.scale = 1
      self.frame = 0
      self.start = CurTimeL()
      self.finish = self.start + self.time
      self.parent = parent
    end,
    __base = _base_0,
    __name = "SequenceBase"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  PPM2.SequenceBase = _class_0
  return _class_0
end
