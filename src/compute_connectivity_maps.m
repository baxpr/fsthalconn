function compute_connectivity_maps(out_dir,roidata_csv,fmri_nii,filetag)

% Load ROI data from make_roimasks_and_extract.m
roidata = readtable(roidata_csv);

% Load fmri
Vfmri = spm_vol(fmri_nii);
Yfmri = spm_read_vols(Vfmri);
osize = size(Yfmri);
rYfmri = reshape(Yfmri,[],osize(4))';

% Compute connectivity maps
R = corr(roidata,rYfmri);
Z = atanh(R) * sqrt(size(roidata,1)-3);

% Save to file
for r = 1:width(roidata)
	Vout = rmfield(Vfmri,'pinfo');
	Vout.fname = fullfile(out_dir,['Z_' filetag '.nii']);
	Yout = reshape(Z(r,:),osize(1:3));
	spm_write_vol(Vout,Yout);
end
