# Angular Module: `mini-typeahead`

## Usage

Apply `mini-typeahead` directive to the input tag that you want to pop typeahead menu.

## Dependencies

Currently depend on lodash and jquery

## Required Options

Define the following attributes in

* `mini-typeahead="options"`

    `options` is an object contains the following properties:

    * watches (Array, default: []): properties on $scope to watch, when changes update the position of typeahead menu.
    * watchResize (Bool, default: true): watch window resize to adjust the position.
    * watchPosition (Bool, default: true): if true, mini typeahead will adjust position on every digest cycle. If this is enabled, `watches` option may become redundant.
    * appendTo (String, default: null): should be a valid jQuery selector. It will be used to append mini-typeahead menu to that element. Default to current element's parent.
    * listClass (String, default: 'mini-typeahead-list'): a class name for typeahead `ol`
    * itemClass (String, default: 'mini-typeahead-item'): a class name for typeahead `li`
    * cursorOnClass (String, default: 'mini-typeahead-cursor-on'): a class name that will added to `li` when cursor is on it. Cursor on could be both keyboard selection or mouse over.

* `mini-typeahead-list=""`

    A property of current $scope to generate the typeahead list. Should be an `Array`. It is used internally with `ng-repeat`.

* `mini-typeahead-change=""`

    Method on current $scope to execute when input changed with the arguments `input` and `offset`. This method will also be called when cursor changed position.

* `mini-typeahead-select=""`

    A method of current $scope to execute when typeahead item is selected, or enter key is pressed. Arguments `input` will be passed to the method.
