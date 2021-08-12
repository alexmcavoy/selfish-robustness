function [piX, piY] = payoff(p, q, game_parameters, error_probabilities)
% PAYOFF
%     PAYOFF(p, q, game_parameters, error_probabilities) takes as input the
%     strategy of player X (p), the strategy of player Y (q), the payoffs
%     for the one-shot game (game_parameters), and the probabilities of
%     making an implementation error (error_probabilities, whose first and
%     second entries correspond to p and q). The output is a pair, [piX,
%     piY], where piX is the payoff to X and piY is the payoff to Y. An
%     error is thrown if these payoffs are undefined.

    % effective strategies for X and Y after taking into account errors
    p_effective = (1-error_probabilities(1))*p+error_probabilities(1)*(1-p);
    q_effective = (1-error_probabilities(2))*q+error_probabilities(2)*(1-q);

    % ordering of the states from the perspectives of X and Y, respectively
    X_ind = [1, 2, 3, 4];
    Y_ind = [1, 3, 2, 4];
    
    % build transition matrix for the Markov chain
    M = zeros(4, 4);
    for i=1:4
    	M(i, 1) = p_effective(X_ind(i))*q_effective(Y_ind(i));
	    M(i, 2) = p_effective(X_ind(i))*(1-q_effective(Y_ind(i)));
	    M(i, 3) = (1-p_effective(X_ind(i)))*q_effective(Y_ind(i));
	    M(i, 4) = (1-p_effective(X_ind(i)))*(1-q_effective(Y_ind(i)));
    end
    
    % auxiliary quantities for calculating payoffs
    [numX, numY, den] = deal(M-eye(4));
    numX(:, 4) = game_parameters(X_ind);
    numY(:, 4) = game_parameters(Y_ind);
    den(:, 4) = ones(1, 4);
    
    % throw error if M does not have a unique stationary distribution
    if rank(den)<4
        error('The stationary distribution is not unique.');
    end
    
    % payoff to player X
    piX = det(numX)/det(den);
    
    % payoff to player Y
    piY = det(numY)/det(den);
end
