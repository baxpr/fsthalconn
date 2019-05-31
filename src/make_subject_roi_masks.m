function make_subject_roi_masks(out_dir,subject_dir,roiinfo_csv)

% System command string to set up freesurfer
fscmd = ['export FREESURFER_HOME=/usr/local/freesurfer && ' ...
	'source ${FREESURFER_HOME}/SetUpFreeSurfer.sh'];

% Load ROI combining information. This file must be in the path
rois = readtable(which(roiinfo_csv));

% Identify needed ROI mgz files and convert to nifti
ufiles = table(unique(rois.fsfile),'VariableNames',{'mgzroot'});
clear unii
for f = 1:length(ufsfiles)
	ufiles.mgz{f,1} = [subject_dir '/mri/' ufiles.mgzroot{f}];
	[~,n] = fileparts(ufiles.mgzroot{f});
	ufiles.nii{f,1} = [out_dir '/subject_rois/' n '.nii'];
	cmd = [fscmd ' && mri_convert ' ufiles.mgz{f,1} ' ' ufiles.nii{f,1}];
	system(cmd);
end

% Bung the nii filenames back into the ROI table
for r = 1:height(rois)
	rois.nii{r,1} = ufiles.nii{strcmp(ufiles.mgzroot,rois.fsfile{r})};
end

% Convert the value strings to numbers in the ROI table
rois.values = cellfun(@str2num,rois.values,'UniformOutput',false);

% Create mask image for each ROI
for r = 1:height(rois)
	V = spm_vol(rois.nii{r});
	Y = spm_read_vols(V);
	Yroi = zeros(size(Y));
	Yroi(ismember(Y(:),rois.values{r})) = 1;
	Vroi = V;
	Vroi.pinfo(1:2) = [1 0];
	Vroi.fname = [out_dir '/subject_rois/roi_' rois.region{r} '.nii'];
	spm_write_vol(Vroi,Yroi);
end

