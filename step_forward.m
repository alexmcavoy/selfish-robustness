function p_updated = step_forward(p, q, game_parameters, error_probability, learning_rate)
% STEP_FORWARD
%     STEP_FORWARD(p, q, game_parameters, error_probability, learning_rate)
%     takes as input the strategy of player X (p), the strategy of player Y
%     (q), the payoffs for the one-shot game (game_parameters), the
%     probability of making an implementation error (error_probability),
%     and the learning rate for gradient ascent (learning_rate). The output
%     is the strategy obtained from p by performing one step in the
%     gradient direction, scaled by the prescribed learning rate.

    % effective strategies for X and Y after taking into account errors
    p_effective = (1-error_probability)*p+error_probability*(1-p);
    q_effective = (1-error_probability)*q+error_probability*(1-q);

    % updated strategy for X after applying one gradient ascent step
    p_updated = p + learning_rate*(1-2*error_probability)*payoff_gradient(p_effective, q_effective, game_parameters);
    
    % ensure all coordinates are in the interval [0, 1]
    p_updated = min(max(p_updated, 0), 1);
end
