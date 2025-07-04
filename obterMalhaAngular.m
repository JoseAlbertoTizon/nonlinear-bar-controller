function dinamica = obterMalhaAngular(controlador, planta)

Kp = controlador.Kp;
Kv = controlador.Kv;

J = planta.J;

s = tf('s');
dinamica = (Kp*Kv)/(J*s^2+Kv*s+Kp*Kv);

end