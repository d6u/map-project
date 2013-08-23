path = require('path')
_    = require('lodash')

# Main
module.exports = (grunt) ->

  # Helpers to map files
  compileHelper = {
    getJsFileList: (concatMap, cwd) ->
      fileList = []
      for dist, src of concatMap
        if _.isArray(src)
          for filePath in src
            if grunt.file.isFile(cwd, filePath)
              if /.+(\.js)$/.test(filePath)
                fileList.push(filePath)
            else
              for subPath in grunt.file.expand({cwd: path.join(cwd, filePath)}, '**/*.js')
                fileList.push(path.join(src, subPath))
        else
          fileList.push(src)

      return fileList

    getCoffeeFileList: (pathArray, cwd) ->
      fileList = []
      for filePath in pathArray
        if grunt.file.isFile(cwd, filePath)
          if /.+(\.coffee)$/.test(filePath)
            fileList.push(path.join(cwd, filePath))
        else
          for subPath in grunt.file.expand({cwd: path.join(cwd, filePath)}, '**/*.coffee')
            fileList.push(path.join(cwd, filePath, subPath))

      return fileList

    getConcatTaskFileList: (pathArray, lastFilePath) ->
      cwd = 'tmp/grunt/js'
      fileList = []
      for filePath in pathArray
        # console.log path.join(cwd, filePath), grunt.file.isFile(cwd, filePath)
        if grunt.file.isFile(cwd, filePath)
          if /.+(\.js)$/.test(filePath)
            fileList.push(path.join(cwd, filePath))
        else if grunt.file.isDir(cwd, filePath)
          for subPath in grunt.file.expand({cwd: path.join(cwd, filePath)}, '**/*.js')
            fileList.push(path.join(cwd, filePath, subPath))

      fileList.push(path.join(cwd, lastFilePath))

      return fileList
  }


  # Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json')
    compileSettings: grunt.file.readJSON('development/app.json')

    clean:
      development: ["public/scripts", "app/assets/javascripts/**/*", "tmp/grunt"]

    copy:
      html:
        expand: true
        cwd: 'development/js'
        src: '**/*.html'
        dest: 'public/scripts/'
      js:
        expand: true
        cwd: '<%= compileSettings.js.sourceFolder %>'
        src: '<%= compileSettings.js.copy %>'
        dest: '<%= compileSettings.js.targetFolder %>'
      tmp:
        expand: true
        cwd: '<%= compileSettings.js.sourceFolder %>'
        src: ''
        dest: 'tmp/grunt/js'

    jade:
      options:
        pretty: true
      development:
        files: [{
          expand: true
          cwd: 'development/js'
          src: '**/*.jade'
          dest: 'public/scripts'
          ext: '.html'
        }]

    coffee:
      options:
        join: true
      development:
        files: []

    concat:
      options:
        separator: ';'
      development:
        files: []

    watch:
      options:
        spawn: false
        livereload: true
      development:
        files: [
          'development/js/**/*.html',
          'development/js/**/*.jade',
          'development/js/**/*.js',
          'development/js/**/*.coffee']
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
  grunt.registerTask('updateConfig', 'Dymanic update grunt config', ->
    compileSettings = grunt.config(['compileSettings'])
    # copy:tmp
    copyList = compileHelper.getJsFileList(compileSettings.js.concat, compileSettings.js.sourceFolder)
    grunt.config(['copy', 'tmp', 'src'], copyList)
    # coffee:development
    filesObj = {}
    for dest, src of compileSettings.js.concat
      filesObj[path.join('tmp/grunt/js', dest)] = compileHelper.getCoffeeFileList(src, compileSettings.js.sourceFolder)
    grunt.config(['coffee', 'development', 'files'], filesObj)
  )

  grunt.registerTask('updateConfigAfterTmpReady', 'Dymanic update grunt config when tmp folder is ready', ->
    compileSettings = grunt.config(['compileSettings'])
    # concat:development
    filesObj = {}
    for dest, src of compileSettings.js.concat
      filesObj[path.join(compileSettings.js.targetFolder, dest)] = compileHelper.getConcatTaskFileList(src, dest)
    grunt.config(['concat', 'development', 'files'], filesObj)
  )

  # Default task(s).
  grunt.registerTask('default', [
    'clean:development'
    'updateConfig'
    'copy:html'
    'copy:js'
    'copy:tmp'
    'jade:development'
    'coffee:development'
    'updateConfigAfterTmpReady'
    'concat:development'
    'watch:development'
  ])
