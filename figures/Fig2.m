% Fig2
%     reproduces Figure 2 in the manuscript.

% add path and create output directory
addpath('../');
if ~exist('output', 'dir')
    mkdir output;
end

% prisoner's dilemma with (S+T)/2 > R
game_parameters = [2, -1, 7, 0];

% learning rate
learning_rate = 1e-2;

% number of gradient ascent steps
learning_steps = 1e4;

% fixed strategy for X
p = [1, 0.12, 0.88, 0];

% probabilities of implementation errors for the two players (Y and X)
error_probabilities = [0, 0];

% initial strategies for player Y
initial_strategies = [0.92, 0.77, 0.40, 0.19;
    0.46, 0.93, 0.75, 0.03;
    0.25, 0.78, 0.44, 0.26];

% build panels a, b, and c
panels = ['a', 'b', 'c'];
for panel=1:length(panels)
    % initial strategy for Y
    q = initial_strategies(panel, :);

    [q_trajectory, ~, ~] = optimize(q, p, game_parameters, error_probabilities, learning_rate, learning_steps, 1);

    hFig = figure(1);
    hFig.Renderer = 'Painters';

    for coordinate=1:4
        semilogx(q_trajectory(:, coordinate), 'LineWidth', 2); hold on;
    end

    axis([1, learning_steps, 0, 1]);

    axis square; box on; grid on;

    yticks(0:0.2:1);

    set(gca, 'FontSize', 16);

    set(hFig, 'Units', 'Inches');
    pos = get(hFig, 'Position');
    set(hFig, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', [pos(3), pos(4)]);
    print(hFig, strcat('output/Fig2', panels(panel)), '-dpdf', '-r0');
    close(hFig);
end
