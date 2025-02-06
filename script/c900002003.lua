local s,id=GetID()

function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	-- Verifica si el jugador ha perdido 1500 LP
	return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(tp,id)<Duel.GetLP(tp)//1500
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	-- Reemplaza el robo normal por un monstruo aleatorio de atributo TIERRA
	local g=Duel.GetMatchingGroup(Card.IsAttribute,tp,LOCATION_DECK,0,nil,ATTRIBUTE_EARTH)
	if #g>0 then
		local sg=g:RandomSelect(tp,1)
		Duel.SendtoHand(sg,nil,REASON_RULE)
		Duel.ConfirmCards(1-tp,sg)
	else
		Duel.Draw(tp,1,REASON_RULE)
	end
end
