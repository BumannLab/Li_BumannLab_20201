function Options =  flipSampleVolume(Options)
% take an original volume
downSampledVol = fullfile(Options.originalVolumeDir,[Options.volFname,'.mhd']);
headerInfo=mhd_read_header(downSampledVol); 
vol_data = mhd_read(headerInfo);
Options.InitialVolumeSize = [headerInfo.Dimensions(2) headerInfo.Dimensions(1) headerInfo.Dimensions(3)];


vol_data_flip = flip(vol_data,3); 
vol_data_flip = flip(vol_data_flip,2); 
volNameRot = fullfile(Options.downSampDir, [Options.volFname '.raw']);
mhd_write(vol_data_flip,volNameRot,[1,1,1]); % permut() 2,1,3