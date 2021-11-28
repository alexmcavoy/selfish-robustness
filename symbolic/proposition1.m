
%%%%%%%%%%%%%%%
% basic setup %
%%%%%%%%%%%%%%%

% strategy parameters for player X
syms p1 p2 p3 p4;
assume(0<=p1 & p1<=1);
assume(0<=p2 & p2<=1);
assume(0<=p3 & p3<=1);
assume(0<=p4 & p4<=1);
p = [p1, p2, p3, p4];

% strategy parameters for player Y
syms q1 q2 q3 q4;
assume(0<=q1 & q1<=1);
assume(0<=q2 & q2<=1);
assume(0<=q3 & q3<=1);
assume(0<=q4 & q4<=1);
q = [q1, q2, q3, q4];

% payoffs in the underlying one-shot game
syms R S T P;
game_parameters = [R, S, T, P];

% Press-Dyson matrix and its determinant
PD_matrix = [-1+p1*q1, -1+p1, -1+q1, R; p3*q2, p3, -1+q2, S; p2*q3, -1+p2, q3, T; p4*q4, p4, q4, P];
D(R, S, T, P) = det(PD_matrix);

% payoff to player Y, based on the formalism of Press & Dyson (2012)
piY(q1, q2, q3, q4) = D(R, S, T, P)/D(1, 1, 1, 1);

vertex_strategies = [0, 0, 0, 0;
     0, 0, 0, 1;
     0, 0, 1, 0;
     0, 0, 1, 1;
     0, 1, 0, 0;
     0, 1, 0, 1;
     0, 1, 1, 0;
     0, 1, 1, 1;
     1, 0, 0, 0;
     1, 0, 0, 1;
     1, 0, 1, 0;
     1, 0, 1, 1;
     1, 1, 0, 0;
     1, 1, 0, 1;
     1, 1, 1, 0;
     1, 1, 1, 1];

%%%%%%%%%%%%%%%%%%%%%%%%%%
% analysis of |W| = 2, 3 %
%%%%%%%%%%%%%%%%%%%%%%%%%%
 
for set_size = 3:-1:2

    fprintf('\nanalysis of |W| = %d\n', set_size);
    fprintf('-------------------\n\n');

    % set of subsets of {CC,CD,DC,DD} of size set_size
    W_set = nchoosek(1:4, set_size);

    % set of probabilities for the deterministic components (not in W)
    vertex_probabilities_set = unique(vertex_strategies(:, set_size+1:end), 'rows');

    for w_index=1:size(W_set, 1)
        for bp_index=1:size(vertex_probabilities_set, 1)

            % set of components for which the partial derivative vanishes
            W = W_set(w_index, :);

            % probability of cooperating, one for each component not in W
            vertex_probabilities = vertex_probabilities_set(bp_index, :);

            fprintf('current set = ');
            fprintf(mat2str(W));
            fprintf('\n');
            if length(vertex_probabilities)==1
                fprintf('\ncurrent vertex probability = ');
            else
                fprintf('\ncurrent vertex probabilities = ');
            end
            fprintf(mat2str(vertex_probabilities));
            fprintf('\n\n');

            % build matrix
            eqns = [];
            for coordinate=W
                [n, ~] = numden(simplify(diff(piY, q(coordinate))));
                eqns = [eqns, n==0];
            end
            [MVW, ~] = equationsToMatrix(eqns, game_parameters);
            MVW = simplify(MVW);

            % all two-element subsets of rows
            row2 = nchoosek(1:size(MVW, 1), 2);
            % all two-element subsets of columns
            col2 = nchoosek(1:size(MVW, 2), 2);

            % by the same reasoning used in the proof of theorem 1, we can replace each
            % q-dependent factor by its average over all vertex strategies in order to determine
            % the strategies p at which this factor can vanish, which is done in the following block
            minor_determinants_mod = [];
            for i=1:size(row2, 1)
                for j=1:size(col2, 1)
                    factorization = factor(simplify(det(MVW(row2(i, :), col2(j, :)))));
                    factorization_mod = 1;
                    for k=1:length(factorization)
                        f(q1, q2, q3, q4) = factorization(k);
                        vertex_sum = 0;
                        for q_index=1:size(vertex_strategies, 1)
                            vertex_strategy = vertex_strategies(q_index, :);
                            if all(vertex_strategy(setdiff(1:4, W))==vertex_probabilities)
                                q_current = num2cell(vertex_strategy);
                                vertex_sum = vertex_sum + f(q_current{:});
                            end
                        end
                        factorization_mod = factorization_mod*simplify(vertex_sum/size(vertex_strategies, 1));
                    end
                    minor_determinants_mod = [minor_determinants_mod; factorization_mod];
                end
            end
            minor_determinants_mod = simplify(expand(minor_determinants_mod));

            fprintf('constraints for p:\n\n');
            disp(minor_determinants_mod);

        end
    end
    
end
