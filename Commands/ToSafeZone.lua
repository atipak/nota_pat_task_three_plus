function getInfo()
	return {
		onNoUnits = SUCCESS,
		parameterDefs = {
      { 
				name = "safePos",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "{}"
			},
      { 
				name = "safeRadius",
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

-- target location, where the unit should put down transportee
local safeZoneVector = nil
-- already rescued or being rescued units
local threshold = 50




-- transport unit to safe zone
function Run(self, unitIds, parameter) 
  -- gies through units array and check if the unit has a task or assigns a new task to it if there is a unit to rescue 
  local unitId = parameter.unitId
  local safeRadius = parameter.safeRadius
  local safePos = parameter.safePos
  if isUnitOK(unitId) then
    -- action hasnt started
    -- choosing safe vector
    if safeZoneVector == nil then
      local diff = 50
      local x = math.random(safeRadius - diff)
      local z = math.random(safeRadius - diff) 
      x = ternary(math.random() > 0.5, -1 * x, x) 
      z = ternary(math.random() > 0.5,  -1 * z, z) 
      local targetVector = Vec3(safePos.x + x, Spring.GetGroundHeight(safePos.x + x, safePos.z + z), safePos.z + z)
      safeZoneVector = targetVector
      Spring.GiveOrderToUnit(unitId, CMD.MOVE, safeZoneVector:AsSpringVector(), {})
    end
    local targetVector = safeZoneVector
    -- if the unit is on position, change its state to "unload" and execute action
    if isOnPosition(unitId, targetVector) then  
      safeZoneVector = nil                      
      return SUCCESS
    else 
      return RUNNING        
    end
  else 
    safeZoneVector = nil
    return FAILURE 
  end
end


-- implementation of ternary operator
function ternary (cond , T , F)
    if cond then return T else return F end
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

  