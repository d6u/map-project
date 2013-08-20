path = require('path')

# Main
module.exports = (grunt) ->

  # Map jade file dest: src
  jadeFiles = grunt.file.expandMapping('**/*.jade', 'public/scripts', {
    cwd: 'app/assets/javascripts'
    rename: (dest, matchedSrcPath, options) ->
      withoutExt = /(.*)(\.jade)$/.exec(matchedSrcPath)[1]
      return path.join(dest, withoutExt+'.html')
  })

  jadeMap = {}
  jadeFiles.forEach (item) ->
    jadeMap[item.dest] = item.src

  # Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json')

    clean:
      development: ["public/scripts"]

    jade:
      development:
        options:
          pretty: true
        files: jadeMap

    copy:
      development:
        expand: true
        cwd: 'app/assets/javascripts'
        src: '**/*.html'
        dest: 'public/scripts/'

    watch:
      files: ['app/assets/javascripts/**/*.jade', 'app/assets/javascripts/**/*.html']
      tasks: ['clean', 'jade', 'copy']
      options:
        spawn: false
        livereload: true
  })

  # Load the plugin that provides task(s).
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-jade')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-contrib-watch')

  # Default task(s).
  grunt.registerTask('default', ['clean', 'jade', 'copy', 'watch'])
