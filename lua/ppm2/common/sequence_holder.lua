do
  local _class_0
  local _parent_0 = PPM2.ModifierBase
  local _base_0 = {
    StartSequence = function(self, seqID, time)
      if seqID == nil then
        seqID = ''
      end
      if not self.__class.SEQUENCES_TABLE then
        return false
      end
      if not self.isValid then
        return false
      end
      if self.currentSequences[seqID] then
        return self.currentSequences[seqID]
      end
      if not self.__class.SEQUENCES_TABLE[seqID] then
        return false
      end
      local SequenceObject = self.__class.SequenceObject
      self.currentSequences[seqID] = SequenceObject(self, self.__class.SEQUENCES_TABLE[seqID])
      if time then
        self.currentSequences[seqID]:SetTime(time)
      end
      do
        local _accum_0 = { }
        local _len_0 = 1
        for i, seq in pairs(self.currentSequences) do
          _accum_0[_len_0] = seq
          _len_0 = _len_0 + 1
        end
        self.currentSequencesIterable = _accum_0
      end
      return self.currentSequences[seqID]
    end,
    RestartSequence = function(self, seqID, time)
      if seqID == nil then
        seqID = ''
      end
      if not self.isValid then
        return false
      end
      if self.currentSequences[seqID] then
        self.currentSequences[seqID]:Reset()
        self.currentSequences[seqID]:SetTime(time)
        return self.currentSequences[seqID]
      end
      return self:StartSequence(seqID, time)
    end,
    PauseSequence = function(self, seqID)
      if seqID == nil then
        seqID = ''
      end
      if not self.isValid then
        return false
      end
      if self.currentSequences[seqID] then
        return self.currentSequences[seqID]:Pause()
      end
      return false
    end,
    ResumeSequence = function(self, seqID)
      if seqID == nil then
        seqID = ''
      end
      if not self.isValid then
        return false
      end
      if self.currentSequences[seqID] then
        return self.currentSequences[seqID]:Resume()
      end
      return false
    end,
    StopSequence = function(self, ...)
      return self:EndSequence(...)
    end,
    EndSequence = function(self, seqID, callStop)
      if seqID == nil then
        seqID = ''
      end
      if callStop == nil then
        callStop = true
      end
      if not self.isValid then
        return false
      end
      if not self.currentSequences[seqID] then
        return false
      end
      if callStop then
        self.currentSequences[seqID]:Stop()
      end
      self.currentSequences[seqID] = nil
      do
        local _accum_0 = { }
        local _len_0 = 1
        for i, seq in pairs(self.currentSequences) do
          _accum_0[_len_0] = seq
          _len_0 = _len_0 + 1
        end
        self.currentSequencesIterable = _accum_0
      end
      return true
    end,
    ResetSequences = function(self)
      if not self.__class.SEQUENCES then
        return false
      end
      if not self.isValid then
        return false
      end
      for _, seq in ipairs(self.currentSequencesIterable) do
        seq:Stop()
      end
      self.currentSequences = { }
      self.currentSequencesIterable = { }
      for _, seq in ipairs(self.__class.SEQUENCES) do
        if seq.autostart then
          self:StartSequence(seq.name)
        end
      end
    end,
    Reset = function(self)
      return self:ResetSequences()
    end,
    RemoveHooks = function(self)
      for _, iHook in ipairs(self.hooks) do
        hook.Remove(iHook, self.hookID)
      end
    end,
    PlayerRespawn = function(self)
      if not self.isValid then
        return 
      end
      return self:ResetSequences()
    end,
    HasSequence = function(self, seqID)
      if seqID == nil then
        seqID = ''
      end
      if not self.isValid then
        return false
      end
      return self.currentSequences[seqID] and true or false
    end,
    GetSequence = function(self, seqID)
      if seqID == nil then
        seqID = ''
      end
      return self.currentSequences[seqID]
    end,
    Hook = function(self, id, func)
      if not self.isValid then
        return 
      end
      local newFunc
      newFunc = function(...)
        if not IsValid(self:GetEntity()) or self:GetData():GetData() ~= self:GetEntity():GetPonyData() then
          self:RemoveHooks()
          return 
        end
        func(self, ...)
        return nil
      end
      hook.Add(id, self.hookID, newFunc)
      return table.insert(self.hooks, id)
    end,
    Think = function(self, ent)
      if ent == nil then
        ent = self:GetEntity()
      end
      if not self:IsValid() then
        return 
      end
      local delta = RealTimeL() - self.lastThink
      self.lastThink = RealTimeL()
      self.lastThinkDelta = delta
      if not IsValid(ent) or ent:IsDormant() then
        return 
      end
      for _, seq in ipairs(self.currentSequencesIterable) do
        if not seq:IsValid() then
          self:EndSequence(seq:GetName(), false)
          break
        end
        seq:Think(delta)
      end
      self:TriggerLerpAll(delta * 10)
      return delta
    end,
    Remove = function(self)
      self.isValid = false
      return self:RemoveHooks()
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self)
      _class_0.__parent.__init(self)
      self.isValid = true
      self.hooks = { }
      self.__class.NEXT_HOOK_ID = self.__class.NEXT_HOOK_ID + 1
      self.fid = self.__class.NEXT_HOOK_ID
      self.hookID = "PPM2." .. tostring(self.__class.__name) .. "." .. tostring(self.__class.NEXT_HOOK_ID)
      self.lastThink = RealTimeL()
      self.lastThinkDelta = 0
      self.currentSequences = { }
      self.currentSequencesIterable = { }
    end,
    __base = _base_0,
    __name = "SequenceHolder",
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
  self.__inherited = function(self, child)
    _class_0.__parent.__inherited(self, child)
    if not child.SEQUENCES then
      return 
    end
    for i, seq in ipairs(child.SEQUENCES) do
      seq.numid = i
    end
    do
      local _tbl_0 = { }
      for _, seq in ipairs(child.SEQUENCES) do
        _tbl_0[seq.name] = seq
      end
      child.SEQUENCES_TABLE = _tbl_0
    end
    for _, seq in ipairs(child.SEQUENCES) do
      child.SEQUENCES_TABLE[seq.numid] = seq
    end
  end
  self.NEXT_HOOK_ID = 0
  self.SequenceObject = PPM2.SequenceBase
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  PPM2.SequenceHolder = _class_0
  return _class_0
end
