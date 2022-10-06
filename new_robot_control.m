classdef new_robot_control < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure          matlab.ui.Figure
        izgradiButton     matlab.ui.control.Button
        pomaknivrhButton  matlab.ui.control.Button
        pokreniButton     matlab.ui.control.Button
        zEditField        matlab.ui.control.NumericEditField
        zEditFieldLabel   matlab.ui.control.Label
        yEditField        matlab.ui.control.NumericEditField
        yEditFieldLabel   matlab.ui.control.Label
        xEditField        matlab.ui.control.NumericEditField
        xEditFieldLabel   matlab.ui.control.Label
        angle3Knob        matlab.ui.control.Knob
        angle3KnobLabel   matlab.ui.control.Label
        angle2Knob        matlab.ui.control.Knob
        angle2KnobLabel   matlab.ui.control.Label
        angle1Knob        matlab.ui.control.Knob
        angle1KnobLabel   matlab.ui.control.Label
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: pokreniButton
        function pokreniButtonPushed(app, event)
            angle1 = app.angle1Knob.Value;
            angle2 = app.angle2Knob.Value;
            angle3 = app.angle3Knob.Value;
            
            assignin("base","angle3", angle3);
            assignin("base","angle2", angle2);
            assignin("base","angle1", angle1);

            sim("manual_angle.slx", 10);
        end

        % Button pushed function: pomaknivrhButton
        function pomaknivrhButtonPushed(app, event)
            x = app.xEditField.Value;
            y = app.yEditField.Value;
            z = app.zEditField.Value;

        
            angle1 = atan(y/x)*(180/pi)
            h = 40;
            c1 = sqrt(x*x + y*y)
            a = 200;
            b = 185;
            c = sqrt(h*h + c1*c1)

            angle = atan(c1/h)*(180/pi)

            angle2 = 180 - (acos((a*a + c*c - b*b)/(2*a*c))*(180/pi) + angle)
            angle3 = 180 - acos((a*a + b*b - c*c)/(2*a*b))*(180/pi)

            assignin("base","angle3", angle3);
            assignin("base","angle2", angle2);
            assignin("base","angle1", angle1)

            sim("manual_angle.slx", 10);
            
        end

        % Button pushed function: izgradiButton
        function izgradiButtonPushed(app, event)
            %% Get an image from camera
            camera_info = imaqhwinfo("winvideo");
            video_obj = videoinput(camera_info.AdaptorName, 1);
            video_obj.ReturnedColorSpace = "rgb";
            start(video_obj)
            figure
            img = getdata(video_obj);
            img = img(:,:,(1:3));
            imshow(img);title("Input␣image");
%             img = imread("ravnalo.jpg");
%             img = img(:,:,(1:3));
%             imshow(img);title("Input␣image");
            imwrite(img, "ravnalo.jpg");
            %% Segment an image by colors
%             red_segmented_img = segment_img(img, 0.0, 0.9, 0.9);
%             yellow_segmented_img = segment_img(img, 0.14, 0.2, 0.3);
            yellow_segmented_img = segment_img(img, 0.7, 0.9, 0.2);
            blue_segmented_img = segment_img(img, 0.5, 0.65, 0.9);
            green_segmented_img = segment_img(img, 0.25, 0.5, 0.3);
            black_segmented_img = segment_img(img, 0.5, 0.9, 0.5);
            
            %% Get centers of segmented objects
%             origin = regionprops(red_segmented_img, 'centroid');
%             origin = origin.Centroid
%             viscircles(origin,10);

            centers = zeros(3,2);
            
            center = regionprops(green_segmented_img, 'centroid');
            viscircles(center.Centroid,10);
            centers(1,2) = center.Centroid(1);
            centers(1,1) =  center.Centroid(2);
            
            center = regionprops(yellow_segmented_img, 'centroid');
            viscircles(center.Centroid,10);
            centers(2,2) = center.Centroid(1);
            centers(2,1) =  center.Centroid(2);
            
            center = regionprops(blue_segmented_img, 'centroid');
            viscircles(center.Centroid,10);
            centers(3,2) = center.Centroid(1);
            centers(3,1) =  center.Centroid(2);
            
            centers = sortrows(centers, "descend");
            
            dropoff_center = regionprops(black_segmented_img, 'centroid');
            viscircles(dropoff_center.Centroid,10);

            %% Return dropoff coordinates for every block
            for i = [1:3]
                  y = -pixel_to_mm(centers(i, 2)) + pixel_to_mm(520) %%Oduzeti pocetnu tocku
                  x = -pixel_to_mm(centers(i, 1)) + pixel_to_mm(535) %%Oduzeti pocetnu tocku
%                 y = -pixel_to_mm(centers(i, 2)) + pixel_to_mm(orgin(2)) %%Oduzeti pocetnu tocku
%                 x = -pixel_to_mm(centers(i, 1)) + pixel_to_mm(origin(1)) %%Oduzeti pocetnu tocku
            

                angle1 = atan(y/x)*(180/pi);
                h = 50;
                c1 = sqrt(x*x + y+y);
                a = 200;
                b = 185;
                c = sqrt(h*h + c1*c1);
    
                angle = atan(c1/h)*(180/pi);
                
                angle2 = 180 - (acos((a*a + c*c - b*b)/(2*a*c))*(180/pi) + angle);
                angle3 = 180 - acos((a*a + b*b - c*c)/(2*a*b))*(180/pi);
    
                assignin("base","angle3", angle3);
                assignin("base","angle2", angle2);
                assignin("base","angle1", angle1)
                
                sim("manual_angle.slx", 10);
                y = -pixel_to_mm(dropoff_center.Centroid(1)) + pixel_to_mm(520) %%Oduzeti pocetnu tocku
                x = -pixel_to_mm(dropoff_center.Centroid(2)) + pixel_to_mm(535) %%Oduzeti pocetnu tocku
            
