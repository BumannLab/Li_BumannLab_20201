function [point_coor,Options] = transformSegmentedCoordinates(Options)


% read parameters
OBJECT=returnSystemSpecificClass;
param = OBJECT.readMosaicMetaData(getTiledAcquisitionParamFile);

% collect txts to one file
[coordinate_name, B] = resampleRotateCoodinates(Options);

% transform the coordinates
point_coor = applyElastixSparceCoordinates(coordinate_name,B);

% plot the results
Options = plotTransformationResults(point_coor,B,Options);

