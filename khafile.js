let project = new Project('ZealKha');
project.addAssets('Assets/**');
project.addShaders('Shaders/**');
project.addLibrary("trilateralXtra");
project.addLibrary("trilateral");
project.addSources('src');
project.windowOptions.width = 1024;
project.windowOptions.height = 768;
resolve( project );