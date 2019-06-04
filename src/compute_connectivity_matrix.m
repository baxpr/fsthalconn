function compute_connectivity_matrix(out_dir,roidata_csv,filetag)

% Load ROI data from make_roimasks_and_extract.m
roidata = readtable(roidata_csv);

% Compute connectivity matrix
R = corr(table2array(roidata));
Z = atanh(R) * sqrt(size(roidata,1)-3);
roinames = roidata.Properties.VariableNames;
R = array2table(R,'VariableNames',roinames,'RowNames',roinames);
Z = array2table(Z,'VariableNames',roinames,'RowNames',roinames);
writetable(R,[out_dir '/R_' filetag '.csv'],'WriteRowNames',true);
writetable(Z,[out_dir '/Z_' filetag '.csv'],'WriteRowNames',true);
