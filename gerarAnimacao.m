function gerarAnimacao(xr, tipo, requisito)
    
    simulacao = simularBarra(xr, tipo, requisito);
    t = simulacao.tout;
    x = simulacao.x.signals.values;
    theta = simulacao.theta.signals.values;
    
    speedFactor = 1; % Velocidade da animação

    % Gerar Gráficos
    figure('Color','white');
    ax = axes('XLim',[-max(abs(x))*1.5, max(abs(x))*1.5], ...
              'YLim',[-max(abs(x))*1.5, max(abs(x))*1.5], ...
              'DataAspectRatio',[1,1,1]);
    hold(ax,'on');
    barLine = plot(ax, [0,0], [0,0], 'k-', 'LineWidth',1);
    ball = plot(ax, NaN, NaN, 'ro', 'MarkerSize',6, 'MarkerFaceColor','r');

    % Animação
    for k = 1:length(t)
        L = max(abs(x))*1.5;
        ang = theta(k);
        xx = [-L, L] * cos(ang);
        yy = [-L, L] * sin(ang);
        barLine.XData = xx;
        barLine.YData = yy;
        xb = x(k) * cos(ang);
        yb = x(k) * sin(ang);
        ball.XData = xb;
        ball.YData = yb;

        drawnow;

        if k < length(t)
            pause((t(k+1)-t(k)) / speedFactor);
        end
    end
end