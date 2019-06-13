function [roi_dir,rois,urois] = make_roimasks(out_dir,subject_dir,roiinfo_csv)

% Load ROI combining information. This file must be in the path
rois = readtable(which(roiinfo_csv));

% Identify needed ROI mgz files and convert to nifti
urois = table(unique(rois.fsfile),'VariableNames',{'mgzroot'});
clear unii
for u = 1:height(urois)
	urois.mgz{u,1} = [subject_dir '/mri/' urois.mgzroot{u}];
	[~,n] = fileparts(urois.mgzroot{u});
	roi_dir = [out_dir '/subject_rois'];
	if ~exist(roi_dir,'dir'), mkdir(roi_dir), end
	urois.nii{u,1} = [roi_dir '/' n '.nii'];
	cmd = ['bash ' which('mri_convert_run.sh') ' ' urois.mgz{u,1} ' ' urois.nii{u,1}];
	system(cmd);
end

% Bung the nii filenames back into the ROI table
for r = 1:height(rois)
	rois.nii{r,1} = urois.nii{strcmp(urois.mgzroot,rois.fsfile{r})};
end

% Convert the value strings to numbers in the ROI table
rois.values = cellfun(@str2num,rois.values,'UniformOutput',false);

% Create mask image for each desired ROI
fprintf('Creating ROI masks\n')
for r = 1:height(rois)
	
	V = spm_vol(rois.nii{r});
	Y = spm_read_vols(V);
	Yroi = zeros(size(Y));
	Yroi(ismember(Y(:),rois.values{r})) = 1;
	
	Vroi = V;
	Vroi.pinfo(1:2) = [1 0];
	Vroi.fname = [roi_dir '/roi_' rois.region{r} '.nii'];
	spm_write_vol(Vroi,Yroi);
		
end

return




% % Create mask image for each ROI. Resample the ROI images to fMRI voxels,
% % using trilinear interp so we get approximately reasonable weights for
% % making ROI averages. That interp doesn't work super well though.
% flags = struct('mask',true,'mean',false,'interp',1,'which',1, ...
% 	'wrap',[0 0 0],'prefix','r');
% for r = 1:height(rois)
% 	
% 	V = spm_vol(rois.nii{r});
% 	Y = spm_read_vols(V);
% 	Yroi = zeros(size(Y));
% 	Yroi(ismember(Y(:),rois.values{r})) = 1;
% 	
% 	Vroi = V;
% 	Vroi.pinfo(1:2) = [1 0];
% 	Vroi.fname = [roi_dir '/roi_' rois.region{r} '.nii'];
% 	spm_write_vol(Vroi,Yroi);
% 	
% 	spm_reslice({[fmri_nii ',1'],Vroi.fname},flags);
% 	
% end
% 
% % Load the fMRI
% Vfmri = spm_vol(fmri_nii);
% Yfmri = spm_read_vols(Vfmri);
% osize = size(Yfmri);
% Yfmri = reshape(Yfmri,[],osize(4))';
% Yfmri(isnan(Yfmri(:))) = 0;
% 
% % For each ROI and each time point, extract data
% roidata = nan(osize(4),height(rois));
% for r = 1:height(rois)
% 	roi_nii = [roi_dir '/rroi_' rois.region{r} '.nii'];
% 	Vroi = spm_vol(roi_nii);
% 	Yroi = spm_read_vols(Vroi);
% 	Yroi(isnan(Yroi(:))) = 0;
% 	
% 	weights = repmat(Yroi(:)',osize(4),1);
% 	weighted = weights .* Yfmri;
% 	weightsum = sum(Yroi(:));
% 	roidata(:,r) = sum(weighted,2) / weightsum;
% 	
% end


