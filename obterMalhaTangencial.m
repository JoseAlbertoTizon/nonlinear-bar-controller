function [dinamica, controlador] = obterMalhaTangencial(requisitos)

planta = obterPlanta();

tr = requisitos.x.tr;
Mp = requisitos.x.Mp;

g = planta.g;

xi = -log(Mp)/sqrt(pi^2+(log(Mp))^2);
wn = (pi-acos(xi))/(sqrt(1-xi^2)*tr);

Kd = 7*xi*wn/g;
Kp = wn^2*(1+10*xi^2)/g;
Ki = 5*xi*wn^3/g;

g = planta.g;

s = tf('s');
dinamica = Ki/((1/g)*s^3+Kd*s^2+Kp*s+Ki);

controlador.Kd = Kd;
controlador.Kp = Kp;
controlador.Ki = Ki;

end