-- Robo del Destino
-- Habilidad de Duel Links adaptada para EdoPro
-- Condición: Si tus LP ≤ 6000 en tu Draw Phase, en lugar de robar normalmente,
-- puedes buscar en tu Deck cualquier carta y añadirla a tu mano.
local s,id=GetID()
function s.initial_effect(c)
    -- Agrega la habilidad como Skill (se usa auxiliarmente; se activa solo una vez por duelo)
    aux.AddSkillProcedure(c,1,false)
    -- Efecto: Durante la Draw Phase, si es tu turno y tus LP ≤ 6000, pregunta si quieres activar el efecto.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0)) -- Asegúrate de definir en los textos la descripción de la habilidad.
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_PREDRAW)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.rdcon)
    e1:SetOperation(s.rdop)
    Duel.RegisterEffect(e1,0)
end

-- Condición: Es tu turno (Draw Phase) y tus LP son 6000 o menos.
function s.rdcon(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetTurnPlayer()~=tp then return false end
    if Duel.GetCurrentPhase()~=PHASE_DRAW then return false end
    return Duel.GetLP(tp)<=6000
end

-- Operación: Pregunta al jugador si desea activar la habilidad.
-- Si acepta, se anula el robo normal (se cambia la cuenta de robo a 0) y se le permite buscar una carta de su Deck.
function s.rdop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        -- Anula el robo normal de este Draw Phase
        local dt=Duel.GetDrawCount(tp)
        if dt>0 then
            Duel.ChangeDrawCount(tp,0)
        end
        -- Permite al jugador seleccionar una carta de su Deck para añadirla a su mano
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
end
