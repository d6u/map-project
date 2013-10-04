path = require('path')
_    = require('lodash')
require('js-yaml')


# Main
module.exports = (grunt) ->

  # Helpers to map files
  compileHelper = {
    # pathList (array)
    # fileExt (string): must contain `.`
    getFileListFromPathList: (wd, pathList, fileExt) ->
      fileList = []
      for pt in pathList
        # file
        if grunt.file.isFile(wd, pt) && (new RegExp(".+(\\#{fileExt})$")).test(pt)
          fileList.push(pt)
        # dir
        else
          for subPt in grunt.file.expand({cwd: path.join(wd, pt)}, "**/*#{fileExt}")
            fileList.push(path.join(pt, subPt))
      return fileList


    getAllJsFileList: (concatMap, cwd) ->
      fileList = []
      for dist, src of concatMap
        fileList = if _.isArray(src) then fileList.concat(@getFileListFromPathList(cwd, src, '.js')) else fileList.concat(@getFileListFromPathList(cwd, [src], '.js'))
      return fileList

    getCoffeeFileList: (pathArray, cwd) ->
      fileList = []
      for pt in pathArray
        if grunt.file.isFile(cwd, pt)
          if /.+(\.coffee)$/.test(pt)
            fileList.push(path.join(cwd, pt))
        else
          for subPt in grunt.file.expand({cwd: path.join(cwd, pt)}, '**/*.coffee')
            fileList.push(path.join(cwd, pt, subPt))

      return fileList

    getConcatTaskFileList: (pathArray, lastFilePath) ->
      cwd = 'tmp/grunt/js'
      fileList = []
      for pt in @getFileListFromPathList(cwd, pathArray, '.js')
        fileList.push(path.join(cwd, pt))
      fileList.push(path.join(cwd, lastFilePath))
      return fileList
  }


  # Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json')
    compileSettings: require('./development/app.yaml')

    # --- Clean ---
    clean:
      angular_templates: ["public/scripts"]
      rails_pipeline_js: ["app/assets/javascripts/modules/**/*"]
      temp_files_js:     ["tmp/grunt"]

    # --- Copy ---
    copy:
      html:
        expand: true
        cwd:  '<%= compileSettings["html"]["source folder"] %>'
        src:  '**/*.html'
        dest: '<%= compileSettings["html"]["target folder"] %>'
      js:
        expand: true
        cwd:  '<%= compileSettings["js"]["source folder"] %>'
        src:  '<%= compileSettings.js.copy %>'
        dest: '<%= compileSettings["js"]["target folder"] %>'
      # concat_js task settings will be update dynamically
      concat_js:
        expand: true
        cwd:  '<%= compileSettings["js"]["source folder"] %>'
        src:  ''
        dest: 'tmp/grunt/js'

    # --- Jade ---
    jade:
      angular_templates:
        files: [{
          expand: true
          cwd:  '<%= compileSettings["html"]["source folder"] %>'
          src:  '**/*.jade'
          dest: '<%= compileSettings["html"]["target folder"] %>'
          ext:  '.html'
        }]

    # --- Slim ---
    slim:
      angular_templates:
        files: [{
          expand: true
          cwd:  '<%= compileSettings["html"]["source folder"] %>'
          src:  '**/*.slim'
          dest: '<%= compileSettings["html"]["target folder"] %>'
          ext:  '.html'
        }]

    # --- Coffee ---
    coffee:
      options:
        join: true
      # development task settings will be update dynamically
      development:
        files: []

    # --- Concat ---
    concat:
      options:
        separator: ';'
      # js task settings will be update dynamically
      js:
        files: []

    # --- Watch ---
    watch:
      options:
        spawn: false
        livereload: true
      html:
        files: ['<%= compileSettings["html"]["source folder"] %>' + '/**/*.html']
        tasks: ['copy:html']
      jade:
        files: ['<%= compileSettings["html"]["source folder"] %>' + '/**/*.jade']
        tasks: ['jade:angular_templates']
      slim:
        files: ['<%= compileSettings.js["source folder"] %>' + '/**/*.slim']
        tasks: ['slim:angular_templates']
      js:
        files: ['<%= compileSettings.js["source folder"] %>' + '/**/*.js']
        tasks: [
          'copy:js'
          'update config:copy:concat_js'
          'copy:concat_js'
          'update config:concat:js'
          'concat:js'
        ]
      coffee:
        files: ['<%= compileSettings.js["source folder"] %>' + '/**/*.coffee']
        tasks: [
          'update config:coffee:development'
          'coffee:development'
          'update config:concat:js'
          'concat:js'
        ]
  })

  # Load the plugin that provides task(s).
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-contrib-jade')
  grunt.loadNpmTasks('grunt-slim')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-concat')
  grunt.loadNpmTasks('grunt-contrib-watch')


  # Dynamic task config
  # --- copy:concat_js ---
  grunt.registerTask 'update config:copy:concat_js', 'Dymanic update grunt config for copy:concat_js', ->

    compileSettings = grunt.config(['compileSettings'])
    # copy:concat_js
    copyList = compileHelper.getAllJsFileList(compileSettings.js.concat, compileSettings.js["source folder"])
    grunt.config(['copy', 'concat_js', 'src'], copyList)


  # --- coffee:development ---
  grunt.registerTask 'update config:coffee:development', 'Dymanic update grunt config for coffee:development', ->

    compileSettings = grunt.config(['compileSettings'])
    # coffee:development
    filesObj = {}
    for dest, src of compileSettings.js.concat
      filesObj[path.join('tmp/grunt/js', dest)] = compileHelper.getCoffeeFileList(src, compileSettings.js["source folder"])
    grunt.config(['coffee', 'development', 'files'], filesObj)


  # --- concat:js ---
  grunt.registerTask 'update config:concat:js', 'Dymanic update grunt config for concat:js', ->

    compileSettings = grunt.config(['compileSettings'])
    # concat:js
    filesObj = {}
    for dest, src of compileSettings.js.concat
      filesObj[path.join(compileSettings.js["target folder"], dest)] = compileHelper.getConcatTaskFileList(src, dest)
    grunt.config(['concat', 'js', 'files'], filesObj)


  # Default task - development
  grunt.registerTask('default', ['production', 'watch'])

  # Production task
  grunt.registerTask('production', [
    'clean:angular_templates'
    'clean:rails_pipeline_js'
    'clean:temp_files_js'

    'copy:html'
    'jade:angular_templates'
    'slim:angular_templates'

    'copy:js'

    'update config:copy:concat_js'
    'copy:concat_js'
    'update config:coffee:development'
    'coffee:development'
    'update config:concat:js'
    'concat:js'
  ])
