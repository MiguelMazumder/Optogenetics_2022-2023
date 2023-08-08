if isfile('default.avi')
    delete 'default.avi'
end
%goals (add more as it goes)
% - reduce pixels to correct amount on tablet (1920x1080)
% - make it so that you can do single plate or double plate (24 for now)
% - custom time slots for each well?
% - do we want to be able to turn on certain parts again? YES (i.e photomasks)
% - add red and blue light alternatives (most likely two user prompts), do
% blue separate and do red separate, then find minimal overlap requirement 
% - create JPEG inclusion for custom patterning
% NOTE: CNTRL-F and search term fix to see what needs work future
%% User input portion
pxX = 1920; pxY = 1080; % Default parameters of image resolution
[start_stop_times, well_position,row,col] = userinput_temp();%take basic user information
%%
%add red light here
%%
[well, wellDiam, xval, yval] = base_img(pxX,pxY,row,col);clear row col% setting up base image
[illuminate_overlap] = findoverlap(start_stop_times);%find overlap of time to construct pattern frames
%the first column of time_store is which unique_frame to refer to, 2nd is
%start time, and 3rd is end time, unique frames referes to the wells
[time_store,unique_frames]=create_unique_frames(illuminate_overlap,well_position);
framerate=1/60;
write_video(time_store,framerate,well,wellDiam,unique_frames,xval,yval)
clear checkboxState framerate pxX pxY start_stop_times xval yval wellDiam well_position
%% Backend functions
function [wells,wellDiam,xval,yval] = base_img(pxX,pxY,rows,cols)
    switch rows
        case 1
            leftBorder = 970;%double plate is 420 last was 330
            topBorder = 100;%last was 13
            %% 24 well plate version
            %There are 1290px across the 107mm plate area --> each px is ~83um
            %A 48 well is 10.4mm across --> should be 125px across
            %Spacing between wells is 2.6mm --> 31px
            Xedgecorr = 0; %empirically slide the image left/right %double plate at 0 last was 0
            Yedgecorr = 0; %epirically slide the image up/down %started at -130 last was 0
            wellDiam = 400; %must be divisible by 2 refer to line 173 last was 180
            wellSpace = 30; %px 30 originally %20 for 48 and 45 for 24 last was 30
        case 4
            leftBorder = 311;%double plate is 420 last was 330
            topBorder = 13;%last was 13
            %% 24 well plate version
            %There are 1290px across the 107mm plate area --> each px is ~83um
            %A 48 well is 10.4mm across --> should be 125px across
            %Spacing between wells is 2.6mm --> 31px
            Xedgecorr = 0; %empirically slide the image left/right %double plate at 0 last was 0
            Yedgecorr = 0; %epirically slide the image up/down %started at -130 last was 0
            wellDiam = 180; %must be divisible by 2 refer to line 173 last was 180
            wellSpace = 30; %px 30 originally %20 for 48 and 45 for 24 last was 30
        case 6
            leftBorder = 180;%double plate is 420 FIX SPACING FOR PLATE TYPES
            topBorder = 100;
            %% 48 well plate version
            %There are 1290px across the 107mm plate area --> each px is ~83um
            %A 48 well is 10.4mm across --> should be 125px across
            %Spacing between wells is 2.6mm --> 31px
            Xedgecorr = 95; %empirically slide the image left/right %double plate at 0 FIX SPACING FOR PLATE TYPES
            Yedgecorr = -60; %epirically slide the image up/down %started at -130 FIX SPACING FOR PLATE TYPES
            wellDiam = 124; %px 125 originally %132 for 48 FIX SPACING FOR PLATE TYPES
            wellSpace = 30; %px 30 originally %20 for 48 and 45 for 24 FIX SPACING FOR PLATE TYPES
        case 8
            leftBorder = 270;%double plate is 420 FIX SPACING FOR PLATE TYPES
            topBorder = 0;
            %% 96 well plate version
            %There are 1290px across the 107mm plate area --> each px is ~83um
            %A 48 well is 10.4mm across --> should be 125px across
            %Spacing between wells is 2.6mm --> 31px
            Xedgecorr = 95; %empirically slide the image left/right %double plate at 0 FIX SPACING FOR PLATE TYPES
            Yedgecorr = -50; %epirically slide the image up/down %started at -130 FIX SPACING FOR PLATE TYPES
            wellDiam = 70; %px 125 originally %132 for 48 FIX SPACING FOR PLATE TYPES
            wellSpace = 30; %px 30 originally %20 for 48 and 45 for 24 FIX SPACING FOR PLATE TYPES
    end
    %Mark center points of wells
    wells = zeros(pxY, pxX);%convert this to true false mask, use xy values of center points to create checkboard in that area, than apply mask boom
    yCenter = topBorder + Yedgecorr;
    for i = 1:rows%alter if we move to 24 well plate
        xCenter = leftBorder + Xedgecorr; 
        yCenter = yCenter + wellDiam + wellSpace;
        disp(yCenter);%REMOVE LATER
        for j = 1:cols%alter if we move to 24 well plate
            wells(yCenter, xCenter) = 1;
            %yCenter = yCenter + wellDiam + wellSpace;
            xCenter = xCenter + wellDiam + wellSpace+17;%FIX THIS: added a plus 17 for 24 well plate unsure if it will affect other plate types
            disp(xCenter);%REMOVE LATER
        end
    end
    %%For two plates work below
    % refer to previous 2plate code and make sure that it still matches the
    % pixel resolution pxX and pxY
    %%For two plate work above
    dists = bwdist(wells);%takes distances of zeros set up at center of wells
    wells(dists < wellDiam/2) = 1;%anything within radius
    %insert doubling and spacing here
    %remove anything between this comment and above comment if it doesn't
    %work
    [xcent,ycent]=find(dists==0);%centroids of wells
    xval=unique(xcent);yval=unique(ycent);%unique center points
