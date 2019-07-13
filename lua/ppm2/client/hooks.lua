DLib.RegisterAddonName('PPM/2')
local mat_dxlevel = GetConVar('mat_dxlevel')
timer.Create('PPM2.Unsupported', 600, 4, function()
  if mat_dxlevel:GetInt() >= 90 then
    timer.Remove('PPM2.Unsupported')
    return 
  end
  return Derma_Message('gui.ppm2.dxlevel.not_supported', 'gui.ppm2.dxlevel.toolow')
end)
timer.Create('PPM2.ModelChecks', 1, 0, function()
  for _, task in ipairs(PPM2.NetworkedPonyData.RenderTasks) do
    local ent = task.ent
    if IsValid(ent) then
      ent.__cachedIsPony = ent:IsPony()
    end
  end
  for _, ply in ipairs(player.GetAll()) do
    if not ply:IsDormant() then
      ply.__cachedIsPony = ply:IsPony()
      local ponydata = ply:GetPonyData()
      if ply.__cachedIsPony then
        if (not ponydata or ponydata:GetHideWeapons()) and not hook.Run('SuppressPonyWeaponsHide', ply) and not ply.RenderOverride then
          for _, wep in ipairs(ply:GetWeapons()) do
            if wep then
              if not hook.Run('ShouldDrawPonyWeapon', ply, wep) and (not wep.ShouldPonyDraw or not wep:ShouldPonyDraw(ply)) then
                wep:SetNoDraw(true)
                wep.__ppm2_weapon_hit = true
              elseif wep.__ppm2_weapon_hit then
                wep:SetNoDraw(false)
                ply.__ppm2_weapon_hit = false
              end
            end
          end
        else
          for _, wep in ipairs(ply:GetWeapons()) do
            if wep and wep.__ppm2_weapon_hit then
              wep:SetNoDraw(false)
              ply.__ppm2_weapon_hit = false
            end
          end
        end
      end
    end
  end
end)
local PlayerRespawn
PlayerRespawn = function()
  local ent = net.ReadEntity()
  if not IsValid(ent) then
    return 
  end
  if not ent:GetPonyData() then
    return 
  end
  return ent:GetPonyData():PlayerRespawn()
end
local PlayerDeath
PlayerDeath = function()
  local ent = net.ReadEntity()
  if not IsValid(ent) then
    return 
  end
  if not ent:GetPonyData() then
    return 
  end
  return ent:GetPonyData():PlayerDeath()
end
local lastDataSend = 0
local lastDataReceived = 0
net.Receive('PPM2.PlayerRespawn', PlayerRespawn)
net.Receive('PPM2.PlayerDeath', PlayerDeath)
concommand.Add('ppm2_require', function()
  net.Start('PPM2.Require')
  net.SendToServer()
  return PPM2.Message('Requesting pony data...')
end)
concommand.Add('ppm2_reload', function()
  if lastDataSend > RealTimeL() then
    return 
  end
  lastDataSend = RealTimeL() + 10
  local instance = PPM2.GetMainData()
  local newData = instance:CreateNetworkObject()
  newData:Create()
  instance:SetNetworkData(newData)
  return PPM2.Message('Sending pony data to server...')
end)
if not IsValid(LocalPlayer()) then
  local times = 0
  hook.Add('Think', 'PPM2.RequireData', function()
    local ply = LocalPlayer()
    if not IsValid(ply) then
      return 
    end
    if ply:GetVelocity():Length() > 5 then
      times = times + 1
    end
    if times < 200 then
      return 
    end
    hook.Remove('Think', 'PPM2.RequireData')
    return hook.Add('KeyPress', 'PPM2.RequireData', function()
      hook.Remove('KeyPress', 'PPM2.RequireData')
      RunConsoleCommand('ppm2_reload')
      return timer.Simple(3, function()
        return RunConsoleCommand('ppm2_require')
      end)
    end)
  end)
else
  timer.Simple(0, function()
    RunConsoleCommand('ppm2_reload')
    return timer.Simple(3, function()
      return RunConsoleCommand('ppm2_require')
    end)
  end)
