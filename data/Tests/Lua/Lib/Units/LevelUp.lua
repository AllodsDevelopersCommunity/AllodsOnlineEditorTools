-- ����, ���� ������� LevelUp( level, takt, func, params, cheat ) ������� �������� ������� � ���� ���������� �� �������
-- ����� ���� ��� � ������� ���������� ������� � ���������� �����������, ��� �������� ������� funcPass  � ����������� paramsPass
-- ������ ����� ��������� ������
-- ACHTUNG!!! � ���� � ������� ������� funcError ����� ��������� � ���������� ������,
-- � ������� ����� ����� ������
-- � ����� �� ������������ �������� cheat - � ���� ������ ���������� ����� ������ ����� learn_all_spells
--- �������� takt ����� ���� nil, � ����� ������ ���� ������ ����� �������
Global("LEVEL_UP_PASS_FUNC", nil)
Global("LEVEL_UP_ERROR_FUNC", nil)
Global("LEVEL_UP_TAKT", nil)
Global("LEVEL_UP_RUBINS", nil)
Global("LEVEL_UP_TALENTS", 0)

function LevelUp( level, takt, funcPass, funcError, cheat )
   LEVEL_UP_PASS_FUNC = funcPass
   LEVEL_UP_ERROR_FUNC = funcError
   LEVEL_UP_TAKT = takt
	if LevelCheck(level) then
		if takt == nil then
			return PassLearnUp()
		else
			return PassLevelUp(cheat)
		end
	end
	if takt == nil then
		StartPrivateCheckTimer( 10000, LevelCheck, level, ErrorLvlLearnUp, "CANT LEVEL_UP : Level not "..tostring(level), PassLearnUp, nil )
	else
		StartPrivateCheckTimer( 10000, LevelCheck, level, ErrorLvlLearnUp, "CANT LEVEL_UP : Level not "..tostring(level), PassLevelUp, cheat )
	end
	
   LevelUpLog("Try level_up "..tostring(level).."...")
   qaMission.AvatarLevelUp( level ) 
end

function LevelUpLog(msg)
	Log( msg, "LevelUp" )
end

function PassLearnUp()
	Log( "everything is very good", "LevelUp" )
	LEVEL_UP_PASS_FUNC()
end

function LevelCheck(lvl)
	local avatarId = avatar.GetId()
	local cur_lvl = unit.GetLevel( avatarId )
	if lvl == cur_lvl then
		LevelUpLog("level is "..tostring(cur_lvl))
		if LEVEL_UP_TAKT == nil then
			return true
		else
			local talents = GetCurrency("TalentPoint")
			local rubyOption = GetCurrency("RubyCallOption")
			LevelUpLog("Talents "..tostring(talents).." RubyOption "..tostring(rubyOption))
			if talents == nil then
				return false
			end
			if talents > 0 then
				LEVEL_UP_RUBINS = rubyOption
				LEVEL_UP_TALENTS = talents
				return true
			end
			
		end
	end
	return false
end

function PassLevelUp(cheat)
	LevelUpLog("level_up success!")
	if cheat ~= nil then
		qaMission.SendCustomMsg("learn_all_spells")
		StartPrivateTimer(2000,PassLearnUp,nil)
	end
	LEVEL_UP_RUBINS = GetCurrency("RubyCallOption")
	if LEVEL_UP_RUBINS == nil then
		-- ������ �� ����� 10 ������
		StartLearnSpells( true )
	else
		if RubinCheck() then
			LevelUpLog("Acc have Ruby...")
			StartLearnSpells( false )
		else
			StartPrivateCheckTimer( 2000, RubinCheck, nil, ErrorLvlLearnUp, "CANT add rubin ", StartLearnSpells, false )
			LevelUpLog("Try add ruby to acc...")
			qaMission.SendCustomMsg("add_ac /Mechanics/AlternativeCurrencies/Ruby.xdb "..tostring(LEVEL_UP_RUBINS))
		end
	end
