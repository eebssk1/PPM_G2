local ADVANCED_MODE = CreateConVar('ppm2_editor_advanced', '0', {
  FCVAR_ARCHIVE
}, 'Show all options. Keep in mind Editor3 acts different with this option.')
local ENABLE_FULLBRIGHT = CreateConVar('ppm2_editor_fullbright', '1', {
  FCVAR_ARCHIVE
}, 'Disable lighting in editor')
local DISTANCE_LIMIT = CreateConVar('ppm2_sv_editor_dist', '0', {
  FCVAR_NOTIFY,
  FCVAR_REPLICATED
}, 'Distance limit in PPM/2 Editor/2. 0 - means default (400)')
local BackgroundColors = {
  Color(200, 200, 200),
  Color(150, 150, 150),
  Color(255, 255, 255),
  Color(131, 255, 240),
  Color(131, 255, 143),
  Color(206, 131, 255),
  Color(131, 135, 255),
  Color(92, 98, 228),
  Color(92, 201, 228),
  Color(92, 228, 201),
  Color(228, 155, 92),
  Color(228, 92, 110)
}
surface.CreateFont('PPM2.Title', {
  font = 'Roboto',
  size = 72,
  weight = 600
})
surface.CreateFont('PPM2.AboutLabels', {
  font = 'Roboto',
  size = 16,
  weight = 500
})
local EditorModels = {
  ['DEFAULT'] = 'models/ppm/player_default_base.mdl',
  ['CPPM'] = 'models/cppm/player_default_base.mdl',
  ['NEW'] = 'models/ppm/player_default_base_new.mdl'
}
local USE_MODEL = CreateConVar('ppm2_editor_model', 'new', {
  FCVAR_ARCHIVE
}, 'What model to use in editor. Valids are "default", "cppm", "new"')
local PANEL_WIDTH = CreateConVar('ppm2_editor_width', '370', {
  FCVAR_ARCHIVE
}, 'Width of editor panel, in pixels')
local IS_USING_NEW
IS_USING_NEW = function(newEditor)
  if newEditor == nil then
    newEditor = false
  end
  if newEditor then
    return LocalPlayer():IsNewPony()
  else
    local _exp_0 = USE_MODEL:GetString()
    if 'new' == _exp_0 then
      return true
    end
  end
  return false
