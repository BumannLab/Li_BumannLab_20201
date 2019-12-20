function makeMovie(source_dir,options)

Scale = options.Scale;
% num = options.num_imagepercore;
if ispc
    filsep = '\';
else
    filsep = '/';
end

startIndex = regexp(fullfile(source_dir,'.'),filsep);
Sdir = source_dir(1:startIndex(end-1));
save_dir = fullfile(Sdir, 'resized_volume4movie');
if ~exist(save_dir)
    mkdir(save_dir)
end


paramFile=getTiledAcquisitionParamFile;
param=readMetaData2Stitchit(paramFile); 

for optS =1:length(param.sample.activeChannels)
    
    channel = param.sample.activeChannels(optS);
    if ~exist(fullfile(save_dir, sprintf('%i',channel)))
        mkdir(fullfile(save_dir, sprintf('%i',channel)))
    end

    % load images per channel
    d = dir(fullfile(source_dir, sprintf('%i',channel), '*.tif'));
    imds = imageDatastore(fullfile(source_dir, sprintf('%i',channel)), 'FileExtensions', {'.tif'});

    % 
     options.ALLfilenames = cell(numel(d),1);
     for i = 1:numel(d)
         options.ALLfilenames{i} = fullfile(d(i).folder, d(i).name);
     end

    NAMES = options.ALLfilenames;
    fprintf(' Resizing %d images from channel %i\n', ...
        numel(d), channel);

     % load all the images from the given channel into the memory
     NAMES_save = cell(numel(d),1);
     for i = 1:numel(d)
         NAMES_save{i} = fullfile(save_dir, sprintf('%i',channel), d(i).name);
     end
     
    cnt = 1;
    num = options.number_of_images;
    while cnt<=numel(d)
      % load images
         if cnt+num > numel(d)
             steps = numel(d)-cnt;
         else
             steps = num;
         end
        if steps ==0
            steps = 1;
        end
        inds =  cnt:cnt+steps-1
        I = cell(1,length(inds));
        tic;
        parfor i = 1:length(inds)
            display(['Loading ', NAMES{inds(i)}]);
              im = readimage(imds,inds(i));
              I{i} = imresize(im,Scale);
        end
        disp(['Loading took ', int2str(toc), ' sec']);
        tic;
         parfor i = 1:length(inds)
%             im = imresize(I{zsave}, Scale);
            imwrite(I{i},NAMES_save{inds(i)});
         end
         disp(['Writing took ', int2str(toc), ' sec']);
         clear I
         cnt = cnt+steps;
    end
     
end

    %% Save mask images
if strcmp(options.show_mask,'show_mask')

    save_dirSegm = fullfile(save_dir, 'resized_ObjectMask'); 
    if ~exist(save_dirSegm)
        mkdir(save_dirSegm);
    end
    startIndex = regexp(fullfile(options.segment_dir,'.'),filsep);
    Segmdir = options.segment_dir(1:startIndex(end-1));
    txt_name = fullfile(Segmdir,options.positions_filetxt);
    A = readtable(txt_name);
    downSample = [Scale,1];
    fprintf('Downsample in XY by %i and in Z by %i\n',downSample(1),downSample(2));

    resampleXY = [A.X,A.Y].*downSample(1);
    resampleZ = A.Z.*downSample(2);
    resampleCoor = [resampleXY,resampleZ]; 
    illum_norm = nthroot( A.GreenMeanInten,4);

    IM =  imread(NAMES_save{1});
    [columnsInImage rowsInImage] = meshgrid(1:size(IM,2), 1:size(IM,1));

%     save_segment_high_low = options.separate_HighLow;
    d = dir(fullfile(options.segment_dir, '*.pbm'));
    options.ALLfilenames = cell(numel(d),1);
    for i = 1:numel(d)
        options.ALLfilenames{i} = fullfile(d(i).folder, d(i).name);
    end



for num = 1:numel(d) % number of images or slices
    ind = find(resampleCoor(:,3) == num);
%     if save_segment_high_low == 1
%         segment_image_bright = logical(zeros(size(IM,1), size(IM,2)));
%         segment_image_low = logical(zeros(size(IM,1), size(IM,2)));
%         if ~isempty(ind)
%             for j = 1:length(ind)
%                 centerX = resampleCoor(ind(j),1);
%                 centerY = resampleCoor(ind(j),2);
%                 radius = illum_norm(ind(j));
%                 circlePixels = (rowsInImage - centerY).^2 ...
%                     + (columnsInImage - centerX).^2 <= radius.^2;
%                 if radius > 3
%                     segment_image_bright = circlePixels+segment_image_bright;
%     %             figure, imshow(segment_image,[])
%     %             pause
%                 else
%                     segment_image_low = circlePixels+segment_image_low;
%                 end
%             end
%  
%             filename1 = [save_dirSegm 'high/' sprintf('toxo_illum_%i.tif',num)];
%             imwrite(uint16(segment_image_bright*2^16-30),filename1)
%              filename2 = [save_dirSegm 'low/' sprintf('toxo_illum_%i.tif',num)];
%             imwrite(uint16(segment_image_low*2^16-30),filename2)
% 
%         else
%             filename1 = [save_dirSegm 'high/' sprintf('toxo_illum_%i.tif',num)];
%             imwrite(uint16(segment_image_bright*2^16-30),filename1)
%              filename2 = [save_dirSegm 'low/' sprintf('toxo_illum_%i.tif',num)];
%             imwrite(uint16(segment_image_low*2^16-30),filename2)
%         end
%     else
        segment_image = zeros(size(IM,1), size(IM,2),'logical');
        if ~isempty(ind)
            for j = 1:length(ind)
                centerX = resampleCoor(ind(j),1);
                centerY = resampleCoor(ind(j),2);
                radius = illum_norm(ind(j));
                if radius == 0
                    radius = 1;
                end
                circlePixels = (rowsInImage - centerY).^2 ...
                    + (columnsInImage - centerX).^2 <= radius.^2;

                segment_image = circlePixels+segment_image;
          
            end
            
%                  figure, imshow(segment_image,[])
%                 pause
            filename = fullfile(save_dirSegm, sprintf('mask_Rillumination_%i.tif',num));
            imwrite(uint16(segment_image*2^16-30),filename);
        else 
            filename = fullfile(save_dirSegm, sprintf('mask_Rillumination_%i.tif',num));
            imwrite(uint16(segment_image*2^16-30),filename);
        end
%     end
    
end

end


