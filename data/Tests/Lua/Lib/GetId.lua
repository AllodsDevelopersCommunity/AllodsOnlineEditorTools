-- author: Liventsev Andrey, date: 25.06.2008
-- ������ ��� ��������� ������������ id


-- ���������� id ���������� �� ����� �� ����� ������ ������� ��� nil
function GetSpellId( nameSpell)
   local spellBook = avatar.GetSpellBook()
   for i, idSpell in spellBook do
	  local spellInfo = avatar.GetSpellInfo( idSpell )
	  if spellInfo.debugName == nameSpell or string.find( spellInfo.debugName, nameSpell ) then
	     return idSpell
	  end
   end
   
   return nil
end

-- ���������� ���������� � ���� ��� nil
function GetBuffInfo( unitId, buffName )
	local count = unit.GetBuffCount( unitId )
	local i=0
	for i=0, count-1 do
	    local buff = unit.GetBuff( unitId, i )
	    if buff.debugName == buffName or string.find( buff.debugName, buffName ) then
	        return buff
	    end
	end
	
	return nil
end

-- ���������� id ������ �� ����� �� ������ �������� ������� ������� ��� nil
function GetQuestId( questName )
	local book = avatar.GetQuestBook()
	for index, questId in book do
		local quest = avatar.GetQuestInfo(questId)
	    if quest.debugName == questName then
	        return questId
	    end
	end

	return nil
end

function GetQuestInfo( questName )
	local book = avatar.GetQuestBook()
	for index, questId in book do
		local quest = avatar.GetQuestInfo( questId )
	    if quest.debugName == questName then
	        return quest
	    end
	end

	return nil
end	

function GetQuestProgress( questName )
	local book = avatar.GetQuestBook()
	for index, questId in book do
		local quest = avatar.GetQuestInfo( questId )
	    if quest.debugName == questName then
	        return avatar.GetQuestProgress( questId )
	    end
	end

	return nil
end

function GetQuestObjective( questName, objectiveName )
	local info = GetQuestProgress( questName )
	for index, objective in info.objectives do 
		if objective.sysDebugName == objectiveName then
			return objective
		end
	end

	return nil
end

-- ���������� id �������� �� ��������� �� ��� ����� ��� nil
function GetItemId( itemName )
	local ids = avatar.GetInventoryItemIds()

	for index, id in ids do 
		local itemInfo = avatar.GetItemInfo( id )
		if itemInfo.debugInstanceFileName == itemName then
			return id
		end
	end
	
	return nil
end


-- ���������� ���������� ��������� itemName �� ������� �������
function GetCountItem( itemName, withLog )
	local result = 0
	local ids = avatar.GetInventoryItemIds()

	for index, id in ids do 
		local itemInfo = avatar.GetItemInfo( id )
		if withLog ~= nil then
		    Log( itemInfo.debugInstanceFileName .. " == " .. itemName, "GetId" )
		end
		if itemInfo.debugInstanceFileName == itemName then
			result = result + itemInfo.stackCount
		end
	end

	return result
end

-- ���������� ����� ����� ��� �������� ��� nil
function GetItemSlot( itemName )
	local countItems = avatar.GetInventorySize()
	local i
	for i=0, countItems-1 do
		local itemId = avatar.GetInventoryItemId( i )
		if itemId ~= nil then
			local itemInfo = avatar.GetItemInfo( itemId )
			if itemInfo.debugInstanceFileName == itemName then
				return i
			end
		end
	end

	return nil
end

-- ���������� ���������� � �������� �� �����
function GetItemInfo( slot )
	local itemId = avatar.GetInventoryItemId( slot )
	return avatar.GetItemInfo( itemId )
end

-- ���������� itemInfo �������� �� ����� dressSlot ������� �� ������� ��� nil
function GetEquipItemByDressSlot( dressSlot )
	for index, itemId in unit.GetEquipmentItemIds( avatar.GetId()) do
		if itemId ~= nil then
			local info = avatar.GetItemInfo( itemId )
			if info.dressSlot == dressSlot then
				return info
			end
		end
	end
	
	return nil
end

function GetDPSByItemInfo( info )
	return GetDPS( info.bonus.misc.minDamage, info.bonus.misc.maxDamage, info.bonus.misc.weaponSpeed )
