A = readtable ('./Allpositions.txt');
size (A.area, 1);
mkdir ('./Patches');

for ii = 2 :size (A.area, 1)
    i = ii-1;
    pause (1);
    Ratio =  A.SumBlue (i)/A.SumGreen (i);
       
    if Ratio > 0.2
        
        disp ('Crop small image')
        
        section = int2str(A.Optical (i,1));

        no = int2str(A.ObjectNum (i,1));
    
          frame = A.Frame (i,1);
          if frame < 10 
              counter = strcat('00',int2str(frame)); 
          elseif frame < 100 
              counter = strcat('0',int2str(frame));   
          else
              counter = int2str(frame);   
          end
    
    if (i > 1) && (A.Frame (i,1) == A.Frame ((i-1),1)) && (A.Optical (i,1) == A.Optical ((i-1),1))      
           

        x =  A.X (i, 1);
        y =  A.Y (i, 1);
    
         if x>400 && y>400 && x<(info.Width-400) && y<(info.Height-400)  %% crop bigger
           RC = imcrop(red,[x-400 y-400 800 800]);
           GC = imcrop(green,[x-400 y-400 800 800]);
           BC = imcrop(blue,x-400 y-400 800 800]);
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
    else
        
        clear red;
        clear green;
        clear blue;
        
        
        red = imread(strcat('./1/', 'section_',counter, '_0', section, '.tif'));
        info = imfinfo('./1/', 'section_',counter, '_0', section, '.tif');
        green = imread(strcat('./2/', 'section_',counter, '_0', section, '.tif'));
        blue = imread(strcat('./2/', 'section_',counter, '_0', section, '.tif'));

    end  
        
        
    elseif Ratio < 0.2 && Ratio > 0
        
        disp ('YFP events: do nothing')
    end 
    
end 

