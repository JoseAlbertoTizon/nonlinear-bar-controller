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

% Executar simulações
for i = 1:length(controladores)
    tipo = controladores{i};
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
    catch ME
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
    
    % Adicionar margem 
    margem_x = (x_max - x_min);
    limites.x = [x_min - margem_x, x_max + margem_x];
    
    limites.x(1) = max(limites.x(1), -10 * abs(xr));
    limites.x(2) = min(limites.x(2), 10 * abs(xr));
else
    limites.x = [-1, 3] * abs(xr);
end

if ~isempty(todos_angulos)
    theta_min = min(todos_angulos);
    theta_max = max(todos_angulos);
    
    margem_theta = (theta_max - theta_min);
    if margem_theta == 0
        margem_theta = 5;
    end
    
    limites.theta = [theta_min - margem_theta, theta_max + margem_theta];
    
    % Limitar valores extremos
    limites.theta(1) = max(limites.theta(1), -360);
    limites.theta(2) = min(limites.theta(2), 360);
else
    limites.theta = [-30, 30];
end

if ~isempty(todos_torques)
    tau_min = min(todos_torques);
    tau_max = max(todos_torques);
    
    margem_tau = 0.2 * (tau_max - tau_min);
    if margem_tau == 0
        margem_tau = 5;
    end
    
    limites.tau = [tau_min - margem_tau, tau_max + margem_tau];
    
    tau_sorted = sort(abs(todos_torques));
    idx_90 = round(0.90 * length(tau_sorted));
    if idx_90 > 0
        limite_extremo = tau_sorted(idx_90) * 3;
        limites.tau(1) = max(limites.tau(1), -limite_extremo);
        limites.tau(2) = min(limites.tau(2), limite_extremo);
    end
else
    limites.tau = [-10, 10];
end

end