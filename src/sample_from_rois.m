%roiinfo_csv
%roi_dir
%fmri_nii
%out_dir

% Get list of ROIs
rois = readtable(which(roiinfo_csv));

% Get fmri info
Vfmri = spm_vol(fmri_nii);
Nfmri = length(Vfmri);

% Resample fMRI to match ROI images. FIXME can't assume same ROI geometry
% for all.
flags = struct('mask',true,'mean',false,'interp',0,'which',1, ...
	'wrap',[0 0 0],'prefix','r');
spm_reslice({[roi_dir '/roi_' rois.region{1} '.nii'],fmri_nii},flags);
[p,n,e] = fileparts(fmri_nii);
rfmri_nii = fullfile(p,['r' n e]);
Vrfmri = spm_vol(rfmri_nii);
Yrfmri = spm_read_vols(Vrfmri);
osize = size(Yrfmri);
Yrfmri = reshape(Yrfmri,[],osize(4))';


%% For each ROI and each time point, extract data
roidata = nan(Nfmri,height(rois));
for r = 1:height(rois)
		roi_nii = [roi_dir '/roi_' rois.region{r} '.nii'];
	Vroi = spm_vol(roi_nii);
	Yroi = spm_read_vols(Vroi);
	roidata(:,r) = mean(Yrfmri(:,Yroi(:)>0),2);
end

roidata = array2table(roi_data,'VariableNames',rois.region);
writetable(roidata,[out_dir '/roidata.csv'])

