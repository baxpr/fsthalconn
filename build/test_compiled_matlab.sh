#!/bin/bash

# Fix imagemagick policy to allow PDF output. See https://usn.ubuntu.com/3785-1/
sed -i 's/rights="none" pattern="PDF"/rights="read | write" pattern="PDF"/' \
/etc/ImageMagick-6/policy.xml

# Run the compiled matlab  
bash ../bin/run_spm12.sh /usr/local/MATLAB/MATLAB_Runtime/v92 function fsthalconn \
out_dir ../OUTPUTS \
subject_dir ../INPUTS/SUBJECT \
roiinfo_csv CombinedFreesurferLabels_v2_reorg.csv \
removegm_niigz ../INPUTS/filtered_removegm_noscrub_nadfmri.nii.gz \
keepgm_niigz ../INPUTS/filtered_keepgm_noscrub_nadfmri.nii.gz \
wremovegm_niigz ../INPUTS/filtered_removegm_noscrub_wadfmri.nii.gz \
wkeepgm_niigz ../INPUTS/filtered_keepgm_noscrub_wadfmri.nii.gz \
wedge_niigz ../INPUTS/redge_wgray.nii.gz \
wbrainmask_niigz ../INPUTS/rwmask.nii.gz \
wmeanfmri_niigz ../INPUTS/wmeanadfmri.nii.gz \
t1_niigz ../INPUTS/mt1.nii.gz \
wt1_niigz ../INPUTS/wmt1.nii.gz \
fwhm 6 \
project UNK_PROJ \
subject UNK_SUBJ \
session UNK_SESS \
scan UNK_SCAN \
magick_path /usr/local/bin
