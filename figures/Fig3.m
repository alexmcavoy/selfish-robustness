% Fig3
%     reproduces Figure 3 in the manuscript.

% add path and create output directory
addpath('../');
if ~exist('output', 'dir')
    mkdir output;
end

% number of initial strategies to sample
initial_conditions = 1e5;

% probability of implementation error
error_probability = 0;

% learning rate
learning_rate = 1e-2;

% game parameters for underlying one-shot games
one_shot_games = [2, -1, 7, 0;
    4, 0, 5, 3];

% fixed strategies for player X
fixed_strategies = [1, 0.12, 0.88, 0;
    1, 0.85, 0.15, 0];

payoff_increments = [2, 1];

% build panels a and b
panels = ['a', 'b'];
for panel=1:length(panels)
    game_parameters = one_shot_games(panel, :);
    % fixed strategy for X
    p = fixed_strategies(panel, :);
    %
    piX_final = zeros(1, initial_conditions);
    piY_final = zeros(1, initial_conditions);
    parfor sample=1:initial_conditions
        [~, piY_final(sample), piX_final(sample)] = optimize(random('beta', 0.5, 0.5, 1, 4), p, game_parameters, error_probability, learning_rate, -1, 0);
    end
    payoffs = [piX_final; piY_final];
    print_heatmap(payoffs, [], game_parameters, payoff_increments(panel), strcat('output/Fig3', panels(panel)));
end
