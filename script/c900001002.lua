local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon restriction
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_FIRE),2)

	-- Set Fire Formation Spells/Traps
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.setcon)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)

	-- ATK Boost for Fire Fist monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x79))
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
		return ct>0 and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,ct,nil)
	end
end

function s.setfilter(c)
	return c:IsSetCard(0x7c) and c:IsSpellTrap() and c:IsSSetable()
end

function s.atkfilter(c)
	return c:IsFaceup() and c:IsSpellTrap() and c:IsSetCard(0x7c)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,99,nil)
	if #g>0 then
		local ct=Duel.SendtoGrave(g,REASON_EFFECT)
		if ct>0 then
			local sg=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
			if #sg>=ct then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
				local setg=aux.SelectUnselectGroup(sg,e,tp,ct,ct,aux.dncheck,1,tp,HINTMSG_SET)
				if #setg>0 then
					Duel.SSet(tp,setg)
				end
			end
		end
	end

	-- Restrict activation of non-Fire Formation S/T
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and not re:GetHandler():IsSetCard(0x7c)
end

function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)*100
end