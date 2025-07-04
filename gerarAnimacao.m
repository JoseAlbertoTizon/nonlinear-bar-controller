function gerarAnimacao(t, x, theta)
    % animateBallOnBar Animate a ball on a rotating infinite bar
    % Inputs:
    %   t     - [N×1] time vector
    %   x     - [N×1] scalar ball position along bar (signed)
    %   theta - [N×1] bar angle (radians, 0 = horizontal)

    % --- Hardcoded speed control ---
    speedFactor = 0.9;  % < 1 slows down the animation

    % Set up figure
    figure('Color','white');
    ax = axes('XLim',[-max(abs(x))*1.5, max(abs(x))*1.5], ...
              'YLim',[-max(abs(x))*1.5, max(abs(x))*1.5], ...
              'DataAspectRatio',[1,1,1]);
    hold(ax,'on');
    barLine = plot(ax, [0,0], [0,0], 'k-', 'LineWidth',2);
    ball = plot(ax, NaN, NaN, 'ro', 'MarkerSize',8, 'MarkerFaceColor','r');

    % Animation loop
    for k = 1:length(t)
        L = max(abs(x))*1.5;
        ang = theta(k);
        xx = [-L, L] * cos(ang);
        yy = [-L, L] * sin(ang);
        barLine.XData = xx;
        barLine.YData = yy;

        % Ball position
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