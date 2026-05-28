clear; clc;

% ============================
% SETTINGS
% ============================

baseDir = "/vols/Scratch/mgarvert/ManyMaps/imagingData";

subjPattern = "Subj_*";
sessPattern = "session_*";

firstLevelDirName = "1stLevel";
design = "design_322_fsl_";

nblocks = 4;          % runs per SPM

% =========================================================
% WHICH REGRESSORS TO CORRELATE?
% =========================================================
%
% In the GLM script, the all_objects pmods are named:
%   dist_rel_map<m>_switch<s>
%   dist_irrel_map<m>_switch<s>
%
% Define the 4 combinations
obj_pair_labels = ["map1_stay","map1_switch","map2_stay","map2_switch"];

% NOTE: "stay" corresponds to switch=0, "switch" corresponds to switch=1
rel_patterns   = ["dist_rel_map1_switch0",  "dist_rel_map1_switch1",  "dist_rel_map2_switch0",  "dist_rel_map2_switch1"];
irrel_patterns = ["dist_irrel_map1_switch0","dist_irrel_map1_switch1","dist_irrel_map2_switch0","dist_irrel_map2_switch1"];

% ============================
% FIND SUBJECTS
% ============================

subjDirs = dir(fullfile(baseDir, subjPattern));
subjDirs = subjDirs([subjDirs.isdir]);

results = struct([]);
row = 0;

fprintf("Found %d subject folders.\n", numel(subjDirs));

% ============================
% MAIN LOOP
% ============================

for s = 1:numel(subjDirs)

    subjName = string(subjDirs(s).name);
    subjPath = fullfile(baseDir, subjName);

    sessDirs = dir(fullfile(subjPath, sessPattern));
    sessDirs = sessDirs([sessDirs.isdir]);

    if isempty(sessDirs)
        fprintf("WARNING: No sessions found for %s\n", subjName);
        continue;
    end

    for ss = 1:numel(sessDirs)

        sessName = string(sessDirs(ss).name);
        sessPath = fullfile(subjPath, sessName);

        designPath = fullfile(sessPath, firstLevelDirName, design);
        spmMatPath = fullfile(designPath, "SPM.mat");

        if ~isfile(spmMatPath)
            fprintf("WARNING: Missing SPM.mat: %s\n", spmMatPath);
            continue;
        end

        S = load(spmMatPath);
        SPM = S.SPM;
        X = SPM.xX.X;

        if ~isfield(SPM, "xX") || ~isfield(SPM.xX, "name")
            fprintf("WARNING: SPM.xX.name missing in %s\n", spmMatPath);
            continue;
        end

        % Column names as string array for robust matching
        xnames = string(SPM.xX.name(:));

        for run = 1:nblocks

            runTag = "Sn(" + string(run) + ")";  % how SPM prefixes per-session columns

            for k = 1:numel(obj_pair_labels)

                % Identify the *global* column indices for this run + pattern
                g_rel = find(startsWith(xnames, runTag) & contains(lower(xnames), lower(rel_patterns(k))));
                g_irr = find(startsWith(xnames, runTag) & contains(lower(xnames), lower(irrel_patterns(k))));

                if isempty(g_rel) || isempty(g_irr)
                    fprintf("WARNING: Missing columns for %s | %s | run %d | %s (rel found=%d, irrel found=%d)\n", ...
                        subjName, sessName, run, obj_pair_labels(k), numel(g_rel), numel(g_irr));
                    continue;
                end

                if numel(g_rel) > 1
                    fprintf("WARNING: Multiple rel matches for %s | %s | run %d | %s. Using first.\n", ...
                        subjName, sessName, run, obj_pair_labels(k));
                    g_rel = g_rel(1);
                end

                if numel(g_irr) > 1
                    fprintf("WARNING: Multiple irrel matches for %s | %s | run %d | %s. Using first.\n", ...
                        subjName, sessName, run, obj_pair_labels(k));
                    g_irr = g_irr(1);
                end

                r_obj = corr(X(:,g_rel), X(:,g_irr), "type","Pearson");

                row = row + 1;
                results(row).subject = subjName;
                results(row).session = sessName;
                results(row).spmMat  = string(spmMatPath);
                results(row).run     = run;
                results(row).label   = obj_pair_labels(k);
                results(row).colRel  = g_rel;
                results(row).colIrr  = g_irr;
                results(row).r       = r_obj;
            end
        end

        fprintf("OK: %s | %s (processed)\n", subjName, sessName);
    end
