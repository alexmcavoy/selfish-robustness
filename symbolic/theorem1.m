
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

%%%%%%%%%%%%%%%%%%
% analysis of MV %
%%%%%%%%%%%%%%%%%%

fprintf('\nanalysis of matrix MV\n');
fprintf('---------------------\n');

fprintf('building matrix... ');
eqns = [];
for coordinate=1:4
    [n, ~] = numden(simplify(diff(piY, q(coordinate))));
    eqns = [eqns, n==0];
end
[MV, ~] = equationsToMatrix(eqns, game_parameters);
MV = simplify(MV);
fprintf('done.\n');

% all two-element subsets of rows
row2 = nchoosek(1:size(MV, 1), 2);
% all two-element subsets of columns
col2 = nchoosek(1:size(MV, 2), 2);
% all three-element subsets of rows
row3 = nchoosek(1:size(MV, 1), 3);
% all three-element subsets of columns
col3 = nchoosek(1:size(MV, 2), 3);

% check that all 3x3 minor determinants of MV vanish
fprintf('checking vanishing of all 3x3 minor determinants... ');
for i=1:size(row3, 1)
    for j=1:size(col3, 1)
        assert(simplify(det(MV(row3(i, :), col3(j, :))))==0);
    end
end
fprintf('done.\n');

% check that in the factorization of each 2x2 minor determinant, every
% factor is linear in p1, p2, p3, p4, q1, q2, q3, q4
fprintf('checking linearity of factors in all 2x2 minor determinants... ');
for i=1:size(row2, 1)
    for j=1:size(col2, 1)
        factorization = factor(simplify(det(MV(row2(i, :), col2(j, :)))));
        for k=1:length(factorization)
            for coordinate=1:4
                assert(diff(factorization(k), p(coordinate), 2)==0);
                assert(diff(factorization(k), q(coordinate), 2)==0);
            end
        end
    end
end
fprintf('done.\n');

% check that in the factorization of each 2x2 minor determinant, every
% factor that depends non-trivially on q1, q2, q3, q4 is either always
% non-negative or non-positive, for all p1, p2, p3, p4, q1, q2, q3, q4
fprintf('checking signs of q-dependent factors of all 2x2 minor determinants... ');
for i=1:size(row2, 1)
    for j=1:size(col2, 1)
        factorization = factor(simplify(det(MV(row2(i, :), col2(j, :)))));
        f(q1, q2, q3, q4) = factorization;
        % restrict attention to factors that are not independent of q1, q2, q3, q4
        q_indices = find(simplify(f-f(0, 0, 0, 0))~=0);
        for k=q_indices
            current_factor(p1, p2, p3, p4, q1, q2, q3, q4) = factorization(k);
            vertex_values = [];
            for p_index=1:size(vertex_strategies, 1)
                for q_index=1:size(vertex_strategies, 1)
                    p_current = num2cell(vertex_strategies(p_index, :));
                    q_current = num2cell(vertex_strategies(q_index, :));
                    vertex_values = [vertex_values, current_factor(p_current{:}, q_current{:})];
                end
            end
            assert(all(vertex_values<=0) || all(vertex_values>=0));
        end
    end
end
fprintf('done.\n');

% by the previous two steps, we know that each q-dependent factor must be non-zero
% for q in (0, 1)^4 unless this factor vanishes at all of the vertex strategies.
% at the same time, we know that the values of this factor at the vertex strategies
% are either all non-positive or all non-negative. therefore, we can replace each
% q-dependent factor by its average over all vertex strategies in order to determine
% the strategies p at which this factor can vanish, which is done in the following block
fprintf('build array of modified minor determinants with same vanishing locus... ');
minor_determinants_mod = [];
for i=1:size(row2, 1)
    for j=1:size(col2, 1)
        factorization = factor(simplify(det(MV(row2(i, :), col2(j, :)))));
        factorization_mod = 1;
        for k=1:length(factorization)
            f(q1, q2, q3, q4) = factorization(k);
            vertex_sum = 0;
            for q_index=1:size(vertex_strategies, 1)
                q_current = num2cell(vertex_strategies(q_index, :));
                vertex_sum = vertex_sum + f(q_current{:});
            end
            factorization_mod = factorization_mod*simplify(vertex_sum/size(vertex_strategies, 1));
        end
        minor_determinants_mod = [minor_determinants_mod; factorization_mod];
    end
