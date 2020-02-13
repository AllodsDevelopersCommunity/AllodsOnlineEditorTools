-- author: Liventsev Andrey, date: 25.06.2008
-- ���������� ��� ������� ������������ ��������.
--
--                     ��������!!!
-- ���������� ���������� ������� EVENT_DEBUG_TIMER, ������� ���������� ������������
-- ������������ ��� ���������� � ��������� ���� OnDebugTimer.
--
-- ��� ����� ������� ������������ ����������� �������� ��������� � ���������� �����������,
-- ��� ��������� ��������� ��������� �������� ������������
--
--
--      ������� ������:
--
--   1. ������� ������� (timers)
-- ������ ��������� �����-���� �������� � ��������� ���������
--
--   2. ������� � �������� (checkTimers)
-- ������ ������ �������� ��������� ���-���� �, � ���������� �� �����������, ��������� �� ��� ���� �-���
--
--   3. ��������� (privateTimers)
-- ������������ ������ � ������ ����������� ���� ����������� �� ���� ��������
-- �������������� ���������� ����� �������. ����� ���� 1 ��� 2 ����.

-- ������������ ��� �������� - ����� �������� ������ 1 ��������
function GetParam( testName, text )
	local result = {}
	result.testName = testName
	result.text = text

	return result
end

function ReturnTrue()
	return true
end

function ReturnFalse()
	return false
end

function EmptyFunction()
end
-- StrConc() ���������� ������. ����� ���������� ����� ����.
-- Str - �������� ������
-- add - ��� ���� �������� (���� �������, �� ������� ��� value � �������, ��������� ������� �� ���������)
-- sep - �����������, �� ��������� ��� ���.
-- StrConc(str) - �������� � ������� ����� ���, ������� WString
-- StrConc(str,add) - ���������� ����������� " ". ��� ��������� �������� � �������, ��. ����
-- StrConc(str,add,sep) - ��� ��������� ��������� � ������ ������� str..sep..add
-- StrConc() - ������ ������ ������ ""
function StrConc(str,add,sep)
	local trueStr = ToString(str)
	local trueSep = ToString(sep)
	if trueSep == "" then
		trueSep = " "
	end
	local trueAdd = ""
	if type(add) == "table" then
		local count = 1
		for i, value in add do
			if count == 1 then
				trueAdd = ToString(value)
			else
				trueAdd = trueAdd..trueSep..ToString(value)
			end
			count = count + 1
		end
	else
		trueAdd = ToString(add)
	end

	return trueStr..trueSep..trueAdd	
end
-- ToString(str)
-- �������� � ������ ����� ���, ������� WString
-- ToString(nil) ������ ""
function ToString(str)
	local str_type = type(str)
	if str_type == "nil" then
		return ""
	elseif str_type == "string" then
		return str
	else
		local ToStr = ""
		if common.IsWString( str ) then
			ToStr = debugCommon.FromWString( str )
		else
			ToStr = tostring(str)
		end
		return ToStr
	end
end

------------------------ ������� ������� -------------------------
-- ��������� �-��� func � ����������� param ����� time ����������

Global( "TIMER",            0 )
Global( "TIMER_WAIT_TIME",  0 )
Global( "TIMER_FUNC",       nil )
Global( "TIMER_FUNC_PARAM", nil )
function StartTimer(time, func, param)
	TIMER = 0
	TIMER_WAIT_TIME = time
	TIMER_FUNC = func
	TIMER_FUNC_PARAM = param
end
function StopTimer()
	TIMER_WAIT_TIME = 0
end

Global( "TIMER1",            0 )
Global( "TIMER1_WAIT_TIME",  0 )
Global( "TIMER1_FUNC",       nil )
Global( "TIMER1_FUNC_PARAM", nil )
function StartTimer1(time, func, param)
	TIMER1 = 0
	TIMER1_WAIT_TIME = time
	TIMER1_FUNC = func
	TIMER1_FUNC_PARAM = param
