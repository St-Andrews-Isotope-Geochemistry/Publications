function Map = Expand_CMap(Colour_Matrix,Number);
    % Check colour input size
    if size(Colour_Matrix,2)==3;
        InputX = 1:size(Colour_Matrix,1);
    elseif size(Colour_Matrix,2)>3 && (any(Colour_Matrix(:,1)>1) || any(Colour_Matrix(:,1)<0)); ;
        InputX = Colour_Matrix(:,1);
        if InputX(1)>InputX(end);
            InputX = flipud(InputX);
            Colour_Matrix = flipud(Colour_Matrix);
        end
        % Check monotonic
        Diff = diff(InputX,1);
            if any(Diff>0) & any(Diff<0) | any(Diff==0);
                error('Input x values must be monotonic');
            end
        Colour_Matrix(:,1)= [];
    elseif size(Colour_Matrix,2)>3;
        warning('Assuming RGBA format');
        InputX = 1:size(Colour_Matrix,1);        
    else
        error('Input colour matrix must be an Nx3 set of RGB triplets or a Nx4 set of X values and RGB triplets');
    end    
    Xq = linspace(InputX(1),InputX(end),Number);
    
    Map(:,1) = interp1(InputX,Colour_Matrix(:,1),Xq);
    Map(:,2) = interp1(InputX,Colour_Matrix(:,2),Xq);
    Map(:,3) = interp1(InputX,Colour_Matrix(:,3),Xq);
    if size(Colour_Matrix,2)>3;
        Map(:,4) = interp1(InputX,Colour_Matrix(:,4),Xq);
    end

end