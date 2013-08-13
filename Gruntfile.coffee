fs = require 'fs'


getFileTree = (basePath) ->
  paths = []
  loadTree = (path) ->
    fs.readdirSync(path).forEach (child) ->
      if !/^\..*/.test(child)
        stats = fs.statSync path+'/'+child
        if /.+(\.coffee)$/.test(child) || stats.isDirectory()
          if stats.isFile()
            paths.push path+'/'+child
          else
            loadTree(path+'/'+child)

  loadTree(basePath)

  map = paths.map (path) ->
    return (new RegExp basePath+'/'+'(.+)$').exec(path)[1]

  return map


# Main
module.exports = (grunt) ->

  # Read manifest
  manifestPath = 'public/scripts/_index.json'
  manifest = grunt.file.readJSON(manifestPath)

  coffeeFiles = {}
  scriptLoadingPaths = []

  manifest.forEach (path) ->
    if /.+(\.js)$/.test path
      scriptLoadingPaths.push 'javascripts/'+path
    else
      if fs.statSync('public/scripts/'+path).isFile()
        match = /^(.+)\.coffee/.exec path
        coffeeFiles['public/javascripts/'+match[1]+'.js'] = 'public/scripts/'+path
        scriptLoadingPaths.push 'javascripts/'+match[1]+'.js'
      else
        files = getFileTree('public/scripts/'+path)
        files.forEach (file) ->
          match = /^(.+)\.coffee/.exec file
          coffeeFiles['public/javascripts/'+path+'/'+match[1]+'.js'] = 'public/scripts/'+path+'/'+file
          scriptLoadingPaths.push 'javascripts/'+path+'/'+match[1]+'.js'


  # Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json')

    clean: ["public/javascripts"]

    copy:
      main:
        expand: true
        cwd: 'public/scripts'
        src: '**/*.js'
        dest: 'public/javascripts/'

    coffee:
      compile:
        options:
          bare: true
          sourceMap: true
        files: coffeeFiles

    watch:
      files: 'public/scripts/**/*.coffee'
      tasks: ['clean', 'copy', 'coffee']
      options:
        spawn: false
        livereload: true
  })

  # Load the plugin that provides task(s).
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')

  # Default task(s).
  grunt.registerTask('default', ['clean', 'copy', 'coffee', 'watch'])

  # $script loader
  console.log '--> Include this array in $script loader\n\n', scriptLoadingPaths
