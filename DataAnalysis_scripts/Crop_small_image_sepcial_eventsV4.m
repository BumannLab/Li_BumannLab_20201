clear all;

A = readtable ('./Segmentation_results_bacteria/Allpositions_filter3D.txt');
size (A.area, 1);
mkdir ('./Patches');

info = imfinfo('./stitchedImages_100/1/section_001_01.tif');
CropCounter = 0;
CropSection = 0;
CropI = 0;

for i = 1 :size (A.area, 1)
    
    %pause (0.01);
    Ratio =  A.SumBlue (i)/A.SumGreen (i);
       
    if (Ratio > 0.16) && (Ratio < 0.75)
        
        disp (strcat('No. ', int2str(A.ObjectGlobalInd (i,1)),' is GFP? Crop small image'));
        
        optical = A.Optical (i,1);
        section = int2str(optical);

        no = int2str(A.ObjectNum (i,1));
    
          frame = A.Frame (i,1);
          if frame < 10 
              counter = strcat('00',int2str(frame)); 
          elseif frame < 100 
              counter = strcat('0',int2str(frame));   
          else
              counter = int2str(frame);   
          end
          
        if (CropI == 0) | (CropCounter ~= frame) | (CropSection ~= section)

                red = imread(strcat('./stitchedImages_100/1/', 'section_',counter, '_0', section, '.tif'));        
                green = imread(strcat('./stitchedImages_100/2/', 'section_',counter, '_0', section, '.tif'));
                blue = imread(strcat('./stitchedImages_100/3/', 'section_',counter, '_0', section, '.tif'));  

        end
    
 
        x =  A.X (i, 1);
        y =  A.Y (i, 1);
    
         if x>400 && y>400 && x<(info.Width-400) && y<(info.Height-400)  %% crop bigger
           RC = imcrop(red,[x-400 y-400 800 800]);
           GC = imcrop(green,[x-400 y-400 800 800]);
           BC = imcrop(blue,[x-400 y-400 800 800]);
           RC( 1, 1) = 2500; GC( 1, 1) = 1600; BC( 1,1) = 800;
           rgbImage = cat(3, RC,GC,BC);
       
           imwrite(rgbImage,strcat('./Patches/',counter, '_', section, '-', no,'.tif'));
  
         elseif x>200 && y>200 && x<(info.Width-200) && y<(info.Height-200)  %% crop bigger
           RC = imcrop(red,[x-200 y-200 400 400]);
           GC = imcrop(green,[x-200 y-200 400 400]);
           BC = imcrop(blue,[x-200 y-200 400 400]);
           RC( 1, 1) = 2500; GC( 1, 1) = 1600; BC( 1,1) = 800;
           rgbImage = cat(3, RC,GC,BC);
         
           imwrite(rgbImage,strcat('./Patches/',counter, '_', section, '-', no,'.tif'));
   
         else
           RC = imcrop(red,[x-50 y-50 100 100]);
           GC = imcrop(green,[x-50 y-50 100 100]);
           BC = imcrop(blue,[x-50 y-50 100 100]);
           RC( 1, 1) = 2500; GC( 1, 1) = 1600; BC( 1,1) = 800;
           rgbImage = cat(3, RC,GC,BC);
         
           imwrite(rgbImage,strcat('./Patches/',counter, '_', section, '-', no,'.tif'));
         end
    

          CropCounter = counter;
          CropSection = section;
          CropI = i;

           
        
    elseif (Ratio <= 0.16) && (Ratio > 0)
        
        disp (strcat('No. ', int2str(A.ObjectGlobalInd (i,1)),' is YFP events: do nothing'));   

        
        
    end 
    
end 

