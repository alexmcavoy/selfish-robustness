% Fig4
%     reproduces Figure 4 in the manuscript.

% add path and create output directory
addpath('../');
if ~exist('output', 'dir')
    mkdir output;
end

% prisoner's dilemma with P < (S+T)/2 < R
game_parameters = [3, 0, 5, 1];

% number of initial strategies to sample
initial_conditions = 1e5;

% probability of implementation error
error_probability = 0;

% learning rate
learning_rate = 1e-2;

% fixed strategies for player X
fixed_strategies = [0.997, 0.005, 0.018, 0.015;
    0.860, 0, 0.225, 0.252];

% build panels a and b
panels = ['a', 'b'];
for panel=1:length(panels)
    % fixed strategy for X
    p = fixed_strategies(panel, :);

    piX_final = zeros(1, initial_conditions);
    piY_final = zeros(1, initial_conditions);
    parfor sample=1:initial_conditions
        [~, piY_final(sample), piX_final(sample)] = optimize(random('beta', 0.5, 0.5, 1, 4), p, game_parameters, error_probability, learning_rate, -1, 0);
    end

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

    payoffs = [piX_final; piY_final];

    hull_payoffs = zeros(2, 11);
    for point=1:11
        [hull_payoffs(1, point), hull_payoffs(2, point)] = payoff(p, hull_strategies(point, :), game_parameters, error_probability);
    end

    print_heatmap(payoffs, hull_payoffs, game_parameters, 1, strcat('output/Fig4', panels(panel)));
end
