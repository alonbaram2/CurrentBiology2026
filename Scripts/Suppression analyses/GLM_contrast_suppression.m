clear all

addpath(genpath('/vols/Scratch/mgarvert/ManyMaps/myPreprocessing/spm12'))
root        = '/vols/Scratch/mgarvert/ManyMaps/imagingData/Subj_';
nblocks     = 4;

% Name of the experimental design. Start with 2* for RSA-designs and 1* for
% more basic designs

for subj    = 1:25
session = 2;
design_name = 'design_322_fsl_';



spmdir = [root,num2str(subj),'/session_',num2str(session),'/1stLevel/',design_name,'/SPM.mat']; % directory for SPM.mat file
if exist(spmdir)
    load(spmdir);
    
    clear matlabbatch
    % how many columns needed for which condition
    % ====================================================================== %
    conditions = [];
    for i = 1:length(SPM.Sess(1).Fc)
        conditions{i} = SPM.Sess(1).Fc(i).name;
        disp( SPM.Sess(1).Fc(i).name)
    end
    
    col.sess        = nblocks;              % one constant per block
    col.motion      = 6;                    % motion only %% 6 motion regressors per session and 17 physio regressors
    col.cond        = length(SPM.Sess(1).col)-col.motion;
    
    col.general     = zeros(1,col.cond);  % condition only
    col.total.all   = size(SPM.xX.X,2);
    col.block       = repmat([col.general zeros(1,col.motion)],col.sess,1);
    
    % all columns together
    % ====================================================================== %
    
    disp(['Design matrix should have ',num2str(col.total.all),' columns']);
    
    concounter = 1;
    
    % % ADAPTATION
    % ====================================================================== %
    
    % 1 Object onset
    ci_pos = [1 4 7 10];
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
    end
    stim_onset = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name      = 'stim_onset'; %name
    stats.con.consess{concounter}.tcon.convec    = stim_onset;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;
        
    % 2 Relevant distance stay
    ci_pos = [2 8];
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
    end
    rel_dist_stay = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name      = 'rel_dist_stay'; %name
    stats.con.consess{concounter}.tcon.convec    = rel_dist_stay;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;
    
    % 3 Irrelevant distance stay
    ci_pos = [3 9];
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
    end
    irrel_dist_stay = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name      = 'irrel_dist_stay'; %name
    stats.con.consess{concounter}.tcon.convec    = irrel_dist_stay;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;

    % 4 Relevant distance switch
    ci_pos = [5 11];
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
    end
    rel_dist_switch = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name      = 'rel_dist_switch'; %name
    stats.con.consess{concounter}.tcon.convec    = rel_dist_switch;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;

    % 5 Irrelevant distance switch
    ci_pos = [6 12];
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
    end
    irrel_dist_switch = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name      = 'irrel_dist_switch'; %name
    stats.con.consess{concounter}.tcon.convec    = irrel_dist_switch;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;

    % 6 Relevant - Irrelevant distance stay
    ci_pos = [2 8];
    ci_neg = [3 9];
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
	block(i,ci_neg) = -1;
    end
    rel_irrel_dist_stay = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name      = 'rel_irrel_dist_stay'; %name
    stats.con.consess{concounter}.tcon.convec    = rel_irrel_dist_stay;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;

    % 7 Any distance stay
    ci_pos = [2 3 8 9];
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
    end
    any_dist_stay = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name      = 'any_dist_stay'; %name
    stats.con.consess{concounter}.tcon.convec    = any_dist_stay;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;

    % 8 Any distance switch
    ci_pos = [5 6 11 12];
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
    end
    any_dist_switch = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name      = 'any_dist_switch'; %name
    stats.con.consess{concounter}.tcon.convec    = any_dist_switch;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;

    % 9 Stay versus switch
    ci_pos = [1 4];
    ci_neg = [7 10];
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
        block(i,ci_neg) = -1;
    end
    stay_switch = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name      = 'stay_switch'; %name
    stats.con.consess{concounter}.tcon.convec    = stay_switch;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;
    
    % 10 Map 1 versus map 2
    ci_pos = [1 7];
    ci_neg = [4 10];
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
        block(i,ci_neg) = -1;
    end
    map1_vs_map2 = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name      = 'map1_vs_map2'; %name
    stats.con.consess{concounter}.tcon.convec    = map1_vs_map2;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;

    % 11. choiceOnset
    ci_pos = 13;
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
    end
    stim_onset = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name	 = 'choiceOnset'; %name
    stats.con.consess{concounter}.tcon.convec    = stim_onset;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;

    % 12,13,14,15. Distances
    distName={'chosenRel','unchosenRel','chosenIrrel','unchosenIrrel'};
    for i = 1:4
        ci_pos = 13+i;
        block = col.block;
        for h = 1:nblocks
            block(h,ci_pos) = 1;
        end
        stim_onset = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
        stats.con.consess{concounter}.tcon.name      = distName{i}; %name
        stats.con.consess{concounter}.tcon.convec    = stim_onset;                   %contrast vector
        stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
        concounter = concounter+1;
    end

    % 16 chosen - unchosen rel
    ci_pos = 14;
    ci_neg = 15;
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
        block(i,ci_neg) = -1;
    end
    stim_onset = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name	 = 'chosen-unchosenRel'; %name
    stats.con.consess{concounter}.tcon.convec    = stim_onset;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;

    % 17 chosen - unchosen irrel
    ci_pos = 16;
    ci_neg = 17;
    block = col.block;
    for i = 1:nblocks
	block(i,ci_pos) = 1;
        block(i,ci_neg) = -1;
    end
    stim_onset = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name	 = 'chosen-unchosenIrrel'; %name
    stats.con.consess{concounter}.tcon.convec    = stim_onset;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;

    % 18 chosen rel - chosen irrel
    ci_pos = 14;
    ci_neg = 16;
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
        block(i,ci_neg) = -1;
    end
    stim_onset = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name	 = 'chosenRel-chosenIrrel'; %name
    stats.con.consess{concounter}.tcon.convec    = stim_onset;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;

    % 19 unchosen rel - unchosen irrel
    ci_pos = 15;
    ci_neg = 17;
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
        block(i,ci_neg) = -1;
    end
    stim_onset = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name	 = 'unchosenRel-unchosenIrrel'; %name
    stats.con.consess{concounter}.tcon.convec    = stim_onset;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;

    % 20 chosen + unchosen rel
    ci_pos = [14 15];
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
    end
    stim_onset = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name	 = 'chosen+unchosenRel'; %name
    stats.con.consess{concounter}.tcon.convec    = stim_onset;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;

    % 21 chosen + unchosen irrel
    ci_pos = [16 17];
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
    end
    stim_onset = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name	 = 'chosen+unchosenIrrel'; %name
    stats.con.consess{concounter}.tcon.convec    = stim_onset;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;

    % 22 chosen rel + chosen irrel
    ci_pos = [14 16];
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
    end
    stim_onset = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name	 = 'chosenRel+chosenIrrel'; %name
    stats.con.consess{concounter}.tcon.convec    = stim_onset;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;

    % 23 unchosen rel + unchosen irrel
    ci_pos = [15 17];
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
    end
    stim_onset = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name	 = 'unchosenRel+unchosenIrrel'; %name
    stats.con.consess{concounter}.tcon.convec    = stim_onset;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;

    % 24 map 1 rel stay
    ci_pos = 2;
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
    end
    stim_onset = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name	 = 'map_1_rel_stay'; %name
    stats.con.consess{concounter}.tcon.convec    = stim_onset;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;

    % 25 map 2 rel stay
    ci_pos = 8;
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
    end
    stim_onset = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name	 = 'map_2_rel_stay'; %name
    stats.con.consess{concounter}.tcon.convec    = stim_onset;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;

    % 26 map 1 rel stay > map 2 rel stay
    ci_pos = 2;
    ci_neg = 8;
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
        block(i,ci_neg) = -1;
    end
    stim_onset = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name	 = 'map_1_rel_stay-map_2_rel_stay'; %name
    stats.con.consess{concounter}.tcon.convec    = stim_onset;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;

    % 27 map 1 irrel stay
    ci_pos = 3;
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
    end
    stim_onset = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name	 = 'map_1_irrel_stay'; %name
    stats.con.consess{concounter}.tcon.convec    = stim_onset;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;
        
    % 28 map 2 irrel stay
    ci_pos = 9;
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
    end
    stim_onset = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name	 = 'map_2_irrel_stay'; %name
    stats.con.consess{concounter}.tcon.convec    = stim_onset;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;
        
    % 29 map 1 irrel stay > map 2 irrel stay
    ci_pos = 3;
    ci_neg = 9;
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
        block(i,ci_neg) = -1;
    end
    stim_onset = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name	 = 'map_1_irrel_stay-map_2_irrel_stay'; %name
    stats.con.consess{concounter}.tcon.convec    = stim_onset;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;


    % 30 map 1 rel switch
    ci_pos = 5;
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
    end
    stim_onset = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name	 = 'map_1_rel_switch'; %name
    stats.con.consess{concounter}.tcon.convec    = stim_onset;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;

    % 31 map 2 rel switch
    ci_pos = 11;
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
    end
    stim_onset = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name	 = 'map_2_rel_switch'; %name
    stats.con.consess{concounter}.tcon.convec    = stim_onset;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;

    % 32 map 1 irrel stay > map 2 irrel stay
    ci_pos = 5;
    ci_neg = 11;
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
        block(i,ci_neg) = -1;
    end
    stim_onset = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name	 = 'map_1_rel_switch-map_2_rel_switch'; %name
    stats.con.consess{concounter}.tcon.convec    = stim_onset;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;

    % 33 Any distance stay map 1
    ci_pos = [2 3];
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
    end
    any_dist_stay = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name	 = 'any_dist_stay_map1'; %name
    stats.con.consess{concounter}.tcon.convec    = any_dist_stay;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;

    % 34 Any distance stay map 2
    ci_pos = [8 9];
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
    end
    any_dist_stay = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name	 = 'any_dist_stay_map2'; %name
    stats.con.consess{concounter}.tcon.convec    = any_dist_stay;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;

    % 35 Any distance stay map1 - map 2
    ci_pos = [2 3];
    ci_neg = [8 9];
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
	block(i,ci_neg) = -1;
    end
    any_dist_stay = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name	 = 'any_dist_stay_map1-map2'; %name
    stats.con.consess{concounter}.tcon.convec    = any_dist_stay;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;

    % 36 Relevant distance, stay+switch
    ci_pos = [2 5 8 11];
    block = col.block;
    for i = 1:nblocks
        block(i,ci_pos) = 1;
    end
    rel_dist_stay = [reshape(block',1,length(block)*nblocks) zeros(1,nblocks)];
    stats.con.consess{concounter}.tcon.name      = 'rel_dist_stayAndSwitch'; %name
    stats.con.consess{concounter}.tcon.convec    = rel_dist_stay;                   %contrast vector
    stats.con.consess{concounter}.tcon.sessrep   = 'none';                   %replicate vector over sessions
    concounter = concounter+1;

    %%
    stats.con.spmmat                    = {spmdir}; % where to find SPM.mat on which estimation has already run
    
    % show in results window
    % ====================================================================== %
    
    stats.results.spmmat = {spmdir}; %which SPM.mat
    stats.results.conspec.titlestr      = '';   %whith title
    stats.results.conspec.contrasts     = 1;    %which contrast
    stats.results.conspec.threshdesc    = 'none'; %FWD or none
    stats.results.conspec.thresh        = 0.05; %threshold
    stats.results.conspec.extent        = 0;    %cluster extend
    stats.results.conspec.mask          = struct('contrasts', {}, 'thresh', {}, 'mtype', {});
    stats.results.units                 = 1;    %datatype:volumetric
    stats.con.delete                    = 1;    %delete existing contrasts
    stats.results.print                 = true; %print in results window
    
    matlabbatch{1}.spm.stats = stats;
    contrast = matlabbatch;
    save([root,num2str(subj),'/session_',num2str(session),'/1stLevel/',design_name,'/contrast.mat'],'contrast');
    save([root,num2str(subj),'/session_',num2str(session),'/1stLevel/',design_name,'/contrastmatrix.mat'],'contrast');
    
    spm_jobman('run',matlabbatch);
    
    clear matlabbatch;
    
    
    %% Smooth contrast images
    
    clear matlabbatch
    factorial_design.dir = {[root,num2str(subj),'/session_',num2str(session),'/1stLevel/',design_name]};
    cd(factorial_design.dir{1})
    
    mkdir ([factorial_design.dir{1},'/smooth/warp'])
    
    % specify scans for each session and voxel shift map generated in
    % previous step (vdm*)
    images  = spm_select('List',['con*nii']);
    for epi = 1:size(images,1)
        matlabbatch{1}.spm.spatial.smooth.data{epi,1} = fullfile(factorial_design.dir{1},images(epi,:));
    end
    
    matlabbatch{1}.spm.spatial.smooth.fwhm = [5 5 5];
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = 's_';
    
    spm_jobman('run',matlabbatch);
    
    images  = spm_select('List',['*nii']);
    for epi = 1:size(images,1)
        matlabbatch{1}.spm.spatial.smooth.data{epi,1} = fullfile(factorial_design.dir{1},images(epi,:));
    end
    
    matlabbatch{1}.spm.spatial.smooth.fwhm = [5 5 5];
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = 's_';
    
    spm_jobman('run',matlabbatch);
    movefile('s_*',[factorial_design.dir{1},'/smooth/'])
    delete([factorial_design.dir{1},'/smooth/s_s_*'])
end
end