end
function [illuminate_overlap] = findoverlap(start_stop_times)
    %create an extra 2 minutes at the start for a blank pattern
    start_stop_times(2:end,:)=start_stop_times(2:end,:)+start_stop_times(1,2);
    %create mxn matrix where m is the number of patterns, and n is the max number of minutes
    illuminate_overlap=zeros(size(start_stop_times,2),max(start_stop_times(:,2)));
    %create for loop going through every minute
    for i=0:size(illuminate_overlap,2)
        i_interval=i+0.5;%middle of time intervals
        for j=1:size(start_stop_times,1)
            start_time_comp=start_stop_times(j,1);
            end_time_comp=start_stop_times(j,2);
            if i_interval >= start_time_comp && i_interval <= end_time_comp
                %fprintf('row %d is in the %d to %d interval\n',j,i,i+1)
                illuminate_overlap(j,i+1)=1;%store_row(i,j)=1; but now (i+1,j) to account for start time 0
            end
        end
    end
end
function [time_store,uniqueframes]=create_unique_frames(illuminate_overlap,well_position)
    [~, unique_indices, ~] = unique(illuminate_overlap', 'rows', 'stable');
    unique_columns = illuminate_overlap(:, unique_indices);
    uniqueframes = cell(size(unique_columns,2),1);%create cell array to hold unique frames
    time_store = zeros(1,3);%3 columns, 1 for pattern, 2 for start time, 3 for end time
    for i=1:size(unique_columns,2)
        current_superimp_pattern=unique_columns(:,i);%find unique combinations of patterns
        time_slots=illuminate_overlap==current_superimp_pattern;%find which time slots it matches
        matchingIndices = find(all(time_slots));       
        %Supposed to fix skips, but guess not it works fine
        [idx, ~]=find(current_superimp_pattern);%where a is the index
        unique_frame=zeros(size(well_position(:,:,1)));
        for j=1:length(idx)
            unique_frame=unique_frame+well_position(:,:,idx(j));%maybe FIX if you have the same well selected for two different time duration, ur special but might have to fix this later
        end %just potential user error
        uniqueframes{i}=unique_frame;
        addto_time_store=[i, matchingIndices(1)-1,matchingIndices(end)];%FIX with watch for skips (line 148)
        time_store=[time_store;addto_time_store];zeroRows = all(time_store == 0, 2);time_store = time_store(~zeroRows, :);
        %time_store = sortrows(time_store,2);%sorting it based on which occurs first
    end
end
%% Write video
function [] = write_video(time_store,framerate,well,wellDiam,unique_frames,xval,yval)%going to need to add black image before and after just as precaution
    secsPerImage=(time_store(:,3)-time_store(:,2))';%time stored will also have to be the same as the blue, red, green frames
    prompt = {'Enter filename: '};
    dlgtitle = 'File Name input';
    dims = [1 35];
    definput = {'default.avi'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    writerObj = VideoWriter(char(answer));%,'Uncompressed AVI');can affect synchronization of the frames if not enough storage space
    writerObj.FrameRate = framerate;
    open(writerObj);
    for u=1:size(time_store,1)
    % convert the image to a frame
        blue_frame=create_pattern(well,wellDiam,unique_frames{u},xval,yval);%this will have to be unique_frames{u,1}
        red_frame=zeros(size(blue_frame));%change later this will have to be unique_frames{u,2}
        green_frame=zeros(size(blue_frame));%change later will have to be unique_frames{u,3} since there is no timer, its by blocks
        rgb_img=cat(3, blue_frame, blue_frame, blue_frame);rgb_img=rgb_img./255;
        frame = im2frame(rgb_img);
        for v=1:secsPerImage(u) 
            writeVideo(writerObj, frame);
        end
    end
    close(writerObj);
end
function [img]=create_pattern(well,wellDiam,current_pattern,xval,yval)
    temp=zeros(size(well));
    log_well=logical(well);
    pattern_img = evalin('base', 'images');
    for i=1:size(current_pattern,1)%loop through rows
        for j=1:size(current_pattern,2)%loop through columns
            current_cell=current_pattern(i,j);
            if nonzeros(current_cell)
                xcoor=xval(i)-wellDiam/2:xval(i)-1+wellDiam/2;ycoor=yval(j)-wellDiam/2:yval(j)-1+wellDiam/2;
                temp(xcoor,ycoor)=pattern_img{current_cell,2};%originally 1 see if this works
            end
        end
    end
    img = bsxfun(@times, temp, cast(log_well,class(temp)));
end
%%  User input functions
function [start_end_times, well_locs, row_num, col_num] = userinput_temp()
    % Determine device type
    device_choice = questdlg('Select an illumination method:', 'User Input', 'Projector (1 plate)', 'Tablet (2 plates)', 'Projector (1 plate)');
    % Determine plate type
    plate_choice = questdlg('Select a plate type:', 'User Input','1 well','24 well','48 well','1 well');
    plate_num = sscanf(plate_choice, '%d');% Convert plate type to double
    if plate_num == 24
        row_num=4;col_num = 6;wellDiam=180;assignin('base', 'wellDiam', wellDiam);%Testing refer to line 34
    elseif plate_num == 1
        row_num = 1;col_num = 1;wellDiam=400;assignin('base','wellDiam', wellDiam)%Testing
    elseif plate_num == 48
        row_num=6;col_num = 8;wellDiam=124;assignin('base', 'wellDiam', wellDiam);%Testing
    else
        row_num=8;col_num = 12;wellDiam=70;assignin('base', 'wellDiam', wellDiam);%Testing
    end
    if contains(device_choice, 'Projector')
        answer = 'start'; % Initialize answer to random string ensure while loop works
        start_end_times = [0 2]; % The first "pattern" is a black screen for 2 minutes
        well_locs = zeros(row_num, col_num); % Intializing the first pattern (no pattern) (4x6, 6x8, 8x12)
        while ~isempty(char(answer))
            prompt = {'Enter start_time,end_time (i.e 0,10) WHEN DONE LEAVE BOX EMPTY'};
            dlgtitle = 'Illumination time duration (min)';
            dims = [1 70];
            definput = {'0,10'};
            answer = inputdlg(prompt, dlgtitle, dims, definput);
            if isempty(char(answer))
                break
            end
            images=findimgs(399,wellDiam);%set up default images in folder
            mytemps(images);%get user input on pattern
            start_stop = str2double(split(string(answer), ','))';% Convert to double and split to use as double
            checkboxState = create_checkbox_figure(row_num,col_num);% Get checkbox user input
            %% TESTING
            pattern_idx=evalin('base', 'patternidx');
            checkboxState(checkboxState ~= 0) = pattern_idx;
            %% TESTING
            start_end_times = [start_end_times; start_stop];% Add start stop times of pattern to previous
            well_locs = cat(3, well_locs, checkboxState);% Add pattern to previous patterns
        end
    else
        %add code for 2 plate style
    end
    % _____ might be better to do this in seperate function to not confuse
    % too much
    %add seperate function to determine pattern for those well_locs that
    %are present in each layer of well_locs)
    %use directory to pull those jpegs or tiffs or whatever
    % _____
