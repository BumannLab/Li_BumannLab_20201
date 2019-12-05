% make images on coordinates of bacteria
% radius corresponds to illumination
clear all
close all
% please specify volume size
image_size = [800 1531 900];

% please specify the path to salmonella.xls
read_dir = './'; % give a path to your dir
% if you want to separate into low and high illuminations put 1
save_segment_high_low = 0;

%%
save_dir = './volume_and_bacteria/segmented_bacteria/';
if ~(exist(save_dir))
    mkdir (save_dir)
end

% read xls table
tabl = xlsread([read_dir 'salmonella.xls']);
Coor = tabl(:, [1:2,9]);
Coor(:,1:2) = Coor(:,1:2)./0.435;

% to resample according to the volume size
siz = [20.619,0.3333];
Coor(:,1:2) = round(Coor(:,1:2)./siz(1));
Coor(:,3) = round(Coor(:,3)./siz(2));
illum = tabl(:,5);
illum_norm = nthroot(illum,3);

Coor_add_oversample = [];
Illum_norm = [];
for i = 1: size(Coor,1)
    z_oversamp = Coor(i,3)-floor(1/siz(2))+1:Coor(i,3);
    xyz_overs = repmat(Coor(i,1:2),length(z_oversamp),1);
    Coor_add_oversample = [Coor_add_oversample; xyz_overs,z_oversamp'];
    Illum_norm = [Illum_norm; repmat(illum_norm(i),length(z_oversamp),1)];
end



[columnsInImage rowsInImage] = meshgrid(1:image_size(1), 1:image_size(2));
save_no_blank = logical(zeros(image_size(2), image_size(1)));

for num = 1:image_size(3)%235 number of images or slices
    ind = find(Coor_add_oversample(:,3) == num);
    if save_segment_high_low == 1
        segment_image_bright = logical(zeros(image_size(2), image_size(1)));
        segment_image_low = logical(zeros(image_size(2), image_size(1)));
        if ~isempty(ind)
            for j = 1:length(ind)
                centerX = Coor_add_oversample(ind(j),1);
                centerY = Coor_add_oversample(ind(j),2);
                radius = Illum_norm(ind(j));
                circlePixels = (rowsInImage - centerY).^2 ...
                    + (columnsInImage - centerX).^2 <= radius.^2;
                if radius > 3
                    segment_image_bright = circlePixels+segment_image_bright;
    %             figure, imshow(segment_image,[])
    %             pause
                else
                    segment_image_low = circlePixels+segment_image_low;
                    max(segment_image_low(:))
                end
            end
    %         if num == 220
    %           figure, imshow(segment_image_bright,[])
    %           pause
    %         end
    %         segment_image(segment_image>1)=1;
    %         if num == 220
    %           figure, imshow(segment_image,[])
    %           pause
    %         end
            filename1 = [save_dir 'high/' sprintf('toxo_illum_%i.tif',num)];
            imwrite(uint16(segment_image_bright*2^16-30),filename1)
             filename2 = [save_dir 'low/' sprintf('toxo_illum_%i.tif',num)];
            imwrite(uint16(segment_image_low*2^16-30),filename2)
    %     slice(ind,:) = [];

        else
                filename1 = [save_dir 'high/' sprintf('toxo_illum_%i.tif',num)];
                imwrite(uint16(segment_image_bright*2^16-30),filename1)
                 filename2 = [save_dir 'low/' sprintf('toxo_illum_%i.tif',num)];
                imwrite(uint16(segment_image_low*2^16-30),filename2)
                
        end
    else
        segment_image = logical(zeros(image_size(2), image_size(1)));
        if ~isempty(ind)
            for j = 1:length(ind)
                centerX = Coor_add_oversample(ind(j),1);
                centerY = Coor_add_oversample(ind(j),2);
                radius = Illum_norm(ind(j));
                if radius == 0
                    radius = 1;
                end
                circlePixels = (rowsInImage - centerY).^2 ...
                    + (columnsInImage - centerX).^2 <= radius.^2;

                segment_image = circlePixels+segment_image;
          
            end
%                 figure, imshow(segment_image,[])
%                 pause
            filename = [save_dir sprintf('toxo_illum_%i.tif',num)];
            imwrite(uint16(segment_image*2^16-30),filename);
        else 
                filename = [save_dir sprintf('toxo_illum_%i.tif',num)];
                imwrite(uint16(segment_image*2^16-30),filename);
        end
    end
    fprintf('Image %i\n', num);
end