end
minor_determinants_mod = simplify(expand(minor_determinants_mod));
fprintf('done.\n');

% a common factor is (2-p1-p2+p3+p4)/32, which vanishes only at when (p1, p2,
% p3, p4) = (1, 1, 0, 0), which is excluded, so we can remove this factor.
minor_determinants_mod = simplify(minor_determinants_mod*(32/(2-p1-p2+p3+p4)));

% we therefore end up at the following strategies p causing 
% all elements of minor_determinants_mod to vanish:
%
%             minor_determinants_mod == 0
%                         . .            
%                        .   .
%                       .     .
%                      .       .
%                     .         .
%                 p3 = p4   p1 = p2 = 1
%                   . .                                       
%                  .   .                                      
%                 .     .                                     
%                .       .                                   
%               .         .                                     
%           p3 = 0      p1 = p2       
%                         . .
%                        .   .
%                       .     .
%                      .       .
%                     .         .
%                 p1 = 1      p1 = p3
%
% these strategies are exactly those that result in dim V(p, q) = 3

%%%%%%%%%%%%%%%%%%%
% analysis of MBe %
%%%%%%%%%%%%%%%%%%%

fprintf(strcat('\n', 'analysis of matrix MBe\n'));
fprintf('----------------------\n');

fprintf('building matrix... ');
syms e;
assume(0<e & e<1);
vertex_strategies_e = vertex_strategies*(1-e)+(1-vertex_strategies)*e;
q1 = num2cell(vertex_strategies_e(1, :));
eqns = [];
for q_index=2:size(vertex_strategies_e, 1)
    q = num2cell(vertex_strategies_e(q_index,  :));
    [n, ~] = numden(simplify(piY(q{:})-piY(q1{:})));
    eqns = [eqns, n==0];
end
[MBe, ~] = equationsToMatrix(eqns, game_parameters);
MBe = unique(simplify(MBe), 'rows');
fprintf('done.\n');

% all two-element subsets of rows
row2 = nchoosek(1:size(MBe, 1), 2);
% all two-element subsets of columns
col2 = nchoosek(1:size(MBe, 2), 2);
% all three-element subsets of rows
row3 = nchoosek(1:size(MBe, 1), 3);
% all three-element subsets of columns
col3 = nchoosek(1:size(MBe, 2), 3);

% check that all 3x3 minor determinants of MBe vanish
fprintf('checking vanishing of all 3x3 minor determinants... ');
for i=1:size(row3, 1)
    for j=1:size(col3, 1)
        assert(simplify(det(MBe(row3(i, :), col3(j, :))))==0);
    end
end
fprintf('done.\n');

% we know that there exists e=e(p) with 0<e<1/2 such that Be(p) is contained in V(p, q).
% the latter space generically has dimension 2, deviating to dimension 3 only when p
% is repeated cooperation, repeated defection, or an unconditional strategy. so to complete
% the proof of Theorem 1 we need only show that if p is one of these three kinds of strategies,
% then Be(p) has dimension 3. in fact, this holds regardless of the value of 0<e<1/2
fprintf('checking vanishing of all 2x2 minor determinants at p = (1, 1, p3, p4), (p1, p2, 0, 0), and (p1, p1, p1, p1)... ');
for i=1:size(row2, 1)
    for j=1:size(col2, 1)
        current_determinant(p1, p2, p3, p4) = simplify(det(MBe(row2(i, :), col2(j, :))));
        assert(current_determinant(1, 1, p3, p4)==0);
        assert(current_determinant(p1, p2, 0, 0)==0);
        assert(current_determinant(p1, p1, p1, p1)==0);
    end
end
fprintf('done.\n\n');
