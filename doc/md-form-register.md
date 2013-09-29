# mdFormRegister, md-form-register directive

## Usage

Minimum markup (using Slim):

    form(md-form-register md-form-success="{method name}" name="MdFormRegisterCtrl.form" ng-submit="MdFormRegisterCtrl.submit()")
      input(name="name" ng-model="MdFormRegisterCtrl.newUser.name" required type="text")
      p
        | {{MdFormRegisterCtrl.formMessages.nameError}}
      input(name="email" ng-model="MdFormRegisterCtrl.newUser.email" required type="email" ng-change="")
      p
        | {{MdFormRegisterCtrl.formMessages.emailError}}
      input(name="password" ng-model="MdFormRegisterCtrl.newUser.password" required type="password" ng-minlength="8" ng-trim="false")
      p
        | {{MdFormRegisterCtrl.formMessages.passwordError}}
      input(name="password_confirmation" ng-model="MdFormRegisterCtrl.newUser.password_confirmation" required type="password" ng-trim="false")
      p
        | {{MdFormRegisterCtrl.formMessages.passwordConfirmationError}}
      button Register

## Details

- `p` tag is optional, but can be used to display error messages
- `md-form-success` attribute should be a method name that take a user object as an argument
- The form itself only validate and display error. Once the form is valid, the object contains user data will be passed to method defined in `md-form-success`
