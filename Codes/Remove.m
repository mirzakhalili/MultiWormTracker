% Code by Ehsan Mirzakhalili mirzakh@umich.edu
clf;clear;clc;close all;
List=ls;
ListSize=size(List,1);
for i=1:ListSize
    clearvars -except List ListSize i
    Name=List(i,:);
    Dot=find(Name=='.');Dot=Dot(1);
    try Name(Dot+1:Dot+3)=='avi';
        Name=Name(1:Dot-1);
        obj=VideoReader([Name,'.avi']);% Inserting name of the movie file
        N=obj.NumberOfFrames;% Number of frames in the movie
        j=1;% Starting Frame
        End=N;% Last Frame
        for j=j:End % Looping through rest of the frames
            disp(['Frame = ',num2str(j)]); % Displaying frame number
            f=read(obj,j); % Reading the next frame
            F(j).I=f;
        end
        FF=double(F(j).I)/N;
        for j=2:N
            FF=double(F(j).I)/N+FF;
        end
        %imshow(uint8(FF))
        Back=uint8(FF);
        save([Name,'Back.mat'],'Back')
    end
end
