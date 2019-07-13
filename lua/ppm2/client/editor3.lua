local ENABLE_FULLBRIGHT = CreateConVar('ppm2_editor_fullbright', '1', {
  FCVAR_ARCHIVE
}, 'Disable lighting in editor')
local ADVANCED_MODE = CreateConVar('ppm2_editor_advanced', '0', {
  FCVAR_ARCHIVE
}, 'Show all options. Keep in mind Editor3 acts different with this option.')
local inRadius
inRadius = function(val, min, max)
  return val >= min and val <= max
end
local inBox
inBox = function(pointX, pointY, x, y, w, h)
  return inRadius(pointX, x - w, x + w) and inRadius(pointY, y - h, y + h)
end
surface.CreateFont('PPM2BackButton', {
  font = 'Roboto',
  size = ScreenScale(24):floor(),
  weight = 600
})
surface.CreateFont('PPM2EditorPanelHeaderText', {
  font = 'PT Serif',
  size = ScreenScale(16):floor(),
  weight = 600
})
local HUDCommons
HUDCommons = DLib.HUDCommons
local drawCrosshair
drawCrosshair = function(x, y, radius, arcColor, boxesColor)
  if radius == nil then
    radius = ScreenScale(10)
  end
  if arcColor == nil then
    arcColor = Color(255, 255, 255)
  end
  if boxesColor == nil then
    boxesColor = Color(200, 200, 200)
  end
  x = x - (radius / 2)
  y = y - (radius / 2)
  HUDCommons.DrawCircleHollow(x, y, radius, radius * 2, radius * 0.2, arcColor)
  local h = radius * 0.1
  local w = radius * 0.6
  surface.SetDrawColor(boxesColor)
  surface.DrawRect(x - w / 2, y + radius / 2 - h / 2, w, h)
  surface.DrawRect(x + radius / 2 + w / 2, y + radius / 2 - h / 2, w, h)
  surface.DrawRect(x + radius / 2 - h / 2, y - w / 2, h, w)
  return surface.DrawRect(x + radius / 2 - h / 2, y + radius / 2 + w / 3, h, w)
