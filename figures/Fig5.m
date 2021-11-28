% Fig5
%     reproduces Figure 5 in the manuscript.

% add path and create output directory
addpath('../');
if ~exist('output', 'dir')
    mkdir output;
end

% prisoner's dilemma with P < (S+T)/2 < R
game_parameters = [3, 0, 5, 1];

% fixed strategy for X
p = [0.997, 0.005, 0.018, 0.015];

% initial strategy for Y
q = [0.19, 0.10, 0.75, 0.92];

% number of gradient ascent steps
learning_steps = 6e5;

% learning rate
learning_rate = 1e-2;

% probabilities of implementation errors for the two players (first column
% for Y, second column for X)
error_probabilities = [0, 0;
    1e-3, 0];

% build panels a and b
panels = ['a', 'b'];
for panel=1:length(panels)
    
    [~, piY_final, piX_final] = optimize(q, p, game_parameters, error_probabilities(panel, :), learning_rate, learning_steps, 1);

    hFig = figure(1);
    hFig.Renderer = 'Painters';

    buff = 0.25;

    X_ind = [1, 2, 3, 4];
    Y_ind = [1, 3, 2, 4];
    
    xx = [game_parameters(X_ind), game_parameters(1)];
    yy = [game_parameters(Y_ind), game_parameters(1)];

    k = convhull(yy, xx);
    feas = patch(yy(k), xx(k), [0.8, 0.9, 1.0]);
    alpha(feas, 0.5); hold on;
    plot(yy(k), xx(k), 'LineWidth', 1, 'Color', [0, 0, 0.6]); hold on;
    m = min((xx(k)+yy(k))/2);
    M = max((xx(k)+yy(k))/2);
    plot(m:0.01:M, m:0.01:M, '--k'); hold on;

    colors = jet(length(piX_final));
    colormap(colors);

    scatter(piY_final, piX_final, 30, 1:length(piX_final), 'filled'); colorbar; hold on;

    scatter(piY_final(1), piX_final(1), 75, colors(1, :), 'filled'); hold on;
    scatter(piY_final(length(piX_final)), piX_final(length(piX_final)), 50, colors(length(piX_final), :), 'filled');
    
    axis([min(game_parameters)-buff, max(game_parameters)+buff, min(game_parameters)-buff, max(game_parameters)+buff]);

    xticks(min(game_parameters):1:max(game_parameters));
    yticks(min(game_parameters):1:max(game_parameters));

    axis square; box on; grid on;

    set(gca, 'FontSize', 16);

    set(hFig, 'Units', 'Inches');
    pos = get(hFig, 'Position');
    set(hFig, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', [pos(3), pos(4)]);
    print(hFig, strcat('output/Fig5', panels(panel)), '-dpdf', '-r0');
    close(hFig);
end
