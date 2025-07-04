function [dinamica, controlador] = obterMalhaTangencial(ctrlType, requisitos)
% Gera função de transferência explícita da malha tangencial
% Modela sistema de 3ª ordem com controladores P, PD, PI, PID, PV

planta = obterPlanta();
g = planta.g;

% Requisitos
tr = getfieldSafe(requisitos, {'x','tr'});
Mp = getfieldSafe(requisitos, {'x','Mp'});

if isempty(tr) || isempty(Mp)
    error('Requisitos mínimos (tr e Mp) não fornecidos.');
end

% Parâmetros do sistema de 3ª ordem
xi = -log(Mp)/sqrt(pi^2 + (log(Mp))^2);
wn = (pi - acos(xi)) / (sqrt(1 - xi^2) * tr);

switch upper(ctrlType)
    case 'P'
        Kp = wn^2 * g;
        Ki = 0;
        Kd = 0;
        num = [Kp];
        den = [1/g, 0, Kp];
        dinamica = tf(num, den);

    case 'PD'
        Kp = wn^2 * g;
        Kd = 2 * xi * wn * g;
        Ki = 0;
        num = [Kp];
        den = [1/g, Kd, Kp];
        dinamica = tf(num, den);

    case 'PI'
        Kp = 2 * xi * wn * g;
        Ki = wn^3 * g;
        Kd = 0;
        num = [Ki];
        den = [1/g, 0, Kp, Ki];
        dinamica = tf(num, den);

    case 'PID'
        Kp = wn^2 * g * (1 + 10 * xi^2);
        Ki = 5 * xi * wn^3 * g;
        Kd = 7 * xi * wn * g;
        num = [Kd, Kp, Ki];
        den = [1/g, Kd, Kp, Ki];
        dinamica = tf(num, den);

    case 'PV'
        Kp = wn^2 * g;
        Kd = 2 * xi * wn * g;
        Ki = 0;
        num = [Kp];
        den = [1/g, Kd, Kp];
        dinamica = tf(num, den);

    otherwise
        error('Tipo de controlador inválido. Use: P, PD, PI, PID, PV');
end

% Estrutura de saída com nomes corretos
controlador.Type = ctrlType;
controlador.Kp = Kp;
if exist('Ki','var') && Ki ~= 0, controlador.Ki = Ki; end
if exist('Kd','var') && Kd ~= 0, controlador.Kd = Kd; end

end

function v = getfieldSafe(st, path)
    try v = getfield(st, path{:});
    catch, v = []; end
end
