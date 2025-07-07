function [requisitos_corrigido, J_min] = ajustarRequisitosEstabilidade(xr, tipo, tipoRequisito, requisitos)
% Resumo do algoritmo: realiza uma busca utilizando o algoritmo de
% Nelder-Mead para encontrar o par de requisitos (Mp, tr ou tp ou ts) mais
% próximo do desejado que torna o sistema estável. Se após a busca o
% sistema continuar instável, o valor de tr ou tp ou ts é dobrado e é
% realizada outra busca até um máximo de 10 tentativas além da primeira.

    max_tentativas = 11;

    Mp_req = requisitos.x.Mp;

    switch upper(tipoRequisito)
    case 'A'
        t_req = requisitos.x.tr;
        requisitos.x.t = requisitos.x.tr;
    
    case 'B'
        t_req = requisitos.x.tp;
        requisitos.x.t = requisitos.x.tp;
    case 'C'
        t_req = requisitos.x.ts;
        requisitos.x.t = requisitos.x.ts;
    end

    for tentativa = 1:max_tentativas
        if tentativa == 2
            fprintf('Ajustando requisitos para estabilizar o sistema.\n');
        end
        if tentativa > 1
            fprintf('Tentativa %d de %d\n', tentativa-1, max_tentativas-1);
        end

        x0 = [Mp_req, t_req];

        custo = @(x) custo_penalizado(x, xr, tipo, tipoRequisito, requisitos);

        % Otimização Nelder-Mead
        [x_opt, J_min] = fminsearch(custo, x0);

        % Se encontrou solução viável, sai do loop
        if J_min < 1e6
            break;
        end

        % Caso contrário, aumenta tr
        t_req = t_req * 2;
    end

    % Retornar requisitos corrigidos
    requisitos_corrigido = requisitos;

    requisitos_corrigido.x.Mp = min(max(x_opt(1), 0.01), 1.0);

    switch upper(tipoRequisito)
    case 'A'
        requisitos_corrigido.x.tr = max(x_opt(2), 0.01);    
    case 'B'
        requisitos_corrigido.x.tp = max(x_opt(2), 0.01);    
    case 'C'
        requisitos_corrigido.x.ts = max(x_opt(2), 0.01);    
    end

    requisitos_corrigido.x = rmfield(requisitos_corrigido.x, 't');
end

function J = custo_penalizado(x, xr, tipo, tipoRequisito, requisitos)
    PENALIDADE = 1e6;

    Mp = x(1);
    t = x(2);

    % Restrições
    if Mp > 1 || Mp < requisitos.x.Mp || t < requisitos.x.t
        J = PENALIDADE;
        return;
    end

    reqNovo = requisitos;
    reqNovo.x.Mp = Mp;
    reqNovo.x.t = t;

    switch upper(tipoRequisito)
    case 'A'
        reqNovo.x.tr = t;
    
    case 'B'
        reqNovo.x.tp = t;
    case 'C'
        reqNovo.x.ts = t;
    end

    sim = simularBarra(xr, tipo, tipoRequisito, false, reqNovo);
    estados = sim.x.signals.values;
    excesso = max(abs(estados), [], 'all');

    if excesso > 20 * max(abs(xr(:)))
        J = PENALIDADE;
    else
        J = (requisitos.x.Mp - Mp)^2 + (requisitos.x.t - t)^2;
    end
end
