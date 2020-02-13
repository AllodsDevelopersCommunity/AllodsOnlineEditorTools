-- author: Liventsev Andrey, date: 25.06.2008
-- ���������� ��� ������ � ������������/������������
--
-- ���������� ����� ���� 2-� ����� - ���������� (X, Y, Z) � �����������(globalX, localX, globalY .... )
-- ���� �� ������� ���������, �� ��� ���������� � ����������� �������


-- ������� �� ����������� ��������� � ����������
function ToAbsCoord( position )
	local ret = {}
	ret.X = position.globalX*32 + position.localX
	ret.Y = position.globalY*32 + position.localY
	ret.Z = position.globalZ*32 + position.localZ
	
	return ret
end

function ToNewAbsCoord( position )
	local ret = {}
	ret.posX = position.globalX*32 + position.localX
	ret.posY = position.globalY*32 + position.localY
	ret.posZ = position.globalZ*32 + position.localZ
	
	return ret
end

-- ������� �� ���������� ��������� � �����������
function ToStandartCoord( pos )
	local ret = {}
	
	local del = modf(pos.X, 32)
	ret.localX = del.drob
	ret.globalX = del.cel
	
	del = modf(pos.Y, 32)
	ret.localY = del.drob
	ret.globalY = del.cel
	
	del = modf(pos.Z, 32)
	ret.localZ = del.drob
	ret.globalZ = del.cel
	
	return ret
end

-- ����� x �� d. ���������� 2 ��������: cel - ����� �����, drop - ������� �� �������
function modf( x, d )
	local ret = {
		cel = 0, 
		drob = 0
	}
	
	if x>0 then
		ret.cel = math.floor( x/d )
		ret.drob = x - (ret.cel*d)
	else
		ret.cel = math.ceil( x/d )
		ret.drob = x - (ret.cel*d)
	end
	
	return ret
end

-- ���������� ���������� ����� �� ��������� dist � ����������� �� firstPoint � secondPoint
function GetPosFromPointToPoint( firstPoint, secondPoint, dist )
	local dir = GetAngleBetweenPoints( firstPoint, secondPoint )
	return GetPositionAtDistance( firstPoint, dir, dist )
end

-- ���������� ���������� ����� ������������� �� ���������� distance �� position � ����������� direction
function GetPositionAtDistance( position, direction, distance )
	local dy = math.sin( direction )
    local dx = math.cos( direction )
    
	local aPos = ToAbsCoord( position )
	aPos.X = aPos.X + ( dx * distance )
	aPos.Y = aPos.Y + ( dy * distance )
	
	return ToStandartCoord( aPos )
end

-- ���������� ���������� ��������� ����� � �������� �� �������� range � ������� position
-- ����������� ����� ����� �� �� ������, ��� � position
function GetRandomCoord( position, range )
	local pos = ToAbsCoord( position )
	local result = {
		X = pos.X + range * math.random() - range / 2,
		Y = pos.Y + range * math.random() - range / 2,
		Z = pos.Z
	}

	return ToStandartCoord( result )
end

-- ���������� ���������� �� ����� �� ����� pos. ���� isHorizontal true - ����� �� ���������� ���������� z
function GetDistanceFromPosition( unitId, pos, isHorizontal )
	return GetDistanceBetweenPoints( debugMission.InteractiveObjectGetPos( unitId ), pos, isHorizontal )
end

-- ���������� ���������� ����� ����� �������. ���� isHorizontal true - ����� �� ���������� ���������� z
function GetDistanceBetweenPoints( pos1, pos2, isHorizontal )
	local aPos1 = ToAbsCoord( pos1 )
	local aPos2 = ToAbsCoord( pos2 )
	local result = nil
	if isHorizontal == true then
		return math.sqrt( (aPos1.X - aPos2.X)^2 + (aPos1.Y - aPos2.Y)^2 )
	else
		return math.sqrt( (aPos1.X - aPos2.X)^2 + (aPos1.Y - aPos2.Y)^2 + (aPos1.Z - aPos2.Z)^2 )
	end
end

-- ���������� ���� ����� ����� �������. �.�. � ����� ����������� ����� �������� �� ����� pos1, ����� ������� ����� pos2 ))
function GetAngleBetweenPoints( pos1, pos2 )
	local firstPoint = ToAbsCoord( pos1 )
	local secPoint   = ToAbsCoord( pos2 )
	local dY = secPoint.Y - firstPoint.Y
	local dX = secPoint.X - firstPoint.X
    local yaw = 0
	if dX == 0 then
		if dY > 0 then
			yaw = math.pi / 2
		elseif dY < 0 then
			yaw = - math.pi / 2
		else
			yaw = nil
		end
	elseif dX > 0 then
		yaw = math.atan( dY / dX )
	else
		if dY >= 0 then
		yaw = math.atan( dY / dX ) + math.pi
		else
		yaw = math.atan( dY / dX ) - math.pi
		end
	end
	return yaw
