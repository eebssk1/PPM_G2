local USE_HIGHRES_BODY = PPM2.USE_HIGHRES_BODY
local USE_HIGHRES_TEXTURES = PPM2.USE_HIGHRES_TEXTURES
local NewPonyTextureController
do
  local _class_0
  local _parent_0 = PPM2.PonyTextureController
  local _base_0 = {
    __tostring = function(self)
      return "[" .. tostring(self.__class.__name) .. ":" .. tostring(self.objID) .. "|" .. tostring(self:GetData()) .. "]"
    end,
    DataChanges = function(self, state)
      if not (self.isValid) then
        return 
      end
      _class_0.__parent.__base.DataChanges(self, state)
      local _exp_0 = state:GetKey()
      if 'ManeTypeNew' == _exp_0 or 'ManeTypeLowerNew' == _exp_0 or 'TailTypeNew' == _exp_0 then
        return self:DelayCompile('CompileHair')
      elseif 'TeethColor' == _exp_0 or 'MouthColor' == _exp_0 or 'TongueColor' == _exp_0 then
        return self:DelayCompile('CompileMouth')
      elseif 'SeparateWings' == _exp_0 then
        self:DelayCompile('CompileBatWings')
        return self:DelayCompile('CompileBatWingsSkin')
      elseif 'BatWingColor' == _exp_0 or 'BatWingURL1' == _exp_0 or 'BatWingURL2' == _exp_0 or 'BatWingURL3' == _exp_0 or 'BatWingURLColor1' == _exp_0 or 'BatWingURLColor2' == _exp_0 or 'BatWingURLColor3' == _exp_0 then
        return self:DelayCompile('CompileBatWings')
      elseif 'BatWingSkinColor' == _exp_0 or 'BatWingSkinURL1' == _exp_0 or 'BatWingSkinURL2' == _exp_0 or 'BatWingSkinURL3' == _exp_0 or 'BatWingSkinURLColor1' == _exp_0 or 'BatWingSkinURLColor2' == _exp_0 or 'BatWingSkinURLColor3' == _exp_0 then
        return self:DelayCompile('CompileBatWingsSkin')
      end
    end,
    GetManeType = function(self)
      return self:GetData():GetManeTypeNew()
    end,
    GetManeTypeLower = function(self)
      return self:GetData():GetManeTypeLowerNew()
    end,
    GetTailType = function(self)
      return self:GetData():GetTailTypeNew()
    end,
    CompileHairInternal = function(self, prefix)
      if prefix == nil then
        prefix = 'Upper'
      end
      if not (self.isValid) then
        return 
      end
      local textureFirst = {
        ['name'] = "PPM2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(self:GetID()) .. "_Mane_1_" .. tostring(prefix),
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
        ['name'] = "PPM2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(self:GetID()) .. "_Mane_2_" .. tostring(prefix),
        ['shader'] = 'VertexLitGeneric',
        ['data'] = (function()
          local _tbl_0 = { }
          for k, v in pairs(textureFirst.data) do
            _tbl_0[k] = v
          end
          return _tbl_0
        end)()
      }
      local HairColor1MaterialName = "!" .. tostring(textureFirst.name:lower())
      local HairColor2MaterialName = "!" .. tostring(textureSecond.name:lower())
      local HairColor1Material = CreateMaterial(textureFirst.name, textureFirst.shader, textureFirst.data)
      local HairColor2Material = CreateMaterial(textureSecond.name, textureSecond.shader, textureSecond.data)
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
          local _obj_0 = self:GrabData(tostring(prefix) .. "ManeColor1")
          r, g, b = _obj_0.r, _obj_0.g, _obj_0.b
        end
        self:StartRTOpaque("Mane_rt_1_" .. tostring(prefix), texSize, r, g, b)
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
                local _obj_0 = self:GetData()["Get" .. tostring(prefix) .. "ManeDetailColor" .. tostring(i)](self:GetData())
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
          surface.SetDrawColor(self:GetData()["Get" .. tostring(prefix) .. "ManeURLColor" .. tostring(i)](self:GetData()))
          surface.SetMaterial(mat)
          surface.DrawTexturedRect(0, 0, texSize, texSize)
        end
        HairColor1Material:SetTexture('$basetexture', self:EndRT())
        do
          local _obj_0 = self:GrabData(tostring(prefix) .. "ManeColor2")
          r, g, b = _obj_0.r, _obj_0.g, _obj_0.b
        end
        self:StartRTOpaque("Mane_rt_2_" .. tostring(prefix), texSize, r, g, b)
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
                local _obj_0 = self:GetData()["Get" .. tostring(prefix) .. "ManeDetailColor" .. tostring(i)](self:GetData())
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
          surface.SetDrawColor(self:GetData()["Get" .. tostring(prefix) .. "ManeURLColor" .. tostring(i)](self:GetData()))
          surface.SetMaterial(mat)
          surface.DrawTexturedRect(0, 0, texSize, texSize)
        end
        HairColor2Material:SetTexture('$basetexture', self:EndRT())
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
            local detailURL = data["Get" .. tostring(prefix) .. "ManeURL" .. tostring(i)](data)
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
      return HairColor1Material, HairColor2Material, HairColor1MaterialName, HairColor2MaterialName
    end,
    GetBodyPhongMaterials = function(self, output)
      if output == nil then
        output = { }
      end
      _class_0.__parent.__base.GetBodyPhongMaterials(self, output)
      if not self:GrabData('SeparateWingsPhong') then
        if self.BatWingsMaterial then
          table.insert(output, self.BatWingsMaterial)
        end
        if self.BatWingsSkinMaterial then
          return table.insert(output, self.BatWingsSkinMaterial)
        end
      end
    end,
    UpdatePhongData = function(self)
      _class_0.__parent.__base.UpdatePhongData(self)
      if self:GrabData('SeparateWingsPhong') then
        self:ApplyPhongData(self.BatWingsMaterial, 'Wings')
        self:ApplyPhongData(self.BatWingsSkinMaterial, 'BatWingsSkin')
      end
      if self:GrabData('SeparateManePhong') then
        self:ApplyPhongData(self.UpperManeColor1, 'UpperMane')
        self:ApplyPhongData(self.UpperManeColor2, 'UpperMane')
        self:ApplyPhongData(self.LowerManeColor1, 'LowerMane')
        self:ApplyPhongData(self.LowerManeColor2, 'LowerMane')
      end
      if self.TeethMaterial then
        self:ApplyPhongData(self.TeethMaterial, 'Teeth')
      end
      if self.MouthMaterial then
        self:ApplyPhongData(self.MouthMaterial, 'Mouth')
      end
      if self.TongueMaterial then
        return self:ApplyPhongData(self.TongueMaterial, 'Tongue')
      end
    end,
    CompileBatWings = function(self)
      if not (self.isValid) then
        return 
      end
      local textureData = {
        ['name'] = "PPM2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(self:GetID()) .. "_BatWings",
        ['shader'] = 'VertexLitGeneric',
        ['data'] = {
          ['$basetexture'] = 'models/debug/debugwhite',
          ['$lightwarptexture'] = 'models/ppm2/base/lightwrap',
          ['$halflambert'] = '1',
          ['$model'] = '1',
          ['$phong'] = '1',
          ['$phongexponent'] = '0.1',
          ['$phongboost'] = '0.1',
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
      self.BatWingsMaterialName = "!" .. tostring(textureData.name:lower())
      self.BatWingsMaterial = CreateMaterial(textureData.name, textureData.shader, textureData.data)
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
            local _obj_0 = self:GrabData('BatWingColor')
            r, g, b = _obj_0.r, _obj_0.g, _obj_0.b
          end
        end
        self:StartRTOpaque('BatWings_rt', texSize, r, g, b)
        for i, mat in pairs(urlTextures) do
          local a
          do
            local _obj_0 = self:GetData()["GetBatWingURLColor" .. tostring(i)](self:GetData())
            r, g, b, a = _obj_0.r, _obj_0.g, _obj_0.b, _obj_0.a
          end
          surface.SetDrawColor(r, g, b, a)
          surface.SetMaterial(mat)
          surface.DrawTexturedRect(0, 0, texSize, texSize)
        end
        self.BatWingsMaterial:SetTexture('$basetexture', self:EndRT())
        return PPM2.DebugPrint('Compiled Bat Wings texture for ', self:GetEntity(), ' as part of ', self)
      end
      local data = self:GetData()
      local validURLS
      do
        local _accum_0 = { }
        local _len_0 = 1
        for i = 1, 3 do
          local _continue_0 = false
          repeat
            local detailURL = data["GetBatWingURL" .. tostring(i)](data)
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
      return self.BatWingsMaterial
    end,
    CompileBatWingsSkin = function(self)
      if not (self.isValid) then
        return 
      end
      local textureData = {
        ['name'] = "PPM2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(self:GetID()) .. "_BatWingsSkin",
        ['shader'] = 'VertexLitGeneric',
        ['data'] = {
          ['$basetexture'] = 'models/debug/debugwhite',
          ['$lightwarptexture'] = 'models/ppm2/base/lightwrap',
          ['$halflambert'] = '1',
          ['$model'] = '1',
          ['$phong'] = '1',
          ['$phongexponent'] = '0.1',
          ['$phongboost'] = '0.1',
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
      self.BatWingsSkinMaterialName = "!" .. tostring(textureData.name:lower())
      self.BatWingsSkinMaterial = CreateMaterial(textureData.name, textureData.shader, textureData.data)
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
            local _obj_0 = self:GrabData('BatWingSkinColor')
            r, g, b = _obj_0.r, _obj_0.g, _obj_0.b
          end
        end
        self:StartRTOpaque('BatWingsSkin_rt', texSize, r, g, b)
        for i, mat in pairs(urlTextures) do
          local a
          do
            local _obj_0 = self:GetData()["GetBatWingSkinURLColor" .. tostring(i)](self:GetData())
            r, g, b, a = _obj_0.r, _obj_0.g, _obj_0.b, _obj_0.a
          end
          surface.SetDrawColor(r, g, b, a)
          surface.SetMaterial(mat)
          surface.DrawTexturedRect(0, 0, texSize, texSize)
        end
        self.BatWingsSkinMaterial:SetTexture('$basetexture', self:EndRT())
        return PPM2.DebugPrint('Compiled Bat Wings skin texture for ', self:GetEntity(), ' as part of ', self)
      end
      local data = self:GetData()
      local validURLS
      do
        local _accum_0 = { }
        local _len_0 = 1
        for i = 1, 3 do
          local _continue_0 = false
          repeat
            local detailURL = data["GetBatWingSkinURL" .. tostring(i)](data)
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
      return self.BatWingsSkinMaterial
    end,
    CompileHair = function(self)
      if not (self.isValid) then
        return 
      end
      if not self:GetData():GetSeparateMane() then
        return _class_0.__parent.__base.CompileHair(self)
      end
      local mat1, mat2, name1, name2 = self:CompileHairInternal('Upper')
      local mat3, mat4, name3, name4 = self:CompileHairInternal('Lower')
      self.UpperManeColor1, self.UpperManeColor2 = mat1, mat2
      self.LowerManeColor1, self.LowerManeColor2 = mat3, mat4
      self.UpperManeColor1Name, self.UpperManeColor2Name = name1, name2
      self.LowerManeColor1Name, self.LowerManeColor2Name = name3, name4
      return mat1, mat2, mat3, mat4
    end,
    CompileMouth = function(self)
      local textureData = {
        ['$basetexture'] = 'models/debug/debugwhite',
        ['$lightwarptexture'] = 'models/ppm2/base/lightwrap',
        ['$halflambert'] = '1',
        ['$phong'] = '1',
        ['$phongexponent'] = '20',
        ['$phongboost'] = '.1',
        ['$phongfresnelranges'] = '[.3 1 8]',
        ['$halflambert'] = '0',
        ['$basemapalphaphongmask'] = '1',
        ['$rimlight'] = '1',
        ['$rimlightexponent'] = '4',
        ['$rimlightboost'] = '2',
        ['$color'] = '[1 1 1]',
        ['$color2'] = '[1 1 1]',
        ['$ambientocclusion'] = '1'
      }
      local r, g, b
      do
        local _obj_0 = self:GrabData('TeethColor')
        r, g, b = _obj_0.r, _obj_0.g, _obj_0.b
      end
      self.TeethMaterialName = "!ppm2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(self:GetID()) .. "_teeth"
      self.TeethMaterial = CreateMaterial("ppm2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(self:GetID()) .. "_teeth", 'VertexLitGeneric', textureData)
      self.TeethMaterial:SetVector('$color', Vector(r / 255, g / 255, b / 255))
      self.TeethMaterial:SetVector('$color2', Vector(r / 255, g / 255, b / 255))
      do
        local _obj_0 = self:GrabData('MouthColor')
        r, g, b = _obj_0.r, _obj_0.g, _obj_0.b
      end
      self.MouthMaterialName = "!ppm2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(self:GetID()) .. "_mouth"
      self.MouthMaterial = CreateMaterial("ppm2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(self:GetID()) .. "_mouth", 'VertexLitGeneric', textureData)
      self.MouthMaterial:SetVector('$color', Vector(r / 255, g / 255, b / 255))
      self.MouthMaterial:SetVector('$color2', Vector(r / 255, g / 255, b / 255))
      do
        local _obj_0 = self:GrabData('TongueColor')
        r, g, b = _obj_0.r, _obj_0.g, _obj_0.b
      end
      self.TongueMaterialName = "!ppm2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(self:GetID()) .. "_tongue"
      self.TongueMaterial = CreateMaterial("ppm2_" .. tostring(self.__class.SessionID) .. "_" .. tostring(self:GetID()) .. "_tongue", 'VertexLitGeneric', textureData)
      self.TongueMaterial:SetVector('$color', Vector(r / 255, g / 255, b / 255))
      self.TongueMaterial:SetVector('$color2', Vector(r / 255, g / 255, b / 255))
      self:UpdatePhongData()
      PPM2.DebugPrint('Compiled mouth textures for ', self:GetEntity(), ' as part of ', self)
      return self.TeethMaterial, self.MouthMaterial, self.TongueMaterial
    end,
    CompileTextures = function(self)
      if not self:GetData():IsValid() then
        return 
      end
      _class_0.__parent.__base.CompileTextures(self)
      self:DelayCompile('CompileMouth')
      self:DelayCompile('CompileBatWingsSkin')
      return self:DelayCompile('CompileBatWings')
    end,
    GetTeeth = function(self)
      return self.TeethMaterial
    end,
    GetMouth = function(self)
      return self.MouthMaterial
    end,
    GetTongue = function(self)
      return self.TongueMaterial
    end,
    GetBatWings = function(self)
      return self.BatWingsMaterial
    end,
    GetBatWingsSkin = function(self)
      return self.BatWingsSkinMaterial
    end,
    GetBatWingsName = function(self)
      return self.BatWingsMaterialName
    end,
    GetBatWingsSkinName = function(self)
      return self.BatWingsSkinMaterialName
    end,
    GetTeethName = function(self)
      return self.TeethMaterialName
    end,
    GetMouthName = function(self)
      return self.MouthMaterialName
    end,
    GetTongueName = function(self)
      return self.TongueMaterialName
    end,
    GetUpperHair = function(self, index)
      if index == nil then
        index = 1
      end
      if index == 2 then
        return self.UpperManeColor2
      else
        return self.UpperManeColor1
      end
    end,
    GetLowerHair = function(self, index)
      if index == nil then
        index = 1
      end
      if index == 2 then
        return self.LowerManeColor2
      else
        return self.LowerManeColor1
      end
    end,
    GetUpperHairName = function(self, index)
      if index == nil then
        index = 1
      end
      if index == 2 then
        return self.UpperManeColor2Name
      else
        return self.UpperManeColor1Name
      end
    end,
    GetLowerHairName = function(self, index)
      if index == nil then
        index = 1
      end
      if index == 2 then
        return self.LowerManeColor2Name
      else
        return self.LowerManeColor1Name
      end
    end,
    UpdateUpperMane = function(self, ent, entMane)
      if ent == nil then
        ent = self:GetEntity()
      end
      if not (self.isValid) then
        return 
      end
      if not self:GetData():GetSeparateMane() then
        entMane:SetSubMaterial(self.__class.MAT_INDEX_HAIR_COLOR1, self:GetManeName(1))
        return entMane:SetSubMaterial(self.__class.MAT_INDEX_HAIR_COLOR2, self:GetManeName(2))
      else
        entMane:SetSubMaterial(self.__class.MAT_INDEX_HAIR_COLOR1, self:GetUpperHairName(1))
        return entMane:SetSubMaterial(self.__class.MAT_INDEX_HAIR_COLOR2, self:GetUpperHairName(2))
      end
    end,
    UpdateLowerMane = function(self, ent, entMane)
      if ent == nil then
        ent = self:GetEntity()
      end
      if not (self.isValid) then
        return 
      end
      if not self:GetData():GetSeparateMane() then
        entMane:SetSubMaterial(self.__class.MAT_INDEX_HAIR_COLOR1, self:GetManeName(1))
        return entMane:SetSubMaterial(self.__class.MAT_INDEX_HAIR_COLOR2, self:GetManeName(2))
      else
        entMane:SetSubMaterial(self.__class.MAT_INDEX_HAIR_COLOR1, self:GetLowerHairName(1))
        return entMane:SetSubMaterial(self.__class.MAT_INDEX_HAIR_COLOR2, self:GetLowerHairName(2))
      end
    end,
    UpdateTail = function(self, ent, entTail)
      if ent == nil then
        ent = self:GetEntity()
      end
      if not (self.isValid) then
        return 
      end
      entTail:SetSubMaterial(self.__class.MAT_INDEX_HAIR_COLOR1, self:GetTailName(1))
      return entTail:SetSubMaterial(self.__class.MAT_INDEX_HAIR_COLOR2, self:GetTailName(2))
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
        ent:SetSubMaterial(self.__class.MAT_INDEX_TONGUE, self:GetTongueName())
        ent:SetSubMaterial(self.__class.MAT_INDEX_TEETH, self:GetTeethName())
        ent:SetSubMaterial(self.__class.MAT_INDEX_MOUTH, self:GetMouthName())
        ent:SetSubMaterial(self.__class.MAT_INDEX_BODY, self:GetBodyName())
        ent:SetSubMaterial(self.__class.MAT_INDEX_HORN, self:GetHornName())
        ent:SetSubMaterial(self.__class.MAT_INDEX_WINGS, self:GetWingsName())
        ent:SetSubMaterial(self.__class.MAT_INDEX_CMARK, self:GetCMarkName())
        ent:SetSubMaterial(self.__class.MAT_INDEX_EYELASHES, self.EyelashesName)
        ent:SetSubMaterial(self.__class.MAT_INDEX_WINGS_BAT, self:GetBatWingsName())
        ent:SetSubMaterial(self.__class.MAT_INDEX_WINGS_BAT_SKIN, self:GetBatWingsSkinName())
      end
      if drawingNewTask then
        render.MaterialOverrideByIndex(self.__class.MAT_INDEX_EYE_LEFT, self:GetEye(true))
        render.MaterialOverrideByIndex(self.__class.MAT_INDEX_EYE_RIGHT, self:GetEye(false))
        render.MaterialOverrideByIndex(self.__class.MAT_INDEX_TONGUE, self:GetTongue())
        render.MaterialOverrideByIndex(self.__class.MAT_INDEX_TEETH, self:GetTeeth())
        render.MaterialOverrideByIndex(self.__class.MAT_INDEX_MOUTH, self:GetMouth())
        render.MaterialOverrideByIndex(self.__class.MAT_INDEX_BODY, self:GetBody())
        render.MaterialOverrideByIndex(self.__class.MAT_INDEX_HORN, self:GetHorn())
        render.MaterialOverrideByIndex(self.__class.MAT_INDEX_WINGS, self:GetWings())
        render.MaterialOverrideByIndex(self.__class.MAT_INDEX_CMARK, self:GetCMark())
        render.MaterialOverrideByIndex(self.__class.MAT_INDEX_EYELASHES, self.Eyelashes)
        render.MaterialOverrideByIndex(self.__class.MAT_INDEX_WINGS_BAT, self:GetBatWings())
        return render.MaterialOverrideByIndex(self.__class.MAT_INDEX_WINGS_BAT_SKIN, self:GetBatWingsSkin())
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
      render.MaterialOverrideByIndex(self.__class.MAT_INDEX_TONGUE)
      render.MaterialOverrideByIndex(self.__class.MAT_INDEX_TEETH)
      render.MaterialOverrideByIndex(self.__class.MAT_INDEX_MOUTH)
      render.MaterialOverrideByIndex(self.__class.MAT_INDEX_BODY)
      render.MaterialOverrideByIndex(self.__class.MAT_INDEX_HORN)
      render.MaterialOverrideByIndex(self.__class.MAT_INDEX_WINGS)
      render.MaterialOverrideByIndex(self.__class.MAT_INDEX_CMARK)
      render.MaterialOverrideByIndex(self.__class.MAT_INDEX_EYELASHES)
      render.MaterialOverrideByIndex(self.__class.MAT_INDEX_WINGS_BAT)
      return render.MaterialOverrideByIndex(self.__class.MAT_INDEX_WINGS_BAT_SKIN)
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
      ent:SetSubMaterial(self.__class.MAT_INDEX_TONGUE)
      ent:SetSubMaterial(self.__class.MAT_INDEX_TEETH)
      ent:SetSubMaterial(self.__class.MAT_INDEX_MOUTH)
      ent:SetSubMaterial(self.__class.MAT_INDEX_BODY)
      ent:SetSubMaterial(self.__class.MAT_INDEX_HORN)
      ent:SetSubMaterial(self.__class.MAT_INDEX_WINGS)
      ent:SetSubMaterial(self.__class.MAT_INDEX_CMARK)
      ent:SetSubMaterial(self.__class.MAT_INDEX_EYELASHES)
      ent:SetSubMaterial(self.__class.MAT_INDEX_WINGS_BAT)
      return ent:SetSubMaterial(self.__class.MAT_INDEX_WINGS_BAT_SKIN)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "NewPonyTextureController",
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
  do
    local _tbl_0 = { }
    for i, val in pairs(self.UPPER_MANE_MATERIALS) do
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
    for i, val in pairs(self.LOWER_MANE_MATERIALS) do
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
    for i, val in pairs(self.TAIL_DETAIL_MATERIALS) do
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
  do
    local _tbl_0 = { }
    for k, v in pairs(PPM2.PonyTextureController.PHONG_UPDATE_TRIGGER) do
      _tbl_0[k] = v
    end
    self.PHONG_UPDATE_TRIGGER = _tbl_0
  end
  for _, ttype in ipairs({
    'Mouth',
    'Teeth',
    'Tongue'
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
  self.MAT_INDEX_CMARK = 0
  self.MAT_INDEX_EYELASHES = 3
  self.MAT_INDEX_TONGUE = 1
  self.MAT_INDEX_BODY = 2
  self.MAT_INDEX_TEETH = 5
  self.MAT_INDEX_EYE_LEFT = 7
  self.MAT_INDEX_EYE_RIGHT = 4
  self.MAT_INDEX_MOUTH = 6
  self.MAT_INDEX_HORN = 8
  self.MAT_INDEX_WINGS = 9
  self.MAT_INDEX_WINGS_BAT = 10
  self.MAT_INDEX_WINGS_BAT_SKIN = 11
  self.MAT_INDEX_HAIR_COLOR1 = 0
  self.MAT_INDEX_HAIR_COLOR2 = 1
  self.MAT_INDEX_TAIL_COLOR1 = 0
  self.MAT_INDEX_TAIL_COLOR2 = 1
  do
    local _tbl_0 = { }
    for key, value in pairs(self.MANE_UPDATE_TRIGGER) do
      _tbl_0[key] = value
    end
    self.MANE_UPDATE_TRIGGER = _tbl_0
  end
  self.MANE_UPDATE_TRIGGER['ManeTypeNew'] = true
  self.MANE_UPDATE_TRIGGER['SeparateMane'] = true
  self.MANE_UPDATE_TRIGGER['ManeTypeLowerNew'] = true
  for i = 1, 6 do
    self.MANE_UPDATE_TRIGGER["LowerManeColor" .. tostring(i)] = true
    self.MANE_UPDATE_TRIGGER["UpperManeColor" .. tostring(i)] = true
    self.MANE_UPDATE_TRIGGER["LowerManeDetailColor" .. tostring(i)] = true
    self.MANE_UPDATE_TRIGGER["UpperManeDetailColor" .. tostring(i)] = true
    self.MANE_UPDATE_TRIGGER["LowerManeURL" .. tostring(i)] = true
    self.MANE_UPDATE_TRIGGER["LowerManeURLColor" .. tostring(i)] = true
    self.MANE_UPDATE_TRIGGER["UpperManeURL" .. tostring(i)] = true
    self.MANE_UPDATE_TRIGGER["UpperManeURLColor" .. tostring(i)] = true
  end
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  NewPonyTextureController = _class_0
end
PPM2.NewPonyTextureController = NewPonyTextureController