end

function StartLearnSpells(ten_lesser)
	if ten_lesser then
		LEVEL_UP_RUBINS = 0
	else
		LEVEL_UP_RUBINS = GetCurrency("Ruby")
	end
	
	LEVEL_UP_TALENTS = GetCurrency("TalentPoint")
	LevelUpLog("Ruby: "..tostring(LEVEL_UP_RUBINS).." Talents: "..tostring(LEVEL_UP_TALENTS))
	StartPrivateTimer(1000,LearnNextSpell, 2 )
end

function RubinCheck()
	local ruby = GetCurrency("Ruby")
	if ruby == nil then
		return false
	end
	if ruby >= LEVEL_UP_RUBINS then
		return true
	else
		return false
	end
end

function GetCurrency(name)
	local ids = avatar.GetCurrencies()
	local num = nil
	for i, id in ids do
		local info = avatar.GetCurrencyInfo( id )
		if info ~= nil then
			--LevelUpLog(info.sysName)
			if info.sysName == name then
				return info.value
			end
		end
	end
	return nil
end

function LearnNextSpell(num)
	LevelUpLog("LearnNextSpell NUM: "..tostring(num))
	local spell = TaktGetNextCell(num,true)
	--�������� ������� � ������ � ������������
	--if spell == nil then
		-- ������ �� ������ ����� �� ������
		--return ErrorLvlLearnUp("Cant get next cell from taktik NUM: "..tostring(num))
	--end
	if spell == false then
		LevelUpLog("in this NUM: "..tostring(num).." not base spell")
		--������ ������ ������� �� ����� � �� ����� �� ���� �������
		-- ��������� � �������� �� ���� �� �������
		return LearnFirstTalent()
	end
	
	local fromName = GetLayerLineTalent(spell.name,-1)
	-- ���� ���������� �� �����
	if fromName~=nil then
		LevelUpLog("Search - Layer: "..tostring(fromName.layer).." Line: "..tostring(fromName.line))
		spell.layer = fromName.layer
		spell.line = fromName.line
	end
	if fromName == nil and spell.layer == -1 then
		-- ���� �� ����� ���������� �� ����� � �� ��� � �������
		return ErrorLvlLearnUp("Wrong params on NUM "..num)
	end
	-- ������� ������ ����������
	local str = " layer: "..tostring(spell.layer).." line : "..tostring(spell.line).." name: "..spell.name
	
	LevelUpLog("Get info about Spell on"..str.."...")
	local info = avatar.GetBaseTalentInfo( spell.layer, spell.line )
	-- �������� ���� � ������
	if info == nil then
		-- ������ �� ���� ����������� ��� (������ �� ����� �� �����, ������� �� �������)
		return ErrorLvlLearnUp("Talent doesnt exist on "..str)
	end
	local currank = 0
	local name = ""
	if info.current == nil and info.next == nil then
		-- ������� �����, ���� �� ��� ������ ���� ������
		return ErrorLvlLearnUp("Current and Next is nil!")
	end
	if info.current ~= nil then
		--����� ����� ��� ������� 1 ����
		currank = info.current.rank
		name = debugCommon.FromWString(info.current.name)
	else
		-- ���� �� ������
		name = debugCommon.FromWString(info.next.name)
	end
	local reqTalents = currank + 1
	-- �������� ����������� ���-�� �����
	if reqTalents > 3 then
		-- ����� ������ ����� ���� �����.
		return ErrorLvlLearnUp("Base Talent Max Rang reqTalents: "..tostring(reqTalents).." - "..str.." Name "..name)
	end
	LevelUpLog("Current Rank : "..tostring(currank).." Current required talents : "..tostring(reqTalents))

	-- � ��� ������ ���� �������� �� ���-�� ������ �������
	-- TODO (���� ����� ���� ���� �� ������ ������) - ������
	local haveTalents = GetCurrency("TalentPoint")
	if haveTalents == nil then
		haveTalents = 0
	end
	if haveTalents < reqTalents or LEVEL_UP_TALENTS < reqTalents then
		-- ���� ���������� � ��������
		LevelUpLog("Talents "..tostring(haveTalents).." in srcipt "..tostring(LEVEL_UP_TALENTS))
		return LearnFirstTalent()
	end
	if not info.canUpdate then
		-- ����� ������ ������� (�� ������� �������)
		return ErrorLvlLearnUp("Cant Update Base Talent "..str.." Name "..name)
	end
	LevelUpLog("Try Learn Next Spell "..name.."...")
	StartPrivateCheckTimer( 10000, TalentCheck, {base = true, layer = spell.layer, line = spell.line, rank = currank},
							ErrorLvlLearnUp, "TIMEOUT Base Spell not updated "..str, 
							LearnNextSpell, num + 1 )
	LEVEL_UP_TALENTS = LEVEL_UP_TALENTS - reqTalents
	avatar.UpdateBaseTalent( spell.layer, spell.line )
