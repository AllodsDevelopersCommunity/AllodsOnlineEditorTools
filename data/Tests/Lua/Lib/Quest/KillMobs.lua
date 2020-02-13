-- author: Liventsev Andrey, date: 01.07.2008, task#34553
-- ���������� ��� ���������� ������� ���� ��������� �����

Global( "QKM_MAX_COUNT_MOBS", 10 )

Global( "QKM_MOB_NAME",       nil )
Global( "QKM_MOB_COORDS",     nil )
Global( "QKM_QUEST_NAME",     nil )
Global( "QKM_PASS_FUNCTION",  nil )
Global( "QKM_ERROR_FUNCTION", nil )

Global( "QKM_CRITICAL_MAX_COUNT", 100 ) --  ���� �� ��������� ����� QKM_CRITICAL_MAX_COUNT ����� ������ - ������ � �������
Global( "QKM_CRITICAL_COUNT", nil )

Global( "QKM_COUNT", nil )
Global( "QKM_TRACKER_INDEX", nil )
Global( "QKM_TRACKERS", nil )

-- ����� ��� �������� �����. ����� ������� ���������� ����� functionName
-- ���������� ��� ���� mobCount � ������ ��� ��������� ��������� mobPlaces
-- ������� ����� ������ �� ������ ��������� ������ - ���� ��� �������� �����-���� ������� ��������, �� ���� ������� ��������� ��������� ����� 
-- � ���� ��������� ���� ������� �� ������ ������������
-- ���� � ������� QKM_MAX_COUNT_MOBS ������� �� ���� �� ��������� �� ���������, �� ������� � �������
function KillMobs( questName, mobName, mobCoords, passFunc, errorFunc )
	Log( "" )
	Log( "" )
	Log( "" )
	Log( "killing mobs with name=" .. mobName, "Quests.KillMobs" )

	QKM_MOB_NAME = mobName
	QKM_MOB_COORDS = mobCoords
	QKM_PASS_FUNCTION = passFunc
	QKM_ERROR_FUNCTION = errorFunc
	QKM_QUEST_NAME = questName
	QKM_TRACKER_INDEX = nil
	
	local progress = avatar.GetQuestProgress( GetQuestId( QKM_QUEST_NAME ))
	QKM_TRACKERS = progress.objectives
	
	QKM_COUNT = 0
	QKM_CRITICAL_COUNT = 0
	
	QKM_KillingNextMob()
end

function QKM_KillingNextMob( mobId )
	local progress = avatar.GetQuestProgress( GetQuestId( QKM_QUEST_NAME ))
	local objectives = progress.objectives

	Log( "" )
	if QKM_TRACKER_INDEX == nil then
		Log( "Klling next mob    unknown. critical=" .. tostring(QKM_CRITICAL_COUNT), "Quests.KillMobs" )
	else
		Log( "Klling next mob    " .. tostring(objectives[ QKM_TRACKER_INDEX ].progress) .. "/" .. tostring(objectives[ QKM_TRACKER_INDEX ].required) .. "   critical=" .. tostring(QKM_CRITICAL_COUNT), "Quests.KillMobs" )
	end
	
	if QKM_CRITICAL_COUNT >= QKM_CRITICAL_MAX_COUNT then
		QKM_ERROR_FUNCTION( "Can't find mob in " .. tostring(QKM_CRITICAL_MAX_COUNT) .. " times" )
	
	-- ���� ��� �� ����� ������ ������
	elseif QKM_TRACKER_INDEX == nil then
		if QKM_COUNT < QKM_MAX_COUNT_MOBS then
		    for index, obj in objectives do
		        if obj.progress ~= QKM_TRACKERS[ index ].progress then
		            Log( "tracker founded", "Quest/KillMobs" )
					QKM_TRACKER_INDEX = index
					QKM_KillingNextMob()
					return
		        end
		    end
		    
		    Log( "tracker not founded, killing next", "Quest/KillMobs"  )
		    QKM_GetNearestMob( mobId )
		else
			QKM_ERROR_FUNCTION( "No one tracker did not changed. Killed " .. tostring(QKM_MAX_COUNT_MOBS) " mobs. name=" .. tostring( QKM_MOB_NAME ))
			return
		end

	-- ���� ������ ������ ��� ������
	elseif QKM_TRACKER_INDEX ~= nil then
		if objectives[ QKM_TRACKER_INDEX ].progress >= objectives[ QKM_TRACKER_INDEX ].required then
		    QKM_PASS_FUNCTION()
		else
			QKM_GetNearestMob( mobId )
		end
	end	
end

function QKM_GetNearestMob( mobId )
	if mobId ~= nil then
		QKM_COUNT = QKM_COUNT + 1
		QKM_CRITICAL_COUNT = 0
		KillMob( mobId, QKM_KillingNextMob, QKM_ERROR_FUNCTION )

	else
		QKM_CRITICAL_COUNT = QKM_CRITICAL_COUNT + 1
		FindMob( QKM_MOB_NAME, QKM_MOB_COORDS[GetRandomTableIndex( QKM_MOB_COORDS )], QKM_KillingNextMob, QKM_ERROR_FUNCTION )
	end
end