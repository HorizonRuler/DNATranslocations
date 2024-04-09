clf
clear
clc

% Starting Settings
channels = 13;
spacing = 8;
firstChannel = 17;
prominence = 5000;
voltageStartFrame = 1947;
frameRate = 158.73;

% Initialize variables
t = tiffreadVolume('video3Middle.tif');
totalTranslocations = zeros([1 channels]);
lastThreshold = zeros([1 channels]);
TimeVec = load('TimeVec.mat').TimeVec;
TimeVec = [0 TimeVec-TimeVec(1)+(voltageStartFrame-1)/frameRate];
TimeVec = [TimeVec TimeVec(3)-TimeVec(2)+TimeVec(length(TimeVec))];
VoltVec = [0 load('VoltVec.mat').VoltVec 0];
CurrVec = [0 10^9*load('CurrVec.mat').CurrVec 0];
myWriter = VideoWriter('translocationProcessing', 'MPEG-4');
myWriter.FrameRate = frameRate;
open(myWriter);
currentTimeSlot = 1;
lineWidth = 1.5;

% Loop through all time slices
for a = 1:size(t, 3)
    % Clear figure and prepare
    clf
    f = tiledlayout('flow', 'TileSpacing','tight', 'Padding', 'compact');
    currentTime = (a - 1) / frameRate;
    title(f, sprintf("DNA Translocations at %.4f s", currentTime))
    if currentTimeSlot ~= length(TimeVec) && ...
            TimeVec(currentTimeSlot + 1) <= currentTime
        currentTimeSlot = currentTimeSlot + 1;
    end

    % Plot intensities
    nexttile
    grid on
    meanIntensity = mean(t(:, :, a), 1);
    plot(meanIntensity,'LineWidth', lineWidth)
    title("Intensity Profile")
    xlabel('Pixel Number')
    ylabel('Average Intensity (16 bit)')
    xlim([0 size(t, 2) + 1])
    ylim([0 intmax("uint16") + 1])

    % Look for prominent peaks
    pks = findpeaks(double(meanIntensity), 'MinPeakProminence', prominence);

    % Increment totalled translocations if it is peak
    for b = 1:channels
        % Only look at maximums
        if ismember(max(meanIntensity((firstChannel - spacing / 2 ...
                + spacing * b):(firstChannel - spacing / 2 ...
                + spacing * (b + 1)))), pks)
            if ~lastThreshold(b)
                totalTranslocations(b) = totalTranslocations(b) + 1; 
            end
            lastThreshold(b) = 1;
        else
            lastThreshold(b) = 0;
        end
    end

    % Plot voltage graph
    nexttile
    hold on
    if currentTimeSlot == 1
        plot([0 currentTime], [0 0], 'b', 'LineWidth', lineWidth)
    elseif currentTimeSlot == length(TimeVec)
        plot([TimeVec(length(TimeVec)) currentTime], [0 0], 'b', 'LineWidth', lineWidth)
    end
    stairs(TimeVec(1:currentTimeSlot), VoltVec(1:currentTimeSlot), 'b', 'LineWidth', lineWidth)
    title('Real Time Voltage')
    xlabel('Time (s)')
    ylabel('Voltage (V)')
    xlim([-5 (size(t, 3) - 1) / frameRate + 1])
    ylim([-5 max(VoltVec) + 1])
    
    % Plot histogram of totalled translocations
    nexttile
    bar(1:channels, totalTranslocations)
    title('Total DNA Translocations Counts')
    xlabel('Channel Number')
    ylabel('Total Translocations')

    % Plot current graph
    nexttile
    hold on
    if currentTimeSlot == 1
        plot([0 currentTime], [0 0], 'b', 'LineWidth', lineWidth)
    elseif currentTimeSlot == length(TimeVec)
        plot([TimeVec(length(TimeVec)) currentTime], [0 0], 'b', 'LineWidth', lineWidth)
    end
    stairs(TimeVec(1:currentTimeSlot), CurrVec(1:currentTimeSlot), 'b', 'LineWidth', lineWidth)
    title('Real Time Current')
    xlabel('Time (s)')
    ylabel('Current (nA)')
    xlim([-5 (size(t, 3) - 1) / frameRate + 1])
    ylim([-10 max(CurrVec) + 1])

    % Save frame
    exportgraphics(gcf, "temp.jpg")
    writeVideo(myWriter, im2uint8(imread("temp.jpg")));
end

close(myWriter); 