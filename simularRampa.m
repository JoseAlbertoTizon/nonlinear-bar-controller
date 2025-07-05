function simulacao = simularRampa(xr, tipo, requisito)

planta = obterPlanta();
saturacoes = obterValoresSaturacao();
[~,controlador.theta] = obterMalhaAngular();
[~,controlador.x] = obterMalhaTangencial(tipo, requisito);
tf = 10;

controlador.g = planta.g;

% Transformar xr em um vetor constante
xr = [0, xr; tf, xr];

% Configurando as variaveis usadas no Simulink
assignin('base', 'xr', xr);
assignin('base', 'x0', 0);
assignin('base', 'theta0', 0);
assignin('base', 'controlador', controlador);
assignin('base', 'planta', planta);
assignin('base', 'saturacoes', saturacoes);

% Carregando o Simulink
load_system('controladorRampa');

% Configurando o tempo final de simulacao
set_param('controladorRampa', 'StopTime', sprintf('%g', tf));

% Rodando a simulacao
simulacao = sim('controladorRampa');

% Plotar gráficos t por x e t por theta
t = simulacao.tout;
x = simulacao.x.signals.values;
theta = simulacao.theta.signals.values;
tau = simulacao.tau.signals.values;
dx = simulacao.dx.signals.values;

figure;

subplot(2,2,1);
plot(t, x, 'LineWidth', 1.5);
grid on;
xlabel('Tempo (s)');
ylabel('Posição x (m)');
title('Resposta da posição x');

subplot(2,2,2);
plot(t, theta, 'LineWidth', 1.5);
grid on;
xlabel('Tempo (s)');
ylabel('\theta (rad)');
title('Resposta do ângulo \theta');

subplot(2,2,3);
plot(t, tau, 'LineWidth', 1.5);
grid on;
xlabel('Tempo (s)');
ylabel('\tau (N\cdotm)');
title('Resposta do torque \tau');

subplot(2,2,4);
plot(t, dx, 'LineWidth', 1.5);
grid on;
xlabel('Tempo (s)');
ylabel('Velocidade dx (m/s)');
title('Resposta da velocidade dx');

end