end
%% Function for creating user input checkbox for which well
function checkboxState = create_checkbox_figure(rows,cols)
    % Create a figure
    figure('WindowStyle', 'modal');
    % Define the dimensions of the checkbox grid
    %rows = 4;
    %cols = 6;
    switch rows
        case 1
            calibrate = 0;
        case 4
            calibrate=0.055;
        case 6
            calibrate=0.04;
        case 8
            calibrate=0.035;
    end
    % Initialize a cell array to store the checkboxes
    checkboxes = cell(rows, cols);
    % Define the size and position of each checkbox and spacing between boxes
    checkboxWidth = 0.1*4/rows;
    checkboxHeight = 0.1*4/rows;
    spacing = 0.02;%originally 0.02
    % Compute the total width and height of the checkbox grid
    totalWidth = cols * checkboxWidth + (cols - 1) * spacing;
    totalHeight = rows * checkboxHeight + (rows - 1) * spacing;
    % Compute the starting position to center the grid
    startX = (1 - totalWidth) / 2;
    startY = (1 - totalHeight) / 2;
    % Define the labels for columns
    columnLabels = cellstr(string(1:cols));
    % Define the labels for rows
    all_letters = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'};
    rowLabels = all_letters(1:rows);
    % Loop through rows and columns to create checkboxes
    for i = 1:rows
        for j = 1:cols
            % Compute the position of the checkbox
            x = startX + (j - 1) * (checkboxWidth + spacing);
            y = startY + (rows - i) * (checkboxHeight + spacing);

            % Create the checkbox and store its handle in the cell array
            checkboxes{i, j} = uicontrol('Style', 'checkbox', ...
                'Units', 'normalized', ...
                'Position', [x, y, checkboxWidth, checkboxHeight]);
        end
    end
    % Add labels for columns
    for j = 1:cols
        % Compute the position of the column label
        x = startX - calibrate + (j - 1) * (checkboxWidth + spacing) + checkboxWidth / 2;
        y = startY + rows * (checkboxHeight + spacing) + 0.01;
        % Create the column label text
        uicontrol('Style', 'text', ...
            'String', columnLabels{j}, ...
            'Units', 'normalized', ...
            'Position', [x, y, 0.04, 0.04], ...
            'HorizontalAlignment', 'center');
    end
    % Add labels for rows
    for i = 1:rows
        % Compute the position of the row label
        x = startX - 0.06;
        y = startY - 0.02 + (rows - i) * (checkboxHeight + spacing) + checkboxHeight / 2;
        % Create the row label text
        uicontrol('Style', 'text', ...
            'String', rowLabels{i}, ...
            'Units', 'normalized', ...
            'Position', [x, y, 0.04, 0.04], ...
            'HorizontalAlignment', 'center');
    end
    % Add an "Okay" button
    buttonWidth = 0.1;
    buttonHeight = 0.05;
    buttonX = (1 - buttonWidth) / 2;
    buttonY = startY - buttonHeight - 0.02;
    uicontrol('Style', 'pushbutton', ...
        'String', 'Confirm', ...
        'Units', 'normalized', ...
        'Position', [buttonX, buttonY, buttonWidth, buttonHeight], ...
        'Callback', {@saveCheckboxState, checkboxes});
    % Wait for user input to close the figure
    uiwait;
    % Access the checkbox array from the workspace
    checkboxState = evalin('base', 'checkboxState');