end
function StopTimer1()
	TIMER1_WAIT_TIME = 0
end

Global( "TIMER2",            0 )
Global( "TIMER2_WAIT_TIME",  0 )
Global( "TIMER2_FUNC",       nil )
Global( "TIMER2_FUNC_PARAM", nil )
function StartTimer2(time, func, param)
	TIMER2 = 0
	TIMER2_WAIT_TIME = time
	TIMER2_FUNC = func
	TIMER2_FUNC_PARAM = param
end
function StopTimer2()
	TIMER2_WAIT_TIME = 0
end

Global( "PRIVATE_TIMER",            0 )
Global( "PRIVATE_TIMER_WAIT_TIME",  0 )
Global( "PRIVATE_TIMER_FUNC",       nil )
Global( "PRIVATE_TIMER_FUNC_PARAM", nil )
function StartPrivateTimer(time, func, param)
	--Log("StartPrivateTimer "..tostring(func))
	PRIVATE_TIMER = 0
	PRIVATE_TIMER_WAIT_TIME = time
	PRIVATE_TIMER_FUNC = func
	PRIVATE_TIMER_FUNC_PARAM = param
end
function StopPrivateTimer()
	--Log("StopPrivateTimer")
	PRIVATE_TIMER_WAIT_TIME = 0
end
function RestartPrivateTimer()
	PRIVATE_TIMER = 0
end


-------------------------- ������� � �������� -----------------------
-- �� ������ �������� � ������� time ������� ��������� �-��� checkFunc � ����������� checkFuncParam
-- ���� �-��� checkFunc ������� true - ��������� �-��� PASSFunc � ����������� PASSFuncParam, ������������� ������
-- ���� ������ time �������, � ������ �� ��������� - ��������� �-��� errorFunc � ����������� errorFuncParam

Global( "CH_TIMER",                  0 )
Global( "CH_TIMER_WAIT_TIME",        0 )
Global( "CH_TIMER_CHECK_FUNC",       nil )
Global( "CH_TIMER_CHECK_FUNC_PARAM", nil )
Global( "CH_TIMER_ERROR_FUNC",       nil )
Global( "CH_TIMER_ERROR_FUNC_PARAM", nil )
Global( "CH_TIMER_PASS_FUNC",        nil )
Global( "CH_TIMER_PASS_FUNC_PARAM",  nil )
function StartCheckTimer( time, checkFunc, checkFuncParam, errorFunc, errorFuncParam, passFunc, passFuncParam )
	CH_TIMER = 0
	CH_TIMER_WAIT_TIME        = time
	CH_TIMER_CHECK_FUNC       = checkFunc
	CH_TIMER_CHECK_FUNC_PARAM = checkFuncParam
	CH_TIMER_ERROR_FUNC       = errorFunc
	CH_TIMER_ERROR_FUNC_PARAM = errorFuncParam
	CH_TIMER_PASS_FUNC        = passFunc
	CH_TIMER_PASS_FUNC_PARAM  = passFuncParam
end
function StopCheckTimer()
	CH_TIMER_WAIT_TIME = 0
end

Global( "CH_TIMER1",                  0 )
Global( "CH_TIMER1_WAIT_TIME",        0 )
Global( "CH_TIMER1_CHECK_FUNC",       nil )
Global( "CH_TIMER1_CHECK_FUNC_PARAM", nil )
Global( "CH_TIMER1_ERROR_FUNC",       nil )
Global( "CH_TIMER1_ERROR_FUNC_PARAM", nil )
Global( "CH_TIMER1_PASS_FUNC",        nil )
Global( "CH_TIMER1_PASS_FUNC_PARAM",  nil )
function StartCheckTimer1( time, checkFunc, checkFuncParam, errorFunc, errorFuncParam, passFunc, passFuncParam )
	CH_TIMER1 = 0
	CH_TIMER1_WAIT_TIME        = time
	CH_TIMER1_CHECK_FUNC       = checkFunc
	CH_TIMER1_CHECK_FUNC_PARAM = checkFuncParam
	CH_TIMER1_ERROR_FUNC       = errorFunc
	CH_TIMER1_ERROR_FUNC_PARAM = errorFuncParam
	CH_TIMER1_PASS_FUNC        = passFunc
	CH_TIMER1_PASS_FUNC_PARAM  = passFuncParam