%                 y += (2 - i) * 40
                angle1 = atan(y/x)*(180/pi);
                h = 30;
                c1 = sqrt(x*x + y+y);
                a = 200;
                b = 185;
                c = sqrt(h*h + c1*c1);
    
                angle = atan(c1/h)*(180/pi);
                
                angle2 = 180 - (acos((a*a + c*c - b*b)/(2*a*c))*(180/pi) + angle);
                angle3 = 180 - acos((a*a + b*b - c*c)/(2*a*b))*(180/pi);
    
                assignin("base","angle3", angle3);
                assignin("base","angle2", angle2);
                assignin("base","angle1", angle1)
                
                sim("manual_angle.slx", 10);
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 778 625];
            app.UIFigure.Name = 'UI Figure';

            % Create angle1KnobLabel
            app.angle1KnobLabel = uilabel(app.UIFigure);
            app.angle1KnobLabel.HorizontalAlignment = 'center';
            app.angle1KnobLabel.Position = [80.5 478 42 22];
            app.angle1KnobLabel.Text = 'angle1';

            % Create angle1Knob
            app.angle1Knob = uiknob(app.UIFigure, 'continuous');
            app.angle1Knob.Limits = [0 359];
            app.angle1Knob.Position = [70 534 60 60];

            % Create angle2KnobLabel
            app.angle2KnobLabel = uilabel(app.UIFigure);
            app.angle2KnobLabel.HorizontalAlignment = 'center';
            app.angle2KnobLabel.Position = [258.5 478 42 22];
            app.angle2KnobLabel.Text = 'angle2';

            % Create angle2Knob
            app.angle2Knob = uiknob(app.UIFigure, 'continuous');
            app.angle2Knob.Limits = [0 359];
            app.angle2Knob.Position = [249 534 60 60];

            % Create angle3KnobLabel
            app.angle3KnobLabel = uilabel(app.UIFigure);
            app.angle3KnobLabel.HorizontalAlignment = 'center';
            app.angle3KnobLabel.Position = [447.5 478 42 22];
            app.angle3KnobLabel.Text = 'angle3';

            % Create angle3Knob
            app.angle3Knob = uiknob(app.UIFigure, 'continuous');
            app.angle3Knob.Limits = [0 359];
            app.angle3Knob.Position = [438 534 60 60];

            % Create xEditFieldLabel
            app.xEditFieldLabel = uilabel(app.UIFigure);
            app.xEditFieldLabel.HorizontalAlignment = 'right';
            app.xEditFieldLabel.Position = [14 372 25 22];
            app.xEditFieldLabel.Text = 'x';

            % Create xEditField
            app.xEditField = uieditfield(app.UIFigure, 'numeric');
            app.xEditField.Position = [54 372 100 22];

            % Create yEditFieldLabel
            app.yEditFieldLabel = uilabel(app.UIFigure);
            app.yEditFieldLabel.HorizontalAlignment = 'right';
            app.yEditFieldLabel.Position = [193 372 25 22];
            app.yEditFieldLabel.Text = 'y';

            % Create yEditField
            app.yEditField = uieditfield(app.UIFigure, 'numeric');
            app.yEditField.Position = [233 372 100 22];

            % Create zEditFieldLabel
            app.zEditFieldLabel = uilabel(app.UIFigure);
            app.zEditFieldLabel.HorizontalAlignment = 'right';
            app.zEditFieldLabel.Position = [382 372 25 22];
            app.zEditFieldLabel.Text = 'z';

            % Create zEditField
            app.zEditField = uieditfield(app.UIFigure, 'numeric');
            app.zEditField.Position = [422 372 100 22];

            % Create pokreniButton
            app.pokreniButton = uibutton(app.UIFigure, 'push');
            app.pokreniButton.ButtonPushedFcn = createCallbackFcn(app, @pokreniButtonPushed, true);
            app.pokreniButton.Position = [595 553 100 22];
            app.pokreniButton.Text = 'pokreni';

            % Create pomaknivrhButton
            app.pomaknivrhButton = uibutton(app.UIFigure, 'push');
            app.pomaknivrhButton.ButtonPushedFcn = createCallbackFcn(app, @pomaknivrhButtonPushed, true);
            app.pomaknivrhButton.Position = [595 372 100 22];
            app.pomaknivrhButton.Text = 'pomakni vrh';

            % Create izgradiButton
            app.izgradiButton = uibutton(app.UIFigure, 'push');
            app.izgradiButton.ButtonPushedFcn = createCallbackFcn(app, @izgradiButtonPushed, true);
            app.izgradiButton.Position = [53 215 100 22];
            app.izgradiButton.Text = 'izgradi';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = new_robot_control

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
%% 20 pixela = 1cm = 10mm
function result = pixel_to_mm(pixel_value)
    result = pixel_value/2;
end
%% Segment image function
function segmented_img = segment_img(img, lower_bound, upper_bound, min_saturation)
    img_hsv = rgb2hsv(img);
    segmented_img = img_hsv(:,:,1) > lower_bound & img_hsv(:,:,1) < upper_bound & img_hsv(:,:,2) > min_saturation;
    segmented_img=bwareafilt(segmented_img,1);
%     figure;
%     imshow(segmented_img);
end