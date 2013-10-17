app.directive 'mdNoticePopItem',
['mpTemplateCache', '$compile', (mpTemplateCache, $compile) ->

  (scope, element, attrs) ->

    switch scope.notice.get('notice_type')
      when 0
        templateName = 'add-friend-request'
      when 5
        templateName = 'add-friend-request-accepted'
      when 10
        templateName = 'project-invitation'
      when 15
        templateName = 'project-invitation-accepted'
      when 16
        templateName = 'project-invitation-rejected'
      when 25
        templateName = 'new-user-added'
      when 45
        templateName = 'you-are-removed-from-project'
      when 26
        templateName = 'project-user-list-update'


    templateUrl = "/scripts/ng-components/notice/notice-pop-templates/#{templateName}.html"


    mpTemplateCache.get(templateUrl).then (template) ->
      element.html( $compile(template)(scope) )
]
