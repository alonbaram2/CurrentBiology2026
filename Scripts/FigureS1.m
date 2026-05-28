%% Fig. S1
% Loop through subjects 1-25 and days 1-3 to load data
clear all; close all; clc;

% Define the base path where data is stored
basePath = '../Data/behdata';

addpath(genpath('matlab_scripts'))

% Preallocate a cell array to store data for each subject and each day
data_all_subjects = cell(25, 3); % 25 subjects, 3 days

for subj = 1:25
    for day = 1:3
        % Construct the file path for each subject and day
        dataFilePath = fullfile(basePath, sprintf('Subj_%d', subj), 'training', sprintf('subj_%d_day%d.mat', subj, day));
        
        % Check if the file exists to avoid loading errors
        if isfile(dataFilePath)
            % Load the data and store it in the cell array
            loadedData = load(dataFilePath);
            data_all_subjects{subj, day} = loadedData;
        else
            fprintf('File not found: %s\n', dataFilePath); % Display a warning if the file is missing
        end
    end
    dist = data_all_subjects{1}.data.dist;
end

%% 
perf_mem = nan(25,3);
perf_exp = nan(25,3);
perf_part = nan(25,3);
perf_objDiff = nan(25,3);
perf_goalNav = nan(25,3,6);
for subj = 1:25
    for day = 1:3
        try
            mem = data_all_subjects{subj, day}.data.memory{1};
            perf_mem(subj,day) = sum(mem.cr == 1)/length(mem.cr)*100;
        end
        try
            mem = data_all_subjects{subj, day}.data.passiveExposure{1};
            perf_exp(subj,day) = sum(mem.cr == 1)/length(mem.cr)*100;
        end
        temp = [];
        try
            for run = 1:length(data_all_subjects{subj, day}.data.findPartner)
                mem = data_all_subjects{subj, day}.data.findPartner{run};
                temp(run) = sum(mem.cr == 1)/length(mem.cr)*100;
            end
            perf_part(subj,day) = nanmean(temp);
        end
        temp = [];
        try
            for run = 1:length(data_all_subjects{subj, day}.data.objectDifference)
                mem = data_all_subjects{subj, day}.data.objectDifference{run};
                temp(run) = sum(mem.cr == 1)/length(mem.sideChosen)*100;
            end
            perf_objDiff(subj,day) = nanmean(temp);
        end
        temp = [];
        try
            counter = 0;
            for run = 1:length(data_all_subjects{subj, day}.data.goalNavigation)
                mem = data_all_subjects{subj, day}.data.goalNavigation{run};
                for trial = 1:30
                    target = mem.target(trial)+1;           % javascript indexing starts at 0!
                    options = mem.options{trial}+1;
                    start = mem.chosenSeq{trial}(1)+1;
                    try
                        counter = counter + 1;
                        temp(counter,:) = [dist(target,start), length(mem.chosenSeq{trial})-1];   % subtract one, because the first element of chosenSeq is the start object
                        
                    end
                end
            end
            for i = 1:6
                perf_goalNav(subj,day,i) = nanmean(temp(temp(:,1) == i,2));
            end
        end
        
    end
end

% Define colors and days
colors = [114, 151, 173; 209, 132, 134; 244, 212, 174] / 255;
days = 1:3; % Days 1, 2, and 3

% Create a figure with multiple subplots
figure;

% Define variables to plot
performanceVariables = {perf_mem, perf_exp, perf_part, perf_objDiff};
titles = {'Memory', 'Passive Exposure', 'Find Partner', 'Object Difference'};

