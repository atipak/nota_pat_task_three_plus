function getInfo()
	return {
		onNoUnits = SUCCESS,
		parameterDefs = {
      { 
				name = "unitToRescue",
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


-- load unit
function Run(self, unitIds, parameter) 
  -- gies through units array and check if the unit has a task or assigns a new task to it if there is a unit to rescue 
  local unitToRescue = parameter.unitToRescue
  local unitId = parameter.unitId 
  if isUnitOK(unitId) then
    -- loading  
    -- if the unit loaded a unit in danger, change its state to "move" and transport unit to first point of backpath 
    if isLoaded(unitId, unitToRescue) then
      return SUCCESS
    else
      Spring.GiveOrderToUnit(unitId, CMD.LOAD_UNITS, {unitToRescue}, {})
      return RUNNING
    end
  else 
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

function isLoaded(transporterID, transporteeID)
  -- transporterId 
  local tranID = Spring.GetUnitTransporter(transporteeID)
  return nil ~= tranID and tranID == transporterID
end
