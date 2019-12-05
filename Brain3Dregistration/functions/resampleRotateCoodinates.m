% amke a movie for new txt coordinates
%sourceD = '/media/natasha/0C81DABC57F3AF06/Data/brain/20171013_brain_MT_5wka/';

function [allTxT, B, A] = resampleRotateCoodinates(Options)

% % load new txt
A = readtable(fullfile(Options.segmentationDir,'Allpositions_filter3D.txt'));

% downsample according to the log file
S=settings_handler('settingsFiles_ARAtools.yml');
% volFname = 'dstest_25_25_02'; % sample name
downSampledTextFile = fullfile(Options.originalVolumeDir,[Options.volFname,'.txt']);

% get resolution for downsampling
fid = fopen(downSampledTextFile);
tline = fgetl(fid);
downSample = [nan,nan];
    while ischar(tline)

    if strfind(tline,'x/y: ')
        downSample(1) = str2num(tline(5:end));
    end

    if strfind(tline,'z: ')
        downSample(2) = str2num(tline(3:end));
    end

    if strcmpi('Loading and ',tline)
        break
    end
    tline = fgetl(fid);
end
fclose(fid);
% A(:,2:3) comes from regionprops - centroids
% cnetroids(:,1) - columns, centroids(:,2) - rows
B = [A.Y A.X A.Z]; % [rows, cols, z]
B(:,1:2) = B(:,1:2)./downSample(1);
B(:,3) = B(:,3)./downSample(2);
Show=1;
if Show==1
    sampleFile = fullfile(Options.originalVolumeDir,[Options.volFname,'.mhd']);
    sampleVol = mhd_read(sampleFile);
    for i = 1:3
        SliceVec = round( B([1,round(size(B,1)/2),size(B,1)],3));
        slice = SliceVec(i);
        figure, imshow(imadjust(sampleVol(:,:,slice)),[])
        hold on
            IND = find(round(B(:,3))==slice); % vertical coordinate
            if ~isempty(IND)
                plot(B(IND,2),B(IND,1),'*r')% plot(cols, rows)
            end
        hold off
        pause(1)
    end
end


% size of the downsampled volume
ImsizeBefore = Options.InitialVolumeSize(1:2)';% [cols, rows]
ImsizeBefore = [ImsizeBefore(2),ImsizeBefore(1)]';
ImsizeAfter = Options.RotatedVolumeSize(1:2)';
ImsizeAfter = [ImsizeAfter(2),ImsizeAfter(1)]';
% flip if needed
if Options.flipping==1 && ~isempty(Options.flipping)
%     B(:,1) = Options.InitialVolumeSize(1)-B(:,1)+1;
    B(:,2) = Options.InitialVolumeSize(2)-B(:,2)+1;

    B(:,3) = Options.InitialVolumeSize(3)-B(:,3)+1;
    
end
% rotate if needed
if ~isempty(Options.angle)
    angle = Options.angle;% countreclockwise rotation
%     % x y coordinates
    coord = [B(:,2),abs(B(:,1)-ImsizeBefore(2))]';% [ cols rows]
%     coord =[334,0]'
%     coord = [336,449]'
    RotM = [cosd(angle) -sind(angle);
          sind(angle)  cosd(angle)  ];
        
      % shift a rotation center to the center of an image
     coord_in = coord - ImsizeBefore/2;
     coord_out = RotM*coord_in + ImsizeAfter/2; 
     coord_out=[coord_out(1,:);abs(coord_out(2,:)-ImsizeAfter(2))];
     B = [coord_out(2,:)', coord_out(1,:)', B(:,3)];%[rows,cols]
end

if Show==1
    sampleRotFile = fullfile(S.downSampledDir,[Options.volFname,'.mhd']);
    sampleRotVol = mhd_read(sampleRotFile);
    for i = 1:3
        SliceVec = round( B([1,round(size(B,1)/2),size(B,1)],3));
        slice = SliceVec(i);
        figure,imshow(imadjust(sampleRotVol(:,:,slice)),[])
        hold on
            IND = find(round(B(:,3))==slice); % vertical coordinate
            if ~isempty(IND)
                plot(B(IND,2),B(IND,1),'*r')% plot(cols, rows)
            end
        hold off
        pause(1)
    end
end


allTxT = fullfile(Options.segmentationDir, 'SegmentationCoordinates.txt');
fileID = fopen(allTxT,'w');
fprintf(fileID,'%10.1f %10.1f %10.1f\n',B');
fclose(fileID);


