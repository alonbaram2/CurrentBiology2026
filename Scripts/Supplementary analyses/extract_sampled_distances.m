clear; clc;

baseDir = fullfile('..','..','Data','behdata');  % ../../Data/behdata

nSubj = 25;
nSess = 2;

allRel  = [];
allIrrel = [];

for subj = 1:nSubj
    for sess = 1:nSess
        
        filename = fullfile(baseDir, sprintf('data_%d_%d.mat', subj, sess));
        
        if ~isfile(filename)
            fprintf('File not found: %s\n', filename);
            continue
        end
        
        load(filename);  % loads variable "data"
        
        % Extract distance matrices
        distRel   = data.scan{1}.objDiff.distRel;
        distIrrel = data.scan{1}.objDiff.distIrrel;
                
        % Identify valid choice trials:
        % Remove rows where entries are zero
        validIdx = ~(distRel(:,1)==0 & distRel(:,2)==0 & ...
                     distIrrel(:,1)==0 & distIrrel(:,2)==0);
        
        distRel_valid   = distRel(validIdx,:);
        distIrrel_valid = distIrrel(validIdx,:);
        
        % Append all distances (both columns)
        allRel   = [allRel;   distRel_valid(:)];
        allIrrel = [allIrrel; distIrrel_valid(:)];
        
        clear data
    end
end


%% Subject-level comparison 

rel_by_subj   = zeros(nSubj,1);
irrel_by_subj = zeros(nSubj,1);

for subj = 1:nSubj
    subjRel = [];
    subjIrrel = [];
    
    for sess = 1:nSess
        filename = fullfile(baseDir, sprintf('data_%d_%d.mat', subj, sess));
        if ~isfile(filename); continue; end
        S = load(filename);
        data = S.data;
        
        distRel   = data.scan{1}.objDiff.distRel;
        distIrrel = data.scan{1}.objDiff.distIrrel;
        
        validIdx = ~((distRel(:,1)==0 & distRel(:,2)==0) & ...
                     (distIrrel(:,1)==0 & distIrrel(:,2)==0));
        
        distRel_valid   = distRel(validIdx,:);
        distIrrel_valid = distIrrel(validIdx,:);
        
        subjRel   = [subjRel;   distRel_valid(:)];
        subjIrrel = [subjIrrel; distIrrel_valid(:)];
    end
    
    subjRel   = subjRel(subjRel ~= 0);
    subjIrrel = subjIrrel(subjIrrel ~= 0);
    
    rel_by_subj(subj)   = mean(subjRel);
    irrel_by_subj(subj) = mean(subjIrrel);
end

[~,p_subj,~,stats_subj] = ttest(rel_by_subj, irrel_by_subj);

fprintf('\nSUBJECT-LEVEL COMPARISON\n');
fprintf('Mean Rel = %.3f | Mean Irrel = %.3f\n', ...
    mean(rel_by_subj,'omitnan'), ...
    mean(irrel_by_subj,'omitnan'));
fprintf('Std Rel = %.3f | Std Irrel = %.3f\n', ...
    std(rel_by_subj,'omitnan'), ...
    std(irrel_by_subj,'omitnan'));
fprintf('t(%d) = %.3f, p = %.4f\n', stats_subj.df, stats_subj.tstat, p_subj);

validSubs = ~isnan(rel_by_subj) & ~isnan(irrel_by_subj);
nValid = sum(validSubs);

x = rel_by_subj(validSubs);
y = irrel_by_subj(validSubs);

% ---------------
fs = 12;   % <-- global font size

rel_color   = [109 199 183] / 255;   % #6DC7B7
irrel_color = [27 119 96]  / 255;    % #1B7760

figure('Color','w');
subplot(1,2,1)
edges = 0.5:1:6.5;

histogram(allRel, edges, 'Normalization','probability', ...
    'FaceColor', rel_color, ...
    'FaceAlpha',0.6, ...
    'EdgeColor',rel_color);

hold on;
histogram(allIrrel, edges, 'Normalization','probability', ...
    'FaceColor', irrel_color, ...
    'FaceAlpha',0.6, ...
    'EdgeColor',irrel_color);

xlabel('Shortest path length');
ylabel('Proportion of trials');
leg = legend({'Relevant','Irrelevant'}, ...
    'Location','northeast', ...
    'Box','off');
set(leg,'FontSize',fs);

% ---- Axis styling ----
set(gca, ...
    'TickDir','out', ...        % ticks outside
    'Box','on', ...             % full border
    'LineWidth',1.2, ...
        'FontSize',fs);
box off
xlim([0.5 6.5]);
xticks(1:6);

title('Distribution of sampled shortest-path distances','FontSize',fs);
legend boxoff

subplot(1,2,2)

x = [rel_by_subj(validSubs), irrel_by_subj(validSubs)];

boxplot(x, ...
    'Labels', {'Relevant','Irrelevant'}, ...
    'Symbol','k');   % outliers as black +

set(gca, ...
    'TickDir','out', ...
    'Box','off', ...
    'LineWidth',1.2, ...
    'FontSize',fs);

ylabel('Mean sampled distance','FontSize',fs);
title('Subject-level means','FontSize',fs);


% ---- Color the boxes ----
h = findobj(gca,'Tag','Box');

patch(get(h(2),'XData'), get(h(2),'YData'), rel_color, ...
      'FaceAlpha',0.6, 'EdgeColor',rel_color, 'LineWidth',1);

patch(get(h(1),'XData'), get(h(1),'YData'), irrel_color, ...
      'FaceAlpha',0.6, 'EdgeColor',irrel_color, 'LineWidth',1);
hold on

% ---- Connect paired observations ----
for i = find(validSubs)'
    plot([1 2], ...
         [rel_by_subj(i), irrel_by_subj(i)], ...
         'k', 'LineWidth',1);
end

% ---- Overlay individual subject points ----
hold on
scatter(ones(sum(validSubs),1), rel_by_subj(validSubs), 40, ...
        'MarkerFaceColor', rel_color, ...
        'MarkerEdgeColor',rel_color);

scatter(2*ones(sum(validSubs),1), irrel_by_subj(validSubs), 40, ...
        'MarkerFaceColor', irrel_color, ...
        'MarkerEdgeColor',irrel_color);

ylim([2 4]);