for varIdx = 1:length(performanceVariables)
    % Select the current variable data
    perf_data = performanceVariables{varIdx};
    
    % Remove specific subjects if needed
    if isequal(perf_data, perf_mem)
        perf_data([15, 18], :) = [];
    end

    % Calculate the mean performance for each day
    mean_perf = nanmean(perf_data, 1);
    
    % Prepare data for scatter plot
    numSubjects = size(perf_data, 1);
    group = repmat(1:3, numSubjects, 1);
    data = reshape(perf_data, 1, []);
    group = reshape(group, 1, []);

    % Create subplot
    subplot(2, 2, varIdx); % 2x2 grid of subplots

    % Plot bars and scatter points for each day
    for i = 1:3
        bar(days(i), mean_perf(i), 'FaceColor', colors(i, :), 'BarWidth', 0.8);
        hold on;

        dayIndices = (group == days(i)); % Find indices for the current day
        jitteredX = days(i) - 0.15 + 0.3 * rand(1, sum(dayIndices)); % Small random offset
        scatter(jitteredX, data(dayIndices), 35, colors(i, :), 'filled', 'MarkerEdgeColor', 'k');
    end

    % Add labels and titles
    set(gca, 'XTick', 1:3, 'FontSize', 12);
    ylabel('Percent correct');
    xlabel('Day');
    title(titles{varIdx});
    box off;
    prepImg

    
    if varIdx == 2
        [~,p,~,stats] = ttest(perf_data(:,1),perf_data(:,2));
        fprintf('Obj difference day 1 versus day 2, p = %0.3f\n',p)
    else
        t = table((1:25)',perf_data(:,1),perf_data(:,2),perf_data(:,3),'VariableNames',{'IDs','d1','d2','d3'});
        Days = table([1 2 3]','VariableNames',{'Measurements'});
        rm = fitrm(t,'d1-d3 ~ 1','WithinDesign',Days);
        ranovatbl = ranova(rm);
        fprintf('%s, Anova, p = %0.3f\n', titles{varIdx}, ranovatbl.pValue(1))
        if ranovatbl.pValue(1) < 0.05
            [~,p,~,stats] = ttest(perf_data(:,1),perf_data(:,2));
            fprintf('%s, Day 1 versus Day 2, p = %0.3f\n', titles{varIdx},p)
            [~,p,~,stats] = ttest(perf_data(:,1),perf_data(:,3));
            fprintf('%s, Day 1 versus Day 3, p = %0.3f\n', titles{varIdx},p)
            [~,p,~,stats] = ttest(perf_data(:,2),perf_data(:,3));
            fprintf('%s, Day 2 versus Day 3, p = %0.3f\n', titles{varIdx},p)
            
        end
    end
end

% Adjust layout
sgtitle('Performance across Days for Different Tasks'); % Super title for all subplots

%%

% Create a figure
figure;

% Loop through each distance (1 to 6)
for day = 1:3
    % Extract data for the current distance
    perf_data = squeeze(perf_goalNav(:, day, :)); % 25x3 matrix (subjects x days)
    
    % Calculate mean performance for each day
    mean_perf = nanmean(perf_data, 1);

    % Prepare data for scatter plot
    numSubjects = size(perf_data, 1);
    group = repmat(1:6, numSubjects, 1);
    data = reshape(perf_data, 1, []);
    group = reshape(group, 1, []);

    % Create subplot for each distance
    subplot(1, 3, day); % 2x3 grid for 6 distances

    % Plot bars and scatter points for each day
    for i = 1:6
        bar(i, mean_perf(i), 'FaceColor', colors(day, :), 'BarWidth', 0.8);
        hold on;

        dayIndices = (group == i); % Find indices for the current day
        jitteredX = i - 0.15 + 0.3 * rand(1, sum(dayIndices)); % Small random offset
        scatter(jitteredX, data(dayIndices), 35, colors(day, :), 'filled', 'MarkerEdgeColor', 'k');
    end

    % Add labels and titles
    set(gca, 'XTick', 2:6, 'FontSize', 12, 'XLim',[1 7],'ylim',[0 14]);
    ylabel('Average path length');
    xlabel(sprintf('Shortest\npath length'));
    title(['Day ' num2str(day)]);
    box off;
    prepImg
end

% Adjust layout
sgtitle('Goal Navigation Performance across Days by Distance');


