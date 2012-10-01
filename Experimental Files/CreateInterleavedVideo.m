video0 = 'Video0.avi';
video1 = 'Video1.avi';

%WMInput = int8(rand(1,30));
WMInput = [1 1 1 0 0 0 1 1 1 0 0 0 1 1 1 0 0 0 1 1 1 0 0 0 1 1 1 0 0 0 1 1 1 0 0 0 1 1 1 0 0 0 1 1 1 0 0 0 1 1 1 0 0 0 1 1 1 0 0 0 1 1 1 0 0 0 1 1 1 0 0 0];

Interleave(video0,video1,WMInput,30)