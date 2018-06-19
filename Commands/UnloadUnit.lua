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




-- unload unit
function Run(self, unitIds, parameter)  
  local unitId = parameter.unitId
  local unitToRescue = parameter.unitToRescue
  if isUnitOK(unitId) then
    if isUnloaded(unitId, unitToRescue) then
      return SUCCESS
    else 
      local lx, ly, lz = Spring.GetUnitPosition(unitId)  
      Spring.GiveOrderToUnit(unitId, CMD.UNLOAD_UNITS, {lx, ly, lz, 15} , {})
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

function isUnloaded(transporterID, transporteeID)
  return nil == Spring.GetUnitTransporter(transporteeID)
end

  