end

function GetDPS( minDmg, maxDmg, speed )
	return (minDmg+maxDmg)/(2*speed)
end

-- ���������� id ������ �� ����� �� ������ ������� npc
function GetAvailableQuestId( questName )
	local quests = avatar.GetAvailableQuests()

	for index, questId in quests do
		local quest = avatar.GetQuestInfo(questId)
	    if quest.debugName == questName then
	        return questId
	    end
	end
	
	return nil
end

-- ���������� id ������� ���������� ���� �� ��� �����, ������� ��������� � ���� ��������� ������� ��� nil
-- ���� �������� isDead �� ������ ������ ������ ����, ���� true - ��������
function GetMobId( mobName, isDead )
	local mobs = avatar.GetUnitList()
	
	for count, mobId in mobs do
		local dead = unit.IsDead( mobId )
		
		if qaMission.UnitGetXDB( mobId ) == mobName then
			local distance = GetDistanceBetweenPoints( debugMission.InteractiveObjectGetPos( mobId ), avatar.GetPos() )
		    if distance <= 50 then
				if isDead ~= nil and isDead == true and dead then
					return mobId
				elseif (isDead == nil or isDead == false) and not dead then
				    return mobId
				end
			end
		end
	end

	return nil
end

-- ���������� id ������� ���������� ����������, ������� ������������ ����� �������, �� ��� ����� ��� nil
-- distance - �������������� ��������. ���� ����� - ���� � �������� �������
function GetDevId( devName, distance )
	local devices = avatar.GetDeviceList()
	
	for index, id in devices do
		local xdb = qaMission.DeviceGetDebugName( id )
		if xdb == devName and device.IsUsable( id ) then
			if distance == nil or GetDistanceFromPosition( id, avatar.GetPos()) <= distance then
				return id
			end
		end
	end
	
	return nil
end

-- ���������� table � ������ id,count,cost �� ��� ����� � ����� �� debugInstanceFileName
function GetSellingItemId( itemName )
	local bag = avatar.GetInventoryItemIds()
	local items = {}
	local notnil = false
	for i, itemId in bag do
	    if itemId ~= nil then
	        local itemInfo = avatar.GetItemInfo(itemId)
	        if itemInfo.debugInstanceFileName == itemName then
				table.insert(items, {id = itemId, count = itemInfo.stackCount, cost = itemInfo.sellPrice})
				notnil = true
	        end
	    end
	end
	if notnil then
	    return items
	end
	return nil
end

function GetSlotsTable( itemName )
	local notNil = false
	local result = {}
	local slot
	local countItems = avatar.GetInventorySize()
	Log( "count items =" .. tostring( countItems ) )
	for slot=0, countItems-1 do
		local itemId = avatar.GetInventoryItemId( slot )
		if itemId ~= nil then
			local itemInfo = avatar.GetItemInfo( itemId )
			if itemInfo.debugInstanceFileName == itemName then
				table.insert( result, { slot=slot, count=itemInfo.stackCount, cost=itemInfo.sellPrice } )
				notNil = true
			end
		end
	end

	if notNil then
		return result
	end
	
	return nil	
end

-- ���������� nil ���� ������� ����������, ����� errorText. (var,string)
function IsClassHaveFunc(class,func)
	if type(func) ~= "string" then
		return "Wrong parameters"
	end
	if class ~= nil then
		if type(class) == "table" then
			for key,value in class do
				if key == func then
					if type(value) == "function" then
						return nil
					else
						return "Not a function: "..type(value)
					end
				end
			end
			return "Class have not this function"
		else
			return "Class not a table"
		end
	else
		return "Class is nil"
	end
end

-- ���������� ���� ���������� ������� �����
function GetAggroMobsIds( unitId )
	local result = {}
	for index, id in avatar.GetUnitList() do
		Log(tostring(id))
		local list = debugMission.UnitGetAggroList( id )
		if list ~= nil then
			Log("not nil")
			for unitId, aggro in list do
				Log(tostring(aggro))
				if unitId == avatar.GetId() and aggro > 0 then
					table.insert( result, id )
				end
			end
		end	
	end
	
	return result
end

function IsMobHere( mobName )
	return GetMobId( mobName ) ~= nil
end
