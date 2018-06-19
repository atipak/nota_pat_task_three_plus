function getInfo()
	return {
		onNoUnits = SUCCESS,
		parameterDefs = {
      { 
				name = "path",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "{}"
			}, 
      { 
				name = "unitId",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "{}"
			}
		}
	}
end

actualIndex = 1
local threshold = 50
launched = false
lastCheckTime = 0
timeout = 2
lastPosition = nil
moveThreshold = 10



-- goes along a path
function Run(self, unitIds, parameter) 
  -- gies through units array and check if the unit has a task or assigns a new task to it if there is a unit to rescue 
  local path = parameter.path
  local unitId = parameter.unitId
  if isUnitOK(unitId) then
    local targetPos = path[actualIndex]
    -- if the unit is on position, change its state to "load" and execute action
    if isUnitStuck(unitId) then
      Spring.GiveOrderToUnit(unitId, CMD.MOVE, path[actualIndex]:AsSpringVector(), {})
    end
    if isOnPosition(unitId, targetPos) then
      if actualIndex < #path then
        actualIndex = actualIndex + 1
        Spring.GiveOrderToUnit(unitId, CMD.MOVE, path[actualIndex]:AsSpringVector(), {})
      else
        actualIndex = 1
        launched = false
        return SUCCESS
      end
    end
    return RUNNING
  else
    actualIndex = 1 
    launched = false
    return FAILURE
  end
end



-- check function
function isUnitOK(unitID)
  if not Spring.ValidUnitID(unitID) or Spring.GetUnitIsDead(unitID) then
    transportersStates[unitID] = endedState
    return false
  else
    return true
  end
end       

function isOnPosition(unitId, target) 
  local x, y, z = Spring.GetUnitPosition(unitId)
  if math.abs(x - target.x) > threshold or math.abs(z - target.z) > threshold then
      return false  
  end 
  return true
end

function isUnitStuck(myId)
  local currentTime = os.clock()
  local stuck = false
  if lastCheckTime == 0 then
    lastCheckTime = currentTime
    lastPosition = Vec3(Spring.GetUnitPosition(myId))
  end
  if currentTime - lastCheckTime > timeout then
    local lx, ly, lz = Spring.GetUnitPosition(myId)
    --Spring.Echo(lx,ly,lz, lastPosition.x, lastPosition.y, lastPosition.z)
    if math.abs(lastPosition.x - lx) > moveThreshold or math.abs(lastPosition.y - ly) > moveThreshold or math.abs(lastPosition.z - lz) > moveThreshold then
      stuck = false  
    else 
      stuck = true
    end
    lastCheckTime = currentTime
    lastPosition = Vec3(lx,ly,lz)
  end
  return stuck
end
  