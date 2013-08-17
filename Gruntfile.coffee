# Main
module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json')

    clean: ["public/scripts"]

    copy:
      main:
        expand: true
        cwd: 'app/assets/javascripts'
        src: '**/*.html'
        dest: 'public/scripts/'

    # coffee:
    #   compile:
    #     options:
    #       bare: true
    #       sourceMap: true
    #     files: coffeeFiles

    watch:
      files: 'app/assets/javascripts/**/*.html'
      tasks: ['clean', 'copy']
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
  grunt.registerTask('default', ['clean', 'copy', 'watch'])
  grunt.registerTask('development', ['clean', 'copy', 'coffee', 'watch'])
