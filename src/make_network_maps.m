function make_network_maps( ...
	out_dir, ...
	roi_label, ...
	wedge_nii, ...
	wbrainmask_nii, ...
	project, ...
	subject, ...
	session, ...
	scan ...
	)

% Load ROI connectivity map for specified ROI
map_nii = fullfile(out_dir,['sZ_' roi_label '_wremovegm.nii']);
Vmap = spm_vol(map_nii);
Ymap = spm_read_vols(Vmap);

% Load edge image from connprep
Vedge = spm_vol(wedge_nii);
Yedge = spm_read_vols(Vedge);

% Brain mask from connprep
Vmask = spm_vol(wbrainmask_nii);
Ymask = spm_read_vols(Vmask);
keeps = Ymask(:)>0;

spm_check_orientations([Vmap;Vedge;Vmask]);


% Threshold conn map at +/- 10th percentile
% Add the edge image at a weird place that will be mapped to black in
% the colormap
map = Ymap;
map(~keeps) = 0;
zmax = 0.9*max(abs(map(keeps)));
p = prctile(map(keeps),[10,90]);
map( map(:)>p(1) & map(:)<p(2) ) = 0;
map( map(:)==0   & Yedge(:)>0 ) = 0.0864*zmax/0.9;

% PDF figures

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

% Summary
set(figH.summary_text, 'String', roi_label )

% Scan info
set(figH.scan_info, 'String', sprintf( ...
	'%s, %s, %s, %s', ...
	project, subject, session, scan));
set(figH.date,'String',['Report date: ' date]);
set(figH.version,'String',['Matlab version: ' version]);

% Custom colormap:
%    1       21       41        61      81
%    cyan    blue    (black)   red     yellow
%    0 1 1   0 0 1   (0 0 0)   1 0 0   1 1 0
cmap = zeros(81,3);
cmap(1:21,2) = 1:-1/20:0;
cmap(1:21,3) = 1;
cmap(21:41,3) = 1:-1/20:0;
cmap(41:61,1) = 0:1/20:1;
cmap(61:81,2) = 0:1/20:1;
cmap(61:81,1) = 1;
cmap(40:42,:) = 1;
set(pdf_figure,'Colormap',cmap);

% Slices
ns = size(Ymap,3);
ss = round(20 : (ns-30)/9 : ns-10);
for sl = 1:9
	ax = ['slice' num2str(sl)];
	axes(figH.(ax))
	imagesc(imrotate(map(:,:,ss(sl)),90),[-zmax zmax])
	axis image off
end

% Print to PNG
print(gcf,'-dpng',sprintf('%s/connmap_%s.png',out_dir,roi_label))
close(pdf_figure)


