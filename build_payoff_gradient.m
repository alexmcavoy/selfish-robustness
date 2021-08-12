% BUILD_PAYOFF_GRADIENT
%     generates MATLAB function that calculates the payoff gradient with
%     respect to the strategy of a player against a fixed opponent.

% delete existing payoff_gradient function, if it exists
delete payoff_gradient.m;

% symbolic payoffs for the one-shot game
syms R S T P;
assume(R, 'real');
assume(S, 'real');
assume(T, 'real');
assume(P, 'real');
game_parameters = [R, S, T, P];

% ordering of the states from X's perspective
X_ind = [1, 2, 3, 4];

% ordering of the states from Y's perspective
Y_ind = [1, 3, 2, 4];

% symbolic strategy for player X
p = sym('p', [1, 4]);
assume(p, 'real');

% symbolic strategy for player Y
q = sym('q', [1, 4]);
assume(q, 'real');

% transition matrix for strategy pairs
M = sym(zeros(4, 4));
for i=1:4
    M(i, 1) = p(X_ind(i))*q(Y_ind(i));
    M(i, 2) = p(X_ind(i))*(1-q(Y_ind(i)));
    M(i, 3) = (1-p(X_ind(i)))*q(Y_ind(i));
    M(i, 4) = (1-p(X_ind(i)))*(1-q(Y_ind(i)));
end

% payoff to player X
[numX, numY, den] = deal(M-eye(4));
numX(:, 4) = game_parameters(X_ind);
numY(:, 4) = game_parameters(Y_ind);
den(:, 4) = ones(1, 4);
piX = det(numX)/det(den);

% gradient direction for X with respect to strategy p
payoff_gradient = [diff(piX, p(1)), diff(piX, p(2)), diff(piX, p(3)), diff(piX, p(4))];

% export payoff_gradient to MATLAB function
matlabFunction(payoff_gradient, 'File', 'payoff_gradient', 'Vars', {p, q, game_parameters});

clear; clc;
