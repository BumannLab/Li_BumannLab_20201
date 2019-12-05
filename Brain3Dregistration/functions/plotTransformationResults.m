function Options = plotTransformationResults(point_coor,B,Options)
B = round(B);
point_coor = round(point_coor);
S=settings_handler('settingsFiles_ARAtools.yml');

% load resized data before registration
mhdFile = getDownSampledMHDFile;
sampleFile = fullfile(S.downSampledDir,mhdFile);
sampleVol = mhd_read(sampleFile);

% load volume after registration
elastixDir = fullfile(S.downSampledDir,S.sample2araDir);
mhdFile = 'result.1.mhd';
sampleTransformedFile = fullfile(elastixDir,mhdFile);
sampleTransVol = mhd_read(sampleTransformedFile);
Options.registeredVolumeSize = size(sampleTransVol);

% take any slice number from the 3 column
    slice = B(round(size(B,1)/2),3);
    % before
    figure, subplot(1,2,1), imshow(imadjust(sampleVol(:,:,slice)),[])
    hold on
        IND = find(B(:,3)==slice); % vertical coordinate
        if ~isempty(IND)
            plot(B(IND,2),B(IND,1),'*r')% plot(cols, rows)
        end
    hold off
    % after
        subplot(1,2,2), imshow(imadjust(sampleTransVol(:,:,slice)),[])
    hold on
%         IND = find(point_coor(:,3)==slice); % vertical coordinate
        if ~isempty(IND)
            plot(point_coor(IND,1),point_coor(IND,2),'*r')%[cols, rows]
        end
    hold off
