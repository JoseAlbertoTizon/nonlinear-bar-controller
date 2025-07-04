function [dinamica, controlador] = obterMalhaAngular(ctrlType, requisitos)
% Gera função de transferência explícita da malha angular
% Aceita tipos: P, PD, PI, PID, PV
% Usa tr e Mp para definir ganhos com nomenclatura apropriada

planta = obterPlanta();
J = planta.J;

% Requisitos
tr = getfieldSafe(requisitos, {'theta','tr'});
Mp = getfieldSafe(requisitos, {'theta','Mp'});

if isempty(tr) || isempty(Mp)
    error('Requisitos mínimos (tr e Mp) não fornecidos.');
end

% Parâmetros de projeto
xi = -log(Mp)/sqrt(pi^2 + (log(Mp))^2);
wn = (pi - acos(xi)) / (sqrt(1 - xi^2) * tr);

switch upper(ctrlType)
    case 'P'
        Kp = wn^2 * J;
        num = [Kp];
        den = [J, 0, Kp];
        dinamica = tf(num, den);
        controlador.Kp = Kp;

    case 'PD'
        Kd = 2 * xi * wn * J;
        Kp = wn^2 * J;
        num = [Kp];
        den = [J, Kd, Kp];
        dinamica = tf(num, den);
        controlador.Kp = Kp;
        controlador.Kd = Kd;

    case 'PI'
        Ki = wn^3 * J;
        Kp = 2 * xi * wn * J;
        num = [Ki];
        den = [J, 0, Kp, Ki];
        dinamica = tf(num, den);
        controlador.Kp = Kp;
        controlador.Ki = Ki;

    case 'PID'
        Kd = 7 * xi * wn * J;
        Kp = wn^2 * J * (1 + 10 * xi^2);
        Ki = 5 * xi * wn^3 * J;
        num = [Kd, Kp, Ki];
        den = [J, Kd, Kp, Ki];
        dinamica = tf(num, den);
        controlador.Kp = Kp;
        controlador.Ki = Ki;
        controlador.Kd = Kd;

    case 'PV'  % Derivada na saída (velocidade)
        Kd = 2 * xi * wn * J;
        Kp = wn^2 * J;
        num = [Kp];
        den = [J, Kd, Kp];
        dinamica = tf(num, den);
        controlador.Kp = Kp;
        controlador.Kd = Kd;

    otherwise
        error('Tipo de controlador inválido. Use: P, PD, PI, PID, PV');
end

controlador.Type = ctrlType;

end

function v = getfieldSafe(st, path)
    try v = getfield(st, path{:});
    catch, v = []; end
end
