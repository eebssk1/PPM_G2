local _M = PPM2.MaterialsRegistry
local USE_HIGHRES_BODY = PPM2.USE_HIGHRES_BODY
local USE_HIGHRES_TEXTURES = PPM2.USE_HIGHRES_TEXTURES
PPM2.REAL_TIME_EYE_REFLECTIONS = CreateConVar('ppm2_cl_reflections', '0', {
  FCVAR_ACRHIVE
}, 'Calculate eye reflections in real time. Needs beefy computer.')
local REAL_TIME_EYE_REFLECTIONS = PPM2.REAL_TIME_EYE_REFLECTIONS
PPM2.REAL_TIME_EYE_REFLECTIONS_SIZE = CreateConVar('ppm2_cl_reflections_size', '512', {
  FCVAR_ACRHIVE
}, 'Reflections size. Must be multiple to 2! (16, 32, 64, 128, 256)')
local REAL_TIME_EYE_REFLECTIONS_SIZE = PPM2.REAL_TIME_EYE_REFLECTIONS_SIZE
PPM2.REAL_TIME_EYE_REFLECTIONS_DIST = CreateConVar('ppm2_cl_reflections_drawdist', '192', {
  FCVAR_ACRHIVE
}, 'Reflections maximal draw distance')
local REAL_TIME_EYE_REFLECTIONS_DIST = PPM2.REAL_TIME_EYE_REFLECTIONS_DIST
PPM2.REAL_TIME_EYE_REFLECTIONS_RDIST = CreateConVar('ppm2_cl_reflections_renderdist', '1000', {
  FCVAR_ACRHIVE
}, 'Reflection scene draw distance (ZFar)')
local REAL_TIME_EYE_REFLECTIONS_RDIST = PPM2.REAL_TIME_EYE_REFLECTIONS_RDIST
local lastReflectionFrame = 0
hook.Remove('DrawOverlay', 'PPM2.ReflectionsUpdate')
hook.Add('PreRender', 'PPM2.ReflectionsUpdate', function(a, b)
  if PPM2.__RENDERING_REFLECTIONS then
    return 
  end
  if lastReflectionFrame == FrameNumberL() then
    return 
  end
  lastReflectionFrame = FrameNumberL()
  PPM2.__RENDERING_REFLECTIONS = true
  for i, task in ipairs(PPM2.NetworkedPonyData.CheckTasks) do
    if task.GetRenderController then
      do
        local render = task:GetRenderController()
        if render then
          do
            local textures = render:GetTextureController()
            if textures then
              ProtectedCall(textures.CheckReflectionsClosure)
            end
          end
        end
      end
    end
  end
  PPM2.__RENDERING_REFLECTIONS = false
end)
hook.Add('PreDrawEffects', 'PPM2.ReflectionsUpdate', (function()
  if PPM2.__RENDERING_REFLECTIONS then
    return true
  end
end), -10)
hook.Add('PostDrawEffects', 'PPM2.ReflectionsUpdate', (function()
  if PPM2.__RENDERING_REFLECTIONS then
    return true
  end
end), -10)
hook.Add('PreDrawHalos', 'PPM2.ReflectionsUpdate', (function()
  if PPM2.__RENDERING_REFLECTIONS then
    return true
  end
end), -10)
hook.Add('PostDrawHalos', 'PPM2.ReflectionsUpdate', (function()
  if PPM2.__RENDERING_REFLECTIONS then
    return true
  end
end), -10)
hook.Add('PreDrawOpaqueRenderables', 'PPM2.ReflectionsUpdate', (function()
  if PPM2.__RENDERING_REFLECTIONS then
    return false
  end
end), -10)
hook.Add('PostDrawOpaqueRenderables', 'PPM2.ReflectionsUpdate', (function()
  if PPM2.__RENDERING_REFLECTIONS then
    return false
  end
end), -10)
hook.Add('PreDrawTranslucentRenderables', 'PPM2.ReflectionsUpdate', (function()
  if PPM2.__RENDERING_REFLECTIONS then
    return false
  end
end), -10)
hook.Add('PostDrawTranslucentRenderables', 'PPM2.ReflectionsUpdate', (function()
  if PPM2.__RENDERING_REFLECTIONS then
    return false
  end
end), -10)
local mat_picmip = GetConVar('mat_picmip')
local RT_SIZES
do
  local _accum_0 = { }
  local _len_0 = 1
  for i = 1, 24 do
    _accum_0[_len_0] = math.pow(2, i)
    _len_0 = _len_0 + 1
  end
  RT_SIZES = _accum_0
end
PPM2.GetTextureQuality = function()
  local mult = 1
  local _exp_0 = math.Clamp(mat_picmip:GetInt(), -2, 2)
  if -2 == _exp_0 then
    mult = mult * 2
  elseif 0 == _exp_0 then
    mult = mult * 0.75
  elseif 1 == _exp_0 then
    mult = mult * 0.5
  elseif 2 == _exp_0 then
    mult = mult * 0.25
  end
  if USE_HIGHRES_TEXTURES:GetBool() then
    mult = mult * 2
  end
  return mult
end
PPM2.GetTextureSize = function(texSize)
  texSize = texSize * PPM2.GetTextureQuality(texSize)
  local delta = 9999
  local nsize = texSize
  for _, size in ipairs(RT_SIZES) do
    local ndelta = math.abs(size - texSize)
    if ndelta < delta then
      delta = ndelta
      nsize = size
    end
  end
  return nsize
end
local DrawTexturedRectRotated
DrawTexturedRectRotated = function(x, y, width, height, rotation)
  if x == nil then
    x = 0
  end
  if y == nil then
    y = 0
  end
  if width == nil then
    width = 0
  end
  if height == nil then
    height = 0
  end
  if rotation == nil then
    rotation = 0
  end
  return surface.DrawTexturedRectRotated(x + width / 2, y + height / 2, width, height, rotation)
