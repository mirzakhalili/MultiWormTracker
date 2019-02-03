% Code by Ehsan Mirzakhalili mirzakh@umich.edu
clf;clear;clc;close all;
SC = get(0,'ScreenSize');% Finding size of the screen to be used later in plotting
Name='C1';
obj=VideoReader([Name,'.avi']);% Inserting name of the movie file
load([Name,'Back.mat']);
N=obj.NumberOfFrames;% Number of frames in the movie
Width=obj.width; % Finding width of the movie frame
Height=obj.height; % Finding Height of the movie frame
i=1;% Starting Frame
End=200;% Last Frame
F=60; % Size of the small frame
f=read(obj,i); % Reading the first frame
f=imabsdiff(f,Back);Z=f-f;
tempfig=imshow(imcomplement(f),'InitialMagnification',50); % Showing the first frame
NW=1;
hold on;
while ishghandle(tempfig)
    try
        [Xw(NW),Yw(NW)]=ginput(1); % Creating the frame around the worm that is going to be tracked
        plot(Xw(NW),Yw(NW),'marker','.','color',Colors(NW+1),'markersize',20);
        text(Xw(NW)-F/2,Yw(NW)+F,['Worm' num2str(NW)] ,'color',Colors(NW+1));
        NW=NW+1;
    catch
        NW=NW-1;
    end
end
Worm(NW).Left=0;
for nW=1:NW
    Worm(nW).Left=ceil(Xw(nW)-F); % Left of the small frame
    Worm(nW).Right=ceil(Xw(nW)+F); % Right of the small frame
    Worm(nW).Bottom=ceil(Yw(nW)-F); % Bottom of the the small frame
    Worm(nW).Top=ceil(Yw(nW)+F); % Top of the small frame
    Worm(nW).Center.X=Xw(nW);
    Worm(nW).Center.Y=Yw(nW);
    Worm(nW).Mask=Z;Worm(nW).Mask(Worm(nW).Bottom:Worm(nW).Top,Worm(nW).Left:Worm(nW).Right)=1;
    Worm(nW).Image=f(Worm(nW).Bottom:Worm(nW).Top,Worm(nW).Left:Worm(nW).Right); % Cropping the original frame
    Worm(nW).level = graythresh(Worm(nW).Image); % Finding the threshold to convert the grayscale image to binray image
    Worm(nW).Image=im2bw(Worm(nW).Image,Worm(nW).level); % Converting the graysclae image to binary image (black and white)
    Worm(nW).Image = imfill(Worm(nW).Image,'holes'); % Filling the holes in the binary image
    Worm(nW).Image=bwareaopen(Worm(nW).Image,200); % Removing parts of the image that are smaller than 300 pixels
    [Worm(nW).J,Worm(nW).I]=find(Worm(nW).Image); % Finding white portion of the Image (in binary image white = 1 and black = 0)
    Worm(nW).W(i).X=mean(Worm(nW).I)+Worm(nW).Left; % Saving the global position of the selected worm
    Worm(nW).W(i).Y=mean(Worm(nW).J)+Worm(nW).Bottom; % Saving the global position of the selected worm
    Worm(nW).W(i).I=Worm(nW).Image; % Saving the segmented image
