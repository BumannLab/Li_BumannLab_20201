function point_coor= applyElastixSparceVolume
% does not work
S=settings_handler('settingsFiles_ARAtools.yml');

outputDirectory = [S.downSampledDir '/sparseCoordinates/'];
transformation_name_txt = '/media/natasha/0C81DABC57F3AF06/Data/Splin_data/20170123_brainshort2/downsampled/sample2ARA/TransformParameters.1.txt';

volFname_sp = 'sparse';
volNameSliced = fullfile([S.downSampledDir '/sparseCoordinates'], [volFname_sp '.mhd']);

cmd = ['transformix -tp ' transformation_name_txt ' -out ' outputDirectory ' -in ' volNameSliced];

system(cmd);

volNameSliced = fullfile([S.downSampledDir '/sparseCoordinates'], 'result.mhd');
headerInfo=mhd_read_header(volNameSliced); 
vol_sparse = mhd_read(headerInfo);

IND=find(vol_sparse==1000);

[x,y,z] =ind2sub(size(vol_sparse),IND);
point_coor =[x,y,z];