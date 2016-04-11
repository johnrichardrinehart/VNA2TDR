function [tdstep, step_response, Freq, S11, rcstep, Zmr] = SParams2TDR(Freq,S11,varargin)
% [tdstep, step_response, Freq, S11, rcstep, Zmr] = SParams2TDR(Freq,S11,varargin)
% The arguments this function can take is described as follows:
% Freqs: The frequencies over which the scattering parameters were measured
% S11: The complex S11's obtained from the VNA:
%         S11 = 10.^(S11Mag/20)*exp(1i*pi*S11Phase/180)
% varargin: The next arguments can be any number of things. Concretely,
%         1) EXTENDFLAG: 0 or 1 that indicates whether on not the results need to be
%         extended down to near DC. The algorithm that performs this
%         extension performs the followingc tasks: It determines the
%         frequency spacing of the scattering parameters and uses this
%         information to create new points from the lowest acquisition
%         frequency (F_min) to as close to DC as possible without going
%         past it. Then, it grabs the magnitude and phase of the lowest
%         frequency S11 and uses that information to obtain the lower
%         frequency scattering parameters. The lower frequency scattering
%         parameters (those between DC and F_min) are the same magnitude as
%         S11(F_min) but have their phase rotated down to zero.
%
%         2) riseTime - riseTime of the time-domain raised-cosine step
%
%         3) ZPF: Argument that I will accept is a zero-padding factor. This
%         factor is a multiple of the number of points in S11. If
%         zero-padding factor (ZPF) is 1 then there will be as many zeros
%         appended to the S11 array as there are initial elements in the
%         S11 array (default: 1);
%
%         4) MR: A binary integer flag that determines whether an algorithm
%         is used that tries to account for multiple reflections.
%
%         5) PLOTS: A binary integer flag that determines if plots are to
%         be generated.
%
%     Important note: By convention, all frequency arrays are assumed NOT
%     to be symmetric about the middle value. Rather DC exists as the first
%     entry and the negative values exist at N/2 -> end. Thus, to obtain a
%     symmetric array one would need to fftshift(array) (assuming array is
%     symmetric about DC).

Zc = 50;
vf = .77; % velocity factor
v = vf*3*10^8; % speed of light in the medium in m/s

if isrow(S11)
    S11 = S11.';
end
if isrow(Freq)
    Freq = Freq.';
end

% Make sure the frequency array is valid

[Freq, S11] = SParamsOverlapFixer(Freq,S11);
%!! Sanity checks terminate

% specify the defaults before switching based on user input
zpf = 1;
EXTENDFLAG = 0;
if nargin > 2
    if varargin{1,1} == 1
        EXTENDFLAG = 1;
        [Freq, S11] = SParamsDCExtend(Freq, S11);
    elseif varargin{1,1} == 0
        warning(['If you don''t want to ex2tend down to DC then'...
            ' your results may not make a lot of sense. Continue with caution.']);
    else
        error('Your EXTENDFLAG value must be either 0 or 1.');
    end
    if nargin > 3
        try
            risetime = varargin{1,2};
            if ~isa(risetime,'double')
                warning('Your risetime isn''t a double.');
            end
        catch
            error(['I could not make the risetime variable.'...
                ' Make sure that they are in an array of doubles.']);
        end
    end
    if nargin > 4
        try
            zpf = varargin{1,3};
            if ~isa(zpf,'double')
                warning('Your zero padding factor isn''t a double.');
            end
        catch
            error(['Zero padding factor is not a number. It is of '...
                'class ' class(varargin{1,2}) '. Can not continue.']);
        end
    end
else
    warning(['There are many options you can set, optionally. You should '...
        'strongly consider using the EXTENDFLAG option.']);
end

% zero pad scattering parameters
[Freq, S11] = zeropad(Freq,S11,zpf);

% make everything double-sided
S11 = [S11; conj(flipud(S11(2:end)))]; % double-sided scattering parameters
Freq = [Freq; -flipud(Freq(2:end))]; % double-sided frequencies

% define quantities now that manipulation is done
% define a couple important values from the frequency array
deltaf = Freq(2)-Freq(1);
max_t = 1/deltaf; % see book on DSP for this step
max_f = length(Freq)*deltaf;
deltat = max_t/length(S11);

if floor(max_f/deltaf) ~= floor(max_t/deltat) ...
        && ceil(max_f/deltaf) ~= ceil(max_t/deltat)
    error('Check your frequency and S11 arrays. Something is inconsistent');
end

s11 = real(fft(S11))/length(S11);

[tdstep, rcstep, riseTimeIdx] = StepMaker(deltat, 20e-12, max_t );

%[tdstep, rcstep, riseTimeIdx] = RCStepMaker(deltat, risetime, max_t-deltat);

fdstep = fft(rcstep); % frequency-domain representation of the step pulse

