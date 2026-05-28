%% Code to generate all subpanels in Fig 2.
clear
close all
addpath('matlab_scripts')


% Extract relevant data for subsequent analyses
subject_numbers = []; sessions = []; runs = []; trial_numbers = [];
stim1s = []; stim2s = []; dist_rel1s = []; dist_rel2s = []; dist_irrel1s = []; dist_irrel2s = [];
choices = []; crs = []; RTs = []; dist_rel_chs = []; dist_rel_unchs = []; dist_irrel_chs = []; dist_irrel_unchs = [];     

for subj = 1:25        
    for session = 1:2        
        try
            load(['../Data/alldata/data_',num2str(subj),'_',num2str(session),'.mat']);
            data.day
            for run = 1:4

                % index choice trials
                ix_ch = data.scan{run}.objDiff.distRel(:,1)~=0;
                
                % Extract relevant information for each trial
                trial = find(ix_ch);
                stim1 = data.scan{run}.objDiff.stim(trial,1);
                stim2 = data.scan{run}.objDiff.stim(trial,2);
                dist_rel1 = data.scan{run}.objDiff.distRel(trial,1);
                dist_rel2 = data.scan{run}.objDiff.distRel(trial,2);
                dist_irrel1 = data.scan{run}.objDiff.distIrrel(trial,1);
                dist_irrel2 = data.scan{run}.objDiff.distIrrel(trial,2);

                choice = data.scan{run}.objDiff.choice(trial);
                cr = data.scan{run}.objDiff.cr(trial);
                RT = log(data.scan{run}.objDiff.RT(trial));
                dist_rel_ch = data.scan{run}.objDiff.distRelCh(trial);
                dist_rel_unch = data.scan{run}.objDiff.distRelUnch(trial);
                dist_irrel_ch = data.scan{run}.objDiff.distIrrelCh(trial);
                dist_irrel_unch = data.scan{run}.objDiff.distIrrelUnch(trial);
                    
                % Append extracted data to arrays
                subject_numbers = [subject_numbers; repmat(subj,sum(ix_ch),1)];
                sessions = [sessions; repmat(session,sum(ix_ch),1)];
                runs =  [runs; repmat(run,sum(ix_ch),1)];
                trial_numbers = [trial_numbers; trial];
                
                % Left and right options
                stim1s = [stim1s; stim1];
                stim2s = [stim2s; stim2];
                dist_rel1s = [dist_rel1s; dist_rel1];
                dist_rel2s = [dist_rel2s; dist_rel2];
                dist_irrel1s = [dist_irrel1s; dist_irrel1];
                dist_irrel2s = [dist_irrel2s; dist_irrel2];

                % Choice, correct performance
                choices = [choices; choice'];
                crs = [crs; cr'];
                RTs = [RTs; RT'];
                    
                % Chosen and unchosen distances
                dist_rel_chs = [dist_rel_chs; dist_rel_ch'];
                dist_rel_unchs = [dist_rel_unchs; dist_rel_unch'];
                dist_irrel_chs = [dist_irrel_chs; dist_irrel_ch'];
                dist_irrel_unchs = [dist_irrel_unchs; dist_irrel_unch'];
                
            end
        end
    end
end
   
% Table to be used in mixed-effects model
% Step 1: Compute the predictor variables
dist_rel_diff = dist_rel1s - dist_rel2s;
dist_irrel_diff = dist_irrel1s - dist_irrel2s;
dist_rel_sum = dist_rel1s + dist_rel2s;
dist_irrel_sum = dist_irrel1s + dist_irrel2s;

% Create a table with the extracted data
result_table = table(subject_numbers, sessions, runs, trial_numbers, ...
    stim1s, stim2s, dist_rel1s, dist_rel2s, dist_irrel1s, dist_irrel2s,...
    choices, crs, RTs, dist_rel_chs, dist_rel_unchs, dist_irrel_chs, dist_irrel_unchs, ...
    dist_rel_diff, dist_irrel_diff, dist_rel_sum, dist_irrel_sum,...
    'VariableNames', {'Subject', 'Session', 'Run', 'Trial', ...
    'stim_left', 'stim_right','dist_rel_left','dist_rel_right','dist_irrel_left','dist_irrel_right',...
    'Choice', 'correct','RT', 'DistRelCh', 'DistRelUnCh', 'DistIrrelCh', 'DistIrrelUnCh',...
    'DistRelDiff','DistIrrelDiff','DistRelSum','DistIrrelSum'});

% Recode         
result_table.Choice(result_table.Choice == -1) = 0;     % left versus right
result_table.correct(result_table.correct == -1) = 0;   % correct versus incorrect

% Keep only rows where Choice is 0 or 1
result_table = result_table(result_table.Choice == 0 | result_table.Choice == 1, :);
         
% Save the table to a CSV file if needed
writetable(result_table, '../Data/alldata/objDiff_table.csv');

%% Fig 2A-C

arena = nan(25,2);                  % correlation between true distances and arena distances
overall_arena = nan(2,25,136);      % distance matrix
for subj = 1:25
    for map = 1:2
        if exist(['../Data/arena/similarityJudgementData_Subj_',num2str(subj),'_map_',num2str(map),'_trial1.mat'],'file')
            a = load((['../Data/arena/similarityJudgementData_Subj_',num2str(subj),'_map_',num2str(map),'_trial1.mat']));
            load(['../Data/alldata/data_',num2str(subj),'_2.mat']);
            

            for i = 1:17
                order(i) = find(data.stimuli(2,:) == data.stimuli(1,i));
            end
            
            if map == 1
                overall_arena(map,subj,:)   = a.distMat_ltv;
                arena(subj,map) = corr(squareform(data.map{map})',a.distMat_ltv');
            
           else
               sqfm = squareform(a.distMat_ltv);
               sqfm(order,order) = sqfm;

               overall_arena(map,subj,:) = squareform(sqfm);
               arena(subj,map) = corr(squareform(data.map{1})',squareform(sqfm)');
            
           end
        end
    end
end

figure;
subplot(2,3,1)
Y = mdscale(data.map{1}, 2); % Perform multidimensional scaling
eudist = pdist(Y, 'euclidean'); % Compute Euclidean distance
imagesc(squareform(eudist)) % Display distance matrix
axis equal off

subplot(2,3,4)
Y = mdscale(squareform(eudist), 2); % Redo MDS on distance matrix
hold on
scatter(Y(:,1), Y(:,2), 'k', 'filled') % Plot the points
axis equal off

% Find and plot lines between points where data.map{1}(i,j) == 1
[nRows, nCols] = size(data.map{1});
for i = 1:nRows
    for j = i+1:nCols % Check only upper triangular part to avoid duplicate lines
        if data.map{1}(i, j) == 1
            % Draw a line between Y(i,:) and Y(j,:)
            plot([Y(i, 1), Y(j, 1)], [Y(i, 2), Y(j, 2)], 'k-')
        end
    end
end


for map = 1:2
    subplot(2,3,map+1)
    imagesc(squareform(squeeze(nanmean(overall_arena(map,:,:),2))))
    axis equal off

    subplot(2,3,3+map+1)
    Y = mdscale(squareform(squeeze(nanmean(overall_arena(map,:,:),2))),2);
    Y = -Y;             % Rotate by 180 degrees
    Y(:, 1) = -Y(:, 1); % Flip horizontally 

    hold on
    scatter(Y(:,1),Y(:,2),'k','filled')
    axis equal off
    
    % Find and plot lines between points where data.map{1}(i,j) == 1
    for i = 1:nRows
        for j = i+1:nCols % Check only upper triangular part to avoid duplicate lines
            if data.map{1}(i, j) == 1
                % Draw a line between Y(i,:) and Y(j,:)
                plot([Y(i, 1), Y(j, 1)], [Y(i, 2), Y(j, 2)], 'k-')
            end
        end
    end
end
colormap(lbmap(25,'RedBlue'))
prepImg

%% Fig 2D

% Test for significance after standardising
for graph = 1:2
    
    x = atanh(arena(:,graph));
    x = x(~isnan(x));
    [h_norm,p_norm] = swtest(x); % Test for normality
    
    med  = median(x);
    q    = quantile(x, [0.25 0.75]);

    [h, p, ci, stats] = ttest(x);
    
    n   = numel(x);
    dz  = stats.tstat / sqrt(n);                             % Cohen's dz (one-sample)
    r_es = stats.tstat / sqrt(stats.tstat^2 + stats.df);     % effect-size r

    fprintf('\n--- T-test results for %u ---\n', graph);
    fprintf('Median:         %.4f\n', med);
    fprintf('IQR:            [%.4f, %.4f]\n', q(1), q(2));
    fprintf('normality:      %.6f\n', p_norm);
    fprintf('p-value:        %.6f\n', p);
    fprintf('H (0=no,1=yes): %d\n', h);
    fprintf('95%% CI:        [%.4f, %.4f]\n', ci(1), ci(2));
    fprintf('t statistic:    %.4f\n', stats.tstat);
    fprintf('df:             %d\n', stats.df);
    fprintf('SD estimate:    %.4f\n', stats.sd);
    fprintf('Cohen''s dz:    %.3f\n', dz);
    fprintf('effect-size r:  %.3f\n', r_es);
end


[r,p,RLO,RUP] = corrcoef(atanh(arena(:,1)), atanh(arena(:,2)),'rows','complete')
[h,p,ci,stats] = ttest(atanh(arena(:,1)), atanh(arena(:,2)))

% Effect size for paired t-test (Graph 1 vs Graph 2, Fisher z)
valid_idx = ~isnan(atanh(arena(:,1))) & ~isnan(atanh(arena(:,2)));
n_pair = sum(valid_idx);
dz_pair = stats.tstat / sqrt(n_pair);                       % Cohen's dz (paired)

fprintf('\n--- Between-graph comparison (Fisher z) ---\n');
fprintf('t(%d) = %.3f, p = %.6f\n', stats.df, stats.tstat, p);
fprintf('95%% CI:        [%.4f, %.4f]\n', ci(1), ci(2));
fprintf('Cohen''s dz:    %.3f\n', dz_pair);
fprintf('effect-size r:  %.3f\n', r(1,2));

% Boxcar plot (boxplot)
figure;
hold on;

% Plotting the box plots for both conditions
boxplot(arena, 'Colors', 'k', 'Labels', {'Graph 1', 'Graph 2'});

% Add individual data points
scatter(ones(size(arena(:, 1)))- 0.2 + 0.4*rand(size(arena(:, 1),1), 1), arena(:, 1), 35,  'filled','MarkerEdgeColor', 'k');
scatter(2 * ones(size(arena(:, 2)))- 0.2 + 0.4*rand(size(arena(:, 2),1), 1), arena(:, 2), 35,  'filled','MarkerEdgeColor', 'k');

% Formatting
ylabel('Correlation between arena distances and true distances');
set(gca, 'XTickLabel', {'Graph 1', 'Graph 2'});
box off;
set(gcf,'color','w');
ylim([-0.2 1]);

%% Fig. 2E
% Calculate the average of result_table.correct for each participant and session
avg_correct = grpstats(result_table, {'Subject', 'Session'}, 'mean', 'DataVars', 'correct');

% Rename the variable for clarity
avg_correct.Properties.VariableNames{'mean_correct'} = 'avg_correct';

% Step 1: Extract unique subjects
unique_subjects = unique(avg_correct.Subject);

% Step 2: Initialize a matrix to hold avg_correct values
cr_blocks = zeros(25, 2);  % Two columns for two sessions

% Step 3: Fill the matrix
for subject_id = 1:25
    % Get the avg_correct values for this subject
    try
        cr_blocks(subject_id, 1) = avg_correct.avg_correct(avg_correct.Subject == subject_id & avg_correct.Session == 1);
    catch
        cr_blocks(subject_id, 1) = nan;
    end
    try
        cr_blocks(subject_id, 2) = avg_correct.avg_correct(avg_correct.Subject == subject_id & avg_correct.Session == 2);
    catch
        cr_blocks(subject_id, 2) = nan;
    end
end

% Plotting the box plots for both conditions
figure
boxplot(cr_blocks(~isnan(cr_blocks(:,1)),1),  'Colors', 'k','positions',1); hold on
boxplot(cr_blocks(~isnan(cr_blocks(:,2)),2),  'Colors', 'k','positions',2); hold on

% Get the indices of subjects with data for both sessions
valid_indices = ~isnan(cr_blocks(:,1)) & ~isnan(cr_blocks(:,2));


% Connect the points for subjects with data in both sessions
for i = 1:length(cr_blocks)
    if valid_indices(i)  % Check if there is data for both sessions
        plot([1.2 1.8], cr_blocks(i, :), 'k-', 'LineWidth', 1);  % Connect points
    end
end

% Add individual data points
scatter(ones(sum(~isnan(cr_blocks(:,1))),1)+ 0.2, cr_blocks(~isnan(cr_blocks(:,1)),1), 70, [248/256, 206/256, 161/256], 'filled', 'MarkerEdgeColor', 'none');
scatter(2*ones(sum(~isnan(cr_blocks(:,2))),1)- 0.2, cr_blocks(~isnan(cr_blocks(:,2)),2), 70,  [248/256, 206/256, 161/256], 'filled', 'MarkerEdgeColor', 'none');

set(gca, 'XTick',[1,2], 'XTickLabel', {'session 1', 'session 2'},'YLim',[0.5, 1],'YTick',0.5:0.1: 1);
ylabel('Percent correct choices');
prepImg;

for session = 1:2
    
    x = cr_blocks(:,session);
    x = x(~isnan(x));               % remove NaNs
    
    med  = median(x);
    q    = quantile(x,[0.25 0.75]);   % q(1)=Q1, q(2)=Q3
    m    = mean(x);
    sd   = std(x);

    fprintf('\n--- Results for Session %u ---\n', session);
    fprintf('Median:         %.4f\n', med);
    fprintf('IQR:            [%.4f, %.4f]\n', q(1), q(2));
    fprintf('mean:           %.4f\n', m);
    fprintf('SD:             %.4f\n', sd);

    [h_norm,p_norm] = swtest(x);    % normality check
    fprintf('normality p:    %.6f\n', p_norm);

    if p_norm > 0.05
        % normal → t-test is valid
        [h, p, ci, stats] = ttest(x, 0.5);

        n   = numel(x);
        dz  = stats.tstat / sqrt(n);                         % Cohen's dz (one-sample)
        r_es = stats.tstat / sqrt(stats.tstat^2 + stats.df); % effect-size r

        fprintf('Test:           t-test\n');
        fprintf('p-value:        %.6f\n', p);
        fprintf('H:              %d\n', h);
        fprintf('95%% CI:        [%.4f, %.4f]\n', ci(1), ci(2));
        fprintf('t statistic:    %.4f\n', stats.tstat);
        fprintf('df:             %d\n', stats.df);
        fprintf('SD estimate:    %.4f\n', stats.sd);
        fprintf('Cohen''s dz:    %.3f\n', dz);
        fprintf('effect-size r:  %.3f\n', r_es);

    else
        % non-normal → Wilcoxon signed-rank
        [p_w, h_w, stats_w] = signrank(x, 0.5, 'method', 'exact');

        fprintf('Test:           Wilcoxon signed-rank\n');
        fprintf('p-value:        %.6f\n', p_w);
        fprintf('H:              %d\n', h_w);
        fprintf('W statistic:    %d\n', stats_w.signedrank);
        % you could add rank-biserial correlation here if you want
    end

end



% Test for change in performance across sesssions

d = cr_blocks(:,2) - cr_blocks(:,1);
d = d(~isnan(d));
[h_norm, p_norm] = swtest(d);

med  = median(d);
q    = quantile(d,[0.25 0.75]);   % q(1)=Q1, q(2)=Q3
m    = mean(d);
sd   = std(d);

[h, p, ci, stats] = ttest(d);

n   = numel(d);
dz  = stats.tstat / sqrt(n);                         % Cohen's dz (paired)

fprintf('\n--- T-test results for change in choice performance ---\n');
fprintf('Median:         %.4f\n', med);
fprintf('IQR:            [%.4f, %.4f]\n', q(1), q(2));
fprintf('mean:           %.4f\n', m);
fprintf('SD:             %.4f\n', sd);
fprintf('normality:      %.6f\n', p_norm);
fprintf('p-value:        %.6f\n', p);
fprintf('H (0=no,1=yes): %d\n', h);
fprintf('95%% CI:        [%.4f, %.4f]\n', ci(1), ci(2));
fprintf('t statistic:    %.4f\n', stats.tstat);
fprintf('df:             %d\n', stats.df);
fprintf('SD estimate:    %.4f\n', stats.sd);
fprintf('Cohen''s dz:    %.3f\n', dz);


%% Fig. 2F

figure;
scatter(mean(arena, 2), mean(cr_blocks,2)', 75, [248/256, 206/256, 161/256], 'filled','MarkerEdgeColor', 'k');
[r, p,RLO,RUP] = corrcoef(mean(arena, 2), mean(cr_blocks,2), 'rows', 'complete')
set(gca,'XLim',[0,1],'XTick',0:0.2:1,'Ylim',[0.5, 0.95],'YTick',0.5:0.1:0.9)
lsline;
title(sprintf('r = %0.2f, p = %0.3f', r(1,2), p(1, 2)));
xlabel('Correlation between arena distances and true distances');
ylabel('Percent correct choices');

prepImg

%% Fig. 2G
% Chosen side
formula = 'Choice ~ DistRelDiff + DistIrrelDiff + (1|Subject)';
glme = fitglme(result_table, formula, 'Distribution', 'Binomial', 'Link', 'logit');
disp(glme)

figure;
hold on 
bar(glme.Coefficients.Estimate(2:3),'facecolor','#6dc8b7','edgecolor','none')
errorbar(1:2,glme.Coefficients.Estimate(2:3),glme.Coefficients.SE(2:3),'k','linestyle','none');
set(gca,'XTick',1:2,'XTickLabel',{'relevant','irrelevant'})
title(sprintf('Chosen side'))
prepImg

%% Fig. 2H
% RT
model_formula = 'RT ~ DistRelCh + DistIrrelCh + DistRelUnCh + DistIrrelUnCh + (1|Subject)';
lme = fitlme(result_table, model_formula);
disp(lme)

figure
hold on
bar(lme.Coefficients.Estimate([2,4,3,5]),'facecolor','#6dc8b7','edgecolor','none')
errorbar(1:4,lme.Coefficients.Estimate([2,4,3,5]),lme.Coefficients.SE([2,4,3,5]),'k','linestyle','none');
set(gca,'XTick',1:4,'XTickLabel',{lme.Coefficients.Name{2},lme.Coefficients.Name{4},lme.Coefficients.Name{3},lme.Coefficients.Name{5}})
title(sprintf('RT'))
title('Effect on Response Time')
prepImg



%% Subpanel I-L
% Run regression separately for each subject
% Initialize variables
num_subjects = 25; % Assuming there are 25 subjects
num_sessions = 2; % Assuming 2 sessions
num_runs = 4; % Assuming 4 runs per session

RT_all_effect = nan(num_subjects, 5);
side_all_effect = nan(num_subjects, 3);

% Loop through each subject
for subj = 1:num_subjects
    % Filter data for the current subject
    subj_data = result_table(result_table.Subject == subj, :);
    
    % Run regression analysis on RT with chosen and unchosen distances
    RT_all_effect(subj, :) = regress(subj_data.RT, ...
        [ones(length(subj_data.RT), 1), ...
         subj_data.DistRelCh, subj_data.DistIrrelCh, subj_data.DistRelUnCh, subj_data.DistIrrelUnCh]);
end

colors = [27/255,119/255,97/255; 110/255,199/255,183/255;27/255,119/255,97/255; 110/255,199/255,183/255];
label = {'chosen rel','chosen irrel','unchosen rel', 'unchosen irrel'};
figure('Position', [100, 100, 1200, 300]);
for s = 1:4
    subplot(1,4,s)
    scatter(mean(arena, 2), RT_all_effect(:,s+1),50,colors(s,:),'filled','MarkerEdgeColor', 'none');
    [r, p,RLO,RUP] = corrcoef(mean(arena, 2), RT_all_effect(:,s+1),'rows','complete');
    lsline;
    title(sprintf('%s, r = %0.2f, p = %0.3f', label{s}, r(1, 2), p(1, 2)), 'Interpreter', 'none');
    ylabel('RT effect')
    xlabel('Correlation between arena distances and true distances');
    prepImg

    fprintf('Test:           %u\n', s);
    fprintf('p-value:        %.6f\n', p(1,2));
    fprintf('r-value:        %.2f\n', r(1,2));
    fprintf('95%% CI:        [%.2f, %.2f]\n', RLO(1,2), RUP(1,2));
        
end
