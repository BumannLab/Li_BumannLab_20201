function [Options,vol_rotate] = rotateSampleVolume(Options)

% angle=Options.angle;

% S=settings_handler('settingsFiles_ARAtools.yml');
% load initial downsampled volume of the sample data
% volFname = 'dstest_25_25_02'; % sample name
if Options.flipping==0
    downSampledVol = fullfile(Options.originalVolumeDir,[Options.volFname,'.mhd']);
    headerInfo=mhd_read_header(downSampledVol); 
    vol_data = mhd_read(headerInfo);
    Options.InitialVolumeSize = [headerInfo.Dimensions(2) headerInfo.Dimensions(1) headerInfo.Dimensions(3)];
else % load flipped data set
    downSampledVol = fullfile(Options.downSampDir,[Options.volFname,'.mhd']);
    headerInfo=mhd_read_header(downSampledVol); 
    vol_data = mhd_read(headerInfo);
end

% rotate the sample

vol_rotate = imrotate(vol_data,Options.angle);
Options.RotatedVolumeSize = size(vol_rotate);

volNameRot = fullfile(Options.downSampDir, [Options.volFname '.raw']);
mhd_write(vol_rotate,volNameRot,[1,1,1]); % permut() 2,1,3

