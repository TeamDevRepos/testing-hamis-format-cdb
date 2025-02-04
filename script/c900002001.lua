local s,id=GetID()
function s.initial_effect(c)
    -- Activate at the start of the Duel (before the Draw Phase)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PREDRAW)
    e1:SetCondition(s.startcon)
    e1:SetOperation(s.startop)
    Duel.RegisterEffect(e1,0)
end

-- Condition: Only activate at the start of the Duel (before first Draw Phase)
function s.startcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnCount()==1 and Duel.GetDrawCount(tp)>0
end

-- Operation: Add "Change of Heart" from outside the Duel into the Deck and shuffle
function s.startop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.CreateToken(tp,04031928) -- Change of Heart's official ID
    Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_RULE)
    Duel.ShuffleDeck(tp)
    Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
    Duel.Hint(HINT_CARD,tp,id)
    Duel.Hint(HINT_MESSAGE,tp,HINTMSG_ATOHAND)
    Duel.Hint(HINT_MESSAGE,1-tp,HINTMSG_ATOHAND)
end