end

function LearnFirstTalent()
	-- ���� ����� ������ ������ ����� ��������
	for k, v in LEVEL_UP_TAKT do
		if( type( v ) ~= "table" ) then
			return ErrorLvlLearnUp("Cant get first talent ") - --���!!!
		end
		for key, value in v.conditions do
			if debugCommon.FromWString(value.rule) == "field" then
				return LearnNextTalent(k)
			end
		end
	end
	-- ���� ���� ������ �� ������� �� ����� ������ ������
	return ErrorLvlLearnUp("Cant get first talent ")
end

function LearnNextTalent(num)
	LevelUpLog("LearnNextTalent NUM: "..tostring(num))
	local spell = TaktGetNextCell(num,false)
		--�������� ������� � ������ � ������������
	--if spell == nil then
		-- ������ �� ����� ������ �� ����� ������
		--return ErrorLvlLearnUp("Cant get next talent cell from taktik NUM: "..tostring(num))
	--end
	if spell == false then
		-- ������ ������� �����������
		return PassLearnUp()
	end
	-- ������� ������ ����
	local str = "field : "..tostring(spell.field).." layer: "..tostring(spell.layer).." line : "..tostring(spell.line)
	LevelUpLog("Get Info about Talent on "..str.."...")
	local info = avatar.GetFieldTalentInfo( spell.field, spell.layer, spell.line )
	-- �������� ���������� � �������
	if info == nil then
		-- ������� �� ���� ����������� ��� 
		return ErrorLvlLearnUp("Talent doesnt exist on "..str)
	end
	local currank = -1
	local name = "nil"
	if info.current == nil and info.next == nil then
		-- ������� �����, ���� �� ��� ������ ���� ������
		return ErrorLvlLearnUp("Current and Next is nil!")
	end
	if info.current ~= nil then
		--����� ����� ��� ������� 1 ����
		currank = info.current.rank
		name = debugCommon.FromWString(info.current.name)
	else
		-- ���� �� ������
		name = debugCommon.FromWString(info.next.name)
	end
	str = str.." name: "..name
	LevelUpLog("Current Rank : "..tostring(currank))
	if currank == 0 then
		--������ ���� ��� ��� ������ ����
		return ErrorLvlLearnUp("Talent uge learned "..str)
	end
	-- ���� �������� ������ 
	-- TODO (���� ����� ���� ���� �� ������ ������) ������
	local haveRuby = GetCurrency("Ruby")
	if haveRuby == nil then
		haveRuby = 0
	end
	if haveRuby < 1 or LEVEL_UP_RUBINS < 1 then
		-- ��� ������� ��� ��� ������
		LevelUpLog("Ruby "..tostring(haveRuby).." in srcipt "..tostring(LEVEL_UP_RUBINS))
		return PassLearnUp()
	end	
	
	-- ��� ��� ��� ����� ����
	if not info.canUpdate then
		return ErrorLvlLearnUp("Cant Update Field Talent on "..str)
	end
		
	LevelUpLog("Try Learn Next Talent "..name.."...")
	StartPrivateCheckTimer( 10000, TalentCheck, {base = false, field = spell.field, layer = spell.layer, line = spell.line, rank = currank},
							ErrorLvlLearnUp, "TIMEOUT Talent not updated on "..str, 
							LearnNextTalent, num + 1 )
	LEVEL_UP_RUBINS = LEVEL_UP_RUBINS - 1
	avatar.UpdateFieldTalent( spell.field, spell.layer, spell.line )
