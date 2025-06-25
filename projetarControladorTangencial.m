function controlador = projetarControladorTangencial(requisitos, planta)

tr = requisitos.tr;
Mp = requisitos.Mp;

g = planta.g;

xi = -log(Mp)/sqrt(pi^2+(log(Mp))^2);
wn = (pi-acos(xi))/(sqrt(1-xi^2)*tr);

controlador.Kd = 7*xi*wn/g;
controlador.Kp = wn^2*(1+10*xi^2)/g;
controlador.Ki = 5*xi*wn^3/g;

end