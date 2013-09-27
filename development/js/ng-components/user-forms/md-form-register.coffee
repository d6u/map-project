app.directive 'mdFormRegister', ['MpUser', (MpUser) ->

  controllerAs: 'MdFormRegisterCtrl'
  controller: [class MdFormRegisterCtrl
    constructor: ->
      @newUser = {}
      @formMessages = {
        passwordError: null
        passwordConfirmationError: null
      }
  ]
  link: (scope, element, attrs, MdFormRegisterCtrl) ->
    element.on 'submit', ->
      scope.$apply ->
        # display error messages
        MdFormRegisterCtrl.formMessages.passwordError = if MdFormRegisterCtrl.newUser.password.length < 8 then "Password has to be at least 8 charatcters long." else null
        MdFormRegisterCtrl.formMessages.passwordConfirmationError = if MdFormRegisterCtrl.newUser.password != MdFormRegisterCtrl.newUser.password_confirmation then "Confirmation is not the same as password." else null
        # submit form if valid
        if MdFormRegisterCtrl.form.$valid && MdFormRegisterCtrl.formMessages.passwordError == null && MdFormRegisterCtrl.formMessages.passwordError == null
          MpUser.emailRegister MdFormRegisterCtrl.newUser, ->
            scope.$eval(attrs.mdFormSuccess)()
]
