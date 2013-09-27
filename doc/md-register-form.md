# mdFormRegister, md-form-register directive

## Usage

Minimum markup (using Slim):

    form(md-form-register name="MdFormRegisterCtrl.form" md-form-success="")
      input(ng-model="MdFormRegisterCtrl.newUser.name"     name="name"     required type="text")
      input(ng-model="MdFormRegisterCtrl.newUser.email"    name="email"    required type="email")
      input(ng-model="MdFormRegisterCtrl.newUser.password" name="password" required type="password")
      p.help-block
        | {{MdFormRegisterCtrl.formMessages.passwordError}}
      input(ng-model="MdFormRegisterCtrl.newUser.password_confirmation" name="password_confirmation" required type="password")
      p.help-block
        | {{MdFormRegisterCtrl.formMessages.passwordConfirmationError}}
      button Register

1. `help-block`: optional, but can be used to display error messages
2. `md-form-success`: the name of function registered on current scope, this will be called with `user` object returned from server as argument after form successful submitted
