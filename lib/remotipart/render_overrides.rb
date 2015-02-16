module Remotipart
  # Responder used to automagically wrap any non-xml replies in a text-area
  # as expected by iframe-transport.
  module RenderOverrides
    include ERB::Util

    def self.included(base)
      base.class_eval do
        alias_method_chain :render, :remotipart
        alias_method_chain :head, :remotipart
      end
    end

    def render_with_remotipart(*args)
      render_without_remotipart(*args).tap do
        patch_remotipart
      end
    end

    def head_with_remotipart(*args)
      head_without_remotipart(*args).tap do
        patch_remotipart
      end
    end

    private
      def patch_remotipart
        return if !remotipart_submitted?
        textarea_body = response.content_type == 'text/html' ? html_escape(response.body) : response.body
        response.body = %{<textarea data-type=\"#{response.content_type}\" data-status=\"#{response.response_code}\" data-statusText=\"#{response.message}\">#{textarea_body}</textarea>}
        response.content_type = Mime::HTML
      end
  end
end