end
function saveCheckboxState(~, ~, checkboxes)
    % Get the dimensions of the checkbox grid
    [rows, cols] = size(checkboxes);
    % Initialize a matrix to store checkbox state
    checkboxState = zeros(rows, cols);
    % Loop through checkboxes and save their state
    for i = 1:rows
        for j = 1:cols
            % Get the state of the checkbox
            checkboxState(i, j) = get(checkboxes{i, j}, 'Value');
        end
    end
    % Display the checkbox state
    %disp(checkboxState);
    % Store the checkbox state in the base workspace
    assignin('base', 'checkboxState', checkboxState);
    % Close the figure
    close(gcf);
end
%% uicontrol figure for patterns
function mytemps(image_in)
f = figure;
a = uicontrol(f,'Style','popupmenu');
a.Position = [10 10 60 20];
a.String = image_in(:,1)';%{'Celsius','Kelvin','Fahrenheit'};
a.Callback = @selection;
b = uicontrol('Style','edit');
b.Position = [80 10 130 20];
b.Callback = @crop;
c = uicontrol('Style', 'pushbutton', 'String', 'Done', 'Position', [500 10 50 20]);
c.Callback = @closeFigure;
uiwait;%Testing
    function crop(~,~)%src,event
        input = str2double(b.String);
        %disp(input);
        welldiam = evalin('base', 'wellDiam');
        images=findimgs(input,welldiam);
        assignin('base', 'images', images);
        val = a.Value;
        imshow(images{val,2})
    end
    function selection(~,~)%src,event
        val = a.Value;
        %str = a.String;
        %index = find(strcmp(images, str{val}));
        %disp(['Selection: ' val]);
        welldiam = evalin('base', 'wellDiam');
        image_use=findimgs(400,welldiam);%400 is just the default for now, to create no crop
        assignin('base', 'images', image_use);
        imshow(image_use{val,2})
    end
    function closeFigure(~, ~)
        %update illuminate overlap
        assignin('base', 'patternidx', a.Value);
        %binary_unique_frames = evalin('base', 'unique_frames');
        %binary_unique_frames(binary_unique_frames ~= 0) = val;
        %assignin('base', 'patternidx_unique_frames', binary_unique_frames);
        close(f);
    end
