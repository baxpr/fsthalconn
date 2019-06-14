function roidata_csv = extract_roidata(out_dir,roi_dir,rois,urois,nii,niitag)

% For each unique ROI file, resample the fMRI to its space for best data
% extraction, the extract
flags = struct('mask',true,'mean',false,'interp',0,'which',1, ...
	'wrap',[0 0 0],'prefix','r');
Vfmri = spm_vol(nii);
roidata = nan(length(Vfmri),height(rois));

for u = 1:height(urois)
	
	fprintf('Working on %s\n',urois.mgzroot{u});
	
	% Resample the fMRI to ROI image space
	fprintf('   resample and load\n')
	spm_reslice_quiet({urois.nii{u} nii},flags);
	[p,n,e] = fileparts(nii);
	rfmri_nii = fullfile(p,['r' n e]);
	movefile(rfmri_nii,fullfile(p,sprintf('r%d%s%s',u,n,e)));
	rfmri_nii = fullfile(p,sprintf('r%d%s%s',u,n,e));
	
	% Find the set of ROIs derived from the current ROI geom
	rinds = find(strcmp(rois.fsfile,urois.mgzroot{u}));
	fprintf('   extract %d rois\n',length(rinds))
	
	% Load resampled fmri volume by volume to save memory
	for v = 1:length(Vfmri)
		
		Vrfmri = spm_vol([rfmri_nii ',' num2str(v)]);
		Yrfmri = spm_read_vols(Vrfmri);
		Yrfmri = reshape(Yrfmri,[],1)';
		Yrfmri(isnan(Yrfmri(:))) = 0;
		
		% Extract data for all matching rois
		for r = 1:length(rinds)
			%fprintf('       %s\n',rois.region{rinds(r)});
			roi_nii = [roi_dir '/roi_' rois.region{rinds(r)} '.nii'];
			Vroi = spm_vol(roi_nii);
			Yroi = spm_read_vols(Vroi);
			Yroi(isnan(Yroi(:))) = 0;
			roidata(v,rinds(r)) = mean(Yrfmri(:,Yroi(:)>0),2);
		end
		
	end
	
	% Clean up
	fprintf('   clean up\n')
	delete(rfmri_nii);
	
end

% Save ROI data to file
roidata = array2table(roidata,'VariableNames',rois.region);
roidata_csv = [out_dir '/roidata_' niitag '.csv'];
writetable(roidata,roidata_csv)


return

