function simulacao = simularRampa(controlador, planta, saturacoes, tf, xr)

controlador.g = planta.g;

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

end