end
%% rake through directory for images and crop em
function [image] = findimgs(crop_,wellDiam)
    % Specify the directory path
    % Find all JPEG and PNG files in the directory
    jpegFiles = dir('*.jpg');
    pngFiles = dir('*.png');
    % Concatenate the file lists    
    allFiles = [jpegFiles; pngFiles];
    image=cell(length(allFiles),2);
    % Loop through each file
    for i = 1:numel(allFiles)
        % Read the image
        imagePath = allFiles(i).name;
        img = imread(imagePath);
        % Get the dimensions of the image
        [height,width,~] = size(img);
        % ensure crop will affect image correctly
        % Calculate the center coordinates of the image
        centerX = min(width,height) / 2;
        centerY = min(width,height) / 2;
        % Calculate the coordinates of the box corners
        left = ceil(centerX - crop_ / 2);
        top = ceil(centerY - crop_ / 2);
        right = floor(centerX + crop_ / 2);
        bottom = floor(centerY + crop_ / 2);
        % Crop the image to the specified box shape
        % if crop size is larger than image, do not crop
        if height <= crop_ || width <= crop_ || isnan(crop_)
            crop_=min(height,width)-1;
            left = ceil(centerX - crop_ / 2);
            top = ceil(centerY - crop_ / 2);
            right = floor(centerX + crop_ / 2);
            bottom = floor(centerY + crop_ / 2);
            croppedImage = img(top:bottom, left:right);%,:);
        elseif crop_==0
            croppedImage = img;
        else
            croppedImage = img(top:bottom, left:right);%,:);
        end
        width = size(croppedImage,2);
        scalingFactor = wellDiam/width;
        resizedImage = imresize(croppedImage,scalingFactor);%resize the image to fit the size of the well diamter
        grey_img=im2gray(resizedImage);%rgb2gray(resizedImage);%greyscale the image
        %sharpen_img = imsharpen(grey_img);%sharpen constrast to avoid low resolution
        %bin_img=imbinarize(sharpen_img);
        % Display the dimensions
        %fprintf('Image: %s\n', allFiles(i).name);
        %fprintf('Dimensions: %d x %d\n', width, height);
        image{i,1}=imagePath;
        image{i,2}=grey_img;%bin_img
        %figure
        %imshow(resizedImage)
        %disp(image)
    end
end