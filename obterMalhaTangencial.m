function dinamica = obterMalhaTangencial(controlador, planta)

Kd = controlador.Kd;
Kp = controlador.Kp;
Ki = controlador.Ki;

g = planta.g;

s = tf('s');
dinamica = Ki/((1/g)*s^3+Kd*s^2+Kp*s+Ki);

end