if ~isreal(s11)
    warning('The ifft of your scattering parameters is not real.');
end

Step_response = S11.*fdstep; % frequency-domain rep. of the step response
step_response = fft(Step_response)/length(S11);

if nargin > 5 && varargin{1,4} == 1
    Zmr = TDRV2Z(TDRMultipleReflections(real(step_response)),1,50); % single prior reflections accounted for
    Znr = TDRV2Z(real(step_response),1,50); % no reflections accounted for
else
    Zmr = 0; % Give it some value
end

if isreal(step_response)
    disp('Your step_response is completely real, comme suppose.');
else
    warning('Your step_response is not completely real; check things.');
end

% Values useful for plotting
OOMFreq = 3*floor(log10(max(abs(Freq)))/3); % order of magnitude for frequencies
OOMtdstep = 3*(floor(log10(max(abs(tdstep)))/3)-1); % order of magnitude for time

if varargin{1,5} == 1
    % If desired, plot the results
    if EXTENDFLAG == 0
        extendstring = 'Non-extended';
    end
    if EXTENDFLAG == 1
        extendstring = 'Extended,';
    end
    if exist('userwindow','var')
        windowstring = ' windowed';
    end
    if ~exist('userwindow','var')
        windowstring = ' non-windowed';
    end
    
    % Double-sided scattering parameters
    figure;
    fig = stem(Freq*10^(-OOMFreq),20*log10(abs(S11)),'MarkerSize',.01);
    fig.BaseLine.Visible = 'off';
    title(sprintf([extendstring ...
        ' Double-sided scattering parameters over frequency']));
    xlabel(sprintf(['Frequency [10^' num2str(OOMFreq) ' Hz]']));
    ylabel(sprintf('S_{11} (dB)'));
    hold on;
    
    % Raw IFFT
    figure;
    plot(tdstep*10^(-OOMtdstep),...
        s11);title(sprintf('Raw IFFT(S11) (padded)'));
    xlabel(sprintf(['Time (10^{' num2str(OOMtdstep) '} s)']));
    ylabel(sprintf('s11(t)'));
    hold on;
    
    % Step response
    figure;
    plot(tdstep*10^(-OOMtdstep),...
        real(step_response));title(sprintf([extendstring ...
        windowstring ' step reponse.']));
    xlabel(sprintf(['Time (10^{' num2str(OOMtdstep) '} s)']));
    ylabel(sprintf('Real(stepresponse)'));
    hold on;
    
    % Incident Step pulse
    figure;
    subplot(2,1,1);plot(tdstep*10^(-OOMtdstep),...
        rcstep);title(sprintf([extendstring ...
        windowstring ' Step Pulse']));
    xlabel(sprintf(['Time (10^{' num2str(OOMtdstep) '} s)']));
    ylabel(sprintf('Step Pulse'));
    % Inset to see risetime
    containerDims = get(gca,'Position');
    insetWidth = containerDims(3)*.25;
    insetHeight = containerDims(4)*.25;
    % [left bottom width height]
    axes('Position',[containerDims(3)-.5*insetWidth,...
        containerDims(2)+insetHeight,...
        insetWidth,...
        insetHeight]);
    plot(tdstep(1:ceil(1.5*riseTimeIdx))*10^(-OOMtdstep),...
        rcstep(1:ceil(1.5*riseTimeIdx)));
    hold on;
    
    subplot(2,1,2);stem(Freq*10^(-OOMFreq),...
        10*log10(abs(fdstep)),'MarkerSize',.01);
    fig.BaseLine.Visible = 'off';
    title(sprintf(' Step Pulse (Frequency Domain)'));
    xlabel(sprintf(['Frequency [10^' num2str(OOMFreq) ' Hz]']));
    ylabel(sprintf('Step Pulse (dB)'));
    hold on;
    
    % Z(t), if multiple reflection considered
    if length(varargin) > 3
        if varargin{1,4} == 1
            figure;
            plot(tdstep*10^(-OOMtdstep),...
                Zmr,'r',tdstep*10^(-OOMtdstep),...
                Znr);title(sprintf('Z(t): Impedance Down the Line'));
            xlabel(sprintf(['Time (10^{' num2str(OOMtdstep) '} s)']));
            ylabel(sprintf('Impedance (\\Omega)'));
            legend(sprintf('Corrected'),sprintf('Uncorrected'));
            hold on;
        end
    end
end
end

function [Freq, S11] = zeropad(Freq, S11,zpf)
deltaf = Freq(2)-Freq(1);
lengthS11 = length(S11);
numzeros = floor(lengthS11*(zpf-1));
S11 = [S11; zeros(numzeros,1)]; % perform the padding
Freq = [Freq; (Freq(end)+deltaf:deltaf:(numzeros*deltaf)+Freq(end))']; % extend the frequency domain accordingly.
end