end
local PonyTextureController
do
  local _class_0
  local _parent_0 = PPM2.ControllerChildren
  local _base_0 = {
    DelayCompile = function(self, func, ...)
      if func == nil then
        func = ''
      end
      if not self[func] then
        return 
      end
      local args = {
        ...
      }
      for i, val in ipairs(self.__class.COMPILE_QUEUE) do
        if val.func == func and val.self == self then
          val.args = args
          return 
        end
      end
      return table.insert(self.__class.COMPILE_QUEUE, {
        self = self,
        func = func,
        args = args,
        run = self[func]
      })
    end,
    DataChanges = function(self, state)
      if not (self.isValid) then
        return 
      end
      if not self:GetEntity() then
        return 
      end
      local key = state:GetKey()
      if key:find('Separate') and key:find('Phong') then
        self:UpdatePhongData()
        return 
      end
      local _exp_0 = key
      if 'BodyColor' == _exp_0 then
        self:DelayCompile('CompileBody')
        self:DelayCompile('CompileWings')
        return self:DelayCompile('CompileHorn')
      elseif 'EyelashesColor' == _exp_0 then
        return self:DelayCompile('CompileEyelashes')
      elseif 'Socks' == _exp_0 or 'Bodysuit' == _exp_0 or 'LipsColor' == _exp_0 or 'NoseColor' == _exp_0 or 'LipsColorInherit' == _exp_0 or 'NoseColorInherit' == _exp_0 or 'EyebrowsColor' == _exp_0 or 'GlowingEyebrows' == _exp_0 or 'EyebrowsGlowStrength' == _exp_0 then
        return self:DelayCompile('CompileBody')
      elseif 'CMark' == _exp_0 or 'CMarkType' == _exp_0 or 'CMarkURL' == _exp_0 or 'CMarkColor' == _exp_0 or 'CMarkSize' == _exp_0 then
        return self:DelayCompile('CompileCMark')
      elseif 'SocksColor' == _exp_0 or 'SocksTextureURL' == _exp_0 or 'SocksTexture' == _exp_0 or 'SocksDetailColor1' == _exp_0 or 'SocksDetailColor2' == _exp_0 or 'SocksDetailColor3' == _exp_0 or 'SocksDetailColor4' == _exp_0 or 'SocksDetailColor5' == _exp_0 or 'SocksDetailColor6' == _exp_0 then
        return self:DelayCompile('CompileSocks')
      elseif 'NewSocksColor1' == _exp_0 or 'NewSocksColor2' == _exp_0 or 'NewSocksColor3' == _exp_0 or 'NewSocksTextureURL' == _exp_0 then
        return self:DelayCompile('CompileNewSocks')
      elseif 'HornURL1' == _exp_0 or 'SeparateHorn' == _exp_0 or 'HornColor' == _exp_0 or 'HornURL2' == _exp_0 or 'HornURL3' == _exp_0 or 'HornURLColor1' == _exp_0 or 'HornURLColor2' == _exp_0 or 'HornURLColor3' == _exp_0 or 'UseHornDetail' == _exp_0 or 'HornGlow' == _exp_0 or 'HornGlowSrength' == _exp_0 or 'HornDetailColor' == _exp_0 then
        return self:DelayCompile('CompileHorn')
      elseif 'WingsURL1' == _exp_0 or 'WingsURL2' == _exp_0 or 'WingsURL3' == _exp_0 or 'WingsURLColor1' == _exp_0 or 'WingsURLColor2' == _exp_0 or 'WingsURLColor3' == _exp_0 or 'SeparateWings' == _exp_0 or 'WingsColor' == _exp_0 then
        return self:DelayCompile('CompileWings')
      else
        if self.__class.MANE_UPDATE_TRIGGER[key] then
          return self:DelayCompile('CompileHair')
        elseif self.__class.TAIL_UPDATE_TRIGGER[key] then
          return self:DelayCompile('CompileTail')
        elseif self.__class.EYE_UPDATE_TRIGGER[key] then
          self:DelayCompile('CompileLeftEye')
          return self:DelayCompile('CompileRightEye')
        elseif self.__class.BODY_UPDATE_TRIGGER[key] then
          return self:DelayCompile('CompileBody')
        elseif self.__class.PHONG_UPDATE_TRIGGER[key] then
          return self:UpdatePhongData()
        end
      end
    end,
    Remove = function(self)
      self.isValid = false
      return self:ResetTextures()
    end,
    IsValid = function(self)
      return IsValid(self:GetEntity()) and self.isValid and self.compiled and self:GetData():IsValid()
    end,
    GetID = function(self)
      if self:GetObjectSlot() then
        return self:GetObjectSlot()
      end
      if self.clientsideID then
        return self.id
      end
      if self:GetEntity() ~= self.cachedENT then
        self.cachedENT = self:GetEntity()
        self.id = self:GetEntity():EntIndex()
        if self.id == -1 then
          self.id = self.__class.NEXT_GENERATED_ID
          self.__class.NEXT_GENERATED_ID = self.__class.NEXT_GENERATED_ID + 1
          if self.compiled then
            self:CompileTextures()
          end
        end
      end
      return self.id
    end,
    GetBody = function(self)
      return self.BodyMaterial
    end,
    GetBodyName = function(self)
      return self.BodyMaterialName
    end,
    GetSocks = function(self)
      return self.SocksMaterial
    end,
    GetSocksName = function(self)
      return self.SocksMaterialName
    end,
    GetNewSocks = function(self)
      return self.NewSocksColor1, self.NewSocksColor2, self.NewSocksBase
    end,
    GetNewSocksName = function(self)
      return self.NewSocksColor1Name, self.NewSocksColor2Name, self.NewSocksBaseName
    end,
    GetCMark = function(self)
      return self.CMarkTexture
    end,
    GetCMarkName = function(self)
      return self.CMarkTextureName
    end,
    GetGUICMark = function(self)
      return self.CMarkTextureGUI
    end,
    GetGUICMarkName = function(self)
      return self.CMarkTextureGUIName
    end,
    GetCMarkGUI = function(self)
      return self.CMarkTextureGUI
    end,
    GetCMarkGUIName = function(self)
      return self.CMarkTextureGUIName
    end,
    GetHair = function(self, index)
      if index == nil then
        index = 1
      end
      if index == 2 then
        return self.HairColor2Material
      else
        return self.HairColor1Material
      end
    end,
    GetHairName = function(self, index)
      if index == nil then
        index = 1
      end
      if index == 2 then
        return self.HairColor2MaterialName
      else
        return self.HairColor1MaterialName
      end
    end,
    GetMane = function(self, index)
      if index == nil then
        index = 1
      end
      if index == 2 then
        return self.HairColor2Material
      else
        return self.HairColor1Material
      end
    end,
    GetManeName = function(self, index)
      if index == nil then
        index = 1
      end
      if index == 2 then
        return self.HairColor2MaterialName
      else
        return self.HairColor1MaterialName
      end
    end,
    GetTail = function(self, index)
      if index == nil then
        index = 1
      end
      if index == 2 then
        return self.TailColor2Material
      else
        return self.TailColor1Material
      end
    end,
    GetTailName = function(self, index)
      if index == nil then
        index = 1
      end
      if index == 2 then
        return self.TailColor2MaterialName
      else
        return self.TailColor1MaterialName
      end
    end,
    GetEye = function(self, left)
      if left == nil then
        left = false
      end
      if left then
        return self.EyeMaterialL
      else
        return self.EyeMaterialR
      end
    end,
    GetEyeName = function(self, left)
      if left == nil then
        left = false
      end
      if left then
        return self.EyeMaterialLName
      else
        return self.EyeMaterialRName
      end
    end,
    GetHorn = function(self)
      return self.HornMaterial
    end,
    GetHornName = function(self)
      return self.HornMaterialName
    end,
    GetWings = function(self)
      return self.WingsMaterial
    end,
    GetWingsName = function(self)
      return self.WingsMaterialName
    end,
    CompileTextures = function(self)
      if not self:GetData():IsValid() then
        return 
      end
      self:DelayCompile('CompileBody')
      self:DelayCompile('CompileHair')
      self:DelayCompile('CompileTail')
      self:DelayCompile('CompileHorn')
      self:DelayCompile('CompileWings')
      self:DelayCompile('CompileCMark')
      self:DelayCompile('CompileSocks')
      self:DelayCompile('CompileNewSocks')
      self:DelayCompile('CompileEyelashes')
      self:DelayCompile('CompileLeftEye')
      self:DelayCompile('CompileRightEye')
      self.compiled = true
    end,
    StartRT = function(self, name, texSize, r, g, b, a)
      if r == nil then
        r = 0
      end
      if g == nil then
        g = 0
      end
      if b == nil then
        b = 0
      end
      if a == nil then
        a = 255
      end
      if self.currentRT then
        error('Attempt to start new render target without finishing the old one!\nUPCOMING =======' .. debug.traceback() .. '\nCURRENT =======' .. self.currentRTTrace)
      end
      self.currentRTTrace = debug.traceback()
      self.oldW, self.oldH = ScrW(), ScrH()
      local rt = GetRenderTarget("PPM2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(self:GetID()) .. "_" .. tostring(name) .. "_" .. tostring(texSize), texSize, texSize, false)
      rt:Download()
      render.PushRenderTarget(rt)
      render.Clear(r, g, b, a, true, true)
      surface.DisableClipping(true)
      render.PushFilterMin(TEXFILTER.ANISOTROPIC)
      render.PushFilterMag(TEXFILTER.ANISOTROPIC)
      cam.Start2D()
      cam.PushModelMatrix(Matrix())
      surface.SetDrawColor(r, g, b, a)
      surface.DrawRect(0, 0, texSize, texSize)
      self.currentRT = rt
      return rt
    end,
    StartRTOpaque = function(self, name, texSize, r, g, b, a)
      if r == nil then
        r = 0
      end
      if g == nil then
        g = 0
      end
      if b == nil then
        b = 0
      end
      if a == nil then
        a = 255
      end
      if self.__class.RT_BUFFER_BROKEN then
        return self:StartRT(name, texSize, r, g, b, a)
      end
      if self.currentRT then
        error('Attempt to start new render target without finishing the old one!\nUPCOMING =======' .. debug.traceback() .. '\nCURRENT =======' .. self.currentRTTrace)
      end
      self.currentRTTrace = debug.traceback()
      self.oldW, self.oldH = ScrW(), ScrH()
      local textureFlags = 0
      textureFlags = textureFlags + 256
      textureFlags = textureFlags + 2048
      textureFlags = textureFlags + 4096
      textureFlags = textureFlags + 8388608
      textureFlags = textureFlags + 32768
      local rt = GetRenderTargetEx("PPM2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(self:GetID()) .. "_" .. tostring(name) .. "_" .. tostring(texSize) .. "_op", texSize, texSize, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_NONE, textureFlags, 0, IMAGE_FORMAT_RGB888)
      if texSize ~= rt:Width() or texSize ~= rt:Height() then
        PPM2.Message('Your videocard is garbage... I cant even save extra memory for you!')
        PPM2.Message('Switching to fat ass render targets with full buffer')
        self.__class.RT_BUFFER_BROKEN = true
        return self:StartRT(name, texSize, r, g, b, a)
      end
      rt:Download()
      render.PushRenderTarget(rt)
      render.Clear(r, g, b, a, true, true)
      surface.DisableClipping(true)
      render.PushFilterMin(TEXFILTER.ANISOTROPIC)
      render.PushFilterMag(TEXFILTER.ANISOTROPIC)
      cam.Start2D()
      cam.PushModelMatrix(Matrix())
      surface.SetDrawColor(r, g, b, a)
      surface.DrawRect(0, 0, texSize, texSize)
      self.currentRT = rt
      return rt
    end,
    EndRT = function(self)
      cam.PopModelMatrix()
      render.PopFilterMin()
      render.PopFilterMag()
      cam.End2D()
      render.PopRenderTarget()
      surface.DisableClipping(false)
      local rt = self.currentRT
      self.currentRT = nil
      cam.Start3D()
      cam.Start3D2D(Vector(0, 0, 0), Angle(0, 0, 0), 1)
      cam.End3D2D()
      cam.End3D()
      return rt
    end,
    CheckReflections = function(self, ent)
      if ent == nil then
        ent = self:GetEntity()
      end
      if REAL_TIME_EYE_REFLECTIONS:GetBool() then
        self.isInRealTimeLReflections = true
        return self:UpdateEyeReflections()
      elseif self.isInRealTimeLReflections then
        self.isInRealTimeLReflections = false
        return self:ResetEyeReflections()
      end
    end,
    PreDraw = function(self, ent, drawingNewTask)
      if ent == nil then
        ent = self:GetEntity()
      end
      if drawingNewTask == nil then
        drawingNewTask = false
      end
      if not (self.isValid) then
        return 
      end
      if self.lastMaterialUpdate < RealTimeL() or self.lastMaterialUpdateEnt ~= ent then
        self.lastMaterialUpdateEnt = ent
        self.lastMaterialUpdate = RealTimeL() + 1
        ent:SetSubMaterial(self.__class.MAT_INDEX_EYE_LEFT, self:GetEyeName(true))
        ent:SetSubMaterial(self.__class.MAT_INDEX_EYE_RIGHT, self:GetEyeName(false))
        ent:SetSubMaterial(self.__class.MAT_INDEX_BODY, self:GetBodyName())
        ent:SetSubMaterial(self.__class.MAT_INDEX_HORN, self:GetHornName())
        ent:SetSubMaterial(self.__class.MAT_INDEX_WINGS, self:GetWingsName())
        ent:SetSubMaterial(self.__class.MAT_INDEX_HAIR_COLOR1, self:GetHairName(1))
        ent:SetSubMaterial(self.__class.MAT_INDEX_HAIR_COLOR2, self:GetHairName(2))
        ent:SetSubMaterial(self.__class.MAT_INDEX_TAIL_COLOR1, self:GetTailName(1))
        ent:SetSubMaterial(self.__class.MAT_INDEX_TAIL_COLOR2, self:GetTailName(2))
        ent:SetSubMaterial(self.__class.MAT_INDEX_CMARK, self:GetCMarkName())
        ent:SetSubMaterial(self.__class.MAT_INDEX_EYELASHES, self.EyelashesName)
      end
      if drawingNewTask then
        render.MaterialOverrideByIndex(self.__class.MAT_INDEX_EYE_LEFT, self:GetEye(true))
        render.MaterialOverrideByIndex(self.__class.MAT_INDEX_EYE_RIGHT, self:GetEye(false))
        render.MaterialOverrideByIndex(self.__class.MAT_INDEX_BODY, self:GetBody())
        render.MaterialOverrideByIndex(self.__class.MAT_INDEX_HORN, self:GetHorn())
        render.MaterialOverrideByIndex(self.__class.MAT_INDEX_WINGS, self:GetWings())
        render.MaterialOverrideByIndex(self.__class.MAT_INDEX_HAIR_COLOR1, self:GetHair(1))
        render.MaterialOverrideByIndex(self.__class.MAT_INDEX_HAIR_COLOR2, self:GetHair(2))
        render.MaterialOverrideByIndex(self.__class.MAT_INDEX_TAIL_COLOR1, self:GetTail(1))
        render.MaterialOverrideByIndex(self.__class.MAT_INDEX_TAIL_COLOR2, self:GetTail(2))
        render.MaterialOverrideByIndex(self.__class.MAT_INDEX_CMARK, self:GetCMark())
        return render.MaterialOverrideByIndex(self.__class.MAT_INDEX_EYELASHES, self.Eyelashes)
      end
    end,
    PostDraw = function(self, ent, drawingNewTask)
      if ent == nil then
        ent = self:GetEntity()
      end
      if drawingNewTask == nil then
        drawingNewTask = false
      end
      if not (self.isValid) then
        return 
      end
      if not (drawingNewTask) then
        return 
      end
      render.MaterialOverrideByIndex(self.__class.MAT_INDEX_EYE_LEFT)
      render.MaterialOverrideByIndex(self.__class.MAT_INDEX_EYE_RIGHT)
      render.MaterialOverrideByIndex(self.__class.MAT_INDEX_BODY)
      render.MaterialOverrideByIndex(self.__class.MAT_INDEX_HORN)
      render.MaterialOverrideByIndex(self.__class.MAT_INDEX_WINGS)
      render.MaterialOverrideByIndex(self.__class.MAT_INDEX_HAIR_COLOR1)
      render.MaterialOverrideByIndex(self.__class.MAT_INDEX_HAIR_COLOR2)
      render.MaterialOverrideByIndex(self.__class.MAT_INDEX_TAIL_COLOR1)
      render.MaterialOverrideByIndex(self.__class.MAT_INDEX_TAIL_COLOR2)
      return render.MaterialOverrideByIndex(self.__class.MAT_INDEX_CMARK)
    end,
    ResetTextures = function(self, ent)
      if ent == nil then
        ent = self:GetEntity()
      end
      if not IsValid(ent) then
        return 
      end
      self.lastMaterialUpdateEnt = NULL
      self.lastMaterialUpdate = 0
      ent:SetSubMaterial(self.__class.MAT_INDEX_EYE_LEFT)
      ent:SetSubMaterial(self.__class.MAT_INDEX_EYE_RIGHT)
      ent:SetSubMaterial(self.__class.MAT_INDEX_BODY)
      ent:SetSubMaterial(self.__class.MAT_INDEX_HORN)
      ent:SetSubMaterial(self.__class.MAT_INDEX_WINGS)
      ent:SetSubMaterial(self.__class.MAT_INDEX_HAIR_COLOR1)
      ent:SetSubMaterial(self.__class.MAT_INDEX_HAIR_COLOR2)
      ent:SetSubMaterial(self.__class.MAT_INDEX_TAIL_COLOR1)
      ent:SetSubMaterial(self.__class.MAT_INDEX_TAIL_COLOR2)
      ent:SetSubMaterial(self.__class.MAT_INDEX_CMARK)
      return ent:SetSubMaterial(self.__class.MAT_INDEX_EYELASHES)
    end,
    PreDrawLegs = function(self, ent)
      if ent == nil then
        ent = self:GetEntity()
      end
      if not (self.isValid) then
        return 
      end
      render.MaterialOverrideByIndex(self.__class.MAT_INDEX_BODY, self:GetBody())
      render.MaterialOverrideByIndex(self.__class.MAT_INDEX_HORN, self:GetHorn())
      render.MaterialOverrideByIndex(self.__class.MAT_INDEX_WINGS, self:GetWings())
      return render.MaterialOverrideByIndex(self.__class.MAT_INDEX_CMARK, self:GetCMark())
    end,
    PostDrawLegs = function(self, ent)
      if ent == nil then
        ent = self:GetEntity()
      end
      if not (self.isValid) then
        return 
      end
      render.MaterialOverrideByIndex(self.__class.MAT_INDEX_BODY)
      render.MaterialOverrideByIndex(self.__class.MAT_INDEX_HORN)
      render.MaterialOverrideByIndex(self.__class.MAT_INDEX_WINGS)
      return render.MaterialOverrideByIndex(self.__class.MAT_INDEX_CMARK)
    end,
    UpdateSocks = function(self, ent, socksEnt)
      if ent == nil then
        ent = self:GetEntity()
      end
      if not (self.isValid) then
        return 
      end
      return socksEnt:SetSubMaterial(self.__class.MAT_INDEX_SOCKS, self:GetSocksName())
    end,
    UpdateNewSocks = function(self, ent, socksEnt)
      if ent == nil then
        ent = self:GetEntity()
      end
      if not (self.isValid) then
        return 
      end
      socksEnt:SetSubMaterial(0, self.NewSocksColor2Name)
      socksEnt:SetSubMaterial(1, self.NewSocksColor1Name)
      return socksEnt:SetSubMaterial(2, self.NewSocksBaseName)
    end,
    DrawTattoo = function(self, index, drawingGlow, texSize)
      if index == nil then
        index = 1
      end
      if drawingGlow == nil then
        drawingGlow = false
      end
      if texSize == nil then
        texSize = self.__class:GetBodySize()
      end
      local mat = _M.TATTOOS[self:GrabData("TattooType" .. tostring(index))]
      if not mat then
        return 
      end
      local X, Y = self:GrabData("TattooPosX" .. tostring(index)), self:GrabData("TattooPosY" .. tostring(index))
      local TattooRotate = self:GrabData("TattooRotate" .. tostring(index))
      local TattooScaleX = self:GrabData("TattooScaleX" .. tostring(index))
      local TattooScaleY = self:GrabData("TattooScaleY" .. tostring(index))
      if not drawingGlow then
        local r, g, b
        do
          local _obj_0 = self:GrabData("TattooColor" .. tostring(index))
          r, g, b = _obj_0.r, _obj_0.g, _obj_0.b
        end
        surface.SetDrawColor(r, g, b)
      else
        if self:GrabData("TattooGlow" .. tostring(index)) then
          surface.SetDrawColor(255, 255, 255, 255 * self:GrabData("TattooGlowStrength" .. tostring(index)))
        else
          surface.SetDrawColor(0, 0, 0)
        end
      end
      surface.SetMaterial(mat)
      local tSize = PPM2.GetTextureSize(self.__class.TATTOO_DEF_SIZE * (USE_HIGHRES_BODY:GetInt() + 1))
      local sizeX, sizeY = tSize * TattooScaleX, tSize * TattooScaleY
      return surface.DrawTexturedRectRotated((X * texSize / 2) / 100 + texSize / 2, -(Y * texSize / 2) / 100 + texSize / 2, sizeX, sizeY, TattooRotate)
    end,
    ApplyPhongData = function(self, matTarget, prefix, lightwarpsOnly, noBump)
      if prefix == nil then
        prefix = 'Body'
      end
      if lightwarpsOnly == nil then
        lightwarpsOnly = false
      end
      if noBump == nil then
        noBump = false
      end
      if not matTarget then
        return 
      end
      local PhongExponent = self:GrabData(prefix .. 'PhongExponent')
      local PhongBoost = self:GrabData(prefix .. 'PhongBoost')
      local PhongTint = self:GrabData(prefix .. 'PhongTint')
      local PhongFront = self:GrabData(prefix .. 'PhongFront')
      local PhongMiddle = self:GrabData(prefix .. 'PhongMiddle')
      local Lightwarp = self:GrabData(prefix .. 'Lightwarp')
      local LightwarpURL = self:GrabData(prefix .. 'LightwarpURL')
      local BumpmapURL = self:GrabData(prefix .. 'BumpmapURL')
      local PhongSliding = self:GrabData(prefix .. 'PhongSliding')
      local r, g, b
      r, g, b = PhongTint.r, PhongTint.g, PhongTint.b
      r = r / 255
      g = g / 255
      b = b / 255
      PhongTint = Vector(r, g, b)
      local PhongFresnel = Vector(PhongFront, PhongMiddle, PhongSliding)
      if not lightwarpsOnly then
        do
          matTarget:SetFloat('$phongexponent', PhongExponent)
          matTarget:SetFloat('$phongboost', PhongBoost)
          matTarget:SetVector('$phongtint', PhongTint)
          matTarget:SetVector('$phongfresnelranges', PhongFresnel)
        end
      end
      if LightwarpURL == '' or not LightwarpURL:find('^https?://') then
        local myTex = PPM2.AvaliableLightwarpsPaths[Lightwarp + 1] or PPM2.AvaliableLightwarpsPaths[1]
        matTarget:SetTexture('$lightwarptexture', myTex)
      else
        self.__class:LoadURL(LightwarpURL, 256, 16, function(tex, panel, mat)
          return matTarget:SetTexture('$lightwarptexture', tex)
        end)
      end
      if not noBump then
        if BumpmapURL == '' or not BumpmapURL:find('^https?://') then
          return matTarget:SetUndefined('$bumpmap')
        else
          return self.__class:LoadURL(BumpmapURL, matTarget:Width(), matTarget:Height(), function(tex, panel, mat)
            return matTarget:SetTexture('$bumpmap', tex)
          end)
        end
      end
    end,
    GetBodyPhongMaterials = function(self, output)
      if output == nil then
        output = { }
      end
      if self.BodyMaterial then
        table.insert(output, {
          self.BodyMaterial,
          false,
          false
        })
      end
      if self.HornMaterial and not self:GrabData('SeparateHornPhong') then
        table.insert(output, {
          self.HornMaterial,
          false,
          true
        })
      end
      if self.WingsMaterial and not self:GrabData('SeparateWingsPhong') then
        table.insert(output, {
          self.WingsMaterial,
          false,
          false
        })
      end
      if self.Eyelashes and not self:GrabData('SeparateEyelashesPhong') then
        table.insert(output, {
          self.Eyelashes,
          false,
          false
        })
      end
      if not self:GrabData('SeparateManePhong') then
        if self.HairColor1Material then
          table.insert(output, {
            self.HairColor1Material,
            false,
            false
          })
        end
        if self.HairColor2Material then
          table.insert(output, {
            self.HairColor2Material,
            false,
            false
          })
        end
      end
      if not self:GrabData('SeparateTailPhong') then
        if self.TailColor1Material then
          table.insert(output, {
            self.TailColor1Material,
            false,
            false
          })
        end
        if self.TailColor2Material then
          return table.insert(output, {
            self.TailColor2Material,
            false,
            false
          })
        end
      end
    end,
    UpdatePhongData = function(self)
      local proceed = { }
      self:GetBodyPhongMaterials(proceed)
      for _, mat in ipairs(proceed) do
        self:ApplyPhongData(mat[1], 'Body', mat[2], mat[3])
      end
      if self:GrabData('SeparateHornPhong') and self.HornMaterial then
        self:ApplyPhongData(self.HornMaterial, 'Horn', false, true)
      end
      if self:GrabData('SeparateEyelashesPhong') and self.Eyelashes then
        self:ApplyPhongData(self.Eyelashes, 'Eyelashes', false, true)
      end
      if self:GrabData('SeparateWingsPhong') and self.WingsMaterial then
        self:ApplyPhongData(self.WingsMaterial, 'Wings')
      end
      if self.SocksMaterial then
        self:ApplyPhongData(self.SocksMaterial, 'Socks')
      end
      if self.NewSocksColor1 then
        self:ApplyPhongData(self.NewSocksColor1, 'Socks')
      end
      if self.NewSocksColor2 then
        self:ApplyPhongData(self.NewSocksColor2, 'Socks')
      end
      if self.NewSocksBase then
        self:ApplyPhongData(self.NewSocksBase, 'Socks')
      end
      if self:GrabData('SeparateManePhong') then
        self:ApplyPhongData(self.HairColor1Material, 'Mane')
        self:ApplyPhongData(self.HairColor2Material, 'Mane')
      end
      if self:GrabData('SeparateTailPhong') then
        self:ApplyPhongData(self.TailColor1Material, 'Tail')
        self:ApplyPhongData(self.TailColor2Material, 'Tail')
      end
      if self:GrabData('SeparateEyes') then
        self:ApplyPhongData(self.EyeMaterialL, 'LEye', true)
        return self:ApplyPhongData(self.EyeMaterialR, 'REye', true)
      else
        self:ApplyPhongData(self.EyeMaterialL, 'BEyes', true)
        return self:ApplyPhongData(self.EyeMaterialR, 'BEyes', true)
      end
    end,
    CompileBody = function(self)
      if not (self.isValid) then
        return 
      end
      local urlTextures = { }
      local left = 0
      local bodysize = self.__class:GetBodySize()
      local textureData = {
        ['name'] = "PPM2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(self:GetID()) .. "_Body",
        ['shader'] = 'VertexLitGeneric',
        ['data'] = {
          ['$basetexture'] = 'models/ppm2/base/body',
          ['$lightwarptexture'] = 'models/ppm2/base/lightwrap',
          ['$halflambert'] = '1',
          ['$selfillum'] = '1',
          ['$selfillummask'] = 'models/ppm2/partrender/null',
          ['$color'] = '{255 255 255}',
          ['$color2'] = '{255 255 255}',
          ['$model'] = '1',
          ['$phong'] = '1',
          ['$basemapalphaphongmask'] = '1',
          ['$phongexponent'] = '3',
          ['$phongboost'] = '0.15',
          ['$phongalbedotint'] = '1',
          ['$phongtint'] = '[1 .95 .95]',
          ['$phongfresnelranges'] = '[0.5 6 10]',
          ['$rimlight'] = '1',
          ['$rimlightexponent'] = '2',
          ['$rimlightboost'] = '1'
        }
      }
      self.BodyMaterialName = "!" .. tostring(textureData.name:lower())
      self.BodyMaterial = CreateMaterial(textureData.name, textureData.shader, textureData.data)
      self:UpdatePhongData()
      local continueCompilation
      continueCompilation = function()
        if not (self.isValid) then
          return 
        end
        local r, g, b
        do
          local _obj_0 = self:GrabData('BodyColor')
          r, g, b = _obj_0.r, _obj_0.g, _obj_0.b
        end
        self:StartRTOpaque("Body_rt", bodysize, r, g, b)
        surface.DrawRect(0, 0, bodysize, bodysize)
        surface.SetDrawColor(self:GrabData('EyebrowsColor'))
        surface.SetMaterial(_M.EYEBROWS)
        surface.DrawTexturedRect(0, 0, bodysize, bodysize)
        if not self:GrabData('LipsColorInherit') then
          surface.SetDrawColor(self:GrabData('LipsColor'))
        else
          do
            local _obj_0 = self:GrabData('BodyColor')
            r, g, b = _obj_0.r, _obj_0.g, _obj_0.b
          end
          r, g, b = math.max(r - 30, 0), math.max(g - 30, 0), math.max(b - 30, 0)
          surface.SetDrawColor(r, g, b)
        end
        surface.SetMaterial(_M.LIPS)
        surface.DrawTexturedRect(0, 0, bodysize, bodysize)
        if not self:GrabData('NoseColorInherit') then
          surface.SetDrawColor(self:GrabData('NoseColor'))
        else
          do
            local _obj_0 = self:GrabData('BodyColor')
            r, g, b = _obj_0.r, _obj_0.g, _obj_0.b
          end
          r, g, b = math.max(r - 30, 0), math.max(g - 30, 0), math.max(b - 30, 0)
          surface.SetDrawColor(r, g, b)
        end
        surface.SetMaterial(_M.NOSE)
        surface.DrawTexturedRect(0, 0, bodysize, bodysize)
        for i = 1, PPM2.MAX_TATTOOS do
          if self:GrabData("TattooOverDetail" .. tostring(i)) then
            self:DrawTattoo(i)
          end
        end
        for i = 1, PPM2.MAX_BODY_DETAILS do
          do
            local mat = _M.BODY_DETAILS[self:GrabData("BodyDetail" .. tostring(i))]
            if mat then
              surface.SetDrawColor(self:GrabData("BodyDetailColor" .. tostring(i)))
              surface.SetMaterial(mat)
              surface.DrawTexturedRect(0, 0, bodysize, bodysize)
            end
          end
        end
        surface.SetDrawColor(255, 255, 255)
        for i, mat in pairs(urlTextures) do
          surface.SetDrawColor(self:GrabData("BodyDetailURLColor" .. tostring(i)))
          surface.SetMaterial(mat)
          surface.DrawTexturedRect(0, 0, bodysize, bodysize)
        end
        for i = 1, PPM2.MAX_TATTOOS do
          if self:GrabData("TattooOverDetail" .. tostring(i)) then
            self:DrawTattoo(i)
          end
        end
        do
          local suit = _M.SUITS[self:GrabData('Bodysuit')]
          if suit then
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(suit)
            surface.DrawTexturedRect(0, 0, bodysize, bodysize)
          end
        end
        if self:GrabData('Socks') then
          surface.SetDrawColor(255, 255, 255)
          surface.SetMaterial(self.__class.PONY_SOCKS)
          surface.DrawTexturedRect(0, 0, bodysize, bodysize)
        end
        self.BodyMaterial:SetTexture('$basetexture', self:EndRT())
        self:StartRTOpaque("Body_rtIllum_" .. tostring(USE_HIGHRES_BODY:GetBool() and 'hd' or USE_HIGHRES_TEXTURES:GetBool() and 'hq' or 'normal'), bodysize)
        surface.SetDrawColor(255, 255, 255)
        if self:GrabData('GlowingEyebrows') then
          surface.SetDrawColor(255, 255, 255, 255 * self:GrabData('EyebrowsGlowStrength'))
          surface.SetMaterial(_M.EYEBROWS)
          surface.DrawTexturedRect(0, 0, bodysize, bodysize)
        end
        for i = 1, PPM2.MAX_TATTOOS do
          if not self:GrabData("TattooOverDetail" .. tostring(i)) then
            self:DrawTattoo(i, true)
          end
        end
        for i = 1, PPM2.MAX_BODY_DETAILS do
          do
            local mat = _M.BODY_DETAILS[self:GetData()["GetBodyDetail" .. tostring(i)](self:GetData())]
            if mat then
              local alpha = self:GetData()["GetBodyDetailGlowStrength" .. tostring(i)](self:GetData())
              if self:GetData()["GetBodyDetailGlow" .. tostring(i)](self:GetData()) then
                surface.SetDrawColor(255, 255, 255, alpha * 255)
                surface.SetMaterial(mat)
                surface.DrawTexturedRect(0, 0, bodysize, bodysize)
              else
                surface.SetDrawColor(0, 0, 0, alpha * 255)
                surface.SetMaterial(mat)
                surface.DrawTexturedRect(0, 0, bodysize, bodysize)
              end
            end
          end
        end
        for i = 1, PPM2.MAX_TATTOOS do
          if self:GrabData("TattooOverDetail" .. tostring(i)) then
            self:DrawTattoo(i, true)
          end
        end
        self.BodyMaterial:SetTexture('$selfillummask', self:EndRT())
        return PPM2.DebugPrint('Compiled body texture for ', self:GetEntity(), ' as part of ', self)
      end
      local data = self:GetData()
      local validURLS
      do
        local _accum_0 = { }
        local _len_0 = 1
        for i = 1, PPM2.MAX_BODY_DETAILS do
          local _continue_0 = false
          repeat
            local detailURL = data["GetBodyDetailURL" .. tostring(i)](data)
            if detailURL == '' or not detailURL:find('^https?://') then
              _continue_0 = true
              break
            end
            left = left + 1
            local _value_0 = {
              detailURL,
              i
            }
            _accum_0[_len_0] = _value_0
            _len_0 = _len_0 + 1
            _continue_0 = true
          until true
          if not _continue_0 then
            break
          end
        end
        validURLS = _accum_0
      end
      for _, _des_0 in ipairs(validURLS) do
        local url, i
        url, i = _des_0[1], _des_0[2]
        self.__class:LoadURL(url, bodysize, bodysize, function(texture, panel, mat)
          left = left - 1
          urlTextures[i] = mat
          if left == 0 then
            return continueCompilation()
          end
        end)
      end
      if left == 0 then
        continueCompilation()
      end
      return self.BodyMaterial
    end,
    CompileHorn = function(self)
      if not (self.isValid) then
        return 
      end
      local textureData = {
        ['name'] = "PPM2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(self:GetID()) .. "_Horn",
        ['shader'] = 'VertexLitGeneric',
        ['data'] = {
          ['$basetexture'] = 'models/ppm2/base/horn',
          ['$bumpmap'] = 'models/ppm2/base/horn_normal',
          ['$selfillum'] = '1',
          ['$selfillummask'] = 'models/ppm2/partrender/null',
          ['$model'] = '1',
          ['$phong'] = '1',
          ['$phongexponent'] = '3',
          ['$phongboost'] = '0.05',
          ['$phongalbedotint'] = '1',
          ['$phongtint'] = '[1 .95 .95]',
          ['$phongfresnelranges'] = '[0.5 6 10]',
          ['$alpha'] = '1',
          ['$color'] = '[1 1 1]',
          ['$color2'] = '[1 1 1]'
        }
      }
      local texSize = PPM2.GetTextureSize(self.__class.QUAD_SIZE_HORN)
      local urlTextures = { }
      local left = 0
      self.HornMaterialName = "!" .. tostring(textureData.name:lower())
      self.HornMaterial = CreateMaterial(textureData.name, textureData.shader, textureData.data)
      self:UpdatePhongData()
      local continueCompilation
      continueCompilation = function()
        local r, g, b
        do
          local _obj_0 = self:GrabData('BodyColor')
          r, g, b = _obj_0.r, _obj_0.g, _obj_0.b
        end
        if self:GrabData('SeparateHorn') then
          do
            local _obj_0 = self:GrabData('HornColor')
            r, g, b = _obj_0.r, _obj_0.g, _obj_0.b
          end
        end
        self:StartRTOpaque('Horn', texSize, r, g, b)
        surface.SetDrawColor(self:GrabData('HornDetailColor'))
        surface.SetMaterial(self.__class.HORN_DETAIL_COLOR)
        surface.DrawTexturedRect(0, 0, texSize, texSize)
        for i, mat in pairs(urlTextures) do
          local a
          do
            local _obj_0 = self:GrabData("HornURLColor" .. tostring(i))
            r, g, b, a = _obj_0.r, _obj_0.g, _obj_0.b, _obj_0.a
          end
          surface.SetDrawColor(r, g, b, a)
          surface.SetMaterial(mat)
          surface.DrawTexturedRect(0, 0, texSize, texSize)
        end
        self.HornMaterial:SetTexture('$basetexture', self:EndRT())
        self:StartRTOpaque('Horn_illum', texSize)
        if self:GrabData('HornGlow') then
          surface.SetDrawColor(255, 255, 255, self:GrabData('HornGlowSrength') * 255)
          surface.SetMaterial(self.__class.HORN_DETAIL_COLOR)
          surface.DrawTexturedRect(0, 0, texSize, texSize)
        end
        self.HornMaterial:SetTexture('$selfillummask', self:EndRT())
        do
          local _obj_0 = self.__class.BUMP_COLOR
          r, g, b = _obj_0.r, _obj_0.g, _obj_0.b
        end
        self:StartRTOpaque('Horn_bump', texSize, r, g, b)
        local alpha = 255
        alpha = self:GrabData('HornDetailColor').a
        surface.SetDrawColor(255, 255, 255, alpha)
        surface.SetMaterial(_M.HORN_DETAIL_BUMP)
        surface.DrawTexturedRect(0, 0, texSize, texSize)
        self.HornMaterial:SetTexture('$bumpmap', self:EndRT())
        return PPM2.DebugPrint('Compiled Horn texture for ', self:GetEntity(), ' as part of ', self)
      end
      local data = self:GetData()
      local validURLS
      do
        local _accum_0 = { }
        local _len_0 = 1
        for i = 1, 3 do
          local _continue_0 = false
          repeat
            local detailURL = data["GetHornURL" .. tostring(i)](data)
            if detailURL == '' or not detailURL:find('^https?://') then
              _continue_0 = true
              break
            end
            left = left + 1
            local _value_0 = {
              detailURL,
              i
            }
            _accum_0[_len_0] = _value_0
            _len_0 = _len_0 + 1
            _continue_0 = true
          until true
          if not _continue_0 then
            break
          end
        end
        validURLS = _accum_0
      end
      for _, _des_0 in ipairs(validURLS) do
        local url, i
        url, i = _des_0[1], _des_0[2]
        self.__class:LoadURL(url, texSize, texSize, function(texture, panel, mat)
          left = left - 1
          urlTextures[i] = mat
          if left == 0 then
            return continueCompilation()
          end
        end)
      end
      if left == 0 then
        continueCompilation()
      end
      return self.HornMaterial
    end,
    CompileNewSocks = function(self)
      if not (self.isValid) then
        return 
      end
      local data = {
        ['$basetexture'] = 'models/debug/debugwhite',
        ['$model'] = '1',
        ['$ambientocclusion'] = '1',
        ['$lightwarptexture'] = 'models/ppm2/base/lightwrap',
        ['$phong'] = '1',
        ['$phongexponent'] = '6',
        ['$phongboost'] = '0.1',
        ['$phongalbedotint'] = '1',
        ['$phongtint'] = '[1 .95 .95]',
        ['$phongfresnelranges'] = '[1 5 10]',
        ['$rimlight'] = '1',
        ['$rimlightexponent'] = '4.0',
        ['$rimlightboost'] = '2',
        ['$color'] = '[1 1 1]',
        ['$color2'] = '[1 1 1]',
        ['$cloakPassEnabled'] = '1'
      }
      local textureColor1 = {
        ['name'] = "PPM2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(self:GetID()) .. "_NewSocks_Color1",
        ['shader'] = 'VertexLitGeneric',
        ['data'] = data
      }
      local textureColor2 = {
        ['name'] = "PPM2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(self:GetID()) .. "_NewSocks_Color2",
        ['shader'] = 'VertexLitGeneric',
        ['data'] = data
      }
      local textureBase = {
        ['name'] = "PPM2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(self:GetID()) .. "_NewSocks_Base",
        ['shader'] = 'VertexLitGeneric',
        ['data'] = data
      }
      self.NewSocksColor1Name = '!' .. textureColor1.name:lower()
      self.NewSocksColor2Name = '!' .. textureColor2.name:lower()
      self.NewSocksBaseName = '!' .. textureBase.name:lower()
      self.NewSocksColor1 = CreateMaterial(textureColor1.name, textureColor1.shader, textureColor1.data)
      self.NewSocksColor2 = CreateMaterial(textureColor2.name, textureColor2.shader, textureColor2.data)
      self.NewSocksBase = CreateMaterial(textureBase.name, textureBase.shader, textureBase.data)
      local texSize = PPM2.GetTextureSize(self.__class.QUAD_SIZE_SOCKS)
      self:UpdatePhongData()
      local url = self:GrabData('NewSocksTextureURL')
      if url == '' or not url:find('^https?://') then
        local r, g, b
        do
          local _obj_0 = self:GrabData('NewSocksColor1')
          r, g, b = _obj_0.r, _obj_0.g, _obj_0.b
        end
        self.NewSocksColor1:SetVector('$color', Vector(r / 255, g / 255, b / 255))
        self.NewSocksColor1:SetVector('$color2', Vector(r / 255, g / 255, b / 255))
        do
          local _obj_0 = self:GrabData('NewSocksColor2')
          r, g, b = _obj_0.r, _obj_0.g, _obj_0.b
        end
        self.NewSocksColor2:SetVector('$color', Vector(r / 255, g / 255, b / 255))
        self.NewSocksColor2:SetVector('$color2', Vector(r / 255, g / 255, b / 255))
        do
          local _obj_0 = self:GrabData('NewSocksColor3')
          r, g, b = _obj_0.r, _obj_0.g, _obj_0.b
        end
        self.NewSocksBase:SetVector('$color', Vector(r / 255, g / 255, b / 255))
        self.NewSocksBase:SetVector('$color2', Vector(r / 255, g / 255, b / 255))
        PPM2.DebugPrint('Compiled new socks texture for ', self:GetEntity(), ' as part of ', self)
      else
        self.__class:LoadURL(url, texSize, texSize, function(texture, panel, material)
          for _, tex in ipairs({
            self.NewSocksColor1,
            self.NewSocksColor2,
            self.NewSocksBase
          }) do
            tex:SetVector('$color', Vector(1, 1, 1))
            tex:SetVector('$color2', Vector(1, 1, 1))
            tex:SetTexture('$basetexture', texture)
          end
        end)
      end
      return self.NewSocksColor1, self.NewSocksColor2, self.NewSocksBase
    end,
    CompileEyelashes = function(self)
      if not (self.isValid) then
        return 
      end
      local textureData = {
        ['name'] = "PPM2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(self:GetID()) .. "_Eyelashes",
        ['shader'] = 'VertexLitGeneric',
        ['data'] = {
          ['$basetexture'] = 'models/debug/debugwhite',
          ['$model'] = '1',
          ['$ambientocclusion'] = '1',
          ['$lightwarptexture'] = 'models/ppm2/base/lightwrap',
          ['$phong'] = '1',
          ['$phongexponent'] = '6',
          ['$phongboost'] = '0.1',
          ['$phongalbedotint'] = '1',
          ['$phongtint'] = '[1 .95 .95]',
          ['$phongfresnelranges'] = '[1 5 10]',
          ['$rimlight'] = '1',
          ['$rimlightexponent'] = '4.0',
          ['$rimlightboost'] = '2',
          ['$color'] = '[1 1 1]',
          ['$color2'] = '[1 1 1]',
          ['$cloakPassEnabled'] = '1'
        }
      }
      self.EyelashesName = '!' .. textureData.name:lower()
      self.Eyelashes = CreateMaterial(textureData.name, textureData.shader, textureData.data)
      self:UpdatePhongData()
      local r, g, b
      do
        local _obj_0 = self:GrabData('EyelashesColor')
        r, g, b = _obj_0.r, _obj_0.g, _obj_0.b
      end
      self.Eyelashes:SetVector('$color', Vector(r / 255, g / 255, b / 255))
      self.Eyelashes:SetVector('$color2', Vector(r / 255, g / 255, b / 255))
      PPM2.DebugPrint('Compiled new eyelashes texture for ', self:GetEntity(), ' as part of ', self)
      return self.Eyelashes
    end,
    CompileSocks = function(self)
      if not (self.isValid) then
        return 
      end
      local textureData = {
        ['name'] = "PPM2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(self:GetID()) .. "_Socks",
        ['shader'] = 'VertexLitGeneric',
        ['data'] = {
          ['$basetexture'] = 'models/props_pony/ppm/ppm_socks/socks_striped',
          ['$model'] = '1',
          ['$ambientocclusion'] = '1',
          ['$lightwarptexture'] = 'models/ppm2/base/lightwrap',
          ['$phong'] = '1',
          ['$phongexponent'] = '6',
          ['$phongboost'] = '0.1',
          ['$phongalbedotint'] = '1',
          ['$phongtint'] = '[1 .95 .95]',
          ['$phongfresnelranges'] = '[1 5 10]',
          ['$rimlight'] = '1',
          ['$rimlightexponent'] = '4.0',
          ['$rimlightboost'] = '2',
          ['$color'] = '[1 1 1]',
          ['$color2'] = '[1 1 1]',
          ['$cloakPassEnabled'] = '1'
        }
      }
      self.SocksMaterialName = "!" .. tostring(textureData.name:lower())
      self.SocksMaterial = CreateMaterial(textureData.name, textureData.shader, textureData.data)
      self:UpdatePhongData()
      local texSize = PPM2.GetTextureSize(self.__class.QUAD_SIZE_SOCKS)
      local r, g, b
      do
        local _obj_0 = self:GrabData('SocksColor')
        r, g, b = _obj_0.r, _obj_0.g, _obj_0.b
      end
      self.SocksMaterial:SetFloat('$alpha', 1)
      local url = self:GrabData('SocksTextureURL')
      if url == '' or not url:find('^https?://') then
        self.SocksMaterial:SetVector('$color', Vector(1, 1, 1))
        self.SocksMaterial:SetVector('$color2', Vector(1, 1, 1))
        self:StartRTOpaque('Socks', texSize, r, g, b)
        local socksType = self:GrabData('SocksTexture') + 1
        surface.SetMaterial(_M.SOCKS_MATERIALS[socksType] or _M.SOCKS_MATERIALS[1])
        surface.DrawTexturedRect(0, 0, texSize, texSize)
        do
          local details = _M.SOCKS_DETAILS[socksType]
          if details then
            for i, id in pairs(details) do
              do
                local _obj_0 = self:GetData()['GetSocksDetailColor' .. i](self:GetData())
                r, g, b = _obj_0.r, _obj_0.g, _obj_0.b
              end
              surface.SetDrawColor(r, g, b)
              surface.SetMaterial(id)
              surface.DrawTexturedRect(0, 0, texSize, texSize)
            end
          end
        end
        self.SocksMaterial:SetTexture('$basetexture', self:EndRT())
        PPM2.DebugPrint('Compiled socks texture for ', self:GetEntity(), ' as part of ', self)
      else
        self.__class:LoadURL(url, texSize, texSize, function(texture, panel, material)
          self.SocksMaterial:SetVector('$color', Vector(r / 255, g / 255, b / 255))
          self.SocksMaterial:SetVector('$color2', Vector(r / 255, g / 255, b / 255))
          return self.SocksMaterial:SetTexture('$basetexture', texture)
        end)
      end
      return self.SocksMaterial
    end,
    CompileWings = function(self)
      if not (self.isValid) then
        return 
      end
      local textureData = {
        ['name'] = "PPM2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(self:GetID()) .. "_Wings",
        ['shader'] = 'VertexLitGeneric',
        ['data'] = {
          ['$basetexture'] = 'models/debug/debugwhite',
          ['$model'] = '1',
          ['$phong'] = '1',
          ['$phongexponent'] = '3',
          ['$phongboost'] = '0.05',
          ['$phongalbedotint'] = '1',
          ['$phongtint'] = '[1 .95 .95]',
          ['$phongfresnelranges'] = '[0.5 6 10]',
          ['$alpha'] = '1',
          ['$color'] = '[1 1 1]',
          ['$color2'] = '[1 1 1]'
        }
      }
      local urlTextures = { }
      local left = 0
      self.WingsMaterialName = "!" .. tostring(textureData.name:lower())
      self.WingsMaterial = CreateMaterial(textureData.name, textureData.shader, textureData.data)
      self:UpdatePhongData()
      local texSize = PPM2.GetTextureSize(self.__class.QUAD_SIZE_WING)
      local continueCompilation
      continueCompilation = function()
        local r, g, b
        do
          local _obj_0 = self:GrabData('BodyColor')
          r, g, b = _obj_0.r, _obj_0.g, _obj_0.b
        end
        if self:GrabData('SeparateWings') then
          do
            local _obj_0 = self:GrabData('WingsColor')
            r, g, b = _obj_0.r, _obj_0.g, _obj_0.b
          end
        end
        local rt = self:StartRTOpaque('Wings_rt', texSize, r, g, b)
        surface.SetMaterial(self.__class.WINGS_MATERIAL_COLOR)
        surface.DrawTexturedRect(0, 0, texSize, texSize)
        for i, mat in pairs(urlTextures) do
          local a
          do
            local _obj_0 = self:GetData()["GetWingsURLColor" .. tostring(i)](self:GetData())
            r, g, b, a = _obj_0.r, _obj_0.g, _obj_0.b, _obj_0.a
          end
          surface.SetDrawColor(r, g, b, a)
          surface.SetMaterial(mat)
          surface.DrawTexturedRect(0, 0, texSize, texSize)
        end
        self.WingsMaterial:SetTexture('$basetexture', rt)
        self:EndRT()
        return PPM2.DebugPrint('Compiled wings texture for ', self:GetEntity(), ' as part of ', self)
      end
      local data = self:GetData()
      local validURLS
      do
        local _accum_0 = { }
        local _len_0 = 1
        for i = 1, 3 do
          local _continue_0 = false
          repeat
            local detailURL = data["GetWingsURL" .. tostring(i)](data)
            if detailURL == '' or not detailURL:find('^https?://') then
              _continue_0 = true
              break
            end
            left = left + 1
            local _value_0 = {
              detailURL,
              i
            }
            _accum_0[_len_0] = _value_0
            _len_0 = _len_0 + 1
            _continue_0 = true
          until true
          if not _continue_0 then
            break
          end
        end
        validURLS = _accum_0
      end
      for _, _des_0 in ipairs(validURLS) do
        local url, i
        url, i = _des_0[1], _des_0[2]
        self.__class:LoadURL(url, texSize, texSize, function(texture, panel, mat)
          left = left - 1
          urlTextures[i] = mat
          if left == 0 then
            return continueCompilation()
          end
        end)
      end
      if left == 0 then
        continueCompilation()
      end
      return self.WingsMaterial
    end,
    GetManeType = function(self)
      return self:GrabData('ManeType')
    end,
    GetManeTypeLower = function(self)
      return self:GrabData('ManeTypeLower')
    end,
    GetTailType = function(self)
      return self:GrabData('TailType')
    end,
    CompileHair = function(self)
      if not (self.isValid) then
        return 
      end
      local textureFirst = {
        ['name'] = "PPM2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(self:GetID()) .. "_Mane_1",
        ['shader'] = 'VertexLitGeneric',
        ['data'] = {
          ['$basetexture'] = 'models/debug/debugwhite',
          ['$lightwarptexture'] = 'models/ppm2/base/lightwrap',
          ['$halflambert'] = '1',
          ['$model'] = '1',
          ['$phong'] = '1',
          ['$basemapalphaphongmask'] = '1',
          ['$phongexponent'] = '6',
          ['$phongboost'] = '0.05',
          ['$phongalbedotint'] = '1',
          ['$phongtint'] = '[1 .95 .95]',
          ['$phongfresnelranges'] = '[0.5 6 10]',
          ['$rimlight'] = 1,
          ['$rimlightexponent'] = 2,
          ['$rimlightboost'] = 1,
          ['$color'] = '[1 1 1]',
          ['$color2'] = '[1 1 1]'
        }
      }
      local textureSecond = {
        ['name'] = "PPM2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(self:GetID()) .. "_Mane_2",
        ['shader'] = 'VertexLitGeneric',
        ['data'] = (function()
          local _tbl_0 = { }
          for k, v in pairs(textureFirst.data) do
            _tbl_0[k] = v
          end
          return _tbl_0
        end)()
      }
      self.HairColor1MaterialName = "!" .. tostring(textureFirst.name:lower())
      self.HairColor2MaterialName = "!" .. tostring(textureSecond.name:lower())
      self.HairColor1Material = CreateMaterial(textureFirst.name, textureFirst.shader, textureFirst.data)
      self.HairColor2Material = CreateMaterial(textureSecond.name, textureSecond.shader, textureSecond.data)
      local texSize = PPM2.GetTextureSize(self.__class.QUAD_SIZE_HAIR)
      local urlTextures = { }
      local left = 0
      local continueCompilation
      continueCompilation = function()
        if not (self.isValid) then
          return 
        end
        local r, g, b
        do
          local _obj_0 = self:GrabData('ManeColor1')
          r, g, b = _obj_0.r, _obj_0.g, _obj_0.b
        end
        self:StartRTOpaque('Mane_1', texSize, r, g, b)
        local maneTypeUpper = self:GetManeType()
        if self.__class.UPPER_MANE_MATERIALS[maneTypeUpper] then
          local i = 1
          for _, mat in ipairs(self.__class.UPPER_MANE_MATERIALS[maneTypeUpper]) do
            local _continue_0 = false
            repeat
              if type(mat) == 'number' then
                _continue_0 = true
                break
              end
              local a
              do
                local _obj_0 = self:GetData()["GetManeDetailColor" .. tostring(i)](self:GetData())
                r, g, b, a = _obj_0.r, _obj_0.g, _obj_0.b, _obj_0.a
              end
              surface.SetDrawColor(r, g, b, a)
              surface.SetMaterial(mat)
              surface.DrawTexturedRect(0, 0, texSize, texSize)
              i = i + 1
              _continue_0 = true
            until true
            if not _continue_0 then
              break
            end
          end
        end
        for i, mat in pairs(urlTextures) do
          surface.SetDrawColor(self:GetData()["GetManeURLColor" .. tostring(i)](self:GetData()))
          surface.SetMaterial(mat)
          surface.DrawTexturedRect(0, 0, texSize, texSize)
        end
        self.HairColor1Material:SetTexture('$basetexture', self:EndRT())
        do
          local _obj_0 = self:GrabData('ManeColor2')
          r, g, b = _obj_0.r, _obj_0.g, _obj_0.b
        end
        self:StartRTOpaque('Mane_2', texSize, r, g, b)
        local maneTypeLower = self:GetManeTypeLower()
        if self.__class.LOWER_MANE_MATERIALS[maneTypeLower] then
          local i = 1
          for _, mat in ipairs(self.__class.LOWER_MANE_MATERIALS[maneTypeLower]) do
            local _continue_0 = false
            repeat
              if type(mat) == 'number' then
                _continue_0 = true
                break
              end
              local a
              do
                local _obj_0 = self:GetData()["GetManeDetailColor" .. tostring(i)](self:GetData())
                r, g, b, a = _obj_0.r, _obj_0.g, _obj_0.b, _obj_0.a
              end
              surface.SetDrawColor(r, g, b, a)
              surface.SetMaterial(mat)
              surface.DrawTexturedRect(0, 0, texSize, texSize)
              i = i + 1
              _continue_0 = true
            until true
            if not _continue_0 then
              break
            end
          end
        end
        for i, mat in pairs(urlTextures) do
          surface.SetDrawColor(self:GetData()["GetManeURLColor" .. tostring(i)](self:GetData()))
          surface.SetMaterial(mat)
          surface.DrawTexturedRect(0, 0, texSize, texSize)
        end
        self.HairColor2Material:SetTexture('$basetexture', self:EndRT())
        return PPM2.DebugPrint('Compiled mane textures for ', self:GetEntity(), ' as part of ', self)
      end
      local data = self:GetData()
      local validURLS
      do
        local _accum_0 = { }
        local _len_0 = 1
        for i = 1, 6 do
          local _continue_0 = false
          repeat
            local detailURL = data["GetManeURL" .. tostring(i)](data)
            if detailURL == '' or not detailURL:find('^https?://') then
              _continue_0 = true
              break
            end
            left = left + 1
            local _value_0 = {
              detailURL,
              i
            }
            _accum_0[_len_0] = _value_0
            _len_0 = _len_0 + 1
            _continue_0 = true
          until true
          if not _continue_0 then
            break
          end
        end
        validURLS = _accum_0
      end
      for _, _des_0 in ipairs(validURLS) do
        local url, i
        url, i = _des_0[1], _des_0[2]
        self.__class:LoadURL(url, texSize, texSize, function(texture, panel, mat)
          left = left - 1
          urlTextures[i] = mat
          if left == 0 then
            return continueCompilation()
          end
        end)
      end
      if left == 0 then
        continueCompilation()
      end
      return self.HairColor1Material, self.HairColor2Material
    end,
    CompileTail = function(self)
      if not (self.isValid) then
        return 
      end
      local textureFirst = {
        ['name'] = "PPM2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(self:GetID()) .. "_Tail_1",
        ['shader'] = 'VertexLitGeneric',
        ['data'] = {
          ['$basetexture'] = 'models/debug/debugwhite',
          ['$lightwarptexture'] = 'models/ppm2/base/lightwrap',
          ['$halflambert'] = '1',
          ['$model'] = '1',
          ['$phong'] = '1',
          ['$basemapalphaphongmask'] = '1',
          ['$phongexponent'] = '6',
          ['$phongboost'] = '0.05',
          ['$phongalbedotint'] = '1',
          ['$phongtint'] = '[1 .95 .95]',
          ['$phongfresnelranges'] = '[0.5 6 10]',
          ['$rimlight'] = 1,
          ['$rimlightexponent'] = 2,
          ['$rimlightboost'] = 1,
          ['$color'] = '[1 1 1]',
          ['$color2'] = '[1 1 1]'
        }
      }
      local textureSecond = {
        ['name'] = "PPM2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(self:GetID()) .. "_Tail_2",
        ['shader'] = 'VertexLitGeneric',
        ['data'] = (function()
          local _tbl_0 = { }
          for k, v in pairs(textureFirst.data) do
            _tbl_0[k] = v
          end
          return _tbl_0
        end)()
      }
      self.TailColor1MaterialName = "!" .. tostring(textureFirst.name:lower())
      self.TailColor2MaterialName = "!" .. tostring(textureSecond.name:lower())
      self.TailColor1Material = CreateMaterial(textureFirst.name, textureFirst.shader, textureFirst.data)
      self.TailColor2Material = CreateMaterial(textureSecond.name, textureSecond.shader, textureSecond.data)
      local texSize = PPM2.GetTextureSize(self.__class.QUAD_SIZE_TAIL)
      local urlTextures = { }
      local left = 0
      local continueCompilation
      continueCompilation = function()
        if not (self.isValid) then
          return 
        end
        local r, g, b
        do
          local _obj_0 = self:GrabData('TailColor1')
          r, g, b = _obj_0.r, _obj_0.g, _obj_0.b
        end
        self:StartRTOpaque('Tail_1', texSize, r, g, b)
        local tailType = self:GetTailType()
        if self.__class.TAIL_DETAIL_MATERIALS[tailType] then
          local i = 1
          for _, mat in ipairs(self.__class.TAIL_DETAIL_MATERIALS[tailType]) do
            local _continue_0 = false
            repeat
              if type(mat) == 'number' then
                _continue_0 = true
                break
              end
              surface.SetMaterial(mat)
              surface.SetDrawColor(self:GetData()["GetTailDetailColor" .. tostring(i)](self:GetData()))
              surface.DrawTexturedRect(0, 0, texSize, texSize)
              i = i + 1
              _continue_0 = true
            until true
            if not _continue_0 then
              break
            end
          end
        end
        for i, mat in pairs(urlTextures) do
          surface.SetDrawColor(self:GetData()["GetTailURLColor" .. tostring(i)](self:GetData()))
          surface.SetMaterial(mat)
          surface.DrawTexturedRect(0, 0, texSize, texSize)
        end
        self.TailColor1Material:SetTexture('$basetexture', self:EndRT())
        do
          local _obj_0 = self:GrabData('TailColor2')
          r, g, b = _obj_0.r, _obj_0.g, _obj_0.b
        end
        self:StartRTOpaque('Tail_2', texSize, r, g, b)
        if self.__class.TAIL_DETAIL_MATERIALS[tailType] then
          local i = 1
          for _, mat in ipairs(self.__class.TAIL_DETAIL_MATERIALS[tailType]) do
            local _continue_0 = false
            repeat
              if type(mat) == 'number' then
                _continue_0 = true
                break
              end
              surface.SetMaterial(mat)
              surface.SetDrawColor(self:GetData()["GetTailDetailColor" .. tostring(i)](self:GetData()))
              surface.DrawTexturedRect(0, 0, texSize, texSize)
              i = i + 1
              _continue_0 = true
            until true
            if not _continue_0 then
              break
            end
          end
        end
        for i, mat in pairs(urlTextures) do
          surface.SetDrawColor(self:GetData()["GetTailURLColor" .. tostring(i)](self:GetData()))
          surface.SetMaterial(mat)
          surface.DrawTexturedRect(0, 0, texSize, texSize)
        end
        self.TailColor2Material:SetTexture('$basetexture', self:EndRT())
        return PPM2.DebugPrint('Compiled tail textures for ', self:GetEntity(), ' as part of ', self)
      end
      local data = self:GetData()
      local validURLS
      do
        local _accum_0 = { }
        local _len_0 = 1
        for i = 1, 6 do
          local _continue_0 = false
          repeat
            local detailURL = data["GetTailURL" .. tostring(i)](data)
            if detailURL == '' or not detailURL:find('^https?://') then
              _continue_0 = true
              break
            end
            left = left + 1
            local _value_0 = {
              detailURL,
              i
            }
            _accum_0[_len_0] = _value_0
            _len_0 = _len_0 + 1
            _continue_0 = true
          until true
          if not _continue_0 then
            break
          end
        end
        validURLS = _accum_0
      end
      for _, _des_0 in ipairs(validURLS) do
        local url, i
        url, i = _des_0[1], _des_0[2]
        self.__class:LoadURL(url, texSize, texSize, function(texture, panel, mat)
          left = left - 1
          urlTextures[i] = mat
          if left == 0 then
            return continueCompilation()
          end
        end)
      end
      if left == 0 then
        continueCompilation()
      end
      return self.TailColor1Material, self.TailColor2Material
    end,
    ResetEyeReflections = function(self)
      if self.EyeTextureL then
        self.EyeMaterialL:SetTexture('$iris', self.EyeTextureL)
      end
      if self.EyeTextureR then
        return self.EyeMaterialR:SetTexture('$iris', self.EyeTextureR)
      end
    end,
    UpdateEyeReflections = function(self, ent)
      if ent == nil then
        ent = self:GetEntity()
      end
      if not self.EyeMaterialDrawL or not self.EyeMaterialDrawR then
        return 
      end
      self.AttachID = self.AttachID or self:GetEntity():LookupAttachment('eyes')
      local Pos
      local Ang
      if ent == self:GetEntity() then
        do
          local _obj_0 = self:GetEntity():GetAttachment(self.AttachID)
          Pos, Ang = _obj_0.Pos, _obj_0.Ang
        end
      end
      if ent ~= self:GetEntity() then
        do
          local _obj_0 = ent:GetAttachment(ent:LookupAttachment('eyes'))
          Pos, Ang = _obj_0.Pos, _obj_0.Ang
        end
      end
      if Pos:Distance(EyePos()) > REAL_TIME_EYE_REFLECTIONS_DIST:GetInt() then
        return self:ResetEyeReflections()
      end
      local scale = self.__class:GetReflectionsScale()
      self.lastScale = self.lastScale or scale
      if self.lastScale ~= scale then
        self.lastScale = scale
        self.reflectRT = nil
        self.reflectRTMat = nil
      end
      local texName = "PPM2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(USE_HIGHRES_TEXTURES:GetBool() and 'HD' or 'NORMAL') .. "_" .. tostring(self:GetID()) .. "_EyesReflect_" .. tostring(scale)
      local reflectrt = self.__class.reflectRT or GetRenderTarget(texName, scale, scale, false)
      reflectrt:Download()
      self.__class.reflectRT = reflectrt
      self.reflectRTMat = self.reflectRTMat or CreateMaterial(texName .. '_Mat', 'UnlitGeneric', {
        ['$basetexture'] = 'models/debug/debugwhite',
        ['$ignorez'] = 1,
        ['$vertexcolor'] = 1,
        ['$translucent'] = 1,
        ['$alpha'] = 1,
        ['$vertexalpha'] = 1,
        ['$nolod'] = 1
      })
      self.reflectRTMat:SetTexture('$basetexture', reflectrt)
      render.PushRenderTarget(reflectrt)
      render.Clear(0, 0, 0, 255, true, true)
      local viewData = { }
      viewData.drawhud = false
      viewData.drawmonitors = false
      viewData.drawviewmodel = false
      viewData.origin = Pos
      viewData.angles = Ang
      viewData.x = 0
      viewData.y = 0
      viewData.fov = 150
      viewData.w = scale
      viewData.h = scale
      viewData.aspectratio = 1
      viewData.znear = 1
      viewData.zfar = REAL_TIME_EYE_REFLECTIONS_RDIST:GetInt()
      render.RenderView(viewData)
      render.PopRenderTarget()
      local texSize = PPM2.GetTextureSize(self.__class.QUAD_SIZE_EYES)
      surface.DisableClipping(true)
      local rtleft = GetRenderTarget("PPM2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(self:GetID()) .. "_" .. tostring(USE_HIGHRES_TEXTURES:GetBool() and 'HD' or 'NORMAL') .. "_LeftReflect_" .. tostring(scale), texSize, texSize, false)
      rtleft:Download()
      local rtright = GetRenderTarget("PPM2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(self:GetID()) .. "_" .. tostring(USE_HIGHRES_TEXTURES:GetBool() and 'HD' or 'NORMAL') .. "_RightReflect_" .. tostring(scale), texSize, texSize, false)
      rtright:Download()
      local W, H = 1, 1
      local separated = self:GrabData('SeparateEyes')
      local prefixData = ''
      if separated then
        prefixData = 'Left'
      end
      render.PushRenderTarget(rtleft)
      render.Clear(0, 0, 0, 255, true, true)
      cam.Start2D()
      surface.SetDrawColor(255, 255, 255, 255)
      surface.SetMaterial(self.EyeMaterialDrawL)
      surface.DrawTexturedRect(0, 0, texSize * W, texSize * H)
      surface.SetDrawColor(255, 255, 255, 255 * self:GrabData('EyeGlossyStrength' .. prefixData))
      surface.SetMaterial(self.reflectRTMat)
      surface.DrawTexturedRect(0, 0, texSize * W, texSize * H)
      cam.End2D()
      render.PopRenderTarget()
      self.EyeMaterialL:SetTexture('$iris', rtleft)
      if separated then
        prefixData = 'Right'
      end
      render.PushRenderTarget(rtright)
      render.Clear(0, 0, 0, 255, true, true)
      cam.Start2D()
      surface.SetDrawColor(255, 255, 255, 255)
      surface.SetMaterial(self.EyeMaterialDrawR)
      surface.DrawTexturedRect(0, 0, texSize * W, texSize * H)
      surface.SetDrawColor(255, 255, 255, 255 * self:GrabData('EyeGlossyStrength' .. prefixData))
      surface.SetMaterial(self.reflectRTMat)
      surface.DrawTexturedRect(0, 0, texSize * W, texSize * H)
      cam.End2D()
      render.PopRenderTarget()
      surface.DisableClipping(false)
      return self.EyeMaterialR:SetTexture('$iris', rtright)
    end,
    CompileLeftEye = function(self)
      return self:CompileEye(true)
    end,
    CompileRightEye = function(self)
      return self:CompileEye(false)
    end,
    CompileEye = function(self, left)
      if left == nil then
        left = false
      end
      if not (self.isValid) then
        return 
      end
      local prefix = left and 'l' or 'r'
      local prefixUpper = left and 'L' or 'R'
      local prefixUpperR = left and 'R' or 'L'
      local separated = self:GrabData('SeparateEyes')
      local prefixData = ''
      if separated then
        prefixData = left and 'Left' or 'Right'
      end
      local EyeRefract = self:GrabData("EyeRefract" .. tostring(prefixData))
      local EyeCornerA = self:GrabData("EyeCornerA" .. tostring(prefixData))
      local EyeType = self:GrabData("EyeType" .. tostring(prefixData))
      local EyeBackground = self:GrabData("EyeBackground" .. tostring(prefixData))
      local EyeHole = self:GrabData("EyeHole" .. tostring(prefixData))
      local HoleWidth = self:GrabData("HoleWidth" .. tostring(prefixData))
      local IrisSize = self:GrabData("IrisSize" .. tostring(prefixData)) * (EyeRefract and .38 or .75)
      local EyeIris1 = self:GrabData("EyeIrisTop" .. tostring(prefixData))
      local EyeIris2 = self:GrabData("EyeIrisBottom" .. tostring(prefixData))
      local EyeIrisLine1 = self:GrabData("EyeIrisLine1" .. tostring(prefixData))
      local EyeIrisLine2 = self:GrabData("EyeIrisLine2" .. tostring(prefixData))
      local EyeLines = self:GrabData("EyeLines" .. tostring(prefixData))
      local HoleSize = self:GrabData("HoleSize" .. tostring(prefixData))
      local EyeReflection = self:GrabData("EyeReflection" .. tostring(prefixData))
      local EyeReflectionType = self:GrabData("EyeReflectionType" .. tostring(prefixData))
      local EyeEffect = self:GrabData("EyeEffect" .. tostring(prefixData))
      local DerpEyes = self:GrabData("DerpEyes" .. tostring(prefixData))
      local DerpEyesStrength = self:GrabData("DerpEyesStrength" .. tostring(prefixData))
      local EyeURL = self:GrabData("EyeURL" .. tostring(prefixData))
      local IrisWidth = self:GrabData("IrisWidth" .. tostring(prefixData))
      local IrisHeight = self:GrabData("IrisHeight" .. tostring(prefixData))
      local HoleHeight = self:GrabData("HoleHeight" .. tostring(prefixData))
      local HoleShiftX = self:GrabData("HoleShiftX" .. tostring(prefixData))
      local HoleShiftY = self:GrabData("HoleShiftY" .. tostring(prefixData))
      local EyeRotation = self:GrabData("EyeRotation" .. tostring(prefixData))
      local EyeLineDirection = self:GrabData("EyeLineDirection" .. tostring(prefixData))
      local PonySize = self:GrabData('PonySize')
      if IsValid(self:GetEntity()) and self:GetEntity():IsRagdoll() then
        PonySize = 1
      end
      local texSize = PPM2.GetTextureSize(self.__class.QUAD_SIZE_EYES)
      local shiftX, shiftY = (1 - IrisWidth) * texSize / 2, (1 - IrisHeight) * texSize / 2
      if DerpEyes and left then
        shiftY = shiftY + (DerpEyesStrength * .15 * texSize)
      end
      if DerpEyes and not left then
        shiftY = shiftY - (DerpEyesStrength * .15 * texSize)
      end
      local textureData = {
        ['name'] = "PPM2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(self:GetID()) .. "_" .. tostring(EyeRefract and 'EyeRefract' or 'Eyes') .. "_" .. tostring(prefix),
        ['shader'] = EyeRefract and 'EyeRefract' or 'Eyes',
        ['data'] = {
          ['$iris'] = 'models/ppm2/base/face/p_base',
          ['$irisframe'] = '0',
          ['$ambientoccltexture'] = 'models/ppm2/eyes/eye_extra',
          ['$envmap'] = 'models/ppm2/eyes/eye_reflection',
          ['$corneatexture'] = 'models/ppm2/eyes/eye_cornea_oval',
          ['$lightwarptexture'] = 'models/ppm2/clothes/lightwarp',
          ['$eyeballradius'] = '3.7',
          ['$ambientocclcolor'] = '[0.3 0.3 0.3]',
          ['$dilation'] = '0.5',
          ['$glossiness'] = '1',
          ['$parallaxstrength'] = '0.1',
          ['$corneabumpstrength'] = '0.1',
          ['$halflambert'] = '1',
          ['$nodecal'] = '1',
          ['$raytracesphere'] = '0',
          ['$spheretexkillcombo'] = '0',
          ['$eyeorigin'] = '[0 0 0]',
          ['$irisu'] = '[0 1 0 0]',
          ['$irisv'] = '[0 0 1 0]',
          ['$entityorigin'] = '1.0'
        }
      }
      self["EyeMaterial" .. tostring(prefixUpper) .. "Name"] = "!" .. tostring(textureData.name:lower())
      local createdMaterial = CreateMaterial(textureData.name, textureData.shader, textureData.data)
      self["EyeMaterial" .. tostring(prefixUpper)] = createdMaterial
      self:UpdatePhongData()
      local IrisPos = texSize / 2 - texSize * IrisSize * PonySize / 2
      local IrisQuadSize = texSize * IrisSize * PonySize
      local HoleQuadSize = texSize * IrisSize * HoleSize * PonySize
      local HolePos = texSize / 2
      local holeX = HoleQuadSize * HoleWidth / 2
      local holeY = texSize * (IrisSize * HoleSize * HoleHeight * PonySize) / 2
      local calcHoleX = HolePos - holeX + holeX * HoleShiftX + shiftX
      local calcHoleY = HolePos - holeY + holeY * HoleShiftY + shiftY
      if EyeRefract then
        self:StartRT("EyeCornea_" .. tostring(prefix), texSize)
        if EyeCornerA then
          surface.SetMaterial(_M.EYE_CORNERA_OVAL)
          surface.SetDrawColor(255, 255, 255)
          DrawTexturedRectRotated(IrisPos + shiftX - texSize / 16, IrisPos + shiftY - texSize / 16, IrisQuadSize * IrisWidth * 1.5, IrisQuadSize * IrisHeight * 1.5, EyeRotation)
        end
        createdMaterial:SetTexture('$corneatexture', self:EndRT())
      end
      if EyeURL == '' or not EyeURL:find('^https?://') then
        local r, g, b, a
        r, g, b, a = EyeBackground.r, EyeBackground.g, EyeBackground.b, EyeBackground.a
        local rt = self:StartRTOpaque(tostring(EyeRefract and 'EyeRefract' or 'Eyes') .. "_" .. tostring(prefix), texSize, r, g, b)
        self["EyeTexture" .. tostring(prefixUpper)] = rt
        local drawMat = CreateMaterial("PPM2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(USE_HIGHRES_TEXTURES:GetBool() and 'HD' or 'NORMAL') .. "_" .. tostring(self:GetID()) .. "_" .. tostring(EyeRefract and 'EyeRefract' or 'Eyes') .. "_RenderMat_" .. tostring(prefix), 'UnlitGeneric', {
          ['$basetexture'] = 'models/debug/debugwhite',
          ['$ignorez'] = 1,
          ['$vertexcolor'] = 1,
          ['$vertexalpha'] = 1,
          ['$nolod'] = 1
        })
        self["EyeMaterialDraw" .. tostring(prefixUpper)] = drawMat
        drawMat:SetTexture('$basetexture', rt)
        surface.SetDrawColor(EyeIris1)
        surface.SetMaterial(self.__class.EYE_OVALS[EyeType + 1] or self.EYE_OVAL)
        DrawTexturedRectRotated(IrisPos + shiftX, IrisPos + shiftY, IrisQuadSize * IrisWidth, IrisQuadSize * IrisHeight, EyeRotation)
        surface.SetDrawColor(EyeIris2)
        surface.SetMaterial(self.__class.EYE_GRAD)
        DrawTexturedRectRotated(IrisPos + shiftX, IrisPos + shiftY, IrisQuadSize * IrisWidth, IrisQuadSize * IrisHeight, EyeRotation)
        if EyeLines then
          local lprefix = prefixUpper
          if not EyeLineDirection then
            lprefix = prefixUpperR
          end
          surface.SetDrawColor(EyeIrisLine1)
          surface.SetMaterial(self.__class["EYE_LINE_" .. tostring(lprefix) .. "_1"])
          DrawTexturedRectRotated(IrisPos + shiftX, IrisPos + shiftY, IrisQuadSize * IrisWidth, IrisQuadSize * IrisHeight, EyeRotation)
          surface.SetDrawColor(EyeIrisLine2)
          surface.SetMaterial(self.__class["EYE_LINE_" .. tostring(lprefix) .. "_2"])
          DrawTexturedRectRotated(IrisPos + shiftX, IrisPos + shiftY, IrisQuadSize * IrisWidth, IrisQuadSize * IrisHeight, EyeRotation)
        end
        surface.SetDrawColor(EyeHole)
        surface.SetMaterial(self.__class.EYE_OVALS[EyeType + 1] or self.EYE_OVAL)
        DrawTexturedRectRotated(calcHoleX, calcHoleY, HoleQuadSize * HoleWidth * IrisWidth, HoleQuadSize * HoleHeight * IrisHeight, EyeRotation)
        surface.SetDrawColor(EyeEffect)
        surface.SetMaterial(self.__class.EYE_EFFECT)
        DrawTexturedRectRotated(IrisPos + shiftX, IrisPos + shiftY, IrisQuadSize * IrisWidth, IrisQuadSize * IrisHeight, EyeRotation)
        surface.SetDrawColor(EyeReflection)
        surface.SetMaterial(_M.EYE_REFLECTIONS[EyeReflectionType + 1])
        DrawTexturedRectRotated(IrisPos + shiftX, IrisPos + shiftY, IrisQuadSize * IrisWidth, IrisQuadSize * IrisHeight, EyeRotation)
        self["EyeMaterial" .. tostring(prefixUpper)]:SetTexture('$iris', self:EndRT())
        PPM2.DebugPrint('Compiled eyes texture for ', self:GetEntity(), ' as part of ', self)
      else
        self.__class:LoadURL(EyeURL, texSize, texSize, function(texture, panel, material)
          return self["EyeMaterial" .. tostring(prefixUpper)]:SetTexture('$iris', texture)
        end)
      end
      return self["EyeMaterial" .. tostring(prefixUpper)]
    end,
    CompileCMark = function(self)
      if not (self.isValid) then
        return 
      end
      local textureData = {
        ['name'] = "PPM2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(self:GetID()) .. "_CMark",
        ['shader'] = 'VertexLitGeneric',
        ['data'] = {
          ['$basetexture'] = 'models/ppm2/partrender/null',
          ['$translucent'] = '1',
          ['$lightwarptexture'] = 'models/ppm2/base/lightwrap',
          ['$halflambert'] = '1'
        }
      }
      local textureDataGUI = {
        ['name'] = "PPM2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(self:GetID()) .. "_CMark_GUI",
        ['shader'] = 'UnlitGeneric',
        ['data'] = {
          ['$basetexture'] = 'models/ppm2/partrender/null',
          ['$translucent'] = '1',
          ['$lightwarptexture'] = 'models/ppm2/base/lightwrap',
          ['$halflambert'] = '1'
        }
      }
      self.CMarkTextureName = "!" .. tostring(textureData.name:lower())
      self.CMarkTexture = CreateMaterial(textureData.name, textureData.shader, textureData.data)
      self.CMarkTextureGUIName = "!" .. tostring(textureDataGUI.name:lower())
      self.CMarkTextureGUI = CreateMaterial(textureDataGUI.name, textureDataGUI.shader, textureDataGUI.data)
      if not (self:GrabData('CMark')) then
        self.CMarkTexture:SetTexture('$basetexture', 'models/ppm2/partrender/null')
        self.CMarkTextureGUI:SetTexture('$basetexture', 'models/ppm2/partrender/null')
        return self.CMarkTexture, self.CMarkTextureGUI
      end
      local URL = self:GrabData('CMarkURL')
      local size = self:GrabData('CMarkSize')
      local texSize = PPM2.GetTextureSize(self.__class.QUAD_SIZE_CMARK)
      local sizeQuad = texSize * size
      local shift = (texSize - sizeQuad) / 2
      if URL == '' or not URL:find('^https?://') then
        local rt = self:StartRT('CMark', texSize, 0, 0, 0, 0)
        do
          local mark = _M.CUTIEMARKS[self:GrabData('CMarkType') + 1]
          if mark then
            surface.SetDrawColor(self:GrabData('CMarkColor'))
            surface.SetMaterial(mark)
            surface.DrawTexturedRect(shift, shift, sizeQuad, sizeQuad)
          end
        end
        self:EndRT()
        self.CMarkTexture:SetTexture('$basetexture', rt)
        self.CMarkTextureGUI:SetTexture('$basetexture', rt)
        PPM2.DebugPrint('Compiled cutiemark texture for ', self:GetEntity(), ' as part of ', self)
      else
        self.__class:LoadURL(URL, texSize, texSize, function(texture, panel, material)
          local rt = self:StartRT('CMark', texSize, 0, 0, 0, 0)
          surface.SetDrawColor(self:GrabData('CMarkColor'))
          surface.SetMaterial(material)
          surface.DrawTexturedRect(shift, shift, sizeQuad, sizeQuad)
          self:EndRT()
          self.CMarkTexture:SetTexture('$basetexture', rt)
          self.CMarkTextureGUI:SetTexture('$basetexture', rt)
          return PPM2.DebugPrint('Compiled cutiemark texture for ', self:GetEntity(), ' as part of ', self)
        end)
      end
      return self.CMarkTexture, self.CMarkTextureGUI
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, controller, compile)
      if compile == nil then
        compile = true
      end
      _class_0.__parent.__init(self, controller:GetData())
      self.isValid = true
      self.cachedENT = self:GetEntity()
      self.id = self:GetEntity():EntIndex()
      if self.id == -1 then
        self.clientsideID = true
        self.id = self.__class.NEXT_GENERATED_ID
        self.__class.NEXT_GENERATED_ID = self.__class.NEXT_GENERATED_ID + 1
      end
      self.compiled = false
      self.lastMaterialUpdate = 0
      self.lastMaterialUpdateEnt = NULL
      self.delayCompilation = { }
      self.CheckReflectionsClosure = function()
        return self:CheckReflections()
      end
      if compile then
        self:CompileTextures()
      end
      return PPM2.DebugPrint('Created new texture controller for ', self:GetEntity(), ' as part of ', controller, '; internal ID is ', self.id)
    end,
    __base = _base_0,
    __name = "PonyTextureController",
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
  do
    local _tbl_0 = { }
    for i, val in pairs(_M.UPPER_MANE_DETAILS) do
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _, val1 in ipairs(val) do
          _accum_0[_len_0] = val1
          _len_0 = _len_0 + 1
        end
        _tbl_0[i] = _accum_0
      end
    end
    self.UPPER_MANE_MATERIALS = _tbl_0
  end
  do
    local _tbl_0 = { }
    for i, val in pairs(_M.LOWER_MANE_DETAILS) do
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _, val1 in ipairs(val) do
          _accum_0[_len_0] = val1
          _len_0 = _len_0 + 1
        end
        _tbl_0[i] = _accum_0
      end
    end
    self.LOWER_MANE_MATERIALS = _tbl_0
  end
  do
    local _tbl_0 = { }
    for i, val in pairs(_M.TAIL_DETAILS) do
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _, val1 in ipairs(val) do
          _accum_0[_len_0] = val1
          _len_0 = _len_0 + 1
        end
        _tbl_0[i] = _accum_0
      end
    end
    self.TAIL_DETAIL_MATERIALS = _tbl_0
  end
  self.HAIR_MATERIAL_COLOR = _M.HAIR_MATERIAL_COLOR
  self.TAIL_MATERIAL_COLOR = _M.TAIL_MATERIAL_COLOR
  self.WINGS_MATERIAL_COLOR = _M.WINGS_MATERIAL_COLOR
  self.HORN_MATERIAL_COLOR = _M.HORN_MATERIAL_COLOR
  self.BODY_MATERIAL = _M.BODY_MATERIAL
  self.HORN_DETAIL_COLOR = _M.HORN_DETAIL_COLOR
  self.EYE_OVAL = _M.EYE_OVAL
  self.EYE_OVALS = _M.EYE_OVALS
  self.EYE_GRAD = _M.EYE_GRAD
  self.EYE_EFFECT = _M.EYE_EFFECT
  self.EYE_LINE_L_1 = _M.EYE_LINE_L_1
  self.EYE_LINE_R_1 = _M.EYE_LINE_R_1
  self.EYE_LINE_L_2 = _M.EYE_LINE_L_2
  self.EYE_LINE_R_2 = _M.EYE_LINE_R_2
  self.PONY_SOCKS = _M.PONY_SOCKS
  self.SessionID = 1
  self.MAT_INDEX_EYE_LEFT = 0
  self.MAT_INDEX_EYE_RIGHT = 1
  self.MAT_INDEX_BODY = 2
  self.MAT_INDEX_HORN = 3
  self.MAT_INDEX_WINGS = 4
  self.MAT_INDEX_HAIR_COLOR1 = 5
  self.MAT_INDEX_HAIR_COLOR2 = 6
  self.MAT_INDEX_TAIL_COLOR1 = 7
  self.MAT_INDEX_TAIL_COLOR2 = 8
  self.MAT_INDEX_CMARK = 9
  self.MAT_INDEX_EYELASHES = 10
  self.NEXT_GENERATED_ID = 100000
  self.MANE_UPDATE_TRIGGER = {
    ['ManeType'] = true,
    ['ManeTypeLower'] = true
  }
  self.TAIL_UPDATE_TRIGGER = {
    ['TailType'] = true
  }
  self.EYE_UPDATE_TRIGGER = {
    ['SeparateEyes'] = true
  }
  self.PHONG_UPDATE_TRIGGER = {
    ['SeparateHornPhong'] = true,
    ['SeparateWingsPhong'] = true,
    ['SeparateManePhong'] = true,
    ['SeparateTailPhong'] = true
  }
  for _, ttype in ipairs({
    'Body',
    'Horn',
    'Wings',
    'BatWingsSkin',
    'Socks',
    'Mane',
    'Tail',
    'UpperMane',
    'LowerMane',
    'LEye',
    'REye',
    'BEyes',
    'Eyelashes'
  }) do
    self.PHONG_UPDATE_TRIGGER[ttype .. 'PhongExponent'] = true
    self.PHONG_UPDATE_TRIGGER[ttype .. 'PhongBoost'] = true
    self.PHONG_UPDATE_TRIGGER[ttype .. 'PhongTint'] = true
    self.PHONG_UPDATE_TRIGGER[ttype .. 'PhongFront'] = true
    self.PHONG_UPDATE_TRIGGER[ttype .. 'PhongMiddle'] = true
    self.PHONG_UPDATE_TRIGGER[ttype .. 'PhongSliding'] = true
    self.PHONG_UPDATE_TRIGGER[ttype .. 'Lightwarp'] = true
    self.PHONG_UPDATE_TRIGGER[ttype .. 'LightwarpURL'] = true
  end
  for _, publicName in ipairs({
    '',
    'Left',
    'Right'
  }) do
    self.EYE_UPDATE_TRIGGER["EyeType" .. tostring(publicName)] = true
    self.EYE_UPDATE_TRIGGER["HoleWidth" .. tostring(publicName)] = true
    self.EYE_UPDATE_TRIGGER["IrisSize" .. tostring(publicName)] = true
    self.EYE_UPDATE_TRIGGER["EyeLines" .. tostring(publicName)] = true
    self.EYE_UPDATE_TRIGGER["HoleSize" .. tostring(publicName)] = true
    self.EYE_UPDATE_TRIGGER["EyeBackground" .. tostring(publicName)] = true
    self.EYE_UPDATE_TRIGGER["EyeIrisTop" .. tostring(publicName)] = true
    self.EYE_UPDATE_TRIGGER["EyeIrisBottom" .. tostring(publicName)] = true
    self.EYE_UPDATE_TRIGGER["EyeIrisLine1" .. tostring(publicName)] = true
    self.EYE_UPDATE_TRIGGER["EyeIrisLine2" .. tostring(publicName)] = true
    self.EYE_UPDATE_TRIGGER["EyeHole" .. tostring(publicName)] = true
    self.EYE_UPDATE_TRIGGER["DerpEyesStrength" .. tostring(publicName)] = true
    self.EYE_UPDATE_TRIGGER["DerpEyes" .. tostring(publicName)] = true
    self.EYE_UPDATE_TRIGGER["EyeReflection" .. tostring(publicName)] = true
    self.EYE_UPDATE_TRIGGER["EyeEffect" .. tostring(publicName)] = true
    self.EYE_UPDATE_TRIGGER["EyeURL" .. tostring(publicName)] = true
    self.EYE_UPDATE_TRIGGER["IrisWidth" .. tostring(publicName)] = true
    self.EYE_UPDATE_TRIGGER["IrisHeight" .. tostring(publicName)] = true
    self.EYE_UPDATE_TRIGGER["HoleHeight" .. tostring(publicName)] = true
    self.EYE_UPDATE_TRIGGER["HoleShiftX" .. tostring(publicName)] = true
    self.EYE_UPDATE_TRIGGER["HoleShiftY" .. tostring(publicName)] = true
    self.EYE_UPDATE_TRIGGER["EyeRotation" .. tostring(publicName)] = true
    self.EYE_UPDATE_TRIGGER["PonySize"] = true
    self.EYE_UPDATE_TRIGGER["EyeRefract" .. tostring(publicName)] = true
    self.EYE_UPDATE_TRIGGER["EyeCornerA" .. tostring(publicName)] = true
    self.EYE_UPDATE_TRIGGER["EyeLineDirection" .. tostring(publicName)] = true
    self.EYE_UPDATE_TRIGGER["LEyeLightwarp"] = true
    self.EYE_UPDATE_TRIGGER["REyeLightwarp"] = true
    self.EYE_UPDATE_TRIGGER["LEyeLightwarpURL"] = true
    self.EYE_UPDATE_TRIGGER["REyeLightwarpURL"] = true
    self.EYE_UPDATE_TRIGGER["BEyesLightwarp"] = true
    self.EYE_UPDATE_TRIGGER["BEyesLightwarpURL"] = true
  end
  for i = 1, 6 do
    self.MANE_UPDATE_TRIGGER["ManeColor" .. tostring(i)] = true
    self.MANE_UPDATE_TRIGGER["ManeDetailColor" .. tostring(i)] = true
    self.MANE_UPDATE_TRIGGER["ManeURLColor" .. tostring(i)] = true
    self.MANE_UPDATE_TRIGGER["ManeURL" .. tostring(i)] = true
    self.MANE_UPDATE_TRIGGER["TailURL" .. tostring(i)] = true
    self.MANE_UPDATE_TRIGGER["TailURLColor" .. tostring(i)] = true
    self.TAIL_UPDATE_TRIGGER["TailColor" .. tostring(i)] = true
    self.TAIL_UPDATE_TRIGGER["TailDetailColor" .. tostring(i)] = true
  end
  self.BODY_UPDATE_TRIGGER = { }
  for i = 1, PPM2.MAX_BODY_DETAILS do
    self.BODY_UPDATE_TRIGGER["BodyDetail" .. tostring(i)] = true
    self.BODY_UPDATE_TRIGGER["BodyDetailColor" .. tostring(i)] = true
    self.BODY_UPDATE_TRIGGER["BodyDetailURLColor" .. tostring(i)] = true
    self.BODY_UPDATE_TRIGGER["BodyDetailURL" .. tostring(i)] = true
    self.BODY_UPDATE_TRIGGER["BodyDetailGlow" .. tostring(i)] = true
    self.BODY_UPDATE_TRIGGER["BodyDetailGlowStrength" .. tostring(i)] = true
  end
  for i = 1, PPM2.MAX_TATTOOS do
    self.BODY_UPDATE_TRIGGER["TattooType" .. tostring(i)] = true
    self.BODY_UPDATE_TRIGGER["TattooPosX" .. tostring(i)] = true
    self.BODY_UPDATE_TRIGGER["TattooPosY" .. tostring(i)] = true
    self.BODY_UPDATE_TRIGGER["TattooRotate" .. tostring(i)] = true
    self.BODY_UPDATE_TRIGGER["TattooScaleX" .. tostring(i)] = true
    self.BODY_UPDATE_TRIGGER["TattooScaleY" .. tostring(i)] = true
    self.BODY_UPDATE_TRIGGER["TattooColor" .. tostring(i)] = true
    self.BODY_UPDATE_TRIGGER["TattooGlow" .. tostring(i)] = true
    self.BODY_UPDATE_TRIGGER["TattooGlowStrength" .. tostring(i)] = true
    self.BODY_UPDATE_TRIGGER["TattooOverDetail" .. tostring(i)] = true
  end
  self.COMPILE_QUEUE = { }
  self.COMPILE_WAIT_UNTIL = 0
  self.COMPILE_THREAD = coroutine.create(function()
    while true do
      if #self.COMPILE_QUEUE == 0 then
        coroutine.yield()
      else
        if #self.COMPILE_QUEUE > 40 and #self.COMPILE_QUEUE % 20 == 0 then
          PPM2.LMessage('message.ppm2.queue_notify', #self.COMPILE_QUEUE)
        end
        local data = table.remove(self.COMPILE_QUEUE)
        if data.self:IsValid() then
          data.run(data.self, unpack(data.args))
          data.self.lastMaterialUpdate = 0
          coroutine.yield()
        end
      end
    end
  end)
  self.COMPILE_TEXTURES = function()
    if #self.COMPILE_QUEUE == 0 then
      return 
    end
    if self.COMPILE_WAIT_UNTIL < RealTimeL() then
      self.COMPILE_WAIT_UNTIL = RealTimeL() + 0.2
      coroutine.resume(self.COMPILE_THREAD)
    end
  end
  hook.Add('PreRender', 'PPM2.CompileTextures', self.COMPILE_TEXTURES, -1)
  self.HTML_MATERIAL_QUEUE = { }
  self.URL_MATERIAL_CACHE = { }
  self.ALREADY_DOWNLOADING = { }
  self.FAILED_TO_DOWNLOAD = { }
  self.LoadURL = function(self, url, width, height, callback)
    if width == nil then
      width = PPM2.GetTextureSize(self.QUAD_SIZE_CONST)
    end
    if height == nil then
      height = PPM2.GetTextureSize(self.QUAD_SIZE_CONST)
    end
    if callback == nil then
      callback = (function() end)
    end
    if not url or url == '' then
      error('Must specify URL')
    end
    self.URL_MATERIAL_CACHE[width] = self.URL_MATERIAL_CACHE[width] or { }
    self.URL_MATERIAL_CACHE[width][height] = self.URL_MATERIAL_CACHE[width][height] or { }
    self.ALREADY_DOWNLOADING[width] = self.ALREADY_DOWNLOADING[width] or { }
    self.ALREADY_DOWNLOADING[width][height] = self.ALREADY_DOWNLOADING[width][height] or { }
    self.FAILED_TO_DOWNLOAD[width] = self.FAILED_TO_DOWNLOAD[width] or { }
    self.FAILED_TO_DOWNLOAD[width][height] = self.FAILED_TO_DOWNLOAD[width][height] or { }
    if self.FAILED_TO_DOWNLOAD[width][height][url] then
      callback(self.FAILED_TO_DOWNLOAD[width][height][url].texture, nil, self.FAILED_TO_DOWNLOAD[width][height][url].material)
      return 
    end
    if self.ALREADY_DOWNLOADING[width][height][url] then
      for _, data in ipairs(self.HTML_MATERIAL_QUEUE) do
        if data.url == url then
          table.insert(data.callbacks, callback)
          break
        end
      end
      return 
    end
    if self.URL_MATERIAL_CACHE[width][height][url] then
      callback(self.URL_MATERIAL_CACHE[width][height][url].texture, nil, self.URL_MATERIAL_CACHE[width][height][url].material)
      return 
    end
    self.ALREADY_DOWNLOADING[width][height][url] = true
    return table.insert(self.HTML_MATERIAL_QUEUE, {
      url = url,
      width = width,
      height = height,
      callbacks = {
        callback
      },
      timeouts = 0
    })
  end
  self.BuildURLHTML = function(self, url, width, height)
    if url == nil then
      url = 'https://dbot.serealia.ca/illuminati.jpg'
    end
    if width == nil then
      width = PPM2.GetTextureSize(self.QUAD_SIZE_CONST)
    end
    if height == nil then
      height = PPM2.GetTextureSize(self.QUAD_SIZE_CONST)
    end
    url = url:Replace('%', '%25'):Replace(' ', '%20'):Replace('"', '%22'):Replace("'", '%27'):Replace('#', '%23'):Replace('<', '%3C'):Replace('=', '%3D'):Replace('>', '%3E')
    return "<html>\n					<head>\n						<style>\n							html, body {\n								background: transparent;\n								margin: 0;\n								padding: 0;\n								overflow: hidden;\n							}\n\n							#mainimage {\n								max-width: " .. tostring(width) .. ";\n								height: auto;\n								width: 100%;\n								margin: 0;\n								padding: 0;\n								max-height: " .. tostring(height) .. ";\n							}\n\n							#imgdiv {\n								width: " .. tostring(width) .. ";\n								height: " .. tostring(height) .. ";\n								overflow: hidden;\n								margin: 0;\n								padding: 0;\n								text-align: center;\n							}\n						</style>\n						<script>\n							window.onload = function() {\n								var img = document.getElementById('mainimage');\n								if (img.naturalWidth < img.naturalHeight) {\n									img.style.setProperty('height', '100%');\n									img.style.setProperty('width', 'auto');\n								}\n\n								img.style.setProperty('margin-top', (" .. tostring(height) .. " - img.height) / 2);\n\n								setInterval(function() {\n									console.log('FRAME');\n								}, 50);\n							};\n						</script>\n					</head>\n					<body>\n						<div id='imgdiv'>\n							<img src='" .. tostring(url) .. "' id='mainimage' />\n						</div>\n					</body>\n				</html>"
  end
  self.SHOULD_WAIT_WEB = false
  hook.Add('Think', 'PPM2.WebMaterialThink', function()
    if self.SHOULD_WAIT_WEB then
      return 
    end
    local data = self.HTML_MATERIAL_QUEUE[1]
    if not data then
      return 
    end
    if IsValid(data.panel) then
      local panel = data.panel
      if panel:IsLoading() then
        return 
      end
      if data.timerid then
        timer.Remove(data.timerid)
        data.timerid = nil
      end
      if data.frame < 20 then
        return 
      end
      self.SHOULD_WAIT_WEB = true
      timer.Simple(1, function()
        self.SHOULD_WAIT_WEB = false
        table.remove(self.HTML_MATERIAL_QUEUE, 1)
        if not (IsValid(panel)) then
          return 
        end
        panel:UpdateHTMLTexture()
        local htmlmat = panel:GetHTMLMaterial()
        if not htmlmat then
          return 
        end
        local texture = htmlmat:GetTexture('$basetexture')
        texture:Download()
        local newMat = CreateMaterial("PPM2.URLMaterial." .. tostring(texture:GetName()) .. "_" .. tostring(math.random(1, 100000)), 'UnlitGeneric', {
          ['$basetexture'] = 'models/debug/debugwhite',
          ['$ignorez'] = 1,
          ['$vertexcolor'] = 1,
          ['$vertexalpha'] = 1,
          ['$nolod'] = 1
        })
        newMat:SetTexture('$basetexture', texture)
        self.URL_MATERIAL_CACHE[data.width][data.height][data.url] = {
          texture = texture,
          material = newMat
        }
        self.ALREADY_DOWNLOADING[data.width][data.height][data.url] = false
        for _, callback in ipairs(data.callbacks) do
          callback(texture, panel, newMat)
        end
        return timer.Simple(0, function()
          if IsValid(panel) then
            return panel:Remove()
          end
        end)
      end)
      return 
    end
    data.frame = 0
    local panel = vgui.Create('DHTML')
    panel:SetVisible(false)
    panel:SetSize(data.width, data.height)
    panel:SetHTML(self:BuildURLHTML(data.url, data.width, data.height))
    panel:Refresh()
    panel.ConsoleMessage = function(pnl, msg)
      if msg == 'FRAME' then
        data.frame = data.frame + 1
      end
    end
    data.panel = panel
    data.timerid = "PPM2.TextureMaterialTimeout." .. tostring(math.random(1, 100000))
    return timer.Create(data.timerid, 8, 1, function()
      if not (IsValid(panel)) then
        return 
      end
      panel:Remove()
      if data.timeouts >= 4 then
        local newMat = CreateMaterial("PPM2.URLMaterial_Failed_" .. tostring(math.random(1, 100000)), 'UnlitGeneric', {
          ['$basetexture'] = 'models/ppm2/partrender/null',
          ['$ignorez'] = 1,
          ['$vertexcolor'] = 1,
          ['$vertexalpha'] = 1,
          ['$nolod'] = 1,
          ['$translucent'] = 1
        })
        self.FAILED_TO_DOWNLOAD[data.width][data.height][data.url] = {
          texture = newMat:GetTexture('$basetexture'),
          material = newMat
        }
        for _, callback in ipairs(data.callbacks) do
          callback(newMat:GetTexture('$basetexture'), nil, newMat)
        end
        return table.remove(self.HTML_MATERIAL_QUEUE, 1)
      else
        data.timeouts = data.timeouts + 1
        table.remove(self.HTML_MATERIAL_QUEUE, 1)
        return table.insert(self.HTML_MATERIAL_QUEUE, data)
      end
    end)
  end)
  self.MAT_INDEX_SOCKS = 0
  self.QUAD_SIZE_EYES = 512
  self.QUAD_SIZE_SOCKS = 512
  self.QUAD_SIZE_CMARK = 512
  self.QUAD_SIZE_CONST = 512
  self.QUAD_SIZE_WING = 64
  self.QUAD_SIZE_HORN = 128
  self.QUAD_SIZE_HAIR = 256
  self.QUAD_SIZE_TAIL = 256
  self.QUAD_SIZE_BODY = 1024
  self.TATTOO_DEF_SIZE = 128
  self.GetBodySize = function(self)
    return PPM2.GetTextureSize(self.QUAD_SIZE_BODY * (USE_HIGHRES_BODY:GetInt() + 1))
  end
  self.BUMP_COLOR = Color(127, 127, 255)
  self.REFLECT_RENDER_SIZE = 64
  self.GetReflectionsScale = function(self)
    local val = REAL_TIME_EYE_REFLECTIONS_SIZE:GetInt()
    if val % 2 ~= 0 then
      return self.REFLECT_RENDER_SIZE
    end
    return val
  end
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  PonyTextureController = _class_0
end
PPM2.PonyTextureController = PonyTextureController
PPM2.GetTextureController = function(model)
  if model == nil then
    model = 'models/ppm/player_default_base.mdl'
  end
  return PonyTextureController.AVALIABLE_CONTROLLERS[model:lower()] or PonyTextureController
end
