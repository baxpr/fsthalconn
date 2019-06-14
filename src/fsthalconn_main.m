function fsthalconn_main( ...
	out_dir,subject_dir,roiinfo_csv, ...
	removegm_niigz,keepgm_niigz,wremovegm_niigz,wkeepgm_niigz, ...
	wedge_niigz,wbrainmask_niigz, ...
	wmeanfmri_niigz,t1_niigz,wt1_niigz, ...
	fwhm, ...
	project,subject,session,scan, ...
	magick_path ...
	)

% Unzip images
[removegm_nii,keepgm_nii,wremovegm_nii,wkeepgm_nii, ...
	wedge_nii,wbrainmask_nii,wmeanfmri_nii,t1_nii,wt1_nii] = ...
	prep_files( ...
	out_dir, ...
	removegm_niigz,keepgm_niigz,wremovegm_niigz,wkeepgm_niigz, ...
	wedge_niigz,wbrainmask_niigz,wmeanfmri_niigz,t1_niigz,wt1_niigz);

% SPM init
spm_jobman('initcfg');

% Make ROI masks in native space using Freesurfer thalamus
[roi_dir,rois,urois] = make_roimasks(out_dir,subject_dir,roiinfo_csv);

% Compute connectivity matrices and maps (smoothed and unsmoothed) for four
% different preprocessing streams
for niitag = {'removegm','keepgm','wremovegm','wkeepgm'}
	disp(['--- ' niitag{1} ' -----------------------------------------------'])
	nii = eval([niitag{1} '_nii']);  % The worst hack
	roidata_csv = extract_roidata(out_dir,roi_dir,rois,urois,nii,niitag{1});
	compute_connectivity_matrix(out_dir,roidata_csv,niitag{1});
	compute_connectivity_maps(out_dir,roidata_csv,nii,fwhm,niitag{1});
end

% Mask MNI space connectivity maps (leniently) to reduce disk usage
mask_mni(out_dir);


% Generate PDF report
make_pdf(out_dir,t1_nii,wmeanfmri_nii,wt1_nii,magick_path, ...
	project,subject,session,scan);


% Organize and clean up
organize_outputs(out_dir,roiinfo_csv);



