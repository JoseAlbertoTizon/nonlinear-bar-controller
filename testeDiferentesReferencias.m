function testeDiferentesReferencias()
% Testa o mesmo controlador com diferentes valores de referência
% Analisa como a posição desejada afeta o desempenho

clear; close all; clc;

% Configurações do teste
referencias = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0]; % Diferentes posições desejadas
tipo = 'PD'; % Controlador a ser testado
tipoRequisito = 'A'; % Mp e tr
cores = parula(length(referencias));

fprintf('=== TESTE: Diferentes Referências ===\n');
fprintf('Controlador: %s\n', tipo);
fprintf('Tipo de requisito: %s (Mp e tr)\n\n', tipoRequisito);

% Estrutura para armazenar resultados
resultados = struct();

% Executar simulações
for i = 1:length(referencias)
    xr = referencias(i);
    fprintf('Simulando para xr = %.1f m...\n', xr);
    
    try
        sim = simularBarra(xr, tipo, tipoRequisito, false);
        
        % Armazenar resultados
        campo = sprintf('xr_%d', round(xr*10));
        resultados.(campo).t = sim.tout;
        resultados.(campo).x = sim.x.signals.values;
        resultados.(campo).theta = sim.theta.signals.values;
        resultados.(campo).tau = sim.tau.signals.values;
        resultados.(campo).xr = xr;
        
        % Calcular métricas
        [Mp, tr, ts, tp, ess] = calcularMetricas(sim.tout, sim.x.signals.values, xr);
        resultados.(campo).Mp = Mp;
        resultados.(campo).tr = tr;
        resultados.(campo).ts = ts;
        resultados.(campo).tp = tp;
        resultados.(campo).ess = ess;
        
        fprintf('  Mp: %.3f, tr: %.3f s, ts: %.3f s, ess: %.4f\n', Mp, tr, ts, ess);
        
    catch ME
        fprintf('  ERRO: %s\n', ME.message);
        continue;
    end
end

% Gerar gráficos
figure('Position', [100, 100, 1000, 700]);

% Gráfico 1: Resposta de posição
subplot(2,3,1);
hold on; grid on;
campos = fieldnames(resultados);
for i = 1:length(campos)
    campo = campos{i};
    plot(resultados.(campo).t, resultados.(campo).x, ...
         'Color', cores(i,:), 'LineWidth', 1.5, ...
         'DisplayName', sprintf('xr=%.1f', resultados.(campo).xr));
end
xlabel('Tempo (s)');
ylabel('x (m)');
title('Posição x para xr variados', 'FontSize', 10);
legend('Location', 'best', 'FontSize', 8);
xlim([0 10]);

% Gráfico 2: Ângulo theta
subplot(2,3,2);
hold on; grid on;
for i = 1:length(campos)
    campo = campos{i};
    plot(resultados.(campo).t, resultados.(campo).theta * 180/pi, ...
         'Color', cores(i,:), 'LineWidth', 1.5, ...
         'DisplayName', sprintf('xr=%.1f', resultados.(campo).xr));
end
xlabel('Tempo (s)');
ylabel('θ (graus)');
title('Ângulo θ para xr variados', 'FontSize', 10);
legend('Location', 'best', 'FontSize', 8);
xlim([0 10]);

% Gráfico 3: Esforço de controle
subplot(2,3,3);
hold on; grid on;
for i = 1:length(campos)
    campo = campos{i};
    plot(resultados.(campo).t, resultados.(campo).tau, ...
         'Color', cores(i,:), 'LineWidth', 1.5, ...
         'DisplayName', sprintf('xr=%.1f', resultados.(campo).xr));
end
xlabel('Tempo (s)');
ylabel('τ (N·m)');
title('Torque aplicado (τ)', 'FontSize', 10);
legend('Location', 'best', 'FontSize', 8);
xlim([0 10]);

% Gráfico 4: Mp e tr vs xr
subplot(2,3,4);
xr_vals = zeros(length(campos), 1);
Mp_vals = zeros(length(campos), 1);
tr_vals = zeros(length(campos), 1);
ts_vals = zeros(length(campos), 1);

for i = 1:length(campos)
    campo = campos{i};
    xr_vals(i) = resultados.(campo).xr;
    Mp_vals(i) = resultados.(campo).Mp;
    tr_vals(i) = resultados.(campo).tr;
    ts_vals(i) = resultados.(campo).ts;
end

[xr_sort, idx] = sort(xr_vals);
yyaxis left;
plot(xr_sort, Mp_vals(idx), 'o-', 'LineWidth', 2, 'MarkerSize', 8);
ylabel('Mp');
yyaxis right;
plot(xr_sort, tr_vals(idx), 's-', 'LineWidth', 2, 'MarkerSize', 8);
ylabel('tr (s)');
xlabel('xr (m)');
title('Mp e tr vs referência', 'FontSize', 10);
grid on;

% Gráfico 5: ts vs xr
subplot(2,3,5);
plot(xr_sort, ts_vals(idx), 'd-', 'LineWidth', 2, 'MarkerSize', 8, 'Color', 'red');
xlabel('xr (m)');
ylabel('ts (s)');
title('ts vs referência', 'FontSize', 10);
grid on;

% Gráfico 6: erro em regime permanente
subplot(2,3,6);
ess_vals = zeros(length(campos), 1);
for i = 1:length(campos)
    campo = campos{i};
    ess_vals(i) = abs(resultados.(campo).ess);
end
plot(xr_sort, ess_vals(idx), '^-', 'LineWidth', 2, 'MarkerSize', 8, 'Color', 'green');
xlabel('xr (m)');
ylabel('|Erro final|');
title('|Erro final| vs referência', 'FontSize', 10);
grid on;

% Salvar figura
saveas(gcf, 'diferentes_referencias.png');
fprintf('\nGráfico salvo como: diferentes_referencias.png\n');

% Mostrar tabela de resultados
fprintf('\n=== TABELA DE RESULTADOS ===\n');
fprintf('xr(m)\tMp\ttr(s)\tts(s)\t|ess|\n');
fprintf('-----------------------------------\n');
for i = 1:length(xr_sort)
    idx_campo = idx(i);
    campo = campos{idx_campo};
    fprintf('%.1f\t%.3f\t%.3f\t%.3f\t%.4f\n', ...
            xr_sort(i), Mp_vals(idx_campo), tr_vals(idx_campo), ...
            ts_vals(idx_campo), abs(ess_vals(idx_campo)));
end

end

function [Mp, tr, ts, tp, ess] = calcularMetricas(t, x, xr)
% Calcula métricas de desempenho da resposta temporal

xss = x(end);
ess = abs(xr - xss); % Erro em regime permanente

[xmax, idx_max] = max(x);
Mp = (xmax - xss) / xss; % Sobressinal percentual
tp = t(idx_max); % Tempo de pico

% Tempo de subida (10% a 90% do valor final)
x10 = 0.1 * xss;
x90 = 0.9 * xss;
idx10 = find(x >= x10, 1);
idx90 = find(x >= x90, 1);
if ~isempty(idx10) && ~isempty(idx90)
    tr = t(idx90) - t(idx10);
else
    tr = NaN;
end

% Tempo de acomodação (±2% do valor final)
tolerancia = 0.02 * abs(xss);
for i = length(x):-1:1
    if abs(x(i) - xss) > tolerancia
        ts = t(i);
        break;
    end
end
if ~exist('ts', 'var')
    ts = 0;
end

end
