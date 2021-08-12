% Fig1
%     reproduces Figure 1 in the manuscript.

% add path and create output directory
addpath('../');
if ~exist('output', 'dir')
    mkdir output;
end

% donation game with b = 2 and c = 1
game_parameters = [2-1, -1, 2, 0];

% fixed strategies for player X
fixed_strategies = [0.94, 0.02, 0.11, 0.97;
    0.84, 0.02, 0.55, 0.06;
    1, 0.22, 0.53, 0.13;
    0.8, 0, 0.8, 0;
    1, 0.2, 1, 0.2];

% boundary strategies used to determine the feasible region of a strategy
hull_strategies = [0, 0, 0, 0;
        0, 0, 0, 1;
        0, 0, 1, 0;
        0, 0, 1, 1;
        0, 1, 0, 1;
        0, 1, 1, 0;
        0, 1, 1, 1;
        1, 0, 0, 1;
        1, 0, 1, 0;
        1, 0, 1, 1;
        1, 1, 1, 1];
    
% probabilities of implementation errors for the two players (X and Y)
error_probabilities = [0, 0];

% build panels a, b, c, d, and e
panels = ['a', 'b', 'c', 'd', 'e'];
for panel=1:length(panels)
    p = fixed_strategies(panel, :);
    
    piX_hull = zeros(1, size(hull_strategies, 1));
    piY_hull = zeros(1, size(hull_strategies, 1));
    for hull_strategy=1:size(hull_strategies, 1)
        [piX_hull(hull_strategy), piY_hull(hull_strategy)] = payoff(p, hull_strategies(hull_strategy, :), game_parameters, error_probabilities);
    end
    
    hFig = figure(1);
    hFig.Renderer = 'Painters';

    buff = 0.25;

    xx = game_parameters([1, 2, 3, 4, 1]);
    yy = game_parameters([1, 3, 2, 4, 1]);

    k = convhull(yy, xx);
    feas = patch(yy(k), xx(k), [0.8, 0.9, 1.0]);
    alpha(feas, 0.5); hold on;
    plot(yy(k), xx(k), 'LineWidth', 1, 'Color', [0, 0, 0.6]); hold on;
    m = min((xx(k)+yy(k))/2);
    M = max((xx(k)+yy(k))/2);
    plot(m:0.1:M, m:0.1:M, '--k'); hold on;

    try
        kk = convhull(piY_hull, piX_hull);
        feas = patch(piY_hull(kk), piX_hull(kk), [0.8, 0.8, 0.8]);
        alpha(feas, 0.5); hold on;
        plot(piY_hull(kk), piX_hull(kk), 'LineWidth', 1, 'Color', [0.2, 0.2, 0.2]); hold on;
    catch
        plot(piY_hull, piX_hull, 'Color', [0.2, 0.2, 0.2], 'LineWidth', 1); hold on;
    end

    maxIndex = find(piY_hull==max(piY_hull));
    scatter(piY_hull(maxIndex), piX_hull(maxIndex), 100, [0.6, 0, 0], 'filled');

    axis([min(game_parameters)-buff, max(game_parameters)+buff, min(game_parameters)-buff, max(game_parameters)+buff]);

    xticks(min(game_parameters):1:max(game_parameters));
    yticks(min(game_parameters):1:max(game_parameters));

    axis square; box on; grid on;

    set(gca, 'FontSize', 16);

    set(hFig, 'Units', 'Inches');
    pos = get(hFig, 'Position');
    set(hFig, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', [pos(3), pos(4)]);
    print(hFig, strcat('output/Fig1', panels(panel)), '-dpdf', '-r0');
    close(hFig);
end

% build panel f
max_samples = 1e6;

piX = zeros(1, max_samples);
piY = zeros(1, max_samples);
parfor sample=1:max_samples
    p = random('beta', 0.5, 0.5, 1, 4);
    piX_hull = zeros(1, size(hull_strategies, 1));
    piY_hull = zeros(1, size(hull_strategies, 1));
    for hull_strategy=1:size(hull_strategies, 1)
        [piX_hull(hull_strategy), piY_hull(hull_strategy)] = payoff(p, hull_strategies(hull_strategy, :), game_parameters, error_probabilities);
    end
    maxIndex = find(piY_hull==max(piY_hull));
    piX(sample) = piX_hull(maxIndex);
    piY(sample) = piY_hull(maxIndex);
end
print_heatmap([piX; piY], [], game_parameters, 1, 'output/Fig1f');