end
close(figure(1));
for i=i+1:End % Looping through rest of the frames
    disp(['Frame = ',num2str(i)]); % Displaying frame number
    f=read(obj,i); % Reading the next frame
    f=imabsdiff(f,Back);
    for nW=1:NW
        if any(isnan([Worm(nW).Top,Worm(nW).Bottom,Worm(nW).Right,Worm(nW).Left]))==0
            Worm(nW).Left=ceil(Worm(nW).W(i-1).X-F);% Left of the small frame
            Worm(nW).Left=(Worm(nW).Left<1)*(1-Worm(nW).Left)+Worm(nW).Left;
            Worm(nW).Right=ceil(Worm(nW).W(i-1).X+F); % Right of the small frame
            Worm(nW).Right=(Worm(nW).Right>Width)*(Width-Worm(nW).Right)+Worm(nW).Right;
            Worm(nW).Bottom=ceil(Worm(nW).W(i-1).Y-F); % Bottom of the the small frame
            Worm(nW).Bottom=(Worm(nW).Bottom<1)*(1-Worm(nW).Bottom)+Worm(nW).Bottom;
            Worm(nW).Top=ceil(Worm(nW).W(i-1).Y+F); % Top of the small frame
            Worm(nW).Top=(Worm(nW).Top>Height)*(Height-Worm(nW).Top)+Worm(nW).Top;
            Worm(nW).Center.X=0.5*(Worm(nW).Right+Worm(nW).Left);
            Worm(nW).Center.Y=0.5*(Worm(nW).Bottom+Worm(nW).Top);
            if any(isnan([Worm(nW).Top,Worm(nW).Bottom,Worm(nW).Right,Worm(nW).Left]))==0
                Worm(nW).Mask=Z;Worm(nW).Mask(Worm(nW).Bottom:Worm(nW).Top,Worm(nW).Left:Worm(nW).Right)=1;
                Worm(nW).Image=f(Worm(nW).Bottom:Worm(nW).Top,Worm(nW).Left:Worm(nW).Right); % Cropping the original frame
                Worm(nW).level = graythresh(Worm(nW).Image); % Finding the threshold to convert the grayscale image to binray image
                Worm(nW).Image=im2bw(Worm(nW).Image,Worm(nW).level); % Converting the graysclae image to binary image (black and white)
                Worm(nW).Image = imfill(Worm(nW).Image,'holes'); % Filling the holes in the binary image
                Worm(nW).Image=bwareaopen(Worm(nW).Image,200); % Removing parts of the image that are smaller than 300 pixels
                [Worm(nW).L,Worm(nW).num] = bwlabel(Worm(nW).Image); % Finding number of disconnected objects in the image
            end
        end
    end
    figure(1);imshow(f,'InitialMagnification',50);
    Checked=zeros(NW,1);
    for nW=1:NW
        if Checked(nW)==0
            Checked(nW)=1;
            C=[];ind=0;
            if any(isnan([Worm(nW).Top,Worm(nW).Bottom,Worm(nW).Right,Worm(nW).Left]))==0
                if Worm(nW).num>1 % If there is more than one object in the image, we need to remove the extra object
                    Mask=Worm(nW).Mask;
                    for nC=1:NW
                        if nC~=nW && Checked(nC)~=1 && sqrt((Worm(nW).Center.X-Worm(nC).Center.X).^2+(Worm(nW).Center.Y-Worm(nC).Center.Y).^2)<sqrt(2)*F
                            ind=ind+1;
                            C(ind)=nC;
                            Checked(nC)=1;
                            Mask=Mask+Worm(nC).Mask;
                        end
                    end
                    Temp.Worms=[nW,C];
                    Temp.Image=f;Temp.Image(Mask<1)=0;
                    Temp.level = graythresh(Temp.Image); % Finding the threshold to convert the grayscale image to binray image
                    Temp.Image=im2bw(Temp.Image,Temp.level); % Converting the graysclae image to binary image (black and white)
                    Temp.Image = imfill(Temp.Image,'holes'); % Filling the holes in the binary image
                    Temp.Image=bwareaopen(Temp.Image,200); % Removing parts of the image that are smaller than 300 pixels
                    [Temp.L,Temp.num] = bwlabel(Temp.Image); % Finding number of disconnected objects in the image
                    JJJ=zeros(Temp.num,1);III=JJJ;
                    D=zeros(length(Temp.Worms),Temp.num);
                    for k=1:Temp.num % Looping through the extra objects
                        ImageCopy=Temp.Image; % Keeping a copy of the original image
                        ImageCopy(Temp.L~=k)=0; % Removing (making them black) all the objects other than object k
                        [JJ,II]=find(ImageCopy); % Finding coordinates of object k
                        JJJ(k)=mean(JJ); % finding center of object k
                        III(k)=mean(II); % finding center of object k
                        for kk=1:length(Temp.Worms)
                            D(kk,k)=sqrt((III(k)-Worm(Temp.Worms(kk)).Center.X).^2+(JJJ(k)-Worm(Temp.Worms(kk)).Center.Y).^2);
                        end
                    end
                    [D,indD]=sort(D,2);
                    for k=1:length(Temp.Worms)
                        for kk=1:size(D,2)
                            if indD(k,kk)~=0
                                pick=kk;
                                break;
                            end
                        end
                        ImageCopy2=Temp.Image;
                        ImageCopy2(Temp.L~=indD(k,pick))=0;
                        indD(indD==indD(k,pick))=0;
                        if sum(sum(ImageCopy2))==0
                            [D,indD]=sort(D,2);
                            pick=indD(k,1);
                            ImageCopy2=Temp.Image;
                            ImageCopy2(Temp.L~=indD(k,pick))=0;
                        end
                        Worm(Temp.Worms(k)).Image=ImageCopy2;
                        [Worm(Temp.Worms(k)).J,Worm(Temp.Worms(k)).I]=find(Worm(Temp.Worms(k)).Image);
                        Worm(Temp.Worms(k)).W(i).X=mean(Worm(Temp.Worms(k)).I); % Saving the global position of the selected worm
                        Worm(Temp.Worms(k)).W(i).Y=mean(Worm(Temp.Worms(k)).J);
