# MpUser service

## API

1. fbLogin([success][, error])
    - success: (function, optional)
    - error: (function, optional)

2. fbRegister - alias of fbLogin
3. emailLogin(user[, success])

    user: (object) must contain name and password properties

4. emailRegister(user[, success])

    user: (object) must contain name, email and password properties

5. logout([success])
6. getUser (null or User object with id, name, profile picture)
7. getId
8. getName
9. getEmail
10. getProfilePicture

## Low Level API (should be avoided to call whenever is possible)

1. $$user - property
2. $$fbLoginSuccess(authResponse[, success])
3. $$getLoginStatus([loginCallback][, notLoginCallback])
    - loginCallback(user): (function, options)