end
function StopCheckTimer1()
	CH_TIMER1_WAIT_TIME = 0
end

Global( "CH_TIMER2",                  0 )
Global( "CH_TIMER2_WAIT_TIME",        0 )
Global( "CH_TIMER2_CHECK_FUNC",       nil )
Global( "CH_TIMER2_CHECK_FUNC_PARAM", nil )
Global( "CH_TIMER2_ERROR_FUNC",       nil )
Global( "CH_TIMER2_ERROR_FUNC_PARAM", nil )
Global( "CH_TIMER2_PASS_FUNC",        nil )
Global( "CH_TIMER2_PASS_FUNC_PARAM",  nil )
function StartCheckTimer2( time, checkFunc, checkFuncParam, errorFunc, errorFuncParam, passFunc, passFuncParam )
	CH_TIMER2 = 0
	CH_TIMER2_WAIT_TIME        = time
	CH_TIMER2_CHECK_FUNC       = checkFunc
	CH_TIMER2_CHECK_FUNC_PARAM = checkFuncParam
	CH_TIMER2_ERROR_FUNC       = errorFunc
	CH_TIMER2_ERROR_FUNC_PARAM = errorFuncParam
	CH_TIMER2_PASS_FUNC        = passFunc
	CH_TIMER2_PASS_FUNC_PARAM  = passFuncParam
end
function StopCheckTimer2()
	CH_TIMER2_WAIT_TIME = 0
end

Global( "PRIVATE_CH_TIMER",                  0 )
Global( "PRIVATE_CH_TIMER_WAIT_TIME",        0 )
Global( "PRIVATE_CH_TIMER_CHECK_FUNC",       nil )
Global( "PRIVATE_CH_TIMER_CHECK_FUNC_PARAM", nil )
Global( "PRIVATE_CH_TIMER_ERROR_FUNC",       nil )
Global( "PRIVATE_CH_TIMER_ERROR_FUNC_PARAM", nil )
Global( "PRIVATE_CH_TIMER_PASS_FUNC",        nil )
Global( "PRIVATE_CH_TIMER_PASS_FUNC_PARAM",  nil )
function StartPrivateCheckTimer( time, checkFunc, checkFuncParam, errorFunc, errorFuncParam, passFunc, passFuncParam )
	--Log("StartPrivateCheckTimer"..tostring(checkFunc))
	PRIVATE_CH_TIMER = 0
	PRIVATE_CH_TIMER_WAIT_TIME        = time
	PRIVATE_CH_TIMER_CHECK_FUNC       = checkFunc
	PRIVATE_CH_TIMER_CHECK_FUNC_PARAM = checkFuncParam
	PRIVATE_CH_TIMER_ERROR_FUNC       = errorFunc
	PRIVATE_CH_TIMER_ERROR_FUNC_PARAM = errorFuncParam
	PRIVATE_CH_TIMER_PASS_FUNC        = passFunc
	PRIVATE_CH_TIMER_PASS_FUNC_PARAM  = passFuncParam
end
function StopPrivateCheckTimer()
	--Log("StopPrivateCheckTimer")
	PRIVATE_CH_TIMER_WAIT_TIME = 0
end

Global("TIME_START",nil)
Global("TIME_STOP",nil)
Global("ACTIVE_TIME",false)
function ActiveTime()
	ACTIVE_TIME = true
end
function GetTime()
	local t = TIME_STOP - TIME_START
	TIME_STOP = nil
	return t
