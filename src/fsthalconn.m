function fsthalconn(varargin)


%% Parse inputs
P = inputParser;

	out_dir,subject_dir,roiinfo_csv, ...
	removegm_niigz,keepgm_niigz,wremovegm_niigz,wkeepgm_niigz, ...
	wedge_niigz,wbrainmask_niigz, ...
	wmeanfmri_niigz,t1_niigz,wt1_niigz, ...
	fwhm, ...
	project,subject,session,scan, ...
	magick_path ...

addOptional(P,'out_dir','/OUTPUTS');
addOptional(P,'subject_dir','/INPUTS/SUBJECT');
addOptional(P,'roiinfo_csv','CombinedFreesurferLabels_reorg.csv');

addOptional(P,'removegm_niigz','/INPUTS/fmri.nii.gz');
addOptional(P,'keepgm_niigz','/INPUTS/fmri.nii.gz');
addOptional(P,'wremovegm_niigz','/INPUTS/fmri.nii.gz');
addOptional(P,'wkeepgm_niigz','/INPUTS/fmri.nii.gz');

addOptional(P,'wedge_niigz','/INPUTS/redge_wgray.nii.gz');
addOptional(P,'wbrainmask_niigz','/INPUTS/rwmask.nii.gz');

addOptional(P,'wmeanfmri_niigz','/INPUTS/wmeanadfmri.nii.gz');
addOptional(P,'t1_niigz','/INPUTS/mt1.nii.gz');
addOptional(P,'wt1_niigz','/INPUTS/wmt1.nii.gz');

addOptional(P,'fwhm','6');

addOptional(P,'project','UNK_PROJ');
addOptional(P,'subject','UNK_SUBJ');
addOptional(P,'session','UNK_SESS');
addOptional(P,'scan','UNK_SCAN');

addOptional(P,'magick_path','/usr/bin');


parse(P,varargin{:});

out_dir = P.Results.out_dir;
subject_dir = P.Results.subject_dir;
roiinfo_csv = P.Results.roiinfo_csv;

removegm_niigz = P.Results.removegm_niigz;
keepgm_niigz = P.Results.keepgm_niigz;
wremovegm_niigz = P.Results.wremovegm_niigz;
wkeepgm_niigz = P.Results.wkeepgm_niigz;

wedge_niigz = P.Results.wedge_niigz;
wbrainmask_niigz = P.Results.wbrainmask_niigz;

wmeanfmri_niigz = P.Results.wmeanfmri_niigz;
t1_niigz = P.Results.t1_niigz;
wt1_niigz = P.Results.wt1_niigz;

fwhm = P.Results.fwhm;

project = P.Results.project;
subject = P.Results.subject;
session = P.Results.session;
scan    = P.Results.scan;

magick_path = P.Results.magick_path;


fprintf('%s %s %s\n',project,subject,session);
fprintf('fmri scan:       %s\n',scan);
fprintf('fwhm:            %s\n',fwhm);
fprintf('removegm_niigz:  %s\n',removegm_niigz);
fprintf('keepgm_niigz:    %s\n',keepgm_niigz);
fprintf('wremovegm_niigz: %s\n',wremovegm_niigz);
fprintf('wkeepgm_niigz:   %s\n',wkeepgm_niigz);
fprintf('out_dir:         %s\n',out_dir);


%% Process
fsthalconn_main( ...
	out_dir,subject_dir,roiinfo_csv, ...
	removegm_niigz,keepgm_niigz,wremovegm_niigz,wkeepgm_niigz, ...
	wedge_niigz,wbrainmask_niigz, ...
	wmeanfmri_niigz,t1_niigz,wt1_niigz, ...
	fwhm, ...
	project,subject,session,scan, ...
	magick_path ...
	);


%% Exit
if isdeployed
	exit
end

