local sensorInfo = {
	name = "CreatesTriplets",
	desc = "Add to given array with already stored keys a new key with begin positions",
	author = "Patik",
	date = "2018-05-11",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = -1 -- acutal, no caching

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT 
	}
end

-- global variable
actualRescueOperations = {}

-- is unit dead??
function isUnitOk(unitID)
  if not Spring.ValidUnitID(unitID) or Spring.GetUnitIsDead(unitID)then
      return false
    else
      return true
  end  
end


-- return a free unit to rescue
function getUnassignUnit(unitsIds, assignedUnits)
   for i = 1, #unitsIds do
    if not isUsing(unitsIds[i], assignedUnits) then
      return unitsIds[i]   
    end
  end
  return nil
end

-- is this unit used?
-- unitId = unit id which should be tested
-- usingUnits = ids of units which are alredy used
function isUsing(unitId, usingUnits) 
  for i = 1, #usingUnits do
    if usingUnits[i] == unitId then
      return true
    end
  end
  return false
end

-- filtres dead transporters
function getAlivedTransporters(transporters)
  local trans = {}
  for i = 1, #transporters do
    if isUnitOk(transporters[i]) then
      trans[#trans + 1] = transporters[i] 
    end 
  end
  return trans
end

-- get free transporter
-- usingTransporters = transporters which are used in this moment
function getFreeUnit(usingTransporters)
  for i = 1, #units do
    local unitId = units[i]
    if not isUsing(unitId, usingTransporters)  then
      return unitId  
    end
  end
  return nil
end

-- divide units into two groups, units which are alredy saved and units which have to be saved
function getDevidedUnits(unitsIds, safePos, safeRad)
  local rescuedUnits = {}
  local unitsInDanger = {}
  local indexRescued = 1
  local indexDanger = 1
  for i = 1, #unitsIds do
    local unitId = unitsIds[i]
    local lx, ly, lz = Spring.GetUnitPosition(unitId)
    local posVector = Vec3(lx, ly, lz)
    if isInArea(safePos, safeRad, posVector) then
      rescuedUnits[indexRescued] = unitId
      indexRescued = indexRescued + 1 
    else
      unitsInDanger[indexDanger] = unitId
      indexDanger = indexDanger + 1
    end
  end
  return {rescued = rescuedUnits, inDanger = unitsInDanger }
end

-- units which are operated with -> transporters, units to be rescued
-- unitsAvailable = count of units which are allowed operate 
function getOperationUnits(unitsAvailable)
 local transporters = {}
 local rescueUnits = {}
 for i = 1, unitsAvailable do
  if actualRescueOperations[i] ~= nil then
    transporters[#transporters + 1] = actualRescueOperations[i].transporter
    rescueUnits[#rescueUnits + 1] = actualRescueOperations[i].unitToRescue
  end
 end
 return {transporters = transporters, unitsToRescue = rescueUnits}
end

-- implementation of ternary operator
function ternary (cond , T , F)
    if cond then return T else return F end
end

function isInArea(basePosition, radius, position)
  return (position.x - basePosition.x)^2 + (position.z - basePosition.z)^2 <= radius^2
end



-- unitsAvailable = count of units which are allowed operate/ count of references nodes in parallel node
-- unitsToRescue = units, which have to be rescued
-- information about safe zone {"safePosition", "safeRadius"}
-- all my transporters, can have invalid ids
-- @description 
return function(unitsAvailable, unitsToRescue, safeInformation, transporters)
  local devidedUnits = getDevidedUnits(unitsToRescue, safeInformation.safePosition, safeInformation.safeRadius)
  local liveTransporters = getAlivedTransporters(transporters)
  local maxOps = ternary(#transporters > unitsAvailable, unitsAvailable, #transporters)  
  for i = 1, maxOps do
    if actualRescueOperations[i] == nil then
      -- no operation assigned
      local usingUnits = getOperationUnits(maxOps)
      local unitToRescue = getUnassignUnit(devidedUnits.inDanger, usingUnits.unitsToRescue)
      local transporter =  getFreeUnit(usingUnits.transporters)
      actualRescueOperations[i] = {transporter = transporter, unitToRescue = unitToRescue}
    else
      -- check correctness, life etc. 
      local unitToRescue = actualRescueOperations[i].unitToRescue
      local transporter =  actualRescueOperations[i].transporter
      if not isUnitOk(transporter) then
        actualRescueOperations[i] = nil  
      end
      if isInArea(safeInformation.safePosition, safeInformation.safeRadius, Vec3(Spring.GetUnitPosition(unitToRescue))) then
        actualRescueOperations[i] = nil
      end 
    end
  end
  return actualRescueOperations
end