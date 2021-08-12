function p_updated = step_forward(p, q, game_parameters, error_probabilities, learning_rate)
% STEP_FORWARD
%     STEP_FORWARD(p, q, game_parameters, error_probability, learning_rate)
%     takes as input the strategy of player X (p), the strategy of player Y
%     (q), the payoffs for the one-shot game (game_parameters), the
%     probabilities of making an implementation error (error_probabilities,
%     whose first and second entries correspond to p and q), and the
%     learning rate for gradient ascent (learning_rate). The output is the
%     strategy obtained from p by performing one step in the gradient
%     direction, scaled by the prescribed learning rate.

    % effective strategies for X and Y after taking into account errors
    p_effective = (1-error_probabilities(1))*p+error_probabilities(1)*(1-p);
    q_effective = (1-error_probabilities(2))*q+error_probabilities(2)*(1-q);

    % updated strategy for X after applying one gradient ascent step
    p_updated = p + learning_rate*(1-2*error_probabilities(1))*payoff_gradient(p_effective, q_effective, game_parameters);
    
    % ensure all coordinates are in the interval [0, 1]
    p_updated = min(max(p_updated, 0), 1);
end
