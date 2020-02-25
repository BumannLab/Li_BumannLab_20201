clear all
close all
% read images
addpath(genpath('/home/natasha/Programming/Matlab_wd/Projects_Biozentrum/Segmentation/CumulativePipeline_Spleen/functions/'));
folder_source = '/media/natasha/0C81DABC57F3AF06/Data/Spleen_data/jia/';

frame = 5;
optical = 1;
  if frame < 10 
      counter = strcat('00',int2str(frame)); 
  elseif frame < 100 
      counter = strcat('0',int2str(frame));   
  else
      counter = int2str(frame);   
  end
  name = strcat('section_', counter);
  ext = '.tif';
green = imread([folder_source '2/', name, '_0',  int2str(optical), ext]);
red = imread([folder_source '1/', name, '_0',  int2str(optical), ext]);
blue = imread([folder_source '3/', name, '_0',  int2str(optical), ext]);

% read model

mod_dir = '/home/natasha/Programming/Matlab_wd/Projects_Biozentrum/Segmentation/CumulativePipeline_Spleen/models/';
load([mod_dir 'SVMModel_linear_moreData_Salm.mat']);

test= [red(:), green(:), blue(:)];
cpre = predict(SVMModel,double(test));
RED_mask = zeros(size(red));
RED_mask(cpre==20) =1;
cc = bwconncomp(RED_mask,8);
s = regionprops(cc,'basic');
centroids = cat(1, s.Centroid);

for j=1:size(centroids,1)
    bac_pixelsr = red(cc.PixelIdxList{j});
    bac_pixelsg = green(cc.PixelIdxList{j});
    bac_pixelsb = blue(cc.PixelIdxList{j});
    thr = 5000;
    num_bright_pixels = sum(bac_pixelsr>thr & bac_pixelsg>thr & bac_pixelsb>thr);
    if num_bright_pixels~=0
        if (num_bright_pixels <= length(bac_pixelsr) && num_bright_pixels >= length(bac_pixelsr)-2)

%                             img= rgb2gray(cat(3,red_pix, gr_pix, bl_pix));
%                             figure, imshow(imadjust(img))
                RED_mask(cc.PixelIdxList{j}) = 0;
        end
    end

    if sum(bac_pixelsr)> sum(bac_pixelsg) && length(cc.PixelIdxList{j})>5

%         % include bacteria in red  
%         CRshift = 5*rect(j,3);
%         red_pix = imcrop ( red_8,[rect(j,1)-CRshift, rect(j,2)-CRshift, rect(j,3)+2*CRshift,rect(j,4)+2*CRshift])  ;
%         gr_pix =zeros(size(red_pix));%imcrop ( gr_8,[rect(j,1)-CRshift, rect(j,2)-CRshift, rect(j,3)+2*CRshift,rect(j,4)+2*CRshift])  ;
%         bl_pix =  zeros(size(red_pix));%imcrop ( bl_8,[rect(j,1)-CRshift, rect(j,2)-CRshift, rect(j,3)+2*CRshift,rect(j,4)+2*CRshift])  ;
% %                             if entropy(red_pix)/(size(red_pix,1)*size(red_pix,2))*10^5>4
%             patch_mask =  zeros(size(RED_mask)); patch_mask(cc.PixelIdxList{j})=1;
%             patch_mask = imcrop ( patch_mask,[rect(j,1)-CRshift, rect(j,2)-CRshift, rect(j,3)+2*CRshift,rect(j,4)+2*CRshift])  ;
% 
%             red_area = regionGrowingBacteria(patch_mask, red_pix, gr_pix, bl_pix,1);
% %                                 length(find(red_pix>500))
% %                                 length(find(red_area==1))
%             if  length(find(red_area==1))< 300 
%                RED_mask(cc.PixelIdxList{j}) = 0;
%             end
%                             end
    elseif sum(bac_pixelsr)> sum(bac_pixelsg) && length(cc.PixelIdxList{j})<5
           RED_mask(cc.PixelIdxList{j}) = 0;
    end

    if sum(bac_pixelsb)> sum(bac_pixelsg)
        RED_mask(cc.PixelIdxList{j}) = 0; 
    end
end

% remove small objects
cc = bwconncomp(RED_mask,8); %% why 8? by Jiagui
numPixels = cellfun(@numel,cc.PixelIdxList);
idX = find(numPixels<5);
for i=1:length(idX)
    RED_mask(cc.PixelIdxList{idX(i)}) = 0;
end

% if regionGrowing == true && ~isempty(find(RED_mask,1))
    RED_mask = regionGrowingBacteria(RED_mask, red, green, blue,0);
% end

mask = RED_mask;
cc = bwconncomp(mask,8);
s = regionprops(cc,'basic');
centroids = cat(1, s.Centroid);

% convert to 8 bit
threshold = 1000;
l = red;
l(l>threshold)=threshold;
im1_8 = uint8(double(l)./double(max(l(:)))*2^8);
m=green;
m(m>threshold)=threshold;
im2_8 = uint8(double(m)./double(max(m(:)))*2^8);
n = blue;
n(n>threshold)=threshold;
im3_8 = uint8(double(n)./double(max(n(:)))*2^8);
rgbIm = cat(3, im1_8,im2_8,im3_8);
figure,imshow(rgbIm)
hold on
%                 for i = 344
plot(centroids(:,1),centroids(:,2), 'g*')
%                 i
%                 pause
%                 end
hold off

%% calcualte medians around bacteria

seOut = strel('disk',7);
seIn = strel('disk',3);
% mask_dilate = imdilate(RED_mask,se);
% PerimInitial = bwperim(mask);
% PerimDilate = bwperim(mask_dilate);
% mask = mask_dilate;
% ccDilate = bwconncomp(mask,8);
rect = round(cat(1,s.BoundingBox));
RedVal = zeros(1, cc.NumObjects);
shift = 2*max(max(rect(:,3:4)))+2;

for i=1:cc.NumObjects

            rect2 = rect(i,:);
        if shift > rect2(1) || shift > rect2(2) || rect2(1)+shift>size(red,2) || rect2(2)+shift>size(red,1)
%             shift = 2*min(rect2(3:4))-2;
%             Im = imcrop(rgbIm,[rect2(1)-shift/2 rect2(2)-shift/2 rect2(3)+shift rect2(4)+shift]);
%             seed_point = seeds(i,:)-rect2(1:2)+shift/2+1;
            shift = 0;
            maskInit = imcrop(mask,[rect2(1)-shift/2 rect2(2)-shift/2 rect2(3)+shift rect2(4)+shift]);
            redIm = imcrop(red,[rect2(1)-shift/2 rect2(2)-shift/2 rect2(3)+shift rect2(4)+shift]);
        else
            maskInit = imcrop(mask,[rect2(1)-shift/2 rect2(2)-shift/2 rect2(3)+shift rect2(4)+shift]);
            redIm = imcrop(red,[rect2(1)-shift/2 rect2(2)-shift/2 rect2(3)+shift rect2(4)+shift]);
        end            
%         figure, imshow(imadjust(redIm),[])
        
        maskDil1 = imdilate(maskInit,seIn);
        maskDil2 = imdilate(maskInit,seOut);
        Ring = abs(maskDil2 - maskDil1);
        imRing = double(redIm).*Ring;
        vecIm = imRing(imRing~=0);
        RedVal(i) = median(vecIm);
 

end
T = table((1:length(RedVal))',RedVal',repmat(3,length(RedVal),1),'VariableNames',{'Object_num','Median_Red', 'kernel_size'});
writetable(T,[folder_source 'SE_10.xls']);