end

function StopAllTimers()
    StopPrivateCheckTimer()
    StopCheckTimer()
    StopCheckTimer1()
    StopCheckTimer2()
    StopPrivateTimer()
    StopTimer()
    StopTimer1()
    StopTimer2()
end

Global("TIME_SEC", 0)
Global("TIME_SEC_ZERO", nil)

Global( "PASS_PING_FUNC", nil )
Global( "PASS_PING_PARAM", nil )

function Ping( param )
	StartPrivateTimer( 5000, param.failFunc, nil )
	qaMission.RequestIsShardAlive()
	PASS_PING_FUNC = param.passFunc
	PASS_PING_PARAM = param.passParams
end

function OnDebugShardIsAlive( params )
	StopPrivateTimer()
	if( PASS_PING_FUNC ~= nil ) then
		PASS_PING_FUNC( PASS_PING_PARAM )
	end
end

--Global( "av", nil )
--Global( "num", nil )

function OnLatency( params )

end
--[[
function GetLatency()
	av = (av*num + cur)/(num+1)
	num = num + 1
end]]

---------------------------------    ���������� ������� EVENT_DEBUG_TIMER   ----
function OnDebugTimer( params )
    if ACTIVE_TIME then
    	TIME_START = params.elapsed
    	ACTIVE_TIME = false
    end
    if TIME_START ~= nil then
    	TIME_STOP = params.elapsed
    end
	
-- ������� �������
	if TIMER_WAIT_TIME > 0 then
		TIMER = TIMER + params.delta
		if TIMER >= TIMER_WAIT_TIME then
		    TIMER_WAIT_TIME = 0
		    if TIMER_FUNC_PARAM ~= nil then
		    	TIMER_FUNC( TIMER_FUNC_PARAM )
		    else
		    	TIMER_FUNC() 
			end	
		end
	end

	if TIMER1_WAIT_TIME > 0 then
		TIMER1 = TIMER1 + params.delta
		if TIMER1 >= TIMER1_WAIT_TIME then
		    TIMER1_WAIT_TIME = 0
		    if TIMER1_FUNC_PARAM ~= nil then
		    	TIMER1_FUNC( TIMER1_FUNC_PARAM )
		    else
		    	TIMER1_FUNC()
			end
		end
	end
	
	if TIMER2_WAIT_TIME > 0 then
		TIMER2 = TIMER2 + params.delta
		if TIMER2 >= TIMER2_WAIT_TIME then
		    TIMER2_WAIT_TIME = 0
		    if TIMER2_FUNC_PARAM ~= nil then
		    	TIMER2_FUNC( TIMER2_FUNC_PARAM )
		    else
		    	TIMER2_FUNC()
			end
		end
	end
	
	if PRIVATE_TIMER_WAIT_TIME > 0 then
		PRIVATE_TIMER = PRIVATE_TIMER + params.delta
		if PRIVATE_TIMER >= PRIVATE_TIMER_WAIT_TIME then
		    PRIVATE_TIMER_WAIT_TIME = 0
		    if PRIVATE_TIMER_FUNC_PARAM ~= nil then
		    	PRIVATE_TIMER_FUNC( PRIVATE_TIMER_FUNC_PARAM )
		    else
		    	PRIVATE_TIMER_FUNC()
			end
		end
	end	

	
