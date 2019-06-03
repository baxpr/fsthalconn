function fsthalconn_main( ...
	out_dir,subject_dir,roiinfo_csv, ...
	removegm_nii,keepgm_nii,wremovegm_nii,wkeepgm_nii, ...
	project,subject,session,scan, ...
	magick_path ...
	)

% Make ROI masks in native space using Freesurfer thalamus
[roi_dir,rois,urois] = make_roimasks(out_dir,subject_dir,roiinfo_csv);

% Compute connectivity matrices and maps for four different preprocessing
% streams
for niitag = {'removegm_nii','keepgm_nii','wremovegm_nii','wkeepgm_nii'}
	nii = eval(niitag{1});
	roidata_csv = extract_roidata(out_dir,roi_dir,rois,urois,nii);
	compute_connectivity_matrix(out_dir,roidata_csv,niitag);
	compute_connectivity_maps(out_dir,roidata_csv,nii,niitag);
end

% Mask MNI space connectivity maps (leniently) to reduce disk usage

% Generate PDF report
