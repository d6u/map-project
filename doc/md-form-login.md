# md-form-login (mdFormLogin) directive

## Usage

Minimum markup (using Slim):

    form(md-form-login md-form-success="{mothed name}" name="MdFormLoginCtrl.form" ng-submit="MdFormLoginCtrl.submit()")
      input(name="email" ng-model="MdFormLoginCtrl.user.email" required type="email")
      p
        | {{MdFormLoginCtrl.formMessages.emailError}}
      input(name="password" ng-model="MdFormLoginCtrl.user.password" required type="password" ng-minlength="8" ng-trim="false")
      p
        | {{MdFormLoginCtrl.formMessages.passwordError}}
      input(ng-model="MdFormLoginCtrl.user.remember_me" type="checkbox")
      |  Remember Me
      button Register

## Details

- `p` tag is optional, but can be used to display error messages.
- `md-form-success` attribute should be a method name that take a user object as an argument.
- The form itself only validate and display error. Once the form is valid, the object contains user data will be passed to method defined in `md-form-success`.
- `input[type="checkbox"]` will be evaluated into `true` or `false`. If server only evaluate data into string, you need to apply `ng-true-value` or `ng-false-value` and adjust server code to properly identify this field.