end

function TaktGetNextCell(num, base)

	for k, v in LEVEL_UP_TAKT do
		if k == num then
			local clayer = -1
			local cline = -1
			local cname = nil

			for key, value in v.conditions do
				if debugCommon.FromWString(value.rule) == "base" and base then
					if v.spells ~= nil then
						clayer = tonumber(debugCommon.FromWString(v.spells[1].target))
						cline = tonumber(debugCommon.FromWString(v.spells[1].name))
					end
					if v.endCondition ~= nil then
						cname = debugCommon.FromWString(v.endCondition.type)
					end
					return {layer = clayer, line = cline, name = cname}
				elseif debugCommon.FromWString(value.rule) == "field" and not base then
					local cfield = tonumber(debugCommon.FromWString(value.param))
					if v.spells ~= nil then
						clayer = tonumber(debugCommon.FromWString(v.spells[1].target))
						cline = tonumber(debugCommon.FromWString(v.spells[1].name))
					end
					if v.endCondition ~= nil then
						cname = debugCommon.FromWString(v.endCondition.type)
					end
					return {field = cfield, layer = clayer, line = cline, name = cname}
				end
			end
		end
	end
	return false
end

function TalentCheck(params)
	local info = nil
	if params.base == true then
		info = avatar.GetBaseTalentInfo( params.layer, params.line )
	else
		info = avatar.GetFieldTalentInfo( params.field, params.layer, params.line )
	end
	if info ~= nil then
		if info.current == nil then
			return false
		end
		if info.current.rank > params.rank then
			return true
		end
	end
	return false
end

function ErrorLvlLearnUp(params)
	LogErr(params,"LevelUp")
    LEVEL_UP_ERROR_FUNC(params)
end


function GetLayerLineTalent(name,field)
	local size = avatar.GetBaseTalentTableSize()
	for iLayer = 0, size.layersCount - 1, 1 do
		for iLine = 0, size.linesCount - 1, 1 do
			local Info
			if field == -1 then
				Info = avatar.GetBaseTalentInfo( iLayer, iLine )
			else
				Info = avatar.GetFieldTalentInfo( field, iLayer, iLine )
			end
			local infoname = ""
			local linkTalent = nil
			if Info ~= nil then
				if Info.current ~= nil then
					linkTalent = Info.current
				elseif Info.next ~= nil then
					linkTalent = Info.next
				end
				local sysName = nil	
				if linkTalent.spellId ~= nil then
					local spellInfo = avatar.GetSpellInfo(linkTalent.spellId)
					sysName = spellInfo.debugName
				else
					if linkTalent.abilityId ~= nil then
						local spellInfo = avatar.GetSpellInfo( linkTalent.spellId )
						sysName = spellInfo.sysInfo
					end
				end
				local find = false
				local same = false
				if sysName ~= nil then
					find = string.find(sysName, name)
					same = (sysName == name)
				else
					infoname = debugCommon.FromWString(linkTalent.name)
					find = string.find(infoname, name)
					same = (infoname == name)
				end
				--LevelUpLog(infoname.." find "..tostring(find).." "..name.." same "..tostring(same))
				if find or same then
					return {layer = iLayer, line = iLine}
				end
			end
		end
	end
	return nil
end
