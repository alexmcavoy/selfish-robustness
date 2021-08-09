function print_heatmap(payoffs, hull_payoffs, game_parameters, payoff_increment, filename)
% PRINT_HEATMAP
%     PRINT_HEATMAP(payoffs, hull_payoffs, game_parameters, 
%     payoff_increment, filename) takes in a matrix with two rows
%     (payoffs), whose columns represent payoffs to X in the first row
%     and payoffs to Y in the second row, a collection of boundary points
%     whose convex hull represents the feasible region for a fixed
%     strategy (hull_payoffs), the payoffs for the one-shot game
%     (game_parameters), the amount by which to space out payoffs in the
%     labels of the axes (payoff_increment), and a file name for the output
%     file. The result is a heatmap, saved as a PDF, showing the
%     distribution of payoffs, with X's payoff on the vertical axis and Y's
%     payoff on the horizontal axis.

    hFig = figure(1);
    hFig.Renderer = 'Painters';

    game_min = min(game_parameters);
    game_max = max(game_parameters);
    
    margin = 0.25*((game_max-game_min)/3);

    mesh_size = (game_max-game_min)/1000;
    M = hist3([transpose(payoffs(2, :)), transpose(payoffs(1, :))], 'Ctrs', ...
        {game_min-margin:mesh_size:game_max+margin game_min-margin:mesh_size:game_max+margin});
    M = imgaussfilt(M, 10);

    image([game_min-margin, game_max+margin], [game_min-margin, game_max+margin], ...
        transpose(M), 'CDataMapping', 'scaled');
    hold on;

    load('colormap.mat', 'cmap'); colormap(cmap);

    set(gca,'YDir','normal');
    axis square; grid on;
    ax = gca;
    ax.GridColor = [1, 1, 1];
    
    X_ind = [1, 2, 3, 4];
    Y_ind = [1, 3, 2, 4];
    
    xx = [game_parameters(X_ind), game_parameters(1)];
    yy = [game_parameters(Y_ind), game_parameters(1)];

    k = convhull(xx, yy);
    
    self_min = min((game_parameters(X_ind)+game_parameters(Y_ind))/2);
    self_max = max((game_parameters(X_ind)+game_parameters(Y_ind))/2);

    xticks(game_min:payoff_increment:game_max);
    yticks(game_min:payoff_increment:game_max);

    plot(yy(k), xx(k), 'LineWidth', 0.5, 'Color', [0.7, 0.7, 0.7]); hold on;
    plot(self_min:0.1:self_max, self_min:0.1:self_max, '--', ...
        'LineWidth', 0.5, 'Color', [0.7, 0.7, 0.7]); hold on;
    
    if ~isempty(hull_payoffs)
        try
            kk = convhull(hull_payoffs(2, :), hull_payoffs(1, :));
            pat = patch(hull_payoffs(2, kk), hull_payoffs(1, kk), [0.7, 0.7, 0.7]); hold on;
            pat.FaceAlpha = 0.25;
            bdryline = plot(hull_payoffs(2, kk), hull_payoffs(1, kk), 'LineWidth', 0.5, 'Color', [0, 0, 0.6]);
            bdryline.Color(4) = 0.5;
        catch
            error('Error drawing convex hull of specified boundary points.');
        end
    end

    set(gca, 'FontSize', 16);

    set(hFig, 'Units', 'Inches');
    pos = get(hFig, 'Position');
    set(hFig, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', ...
        'PaperSize', [pos(3), pos(4)]);
    print(hFig, filename, '-dpdf', '-r0');
    close(hFig);
end
