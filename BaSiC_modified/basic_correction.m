function basic_correction(source,varargin)
% basic_correction calculates a flatfield and darkfield images to the
% Tissue Vision data. It loads all the images in the source folder with a
% specified filter (only images of the first channel).
% The source is a folder name which should look like
% this: source = sprintf('./rawData/*_0%i.tif',thisChan);
% thisChan is a channel.
%
% The calculated images are then saved into destination folder which should
% be provided by varagin: 'destination',avDir
%
% Example
% thisChan = 1; % calculate for the first channel
% source = sprintf('./rawData/*_0%i.tif',thisChan);
% basic_correction(source,'destination',avDir);



options = cdr_parseInputs(varargin);
[pth filter ext] = fileparts(source);
pth = [pth '/**/'];

% read all the files in d
d = rdir([pth filter ext]);

% create a new field for all file names of the channel in options.
options.ALLfilenames = cell(numel(d),1);
for i = 1:numel(d)
    options.ALLfilenames{i} = d(i).name;
end

% store the number of source images into the options structure
options.ALLnum_images_provided = numel(options.ALLfilenames);

% load one image from the given channel into the memory
I = imread( options.ALLfilenames{1});
options.size = size(I);

% we need only part of available images. One should choose a number that
% allows to load into memory
% if the flatfield image has spikes and not very smooth -> increase the
% number of loaded images
% preallocate memory for loaded images
Memory_byte = options.size(1)*options.size(2)*options.ALLnum_images_provided*8/1024^3; % in Gb
memory_ram_available = 80;% in Gb

load_images = options.ALLnum_images_provided;
while Memory_byte>memory_ram_available
    load_images = floor(load_images/2);
    Memory_byte = options.size(1)*options.size(2)*load_images*8/1024^3;
end
Im_all = zeros([options.size load_images]);
% if options.ALLnum_images_provided > 10000
%     load_images = floor(options.ALLnum_images_provided/10);
% else
%     load_images = options.ALLnum_images_provided;
% end


fprintf('Loading %i images\n', size(Im_all,3));
NAMES = options.ALLfilenames;
parfor z = 1:size(Im_all,3)
       I = imread(NAMES{z});
       Im_all(:,:,z) = double(I);
end

[flatfield,darkfield] = BaSiC(Im_all,'darkfield','true');  

model.method = 'basic';
model.v = flatfield;
model.z = darkfield;
% save the correction model to the destination folder
channel = str2double(filter(end));
filename = sprintf('%s%s', options.folder_destination, ...
    sprintf('/basic_channel_%i.mat',channel));
save( filename, 'model');