end
local PPM_HINT_COLOR_FIRST = Color(255, 255, 255)
local PPM_HINT_COLOR_SECOND = Color(0, 0, 0)
net.receive('PPM2.EditorCamPos', function()
  local ply = net.ReadPlayer()
  if not ply:IsValid() then
    return 
  end
  local pVector, pAngle = net.ReadVector(), net.ReadAngle()
  if not IsValid(ply.__ppm2_cam) then
    ply.__ppm2_cam = ClientsideModel('models/tools/camera/camera.mdl', RENDERGROUP_BOTH)
    ply.__ppm2_cam:SetModelScale(0.4)
    ply.__ppm2_cam.RenderOverride = function(self)
      if not ply.__ppm2_campos_lerp then
        return 
      end
      render.DrawLine(ply.__ppm2_campos_lerp, ply:EyePos(), color_white, true)
      return self:DrawModel()
    end
    return hook.Add('Think', ply.__ppm2_cam, function(self)
      if not IsValid(ply) or not ply:GetNWBool('PPM2.InEditor') then
        return self:Remove()
      end
      local findPos, findAng = LocalToWorld(pVector, pAngle, ply:GetPos(), ply:EyeAngles())
      ply.__ppm2_campos_lerp = Lerp(RealFrameTime() * 22, ply.__ppm2_campos_lerp or findPos, findPos)
      self:SetPos(ply.__ppm2_campos_lerp)
      return self:SetAngles(findAng)
    end)
  end
end)
hook.Add('HUDPaint', 'PPM2.EditorStatus', function()
  local lply = LocalPlayer()
  local lpos = lply:EyePos()
  local editortext = DLib.i18n.localize('tip.ppm2.in_editor')
  local _list_0 = player.GetAll()
  for _index_0 = 1, #_list_0 do
    local ply = _list_0[_index_0]
    if ply ~= lply and ply:GetNWBool('PPM2.InEditor') then
      local pos = ply:EyePos()
      local dist = pos:Distance(lpos)
      if dist < 250 then
        pos.z = pos.z + 10
        local alpha = (1 - dist:progression(0, 250)):max(0.1) * 255
        local x, y
        do
          local _obj_0 = pos:ToScreen()
          x, y = _obj_0.x, _obj_0.y
        end
        draw.DrawText(editortext, 'HudHintTextLarge', x, y, Color(0, 0, 0, alpha), TEXT_ALIGN_CENTER)
        draw.DrawText(editortext, 'HudHintTextLarge', x + 1, y + 1, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER)
      end
      if ply.__ppm2_campos then
        pos = Vector(ply.__ppm2_campos)
        dist = pos:Distance(lpos)
        if dist < 250 then
          pos.z = pos.z + 9
          local alpha = (1 - dist:progression(0, 250)):max(0.1) * 255
          local x, y
          do
            local _obj_0 = pos:ToScreen()
            x, y = _obj_0.x, _obj_0.y
          end
          local text = DLib.i18n.localize('tip.ppm2.camera', ply:Nick())
          draw.DrawText(text, 'HudHintTextLarge', x, y, Color(0, 0, 0, alpha), TEXT_ALIGN_CENTER)
          draw.DrawText(text, 'HudHintTextLarge', x + 1, y + 1, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER)
        end
      end
    end
  end
end)
concommand.Add('ppm2_cleanup', function()
  for _, ent in ipairs(ents.GetAll()) do
    if ent.isPonyPropModel and not IsValid(ent.manePlayer) then
      ent:Remove()
    end
  end
  return PPM2.Message('All unused models were removed')
end)
timer.Create('PPM2.ModelCleanup', 60, 0, function()
  for _, ent in ipairs(ents.GetAll()) do
    if ent.isPonyPropModel and not IsValid(ent.manePlayer) then
      ent:Remove()
    end
  end
end)
cvars.AddChangeCallback('mat_picmip', (function()
  return timer.Simple(0, (function()
    RunConsoleCommand('ppm2_require')
    return RunConsoleCommand('ppm2_reload')
  end))
end), 'ppm2')
cvars.AddChangeCallback('ppm2_cl_hires_generic', (function()
  return timer.Simple(0, (function()
    RunConsoleCommand('ppm2_require')
    return RunConsoleCommand('ppm2_reload')
  end))
end), 'ppm2')
cvars.AddChangeCallback('ppm2_cl_hires_body', (function()
  return timer.Simple(0, (function()
    RunConsoleCommand('ppm2_require')
    return RunConsoleCommand('ppm2_reload')
  end))
end), 'ppm2')
