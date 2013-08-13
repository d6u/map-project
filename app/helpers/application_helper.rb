module ApplicationHelper

  def javascript_path_with_manifest(path)
    html_string = javascript_include_tag path
    script_tags = html_string.split /\n/
    if script_tags.kind_of? Array
      paths = script_tags.map {|script_tag|
        match = /<script.*src="(.+)"><\/script>/.match(script_tag)
        "\"#{ match[1] }\""
      }
      paths.join(',').html_safe
    else
      match = /<script src="(.+)"><\/script>/.match(script_tag)
      "\"#{ match[1] }\"".html_safe
    end
  end

end
