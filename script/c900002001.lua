local s,id=GetID()
function s.initial_effect(c)
    aux.AddSkillProcedure(c,2,false,nil,nil)
    
    -- This card remains in the Skill Zone
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_CANNOT_TO_DECK)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    c:RegisterEffect(e0)
    
    e0=e0:Clone()
    e0:SetCode(EFFECT_CANNOT_TO_HAND)
    c:RegisterEffect(e0)
    
    e0=e0:Clone()
    e0:SetCode(EFFECT_CANNOT_TO_GRAVE)
    c:RegisterEffect(e0)
    
    e0=e0:Clone()
    e0:SetCode(EFFECT_CANNOT_REMOVE)
    c:RegisterEffect(e0)
    
    -- Activate at the start of the Duel (before the Draw Phase)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EVENT_STARTUP)
    e1:SetRange(LOCATION_ALL)
    e1:SetCountLimit(1)
    e1:SetOperation(s.startop)
    c:RegisterEffect(e1)
end

-- Setup effect for start of Duel
function s.startop(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PREDRAW)
    e1:SetCondition(function() return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 end)
    e1:SetOperation(s.addcard)
    e1:SetReset(RESET_PHASE|PHASE_DRAW)
    Duel.RegisterEffect(e1,tp)
end

-- Add "Change of Heart" from outside the Duel into the Deck and shuffle
function s.addcard(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
    Duel.Hint(HINT_CARD,tp,id)
    if Duel.IsExistingMatchingCard(aux.FilterEqualFunction(Card.GetCode,04031928),tp,LOCATION_DECK,0,1,nil) then return end
    local tc=Duel.CreateToken(tp,04031928) -- Change of Heart's official ID
    Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_RULE)
    Duel.ShuffleDeck(tp)
end
