app.directive 'mdFormRegister', [->

  controllerAs: 'MdFormRegisterCtrl'
  controller: ['$attrs', '$scope', class MdFormRegisterCtrl
    constructor: ($attrs, $scope) ->
      # @form property will be registered through form[name=""]
      @newUser = {name: '', email: '', password: '', password_confirmation: ''}
      @formMessages = {
        nameError: ''
        emailError: ''
        passwordError: ''
        passwordConfirmationError: ''
      }

      @submit = ->
        # name
        if @form.name.$invalid
          @formMessages.nameError = 'You must have a name to register.'
        else
          @formMessages.nameError = ''

        # email
        if @form.email.$invalid
          if @form.email.$error.required
            @formMessages.emailError = 'You must have an email to register.'
          else if @form.email.$error.email
            @formMessages.emailError = 'Email address is not valid.'
        else
          @formMessages.emailError = ''

        # password
        if @form.password.$invalid
          @formMessages.passwordError = 'Password has to be at least 8 charatcters long.'
        else
          @formMessages.passwordError = ''

        # password confirmation
        if @newUser.password != @newUser.password_confirmation
          @formMessages.passwordConfirmationError = 'Password does not match confirmation.'
        else
          @formMessages.passwordConfirmationError = ''

        # sumit if form is valid
        if @form.$valid && @newUser.password == @newUser.password_confirmation
          $scope.$eval($attrs.mdFormSuccess)(@newUser, (errorData) =>
            # process server user creation error messages
            if errorData.email?
              @formMessages.emailError = 'Email address has already been taken.'
          )
  ]
  link: (scope, element, attrs, MdFormRegisterCtrl) ->
]
