module ApplicationHelper

  def javascript_path_with_manifest(path)
    html_string = javascript_include_tag path
    script_tags = html_string.split /\n/
    paths = script_tags.map {|script_tag|
      match = /<script src="(.+)"><\/script>/.match(script_tag)
      "\"#{ match[1] }\""
    }
    paths.join(',').html_safe
  end
end
