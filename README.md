# Map Project

Real time map making and trip planning with friends.

## Project Dependencies

Rails 4, Redis, PostgreSQL, Node.js, CoffeeScripts, WebSocket, Google Map API, Facebook SDK

## Folder Structure

This is a Rails project, it follows folder structure of a typical rails application, with some __exception__.

### 1. /: root

Root folder contains files of a typical node.js project and grunt

* streaming.coffee: node.js app file
* Gruntfile.coffee: the gruntfile
* Procfile: foreman procfile, used to quickly start all service in development

### 2. /development

This folder to used to store javascript files in development stage. Files in this folder are later concatenated then copied into `/app/assets/javascripts/` folder to be consumed by Rails asset pipeline.

> Why use this folder: because by default Rails asset pipeline warp each coffee file content with an anonymous function, this is good behavior, but the Angular application is broke into so many pieces. Give each piece a module name is unrealistic. Instead, each piece relies on `app` global variable. Wrapper function this behavior unpredictable.

> The solution is to use 3rd party compilers. This is case, I used Grunt.js to automate this process.


### 3. /public

Public folder has minor difference with a typical rails project.

* __img__: to store images that are not good for asset pipeline
* __js__: files that need not to be edited, concatenated or compiled by Rails asset pipeline are stored here. Accept access from public, these files usually work with RequireJS and setup the stage until AngularJS bootstrap the application
* __scripts__: to store angular template files
* __bower_components__: store bower components (at this time is Masonry and its RequireJS dependencies)

## Grunt settings (TODO: need to update)

### `grunt` (default task)

The default grunt task is used in development, it will perform the following tasks by order:

1. Remove `public/scripts` folder
2. Copy angular templates `*.html` in `app/assets/javascripts` folder to `public/scripts` with the original directory structure
3. Watch for any changes from `*.html` in `app/assets/javascripts` folder, then perform the previous tasks


### `grunt development` (TODO)

1. Remove `/public/js` folder: clean up previously generate files (by grunt)
2. Covert all coffee scripts in `/app/assets/javascripts` to javascripts, then copy them to `/public/js` folder with original folder structure
3. __Insert files loading list to script loader file (TODO)__
4. Copy all `*.js` files in `/app/assets/javascripts` to `/public/js` with original folder structure
5. Watch for changes in coffee files, then perform the previous tasks

### `grunt production` (TODO)