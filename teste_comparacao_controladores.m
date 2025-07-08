function teste_comparacao_controladores()
% Compara diferentes tipos de controladores para a mesma referência
% Gera gráficos comparativos de desempenho (posição, ângulo e torque)

clear; close all; clc;

% Configurações do teste
xr = 0.9; % Posição desejada
tipoRequisito = 'A'; % Usar Mp e tr
controladores = {'P', 'PI', 'PD', 'DI', 'PID'};
cores = {'r', 'g', 'b', 'm', 'c'};

% Estruturas para armazenar resultados
resultados = struct();

fprintf('=== TESTE: Comparação de Controladores ===\n');
fprintf('Posição desejada: %.1f m\n', xr);
fprintf('Tipo de requisito: %s (Mp e tr)\n\n', tipoRequisito);

% Executar simulações
for i = 1:length(controladores)
    tipo = controladores{i};
    fprintf('Simulando controlador %s...\n', tipo);
    try
        sim = simularBarra(xr, tipo, tipoRequisito, false);
        resultados.(tipo).t = sim.tout;
        resultados.(tipo).x = sim.x.signals.values;
        resultados.(tipo).theta = sim.theta.signals.values;
        resultados.(tipo).tau = sim.tau.signals.values;
        resultados.(tipo).dx = sim.dx.signals.values;
        [Mp, tr, ts, tp, ess] = calcularMetricas(sim.tout, sim.x.signals.values, xr);
        resultados.(tipo).Mp = Mp;
        resultados.(tipo).tr = tr;
        resultados.(tipo).ts = ts;
        resultados.(tipo).tp = tp;
        resultados.(tipo).ess = ess;
        fprintf('  Mp: %.3f, tr: %.3f s, ts: %.3f s, ess: %.4f\n', Mp, tr, ts, ess);
    catch ME
        fprintf('  ERRO: %s\n', ME.message);
        continue;
    end
end

% Calcular limites automáticos para os gráficos
limites = calcularLimitesGraficos(resultados, xr);

% Gerar figura com layout de 1x3 sem espaço adicional
figure('Position', [100, 100, 1200, 500]);
t = tiledlayout(1,3,'TileSpacing','compact','Padding','compact');

% Gráfico 1: Posição x(t)
nexttile;
hold on; grid on;
for i = 1:length(controladores)
    tipo = controladores{i};
    if isfield(resultados, tipo)
        plot(resultados.(tipo).t, resultados.(tipo).x, ...
             'Color', cores{i}, 'LineWidth', 1.5, 'DisplayName', tipo);
    end
end
plot([0 10], [xr xr], 'k--', 'LineWidth', 1, 'DisplayName','Referência');
xlabel('Tempo (s)');
ylabel('Posição x (m)');
title('Resposta da Posição');
legend('Location','best');
xlim([0 10]);
ylim(limites.x);

% Gráfico 2: Ângulo θ(t)
nexttile;
hold on; grid on;
for i = 1:length(controladores)
    tipo = controladores{i};
    if isfield(resultados, tipo)
        plot(resultados.(tipo).t, resultados.(tipo).theta * 180/pi, ...
             'Color', cores{i}, 'LineWidth', 1.5, 'DisplayName', tipo);
    end
end
xlabel('Tempo (s)');
ylabel('Ângulo θ (°)');
title('Resposta Angular');
legend('Location','best');
xlim([0 10]);
ylim(limites.theta);

% Gráfico 3: Torque τ(t)
nexttile;
hold on; grid on;
for i = 1:length(controladores)
    tipo = controladores{i};
    if isfield(resultados, tipo)
        plot(resultados.(tipo).t, resultados.(tipo).tau, ...
             'Color', cores{i}, 'LineWidth', 1.5, 'DisplayName', tipo);
    end
end
xlabel('Tempo (s)');
ylabel('Torque τ (N·m)');
title('Esforço de Controle');
legend('Location','best');
xlim([0 10]);
ylim(limites.tau);

% Salvar figura
saveas(gcf, 'comparacao_controladores.png');
fprintf('\nGráfico salvo como: comparacao_controladores.png\n');

