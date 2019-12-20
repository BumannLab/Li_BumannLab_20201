% moving average movie
clear all 
close all
folder_source = '/media/natasha/0C81DABC57F3AF06/Data/brain/20171013_brain_MT_2wka/volume_and_bacteria/';
FRAMES = 300;
OPTICS = 2;
%%
prefix = 'section_';
k = 1;
green = zeros(963,720,FRAMES*OPTICS,'uint16');
red = zeros(963,720,FRAMES*OPTICS,'uint16');
blue = zeros(963,720,FRAMES*OPTICS,'uint16');

for frame = 1:FRAMES
    % load images
  if frame < 10 
      counter = strcat('00',int2str(frame)); 
  elseif frame < 100 
      counter = strcat('0',int2str(frame));   
  else
      counter = int2str(frame);   
  end
  name = strcat(prefix, counter);
  
  for optical = 1:OPTICS
        imName = ['resized' name '_0' int2str(optical), '.tif'];
        green(:,:,k) = imread([folder_source 'resized_volume/1/' imName]);
        red(:,:,k) = imread([folder_source 'resized_volume/2/' imName]);
        blue(:,:,k) = imread([folder_source 'resized_volume/3/' imName]);
        
        k = k+1;
  end
  k
end

% make avarage slices
num=FRAMES*OPTICS;
slices = 2;
% save_d = '/media/natasha/0C81DABC57F3AF06/Data/brain/20171013_brain_MT_2wka/volume_and_bacteria/';
if ~exist([folder_source sprintf('resizedMeanVolume_%i',2*slices)])
    mkdir([folder_source sprintf('resizedMeanVolume_%i',2*slices)]);
    mkdir([folder_source sprintf('resizedMeanVolume_%i/1/',2*slices)]);
    mkdir([folder_source sprintf('resizedMeanVolume_%i/2/',2*slices)]);
    mkdir([folder_source sprintf('resizedMeanVolume_%i/3/',2*slices)]);
end
save_dir = [folder_source sprintf('resizedMeanVolume_%i',2*slices)];
for i = 1:num
 
    if i<=slices
        leftInd = 1;
        rightInd = slices;
        ind3 = i-leftInd+1:i+rightInd+1;
        while length(ind3)<2*slices+1
            ind3 = i-leftInd+1:i+rightInd+1;
            rightInd = rightInd+1;
        end
        rightInd = rightInd-1;
    elseif num-i<=slices
        rightInd = num-i-1;
        leftInd = slices;
        ind3 = i-leftInd+1:i+rightInd+1;
        while length(ind3)<2*slices+1
            ind3 = i-leftInd+1:i+rightInd+1;
            leftInd = leftInd+1;
        end
        leftInd = leftInd-1;
    else
        leftInd = slices;
        rightInd = slices;
    end
    
    ind3 = i-leftInd+1:i+rightInd+1;
    
    green3 = mean(green(:,:,ind3),3,'nativ');
    imName = sprintf('resizedAverage_%i.tif',i);
    imwrite(green3,[save_dir '/1/' imName]);
    red3 = mean(red(:,:,ind3),3,'nativ');
    imwrite(red3,[save_dir '/2/' imName]);
    blue3 = mean(blue(:,:,ind3),3,'nativ');
    imwrite(blue3,[save_dir '/3/' imName]);
    
    i
end


