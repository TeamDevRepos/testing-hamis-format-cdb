local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
	-- Rastrea la cantidad de LP perdidos
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DAMAGE)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp then return end
	if ev>=1500 then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_DRAW,0,1)
	end
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	-- Verifica si el jugador ha perdido al menos 1500 LP antes de su Draw Phase
	return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(tp,id)>0 and Duel.GetTurnCount()>1 and Duel.IsTurnPlayer(tp) and Duel.GetCurrentPhase()==PHASE_DRAW
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ResetFlagEffect(tp,id)
	-- Reemplaza el robo normal por un monstruo aleatorio de atributo TIERRA
	local g=Duel.GetMatchingGroup(function(c) return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsMonster() end, tp, LOCATION_DECK, 0, nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:RandomSelect(tp,1)
		Duel.SendtoHand(sg,nil,REASON_RULE)
		Duel.ConfirmCards(1-tp,sg)
	else
		Duel.Draw(tp,1,REASON_RULE)
	end
end
