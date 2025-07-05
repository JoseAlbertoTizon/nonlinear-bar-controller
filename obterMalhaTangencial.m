function [dinamica, controlador] = obterMalhaTangencial(tipo, requisito)

planta = obterPlanta();
requisitos = obterRequisitos();

tr = requisitos.x.tr;
Mp = requisitos.x.Mp;
tp = requisitos.x.tp;
ts = requisitos.x.ts;

g = planta.g;

%%Requisito tipo a: Mp e tr, b: Mp e tp, c: Mp e ts
switch upper(requisito)
    case 'A'
        xi = -log(Mp)/sqrt(pi^2+(log(Mp))^2);
        wn = (pi-acos(xi))/(sqrt(1-xi^2)*tr);
    
    case 'B'
        xi = -log(Mp)/sqrt(pi^2+(log(Mp))^2);
        wn = pi/(sqrt(1-xi^2)*tp);

    case 'C'
        xi = -log(Mp)/sqrt(pi^2+(log(Mp))^2);
        wn = 3/(xi*ts);
    
    otherwise
        error('Tipo de requisito inválido. Use: A, B ou C (Veja a documentacao)');
end

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

    otherwise
        error('Tipo de controlador inválido. Use: P, PD, PI ou PID');
end
end