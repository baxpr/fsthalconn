#!/bin/sh

# singularity pull shub://baxpr/connprep:v2.1.0

# Binding fails with .. in paths so we move up a directory
cd ..

singularity run --cleanenv \
  --home `pwd`/INPUTS \
  --bind INPUTS:/INPUTS \
  --bind OUTPUTS:/OUTPUTS \
  build/baxpr-connprep-master-v2.1.0.simg \
  num_initial_vols_to_drop 0 \
  num_vols_to_analyze all \
  bandpasslo_hz 0.01 \
  bandpasshi_hz 0.10 \
  mot_PCs 6 \
  motderiv_PCs 6 \
  wmcsf_PCs 6 \
  slorder none \
  fmri_niigz /INPUTS/fmri.nii.gz \
  mt1_niigz /INPUTS/mt1.nii.gz \
  deffwd_niigz /INPUTS/y_t1.nii.gz \
  gray_niigz /INPUTS/p1t1.nii.gz \
  white_niigz /INPUTS/p2t1.nii.gz \
  csf_niigz /INPUTS/p3t1.nii.gz \
  project PROJ_LABEL \
  subject SUBJ_LABEL \
  session SESS_LABEL \
  scan SCAN_LABEL \
  out_dir /OUTPUTS
  