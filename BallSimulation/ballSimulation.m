% Starting Settings
simulationSize = 20;
channels = 11;
iterations = 200;
ballsPerSecond = 11;
m = 6;
standardDeviation = 2;
speed = 1;

% Initialize variables
ballPositions = zeros([iterations*ballsPerSecond 2]);
movieVector = struct('cdata', cell(1, iterations),'colormap', cell(1,iterations));
spacing = simulationSize/(channels - 1);
currentEnd = 0;
currentStart = 1;
fig = figure('position',[100 100 850 600]);

% Loop throught the time steps
for a = 1:iterations
    % Clear figure and restylize
    clf
    subplot(2, 1, 1)
    grid on
    hold on
    title("Ball Simulation")
    axis([-1 simulationSize+1 0 simulationSize]);

    % Generate 5 background black channels
    for b = 0:spacing:simulationSize
        rectangle('Position', [b-.5 0 1 simulationSize], 'EdgeColor', 'b')
    end

    % Randomly generate 3 new balls in channels
    randomSequence = min(max(round(m - 1 + standardDeviation * randn(ballsPerSecond, 1)), 0), channels - 1);
    for b = 1:ballsPerSecond
        ballPositions(currentEnd + b, :) = [-.5+spacing*randomSequence(b) 0];
    end
    currentEnd = currentEnd + ballsPerSecond;

    % Shift existing balls up by speed
    for b = currentStart:(currentEnd - ballsPerSecond)
        ballPositions(b, 2) = ballPositions(b, 2) + speed;
        % Pop out balls that passed all the way though
        if (ballPositions(b, 2) > simulationSize - 1)
            currentStart = currentStart + 1;
        end
    end

    % Plot balls
    for b = currentStart:currentEnd
        rectangle('Position', [ballPositions(b, 1) ballPositions(b, 2) 1 1], 'FaceColor', 'y', 'Curvature', 1, 'EdgeColor', 'black')
    end

    % Plot histogram of ball distribution
    subplot(2, 1, 2)
    histogram(categorical(ballPositions(1:currentEnd, 1)), 'BarWidth', 1 / spacing)
    xticklabels(1:channels)

    % Save frame
    movieVector(a) = getframe(fig);
end

% Save to video
myWriter = VideoWriter('channelSimulation', 'MPEG-4');
myWriter.FrameRate = 5;
open(myWriter);
writeVideo(myWriter, movieVector);
close(myWriter);