% Mostrar tabela de resultados
fprintf('\n=== TABELA DE RESULTADOS ===\n');
fprintf('Controlador\tMp\ttr(s)\tts(s)\tess\n');
fprintf('-------------------------------------------\n');
for i = 1:length(controladores)
    tipo = controladores{i};
    if isfield(resultados, tipo)
        fprintf('%s\t\t%.3f\t%.3f\t%.3f\t%.4f\n', tipo, ...
                resultados.(tipo).Mp, resultados.(tipo).tr, ...
                resultados.(tipo).ts, resultados.(tipo).ess);
    end
end

end


function limites = calcularLimitesGraficos(resultados, xr)
% Calcula limites automáticos para os gráficos baseados nos dados

% Coletar todos os valores
todas_posicoes = [];
todos_angulos = [];
todos_torques = [];

campos = fieldnames(resultados);
for i = 1:length(campos)
    tipo = campos{i};
    todas_posicoes = [todas_posicoes; resultados.(tipo).x];
    todos_angulos = [todos_angulos; resultados.(tipo).theta * 180/pi];
    todos_torques = [todos_torques; resultados.(tipo).tau];
end

% Calcular limites para posição
if ~isempty(todas_posicoes)
    x_min = min(todas_posicoes);
    x_max = max(todas_posicoes);
    
    % Garantir que a referência seja visível
    x_min = min(x_min, xr * 0.8);
    x_max = max(x_max, xr * 1.2);
    
    % Adicionar margem de 20%
    margem_x = (x_max - x_min);
    limites.x = [x_min - margem_x, x_max + margem_x];
    
    % Limitar valores extremos (máximo 10x a referência)
    limites.x(1) = max(limites.x(1), -10 * abs(xr));
    limites.x(2) = min(limites.x(2), 10 * abs(xr));
else
    limites.x = [-1, 3] * abs(xr);
end

% Calcular limites para ângulo
if ~isempty(todos_angulos)
    theta_min = min(todos_angulos);
    theta_max = max(todos_angulos);
    
    % Adicionar margem de
    margem_theta = (theta_max - theta_min);
    if margem_theta == 0
        margem_theta = 5; % Margem mínima de 5 graus
    end
    
    limites.theta = [theta_min - margem_theta, theta_max + margem_theta];
    
    % Limitar valores extremos (máximo ±360 graus)
    limites.theta(1) = max(limites.theta(1), -360);
    limites.theta(2) = min(limites.theta(2), 360);
else
    limites.theta = [-30, 30];
end

% Calcular limites para torque
if ~isempty(todos_torques)
    tau_min = min(todos_torques);
    tau_max = max(todos_torques);
    
    % Adicionar margem de 20%
    margem_tau = 0.2 * (tau_max - tau_min);
    if margem_tau == 0
        margem_tau = 5; % Margem mínima
    end
    
    limites.tau = [tau_min - margem_tau, tau_max + margem_tau];
    
    % Limitar valores extremos baseado no percentil 90%
    tau_sorted = sort(abs(todos_torques));
    idx_90 = round(0.90 * length(tau_sorted));
    if idx_90 > 0
        limite_extremo = tau_sorted(idx_90) * 3; % 3x o percentil 90%
        limites.tau(1) = max(limites.tau(1), -limite_extremo);
        limites.tau(2) = min(limites.tau(2), limite_extremo);
    end
else
    limites.tau = [-10, 10];
end

% Mostrar limites calculados (comentado)
% fprintf('\n=== LIMITES DOS GRÁFICOS ===\n');
% fprintf('Posição: [%.2f, %.2f] m\n', limites.x(1), limites.x(2));
% fprintf('Ângulo: [%.1f, %.1f] graus\n', limites.theta(1), limites.theta(2));
% fprintf('Torque: [%.1f, %.1f] N·m\n', limites.tau(1), limites.tau(2));

end

function [Mp, tr, ts, tp, ess] = calcularMetricas(t, x, xr)
% Calcula métricas de desempenho da resposta temporal

% Valor final (steady-state)
xss = x(end);
ess = abs(xr - xss); % Erro em regime permanente

% Valor de pico
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