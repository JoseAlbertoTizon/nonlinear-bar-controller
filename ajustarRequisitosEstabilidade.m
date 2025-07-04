function [requisitos_corrigido, J_min] = ajustarRequisitosEstabilidade(xr, requisitos, modo)
% Ajusta Mp e tr para estabilizar e aproximar dos desejados usando Nelder-Mead
% com recuos progressivos caso o sistema continue instável
% modo: 'ambos' ou 'tr'

    max_tentativas = 10;

    Mp_req = requisitos.x.Mp;
    tr_req = requisitos.x.tr;

    for tentativa = 1:max_tentativas
        fprintf("Tentativa = %d\n", tentativa);

        if strcmp(modo, 'ambos')
            x0 = [Mp_req, tr_req];
        elseif strcmp(modo, 'tr')
            x0 = tr_req;
        else
            error("Modo inválido. Use 'ambos' ou 'tr'.");
        end

        custo = @(x) custo_penalizado(x, xr, requisitos, modo);

        % Otimização Nelder-Mead
        [x_opt, J_min] = fminsearch(custo, x0);

        % Se encontrou solução viável, sai do loop
        if J_min < 1e6
            break;
        end

        % Caso contrário, aumenta tr
        tr_req = tr_req * 2;
    end

    % Retornar requisitos corrigidos
    requisitos_corrigido = requisitos;

    if strcmp(modo, 'ambos')
        requisitos_corrigido.x.Mp = min(max(x_opt(1), 0.01), 1.0);
        requisitos_corrigido.x.tr = max(x_opt(2), 0.01);
    else % apenas tr
        requisitos_corrigido.x.tr = max(x_opt, 0.01);
    end
end

function J = custo_penalizado(x, xr, requisitos, modo)
    PENALIDADE = 1e6;

    if strcmp(modo, 'ambos')
        Mp = x(1);
        tr = x(2);
    else % 'tr'
        Mp = requisitos.x.Mp;
        tr = x;
    end

    % Restrições
    if Mp > 1 || Mp < requisitos.x.Mp || tr < requisitos.x.tr
        J = PENALIDADE;
        return;
    end

    reqNovo = requisitos;
    reqNovo.x.Mp = Mp;
    reqNovo.x.tr = tr;

    sim = simularRampa(xr, reqNovo, false);
    estados = sim.x.signals.values;
    excesso = max(abs(estados), [], 'all');

    if excesso > 100 * max(abs(xr(:)))
        J = PENALIDADE;
    else
        J = (requisitos.x.Mp - Mp)^2 + (requisitos.x.tr - tr)^2;
    end
end
