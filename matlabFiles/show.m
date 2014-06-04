function [frame m b]=show(varargin)
% [frame m b]=show(varargin)
% Show intensity image of single_frame
% Single_frame should have 2D intensity
% data stored in the first two dimensions.
% 
% Uses:
% frame_adj=show(frame)
% Only one input: frame_adj=frame, m=1, b=0 and the displayed frame
% is not modified. If frame is double, values should be in the range 0 to 1.
% If frame is int16, values should be in the range 0 to 4095.  Values
% outside these ranges will be coerced.
% 
% frame_adj=show(frame,'adj')
% An automatic linear adjustment will be applied (mx+b; scale and shift)
% to use bit depth optimally. The adjusted frame, m, and b are returned.
% 
% frame_adj=show(frame,d)
% An automatic linear adjustment will be applied (mx+b; scale and shift)
% to ensure that d number of standard deviations will be included in the
% visible scale. If d=0, a linear adjustment will be applied to fit every
% value in the visible range.
% 
% frame_adj=show(frame,'hist')
% Shows and returns the histogram. returns frame, m=1, b=0.
% 

switch nargin %switch by number of inputs
    case 0
        error('Requires a 2D array of intensity values');
 
    case 1
        frame=double(varargin{1});
        m=1; b=0;
        
        %Check that it's 2D
        if (size(frame,3)~=1 || size(frame,4)~=1 || size(frame,5)~=1),
            %multidimentional
            if(size(frame,1)==1), %assume data is in 2nd and 3rd dimention
                frame=reshape(frame,size(frame,2),size(frame,3));
            else
                error('Frame must contain values in first two dimentions only')
            end;
        else
            frame=reshape(frame,size(frame,1),size(frame,2));
        end;
        
        %Coerce to range 0-1
        if(isa(frame,'double')),
            %coerse
            frame=frame.*(frame>0);
            frame=frame.*(frame<1)+1*(~(frame<1));
        elseif(isa(frame,'uint16')),
            frame=double(frame)/4095;
            frame=frame.*(frame>0);
            frame=frame.*(frame<1)+1*(~(frame<1));
        else
            error('Frame must be double or uint16')
        end;

        %Put into green channel
%         total=zeros(size(frame,1),size(frame,2),3);
%         total(:,:,1)=0;
%         total(:,:,2)=frame;
%         total(:,:,3)=0;
        imshow(frame);
        
    case 2
        frame=double(varargin{1});
        
        %Check that it's 2D
        if (size(frame,3)~=1 || size(frame,4)~=1 || size(frame,5)~=1),
            %multidimentional
            if(size(frame,1)==1), %assume data is in 2nd and 3rd dimention
                frame=reshape(frame,size(frame,2),size(frame,3));
            else
                error('Frame must contain values in first two dimentions only')
            end;
        else
            frame=reshape(frame,size(frame,1),size(frame,2));
        end;
        
        %Check that values are finite numbers
        if(min(min(isfinite(frame)))<1)
            [val indx]=min(isfinite(frame));
            for m=1:size(frame,2), %go through the columns
                if(val(m)<1), %is there none finite # in the column?
                    for n=1:size(frame,1),
                        if(~isfinite(frame(n,m))),
                            frame(n,m)=-1;
                        end;
                    end;
                end;
            end;
        end;
        
        %switch functionality depending on second input
        val=varargin{2};
        if(isa(val,'char')),
            if(strcmp(val,'hist')),
                %display histogram
                hist(reshape(frame,1,size(frame,1)*size(frame,2)),50);
                %return histogram
                frame=hist(reshape(frame,1,size(frame,1)*size(frame,2)),50);
                m=1; b=0;
            elseif(strcmp(val,'adj')),
                vec=double(reshape(frame,size(frame,1)*size(frame,2),1));
                span=max(vec)-min(vec);
                b=-(mean(vec)/span-0.5);
                m=1/span;
                frame=m*frame+b;
            else
                error('Second input method not recognized')
            end;
        elseif(isa(val,'double')),
            if(val>0),
                [v b] = CHECK_ifNaNInf(frame,mean(mean(frame)));
                vec=double(reshape(v,size(frame,1)*size(frame,2),1));
                
                span=2*val*std(vec);
                b=-(mean(vec)/span-0.5);
                m=1/span;
                frame=m*frame+b;
            end;
            %Put into green channel
            total=zeros(size(frame,1),size(frame,2),3);
            total(:,:,1)=0;
            total(:,:,2)=frame;
            total(:,:,3)=0;
            imshow(total);
        else
            error('Second argument must be char or double')
        end;
end;
        