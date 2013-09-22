app.directive 'mdInvitationModal', [->

  controllerAs: 'MdInvitationModalCtrl'
  controller: ['$scope', 'MpInvitation', class MdInvitationModalCtrl
    constructor: ($scope, MpInvitation) ->

      @invitationForm = {}

      $scope.$watch 'insideViewCtrl.showInvitationDialog', (newVal) =>
        @invitationForm.project_id = 'null' if newVal


      @postOnFacebook = ->
        MpInvitation.generateInvitation(@invitationForm).then (invitation) ->
          FB.ui {
            method: 'feed'
            link: "http://iwantmap.com/invitations/#{invitation.code}"
            name: 'Invitation to join iwantmap.com'
            caption: 'Join iwantmap.com to easily create travel plan with friends for free.'
            description: 'Why is creating a travel plan with friends so hard? iwantmap.com makes it easy by give you very simple abilities that are not provided by other sites. E.g. enabling you to mark multiple places on the same map, live chat with friends while searching the map.'
          }, (response) ->
            # {post_id: "720697944_10151674709142945"}
            $scope.$apply ->
              if response && response.post_id
                $scope.insideViewCtrl.showInvitationDialog = false
              else
                # post was not published
                invitation.remove()
  ]
  link: (scope, element, attrs, MdInvitationModalCtrl) ->

]
