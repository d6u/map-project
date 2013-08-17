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

### 2. /public

Public folder has minor difference with a typical rails project.

* img: to store images that isn't good for asset pipeline
* scripts: to store angular template files
* bower_components: store bower components (at this time is Masonry and its RequireJS dependencies)

## Grunt settings

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