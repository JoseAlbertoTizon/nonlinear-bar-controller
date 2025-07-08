function [dinamica, controlador] = obterMalhaAngular()

%Projeto da malha

planta = obterPlanta();
requisitos = obterRequisitos();

tr = requisitos.theta.tr;
Mp = requisitos.theta.Mp;

J = planta.J;

xi = -log(Mp)/sqrt(pi^2+(log(Mp))^2);
wn = (pi-acos(xi))/(sqrt(1-xi^2)*tr);

Kv = 2*xi*wn*J;
Kp = wn/(2*xi);

J = planta.J;

s = tf('s');
dinamica = (Kp*Kv)/(J*s^2+Kv*s+Kp*Kv);

controlador.Kv = Kv;
controlador.Kp = Kp;

end