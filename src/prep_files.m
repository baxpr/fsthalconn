function [removegm_nii,keepgm_nii,wremovegm_nii,wkeepgm_nii, ...
	wedge_nii,wbrainmask_nii,wmeanfmri_nii,t1_nii,wt1_nii] = ...
	prep_files( ...
	out_dir, ...
	removegm_niigz,keepgm_niigz,wremovegm_niigz,wkeepgm_niigz, ...
	wedge_niigz,wbrainmask_niigz,wmeanfmri_niigz,t1_niigz,wt1_niigz)

% Terrible hack with eval again to copy files to out_dir and unzip
for tag = {'removegm','keepgm','wremovegm','wkeepgm', ...
		'wedge','wbrainmask','wmeanfmri','t1','wt1'}
	copyfile(eval([tag{1} '_niigz']),[out_dir '/' tag{1} '.nii.gz']);
	system(['gunzip -f ' out_dir '/' tag{1} '.nii.gz']);
	cmd = [tag{1} '_nii = [out_dir ''/'' tag{1} ''.nii''];'];
	eval(cmd);
end