-- ������� � ��������
	if CH_TIMER_WAIT_TIME > 0 then
	    if CH_TIMER >= CH_TIMER_WAIT_TIME then
	    	CH_TIMER = CH_TIMER + params.delta
	    	CH_TIMER_WAIT_TIME = 0
			CH_TIMER_ERROR_FUNC( CH_TIMER_ERROR_FUNC_PARAM )
     	else
     		CH_TIMER = CH_TIMER + params.delta
		    local pass = CH_TIMER_CHECK_FUNC( CH_TIMER_CHECK_FUNC_PARAM )
		    if pass then
		    	CH_TIMER_WAIT_TIME = 0
		        CH_TIMER_PASS_FUNC( CH_TIMER_PASS_FUNC_PARAM )
		    end
		end
	end

	if CH_TIMER1_WAIT_TIME > 0 then
	    CH_TIMER1 = CH_TIMER1 + params.delta
	    
	    if CH_TIMER1 >= CH_TIMER1_WAIT_TIME then
	    	CH_TIMER1_WAIT_TIME = 0
			CH_TIMER1_ERROR_FUNC( CH_TIMER1_ERROR_FUNC_PARAM )
     	else
		    local pass = CH_TIMER1_CHECK_FUNC( CH_TIMER1_CHECK_FUNC_PARAM )
		    if pass then
		    	CH_TIMER1_WAIT_TIME = 0
		        CH_TIMER1_PASS_FUNC( CH_TIMER1_PASS_FUNC_PARAM )
		    end
		end
	end

	if CH_TIMER2_WAIT_TIME > 0 then
	    CH_TIMER2 = CH_TIMER2 + params.delta
	    
	    if CH_TIMER2 >= CH_TIMER2_WAIT_TIME then
	    	CH_TIMER2_WAIT_TIME = 0
			CH_TIMER2_ERROR_FUNC( CH_TIMER2_ERROR_FUNC_PARAM )
     	else
		    local pass = CH_TIMER2_CHECK_FUNC( CH_TIMER2_CHECK_FUNC_PARAM )
		    if pass then
		    	CH_TIMER2_WAIT_TIME = 0
		        CH_TIMER2_PASS_FUNC( CH_TIMER2_PASS_FUNC_PARAM )
		    end
		end
	end
	
	if PRIVATE_CH_TIMER_WAIT_TIME > 0 then
--		Log( "ch_timer 1  timer=" .. tostring(PRIVATE_CH_TIMER) .. " waitTime=" .. tostring( PRIVATE_CH_TIMER_WAIT_TIME ) .. " delta=" .. tostring( params.delta ))
	    
	    
	    if PRIVATE_CH_TIMER >= PRIVATE_CH_TIMER_WAIT_TIME then
--	    	Log( "ch_timer 2" )
	    	PRIVATE_CH_TIMER = PRIVATE_CH_TIMER + params.delta
	    	PRIVATE_CH_TIMER_WAIT_TIME = 0
			PRIVATE_CH_TIMER_ERROR_FUNC( PRIVATE_CH_TIMER_ERROR_FUNC_PARAM )
     	else
--     		Log( "ch_timer 3" )
     		PRIVATE_CH_TIMER = PRIVATE_CH_TIMER + params.delta
		    local pass = PRIVATE_CH_TIMER_CHECK_FUNC( PRIVATE_CH_TIMER_CHECK_FUNC_PARAM )
		    if pass then
--		    	Log( "ch_timer 4" )
		    	PRIVATE_CH_TIMER_WAIT_TIME = 0
				if( PRIVATE_CH_TIMER_PASS_FUNC ~= nil )	then
					PRIVATE_CH_TIMER_PASS_FUNC( PRIVATE_CH_TIMER_PASS_FUNC_PARAM )
				end
		    end
		end
	end	
	
	if TIME_SEC_ZERO == nil then
		TIME_SEC_ZERO = params.elapsed
	else
		TIME_SEC = math.floor(( params.elapsed - TIME_SEC_ZERO ) / 1000)
	end
    
end


function InitTimer()
   common.RegisterEventHandler( OnDebugTimer, "EVENT_DEBUG_TIMER" )
   common.RegisterEventHandler( OnDebugShardIsAlive, "EVENT_DEBUG_SHARD_IS_ALIVE" )
   common.RegisterEventHandler( OnLatency, "EVENT_DEBUG_SERVER_LATENCY" )   
end

InitTimer()
