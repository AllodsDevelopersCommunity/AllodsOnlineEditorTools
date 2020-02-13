
-- object types in moblists
Global( "OBJ_TYPE_MOB_WORLD", "MobWorld" )
Global( "OBJ_TYPE_CHEST_RESOURCE", "ChestResource" )
Global( "OBJ_TYPE_STELE_RESOURCE", "SteleResource" )
Global( "OBJ_TYPE_QUEST_RESOURCE", "QuestResource" )
Global( "OBJ_TYPE_ZONE", "ZoneResource" )

-- ���������� ��������� ����� �� ��������
function GetMobCoords( mobList, mobName )
	return GetObjCoords( mobList, mobName, OBJ_TYPE_MOB_WORLD )
end

-- ���������� ��������� ����� �� �������� �� ���� (�� ������ ������)
function GetMobCoordsZone( mobList, mobName, zoneName )
	local objInfo = GetObjInfoFromList( mobList, mobName, OBJ_TYPE_MOB_WORLD )
	if objInfo ~= nil then
		local zone = ParseObjName( objInfo.zone, OBJ_TYPE_ZONE )
		--Log("Zone "..tostring(zone))
		if zone == zoneName then
			local result = {}
			local positions = objInfo.positions
			for index, position in positions do
				local pos = {
					X = position.x,
					Y = position.y,
					Z = position.z
				}
				
				result[index] = pos 
			end
			
			return result
		end
	    
	end
	return nil
end


-- ���������� ��������� ����������� � ����� �� ��������
function GetDevCoords( mobList, devName )
	return GetObjCoords( mobList, devName, OBJ_TYPE_CHEST_RESOURCE )
end

-- ���������� ��������� �������� �� ��������
function GetNoLootDevCoords( mobList, devName )
	return GetObjCoords( mobList, devName, OBJ_TYPE_STELE_RESOURCE )
end

-- ���������� ���������� � ������
function GetQuestInfoFromQuestList( questList, questName )
	for index, questInfo in questList do
		local name = ParseObjName( questInfo.name, OBJ_TYPE_QUEST_RESOURCE )
		if name == questName then
			return questInfo
		end
	end
	
	return nil
end

-- ���������� ��� ������� ��������� ����� � ��� ��� ObjType...
function GetQuestGiver( questList, questName )
	local name = GetQuestInfoFromQuestList( questList, questName ).giver
	
	local result = ParseObjName( name, OBJ_TYPE_MOB_WORLD )
	if result ~= nil then
		return result, OBJ_TYPE_MOB_WORLD
	end
	
	result = ParseObjName( name, OBJ_TYPE_CHEST_RESOURCE )
	if result ~= nil then
		return result, OBJ_TYPE_CHEST_RESOURCE
	end
	
	result = ParseObjName( name, OBJ_TYPE_STELE_RESOURCE )
	if result ~= nil then
		return result, OBJ_TYPE_STELE_RESOURCE
	end
	
	return nil
end

-- ���������� ��� ������� �������� ������� ����� � ��� ��� ObjType
function GetQuestFinisher( questList, questName )
	local name = GetQuestInfoFromQuestList( questList, questName ).finisher
	
	local result = ParseObjName( name, OBJ_TYPE_MOB_WORLD )
	if result ~= nil then
		return result, OBJ_TYPE_MOB_WORLD
	end
	
	result = ParseObjName( name, OBJ_TYPE_CHEST_RESOURCE )
	if result ~= nil then
		return result, OBJ_TYPE_CHEST_RESOURCE
	end
	
	result = ParseObjName( name, OBJ_TYPE_STELE_RESOURCE )
	if result ~= nil then
		return result, OBJ_TYPE_STELE_RESOURCE
	end
	
	return nil
end

-- ���������� �����, � ������� ����� �������� ����
function GetLootOwner( mobList, itemName )
	local result = {}
	for index, objInfo in mobList do
		if ParseObjName( objInfo.name, OBJ_TYPE_MOB_WORLD ) ~= nil then
			if IsTableContents( objInfo.questLoot, itemName ) == true then
				table.insert( result, objInfo )
			end
		end	
	end
	return result
end

-- ��� ������� ���� QUEST_COUNT_KILL
-- ���������� name=��� ���� ��� �������, ������� ���� �����/������� ��� ������. � targetName ���������� quest.objective.sysDebugName
-- ���������� isMob - boolean - ��� ��� ��� ������
function GetQuestTargetInfoByName( mobList, targetName )
	for index, objInfo in mobList do 
		if ParseObjName( objInfo.name, OBJ_TYPE_MOB_WORLD ) == targetName then
			Log( " -- " .. ParseObjName( objInfo.name, OBJ_TYPE_MOB_WORLD ) )
			return { isMob = true, name = ParseObjName( objInfo.name, OBJ_TYPE_MOB_WORLD ) }
			
		elseif ParseObjName( objInfo.name, OBJ_TYPE_STELE_RESOURCE ) == targetName then
			Log( " 2 -- " .. ParseObjName( objInfo.name, OBJ_TYPE_MOB_WORLD ) )
			return { isMob = false, name = ParseObjName( objInfo.name, OBJ_TYPE_STELE_RESOURCE ) }
		end
	end
end

