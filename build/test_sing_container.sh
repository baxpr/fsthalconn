#!/bin/sh

# singularity pull shub://baxpr/fsthalconn:v2.0.3

# Binding fails with .. in paths so we move up a directory
cd ..

singularity run --cleanenv \
  --home `pwd`/INPUTS \
  --bind INPUTS:/INPUTS \
  --bind OUTPUTS:/OUTPUTS \
  --bind freesurfer_license.txt:/usr/local/freesurfer/license.txt \
  build/baxpr-fsthalconn-master-v2.0.3.simg \
  out_dir /OUTPUTS \
  subject_dir /INPUTS/SUBJECT \
  roiinfo_csv CombinedFreesurferLabels_v2_reorg.csv \
  removegm_niigz /INPUTS/filtered_removegm_noscrub_nadfmri.nii.gz \
  keepgm_niigz /INPUTS/filtered_keepgm_noscrub_nadfmri.nii.gz \
  wremovegm_niigz /INPUTS/filtered_removegm_noscrub_wadfmri.nii.gz \
  wkeepgm_niigz /INPUTS/filtered_keepgm_noscrub_wadfmri.nii.gz \
  wedge_niigz /INPUTS/redge_wgray.nii.gz \
  wbrainmask_niigz /INPUTS/rwmask.nii.gz \
  wmeanfmri_niigz /INPUTS/wmeanadfmri.nii.gz \
  t1_niigz /INPUTS/mt1.nii.gz \
  wt1_niigz /INPUTS/wmt1.nii.gz \
  fwhm 6 \
  project TEST_PROJ \
  subject TEST_SUBJ \
  session TEST_SESS \
  scan TEST_SCAN
  