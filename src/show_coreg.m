function show_coreg(out_dir,wmeanfmri_nii,wt1_nii, ...
	project,subject,session,scan)

% Reslice flags and target image
flags = struct('mask',true,'mean',false,'interp',1,'which',1, ...
	'wrap',[0 0 0],'prefix','r');
tgt_nii = [spm('dir') '/tpm/TPM.nii,1'];
Ytgt = spm_read_vols(spm_vol(tgt_nii));

% Reslice and load mean fmri
spm_reslice_quiet({tgt_nii,wmeanfmri_nii},flags);
[p,n,e] = fileparts(wmeanfmri_nii);
rfmri_nii = fullfile(p,['r' n e]);
Yfmri = spm_read_vols(spm_vol(rfmri_nii));

% Reslice and load T1
spm_reslice_quiet({tgt_nii,wt1_nii},flags);
[p,n,e] = fileparts(wt1_nii);
rt1_nii = fullfile(p,['r' n e]);
Yt1 = spm_read_vols(spm_vol(rt1_nii));


%% PDF figures

% Figure out screen size so the figure will fit
ss = get(0,'screensize');
ssw = ss(3);
ssh = ss(4);
ratio = 8.5/11;
if ssw/ssh >= ratio
	dh = ssh;
	dw = ssh * ratio;
else
	dw = ssw;
	dh = ssw / ratio;
end

% Create figure
pdf_figure = openfig('pdf_connmaps_figure.fig','new');
set(pdf_figure,'Tag','pdf_connmaps');
set(pdf_figure,'Units','pixels','Position',[0 0 dw dh]);
figH = guihandles(pdf_figure);

set(pdf_figure,'Colormap',colormap(gray));

% Summary
set(figH.summary_text, 'String', 'MNI space registration check' )

% Scan info
set(figH.scan_info, 'String', sprintf( ...
	'%s, %s, %s, %s', ...
	project, subject, session, scan));
set(figH.date,'String',['Report date: ' date]);
set(figH.version,'String',['Matlab version: ' version]);

% Slice locations (center of volume)
X = round(size(Yt1,1)/2);
Y = round(size(Yt1,2)/2);
Z = round(size(Yt1,3)/2);

% Top row: three plane view of template gray matter
axes(figH.(['slice' num2str(1)]))
imagesc( imrotate(squeeze(Ytgt(X,:,:)),90) )
axis image off
title('Atlas gray')
axes(figH.(['slice' num2str(2)]))
imagesc( imrotate(squeeze(Ytgt(:,Y,:)),90) )
axis image off
axes(figH.(['slice' num2str(3)]))
imagesc( imrotate(squeeze(Ytgt(:,:,Z)),90) )
axis image off


% Center row: three plane view of T1
axes(figH.(['slice' num2str(4)]))
imagesc( imrotate(squeeze(Yt1(X,:,:)),90) )
axis image off
title('Subject T1')
axes(figH.(['slice' num2str(5)]))
imagesc( imrotate(squeeze(Yt1(:,Y,:)),90) )
axis image off
axes(figH.(['slice' num2str(6)]))
imagesc( imrotate(squeeze(Yt1(:,:,Z)),90) )
axis image off

% Bottom row: three plane view of fmri
axes(figH.(['slice' num2str(7)]))
imagesc( imrotate(squeeze(Yfmri(X,:,:)),90) )
axis image off
title('Subject fMRI')
axes(figH.(['slice' num2str(8)]))
imagesc( imrotate(squeeze(Yfmri(:,Y,:)),90) )
axis image off
axes(figH.(['slice' num2str(9)]))
imagesc( imrotate(squeeze(Yfmri(:,:,Z)),90) )
axis image off


% Print to PNG
print(gcf,'-dpng',sprintf('%s/coreg.png',out_dir))
close(pdf_figure)


