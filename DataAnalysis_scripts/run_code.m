% run
clear all
close all
addpath(genpath('/home/natasha/Programming/GitHub_clone/BacteriaSegmentationSVM/'));
addpath(genpath('/home/natasha/Programming/GitHub_clone/StitchIt/'));


sourceD = '/media/natasha/0C81DABC57F3AF06/Data/Spleen_data/20170223_D5_GFPfil/stitchedImages_100/';

% load an image which has the largest amount of objects of interest (bacteria)
red_name = [sourceD '1/section_004_01.tif']; % point to the red channel image
green_name = [sourceD '2/section_004_01.tif'];
blue_name = [sourceD '3/section_004_01.tif'];
 
[SVMModel, model_name] = InitializeYourModel(red_name, green_name, blue_name);
% 
% % model_name = '/home/natasha/Programming/Matlab_wd/Projects_Biozentrum/Segmentation/CumulativePipeline_Spleen/models/Neutrophils_model';% get full path
% % % segment the object in the entire data set
% % AllBacteriaSegmentation(sourceD,model_name,'object','neutrophil','show',1,'filter_artifacts',1,'filter3d',0,'brightness_correction',0);

model_name = '/home/natasha/Programming/GitHub_clone/BacteriaSegmentationSVM/models/20170223_D5_GFPfil';% get full path
AllBacteriaSegmentation(sourceD,model_name,'object','bacteria','show',1,...
    'filter_artifacts',1,'brightness_correction',1,...
    'number_pix_lowest',2,'number_of_images',1);

%% train a new network
segmentation_dir = '/media/natasha/0C81DABC57F3AF06/Data/Spleen_data/20170223_D5_GFPfil/Segmentation_results_bacteria_beforeCNN/SegmenatationPerSlice/';
save_dir = '/media/natasha/0C81DABC57F3AF06/Data/Spleen_data/20170223_D5_GFPfil/Segmentation_results_bacteria/Data4CNNtrain/';
thresh_red = 2000;
thresh_green = 1800;
thresh_blue = 1800;

for frame = 5
    for optical = 5
        buildBacteriaTrainingSet(sourceD,frame, optical,segmentation_dir,save_dir, [thresh_red thresh_green thresh_blue] )
    end
end


%% save pathes with bacteria
addpath(genpath('/home/natasha/Programming/GitHub_clone/DataAnalysis_scripts/'));
segmentation_dir = '/media/natasha/0C81DABC57F3AF06/Data/Spleen_data/20170223_D5_GFPfil/Segmentation_results_bacteria_beforeCNN/SegmenatationPerSlice/';
for frame = 93
    for optical = 2
%         show_segmentation_resutlsPatches(sourceD,frame,optical,segmentation_dir,0,1);
        saveSegmentedPatches(sourceD,frame,optical,segmentation_dir);
    end
end

%%

segment_dir_nuetrophil = '/media/natasha/0C81DABC57F3AF06/Data/Spleen_data/20170320_ABX7dosage_GFPfil/stitchedImages_100_brightCorrec/Segmentation_results_neutrophil/';
segment_dir_bacter = '/media/natasha/0C81DABC57F3AF06/Data/Spleen_data/20170320_ABX7dosage_GFPfil/stitchedImages_100_brightCorrec/Segmentation_results_bacteria/';


% NeutrophilAnalysis
addpath(genpath('/home/natasha/Programming/Matlab_wd/Projects_Biozentrum/Data_analysis/RingDistance3D/'));
addpath(genpath('/home/natasha/Programming/GitHub_clone/StitchIt/'));

options.RadiusSphere = 50/0.4375;%
options.RadiusSphere2 = 0;
options.method = 'Sphere';
% options.method = 'Ring';
[A,options] = DistanceAnalysisAroundPoint(segment_dir_bacter,segment_dir_nuetrophil,options);

%% visualize the model
visualizeModel(model_name,'log')