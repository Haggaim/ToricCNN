    function out =  captureFunctionOnTriangles(V_flat,cutMesh,f,params)


sz = getoptions(params,'sz',512);
isseg = getoptions(params,'isseg',0);

limits =  [-3,1, -3,1];
figure('visible','off', 'Position', [100, 100, 1000, 1000])
make_tiling(V_flat, cutMesh, f,isseg);
axis(limits)

axis off
colormap gray
set(gca,'units','pixels'); % set the axes units to pixels
x = get(gca,'position'); % get the position of the axes
set(gcf,'units','pixels'); % set the figure units to pixels
y = get(gcf,'position'); % get the figure position
set(gcf,'position',[y(1) y(2) x(3) x(4)]);% set the position of the figure to the length and width of the axes
set(gca,'units','normalized','position',[0 0 1 1]); % set the axes units to pixel


frame = getframe(gca);
out = imresize(frame.cdata(:,:,1),[sz sz]);
close all;
end