end
-- ��������� ����� � ����, ������������� ��������� �� ��������� �� ������ ��� ��
function AngleInc( angle, delta, degr )
	local ret
	if degr == nil then
		ret = angle + delta
	else
		ret = angle + DegrToRad( delta )
	end
	if ret <= math.pi() then
		return ret
	else
		return - ( 2*math.pi() - ret )
	end
end
-- �������� ������ �� ����, �������������� ��������� �� ������ 0
function AngleDec( angle, delta, degr )
	local ret
	if degr == nil then
		ret = angle - delta
	else
		ret = angle - DegrToRad( delta )
	end
	if ret >= - math.pi() then
		return ret
	else
		return ret + 2*math.pi()
	end
end

function RadToDegr( rad )
	return rad * 180 / math.pi
end

function DegrToRad( degr )
	return math.pi * degr / 180
end

-- ������������� � ����� pos (����� ���� ����������� ������ ����), ���� �� ����� time - ���������� ������� ������� ���� �� ��������
-- ���� ������ checkFunc, checkFuncParam, errorFunc, errorFuncParam - ��������� �������� �� �������
function MoveToPos( pos, passFunc, passFuncParam, time, checkFunc, checkFuncParam, errorFunc, errorFuncParam, map )
	local stPos = pos
	if stPos.X ~= nil then
		stPos = ToStandartCoord( pos )
	end
	
	local changeMap = false
	local aPos = ToAbsCoord( stPos )
	if map ~= nil and debugMission.GetMap().debugName ~= map then
		changeMap = true
		Log( "tpmap " .. map .. " " .. tostring(aPos.X).. " " .. tostring(aPos.Y).. " " .. tostring(aPos.Z), "Coordinates" )
		qaMission.TeleportMap( map, aPos.X, aPos.Y, aPos.Z )
	else
		Log( "teleport " .. tostring(aPos.X).. " " .. tostring(aPos.Y).. " " .. tostring(aPos.Z), "Coordinates" )
		qaMission.AvatarSetPos( stPos )
	end
	
	
	if checkFunc ~= nil then
		StartPrivateCheckTimer( time, checkFunc, checkFuncParam, errorFunc, errorFuncParam, passFunc, passFuncParam )

	else
		if time ~= nil then
			StartPrivateTimer( time, passFunc, passFuncParam )

		else
			local distance = GetDistanceFromPosition( avatar.GetId(), stPos, true )
			if distance < 20 then
				StartPrivateTimer( 8000, passFunc, passFuncParam )
			elseif distance < 100 then
				StartPrivateTimer( 10000, passFunc, passFuncParam )
			elseif changeMap == false then
				StartPrivateTimer( 15000, passFunc, passFuncParam )
			else
				StartPrivateTimer( 30000, passFunc, passFuncParam )
			end
		end
	end	
end

-- �������� � ���� � ���������, ��� �� ��� ����. errorFuncParam ����� �� ��������
function MoveToMob( pos, mobName, passFunc, passFuncParam, errorFunc, errorFuncParam, map )
	local text = errorFuncParam
	if text == nil then
		text = "Can't find mob after teleport. mobName=" .. mobName .. "  pos=" .. PrintCoord( pos )
	end
	MoveToPos( pos, passFunc, passFuncParam, 70000, IsMobHere, mobName, errorFunc, text, map )
end

-- �������� � ���� � ���������, ��� �� ��� ����. errorFuncParam ����� �� ��������
function MoveToMobId( mobId, passFunc, passFuncParam, errorFunc, errorFuncParam )
	local pos = debugMission.InteractiveObjectGetPos( mobId )
	local name = qaMission.UnitGetXDB( mobId )
	MoveToMob( pos, name, passFunc, passFuncParam, errorFunc, errorFuncParam )
end
-- ������� ��� ����� p = {x,y} ��������� ������ ������������ � ���������, p1,p2,p3 = {x,y}
function PointInTriangle(p,p1,p2,p3)
	if ((x-p1.x)*(p1.y-p2.y)+(p.y-p1.y)*(p2.x-p1.x))>=0 
		and ((p.x-p2.x)*(p2.y-p3.y)+(p.y-p2.y)*(p3.x-p2.x)) >= 0 
		and ((p.x-p3.x)*(p3.y-p1.y)+(p.y-p3.y)*(p1.x-p3.x))>=0 then 
		return true
	else 
		return false
	end
end

function IsAbsCoord( coord )
	return ( coord.X ~= nil and coord.Y ~= nil and coord.Z ~= nil )
end

function PrintCoord( coord )
	local aPos = coord
	if not IsAbsCoord( coord ) then
		aPos = ToAbsCoord( coord )
	end
	
	local result = " X=" .. tostring( aPos.X ) .. " Y=" .. tostring( aPos.Y ) .. " Z=" .. tostring( aPos.Z )
	return result
end