end
local MODEL_BOX_PANEL = {
  SEQUENCE_STAND = 22,
  PONY_VEC_Z = 64 * .7,
  SEQUENCES = {
    ['Standing'] = 22,
    ['Moving'] = 316,
    ['Walking'] = 232,
    ['Sit'] = 202,
    ['Swim'] = 370,
    ['Run'] = 328,
    ['Crouch walk'] = 286,
    ['Crouch'] = 76,
    ['Jump'] = 160
  },
  Init = function(self)
    self.animRate = 1
    self.seq = self.SEQUENCE_STAND
    self.hold = false
    self.holdOnPoint = false
    self.holdRightClick = false
    self.canHold = true
    self.lastTick = RealTimeL()
    self.startAnimStart = RealTimeL() + 2
    self.startAnimEnd = RealTimeL() + 8
    self.startAnimStart2 = RealTimeL() + 2.5
    self.startAnimEnd2 = RealTimeL() + 9
    self.menuPanelsCache = { }
    self.updatePanels = { }
    self.holdLast = 0
    self.mouseX, self.mouseY = 0, 0
    self.crosshairCircleInactive = Color(150, 150, 150)
    self.crosshairBoxInactive = Color(100, 100, 100)
    self.crosshairCircleHovered = Color(137, 195, 196)
    self.crosshairBoxHovered = Color(200, 200, 200)
    self.crosshairCircleSelected = Color(0, 0, 0, 0)
    self.crosshairBoxSelected = Color(211, 255, 192)
    self.angle = Angle(-10, -30, 0)
    self.distToPony = 90
    self.ldistToPony = 90
    self.trackBone = -1
    self.trackBoneName = 'LrigSpine2'
    self.trackAttach = -1
    self.trackAttachName = ''
    self.shouldAutoTrack = true
    self.autoTrackPos = Vector(0, 0, 0)
    self.lautoTrackPos = Vector(0, 0, 0)
    self.fixedDistanceToPony = 100
    self.lfixedDistanceToPony = 100
    self.vectorPos = Vector(self.fixedDistanceToPony, 0, 0)
    self.lvectorPos = Vector(self.fixedDistanceToPony, 0, 0)
    self.targetPos = Vector(0, 0, self.PONY_VEC_Z * .7)
    self.ldrawAngle = Angle()
    self:SetCursor('none')
    self:SetMouseInputEnabled(true)
    self.buildingModel = ClientsideModel('models/ppm/ppm2_stage.mdl', RENDERGROUP_OTHER)
    self.buildingModel:SetNoDraw(true)
    self.buildingModel:SetModelScale(0.9)
    do
      local _with_0 = vgui.Create('DComboBox', self)
      self.seqButton = _with_0
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
  UpdateAttachsIDs = function(self)
    if self.trackBoneName ~= '' then
      self.trackBone = self.model:LookupBone(self.trackBoneName) or -1
    end
    if self.trackAttachName ~= '' then
      self.trackAttach = self.model:LookupAttachment(self.trackAttachName) or -1
    end
  end,
  GetTrackedPosition = function(self)
    if self.shouldAutoTrack then
      return self.lautoTrackPos
    end
    return self.targetPos
  end,
  UpdateSeqButtonsPos = function(self, inMenus)
    if inMenus == nil then
      inMenus = self:InMenu2()
    end
    if inMenus then
      local bX, bY = self:GetSize()
      local bW, bH = 0, 0
      bX = bX - ScreenScale(6)
      bY = ScreenScale(4)
      if IsValid(self.backButton) then
        bX, bY = self.backButton:GetPos()
      end
      if IsValid(self.backButton) then
        bW, bH = self.backButton:GetSize()
      end
      local w, h = self:GetSize()
      local W, H = self.seqButton:GetSize()
      self.seqButton:SetPos(w - ScreenScale(6) - W, bY + bH + ScreenScale(8))
      W, H = self.emotesPanel:GetSize()
      return self.emotesPanel:SetPos(w - ScreenScale(6) - W, bY + bH + ScreenScale(8) + 30)
    else
      self.seqButton:SetPos(10, 10)
      return self.emotesPanel:SetPos(10, 40)
    end
  end,
  PerformLayout = function(self, w, h)
    if w == nil then
      w = 0
    end
    if h == nil then
      h = 0
    end
    if IsValid(self.lastVisibleMenu) and self.lastVisibleMenu:IsVisible() then
      self:UpdateSeqButtonsPos(true)
      local x, y = self:GetPos()
      local W, H = self:GetSize()
      local width = ScreenScale(120)
      do
        local _with_0 = self.lastVisibleMenu
        _with_0:SetPos(x, y)
        _with_0:SetSize(width, H)
        return _with_0
      end
    else
      return self:UpdateSeqButtonsPos(self:InMenu2())
    end
  end,
  OnMousePressed = function(self, code)
    if code == nil then
      code = MOUSE_LEFT
    end
    if code == MOUSE_LEFT and self.canHold then
      if not self.selectPoint then
        self.hold = true
        self:SetCursor('sizeall')
        self.holdLast = RealTimeL() + .1
        self.mouseX, self.mouseY = gui.MousePos()
      else
        self.holdOnPoint = true
        return self:SetCursor('crosshair')
      end
    elseif code == MOUSE_RIGHT then
      self.holdRightClick = true
    end
  end,
  OnMouseReleased = function(self, code)
    if code == nil then
      code = MOUSE_LEFT
    end
    if code == MOUSE_LEFT and self.canHold then
      self.holdOnPoint = false
      self:SetCursor('none')
      if not self.selectPoint then
        self.hold = false
      else
        return self:PushMenu(self.selectPoint.linkTable)
      end
    elseif code == MOUSE_RIGHT then
      self.holdRightClick = false
    end
  end,
  SetController = function(self, val)
    self.controller = val
  end,
  OnMouseWheeled = function(self, wheelDelta)
    if wheelDelta == nil then
      wheelDelta = 0
    end
    if self.canHold then
      self.distToPony = math.clamp(self.distToPony - wheelDelta * 10, 20, 150)
    end
  end,
  GetModel = function(self)
    return self.model
  end,
  GetSequence = function(self)
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
  GetParentTarget = function(self)
    return self.parentTarget
  end,
  SetParentTarget = function(self, val)
    self.parentTarget = val
  end,
  DoUpdate = function(self)
    for _, panel in ipairs(self.updatePanels) do
      if panel:IsValid() then
        panel:DoUpdate()
      end
    end
  end,
  UpdateMenu = function(self, menu, goingToDelete)
    if goingToDelete == nil then
      goingToDelete = false
    end
    if self:InMenu2() and not goingToDelete then
      local x, y = self:GetPos()
      local frame = self:GetParentTarget() or self:GetParent() or self
      local W, H = self:GetSize()
      local width = ScreenScale(120)
      if not self.menuPanelsCache[menu.id] then
        if menu.menus then
          local targetPanel
          do
            local settingsPanel = vgui.Create('DPropertySheet', frame)
            settingsPanel:SetPos(x, y)
            settingsPanel:SetSize(width, H)
            self.menuPanelsCache[menu.id] = settingsPanel
            for menuName, menuPopulate in pairs(menu.menus) do
              do
                local menuPanel = vgui.Create('PPM2SettingsBase', settingsPanel)
                if menu.id == 'saves' then
                  self.saves = settingsPanel
                end
                table.insert(self.updatePanels, menuPanel)
                menuPanel.frame = self.frame
                do
                  local _with_0 = vgui.Create('DLabel', menuPanel)
                  _with_0:Dock(TOP)
                  _with_0:SetFont('PPM2EditorPanelHeaderText')
                  _with_0:SetText(menuName)
                  _with_0:SizeToContents()
                end
                settingsPanel:AddSheet(menuName, menuPanel)
                menuPanel:SetTargetData(self.controllerData)
                if menuName == 'gui.ppm2.editor.tabs.files' then
                  self.saves = menuPanel
                end
                if menuName == 'gui.ppm2.editor.tabs.old_files' then
                  self.savesOld = menuPanel
                end
                menuPanel:Dock(FILL)
                menuPanel.Populate = menuPopulate
                if menu.selectmenu == menuName then
                  targetPanel = menuPanel
                end
              end
            end
            if targetPanel then
              for _, item in ipairs(settingsPanel:GetItems()) do
                if item.Panel == targetPanel then
                  settingsPanel:SetActiveTab(item.Tab)
                end
              end
            end
          end
        else
          do
            local settingsPanel = vgui.Create('PPM2SettingsBase', frame)
            self.menuPanelsCache[menu.id] = settingsPanel
            if menu.id == 'saves' then
              self.saves = settingsPanel
            end
            settingsPanel.frame = self.frame
            table.insert(self.updatePanels, settingsPanel)
            do
              local _with_0 = vgui.Create('DLabel', settingsPanel)
              _with_0:Dock(TOP)
              _with_0:SetFont('PPM2EditorPanelHeaderText')
              _with_0:SetText(menu.name or '<unknown>')
              _with_0:SizeToContents()
            end
            settingsPanel:SetPos(x, y)
            settingsPanel:SetSize(width, H)
            settingsPanel:SetTargetData(self.controllerData)
            settingsPanel.Populate = menu.populate
          end
        end
      end
      do
        local _with_0 = self.menuPanelsCache[menu.id]
        _with_0:SetVisible(true)
        _with_0:SetPos(x, y)
        _with_0:SetSize(width, H)
      end
      self.lastVisibleMenu = self.menuPanelsCache[menu.id]
      return self:UpdateSeqButtonsPos(true)
    elseif IsValid(self.menuPanelsCache[menu.id]) then
      self.menuPanelsCache[menu.id]:SetVisible(false)
      self.seqButton:SetPos(10, 10)
      return self.emotesPanel:SetPos(10, 40)
    end
  end,
  PushMenu = function(self, menu)
    self:UpdateMenu(self.stack[#self.stack], true)
    table.insert(self.stack, menu)
    if not IsValid(self.backButton) then
      do
        local _with_0 = vgui.Create('DButton', self)
        self.backButton = _with_0
        local x, y = self:GetPos()
        local w, h = self:GetSize()
        _with_0:SetText('↩')
        _with_0:SetFont('PPM2BackButton')
        _with_0:SizeToContents()
        local W, H = _with_0:GetSize()
        W = W + ScreenScale(8)
        _with_0:SetSize(W, H)
        _with_0:SetPos(w - ScreenScale(6) - W, ScreenScale(4))
        _with_0.DoClick = function()
          return self:PopMenu()
        end
      end
    end
    self:UpdateMenu(menu)
    self.fixedDistanceToPony = menu.dist
    self.angle = Angle(menu.defang)
    self.distToPony = 90
    return self
  end,
  PopMenu = function(self)
    assert(#self.stack > 1, 'invalid stack size to pop from')
    local _menu = self.stack[#self.stack]
    table.remove(self.stack)
    self:UpdateMenu(_menu, true)
    if #self.stack == 1 and IsValid(self.backButton) then
      self.backButton:Remove()
    end
    local menu = self.stack[#self.stack]
    self:UpdateMenu(menu)
    self.fixedDistanceToPony = menu.dist
    self.angle = Angle(menu.defang)
    self.distToPony = 90
    return self
  end,
  CurrentMenu = function(self)
    return self.stack[#self.stack]
  end,
  InRoot = function(self)
    return #self.stack == 1
  end,
  InSelection = function(self)
    return self:CurrentMenu().type == 'level'
  end,
  InMenu = function(self)
    return self:CurrentMenu().type == 'menu'
  end,
  InMenu2 = function(self)
    return self:CurrentMenu().type == 'menu' or self:CurrentMenu().populate or self:CurrentMenu().menus
  end,
  ResetModel = function(self, ponydata, model)
    if model == nil then
      model = 'models/ppm/player_default_base_new_nj.mdl'
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
      _with_0:SetPos(Vector())
      _with_0:InvalidateBoneCache()
    end
    if IsValid(self.emotesPanel) then
      self.emotesPanel:Remove()
    end
    do
      local _with_0 = PPM2.CreateEmotesPanel(self, self.model, false)
      self.emotesPanel = _with_0
      _with_0:SetPos(10, 40)
      _with_0:SetMouseInputEnabled(true)
      _with_0:SetVisible(true)
    end
    self:UpdateAttachsIDs()
    return self.model
  end,
  Think = function(self)
    local rtime = RealTimeL()
    local delta = rtime - self.lastTick
    self.lastTick = rtime
    local lerp = (delta * 15):min(1)
    if IsValid(self.model) then
      self.model:FrameAdvance(delta * self.animRate)
      self.model:SetPlaybackRate(1)
      self.model:SetPoseParameter('move_x', 1)
      if self.shouldAutoTrack then
        local menu = self:CurrentMenu()
        if menu.getpos then
          self.autoTrackPos = menu.getpos(self.model)
          self.lautoTrackPos = LerpVector(lerp, self.lautoTrackPos, self.autoTrackPos)
        elseif self.trackAttach ~= -1 then
          local Ang, Pos
          do
            local _obj_0 = self.model:GetAttachment(self.trackAttach)
            Ang, Pos = _obj_0.Ang, _obj_0.Pos
          end
          self.autoTrackPos = Pos or Vector()
          self.lautoTrackPos = LerpVector(lerp, self.lautoTrackPos, self.autoTrackPos)
        elseif self.trackBone ~= -1 then
          self.autoTrackPos = self.model:GetBonePosition(self.trackBone) or Vector()
          self.lautoTrackPos = LerpVector(lerp, self.lautoTrackPos, self.autoTrackPos)
        else
          self.shouldAutoTrack = false
        end
      end
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
        local _obj_0 = self.angle
        pitch, yaw, roll = _obj_0.pitch, _obj_0.yaw, _obj_0.roll
      end
      yaw = yaw - (deltaX * .5)
      pitch = math.clamp(pitch - deltaY * .5, -45, 45)
      self.angle = Angle(pitch, yaw % 360, roll)
    end
    self.lfixedDistanceToPony = Lerp(lerp, self.lfixedDistanceToPony, self.fixedDistanceToPony)
    self.ldistToPony = Lerp(lerp, self.ldistToPony, self.distToPony)
    self.vectorPos = Vector(self.lfixedDistanceToPony, 0, 0)
    self.vectorPos:Rotate(self.angle)
    self.lvectorPos = LerpVector(lerp, self.lvectorPos, self.vectorPos)
    self.drawAngle = Angle(-self.angle.p, self.angle.y - 180)
    self.ldrawAngle = LerpAngle(lerp, self.ldrawAngle, self.drawAngle)
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
  WALL_COLOR = Color() - 255,
  FLOOR_COLOR = Color() - 255,
  EMPTY_VECTOR = Vector(),
  WIREFRAME = Material('models/wireframe'),
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
    local drawpos = self.lvectorPos + self:GetTrackedPosition()
    cam.Start3D(drawpos, self.ldrawAngle, self.ldistToPony, x, y, w, h)
    if self.holdRightClick then
      self.model:SetEyeTarget(drawpos)
      local turnpitch, turnyaw = DLib.combat.turnAngle(self.EMPTY_VECTOR, drawpos, Angle())
      if not inRadius(turnyaw, -20, 20) then
        if turnyaw < 0 then
          self.model:SetPoseParameter('head_yaw', turnyaw + 20)
        else
          self.model:SetPoseParameter('head_yaw', turnyaw - 20)
        end
      else
        self.model:SetPoseParameter('head_yaw', 0)
      end
      turnpitch = turnpitch + 2000 / self.lfixedDistanceToPony
      if not inRadius(turnpitch, -10, 0) then
        if turnpitch < 0 then
          self.model:SetPoseParameter('head_pitch', turnpitch + 10)
        else
          self.model:SetPoseParameter('head_pitch', turnpitch)
        end
      else
        self.model:SetPoseParameter('head_pitch', 0)
      end
    else
      self.model:SetEyeTarget(self.EMPTY_VECTOR)
      self.model:SetPoseParameter('head_yaw', 0)
      self.model:SetPoseParameter('head_pitch', 0)
    end
    if ENABLE_FULLBRIGHT:GetBool() then
      render.SuppressEngineLighting(true)
      render.ResetModelLighting(1, 1, 1)
      render.SetColorModulation(1, 1, 1)
    end
    local progression = RealTimeL():progression(self.startAnimStart, self.startAnimEnd)
    local progression2 = RealTimeL():progression(self.startAnimStart2, self.startAnimEnd2)
    if progression2 == 1 then
      self.buildingModel:DrawModel()
    else
      local old = render.EnableClipping(true)
      render.SetBlend(0.2)
      render.MaterialOverride(self.WIREFRAME)
      for layer = -16, 16 do
        render.PushCustomClipPlane(Vector(0, 0, -1), (1 - progression) * 1200 + layer * 9 - 800)
        self.buildingModel:DrawModel()
        render.PopCustomClipPlane()
      end
      render.MaterialOverride()
      render.SetBlend(1)
      render.PushCustomClipPlane(Vector(0, 0, -1), (1 - progression2) * 1200 - 800)
      self.buildingModel:DrawModel()
      render.PopCustomClipPlane()
      render.EnableClipping(old)
    end
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
    local menu = self:CurrentMenu()
    self.drawPoints = false
    local lx, ly = x, y
    self.model:InvalidateBoneCache()
    if type(menu.points) == 'table' then
      self.drawPoints = true
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _, point in ipairs(menu.points) do
          local vecpos = point.getpos(self.model, self.controller:GetPonySize())
          local position = vecpos:ToScreen()
          local _value_0 = {
            position,
            point,
            vecpos:Distance(drawpos)
          }
          _accum_0[_len_0] = _value_0
          _len_0 = _len_0 + 1
        end
        self.pointsData = _accum_0
      end
    elseif self:InMenu() and menu.getpos then
      do
        local _obj_0 = menu.getpos(self.model):ToScreen(drawpos)
        x, y = _obj_0.x, _obj_0.y
      end
      x, y = x - lx, y - ly
    end
    cam.End3D()
    if self.drawPoints then
      local mx, my = gui.MousePos()
      mx, my = mx - lx, my - ly
      local radius = ScreenScale(10)
      local drawnSelected
      local min = 9999
      for _, pointdata in ipairs(self.pointsData) do
        do
          local _obj_0 = pointdata[1]
          x, y = _obj_0.x, _obj_0.y
        end
        x, y = x - lx, y - ly
        pointdata[1].x, pointdata[1].y = x, y
        if inBox(mx, my, x, y, radius, radius) then
          if min > pointdata[3] then
            drawnSelected = pointdata
            min = pointdata[3]
          end
        end
      end
      self.selectPoint = drawnSelected and drawnSelected[2] or false
      for _, pointdata in ipairs(self.pointsData) do
        do
          local _obj_0 = pointdata[1]
          x, y = _obj_0.x, _obj_0.y
        end
        if pointdata == drawnSelected then
          drawCrosshair(x, y, radius, self.crosshairCircleHovered, self.crosshairBoxHovered)
        else
          drawCrosshair(x, y, radius, self.crosshairCircleInactive, self.crosshairBoxInactive)
        end
      end
      if not self.hold and not self.holdOnPoint then
        if drawnSelected then
          return self:SetCursor('hand')
        else
          return self:SetCursor('none')
        end
      end
    else
      self.selectPoint = false
      if self:InMenu() and menu.getpos then
        local radius = ScreenScale(10)
        return drawCrosshair(x, y, radius, self.crosshairCircleSelected, self.crosshairBoxSelected)
      end
    end
  end,
  OnRemove = function(self)
    if IsValid(self.model) then
      self.model:Remove()
    end
    if IsValid(self.buildingModel) then
      self.buildingModel:Remove()
    end
    for _, panel in ipairs(self.menuPanelsCache) do
      if panel:IsValid() then
        panel:Remove()
      end
    end
  end
}
vgui.Register('PPM2Model2Panel', MODEL_BOX_PANEL, 'EditablePanel')
local genEyeMenu
genEyeMenu = function(publicName)
  return function(self)
    self:ScrollPanel()
    self:CheckBox('gui.ppm2.editor.eyes.separate', 'SeparateEyes')
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
    return self:ColorBox("gui.ppm2.editor.eyes." .. tostring(tprefix) .. ".effect", "EyeEffect" .. tostring(publicName))
  end
end
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
local EDIT_TREE = {
  type = 'level',
  name = 'Pony overview',
  dist = 100,
  defang = Angle(-10, -30, 0),
  selectmenu = 'gui.ppm2.editor.tabs.main',
  menus = {
    ['gui.ppm2.editor.tabs.main'] = function(self)
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
    end,
    ['gui.ppm2.editor.tabs.files'] = PPM2.EditorBuildNewFilesPanel,
    ['gui.ppm2.editor.tabs.old_files'] = PPM2.EditorBuildOldFilesPanel,
    ['gui.ppm2.editor.tabs.about'] = function(self)
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
  },
  points = {
    {
      type = 'bone',
      target = 'LrigScull',
      link = 'head_submenu'
    },
    {
      type = 'bone',
      target = 'Lrig_LEG_BL_Femur',
      link = 'cutiemark'
    },
    {
      type = 'bone',
      target = 'Lrig_LEG_BR_Femur',
      link = 'cutiemark'
    },
    {
      type = 'bone',
      target = 'LrigSpine1',
      link = 'spine'
    },
    {
      type = 'bone',
      target = 'Tail03',
      link = 'tail'
    },
    {
      type = 'bone',
      target = 'Lrig_LEG_FL_Metacarpus',
      link = 'legs_submenu'
    },
    {
      type = 'bone',
      target = 'Lrig_LEG_FR_Metacarpus',
      link = 'legs_submenu'
    },
    {
      type = 'bone',
      target = 'Lrig_LEG_BR_LargeCannon',
      link = 'legs_submenu'
    },
    {
      type = 'bone',
      target = 'Lrig_LEG_BL_LargeCannon',
      link = 'legs_submenu'
    }
  },
  children = {
    cutiemark = {
      type = 'menu',
      name = 'gui.ppm2.editor.tabs.cutiemark',
      dist = 30,
      defang = Angle(0, -90, 0),
      populate = function(self)
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
    head_submenu = {
      type = 'level',
      name = 'gui.ppm2.editor.tabs.head',
      dist = 40,
      defang = Angle(-7, -30, 0),
      points = {
        {
          type = 'attach',
          target = 'eyes',
          link = 'eyes'
        },
        {
          type = 'attach',
          target = 'eyes',
          link = 'eyel',
          addvector = Vector(-5, 5, 2)
        },
        {
          type = 'attach',
          target = 'eyes',
          link = 'mane_horn',
          addvector = Vector(-5, 0, 13)
        },
        {
          type = 'attach',
          target = 'eyes',
          link = 'eyer',
          addvector = Vector(-5, -5, 2)
        }
      },
      children = {
        eyes = {
          type = 'menu',
          name = 'gui.ppm2.editor.tabs.eyes',
          dist = 30,
          defang = Angle(-10, 0, 0),
          menus = {
            ['gui.ppm2.editor.tabs.eyes'] = genEyeMenu(''),
            ['gui.ppm2.editor.tabs.face'] = function(self)
              self:ScrollPanel()
              self:ComboBox('gui.ppm2.editor.face.eyelashes', 'EyelashType')
              self:ColorBox('gui.ppm2.editor.face.eyelashes_color', 'EyelashesColor')
              self:ColorBox('gui.ppm2.editor.face.eyebrows_color', 'EyebrowsColor')
              self:CheckBox('gui.ppm2.editor.face.new_muzzle', 'NewMuzzle')
              if ADVANCED_MODE:GetBool() then
                self:Hr()
                self:CheckBox('gui.ppm2.editor.face.inherit.lips', 'LipsColorInherit')
                self:CheckBox('gui.ppm2.editor.face.inherit.nose', 'NoseColorInherit')
                self:ColorBox('gui.ppm2.editor.face.lips', 'LipsColor')
                self:ColorBox('gui.ppm2.editor.face.nose', 'NoseColor')
                self:Hr()
                self:CheckBox('gui.ppm2.editor.face.eyebrows_glow', 'GlowingEyebrows')
                self:NumSlider('gui.ppm2.editor.face.eyebrows_glow_strength', 'EyebrowsGlowStrength', 2)
                self:CheckBox('gui.ppm2.editor.face.eyelashes_separate_phong', 'SeparateEyelashesPhong')
                return PPM2.EditorPhongPanels(self, 'Eyelashes', 'gui.ppm2.editor.face.eyelashes_phong')
              end
            end,
            ['gui.ppm2.editor.tabs.mouth'] = function(self)
              self:CheckBox('gui.ppm2.editor.mouth.fangs', 'Fangs')
              self:CheckBox('gui.ppm2.editor.mouth.alt_fangs', 'AlternativeFangs')
              if ADVANCED_MODE:GetBool() then
                self:NumSlider('gui.ppm2.editor.mouth.fangs', 'FangsStrength', 2)
              end
              self:CheckBox('gui.ppm2.editor.mouth.claw', 'ClawTeeth')
              if ADVANCED_MODE:GetBool() then
                self:NumSlider('gui.ppm2.editor.mouth.claw', 'ClawTeethStrength', 2)
              end
              self:Hr()
              self:ColorBox('gui.ppm2.editor.mouth.teeth', 'TeethColor')
              self:ColorBox('gui.ppm2.editor.mouth.mouth', 'MouthColor')
              self:ColorBox('gui.ppm2.editor.mouth.tongue', 'TongueColor')
              PPM2.EditorPhongPanels(self, 'Teeth', 'gui.ppm2.editor.mouth.teeth_phong')
              PPM2.EditorPhongPanels(self, 'Mouth', 'gui.ppm2.editor.mouth.mouth_phong')
              return PPM2.EditorPhongPanels(self, 'Tongue', 'gui.ppm2.editor.mouth.tongue_phong')
            end
          }
        },
        eyel = {
          type = 'menu',
          name = 'gui.ppm2.editor.tabs.left_eye',
          dist = 20,
          defang = Angle(-7, 30, 0),
          populate = genEyeMenu('Left')
        },
        eyer = {
          type = 'menu',
          name = 'gui.ppm2.editor.tabs.right_eye',
          dist = 20,
          populate = genEyeMenu('Right')
        },
        mane_horn = {
          type = 'level',
          name = 'gui.ppm2.editor.tabs.mane_horn',
          dist = 50,
          defang = Angle(-25, -120, 0),
          points = {
            {
              type = 'attach',
              target = 'eyes',
              link = 'mane',
              addvector = Vector(-15, 0, 14)
            },
            {
              type = 'attach',
              target = 'eyes',
              link = 'horn',
              addvector = Vector(-2, 0, 14)
            },
            {
              type = 'attach',
              target = 'eyes',
              link = 'ears',
              addvector = Vector(-16, -8, 8)
            },
            {
              type = 'attach',
              target = 'eyes',
              link = 'ears',
              addvector = Vector(-16, 8, 8)
            }
          },
          children = {
            mane = {
              type = 'menu',
              name = 'gui.ppm2.editor.tabs.mane',
              defang = Angle(-7, -120, 0),
              menus = {
                ['gui.ppm2.editor.tabs.main'] = function(self)
                  self:ComboBox('gui.ppm2.editor.mane.type', 'ManeTypeNew')
                  self:CheckBox('gui.ppm2.editor.misc.hide_pac3', 'HideManes')
                  self:CheckBox('gui.ppm2.editor.misc.hide_mane', 'HideManesMane')
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
                  self:Hr()
                  for i = 1, ADVANCED_MODE:GetBool() and 6 or 4 do
                    self:ColorBox("gui.ppm2.editor.mane.detail_color" .. tostring(i), "ManeDetailColor" .. tostring(i))
                  end
                end,
                ['gui.ppm2.editor.tabs.details'] = function(self)
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
                end,
                ['gui.ppm2.editor.tabs.url_details'] = function(self)
                  for i = 1, ADVANCED_MODE:GetBool() and 6 or 1 do
                    self:Label("gui.ppm2.editor.url_mane.desc" .. tostring(i))
                    self:URLInput("ManeURL" .. tostring(i))
                    self:ColorBox("gui.ppm2.editor.url_mane.color" .. tostring(i), "ManeURLColor" .. tostring(i))
                    self:Hr()
                  end
                end,
                ['gui.ppm2.editor.tabs.url_separated_details'] = function(self)
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
              }
            },
            ears = {
              type = 'menu',
              name = 'gui.ppm2.editor.tabs.ears',
              defang = Angle(-12, -110, 0),
              populate = function(self)
                self:CheckBox('gui.ppm2.editor.ears.bat', 'BatPonyEars')
                if ADVANCED_MODE:GetBool() then
                  self:NumSlider('gui.ppm2.editor.ears.bat', 'BatPonyEarsStrength', 2)
                end
                if ADVANCED_MODE:GetBool() then
                  return self:NumSlider('gui.ppm2.editor.ears.size', 'EarsSize', 2)
                end
              end
            },
            horn = {
              type = 'menu',
              name = 'gui.ppm2.editor.tabs.horn',
              dist = 30,
              defang = Angle(-13, -20, 0),
              menus = {
                ['gui.ppm2.editor.tabs.main'] = function(self)
                  self:CheckBox('gui.ppm2.editor.horn.separate_color', 'SeparateHorn')
                  self:ColorBox('gui.ppm2.editor.horn.detail_color', 'HornDetailColor')
                  self:CheckBox('gui.ppm2.editor.horn.glowing_detail', 'HornGlow')
                  self:NumSlider('gui.ppm2.editor.horn.glow_strength', 'HornGlowSrength', 2)
                  self:ColorBox('gui.ppm2.editor.horn.color', 'HornColor')
                  self:CheckBox('gui.ppm2.editor.horn.separate_magic_color', 'SeparateMagicColor')
                  self:ColorBox('gui.ppm2.editor.horn.magic', 'HornMagicColor')
                  if ADVANCED_MODE:GetBool() then
                    self:CheckBox('gui.ppm2.editor.horn.separate_phong', 'SeparateHornPhong')
                  end
                  if ADVANCED_MODE:GetBool() then
                    return PPM2.EditorPhongPanels(self, 'Horn', 'gui.ppm2.editor.horn.horn_phong')
                  end
                end,
                ['gui.ppm2.editor.tabs.details'] = function(self)
                  for i = 1, 3 do
                    self:Label('gui.ppm2.editor.horn.detail.desc' .. i)
                    self:URLInput("HornURL" .. tostring(i))
                    self:ColorBox('gui.ppm2.editor.horn.detail.color' .. i, "HornURLColor" .. tostring(i))
                    self:Hr()
                  end
                end
              }
            }
          }
        }
      }
    },
    spine = {
      type = 'level',
      name = 'gui.ppm2.editor.tabs.back',
      dist = 80,
      defang = Angle(-30, -90, 0),
      points = {
        {
          type = 'bone',
          target = 'LrigSpine1',
          link = 'overall_body'
        },
        {
          type = 'bone',
          target = 'LrigNeck2',
          link = 'neck'
        },
        {
          type = 'bone',
          target = 'wing_l',
          link = 'wings'
        },
        {
          type = 'bone',
          target = 'wing_r',
          link = 'wings'
        }
      },
      children = {
        wings = {
          type = 'menu',
          name = 'gui.ppm2.editor.tabs.wings',
          dist = 40,
          defang = Angle(-12, -30, 0),
          menus = {
            ['gui.ppm2.editor.tabs.main'] = function(self)
              self:CheckBox('gui.ppm2.editor.wings.separate_color', 'SeparateWings')
              self:ColorBox('gui.ppm2.editor.wings.color', 'WingsColor')
              if ADVANCED_MODE:GetBool() then
                self:CheckBox('gui.ppm2.editor.wings.separate_phong', 'SeparateWingsPhong')
              end
              self:Hr()
              self:ColorBox('gui.ppm2.editor.wings.bat_color', 'BatWingColor')
              self:ColorBox('gui.ppm2.editor.wings.bat_skin_color', 'BatWingSkinColor')
              if ADVANCED_MODE:GetBool() then
                return PPM2.EditorPhongPanels(self, 'BatWingsSkin', 'gui.ppm2.editor.wings.bat_skin_phong')
              end
            end,
            ['gui.ppm2.editor.tabs.left'] = function(self)
              self:NumSlider('gui.ppm2.editor.wings.left.size', 'LWingSize', 2)
              self:NumSlider('gui.ppm2.editor.wings.left.fwd', 'LWingX', 2)
              self:NumSlider('gui.ppm2.editor.wings.left.up', 'LWingY', 2)
              return self:NumSlider('gui.ppm2.editor.wings.left.inside', 'LWingZ', 2)
            end,
            ['gui.ppm2.editor.tabs.right'] = function(self)
              self:NumSlider('gui.ppm2.editor.wings.right.size', 'RWingSize', 2)
              self:NumSlider('gui.ppm2.editor.wings.right.fwd', 'RWingX', 2)
              self:NumSlider('gui.ppm2.editor.wings.right.up', 'RWingY', 2)
              return self:NumSlider('gui.ppm2.editor.wings.right.inside', 'RWingZ', 2)
            end,
            ['gui.ppm2.editor.tabs.details'] = function(self)
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
          }
        },
        neck = {
          type = 'menu',
          name = 'gui.ppm2.editor.tabs.neck',
          dist = 40,
          defang = Angle(-7, -15, 0),
          populate = function(self)
            return self:NumSlider('gui.ppm2.editor.neck.height', 'NeckSize', 2)
          end
        },
        overall_body = {
          type = 'menu',
          name = 'gui.ppm2.editor.tabs.body',
          dist = 90,
          defang = Angle(-3, -90, 0),
          menus = {
            ['gui.ppm2.editor.tabs.main'] = function(self)
              self:ComboBox('gui.ppm2.editor.body.suit', 'Bodysuit')
              return self:ColorBox('gui.ppm2.editor.body.color', 'BodyColor')
            end,
            ['gui.ppm2.editor.tabs.back'] = function(self)
              return self:NumSlider('gui.ppm2.editor.body.spine_length', 'BackSize', 2)
            end,
            ['gui.ppm2.editor.tabs.details'] = function(self)
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
            end,
            ['gui.ppm2.editor.tabs.tattoos'] = function(self)
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
          }
        }
      }
    },
    tail = {
      type = 'menu',
      name = 'gui.ppm2.editor.tabs.tail',
      dist = 50,
      defang = Angle(-10, -90, 0),
      menus = {
        ['gui.ppm2.editor.tabs.main'] = function(self)
          self:ComboBox('gui.ppm2.editor.tail.type', 'TailTypeNew')
          self:CheckBox('gui.ppm2.editor.misc.hide_pac3', 'HideManes')
          self:CheckBox('gui.ppm2.editor.misc.hide_tail', 'HideManesTail')
          self:NumSlider('gui.ppm2.editor.tail.size', 'TailSize', 2)
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
            self:ColorBox('gui.ppm2.editor.tail.detail' .. i, "TailDetailColor" .. tostring(i))
          end
        end,
        ['gui.ppm2.editor.tabs.details'] = function(self)
          for i = 1, ADVANCED_MODE:GetBool() and 6 or 1 do
            self:Hr()
            self:Label('gui.ppm2.editor.tail.url.detail' .. i)
            self:URLInput("TailURL" .. tostring(i))
            self:ColorBox('gui.ppm2.editor.tail.url.color' .. i, "TailURLColor" .. tostring(i))
          end
        end
      }
    },
    legs_submenu = {
      type = 'level',
      name = 'gui.ppm2.editor.tabs.hooves',
      dist = 50,
      defang = Angle(-10, -50, 0),
      points = {
        {
          type = 'bone',
          target = 'Lrig_LEG_BR_RearHoof',
          link = 'bottom_hoof'
        },
        {
          type = 'bone',
          target = 'Lrig_LEG_BL_RearHoof',
          link = 'bottom_hoof',
          defang = Angle(0, 90, 0)
        },
        {
          type = 'bone',
          target = 'Lrig_LEG_FL_FrontHoof',
          link = 'bottom_hoof',
          defang = Angle(0, 90, 0)
        },
        {
          type = 'bone',
          target = 'Lrig_LEG_FR_FrontHoof',
          link = 'bottom_hoof'
        },
        {
          type = 'bone',
          target = 'Lrig_LEG_FL_Metacarpus',
          link = 'legs_generic',
          defang = Angle(0, 90, 0)
        },
        {
          type = 'bone',
          target = 'Lrig_LEG_FR_Metacarpus',
          link = 'legs_generic'
        },
        {
          type = 'bone',
          target = 'Lrig_LEG_BR_LargeCannon',
          link = 'legs_generic'
        },
        {
          type = 'bone',
          target = 'Lrig_LEG_BL_LargeCannon',
          link = 'legs_generic',
          defang = Angle(0, 90, 0)
        }
      },
      children = {
        bottom_hoof = {
          type = 'menu',
          name = 'gui.ppm2.editor.tabs.bottom_hoof',
          dist = 30,
          defang = Angle(0, -90, 0),
          populate = function(self)
            self:CheckBox('gui.ppm2.editor.hoof.fluffers', 'HoofFluffers')
            self:NumSlider('gui.ppm2.editor.hoof.fluffers', 'HoofFluffersStrength', 2)
            self:Hr()
            self:CheckBox('gui.ppm2.editor.body.disable_hoofsteps', 'DisableHoofsteps')
            self:CheckBox('gui.ppm2.editor.body.disable_wander_sounds', 'DisableWanderSounds')
            self:CheckBox('gui.ppm2.editor.body.disable_new_step_sounds', 'DisableStepSounds')
            self:CheckBox('gui.ppm2.editor.body.disable_jump_sound', 'DisableJumpSound')
            self:CheckBox('gui.ppm2.editor.body.disable_falldown_sound', 'DisableFalldownSound')
            self:Hr()
            self:CheckBox('gui.ppm2.editor.body.call_playerfootstep', 'CallPlayerFootstepHook')
            return self:Label('gui.ppm2.editor.body.call_playerfootstep_desc')
          end
        },
        legs_generic = {
          type = 'menu',
          name = 'gui.ppm2.editor.tabs.legs',
          dist = 30,
          defang = Angle(0, -90, 0),
          menus = {
            ['gui.ppm2.editor.tabs.main'] = function(self)
              self:CheckBox('gui.ppm2.editor.misc.hide_pac3', 'HideManes')
              self:CheckBox('gui.ppm2.editor.misc.hide_socks', 'HideManesSocks')
              return self:NumSlider('gui.ppm2.editor.legs.height', 'LegsSize', 2)
            end,
            ['gui.ppm2.editor.tabs.socks'] = function(self)
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
                self:Hr()
                for i = 1, 6 do
                  self:ColorBox('gui.ppm2.editor.legs.socks.color' .. i, 'SocksDetailColor' .. i)
                end
              end
            end,
            ['gui.ppm2.editor.tabs.newsocks'] = function(self)
              self:CheckBox('gui.ppm2.editor.legs.newsocks.model', 'SocksAsNewModel')
              self:ColorBox('gui.ppm2.editor.legs.newsocks.color1', 'NewSocksColor1')
              self:ColorBox('gui.ppm2.editor.legs.newsocks.color1', 'NewSocksColor2')
              self:ColorBox('gui.ppm2.editor.legs.newsocks.color1', 'NewSocksColor3')
              if ADVANCED_MODE:GetBool() then
                self:Label('gui.ppm2.editor.legs.newsocks.url')
                return self:URLInput('NewSocksTextureURL')
              end
            end
          }
        }
      }
    }
  }
}
local patchSubtree
patchSubtree = function(node)
  if type(node.children) == 'table' then
    for childID, child in pairs(node.children) do
      child.id = childID
      child.defang = child.defang or Angle(node.defang)
      child.dist = child.dist or node.dist
      patchSubtree(child)
    end
  end
  if type(node.points) == 'table' then
    for _, point in ipairs(node.points) do
      point.addvector = point.addvector or Vector()
      local _exp_0 = point.type
      if 'point' == _exp_0 then
        point.getpos = function(self)
          return Vector(point.target)
        end
      elseif 'bone' == _exp_0 then
        point.getpos = function(self, ponysize)
          if ponysize == nil then
            ponysize = 1
          end
          if not point.targetID or point.targetID == -1 then
            point.targetID = self:LookupBone(point.target) or -1
          end
          if point.targetID == -1 then
            return point.addvector * ponysize
          else
            return self:GetBonePosition(point.targetID) + point.addvector * ponysize
          end
        end
      elseif 'attach' == _exp_0 then
        point.getpos = function(self, ponysize)
          if ponysize == nil then
            ponysize = 1
          end
          if not point.targetID or point.targetID == -1 then
            point.targetID = self:LookupAttachment(point.target) or -1
          end
          if point.targetID == -1 then
            return point.addvector * ponysize
          else
            local Pos, Ang
            do
              local _obj_0 = self:GetAttachment(point.targetID)
              Pos, Ang = _obj_0.Pos, _obj_0.Ang
            end
            return Pos and (Pos + point.addvector * ponysize) or point.addvector * ponysize
          end
        end
      end
      if type(node.children) == 'table' then
        point.linkTable = table.Copy(node.children[point.link])
        if type(point.linkTable) == 'table' then
          point.linkTable.getpos = point.getpos
          if point.defang then
            point.linkTable.defang = Angle(point.defang)
          end
        else
          PPM2.Message('Editor3: Missing submenu ' .. point.link .. ' of ' .. node.id .. '!')
        end
      end
    end
  end
end
EDIT_TREE.id = 'root'
patchSubtree(EDIT_TREE)
if IsValid(PPM2.EDITOR3) then
  PPM2.EDITOR3:Remove()
  net.Start('PPM2.EditorStatus')
  net.WriteBool(false)
  net.SendToServer()
end
local ppm2_editor3
ppm2_editor3 = function()
  if IsValid(PPM2.EDITOR3) then
    PPM2.EDITOR3:SetVisible(true)
    PPM2.EDITOR3:MakePopup()
    return PPM2.EDITOR3
  end
  PPM2.EDITOR3 = vgui.Create('DLib_Window')
  local self = PPM2.EDITOR3
  self:SetSize(ScrWL(), ScrHL())
  self:SetPos(0, 0)
  self:MakePopup()
  self:SetDraggable(false)
  self:RemoveResize()
  self:SetDeleteOnClose(false)
  do
    local _with_0 = vgui.Create('PPM2Model2Panel', self)
    self.modelPanel = _with_0
    _with_0:Dock(FILL)
    _with_0:DockMargin(3, 3, 3, 3)
  end
  local copy = PPM2.GetMainData():Copy()
  local ply = LocalPlayer()
  local ent = self.modelPanel:ResetModel()
  self.data = copy
  local controller = copy:CreateCustomController(ent)
  controller:SetFlexLerpMultiplier(1.3)
  copy:SetController(controller)
  self.controller = controller
  self.modelPanel:SetController(controller)
  controller:SetupEntity(ent)
  controller:SetDisableTask(true)
  self.modelPanel.frame = self
  self.modelPanel.stack = {
    EDIT_TREE
  }
  self.modelPanel:SetParentTarget(self)
  self.modelPanel.controllerData = copy
  self.modelPanel:UpdateMenu(self.modelPanel:CurrentMenu())
  self:SetTitle('gui.ppm2.editor.generic.title_file', copy:GetFilename() or '%ERRNAME%')
  PPM2.EditorCreateTopButtons(self, true, true)
  self.saves = self.modelPanel.saves
  self.savesOld = self.modelPanel.savesOld
  self.DoUpdate = function()
    return self.modelPanel:DoUpdate()
  end
  self.OnClose = function()
    net.Start('PPM2.EditorStatus')
    net.WriteBool(false)
    return net.SendToServer()
  end
  net.Start('PPM2.EditorStatus')
  net.WriteBool(true)
  net.SendToServer()
  if not file.Exists('ppm2_intro.txt', 'DATA') then
    file.Write('ppm2_intro.txt', '')
    return Derma_Message('gui.ppm2.editor.intro.text', 'gui.ppm2.editor.intro.title', 'gui.ppm2.editor.intro.okay')
  end
end
concommand.Add('ppm2_editor3', ppm2_editor3)
local IconData3 = {
  title = 'PPM/2 Editor/3',
  icon = 'gui/ppm2_icon.png',
  width = 960,
  height = 700,
  onewindow = true,
  init = function(icon, window)
    window:Remove()
    return ppm2_editor3()
  end
}
list.Set('DesktopWindows', 'PPM2_E3', IconData3)
if IsValid(g_ContextMenu) then
  return CreateContextMenu()
end
