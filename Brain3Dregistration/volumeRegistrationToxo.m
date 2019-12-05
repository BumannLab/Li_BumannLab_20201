function volumeRegistrationToxo(data_dir,segmenation_dir,angle,flipping,channel,overwrite)
% This function registers image stack of brain to the ARA template, 
% transforms coordinates of segmented objects and localizes functional part
% of the brain in which object is localted. The code is written for Tissue
% Vision data and requires Mosaic.txt file and segmentation txt file with 
% coordinates.
% Registration pipeline uses elastix algorithm.
%
% Usage:          volumeRegistrationToxo(data_dir,segmenation_dir,angle,flipping,channel,overwrite)
%
% Input: data_dir The address of a directory that points to the image data
%                 where 'stitchedImages_100' folder located. 
%                 Inside there should be a folder with the channel, e.g. '1/'
% 
% segmenation_dir The address of a directory that points to the segmented
%                 txt files.
%
%           angle Rotation of the volume in 2D. It is often needed to 
%                 pre-align the data with the template.    
%
%        flipping Flipping of the data in 3D. It is needed for correct sample
%                 volume positioning in order to register the data to the sample.                
%
%         channel There are usually 3 channels acquired with the Tissue Vision: 
%                 red, green and blue. This parameter can specify which
%                 channel is used to register to the template. 
%                 Values - 1,2, or 3.
% Output:         
cd (data_dir);

% options and parameters
S=settings_handler('settingsFiles_ARAtools.yml');

Options.downSampDir = fullfile(data_dir,S.downSampledDir);
Options.angle = angle;
Options.flipping = flipping;
Options.originalVolumeDir = fullfile(Options.downSampDir, 'originalVolume');
Options.sample2AraDir =fullfile(Options.downSampDir, S.sample2araDir);
Options.registResult = 'result.1.mhd';
Options.segmentationDir = segmenation_dir;

% downsample in xy and oversample in z, 25 - isitropic resolution


% maKE INI FILE or copy from home directory
if ~exist('stitchitConf.ini')
	copyfile(fullfile('~','stitchitConf.ini'),data_dir);
end

% downsample to fit the brain template
if ~exist(Options.downSampDir)
    downsampleVolumeAndData(channel,25,[],[],overwrite);
else 
    disp('Downsampled data already exist. Skip this step.')
end
% find volume name
d = dir(fullfile(Options.downSampDir,'*.mhd'));
[~,volName] = fileparts(d.name);
Options.volFname =volName; % sample name

% copy initial data to originalVolume folder
if ~exist(Options.originalVolumeDir)
    mkdir(Options.originalVolumeDir);
    copyfile(fullfile(Options.downSampDir,[Options.volFname '.*']),Options.originalVolumeDir);
end

if ~isempty(flipping) || ~isempty(flipping) && overwrite  
    Options = flipSampleVolume(Options);
end
% rotate sample data and move initial data to a new folder
if ~isempty(angle) || ~isempty(angle) && overwrite
    if overwrite
        disp('Rotating the volume');
    end
    Options = rotateSampleVolume(Options);
end

% downsampled
downSampledVol = fullfile(Options.originalVolumeDir,[Options.volFname,'.mhd']);
headerInfo=mhd_read_header(downSampledVol); 
Options.InitialVolumeSize = [headerInfo.Dimensions(2) headerInfo.Dimensions(1) headerInfo.Dimensions(3)];
% rotated
volNameRot = fullfile(Options.downSampDir,[Options.volFname,'.mhd']);
headerInfo=mhd_read_header(volNameRot); 
Options.RotatedVolumeSize = [headerInfo.Dimensions(2) headerInfo.Dimensions(1) headerInfo.Dimensions(3)];


    



% register data
if overwrite || ~exist(fullfile(Options.sample2AraDir, Options.registResult))
    ARAregister;
else 
    disp('Registered data already exist. Skip this step.\n');
end
% transform segmented coordinates
[point_coor,Options] = transformSegmentedCoordinates(Options);%[cols rows z]

% remove outliers from points' coordinates
[point_coor,ParamTable] = removeOutliers(point_coor,Options);


%% data analysis

% load anotated brain data to find part names
templateFile = getARAfnames;
templateFile_annotated = [templateFile(1:end-12) 'atlas_smooth1_corrected.mhd'];
headerInfo=mhd_read_header(templateFile_annotated); 
vol_atlas_annotated = mhd_read(headerInfo);

% find ID of a brain structure
% (col, row)
ID = [];

for i = 1:length(point_coor(:,1))
    ID = [ID,vol_atlas_annotated(point_coor(i,2),point_coor(i,1),point_coor(i,3))];% vol(rows,cols,z)
end
ParamTable = addvars(ParamTable,ID','NewVariableNames','ID_brain');

if ~mkdir('data_analysis')
end

if ~isempty(ID)
    % get the name
    for level = 3:10
        % build a new IDs for specific level in the brain tree and save all
        % the paramters of the objects that belong to the specific part of
        % the brain
        [T,IDlevel] = sortNamesByMode(ID,ParamTable,level);

        [Tvol,Vol] = CalculateVolumeLevel(IDlevel,vol_atlas_annotated,level);

        Tlev = table(repmat(level,length(Vol),1),'VariableNames',{'Level'});
        T = [T Tvol Tlev];
        writetable(T,['data_analysis/' sprintf('ToxoBrainDistributionLevel_%i.xls',level)]);
        % plots
        [TidSort indSort] = sort(T.ID);
        Ratio = T.number_of_toxo./T.Volume*1000;
        figure, plot(1:length(TidSort),Ratio(indSort)), 
        ylabel ('#toxo/Vol')
        xlabel ('Braind ID')
        xticks(1:length(TidSort))
        h = num2cell(TidSort);
        xticklabels(h)
        savefig(['data_analysis/' sprintf('ToxoBrainDistributionLevel_%i.fig',level)])
        close all
    end
else
    disp('NO objects found')
end

