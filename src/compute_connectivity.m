function compute_connectivity(out_dir,roidata_csv,fmri_nii,filetag)

% Load ROI data from make_roimasks_and_extract.m
roidata = readtable(roidata_csv);

% Compute connectivity matrix
R = corr(roidata);
Z = atanh(R) * sqrt(size(roidata,1)-3);
roinames = roidata.Properties.VariableNames;
R = array2table(R,'VariableNames',roinames,'RowNames',roinames);
Z = array2table(Z,'VariableNames',roinames,'RowNames',roinames);
writetable(R,[out_dir '/R_' filetag '.csv']);
writetable(Z,[out_dir '/Z_' filetag '.csv']);

% Load fmri
Vfmri = spm_vol(fmri_nii);
Yfmri = spm_read_vols(Vfmri);
osize = size(Yfmri);
rYfmri = reshape(Yfmri,[],osize(4))';

% Compute connectivity maps
