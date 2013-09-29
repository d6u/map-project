app.directive 'mdFormLogin', [->

  controllerAs: 'MdFormLoginCtrl'
  controller: ['$attrs', '$scope', class MdFormLoginCtrl
    constructor: ($attrs, $scope) ->
      # @form property will be registered through form[name=""]
      @user         = {email: '', password: '', remember_me: false}
      @formMessages = {emailError: '', passwordError: ''}

      @submit = ->
        # email
        if @form.email.$invalid
          if @form.email.$error.required
            @formMessages.emailError = "You didn't enter your email."
          else if @form.email.$error.email
            @formMessages.emailError = 'Email address is not valid'
        else
          @formMessages.emailError = ''

        # password
        if @form.password.$invalid
          if @form.password.$error.required
            @formMessages.passwordError = "You didn't enter your password."
          else if @form.password.$error.minlength
            @formMessages.passwordError = "Email and password don't match."
        else
          @formMessages.passwordError = ''

        # submit if form is valid
        if @form.$valid
          $scope.$eval($attrs.mdFormSuccess)(@user)
  ]
  link: (scope, element, attrs, MdFormLoginCtrl) ->
]
