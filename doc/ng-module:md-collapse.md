# Angular Module: `md-collapse`

## Usage

- Add `md-collapse` to container
- Add `ng-switch="MdCollapseCtrl.activeChild"` to container
- Add `ng-class="{'active': MdCollapseCtrl.activeChild == 0}"` to child element
- Add `ng-click="MdCollapseCtrl.activeChild = 0"` to clickable part of child element
- Add `ng-switch-when="0"` and class `.md-collapse-body-js` to the part of click element that you want to hide/show
- Change the `0` in previous steps to index of the child element

## Results

Active child element will be assigned class `.active`, you can change that in the second ng-class step of above.

The `.md-collapse-body-js` will be animated using jQuery slideDown/Up method.