end
local MODEL_BOX_PANEL = {
  SEQUENCE_STAND = 22,
  PONY_VEC_Z = 64 * .7,
  SEQUENCES = {
    ['gui.ppm2.editor.seq.standing'] = 22,
    ['gui.ppm2.editor.seq.move'] = 316,
    ['gui.ppm2.editor.seq.walk'] = 232,
    ['gui.ppm2.editor.seq.sit'] = 202,
    ['gui.ppm2.editor.seq.swim'] = 370,
    ['gui.ppm2.editor.seq.run'] = 328,
    ['gui.ppm2.editor.seq.duckwalk'] = 286,
    ['gui.ppm2.editor.seq.duck'] = 76,
    ['gui.ppm2.editor.seq.jump'] = 160
  },
  Init = function(self)
    self.animRate = 1
    self.seq = self.SEQUENCE_STAND
    self.targetAngle = Angle(0, 0, 0)
    self.angle = Angle(0, 0, 0)
    self.distToPony = 100
    self.targetDistToPony = 100
    self.vectorPos = Vector(self.distToPony, 0, self.PONY_VEC_Z)
    self.hold = false
    self.holdLast = 0
    self.mouseX, self.mouseY = 0, 0
    self:SetMouseInputEnabled(true)
    self.editorSeq = 1
    self.playing = true
    self.lastTick = RealTimeL()
    self:SetCursor('none')
    self.buildingModel = ClientsideModel('models/ppm/ppm2_stage.mdl', RENDERGROUP_OTHER)
    self.buildingModel:SetNoDraw(true)
    self.buildingModel:SetModelScale(0.9)
    self.seqButton = vgui.Create('DComboBox', self)
    do
      local _with_0 = self.seqButton
      _with_0:SetSize(120, 20)
      _with_0:SetValue('Standing')
      for choice, num in pairs(self.SEQUENCES) do
        _with_0:AddChoice(choice, num)
      end
      _with_0.OnSelect = function(pnl, index, value, data)
        if pnl == nil then
          pnl = box
        end
        if index == nil then
          index = 1
        end
        if value == nil then
          value = ''
        end
        if data == nil then
          data = value
        end
        return self:SetSequence(data)
      end
      return _with_0
    end
  end,
  ResetPosition = function(self)
    self.targetAngle = Angle(0, 0, 0)
    self.targetDistToPony = 100
    self.vectorPos = Vector(self.distToPony, 0, self.PONY_VEC_Z)
  end,
  PerformLayout = function(self, w, h)
    if w == nil then
      w = 0
    end
    if h == nil then
      h = 0
    end
    self.seqButton:SetPos(10, 10)
    if IsValid(self.emotesPanel) then
      return self.emotesPanel:SetPos(10, 40)
    end
  end,
  OnMousePressed = function(self, code)
    if code == nil then
      code = MOUSE_LEFT
    end
    if code ~= MOUSE_LEFT then
      return 
    end
    self.hold = true
    self:SetCursor('sizeall')
    self.holdLast = RealTimeL() + .1
    self.mouseX, self.mouseY = gui.MousePos()
  end,
  OnMouseReleased = function(self, code)
    if code == nil then
      code = MOUSE_LEFT
    end
    if code ~= MOUSE_LEFT then
      return 
    end
    self.hold = false
    return self:SetCursor('none')
  end,
  SetController = function(self, val)
    self.controller = val
  end,
  OnMouseWheeled = function(self, wheelDelta)
    if wheelDelta == nil then
      wheelDelta = 0
    end
    self.playing = false
    self.editorSeq = 1
    self.targetDistToPony = math.Clamp(self.targetDistToPony - wheelDelta * 10, 20, 150)
  end,
  GetModel = function(self)
    return self.model
  end,
  GetSequence = function(self)
    return self.seq
  end,
  GetSeq = function(self)
    return self.seq
  end,
  GetAnimRate = function(self)
    return self.animRate
  end,
  SetAnimRate = function(self, val)
    if val == nil then
      val = 1
    end
    self.animRate = val
  end,
  SetSeq = function(self, val)
    if val == nil then
      val = self.SEQUENCE_STAND
    end
    self.seq = val
    if IsValid(self.model) then
      return self.model:SetSequence(self.seq)
    end
  end,
  SetSequence = function(self, val)
    if val == nil then
      val = self.SEQUENCE_STAND
    end
    self.seq = val
    if IsValid(self.model) then
      return self.model:SetSequence(self.seq)
    end
  end,
  ResetSequence = function(self)
    return self:SetSequence(self.SEQUENCE_STAND)
  end,
  ResetSeq = function(self)
    return self:SetSequence(self.SEQUENCE_STAND)
  end,
  ResetModel = function(self, ponydata, model)
    if model == nil then
      model = 'models/ppm/player_default_base.mdl'
    end
    if IsValid(self.model) then
      self.model:Remove()
    end
    do
      local _with_0 = ClientsideModel(model)
      self.model = _with_0
      _with_0:SetNoDraw(true)
      _with_0.__PPM2_PonyData = ponydata
      _with_0:SetSequence(self.seq)
      _with_0:FrameAdvance(0)
    end
    if IsValid(self.emotesPanel) then
      self.emotesPanel:Remove()
    end
    if IS_USING_NEW() then
      self.emotesPanel = PPM2.CreateEmotesPanel(self, self.model, false)
      self.emotesPanel:SetPos(10, 40)
      self.emotesPanel:SetMouseInputEnabled(true)
      self.emotesPanel:SetVisible(true)
    end
    return self.model
  end,
  Think = function(self)
    local rtime = RealTimeL()
    local delta = rtime - self.lastTick
    self.lastTick = rtime
    if IsValid(self.model) then
      self.model:FrameAdvance(delta * self.animRate)
      self.model:SetPlaybackRate(1)
      self.model:SetPoseParameter('move_x', 1)
    end
    if self.hold then
      self.hold = self:IsHovered()
    end
    if self.hold then
      local x, y = gui.MousePos()
      local deltaX, deltaY = x - self.mouseX, y - self.mouseY
      self.mouseX, self.mouseY = x, y
      local pitch, yaw, roll
      do
        local _obj_0 = self.targetAngle
        pitch, yaw, roll = _obj_0.pitch, _obj_0.yaw, _obj_0.roll
      end
      yaw = yaw - (deltaX * .5)
      pitch = math.Clamp(pitch - deltaY * .5, -40, 10)
      self.targetAngle = Angle(pitch, yaw, roll)
    end
    self.angle = LerpAngle(delta * 4, self.angle, self.targetAngle)
    self.distToPony = Lerp(delta * 4, self.distToPony, self.targetDistToPony)
    self.vectorPos = Vector(self.distToPony, 0, self.PONY_VEC_Z)
    self.vectorPos:Rotate(self.angle)
    self.drawAngle = (Vector(0, 0, self.PONY_VEC_Z * .7) - self.vectorPos):Angle()
  end,
  FLOOR_VECTOR = Vector(0, 0, -30),
  FLOOR_ANGLE = Vector(0, 0, 1),
  DRAW_WALLS = {
    {
      Vector(-4000, 0, 900),
      Vector(1, 0, 0),
      8000,
      2000
    },
    {
      Vector(4000, 0, 900),
      Vector(-1, 0, 0),
      8000,
      2000
    },
    {
      Vector(0, -4000, 900),
      Vector(0, 1, 0),
      8000,
      2000
    },
    {
      Vector(0, 4000, 900),
      Vector(0, -1, 0),
      8000,
      2000
    },
    {
      Vector(0, 0, 900),
      Vector(0, 0, -1),
      8000,
      8000
    }
  },
  WALL_COLOR = Color(98, 189, 176),
  FLOOR_COLOR = Color(53, 150, 84),
  Paint = function(self, w, h)
    if w == nil then
      w = 0
    end
    if h == nil then
      h = 0
    end
    surface.SetDrawColor(0, 0, 0)
    surface.DrawRect(0, 0, w, h)
    if not IsValid(self.model) then
      return 
    end
    local x, y = self:LocalToScreen(0, 0)
    cam.Start3D(self.vectorPos, self.drawAngle, 90, x, y, w, h)
    render.DrawQuadEasy(self.FLOOR_VECTOR, self.FLOOR_ANGLE, 7000, 7000, self.FLOOR_COLOR)
    for _, _des_0 in ipairs(self.DRAW_WALLS) do
      local pos, ang
      pos, ang, w, h = _des_0[1], _des_0[2], _des_0[3], _des_0[4]
      render.DrawQuadEasy(pos, ang, w, h, self.WALL_COLOR)
    end
    if ENABLE_FULLBRIGHT:GetBool() then
      render.SuppressEngineLighting(true)
      render.ResetModelLighting(1, 1, 1)
      render.SetColorModulation(1, 1, 1)
    end
    self.buildingModel:DrawModel()
    local ctrl = self.controller:GetRenderController()
    do
      local bg = self.controller:GetBodygroupController()
      if bg then
        bg:ApplyBodygroups()
      end
    end
    do
      local _with_0 = self.model:PPMBonesModifier()
      _with_0:ResetBones()
      hook.Call('PPM2.SetupBones', nil, self.model, self.controller)
      _with_0:Think(true)
    end
    do
      ctrl:DrawModels()
      ctrl:HideModels(true)
      ctrl:PreDraw(self.model)
    end
    self.model:DrawModel()
    ctrl:PostDraw(self.model)
    if ENABLE_FULLBRIGHT:GetBool() then
      render.SuppressEngineLighting(false)
    end
    return cam.End3D()
  end,
  OnRemove = function(self)
    if IsValid(self.model) then
      self.model:Remove()
    end
    if IsValid(self.buildingModel) then
      return self.buildingModel:Remove()
    end
  end
}
vgui.Register('PPM2ModelPanel', MODEL_BOX_PANEL, 'EditablePanel')
local CALC_VIEW_PANEL = {
  Init = function(self)
    self.playingOpenAnim = true
    self.hold = false
    self.mousex, self.mousey = 0, 0
    self:SetMouseInputEnabled(true)
    self:SetKeyboardInputEnabled(true)
    local ply = LocalPlayer()
    self.drawPos = Vector(100, 0, 70)
    self.drawAngle = Angle(0, 180, 0)
    self.fov = 90
    self.lastTick = RealTimeL()
    hook.Add('CalcView', self, self.CalcView)
    hook.Add('PrePlayerDraw', self, self.PrePlayerDraw)
    self.slow = false
    self.fast = false
    self.forward = false
    self.backward = false
    self.left = false
    self.right = false
    self.up = false
    self.down = false
    self.lastPosSend = 0
    self.prevPos = Vector()
    self.realX, self.realY = 0, 0
    self.realW, self.realH = ScrW(), ScrH()
    self:SetCursor('hand')
    if IS_USING_NEW(true) then
      self.emotesPanel = PPM2.CreateEmotesPanel(self, LocalPlayer(), false)
      self.emotesPanel:SetPos(10, 10)
      self.emotesPanel:SetMouseInputEnabled(true)
      return self.emotesPanel:SetVisible(true)
    end
  end,
  SetRealSize = function(self, w, h)
    if w == nil then
      w = self.realW
    end
    if h == nil then
      h = self.realH
    end
    self.realW, self.realH = w, h
  end,
  SetRealPos = function(self, x, y)
    if x == nil then
      x = self.realX
    end
    if y == nil then
      y = self.realY
    end
    self.realX, self.realY = x, y
  end,
  CalcView = function(self, ply, origin, angles, fov, znear, zfar)
    if ply == nil then
      ply = LocalPlayer()
    end
    if origin == nil then
      origin = Vector(0, 0, 0)
    end
    if angles == nil then
      angles = Angle(0, 0, 0)
    end
    if fov == nil then
      fov = self.fov
    end
    if znear == nil then
      znear = 0
    end
    if zfar == nil then
      zfar = 1000
    end
    if not self:IsValid() then
      return hook.Remove('CalcView', self)
    end
    if not self:IsVisible() then
      return 
    end
    origin, angles = LocalToWorld(self.drawPos, self.drawAngle, LocalPlayer():GetPos(), Angle(0, LocalPlayer():EyeAnglesFixed().y, 0))
    local newData = {
      angles = angles,
      origin = origin,
      fov = self.fov,
      znear = znear,
      zfar = zfar,
      drawviewer = true
    }
    return newData
  end,
  PrePlayerDraw = function(self, ply)
    if ply == nil then
      ply = LocalPlayer()
    end
    if not self:IsValid() then
      return hook.Remove('PrePlayerDraw', self)
    end
    if not self:IsVisible() then
      return 
    end
    if ply ~= LocalPlayer() then
      return 
    end
    do
      local data = ply:GetPonyData()
      if data then
        do
          local bg = data:GetBodygroupController()
          if bg then
            bg:ApplyBodygroups()
          end
        end
        do
          local _with_0 = ply:PPMBonesModifier()
          _with_0:ResetBones()
          hook.Call('PPM2.SetupBones', nil, ply, data)
          _with_0:Think(true)
        end
      end
    end
  end,
  OnMousePressed = function(self, code)
    if code == nil then
      code = MOUSE_LEFT
    end
    if code ~= MOUSE_LEFT then
      return 
    end
    if IsValid(self.emotesPanel) then
      self.emotesPanel:SetVisible(false)
    end
    self.hold = true
    self:SetCursor('sizeall')
    self.mouseX, self.mouseY = gui.MousePos()
  end,
  IsActive = function(self)
    return self.forward or self.backward or self.left or self.right or self.hold or self.down or self.up
  end,
  CheckCode = function(self, code, status)
    if code == nil then
      code = KEY_NONE
    end
    if status == nil then
      status = false
    end
    local _exp_0 = code
    if KEY_RCONTROL == _exp_0 or KEY_LCONTROL == _exp_0 then
      self.slow = status
      if IsValid(self.emotesPanel) then
        return self.emotesPanel:SetVisible(not self:IsActive())
      end
    elseif KEY_LSHIFT == _exp_0 or KEY_RSHIFT == _exp_0 then
      self.fast = status
      if IsValid(self.emotesPanel) then
        return self.emotesPanel:SetVisible(not self:IsActive())
      end
    elseif KEY_W == _exp_0 then
      self.forward = status
      if IsValid(self.emotesPanel) then
        return self.emotesPanel:SetVisible(not self:IsActive())
      end
    elseif KEY_S == _exp_0 then
      self.backward = status
      if IsValid(self.emotesPanel) then
        return self.emotesPanel:SetVisible(not self:IsActive())
      end
    elseif KEY_A == _exp_0 then
      self.left = status
      if IsValid(self.emotesPanel) then
        return self.emotesPanel:SetVisible(not self:IsActive())
      end
    elseif KEY_D == _exp_0 then
      self.right = status
      if IsValid(self.emotesPanel) then
        return self.emotesPanel:SetVisible(not self:IsActive())
      end
    elseif KEY_SPACE == _exp_0 then
      self.up = status
      if IsValid(self.emotesPanel) then
        return self.emotesPanel:SetVisible(not self:IsActive())
      end
    end
  end,
  OnKeyCodePressed = function(self, code)
    if code == nil then
      code = KEY_NONE
    end
    return self:CheckCode(code, true)
  end,
  OnKeyCodeReleased = function(self, code)
    if code == nil then
      code = KEY_NONE
    end
    return self:CheckCode(code, false)
  end,
  OnMouseReleased = function(self, code)
    if code == nil then
      code = MOUSE_LEFT
    end
    if code ~= MOUSE_LEFT then
      return 
    end
    if IsValid(self.emotesPanel) then
      self.emotesPanel:SetVisible(not self:IsActive())
    end
    self.hold = false
    return self:SetCursor('hand')
  end,
  Think = function(self)
    local rtime = RealTimeL()
    local delta = rtime - self.lastTick
    self.lastTick = rtime
    if self.hold then
      self.hold = self:IsHovered()
    end
    if self.hold then
      local x, y = gui.MousePos()
      local deltaX, deltaY = x - self.mouseX, y - self.mouseY
      self.mouseX, self.mouseY = x, y
      local pitch, yaw, roll
      do
        local _obj_0 = self.drawAngle
        pitch, yaw, roll = _obj_0.pitch, _obj_0.yaw, _obj_0.roll
      end
      yaw = yaw - (deltaX * .3)
      pitch = pitch + (deltaY * .3)
      self.drawAngle = Angle(pitch:clamp(-89, 89), yaw, roll)
      self.drawAngle:Normalize()
    end
    local speedModifier = 1
    if self.fast then
      speedModifier = speedModifier * 2
    end
    if self.slow then
      speedModifier = speedModifier * 0.5
    end
    if self.forward then
      self.drawPos = self.drawPos + (self.drawAngle:Forward() * speedModifier * delta * 100)
    end
    if self.backward then
      self.drawPos = self.drawPos - (self.drawAngle:Forward() * speedModifier * delta * 100)
    end
    if self.right then
      self.drawPos = self.drawPos + (self.drawAngle:Right() * speedModifier * delta * 100)
    end
    if self.left then
      self.drawPos = self.drawPos - (self.drawAngle:Right() * speedModifier * delta * 100)
    end
    if self.up then
      self.drawPos = self.drawPos + (self.drawAngle:Up() * speedModifier * delta * 100)
    end
    local limitDist = DISTANCE_LIMIT:GetFloat()
    if limitDist <= 0 then
      limitDist = 400
    end
    local lenDist = self.drawPos:Length()
    if lenDist > limitDist then
      self.drawPos:Normalize()
      self.drawPos = self.drawPos * limitDist
    end
    if self.drawPos ~= self.prevPos and self.lastPosSend < RealTimeL() then
      self.lastPosSend = RealTimeL() + 0.1
      self.prevPos = Vector(self.drawPos)
      net.Start('PPM2.EditorCamPos')
      net.WriteVector(self.drawPos)
      net.WriteAngle(self.drawAngle)
      net.SendToServer()
    end
    if self:IsActive() then
      if not self.resizedToScreen then
        if IsValid(self.emotesPanel) then
          self.emotesPanel:SetVisible(false)
        end
        self.resizedToScreen = true
        self:SetPos(0, 0)
        return self:SetSize(ScrW(), ScrH())
      end
    else
      if self.resizedToScreen then
        self.resizedToScreen = false
        self:SetPos(self.realX, self.realY)
        self:SetSize(self.realW, self.realH)
        if IsValid(self.emotesPanel) then
          return self.emotesPanel:SetVisible(not self:IsActive())
        end
      end
    end
  end,
  OnRemove = function(self)
    hook.Remove('CalcView', self)
    return hook.Remove('PrePlayerDraw', self)
  end
}
vgui.Register('PPM2CalcViewPanel', CALC_VIEW_PANEL, 'EditablePanel')
local TATTOO_INPUT_GRABBER = {
  WatchButtons = {
    KEY_W,
    KEY_A,
    KEY_S,
    KEY_D,
    KEY_UP,
    KEY_DOWN,
    KEY_LEFT,
    KEY_RIGHT,
    KEY_Q,
    KEY_E
  },
  BUTTONS_DELAY = 0.5,
  DEFAULT_STEP = 0.25,
  ROTATE_STEP = 6,
  SCALE_STEP = 0.05,
  CONTINIOUS_STEP_MULTIPLIER = 2,
  CONTINIOUS_SCALE_STEP = 0.25,
  CONTINIOUS_ROTATE_STEP = 3,
  SetPanelsToUpdate = function(self, data)
    if data == nil then
      data = { }
    end
    self.panelsToUpdate = data
  end,
  SetTargetData = function(self, data)
    self.targetData = data
  end,
  GetTargetData = function(self)
    return self.targetData
  end,
  GetPanelsToUpdate = function(self)
    return self.panelsToUpdate
  end,
  SetTargetID = function(self, id)
    if id == nil then
      id = self.targetID
    end
    self.targetID = id
  end,
  GetTargetID = function(self)
    return self.targetID
  end,
  DataCall = function(self, key, ...)
    if key == nil then
      key = ''
    end
    return self.targetData[key .. self.targetID](self.targetData, ...)
  end,
  DataSet = function(self, key, ...)
    if key == nil then
      key = ''
    end
    return self.targetData['Set' .. key .. self.targetID](self.targetData, ...)
  end,
  DataGet = function(self, key, ...)
    if key == nil then
      key = ''
    end
    return self.targetData['Get' .. key .. self.targetID](self.targetData, ...)
  end,
  DataAdd = function(self, key, val)
    if key == nil then
      key = ''
    end
    if val == nil then
      val = 0
    end
    return self:DataSet(key, self:DataGet(key) + val)
  end,
  TriggerUpdate = function(self)
    for _, pnl in ipairs(self.panelsToUpdate) do
      if IsValid(pnl) then
        pnl:DoUpdate()
      end
    end
  end,
  Init = function(self)
    self.targetID = 1
    self:MakePopup()
    self:SetSize(400, 90)
    self:SetPos(ScrW() / 2 - 200, ScrH() * .2)
    self:SetMouseInputEnabled(false)
    self:SetKeyboardInputEnabled(true)
    self.ignoreFocus = RealTimeL() + 1
    self.scaleUp = false
    self.scaleDown = false
    self.scaleLeft = false
    self.scaleRight = false
    self.rotateLeft = false
    self.rotateRight = false
    self.moveLeft = false
    self.moveRight = false
    self.moveUp = false
    self.moveDown = false
    self.scaleUpTime = 0
    self.scaleDownTime = 0
    self.scaleLeftTime = 0
    self.scaleRightTime = 0
    self.rotateLeftTime = 0
    self.rotateRightTime = 0
    self.moveLeftTime = 0
    self.moveRightTime = 0
    self.moveUpTime = 0
    self.moveDownTime = 0
    self.panelsToUpdate = { }
    do
      local _with_0 = vgui.Create('DLabel', self)
      self.helpLabel = _with_0
      _with_0:SetFont('HudHintTextLarge')
      _with_0:Dock(FILL)
      _with_0:DockMargin(10, 10, 10, 10)
      _with_0:SetTextColor(color_white)
      _with_0:SetText('gui.ppm2.editor.tattoo.help')
      return _with_0
    end
  end,
  HandleKey = function(self, code, status)
    if code == nil then
      code = KEY_NONE
    end
    if status == nil then
      status = false
    end
    local _exp_0 = code
    if KEY_W == _exp_0 then
      if not self.moveDown and not self.moveUp and not self.moveLeft and not self.moveRight then
        self.moveUpTime = RealTimeL() + self.BUTTONS_DELAY
      end
      self.moveUp = status
      if status then
        self:DataAdd('TattooPosY', self.DEFAULT_STEP)
      end
      return self:TriggerUpdate()
    elseif KEY_S == _exp_0 then
      if not self.moveDown and not self.moveUp and not self.moveLeft and not self.moveRight then
        self.moveDownTime = RealTimeL() + self.BUTTONS_DELAY
      end
      self.moveDown = status
      if status then
        self:DataAdd('TattooPosY', -self.DEFAULT_STEP)
      end
      return self:TriggerUpdate()
    elseif KEY_A == _exp_0 then
      if not self.moveDown and not self.moveUp and not self.moveLeft and not self.moveRight then
        self.moveLeftTime = RealTimeL() + self.BUTTONS_DELAY
      end
      self.moveLeft = status
      if status then
        self:DataAdd('TattooPosX', -self.DEFAULT_STEP)
      end
      return self:TriggerUpdate()
    elseif KEY_D == _exp_0 then
      if not self.moveDown and not self.moveUp and not self.moveLeft and not self.moveRight then
        self.moveRightTime = RealTimeL() + self.BUTTONS_DELAY
      end
      self.moveRight = status
      if status then
        self:DataAdd('TattooPosX', self.DEFAULT_STEP)
      end
      return self:TriggerUpdate()
    elseif KEY_UP == _exp_0 then
      self.scaleUp = status
      self.scaleUpTime = RealTimeL() + self.BUTTONS_DELAY
      if status then
        self:DataAdd('TattooScaleY', self.SCALE_STEP)
      end
      return self:TriggerUpdate()
    elseif KEY_DOWN == _exp_0 then
      self.scaleDown = status
      self.scaleDownTime = RealTimeL() + self.BUTTONS_DELAY
      if status then
        self:DataAdd('TattooScaleY', -self.SCALE_STEP)
      end
      return self:TriggerUpdate()
    elseif KEY_LEFT == _exp_0 then
      self.scaleLeft = status
      self.scaleLeftTime = RealTimeL() + self.BUTTONS_DELAY
      if status then
        self:DataAdd('TattooScaleX', -self.SCALE_STEP)
      end
      return self:TriggerUpdate()
    elseif KEY_RIGHT == _exp_0 then
      self.scaleRight = status
      self.scaleRightTime = RealTimeL() + self.BUTTONS_DELAY
      if status then
        self:DataAdd('TattooScaleX', self.SCALE_STEP)
      end
      return self:TriggerUpdate()
    elseif KEY_Q == _exp_0 then
      self.rotateLeft = status
      self.rotateLeftTime = RealTimeL() + self.BUTTONS_DELAY
      if status then
        self:DataAdd('TattooRotate', -self.ROTATE_STEP)
      end
      return self:TriggerUpdate()
    elseif KEY_E == _exp_0 then
      self.rotateRight = status
      self.rotateRightTime = RealTimeL() + self.BUTTONS_DELAY
      if status then
        self:DataAdd('TattooRotate', self.ROTATE_STEP)
      end
      return self:TriggerUpdate()
    elseif KEY_ESCAPE == _exp_0 then
      return self:Remove()
    end
  end,
  OnKeyCodePressed = function(self, code)
    if code == nil then
      code = KEY_NONE
    end
    return self:HandleKey(code, true)
  end,
  OnKeyCodeReleased = function(self, code)
    if code == nil then
      code = KEY_NONE
    end
    return self:HandleKey(code, false)
  end,
  Think = function(self)
    if not self:HasFocus() and self.ignoreFocus < RealTimeL() then
      return self:Remove()
    end
    local ftime = FrameTime()
    if self.moveUp and self.moveUpTime < RealTimeL() then
      self:DataAdd('TattooPosY', self.CONTINIOUS_STEP_MULTIPLIER * ftime)
      self:TriggerUpdate()
    end
    if self.moveDown and self.moveDownTime < RealTimeL() then
      self:DataAdd('TattooPosY', -self.CONTINIOUS_STEP_MULTIPLIER * ftime)
      self:TriggerUpdate()
    end
    if self.moveRight and self.moveRightTime < RealTimeL() then
      self:DataAdd('TattooPosX', self.CONTINIOUS_STEP_MULTIPLIER * ftime)
      self:TriggerUpdate()
    end
    if self.moveLeft and self.moveLeftTime < RealTimeL() then
      self:DataAdd('TattooPosX', -self.CONTINIOUS_STEP_MULTIPLIER * ftime)
      self:TriggerUpdate()
    end
    if self.scaleUp and self.scaleUpTime < RealTimeL() then
      self:DataAdd('TattooScaleY', self.CONTINIOUS_SCALE_STEP * ftime)
      self:TriggerUpdate()
    end
    if self.scaleDown and self.scaleDownTime < RealTimeL() then
      self:DataAdd('TattooScaleY', -self.CONTINIOUS_SCALE_STEP * ftime)
      self:TriggerUpdate()
    end
    if self.scaleLeft and self.scaleLeftTime < RealTimeL() then
      self:DataAdd('TattooScaleX', -self.CONTINIOUS_SCALE_STEP * ftime)
      self:TriggerUpdate()
    end
    if self.scaleRight and self.scaleRightTime < RealTimeL() then
      self:DataAdd('TattooScaleX', self.CONTINIOUS_SCALE_STEP * ftime)
      self:TriggerUpdate()
    end
    if self.rotateLeft and self.rotateLeftTime < RealTimeL() then
      self:DataAdd('TattooRotate', -self.CONTINIOUS_ROTATE_STEP * ftime)
      self:TriggerUpdate()
    end
    if self.rotateRight and self.rotateRightTime < RealTimeL() then
      self:DataAdd('TattooRotate', self.CONTINIOUS_ROTATE_STEP * ftime)
      return self:TriggerUpdate()
    end
  end,
  Paint = function(self, w, h)
    if w == nil then
      w = 0
    end
    if h == nil then
      h = 0
    end
    surface.SetDrawColor(0, 0, 0, 150)
    return surface.DrawRect(0, 0, w, h)
  end
}
vgui.Register('PPM2TattooEditor', TATTOO_INPUT_GRABBER, 'EditablePanel')
PPM2.EditorBuildNewFilesPanel = function(self)
  self:Label('gui.ppm2.editor.io.hint')
  self:Button('gui.ppm2.editor.io.reload', function()
    return self:rebuildFileList()
  end)
  local list = vgui.Create('DListView', self)
  list:Dock(FILL)
  list:SetMultiSelect(false)
  local openFile
  openFile = function(fil)
    local confirm
    confirm = function()
      self.frame.data:SetFilename(fil)
      self.frame.data:ReadFromDisk(true)
      self.frame.data:UpdateController()
      self.frame.DoUpdate()
      self.unsavedChanges = false
      self.frame.unsavedChanges = false
      return self.frame:SetTitle('gui.ppm2.editor.generic.title_file', fil)
    end
    if self.unsavedChanges then
      return Derma_Query('gui.ppm2.editor.io.warn.text', 'gui.ppm2.editor.io.warn.header', 'gui.ppm2.editor.generic.yes', confirm, 'gui.ppm2.editor.generic.no')
    else
      return confirm()
    end
  end
  PPM2.EditorFileManipFuncs(list, 'ppm2', openFile)
  list:AddColumn('gui.ppm2.editor.io.filename')
  self.rebuildFileList = function()
    list:Clear()
    local files, dirs = file.Find('ppm2/*.dat', 'DATA')
    local matchBak = '.bak.dat'
    for _, fil in ipairs(files) do
      if fil:sub(-#matchBak) ~= matchBak then
        local fil2 = fil:sub(1, #fil - 4)
        local line = list:AddLine(fil2)
        line.file = fil
        local recomputed = false
        hook.Add('PostRenderVGUI', line, function(self)
          if not self:IsVisible() or not self:IsHovered() then
            return 
          end
          if not recomputed then
            recomputed = true
            if file.Exists('ppm2/thumbnails/' .. fil2 .. '.png', 'DATA') then
              line.png = Material('data/ppm2/thumbnails/' .. fil2 .. '.png')
              line.png:Recompute()
              line.png:GetTexture('$basetexture'):Download()
            end
          end
          local parent = self:GetParent():GetParent()
          local x, y = parent:LocalToScreen(parent:GetWide(), 0)
          if self.png then
            surface.SetMaterial(self.png)
            surface.SetDrawColor(255, 255, 255)
            return surface.DrawTexturedRect(x, y, 512, 512)
          else
            if not self.genPreview then
              PPM2.PonyDataInstance(fil2):SavePreview()
              self.genPreview = true
              timer.Simple(1, function()
                self.png = Material('data/ppm2/thumbnails/' .. fil2 .. '.png')
                self.png:Recompute()
                return self.png:GetTexture('$basetexture'):Download()
              end)
            end
            surface.SetDrawColor(0, 0, 0)
            surface.DrawRect(x, y, 512, 512)
            return DLib.HUDCommons.DrawLoading(x + 40, y + 40, 432, color_white)
          end
        end)
      end
    end
  end
  self:rebuildFileList()
  list.rebuildFileList = self.rebuildFileList
end
PPM2.EditorBuildOldFilesPanel = function(self)
  self:Label('gui.ppm2.editor.io.warn.oldfile')
  self:Button('gui.ppm2.editor.io.reload', function()
    return self:rebuildFileList()
  end)
  local list = vgui.Create('DListView', self)
  list:Dock(FILL)
  list:SetMultiSelect(false)
  local openFile
  openFile = function(fil)
    local confirm
    confirm = function()
      local newData = PPM2.ReadFromOldData(fil)
      if not newData then
        Derma_Message('gui.ppm2.editor.io.failed', 'gui.ppm2.editor.generic.ohno', 'gui.ppm2.editor.generic.okay')
        return 
      end
      self.frame.data:SetFilename(newData:GetFilename())
      newData:ApplyDataToObject(self.frame.data, false)
      self.frame.data:UpdateController()
      self.frame.DoUpdate()
      self.unsavedChanges = true
      self.frame.unsavedChanges = true
      return self.frame:SetTitle('gui.ppm2.editor.generic.title_file_unsaved', newData:GetFilename())
    end
    if self.unsavedChanges then
      return Derma_Query('gui.ppm2.editor.io.warn.text', 'gui.ppm2.editor.io.warn.header', 'gui.ppm2.editor.generic.yes', confirm, 'gui.ppm2.editor.generic.no')
    else
      return confirm()
    end
  end
  list:AddColumn('gui.ppm2.editor.io.filename')
  PPM2.EditorFileManipFuncs(list, 'ppm', openFile)
  self.rebuildFileList = function()
    list:Clear()
    local files, dirs = file.Find('ppm/*', 'DATA')
    for _, fil in ipairs(files) do
      local fil2 = fil:sub(1, #fil - 4)
      local line = list:AddLine(fil2)
      line.file = fil
      local recomputed = false
      hook.Add('PostRenderVGUI', line, function(self)
        if not self:IsVisible() or not self:IsHovered() then
          return 
        end
        if not recomputed then
          recomputed = true
          if file.Exists('ppm2/thumbnails/' .. fil2 .. '_imported.png', 'DATA') then
            line.png = Material('data/ppm2/thumbnails/' .. fil2 .. '_imported.png')
            line.png:Recompute()
            line.png:GetTexture('$basetexture'):Download()
          end
        end
        local parent = self:GetParent():GetParent()
        local x, y = parent:LocalToScreen(parent:GetWide(), 0)
        if self.png then
          surface.SetMaterial(self.png)
          surface.SetDrawColor(255, 255, 255)
          return surface.DrawTexturedRect(x, y, 512, 512)
        else
          if not self.genPreview then
            PPM2.ReadFromOldData(fil2):SavePreview()
            self.genPreview = true
            timer.Simple(1, function()
              self.png = Material('data/ppm2/thumbnails/' .. fil2 .. '_imported.png')
              self.png:Recompute()
              return self.png:GetTexture('$basetexture'):Download()
            end)
          end
          surface.SetDrawColor(0, 0, 0)
          surface.DrawRect(x, y, 512, 512)
          return DLib.HUDCommons.DrawLoading(x + 40, y + 40, 432, color_white)
        end
      end)
    end
  end
  self:rebuildFileList()
  list.rebuildFileList = self.rebuildFileList
end
PPM2.EditorFileManipFuncs = function(list, prefix, openFile)
  list.DoDoubleClick = function(pnl, rowID, line)
    local fil = line:GetColumnText(1)
    return openFile(fil)
  end
  list.OnRowRightClick = function(pnl, rowID, line)
    local fil = line:GetColumnText(1)
    local menu = DermaMenu()
    menu:AddOption('Open', function()
      return openFile(fil)
    end):SetIcon('icon16/accept.png')
    menu:AddOption('Delete', function()
      local confirm
      confirm = function()
        file.Delete(tostring(prefix) .. "/" .. tostring(fil) .. ".dat")
        return list:rebuildFileList()
      end
      return Derma_Query('gui.ppm2.editor.io.delete.confirm', 'gui.ppm2.editor.io.delete.title', 'gui.ppm2.editor.generic.yes', confirm, 'gui.ppm2.editor.generic.no')
    end):SetIcon('icon16/cross.png')
    return menu:Open()
  end
end
local PANEL_SETTINGS_BASE = {
  Init = function(self)
    self.shouldSaveData = false
    self:SetMouseInputEnabled(true)
    self:SetKeyboardInputEnabled(true)
    self:DockPadding(5, 5, 5, 5)
    self.unsavedChanges = false
    self.updateFuncs = { }
    self.createdPanels = 1
    self.isNewEditor = false
    self.populated = false
  end,
  Populate = function(self) end,
  Think = function(self)
    if not self.populated and self:IsVisible() then
      self.populated = true
      return self:Populate()
    end
  end,
  IsNewEditor = function(self)
    return self.isNewEditor
  end,
  GetIsNewEditor = function(self)
    return self.isNewEditor
  end,
  SetIsNewEditor = function(self, val)
    self.isNewEditor = val
  end,
  ValueChanges = function(self, valID, newVal, pnl)
    self.unsavedChanges = true
    if not self.frame then
      return 
    end
    self.frame.unsavedChanges = true
    return self.frame:SetTitle('gui.ppm2.editor.generic.title_file_unsaved', self:GetTargetData() and self:GetTargetData():GetFilename() or '%ERRNAME%')
  end,
  GetFrame = function(self)
    return self.frame
  end,
  GetShouldSaveData = function(self)
    return self.shouldSaveData
  end,
  ShouldSaveData = function(self)
    return self.shouldSaveData
  end,
  SetShouldSaveData = function(self, val)
    if val == nil then
      val = false
    end
    self.shouldSaveData = val
  end,
  GetTargetData = function(self)
    return self.data
  end,
  TargetData = function(self)
    return self.data
  end,
  SetTargetData = function(self, val)
    self.data = val
  end,
  DoUpdate = function(self)
    for _, func in ipairs(self.updateFuncs) do
      func()
    end
  end,
  CreateResetButton = function(self, name, option, parent)
    if name == nil then
      name = 'NULL'
    end
    if option == nil then
      option = 'NULL'
    end
    self.createdPanels = self.createdPanels + 1
    if not IsValid(parent) then
      do
        local button = vgui.Create('DButton', self.resetCollapse)
        button:SetParent(self.resetCollapse)
        button:Dock(TOP)
        button:DockMargin(2, 0, 2, 0)
        button:SetText('gui.ppm2.editor.reset_value', DLib.i18n.localize(option))
        button.DoClick = function()
          local dt = self:GetTargetData()
          dt['Reset' .. option](dt)
          self:ValueChanges(option, dt['Get' .. option](dt), button)
          return self:DoUpdate()
        end
        return button
      end
    else
      do
        local button = vgui.Create('DButton', parent)
        button:SetParent(parent)
        button:DockMargin(0, 0, 0, 0)
        button:SetText('gui.ppm2.editor.reset_value', DLib.i18n.localize(option))
        button:SetSize(0, 0)
        button:SetTextColor(Color(255, 255, 255))
        button.Paint = function(self, w, h)
          if w == 0 then
            return 
          end
          surface.SetDrawColor(0, 0, 0)
          return surface.DrawRect(0, 0, w, h)
        end
        button.DoClick = function()
          local dt = self:GetTargetData()
          dt['Reset' .. option](dt)
          self:ValueChanges(option, dt['Get' .. option](dt), button)
          return self:DoUpdate()
        end
        button.Think = function()
          if input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT) then
            return button:SetSize(button:GetParent():GetSize())
          else
            return button:SetSize(0, 0)
          end
        end
        return button
      end
    end
  end,
  NumSlider = function(self, name, option, decimals, parent)
    if name == nil then
      name = 'Slider'
    end
    if option == nil then
      option = ''
    end
    if decimals == nil then
      decimals = 0
    end
    if parent == nil then
      parent = self.scroll or self
    end
    self.createdPanels = self.createdPanels + 3
    do
      local withPanel = vgui.Create('DNumSlider', parent)
      self:CreateResetButton(name, option, withPanel)
      withPanel:Dock(TOP)
      withPanel:DockMargin(2, 0, 2, 0)
      withPanel:SetTooltip('gui.ppm2.editor.generic.datavalue', name, option)
      withPanel:SetText(name)
      withPanel:SetMin(0)
      withPanel:SetMax(1)
      if self:GetTargetData() then
        withPanel:SetMin(self:GetTargetData()["GetMin" .. tostring(option)](self:GetTargetData()))
      end
      if self:GetTargetData() then
        withPanel:SetMax(self:GetTargetData()["GetMax" .. tostring(option)](self:GetTargetData()))
      end
      withPanel:SetDecimals(decimals)
      if self:GetTargetData() then
        withPanel:SetValue(self:GetTargetData()["Get" .. tostring(option)](self:GetTargetData()))
      end
      withPanel.TextArea:SetTextColor(color_white)
      withPanel.Label:SetTextColor(color_white)
      withPanel.DoUpdate = function()
        if self:GetTargetData() then
          return withPanel:SetValue(self:GetTargetData()["Get" .. tostring(option)](self:GetTargetData()))
        end
      end
      withPanel.OnValueChanged = function(pnl, newVal)
        if newVal == nil then
          newVal = 1
        end
        if option == '' then
          return 
        end
        local data = self:GetTargetData()
        if not data then
          return 
        end
        data["Set" .. tostring(option)](data, newVal, self:GetShouldSaveData())
        return self:ValueChanges(option, newVal, pnl)
      end
      table.insert(self.updateFuncs, function()
        if self:GetTargetData() then
          withPanel:SetMin(self:GetTargetData()["GetMin" .. tostring(option)](self:GetTargetData()))
        end
        if self:GetTargetData() then
          withPanel:SetMax(self:GetTargetData()["GetMax" .. tostring(option)](self:GetTargetData()))
        end
        if self:GetTargetData() then
          return withPanel:SetValue(self:GetTargetData()["Get" .. tostring(option)](self:GetTargetData()))
        end
      end)
      if IsValid(self.scroll) and parent == self.scroll then
        self.scroll:AddItem(withPanel)
      end
      return withPanel
    end
  end,
  Label = function(self, text, parent)
    if text == nil then
      text = ''
    end
    if parent == nil then
      parent = self.scroll or self
    end
    self.createdPanels = self.createdPanels + 1
    do
      local withPanel = vgui.Create('DLabel', parent)
      withPanel:SetText(text)
      withPanel:SetTooltip(text)
      withPanel:Dock(TOP)
      withPanel:DockMargin(2, 2, 2, 2)
      withPanel:SetTextColor(color_white)
      withPanel:SizeToContents()
      withPanel:SetMouseInputEnabled(true)
      local w, h = withPanel:GetSize()
      withPanel:SetSize(w, h + 5)
      if IsValid(self.scroll) and parent == self.scroll then
        self.scroll:AddItem(withPanel)
      end
      return withPanel
    end
  end,
  URLLabel = function(self, text, url, parent)
    if text == nil then
      text = ''
    end
    if url == nil then
      url = ''
    end
    if parent == nil then
      parent = self.scroll or self
    end
    self.createdPanels = self.createdPanels + 1
    do
      local withPanel = vgui.Create('DLabel', parent)
      withPanel:SetText(text)
      withPanel:SetTooltip('gui.ppm2.editor.generic.url', text, url)
      withPanel:Dock(TOP)
      withPanel:DockMargin(2, 2, 2, 2)
      withPanel:SetTextColor(Color(158, 208, 208))
      withPanel:SizeToContents()
      withPanel:SetCursor('hand')
      local w, h = withPanel:GetSize()
      withPanel:SetSize(w, h + 5)
      withPanel:SetMouseInputEnabled(true)
      withPanel.DoClick = function()
        if url ~= '' then
          return gui.OpenURL(url)
        end
      end
      if IsValid(self.scroll) and parent == self.scroll then
        self.scroll:AddItem(withPanel)
      end
      return withPanel
    end
  end,
  Hr = function(self, parent)
    if parent == nil then
      parent = self.scroll or self
    end
    self.createdPanels = self.createdPanels + 1
    do
      local withPanel = vgui.Create('EditablePanel', parent)
      withPanel:Dock(TOP)
      withPanel:SetSize(200, 15)
      if IsValid(self.scroll) and parent == self.scroll then
        self.scroll:AddItem(withPanel)
      end
      withPanel.Paint = function(self, w, h)
        if w == nil then
          w = 0
        end
        if h == nil then
          h = 0
        end
        surface.SetDrawColor(150, 162, 162)
        return surface.DrawLine(0, h / 2, w, h / 2)
      end
      return withPanel
    end
  end,
  Button = function(self, text, doClick, parent)
    if text == nil then
      text = 'Perfectly generic button'
    end
    if doClick == nil then
      doClick = (function() end)
    end
    if parent == nil then
      parent = self.scroll or self
    end
    self.createdPanels = self.createdPanels + 1
    do
      local withPanel = vgui.Create('DButton', parent)
      withPanel:Dock(TOP)
      withPanel:SetSize(200, 20)
      withPanel:DockMargin(2, 2, 2, 2)
      withPanel:SetText(text)
      if IsValid(self.scroll) and parent == self.scroll then
        self.scroll:AddItem(withPanel)
      end
      withPanel.DoClick = function()
        return doClick()
      end
      return withPanel
    end
  end,
  CheckBox = function(self, name, option, parent)
    if name == nil then
      name = 'Label'
    end
    if option == nil then
      option = ''
    end
    if parent == nil then
      parent = self.scroll or self
    end
    self.createdPanels = self.createdPanels + 3
    do
      local withPanel = vgui.Create('DCheckBoxLabel', parent)
      self:CreateResetButton(name, option, withPanel)
      withPanel:Dock(TOP)
      withPanel:DockMargin(2, 2, 2, 2)
      withPanel:SetText(name)
      withPanel:SetTextColor(color_white)
      withPanel:SetTooltip('gui.ppm2.editor.generic.datavalue', name, option)
      if self:GetTargetData() then
        withPanel:SetChecked(self:GetTargetData()["Get" .. tostring(option)](self:GetTargetData()))
      end
      withPanel.OnChange = function(pnl, newVal)
        if newVal == nil then
          newVal = false
        end
        if option == '' then
          return 
        end
        local data = self:GetTargetData()
        if not data then
          return 
        end
        data["Set" .. tostring(option)](data, newVal and 1 or 0, self:GetShouldSaveData())
        return self:ValueChanges(option, newVal and 1 or 0, pnl)
      end
      table.insert(self.updateFuncs, function()
        if self:GetTargetData() then
          return withPanel:SetChecked(self:GetTargetData()["Get" .. tostring(option)](self:GetTargetData()))
        end
      end)
      if IsValid(self.scroll) and parent == self.scroll then
        self.scroll:AddItem(withPanel)
      end
      return withPanel
    end
  end,
  ColorBox = function(self, name, option, parent)
    if name == nil then
      name = 'Colorful Box'
    end
    if option == nil then
      option = ''
    end
    if parent == nil then
      parent = self.scroll or self
    end
    self.createdPanels = self.createdPanels + 7
    local collapse = vgui.Create('DCollapsibleCategory', parent)
    local box = vgui.Create('DColorMixer', collapse)
    collapse.box = box
    do
      box:SetSize(250, 270)
      box:SetTooltip('gui.ppm2.editor.generic.datavalue', name, option)
      if self:GetTargetData() then
        box:SetColor(self:GetTargetData()["Get" .. tostring(option)](self:GetTargetData()))
      end
      box.ValueChanged = function(pnl)
        return timer.Simple(0, function()
          if option == '' then
            return 
          end
          local data = self:GetTargetData()
          if not data then
            return 
          end
          local newVal = pnl:GetColor()
          data["Set" .. tostring(option)](data, newVal, self:GetShouldSaveData())
          return self:ValueChanges(option, newVal, pnl)
        end)
      end
      table.insert(self.updateFuncs, function()
        if self:GetTargetData() then
          return box:SetColor(self:GetTargetData()["Get" .. tostring(option)](self:GetTargetData()))
        end
      end)
    end
    do
      collapse:SetContents(box)
      collapse:Dock(TOP)
      collapse:DockMargin(2, 2, 2, 2)
      collapse:SetSize(250, 270)
      collapse:SetLabel(name)
      collapse:SetExpanded(false)
      if IsValid(self.scroll) and parent == self.scroll then
        self.scroll:AddItem(collapse)
      end
      self:CreateResetButton(name, option, collapse)
    end
    return box, collapse
  end,
  Spoiler = function(self, name, parent)
    if name == nil then
      name = 'gui.ppm2.editor.generic.spoiler'
    end
    if parent == nil then
      parent = self.scroll or self
    end
    self.createdPanels = self.createdPanels + 2
    local collapse = vgui.Create('DCollapsibleCategory', parent)
    local canvas = vgui.Create('EditablePanel', collapse)
    do
      canvas:SetSize(0, 400)
      canvas:Dock(FILL)
    end
    do
      collapse:SetContents(canvas)
      collapse:Dock(TOP)
      collapse:DockMargin(2, 2, 2, 2)
      collapse:SetSize(250, 270)
      collapse:SetLabel(name)
      collapse:SetExpanded(false)
      if IsValid(self.scroll) and parent == self.scroll then
        self.scroll:AddItem(collapse)
      end
    end
    return canvas, collapse
  end,
  ComboBox = function(self, name, option, choices, parent)
    if name == nil then
      name = 'Combo Box'
    end
    if option == nil then
      option = ''
    end
    if parent == nil then
      parent = self.scroll or self
    end
    self.createdPanels = self.createdPanels + 4
    do
      local label = vgui.Create('DLabel', parent)
      label:SetText(name)
      label:SetTextColor(color_white)
      label:Dock(TOP)
      label:SetSize(0, 20)
      label:DockMargin(5, 0, 5, 0)
      label:SetMouseInputEnabled(true)
      if IsValid(self.scroll) and parent == self.scroll then
        self.scroll:AddItem(label)
      end
      do
        local box = vgui.Create('DComboBox', label)
        box:Dock(RIGHT)
        box:SetSize(170, 0)
        box:DockMargin(0, 0, 5, 0)
        box:SetSortItems(false)
        if self:GetTargetData() then
          box:SetValue(self:GetTargetData()["Get" .. tostring(option) .. "Enum"](self:GetTargetData()))
        end
        if self:GetTargetData() and self:GetTargetData()["Get" .. tostring(option) .. "Types"] then
          if choices then
            for _, choice in ipairs(choices) do
              box:AddChoice(choice)
            end
          else
            for _, choice in ipairs(self:GetTargetData()["Get" .. tostring(option) .. "Types"](self:GetTargetData())) do
              box:AddChoice(choice)
            end
          end
        end
        box.OnSelect = function(pnl, index, value, data)
          if pnl == nil then
            pnl = box
          end
          if index == nil then
            index = 1
          end
          if value == nil then
            value = ''
          end
          if data == nil then
            data = value
          end
          index = index - 1
          data = self:GetTargetData()
          if not data then
            return 
          end
          data["Set" .. tostring(option)](data, index, self:GetShouldSaveData())
          return self:ValueChanges(option, index, pnl)
        end
        table.insert(self.updateFuncs, function()
          if self:GetTargetData() then
            return box:SetValue(self:GetTargetData()["Get" .. tostring(option) .. "Enum"](self:GetTargetData()))
          end
        end)
      end
      self:CreateResetButton(name, option, label)
    end
    return box, label
  end,
  URLInput = function(self, option, parent)
    if option == nil then
      option = ''
    end
    if parent == nil then
      parent = self.scroll or self
    end
    self.createdPanels = self.createdPanels + 2
    do
      local wrapper = vgui.Create('EditablePanel', parent)
      wrapper:Dock(TOP)
      wrapper:DockMargin(5, 10, 5, 10)
      wrapper:SetKeyboardInputEnabled(true)
      wrapper:SetMouseInputEnabled(true)
      wrapper:SetSize(0, 20)
      if IsValid(self.scroll) and parent == self.scroll then
        self.scroll:AddItem(wrapper)
      end
      do
        local textInput = vgui.Create('DTextEntry', wrapper)
        self:CreateResetButton('gui.ppm2.editor.generic.url_field', option, textInput)
        textInput:Dock(FILL)
        if self:GetTargetData() then
          textInput:SetText(self:GetTargetData()["Get" .. tostring(option)](self:GetTargetData()))
        end
        textInput:SetKeyboardInputEnabled(true)
        textInput:SetMouseInputEnabled(true)
        textInput.OnEnter = function()
          local text = textInput:GetValue()
          if text:find('^https?://') then
            self:GetTargetData()["Set" .. tostring(option)](self:GetTargetData(), text)
            return self:ValueChanges(option, text, textInput)
          else
            self:GetTargetData()["Set" .. tostring(option)](self:GetTargetData(), '')
            return self:ValueChanges(option, '', textInput)
          end
        end
        textInput.OnKeyCodeTyped = function(pnl, key)
          if key == nil then
            key = KEY_FIRST
          end
          local _exp_0 = key
          if KEY_FIRST == _exp_0 then
            return true
          elseif KEY_NONE == _exp_0 then
            return true
          elseif KEY_TAB == _exp_0 then
            return true
          elseif KEY_ENTER == _exp_0 then
            textInput.OnEnter()
            textInput:KillFocus()
            return true
          end
          return timer.Create("PPM2.EditorCodeChange." .. tostring(option), 1, 1, function()
            if not IsValid(textInput) then
              return 
            end
            return textInput.OnEnter()
          end)
        end
        table.insert(self.updateFuncs, function()
          if self:GetTargetData() then
            return textInput:SetText(self:GetTargetData()["Get" .. tostring(option)](self:GetTargetData()))
          end
        end)
        return textInput
      end
      return wrapper
    end
  end,
  ScrollPanel = function(self)
    if IsValid(self.scroll) then
      return self.scroll
    end
    self.createdPanels = self.createdPanels + 1
    self.scroll = vgui.Create('DScrollPanel', self)
    self.scroll:Dock(FILL)
    return self.scroll
  end,
  Paint = function(self, w, h)
    if w == nil then
      w = 0
    end
    if h == nil then
      h = 0
    end
    surface.SetDrawColor(130, 130, 130)
    return surface.DrawRect(0, 0, w, h)
  end
}
vgui.Register('PPM2SettingsBase', PANEL_SETTINGS_BASE, 'EditablePanel')
PPM2.EditorPhongPanels = function(self, ttype, spoilerName)
  if ttype == nil then
    ttype = 'Body'
  end
  if spoilerName == nil then
    spoilerName = ttype .. ' phong parameters'
  end
  local spoiler = self:Spoiler(spoilerName)
  self:URLLabel('gui.ppm2.editor.phong.info', 'https://developer.valvesoftware.com/wiki/Phong_materials', spoiler)
  self:Label('gui.ppm2.editor.phong.exponent', spoiler)
  self:NumSlider('gui.ppm2.editor.phong.exponent_text', ttype .. 'PhongExponent', 3, spoiler)
  self:Label('gui.ppm2.editor.phong.boost.title', spoiler)
  self:NumSlider('gui.ppm2.editor.phong.boost.boost', ttype .. 'PhongBoost', 3, spoiler)
  self:Label('gui.ppm2.editor.phong.tint.title', spoiler)
  local picker, pickerSpoiler = self:ColorBox('gui.ppm2.editor.phong.tint.tint', ttype .. 'PhongTint', spoiler)
  pickerSpoiler:SetExpanded(true)
  self:Label('gui.ppm2.editor.phong.frensel.front.title', spoiler)
  self:NumSlider('gui.ppm2.editor.phong.frensel.front.front', ttype .. 'PhongFront', 2, spoiler)
  self:Label('gui.ppm2.editor.phong.frensel.middle.title', spoiler)
  self:NumSlider('gui.ppm2.editor.phong.frensel.middle.front', ttype .. 'PhongMiddle', 2, spoiler)
  self:Label('gui.ppm2.editor.phong.frensel.sliding.title', spoiler)
  self:NumSlider('gui.ppm2.editor.phong.frensel.sliding.front', ttype .. 'PhongSliding', 2, spoiler)
  self:ComboBox('gui.ppm2.editor.phong.lightwarp', ttype .. 'Lightwarp', nil, spoiler)
  self:Label('gui.ppm2.editor.phong.url_lightwarp', spoiler)
  self:URLInput(ttype .. 'LightwarpURL', spoiler)
  self:Label('gui.ppm2.editor.phong.bumpmap', spoiler)
  return self:URLInput(ttype .. 'BumpmapURL', spoiler)
end
local EditorPages = {
  {
    ['name'] = 'gui.ppm2.editor.tabs.main',
    ['internal'] = 'main',
    ['func'] = function(self, sheet)
      self:Button('gui.ppm2.editor.io.newfile.title', function()
        local data = self:GetTargetData()
        if not data then
          return 
        end
        local confirmed
        confirmed = function()
          data:SetFilename("new_pony-" .. tostring(math.random(1, 100000)))
          data:Reset()
          return self:ValueChanges()
        end
        return Derma_Query('gui.ppm2.editor.io.newfile.confirm', 'gui.ppm2.editor.io.newfile.toptext', 'gui.ppm2.editor.generic.yes', confirmed, 'gui.ppm2.editor.generic.no')
      end)
      self:Button('gui.ppm2.editor.io.random', function()
        local data = self:GetTargetData()
        if not data then
          return 
        end
        local confirmed
        confirmed = function()
          PPM2.Randomize(data, false)
          return self:ValueChanges()
        end
        return Derma_Query('Really want to randomize?', 'Randomize', 'gui.ppm2.editor.generic.yes', confirmed, 'gui.ppm2.editor.generic.no')
      end)
      self:ComboBox('gui.ppm2.editor.misc.race', 'Race')
      self:ComboBox('gui.ppm2.editor.misc.wings', 'WingsType')
      self:CheckBox('gui.ppm2.editor.misc.gender', 'Gender')
      self:NumSlider('gui.ppm2.editor.misc.chest', 'MaleBuff', 2)
      self:NumSlider('gui.ppm2.editor.misc.weight', 'Weight', 2)
      self:NumSlider('gui.ppm2.editor.misc.size', 'PonySize', 2)
      if not ADVANCED_MODE:GetBool() then
        return 
      end
      self:CheckBox('gui.ppm2.editor.misc.hide_weapons', 'HideWeapons')
      if IS_USING_NEW(self:IsNewEditor()) then
        self:Hr()
        self:CheckBox('gui.ppm2.editor.misc.no_flexes2', 'NoFlex')
        self:Label('gui.ppm2.editor.misc.no_flexes_desc')
        local flexes = self:Spoiler('gui.ppm2.editor.misc.flexes')
        for _, _des_0 in ipairs(PPM2.PonyFlexController.FLEX_LIST) do
          local flex, active
          flex, active = _des_0.flex, _des_0.active
          if active then
            self:CheckBox("Disable " .. tostring(flex) .. " control", "DisableFlex" .. tostring(flex)):SetParent(flexes)
          end
        end
        return flexes:SizeToContents()
      end
    end
  },
  {
    ['name'] = 'gui.ppm2.editor.tabs.body',
    ['internal'] = 'body',
    ['func'] = function(self, sheet)
      self:ScrollPanel()
      self:ComboBox('gui.ppm2.editor.body.suit', 'Bodysuit')
      self:ColorBox('gui.ppm2.editor.body.color', 'BodyColor')
      if ADVANCED_MODE:GetBool() then
        self:CheckBox('gui.ppm2.editor.face.inherit.lips', 'LipsColorInherit')
        self:CheckBox('gui.ppm2.editor.face.inherit.nose', 'NoseColorInherit')
        self:ColorBox('gui.ppm2.editor.face.lips', 'LipsColor')
        self:ColorBox('gui.ppm2.editor.face.nose', 'NoseColor')
        PPM2.EditorPhongPanels(self, 'Body', 'gui.ppm2.editor.body.body_phong')
      end
      self:NumSlider('gui.ppm2.editor.neck.height', 'NeckSize', 2)
      self:NumSlider('gui.ppm2.editor.legs.height', 'LegsSize', 2)
      self:NumSlider('gui.ppm2.editor.body.spine_length', 'BackSize', 2)
      if ADVANCED_MODE:GetBool() then
        self:Hr()
        self:CheckBox('gui.ppm2.editor.body.disable_hoofsteps', 'DisableHoofsteps')
        self:CheckBox('gui.ppm2.editor.body.disable_wander_sounds', 'DisableWanderSounds')
        self:CheckBox('gui.ppm2.editor.body.disable_new_step_sounds', 'DisableStepSounds')
        self:CheckBox('gui.ppm2.editor.body.disable_jump_sound', 'DisableJumpSound')
        self:CheckBox('gui.ppm2.editor.body.disable_falldown_sound', 'DisableFalldownSound')
        self:Hr()
        self:CheckBox('gui.ppm2.editor.body.call_playerfootstep', 'CallPlayerFootstepHook')
        self:Label('gui.ppm2.editor.body.call_playerfootstep_desc')
      end
      self:Hr()
      if ADVANCED_MODE:GetBool() then
        self:CheckBox('gui.ppm2.editor.legs.socks.simple', 'Socks')
      end
      self:CheckBox('gui.ppm2.editor.legs.socks.model', 'SocksAsModel')
      self:ColorBox('gui.ppm2.editor.legs.socks.color', 'SocksColor')
      if ADVANCED_MODE:GetBool() then
        self:Hr()
        PPM2.EditorPhongPanels(self, 'Socks', 'gui.ppm2.editor.legs.socks.socks_phong')
        self:ComboBox('gui.ppm2.editor.legs.socks.texture', 'SocksTexture')
        self:Label('gui.ppm2.editor.legs.socks.url_texture')
        self:URLInput('SocksTextureURL')
        if IS_USING_NEW(self:IsNewEditor()) then
          self:Hr()
          self:CheckBox('gui.ppm2.editor.hoof.fluffers', 'HoofFluffers')
          self:NumSlider('gui.ppm2.editor.hoof.fluffers', 'HoofFluffersStrength', 2)
        end
        self:Hr()
        for i = 1, 6 do
          self:ColorBox('gui.ppm2.editor.legs.socks.color' .. i, 'SocksDetailColor' .. i)
        end
      end
      self:Hr()
      self:CheckBox('gui.ppm2.editor.legs.newsocks.model', 'SocksAsNewModel')
      self:ColorBox('gui.ppm2.editor.legs.newsocks.color1', 'NewSocksColor1')
      self:ColorBox('gui.ppm2.editor.legs.newsocks.color1', 'NewSocksColor2')
      self:ColorBox('gui.ppm2.editor.legs.newsocks.color1', 'NewSocksColor3')
      if ADVANCED_MODE:GetBool() then
        self:Label('gui.ppm2.editor.legs.newsocks.url')
        return self:URLInput('NewSocksTextureURL')
      end
    end
  },
  {
    ['name'] = 'gui.ppm2.editor.old_tabs.wings_and_horn',
    ['internal'] = 'wings_horn',
    ['func'] = function(self, sheet)
      self:ScrollPanel()
      self:CheckBox('gui.ppm2.editor.wings.separate_color', 'SeparateWings')
      if ADVANCED_MODE:GetBool() then
        self:CheckBox('gui.ppm2.editor.wings.separate_phong', 'SeparateWingsPhong')
      end
      self:CheckBox('gui.ppm2.editor.horn.separate_color', 'SeparateHorn')
      if ADVANCED_MODE:GetBool() then
        self:CheckBox('gui.ppm2.editor.horn.separate_phong', 'SeparateHornPhong')
      end
      self:CheckBox('gui.ppm2.editor.horn.separate_magic_color', 'SeparateMagicColor')
      self:Hr()
      self:ColorBox('gui.ppm2.editor.wings.color', 'WingsColor')
      if ADVANCED_MODE:GetBool() then
        PPM2.EditorPhongPanels(self, 'Wings', 'gui.ppm2.editor.wings.wings_phong')
      end
      self:ColorBox('gui.ppm2.editor.horn.color', 'HornColor')
      self:ColorBox('gui.ppm2.editor.horn.magic', 'HornMagicColor')
      if ADVANCED_MODE:GetBool() then
        PPM2.EditorPhongPanels(self, 'Horn', 'gui.ppm2.editor.horn.horn_phong')
      end
      self:Hr()
      self:ColorBox('gui.ppm2.editor.wings.bat_color', 'BatWingColor')
      self:ColorBox('gui.ppm2.editor.wings.bat_skin_color', 'BatWingSkinColor')
      if ADVANCED_MODE:GetBool() then
        PPM2.EditorPhongPanels(self, 'BatWingsSkin', 'gui.ppm2.editor.wings.bat_skin_phong')
      end
      self:Hr()
      local left = self:Spoiler('gui.ppm2.editor.tabs.left')
      self:NumSlider('gui.ppm2.editor.wings.left.size', 'LWingSize', 2, left)
      self:NumSlider('gui.ppm2.editor.wings.left.fwd', 'LWingX', 2, left)
      self:NumSlider('gui.ppm2.editor.wings.left.up', 'LWingY', 2, left)
      self:NumSlider('gui.ppm2.editor.wings.left.inside', 'LWingZ', 2, left)
      local right = self:Spoiler('gui.ppm2.editor.tabs.right')
      self:NumSlider('gui.ppm2.editor.wings.right.size', 'RWingSize', 2, right)
      self:NumSlider('gui.ppm2.editor.wings.right.fwd', 'RWingX', 2, right)
      self:NumSlider('gui.ppm2.editor.wings.right.up', 'RWingY', 2, right)
      self:NumSlider('gui.ppm2.editor.wings.right.inside', 'RWingZ', 2, right)
      if not ADVANCED_MODE:GetBool() then
        return 
      end
      self:Hr()
      self:ColorBox('gui.ppm2.editor.horn.detail_color', 'HornDetailColor')
      self:CheckBox('gui.ppm2.editor.horn.glowing_detail', 'HornGlow')
      return self:NumSlider('gui.ppm2.editor.horn.glow_strength', 'HornGlowSrength', 2)
    end
  },
  {
    ['name'] = 'gui.ppm2.editor.old_tabs.mane_tail',
    ['internal'] = 'manetail_old',
    ['display'] = function(editorMode)
      if editorMode == nil then
        editorMode = false
      end
      return not IS_USING_NEW(editorMode)
    end,
    ['func'] = function(self, sheet)
      self:ScrollPanel()
      self:ComboBox('Mane type', 'ManeType')
      self:ComboBox('Lower Mane type', 'ManeTypeLower')
      self:ComboBox('Tail type', 'TailType')
      self:CheckBox('Hide entitites when using PAC3 entity', 'HideManes')
      self:CheckBox('Hide socks when using PAC3 entity', 'HideManesSocks')
      self:NumSlider('Tail size', 'TailSize', 2)
      self:Hr()
      for i = 1, 2 do
        self:ColorBox("Mane color " .. tostring(i), "ManeColor" .. tostring(i))
      end
      for i = 1, 2 do
        self:ColorBox("Tail color " .. tostring(i), "TailColor" .. tostring(i))
      end
      self:Hr()
      for i = 1, 4 do
        self:ColorBox("Mane detail color " .. tostring(i), "ManeDetailColor" .. tostring(i))
      end
      for i = 1, 4 do
        self:ColorBox("Tail detail color " .. tostring(i), "TailDetailColor" .. tostring(i))
      end
    end
  },
  {
    ['name'] = 'gui.ppm2.editor.old_tabs.mane_tail',
    ['internal'] = 'manetail_new',
    ['display'] = IS_USING_NEW,
    ['func'] = function(self, sheet)
      self:ScrollPanel()
      self:ComboBox('gui.ppm2.editor.mane.type', 'ManeTypeNew')
      self:ComboBox('gui.ppm2.editor.mane.down.type', 'ManeTypeLowerNew')
      self:ComboBox('gui.ppm2.editor.tail.type', 'TailTypeNew')
      self:CheckBox('gui.ppm2.editor.misc.hide_pac3', 'HideManes')
      self:CheckBox('gui.ppm2.editor.misc.hide_mane', 'HideManesMane')
      self:CheckBox('gui.ppm2.editor.misc.hide_socks', 'HideManesSocks')
      self:CheckBox('gui.ppm2.editor.misc.hide_tail', 'HideManesTail')
      self:NumSlider('gui.ppm2.editor.tail.size', 'TailSize', 2)
      self:Hr()
      if ADVANCED_MODE:GetBool() then
        self:CheckBox('gui.ppm2.editor.mane.phong', 'SeparateManePhong')
      end
      if ADVANCED_MODE:GetBool() then
        PPM2.EditorPhongPanels(self, 'Mane', 'gui.ppm2.editor.mane.mane_phong')
      end
      for i = 1, 2 do
        self:ColorBox("gui.ppm2.editor.mane.color" .. tostring(i), "ManeColor" .. tostring(i))
      end
      for i = 1, 2 do
        self:ColorBox('gui.ppm2.editor.tail.color' .. i, "TailColor" .. tostring(i))
      end
      self:Hr()
      if ADVANCED_MODE:GetBool() then
        self:CheckBox('gui.ppm2.editor.tail.separate', 'SeparateTailPhong')
      end
      if ADVANCED_MODE:GetBool() then
        PPM2.EditorPhongPanels(self, 'Tail', 'gui.ppm2.editor.tail.tail_phong')
      end
      for i = 1, ADVANCED_MODE:GetBool() and 6 or 4 do
        self:ColorBox("gui.ppm2.editor.mane.detail_color" .. tostring(i), "ManeDetailColor" .. tostring(i))
      end
      for i = 1, ADVANCED_MODE:GetBool() and 6 or 4 do
        self:ColorBox('gui.ppm2.editor.tail.detail' .. i, "TailDetailColor" .. tostring(i))
      end
      if not ADVANCED_MODE:GetBool() then
        return 
      end
      self:Hr()
      self:CheckBox('gui.ppm2.editor.mane.phong_sep', 'SeparateMane')
      if ADVANCED_MODE:GetBool() then
        PPM2.EditorPhongPanels(self, 'UpperMane', 'gui.ppm2.editor.mane.up.phong')
      end
      if ADVANCED_MODE:GetBool() then
        PPM2.EditorPhongPanels(self, 'LowerMane', 'gui.ppm2.editor.mane.down.phong')
      end
      self:Hr()
      for i = 1, 2 do
        self:ColorBox("gui.ppm2.editor.mane.up.color" .. tostring(i), "UpperManeColor" .. tostring(i))
      end
      for i = 1, 2 do
        self:ColorBox("gui.ppm2.editor.mane.down.color" .. tostring(i), "LowerManeColor" .. tostring(i))
      end
      self:Hr()
      for i = 1, ADVANCED_MODE:GetBool() and 6 or 4 do
        self:ColorBox("gui.ppm2.editor.mane.up.detail_color" .. tostring(i), "UpperManeDetailColor" .. tostring(i))
      end
      for i = 1, ADVANCED_MODE:GetBool() and 6 or 4 do
        self:ColorBox("gui.ppm2.editor.mane.down.detail_color" .. tostring(i), "LowerManeDetailColor" .. tostring(i))
      end
    end
  },
  {
    ['name'] = 'gui.ppm2.editor.tabs.face',
    ['internal'] = 'face',
    ['func'] = function(self, sheet)
      self:ScrollPanel()
      self:ComboBox('gui.ppm2.editor.face.eyelashes', 'EyelashType')
      self:ColorBox('gui.ppm2.editor.face.eyelashes_color', 'EyelashesColor')
      self:ColorBox('gui.ppm2.editor.face.eyebrows_color', 'EyebrowsColor')
      if ADVANCED_MODE:GetBool() then
        self:CheckBox('gui.ppm2.editor.face.eyebrows_glow', 'GlowingEyebrows')
        self:NumSlider('gui.ppm2.editor.face.eyebrows_glow_strength', 'EyebrowsGlowStrength', 2)
        self:CheckBox('gui.ppm2.editor.face.eyelashes_separate_phong', 'SeparateEyelashesPhong')
        PPM2.EditorPhongPanels(self, 'Eyelashes', 'gui.ppm2.editor.face.eyelashes_phong')
      end
      if IS_USING_NEW(self:IsNewEditor()) then
        self:CheckBox('gui.ppm2.editor.ears.bat', 'BatPonyEars')
        if ADVANCED_MODE:GetBool() then
          self:NumSlider('gui.ppm2.editor.ears.bat', 'BatPonyEarsStrength', 2)
        end
        self:CheckBox('gui.ppm2.editor.mouth.fangs', 'Fangs')
        self:CheckBox('gui.ppm2.editor.mouth.alt_fangs', 'AlternativeFangs')
        if ADVANCED_MODE:GetBool() then
          self:NumSlider('gui.ppm2.editor.mouth.fangs', 'FangsStrength', 2)
        end
        self:CheckBox('gui.ppm2.editor.mouth.claw', 'ClawTeeth')
        if ADVANCED_MODE:GetBool() then
          self:NumSlider('gui.ppm2.editor.mouth.claw', 'ClawTeethStrength', 2)
        end
        if ADVANCED_MODE:GetBool() then
          self:NumSlider('gui.ppm2.editor.ears.size', 'EarsSize', 2)
          self:Hr()
          self:ColorBox('gui.ppm2.editor.mouth.teeth', 'TeethColor')
          self:ColorBox('gui.ppm2.editor.mouth.mouth', 'MouthColor')
          self:ColorBox('gui.ppm2.editor.mouth.tongue', 'TongueColor')
          PPM2.EditorPhongPanels(self, 'Teeth', 'gui.ppm2.editor.mouth.teeth_phong')
          PPM2.EditorPhongPanels(self, 'Mouth', 'gui.ppm2.editor.mouth.mouth_phong')
          return PPM2.EditorPhongPanels(self, 'Tongue', 'gui.ppm2.editor.mouth.tongue_phong')
        end
      end
    end
  },
  {
    ['name'] = 'gui.ppm2.editor.tabs.eyes',
    ['internal'] = 'eyes',
    ['func'] = function(self, sheet)
      self:ScrollPanel()
      if ADVANCED_MODE:GetBool() then
        self:Hr()
        self:CheckBox('gui.ppm2.editor.eyes.separate', 'SeparateEyes')
      end
      local eyes = {
        ''
      }
      if ADVANCED_MODE:GetBool() then
        eyes = {
          '',
          'Left',
          'Right'
        }
      end
      for _, publicName in ipairs(eyes) do
        self:Hr()
        local prefix = ''
        local tprefix = 'def'
        if publicName ~= '' then
          tprefix = publicName:lower()
          prefix = publicName .. ' '
        end
        self:Label('gui.ppm2.editor.eyes.url')
        self:URLInput("EyeURL" .. tostring(publicName))
        if ADVANCED_MODE:GetBool() then
          self:Label('gui.ppm2.editor.eyes.lightwarp_desc')
          local ttype = publicName == '' and 'BEyes' or publicName == 'Left' and 'LEye' or 'REye'
          self:CheckBox("gui.ppm2.editor.eyes." .. tostring(tprefix) .. ".lightwarp.shader", "EyeRefract" .. tostring(publicName))
          self:CheckBox("gui.ppm2.editor.eyes." .. tostring(tprefix) .. ".lightwarp.cornera", "EyeCornerA" .. tostring(publicName))
          self:ComboBox('gui.ppm2.editor.eyes.lightwarp', ttype .. 'Lightwarp')
          self:Label('gui.ppm2.editor.eyes.desc1')
          self:URLInput(ttype .. 'LightwarpURL')
          self:Label('gui.ppm2.editor.eyes.desc2')
          self:NumSlider("gui.ppm2.editor.eyes." .. tostring(tprefix) .. ".lightwarp.glossiness", 'EyeGlossyStrength' .. publicName, 2)
        end
        self:Label('gui.ppm2.editor.eyes.url_desc')
        self:ComboBox("gui.ppm2.editor.eyes." .. tostring(tprefix) .. ".type", "EyeType" .. tostring(publicName))
        self:ComboBox("gui.ppm2.editor.eyes." .. tostring(tprefix) .. ".reflection_type", "EyeReflectionType" .. tostring(publicName))
        self:CheckBox("gui.ppm2.editor.eyes." .. tostring(tprefix) .. ".lines", "EyeLines" .. tostring(publicName))
        self:CheckBox("gui.ppm2.editor.eyes." .. tostring(tprefix) .. ".derp", "DerpEyes" .. tostring(publicName))
        self:NumSlider("gui.ppm2.editor.eyes." .. tostring(tprefix) .. ".derp_strength", "DerpEyesStrength" .. tostring(publicName), 2)
        self:NumSlider("gui.ppm2.editor.eyes." .. tostring(tprefix) .. ".iris_size", "IrisSize" .. tostring(publicName), 2)
        if ADVANCED_MODE:GetBool() then
          self:CheckBox("gui.ppm2.editor.eyes." .. tostring(tprefix) .. ".points_inside", "EyeLineDirection" .. tostring(publicName))
          self:NumSlider("gui.ppm2.editor.eyes." .. tostring(tprefix) .. ".width", "IrisWidth" .. tostring(publicName), 2)
          self:NumSlider("gui.ppm2.editor.eyes." .. tostring(tprefix) .. ".height", "IrisHeight" .. tostring(publicName), 2)
        end
        self:NumSlider("gui.ppm2.editor.eyes." .. tostring(tprefix) .. ".pupil.width", "HoleWidth" .. tostring(publicName), 2)
        if ADVANCED_MODE:GetBool() then
          self:NumSlider("gui.ppm2.editor.eyes." .. tostring(tprefix) .. ".pupil.height", "HoleHeight" .. tostring(publicName), 2)
        end
        self:NumSlider("gui.ppm2.editor.eyes." .. tostring(tprefix) .. ".pupil.size", "HoleSize" .. tostring(publicName), 2)
        if ADVANCED_MODE:GetBool() then
          self:NumSlider("gui.ppm2.editor.eyes." .. tostring(tprefix) .. ".pupil.shift_x", "HoleShiftX" .. tostring(publicName), 2)
          self:NumSlider("gui.ppm2.editor.eyes." .. tostring(tprefix) .. ".pupil.shift_y", "HoleShiftY" .. tostring(publicName), 2)
          self:NumSlider("gui.ppm2.editor.eyes." .. tostring(tprefix) .. ".pupil.rotation", "EyeRotation" .. tostring(publicName), 0)
        end
        self:Hr()
        self:ColorBox("gui.ppm2.editor.eyes." .. tostring(tprefix) .. ".background", "EyeBackground" .. tostring(publicName))
        self:ColorBox("gui.ppm2.editor.eyes." .. tostring(tprefix) .. ".pupil_size", "EyeHole" .. tostring(publicName))
        self:ColorBox("gui.ppm2.editor.eyes." .. tostring(tprefix) .. ".top_iris", "EyeIrisTop" .. tostring(publicName))
        self:ColorBox("gui.ppm2.editor.eyes." .. tostring(tprefix) .. ".bottom_iris", "EyeIrisBottom" .. tostring(publicName))
        self:ColorBox("gui.ppm2.editor.eyes." .. tostring(tprefix) .. ".line1", "EyeIrisLine1" .. tostring(publicName))
        self:ColorBox("gui.ppm2.editor.eyes." .. tostring(tprefix) .. ".line2", "EyeIrisLine2" .. tostring(publicName))
        self:ColorBox("gui.ppm2.editor.eyes." .. tostring(tprefix) .. ".reflection", "EyeReflection" .. tostring(publicName))
        self:ColorBox("gui.ppm2.editor.eyes." .. tostring(tprefix) .. ".effect", "EyeEffect" .. tostring(publicName))
      end
    end
  },
  {
    ['name'] = 'gui.ppm2.editor.old_tabs.wings_and_horn_details',
    ['internal'] = 'wings_horn_details',
    ['display'] = function(editorMode)
      if editorMode == nil then
        editorMode = false
      end
      return ADVANCED_MODE:GetBool()
    end,
    ['func'] = function(self, sheet)
      self:ScrollPanel()
      for i = 1, 3 do
        self:Label('gui.ppm2.editor.horn.detail.desc' .. i)
        self:URLInput("HornURL" .. tostring(i))
        self:ColorBox('gui.ppm2.editor.horn.detail.color' .. i, "HornURLColor" .. tostring(i))
        self:Hr()
      end
      self:Hr()
      self:Label('gui.ppm2.editor.wings.normal')
      self:Hr()
      for i = 1, 3 do
        self:Label('gui.ppm2.editor.wings.details.def.detail' .. i)
        self:URLInput("WingsURL" .. tostring(i))
        self:ColorBox('gui.ppm2.editor.wings.details.def.color' .. i, "WingsURLColor" .. tostring(i))
        self:Hr()
      end
      self:Label('gui.ppm2.editor.wings.bat')
      self:Hr()
      for i = 1, 3 do
        self:Label('gui.ppm2.editor.wings.details.bat.detail' .. i)
        self:URLInput("BatWingURL" .. tostring(i))
        self:ColorBox('gui.ppm2.editor.wings.details.bat.color' .. i, "BatWingURLColor" .. tostring(i))
        self:Hr()
      end
      self:Label('gui.ppm2.editor.wings.bat_skin')
      self:Hr()
      for i = 1, 3 do
        self:Label('gui.ppm2.editor.wings.details.batskin.detail' .. i)
        self:URLInput("BatWingSkinURL" .. tostring(i))
        self:ColorBox('gui.ppm2.editor.wings.details.batskin.color' .. i, "BatWingSkinURLColor" .. tostring(i))
        self:Hr()
      end
    end
  },
  {
    ['name'] = 'gui.ppm2.editor.old_tabs.body_details',
    ['internal'] = 'bodydetails',
    ['func'] = function(self, sheet)
      self:ScrollPanel()
      for i = 1, ADVANCED_MODE:GetBool() and PPM2.MAX_BODY_DETAILS or 3 do
        self:ComboBox('gui.ppm2.editor.body.detail.desc' .. i, "BodyDetail" .. tostring(i))
        self:ColorBox('gui.ppm2.editor.body.detail.color' .. i, "BodyDetailColor" .. tostring(i))
        if ADVANCED_MODE:GetBool() then
          self:CheckBox('gui.ppm2.editor.body.detail.glow' .. i, "BodyDetailGlow" .. tostring(i))
          self:NumSlider('gui.ppm2.editor.body.detail.glow_strength' .. i, "BodyDetailGlowStrength" .. tostring(i), 2)
        end
        self:Hr()
      end
      self:Label('gui.ppm2.editor.body.url_desc')
      self:Hr()
      for i = 1, ADVANCED_MODE:GetBool() and PPM2.MAX_BODY_DETAILS or 2 do
        self:Label('gui.ppm2.editor.body.detail.url.desc' .. i)
        self:URLInput("BodyDetailURL" .. tostring(i))
        self:ColorBox('gui.ppm2.editor.body.detail.url.color' .. i, "BodyDetailURLColor" .. tostring(i))
        self:Hr()
      end
    end
  },
  {
    ['name'] = 'gui.ppm2.editor.old_tabs.mane_tail_detals',
    ['internal'] = 'manetail',
    ['func'] = function(self, sheet)
      self:ScrollPanel()
      for i = 1, ADVANCED_MODE:GetBool() and 6 or 1 do
        self:Label("gui.ppm2.editor.url_mane.desc" .. tostring(i))
        self:URLInput("ManeURL" .. tostring(i))
        self:ColorBox("gui.ppm2.editor.url_mane.color" .. tostring(i), "ManeURLColor" .. tostring(i))
        self:Hr()
      end
      for i = 1, ADVANCED_MODE:GetBool() and 6 or 1 do
        self:Label("gui.ppm2.editor.url_tail.desc" .. tostring(i))
        self:URLInput("TailURL" .. tostring(i))
        self:ColorBox("gui.ppm2.editor.url_tail.color" .. tostring(i), "TailURLColor" .. tostring(i))
        self:Hr()
      end
      self:Label('gui.ppm2.editor.mane.newnotice')
      self:CheckBox('gui.ppm2.editor.mane.phong_sep', 'SeparateMane')
      for i = 1, ADVANCED_MODE:GetBool() and 6 or 1 do
        self:Hr()
        self:Label("gui.ppm2.editor.url_mane.sep.up.desc" .. tostring(i))
        self:URLInput("UpperManeURL" .. tostring(i))
        self:ColorBox("gui.ppm2.editor.url_mane.sep.up.color" .. tostring(i), "UpperManeURLColor" .. tostring(i))
      end
      for i = 1, ADVANCED_MODE:GetBool() and 6 or 1 do
        self:Hr()
        self:Label("gui.ppm2.editor.url_mane.sep.down.desc" .. tostring(i))
        self:URLInput("LowerManeURL" .. tostring(i))
        self:ColorBox("gui.ppm2.editor.url_mane.sep.down.color" .. tostring(i), "LowerManeURLColor" .. tostring(i))
      end
    end
  },
  {
    ['name'] = 'gui.ppm2.editor.tabs.tattoos',
    ['internal'] = 'tattoos',
    ['display'] = function()
      return ADVANCED_MODE:GetBool()
    end,
    ['func'] = function(self, sheet)
      self:ScrollPanel()
      for i = 1, PPM2.MAX_TATTOOS do
        local spoiler = self:Spoiler('gui.ppm2.editor.tattoo.layer' .. i)
        local updatePanels = { }
        self:Button('gui.ppm2.editor.tattoo.edit_keyboard', (function()
          return self:GetFrame():EditTattoo(i, updatePanels)
        end), spoiler)
        self:ComboBox('gui.ppm2.editor.tattoo.type', "TattooType" .. tostring(i), nil, spoiler)
        table.insert(updatePanels, self:NumSlider('gui.ppm2.editor.tattoo.tweak.rotate', "TattooRotate" .. tostring(i), 0, spoiler))
        table.insert(updatePanels, self:NumSlider('gui.ppm2.editor.tattoo.tweak.x', "TattooPosX" .. tostring(i), 2, spoiler))
        table.insert(updatePanels, self:NumSlider('gui.ppm2.editor.tattoo.tweak.y', "TattooPosY" .. tostring(i), 2, spoiler))
        table.insert(updatePanels, self:NumSlider('gui.ppm2.editor.tattoo.tweak.width', "TattooScaleX" .. tostring(i), 2, spoiler))
        table.insert(updatePanels, self:NumSlider('gui.ppm2.editor.tattoo.tweak.height', "TattooScaleY" .. tostring(i), 2, spoiler))
        self:CheckBox('gui.ppm2.editor.tattoo.over', "TattooOverDetail" .. tostring(i), spoiler)
        self:CheckBox('gui.ppm2.editor.tattoo.glow', "TattooGlow" .. tostring(i), spoiler)
        self:NumSlider('gui.ppm2.editor.tattoo.glow_strength', "TattooGlowStrength" .. tostring(i), 2, spoiler)
        local box, collapse = self:ColorBox('gui.ppm2.editor.tattoo.color', "TattooColor" .. tostring(i), spoiler)
        collapse:SetExpanded(true)
      end
    end
  },
  {
    ['name'] = 'gui.ppm2.editor.tabs.cutiemark',
    ['internal'] = 'cmark',
    ['func'] = function(self, sheet)
      self:CheckBox('gui.ppm2.editor.cutiemark.display', 'CMark')
      self:ComboBox('gui.ppm2.editor.cutiemark.type', 'CMarkType')
      self.markDisplay = vgui.Create('EditablePanel', self)
      do
        local _with_0 = self.markDisplay
        _with_0:Dock(TOP)
        _with_0:SetSize(320, 320)
        _with_0:DockMargin(20, 20, 20, 20)
        _with_0.currentColor = BackgroundColors[1]
        _with_0.lerpChange = 0
        _with_0.colorIndex = 2
        _with_0.nextColor = BackgroundColors[2]
        _with_0.Paint = function(pnl, w, h)
          if w == nil then
            w = 0
          end
          if h == nil then
            h = 0
          end
          local data = self:GetTargetData()
          if not data then
            return 
          end
          local controller = data:GetController()
          if not controller then
            return 
          end
          local rcontroller = controller:GetRenderController()
          if not rcontroller then
            return 
          end
          local tcontroller = rcontroller:GetTextureController()
          if not tcontroller then
            return 
          end
          local mat = tcontroller:GetCMarkGUI()
          if not mat then
            return 
          end
          _with_0.lerpChange = _with_0.lerpChange + (RealFrameTime() / 4)
          if _with_0.lerpChange >= 1 then
            _with_0.lerpChange = 0
            _with_0.currentColor = BackgroundColors[_with_0.colorIndex]
            _with_0.colorIndex = _with_0.colorIndex + 1
            if _with_0.colorIndex > #BackgroundColors then
              _with_0.colorIndex = 1
            end
            _with_0.nextColor = BackgroundColors[_with_0.colorIndex]
          end
          local r1, g1, b1
          do
            local _obj_0 = _with_0.currentColor
            r1, g1, b1 = _obj_0.r, _obj_0.g, _obj_0.b
          end
          local r2, g2, b2
          do
            local _obj_0 = _with_0.nextColor
            r2, g2, b2 = _obj_0.r, _obj_0.g, _obj_0.b
          end
          local r, g, b = r1 + (r2 - r1) * _with_0.lerpChange, g1 + (g2 - g1) * _with_0.lerpChange, r1 + (b2 - b1) * _with_0.lerpChange
          surface.SetDrawColor(r, g, b, 100)
          surface.DrawRect(0, 0, w, h)
          surface.SetDrawColor(255, 255, 255)
          surface.SetMaterial(mat)
          return surface.DrawTexturedRect(0, 0, w, h)
        end
      end
      self:NumSlider('gui.ppm2.editor.cutiemark.size', 'CMarkSize', 2)
      self:ColorBox('gui.ppm2.editor.cutiemark.color', 'CMarkColor')
      self:Hr()
      self:Label('gui.ppm2.editor.cutiemark.input'):DockMargin(5, 10, 5, 10)
      return self:URLInput('CMarkURL')
    end
  },
  {
    ['name'] = 'gui.ppm2.editor.tabs.files',
    ['internal'] = 'saves',
    ['func'] = PPM2.EditorBuildNewFilesPanel
  },
  {
    ['name'] = 'gui.ppm2.editor.tabs.old_files',
    ['internal'] = 'oldsaves',
    ['func'] = PPM2.EditorBuildOldFilesPanel
  },
  {
    ['name'] = 'gui.ppm2.editor.tabs.about',
    ['internal'] = 'about',
    ['func'] = function(self, sheet)
      local title = self:Label('PPM/2')
      title:SetFont('PPM2.Title')
      title:SizeToContents()
      self:URLLabel('gui.ppm2.editor.info.discord', 'https://discord.gg/HG9eS79'):SetFont('PPM2.AboutLabels')
      self:URLLabel('gui.ppm2.editor.info.ponyscape', 'http://steamcommunity.com/groups/Ponyscape'):SetFont('PPM2.AboutLabels')
      self:URLLabel('gui.ppm2.editor.info.creator', 'https://steamcommunity.com/profiles/76561198077439269'):SetFont('PPM2.AboutLabels')
      self:URLLabel('gui.ppm2.editor.info.newmodels', 'https://steamcommunity.com/profiles/76561198013875404'):SetFont('PPM2.AboutLabels')
      self:URLLabel('gui.ppm2.editor.info.cppmmodels', 'http://steamcommunity.com/profiles/76561198084938735'):SetFont('PPM2.AboutLabels')
      self:URLLabel('gui.ppm2.editor.info.oldmodels', 'https://github.com/ChristinaTech/PonyPlayerModels'):SetFont('PPM2.AboutLabels')
      self:URLLabel('gui.ppm2.editor.info.bugs', 'https://gitlab.com/DBotThePony/PPM2/issues'):SetFont('PPM2.AboutLabels')
      self:URLLabel('gui.ppm2.editor.info.sources', 'https://gitlab.com/DBotThePony/PPM2'):SetFont('PPM2.AboutLabels')
      self:URLLabel('gui.ppm2.editor.info.githubsources', 'https://github.com/roboderpy/PPM2'):SetFont('PPM2.AboutLabels')
      return self:Label('gui.ppm2.editor.info.thanks'):SetFont('PPM2.AboutLabels')
    end
  }
}
if IsValid(PPM2.OldEditorFrame) then
  PPM2.OldEditorFrame:Remove()
  net.Start('PPM2.EditorStatus')
  net.WriteBool(false)
  net.SendToServer()
end
if IsValid(PPM2.EditorTopFrame) then
  PPM2.EditorTopFrame:Remove()
  net.Start('PPM2.EditorStatus')
  net.WriteBool(false)
  net.SendToServer()
end
local STRETCHING_PANEL = {
  Init = function(self)
    self.size = PANEL_WIDTH:GetInt()
    self.isize = PANEL_WIDTH:GetInt()
    self:SetSize(8, 0)
    self:SetCursor('sizewe')
    self:SetMouseInputEnabled(true)
    self.hold = false
    self.MINS = 200
    self.MAXS = 600
    self.posx, self.posy = 0, 0
  end,
  OnMousePressed = function(self, key)
    if key == nil then
      key = MOUSE_LEFT
    end
    if key ~= MOUSE_LEFT then
      return 
    end
    self.hold = true
    self.posx, self.posy = self:LocalToScreen(0, 0)
    self.posx = self.posx + 3
    self.isize = self.size
  end,
  OnMouseReleased = function(self, key)
    if key == nil then
      key = MOUSE_LEFT
    end
    if key ~= MOUSE_LEFT then
      return 
    end
    self.hold = false
    return RunConsoleCommand('ppm2_editor_width', self.size)
  end,
  Think = function(self)
    if not self.hold then
      return 
    end
    local x, y = gui.MousePos()
    self.size = self.isize + x - self.posx
    if self.size ~= self.isize then
      return self.target:SetSize(self.size, 0)
    end
  end,
  Paint = function(self, w, h)
    if w == nil then
      w = 0
    end
    if h == nil then
      h = 0
    end
    surface.SetDrawColor(35, 175, 99)
    return surface.DrawRect(0, 0, w, h)
  end
}
vgui.Register('PPM2.Editor.Stretch', STRETCHING_PANEL, 'EditablePanel')
local cl_playermodel
PPM2.EditorCreateTopButtons = function(self, isNewEditor, addFullbright)
  if isNewEditor == nil then
    isNewEditor = false
  end
  if addFullbright == nil then
    addFullbright = false
  end
  local oldPerformLayout = self.PerformLayout or (function() end)
  local saveAs
  saveAs = function(callback)
    if callback == nil then
      callback = (function() end)
    end
    local confirm
    confirm = function(txt)
      if txt == nil then
        txt = ''
      end
      txt = txt:Trim()
      if txt == '' then
        return 
      end
      self.data:SetFilename(txt)
      self.data:Save()
      self.unsavedChanges = false
      if IsValid(self.model) then
        self.model.unsavedChanges = false
      end
      self:SetTitle('gui.ppm2.editor.generic.title_file', self.data:GetFilename() or '%ERRNAME%')
      if self.panels and self.panels.saves and self.panels.saves.rebuildFileList then
        self.panels.saves.rebuildFileList()
      end
      if self.saves and self.saves.rebuildFileList then
        self.saves.rebuildFileList()
      end
      return callback(txt)
    end
    return Derma_StringRequest('gui.ppm2.editor.io.save.button', 'gui.ppm2.editor.io.save.text', self.data:GetFilename(), confirm)
  end
  do
    local _with_0 = vgui.Create('DButton', self)
    self.saveButton = _with_0
    _with_0:SetText('gui.ppm2.editor.io.save.button')
    _with_0:SetSize(90, 20)
    _with_0.DoClick = function()
      return saveAs()
    end
  end
  do
    local _with_0 = vgui.Create('DButton', self)
    self.wearButton = _with_0
    _with_0:SetText('gui.ppm2.editor.io.wear')
    _with_0:SetSize(140, 20)
    local lastWear = 0
    _with_0.DoClick = function()
      if RealTimeL() < lastWear then
        return 
      end
      lastWear = RealTimeL() + 5
      local mainData = PPM2.GetMainData()
      local nwdata = LocalPlayer():GetPonyData()
      if nwdata then
        mainData:SetNetworkData(nwdata)
        if nwdata.netID == -1 then
          nwdata.NETWORKED = false
          nwdata:Create()
        end
      end
      self.data:ApplyDataToObject(mainData, false)
      cl_playermodel = cl_playermodel or GetConVar('cl_playermodel')
      if not cl_playermodel:GetString():find('pony') then
        return RunConsoleCommand('cl_playermodel', 'pony')
      end
    end
  end
  if not isNewEditor then
    local editorModelSelect = USE_MODEL:GetString():upper()
    editorModelSelect = EditorModels[editorModelSelect] and editorModelSelect or 'DEFAULT'
    do
      local _with_0 = vgui.Create('DComboBox', self)
      self.selectModelBox = _with_0
      _with_0:SetSize(120, 20)
      _with_0:SetValue(editorModelSelect)
      for _, choice in ipairs({
        'default',
        'cppm',
        'new'
      }) do
        _with_0:AddChoice(choice)
      end
      _with_0.OnSelect = function(pnl, index, value, data)
        if pnl == nil then
          pnl = box
        end
        if index == nil then
          index = 1
        end
        if value == nil then
          value = ''
        end
        if data == nil then
          data = value
        end
        self:SetDeleteOnClose(true)
        RunConsoleCommand('ppm2_editor_model', value)
        local confirm
        confirm = function()
          self:Close()
          return timer.Simple(0.1, PPM2.OpenOldEditor)
        end
        return Derma_Query('gui.ppm2.editor.generic.restart.text', 'gui.ppm2.editor.generic.restart.needed', 'gui.ppm2.editor.generic.yes', confirm, 'gui.ppm2.editor.generic.no')
      end
    end
  end
  do
    local _with_0 = vgui.Create('DCheckBoxLabel', self)
    self.enableAdvanced = _with_0
    _with_0:SetSize(120, 20)
    _with_0:SetConVar('ppm2_editor_advanced')
    _with_0:SetText('Advanced mode')
    _with_0.ingore = true
    _with_0.OnChange = function(pnl, newVal)
      if pnl == nil then
        pnl = box
      end
      if newVal == ADVANCED_MODE:GetBool() then
        return 
      end
      self:SetDeleteOnClose(true)
      local confirm
      confirm = function()
        self:Close()
        return timer.Simple(0.1, PPM2.OpenEditor)
      end
      return Derma_Query('gui.ppm2.editor.generic.restart.text', 'gui.ppm2.editor.generic.restart.needed', 'gui.ppm2.editor.generic.yes', confirm, 'gui.ppm2.editor.generic.no')
    end
  end
  if not isNewEditor or addFullbright then
    do
      local _with_0 = vgui.Create('DCheckBoxLabel', self)
      self.fullbrightSwitch = _with_0
      _with_0:SetSize(120, 20)
      _with_0:SetConVar('ppm2_editor_fullbright')
      _with_0:SetText('gui.ppm2.editor.generic.fullbright')
    end
  end
  self.PerformLayout = function(self, W, H)
    if W == nil then
      W = 0
    end
    if H == nil then
      H = 0
    end
    oldPerformLayout(self, w, h)
    self.wearButton:SetPos(W - 350, 5)
    self.saveButton:SetPos(W - 205, 5)
    self.enableAdvanced:SetPos(W - 590, 7)
    if IsValid(self.fullbrightSwitch) then
      self.fullbrightSwitch:SetPos(W - 700, 7)
    end
    if IsValid(self.selectModelBox) then
      return self.selectModelBox:SetPos(W - 475, 5)
    end
  end
end
PPM2.OpenNewEditor = function()
  if IsValid(PPM2.EditorTopFrame) then
    do
      local _with_0 = PPM2.EditorTopFrame
      if _with_0.TargetModel ~= LocalPlayer():GetModel() then
        _with_0:Remove()
        return PPM2.OpenNewEditor()
      end
      _with_0:SetVisible(true)
      _with_0.controller = LocalPlayer():GetPonyData() or _with_0.controller
      _with_0.data:ApplyDataToObject(_with_0.controller, false)
      _with_0.data:SetNetworkData(_with_0.controller)
      _with_0.leftPanel:SetVisible(true)
      _with_0.calcPanel:SetVisible(true)
      net.Start('PPM2.EditorStatus')
      net.WriteBool(true)
      net.SendToServer()
    end
    return 
  end
  local ply = LocalPlayer()
  local controller = ply:GetPonyData()
  if not controller then
    Derma_Message('gui.ppm2.editor.generic.wtf', 'gui.ppm2.editor.generic.ohno', 'gui.ppm2.editor.generic.okay')
    return 
  end
  PPM2.EditorTopFrame = vgui.Create('EditablePanel')
  PPM2.EditorTopFrame:SetSkin('DLib_Black')
  local self = PPM2.EditorTopFrame
  local topframe = PPM2.EditorTopFrame
  self:SetPos(0, 0)
  self:MakePopup()
  local topSize = 55
  self:SetSize(ScrW(), topSize)
  local sysTime = SysTime()
  self.TargetModel = LocalPlayer():GetModel()
  self.btnClose = vgui.Create('DButton', self)
  self.btnClose:SetText('')
  self.btnClose.DoClick = function()
    return self:Close()
  end
  self.btnClose.Paint = function(self, w, h)
    if w == nil then
      w = 0
    end
    if h == nil then
      h = 0
    end
    return derma.SkinHook('Paint', 'WindowCloseButton', self, w, h)
  end
  self.btnClose:SetSize(31, 31)
  self.btnClose:SetPos(ScrW() - 40, 0)
  self.Paint = function(self, w, h)
    if w == nil then
      w = 0
    end
    if h == nil then
      h = 0
    end
    return derma.SkinHook('Paint', 'Frame', self, w, h)
  end
  self:DockPadding(5, 29, 5, 5)
  PPM2.EditorCreateTopButtons(self, true)
  self.lblTitle = vgui.Create('DLabel', self)
  self.lblTitle:SetPos(5, 0)
  self.lblTitle:SetSize(300, 20)
  self.SetTitle = function(self, text, ...)
    if text == nil then
      text = ''
    end
    return self.lblTitle:SetText(text, ...)
  end
  self.GetTitle = function(self)
    return self.lblTitle:GetText()
  end
  self.deleteOnClose = false
  self.SetDeleteOnClose = function(self, val)
    if val == nil then
      val = false
    end
    self.deleteOnClose = val
  end
  self.Close = function(self)
    local data = PPM2.GetMainData()
    data:ApplyDataToObject(self.controller, false)
    self:SetVisible(false)
    self.leftPanel:SetVisible(false)
    self.calcPanel:SetVisible(false)
    net.Start('PPM2.EditorStatus')
    net.WriteBool(false)
    net.SendToServer()
    if self.deleteOnClose then
      return self:Remove()
    end
  end
  self.OnRemove = function(self)
    self.leftPanel:Remove()
    return self.calcPanel:Remove()
  end
  self.calcPanel = vgui.Create('PPM2CalcViewPanel')
  self.calcPanel:SetPos(350, topSize)
  self.calcPanel:SetRealPos(350, topSize)
  self.calcPanel:SetSize(ScrW() - 350, ScrH() - topSize)
  self.calcPanel:SetRealSize(ScrW() - 350, ScrH() - topSize)
  self.calcPanel:MakePopup()
  self.calcPanel:SetSkin('DLib_Black')
  self:MakePopup()
  self.leftPanel = vgui.Create('EditablePanel')
  self.leftPanel:SetPos(0, topSize)
  self.leftPanel:SetSize(350, ScrH() - topSize)
  self.leftPanel:SetMouseInputEnabled(true)
  self.leftPanel:SetKeyboardInputEnabled(true)
  self.leftPanel:MakePopup()
  self.leftPanel:SetSkin('DLib_Black')
  self.menus = vgui.Create('DPropertySheet', self.leftPanel)
  self.menus:Dock(FILL)
  self.menus:SetSize(PANEL_WIDTH:GetInt(), 0)
  self.menusBar = self.menus.tabScroller
  self.menusBar:SetParent(self)
  self.menusBar:Dock(FILL)
  self.menusBar:SetSize(0, 20)
  local copy = PPM2.GetMainData():Copy()
  self.controller = controller
  copy:SetNetworkData(self.controller)
  copy:SetNetworkOnChange(false)
  self.data = copy
  self.DoUpdate = function()
    for i, pnl in pairs(self.panels) do
      pnl:DoUpdate()
    end
  end
  self:SetTitle('gui.ppm2.editor.generic.title_file', copy:GetFilename() or '%ERRNAME%')
  self.EditTattoo = function(self, index, panelsToUpdate)
    if index == nil then
      index = 1
    end
    if panelsToUpdate == nil then
      panelsToUpdate = { }
    end
    local editor = vgui.Create('PPM2TattooEditor')
    editor:SetTargetData(copy)
    editor:SetTargetID(index)
    return editor:SetPanelsToUpdate(panelsToUpdate)
  end
  self.panels = { }
  local createdPanels = 9
  for _, _des_0 in ipairs(EditorPages) do
    local _continue_0 = false
    repeat
      local name, func, internal, display
      name, func, internal, display = _des_0.name, _des_0.func, _des_0.internal, _des_0.display
      if display and not display(true) then
        _continue_0 = true
        break
      end
      local pnl = vgui.Create('PPM2SettingsBase', self.menus)
      self.menus:AddSheet(name, pnl)
      pnl:SetIsNewEditor(true)
      pnl:SetTargetData(copy)
      pnl:Dock(FILL)
      pnl.frame = self
      pnl.Populate = function()
        return func(pnl, self.menus)
      end
      self.panels[internal] = pnl
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
  self.leftPanel:MakePopup()
  self:MakePopup()
  net.Start('PPM2.EditorStatus')
  net.WriteBool(true)
  net.SendToServer()
  local iTime = math.floor((SysTime() - sysTime) * 1000)
end
PPM2.OpenOldEditor = function()
  if IsValid(PPM2.OldEditorFrame) then
    PPM2.OldEditorFrame:SetVisible(true)
    PPM2.OldEditorFrame:Center()
    PPM2.OldEditorFrame:MakePopup()
    net.Start('PPM2.EditorStatus')
    net.WriteBool(true)
    net.SendToServer()
    return 
  end
  local sysTime = SysTime()
  local frame = vgui.Create('DLib_Window')
  local self = frame
  local W, H = ScrW() - 25, ScrH() - 25
  self:SetSize(W, H)
  self:Center()
  self:SetDeleteOnClose(false)
  PPM2.OldEditorFrame = self
  self.OnClose = function()
    net.Start('PPM2.EditorStatus')
    net.WriteBool(false)
    return net.SendToServer()
  end
  self.menus = vgui.Create('DPropertySheet', self)
  self.menus:Dock(LEFT)
  self.menus:SetSize(PANEL_WIDTH:GetInt(), 0)
  self.menusBar = self.menus.tabScroller
  self.menusBar:SetParent(self)
  self.menusBar:Dock(TOP)
  self.menusBar:SetSize(0, 20)
  self.stretch = vgui.Create('PPM2.Editor.Stretch', self)
  self.stretch:Dock(LEFT)
  self.stretch:DockMargin(5, 0, 0, 0)
  self.stretch.target = self.menus
  self.model = vgui.Create('PPM2ModelPanel', self)
  self.model:Dock(FILL)
  local copy = PPM2.GetMainData():Copy()
  local ply = LocalPlayer()
  local editorModelSelect = USE_MODEL:GetString():upper()
  editorModelSelect = EditorModels[editorModelSelect] and editorModelSelect or 'DEFAULT'
  local ent = self.model:ResetModel(nil, EditorModels[editorModelSelect])
  local controller = copy:CreateCustomController(ent)
  controller:SetFlexLerpMultiplier(1.3)
  copy:SetController(controller)
  frame.controller = controller
  frame.data = copy
  frame.DoUpdate = function()
    for i, pnl in pairs(self.panels) do
      pnl:DoUpdate()
    end
  end
  PPM2.EditorCreateTopButtons(self)
  self:SetTitle('gui.ppm2.editor.generic.title_file', copy:GetFilename() or '%ERRNAME%')
  self.model:SetController(controller)
  controller:SetupEntity(ent)
  controller:SetDisableTask(true)
  self.EditTattoo = function(self, index, panelsToUpdate)
    if index == nil then
      index = 1
    end
    if panelsToUpdate == nil then
      panelsToUpdate = { }
    end
    local editor = vgui.Create('PPM2TattooEditor')
    editor:SetTargetData(copy)
    editor:SetTargetID(index)
    return editor:SetPanelsToUpdate(panelsToUpdate)
  end
  self.panels = { }
  local createdPanels = 17
  for _, _des_0 in ipairs(EditorPages) do
    local _continue_0 = false
    repeat
      local name, func, internal, display
      name, func, internal, display = _des_0.name, _des_0.func, _des_0.internal, _des_0.display
      if display and not display(false) then
        _continue_0 = true
        break
      end
      local pnl = vgui.Create('PPM2SettingsBase', self.menus)
      self.menus:AddSheet(name, pnl)
      pnl:SetTargetData(copy)
      pnl:Dock(FILL)
      pnl.frame = self
      pnl.Populate = function()
        return func(pnl, self.menus)
      end
      self.panels[internal] = pnl
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
  net.Start('PPM2.EditorStatus')
  net.WriteBool(true)
  net.SendToServer()
  local iTime = math.floor((SysTime() - sysTime) * 1000)
end
PPM2.OpenEditor = function()
  if LocalPlayer():IsPony() then
    return PPM2.OpenNewEditor()
  else
    return PPM2.OpenOldEditor()
  end
end
concommand.Add('ppm2_editor', PPM2.OpenEditor)
concommand.Add('ppm2_new_editor', PPM2.OpenNewEditor)
concommand.Add('ppm2_old_editor', PPM2.OpenOldEditor)
concommand.Add('ppm2_old_editor_reload', function()
  if IsValid(PPM2.OldEditorFrame) then
    return PPM2.OldEditorFrame:Remove()
  end
end)
concommand.Add('ppm2_new_editor_reload', function()
  if IsValid(PPM2.EditorTopFrame) then
    return PPM2.EditorTopFrame:Remove()
  end
end)
concommand.Add('ppm2_editor_reload', function()
  if IsValid(PPM2.OldEditorFrame) then
    PPM2.OldEditorFrame:Remove()
  end
  if IsValid(PPM2.EditorTopFrame) then
    PPM2.EditorTopFrame:Remove()
  end
  if IsValid(PPM2.EDITOR3) then
    return PPM2.EDITOR3:Remove()
  end
end)
local IconData = {
  title = 'PPM/2 Editor',
  icon = 'gui/ppm2_icon.png',
  width = 960,
  height = 700,
  onewindow = true,
  init = function(icon, window)
    window:Remove()
    return RunConsoleCommand('ppm2_editor')
  end
}
list.Set('DesktopWindows', 'PPM2', IconData)
if IsValid(g_ContextMenu) then
  CreateContextMenu()
end
return hook.Add('PopulateToolMenu', 'PPM2.PonyPosing', function()
  return spawnmenu.AddToolMenuOption('Utilities', 'User', 'PPM2.Posing', 'PPM2', '', '', function(self)
    if not self:IsValid() then
      return 
    end
    self:Clear()
    self:Button('gui.ppm2.spawnmenu.newmodel', 'gm_spawn', 'models/ppm/player_default_base_new.mdl')
    self:Button('gui.ppm2.spawnmenu.newmodelnj', 'gm_spawn', 'models/ppm/player_default_base_new_nj.mdl')
    self:Button('gui.ppm2.spawnmenu.oldmodel', 'gm_spawn', 'models/ppm/player_default_base.mdl')
    self:Button('gui.ppm2.spawnmenu.oldmodelnj', 'gm_spawn', 'models/ppm/player_default_base_nj.mdl')
    self:Button('gui.ppm2.spawnmenu.cppmmodel', 'gm_spawn', 'models/cppm/player_default_base.mdl')
    self:Button('gui.ppm2.spawnmenu.cppmmodelnj', 'gm_spawn', 'models/cppm/player_default_base_nj.mdl')
    self:Button('gui.ppm2.spawnmenu.cleanup', 'ppm2_cleanup')
    self:Button('gui.ppm2.spawnmenu.reload', 'ppm2_reload')
    self:Button('gui.ppm2.spawnmenu.require', 'ppm2_require')
    self:CheckBox('gui.ppm2.spawnmenu.drawhooves', 'ppm2_cl_draw_hands')
    self:CheckBox('gui.ppm2.spawnmenu.nohoofsounds', 'ppm2_cl_no_hoofsound')
    self:CheckBox('gui.ppm2.spawnmenu.noflexes', 'ppm2_disable_flexes')
    self:CheckBox('gui.ppm2.spawnmenu.advancedmode', 'ppm2_editor_advanced')
    self:CheckBox('gui.ppm2.spawnmenu.reflections', 'ppm2_cl_reflections')
    self:NumSlider('gui.ppm2.spawnmenu.reflections_drawdist', 'ppm2_cl_reflections_drawdist', 0, 1024, 0)
    self:NumSlider('gui.ppm2.spawnmenu.reflections_renderdist', 'ppm2_cl_reflections_renderdist', 32, 4096, 0)
    return self:CheckBox('gui.ppm2.spawnmenu.doublejump', 'ppm2_flight_djump')
  end)
end)
