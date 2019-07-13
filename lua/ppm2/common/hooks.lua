DLib.nw.PoolBoolean('PPM2.InEditor', false)
do
  local GetModel, IsDormant, GetPonyData, IsValid
  do
    local _obj_0 = FindMetaTable('Entity')
    GetModel, IsDormant, GetPonyData, IsValid = _obj_0.GetModel, _obj_0.IsDormant, _obj_0.GetPonyData, _obj_0.IsValid
  end
  local callback
  callback = function()
    for _, ply in ipairs(player.GetAll()) do
      if not IsDormant(ply) then
        local model = GetModel(ply)
        ply.__ppm2_lastmodel = ply.__ppm2_lastmodel or model
        if ply.__ppm2_lastmodel ~= model then
          local data = GetPonyData(ply)
          if data and data.ModelChanges then
            local oldModel = ply.__ppm2_lastmodel
            ply.__ppm2_lastmodel = model
            data:ModelChanges(oldModel, model)
          end
        end
      end
    end
    for _, task in ipairs(PPM2.NetworkedPonyData.RenderTasks) do
      local ply = task.ent
      if IsValid(ply) and not IsDormant(ply) then
        local model = GetModel(ply)
        ply.__ppm2_lastmodel = ply.__ppm2_lastmodel or model
        if ply.__ppm2_lastmodel ~= model then
          local data = GetPonyData(ply)
          if data and data.ModelChanges then
            local oldModel = ply.__ppm2_lastmodel
            ply.__ppm2_lastmodel = model
            data:ModelChanges(oldModel, model)
          end
        end
      end
    end
  end
  timer.Create('PPM2.ModelWatchdog', 1, 0, function()
    local status, err = pcall(callback)
    if not status then
      return print('PPM2 Error: ' .. err)
    end
  end)
end
do
  local GetModel, IsDormant, GetPonyData, IsValid, IsPonyCached
  do
    local _obj_0 = FindMetaTable('Entity')
    GetModel, IsDormant, GetPonyData, IsValid, IsPonyCached = _obj_0.GetModel, _obj_0.IsDormant, _obj_0.GetPonyData, _obj_0.IsValid, _obj_0.IsPonyCached
  end
  hook.Add('Think', 'PPM2.PonyDataThink', function()
    for _, ply in ipairs(player.GetAll()) do
      if not IsDormant(ply) and IsPonyCached(ply) then
        local data = GetPonyData(ply)
        if data and data.Think then
          data:Think()
        end
      end
    end
    for _, task in ipairs(PPM2.NetworkedPonyData.RenderTasks) do
      local ply = task.ent
      if IsValid(ply) and not IsDormant(ply) and IsPonyCached(ply) and task.Think then
        task:Think()
      end
    end
  end)
  hook.Add('RenderScreenspaceEffects', 'PPM2.PonyDataRenderScreenspaceEffects', function()
    for _, ply in ipairs(player.GetAll()) do
      if not IsDormant(ply) and IsPonyCached(ply) then
        local data = GetPonyData(ply)
        if data and data.RenderScreenspaceEffects then
          data:RenderScreenspaceEffects()
        end
      end
    end
    for _, task in ipairs(PPM2.NetworkedPonyData.RenderTasks) do
      local ply = task.ent
      if IsValid(ply) and not IsDormant(ply) and IsPonyCached(ply) and task.RenderScreenspaceEffects then
        task:RenderScreenspaceEffects()
      end
    end
  end)
end
do
  local catchError
  catchError = function(err)
    PPM2.Message('Slow Update Error: ', err)
    return PPM2.Message(debug.traceback())
  end
  local Alive
  Alive = FindMetaTable('Player').Alive
  local IsPonyCached, IsDormant, GetPonyData
  do
    local _obj_0 = FindMetaTable('Entity')
    IsPonyCached, IsDormant, GetPonyData = _obj_0.IsPonyCached, _obj_0.IsDormant, _obj_0.GetPonyData
  end
  timer.Create('PPM2.SlowUpdate', CLIENT and 0.5 or 5, 0, function()
    for _, ply in ipairs(player.GetAll()) do
      if not IsDormant(ply) and Alive(ply) and IsPonyCached(ply) and GetPonyData(ply) then
        local data = GetPonyData(ply)
        if data.SlowUpdate then
          xpcall(data.SlowUpdate, catchError, data, CLIENT)
        end
      end
    end
    for _, task in ipairs(PPM2.NetworkedPonyData.RenderTasks) do
      if IsValid(task.ent) and task.ent:IsPony() then
        if task.SlowUpdate then
          xpcall(task.SlowUpdate, catchError, task, CLIENT)
        end
      end
    end
  end)
end
local ENABLE_TOOLGUN = CreateConVar('ppm2_sv_ragdoll_toolgun', '0', {
  FCVAR_REPLICATED,
  FCVAR_NOTIFY
}, 'Allow toolgun usage on player death ragdolls')
local ENABLE_PHYSGUN = CreateConVar('ppm2_sv_ragdoll_physgun', '1', {
  FCVAR_REPLICATED,
  FCVAR_NOTIFY
}, 'Allow physgun usage on player death ragdolls')
hook.Add('CanTool', 'PPM2.DeathRagdoll', function(ply, tr, tool)
  if ply == nil then
    ply = NULL
  end
  if tr == nil then
    tr = {
      Entity = NULL
    }
  end
  if tool == nil then
    tool = ''
  end
  if IsValid(tr.Entity) and tr.Entity:GetNWBool('PPM2.IsDeathRagdoll') and not ENABLE_TOOLGUN:GetBool() then
    return false
  end
end)
hook.Add('PhysgunPickup', 'PPM2.DeathRagdoll', function(ply, ent)
  if ply == nil then
    ply = NULL
  end
  if ent == nil then
    ent = NULL
  end
  if IsValid(ent) and ent:GetNWBool('PPM2.IsDeathRagdoll') and not ENABLE_PHYSGUN:GetBool() then
    return false
  end
end)
hook.Add('CanProperty', 'PPM2.DeathRagdoll', function(ply, mode, ent)
  if ply == nil then
    ply = NULL
  end
  if mode == nil then
    mode = ''
  end
  if ent == nil then
    ent = NULL
  end
  if IsValid(ent) and ent:GetNWBool('PPM2.IsDeathRagdoll') and not ENABLE_TOOLGUN:GetBool() then
    return false
  end
end)
return hook.Add('CanDrive', 'PPM2.DeathRagdoll', function(ply, ent)
  if ply == nil then
    ply = NULL
  end
  if ent == nil then
    ent = NULL
  end
  if IsValid(ent) and ent:GetNWBool('PPM2.IsDeathRagdoll') and not ENABLE_TOOLGUN:GetBool() then
    return false
  end
end)
