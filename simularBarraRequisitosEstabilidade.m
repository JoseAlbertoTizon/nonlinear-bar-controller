function simulacao = simularBarraRequisitosEstabilidade(xr, tipo, tipoRequisito)
    requisitos = obterRequisitos();
    [requisitos_corrigido, ~] = ajustarRequisitosEstabilidade(xr, tipo, tipoRequisito, requisitos);

    simulacao = simularBarra(xr, tipo, tipoRequisito, true, requisitos_corrigido);

    requisitos_original = requisitos.x;
    requisitos_final = requisitos_corrigido.x;

    mudaram = false;
    mensagens = {};

    % Mp sempre será mostrado
    if requisitos_original.Mp ~= requisitos_final.Mp
        mudaram = true;
        mensagens{end+1} = sprintf('Mp: %.2f → %.2f', requisitos_original.Mp, requisitos_final.Mp);
    end

    % Verifica quais tempos mudaram (tr, tp, ts)
    if isfield(requisitos_original, 'tr') && requisitos_original.tr ~= requisitos_final.tr
        mudaram = true;
        mensagens{end+1} = sprintf('tr: %.2f → %.2f', requisitos_original.tr, requisitos_final.tr);
    end
    if isfield(requisitos_original, 'tp') && requisitos_original.tp ~= requisitos_final.tp
        mudaram = true;
        mensagens{end+1} = sprintf('tp: %.2f → %.2f', requisitos_original.tp, requisitos_final.tp);
    end
    if isfield(requisitos_original, 'ts') && requisitos_original.ts ~= requisitos_final.ts
        mudaram = true;
        mensagens{end+1} = sprintf('ts: %.2f → %.2f', requisitos_original.ts, requisitos_final.ts);
    end

    if mudaram
        fprintf('\n[AVISO] Não foi possível obter um sistema estável com os requisitos originais.\n');
        fprintf('Para obter um controlador estável, os requisitos foram ajustados da seguinte forma:\n');
        for i = 1:length(mensagens)
            fprintf('  - %s\n', mensagens{i});
        end
    end
end
