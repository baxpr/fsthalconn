function [roi_dir,roi_csv] = make_roimasks_and_extract( ...
	out_dir,subject_dir,roiinfo_csv,fmri_nii)

% System command string to set up freesurfer
fscmd = ['export FREESURFER_HOME=/usr/local/freesurfer && ' ...
	'source ${FREESURFER_HOME}/SetUpFreeSurfer.sh'];

% Load ROI combining information. This file must be in the path
rois = readtable(which(roiinfo_csv));

% Identify needed ROI mgz files and convert to nifti
ufiles = table(unique(rois.fsfile),'VariableNames',{'mgzroot'});
clear unii
for u = 1:height(ufiles)
	ufiles.mgz{u,1} = [subject_dir '/mri/' ufiles.mgzroot{u}];
	[~,n] = fileparts(ufiles.mgzroot{u});
	roi_dir = [out_dir '/subject_rois'];
	if ~exist(roi_dir,'dir'), mkdir(roi_dir), end
	ufiles.nii{u,1} = [roi_dir '/' n '.nii'];
	cmd = [fscmd ' && mri_convert ' ufiles.mgz{u,1} ' ' ufiles.nii{u,1}];
	system(cmd);
end

% Bung the nii filenames back into the ROI table
for r = 1:height(rois)
	rois.nii{r,1} = ufiles.nii{strcmp(ufiles.mgzroot,rois.fsfile{r})};
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

% For each unique ROI file, resample the fMRI to its space for best data
% extraction, the extract
flags = struct('mask',true,'mean',false,'interp',0,'which',1, ...
	'wrap',[0 0 0],'prefix','r');
Vfmri = spm_vol(fmri_nii);
roidata = nan(length(Vfmri),height(rois));

for u = 1:height(ufiles)
	
	fprintf('Working on %s\n',ufiles.mgzroot{u});
	
	% Resample and load the fMRI
	fprintf('   resample and load\n')
	spm_reslice({ufiles.nii{u} fmri_nii},flags);
	[p,n,e] = fileparts(fmri_nii);
	rfmri_nii = fullfile(p,['r' n e]);
	movefile(rfmri_nii,fullfile(p,sprintf('r%d%s%s',u,n,e)));
	rfmri_nii = fullfile(p,sprintf('r%d%s%s',u,n,e));
	Vrfmri = spm_vol(rfmri_nii);
	Yrfmri = spm_read_vols(Vrfmri);
	osize = size(Yrfmri);
	Yrfmri = reshape(Yrfmri,[],osize(4))';
	Yrfmri(isnan(Yrfmri(:))) = 0;
	
	% Extract data for all matching rois
	fprintf('   extract\n')
	rinds = find(strcmp(rois.fsfile,ufiles.mgzroot{u}));
	for r = 1:length(rinds)
		roi_nii = [roi_dir '/roi_' rois.region{rinds(r)} '.nii'];
		Vroi = spm_vol(roi_nii);
		Yroi = spm_read_vols(Vroi);
		Yroi(isnan(Yroi(:))) = 0;
		roidata(:,rinds(r)) = mean(Yrfmri(:,Yroi(:)>0),2);
	end
	
	% Clean up
	fprintf('   clean up\n')
	%delete(rfmri_nii);
	
end

% Save ROI data to file
roidata = array2table(roidata,'VariableNames',rois.region);
roi_csv = [out_dir '/roidata.csv'];
writetable(roidata,roi_csv)


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


