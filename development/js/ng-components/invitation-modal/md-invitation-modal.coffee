app.directive 'mdInvitationModal', [->

  controllerAs: 'MdInvitationModalCtrl'
  controller: ['$scope', 'MpInvitation', '$window', '$routeParams', class MdInvitationModalCtrl
    constructor: ($scope, MpInvitation, $window, $routeParams) ->

      @invitationForm = {}

      $scope.$watch 'insideViewCtrl.showInvitationDialog', (newVal) =>
        if newVal
          @invitationForm.project_id = if $routeParams.project_id then Number($routeParams.project_id) else ''


      @generateInvitationLink = ->
        @invitationForm.invitation_type = 0
        MpInvitation.generateInvitation(@invitationForm).then (invitation) =>
          @invitationLink = "http://iwantmap.com/invitations/#{invitation.code}"


      @postOnFacebook = ->
        @invitationForm.invitation_type = 2
        MpInvitation.generateInvitation(@invitationForm).then (invitation) ->
          FB.ui {
            method: 'feed'
            link: "http://iwantmap.com/invitations/#{invitation.code}"
            name: 'Invitation to join iwantmap.com'
            caption: 'Join iwantmap.com to easily create travel plan with friends for free.'
            description: 'Why is creating a travel plan with friends so hard? iwantmap.com makes it easy by give you very simple abilities that are not provided by other sites. E.g. enabling you to mark multiple places on the same map, live chat with friends while searching the map.'
          }, (response) ->
            # {post_id: "<some number string>"}
            $scope.$apply ->
              if response && response.post_id
                $scope.insideViewCtrl.showInvitationDialog = false
              else
                # post was not published
                invitation.remove()


      @postOnTwitter = ->
        @invitationForm.invitation_type = 3
        MpInvitation.generateInvitation(@invitationForm).then (invitation) ->
          url = "https://twitter.com/share?url=http://iwantmap.com/invitations/#{invitation.code}&text=Use iwantmap.com to create travel plan with friends in real time is easy&hashtags=iwantmap,travelplaning"
          $window.open url, '', 'height=500,width=600'
  ]
  link: (scope, element, attrs, MdInvitationModalCtrl) ->

]
