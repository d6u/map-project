path = require('path')
_    = require('lodash')

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
    compileSettings: grunt.file.readJSON('development/app.json')

    # --- Clean ---
    clean:
      development: ["public/scripts", "app/assets/javascripts/**/*", "tmp/grunt"]

    # --- Copy ---
    copy:
      html:
        expand: true
        cwd:  '<%= compileSettings.js.sourceFolder %>'
        src:  '**/*.html'
        dest: 'public/scripts/'
      js:
        expand: true
        cwd:  '<%= compileSettings.js.sourceFolder %>'
        src:  '<%= compileSettings.js.copy %>'
        dest: '<%= compileSettings.js.targetFolder %>'
      # tmp task settings will be update dynamically
      tmp:
        expand: true
        cwd:  '<%= compileSettings.js.sourceFolder %>'
        src:  ''
        dest: 'tmp/grunt/js'

    # --- Jade ---
    jade:
      development:
        files: [{
          expand: true
          cwd:  '<%= compileSettings.js.sourceFolder %>'
          src:  '**/*.jade'
          dest: 'public/scripts'
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
      # development task settings will be update dynamically
      development:
        files: []

    # --- Watch ---
    watch:
      options:
        spawn: false
        livereload: true
      development:
        files: [
          '<%= compileSettings.js.sourceFolder %>' + '/**/*.html'
          '<%= compileSettings.js.sourceFolder %>' + '/**/*.jade'
          '<%= compileSettings.js.sourceFolder %>' + '/**/*.js'
          '<%= compileSettings.js.sourceFolder %>' + '/**/*.coffee'
        ]
        tasks: ['default']
  })

  # Load the plugin that provides task(s).
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-contrib-jade')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-concat')
  grunt.loadNpmTasks('grunt-contrib-watch')

  # Dynamic task config
  # ----------------------------------------
  grunt.registerTask('update-config', 'Dymanic update grunt config', ->
    compileSettings = grunt.config(['compileSettings'])
    # copy:tmp
    copyList = compileHelper.getAllJsFileList(compileSettings.js.concat, compileSettings.js.sourceFolder)
    grunt.config(['copy', 'tmp', 'src'], copyList)
    # coffee:development
    filesObj = {}
    for dest, src of compileSettings.js.concat
      filesObj[path.join('tmp/grunt/js', dest)] = compileHelper.getCoffeeFileList(src, compileSettings.js.sourceFolder)
    grunt.config(['coffee', 'development', 'files'], filesObj)
  )

  grunt.registerTask('update-config-after-tmp-ready', 'Dymanic update grunt config when tmp folder is ready', ->
    compileSettings = grunt.config(['compileSettings'])
    # concat:development
    filesObj = {}
    for dest, src of compileSettings.js.concat
      filesObj[path.join(compileSettings.js.targetFolder, dest)] = compileHelper.getConcatTaskFileList(src, dest)
    grunt.config(['concat', 'development', 'files'], filesObj)
  )

  # Default task - development
  grunt.registerTask('default', [
    'clean:development'
    'update-config'
    'copy:html'
    'copy:js'
    'copy:tmp'
    'jade:development'
    'coffee:development'
    'update-config-after-tmp-ready'
    'concat:development'
    'watch:development'
  ])

  # Production task
  grunt.registerTask('production', [
    'clean:development'
    'update-config'
    'copy:html'
    'copy:js'
    'copy:tmp'
    'jade:development'
    'coffee:development'
    'update-config-after-tmp-ready'
    'concat:development'
  ])
