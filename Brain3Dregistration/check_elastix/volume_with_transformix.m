% transform the volume with transformix
readD = '/media/natasha/0C81DABC57F3AF06/Data/Splin_data/20170123_brainshort2/downsampled/';
volName = 'dstest_25_25_02';
SampledVol = fullfile(readD ,[volName,'.mhd']);
headerInfo=mhd_read_header(SampledVol); 
vol_data = mhd_read(headerInfo);

figure, imshow(vol_data(:,:,300))
imcontrast

%_______________

transformation_name_txt = '/media/natasha/0C81DABC57F3AF06/Data/Splin_data/20170123_brainshort2/downsampled/sample2ARA/TransformParameters.1.txt';

outputDirectory = [readD 'sparseCoordinates/'];
coordinates_name = fullfile([readD 'sparseCoordinates'], 'DownsampSparseCoordinates.txt');

cmd = ['transformix -tp ' transformation_name_txt ' -out ' outputDirectory ' -in ' SampledVol ' -def ' coordinates_name];

system(cmd);

% load the output
Vol = [outputDirectory 'result.mhd'];
headerInfo=mhd_read_header(Vol); 
vol_data_tr = mhd_read(headerInfo);

figure, imshow(vol_data_tr(:,:,310))
imcontrast