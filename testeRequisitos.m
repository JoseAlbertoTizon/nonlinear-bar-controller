function testeRequisitos()

casos_teste = [
    struct('xr', 0.9, 'tipo', 'PD', 'tipoReq', 'A', 'nome', 'Caso 1: xr=0.9m, PD');
    struct('xr', 0.9, 'tipo', 'PD', 'tipoReq', 'B', 'nome', 'Caso 2: xr=0.9m, PD');
    struct('xr', 0.9, 'tipo', 'PD', 'tipoReq', 'C', 'nome', 'Caso 3: xr=0.9m, PD');
];

fprintf('=== TESTE: Ajuste Automático de Requisitos ===\n\n');

resultados = struct();

for i = 1:length(casos_teste)
    caso = casos_teste(i);
    fprintf('Processando %s...\n', caso.nome);
    
    try
        fprintf('  Testando com requisitos originais...\n');
        sim_original = simularBarra(caso.xr, caso.tipo, caso.tipoReq, false);  % NÃO deve gerar gráfico
        x_vals = sim_original.x.signals.values;
        sistema_estavel_original = max(abs(x_vals)) <= 20 * abs(caso.xr);
        if sistema_estavel_original
            fprintf('  Sistema estável com requisitos originais.\n');
        else
            fprintf('  Sistema instável com requisitos originais.\n');
        end
    catch ME
        fprintf('  ERRO com requisitos originais: %s\n', ME.message);
        sim_original = [];
        sistema_estavel_original = false;
    end

    try
        fprintf('  Executando com ajuste automático...\n');
        sim_ajustado = simularBarraRequisitosEstabilidade(caso.xr, caso.tipo, caso.tipoReq);  % NÃO deve gerar gráfico
        sistema_estavel_ajustado = true;
    catch ME
        fprintf('  ERRO com ajuste automático: %s\n', ME.message);
        sim_ajustado = [];
        sistema_estavel_ajustado = false;
    end

    campo = sprintf('caso_%d', i);
    resultados.(campo).caso = caso;
    resultados.(campo).estavel_original = sistema_estavel_original;
    resultados.(campo).estavel_ajustado = sistema_estavel_ajustado;
    resultados.(campo).sim_original = sim_original;
    resultados.(campo).sim_ajustado = sim_ajustado;

    fprintf('  Concluído.\n\n');
end

campos = fieldnames(resultados);
for i = 1:length(campos)
    campo = campos{i};
    resultado = resultados.(campo);

    if resultado.estavel_original && resultado.estavel_ajustado && ...
       ~isempty(resultado.sim_original) && ~isempty(resultado.sim_ajustado)

        figure('Name', resultado.caso.nome, 'Position', [100, 100, 1000, 600]);

        subplot(2,2,1); hold on; grid on;
        plot(resultado.sim_original.tout, resultado.sim_original.x.signals.values, 'r', 'LineWidth', 2);
        plot([0 10], [resultado.caso.xr resultado.caso.xr], 'k--');
        title('Posição - Requisitos Originais');
        xlabel('Tempo (s)'); ylabel('x (m)'); xlim([0 10]);

        subplot(2,2,2); hold on; grid on;
        plot(resultado.sim_ajustado.tout, resultado.sim_ajustado.x.signals.values, 'b', 'LineWidth', 2);
        plot([0 10], [resultado.caso.xr resultado.caso.xr], 'k--');
        title('Posição - Requisitos Ajustados');
        xlabel('Tempo (s)'); ylabel('x (m)'); xlim([0 10]);

        subplot(2,2,3); hold on; grid on;
        plot(resultado.sim_original.tout, resultado.sim_original.theta.signals.values * 180/pi, 'r', 'LineWidth', 2);
        title('Ângulo - Requisitos Originais');
        xlabel('Tempo (s)'); ylabel('\theta (graus)'); xlim([0 10]);

        subplot(2,2,4); hold on; grid on;
        plot(resultado.sim_ajustado.tout, resultado.sim_ajustado.theta.signals.values * 180/pi, 'b', 'LineWidth', 2);
        title('Ângulo - Requisitos Ajustados');
        xlabel('Tempo (s)'); ylabel('\theta (graus)'); xlim([0 10]);
    end
end

fprintf('\n=== RELATÓRIO DE AJUSTE DE REQUISITOS ===\n');
fprintf('Caso\t\tControlador\tTipo\txr\tOriginal\tAjustado\n');
fprintf('--------------------------------------------------------\n');

for i = 1:length(campos)
    campo = campos{i};
    r = resultados.(campo);
    fprintf('Caso %d\t\t%s\t\t%s\t%.1f\t%s\t\t%s\n', ...
        i, r.caso.tipo, r.caso.tipoReq, r.caso.xr, ...
        tern(r.estavel_original,'Estável','Instável'), ...
        tern(r.estavel_ajustado,'Estável','Falhou'));
end

fprintf('\nLegenda dos Tipos de Requisito:\n');
fprintf('A: Mp e tr (tempo de subida)\n');
fprintf('B: Mp e tp (tempo de pico)\n');
fprintf('C: Mp e ts (tempo de acomodação)\n');

fprintf('\n=== ANÁLISE DOS REQUISITOS AJUSTADOS ===\n');
requisitos_originais = obterRequisitos();
fprintf('Requisitos Originais:\n');
fprintf('  Mp: %.3f\n', requisitos_originais.x.Mp);
fprintf('  tr: %.3f s\n', requisitos_originais.x.tr);
fprintf('  tp: %.3f s\n', requisitos_originais.x.tp);
fprintf('  ts: %.3f s\n', requisitos_originais.x.ts);

fprintf('\nObservações:\n');
fprintf('- O sistema de ajuste automático busca requisitos mais brandos até garantir estabilidade.\n');
fprintf('- Se o sistema continua instável, os tempos são dobrados até no máximo 10 tentativas.\n');

end

function out = tern(cond, valTrue, valFalse)
    if cond
        out = valTrue;
    else
        out = valFalse;
    end
end
