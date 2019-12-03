function experiment = example (~)
source_dir = './'; % here you need to have rawData directory with all your data and a Mosaic.txt


addpath(genpath('/home/lijiag/Programming/GitHub_clone'));

% add path of the StitchIt(https://github.com/BaselLaserMouse/StitchIt).

%addpath(genpath('FULL_PATH/StitchIt_cidre/')); % add path of the CIDRE(https://github.com/Fouga/cidre) 

cd (source_dir);

% maKE INI FILE
if ~exist('./stitchitConf.ini')
	makeLocalStitchItConf
    
end

% read info from Mosaic.txt 
M=readMetaData2Stitchit;
%generateTileIndex;


%% check for and fix missing tiles if this was a TissueCyte acquisition
if strcmp(M.System.type,'TissueCyte')
    writeBlacktile = 0;  %% 0, means will replace the missing tile with tiles just right up or down optical layer; 1, means will replace with black tile  
    missingTiles=identifyMissingTilesInDir('rawData',0,0,[],writeBlacktile);
else
    missingTiles = -1;
end


%% correct background illumination with cidre; if no need to do any illumination correction, this line should not be run.
 alternativeIlluminationCorrection


%% stitch all the data
stitchAllChannels

%% segmentation

%% step 1 optional, build a new model.
%% load an image which has the largest amount of objects of interest (bacteria)
% 
% red_name = fullfile(source_dir, 'stitchedImages_100/2/section_087_01.tif'); % point to the red channel image
% green_name = fullfile(source_dir, 'stitchedImages_100/1/section_087_01.tif');
% blue_name = fullfile(source_dir, 'stitchedImages_100/3/section_087_01.tif');
%  
% [SVMModel, model_name] = InitializeYourModel(red_name, green_name, blue_name);
%   
% %% step 2 Segmentation for the entire dataset with SVM.
% model_name = [segmentCodedir 'models/20171013_brain_WT_5wka_model'];   
% AllBacteriaSegmentation(fullfile(source_dir, 'stitchedImages_100'),model_name,...
%      'show',1,'filter_artifacts',1,'number_pix_lowest',5,'red',2,'green',1,'number_of_images',30,'filter_cnn',0);  
% %% 'number_of_images', how many images are going to be load into the ram at the same time. what is 'number of images'? 'filter_cnn' means whether apply conventional neunon network on the results from SVM (1) or not (0)


 
 
 
 
 