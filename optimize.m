function [p_final, piX_final, piY_final] = optimize(p, q, game_parameters, ...
    error_probabilities, learning_rate, learning_steps, track_trajectory)
% OPTIMIZE
%     OPTIMIZE(p, q, game_parameters, error_probabilities, learning_rate,
%     learning_steps, track_trajectory) takes as input the strategy of
%     player X (p; to be optimized), the strategy of player Y (q; fixed),
%     the payoffs for the one-shot game (game_parameters), the
%     probabilities of making an implementation error (error_probabilities,
%     whose first and second entries correspond to p and q), the learning
%     rate for gradient ascent (learning_rate), the number of learning
%     steps to apply in total (learning_steps), and a boolean for whether
%     to track the trajectory (track_trajectory). If learning_steps is
%     negative, then gradient ascent is applied until successive payoff
%     differences fall beneath a threshold of 1e-15; otherwise, the
%     prescribed number of gradient ascent steps is applied. If
%     track_trajectory is 1, then the output is a sequence of 3-tuples,
%     giving the strategy of X, the payoff of X, the payoff of X, and the
%     payoff of Y at each step along the learning trajectory. Otherwise,
%     only the final such 3-tuple is returned and the learning trajectory
%     is discarded.

    [piX_final, piY_final] = payoff(p, q, game_parameters, error_probabilities);
    p_final = p;
    p_current = p;
    if learning_steps<0
        piX_current = piX_final;
        array_size = 1e4; % amount of new entries to add to arrays when resizing
        threshold = 1e-15; % fixed threshold for successive payoff differences
        current_difference = 1; % current difference between sucessive payoffs
        current_size = 1; % current size of output arrays
        
        % run gradient ascent until succesive payoffs are below a threshold
        step = 1;
        while abs(current_difference)>threshold
            p_updated = step_forward(p_current, q, game_parameters, error_probabilities, learning_rate);
            [piX, piY] = payoff(p_updated, q, game_parameters, error_probabilities);
            current_difference = piX-piX_current;
            if track_trajectory
                % set initial size of arrays (or resize if necessary)
                if step+1>current_size
                    p_final = [p_final; zeros(array_size, 4)];
                    piX_final = [piX_final; zeros(array_size, 1)];
                    piY_final = [piY_final; zeros(array_size, 1)];
                    current_size = current_size+array_size;
                end
                p_final(step+1, :) = p_updated;
                piX_final(step+1) = piX;
                piY_final(step+1) = piY;
            else
                p_final = p_updated;
                piX_final = piX;
                piY_final = piY;
            end
            p_current = p_updated;
            piX_current = piX;
            step = step+1;
        end
        if track_trajectory
            % truncate output arrays to match threshold criterion
            p_final = p_final(1:step, :);
            piX_final = piX_final(1:step);
            piY_final = piY_final(1:step);
        end
    else
        % run gradient ascent for prescribed number of steps
        for step=1:learning_steps-1
            p_updated = step_forward(p_current, q, game_parameters, error_probabilities, learning_rate);
            [piX, piY] = payoff(p_updated, q, game_parameters, error_probabilities);
            if track_trajectory
                % set initial size of arrays
                if step==1
                    p_final = [p_final; zeros(learning_steps-1, 4)];
                    piX_final = [piX_final; zeros(learning_steps-1, 1)];
                    piY_final = [piY_final; zeros(learning_steps-1, 1)];
                end
                p_final(step+1, :) = p_updated;
                piX_final(step+1) = piX;
                piY_final(step+1) = piY;
            else
                p_final = p_updated;
                piX_final = piX;
                piY_final = piY;
            end
            p_current = p_updated;
        end
    end
end
