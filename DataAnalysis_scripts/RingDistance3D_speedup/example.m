clear all
close all
segment_dir_nuetrophil = '/media/natasha/0C81DABC57F3AF06/Data/Spleen_data/20170223_D5_GFPfil/stitchedImages_100/Segmentation_results_neutrophil/';
segment_dir_bacter = '/media/natasha/0C81DABC57F3AF06/Data/Spleen_data/20170223_D5_GFPfil/stitchedImages_100/Segmentation_results_bacteria/';


% NeutrophilAnalysis
addpath(genpath('/home/natasha/Programming/Matlab_wd/Projects_Biozentrum/Data_analysis/RingDistance3D_speedup/'));
addpath(genpath('/home/natasha/Programming/GitHub_clone/StitchIt/'));

options.RadiusSphere = 50/0.4375;%
% options.RadiusSphere = 100/0.4375;%
% options.RadiusSphere = 200/0.4375;%

options.RadiusSphere2 = 0;
options.method = 'Sphere';
% options.method = 'Ring';
[A,options] = DistanceAnalysisAroundPoint(segment_dir_bacter,segment_dir_nuetrophil,options);

[A,options] = DistanceAnalysisAroundPoint(segment_dir_bacter,segment_dir_bacter,options);



