-- Robo del Destino - Skill Script para EdoPro
local s,id=GetID()
function s.initial_effect(c)
    -- Registrar la habilidad como Skill (se activa una vez por Duelo)
    aux.AddSkillProcedure(c,1,false)
    local tp=c:GetControler()

    -- Configurar la variable global para almacenar LP previos (si aún no se ha hecho)
    if not s.global_check then
        s.global_check=true
        s.prev_lp = {}
        -- Inicializa los LP de cada jugador al comienzo del duelo
        for i=0,1 do
            s.prev_lp[i] = Duel.GetLP(i)
        end
        -- Crea un efecto global que se active al final de cada turno para actualizar los LP
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_PHASE+PHASE_END)
        ge1:SetOperation(s.updateLP)
        Duel.RegisterEffect(ge1,0)
    end

    -- Efecto: Durante la Draw Phase, si en el turno anterior perdiste 2000 o más LP, pregunta si quieres activar el efecto.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0)) -- Asegúrate de tener la descripción definida en tu archivo de idioma
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_PREDRAW)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.rdcon)
    e1:SetOperation(s.rdop)
    Duel.RegisterEffect(e1,tp)
end

-- Actualiza la variable global con los LP actuales de cada jugador al final del turno.
function s.updateLP(e,tp,eg,ep,ev,re,r,rp)
    for i=0,1 do
        s.prev_lp[i] = Duel.GetLP(i)
    end
end

-- Condición: Es tu turno, estamos en la Draw Phase y en el turno anterior perdiste al menos 2000 LP.
function s.rdcon(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetTurnPlayer()~=tp then return false end
    if Duel.GetCurrentPhase()~=PHASE_DRAW then return false end
    local prev = s.prev_lp[tp] or Duel.GetLP(tp)
    return Duel.GetLP(tp) <= prev - 2000
end

-- Operación: Pregunta al jugador si desea activar la habilidad.
-- Si acepta, se anula el robo normal y se le permite buscar 1 carta en su Deck.
function s.rdop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        -- Anula el robo normal de este Draw Phase
        local dt = Duel.GetDrawCount(tp)
        if dt > 0 then
            Duel.ChangeDrawCount(tp,0)
        end
        -- Permite al jugador seleccionar 1 carta de su Deck para añadirla a su mano
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local g = Duel.SelectMatchingCard(tp, aux.TRUE, tp, LOCATION_DECK, 0, 1, 1, nil)
        if #g > 0 then
            Duel.SendtoHand(g, nil, REASON_EFFECT)
            Duel.ConfirmCards(1-tp, g)
        end
    end
end
