function adj_x=findspot(nx,ny,x,data,search_size,threshold)
adj_x=zeros(length(x),2); %allocate space for new x

% xspacing=ceil((x(end,1)-x(1,1))/(2*(nx-1))); %finds half the distance between spots
% yspacing=ceil((x(end,2)-x(1,2))/(2*(ny-1)));

q=1; %initiate counter
for n=1:ny
    for m=1:nx    
        clear roi binary info temp_info

        %Does not utilized search_size and threshold
%         border(1)=x(q,1)-xspacing; %left x boundary
%         border(2)=x(q,1)+xspacing; %right x boundary
%         border(3)=x(q,2)-yspacing; %bottom y boundary
%         border(4)=x(q,2)+yspacing; %top y boundary

        %Using search_size to determine roi
        border(1)=x(q,1)-search_size; %left x boundary
        border(2)=x(q,1)+search_size; %right x boundary
        border(3)=x(q,2)-search_size; %bottom y boundary
        border(4)=x(q,2)+search_size; %top y boundary


       
        roi=data(border(3):border(4),border(1):border(2)); %get region of interest for spot

        binary=roi > mean(mean(roi)); %get binary image
        binary=imfill(binary,'holes'); %fill in spots
        info=regionprops(binary,'all'); %get info about all spots

        if(length(info)>1) %if more than one spot was found (background noise)
            spot_area=zeros(1,length(info)); %allocate space
            for i=1:length(info) %obtain area of each spot
               spot_area(i)=info(i).BoundingBox(3).*info(i).BoundingBox(4);
            end
            [val indx]=max(spot_area); %find the largest spot (true spot
            temp_info=info(indx); %replace info with just the information for the largest spot
            clear info
            info=temp_info;
        end

        %calculate new x value
        adj_x(q,:)=[ceil(info.Centroid(1)+border(1))-1 ceil(info.Centroid(2)+border(3))-1];
       
        q=q+1;
    end
end