local doPatch
doPatch = function(self)
  if not self:IsValid() then
    return 
  end
  local target
  for _, child in ipairs(self:GetChildren()) do
    if child:GetName() == 'DIconLayout' then
      target = child
      break
    end
  end
  if not target then
    return 
  end
  local buttonTarget
  for _, button in ipairs(target:GetChildren()) do
    local buttonChilds = button:GetChildren()
    local cond1 = buttonChilds[1] and buttonChilds[1]:GetName() == 'DLabel'
    local cond2 = buttonChilds[2] and buttonChilds[2]:GetName() == 'DLabel'
    if cond1 and buttonChilds[1]:GetText() == 'Player Model' then
      buttonTarget = button
      break
    elseif cond2 and buttonChilds[2]:GetText() == 'Player Model' then
      buttonTarget = button
      break
    end
  end
  if not buttonTarget then
    return 
  end
  local title, init, icon, width, height, onewindow
  do
    local _obj_0 = list.Get('DesktopWindows').PlayerEditor
    title, init, icon, width, height, onewindow = _obj_0.title, _obj_0.init, _obj_0.icon, _obj_0.width, _obj_0.height, _obj_0.onewindow
  end
  buttonTarget.DoClick = function()
    if onewindow and IsValid(buttonTarget.Window) then
      return buttonTarget.Window:Center()
    end
    buttonTarget.Window = self:Add('DFrame')
    do
      local _with_0 = buttonTarget.Window
      _with_0:SetSize(width, height)
      _with_0:SetTitle(title)
      _with_0:Center()
    end
    init(buttonTarget, buttonTarget.Window)
    local targetModel
    for _, child in ipairs(buttonTarget.Window:GetChildren()) do
      if child:GetName() == 'DModelPanel' then
        targetModel = child
        break
      end
    end
    if not targetModel then
      return 
    end
    targetModel.oldSetModel = targetModel.SetModel
    targetModel.SetModel = function(self, model)
      local oldModel = self.Entity:GetModel()
      local oldPonyData = self.Entity:GetPonyData()
      self:oldSetModel(model)
      if IsValid(self.Entity) and oldPonyData then
        oldPonyData:SetupEntity(self.Entity)
        return oldPonyData:ModelChanges(oldModel, model)
      end
    end
    targetModel.PreDrawModel = function(self, ent)
      local controller = self.ponyController
      if not controller then
        return 
      end
      if not ent:IsPony() then
        return 
      end
      if controller.ent ~= ent then
        controller:SetupEntity(ent)
      end
      controller:GetRenderController():DrawModels()
      controller:GetRenderController():PreDraw(ent)
      controller:GetRenderController():HideModels(true)
      local bg = controller:GetBodygroupController()
      if bg then
        return bg:ApplyBodygroups()
      end
    end
    local copy = PPM2.GetMainData():Copy()
    local controller = copy:CreateCustomController(targetModel.Entity)
    copy:SetController(controller)
    controller:SetDisableTask(true)
    targetModel.ponyController = controller
    return hook.Run('BuildPlayerModelMenu', buttonTarget, buttonTarget.Window)
  end
end
return hook.Add('ContextMenuCreated', 'PPM2.PatchPlayerModelMenu', function(self)
  return timer.Simple(0, function()
    return doPatch(self)
  end)
end)