%                         figure(1);rectangle('Position',[Worm(Temp.Worms(k)).W(i).X-F,Worm(Temp.Worms(k)).W(i).Y-F,2*F,2*F],'edgecolor',Colors(Temp.Worms(k)+1))
                        figure(1);hold on;plot(Worm(Temp.Worms(k)).W(i).X,Worm(Temp.Worms(k)).W(i).Y,'marker','.','color',Colors(Temp.Worms(k)+1),'markersize',20);hold off;
%                         text(Worm(Temp.Worms(k)).W(i).X-F/2,Worm(Temp.Worms(k)).W(i).Y+F,num2str(sqrt((Worm(Temp.Worms(k)).W(i).X-Worm(Temp.Worms(k)).W(i-1).X)^2+(Worm(Temp.Worms(k)).W(i).Y-Worm(Temp.Worms(k)).W(i-1).Y)^2)),'color',Colors(Temp.Worms(k)+1));
                    end
                else
                    if any(isnan([Worm(nW).Top,Worm(nW).Bottom,Worm(nW).Right,Worm(nW).Left]))==0
                        [Worm(nW).J,Worm(nW).I]=find(Worm(nW).Image); % Finding white portion of the Image (in binary image white = 1 and black = 0)
                        Worm(nW).W(i).X=mean(Worm(nW).I)+Worm(nW).Left; % Saving the global position of the selected worm
                        Worm(nW).W(i).Y=mean(Worm(nW).J)+Worm(nW).Bottom; % Saving the global position of the selected worm
                        Worm(nW).W(i).I=Worm(nW).Image; % Saving the segmented image
%                         figure(1);rectangle('Position',[Worm(nW).Left,Worm(nW).Bottom,2*F,2*F],'edgecolor',Colors(nW+1));
                        figure(1);hold on;plot(Worm(nW).W(i).X,Worm(nW).W(i).Y,'marker','.','color',Colors(nW+1),'markersize',20);hold off;
%                         text(Worm(nW).W(i).X-F/2,Worm(nW).W(i).Y+F,num2str(sqrt((Worm(nW).W(i).X-Worm(nW).W(i-1).X)^2+(Worm(nW).W(i).Y-Worm(nW).W(i-1).Y)^2)),'color',Colors(nW+1));
                        %             figure(nW+1);imshow(Worm(nW).Image);
                    end
                end
            end
        end
    end
end
Name=[Name,'Results','.mat'];save(Name,'Worm');