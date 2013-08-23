path = require('path')
_    = require('lodash')

# Main
module.exports = (grunt) ->

  # Map jade file dest: src
  mapJadeFiles = ->
    jadeFiles = grunt.file.expandMapping('**/*.jade', 'public/scripts', {
      cwd: 'development/js'
      rename: (dest, matchedSrcPath, options) ->
        withoutExt = /(.*)(\.jade)$/.exec(matchedSrcPath)[1]
        return path.join(dest, withoutExt+'.html')
    })

    jadeMap = {}
    jadeFiles.forEach (item) ->
      jadeMap[item.dest] = item.src

    return jadeMap


  getJsFiles = (fileNames) ->
    return _.filter fileNames, (name) ->
      /.+(\.js)$/.test name

  getCoffeeFiles = (fileNames) ->
    workingDir = "development/js"
    coffeeFiles = []

    fileNames.forEach (name) ->
      if grunt.file.isFile(workingDir, name)
        coffeeFiles.push(path.join(workingDir, name)) if /.+(.coffee)$/.test(name)
      else if grunt.file.isDir(workingDir, name)
        subfolderFiles = grunt.file.expand({
          cwd: path.join(workingDir, name)
        }, '**/*.coffee')
        subfolderFiles.forEach (subfolderFileName) ->
          coffeeFiles.push(path.join(workingDir, name, subfolderFileName))

    return coffeeFiles


  getConcatFileList = (fileList) ->
    workingDir = "development/tmp"
    lastFileName = "coffeeTmp.js"
    files = []
    fileList.forEach (name) ->
      if grunt.file.isFile(workingDir, name)
        files.push(path.join(workingDir, name))
    files.push(path.join(workingDir, lastFileName))
    return files


  # Project configuration.
  developmentSettings = grunt.file.readJSON('development/app.json')

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json')

    clean:
      development: ["public/scripts", "app/assets/javascripts/**/*", "development/tmp"]

    copy:
      html:
        expand: true
        cwd: 'development/js'
        src: '**/*.html'
        dest: 'public/scripts/'
      js:
        expand: true
        cwd: 'development/js'
        src: developmentSettings.js.copy
        dest: 'app/assets/javascripts'
      tmp:
        expand: true
        cwd: 'development/js'
        src: getJsFiles(developmentSettings.js.concat.src)
        dest: 'development/tmp'

    jade:
      development:
        options:
          pretty: true
        files: mapJadeFiles()

    coffee:
      development:
        options:
          join: true
        files: {
          "development/tmp/coffeeTmp.js": getCoffeeFiles(developmentSettings.js.concat.src)
        }

    concat:
      development:
        src: getConcatFileList(developmentSettings.js.concat.src)
        dest: path.join('app/assets/javascripts', developmentSettings.js.concat.dest)

    watch:
      files: ['app/assets/javascripts/**/*.jade', 'app/assets/javascripts/**/*.html']
      tasks: ['clean', 'jade', 'copy']
      options:
        spawn: false
        livereload: true
  })

  # Load the plugin that provides task(s).
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-contrib-jade')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-concat')
  grunt.loadNpmTasks('grunt-contrib-watch')

  # Default task(s).
  grunt.registerTask('default', ['clean:development',
                                 'copy:html',
                                 'copy:js',
                                 'copy:tmp',
                                 'jade:development',
                                 'coffee:development',
                                 'concat:development'])

  ###
  Dymanic change config for jade
  Watch for new files, still have issues when add file to new folder or
    folder not previouly watched
  ###
  grunt.event.on 'watch', (action, filepath) ->
    jadeMap = mapJadeFiles()
    grunt.config(['jade', 'development', 'files'], jadeMap)
