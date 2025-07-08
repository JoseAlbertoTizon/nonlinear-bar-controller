function testeDiferentesReferencias()
% Testa o mesmo controlador com diferentes valores de referência
% Analisa como a posição desejada afeta o desempenho

clear; close all; clc;

% Configurações do teste
referencias = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0]; 
tipo = 'PD'; 
tipoRequisito = 'A'; % Mp e tr
cores = parula(length(referencias));

resultados = struct();

for i = 1:length(referencias)
    xr = referencias(i);
    
    try
        sim = simularBarra(xr, tipo, tipoRequisito, false);
        
        campo = sprintf('xr_%d', round(xr*10));
        resultados.(campo).t = sim.tout;
        resultados.(campo).x = sim.x.signals.values;
        resultados.(campo).theta = sim.theta.signals.values;
        resultados.(campo).tau = sim.tau.signals.values;
        resultados.(campo).xr = xr;
        
        [Mp, tr, ts, tp, ess] = calcularMetricas(sim.tout, sim.x.signals.values, xr);
        resultados.(campo).Mp = Mp;
        resultados.(campo).tr = tr;
        resultados.(campo).ts = ts;
        resultados.(campo).tp = tp;
        resultados.(campo).ess = ess;
                
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

saveas(gcf, 'diferentes_referencias.png');

end

function [Mp, tr, ts, tp, ess] = calcularMetricas(t, x, xr)

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
