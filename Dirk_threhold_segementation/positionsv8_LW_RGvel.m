salmonella = 0;

for frame = 1:1
   if frame < 10 
      counter = strcat('00',int2str(frame)); 
   elseif frame < 100 
      counter = strcat('0',int2str(frame));   
   else
      counter = int2str(frame);   
   end
     
   for optical = 1:5
     section = int2str(optical);
     fileName = strcat('./SalmTextPic/positions', counter, '_0', section, '.txt')
     formatSpec = '%d %d %d %f %f %f %d %f %f %f %f %f %f %f %f %f';  %% '%10d %10d %10d %10.1f %10.1f %10.1f %4d %10.1f %10.1f %10.1f %10.1f %10.2f %10.2f\n'
     sizeA = [16 Inf];
     if exist(fileName, 'file')
       fileID = fopen(fileName,'r')
       [ A, number] = fscanf(fileID,formatSpec,sizeA);
       A = A';
       fclose(fileID);
       number = number / 16;  %% count how many salm
       
       for i = 1:number
          salmonella = salmonella + 1;
          Frame ( salmonella) = A( i, 1);
          Optical ( salmonella) = A( i, 2);
          Component( salmonella)  = A( i, 3);
          x( salmonella) = A( i, 4);
          y( salmonella) = A( i, 5);
          z( salmonella) = A( i, 6);
          area( salmonella) = A( i, 7); 
          salm( salmonella) = A( i, 7) * A(i, 8) / 1000;
          Redmean( salmonella) = A( i, 9); 
          Greenmean( salmonella) = A( i, 10);
          Bluemean( salmonella) = A( i, 11);
          MajorAxisLength( salmonella) = A( i, 12);
          MinorAxisLength( salmonella) = A( i, 13);
          Eccentricity( salmonella) = A( i, 14); 
          RedVal( salmonella) = A( i, 15);
          GreenVal( salmonella) = A( i, 16); 
          
          flag( salmonella) = 0;
       end
       clear A;
     end
  end
end

 fileID = fopen('salmonella.txt','w');

for class = 1:100
   count( class) = 0;
   count_min( class) = 0;  %% Why? what is class?
end

for i = 1:salmonella
   if salm( i) < 0.5
       flag( i) = 1;
   end
 %  if y(i) > (x(i) / 0.435 * 0.546 + 8474) * 0.435
 %      flag( i) = 1;
 %  end
   for j = 1:salmonella
      if i ~= j
          xy_distance = sqrt((x(i)-x(j))^2 + (y(i)-y(j))^2);
          z_distance = abs( z(i)-z(j));
          if xy_distance < 5 && z_distance < 11  %% ?? why 11
              if salm( i) > salm( j)
                 flag( j) = 1;
                 salm( i) = salm( i) + salm( j);
              else
                 flag( i) = 1;
                 salm( j) = salm( i) + salm( j);
              end
          end
      end
   end
end

number = 0;
for i = 1:salmonella
    if flag( i) < 1
       number = number + 1;
       Frame( number) = Frame( i);
       Optical( number) = Optical( i);
       Component( number) = Component( i);
       x( number) = x( i);
       y( number) = y( i);
       z( number) = z( i);
       area( number) = area( i); 
       salm( number) = salm( i);
       Redmean( number) = Redmean( i);
       Greenmean( number) = Greenmean( i);
       Bluemean( number) = Bluemean( i);
       MajorAxisLength( number) = MajorAxisLength( i);
       MinorAxisLength( number) = MinorAxisLength( i);
       Eccentricity( number) = Eccentricity( i);
       RedVal( number) = RedVal( i);
    end
end

salmonella = number;

 for i = 1:salmonella
     fprintf(fileID,'%10d %10d %10d %10.1f %10.1f %10.1f %10.1f %10.1f %10.1f %10d %10.1f %10.1f %10.1f %10.1f %10.1f %10.1f\n', Frame(i), Optical(i), Component(i), x(i), y(i), z(i), area(i), salm(i), Redmean(i), Greenmean(i), Bluemean(i), MajorAxisLength(i), MinorAxisLength(i), Eccentricity(i),  RedVal( i), GreenVal( i));
 end
 
fclose( fileID);
% clear;