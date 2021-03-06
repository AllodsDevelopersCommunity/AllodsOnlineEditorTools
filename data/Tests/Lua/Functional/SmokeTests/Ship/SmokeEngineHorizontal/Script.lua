Global( "TEST_NAME", "Smoke.ShipEngineHorizontal author: Vashenko Anton; date: 11.12.2008; task: 51298" )

-- param
Global( "SUMMON_SHIP_SPELL", nil )
-- /param

Global( "START_POS", nil )
Global( "SHIP_ID", nil )
Global( "DEV_ID", nil )

Global( "INDEX_ACTION", nil )

Global( "ERROR_MESSAGE", nil )


function PrintDevicesInfo( shipId )
	SHIP_ID = shipId
	PrintListDeviceShip( SHIP_ID, MoveToEngine )
end

function MoveToEngine()
	local deviceIndex = GetTransportDeviceIndex( SHIP_ID, SHIP_ENGINE_DEV, 1 )
	DEV_ID = GetTransportDeviceId( SHIP_ID, deviceIndex )

	TeleportToDevice( DEV_ID, SHIP_ID, 3, UseHorizontalEngine, ErrorFunc )
end

function UseHorizontalEngine()
	StartUsingTransportDevice( DEV_ID, PrintDeviceInfo, ErrorFunc )
end

function PrintDeviceInfo()
	INDEX_ACTION = 0
	PrintActiveUsableDeviceInfo( ChangeSpeed, ErrorFunc )
end

function ChangeSpeed()
	INDEX_ACTION = INDEX_ACTION + 1
	if INDEX_ACTION <= 3 then
		RunHorizontalEngine( SHIP_ID, INDEX_ACTION, true, WaitMaxSpeed, ErrorFunc )
	else
		RunHorizontalEngine( SHIP_ID, 0, false, WaitStop, ErrorFunc )
	end
end

function WaitMaxSpeed()
	StartTimer( 3000, GetSpeed, nil )
end

function GetSpeed()
	Log( "max speed for index action=" .. tostring(INDEX_ACTION) .. " is ".. tostring( GetTransportHorizontalSpeed( SHIP_ID ) ) )
	ChangeSpeed()
end

function WaitStop()
	StartTimer( 3000, StopMove, nil )
end

function StopMove()
	Log( "Ship speed = " .. tostring( GetTransportHorizontalSpeed( SHIP_ID ) ) )
	if GetTransportHorizontalSpeed( SHIP_ID ) == 0 then
		StopUsingTransportDevice( DEV_ID, Done, ErrorFunc )
	else
		ErrorFunc( "Ship vertical speed is not 0 after stopping" )
	end	
end




function Done()
	DisintShip()
end

function ErrorFunc( text )
	ERROR_MESSAGE = text
	DisintShip()
end

function DisintShip()
	if unit.GetTransport( avatar.GetId() ) ~= nil then
		Log( "Disintegrate ship" )
		debugMission.DisintegrateInteractive( unit.GetTransport( avatar.GetId() ) )
	end

	qaMission.AvatarRevive()
	qaMission.AvatarSetPos( START_POS )
	StartTimer( 2000, CloseScript )	
end

function CloseScript()
	if StringIsBlank( ERROR_MESSAGE ) == false then
		Warn( TEST_NAME, ERROR_MESSAGE )
	else
		Success( TEST_NAME )
	end
end


---------------------------------------- EVENTS -------------------------------------


function OnAvatarCreated( params )
	StartTest( TEST_NAME )
	START_POS = avatar.GetPos()
	local pos = {
		X = 11100,
		Y = 1370,
		Z = 15
	}
	SummonShip( SUMMON_SHIP_SPELL, PrintDevicesInfo, ErrorFunc, ToStandartCoord( pos ))	
end

function Init()
	SUMMON_SHIP_SPELL = developerAddon.GetParam( "SummonShipSpell" )

	local login = {
		login = developerAddon.GetParam( "login" ),
		pass = developerAddon.GetParam(	"password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging(login)
	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()