end

% ============================
% TABLES + SUMMARY
% ============================
T = struct2table(results);

% Participant-level mean correlation (average across all available runs x labels)
Gsub = groupsummary(T, "subject", "mean", "r");

% Fix: rename using char vectors
idx = strcmp(Gsub.Properties.VariableNames, 'mean_r');
if any(idx)
    Gsub.Properties.VariableNames{idx} = 'r_mean_withinSubj';
end

% Overall summary across participants
rsub = Gsub.r_mean_withinSubj;

fprintf("\n============================\n");
fprintf("PARTICIPANT-LEVEL SUMMARY (mean r per participant)\n");
fprintf("============================\n");
fprintf("N participants = %d\n", numel(rsub));
fprintf("Mean = %.4f\n", mean(rsub, 'omitnan'));
fprintf("Std  = %.4f\n", std(rsub,  'omitnan'));
fprintf("Min  = %.4f\n", min(rsub,  [], 'omitnan'));
fprintf("Max  = %.4f\n", max(rsub,  [], 'omitnan'));
fprintf("Max |r| = %.4f\n", max(abs(rsub), [], 'omitnan'));


% participant-level means separately per label
GsubLabel = groupsummary(T, ["subject","label"], "mean", "r");
GlabelAcrossSubj = groupsummary(GsubLabel, "label", ["mean","std","min","max"], "mean_r");

fprintf("\n============================\n");
fprintf("LABEL-WISE SUMMARY (participant means, then summarized)\n");
fprintf("============================\n");
for i = 1:height(GlabelAcrossSubj)
    fprintf("%s: mean=%.4f, sd=%.4f, min=%.4f, max=%.4f\n", ...
        string(GlabelAcrossSubj.label(i)), ...
        GlabelAcrossSubj.mean_mean_r(i), ...
        GlabelAcrossSubj.std_mean_r(i), ...
        GlabelAcrossSubj.min_mean_r(i), ...
        GlabelAcrossSubj.max_mean_r(i));
end


% ============================
% 2) Participant x session mean (average within each session, per participant)
% ============================
GsubSess = groupsummary(T, ["subject","session"], "mean", "r");  % -> mean_r

% ============================
% 3) Session-level summary across participants
% ============================
sessions = unique(GsubSess.session);

fprintf("\n============================\n");
fprintf("SESSION-LEVEL SUMMARY (participant means within session, then across participants)\n");
fprintf("============================\n");

for i = 1:numel(sessions)
    sess = sessions(i);
    ii = GsubSess.session == sess;
    vals = GsubSess.mean_r(ii);

    fprintf("Session %s | N participants = %d | Mean=%.4f | Std=%.4f | Min=%.4f | Max=%.4f | Max|r|=%.4f\n", ...
        sess, sum(ii), ...
        mean(vals,'omitnan'), std(vals,'omitnan'), ...
        min(vals,[],'omitnan'), max(vals,[],'omitnan'), ...
        max(abs(vals),[],'omitnan'));
end

% Save all tables
outCsv_all      = fullfile(baseDir, "pm_corr_all_objects_allRows.csv");
outCsv_sub      = fullfile(baseDir, "pm_corr_all_objects_participantMeans_allSessionsPooled.csv");
outCsv_subSess  = fullfile(baseDir, "pm_corr_all_objects_participantMeans_bySession.csv");

writetable(T, outCsv_all);
writetable(Gsub, outCsv_sub);
writetable(GsubSess, outCsv_subSess);

fprintf("\nSaved row-level table to:\n%s\n", outCsv_all);
fprintf("Saved participant-mean (pooled) table to:\n%s\n", outCsv_sub);
fprintf("Saved participant-mean (by session) table to:\n%s\n", outCsv_subSess);