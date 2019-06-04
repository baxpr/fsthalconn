function fsthalconn(varargin)


%% Parse inputs
P = inputParser;

addOptional(P,'removegm_niigz','/INPUTS/fmri.nii.gz');
addOptional(P,'keepgm_niigz','/INPUTS/fmri.nii.gz');
addOptional(P,'wremovegm_niigz','/INPUTS/fmri.nii.gz');
addOptional(P,'wkeepgm_niigz','/INPUTS/fmri.nii.gz');

addOptional(P,'fwhm','6');

addOptional(P,'project','UNK_PROJ');
addOptional(P,'subject','UNK_SUBJ');
addOptional(P,'session','UNK_SESS');
addOptional(P,'scan','UNK_SCAN');

addOptional(P,'magick_path','/usr/bin');

addOptional(P,'out_dir','/OUTPUTS');

parse(P,varargin{:});

removegm_niigz = P.Results.removegm_niigz;
keepgm_niigz = P.Results.keepgm_niigz;
wremovegm_niigz = P.Results.wremovegm_niigz;
wkeepgm_niigz = P.Results.wkeepgm_niigz;

fwhm = P.Results.fwhm;

project = P.Results.project;
subject = P.Results.subject;
session = P.Results.session;
scan    = P.Results.scan;

magick_path = P.Results.magick_path;

out_dir = P.Results.out_dir;

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
	removegm_nii,keepgm_nii,wremovegm_nii,wkeepgm_nii, ...
	fwhm, ...
	project,subject,session,scan, ...
	magick_path ...
	)

