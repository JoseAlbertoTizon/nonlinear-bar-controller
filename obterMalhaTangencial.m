function [dinamica, controlador] = obterMalhaTangencial(tipo)

planta = obterPlanta();
requisitos = obterRequisitos();

tr = requisitos.x.tr;
Mp = requisitos.x.Mp;

g = planta.g;

xi = -log(Mp)/sqrt(pi^2+(log(Mp))^2);
wn = (pi-acos(xi))/(sqrt(1-xi^2)*tr);

s = tf('s');

switch upper(tipo)
    case 'PID'
        Kd = 7*xi*wn/g;
        Kp = wn^2*(1+10*xi^2)/g;
        Ki = 5*xi*wn^3/g;

        dinamica = Ki/((1/g)*s^3+Kd*s^2+Kp*s+Ki);

        controlador.Kd = Kd;
        controlador.Kp = Kp;
        controlador.Ki = Ki;
        controlador.F = 0;
    case 'PD'
        Kd = 2*xi*wn/g;
        Kp = wn^2/g;
        Ki = 0;
        
        dinamica = Kp/((1/g)*s^2+Kd*s+Kp);

        controlador.Kd = Kd;
        controlador.Kp = Kp;
        controlador.Ki = Ki;
        controlador.F = 1;
    case 'PI'
        Kd = 0;
        Kp = (wn^2-4*xi^2*wn^2)/g;
        Ki = 2*xi*wn^3/g;
        
        dinamica = Kp/((1/g)*s^3+Kp*s+Ki);

        controlador.Kd = Kd;
        controlador.Kp = Kp;
        controlador.Ki = Ki;
        controlador.F = 0;
    case 'P'
        Kd = 0;
        Kp = wn^2/g;
        Ki = 0;
        
        dinamica = Kp/((1/g)*s^3+Kp*s+Ki);

        controlador.Kd = Kd;
        controlador.Kp = Kp;
        controlador.Ki = Ki;
        controlador.F = 1;
end