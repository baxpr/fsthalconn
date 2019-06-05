function fsthalconn_main( ...
	out_dir,subject_dir,roiinfo_csv, ...
	removegm_nii,keepgm_nii,wremovegm_nii,wkeepgm_nii, ...
	fwhm, ...
	project,subject,session,scan, ...
	magick_path ...
	)

% Make ROI masks in native space using Freesurfer thalamus
[roi_dir,rois,urois] = make_roimasks(out_dir,subject_dir,roiinfo_csv);

% Compute connectivity matrices and maps for four different preprocessing
% streams. Smooth.
for niitag = {'removegm','keepgm','wremovegm','wkeepgm'}
	nii = eval([niitag{1} '_nii']);  % The worst hack
	roidata_csv = extract_roidata(out_dir,roi_dir,rois,urois,nii,niitag{1});
	compute_connectivity_matrix(out_dir,roidata_csv,niitag{1});
	compute_connectivity_maps(out_dir,roidata_csv,nii,niitag{1});
	smooth(fullfile(out_dir,['Z_' niitag{1} '.nii']),fwhm);
end

% Mask MNI space connectivity maps (leniently) to reduce disk usage
mask_mni( {
	fullfile(out_dir,'Z_wremovegm.nii')
	fullfile(out_dir,'sZ_wremovegm.nii')
	fullfile(out_dir,'Z_wkeepgm.nii')
	fullfile(out_dir,'sZ_wkeepgm.nii')
	})

% Generate PDF report
