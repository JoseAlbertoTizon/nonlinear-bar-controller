function [dinamica, controlador] = obterMalhaTangencial(ctrlType, requisitos)
% Gera função de transferência explícita da malha tangencial
% Modela sistema de 3ª ordem com controladores P, PD, PI, PID, PV

planta = obterPlanta();
g = planta.g;

% Requisitos
tr = requisitos.x.tr;
Mp = requisitos.x.Mp;

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
    
    case 'LEAD'
        alpha = 5/(7*(1+10*xi^2));
        T = (1+10*xi^2)/(5*xi*wn);
        K = 5*wn^2/(7*(-g));
        num = [K*(-g)*T, K*(-g)];
        den = [alpha*T, 1, K*(-g)*T, K*(-g)];
        dinamica = tf(num, den);
    
    otherwise
        error('Tipo de controlador inválido. Use: P, PD, PI, PID ou LEAD');
end

controlador.Type = ctrlType;
controlador.Kp = Kp;
controlador.Ki = Ki;
controlador.Kd = Kd;

if strcmp(ctrlType, 'LEAD')
    controlador.K = K;
    controlador.alpha = alpha;
    controlador.T = T;
else
    controlador.Kp = Kp;
    controlador.Ki = Ki;
    controlador.Kd = Kd;
end

end
