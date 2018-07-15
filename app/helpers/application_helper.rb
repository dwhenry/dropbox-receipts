module ApplicationHelper
  def current_location?(options)
    unless request
      raise "You cannot use helpers that need to determine the current " \
                "page unless your view context provides a Request object " \
                "in a #request method"
    end

    return false unless request.get? || request.head?

    url_string = URI.parser.unescape(url_for(options)).force_encoding(Encoding::BINARY)

    # We ignore any extra parameters in the request_uri if the
    # submitted url doesn't have any either. This lets the function
    # work with things like ?order=asc
    request_uri = url_string.index("?") ? request.fullpath : request.path
    request_uri = URI.parser.unescape(request_uri).force_encoding(Encoding::BINARY)

    url_string.chomp!("/") if url_string.start_with?("/") && url_string != "/"

    if url_string =~ /^\w+:\/\//
      "#{request.protocol}#{request.host_with_port}#{request_uri}" =~ /#{url_string}/
    else
      request_uri =~ /#{url_string}/
    end
  end
end