-- ��� ������� ���� QUEST_COUNT_ITEM
-- ���������� names = ����� ����� ��� ��������, ������� ���� �������� ��� ������. � targetName ���������� objective.sysDebugName
-- ���������� isMob - boolean - ��� ��� ��� ������
function GetQuestTargetInfoByItem( mobList, itemName )
	local result = {}
	local isMob = nil
	for index, objInfo in mobList do
		if ParseObjName( objInfo.name, OBJ_TYPE_MOB_WORLD ) ~= nil then
			if IsTableContents( objInfo.questLoot, itemName ) == true then
				if isMob == false then
					Log( "!-----------------------------------------------------!" )
					Log( "!-----------------------------------------------------!" )
					Log( "mob and device contain one item=" .. itemName .. " What should i do?", "Table.GetQuestTargetByName" )
					Log( "!-----------------------------------------------------!" )
					Log( "!-----------------------------------------------------!" )
				end
				Log( " -- " .. ParseObjName( objInfo.name, OBJ_TYPE_MOB_WORLD ) )
				table.insert( result, objInfo )
				isMob = true
			end

		elseif ParseObjName( objInfo.name, OBJ_TYPE_CHEST_RESOURCE ) ~= nil then
			if IsTableContents( objInfo.questLoot, itemName ) == true then
				if isMob == true then
					Log( "!-----------------------------------------------------!" )
					Log( "!-----------------------------------------------------!" )
					Log( "device and mob contain one item=" .. itemName .. " What should i do?", "Table.GetQuestTargetByName" )
					Log( "!-----------------------------------------------------!" )
					Log( "!-----------------------------------------------------!" )
				end
				table.insert( result, objInfo )
				isMob = false
			end
		end	
	end
	return {isMob = isMob, names = result}
end

-- ���������� ������� � ������� ����� �������� ����
function GetLootDeviceOwner( mobList, itemName )
	local result = {}
	for index, objInfo in mobList do
		if ParseObjName( objInfo.name, OBJ_TYPE_CHEST_RESOURCE ) ~= nil then
			if IsTableContents( objInfo.questLoot, itemName ) == true then
				table.insert( result, objInfo )
			end
		end	
	end
	return result
end

function GetObjCoords( mobList, objName, prefix )
	local objInfo = GetObjInfoFromList( mobList, objName, prefix )
	if objInfo ~= nil then
	    local result = {}
	    local positions = objInfo.positions
	    for index, position in positions do
			local pos = {
			    X = position.x,
			    Y = position.y,
			    Z = position.z
			}
			
			result[index] = ToStandartCoord( pos )
	    end
	    
	    return result
	    
	else
		Warn( "Parent test", "can't find object in list. name=" .. objName )
	end	
end

-- ���������� ���������� � ���� �� ������
function GetObjInfoFromList( mobList, objName, prefix )
	for index, objInfo in mobList do
		local name = ParseObjName( objInfo.name, prefix )
		if name ~= nil and name == objName then
			return objInfo
		end
	end

	return nil
end

-- ������ ��� ������� �� ������ (������ ���������� � prefix: )
function ParseObjName( objName, prefix )
	local xdb = debugCommon.FromWString( objName )
	if xdb == nil or string.len( xdb ) == 0 then
		return nil
	end
	
	local separatorInd = string.find( xdb, ":" )
	if separatorInd ~= nil then
		local type = string.sub( xdb, 1, separatorInd - 1 )
		if type == prefix then
			return string.sub( xdb, separatorInd+2 )
		else
			return nil
		end
	else
		Warn( "Parent test", "invalid objName in list (no ':' symbol in name). name=" .. xdb )
	end
end

-- ���������� ��� ������, ������� ������ npc. level - ������ ����� � ������� �� ������ level - ������������
function GetQuestsByGiver( questList, npcName, level, ignoreList )
	local result = {}
	for index, questInfo in questList do
		local giver = ParseObjName( questInfo.giver, OBJ_TYPE_MOB_WORLD )
		if npcName == giver then
			local name = ParseObjName( questInfo.name, OBJ_TYPE_QUEST_RESOURCE )
			local isLevel = level == nil or questInfo.level <= level
			local isIgnore = ignoreList ~= nil and IsTableContents( ignoreList, name )
			
			if name ~= nil and isLevel and not isIgnore then
				table.insert( result, name )
			end	
		end
	end
	
	return result
end

function IsQuestCompleted( questName )
	for i, completedQuestIs in avatar.GetQuestHistory() do
		if avatar.GetQuestInfo( completedQuestIs ).debugName == questName then
			return true
		end
	end
	
	return false
end

function IsQuestAccepted( questName )
	for i, acceptedQuestId in avatar.GetQuestBook() do
		if avatar.GetQuestInfo( acceptedQuestId ).debugName == questName then
			return true
		end
	end
	
	return false
end

-- ���������� ������ �������
function GetTableSize( table )
	if table == nil then 
		return 0
	end	

	local count = 0
	for index, value in table do
		if value ~= nil then
			count = count + 1
		end	
	end

	return count
end

-- ���������� ��������� ��������� ������ �������
function GetRandomTableIndex( table )
	return math.random( 1, GetTableSize(table) )
end

function GetRandomTableElement( table )
	return table[ GetRandomTableIndex( table ) ]
end

function IsTableContents( table, item, isWString )
	if GetTableSize( table ) == 0 then
		return false
	end

	for index, value in table do
		local tableItem = value
		if isWString == true then
			tableItem = debugCommon.FromWString( tableItem )
		end
		if tableItem == item then
			return true
		end
	end
	return false
end

function JoinTables( t1, t2 )
	for index, e2 in t2 do
		table.insert( t1, e2 )
	end
	
	return t1
end
